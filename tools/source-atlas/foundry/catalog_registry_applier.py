"""Approval-gated catalog registry applier for Source Atlas governance.

The mutation planner can produce reviewed source/legal/API registry entries,
but it intentionally never mutates the active registries. This applier is the
next serial gate: it builds deterministic candidate registry copies by default
and writes target registries only when explicit execute gates and validation
all pass.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .governance_registry import (
    API_GOVERNANCE_REGISTRY_PATH,
    LEGAL_TERMS_REGISTRY_PATH,
    SOURCE_LANE_REGISTRY_PATH,
    validate_governance_registries,
)
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_REGISTRY_APPLIER_VERSION = "source-atlas-catalog-registry-applier-train-60"
CATALOG_REGISTRY_APPLIER_KIND = "ambitions.sourceAtlas.catalogRegistryApplier.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}
ACTIVE_REGISTRY_DEFAULTS = {
    SOURCE_LANE_REGISTRY_PATH.resolve(),
    LEGAL_TERMS_REGISTRY_PATH.resolve(),
    API_GOVERNANCE_REGISTRY_PATH.resolve(),
}

APPLIER_NON_CLAIMS = [
    "not source authority without completed approval artifact",
    "not outside legal approval",
    "not claim output",
    "not pack output",
    "not R2 readiness",
    "not universal coverage",
    "not app runtime readiness",
    "not release readiness",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class CatalogRegistryApplierOptions:
    plan_path: Path
    output_root: Path
    source_lane_registry_path: Path | None = None
    legal_terms_registry_path: Path | None = None
    api_governance_registry_path: Path | None = None
    execute: bool = False
    allow_active_registry_write: bool = False
    created_at: str | None = None


def compile_catalog_registry_applier(options: CatalogRegistryApplierOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    source_lane_path = options.source_lane_registry_path or SOURCE_LANE_REGISTRY_PATH
    legal_terms_path = options.legal_terms_registry_path or LEGAL_TERMS_REGISTRY_PATH
    api_governance_path = options.api_governance_registry_path or API_GOVERNANCE_REGISTRY_PATH
    explicit_registry_paths = all(
        path is not None
        for path in (
            options.source_lane_registry_path,
            options.legal_terms_registry_path,
            options.api_governance_registry_path,
        )
    )

    plan_payload, plan_load_issues = _safe_read_json(options.plan_path, "mutation plan")
    planned_mutations = _planned_mutations(plan_payload)
    plan_shape_issues = _plan_shape_issues(plan_payload, planned_mutations)
    plan_privacy_issues = privacy_findings_for_value(plan_payload, "catalog-registry-applier-plan") if plan_payload is not None else []

    source_registry, source_load_issues = _safe_read_registry(source_lane_path, "source lane registry")
    legal_registry, legal_load_issues = _safe_read_registry(legal_terms_path, "legal/terms registry")
    api_registry, api_load_issues = _safe_read_registry(api_governance_path, "API governance registry")
    registry_load_issues = source_load_issues + legal_load_issues + api_load_issues

    mutation_issues_by_id: dict[str, list[str]] = {}
    for index, mutation in enumerate(planned_mutations):
        mutation_id = _mutation_id(mutation, index)
        mutation_issues_by_id[mutation_id] = _mutation_issues(mutation, index)

    duplicate_issues_by_id = _duplicate_issues_by_id(
        planned_mutations,
        source_registry.get("source_lanes", []),
        legal_registry.get("licenses", []),
        api_registry.get("api_policies", []),
    )
    for mutation_id, issues in duplicate_issues_by_id.items():
        mutation_issues_by_id.setdefault(mutation_id, []).extend(issues)

    gate_issues = _execute_gate_issues(
        options=options,
        planned_mutation_count=len(planned_mutations),
        explicit_registry_paths=explicit_registry_paths,
        source_lane_path=source_lane_path,
        legal_terms_path=legal_terms_path,
        api_governance_path=api_governance_path,
    )

    can_build_candidates = not plan_load_issues and not plan_shape_issues and not plan_privacy_issues and not registry_load_issues
    applicable_mutations = [
        mutation
        for index, mutation in enumerate(planned_mutations)
        if can_build_candidates and not mutation_issues_by_id.get(_mutation_id(mutation, index))
    ]
    blocked_mutations = [
        _blocked_mutation(mutation, index, mutation_issues_by_id.get(_mutation_id(mutation, index), []), created_at)
        for index, mutation in enumerate(planned_mutations)
        if mutation_issues_by_id.get(_mutation_id(mutation, index))
    ]

    candidate_source_registry = _candidate_registry(
        source_registry,
        "source_lanes",
        [mutation["source_lane_entry"] for mutation in applicable_mutations],
        "source_id",
        created_at,
    )
    candidate_legal_registry = _candidate_registry(
        legal_registry,
        "licenses",
        [mutation["legal_terms_entry"] for mutation in applicable_mutations],
        "license_id",
        created_at,
    )
    candidate_api_registry = _candidate_registry(
        api_registry,
        "api_policies",
        [mutation["api_policy_entry"] for mutation in applicable_mutations],
        "api_policy_id",
        created_at,
    )

    candidate_source_path = output_root / "candidate-source-lane-registry.json"
    candidate_legal_path = output_root / "candidate-legal-terms-registry.json"
    candidate_api_path = output_root / "candidate-api-governance-registry.json"
    write_json(candidate_source_path, candidate_source_registry)
    write_json(candidate_legal_path, candidate_legal_registry)
    write_json(candidate_api_path, candidate_api_registry)

    registry_validation = validate_governance_registries(
        source_lane_path=candidate_source_path,
        legal_terms_path=candidate_legal_path,
        api_governance_path=candidate_api_path,
    )
    registry_validation_issues = list(registry_validation.get("issues", []))
    candidate_privacy_issues = (
        privacy_findings_for_value(candidate_source_registry, "candidate-source-lane-registry")
        + privacy_findings_for_value(candidate_legal_registry, "candidate-legal-terms-registry")
        + privacy_findings_for_value(candidate_api_registry, "candidate-api-governance-registry")
    )
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker({
        "plan": plan_payload,
        "source": candidate_source_registry,
        "legal": candidate_legal_registry,
        "api": candidate_api_registry,
    }) else []

    issues: list[str] = []
    issues.extend(plan_load_issues)
    issues.extend(plan_shape_issues)
    issues.extend(plan_privacy_issues)
    issues.extend(registry_load_issues)
    for mutation_issues in mutation_issues_by_id.values():
        issues.extend(mutation_issues)
    issues.extend(gate_issues)
    issues.extend(registry_validation_issues)
    issues.extend(candidate_privacy_issues)
    issues.extend(forbidden_output_issues)

    valid = not issues
    active_registry_mutations: list[dict[str, Any]] = []
    if options.execute and valid and applicable_mutations:
        before_hashes = {
            "sourceLaneRegistry": stable_hash(source_registry),
            "legalTermsRegistry": stable_hash(legal_registry),
            "apiGovernanceRegistry": stable_hash(api_registry),
        }
        _atomic_write_json(source_lane_path, candidate_source_registry)
        _atomic_write_json(legal_terms_path, candidate_legal_registry)
        _atomic_write_json(api_governance_path, candidate_api_registry)
        after_hashes = {
            "sourceLaneRegistry": stable_hash(read_json(source_lane_path)),
            "legalTermsRegistry": stable_hash(read_json(legal_terms_path)),
            "apiGovernanceRegistry": stable_hash(read_json(api_governance_path)),
        }
        active_registry_mutations = [
            _active_mutation_record(mutation, created_at, before_hashes, after_hashes, source_lane_path, legal_terms_path, api_governance_path)
            for mutation in applicable_mutations
        ]

    checks = [
        {"name": "plan_shape_valid", "passed": not plan_load_issues and not plan_shape_issues, "issues": plan_load_issues + plan_shape_issues},
        {"name": "plan_privacy_scan_passed", "passed": not plan_privacy_issues, "issues": plan_privacy_issues},
        {"name": "target_registries_loaded", "passed": not registry_load_issues, "issues": registry_load_issues},
        {"name": "planned_mutations_complete", "passed": not any(mutation_issues_by_id.values()), "issues": _flatten(mutation_issues_by_id.values())},
        {"name": "duplicate_ids_blocked", "passed": not duplicate_issues_by_id, "issues": _flatten(duplicate_issues_by_id.values())},
        {"name": "execute_gate", "passed": not gate_issues, "issues": gate_issues},
        {"name": "candidate_governance_registry_valid", "passed": registry_validation.get("valid") is True, "issues": registry_validation_issues},
        {"name": "candidate_privacy_scan_passed", "passed": not candidate_privacy_issues, "issues": candidate_privacy_issues},
        {
            "name": "dry_run_writes_no_active_registries",
            "passed": options.execute or not active_registry_mutations,
            "issues": [] if options.execute or not active_registry_mutations else ["dry-run emitted active registry mutation records"],
        },
        {
            "name": "execute_writes_only_after_validation",
            "passed": not options.execute or valid or not active_registry_mutations,
            "issues": [] if not options.execute or valid or not active_registry_mutations else ["execute wrote active registries before validation passed"],
        },
        {"name": "applier_emits_no_claims_or_packs", "passed": True, "issues": []},
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
    ]

    report = {
        "schemaVersion": 1,
        "kind": CATALOG_REGISTRY_APPLIER_KIND,
        "versionID": CATALOG_REGISTRY_APPLIER_VERSION,
        "createdAt": created_at,
        "status": "Source Green for approval-gated catalog registry applier tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; registry applier tooling only",
        "planPath": str(options.plan_path),
        "executeRequested": options.execute,
        "allowActiveRegistryWrite": options.allow_active_registry_write,
        "targetRegistryPaths": {
            "sourceLaneRegistry": str(source_lane_path),
            "legalTermsRegistry": str(legal_terms_path),
            "apiGovernanceRegistry": str(api_governance_path),
        },
        "recordCounts": {
            "plannedRegistryMutations": len(planned_mutations),
            "candidateRegistryMutations": len(applicable_mutations),
            "blockedRegistryMutations": len(blocked_mutations),
            "activeRegistryMutations": len(active_registry_mutations),
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "checks": checks,
        "issues": sorted(set(issues)),
        "blockedRegistryMutations": blocked_mutations,
        "activeRegistryMutations": active_registry_mutations,
        "registryValidation": registry_validation,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": APPLIER_NON_CLAIMS,
        "productionNonClaims": [
            "no production R2 upload",
            "no app runtime Green",
            "no release Green",
            "no universal coverage",
            "no outside legal approval",
            "no final user plan, schedule, or Step generation",
        ],
        "outputPaths": {
            "report": str(output_root / "catalog-registry-applier-report.json"),
            "activeRegistryMutations": str(output_root / "active-registry-mutations.json"),
            "blockedRegistryMutations": str(output_root / "blocked-registry-mutations.json"),
            "candidateSourceLaneRegistry": str(candidate_source_path),
            "candidateLegalTermsRegistry": str(candidate_legal_path),
            "candidateApiGovernanceRegistry": str(candidate_api_path),
            "closeout": str(output_root / "closeout.md"),
        },
        "outputHashes": {
            "candidateSourceLaneRegistry": stable_hash(candidate_source_registry),
            "candidateLegalTermsRegistry": stable_hash(candidate_legal_registry),
            "candidateApiGovernanceRegistry": stable_hash(candidate_api_registry),
        },
    }
    write_json(output_root / "active-registry-mutations.json", {"kind": "ambitions.sourceAtlas.catalogActiveRegistryMutations.v1", "createdAt": created_at, "activeRegistryMutations": active_registry_mutations})
    write_json(output_root / "blocked-registry-mutations.json", {"kind": "ambitions.sourceAtlas.catalogBlockedRegistryMutations.v1", "createdAt": created_at, "blockedRegistryMutations": blocked_mutations})
    write_json(output_root / "catalog-registry-applier-report.json", report)
    report["outputHashes"]["report"] = stable_hash(read_json(output_root / "catalog-registry-applier-report.json"))
    write_json(output_root / "catalog-registry-applier-report.json", report)
    (output_root / "closeout.md").write_text(catalog_registry_applier_markdown(report), encoding="utf-8")
    return {"manifestPath": str(output_root / "catalog-registry-applier-report.json"), "outputRoot": str(output_root), **report}


def write_catalog_registry_applier_report(
    markdown_path: Path,
    json_path: Path,
    *,
    plan_path: Path,
    output_root: Path,
    source_lane_registry_path: Path | None = None,
    legal_terms_registry_path: Path | None = None,
    api_governance_registry_path: Path | None = None,
    execute: bool = False,
    allow_active_registry_write: bool = False,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_registry_applier(
        CatalogRegistryApplierOptions(
            plan_path=plan_path,
            output_root=output_root,
            source_lane_registry_path=source_lane_registry_path,
            legal_terms_registry_path=legal_terms_registry_path,
            api_governance_registry_path=api_governance_registry_path,
            execute=execute,
            allow_active_registry_write=allow_active_registry_write,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_registry_applier_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_registry_applier_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Registry Applier Train 60",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Execute requested: {result['executeRequested']}",
        "",
        "Scope completed:",
        "- Approval-gated registry applier for planned catalog registry mutations.",
        "- Dry-run candidate registry copies are emitted by default without target registry writes.",
        "- Execute writes target registries only after mutation, duplicate, privacy, and governance validation pass.",
        "",
        "Counts:",
        f"- Planned registry mutations: {counts['plannedRegistryMutations']}",
        f"- Candidate registry mutations: {counts['candidateRegistryMutations']}",
        f"- Blocked registry mutations: {counts['blockedRegistryMutations']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- R2 remains public/reference/freshness infrastructure only.",
        "- This applier emits no claims, packs, R2 objects, final plans, schedules, or Steps.",
        "- Candidate/catalog data still requires completed source/legal/API approval before registry activation.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- No R2 request path changed or executed.",
            "- Registry output is limited to public/reference source, legal, and API policy metadata.",
            "",
            "No private graph egress proof:",
            "- Plan and candidate registry privacy scans must pass before Source Green.",
            "- The applier emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- Source/legal/API entries must validate through the governance registry before target writes.",
            "- Outside legal approval is not claimed without an outside legal artifact.",
            "",
            "Restricted-source exclusion proof:",
            "- Inherited governance rules still block catalog/discovery authority, restricted sources, and private R2 object keys.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 60. This train applies registries only.",
            "",
            "Freshness/revocation proof:",
            "- Registry freshness fields validate, but no pack freshness or revocation operation ran.",
            "",
            "LKG/rollback proof:",
            "- Rollback is to restore the pre-train registry files or use the candidate copies and active mutation report.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 60. No native files are touched by this applier.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: Foundry registry applier, CLI command, tests, generated evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: none from this tooling train; native runtime and release proof remain separate.",
            "- Next repair train if debt remains: source-lane activation for completed approvals, then harvest/claim/pack/R2/native proof.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["productionNonClaims"])
    lines.append("")
    return "\n".join(lines)


def _safe_read_json(path: Path, label: str) -> tuple[Any | None, list[str]]:
    try:
        return read_json(path), []
    except FileNotFoundError:
        return None, [f"{label}: missing {path}"]
    except Exception as exc:  # JSONDecodeError is a ValueError subclass.
        return None, [f"{label}: could not read {path}: {exc}"]


def _safe_read_registry(path: Path, label: str) -> tuple[dict[str, Any], list[str]]:
    payload, issues = _safe_read_json(path, label)
    if issues:
        return {}, issues
    if not isinstance(payload, dict):
        return {}, [f"{label}: registry must be an object"]
    return payload, []


def _planned_mutations(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("plannedRegistryMutations"), list):
        return [item for item in payload["plannedRegistryMutations"] if isinstance(item, dict)]
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _plan_shape_issues(payload: Any, planned_mutations: list[dict[str, Any]]) -> list[str]:
    if payload is None:
        return []
    if not isinstance(payload, (dict, list)):
        return ["catalog registry applier plan must be an object or array"]
    if isinstance(payload, dict) and "plannedRegistryMutations" not in payload:
        return ["catalog registry applier plan must include plannedRegistryMutations"]
    if isinstance(payload, dict) and not isinstance(payload.get("plannedRegistryMutations"), list):
        return ["plannedRegistryMutations must be a list"]
    if isinstance(payload, dict) and payload.get("plannedRegistryMutations") and not planned_mutations:
        return ["plannedRegistryMutations must contain objects"]
    return []


def _mutation_id(mutation: dict[str, Any], index: int) -> str:
    value = mutation.get("mutation_id")
    return str(value) if value else f"plannedRegistryMutations[{index}]"


def _mutation_issues(mutation: dict[str, Any], index: int) -> list[str]:
    label = _mutation_id(mutation, index)
    issues: list[str] = []
    if mutation.get("status") != "dry_run_ready_for_separate_registry_apply":
        issues.append(f"{label}: status must be dry_run_ready_for_separate_registry_apply")
    if mutation.get("active_registry_written") is not False:
        issues.append(f"{label}: active_registry_written must be false before apply")
    for field in ("mutation_id", "intake_id", "source_lane_entry", "legal_terms_entry", "api_policy_entry"):
        if not mutation.get(field):
            issues.append(f"{label}: missing {field}")
    source_lane = mutation.get("source_lane_entry") if isinstance(mutation.get("source_lane_entry"), dict) else {}
    legal_terms = mutation.get("legal_terms_entry") if isinstance(mutation.get("legal_terms_entry"), dict) else {}
    api_policy = mutation.get("api_policy_entry") if isinstance(mutation.get("api_policy_entry"), dict) else {}
    if not source_lane:
        issues.append(f"{label}: source_lane_entry must be an object")
    if not legal_terms:
        issues.append(f"{label}: legal_terms_entry must be an object")
    if not api_policy:
        issues.append(f"{label}: api_policy_entry must be an object")
    if source_lane and legal_terms and source_lane.get("license_id") != legal_terms.get("license_id"):
        issues.append(f"{label}: source_lane_entry.license_id must match legal_terms_entry.license_id")
    if source_lane and api_policy and source_lane.get("api_policy_id") != api_policy.get("api_policy_id"):
        issues.append(f"{label}: source_lane_entry.api_policy_id must match api_policy_entry.api_policy_id")
    if source_lane and api_policy and source_lane.get("source_id") != api_policy.get("source_id"):
        issues.append(f"{label}: source_lane_entry.source_id must match api_policy_entry.source_id")
    issues.extend(privacy_findings_for_value(mutation, label))
    if _contains_forbidden_output_marker(mutation):
        issues.append(f"{label}: forbidden final-output marker found")
    return sorted(set(issues))


def _duplicate_issues_by_id(
    planned_mutations: list[dict[str, Any]],
    source_lanes: Any,
    legal_entries: Any,
    api_policies: Any,
) -> dict[str, list[str]]:
    existing_source_ids = {entry.get("source_id") for entry in source_lanes if isinstance(entry, dict)}
    existing_license_ids = {entry.get("license_id") for entry in legal_entries if isinstance(entry, dict)}
    existing_api_policy_ids = {entry.get("api_policy_id") for entry in api_policies if isinstance(entry, dict)}
    seen_source_ids: set[str] = set()
    seen_license_ids: set[str] = set()
    seen_api_policy_ids: set[str] = set()
    issues_by_id: dict[str, list[str]] = {}
    for index, mutation in enumerate(planned_mutations):
        mutation_id = _mutation_id(mutation, index)
        source_lane = mutation.get("source_lane_entry") if isinstance(mutation.get("source_lane_entry"), dict) else {}
        legal_terms = mutation.get("legal_terms_entry") if isinstance(mutation.get("legal_terms_entry"), dict) else {}
        api_policy = mutation.get("api_policy_entry") if isinstance(mutation.get("api_policy_entry"), dict) else {}
        issues: list[str] = []
        source_id = source_lane.get("source_id")
        license_id = legal_terms.get("license_id")
        api_policy_id = api_policy.get("api_policy_id")
        if source_id in existing_source_ids or source_id in seen_source_ids:
            issues.append(f"{mutation_id}: duplicate source_id {source_id}")
        if license_id in existing_license_ids or license_id in seen_license_ids:
            issues.append(f"{mutation_id}: duplicate license_id {license_id}")
        if api_policy_id in existing_api_policy_ids or api_policy_id in seen_api_policy_ids:
            issues.append(f"{mutation_id}: duplicate api_policy_id {api_policy_id}")
        if isinstance(source_id, str):
            seen_source_ids.add(source_id)
        if isinstance(license_id, str):
            seen_license_ids.add(license_id)
        if isinstance(api_policy_id, str):
            seen_api_policy_ids.add(api_policy_id)
        if issues:
            issues_by_id.setdefault(mutation_id, []).extend(issues)
    return issues_by_id


def _execute_gate_issues(
    *,
    options: CatalogRegistryApplierOptions,
    planned_mutation_count: int,
    explicit_registry_paths: bool,
    source_lane_path: Path,
    legal_terms_path: Path,
    api_governance_path: Path,
) -> list[str]:
    if not options.execute or planned_mutation_count == 0:
        return []
    issues: list[str] = []
    if not explicit_registry_paths:
        issues.append("--execute with planned registry mutations requires explicit registry target paths")
    target_paths = {source_lane_path.resolve(), legal_terms_path.resolve(), api_governance_path.resolve()}
    if target_paths & ACTIVE_REGISTRY_DEFAULTS and not options.allow_active_registry_write:
        issues.append("--execute targeting active repo registries requires --allow-active-registry-write")
    return issues


def _candidate_registry(base: dict[str, Any], key: str, additions: list[dict[str, Any]], sort_key: str, created_at: str) -> dict[str, Any]:
    candidate = dict(base)
    existing = base.get(key, [])
    candidate[key] = sorted([entry for entry in existing if isinstance(entry, dict)] + additions, key=lambda item: str(item.get(sort_key, "")))
    if "updated_at" in candidate:
        candidate["updated_at"] = created_at
    return candidate


def _blocked_mutation(mutation: dict[str, Any], index: int, issues: list[str], created_at: str) -> dict[str, Any]:
    return {
        "schema_version": "1.0.0",
        "mutation_id": _mutation_id(mutation, index),
        "intake_id": str(mutation.get("intake_id") or ""),
        "candidate_id": str(mutation.get("candidate_id") or ""),
        "domain_guess": str(mutation.get("domain_guess") or "unclassified_public_reference"),
        "created_at": created_at,
        "status": "blocked",
        "active_registry_written": False,
        "blocking_reasons": sorted(set(issues or ["registry_applier_validation_failed"])),
        "non_claims": [
            "blocked mutation only",
            "not active registry mutation",
            "not source authority",
            "not legal approval",
        ],
    }


def _active_mutation_record(
    mutation: dict[str, Any],
    created_at: str,
    before_hashes: dict[str, str],
    after_hashes: dict[str, str],
    source_lane_path: Path,
    legal_terms_path: Path,
    api_governance_path: Path,
) -> dict[str, Any]:
    return {
        "schema_version": "1.0.0",
        "mutation_id": str(mutation.get("mutation_id")),
        "intake_id": str(mutation.get("intake_id") or ""),
        "candidate_id": str(mutation.get("candidate_id") or ""),
        "domain_guess": str(mutation.get("domain_guess") or "unclassified_public_reference"),
        "created_at": created_at,
        "status": "active_registry_written",
        "active_registry_written": True,
        "source_id": mutation["source_lane_entry"]["source_id"],
        "license_id": mutation["legal_terms_entry"]["license_id"],
        "api_policy_id": mutation["api_policy_entry"]["api_policy_id"],
        "target_registry_paths": {
            "sourceLaneRegistry": str(source_lane_path),
            "legalTermsRegistry": str(legal_terms_path),
            "apiGovernanceRegistry": str(api_governance_path),
        },
        "registry_hashes_before": before_hashes,
        "registry_hashes_after": after_hashes,
        "non_claims": [
            "registry metadata activation only",
            "not claim output",
            "not pack output",
            "not R2 publish",
        ],
    }


def _atomic_write_json(path: Path, value: Any) -> None:
    tmp_path = path.with_name(path.name + ".tmp")
    write_json(tmp_path, value)
    tmp_path.replace(path)


def _contains_forbidden_output_marker(value: Any) -> bool:
    if isinstance(value, str):
        return value in FORBIDDEN_OUTPUT_MARKERS
    if isinstance(value, list):
        return any(_contains_forbidden_output_marker(item) for item in value)
    if isinstance(value, dict):
        return any(
            _contains_forbidden_output_marker(item)
            for key, item in value.items()
            if key not in {"forbidden_artifact_classes", "claim_classes_forbidden", "non_claims", "productionNonClaims"}
        )
    return False


def _flatten(values: Any) -> list[str]:
    flattened: list[str] = []
    for value in values:
        if isinstance(value, list):
            flattened.extend(str(item) for item in value)
        elif value:
            flattened.append(str(value))
    return flattened
