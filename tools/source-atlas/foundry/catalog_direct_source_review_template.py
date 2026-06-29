"""Build direct-source review packet templates for Train 71.

The templates are shaped as directSourceReviewPackets so the Train 71 gate can
consume them, but they are intentionally blocked. A reviewer must replace the
draft sections with completed source-lane, legal/terms, API, and packability
evidence before any packet can become a completion artifact.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .catalog_direct_source_review_gate import CATALOG_DIRECT_SOURCE_REVIEW_GATE_VERSION
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_DIRECT_SOURCE_REVIEW_TEMPLATE_VERSION = "source-atlas-catalog-direct-source-review-template-train-72"
CATALOG_DIRECT_SOURCE_REVIEW_TEMPLATE_KIND = "ambitions.sourceAtlas.catalogDirectSourceReviewTemplate.v1"
DIRECT_SOURCE_REVIEW_PACKET_COLLECTION_KIND = "ambitions.sourceAtlas.catalogDirectSourceReviewPackets.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

DIRECT_SOURCE_REVIEW_TEMPLATE_NON_CLAIMS = [
    "direct-source review packet templates only",
    "not completed direct-source review packets",
    "not source authority",
    "not legal approval",
    "not outside legal approval",
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
class CatalogDirectSourceReviewTemplateOptions:
    resolution_candidates_path: Path
    output_root: Path
    reviewer: str = ""
    created_at: str | None = None


def compile_catalog_direct_source_review_template(options: CatalogDirectSourceReviewTemplateOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload = read_json(options.resolution_candidates_path)
    candidates = _resolution_candidates(payload)
    input_schema_issues = _input_schema_issues(payload, candidates)
    input_privacy_issues = privacy_findings_for_value(payload, "catalog-direct-source-review-template-input")
    templates = [_template_for_candidate(candidate, created_at, reviewer=options.reviewer) for candidate in candidates]
    templates = sorted(templates, key=lambda item: (item["domain_guess"], item["source_name"], item["candidate_id"], item["resolution_id"]))
    collection = {
        "kind": DIRECT_SOURCE_REVIEW_PACKET_COLLECTION_KIND,
        "createdAt": created_at,
        "directSourceReviewPackets": templates,
        "nonClaims": [
            "template collection only",
            "not completed source/legal/API review",
            "not approval",
            "not claim output",
            "not pack output",
        ],
    }
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_DIRECT_SOURCE_REVIEW_TEMPLATE_KIND,
        "versionID": CATALOG_DIRECT_SOURCE_REVIEW_TEMPLATE_VERSION,
        "compatibleGateVersionID": CATALOG_DIRECT_SOURCE_REVIEW_GATE_VERSION,
        "createdAt": created_at,
        "resolutionCandidatesPath": str(options.resolution_candidates_path),
        "reviewer": options.reviewer,
        "directSourceReviewPacketTemplates": templates,
        "completedDirectSourceReviews": [],
        "activeRegistryMutations": [],
        "recordCounts": {
            "resolutionCandidates": len(candidates),
            "directSourceReviewPacketTemplates": len(templates),
            "completedDirectSourceReviews": 0,
            "completedSourceReviewCompletionPackets": 0,
            "activeRegistryMutations": 0,
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DIRECT_SOURCE_REVIEW_TEMPLATE_NON_CLAIMS,
    }
    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-direct-source-review-template")
    collection_privacy_issues = privacy_findings_for_value(collection, "catalog-direct-source-review-template-collection")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    checks = [
        {"name": "input_schema_valid", "passed": not input_schema_issues and bool(candidates), "issues": input_schema_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {
            "name": "templates_are_blocked_not_completed",
            "passed": all(template["completion_status"] == "blocked_review_required" for template in templates),
            "issues": [],
        },
        {
            "name": "templates_are_gate_compatible",
            "passed": all(template.get("resolution_id") and template.get("candidate_id") and template.get("completion_status") for template in templates),
            "issues": [],
        },
        {
            "name": "templates_emit_no_claims",
            "passed": artifact["recordCounts"]["claims"] == 0
            and artifact["recordCounts"]["packableClaims"] == 0
            and artifact["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {"name": "no_active_registry_mutations", "passed": artifact["recordCounts"]["activeRegistryMutations"] == 0, "issues": []},
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues and not collection_privacy_issues, "issues": artifact_privacy_issues + collection_privacy_issues},
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
    ]
    issues: list[str] = []
    issues.extend(input_schema_issues)
    issues.extend(input_privacy_issues)
    issues.extend(artifact_privacy_issues)
    issues.extend(collection_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogDirectSourceReviewTemplateManifest.v1",
        "versionID": CATALOG_DIRECT_SOURCE_REVIEW_TEMPLATE_VERSION,
        "compatibleGateVersionID": CATALOG_DIRECT_SOURCE_REVIEW_GATE_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog direct-source review template tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; direct-source review templates only",
        "resolutionCandidatesPath": str(options.resolution_candidates_path),
        "recordCounts": artifact["recordCounts"],
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogDirectSourceReviewTemplate": str(output_root / "catalog-direct-source-review-template.json"),
            "directSourceReviewPackets": str(output_root / "direct-source-review-packet-templates.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DIRECT_SOURCE_REVIEW_TEMPLATE_NON_CLAIMS,
    }

    write_json(output_root / "catalog-direct-source-review-template.json", artifact)
    write_json(output_root / "direct-source-review-packet-templates.json", collection)
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogDirectSourceReviewTemplate": stable_hash(read_json(output_root / "catalog-direct-source-review-template.json")),
        "directSourceReviewPackets": stable_hash(read_json(output_root / "direct-source-review-packet-templates.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_direct_source_review_template_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_direct_source_review_template_report(
    markdown_path: Path,
    json_path: Path,
    *,
    resolution_candidates_path: Path,
    output_root: Path,
    reviewer: str = "",
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_direct_source_review_template(
        CatalogDirectSourceReviewTemplateOptions(
            resolution_candidates_path=resolution_candidates_path,
            output_root=output_root,
            reviewer=reviewer,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_direct_source_review_template_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_direct_source_review_template_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Direct-Source Review Template Train 72",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic blocked direct-source review packet templates for Train 71.",
        "- Templates preserve candidate locators and required review evidence without approving sources.",
        "- Output is shaped for the direct-source review gate and remains blocked_review_required.",
        "",
        "Counts:",
        f"- Resolution candidates: {counts['resolutionCandidates']}",
        f"- Direct-source review packet templates: {counts['directSourceReviewPacketTemplates']}",
        f"- Completed direct-source reviews: {counts['completedDirectSourceReviews']}",
        f"- Completed source-review completion packets: {counts['completedSourceReviewCompletionPackets']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- No claims, packs, active registry writes, R2 objects, final plans, schedules, or Steps are emitted.",
        "- Templates cannot become source/legal/API approval until a reviewer completes every required section.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed by these templates.",
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


def _input_schema_issues(payload: Any, candidates: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog direct-source review template input must be an object or array")
    if not candidates:
        issues.append("catalog direct-source review template input must include resolution candidates")
    for index, candidate in enumerate(candidates):
        for field in ("resolution_id", "candidate_id", "proposal_id", "intake_id", "source_id", "domain_guess"):
            if not candidate.get(field):
                issues.append(f"resolutionCandidates[{index}].{field} required")
    return issues


def _template_for_candidate(candidate: dict[str, Any], created_at: str, *, reviewer: str) -> dict[str, Any]:
    missing_classes = sorted(str(item) for item in candidate.get("missing_locator_classes", []) if isinstance(item, str))
    blocking_reasons = sorted(
        set(
            [
                "direct_source_review_required",
                "source_lane_review_required",
                "legal_terms_review_required",
                "api_governance_review_required",
                "packability_decision_required",
                *[f"{item}_missing" for item in missing_classes],
            ]
        )
    )
    return {
        "schema_version": "1.0.0",
        "direct_source_review_packet_id": stable_id(
            "catalog_direct_source_review_template",
            {"resolution_id": candidate.get("resolution_id"), "candidate_id": candidate.get("candidate_id")},
        ),
        "resolution_id": str(candidate.get("resolution_id") or ""),
        "candidate_id": str(candidate.get("candidate_id") or ""),
        "proposal_id": str(candidate.get("proposal_id") or ""),
        "intake_id": str(candidate.get("intake_id") or ""),
        "source_id": str(candidate.get("source_id") or ""),
        "source_name": str(candidate.get("source_name") or ""),
        "domain_guess": str(candidate.get("domain_guess") or "unclassified_public_reference"),
        "completion_status": "blocked_review_required",
        "review_owner": reviewer,
        "reviewed_at": "",
        "created_at": created_at,
        "candidate_locators": candidate.get("candidate_locators", []),
        "missing_locator_classes": missing_classes,
        "required_evidence": candidate.get("required_evidence", []),
        "draft_source_lane_entry": _draft_source_lane_entry(candidate),
        "draft_legal_terms_entry": _draft_legal_terms_entry(candidate),
        "draft_api_policy_entry": _draft_api_policy_entry(candidate),
        "completion_checklist": _completion_checklist(missing_classes),
        "reviewer_only_fields": [
            "review_owner",
            "reviewed_at",
            "source_lane_entry",
            "legal_terms_entry",
            "api_policy_entry",
            "outside_legal_status",
            "outside_legal_approval_artifact",
        ],
        "blocking_reasons": blocking_reasons,
        "non_claims": [
            "direct-source review packet template only",
            "not completed review",
            "not approval",
            "not claim output",
            "not pack output",
        ],
    }


def _draft_source_lane_entry(candidate: dict[str, Any]) -> dict[str, Any]:
    return {
        "source_id": "",
        "source_name": str(candidate.get("source_name") or ""),
        "source_class": "",
        "authority_class": "",
        "jurisdiction": "",
        "domain_scope": [str(candidate.get("domain_guess") or "unclassified_public_reference")],
        "claim_classes_allowed": [],
        "claim_classes_forbidden": ["legal_advice", "medical_advice", "financial_advice"],
        "license_id": "",
        "license_url": "",
        "terms_url": "",
        "rights_url": "",
        "attribution_required": None,
        "redistribution_policy": "review_required",
        "r2_pack_policy": "pack_blocked_unknown_terms",
        "lookup_policy": "review_required",
        "crosswalk_policy": "review_required",
        "review_status": "review_required",
        "review_required": True,
        "allowed_artifact_classes": [],
        "forbidden_artifact_classes": ["private_goal_graph", "final_user_path", "final_schedule", "step_list", "personalized_plan"],
        "non_claims": ["draft source lane only", "not authority", "not approval"],
        "schema_version": "1.0.0",
    }


def _draft_legal_terms_entry(candidate: dict[str, Any]) -> dict[str, Any]:
    terms_url = _first_locator_url(candidate, {"source_terms_url", "draft_legal_terms_url"})
    rights_url = _first_locator_url(candidate, {"source_rights_url", "draft_legal_rights_url"})
    license_url = _first_locator_url(candidate, {"draft_license_url"})
    return {
        "license_id": "",
        "license_name": "",
        "license_url": license_url,
        "terms_url": terms_url,
        "rights_url": rights_url,
        "redistribution_allowed": False,
        "pack_output_allowed": False,
        "attribution_required": None,
        "review_required": True,
        "outside_legal_required": True,
        "outside_legal_status": "not_claimed",
        "approval_artifact_path": "",
        "reviewed_at": "",
        "review_owner": "",
        "non_claims": ["draft legal terms only", "not legal approval", "not outside legal approval"],
        "schema_version": "1.0.0",
    }


def _draft_api_policy_entry(candidate: dict[str, Any]) -> dict[str, Any]:
    return {
        "api_policy_id": "",
        "source_id": "",
        "api_mode": "review_required_before_live_harvest",
        "key_required": None,
        "env_var_name": "",
        "missing_key_behavior": "",
        "rate_limit_per_second": None,
        "rate_limit_per_minute": None,
        "daily_budget_limit": None,
        "monthly_budget_limit": None,
        "max_records_per_run": None,
        "max_pages_per_run": None,
        "timeout_seconds": None,
        "retry_policy": "",
        "backoff_policy": "",
        "circuit_breaker_policy": "",
        "live_flag_required": True,
        "execute_flag_required": True,
        "secret_redaction_required": True,
        "high_volume_review_required": None,
        "budget_owner": "",
        "evidence_output_policy": "metadata_only_no_response_body_logs",
        "candidate_api_docs_url": _first_locator_url(candidate, {"api_docs_url"}),
        "schema_version": "1.0.0",
    }


def _first_locator_url(candidate: dict[str, Any], classes: set[str]) -> str:
    for locator in candidate.get("candidate_locators", []):
        if isinstance(locator, dict) and locator.get("locator_class") in classes and locator.get("url"):
            return str(locator["url"])
    return ""


def _completion_checklist(missing_classes: list[str]) -> list[dict[str, Any]]:
    return [
        {
            "section": "direct_source",
            "status": "blocked",
            "required_action": "confirm direct publisher/source authority from source-controlled evidence",
            "missing_locator_classes": missing_classes,
        },
        {
            "section": "source_lane",
            "status": "blocked",
            "required_action": "replace draft_source_lane_entry with completed source_lane_entry only after source authority, jurisdiction, freshness, artifact classes, and non-claims are reviewed",
        },
        {
            "section": "legal_terms",
            "status": "blocked",
            "required_action": "replace draft_legal_terms_entry with completed legal_terms_entry only after source-specific redistribution, attribution, pack-output, and outside-legal artifact posture are reviewed",
        },
        {
            "section": "api_governance",
            "status": "blocked",
            "required_action": "replace draft_api_policy_entry with completed api_policy_entry before live harvest; live and execute flags plus secret redaction must stay required",
        },
        {
            "section": "packability",
            "status": "blocked",
            "required_action": "keep pack output blocked unless legal/terms and packability posture are explicitly approved",
        },
    ]


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
