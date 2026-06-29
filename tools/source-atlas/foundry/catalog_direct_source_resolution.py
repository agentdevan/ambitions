"""Resolve catalog review work into direct-source review candidates.

Catalog work queues explain what review is needed. This compiler takes those
blocked work items plus optional upstream candidate/decision metadata and emits
deterministic direct-source resolution candidates. The output is still review
work only: locators are evidence candidates, not authority, approval, claims,
packs, or R2-ready artifacts.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CATALOG_DIRECT_SOURCE_RESOLUTION_VERSION = "source-atlas-catalog-direct-source-resolution-train-70"
CATALOG_DIRECT_SOURCE_RESOLUTION_KIND = "ambitions.sourceAtlas.catalogDirectSourceResolution.v1"
FORBIDDEN_OUTPUT_MARKERS = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_graph"}

DIRECT_SOURCE_RESOLUTION_NON_CLAIMS = [
    "direct-source resolution candidates only",
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
class CatalogDirectSourceResolutionOptions:
    work_items_path: Path
    output_root: Path
    candidate_review_path: Path | None = None
    decision_inputs_path: Path | None = None
    created_at: str | None = None


def compile_catalog_direct_source_resolution(options: CatalogDirectSourceResolutionOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    work_payload = read_json(options.work_items_path)
    work_items = _review_work_items(work_payload)
    work_schema_issues = _work_schema_issues(work_payload, work_items)
    work_privacy_issues = privacy_findings_for_value(work_payload, "catalog-direct-source-resolution-work-items")

    candidate_payload = read_json(options.candidate_review_path) if options.candidate_review_path else None
    candidate_packets = _candidate_review_packets(candidate_payload)
    candidate_schema_issues = _optional_packet_schema_issues(
        candidate_payload,
        candidate_packets,
        provided=options.candidate_review_path is not None,
        label="catalog direct-source candidate review input",
        required_field="candidate_id",
    )
    candidate_privacy_issues = (
        privacy_findings_for_value(candidate_payload, "catalog-direct-source-resolution-candidate-review")
        if candidate_payload is not None
        else []
    )

    decision_payload = read_json(options.decision_inputs_path) if options.decision_inputs_path else None
    decision_packets = _decision_input_packets(decision_payload)
    decision_schema_issues = _optional_packet_schema_issues(
        decision_payload,
        decision_packets,
        provided=options.decision_inputs_path is not None,
        label="catalog direct-source decision input",
        required_field="decision_input_id",
    )
    decision_privacy_issues = (
        privacy_findings_for_value(decision_payload, "catalog-direct-source-resolution-decision-inputs")
        if decision_payload is not None
        else []
    )

    candidates_by_id = {str(packet.get("candidate_id") or ""): packet for packet in candidate_packets}
    decisions_by_candidate = {str(packet.get("candidate_id") or ""): packet for packet in decision_packets}
    resolution_candidates = [
        _resolution_candidate(
            work_item,
            candidates_by_id.get(str(work_item.get("candidate_id") or "")),
            decisions_by_candidate.get(str(work_item.get("candidate_id") or "")),
            created_at,
        )
        for work_item in work_items
    ]
    resolution_candidates = sorted(
        resolution_candidates,
        key=lambda item: (item["domain_guess"], item["source_name"], item["candidate_id"], item["work_item_id"]),
    )

    record_counts = {
        "reviewWorkItems": len(work_items),
        "candidateReviewPackets": len(candidate_packets),
        "decisionInputPackets": len(decision_packets),
        "directSourceResolutionCandidates": len(resolution_candidates),
        "candidatesWithLocatorCandidates": sum(1 for item in resolution_candidates if item["locatorSummary"]["locatorCandidateCount"] > 0),
        "blockedFromAuthorityResolution": sum(1 for item in resolution_candidates if item["status"] == "blocked_direct_source_review_required"),
        "missingDirectSourceLocator": sum(1 for item in resolution_candidates if "direct_source_locator_url" in item["missing_locator_classes"]),
        "activeRegistryMutations": 0,
        "claims": 0,
        "packableClaims": 0,
        "r2PackableArtifacts": 0,
    }
    artifact = {
        "schemaVersion": 1,
        "kind": CATALOG_DIRECT_SOURCE_RESOLUTION_KIND,
        "versionID": CATALOG_DIRECT_SOURCE_RESOLUTION_VERSION,
        "createdAt": created_at,
        "workItemsPath": str(options.work_items_path),
        "candidateReviewPath": str(options.candidate_review_path) if options.candidate_review_path else "",
        "decisionInputsPath": str(options.decision_inputs_path) if options.decision_inputs_path else "",
        "resolutionCandidates": resolution_candidates,
        "activeRegistryMutations": [],
        "recordCounts": record_counts,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DIRECT_SOURCE_RESOLUTION_NON_CLAIMS,
    }

    artifact_privacy_issues = privacy_findings_for_value(artifact, "catalog-direct-source-resolution")
    forbidden_output_issues = ["forbidden final-output marker found"] if _contains_forbidden_output_marker(artifact) else []
    checks = [
        {"name": "work_items_schema_valid", "passed": not work_schema_issues and bool(work_items), "issues": work_schema_issues},
        {"name": "work_items_privacy_scan_passed", "passed": not work_privacy_issues, "issues": work_privacy_issues},
        {"name": "candidate_review_schema_valid", "passed": not candidate_schema_issues, "issues": candidate_schema_issues},
        {"name": "candidate_review_privacy_scan_passed", "passed": not candidate_privacy_issues, "issues": candidate_privacy_issues},
        {"name": "decision_inputs_schema_valid", "passed": not decision_schema_issues, "issues": decision_schema_issues},
        {"name": "decision_inputs_privacy_scan_passed", "passed": not decision_privacy_issues, "issues": decision_privacy_issues},
        {
            "name": "all_resolution_candidates_remain_blocked",
            "passed": all(item["status"] == "blocked_direct_source_review_required" for item in resolution_candidates),
            "issues": [],
        },
        {
            "name": "catalog_metadata_remains_discovery_only",
            "passed": all(item["catalog_source_status"] == "discovery_only_not_authority" for item in resolution_candidates),
            "issues": [],
        },
        {
            "name": "locator_candidates_do_not_approve_authority",
            "passed": all(
                item["direct_source_authority_allowed"] is False
                and all(locator["authority_use_allowed"] is False for locator in item["candidate_locators"])
                for item in resolution_candidates
            ),
            "issues": [],
        },
        {
            "name": "direct_source_resolution_emits_no_claims",
            "passed": record_counts["claims"] == 0 and record_counts["packableClaims"] == 0 and record_counts["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {"name": "no_active_registry_mutations", "passed": record_counts["activeRegistryMutations"] == 0, "issues": []},
        {"name": "privacy_scan_passed", "passed": not artifact_privacy_issues, "issues": artifact_privacy_issues},
        {"name": "no_final_plan_schedule_step_output", "passed": not forbidden_output_issues, "issues": forbidden_output_issues},
    ]

    issues: list[str] = []
    issues.extend(work_schema_issues)
    issues.extend(work_privacy_issues)
    issues.extend(candidate_schema_issues)
    issues.extend(candidate_privacy_issues)
    issues.extend(decision_schema_issues)
    issues.extend(decision_privacy_issues)
    issues.extend(artifact_privacy_issues)
    issues.extend(forbidden_output_issues)
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.catalogDirectSourceResolutionManifest.v1",
        "versionID": CATALOG_DIRECT_SOURCE_RESOLUTION_VERSION,
        "createdAt": created_at,
        "status": "Source Green for catalog direct-source resolution candidate tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; direct-source resolution candidates only",
        "workItemsPath": str(options.work_items_path),
        "candidateReviewPath": str(options.candidate_review_path) if options.candidate_review_path else "",
        "decisionInputsPath": str(options.decision_inputs_path) if options.decision_inputs_path else "",
        "recordCounts": record_counts,
        "checks": checks,
        "issues": sorted(set(issues)),
        "outputPaths": {
            "catalogDirectSourceResolution": str(output_root / "catalog-direct-source-resolution.json"),
            "directSourceResolutionCandidates": str(output_root / "direct-source-resolution-candidates.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DIRECT_SOURCE_RESOLUTION_NON_CLAIMS,
    }

    write_json(output_root / "catalog-direct-source-resolution.json", artifact)
    write_json(
        output_root / "direct-source-resolution-candidates.json",
        {
            "kind": "ambitions.sourceAtlas.catalogDirectSourceResolutionCandidates.v1",
            "createdAt": created_at,
            "resolutionCandidates": resolution_candidates,
            "nonClaims": ["resolution candidates only", "not authority", "not approval", "not claim output", "not pack output"],
        },
    )
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        "catalogDirectSourceResolution": stable_hash(read_json(output_root / "catalog-direct-source-resolution.json")),
        "directSourceResolutionCandidates": stable_hash(read_json(output_root / "direct-source-resolution-candidates.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(catalog_direct_source_resolution_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def write_catalog_direct_source_resolution_report(
    markdown_path: Path,
    json_path: Path,
    *,
    work_items_path: Path,
    output_root: Path,
    candidate_review_path: Path | None = None,
    decision_inputs_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = compile_catalog_direct_source_resolution(
        CatalogDirectSourceResolutionOptions(
            work_items_path=work_items_path,
            output_root=output_root,
            candidate_review_path=candidate_review_path,
            decision_inputs_path=decision_inputs_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(catalog_direct_source_resolution_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def catalog_direct_source_resolution_markdown(result: dict[str, Any]) -> str:
    counts = result["recordCounts"]
    lines = [
        "# Source Atlas Catalog Direct-Source Resolution Train 70",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic direct-source resolution candidates for blocked catalog review work items.",
        "- Existing catalog locators are preserved as evidence candidates only.",
        "- Missing source, terms, rights, API, jurisdiction, authority, and packability evidence is explicit.",
        "",
        "Counts:",
        f"- Review work items: {counts['reviewWorkItems']}",
        f"- Candidate review packets: {counts['candidateReviewPackets']}",
        f"- Decision input packets: {counts['decisionInputPackets']}",
        f"- Direct-source resolution candidates: {counts['directSourceResolutionCandidates']}",
        f"- Candidates with locator candidates: {counts['candidatesWithLocatorCandidates']}",
        f"- Missing direct-source locator: {counts['missingDirectSourceLocator']}",
        f"- Blocked from authority resolution: {counts['blockedFromAuthorityResolution']}",
        f"- Active registry mutations: {counts['activeRegistryMutations']}",
        f"- Claims: {counts['claims']}",
        f"- Packable claims: {counts['packableClaims']}",
        f"- R2-packable artifacts: {counts['r2PackableArtifacts']}",
        "",
        "Product law preserved:",
        "- Catalog/source-of-sources metadata remains discovery-only and not authority.",
        "- No active registry writes, claims, packs, R2 objects, final plans, schedules, or Steps are emitted.",
        "- Human source-lane, legal/terms, API governance, and packability decisions remain required.",
        "",
        "Validation run:",
        "- See the train closeout for exact command output.",
        "",
        "Validation not run:",
        "- Production R2 upload/readback was not run.",
        "- Native XCTest/build-for-testing was not required for this tooling-only train.",
        "- Outside legal approval was not run or claimed by direct-source resolution candidates.",
        "",
        "Proof artifacts:",
    ]
    for path in result.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    lines.extend(
        [
            "",
            "Source Atlas/R2/native proof fields:",
            "- Source Atlas status ceiling: Yellow overall Source Atlas; direct-source resolution candidates only.",
            "- R2 request privacy proof: no R2 request or object key is emitted.",
            "- No private graph egress proof: privacy scans cover inputs and outputs.",
            "- License/terms proof: missing or candidate-only terms remain blocked; no legal approval is emitted.",
            "- Restricted-source exclusion proof: no source becomes packable or active.",
            "- Provenance completeness proof: no claims are emitted, so packable-claim provenance remains out of scope.",
            "- Freshness/revocation proof: no pack is emitted, so revocation/LKG remains out of scope.",
            "- LKG/rollback proof: no stable pointer or R2 object is emitted.",
            "- Native offline/no-account proof: not touched in this tooling-only train.",
            "",
            "Production non-claims:",
        ]
    )
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _review_work_items(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("reviewWorkItems"), list):
        return [item for item in payload["reviewWorkItems"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("catalogReviewWorkQueue"), dict):
        return _review_work_items(payload["catalogReviewWorkQueue"])
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _candidate_review_packets(payload: Any) -> list[dict[str, Any]]:
    if payload is None:
        return []
    if isinstance(payload, dict) and isinstance(payload.get("reviewPackets"), list):
        return [item for item in payload["reviewPackets"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("catalogCandidateReview"), dict):
        return _candidate_review_packets(payload["catalogCandidateReview"])
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _decision_input_packets(payload: Any) -> list[dict[str, Any]]:
    if payload is None:
        return []
    if isinstance(payload, dict) and isinstance(payload.get("decisionInputPackets"), list):
        return [item for item in payload["decisionInputPackets"] if isinstance(item, dict)]
    if isinstance(payload, dict) and isinstance(payload.get("catalogApprovalDecisionInputs"), dict):
        return _decision_input_packets(payload["catalogApprovalDecisionInputs"])
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def _work_schema_issues(payload: Any, work_items: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append("catalog direct-source resolution work items input must be an object or array")
    if not work_items:
        issues.append("catalog direct-source resolution input must include review work items")
    for index, item in enumerate(work_items):
        for field in ("work_item_id", "candidate_id", "source_id", "domain_guess"):
            if not item.get(field):
                issues.append(f"reviewWorkItems[{index}].{field} required")
    return issues


def _optional_packet_schema_issues(
    payload: Any,
    packets: list[dict[str, Any]],
    *,
    provided: bool,
    label: str,
    required_field: str,
) -> list[str]:
    if not provided:
        return []
    issues: list[str] = []
    if not isinstance(payload, (dict, list)):
        issues.append(f"{label} must be an object or array")
    if not packets:
        issues.append(f"{label} must include packets")
    for index, packet in enumerate(packets):
        if not packet.get(required_field):
            issues.append(f"{label}[{index}].{required_field} required")
    return issues


def _resolution_candidate(
    work_item: dict[str, Any],
    candidate_packet: dict[str, Any] | None,
    decision_packet: dict[str, Any] | None,
    created_at: str,
) -> dict[str, Any]:
    candidate_id = str(work_item.get("candidate_id") or "")
    source_id = str(work_item.get("source_id") or "")
    locators = _candidate_locators(candidate_packet, decision_packet)
    locator_classes = {locator["locator_class"] for locator in locators}
    missing_locator_classes = _missing_locator_classes(locator_classes, candidate_packet, decision_packet)
    blocking_reasons = set(str(reason) for reason in work_item.get("blocking_reasons", []) if isinstance(reason, str))
    blocking_reasons.update(
        {
            "catalog_metadata_not_claim_authority",
            "direct_source_authority_resolution_required",
            "human_source_lane_review_required",
            "legal_terms_review_required",
            "api_governance_review_required",
            "packability_decision_required",
            "pack_output_blocked_until_review",
        }
    )
    blocking_reasons.update(f"{item}_missing" for item in missing_locator_classes)
    if not candidate_packet:
        blocking_reasons.add("candidate_review_packet_missing")
    if not decision_packet:
        blocking_reasons.add("decision_input_packet_missing")

    return {
        "schema_version": "1.0.0",
        "resolution_id": stable_id("catalog_direct_source_resolution", {"candidate_id": candidate_id, "source_id": source_id}),
        "created_at": created_at,
        "status": "blocked_direct_source_review_required",
        "catalog_source_status": "discovery_only_not_authority",
        "review_required": True,
        "direct_source_authority_allowed": False,
        "pack_output_allowed": False,
        "r2_packable_artifact_allowed": False,
        "work_item_id": str(work_item.get("work_item_id") or ""),
        "proposal_id": str(work_item.get("proposal_id") or ""),
        "intake_id": str(work_item.get("intake_id") or ""),
        "candidate_id": candidate_id,
        "decision_input_id": str((decision_packet or {}).get("decision_input_id") or work_item.get("decision_input_id") or ""),
        "source_id": source_id,
        "source_name": str(work_item.get("source_name") or (candidate_packet or {}).get("publisher_name") or ""),
        "domain_guess": str(work_item.get("domain_guess") or "unclassified_public_reference"),
        "authority_class_guess": str((candidate_packet or {}).get("authority_class_guess") or ""),
        "source_class_guess": str((candidate_packet or {}).get("source_class_guess") or ""),
        "declared_jurisdiction": str((candidate_packet or {}).get("declared_jurisdiction") or ""),
        "declared_license": str((candidate_packet or {}).get("declared_license") or ""),
        "candidate_locators": locators,
        "locatorSummary": {
            "locatorCandidateCount": len(locators),
            "directSourceLocatorCandidateCount": sum(
                1
                for locator in locators
                if locator["locator_class"] in {"direct_publisher_url", "direct_dataset_url", "distribution_url"}
            ),
            "termsLocatorCandidateCount": sum(
                1
                for locator in locators
                if locator["locator_class"] in {"source_terms_url", "source_rights_url", "draft_legal_terms_url", "draft_legal_rights_url", "draft_license_url"}
            ),
        },
        "missing_locator_classes": missing_locator_classes,
        "required_evidence": _required_evidence(missing_locator_classes),
        "next_review_actions": [
            "confirm direct publisher/source authority from source-controlled evidence",
            "capture source-specific terms, rights, license, attribution, and restriction posture",
            "classify jurisdiction, source class, authority class, and allowed artifact classes",
            "complete API governance policy before live harvest or mark source no-api with evidence",
            "keep pack output blocked unless legal/terms and packability posture are explicitly approved",
        ],
        "blocking_reasons": sorted(blocking_reasons),
        "non_claims": [
            "direct-source resolution candidate only",
            "catalog locator is not authority",
            "not approval",
            "not claim output",
            "not pack output",
        ],
    }


def _candidate_locators(candidate_packet: dict[str, Any] | None, decision_packet: dict[str, Any] | None) -> list[dict[str, str | bool]]:
    locators: list[dict[str, str | bool]] = []
    if candidate_packet:
        _append_locator(locators, "direct_publisher_url", candidate_packet.get("publisher_url"), "candidate_review.publisher_url")
        _append_locator(locators, "direct_dataset_url", candidate_packet.get("dataset_url"), "candidate_review.dataset_url")
        _append_locator(locators, "api_docs_url", candidate_packet.get("api_docs_url"), "candidate_review.api_docs_url")
        _append_locator(locators, "source_terms_url", candidate_packet.get("terms_url"), "candidate_review.terms_url")
        _append_locator(locators, "source_rights_url", candidate_packet.get("rights_url"), "candidate_review.rights_url")
        for index, value in enumerate(candidate_packet.get("distribution_urls") or []):
            _append_locator(locators, "distribution_url", value, f"candidate_review.distribution_urls[{index}]")
    if decision_packet:
        legal_entry = (decision_packet.get("legal_terms_decision") or {}).get("current_entry") or {}
        _append_locator(locators, "draft_legal_terms_url", legal_entry.get("terms_url"), "decision_input.legal_terms_decision.current_entry.terms_url")
        _append_locator(locators, "draft_legal_rights_url", legal_entry.get("rights_url"), "decision_input.legal_terms_decision.current_entry.rights_url")
        _append_locator(locators, "draft_license_url", legal_entry.get("license_url"), "decision_input.legal_terms_decision.current_entry.license_url")
    deduped = {f"{item['locator_class']}|{item['url']}|{item['source_field']}": item for item in locators}
    return sorted(deduped.values(), key=lambda item: (str(item["locator_class"]), str(item["url"]), str(item["source_field"])))


def _append_locator(locators: list[dict[str, str | bool]], locator_class: str, raw_value: Any, source_field: str) -> None:
    for url in _url_values(raw_value):
        locators.append(
            {
                "locator_class": locator_class,
                "url": url,
                "source_field": source_field,
                "evidence_role": "candidate_locator_only",
                "authority_use_allowed": False,
                "review_required": True,
            }
        )


def _url_values(value: Any) -> list[str]:
    values: list[str] = []
    if isinstance(value, str):
        stripped = value.strip()
        if _is_http_url(stripped):
            values.append(stripped)
    elif isinstance(value, list):
        for item in value:
            values.extend(_url_values(item))
    elif isinstance(value, dict):
        for item in value.values():
            values.extend(_url_values(item))
    return sorted(set(values))


def _is_http_url(value: str) -> bool:
    parsed = urlparse(value)
    return parsed.scheme in {"http", "https"} and bool(parsed.netloc)


def _missing_locator_classes(
    locator_classes: set[str],
    candidate_packet: dict[str, Any] | None,
    decision_packet: dict[str, Any] | None,
) -> list[str]:
    missing: set[str] = set()
    if not locator_classes.intersection({"direct_publisher_url", "direct_dataset_url", "distribution_url"}):
        missing.add("direct_source_locator_url")
    if "direct_publisher_url" not in locator_classes:
        missing.add("publisher_url")
    if "direct_dataset_url" not in locator_classes:
        missing.add("dataset_url")
    if "source_terms_url" not in locator_classes:
        missing.add("source_specific_terms_url")
    if "source_rights_url" not in locator_classes:
        missing.add("source_specific_rights_url")
    if "api_docs_url" not in locator_classes:
        missing.add("api_docs_url_or_no_api_evidence")
    source_lane_entry = ((decision_packet or {}).get("source_lane_decision") or {}).get("current_entry") or {}
    if not source_lane_entry.get("authority_class"):
        missing.add("authority_class_evidence")
    if _is_missing(source_lane_entry.get("jurisdiction")) and _is_missing((candidate_packet or {}).get("declared_jurisdiction")):
        missing.add("jurisdiction_evidence")
    if not source_lane_entry.get("source_class"):
        missing.add("source_class_evidence")
    return sorted(missing)


def _required_evidence(missing_locator_classes: list[str]) -> list[str]:
    evidence = {
        "direct_source_locator",
        "direct_source_authority_evidence",
        "source_specific_terms_rights_license_snapshot",
        "jurisdiction_and_authority_class_review",
        "api_docs_or_no_api_evidence",
        "legal_terms_review_record",
        "api_governance_policy_record",
        "packability_decision_record",
    }
    if "source_specific_terms_url" in missing_locator_classes or "source_specific_rights_url" in missing_locator_classes:
        evidence.add("source_specific_terms_or_rights_locator")
    if "api_docs_url_or_no_api_evidence" in missing_locator_classes:
        evidence.add("api_surface_resolution")
    return sorted(evidence)


def _is_missing(value: Any) -> bool:
    if value is None:
        return True
    if isinstance(value, (dict, list)):
        return True
    if isinstance(value, str):
        stripped = value.strip()
        return stripped.lower() in {"", "unknown", "review_required", "not_claimed", "not_approved"} or stripped.startswith(("{", "["))
    return True


def _contains_forbidden_output_marker(value: Any) -> bool:
    if isinstance(value, str):
        return value in FORBIDDEN_OUTPUT_MARKERS
    if isinstance(value, list):
        return any(_contains_forbidden_output_marker(item) for item in value)
    if isinstance(value, dict):
        return any(
            _contains_forbidden_output_marker(item)
            for key, item in value.items()
            if key not in {"forbidden_artifact_classes", "claim_classes_forbidden", "non_claims", "blocking_reasons", "next_review_actions"}
        )
    return False
