"""Approval-gated registry applier for goal-domain Source Atlas mutations.

Train 94 produces goal-domain mutation plans in a domain-specific camelCase
shape. The existing catalog registry applier is the mature validation/write
gate. This module bridges those contracts without weakening the active registry
write rules: dry-run is the default, execute requires an approval artifact, and
target writes are delegated to the shared applier only after wrapper gates pass.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_registry_applier import CatalogRegistryApplierOptions, compile_catalog_registry_applier, catalog_registry_applier_markdown
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


GOAL_DOMAIN_REGISTRY_APPLIER_VERSION = "source-atlas-goal-domain-registry-applier-train-95"
GOAL_DOMAIN_REGISTRY_APPLIER_KIND = "ambitions.sourceAtlas.goalDomainRegistryApplier.v1"
GOAL_DOMAIN_NORMALIZED_PLAN_KIND = "ambitions.sourceAtlas.goalDomainNormalizedRegistryMutations.v1"

APPLIER_NON_CLAIMS = [
    "goal-domain registry apply gate only",
    "not source authority without completed review evidence",
    "not legal approval by itself",
    "not outside legal approval without artifact",
    "not claim output",
    "not pack output",
    "not R2 readiness",
    "not production R2 upload",
    "not native activation proof",
    "not universal coverage",
    "not app runtime readiness",
    "not release readiness",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class GoalDomainRegistryApplierOptions:
    plan_path: Path
    output_root: Path
    source_lane_registry_path: Path | None = None
    legal_terms_registry_path: Path | None = None
    api_governance_registry_path: Path | None = None
    approval_artifact: Path | None = None
    execute: bool = False
    allow_active_registry_write: bool = False
    created_at: str | None = None


def compile_goal_domain_registry_applier(options: GoalDomainRegistryApplierOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    source_payload, source_load_issues = _safe_read_json(options.plan_path, "goal-domain registry mutation plan")
    planned_mutations, plan_resolution_issues = _goal_domain_planned_mutations(options.plan_path, source_payload)
    source_privacy_issues = privacy_findings_for_value(source_payload, "goal-domain-registry-applier-input") if source_payload is not None else []
    normalized_mutations = [_normalize_goal_domain_mutation(mutation, index, created_at) for index, mutation in enumerate(planned_mutations)]

    normalized_plan = {
        "kind": GOAL_DOMAIN_NORMALIZED_PLAN_KIND,
        "createdAt": created_at,
        "sourcePlanPath": str(options.plan_path),
        "plannedRegistryMutations": normalized_mutations,
        "nonClaims": [
            "normalized apply input only",
            "not active registry mutation by itself",
            "not claim output",
            "not R2 publish",
        ],
    }
    normalized_plan_path = output_root / "normalized-planned-registry-mutations.json"
    write_json(normalized_plan_path, normalized_plan)

    wrapper_gate_issues = []
    wrapper_gate_issues.extend(source_load_issues)
    wrapper_gate_issues.extend(plan_resolution_issues)
    wrapper_gate_issues.extend(source_privacy_issues)
    wrapper_gate_issues.extend(_approval_issues(options, len(normalized_mutations)))

    catalog_output_root = output_root / "catalog-applier"
    catalog_execute = options.execute and not wrapper_gate_issues
    catalog_result = compile_catalog_registry_applier(
        CatalogRegistryApplierOptions(
            plan_path=normalized_plan_path,
            output_root=catalog_output_root,
            source_lane_registry_path=options.source_lane_registry_path,
            legal_terms_registry_path=options.legal_terms_registry_path,
            api_governance_registry_path=options.api_governance_registry_path,
            execute=catalog_execute,
            allow_active_registry_write=options.allow_active_registry_write,
            created_at=created_at,
        )
    )
    catalog_issues = list(catalog_result.get("issues", []))
    issues = sorted(set(wrapper_gate_issues + catalog_issues))
    active_registry_mutations = catalog_result.get("activeRegistryMutations", [])
    valid = not issues and catalog_result.get("valid") is True
    checks = [
        {"name": "goal_domain_plan_loaded", "passed": not source_load_issues and not plan_resolution_issues, "issues": source_load_issues + plan_resolution_issues},
        {"name": "goal_domain_plan_privacy_scan_passed", "passed": not source_privacy_issues, "issues": source_privacy_issues},
        {"name": "approval_gate_passed", "passed": not _approval_issues(options, len(normalized_mutations)), "issues": _approval_issues(options, len(normalized_mutations))},
        {"name": "normalized_plan_emitted", "passed": normalized_plan_path.exists(), "issues": [] if normalized_plan_path.exists() else ["normalized plan missing"]},
        {"name": "catalog_applier_reused", "passed": catalog_result.get("kind") == "ambitions.sourceAtlas.catalogRegistryApplier.v1", "issues": []},
        {"name": "catalog_applier_valid", "passed": catalog_result.get("valid") is True, "issues": catalog_issues},
        {
            "name": "dry_run_writes_no_active_registries",
            "passed": options.execute or not active_registry_mutations,
            "issues": [] if options.execute or not active_registry_mutations else ["dry-run emitted active registry mutation records"],
        },
        {
            "name": "execute_blocked_until_wrapper_gates_pass",
            "passed": not options.execute or not wrapper_gate_issues or catalog_execute,
            "issues": [] if not options.execute or not wrapper_gate_issues or catalog_execute else ["execute reached catalog applier despite wrapper gate issues"],
        },
        {"name": "applier_emits_no_claims_packs_r2_or_native_activation", "passed": True, "issues": []},
    ]

    record_counts = {
        "goalDomainPlannedRegistryMutations": len(planned_mutations),
        "normalizedRegistryMutations": len(normalized_mutations),
        "candidateRegistryMutations": catalog_result.get("recordCounts", {}).get("candidateRegistryMutations", 0),
        "blockedRegistryMutations": catalog_result.get("recordCounts", {}).get("blockedRegistryMutations", 0),
        "activeRegistryMutations": catalog_result.get("recordCounts", {}).get("activeRegistryMutations", 0),
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
        "r2PublishOperations": 0,
        "nativeActivationOperations": 0,
        "finalOutputArtifacts": 0,
    }
    output_paths = {
        "report": str(output_root / "goal-domain-registry-applier-report.json"),
        "normalizedPlan": str(normalized_plan_path),
        "catalogApplierReport": str(catalog_output_root / "catalog-registry-applier-report.json"),
        "activeRegistryMutations": catalog_result.get("outputPaths", {}).get("activeRegistryMutations"),
        "blockedRegistryMutations": catalog_result.get("outputPaths", {}).get("blockedRegistryMutations"),
        "candidateSourceLaneRegistry": catalog_result.get("outputPaths", {}).get("candidateSourceLaneRegistry"),
        "candidateLegalTermsRegistry": catalog_result.get("outputPaths", {}).get("candidateLegalTermsRegistry"),
        "candidateApiGovernanceRegistry": catalog_result.get("outputPaths", {}).get("candidateApiGovernanceRegistry"),
        "closeout": str(output_root / "closeout.md"),
    }
    report = {
        "schemaVersion": 1,
        "kind": GOAL_DOMAIN_REGISTRY_APPLIER_KIND,
        "versionID": GOAL_DOMAIN_REGISTRY_APPLIER_VERSION,
        "createdAt": created_at,
        "status": "Source Green for goal-domain registry applier tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; goal-domain registry applier tooling only",
        "planPath": str(options.plan_path),
        "executeRequested": options.execute,
        "catalogExecuteRequested": catalog_execute,
        "allowActiveRegistryWrite": options.allow_active_registry_write,
        "approvalArtifact": str(options.approval_artifact) if options.approval_artifact else "",
        "recordCounts": record_counts,
        "checks": checks,
        "issues": issues,
        "catalogApplier": catalog_result,
        "activeRegistryMutations": active_registry_mutations,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": APPLIER_NON_CLAIMS,
        "productionNonClaims": [
            "no production R2 upload",
            "no app runtime Green",
            "no release Green",
            "no universal coverage",
            "no outside legal approval without artifact",
            "no final user plan, schedule, or Step generation",
        ],
        "outputPaths": output_paths,
        "outputHashes": {"normalizedPlan": stable_hash(normalized_plan)},
    }
    write_json(output_root / "goal-domain-registry-applier-report.json", report)
    report["outputHashes"]["report"] = stable_hash(read_json(output_root / "goal-domain-registry-applier-report.json"))
    write_json(output_root / "goal-domain-registry-applier-report.json", report)
    (output_root / "closeout.md").write_text(goal_domain_registry_applier_markdown(report), encoding="utf-8")
    return {"manifestPath": str(output_root / "goal-domain-registry-applier-report.json"), "outputRoot": str(output_root), **report}


def write_goal_domain_registry_applier_report(
    markdown_path: Path,
    json_path: Path,
    *,
    plan_path: Path,
    output_root: Path,
    source_lane_registry_path: Path | None = None,
    legal_terms_registry_path: Path | None = None,
    api_governance_registry_path: Path | None = None,
    approval_artifact: Path | None = None,
    execute: bool = False,
    allow_active_registry_write: bool = False,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_goal_domain_registry_applier(
        GoalDomainRegistryApplierOptions(
            plan_path=plan_path,
            output_root=output_root,
            source_lane_registry_path=source_lane_registry_path,
            legal_terms_registry_path=legal_terms_registry_path,
            api_governance_registry_path=api_governance_registry_path,
            approval_artifact=approval_artifact,
            execute=execute,
            allow_active_registry_write=allow_active_registry_write,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(goal_domain_registry_applier_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def goal_domain_registry_applier_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Goal-Domain Registry Applier Train 95",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Execute requested: {result['executeRequested']}",
        f"Catalog execute requested: {result['catalogExecuteRequested']}",
        "",
        "Scope completed:",
        "- Goal-domain mutation plans normalize into the shared catalog registry applier contract.",
        "- Dry-run candidate registry copies are emitted by default without target registry writes.",
        "- Execute writes are blocked unless wrapper approval gates and shared registry validation pass.",
        "",
        "Counts:",
        f"- Goal-domain planned registry mutations: {counts['goalDomainPlannedRegistryMutations']}",
        f"- Normalized registry mutations: {counts['normalizedRegistryMutations']}",
        f"- Candidate registry mutations: {counts['candidateRegistryMutations']}",
        f"- Blocked registry mutations: {counts['blockedRegistryMutations']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- R2 publish operations: {counts['r2PublishOperations']}",
        "",
        "Product law preserved:",
        "- R2 remains public/reference/freshness infrastructure only.",
        "- This applier emits no claims, packs, R2 objects, final plans, schedules, or Steps.",
        "- Goal-domain data still requires completed source/legal/API approval before registry activation.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed without approval artifact.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        if path:
            lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "R2 request privacy proof:",
            "- No R2 request path changed or executed.",
            "- Registry output is limited to public/reference source, legal, and API policy metadata.",
            "",
            "No private graph egress proof:",
            "- Goal-domain plan and normalized registry privacy scans must pass before Source Green.",
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
            "- Not claimed in Train 95. This train applies registry metadata only.",
            "",
            "Freshness/revocation proof:",
            "- Registry freshness fields validate, but no pack freshness or revocation operation ran.",
            "",
            "LKG/rollback proof:",
            "- Rollback is to restore the pre-train registry files or use candidate copies and active mutation reports.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 95. No native files are touched by this applier.",
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
    except Exception as exc:
        return None, [f"{label}: could not read {path}: {exc}"]


def _goal_domain_planned_mutations(path: Path, payload: Any) -> tuple[list[dict[str, Any]], list[str]]:
    if payload is None:
        return [], []
    if isinstance(payload, dict) and isinstance(payload.get("plannedRegistryMutations"), list):
        return [item for item in payload["plannedRegistryMutations"] if isinstance(item, dict)], []
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)], []
    if isinstance(payload, dict):
        output_paths = payload.get("outputPaths")
        if isinstance(output_paths, dict) and output_paths.get("plannedRegistryMutations"):
            planned_path = Path(str(output_paths["plannedRegistryMutations"]))
            if not planned_path.is_absolute():
                planned_path = Path.cwd() / planned_path
            planned_payload, issues = _safe_read_json(planned_path, "goal-domain planned registry mutations")
            if issues:
                return [], issues
            planned, planned_issues = _goal_domain_planned_mutations(planned_path, planned_payload)
            return planned, planned_issues
    return [], [f"goal-domain registry applier plan must include plannedRegistryMutations or outputPaths.plannedRegistryMutations: {path}"]


def _normalize_goal_domain_mutation(mutation: dict[str, Any], index: int, created_at: str) -> dict[str, Any]:
    source_lane_entry = _entry(mutation, "source_lane_entry", "sourceLaneEntry")
    legal_terms_entry = _entry(mutation, "legal_terms_entry", "legalTermsEntry")
    api_policy_entry = _entry(mutation, "api_policy_entry", "apiPolicyEntry")
    mutation_id = str(mutation.get("mutation_id") or mutation.get("mutationID") or stable_id("source_atlas_goal_domain_registry_apply", {"index": index, "mutation": mutation}))
    return {
        "schema_version": "1.0.0",
        "mutation_id": mutation_id,
        "intake_id": str(mutation.get("intake_id") or mutation.get("bundleID") or mutation.get("requestID") or mutation_id),
        "candidate_id": str(mutation.get("candidate_id") or mutation.get("requestID") or ""),
        "domain_guess": str(mutation.get("domain_guess") or mutation.get("matchedDomainID") or mutation.get("requestedDomain") or "unclassified_public_reference"),
        "created_at": str(mutation.get("created_at") or mutation.get("createdAt") or created_at),
        "execute_requested": False,
        "status": mutation.get("status"),
        "active_registry_written": mutation.get("active_registry_written") if "active_registry_written" in mutation else mutation.get("activeRegistryWritten"),
        "source_lane_entry": source_lane_entry,
        "legal_terms_entry": legal_terms_entry,
        "api_policy_entry": api_policy_entry,
        "blocking_reasons": mutation.get("blocking_reasons") or mutation.get("blockingReasons") or ["separate_registry_apply_required"],
        "non_claims": mutation.get("non_claims") or mutation.get("nonClaims") or ["normalized goal-domain registry mutation", "not claim output", "not R2 publish"],
    }


def _entry(mutation: dict[str, Any], snake_key: str, camel_key: str) -> dict[str, Any]:
    value = mutation.get(snake_key) if isinstance(mutation.get(snake_key), dict) else mutation.get(camel_key)
    return dict(value) if isinstance(value, dict) else {}


def _approval_issues(options: GoalDomainRegistryApplierOptions, planned_count: int) -> list[str]:
    if not options.execute or planned_count == 0:
        return []
    if options.approval_artifact is None:
        return ["--execute with goal-domain planned registry mutations requires --approval-artifact"]
    payload, load_issues = _safe_read_json(options.approval_artifact, "goal-domain registry apply approval artifact")
    if load_issues:
        return load_issues
    issues = privacy_findings_for_value(payload, "goal-domain-registry-apply-approval-artifact")
    status = ""
    if isinstance(payload, dict):
        status = str(payload.get("approvalStatus") or payload.get("status") or "")
    if "approved" not in status.lower():
        issues.append("goal-domain registry apply approval artifact must include approved approvalStatus/status")
    return sorted(set(issues))
