"""Assemble completed direct-source review packets from reviewer evidence.

Train 72 emits blocked direct-source review templates. This train consumes
those templates plus optional source-specific reviewer evidence and emits
Train 71-shaped direct-source review packets. Missing evidence remains blocked;
completed evidence is still handed to Train 71 for the final source/legal/API
gate.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_direct_source_review_gate import (
    API_REQUIRED_FIELDS,
    CATALOG_DIRECT_SOURCE_REVIEW_GATE_VERSION,
    LEGAL_REQUIRED_FIELDS,
    SOURCE_LANE_REQUIRED_FIELDS,
)
from .catalog_direct_source_review_template import CATALOG_DIRECT_SOURCE_REVIEW_TEMPLATE_VERSION, DIRECT_SOURCE_REVIEW_PACKET_COLLECTION_KIND
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_DIRECT_SOURCE_REVIEW_COMPLETION_VERSION = "source-atlas-catalog-direct-source-review-completion-train-73"
CATALOG_DIRECT_SOURCE_REVIEW_COMPLETION_KIND = "ambitions.sourceAtlas.catalogDirectSourceReviewCompletion.v1"
DIRECT_SOURCE_REVIEW_EVIDENCE_KIND = "ambitions.sourceAtlas.catalogDirectSourceReviewEvidence.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

DIRECT_SOURCE_REVIEW_COMPLETION_NON_CLAIMS = [
    "direct-source review completion assembler only",
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


@dataclass(frozen=True)
class CatalogDirectSourceReviewCompletionOptions:
    templates_path: Path
    output_root: Path
    review_evidence_path: Path | None = None
    created_at: str | None = None


def compile_catalog_direct_source_review_completion(options: CatalogDirectSourceReviewCompletionOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    template_payload = read_json(options.templates_path)
    templates = _template_packets(template_payload)
    template_schema_issues = _template_schema_issues(template_payload, templates)
    template_privacy_issues = privacy_findings_for_value(template_payload, "catalog-direct-source-review-completion-templates")

    evidence_payload = read_json(options.review_evidence_path) if options.review_evidence_path else None
    evidence_records = _review_evidence_records(evidence_payload)
    evidence_schema_issues = _evidence_schema_issues(evidence_payload, evidence_records, provided=options.review_evidence_path is not None)
    evidence_privacy_issues = (
        privacy_findings_for_value(evidence_payload, "catalog-direct-source-review-completion-evidence")
        if evidence_payload is not None
        else []
    )

    assembly = _assemble_direct_source_review_packets(templates, evidence_records, created_at)
    direct_source_review_packets = assembly["directSourceReviewPackets"]
    blocked_reviews = assembly["blockedDirectSourceReviewCompletions"]
    record_counts = {
        "directSourceReviewTemplates": len(templates),
        "reviewEvidenceRecords": len(evidence_records),
        "directSourceReviewPackets": len(direct_source_review_packets),
        "completedDirectSourceReviews": sum(1 for item in direct_source_review_packets if item["completion_status"] == "completed"),
        "blockedDirectSourceReviews": sum(1 for item in direct_source_review_packets if item["completion_status"] != "completed"),
        "blockedDirectSourceReviewCompletions": len(blocked_reviews),
        "activeRegistryMutations": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
    }
    collection = {
        "kind": DIRECT_SOURCE_REVIEW_PACKET_COLLECTION_KIND,
        "createdAt": created_at,
        "directSourceReviewPackets": direct_source_review_packets,
        "nonClaims": [
            "direct-source review packets for Train 71 gate only",
            "not source authority by themselves",
            "not legal approval",
            "not claim output",
            "not pack output",
        ],
    }
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_DIRECT_SOURCE_REVIEW_COMPLETION_KIND,
        "versionID": CATALOG_DIRECT_SOURCE_REVIEW_COMPLETION_VERSION,
        "compatibleTemplateVersionID": CATALOG_DIRECT_SOURCE_REVIEW_TEMPLATE_VERSION,
        "compatibleGateVersionID": CATALOG_DIRECT_SOURCE_REVIEW_GATE_VERSION,
        "createdAt": created_at,
        "templatesPath": str(options.templates_path),
        "reviewEvidencePath": str(options.review_evidence_path) if options.review_evidence_path else "",
        "directSourceReviewPacketCollection": collection,
        "blockedDirectSourceReviewCompletions": blocked_reviews,
        "activeRegistryMutations": [],
        "recordCounts": record_counts,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DIRECT_SOURCE_REVIEW_COMPLETION_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-direct-source-review-completion")
    collection_privacy_issues = privacy_findings_for_value(collection, "catalog-direct-source-review-completion-packets")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    checks = [
        {"name": "template_schema_valid", "passed": not template_schema_issues and bool(templates), "issues": template_schema_issues},
        {"name": "template_privacy_scan_passed", "passed": not template_privacy_issues, "issues": template_privacy_issues},
        {"name": "review_evidence_schema_valid", "passed": not evidence_schema_issues, "issues": evidence_schema_issues},
        {"name": "review_evidence_privacy_scan_passed", "passed": not evidence_privacy_issues, "issues": evidence_privacy_issues},
        {
            "name": "missing_evidence_blocks_without_completion",
            "passed": options.review_evidence_path is not None or record_counts["completedDirectSourceReviews"] == 0,
            "issues": [],
        },
        {
            "name": "completed_packets_require_direct_source_not_catalog",
            "passed": all(
                packet["completion_status"] != "completed"
                or not packet["source_lane_entry"]["source_id"].startswith("catalog.candidate.")
                for packet in direct_source_review_packets
            ),
            "issues": [],
        },
        {
            "name": "completion_assembler_emits_no_claims",
            "passed": record_counts["claims"] == 0 and record_counts["packableClaims"] == 0 and record_counts["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {"name": "no_active_registry_mutations", "passed": record_counts["activeRegistryMutations"] == 0, "issues": []},
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues and not collection_privacy_issues, "issues": artifact_privacy_issues + collection_privacy_issues},
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
    ]

    issues: list[str] = []
    issues.extend(template_schema_issues)
    issues.extend(template_privacy_issues)
    issues.extend(evidence_schema_issues)
    issues.extend(evidence_privacy_issues)
    issues.extend(assembly["issues"])
    issues.extend(artifact_privacy_issues)
    issues.extend(collection_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogDirectSourceReviewCompletionManifest.v1",
        "versionID": CATALOG_DIRECT_SOURCE_REVIEW_COMPLETION_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog direct-source review completion assembler tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; direct-source review completion assembler tooling only",
        "templatesPath": str(options.templates_path),
        "reviewEvidencePath": str(options.review_evidence_path) if options.review_evidence_path else "",
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogDirectSourceReviewCompletion": str(output_root / "catalog-direct-source-review-completion.json"),
            "directSourceReviewPackets": str(output_root / "direct-source-review-packets.json"),
            "blockedDirectSourceReviewCompletions": str(output_root / "blocked-direct-source-review-completions.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DIRECT_SOURCE_REVIEW_COMPLETION_NON_CLAIMS,
    }

    write_json(output_root / "catalog-direct-source-review-completion.json", artifact)
    write_json(output_root / "direct-source-review-packets.json", collection)
    write_json(
        output_root / "blocked-direct-source-review-completions.json",
        {
            "kind": "ambitions.sourceAtlas.catalogBlockedDirectSourceReviewCompletions.v1",
            "createdAt": created_at,
            "blockedDirectSourceReviewCompletions": blocked_reviews,
        },
    )
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogDirectSourceReviewCompletion": stable_hash(read_json(output_root / "catalog-direct-source-review-completion.json")),
        "directSourceReviewPackets": stable_hash(read_json(output_root / "direct-source-review-packets.json")),
        "blockedDirectSourceReviewCompletions": stable_hash(read_json(output_root / "blocked-direct-source-review-completions.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_direct_source_review_completion_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_direct_source_review_completion_report(
    markdown_path: Path,
    json_path: Path,
    *,
    templates_path: Path,
    output_root: Path,
    review_evidence_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_direct_source_review_completion(
        CatalogDirectSourceReviewCompletionOptions(
            templates_path=templates_path,
            output_root=output_root,
            review_evidence_path=review_evidence_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_direct_source_review_completion_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_direct_source_review_completion_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Direct-Source Review Completion Train 73",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        f"Review evidence path: {result['reviewEvidencePath'] or 'not provided'}",
        "",
        "Scope completed:",
        "- Deterministic assembler from Train 72 direct-source review templates to Train 71 direct-source review packets.",
        "- Missing source-specific reviewer evidence emits blocked packets, not approvals.",
        "- Completed packets require source-lane, legal/terms, API, packability, live/execute, and non-private evidence before completion.",
        "",
        "Counts:",
        f"- Direct-source review templates: {counts['directSourceReviewTemplates']}",
        f"- Review evidence records: {counts['reviewEvidenceRecords']}",
        f"- Direct-source review packets: {counts['directSourceReviewPackets']}",
        f"- Completed direct-source reviews: {counts['completedDirectSourceReviews']}",
        f"- Blocked direct-source reviews: {counts['blockedDirectSourceReviews']}",
        f"- Blocked direct-source review completions: {counts['blockedDirectSourceReviewCompletions']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- No claims, packs, active registry writes, R2 objects, final plans, schedules, or Steps are emitted.",
        "- The output is a governance handoff to Train 71, not source authority or legal approval by itself.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed by this assembler.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _template_packets(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("directSourceReviewPackets"), list):
        return [item for item in payload["directSourceReviewPackets"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("directSourceReviewPacketTemplates"), list):
        return [item for item in payload["directSourceReviewPacketTemplates"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("catalogDirectSourceReviewTemplate"), dict):
        return _template_packets(payload["catalogDirectSourceReviewTemplate"])
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _review_evidence_records(payload: Any) -> list[dict[str, Any]]:
    if payload is None:
        return []
    if isinstance(payload, dict) and isinstance(payload.get("directSourceReviewEvidence"), list):
        return [item for item in payload["directSourceReviewEvidence"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("reviewEvidenceRecords"), list):
        return [item for item in payload["reviewEvidenceRecords"] if isinstance(item, dict)]
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _template_schema_issues(payload: Any, templates: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog direct-source review completion templates input must be an object or array")
    if not templates:
        issues.append("catalog direct-source review completion requires direct-source review templates")
    for index, template in enumerate(templates):
        for field in ("resolution_id", "candidate_id", "completion_status"):
            if not template.get(field):
                issues.append(f"directSourceReviewTemplates[{index}].{field} required")
    return issues


def _evidence_schema_issues(payload: Any, records: list[dict[str, Any]], *, provided: bool) -> list[str]:
    if not provided:
        return []
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog direct-source review evidence input must be an object or array")
    if not records:
        issues.append("catalog direct-source review evidence input must include directSourceReviewEvidence")
    for index, record in enumerate(records):
        for field in ("resolution_id", "candidate_id", "completion_status"):
            if not record.get(field):
                issues.append(f"directSourceReviewEvidence[{index}].{field} required")
    return issues


def _assemble_direct_source_review_packets(
    templates: list[dict[str, Any]],
    evidence_records: list[dict[str, Any]],
    created_at: str,
) -> dict[str, Any]:
    issues: list[str] = []
    evidence_by_resolution: dict[str, dict[str, Any]] = {}
    duplicates: set[str] = set()
    for evidence in evidence_records:
        resolution_id = str(evidence.get("resolution_id") or "")
        if resolution_id in evidence_by_resolution:
            duplicates.add(resolution_id)
        if resolution_id:
            evidence_by_resolution[resolution_id] = evidence
    for resolution_id in sorted(duplicates):
        issues.append(f"{resolution_id}: duplicate direct-source review evidence")

    packets: list[dict[str, Any]] = []
    blocked: list[dict[str, Any]] = []
    template_candidate_ids = {str(template.get("candidate_id") or "") for template in templates}
    for template in sorted(templates, key=lambda item: (item.get("domain_guess", ""), item.get("source_name", ""), item.get("candidate_id", ""), item.get("resolution_id", ""))):
        evidence = evidence_by_resolution.get(str(template.get("resolution_id") or ""))
        if not evidence:
            reasons = ["review_evidence_required", *[f"{item}_missing" for item in template.get("missing_locator_classes", [])]]
            packet = _blocked_direct_source_review_packet(template, created_at, reasons)
            packets.append(packet)
            blocked.append(_blocked_completion(template, created_at, reasons))
            continue
        if evidence.get("candidate_id") != template.get("candidate_id"):
            issue = f"{template.get('resolution_id')}: review evidence candidate_id must match template"
            issues.append(issue)
            reasons = ["review_evidence_candidate_mismatch", issue]
            packet = _blocked_direct_source_review_packet(template, created_at, reasons)
            packets.append(packet)
            blocked.append(_blocked_completion(template, created_at, reasons))
            continue
        if evidence.get("completion_status") != "completed":
            reasons = [f"review_evidence_status_{evidence.get('completion_status') or 'missing'}"]
            packet = _blocked_direct_source_review_packet(template, created_at, reasons)
            packets.append(packet)
            blocked.append(_blocked_completion(template, created_at, reasons))
            continue
        evidence_issues = _completed_evidence_issues(evidence)
        if evidence_issues:
            issues.extend(evidence_issues)
            reasons = ["completed_review_evidence_invalid", *evidence_issues]
            packet = _blocked_direct_source_review_packet(template, created_at, reasons)
            packets.append(packet)
            blocked.append(_blocked_completion(template, created_at, reasons))
            continue
        packets.append(_completed_direct_source_review_packet(template, evidence, created_at))

    for resolution_id, evidence in sorted(evidence_by_resolution.items()):
        if str(evidence.get("candidate_id") or "") not in template_candidate_ids:
            issues.append(f"{resolution_id}: direct-source review evidence does not match a template")

    return {
        "directSourceReviewPackets": sorted(packets, key=lambda item: (item.get("candidate_id", ""), item.get("resolution_id", ""))),
        "blockedDirectSourceReviewCompletions": sorted(blocked, key=lambda item: (item.get("candidate_id", ""), item.get("resolution_id", ""))),
        "issues": sorted(set(issues)),
    }


def _completed_direct_source_review_packet(template: dict[str, Any], evidence: dict[str, Any], created_at: str) -> dict[str, Any]:
    legal_entry = evidence["legal_terms_entry"]
    outside_legal_status = str(evidence.get("outside_legal_status") or legal_entry.get("outside_legal_status") or "not_claimed")
    outside_legal_artifact = str(evidence.get("outside_legal_approval_artifact") or legal_entry.get("approval_artifact_path") or "")
    return {
        "schema_version": "1.0.0",
        "direct_source_review_packet_id": str(
            evidence.get("direct_source_review_packet_id")
            or stable_id("catalog_direct_source_review", {"resolution_id": template.get("resolution_id"), "created_at": created_at})
        ),
        "resolution_id": str(template.get("resolution_id") or ""),
        "candidate_id": str(template.get("candidate_id") or ""),
        "completion_status": "completed",
        "review_owner": str(evidence.get("review_owner") or ""),
        "reviewed_at": str(evidence.get("reviewed_at") or ""),
        "outside_legal_status": outside_legal_status,
        "outside_legal_approval_artifact": outside_legal_artifact,
        "source_lane_entry": evidence["source_lane_entry"],
        "legal_terms_entry": legal_entry,
        "api_policy_entry": evidence["api_policy_entry"],
        "review_artifacts": evidence.get("review_artifacts", []),
        "created_at": created_at,
        "non_claims": [
            "direct-source review packet only",
            "not source authority by itself",
            "not legal approval by itself",
            "not claim output",
            "not pack output by itself",
        ],
    }


def _blocked_direct_source_review_packet(template: dict[str, Any], created_at: str, reasons: list[str]) -> dict[str, Any]:
    return {
        "schema_version": "1.0.0",
        "direct_source_review_packet_id": stable_id("catalog_direct_source_review_blocked", {"resolution_id": template.get("resolution_id"), "reasons": sorted(reasons)}),
        "resolution_id": str(template.get("resolution_id") or ""),
        "candidate_id": str(template.get("candidate_id") or ""),
        "completion_status": "blocked_review_evidence_required",
        "review_owner": "",
        "reviewed_at": "",
        "outside_legal_status": "not_claimed",
        "outside_legal_approval_artifact": "",
        "blocking_reasons": sorted(set(reasons)),
        "created_at": created_at,
        "non_claims": ["blocked direct-source review packet only", "not approval", "not claim output", "not pack output"],
    }


def _blocked_completion(template: dict[str, Any], created_at: str, reasons: list[str]) -> dict[str, Any]:
    return {
        "schema_version": "1.0.0",
        "blocked_direct_source_review_completion_id": stable_id(
            "catalog_direct_source_review_completion_block",
            {"resolution_id": template.get("resolution_id"), "reasons": sorted(reasons)},
        ),
        "created_at": created_at,
        "status": "blocked",
        "resolution_id": str(template.get("resolution_id") or ""),
        "candidate_id": str(template.get("candidate_id") or ""),
        "source_id": str(template.get("source_id") or ""),
        "source_name": str(template.get("source_name") or ""),
        "domain_guess": str(template.get("domain_guess") or ""),
        "blocking_reasons": sorted(set(reasons)),
        "non_claims": ["blocked direct-source review completion only", "not approval", "not claim output", "not pack output"],
    }


def _completed_evidence_issues(evidence: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    resolution_id = evidence.get("resolution_id")
    for field in ("review_owner", "reviewed_at"):
        if _missing(evidence.get(field)):
            issues.append(f"{resolution_id}: {field} required")
    source_lane = evidence.get("source_lane_entry") if isinstance(evidence.get("source_lane_entry"), dict) else {}
    legal_terms = evidence.get("legal_terms_entry") if isinstance(evidence.get("legal_terms_entry"), dict) else {}
    api_policy = evidence.get("api_policy_entry") if isinstance(evidence.get("api_policy_entry"), dict) else {}
    issues.extend(_required_field_issues(source_lane, SOURCE_LANE_REQUIRED_FIELDS, f"{resolution_id}: source_lane_entry"))
    issues.extend(_required_field_issues(legal_terms, LEGAL_REQUIRED_FIELDS, f"{resolution_id}: legal_terms_entry"))
    issues.extend(_required_field_issues(api_policy, API_REQUIRED_FIELDS, f"{resolution_id}: api_policy_entry"))
    if str(source_lane.get("source_id") or "").startswith("catalog.candidate."):
        issues.append(f"{resolution_id}: completed source_lane_entry.source_id must not remain catalog.candidate")
    if source_lane.get("source_class") == "public_catalog":
        issues.append(f"{resolution_id}: completed source_lane_entry.source_class must not be public_catalog")
    if source_lane.get("authority_class") in {"public_catalog", "open_knowledge_graph", "unknown", ""}:
        issues.append(f"{resolution_id}: completed source_lane_entry.authority_class is not sufficient for authority review")
    if source_lane.get("review_status") != "reviewed" or source_lane.get("review_required") is not False:
        issues.append(f"{resolution_id}: source lane review_status/review_required must be reviewed/false")
    if source_lane.get("r2_pack_policy") in {"pack_allowed", "pack_allowed_with_attribution"} and legal_terms.get("pack_output_allowed") is not True:
        issues.append(f"{resolution_id}: pack-allowed source lane requires legal_terms_entry.pack_output_allowed true")
    if source_lane.get("r2_pack_policy") in {"pack_allowed", "pack_allowed_with_attribution"} and not source_lane.get("r2_object_key_prefix"):
        issues.append(f"{resolution_id}: pack-allowed source lane requires r2_object_key_prefix")
    if legal_terms.get("outside_legal_status") == "approved" and not legal_terms.get("approval_artifact_path"):
        issues.append(f"{resolution_id}: outside legal approval requires approval_artifact_path")
    if legal_terms.get("outside_legal_required") is True and not legal_terms.get("approval_artifact_path"):
        issues.append(f"{resolution_id}: outside legal required source requires approval_artifact_path")
    if api_policy.get("secret_redaction_required") is not True:
        issues.append(f"{resolution_id}: api_policy_entry.secret_redaction_required must be true")
    if api_policy.get("live_flag_required") is not True or api_policy.get("execute_flag_required") is not True:
        issues.append(f"{resolution_id}: api policy must require live and execute flags")
    issues.extend(privacy_findings_for_value(evidence, f"directSourceReviewEvidence[{resolution_id}]"))
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
            if key
            not in {
                "forbidden_artifact_classes",
                "claim_classes_forbidden",
                "non_claims",
                "blocking_reasons",
                "required_reviewer_actions",
                "completion_checklist",
            }
        )
    return False
