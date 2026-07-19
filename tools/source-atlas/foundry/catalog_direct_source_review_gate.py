"""Gate direct-source review packets before reviewer-completion intake.

Train 70 finds direct-source resolution candidates. This gate accepts optional
source-specific review packets for those candidates and emits Train 67-shaped
source review completion packets only when source lane, legal/terms, API, and
packability evidence is complete. Missing review evidence remains blocked.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_reviewer_completion_intake import REVIEW_PACKET_COLLECTION_KIND
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_DIRECT_SOURCE_REVIEW_GATE_VERSION = "source-atlas-catalog-direct-source-review-gate-train-71"
CATALOG_DIRECT_SOURCE_REVIEW_GATE_KIND = "ambitions.sourceAtlas.catalogDirectSourceReviewGate.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

DIRECT_SOURCE_REVIEW_GATE_NON_CLAIMS = [
    "direct-source review gate only",
    "not source authority by itself",
    "not legal approval",
    "not outside legal approval without artifact",
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
    "review_required",
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
LEGAL_REQUIRED_FIELDS = [
    "license_id",
    "license_url",
    "terms_url",
    "rights_url",
    "redistribution_allowed",
    "pack_output_allowed",
    "attribution_required",
    "review_required",
    "outside_legal_required",
    "outside_legal_status",
    "reviewed_at",
    "review_owner",
    "expires_at",
    "schema_version",
]
API_REQUIRED_FIELDS = [
    "api_policy_id",
    "source_id",
    "api_mode",
    "key_required",
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


@dataclass(frozen=True)
class CatalogDirectSourceReviewGateOptions:
    resolution_candidates_path: Path
    output_root: Path
    direct_source_reviews_path: Path | None = None
    created_at: str | None = None


def compile_catalog_direct_source_review_gate(options: CatalogDirectSourceReviewGateOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    resolution_payload = read_json(options.resolution_candidates_path)
    resolution_candidates = _resolution_candidates(resolution_payload)
    resolution_schema_issues = _resolution_schema_issues(resolution_payload, resolution_candidates)
    resolution_privacy_issues = privacy_findings_for_value(resolution_payload, "catalog-direct-source-review-gate-resolution-candidates")

    review_payload = read_json(options.direct_source_reviews_path) if options.direct_source_reviews_path else None
    review_packets = _direct_source_review_packets(review_payload)
    review_schema_issues = _review_schema_issues(review_payload, review_packets, provided=options.direct_source_reviews_path is not None)
    review_privacy_issues = (
        privacy_findings_for_value(review_payload, "catalog-direct-source-review-gate-review-packets")
        if review_payload is not None
        else []
    )

    assembled = _assemble_source_review_completion_packets(resolution_candidates, review_packets, created_at)
    source_review_completion_packets = assembled["sourceReviewCompletionPackets"]
    blocked_reviews = assembled["blockedDirectSourceReviews"]
    record_counts = {
        "resolutionCandidates": len(resolution_candidates),
        "directSourceReviewPackets": len(review_packets),
        "sourceReviewCompletionPackets": len(source_review_completion_packets),
        "completedSourceReviewCompletionPackets": sum(1 for item in source_review_completion_packets if item["completion_status"] == "completed"),
        "blockedSourceReviewCompletionPackets": sum(1 for item in source_review_completion_packets if item["completion_status"] != "completed"),
        "blockedDirectSourceReviews": len(blocked_reviews),
        "activeRegistryMutations": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
    }
    collection = {
        "kind": REVIEW_PACKET_COLLECTION_KIND,
        "createdAt": created_at,
        "sourceReviewCompletionPackets": source_review_completion_packets,
        "nonClaims": [
            "source review completion packets for Train 67 intake only",
            "not approval by themselves",
            "not claim output",
            "not pack output",
        ],
    }
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_DIRECT_SOURCE_REVIEW_GATE_KIND,
        "versionID": CATALOG_DIRECT_SOURCE_REVIEW_GATE_VERSION,
        "createdAt": created_at,
        "resolutionCandidatesPath": str(options.resolution_candidates_path),
        "directSourceReviewsPath": str(options.direct_source_reviews_path) if options.direct_source_reviews_path else "",
        "sourceReviewCompletionPacketCollection": collection,
        "blockedDirectSourceReviews": blocked_reviews,
        "activeRegistryMutations": [],
        "recordCounts": record_counts,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DIRECT_SOURCE_REVIEW_GATE_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-direct-source-review-gate")
    collection_privacy_issues = privacy_findings_for_value(collection, "catalog-direct-source-review-gate-completion-packets")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    checks = [
        {"name": "resolution_candidates_schema_valid", "passed": not resolution_schema_issues and bool(resolution_candidates), "issues": resolution_schema_issues},
        {"name": "resolution_candidates_privacy_scan_passed", "passed": not resolution_privacy_issues, "issues": resolution_privacy_issues},
        {"name": "direct_source_review_schema_valid", "passed": not review_schema_issues, "issues": review_schema_issues},
        {"name": "direct_source_review_privacy_scan_passed", "passed": not review_privacy_issues, "issues": review_privacy_issues},
        {
            "name": "missing_direct_reviews_block_without_approval",
            "passed": options.direct_source_reviews_path is not None or record_counts["completedSourceReviewCompletionPackets"] == 0,
            "issues": [],
        },
        {
            "name": "completed_packets_require_direct_source_not_catalog",
            "passed": all(
                packet["completion_status"] != "completed"
                or not packet["source_lane_review"]["source_lane_entry"]["source_id"].startswith("catalog.candidate.")
                for packet in source_review_completion_packets
            ),
            "issues": [],
        },
        {
            "name": "review_gate_emits_no_claims",
            "passed": record_counts["claims"] == 0 and record_counts["packableClaims"] == 0 and record_counts["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {"name": "no_active_registry_mutations", "passed": record_counts["activeRegistryMutations"] == 0, "issues": []},
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues and not collection_privacy_issues, "issues": artifact_privacy_issues + collection_privacy_issues},
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
    ]

    issues: list[str] = []
    issues.extend(resolution_schema_issues)
    issues.extend(resolution_privacy_issues)
    issues.extend(review_schema_issues)
    issues.extend(review_privacy_issues)
    issues.extend(assembled["issues"])
    issues.extend(artifact_privacy_issues)
    issues.extend(collection_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogDirectSourceReviewGateManifest.v1",
        "versionID": CATALOG_DIRECT_SOURCE_REVIEW_GATE_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog direct-source review gate tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; direct-source review gate tooling only",
        "resolutionCandidatesPath": str(options.resolution_candidates_path),
        "directSourceReviewsPath": str(options.direct_source_reviews_path) if options.direct_source_reviews_path else "",
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogDirectSourceReviewGate": str(output_root / "catalog-direct-source-review-gate.json"),
            "sourceReviewCompletionPackets": str(output_root / "source-review-completion-packets.json"),
            "blockedDirectSourceReviews": str(output_root / "blocked-direct-source-reviews.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DIRECT_SOURCE_REVIEW_GATE_NON_CLAIMS,
    }

    write_json(output_root / "catalog-direct-source-review-gate.json", artifact)
    write_json(output_root / "source-review-completion-packets.json", collection)
    write_json(
        output_root / "blocked-direct-source-reviews.json",
        {
            "kind": "ambitions.sourceAtlas.catalogBlockedDirectSourceReviews.v1",
            "createdAt": created_at,
            "blockedDirectSourceReviews": blocked_reviews,
        },
    )
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogDirectSourceReviewGate": stable_hash(read_json(output_root / "catalog-direct-source-review-gate.json")),
        "sourceReviewCompletionPackets": stable_hash(read_json(output_root / "source-review-completion-packets.json")),
        "blockedDirectSourceReviews": stable_hash(read_json(output_root / "blocked-direct-source-reviews.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_direct_source_review_gate_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_direct_source_review_gate_report(
    markdown_path: Path,
    json_path: Path,
    *,
    resolution_candidates_path: Path,
    output_root: Path,
    direct_source_reviews_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_direct_source_review_gate(
        CatalogDirectSourceReviewGateOptions(
            resolution_candidates_path=resolution_candidates_path,
            output_root=output_root,
            direct_source_reviews_path=direct_source_reviews_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_direct_source_review_gate_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_direct_source_review_gate_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Direct-Source Review Gate Train 71",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic gate from direct-source resolution candidates to Train 67 source-review completion packets.",
        "- Missing direct-source review evidence emits blocked completion packets, not approvals.",
        "- Completed packets require direct-source, source-lane, legal/terms, API, and packability evidence before completion.",
        "",
        "Counts:",
        f"- Resolution candidates: {counts['resolutionCandidates']}",
        f"- Direct-source review packets: {counts['directSourceReviewPackets']}",
        f"- Source review completion packets: {counts['sourceReviewCompletionPackets']}",
        f"- Completed source review completion packets: {counts['completedSourceReviewCompletionPackets']}",
        f"- Blocked source review completion packets: {counts['blockedSourceReviewCompletionPackets']}",
        f"- Blocked direct-source reviews: {counts['blockedDirectSourceReviews']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- No claims, packs, active registry writes, R2 objects, final plans, schedules, or Steps are emitted.",
        "- The output is a governance handoff to Train 67, not source authority or legal approval by itself.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed by this gate.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _resolution_candidates(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("resolutionCandidates"), list):
        return [item for item in payload["resolutionCandidates"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("catalogDirectSourceResolution"), dict):
        return _resolution_candidates(payload["catalogDirectSourceResolution"])
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _direct_source_review_packets(payload: Any) -> list[dict[str, Any]]:
    if payload is None:
        return []
    if isinstance(payload, dict) and isinstance(payload.get("directSourceReviewPackets"), list):
        return [item for item in payload["directSourceReviewPackets"] if isinstance(item, dict)]
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _resolution_schema_issues(payload: Any, candidates: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog direct-source review gate candidates input must be an object or array")
    if not candidates:
        issues.append("catalog direct-source review gate requires resolution candidates")
    for index, candidate in enumerate(candidates):
        for field in ("resolution_id", "candidate_id", "proposal_id", "intake_id", "source_id", "domain_guess"):
            if not candidate.get(field):
                issues.append(f"resolutionCandidates[{index}].{field} required")
    return issues


def _review_schema_issues(payload: Any, packets: list[dict[str, Any]], *, provided: bool) -> list[str]:
    if not provided:
        return []
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog direct-source review packets input must be an object or array")
    if not packets:
        issues.append("catalog direct-source review packets input must include directSourceReviewPackets")
    for index, packet in enumerate(packets):
        for field in ("resolution_id", "candidate_id", "completion_status"):
            if not packet.get(field):
                issues.append(f"directSourceReviewPackets[{index}].{field} required")
    return issues


def _assemble_source_review_completion_packets(
    candidates: list[dict[str, Any]],
    reviews: list[dict[str, Any]],
    created_at: str,
) -> dict[str, Any]:
    issues: list[str] = []
    reviews_by_resolution: dict[str, dict[str, Any]] = {}
    duplicates: set[str] = set()
    for review in reviews:
        resolution_id = str(review.get("resolution_id") or "")
        if resolution_id in reviews_by_resolution:
            duplicates.add(resolution_id)
        if resolution_id:
            reviews_by_resolution[resolution_id] = review
    for resolution_id in sorted(duplicates):
        issues.append(f"{resolution_id}: duplicate direct-source review packet")

    completion_packets: list[dict[str, Any]] = []
    blocked: list[dict[str, Any]] = []
    candidate_ids = {str(candidate.get("candidate_id") or "") for candidate in candidates}
    for candidate in sorted(candidates, key=lambda item: (item["domain_guess"], item["source_name"], item["candidate_id"])):
        review = reviews_by_resolution.get(str(candidate.get("resolution_id") or ""))
        if not review:
            block_reasons = ["direct_source_review_packet_required", *[f"{item}_missing" for item in candidate.get("missing_locator_classes", [])]]
            packet = _blocked_completion_packet(candidate, created_at, block_reasons)
            completion_packets.append(packet)
            blocked.append(_blocked_direct_source_review(candidate, created_at, block_reasons))
            continue
        if review.get("candidate_id") != candidate.get("candidate_id"):
            issues.append(f"{candidate.get('resolution_id')}: review packet candidate_id must match resolution candidate")
        if review.get("completion_status") != "completed":
            block_reasons = [f"direct_source_review_status_{review.get('completion_status') or 'missing'}"]
            packet = _blocked_completion_packet(candidate, created_at, block_reasons)
            completion_packets.append(packet)
            blocked.append(_blocked_direct_source_review(candidate, created_at, block_reasons))
            continue
        review_issues = _completed_direct_source_review_issues(review)
        if review_issues:
            issues.extend(review_issues)
            block_reasons = ["direct_source_review_packet_invalid", *review_issues]
            packet = _blocked_completion_packet(candidate, created_at, block_reasons)
            completion_packets.append(packet)
            blocked.append(_blocked_direct_source_review(candidate, created_at, block_reasons))
            continue
        completion_packets.append(_completed_completion_packet(candidate, review, created_at))

    for resolution_id, review in sorted(reviews_by_resolution.items()):
        if str(review.get("candidate_id") or "") not in candidate_ids:
            issues.append(f"{resolution_id}: direct-source review packet does not match a resolution candidate")

    return {
        "sourceReviewCompletionPackets": sorted(completion_packets, key=lambda item: (item["proposal_id"], item["intake_id"])),
        "blockedDirectSourceReviews": sorted(blocked, key=lambda item: (item["proposal_id"], item["intake_id"])),
        "issues": sorted(set(issues)),
    }


def _completed_completion_packet(candidate: dict[str, Any], review: dict[str, Any], created_at: str) -> dict[str, Any]:
    legal_entry = review["legal_terms_entry"]
    outside_legal_status = str(review.get("outside_legal_status") or legal_entry.get("outside_legal_status") or "not_claimed")
    outside_legal_artifact = str(review.get("outside_legal_approval_artifact") or legal_entry.get("approval_artifact_path") or "")
    return {
        "completion_packet_id": stable_id("catalog_source_review_completion", {"resolution_id": candidate["resolution_id"], "created_at": created_at}),
        "proposal_id": str(candidate.get("proposal_id") or ""),
        "intake_id": str(candidate.get("intake_id") or ""),
        "completion_status": "completed",
        "review_owner": str(review.get("review_owner") or ""),
        "reviewed_at": str(review.get("reviewed_at") or ""),
        "source_lane_review": {
            "status": "completed",
            "source_lane_entry": review["source_lane_entry"],
        },
        "legal_terms_review": {
            "status": "completed",
            "outside_legal_status": outside_legal_status,
            "outside_legal_approval_artifact": outside_legal_artifact,
            "legal_terms_entry": legal_entry,
        },
        "api_governance_review": {
            "status": "completed",
            "api_policy_entry": review["api_policy_entry"],
        },
        "non_claims": [
            "direct-source review completion packet only",
            "not active registry mutation",
            "not claim output",
            "not pack output by itself",
        ],
    }


def _blocked_completion_packet(candidate: dict[str, Any], created_at: str, reasons: list[str]) -> dict[str, Any]:
    return {
        "completion_packet_id": stable_id("catalog_source_review_completion_blocked", {"resolution_id": candidate.get("resolution_id"), "reasons": sorted(reasons)}),
        "proposal_id": str(candidate.get("proposal_id") or ""),
        "intake_id": str(candidate.get("intake_id") or ""),
        "completion_status": "blocked_direct_source_review_required",
        "review_owner": "",
        "reviewed_at": "",
        "source_lane_review": {"status": "blocked", "source_lane_entry": {}},
        "legal_terms_review": {
            "status": "blocked",
            "outside_legal_status": "not_claimed",
            "outside_legal_approval_artifact": "",
            "legal_terms_entry": {},
        },
        "api_governance_review": {"status": "blocked", "api_policy_entry": {}},
        "blocking_reasons": sorted(set(reasons)),
        "non_claims": ["blocked direct-source review completion packet only", "not approval"],
    }


def _blocked_direct_source_review(candidate: dict[str, Any], created_at: str, reasons: list[str]) -> dict[str, Any]:
    return {
        "schema_version": "1.0.0",
        "blocked_direct_source_review_id": stable_id("catalog_direct_source_review_block", {"resolution_id": candidate.get("resolution_id"), "reasons": sorted(reasons)}),
        "created_at": created_at,
        "status": "blocked",
        "resolution_id": str(candidate.get("resolution_id") or ""),
        "proposal_id": str(candidate.get("proposal_id") or ""),
        "intake_id": str(candidate.get("intake_id") or ""),
        "candidate_id": str(candidate.get("candidate_id") or ""),
        "source_id": str(candidate.get("source_id") or ""),
        "source_name": str(candidate.get("source_name") or ""),
        "domain_guess": str(candidate.get("domain_guess") or ""),
        "blocking_reasons": sorted(set(reasons)),
        "non_claims": ["blocked direct-source review only", "not approval", "not claim output", "not pack output"],
    }


def _completed_direct_source_review_issues(review: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    for field in ("review_owner", "reviewed_at"):
        if _missing(review.get(field)):
            issues.append(f"{review.get('resolution_id')}: {field} required")
    source_lane = review.get("source_lane_entry") if isinstance(review.get("source_lane_entry"), dict) else {}
    legal_terms = review.get("legal_terms_entry") if isinstance(review.get("legal_terms_entry"), dict) else {}
    api_policy = review.get("api_policy_entry") if isinstance(review.get("api_policy_entry"), dict) else {}
    issues.extend(_required_field_issues(source_lane, SOURCE_LANE_REQUIRED_FIELDS, f"{review.get('resolution_id')}: source_lane_entry"))
    issues.extend(_required_field_issues(legal_terms, LEGAL_REQUIRED_FIELDS, f"{review.get('resolution_id')}: legal_terms_entry"))
    issues.extend(_required_field_issues(api_policy, API_REQUIRED_FIELDS, f"{review.get('resolution_id')}: api_policy_entry"))
    if str(source_lane.get("source_id") or "").startswith("catalog.candidate."):
        issues.append(f"{review.get('resolution_id')}: completed source_lane_entry.source_id must not remain catalog.candidate")
    if source_lane.get("source_class") == "public_catalog":
        issues.append(f"{review.get('resolution_id')}: completed source_lane_entry.source_class must not be public_catalog")
    if source_lane.get("authority_class") in {"public_catalog", "open_knowledge_graph", "unknown", ""}:
        issues.append(f"{review.get('resolution_id')}: completed source_lane_entry.authority_class is not sufficient for authority review")
    if source_lane.get("review_status") != "reviewed" or source_lane.get("review_required") is not False:
        issues.append(f"{review.get('resolution_id')}: source lane review_status/review_required must be reviewed/false")
    if source_lane.get("r2_pack_policy") in {"pack_allowed", "pack_allowed_with_attribution"} and legal_terms.get("pack_output_allowed") is not True:
        issues.append(f"{review.get('resolution_id')}: pack-allowed source lane requires legal_terms_entry.pack_output_allowed true")
    if source_lane.get("r2_pack_policy") in {"pack_allowed", "pack_allowed_with_attribution"} and not source_lane.get("r2_object_key_prefix"):
        issues.append(f"{review.get('resolution_id')}: pack-allowed source lane requires r2_object_key_prefix")
    if legal_terms.get("outside_legal_status") == "approved" and not legal_terms.get("approval_artifact_path"):
        issues.append(f"{review.get('resolution_id')}: outside legal approval requires approval_artifact_path")
    if legal_terms.get("outside_legal_required") is True and not legal_terms.get("approval_artifact_path"):
        issues.append(f"{review.get('resolution_id')}: outside legal required source requires approval_artifact_path")
    if api_policy.get("secret_redaction_required") is not True:
        issues.append(f"{review.get('resolution_id')}: api_policy_entry.secret_redaction_required must be true")
    if api_policy.get("live_flag_required") is not True or api_policy.get("execute_flag_required") is not True:
        issues.append(f"{review.get('resolution_id')}: api policy must require live and execute flags")
    issues.extend(privacy_findings_for_value(review, f"directSourceReviewPackets[{review.get('resolution_id')}]"))
    return sorted(set(issues))


def _required_field_issues(entry: dict[str, Any], required_fields: list[str], label: str) -> list[str]:
    if not entry:
        return [f"{label} required"]
    issues: list[str] = []
    for field in required_fields:
        if _missing(entry.get(field)):
            issues.append(f"{label}.{field} required")
    return issues


def _missing(value: Any) -> bool:
    if value is None:
        return True
    if isinstance(value, str):
        return value.strip() == ""
    if isinstance(value, list):
        return len(value) == 0
    if isinstance(value, dict):
        return len(value) == 0
    return False


def _contains_forbidden_output_marker(value: Any) -> bool:
    if isinstance(value, str):
        return value in FORBIDDEN_OUTPUT_MARKERS
    if isinstance(value, list):
        return any(_contains_forbidden_output_marker(item) for item in value)
    if isinstance(value, dict):
        return any(
            _contains_forbidden_output_marker(item)
            for key, item in value.items()
            if key not in {"forbidden_artifact_classes", "claim_classes_forbidden", "non_claims", "blocking_reasons"}
        )
    return False
