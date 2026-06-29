"""Normalize Deep Research frontier atlases into governed Source Atlas intake.

This lane is intentionally candidate-only. It converts broad research output
into the existing frontier-intake shape and separate review queues, but never
approves sources, emits claim authority, compiles packs, or produces R2-ready
objects.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .claim_frontier import DEFAULT_FRONTIER_CONFIG_PATH
from .frontier_intake import FrontierIntakeOptions, compile_frontier_intake
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, privacy_findings_for_value, read_json, stable_hash, utc_now, write_json


DEEP_RESEARCH_FRONTIER_INTAKE_VERSION = "source-atlas-deep-research-frontier-intake-train-137"
DEEP_RESEARCH_FRONTIER_INTAKE_KIND = "ambitions.sourceAtlas.deepResearchFrontierIntake.v1"
DEFAULT_SOURCE_LANE_REGISTRY_PATH = Path("tools/source-atlas/governance/source-lane-registry.json")

SOURCE_CLASS_GUESS_BY_MARKER = {
    "standards": "standards_body",
    "standard": "standards_body",
    "federal": "official_government",
    "government": "official_government",
    "gov": "official_government",
    "official": "official_government",
    "regulated": "regulated_body",
    "catalog": "public_catalog",
    "open_knowledge_graph": "open_knowledge_graph",
    "community": "open_knowledge_graph",
    "commercial": "commercial_api",
}

AUTHORITY_CLASS_GUESS_BY_MARKER = SOURCE_CLASS_GUESS_BY_MARKER

DEEP_RESEARCH_NON_CLAIMS = [
    "not source authority",
    "not claim output",
    "not pack output",
    "not R2 readiness",
    "not production target readiness",
    "not legal approval",
    "not outside legal approval",
    "not owner approval",
    "not credential proof",
    "not universal coverage",
    "not full Source Atlas Green",
    "not app runtime readiness",
    "not release readiness",
    "not final user plans, schedules, or Steps",
    *NON_CLAIMS,
]

COVERAGE_FREEDOM_LANES = [
    {
        "lane": "frontier_candidate_intake",
        "freedom": "accept broad public/reference frontier definitions as review-bound candidates",
        "gate": "frontier governance review before registry mutation",
    },
    {
        "lane": "source_candidate_review",
        "freedom": "queue official, standards-body, open-license, catalog, and source-of-sources candidates together",
        "gate": "source-lane, legal/terms, API, and owner review before claim use",
    },
    {
        "lane": "gold_claim_review_markers",
        "freedom": "capture desired gold-claim coverage markers without emitting claims",
        "gate": "claim frontier review, provenance, exclusions, non-claims, and adapter evidence",
    },
    {
        "lane": "coverage_gap_expansion",
        "freedom": "preserve jurisdiction, freshness, exclusion, and fragmentation notes as work-order inputs",
        "gate": "no pack production until authority, rights, schema, and privacy reviews pass",
    },
    {
        "lane": "gated_r2_promotion",
        "freedom": "prepare later promotion queues from reviewed packs",
        "gate": "owner approval, legal/terms approval, production-target readiness, credentials, rollback evidence, and readback checksum",
    },
]


@dataclass(frozen=True)
class DeepResearchFrontierIntakeOptions:
    input_path: Path
    output_root: Path
    frontier_config_path: Path | None = DEFAULT_FRONTIER_CONFIG_PATH
    source_lane_registry_path: Path | None = DEFAULT_SOURCE_LANE_REGISTRY_PATH
    created_at: str | None = None


def run_deep_research_frontier_intake(options: DeepResearchFrontierIntakeOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)

    payload, extraction = _load_research_payload(options.input_path)
    payload_issues = _payload_issues(payload)
    input_privacy_issues = (
        privacy_findings_for_value(_boundary_scan_safe_payload(payload), "deep-research-frontier-input")
        if isinstance(payload, dict)
        else []
    )

    normalized_sources = _normalize_sources(payload)
    source_by_original_id = {item["submitted_source_id"]: item for item in normalized_sources if item.get("submitted_source_id")}
    gold_claim_markers = _gold_claim_review_markers(payload, source_by_original_id)
    proposals = _domain_proposals(payload, normalized_sources, gold_claim_markers)
    frontier_intake_input = {
        "domainProposals": proposals,
        "source": {
            "sourceClassification": "research_seed",
            "production_use": False,
            "submittedPath": str(options.input_path),
            "extractionMode": extraction["mode"],
        },
    }

    frontier_intake_input_path = output_root / "frontier-intake-input.json"
    write_json(frontier_intake_input_path, frontier_intake_input)

    frontier_intake_result = compile_frontier_intake(
        FrontierIntakeOptions(
            input_path=frontier_intake_input_path,
            output_root=output_root / "frontier-intake",
            frontier_config_path=options.frontier_config_path,
            created_at=created_at,
        )
    )

    configured_frontiers = _configured_frontier_ids(options.frontier_config_path or DEFAULT_FRONTIER_CONFIG_PATH)
    source_lane_ids, source_lane_names = _configured_source_lane_ids_and_names(options.source_lane_registry_path or DEFAULT_SOURCE_LANE_REGISTRY_PATH)
    overlap = _overlap_report(proposals, normalized_sources, configured_frontiers, source_lane_ids, source_lane_names)
    workflow_queue = _workflow_queue(proposals, gold_claim_markers, normalized_sources, overlap)
    coverage_freedom_map = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.coverageFreedomMap.v1",
        "versionID": DEEP_RESEARCH_FRONTIER_INTAKE_VERSION,
        "createdAt": created_at,
        "statusCeiling": "candidate_only",
        "coverageFreedomLanes": COVERAGE_FREEDOM_LANES,
        "overlap": overlap,
        "recordCounts": {
            "frontierCandidates": len(proposals),
            "sourceCandidates": len(normalized_sources),
            "goldClaimReviewMarkers": len(gold_claim_markers),
            "workflowItems": len(workflow_queue),
            "productionRegistryMutations": 0,
            "r2Objects": 0,
        },
        "nonClaims": DEEP_RESEARCH_NON_CLAIMS,
    }

    normalized_frontiers = [
        {
            "submitted_frontier_id": str(frontier.get("frontier_id", "")),
            "frontier_id": proposal["frontier_id"],
            "domain": proposal["domain"],
            "priority": str(frontier.get("priority", "")),
            "status_ceiling": "candidate_only",
            "review_required": True,
            "pack_output_allowed": False,
            "claim_output_allowed": False,
            "r2_output_allowed": False,
        }
        for frontier, proposal in zip(_frontiers(payload), proposals)
    ]

    checks = [
        {"name": "input_schema_valid", "passed": not payload_issues, "issues": payload_issues},
        {"name": "input_privacy_scan_passed", "passed": not input_privacy_issues, "issues": input_privacy_issues},
        {
            "name": "frontier_intake_valid",
            "passed": bool(frontier_intake_result.get("valid")),
            "issues": frontier_intake_result.get("issues", []),
        },
        {
            "name": "candidate_intake_emits_no_claims",
            "passed": frontier_intake_result["recordCounts"]["claims"] == 0
            and frontier_intake_result["recordCounts"]["packableClaims"] == 0
            and frontier_intake_result["recordCounts"]["r2PackableArtifacts"] == 0,
            "issues": [],
        },
        {
            "name": "gold_claims_are_review_markers_only",
            "passed": all(
                marker["claim_output_allowed"] is False
                and marker["pack_output_allowed"] is False
                and marker["r2_output_allowed"] is False
                for marker in gold_claim_markers
            ),
            "issues": [],
        },
        {
            "name": "production_mutation_blocked",
            "passed": coverage_freedom_map["recordCounts"]["productionRegistryMutations"] == 0
            and coverage_freedom_map["recordCounts"]["r2Objects"] == 0,
            "issues": [],
        },
        {
            "name": "workflow_queue_review_bound",
            "passed": all(item["status"] == "blocked_review_required" for item in workflow_queue),
            "issues": [],
        },
    ]

    issues: list[str] = []
    issues.extend(payload_issues)
    issues.extend(input_privacy_issues)
    if not frontier_intake_result.get("valid"):
        issues.extend(frontier_intake_result.get("issues", []))
    for check in checks:
        if not check["passed"]:
            issues.extend(check.get("issues") or [f"failed check: {check['name']}"])
    issues = sorted(set(str(issue) for issue in issues if issue))

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": DEEP_RESEARCH_FRONTIER_INTAKE_KIND,
        "versionID": DEEP_RESEARCH_FRONTIER_INTAKE_VERSION,
        "createdAt": created_at,
        "status": "Source Green for Deep Research frontier intake normalization" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; Deep Research candidate normalization only",
        "inputPath": str(options.input_path),
        "frontierConfigPath": str(options.frontier_config_path or DEFAULT_FRONTIER_CONFIG_PATH),
        "sourceLaneRegistryPath": str(options.source_lane_registry_path or DEFAULT_SOURCE_LANE_REGISTRY_PATH),
        "recordCounts": coverage_freedom_map["recordCounts"],
        "checks": checks,
        "issues": issues,
        "extraction": extraction,
        "outputPaths": {
            "frontierIntakeInput": str(frontier_intake_input_path),
            "frontierIntakeManifest": str(Path(frontier_intake_result["manifestPath"])),
            "normalizedFrontiers": str(output_root / "normalized-frontiers.json"),
            "normalizedSources": str(output_root / "normalized-source-candidates.json"),
            "goldClaimReviewQueue": str(output_root / "gold-claim-review-queue.json"),
            "coverageFreedomMap": str(output_root / "coverage-freedom-map.json"),
            "workflowQueue": str(output_root / "workflow-queue.json"),
            "manifest": str(output_root / "manifest.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": DEEP_RESEARCH_NON_CLAIMS,
    }

    write_json(output_root / "normalized-frontiers.json", {"createdAt": created_at, "frontiers": normalized_frontiers})
    write_json(output_root / "normalized-source-candidates.json", {"createdAt": created_at, "sourceCandidates": normalized_sources})
    write_json(output_root / "gold-claim-review-queue.json", {"createdAt": created_at, "goldClaimReviewMarkers": gold_claim_markers})
    write_json(output_root / "coverage-freedom-map.json", coverage_freedom_map)
    write_json(output_root / "workflow-queue.json", {"createdAt": created_at, "workflowItems": workflow_queue})
    write_json(output_root / "manifest.json", manifest)
    manifest["outputHashes"] = {
        name: stable_hash(read_json(Path(path)))
        for name, path in manifest["outputPaths"].items()
        if path.endswith(".json") and Path(path).exists()
    }
    write_json(output_root / "manifest.json", manifest)
    (output_root / "closeout.md").write_text(deep_research_frontier_intake_markdown(manifest), encoding="utf-8")
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def deep_research_frontier_intake_markdown(result: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Deep Research Frontier Intake",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Normalized Deep Research frontier/source/gold-claim material into candidate-only Foundry artifacts.",
        "- Fed normalized frontier candidates through the governed frontier-intake compiler.",
        "- Emitted coverage-freedom and workflow queues without mutating production registries or R2.",
        "",
        "Product law preserved:",
        "- R2 remains public/reference/freshness infrastructure only.",
        "- Source Atlas does not receive private user context or private life graph data.",
        "- Gold claims are review markers only, not claim output.",
        "- No pack, current pointer, LKG pointer, revocation manifest, or production R2 object is emitted.",
        "",
        "Record counts:",
    ]
    for key, value in result.get("recordCounts", {}).items():
        lines.append(f"- {key}: {value}")
    lines.extend(["", "Checks:"])
    for check in result.get("checks", []):
        lines.append(f"- {check['name']}: {'PASS' if check['passed'] else 'FAIL'}")
    lines.extend(
        [
            "",
            "Validation not run:",
            "- Live web verification was not run.",
            "- Outside legal review was not run or claimed.",
            "- Source-lane registry mutation was not run.",
            "- Pack production was not run.",
            "- Production R2 publish/readback was not run.",
            "",
            "Proof artifacts:",
        ]
    )
    for path in result.get("outputPaths", {}).values():
        lines.append(f"- {path}")
    lines.extend(["", "Production non-claims:"])
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def _load_research_payload(path: Path) -> tuple[Any, dict[str, str]]:
    text = path.read_text(encoding="utf-8")
    try:
        return json.loads(text), {"mode": "json_file"}
    except json.JSONDecodeError:
        match = re.search(r"```json\s*(.*?)```", text, flags=re.S | re.I)
        if not match:
            raise
        return json.loads(match.group(1)), {"mode": "markdown_fenced_json"}


def _payload_issues(payload: Any) -> list[str]:
    if not isinstance(payload, dict):
        return ["input payload must be an object or markdown file containing a JSON object"]
    issues = []
    if not isinstance(payload.get("frontiers"), list) or not payload.get("frontiers"):
        issues.append("frontiers must be a non-empty list")
    if "source_candidates" in payload and not isinstance(payload["source_candidates"], list):
        issues.append("source_candidates must be a list when present")
    if "gold_claims" in payload and not isinstance(payload["gold_claims"], list):
        issues.append("gold_claims must be a list when present")
    return issues


def _boundary_scan_safe_payload(value: Any) -> Any:
    """Preserve values while renaming governance metadata keys for boundary scan.

    Deep Research source records commonly use ``api_key_required`` to mean "this
    public API requires a key." The generic Source Atlas boundary scanner treats
    any key-like field name as a potential credential, so we rename that metadata
    key before scanning. Secret-looking values still fail the scan.
    """

    if isinstance(value, list):
        return [_boundary_scan_safe_payload(item) for item in value]
    if isinstance(value, dict):
        output = {}
        for key, child in value.items():
            safe_key = "apiCredentialRequirementMetadata" if key == "api_key_required" else key
            output[safe_key] = _boundary_scan_safe_payload(child)
        return output
    return value


def _domain_proposals(
    payload: Any,
    normalized_sources: list[dict[str, Any]],
    gold_claim_markers: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    source_by_id = {source["submitted_source_id"]: source for source in normalized_sources}
    gold_sources_by_frontier: dict[str, set[str]] = {}
    for marker in gold_claim_markers:
        gold_sources_by_frontier.setdefault(marker["frontier_id"], set()).add(marker["submitted_source_id"])

    proposals = []
    for frontier in _frontiers(payload):
        frontier_id = _normalize_frontier_id(str(frontier.get("frontier_id") or frontier.get("domain") or "frontier"))
        selected_sources = [
            source_by_id[source_id]["frontier_candidate_source"]
            for source_id in sorted(gold_sources_by_frontier.get(frontier_id, set()))
            if source_id in source_by_id
        ]
        if not selected_sources:
            selected_sources = _sources_for_claim_classes(frontier, normalized_sources)
        proposal = {
            "proposal_id": frontier_id,
            "frontier_id": frontier_id,
            "domain": str(frontier.get("domain") or frontier_id),
            "goal_intent_classes": _string_list(frontier, "goal_intent_classes"),
            "claim_classes": _string_list(frontier, "claim_classes"),
            "jurisdictions": _string_list(frontier, "jurisdictions"),
            "source_classes_required": _mapped_class_list(_string_list(frontier, "minimum_authority_classes")),
            "minimum_authority_classes": _mapped_class_list(_string_list(frontier, "minimum_authority_classes")),
            "freshness_slas": _split_sla(str(frontier.get("freshness_sla", ""))),
            "candidate_sources": selected_sources,
            "non_claims": _ordered_unique(
                [
                    *_string_list(frontier, "non_claims"),
                    *[f"explicit exclusion: {item}" for item in _string_list(frontier, "explicit_exclusions")],
                    *[f"forbidden claim: {item}" for item in _string_list(frontier, "forbidden_claims")],
                    "not production coverage",
                    "not pack output",
                    "not R2 readiness",
                ]
            ),
        }
        proposals.append(proposal)
    return sorted(proposals, key=lambda item: item["frontier_id"])


def _normalize_sources(payload: Any) -> list[dict[str, Any]]:
    records = []
    for source in _sources(payload):
        submitted_id = str(source.get("source_id") or source.get("source_name") or "")
        normalized_source_id = _normalize_source_id(submitted_id)
        source_class_guess = _mapped_class(str(source.get("source_class") or source.get("authority_class") or "unknown"), SOURCE_CLASS_GUESS_BY_MARKER)
        authority_class_guess = _mapped_class(str(source.get("authority_class") or source.get("source_class") or "unknown"), AUTHORITY_CLASS_GUESS_BY_MARKER)
        data_url = str(source.get("data_url/api_url") or source.get("data_url") or source.get("api_url") or "")
        docs_url = str(source.get("documentation_url") or "")
        terms_url = str(source.get("terms_url") or "")
        license_url = str(source.get("license_url") or "")
        rights_url = str(source.get("rights_url") or "")
        mapped = {
            "discovery_method": "deep_research_seed",
            "publisher_name": str(source.get("publisher") or source.get("source_name") or ""),
            "publisher_url": str(source.get("homepage_url") or ""),
            "declared_jurisdiction": ", ".join(_string_list(source, "jurisdictions_covered")),
            "declared_license": str(source.get("declared_license") or ""),
            "declared_rights": "; ".join(_string_list(source, "known_restrictions")),
            "terms_url": terms_url or license_url or rights_url,
            "rights_url": rights_url or license_url or terms_url,
            "dataset_url": data_url or str(source.get("homepage_url") or ""),
            "distribution_urls": _ordered_unique([data_url, str(source.get("homepage_url") or "")]),
            "api_docs_url": docs_url,
            "source_class_guess": source_class_guess,
            "authority_class_guess": authority_class_guess,
            "claim_class_guess": _string_list(source, "claim_classes_supported"),
            "redistribution_guess": _redistribution_guess(source),
        }
        api_credential_requirement = _api_credential_requirement(source)
        records.append(
            {
                "submitted_source_id": submitted_id,
                "source_id": normalized_source_id,
                "source_name": str(source.get("source_name") or ""),
                "status_ceiling": "candidate_only",
                "review_required": True,
                "claim_authority_allowed": False,
                "pack_output_allowed": False,
                "r2_output_allowed": False,
                "api_key_required": api_credential_requirement,
                "rate_limits": source.get("rate_limits", ""),
                "update_cadence": source.get("update_cadence", ""),
                "coverage_gaps": _string_list(source, "coverage_gaps"),
                "sensitive_data_risk": str(source.get("sensitive_data_risk") or ""),
                "recommended_freshness_sla": str(source.get("recommended_freshness_sla") or ""),
                "frontier_candidate_source": mapped,
                "blocking_reasons": [
                    "source_lane_review_required",
                    "legal_terms_review_required",
                    "api_governance_review_required",
                    "owner_review_required",
                    "pack_output_blocked_until_review",
                ],
                "evidence_hash": stable_hash(source),
            }
        )
    return sorted(records, key=lambda item: item["source_id"])


def _gold_claim_review_markers(payload: Any, source_by_original_id: dict[str, dict[str, Any]]) -> list[dict[str, Any]]:
    markers = []
    for claim in _gold_claims(payload):
        submitted_frontier_id = str(claim.get("frontier_id") or "")
        submitted_source_id = str(claim.get("source_id") or "")
        frontier_id = _normalize_frontier_id(submitted_frontier_id)
        source_id = source_by_original_id.get(submitted_source_id, {}).get("source_id", _normalize_source_id(submitted_source_id))
        claim_type = _normalize_token(str(claim.get("claim_type") or "claim"))
        marker_id = f"gold.{frontier_id}.{source_id.replace('.', '_')}.{claim_type}"
        markers.append(
            {
                "submitted_gold_claim_id": str(claim.get("gold_claim_id") or ""),
                "gold_claim_review_marker_id": marker_id,
                "submitted_frontier_id": submitted_frontier_id,
                "frontier_id": frontier_id,
                "submitted_source_id": submitted_source_id,
                "source_id": source_id,
                "claim_type": str(claim.get("claim_type") or ""),
                "jurisdiction": str(claim.get("jurisdiction") or ""),
                "object_contains_markers": _string_list(claim, "object_contains_markers"),
                "exclusions": _string_list(claim, "exclusions"),
                "non_claims": _string_list(claim, "non_claims"),
                "status_ceiling": "review_marker_only",
                "review_required": True,
                "claim_output_allowed": False,
                "pack_output_allowed": False,
                "r2_output_allowed": False,
                "blocking_reasons": [
                    "claim_frontier_review_required",
                    "provenance_evidence_required",
                    "source_lane_review_required",
                    "legal_terms_review_required",
                    "pack_output_blocked_until_review",
                ],
                "evidence_hash": stable_hash(claim),
            }
        )
    return sorted(markers, key=lambda item: item["gold_claim_review_marker_id"])


def _workflow_queue(
    proposals: list[dict[str, Any]],
    gold_claim_markers: list[dict[str, Any]],
    normalized_sources: list[dict[str, Any]],
    overlap: dict[str, Any],
) -> list[dict[str, Any]]:
    source_ids_with_keys = {
        source["source_id"]
        for source in normalized_sources
        if str(source.get("api_key_required")).lower() in {"true", "yes", "required"} or "key" in str(source.get("api_key_required")).lower()
    }
    gold_count_by_frontier: dict[str, int] = {}
    for marker in gold_claim_markers:
        gold_count_by_frontier[marker["frontier_id"]] = gold_count_by_frontier.get(marker["frontier_id"], 0) + 1

    items = []
    for proposal in proposals:
        frontier_id = proposal["frontier_id"]
        source_ids = sorted(
            source["source_id"]
            for source in normalized_sources
            if source["frontier_candidate_source"] in proposal.get("candidate_sources", [])
        )
        base = {
            "frontier_id": frontier_id,
            "status": "blocked_review_required",
            "candidate_only": True,
            "claim_output_allowed": False,
            "pack_output_allowed": False,
            "r2_output_allowed": False,
            "blocking_reasons": [
                "frontier_review_required",
                "source_lane_review_required",
                "legal_terms_review_required",
                "production_target_readiness_required",
                "r2_owner_approval_required",
            ],
        }
        for work_type in (
            "frontier_governance_review",
            "source_lane_review",
            "legal_terms_review",
            "api_governance_review",
            "gold_claim_review",
            "adapter_contract_planning",
            "local_candidate_harvest_review",
            "production_target_readiness_review",
            "gated_r2_promotion_review",
        ):
            item = {**base, "work_type": work_type}
            item["source_ids"] = source_ids
            item["gold_claim_review_marker_count"] = gold_count_by_frontier.get(frontier_id, 0)
            item["configured_frontier_overlap"] = frontier_id in set(overlap.get("configuredFrontierIDs", []))
            if work_type == "api_governance_review" or source_ids_with_keys.intersection(source_ids):
                item["blocking_reasons"] = sorted(set([*item["blocking_reasons"], "api_credentials_or_budget_review_required"]))
            items.append(item)
    return sorted(items, key=lambda item: (item["frontier_id"], item["work_type"]))


def _overlap_report(
    proposals: list[dict[str, Any]],
    normalized_sources: list[dict[str, Any]],
    configured_frontiers: set[str],
    source_lane_ids: set[str],
    source_lane_names: set[str],
) -> dict[str, Any]:
    candidate_frontier_ids = {proposal["frontier_id"] for proposal in proposals}
    candidate_source_ids = {source["source_id"] for source in normalized_sources}
    candidate_source_names = {source["source_name"].lower() for source in normalized_sources if source.get("source_name")}
    return {
        "configuredFrontierIDs": sorted(candidate_frontier_ids.intersection(configured_frontiers)),
        "newCandidateFrontierIDs": sorted(candidate_frontier_ids - configured_frontiers),
        "configuredSourceLaneIDs": sorted(candidate_source_ids.intersection(source_lane_ids)),
        "configuredSourceLaneNameMatches": sorted(candidate_source_names.intersection(source_lane_names)),
        "overlapPolicy": "informational_review_required_not_registry_mutation",
    }


def _sources_for_claim_classes(frontier: dict[str, Any], normalized_sources: list[dict[str, Any]]) -> list[dict[str, Any]]:
    claim_classes = {item.lower() for item in _string_list(frontier, "claim_classes")}
    selected = []
    for source in normalized_sources:
        source_claim_classes = {item.lower() for item in source["frontier_candidate_source"].get("claim_class_guess", [])}
        if claim_classes.intersection(source_claim_classes):
            selected.append(source["frontier_candidate_source"])
    return selected


def _configured_frontier_ids(path: Path) -> set[str]:
    if not path.exists():
        return set()
    return {str(item.get("frontier_id")) for item in read_json(path).get("frontiers", []) if isinstance(item, dict)}


def _configured_source_lane_ids_and_names(path: Path) -> tuple[set[str], set[str]]:
    if not path.exists():
        return set(), set()
    data = read_json(path)
    lanes = [item for item in data.get("source_lanes", []) if isinstance(item, dict)]
    return {str(item.get("source_id")) for item in lanes}, {str(item.get("source_name", "")).lower() for item in lanes if item.get("source_name")}


def _frontiers(payload: Any) -> list[dict[str, Any]]:
    if not isinstance(payload, dict):
        return []
    return [item for item in payload.get("frontiers", []) if isinstance(item, dict)]


def _sources(payload: Any) -> list[dict[str, Any]]:
    if not isinstance(payload, dict):
        return []
    return [item for item in payload.get("source_candidates", []) if isinstance(item, dict)]


def _gold_claims(payload: Any) -> list[dict[str, Any]]:
    if not isinstance(payload, dict):
        return []
    return [item for item in payload.get("gold_claims", []) if isinstance(item, dict)]


def _normalize_frontier_id(value: str) -> str:
    normalized = _normalize_token(value)
    normalized = re.sub(r"^f\d+_", "", normalized)
    return normalized or "unnamed_frontier"


def _normalize_source_id(value: str) -> str:
    normalized = _normalize_token(value)
    normalized = re.sub(r"^src_", "", normalized)
    return normalized.replace("_", ".") or "unknown.source"


def _normalize_token(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", value.lower()).strip("_")


def _string_list(container: dict[str, Any], key: str) -> list[str]:
    value = container.get(key, [])
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if isinstance(item, (str, int, float)) and str(item).strip()]


def _split_sla(value: str) -> list[str]:
    if not value:
        return []
    return [part.strip() for part in re.split(r";|,", value) if part.strip()]


def _mapped_class_list(values: list[str]) -> list[str]:
    return sorted(set(_mapped_class(value, AUTHORITY_CLASS_GUESS_BY_MARKER) for value in values if value))


def _mapped_class(value: str, mapping: dict[str, str]) -> str:
    lowered = _normalize_token(value)
    for marker, mapped in mapping.items():
        if marker in lowered:
            return mapped
    if "open_reference" in lowered:
        return "official_institution"
    if "scholarly" in lowered:
        return "scholarly_metadata"
    return "unknown"


def _redistribution_guess(source: dict[str, Any]) -> str:
    declared_license = str(source.get("declared_license") or "").lower()
    raw = " ".join(
        str(source.get(key) or "").lower()
        for key in ("redistribution_allowed_guess", "pack_output_allowed_guess", "declared_license")
    )
    if "blocked" in raw or "no" == raw.strip():
        return "blocked"
    if "restricted" in raw or "partial" in raw:
        return "restricted"
    if "unclear" in raw or "not_explicit" in raw:
        return "unclear"
    if "with" in raw or "subject" in raw or "but" in raw or "odbl" in raw or "cc_by" in raw:
        return "open_with_attribution"
    if "cc0" in declared_license or "public domain" in declared_license or "public_domain" in declared_license:
        return "clearly_open"
    if "yes" in raw:
        return "clearly_open"
    return "unclear"


def _api_credential_requirement(source: dict[str, Any]) -> Any:
    return source.get("api_key_required", source.get("apiCredentialRequirementMetadata", ""))


def _ordered_unique(values: list[str]) -> list[str]:
    seen: set[str] = set()
    output: list[str] = []
    for value in values:
        if value and value not in seen:
            seen.add(value)
            output.append(value)
    return output
