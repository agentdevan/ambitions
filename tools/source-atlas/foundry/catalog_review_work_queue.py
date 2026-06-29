"""Compile blocked catalog review inputs into deterministic work queues.

The work queue is the autonomous control surface between discovery and approval:
it explains exactly what evidence is still missing before a candidate can move
toward source-lane completion. It never upgrades catalog/source-of-sources data
to authority and never emits approvals, claims, packs, or registry writes.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_REVIEW_WORK_QUEUE_VERSION = "source-atlas-catalog-review-work-queue-train-69"
CATALOG_REVIEW_WORK_QUEUE_KIND = "ambitions.sourceAtlas.catalogReviewWorkQueue.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

WORK_QUEUE_NON_CLAIMS = [
    "review work queue only",
    "not completed reviewer packets",
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
class CatalogReviewWorkQueueOptions:
    decision_inputs_path: Path
    output_root: Path
    review_packets_path: Path | None = None
    created_at: str | None = None


def compile_catalog_review_work_queue(options: CatalogReviewWorkQueueOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    input_payload = read_json(options.decision_inputs_path)
    packets = _decision_input_packets(input_payload)
    input_schema_issues = _input_schema_issues(input_payload, packets)
    input_privacy_issues = privacy_findings_for_value(input_payload, "catalog-review-work-queue-decision-inputs")

    review_payload = read_json(options.review_packets_path) if options.review_packets_path else None
    review_packets = _review_packets(review_payload)
    review_schema_issues = _review_schema_issues(review_payload, review_packets, provided=options.review_packets_path is not None)
    review_privacy_issues = privacy_findings_for_value(review_payload, "catalog-review-work-queue-review-packets") if review_payload is not None else []
    reviews_by_proposal = {str(packet.get("proposal_id") or ""): packet for packet in review_packets}

    work_items = [_work_item(packet, reviews_by_proposal.get(str(packet.get("proposal_id") or "")), created_at) for packet in packets]
    work_items = sorted(work_items, key=lambda item: (item["domain_guess"], item["intake_id"], item["proposal_id"]))
    lane_counts = _lane_counts(work_items)
    queue_summary = {
        "domains": sorted({item["domain_guess"] for item in work_items}),
        "workItemCount": len(work_items),
        "laneCounts": lane_counts,
        "readyForReviewerCompletionIntake": sum(1 for item in work_items if item["ready_for_reviewer_completion_intake"]),
        "blockedFromCompletion": sum(1 for item in work_items if not item["ready_for_reviewer_completion_intake"]),
    }
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_REVIEW_WORK_QUEUE_KIND,
        "versionID": CATALOG_REVIEW_WORK_QUEUE_VERSION,
        "createdAt": created_at,
        "decisionInputsPath": str(options.decision_inputs_path),
        "reviewPacketsPath": str(options.review_packets_path) if options.review_packets_path else "",
        "queueSummary": queue_summary,
        "reviewWorkItems": work_items,
        "activeRegistryMutations": [],
        "recordCounts": {
            "decisionInputPackets": len(packets),
            "reviewPackets": len(review_packets),
            "reviewWorkItems": len(work_items),
            "directSourceResolutionTasks": lane_counts["direct_source_authority_resolution"],
            "sourceLaneReviewTasks": lane_counts["source_lane_review"],
            "legalTermsReviewTasks": lane_counts["legal_terms_review"],
            "apiGovernanceReviewTasks": lane_counts["api_governance_review"],
            "packabilityDecisionTasks": lane_counts["packability_decision"],
            "readyForReviewerCompletionIntake": queue_summary["readyForReviewerCompletionIntake"],
            "blockedFromCompletion": queue_summary["blockedFromCompletion"],
            "completedReviewerCompletions": 0,
            "completedDecisionArtifacts": 0,
            "activeRegistryMutations": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": WORK_QUEUE_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-review-work-queue")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(packets), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {"name": "review_packet_schema_valid", "passed": not review_schema_issues, "issues": review_schema_issues},
        {"name": "review_packet_privacy_scan_passed", "passed": not review_privacy_issues, "issues": review_privacy_issues},
        {
            "name": "catalog_source_candidates_remain_blocked",
            "passed": all("direct_source_authority_resolution" in item["work_lanes"] for item in work_items),
            "issues": [],
        },
        {
            "name": "work_queue_emits_no_claims",
            "passed": artifact["recordCounts"]["claims"] == 0
            and artifact["recordCounts"]["packableClaims"] == 0
            and artifact["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {"name": "no_completed_review_or_approval_artifacts", "passed": artifact["recordCounts"]["completedReviewerCompletions"] == 0 and artifact["recordCounts"]["completedDecisionArtifacts"] == 0, "issues": []},
        {"name": "no_active_registry_mutations", "passed": artifact["recordCounts"]["activeRegistryMutations"] == 0, "issues": []},
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues, "issues": artifact_privacy_issues},
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
    ]

    issues: list[str] = []
    issues.extend(input_schema_issues)
    issues.extend(input_privacy_issues)
    issues.extend(review_schema_issues)
    issues.extend(review_privacy_issues)
    issues.extend(artifact_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogReviewWorkQueueManifest.v1",
        "versionID": CATALOG_REVIEW_WORK_QUEUE_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog review work queue tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; review work queue tooling only",
        "decisionInputsPath": str(options.decision_inputs_path),
        "reviewPacketsPath": str(options.review_packets_path) if options.review_packets_path else "",
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogReviewWorkQueue": str(output_root / "catalog-review-work-queue.json"),
            "reviewWorkItems": str(output_root / "review-work-items.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": WORK_QUEUE_NON_CLAIMS,
    }

    write_json(output_root / "catalog-review-work-queue.json", artifact)
    write_json(
        output_root / "review-work-items.json",
        {
            "kind": "ambitions.sourceAtlas.catalogReviewWorkItems.v1",
            "createdAt": created_at,
            "reviewWorkItems": work_items,
            "nonClaims": ["work items only", "not approvals", "not claim output", "not pack output"],
        },
    )
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogReviewWorkQueue": stable_hash(read_json(output_root / "catalog-review-work-queue.json")),
        "reviewWorkItems": stable_hash(read_json(output_root / "review-work-items.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_review_work_queue_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_review_work_queue_report(
    markdown_path: Path,
    json_path: Path,
    *,
    decision_inputs_path: Path,
    output_root: Path,
    review_packets_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_review_work_queue(
        CatalogReviewWorkQueueOptions(
            decision_inputs_path=decision_inputs_path,
            output_root=output_root,
            review_packets_path=review_packets_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_review_work_queue_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_review_work_queue_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Review Work Queue Train 69",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic work queue for blocked catalog reviewer completion packets.",
        "- Direct-source, source-lane, legal/terms, API, and packability lanes are explicit.",
        "- Catalog/source-of-sources candidates remain blocked until direct authority and review evidence exists.",
        "",
        "Counts:",
        f"- Decision input packets: {counts['decisionInputPackets']}",
        f"- Review packets: {counts['reviewPackets']}",
        f"- Review work items: {counts['reviewWorkItems']}",
        f"- Direct source resolution tasks: {counts['directSourceResolutionTasks']}",
        f"- Source lane review tasks: {counts['sourceLaneReviewTasks']}",
        f"- Legal/terms review tasks: {counts['legalTermsReviewTasks']}",
        f"- API governance review tasks: {counts['apiGovernanceReviewTasks']}",
        f"- Packability decision tasks: {counts['packabilityDecisionTasks']}",
        f"- Ready for reviewer completion intake: {counts['readyForReviewerCompletionIntake']}",
        f"- Blocked from completion: {counts['blockedFromCompletion']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- No claims, packs, active registry writes, R2 objects, final plans, schedules, or Steps are emitted.",
        "- Work items are instructions for public/reference source review, not approval artifacts.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed by this work queue.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _decision_input_packets(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("decisionInputPackets"), list):
        return [item for item in payload["decisionInputPackets"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("catalogApprovalDecisionInputs"), dict):
        return _decision_input_packets(payload["catalogApprovalDecisionInputs"])
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _review_packets(payload: Any) -> list[dict[str, Any]]:
    if payload is None:
        return []
    if isinstance(payload, dict) and isinstance(payload.get("sourceReviewCompletionPackets"), list):
        return [item for item in payload["sourceReviewCompletionPackets"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("reviewCompletionPackets"), list):
        return [item for item in payload["reviewCompletionPackets"] if isinstance(item, dict)]
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _input_schema_issues(payload: Any, packets: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog review work queue input must be an object or array")
    if not packets:
        issues.append("catalog review work queue input must include decision input packets")
    for index, packet in enumerate(packets):
        for field in ("decision_input_id", "proposal_id", "intake_id", "candidate_id", "source_id", "domain_guess"):
            if not packet.get(field):
                issues.append(f"decisionInputPackets[{index}].{field} required")
    return issues


def _review_schema_issues(payload: Any, packets: list[dict[str, Any]], *, provided: bool) -> list[str]:
    if not provided:
        return []
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog review work queue review packets input must be an object or array")
    if not packets:
        issues.append("catalog review work queue review packets input must include sourceReviewCompletionPackets")
    for index, packet in enumerate(packets):
        for field in ("proposal_id", "intake_id", "completion_status"):
            if not packet.get(field):
                issues.append(f"sourceReviewCompletionPackets[{index}].{field} required")
    return issues


def _work_item(packet: dict[str, Any], review_packet: dict[str, Any] | None, created_at: str) -> dict[str, Any]:
    proposal_id = str(packet.get("proposal_id") or "")
    intake_id = str(packet.get("intake_id") or "")
    source_id = str(packet.get("source_id") or "")
    lanes = _work_lanes(packet, review_packet)
    required_artifacts = _required_artifacts(lanes)
    return {
        "schema_version": "1.0.0",
        "work_item_id": stable_id("catalog_review_work_item", {"proposal_id": proposal_id, "intake_id": intake_id, "lanes": lanes}),
        "created_at": created_at,
        "status": "blocked_review_work_required",
        "priority": _priority_for_domain(str(packet.get("domain_guess") or "")),
        "proposal_id": proposal_id,
        "intake_id": intake_id,
        "candidate_id": str(packet.get("candidate_id") or ""),
        "decision_input_id": str(packet.get("decision_input_id") or ""),
        "domain_guess": str(packet.get("domain_guess") or "unclassified_public_reference"),
        "source_id": source_id,
        "source_name": str(packet.get("source_name") or ""),
        "review_packet_id": str((review_packet or {}).get("completion_packet_id") or ""),
        "review_packet_status": str((review_packet or {}).get("completion_status") or "not_provided"),
        "source_authority_status": str(packet.get("source_authority_status") or "review_required"),
        "ready_for_reviewer_completion_intake": (review_packet or {}).get("completion_status") == "completed",
        "work_lanes": lanes,
        "required_artifacts": required_artifacts,
        "automatable_discovery_steps": [
            "resolve direct publisher dataset page from catalog metadata",
            "collect direct source terms, rights, license, and API documentation URLs",
            "classify direct source authority, jurisdiction, and source class",
            "draft API governance policy with live/execute/rate/budget/secret redaction controls",
        ],
        "reviewer_only_steps": [
            "decide whether direct source can be source authority",
            "decide redistribution and pack-output posture from reviewed terms",
            "supply outside legal approval artifact only if outside legal approval is claimed or required",
            "approve or block R2 pack policy for this artifact class",
        ],
        "blocking_reasons": _blocking_reasons(packet, review_packet, lanes),
        "completion_checklist": packet.get("completion_checklist", []),
        "non_claims": ["work item only", "not approval", "not source authority", "not claim output", "not pack output"],
    }


def _work_lanes(packet: dict[str, Any], review_packet: dict[str, Any] | None) -> list[str]:
    lanes = {
        "direct_source_authority_resolution",
        "source_lane_review",
        "legal_terms_review",
        "api_governance_review",
        "packability_decision",
    }
    if review_packet:
        if review_packet.get("source_lane_review", {}).get("status") == "completed":
            lanes.discard("source_lane_review")
        if review_packet.get("legal_terms_review", {}).get("status") == "completed":
            lanes.discard("legal_terms_review")
        if review_packet.get("api_governance_review", {}).get("status") == "completed":
            lanes.discard("api_governance_review")
    if str(packet.get("source_id") or "").startswith("catalog.candidate.") or packet.get("source_authority_status") == "reviewer_input_only":
        lanes.add("direct_source_authority_resolution")
    return sorted(lanes)


def _required_artifacts(lanes: list[str]) -> list[str]:
    artifacts: list[str] = []
    if "direct_source_authority_resolution" in lanes:
        artifacts.extend(["direct_source_locator", "direct_source_authority_evidence"])
    if "source_lane_review" in lanes:
        artifacts.append("completed_source_lane_entry")
    if "legal_terms_review" in lanes:
        artifacts.append("completed_legal_terms_entry")
    if "api_governance_review" in lanes:
        artifacts.append("completed_api_policy_entry")
    if "packability_decision" in lanes:
        artifacts.append("packability_decision_record")
    return artifacts


def _blocking_reasons(packet: dict[str, Any], review_packet: dict[str, Any] | None, lanes: list[str]) -> list[str]:
    reasons = {str(reason) for reason in packet.get("blocking_reasons", []) if isinstance(reason, str)}
    if not review_packet:
        reasons.add("source_review_completion_packet_not_provided")
    elif review_packet.get("completion_status") != "completed":
        reasons.add(f"source_review_completion_packet_{review_packet.get('completion_status') or 'missing_status'}")
    for lane in lanes:
        reasons.add(f"{lane}_required")
    return sorted(reasons)


def _lane_counts(work_items: list[dict[str, Any]]) -> dict[str, int]:
    lanes = [
        "direct_source_authority_resolution",
        "source_lane_review",
        "legal_terms_review",
        "api_governance_review",
        "packability_decision",
    ]
    return {lane: sum(1 for item in work_items if lane in item["work_lanes"]) for lane in lanes}


def _priority_for_domain(domain: str) -> str:
    if domain in {"health_wellness_reference", "finance_public_reference", "public_civic_requirements"}:
        return "high_review_sensitivity"
    if domain in {"education_credentialing", "business_entrepreneurship", "travel_relocation"}:
        return "standard_governed_review"
    return "standard_review"


def _contains_forbidden_output_marker(value: Any) -> bool:
    if isinstance(value, str):
        return value in FORBIDDEN_OUTPUT_MARKERS
    if isinstance(value, list):
        return any(_contains_forbidden_output_marker(item) for item in value)
    if isinstance(value, dict):
        return any(
            _contains_forbidden_output_marker(item)
            for key, item in value.items()
            if key not in {"forbidden_artifact_classes", "claim_classes_forbidden", "non_claims", "blocking_reasons", "required_reviewer_actions"}
        )
    return False
