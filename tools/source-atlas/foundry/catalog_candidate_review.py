"""Governed review packets for catalog-discovered Source Atlas candidates.

Catalog discovery and transport are source-of-sources lanes. This compiler
turns candidate metadata into review packets only: no active source lanes,
claims, packable artifacts, or R2-ready output are emitted.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_discovery import CATALOG_NON_CLAIMS
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_CANDIDATE_REVIEW_VERSION = "source-atlas-catalog-candidate-review-train-56"
CATALOG_CANDIDATE_REVIEW_KIND = "ambitions.sourceAtlas.catalogCandidateReview.v1"

FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}
FORBIDDEN_ARTIFACT_CLASSES = [
    "final_user_path",
    "final_schedule",
    "step_list",
    "personalized_plan",
    "private_goal_graph",
]
REVIEW_NON_CLAIMS = [
    "not source authority",
    "not active source lane",
    "not claim output",
    "not pack output",
    "not R2 readiness",
    "not legal approval",
    "not outside legal approval",
    "not universal coverage",
    "not app runtime readiness",
    "not release readiness",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]


@dataclass(frozen=True)
class CatalogCandidateReviewOptions:
    input_path: Path
    output_root: Path
    created_at: str | None = None


def compile_catalog_candidate_review(options: CatalogCandidateReviewOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload = read_json(options.input_path)
    candidates = _candidate_records(payload)
    input_schema_issues = _input_schema_issues(payload, candidates)
    input_privacy_issues = privacy_findings_for_value(payload, "catalog-candidate-review-input")

    review_packets: list[dict[str, Any]] = []
    blocked_promotions: list[dict[str, Any]] = []
    issues: list[str] = list(input_schema_issues)
    for index, candidate in enumerate(candidates):
        candidate_issues = _candidate_issues(candidate, index)
        issues.extend(candidate_issues)
        packet = _review_packet(candidate, created_at, candidate_issues)
        review_packets.append(packet)
        blocked_promotions.append(_blocked_promotion(candidate, packet, created_at))

    review_packets = sorted(review_packets, key=lambda item: (item["domain_guess"], item["candidate_id"], item["packet_id"]))
    blocked_promotions = sorted(blocked_promotions, key=lambda item: (item["domain_guess"], item["candidate_id"], item["packet_id"]))
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_CANDIDATE_REVIEW_KIND,
        "versionID": CATALOG_CANDIDATE_REVIEW_VERSION,
        "createdAt": created_at,
        "inputPath": str(options.input_path),
        "reviewPackets": review_packets,
        "blockedPromotions": blocked_promotions,
        "recordCounts": {
            "candidateSources": len(candidates),
            "reviewPackets": len(review_packets),
            "blockedPromotions": len(blocked_promotions),
            "activeSourceLanes": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": REVIEW_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-candidate-review")
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(candidates), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {
            "name": "candidate_review_emits_no_claims",
            "passed": artifact["recordCounts"]["claims"] == 0
            and artifact["recordCounts"]["packableClaims"] == 0
            and artifact["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "no_active_source_lanes_emitted",
            "passed": artifact["recordCounts"]["activeSourceLanes"] == 0
            and all(packet["active_source_lane_emitted"] is False for packet in review_packets),
            "issues": [],
        },
        {
            "name": "all_packets_review_required",
            "passed": all(packet["review_required"] is True for packet in review_packets),
            "issues": [],
        },
        {
            "name": "all_packets_claim_authority_blocked",
            "passed": all(packet["claim_authority_allowed"] is False for packet in review_packets),
            "issues": [],
        },
        {
            "name": "all_packets_pack_output_blocked",
            "passed": all(packet["pack_output_allowed"] is False for packet in review_packets),
            "issues": [],
        },
        {
            "name": "all_packets_source_of_sources_only",
            "passed": all("catalog_metadata_not_claim_authority" in packet["blocking_reasons"] for packet in review_packets),
            "issues": [],
        },
        {
            "name": "all_packets_require_legal_terms_review",
            "passed": all("legal_terms_review_required" in packet["blocking_reasons"] for packet in review_packets),
            "issues": [],
        },
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues, "issues": artifact_privacy_issues},
        {
            "name": "no_final_plan_schedule_step_output",
            "passed": not _contains_forbidden_output_marker(artifact),
            "issues": [] if not _contains_forbidden_output_marker(artifact) else ["forbidden final-output marker found"],
        },
    ]
    issues.extend(input_privacy_issues)
    issues.extend(artifact_privacy_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogCandidateReviewManifest.v1",
        "versionID": CATALOG_CANDIDATE_REVIEW_VERSION,
        "createdAt": created_at,
        "status": "Source Green for governed catalog candidate review-packet tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; catalog candidates remain review-required and pack-blocked",
        "inputPath": str(options.input_path),
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogCandidateReview": str(output_root / "catalog-candidate-review.json"),
            "reviewPackets": str(output_root / "review-packets.json"),
            "blockedPromotions": str(output_root / "blocked-promotions.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": REVIEW_NON_CLAIMS,
    }

    write_json(output_root / "catalog-candidate-review.json", artifact)
    write_json(output_root / "review-packets.json", {"reviewPackets": review_packets, "createdAt": created_at, "kind": "ambitions.sourceAtlas.catalogCandidateReviewPackets.v1"})
    write_json(output_root / "blocked-promotions.json", {"blockedPromotions": blocked_promotions, "createdAt": created_at, "kind": "ambitions.sourceAtlas.catalogCandidateBlockedPromotions.v1"})
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogCandidateReview": stable_hash(read_json(output_root / "catalog-candidate-review.json")),
        "reviewPackets": stable_hash(read_json(output_root / "review-packets.json")),
        "blockedPromotions": stable_hash(read_json(output_root / "blocked-promotions.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_candidate_review_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_candidate_review_report(
    markdown_path: Path,
    json_path: Path,
    *,
    input_path: Path,
    output_root: Path,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_candidate_review(
        CatalogCandidateReviewOptions(
            input_path=input_path,
            output_root=output_root,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_candidate_review_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_candidate_review_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Candidate Review Train 56",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Review-packet compiler for catalog-discovered public/reference candidate source records.",
        "- Deterministic blocked-promotion report for candidate sources that are not active source lanes.",
        "- Source-of-sources, legal/terms, API, claim-authority, and pack-output gates before governance promotion.",
        "",
        "Counts:",
        f"- Candidate sources: {counts['candidateSources']}",
        f"- Review packets: {counts['reviewPackets']}",
        f"- Blocked promotions: {counts['blockedPromotions']}",
        f"- Active source lanes emitted: {counts['activeSourceLanes']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- Catalog candidates remain source-of-sources metadata only.",
        "- No active source lanes, claims, packs, R2 objects, final plans, schedules, or Steps are emitted.",
        "- Human source-lane and legal/terms review remains required before a candidate can affect claims or packs.",
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


def _candidate_records(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("candidateSourceRecords"), list):
        return [item for item in payload["candidateSourceRecords"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("candidate_sources"), list):
        return [item for item in payload["candidate_sources"] if isinstance(item, dict)]
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _input_schema_issues(payload: Any, candidates: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("candidate review input must be an object or array")
    if not candidates:
        issues.append("candidate review input must include candidate source records")
    return issues


def _candidate_issues(candidate: dict[str, Any], index: int) -> list[str]:
    label = str(candidate.get("candidate_id") or f"candidate[{index}]")
    issues: list[str] = []
    if not candidate.get("candidate_id"):
        issues.append(f"{label}: candidate_id required")
    if candidate.get("review_required") is not True:
        issues.append(f"{label}: catalog candidate must remain review_required")
    if candidate.get("claim_authority_allowed") is not False:
        issues.append(f"{label}: catalog candidate cannot allow claim authority")
    if candidate.get("pack_output_allowed") is not False:
        issues.append(f"{label}: catalog candidate cannot allow pack output")
    if candidate.get("source_class_guess") != "public_catalog":
        issues.append(f"{label}: source_class_guess must remain public_catalog")
    blocking_reasons = set(candidate.get("blocking_reasons") or [])
    for required_reason in {
        "catalog_metadata_not_claim_authority",
        "source_lane_review_required",
        "legal_terms_review_required",
        "pack_output_blocked_until_review",
        "candidate_score_cannot_override_review",
    }:
        if required_reason not in blocking_reasons:
            issues.append(f"{label}: missing blocking reason {required_reason}")
    return issues


def _review_packet(candidate: dict[str, Any], created_at: str, candidate_issues: list[str]) -> dict[str, Any]:
    blocking_reasons = sorted(
        {
            "review_required",
            "catalog_metadata_not_claim_authority",
            "source_lane_review_required",
            "legal_terms_review_required",
            "api_policy_review_required",
            "authority_review_required",
            "pack_output_blocked_until_review",
            "candidate_score_cannot_override_review",
            *[str(reason) for reason in candidate.get("blocking_reasons", [])],
        }
    )
    redistribution_guess = str(candidate.get("redistribution_guess") or "unclear")
    r2_pack_policy = "pack_blocked_restricted" if redistribution_guess in {"restricted", "blocked"} else "pack_blocked_unknown_terms"
    domain_guess = str(candidate.get("domain_guess") or "unclassified_public_reference")
    candidate_id = str(candidate.get("candidate_id") or stable_id("catalog_candidate_missing_id", candidate))
    return {
        "schema_version": "1.0.0",
        "packet_id": stable_id("catalog_candidate_review_packet", {"candidate_id": candidate_id, "candidate_hash": stable_hash(candidate)}),
        "candidate_id": candidate_id,
        "created_at": created_at,
        "status": "review_required",
        "domain_guess": domain_guess,
        "publisher_name": str(candidate.get("publisher_name") or ""),
        "publisher_url": str(candidate.get("publisher_url") or ""),
        "dataset_url": str(candidate.get("dataset_url") or ""),
        "distribution_urls": sorted(str(url) for url in candidate.get("distribution_urls", []) if isinstance(url, str)),
        "api_docs_url": str(candidate.get("api_docs_url") or ""),
        "declared_license": str(candidate.get("declared_license") or ""),
        "declared_rights": str(candidate.get("declared_rights") or ""),
        "terms_url": str(candidate.get("terms_url") or ""),
        "rights_url": str(candidate.get("rights_url") or ""),
        "declared_jurisdiction": str(candidate.get("declared_jurisdiction") or "unknown"),
        "authority_class_guess": str(candidate.get("authority_class_guess") or "unknown"),
        "source_class_guess": str(candidate.get("source_class_guess") or "public_catalog"),
        "claim_class_guess": sorted(str(value) for value in candidate.get("claim_class_guess", []) if isinstance(value, str)),
        "redistribution_guess": redistribution_guess,
        "candidate_score": int(candidate.get("candidate_score") or 0),
        "review_required": True,
        "active_source_lane_emitted": False,
        "claim_authority_allowed": False,
        "pack_output_allowed": False,
        "r2_pack_policy": r2_pack_policy,
        "redistribution_policy": "review_required",
        "allowed_artifact_classes": ["candidate_source_record", "discovery_metadata"],
        "forbidden_artifact_classes": FORBIDDEN_ARTIFACT_CLASSES,
        "legal_review": {
            "required": True,
            "license_posture": "review_required",
            "terms_posture": "review_required",
            "redistribution_approval": "not_approved",
            "outside_legal_status": "not_claimed",
        },
        "api_review": {
            "required": True,
            "api_policy_required_before_live_harvest": True,
            "rate_budget_policy_required": True,
            "secret_policy_required": True,
        },
        "blocking_reasons": blocking_reasons,
        "candidate_issues": sorted(candidate_issues),
        "evidence_hash": str(candidate.get("evidence_hash") or stable_hash(candidate)),
        "non_claims": [
            "review packet only",
            "candidate score is advisory only",
            "catalog metadata is not claim authority",
            "not an active source lane",
            "not legal approval",
            "not pack output",
            *CATALOG_NON_CLAIMS,
        ],
    }


def _blocked_promotion(candidate: dict[str, Any], packet: dict[str, Any], created_at: str) -> dict[str, Any]:
    return {
        "schema_version": "1.0.0",
        "packet_id": packet["packet_id"],
        "candidate_id": packet["candidate_id"],
        "domain_guess": packet["domain_guess"],
        "created_at": created_at,
        "promotion_decision": "blocked_until_review",
        "claim_authority_allowed": False,
        "pack_output_allowed": False,
        "active_source_lane_emitted": False,
        "r2_pack_policy": packet["r2_pack_policy"],
        "blocking_reasons": packet["blocking_reasons"],
        "candidate_score": int(candidate.get("candidate_score") or 0),
        "non_claims": [
            "blocked promotion report only",
            "not source authority",
            "not pack output",
            "not R2 readiness",
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
            if key not in {"forbidden_artifact_classes", "non_claims"}
        )
    return False
