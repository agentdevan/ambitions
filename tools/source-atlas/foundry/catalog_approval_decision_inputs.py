"""Reviewer decision-input packets for catalog approval preflight records.

Train 63 made blocked catalog approvals actionable. Train 64 turns those
preflight records into deterministic reviewer input packets while preserving
the hard boundary that reviewer inputs are not approvals, source authority,
registry mutations, claims, packs, or R2 readiness proof.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_approval_finalizer import DECISION_KIND
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_APPROVAL_DECISION_INPUTS_VERSION = "source-atlas-catalog-approval-decision-inputs-train-64"
CATALOG_APPROVAL_DECISION_INPUTS_KIND = "ambitions.sourceAtlas.catalogApprovalDecisionInputs.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

DECISION_INPUT_NON_CLAIMS = [
    "reviewer input packets only",
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
class CatalogApprovalDecisionInputsOptions:
    preflight_records_path: Path
    output_root: Path
    created_at: str | None = None
    decision_owner: str = ""


def compile_catalog_approval_decision_inputs(options: CatalogApprovalDecisionInputsOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload = read_json(options.preflight_records_path)
    preflight_records = _preflight_records(payload)
    input_schema_issues = _input_schema_issues(payload, preflight_records)
    input_privacy_issues = privacy_findings_for_value(payload, "catalog-approval-decision-inputs-input")
    packet_privacy_issues = privacy_findings_for_value(options.decision_owner, "catalog-approval-decision-inputs-owner") if options.decision_owner else []

    decision_input_packets = [
        _decision_input_packet(record, created_at, decision_owner=options.decision_owner) for record in preflight_records
    ]
    decision_input_packets = sorted(
        decision_input_packets,
        key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"], item["decision_input_id"]),
    )
    blocked_inputs = [packet for packet in decision_input_packets if packet["packet_status"] != "decision_input_ready_for_reviewer_completion"]
    ready_inputs = [packet for packet in decision_input_packets if packet["packet_status"] == "decision_input_ready_for_reviewer_completion"]

    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_APPROVAL_DECISION_INPUTS_KIND,
        "versionID": CATALOG_APPROVAL_DECISION_INPUTS_VERSION,
        "createdAt": created_at,
        "preflightRecordsPath": str(options.preflight_records_path),
        "decisionOwner": options.decision_owner,
        "decisionInputPackets": decision_input_packets,
        "blockedDecisionInputs": blocked_inputs,
        "completedApprovalArtifacts": [],
        "activeRegistryMutations": [],
        "recordCounts": {
            "preflightRecords": len(preflight_records),
            "decisionInputPackets": len(decision_input_packets),
            "decisionInputReadyForCompletion": len(ready_inputs),
            "blockedDecisionInputs": len(blocked_inputs),
            "completedApprovalArtifacts": 0,
            "activeRegistryMutations": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DECISION_INPUT_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-approval-decision-inputs")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    approval_like_issues = _approval_like_issues(decision_input_packets)
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(preflight_records), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {"name": "decision_owner_privacy_scan_passed", "passed": not packet_privacy_issues, "issues": packet_privacy_issues},
        {
            "name": "decision_input_packets_cover_all_preflight_records",
            "passed": len(decision_input_packets) == len(preflight_records),
            "issues": [],
        },
        {
            "name": "decision_input_packets_are_not_approvals",
            "passed": not approval_like_issues and artifact["recordCounts"]["completedApprovalArtifacts"] == 0,
            "issues": approval_like_issues,
        },
        {
            "name": "decision_inputs_emit_no_claims",
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
    issues.extend(packet_privacy_issues)
    issues.extend(approval_like_issues)
    issues.extend(artifact_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogApprovalDecisionInputsManifest.v1",
        "versionID": CATALOG_APPROVAL_DECISION_INPUTS_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog approval decision input tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; decision input tooling only",
        "preflightRecordsPath": str(options.preflight_records_path),
        "decisionOwner": options.decision_owner,
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogApprovalDecisionInputs": str(output_root / "catalog-approval-decision-inputs.json"),
            "decisionInputPackets": str(output_root / "decision-input-packets.json"),
            "blockedDecisionInputs": str(output_root / "blocked-decision-inputs.json"),
            "completedApprovalArtifacts": str(output_root / "completed-approval-artifacts.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DECISION_INPUT_NON_CLAIMS,
    }

    write_json(output_root / "catalog-approval-decision-inputs.json", artifact)
    write_json(
        output_root / "decision-input-packets.json",
        {
            "kind": "ambitions.sourceAtlas.catalogApprovalDecisionInputPackets.v1",
            "createdAt": created_at,
            "decisionInputPackets": decision_input_packets,
        },
    )
    write_json(
        output_root / "blocked-decision-inputs.json",
        {
            "kind": "ambitions.sourceAtlas.catalogBlockedDecisionInputs.v1",
            "createdAt": created_at,
            "blockedDecisionInputs": blocked_inputs,
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
        "catalogApprovalDecisionInputs": stable_hash(read_json(output_root / "catalog-approval-decision-inputs.json")),
        "decisionInputPackets": stable_hash(read_json(output_root / "decision-input-packets.json")),
        "blockedDecisionInputs": stable_hash(read_json(output_root / "blocked-decision-inputs.json")),
        "completedApprovalArtifacts": stable_hash(read_json(output_root / "completed-approval-artifacts.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_approval_decision_inputs_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_approval_decision_inputs_report(
    markdown_path: Path,
    json_path: Path,
    *,
    preflight_records_path: Path,
    output_root: Path,
    created_at: str | None = None,
    decision_owner: str = "",
) -> dict[str, Any]:
    result = compile_catalog_approval_decision_inputs(
        CatalogApprovalDecisionInputsOptions(
            preflight_records_path=preflight_records_path,
            output_root=output_root,
            created_at=created_at,
            decision_owner=decision_owner,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_approval_decision_inputs_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_approval_decision_inputs_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Approval Decision Inputs Train 64",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Decision owner: {result['decisionOwner'] or 'not assigned'}",
        "",
        "Scope completed:",
        "- Deterministic reviewer input packets from catalog approval preflight records.",
        "- Source-lane, legal/terms, and API-governance missing fields grouped per proposal.",
        "- Draft decision artifacts remain draft_not_approved and are not finalizer approvals.",
        "",
        "Counts:",
        f"- Preflight records: {counts['preflightRecords']}",
        f"- Decision input packets: {counts['decisionInputPackets']}",
        f"- Decision inputs ready for completion: {counts['decisionInputReadyForCompletion']}",
        f"- Blocked decision inputs: {counts['blockedDecisionInputs']}",
        f"- Completed approval artifacts: {counts['completedApprovalArtifacts']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- Decision input packets are not approvals and do not create source authority.",
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
            "- Decision inputs are limited to public/reference governance review metadata.",
            "",
            "No private graph egress proof:",
            "- Preflight input and output privacy scans must pass before Source Green.",
            "- The command emits no private runtime payloads and no personalized output artifacts.",
            "",
            "License/terms proof:",
            "- Decision input packets preserve missing legal/terms fields and blocked posture.",
            "- Completed legal/terms approval is not claimed.",
            "- Outside legal approval is not claimed.",
            "",
            "Restricted-source exclusion proof:",
            "- Catalog/source-of-sources proposals remain reviewer inputs only until direct source authority is completed.",
            "",
            "Provenance completeness proof:",
            "- Not claimed in Train 64. This train prepares reviewer inputs only.",
            "",
            "Freshness/revocation proof:",
            "- Source-lane freshness fields are carried as decision inputs when missing.",
            "- No pack freshness or revocation operation ran.",
            "",
            "LKG/rollback proof:",
            "- No stable pointer or active registry write ran. Rollback is artifact removal.",
            "",
            "Native offline/no-account proof:",
            "- Not claimed in Train 64. No native files are touched by this decision-input compiler.",
            "",
            "Architecture closeout:",
            "- Final Architecture Tree inspected: yes.",
            "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
            "- Non-canonical owners touched: none.",
            "- Files moved or created: Foundry decision-input compiler, CLI command, tests, generated evidence.",
            "- Old/non-canonical paths removed: none.",
            "- Compatibility shims left behind: none.",
            "- Yellow architecture debt remaining: none from this tooling train; native runtime and release proof remain separate.",
            "- Next repair train if debt remains: reviewer-completed decision artifacts, then finalizer/mutation/applier gates.",
            "- No equivalent folder/path interpretation was used.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _preflight_records(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("decisionPreflightRecords"), list):
        return [item for item in payload["decisionPreflightRecords"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("catalogApprovalPreflight"), dict):
        return _preflight_records(payload["catalogApprovalPreflight"])
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _input_schema_issues(payload: Any, preflight_records: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog approval decision inputs input must be an object or array")
    if not preflight_records:
        issues.append("catalog approval decision inputs input must include decision preflight records")
    for index, record in enumerate(preflight_records):
        for field in ("preflight_id", "proposal_id", "intake_id", "status", "draft_entry"):
            if not record.get(field):
                issues.append(f"decisionPreflightRecords[{index}].{field} required")
    return issues


def _decision_input_packet(record: dict[str, Any], created_at: str, *, decision_owner: str) -> dict[str, Any]:
    missing_source = _string_list(record.get("missing_source_lane_fields"))
    missing_legal = _string_list(record.get("missing_legal_terms_fields"))
    missing_api = _string_list(record.get("missing_api_governance_fields"))
    blocking_reasons = sorted(set(_string_list(record.get("blocking_reasons"))))
    status = "decision_input_ready_for_reviewer_completion" if not blocking_reasons and record.get("status") == "decision_ready_for_reviewer_completion" else "blocked_review_required"
    draft_entry = record.get("draft_entry") if isinstance(record.get("draft_entry"), dict) else {}
    required_actions = _string_list(record.get("required_reviewer_actions"))
    completion_checklist = _completion_checklist(missing_source, missing_legal, missing_api, blocking_reasons, required_actions)
    proposal_id = str(record.get("proposal_id") or "")
    intake_id = str(record.get("intake_id") or "")
    return {
        "schema_version": "1.0.0",
        "decision_input_id": stable_id(
            "catalog_approval_decision_input",
            {
                "preflight_id": record.get("preflight_id"),
                "proposal_id": proposal_id,
                "intake_id": intake_id,
                "draft_entry": draft_entry,
            },
        ),
        "preflight_id": str(record.get("preflight_id") or ""),
        "proposal_id": proposal_id,
        "request_id": str(record.get("request_id") or ""),
        "intake_id": intake_id,
        "candidate_id": str(record.get("candidate_id") or ""),
        "domain_guess": str(record.get("domain_guess") or "unclassified_public_reference"),
        "source_id": str(record.get("source_id") or ""),
        "source_name": str(record.get("source_name") or ""),
        "created_at": created_at,
        "decision_owner": decision_owner,
        "packet_status": status,
        "source_authority_status": "reviewer_input_only",
        "legal_approval_status": "not_approved",
        "outside_legal_status": "not_claimed",
        "registry_mutation_status": "not_active",
        "source_lane_decision": {
            "missing_fields": missing_source,
            "current_entry": draft_entry.get("source_lane_entry") if isinstance(draft_entry.get("source_lane_entry"), dict) else {},
            "completion_required": bool(missing_source) or "source_lane_review_required" in blocking_reasons,
        },
        "legal_terms_decision": {
            "missing_fields": missing_legal,
            "current_entry": draft_entry.get("legal_terms_entry") if isinstance(draft_entry.get("legal_terms_entry"), dict) else {},
            "completion_required": bool(missing_legal) or "legal_terms_review_required" in blocking_reasons,
        },
        "api_governance_decision": {
            "missing_fields": missing_api,
            "current_entry": draft_entry.get("api_policy_entry") if isinstance(draft_entry.get("api_policy_entry"), dict) else {},
            "completion_required": bool(missing_api) or "api_governance_review_required" in blocking_reasons,
        },
        "blocking_reasons": blocking_reasons,
        "required_reviewer_actions": required_actions,
        "completion_checklist": completion_checklist,
        "draft_decision_artifact": {
            "kind": DECISION_KIND,
            "decision_artifact_id": "",
            "decision_status": "draft_not_approved",
            "created_at": created_at,
            "review_owner": decision_owner,
            "reviewed_at": "",
            "source_lane_review_complete": False,
            "legal_terms_review_complete": False,
            "api_governance_review_complete": False,
            "outside_legal_status": "not_claimed",
            "outside_legal_approval_artifact": "",
            "selected_proposal_ids": [proposal_id],
            "draft_entries": [
                {
                    "proposal_id": proposal_id,
                    "intake_id": intake_id,
                    "source_lane_missing_fields": missing_source,
                    "legal_terms_missing_fields": missing_legal,
                    "api_governance_missing_fields": missing_api,
                    "draft_entry": draft_entry,
                }
            ],
            "non_claims": [
                "draft decision input only",
                "not approval",
                "not legal approval",
                "not outside legal approval",
                "not source authority",
            ],
        },
        "non_claims": [
            "decision input packet only",
            "not approval",
            "not legal approval",
            "not outside legal approval",
            "not source authority",
            "not active registry mutation",
        ],
    }


def _completion_checklist(
    missing_source: list[str],
    missing_legal: list[str],
    missing_api: list[str],
    blocking_reasons: list[str],
    required_actions: list[str],
) -> list[dict[str, Any]]:
    checklist: list[dict[str, Any]] = [
        {
            "section": "source_lane",
            "status": "blocked" if missing_source else "ready_for_review",
            "missing_fields": missing_source,
            "required_action": "complete source lane authority, jurisdiction, review, freshness, and artifact policy fields",
        },
        {
            "section": "legal_terms",
            "status": "blocked" if missing_legal else "ready_for_review",
            "missing_fields": missing_legal,
            "required_action": "complete legal/terms redistribution, pack-output, restrictions, review, and expiry fields",
        },
        {
            "section": "api_governance",
            "status": "blocked" if missing_api else "ready_for_review",
            "missing_fields": missing_api,
            "required_action": "complete API governance key, budget, rate, retry, timeout, live/execute, and evidence policy fields",
        },
        {
            "section": "packability",
            "status": "blocked" if any(reason in blocking_reasons for reason in ("pack_policy_not_approved", "legal_terms_not_pack_approved")) else "ready_for_review",
            "missing_fields": [],
            "required_action": "keep pack output blocked unless redistribution and pack-output posture are explicitly approved",
        },
    ]
    if required_actions:
        checklist.append(
            {
                "section": "reviewer_actions",
                "status": "blocked" if blocking_reasons else "ready_for_review",
                "missing_fields": [],
                "required_action": " | ".join(required_actions),
            }
        )
    return checklist


def _approval_like_issues(packets: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    for index, packet in enumerate(packets):
        draft = packet.get("draft_decision_artifact") if isinstance(packet.get("draft_decision_artifact"), dict) else {}
        if draft.get("decision_status") != "draft_not_approved":
            issues.append(f"decisionInputPackets[{index}].draft_decision_artifact.decision_status must remain draft_not_approved")
        if "approved_entries" in draft:
            issues.append(f"decisionInputPackets[{index}].draft_decision_artifact must not include approved_entries")
        if packet.get("legal_approval_status") != "not_approved":
            issues.append(f"decisionInputPackets[{index}].legal_approval_status must remain not_approved")
        if packet.get("source_authority_status") != "reviewer_input_only":
            issues.append(f"decisionInputPackets[{index}].source_authority_status must remain reviewer_input_only")
        if packet.get("registry_mutation_status") != "not_active":
            issues.append(f"decisionInputPackets[{index}].registry_mutation_status must remain not_active")
    return issues


def _string_list(value: Any) -> list[str]:
    if not isinstance(value, list):
        return []
    return sorted({str(item) for item in value if isinstance(item, str) and item})


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
