"""Final approval gate for catalog terms-resolution proposals.

Terms-resolution proposals can fill in reviewable license and terms URLs, but
they are still not approval artifacts. This module accepts an explicit reviewer
decision artifact and emits a planner-ready registry mutation approval only
when source-lane, legal/terms, and API-governance entries are complete.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_registry_mutation_plan import APPROVAL_KIND
from .governance_registry import (
    AUTHORITY_CLASSES,
    PACK_ALLOWED_POLICIES,
    R2_PACK_POLICIES,
    REDISTRIBUTION_POLICIES,
    REVIEW_STATUSES,
    SOURCE_OF_SOURCES_CLASSES,
)
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, object_key_findings, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_APPROVAL_FINALIZER_VERSION = "source-atlas-catalog-approval-finalizer-train-62"
CATALOG_APPROVAL_FINALIZER_KIND = "ambitions.sourceAtlas.catalogApprovalFinalizer.v1"
DECISION_KIND = "ambitions.sourceAtlas.catalogApprovalFinalizerDecision.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

FINALIZER_NON_CLAIMS = [
    "not legal approval by itself",
    "not outside legal approval without outside approval artifact",
    "not source authority without completed reviewer decision",
    "not active registry mutation",
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
class CatalogApprovalFinalizerOptions:
    terms_proposals_path: Path
    output_root: Path
    decision_artifact: Path | None = None
    created_at: str | None = None


def compile_catalog_approval_finalizer(options: CatalogApprovalFinalizerOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload = read_json(options.terms_proposals_path)
    proposals = _terms_resolution_proposals(payload)
    input_schema_issues = _input_schema_issues(payload, proposals)
    input_privacy_issues = privacy_findings_for_value(payload, "catalog-approval-finalizer-input")

    decision_payload = read_json(options.decision_artifact) if options.decision_artifact else None
    decision_validation = _validate_decision(decision_payload, proposals, str(options.decision_artifact) if options.decision_artifact else "")
    decision_privacy_issues = (
        privacy_findings_for_value(decision_payload, "catalog-approval-finalizer-decision")
        if decision_payload is not None
        else []
    )
    decision_valid = decision_validation["valid"] and not decision_privacy_issues

    completed_artifacts = [_completed_approval_artifact(decision_validation, created_at)] if decision_valid else []
    selected_proposal_ids = set(decision_validation.get("selectedProposalIDs", [])) if decision_valid else set()
    blocked_finalizations = [
        _blocked_finalization(proposal, created_at, decision_validation, selected=proposal["proposal_id"] in selected_proposal_ids)
        for proposal in proposals
        if proposal["proposal_id"] not in selected_proposal_ids
        or not decision_valid
    ]
    blocked_finalizations = sorted(blocked_finalizations, key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"]))

    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_APPROVAL_FINALIZER_KIND,
        "versionID": CATALOG_APPROVAL_FINALIZER_VERSION,
        "createdAt": created_at,
        "termsProposalsPath": str(options.terms_proposals_path),
        "decisionArtifactPath": str(options.decision_artifact) if options.decision_artifact else "",
        "decisionValidation": decision_validation,
        "completedApprovalArtifacts": completed_artifacts,
        "blockedApprovalFinalizations": blocked_finalizations,
        "activeRegistryMutations": [],
        "recordCounts": {
            "termsResolutionProposals": len(proposals),
            "completedApprovalArtifacts": len(completed_artifacts),
            "approvedEntries": sum(len(item["approved_entries"]) for item in completed_artifacts),
            "approvedSourceLanes": sum(len(item["approved_entries"]) for item in completed_artifacts),
            "approvedLegalEntries": sum(len(item["approved_entries"]) for item in completed_artifacts),
            "approvedApiPolicies": sum(len(item["approved_entries"]) for item in completed_artifacts),
            "blockedApprovalFinalizations": len(blocked_finalizations),
            "activeRegistryMutations": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": FINALIZER_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-approval-finalizer")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    completed_contract_issues = _completed_contract_issues(completed_artifacts)
    decision_issues_for_checks = decision_validation["issues"] if options.decision_artifact else []

    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(proposals), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {"name": "decision_privacy_scan_passed", "passed": not decision_privacy_issues, "issues": decision_privacy_issues},
        {
            "name": "decision_required_for_completed_approvals",
            "passed": bool(options.decision_artifact) or not completed_artifacts,
            "issues": [] if bool(options.decision_artifact) or not completed_artifacts else ["completed approval emitted without decision artifact"],
        },
        {
            "name": "provided_decision_valid",
            "passed": options.decision_artifact is None or decision_valid,
            "issues": decision_issues_for_checks + decision_privacy_issues,
        },
        {
            "name": "completed_approval_artifacts_match_planner_contract",
            "passed": not completed_contract_issues,
            "issues": completed_contract_issues,
        },
        {
            "name": "unfinalized_proposals_blocked",
            "passed": len(blocked_finalizations) + len(selected_proposal_ids) == len(proposals),
            "issues": [],
        },
        {
            "name": "approval_finalizer_emits_no_claims",
            "passed": artifact["recordCounts"]["claims"] == 0
            and artifact["recordCounts"]["packableClaims"] == 0
            and artifact["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {"name": "no_active_registry_mutations", "passed": artifact["recordCounts"]["activeRegistryMutations"] == 0, "issues": []},
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues, "issues": artifact_privacy_issues},
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
    ]
    issues: list[str] = []
    issues.extend(input_schema_issues)
    issues.extend(input_privacy_issues)
    issues.extend(decision_privacy_issues)
    if options.decision_artifact:
        issues.extend(decision_validation["issues"])
    issues.extend(completed_contract_issues)
    issues.extend(artifact_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    planner_approval_artifact = completed_artifacts[0] if completed_artifacts else {
        "kind": "ambitions.sourceAtlas.catalogRegistryMutationApprovalUnavailable.v1",
        "created_at": created_at,
        "reason": "decision artifact required before planner approval is available",
        "non_claims": ["placeholder only", "not an approval artifact"],
    }
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogApprovalFinalizerManifest.v1",
        "versionID": CATALOG_APPROVAL_FINALIZER_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog approval finalizer tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; approval finalizer tooling only",
        "termsProposalsPath": str(options.terms_proposals_path),
        "decisionArtifactPath": str(options.decision_artifact) if options.decision_artifact else "",
        "decisionValidation": decision_validation,
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogApprovalFinalizer": str(output_root / "catalog-approval-finalizer.json"),
            "completedApprovalArtifacts": str(output_root / "completed-approval-artifacts.json"),
            "plannerApprovalArtifact": str(output_root / "catalog-registry-mutation-approval.json"),
            "blockedApprovalFinalizations": str(output_root / "blocked-approval-finalizations.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": FINALIZER_NON_CLAIMS,
    }

    write_json(output_root / "catalog-approval-finalizer.json", artifact)
    write_json(
        output_root / "completed-approval-artifacts.json",
        {
            "kind": "ambitions.sourceAtlas.catalogCompletedApprovalArtifacts.v1",
            "createdAt": created_at,
            "completedApprovalArtifacts": completed_artifacts,
        },
    )
    write_json(output_root / "catalog-registry-mutation-approval.json", planner_approval_artifact)
    write_json(
        output_root / "blocked-approval-finalizations.json",
        {
            "kind": "ambitions.sourceAtlas.catalogBlockedApprovalFinalizations.v1",
            "createdAt": created_at,
            "blockedApprovalFinalizations": blocked_finalizations,
        },
    )
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogApprovalFinalizer": stable_hash(read_json(output_root / "catalog-approval-finalizer.json")),
        "completedApprovalArtifacts": stable_hash(read_json(output_root / "completed-approval-artifacts.json")),
        "plannerApprovalArtifact": stable_hash(read_json(output_root / "catalog-registry-mutation-approval.json")),
        "blockedApprovalFinalizations": stable_hash(read_json(output_root / "blocked-approval-finalizations.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_approval_finalizer_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_approval_finalizer_report(
    markdown_path: Path,
    json_path: Path,
    *,
    terms_proposals_path: Path,
    output_root: Path,
    decision_artifact: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_approval_finalizer(
        CatalogApprovalFinalizerOptions(
            terms_proposals_path=terms_proposals_path,
            output_root=output_root,
            decision_artifact=decision_artifact,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_approval_finalizer_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_approval_finalizer_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Approval Finalizer Train 62",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Decision artifact path: {result['decisionArtifactPath'] or 'not provided'}",
        "",
        "Scope completed:",
        "- Final approval gate for catalog terms-resolution proposals.",
        "- Completed approval artifacts are emitted only from explicit complete reviewer decision artifacts.",
        "- Missing or incomplete decisions produce blocked finalization records, not source authority.",
        "",
        "Counts:",
        f"- Terms-resolution proposals: {counts['termsResolutionProposals']}",
        f"- Completed approval artifacts: {counts['completedApprovalArtifacts']}",
        f"- Approved entries: {counts['approvedEntries']}",
        f"- Blocked approval finalizations: {counts['blockedApprovalFinalizations']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- No claims, packs, active registry writes, R2 objects, final plans, schedules, or Steps are emitted.",
        "- Catalog/source-of-sources proposals cannot become source authority without a completed decision artifact.",
        "- Outside legal approval is not claimed unless an outside legal approval artifact is present.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed by this finalizer.",
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
            "- Finalizer outputs only public/reference governance metadata and blocked-finalization evidence.",
            "",
            "No private graph egress proof:",
            "- Terms proposal, decision artifact, and output privacy scans must pass before Source Green.",
            "- The finalizer emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- Terms proposals do not become approvals.",
            "- Completed legal/terms entries require explicit source-specific reviewer decision fields.",
            "- Outside legal approval is not claimed without outside legal approval artifact.",
            "",
            "Restricted-source exclusion proof:",
            "- Public catalog/source-of-sources entries are rejected as completed source authority.",
            "- Packable output requires pack-allowed source lane and legal/terms posture.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 62. This train finalizes governance approvals only.",
            "",
            "Freshness/revocation proof:",
            "- Source-lane review/freshness fields are required for completed decisions.",
            "- No pack freshness or revocation operation ran.",
            "",
            "LKG/rollback proof:",
            "- No stable pointer or active registry write ran. Rollback is to remove the finalizer outputs from this train.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 62. No native files are touched by this finalizer.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: Foundry approval finalizer, CLI command, tests, generated evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: none from this tooling train; native runtime and release proof remain separate.",
            "- Next repair train if debt remains: source-lane activation only after completed approvals, then harvest/claim/pack/R2/native proof.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _terms_resolution_proposals(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("termsResolutionProposals"), list):
        return [item for item in payload["termsResolutionProposals"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("catalogTermsResolution"), dict):
        return _terms_resolution_proposals(payload["catalogTermsResolution"])
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _input_schema_issues(payload: Any, proposals: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog approval finalizer input must be an object or array")
    if not proposals:
        issues.append("catalog approval finalizer input must include terms-resolution proposals")
    for index, proposal in enumerate(proposals):
        for field in ("proposal_id", "intake_id", "status", "resolved_approval_artifact_template"):
            if not proposal.get(field):
                issues.append(f"termsResolutionProposals[{index}].{field} required")
        if proposal.get("status") != "terms_resolution_proposed":
            issues.append(f"{proposal.get('proposal_id') or index}: proposal status must be terms_resolution_proposed")
    return issues


def _validate_decision(decision: Any, proposals: list[dict[str, Any]], decision_path: str) -> dict[str, Any]:
    if decision is None:
        return {
            "valid": False,
            "decisionArtifactProvided": False,
            "decisionArtifactPath": "",
            "decisionArtifactID": "",
            "reviewOwner": "",
            "reviewedAt": "",
            "outsideLegalStatus": "not_claimed",
            "selectedProposalIDs": [],
            "selectedIntakeIDs": [],
            "approvedEntries": [],
            "issues": ["decision artifact not provided; all terms-resolution proposals remain blocked"],
            "nonClaims": ["missing decision artifact is expected for blocked finalizer dry-runs"],
        }
    issues: list[str] = []
    if not isinstance(decision, dict):
        issues.append("decision artifact must be an object")
        decision = {}
    if decision.get("kind") != DECISION_KIND:
        issues.append(f"decision artifact kind must be {DECISION_KIND}")
    if decision.get("decision_status") != "approved":
        issues.append("decision_status must be approved")
    for field in ("decision_artifact_id", "review_owner", "reviewed_at"):
        if not decision.get(field):
            issues.append(f"{field} required")
    for field in ("source_lane_review_complete", "legal_terms_review_complete", "api_governance_review_complete"):
        if decision.get(field) is not True:
            issues.append(f"{field} must be true")
    if decision.get("outside_legal_status") == "approved" and not decision.get("outside_legal_approval_artifact"):
        issues.append("outside_legal_status approved requires outside_legal_approval_artifact")

    selected = decision.get("selected_proposal_ids", [])
    if not isinstance(selected, list) or not all(isinstance(item, str) and item for item in selected):
        issues.append("selected_proposal_ids must be a non-empty string list")
        selected = []
    approved_entries = decision.get("approved_entries", [])
    if not isinstance(approved_entries, list):
        issues.append("approved_entries must be a list")
        approved_entries = []

    proposals_by_id = {str(proposal.get("proposal_id") or ""): proposal for proposal in proposals}
    proposal_ids = set(proposals_by_id)
    entry_ids: set[str] = set()
    normalized_entries: list[dict[str, Any]] = []
    for index, entry in enumerate(approved_entries):
        if not isinstance(entry, dict):
            issues.append(f"approved_entries[{index}] must be an object")
            continue
        proposal_id = str(entry.get("proposal_id") or "")
        if not proposal_id:
            issues.append(f"approved_entries[{index}]: proposal_id required")
        if proposal_id and proposal_id not in proposal_ids:
            issues.append(f"{proposal_id}: approved entry does not match input terms-resolution proposal")
        if proposal_id and proposal_id in entry_ids:
            issues.append(f"{proposal_id}: duplicate approved entry")
        entry_ids.add(proposal_id)
        proposal = proposals_by_id.get(proposal_id, {})
        issues.extend(_approved_entry_issues(entry, proposal, f"approved_entries[{index}]"))
        if proposal_id and proposal_id in proposal_ids:
            normalized_entries.append(_normalized_approved_entry(entry, proposal))
    for proposal_id in selected:
        if proposal_id not in proposal_ids:
            issues.append(f"{proposal_id}: selected proposal id does not match input terms-resolution proposal")
        if proposal_id not in entry_ids:
            issues.append(f"{proposal_id}: selected proposal id missing approved entry")
    for entry_id in sorted(entry_ids - set(selected)):
        issues.append(f"{entry_id}: approved entry was not selected")

    selected_entries = [entry for entry in normalized_entries if entry.get("proposal_id") in set(selected)]
    selected_intake_ids = sorted({str(entry["intake_id"]) for entry in selected_entries})
    return {
        "valid": not issues,
        "decisionArtifactProvided": True,
        "decisionArtifactPath": decision_path,
        "decisionArtifactID": str(decision.get("decision_artifact_id") or ""),
        "reviewOwner": str(decision.get("review_owner") or ""),
        "reviewedAt": str(decision.get("reviewed_at") or ""),
        "outsideLegalStatus": str(decision.get("outside_legal_status") or "not_claimed"),
        "outsideLegalApprovalArtifact": str(decision.get("outside_legal_approval_artifact") or ""),
        "selectedProposalIDs": sorted(selected),
        "selectedIntakeIDs": selected_intake_ids,
        "approvedEntries": sorted(selected_entries, key=lambda item: (item["intake_id"], item["proposal_id"])),
        "issues": sorted(set(issues)),
        "nonClaims": [
            "decision validation does not equal outside legal approval unless outside approval artifact is present",
            "finalizer does not write active registries",
        ],
    }


def _approved_entry_issues(entry: dict[str, Any], proposal: dict[str, Any], label: str) -> list[str]:
    issues: list[str] = []
    source_lane = entry.get("source_lane_entry") if isinstance(entry.get("source_lane_entry"), dict) else {}
    legal_terms = entry.get("legal_terms_entry") if isinstance(entry.get("legal_terms_entry"), dict) else {}
    api_policy = entry.get("api_policy_entry") if isinstance(entry.get("api_policy_entry"), dict) else {}
    if not source_lane:
        issues.append(f"{label}: source_lane_entry required")
    if not legal_terms:
        issues.append(f"{label}: legal_terms_entry required")
    if not api_policy:
        issues.append(f"{label}: api_policy_entry required")

    intake_id = str(proposal.get("intake_id") or "")
    if entry.get("intake_id") != intake_id:
        issues.append(f"{label}: intake_id must match proposal intake_id")

    source_id = str(source_lane.get("source_id") or "<source>")
    source_required = [
        "source_id",
        "source_name",
        "source_class",
        "authority_class",
        "jurisdiction",
        "domain_scope",
        "claim_classes_allowed",
        "claim_classes_forbidden",
        "license_id",
        "license_url",
        "terms_url",
        "rights_url",
        "attribution_required",
        "redistribution_policy",
        "r2_pack_policy",
        "lookup_policy",
        "crosswalk_policy",
        "review_status",
        "review_owner",
        "last_reviewed_at",
        "next_review_due_at",
        "freshness_sla",
        "api_mode",
        "api_policy_id",
        "rate_policy_id",
        "budget_policy_id",
        "secret_policy_id",
        "allowed_artifact_classes",
        "forbidden_artifact_classes",
        "non_claims",
        "schema_version",
    ]
    for field in source_required:
        if _missing_required(source_lane, field):
            issues.append(f"{label}.source_lane_entry.{field} required")
    if source_lane.get("authority_class") not in AUTHORITY_CLASSES:
        issues.append(f"{label}: unsupported authority_class {source_lane.get('authority_class')}")
    if source_lane.get("redistribution_policy") not in REDISTRIBUTION_POLICIES:
        issues.append(f"{label}: unsupported redistribution_policy {source_lane.get('redistribution_policy')}")
    if source_lane.get("r2_pack_policy") not in R2_PACK_POLICIES:
        issues.append(f"{label}: unsupported r2_pack_policy {source_lane.get('r2_pack_policy')}")
    if source_lane.get("review_status") not in REVIEW_STATUSES or source_lane.get("review_status") != "reviewed":
        issues.append(f"{label}: source lane review_status must be reviewed")
    if source_lane.get("review_required") is not False:
        issues.append(f"{label}: source lane review_required must be false")
    if source_lane.get("source_class") in SOURCE_OF_SOURCES_CLASSES or source_lane.get("authority_class") == "public_catalog":
        issues.append(f"{label}: approved source lane cannot remain public_catalog source-of-sources")
    if source_lane.get("r2_pack_policy") not in PACK_ALLOWED_POLICIES:
        issues.append(f"{label}: completed approval requires pack-allowed r2_pack_policy")
    if source_lane.get("r2_pack_policy") in PACK_ALLOWED_POLICIES:
        key_prefix = source_lane.get("r2_object_key_prefix")
        if not key_prefix:
            issues.append(f"{source_id}: packable lane requires r2_object_key_prefix")
        else:
            issues.extend(object_key_findings(str(key_prefix)))
    forbidden_classes = set(source_lane.get("forbidden_artifact_classes", []))
    for forbidden in {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_goal_graph"}:
        if forbidden not in forbidden_classes:
            issues.append(f"{label}: forbidden_artifact_classes must include {forbidden}")

    legal_string_required = [
        "license_id",
        "license_name",
        "license_url",
        "terms_url",
        "rights_url",
        "source_specific_restrictions",
        "effective_date",
        "reviewed_at",
        "review_owner",
        "expires_at",
        "non_claims",
        "schema_version",
    ]
    legal_boolean_required = [
        "redistribution_allowed",
        "modification_allowed",
        "commercial_use_allowed",
        "attribution_required",
        "share_alike_required",
        "pack_output_allowed",
        "lookup_output_allowed",
        "review_required",
        "outside_legal_required",
    ]
    for field in legal_string_required:
        if _missing_required(legal_terms, field):
            issues.append(f"{label}.legal_terms_entry.{field} required")
    for field in legal_boolean_required:
        if field not in legal_terms or legal_terms.get(field) is None:
            issues.append(f"{label}.legal_terms_entry.{field} required")
    if legal_terms.get("redistribution_allowed") is not True:
        issues.append(f"{label}: legal_terms_entry.redistribution_allowed must be true")
    if legal_terms.get("pack_output_allowed") is not True:
        issues.append(f"{label}: legal_terms_entry.pack_output_allowed must be true")
    if legal_terms.get("review_required") is not False:
        issues.append(f"{label}: legal_terms_entry.review_required must be false")
    if legal_terms.get("outside_legal_status") == "approved" and not legal_terms.get("approval_artifact_path"):
        issues.append(f"{label}: outside legal approval requires approval_artifact_path")

    api_required = [
        "api_policy_id",
        "source_id",
        "api_mode",
        "key_required",
        "env_var_name",
        "missing_key_behavior",
        "rate_limit_per_second",
        "rate_limit_per_minute",
        "daily_budget_limit",
        "monthly_budget_limit",
        "max_records_per_run",
        "max_pages_per_run",
        "timeout_seconds",
        "retry_policy",
        "backoff_policy",
        "circuit_breaker_policy",
        "live_flag_required",
        "execute_flag_required",
        "secret_redaction_required",
        "high_volume_review_required",
        "budget_owner",
        "evidence_output_policy",
        "schema_version",
    ]
    for field in api_required:
        if field not in api_policy or api_policy.get(field) is None or api_policy.get(field) == "":
            if field == "env_var_name" and api_policy.get("key_required") is False:
                continue
            issues.append(f"{label}.api_policy_entry.{field} required")
    if api_policy.get("key_required") is True and not api_policy.get("env_var_name"):
        issues.append(f"{label}: key_required requires env_var_name")
    if api_policy.get("live_flag_required") is not True or api_policy.get("execute_flag_required") is not True:
        issues.append(f"{label}: api policy must require live and execute flags")
    if api_policy.get("secret_redaction_required") is not True:
        issues.append(f"{label}: api policy must require secret redaction")
    for field in ("daily_budget_limit", "monthly_budget_limit", "max_records_per_run", "max_pages_per_run", "timeout_seconds"):
        value = api_policy.get(field)
        if not isinstance(value, int) or value <= 0:
            issues.append(f"{label}: api_policy_entry.{field} must be positive integer")

    if source_lane and legal_terms and source_lane.get("license_id") != legal_terms.get("license_id"):
        issues.append(f"{label}: source_lane_entry.license_id must match legal_terms_entry.license_id")
    if source_lane and api_policy and source_lane.get("api_policy_id") != api_policy.get("api_policy_id"):
        issues.append(f"{label}: source_lane_entry.api_policy_id must match api_policy_entry.api_policy_id")
    if source_lane and api_policy and source_lane.get("source_id") != api_policy.get("source_id"):
        issues.append(f"{label}: source_lane_entry.source_id must match api_policy_entry.source_id")
    issues.extend(privacy_findings_for_value(entry, label))
    if _contains_forbidden_output_marker(entry):
        issues.append(f"{label}: forbidden final-output marker found")
    return sorted(set(issues))


def _normalized_approved_entry(entry: dict[str, Any], proposal: dict[str, Any]) -> dict[str, Any]:
    return {
        "proposal_id": str(entry.get("proposal_id") or ""),
        "intake_id": str(entry.get("intake_id") or proposal.get("intake_id") or ""),
        "source_lane_entry": entry["source_lane_entry"],
        "legal_terms_entry": entry["legal_terms_entry"],
        "api_policy_entry": entry["api_policy_entry"],
    }


def _completed_approval_artifact(decision_validation: dict[str, Any], created_at: str) -> dict[str, Any]:
    approved_entries = [
        {
            "intake_id": entry["intake_id"],
            "source_lane_entry": entry["source_lane_entry"],
            "legal_terms_entry": entry["legal_terms_entry"],
            "api_policy_entry": entry["api_policy_entry"],
        }
        for entry in decision_validation["approvedEntries"]
    ]
    return {
        "kind": APPROVAL_KIND,
        "approval_artifact_id": decision_validation["decisionArtifactID"],
        "approval_status": "approved",
        "review_owner": decision_validation["reviewOwner"],
        "reviewed_at": decision_validation["reviewedAt"],
        "created_at": created_at,
        "source_lane_review_complete": True,
        "legal_terms_review_complete": True,
        "api_governance_review_complete": True,
        "outside_legal_status": decision_validation["outsideLegalStatus"],
        "outside_legal_approval_artifact": decision_validation.get("outsideLegalApprovalArtifact", ""),
        "selected_intake_ids": decision_validation["selectedIntakeIDs"],
        "approved_entries": approved_entries,
        "non_claims": [
            "approval artifact enables mutation planning only",
            "not active registry mutation",
            "not claim output",
            "not pack output",
            "not R2 publish",
            "not outside legal approval unless outside legal artifact is populated",
        ],
    }


def _completed_contract_issues(completed_artifacts: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    for index, artifact in enumerate(completed_artifacts):
        label = f"completedApprovalArtifacts[{index}]"
        if artifact.get("kind") != APPROVAL_KIND:
            issues.append(f"{label}: kind must be {APPROVAL_KIND}")
        if artifact.get("approval_status") != "approved":
            issues.append(f"{label}: approval_status must be approved")
        for field in ("approval_artifact_id", "review_owner", "reviewed_at", "selected_intake_ids", "approved_entries"):
            if _missing_required(artifact, field):
                issues.append(f"{label}.{field} required")
        for field in ("source_lane_review_complete", "legal_terms_review_complete", "api_governance_review_complete"):
            if artifact.get(field) is not True:
                issues.append(f"{label}.{field} must be true")
        if artifact.get("outside_legal_status") == "approved" and not artifact.get("outside_legal_approval_artifact"):
            issues.append(f"{label}: outside legal approval requires outside_legal_approval_artifact")
    return issues


def _blocked_finalization(proposal: dict[str, Any], created_at: str, decision_validation: dict[str, Any], *, selected: bool) -> dict[str, Any]:
    reasons = {
        "decision_artifact_required",
        "source_lane_review_required",
        "legal_terms_review_required",
        "api_governance_review_required",
        "approval_artifact_still_required",
        "active_registry_mutation_blocked",
    }
    if decision_validation.get("decisionArtifactProvided") and not decision_validation.get("valid"):
        reasons.add("decision_artifact_invalid")
    if decision_validation.get("decisionArtifactProvided") and not selected:
        reasons.add("not_selected_by_decision_artifact")
    reasons.update(str(reason) for reason in proposal.get("blocking_reasons", []))
    return {
        "schema_version": "1.0.0",
        "proposal_id": str(proposal.get("proposal_id") or ""),
        "request_id": str(proposal.get("request_id") or ""),
        "intake_id": str(proposal.get("intake_id") or ""),
        "candidate_id": str(proposal.get("candidate_id") or ""),
        "domain_guess": str(proposal.get("domain_guess") or "unclassified_public_reference"),
        "created_at": created_at,
        "status": "blocked",
        "active_registry_written": False,
        "blocking_reasons": sorted(reasons),
        "non_claims": [
            "blocked finalization only",
            "not an approval artifact",
            "not source authority",
            "not legal approval",
            "not active registry mutation",
        ],
    }


def _missing_required(value: dict[str, Any], field: str) -> bool:
    if field not in value:
        return True
    item = value.get(field)
    return item is None or item == "" or item == []


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
