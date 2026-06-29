"""Decision preflight for catalog approval finalization.

The approval finalizer intentionally blocks catalog terms-resolution proposals
until a reviewer supplies a complete decision artifact. This preflight compiler
makes those blocked records actionable by emitting deterministic missing-field
checklists and draft decision shells without creating approvals.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_approval_finalizer import DECISION_KIND
from .governance_registry import PACK_ALLOWED_POLICIES, SOURCE_OF_SOURCES_CLASSES
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_APPROVAL_PREFLIGHT_VERSION = "source-atlas-catalog-approval-preflight-train-63"
CATALOG_APPROVAL_PREFLIGHT_KIND = "ambitions.sourceAtlas.catalogApprovalPreflight.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

SOURCE_LANE_REQUIRED_FIELDS = [
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
LEGAL_STRING_FIELDS = [
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
LEGAL_BOOLEAN_FIELDS = [
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
API_REQUIRED_FIELDS = [
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

PREFLIGHT_NON_CLAIMS = [
    "not an approval artifact",
    "not legal approval",
    "not outside legal approval",
    "not source authority",
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
class CatalogApprovalPreflightOptions:
    terms_proposals_path: Path
    output_root: Path
    created_at: str | None = None


def compile_catalog_approval_preflight(options: CatalogApprovalPreflightOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload = read_json(options.terms_proposals_path)
    proposals = _terms_resolution_proposals(payload)
    input_schema_issues = _input_schema_issues(payload, proposals)
    input_privacy_issues = privacy_findings_for_value(payload, "catalog-approval-preflight-input")
    preflight_records = [_preflight_record(proposal, created_at) for proposal in proposals]
    preflight_records = sorted(preflight_records, key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"]))
    draft_templates = [_decision_draft_template(record, created_at) for record in preflight_records]
    blocked = [record for record in preflight_records if record["status"] != "decision_ready_for_reviewer_completion"]
    ready = [record for record in preflight_records if record["status"] == "decision_ready_for_reviewer_completion"]

    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_APPROVAL_PREFLIGHT_KIND,
        "versionID": CATALOG_APPROVAL_PREFLIGHT_VERSION,
        "createdAt": created_at,
        "termsProposalsPath": str(options.terms_proposals_path),
        "decisionPreflightRecords": preflight_records,
        "decisionDraftTemplates": draft_templates,
        "completedApprovalArtifacts": [],
        "activeRegistryMutations": [],
        "recordCounts": {
            "termsResolutionProposals": len(proposals),
            "decisionPreflightRecords": len(preflight_records),
            "decisionReadyRecords": len(ready),
            "blockedDecisionRecords": len(blocked),
            "decisionDraftTemplates": len(draft_templates),
            "completedApprovalArtifacts": 0,
            "activeRegistryMutations": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PREFLIGHT_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-approval-preflight")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(proposals), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {
            "name": "preflight_records_cover_all_proposals",
            "passed": len(preflight_records) == len(proposals),
            "issues": [],
        },
        {
            "name": "draft_templates_are_not_approvals",
            "passed": all(template["decision_status"] == "draft_not_approved" for template in draft_templates)
            and artifact["recordCounts"]["completedApprovalArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "preflight_emits_no_claims",
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
    issues.extend(artifact_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogApprovalPreflightManifest.v1",
        "versionID": CATALOG_APPROVAL_PREFLIGHT_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog approval decision preflight tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; decision preflight tooling only",
        "termsProposalsPath": str(options.terms_proposals_path),
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogApprovalPreflight": str(output_root / "catalog-approval-preflight.json"),
            "decisionPreflightRecords": str(output_root / "decision-preflight-records.json"),
            "decisionDraftTemplates": str(output_root / "decision-draft-templates.json"),
            "completedApprovalArtifacts": str(output_root / "completed-approval-artifacts.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PREFLIGHT_NON_CLAIMS,
    }

    write_json(output_root / "catalog-approval-preflight.json", artifact)
    write_json(
        output_root / "decision-preflight-records.json",
        {
            "kind": "ambitions.sourceAtlas.catalogApprovalDecisionPreflightRecords.v1",
            "createdAt": created_at,
            "decisionPreflightRecords": preflight_records,
        },
    )
    write_json(
        output_root / "decision-draft-templates.json",
        {
            "kind": "ambitions.sourceAtlas.catalogApprovalDecisionDraftTemplates.v1",
            "createdAt": created_at,
            "decisionDraftTemplates": draft_templates,
        },
    )
    write_json(
        output_root / "completed-approval-artifacts.json",
        {
            "kind": "ambitions.sourceAtlas.catalogCompletedApprovalArtifacts.v1",
            "createdAt": created_at,
            "completedApprovalArtifacts": [],
        },
    )
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogApprovalPreflight": stable_hash(read_json(output_root / "catalog-approval-preflight.json")),
        "decisionPreflightRecords": stable_hash(read_json(output_root / "decision-preflight-records.json")),
        "decisionDraftTemplates": stable_hash(read_json(output_root / "decision-draft-templates.json")),
        "completedApprovalArtifacts": stable_hash(read_json(output_root / "completed-approval-artifacts.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_approval_preflight_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_approval_preflight_report(
    markdown_path: Path,
    json_path: Path,
    *,
    terms_proposals_path: Path,
    output_root: Path,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_approval_preflight(
        CatalogApprovalPreflightOptions(
            terms_proposals_path=terms_proposals_path,
            output_root=output_root,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_approval_preflight_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_approval_preflight_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Approval Preflight Train 63",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic decision preflight for catalog terms-resolution proposals.",
        "- Per-proposal missing-field and blocking-reason records.",
        "- Draft decision shells that remain draft_not_approved and cannot be used as approvals.",
        "",
        "Counts:",
        f"- Terms-resolution proposals: {counts['termsResolutionProposals']}",
        f"- Decision preflight records: {counts['decisionPreflightRecords']}",
        f"- Decision-ready records: {counts['decisionReadyRecords']}",
        f"- Blocked decision records: {counts['blockedDecisionRecords']}",
        f"- Decision draft templates: {counts['decisionDraftTemplates']}",
        f"- Completed approval artifacts: {counts['completedApprovalArtifacts']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- Preflight records are not approvals and do not create source authority.",
        "- No claims, packs, active registry writes, R2 objects, final plans, schedules, or Steps are emitted.",
        "- Source/legal/API review remains required before approval finalization.",
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
            "- Preflight output is limited to public/reference governance decision metadata.",
            "",
            "No private graph egress proof:",
            "- Terms proposal and output privacy scans must pass before Source Green.",
            "- The preflight emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- Draft templates remain draft_not_approved.",
            "- Completed legal/terms approval is not claimed.",
            "- Outside legal approval is not claimed.",
            "",
            "Restricted-source exclusion proof:",
            "- Public catalog/source-of-sources inputs remain blocked until reviewer-supplied direct source authority is present.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 63. This train prepares approval decisions only.",
            "",
            "Freshness/revocation proof:",
            "- Source-lane freshness fields are listed as required decision data.",
            "- No pack freshness or revocation operation ran.",
            "",
            "LKG/rollback proof:",
            "- No stable pointer or active registry write ran. Rollback is artifact removal.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 63. No native files are touched by this preflight.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: Foundry approval preflight, CLI command, tests, generated evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: none from this tooling train; native runtime and release proof remain separate.",
            "- Next repair train if debt remains: completed decision artifacts only after source/legal/API review, then finalizer/mutation/applier gates.",
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
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _input_schema_issues(payload: Any, proposals: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog approval preflight input must be an object or array")
    if not proposals:
        issues.append("catalog approval preflight input must include terms-resolution proposals")
    for index, proposal in enumerate(proposals):
        for field in ("proposal_id", "intake_id", "status", "resolved_approval_artifact_template"):
            if not proposal.get(field):
                issues.append(f"termsResolutionProposals[{index}].{field} required")
    return issues


def _preflight_record(proposal: dict[str, Any], created_at: str) -> dict[str, Any]:
    template = proposal.get("resolved_approval_artifact_template") if isinstance(proposal.get("resolved_approval_artifact_template"), dict) else {}
    entries = template.get("approved_entries") if isinstance(template.get("approved_entries"), list) else []
    entry = next((item for item in entries if isinstance(item, dict)), {})
    source_lane = entry.get("source_lane_entry") if isinstance(entry.get("source_lane_entry"), dict) else {}
    legal_terms = entry.get("legal_terms_entry") if isinstance(entry.get("legal_terms_entry"), dict) else {}
    api_policy = entry.get("api_policy_entry") if isinstance(entry.get("api_policy_entry"), dict) else {}
    missing_source_lane = _missing_fields(source_lane, SOURCE_LANE_REQUIRED_FIELDS)
    missing_legal = _missing_fields(legal_terms, LEGAL_STRING_FIELDS) + [
        field for field in LEGAL_BOOLEAN_FIELDS if field not in legal_terms or legal_terms.get(field) is None
    ]
    missing_api = [
        field
        for field in API_REQUIRED_FIELDS
        if field not in api_policy or api_policy.get(field) is None or (api_policy.get(field) == "" and not (field == "env_var_name" and api_policy.get("key_required") is False))
    ]
    blocking_reasons = set(str(reason) for reason in proposal.get("blocking_reasons", []))
    if missing_source_lane:
        blocking_reasons.add("source_lane_fields_incomplete")
    if missing_legal:
        blocking_reasons.add("legal_terms_fields_incomplete")
    if missing_api:
        blocking_reasons.add("api_governance_fields_incomplete")
    if source_lane.get("source_class") in SOURCE_OF_SOURCES_CLASSES or source_lane.get("authority_class") == "public_catalog":
        blocking_reasons.add("source_of_sources_not_direct_authority")
    if source_lane.get("r2_pack_policy") not in PACK_ALLOWED_POLICIES:
        blocking_reasons.add("pack_policy_not_approved")
    if legal_terms.get("pack_output_allowed") is not True or legal_terms.get("redistribution_allowed") is not True:
        blocking_reasons.add("legal_terms_not_pack_approved")
    if legal_terms.get("review_required") is not False:
        blocking_reasons.add("legal_terms_review_required")
    if api_policy.get("live_flag_required") is not True or api_policy.get("execute_flag_required") is not True:
        blocking_reasons.add("api_live_execute_flags_required")
    if api_policy.get("secret_redaction_required") is not True:
        blocking_reasons.add("api_secret_redaction_required")
    if not blocking_reasons:
        status = "decision_ready_for_reviewer_completion"
    else:
        status = "blocked_review_required"
    return {
        "schema_version": "1.0.0",
        "preflight_id": stable_id("catalog_approval_preflight", {"proposal_id": proposal.get("proposal_id"), "entry": entry}),
        "proposal_id": str(proposal.get("proposal_id") or ""),
        "request_id": str(proposal.get("request_id") or ""),
        "intake_id": str(proposal.get("intake_id") or ""),
        "candidate_id": str(proposal.get("candidate_id") or ""),
        "domain_guess": str(proposal.get("domain_guess") or "unclassified_public_reference"),
        "source_id": str(proposal.get("source_id") or source_lane.get("source_id") or ""),
        "source_name": str(proposal.get("source_name") or source_lane.get("source_name") or ""),
        "created_at": created_at,
        "status": status,
        "missing_source_lane_fields": sorted(missing_source_lane),
        "missing_legal_terms_fields": sorted(missing_legal),
        "missing_api_governance_fields": sorted(missing_api),
        "blocking_reasons": sorted(blocking_reasons),
        "required_reviewer_actions": _required_actions(missing_source_lane, missing_legal, missing_api, blocking_reasons),
        "draft_entry": entry,
        "non_claims": [
            "preflight record only",
            "not approval",
            "not legal approval",
            "not source authority",
            "not active registry mutation",
        ],
    }


def _decision_draft_template(record: dict[str, Any], created_at: str) -> dict[str, Any]:
    return {
        "kind": DECISION_KIND,
        "decision_artifact_id": "",
        "decision_status": "draft_not_approved",
        "created_at": created_at,
        "review_owner": "",
        "reviewed_at": "",
        "source_lane_review_complete": False,
        "legal_terms_review_complete": False,
        "api_governance_review_complete": False,
        "outside_legal_status": "not_claimed",
        "outside_legal_approval_artifact": "",
        "selected_proposal_ids": [record["proposal_id"]],
        "draft_entries": [
            {
                "proposal_id": record["proposal_id"],
                "intake_id": record["intake_id"],
                "missing_source_lane_fields": record["missing_source_lane_fields"],
                "missing_legal_terms_fields": record["missing_legal_terms_fields"],
                "missing_api_governance_fields": record["missing_api_governance_fields"],
                "draft_entry": record["draft_entry"],
            }
        ],
        "required_reviewer_actions": record["required_reviewer_actions"],
        "non_claims": [
            "draft decision shell only",
            "not approval",
            "not legal approval",
            "not outside legal approval",
            "not source authority",
        ],
    }


def _missing_fields(value: dict[str, Any], fields: list[str]) -> list[str]:
    missing: list[str] = []
    for field in fields:
        item = value.get(field)
        if field not in value or item is None or item == "" or item == []:
            missing.append(field)
    return missing


def _required_actions(
    missing_source_lane: list[str],
    missing_legal: list[str],
    missing_api: list[str],
    blocking_reasons: set[str],
) -> list[str]:
    actions: list[str] = []
    if missing_source_lane:
        actions.append("complete source lane authority, jurisdiction, review, freshness, and artifact policy fields")
    if missing_legal:
        actions.append("complete legal/terms redistribution, pack-output, restrictions, review, and expiry fields")
    if missing_api:
        actions.append("complete API governance key, budget, rate, retry, timeout, live/execute, and evidence policy fields")
    if "source_of_sources_not_direct_authority" in blocking_reasons:
        actions.append("replace catalog/source-of-sources posture with independently reviewed direct source authority")
    if "pack_policy_not_approved" in blocking_reasons:
        actions.append("choose a pack-allowed or blocked pack policy based on completed terms review")
    if "legal_terms_not_pack_approved" in blocking_reasons:
        actions.append("do not allow pack output until redistribution and pack-output posture are approved")
    if not actions:
        actions.append("reviewer may complete a decision artifact, but this preflight still does not approve it")
    return actions


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
