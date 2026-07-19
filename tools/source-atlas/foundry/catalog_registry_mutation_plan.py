"""Approval-gated registry mutation planning for catalog governance drafts.

This train closes the gap between draft governance intake and active registry
mutation without silently changing the active registries. It validates that
source-specific approval artifacts are required before any source-lane, legal,
or API registry mutation can even be planned.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_REGISTRY_MUTATION_PLAN_VERSION = "source-atlas-catalog-registry-mutation-plan-train-58"
CATALOG_REGISTRY_MUTATION_PLAN_KIND = "ambitions.sourceAtlas.catalogRegistryMutationPlan.v1"
APPROVAL_KIND = "ambitions.sourceAtlas.catalogRegistryMutationApproval.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

MUTATION_PLAN_NON_CLAIMS = [
    "not active registry mutation",
    "not source authority without approval artifact",
    "not legal approval",
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
class CatalogRegistryMutationPlanOptions:
    input_path: Path
    output_root: Path
    approval_artifact: Path | None = None
    execute: bool = False
    created_at: str | None = None


def compile_catalog_registry_mutation_plan(options: CatalogRegistryMutationPlanOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload = read_json(options.input_path)
    draft_packets = _draft_packets(payload)
    input_schema_issues = _input_schema_issues(payload, draft_packets)
    input_privacy_issues = privacy_findings_for_value(payload, "catalog-registry-mutation-plan-input")
    approval_payload = read_json(options.approval_artifact) if options.approval_artifact else None
    approval_validation = _validate_approval(approval_payload, draft_packets, str(options.approval_artifact) if options.approval_artifact else "")
    approval_privacy_issues = privacy_findings_for_value(approval_payload, "catalog-registry-mutation-approval") if approval_payload is not None else []

    planned_mutations: list[dict[str, Any]] = []
    blocked_mutations: list[dict[str, Any]] = []
    approval_by_intake_id = {
        item["intake_id"]: item
        for item in approval_validation.get("approvedEntries", [])
        if isinstance(item, dict) and isinstance(item.get("intake_id"), str)
    }
    approval_valid = approval_validation["valid"] and not approval_privacy_issues

    for draft in draft_packets:
        intake_id = str(draft.get("intake_id") or "")
        approved_entry = approval_by_intake_id.get(intake_id)
        if approval_valid and approved_entry:
            planned_mutations.append(_planned_mutation(draft, approved_entry, created_at, execute=options.execute))
        else:
            blocked_mutations.append(_blocked_mutation(draft, created_at, approval_validation, approved_entry))

    planned_mutations = sorted(planned_mutations, key=lambda item: (item["domain_guess"], item["intake_id"], item["mutation_id"]))
    blocked_mutations = sorted(blocked_mutations, key=lambda item: (item["domain_guess"], item["intake_id"]))
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_REGISTRY_MUTATION_PLAN_KIND,
        "versionID": CATALOG_REGISTRY_MUTATION_PLAN_VERSION,
        "createdAt": created_at,
        "inputPath": str(options.input_path),
        "approvalArtifactPath": str(options.approval_artifact) if options.approval_artifact else "",
        "executeRequested": options.execute,
        "approvalValidation": approval_validation,
        "plannedRegistryMutations": planned_mutations,
        "blockedRegistryMutations": blocked_mutations,
        "activeRegistryMutations": [],
        "recordCounts": {
            "draftGovernancePackets": len(draft_packets),
            "plannedRegistryMutations": len(planned_mutations),
            "blockedRegistryMutations": len(blocked_mutations),
            "activeRegistryMutations": 0,
            "approvedSourceLanes": len(planned_mutations),
            "approvedLegalEntries": len(planned_mutations),
            "approvedApiPolicies": len(planned_mutations),
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": MUTATION_PLAN_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-registry-mutation-plan")
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(draft_packets), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {"name": "approval_privacy_scan_passed", "passed": not approval_privacy_issues, "issues": approval_privacy_issues},
        {
            "name": "execute_requires_approval_artifact",
            "passed": not options.execute or approval_valid,
            "issues": [] if not options.execute or approval_valid else ["--execute requires a valid catalog registry mutation approval artifact"],
        },
        {
            "name": "approval_required_for_planned_mutations",
            "passed": bool(options.approval_artifact) or not planned_mutations,
            "issues": [] if bool(options.approval_artifact) or not planned_mutations else ["planned registry mutation emitted without approval artifact"],
        },
        {
            "name": "no_active_registry_mutations_written",
            "passed": artifact["recordCounts"]["activeRegistryMutations"] == 0 and artifact["activeRegistryMutations"] == [],
            "issues": [],
        },
        {
            "name": "registry_mutation_plan_emits_no_claims",
            "passed": artifact["recordCounts"]["claims"] == 0
            and artifact["recordCounts"]["packableClaims"] == 0
            and artifact["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "unapproved_drafts_blocked",
            "passed": len(blocked_mutations) + len(planned_mutations) == len(draft_packets),
            "issues": [],
        },
        {
            "name": "planned_mutations_are_dry_run_only",
            "passed": all(item["active_registry_written"] is False for item in planned_mutations),
            "issues": [],
        },
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues, "issues": artifact_privacy_issues},
        {
            "name": "no_final_plan_schedule_step_output",
            "passed": not _contains_forbidden_output_marker(artifact),
            "issues": [] if not _contains_forbidden_output_marker(artifact) else ["forbidden final-output marker found"],
        },
    ]
    issues: list[str] = []
    issues.extend(input_schema_issues)
    issues.extend(input_privacy_issues)
    issues.extend(approval_privacy_issues)
    if options.approval_artifact is not None or options.execute:
        issues.extend(approval_validation.get("issues", []))
    issues.extend(artifact_privacy_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    # A missing approval artifact is a valid blocked plan in dry-run mode. A
    # provided malformed approval artifact is not valid because it would hide a
    # failed approval gate.
    malformed_approval = options.approval_artifact is not None and not approval_valid
    valid = not input_schema_issues and not input_privacy_issues and not artifact_privacy_issues and not malformed_approval and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogRegistryMutationPlanManifest.v1",
        "versionID": CATALOG_REGISTRY_MUTATION_PLAN_VERSION,
        "createdAt": created_at,
        "status": "Source Green for approval-gated catalog registry mutation planning" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; registry mutation planning only",
        "inputPath": str(options.input_path),
        "approvalArtifactPath": str(options.approval_artifact) if options.approval_artifact else "",
        "executeRequested": options.execute,
        "approvalValidation": approval_validation,
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogRegistryMutationPlan": str(output_root / "catalog-registry-mutation-plan.json"),
            "plannedRegistryMutations": str(output_root / "planned-registry-mutations.json"),
            "blockedRegistryMutations": str(output_root / "blocked-registry-mutations.json"),
            "activeRegistryMutations": str(output_root / "active-registry-mutations.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": MUTATION_PLAN_NON_CLAIMS,
    }

    write_json(output_root / "catalog-registry-mutation-plan.json", artifact)
    write_json(output_root / "planned-registry-mutations.json", {"plannedRegistryMutations": planned_mutations, "createdAt": created_at, "kind": "ambitions.sourceAtlas.catalogPlannedRegistryMutations.v1"})
    write_json(output_root / "blocked-registry-mutations.json", {"blockedRegistryMutations": blocked_mutations, "createdAt": created_at, "kind": "ambitions.sourceAtlas.catalogBlockedRegistryMutations.v1"})
    write_json(output_root / "active-registry-mutations.json", {"activeRegistryMutations": [], "createdAt": created_at, "kind": "ambitions.sourceAtlas.catalogActiveRegistryMutations.v1"})
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogRegistryMutationPlan": stable_hash(read_json(output_root / "catalog-registry-mutation-plan.json")),
        "plannedRegistryMutations": stable_hash(read_json(output_root / "planned-registry-mutations.json")),
        "blockedRegistryMutations": stable_hash(read_json(output_root / "blocked-registry-mutations.json")),
        "activeRegistryMutations": stable_hash(read_json(output_root / "active-registry-mutations.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_registry_mutation_plan_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_registry_mutation_plan_report(
    markdown_path: Path,
    json_path: Path,
    *,
    input_path: Path,
    output_root: Path,
    approval_artifact: Path | None = None,
    execute: bool = False,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_registry_mutation_plan(
        CatalogRegistryMutationPlanOptions(
            input_path=input_path,
            output_root=output_root,
            approval_artifact=approval_artifact,
            execute=execute,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_registry_mutation_plan_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_registry_mutation_plan_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Registry Mutation Plan Train 58",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Execute requested: {result['executeRequested']}",
        "",
        "Scope completed:",
        "- Approval-gated registry mutation planner for catalog governance draft packets.",
        "- Missing approval artifacts produce blocked mutation records, not source authority.",
        "- Planned registry mutation records remain dry-run only; active registry mutation output is empty.",
        "",
        "Counts:",
        f"- Draft governance packets: {counts['draftGovernancePackets']}",
        f"- Planned registry mutations: {counts['plannedRegistryMutations']}",
        f"- Blocked registry mutations: {counts['blockedRegistryMutations']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Approved source lanes: {counts['approvedSourceLanes']}",
        f"- Approved legal entries: {counts['approvedLegalEntries']}",
        f"- Approved API policies: {counts['approvedApiPolicies']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- No active registries are written by this planner.",
        "- No claims, packs, R2 objects, final plans, schedules, or Steps are emitted.",
        "- Approval artifacts are required before any mutation can be planned.",
        "",
        "Validation run:",
        "- See current train closeout for exact commands.",
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
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _draft_packets(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("draftGovernancePackets"), list):
        return [item for item in payload["draftGovernancePackets"] if isinstance(item, dict)]
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _input_schema_issues(payload: Any, draft_packets: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("registry mutation plan input must be an object or array")
    if not draft_packets:
        issues.append("registry mutation plan input must include draft governance packets")
    return issues


def _validate_approval(approval: Any, draft_packets: list[dict[str, Any]], approval_path: str) -> dict[str, Any]:
    if approval is None:
        return {
            "valid": False,
            "approvalArtifactProvided": False,
            "approvalArtifactPath": "",
            "approvedEntries": [],
            "selectedIntakeIDs": [],
            "issues": ["approval artifact not provided; all draft registry mutations remain blocked"],
            "nonClaims": ["missing approval is expected for blocked dry-run plans"],
        }
    issues: list[str] = []
    if not isinstance(approval, dict):
        issues.append("approval artifact must be an object")
        approval = {}
    if approval.get("kind") != APPROVAL_KIND:
        issues.append(f"approval artifact kind must be {APPROVAL_KIND}")
    if approval.get("approval_status") != "approved":
        issues.append("approval_status must be approved")
    for field in ("approval_artifact_id", "review_owner", "reviewed_at"):
        if not approval.get(field):
            issues.append(f"{field} required")
    for field in ("source_lane_review_complete", "legal_terms_review_complete", "api_governance_review_complete"):
        if approval.get(field) is not True:
            issues.append(f"{field} must be true")
    if approval.get("outside_legal_status") == "approved" and not approval.get("outside_legal_approval_artifact"):
        issues.append("outside_legal_status approved requires outside_legal_approval_artifact")
    selected = approval.get("selected_intake_ids", [])
    if not isinstance(selected, list) or not all(isinstance(item, str) and item for item in selected):
        issues.append("selected_intake_ids must be a non-empty string list")
        selected = []
    approved_entries = approval.get("approved_entries", [])
    if not isinstance(approved_entries, list):
        issues.append("approved_entries must be a list")
        approved_entries = []
    draft_ids = {str(draft.get("intake_id") or "") for draft in draft_packets}
    entry_ids: set[str] = set()
    for index, entry in enumerate(approved_entries):
        if not isinstance(entry, dict):
            issues.append(f"approved_entries[{index}] must be an object")
            continue
        entry_id = str(entry.get("intake_id") or "")
        if not entry_id:
            issues.append(f"approved_entries[{index}]: intake_id required")
        if entry_id and entry_id not in draft_ids:
            issues.append(f"{entry_id}: approved entry does not match input draft packet")
        entry_ids.add(entry_id)
        issues.extend(_approved_entry_issues(entry, f"approved_entries[{index}]"))
    for intake_id in selected:
        if intake_id not in draft_ids:
            issues.append(f"{intake_id}: selected intake id does not match input draft packet")
        if intake_id not in entry_ids:
            issues.append(f"{intake_id}: selected intake id missing approved entry")
    return {
        "valid": not issues,
        "approvalArtifactProvided": True,
        "approvalArtifactPath": approval_path,
        "approvalArtifactID": str(approval.get("approval_artifact_id") or ""),
        "reviewOwner": str(approval.get("review_owner") or ""),
        "reviewedAt": str(approval.get("reviewed_at") or ""),
        "outsideLegalStatus": str(approval.get("outside_legal_status") or "not_claimed"),
        "selectedIntakeIDs": sorted(selected),
        "approvedEntries": [entry for entry in approved_entries if isinstance(entry, dict)],
        "issues": sorted(set(issues)),
        "nonClaims": [
            "approval artifact validation does not equal outside legal approval unless outside approval artifact is present",
            "planner does not write active registries",
        ],
    }


def _approved_entry_issues(entry: dict[str, Any], label: str) -> list[str]:
    issues: list[str] = []
    source_lane = entry.get("source_lane_entry")
    legal_terms = entry.get("legal_terms_entry")
    api_policy = entry.get("api_policy_entry")
    if not isinstance(source_lane, dict):
        issues.append(f"{label}: source_lane_entry required")
        source_lane = {}
    if not isinstance(legal_terms, dict):
        issues.append(f"{label}: legal_terms_entry required")
        legal_terms = {}
    if not isinstance(api_policy, dict):
        issues.append(f"{label}: api_policy_entry required")
        api_policy = {}
    for field in ("source_id", "source_name", "source_class", "authority_class", "jurisdiction", "review_status", "r2_pack_policy"):
        if not source_lane.get(field):
            issues.append(f"{label}.source_lane_entry.{field} required")
    if source_lane.get("source_class") == "public_catalog" or source_lane.get("authority_class") == "public_catalog":
        issues.append(f"{label}: approved source lane cannot remain public_catalog source-of-sources")
    if source_lane.get("review_status") != "reviewed":
        issues.append(f"{label}: source lane review_status must be reviewed")
    if str(source_lane.get("r2_pack_policy") or "").startswith("pack_blocked"):
        issues.append(f"{label}: approved source lane cannot use blocked r2_pack_policy")
    for field in ("license_id", "license_name", "license_url", "terms_url", "rights_url", "review_owner", "reviewed_at"):
        if not legal_terms.get(field):
            issues.append(f"{label}.legal_terms_entry.{field} required")
    if legal_terms.get("redistribution_allowed") is not True:
        issues.append(f"{label}: legal_terms_entry.redistribution_allowed must be true")
    if legal_terms.get("pack_output_allowed") is not True:
        issues.append(f"{label}: legal_terms_entry.pack_output_allowed must be true")
    if legal_terms.get("review_required") is not False:
        issues.append(f"{label}: legal_terms_entry.review_required must be false")
    if legal_terms.get("outside_legal_status") == "approved" and not legal_terms.get("approval_artifact_path"):
        issues.append(f"{label}: outside legal approval requires approval_artifact_path")
    for field in ("api_policy_id", "source_id", "api_mode", "missing_key_behavior", "retry_policy", "backoff_policy", "circuit_breaker_policy", "budget_owner", "evidence_output_policy"):
        if not api_policy.get(field):
            issues.append(f"{label}.api_policy_entry.{field} required")
    if api_policy.get("live_flag_required") is not True or api_policy.get("execute_flag_required") is not True:
        issues.append(f"{label}: api policy must require live and execute flags")
    if api_policy.get("secret_redaction_required") is not True:
        issues.append(f"{label}: api policy must require secret redaction")
    return issues


def _planned_mutation(draft: dict[str, Any], approved_entry: dict[str, Any], created_at: str, *, execute: bool) -> dict[str, Any]:
    intake_id = str(draft.get("intake_id") or "")
    source_lane_entry = approved_entry["source_lane_entry"]
    legal_terms_entry = approved_entry["legal_terms_entry"]
    api_policy_entry = approved_entry["api_policy_entry"]
    return {
        "schema_version": "1.0.0",
        "mutation_id": stable_id("catalog_registry_mutation", {"intake_id": intake_id, "approved_entry": approved_entry}),
        "intake_id": intake_id,
        "candidate_id": str(draft.get("candidate_id") or ""),
        "domain_guess": str(draft.get("domain_guess") or "unclassified_public_reference"),
        "created_at": created_at,
        "execute_requested": execute,
        "status": "dry_run_ready_for_separate_registry_apply",
        "active_registry_written": False,
        "source_lane_entry": source_lane_entry,
        "legal_terms_entry": legal_terms_entry,
        "api_policy_entry": api_policy_entry,
        "blocking_reasons": [
            "planner_does_not_write_active_registries",
            "separate_registry_apply_required",
        ],
        "non_claims": [
            "planned mutation only",
            "not active registry mutation",
            "not R2 publish",
            "not claim output",
        ],
    }


def _blocked_mutation(draft: dict[str, Any], created_at: str, approval_validation: dict[str, Any], approved_entry: dict[str, Any] | None) -> dict[str, Any]:
    reasons = {
        "approval_artifact_required",
        "source_specific_review_required",
        "legal_terms_approval_required",
        "api_governance_approval_required",
        "active_registry_mutation_blocked",
    }
    if approval_validation.get("approvalArtifactProvided") and not approval_validation.get("valid"):
        reasons.add("approval_artifact_invalid")
    if approval_validation.get("approvalArtifactProvided") and approved_entry is None:
        reasons.add("not_selected_by_approval_artifact")
    reasons.update(str(reason) for reason in draft.get("blocking_reasons", []))
    return {
        "schema_version": "1.0.0",
        "intake_id": str(draft.get("intake_id") or ""),
        "candidate_id": str(draft.get("candidate_id") or ""),
        "domain_guess": str(draft.get("domain_guess") or "unclassified_public_reference"),
        "created_at": created_at,
        "status": "blocked",
        "active_registry_written": False,
        "blocking_reasons": sorted(reasons),
        "non_claims": [
            "blocked mutation only",
            "not active registry mutation",
            "not source authority",
            "not legal approval",
        ],
    }


def _contains_forbidden_output_marker(value: Any) -> bool:
    if isinstance(value, str):
        return value in FORBIDDEN_OUTPUT_MARKERS
    if isinstance(value, list):
        return any(_contains_forbidden_output_marker(item) for item in value)
    if isinstance(value, dict):
        return any(
            _contains_forbidden_output_marker(item)
            for key, item in value.items()
            if key not in {"forbidden_artifact_classes", "claim_classes_forbidden", "non_claims"}
        )
    return False
