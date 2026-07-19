"""Approval request templates for catalog registry mutation planning.

This compiler prepares review packets that a human owner/legal/API reviewer can
complete later. It never emits an approved artifact, active registry mutation,
claim output, pack output, or R2-ready artifact.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_registry_mutation_plan import APPROVAL_KIND
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_REGISTRY_APPROVAL_REQUEST_VERSION = "source-atlas-catalog-registry-approval-request-train-59"
CATALOG_REGISTRY_APPROVAL_REQUEST_KIND = "ambitions.sourceAtlas.catalogRegistryApprovalRequest.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

APPROVAL_REQUEST_NON_CLAIMS = [
    "not an approval artifact",
    "not active registry mutation",
    "not source authority",
    "not legal approval",
    "not outside legal approval",
    "not API approval",
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
class CatalogRegistryApprovalRequestOptions:
    input_path: Path
    output_root: Path
    intake_ids: tuple[str, ...] = ()
    created_at: str | None = None


def compile_catalog_registry_approval_request(options: CatalogRegistryApprovalRequestOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload = read_json(options.input_path)
    drafts = _draft_packets(payload)
    input_schema_issues = _input_schema_issues(payload, drafts)
    input_privacy_issues = privacy_findings_for_value(payload, "catalog-registry-approval-request-input")
    selected_ids = tuple(sorted(set(options.intake_ids)))
    selection_issues = _selection_issues(selected_ids, drafts)
    selected_drafts = _selected_drafts(drafts, selected_ids)

    approval_requests = [_approval_request(draft, created_at) for draft in selected_drafts]
    approval_requests = sorted(approval_requests, key=lambda item: (item["domain_guess"], item["intake_id"], item["request_id"]))
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_REGISTRY_APPROVAL_REQUEST_KIND,
        "versionID": CATALOG_REGISTRY_APPROVAL_REQUEST_VERSION,
        "createdAt": created_at,
        "inputPath": str(options.input_path),
        "selectedIntakeIDs": list(selected_ids),
        "approvalRequests": approval_requests,
        "completedApprovalArtifacts": [],
        "recordCounts": {
            "draftGovernancePackets": len(drafts),
            "approvalRequests": len(approval_requests),
            "completedApprovalArtifacts": 0,
            "activeRegistryMutations": 0,
            "approvedSourceLanes": 0,
            "approvedLegalEntries": 0,
            "approvedApiPolicies": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": APPROVAL_REQUEST_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-registry-approval-request")
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(drafts), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {"name": "selection_valid", "passed": not selection_issues and bool(approval_requests), "issues": selection_issues},
        {
            "name": "templates_are_not_approvals",
            "passed": all(request["approval_artifact_template"]["approval_status"] == "draft_not_approved" for request in approval_requests)
            and artifact["recordCounts"]["completedApprovalArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "approval_requests_emit_no_claims",
            "passed": artifact["recordCounts"]["claims"] == 0
            and artifact["recordCounts"]["packableClaims"] == 0
            and artifact["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "no_active_registry_mutations",
            "passed": artifact["recordCounts"]["activeRegistryMutations"] == 0,
            "issues": [],
        },
        {
            "name": "privacy_scan_passed",
            "passed": not artifact_privacy_issues,
            "issues": artifact_privacy_issues,
        },
        {
            "name": "no_final_plan_schedule_step_output",
            "passed": not _contains_forbidden_output_marker(artifact),
            "issues": [] if not _contains_forbidden_output_marker(artifact) else ["forbidden final-output marker found"],
        },
    ]
    issues: list[str] = []
    issues.extend(input_schema_issues)
    issues.extend(input_privacy_issues)
    issues.extend(selection_issues)
    issues.extend(artifact_privacy_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogRegistryApprovalRequestManifest.v1",
        "versionID": CATALOG_REGISTRY_APPROVAL_REQUEST_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog registry approval request template tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; approval request templates only",
        "inputPath": str(options.input_path),
        "selectedIntakeIDs": list(selected_ids),
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogRegistryApprovalRequest": str(output_root / "catalog-registry-approval-request.json"),
            "approvalRequests": str(output_root / "approval-requests.json"),
            "completedApprovalArtifacts": str(output_root / "completed-approval-artifacts.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": APPROVAL_REQUEST_NON_CLAIMS,
    }

    write_json(output_root / "catalog-registry-approval-request.json", artifact)
    write_json(output_root / "approval-requests.json", {"approvalRequests": approval_requests, "createdAt": created_at, "kind": "ambitions.sourceAtlas.catalogRegistryApprovalRequests.v1"})
    write_json(output_root / "completed-approval-artifacts.json", {"completedApprovalArtifacts": [], "createdAt": created_at, "kind": "ambitions.sourceAtlas.catalogCompletedApprovalArtifacts.v1"})
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogRegistryApprovalRequest": stable_hash(read_json(output_root / "catalog-registry-approval-request.json")),
        "approvalRequests": stable_hash(read_json(output_root / "approval-requests.json")),
        "completedApprovalArtifacts": stable_hash(read_json(output_root / "completed-approval-artifacts.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_registry_approval_request_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_registry_approval_request_report(
    markdown_path: Path,
    json_path: Path,
    *,
    input_path: Path,
    output_root: Path,
    intake_ids: tuple[str, ...] = (),
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_registry_approval_request(
        CatalogRegistryApprovalRequestOptions(
            input_path=input_path,
            output_root=output_root,
            intake_ids=intake_ids,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_registry_approval_request_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_registry_approval_request_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Registry Approval Request Train 59",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Approval request templates for catalog governance draft packets.",
        "- Incomplete approval artifact templates that remain draft_not_approved.",
        "- Required decision checklist for owner/legal/API review before mutation planning.",
        "",
        "Counts:",
        f"- Draft governance packets: {counts['draftGovernancePackets']}",
        f"- Approval requests: {counts['approvalRequests']}",
        f"- Completed approval artifacts: {counts['completedApprovalArtifacts']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- Templates are not approvals.",
        "- No active registries, claims, packs, R2 objects, final plans, schedules, or Steps are emitted.",
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


def _input_schema_issues(payload: Any, drafts: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("approval request input must be an object or array")
    if not drafts:
        issues.append("approval request input must include draft governance packets")
    return issues


def _selection_issues(selected_ids: tuple[str, ...], drafts: list[dict[str, Any]]) -> list[str]:
    if not selected_ids:
        return []
    available = {str(draft.get("intake_id") or "") for draft in drafts}
    missing = sorted(set(selected_ids) - available)
    return [f"{item}: selected intake id not found" for item in missing]


def _selected_drafts(drafts: list[dict[str, Any]], selected_ids: tuple[str, ...]) -> list[dict[str, Any]]:
    if not selected_ids:
        return drafts
    wanted = set(selected_ids)
    return [draft for draft in drafts if str(draft.get("intake_id") or "") in wanted]


def _approval_request(draft: dict[str, Any], created_at: str) -> dict[str, Any]:
    intake_id = str(draft.get("intake_id") or "")
    source_lane_draft = draft.get("source_lane_draft") if isinstance(draft.get("source_lane_draft"), dict) else {}
    legal_terms_draft = draft.get("legal_terms_draft") if isinstance(draft.get("legal_terms_draft"), dict) else {}
    api_governance_draft = draft.get("api_governance_draft") if isinstance(draft.get("api_governance_draft"), dict) else {}
    source_id = str(source_lane_draft.get("source_id") or f"review_required.{stable_hash(draft)[:12]}")
    return {
        "schema_version": "1.0.0",
        "request_id": stable_id("catalog_registry_approval_request", {"intake_id": intake_id, "draft_hash": stable_hash(draft)}),
        "intake_id": intake_id,
        "candidate_id": str(draft.get("candidate_id") or ""),
        "domain_guess": str(draft.get("domain_guess") or "unclassified_public_reference"),
        "created_at": created_at,
        "status": "review_required",
        "source_lane_draft": source_lane_draft,
        "legal_terms_draft": legal_terms_draft,
        "api_governance_draft": api_governance_draft,
        "required_decisions": list(draft.get("required_decisions", [])),
        "approval_artifact_template": {
            "kind": APPROVAL_KIND,
            "approval_artifact_id": "",
            "approval_status": "draft_not_approved",
            "review_owner": "",
            "reviewed_at": "",
            "source_lane_review_complete": False,
            "legal_terms_review_complete": False,
            "api_governance_review_complete": False,
            "outside_legal_status": "not_claimed",
            "outside_legal_approval_artifact": "",
            "selected_intake_ids": [intake_id],
            "approved_entries": [
                {
                    "intake_id": intake_id,
                    "source_lane_entry": {
                        "source_id": source_id,
                        "source_name": str(source_lane_draft.get("source_name") or ""),
                        "source_class": "",
                        "authority_class": "",
                        "jurisdiction": "",
                        "review_status": "review_required",
                        "r2_pack_policy": "pack_blocked_unknown_terms",
                    },
                    "legal_terms_entry": {
                        "license_id": str(legal_terms_draft.get("license_id") or ""),
                        "license_name": "",
                        "license_url": str(legal_terms_draft.get("license_url") or ""),
                        "terms_url": str(legal_terms_draft.get("terms_url") or ""),
                        "rights_url": str(legal_terms_draft.get("rights_url") or ""),
                        "redistribution_allowed": False,
                        "pack_output_allowed": False,
                        "review_required": True,
                        "outside_legal_status": "not_claimed",
                        "review_owner": "",
                        "reviewed_at": "",
                    },
                    "api_policy_entry": {
                        "api_policy_id": str(api_governance_draft.get("api_policy_id") or ""),
                        "source_id": source_id,
                        "api_mode": "review_required_before_live_harvest",
                        "missing_key_behavior": "",
                        "retry_policy": "",
                        "backoff_policy": "",
                        "circuit_breaker_policy": "",
                        "budget_owner": "",
                        "evidence_output_policy": "candidate_metadata_only_until_review",
                        "live_flag_required": True,
                        "execute_flag_required": True,
                        "secret_redaction_required": True,
                    },
                }
            ],
        },
        "non_claims": [
            "approval request only",
            "template is not approval",
            "not active registry mutation",
            "not legal approval",
            "not API approval",
            "not source authority",
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
