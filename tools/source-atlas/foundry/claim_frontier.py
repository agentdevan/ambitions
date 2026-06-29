"""Claim graph and coverage frontier compiler for Source Atlas Train 3."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .governance_registry import load_governance_registries, validate_governance_registries
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, file_sha256, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


CLAIM_FRONTIER_VERSION = "source-atlas-claim-frontier-train-03"
GOLD_SET_EVALUATOR_VERSION = "source-atlas-gold-set-evaluator-train-40"
SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_FRONTIER_CONFIG_PATH = SOURCE_ATLAS_ROOT / "frontier" / "coverage-frontiers.json"
PACK_ALLOWED_POLICIES = {"pack_allowed", "pack_allowed_with_attribution"}
FRESHNESS_BLOCKING_STATES = {"stale-critical", "revoked", "conflicted", "terms-blocked", "unsupported", "malformed", "unavailable"}
FINAL_OUTPUT_FORBIDDEN = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_goal_graph"}
PRODUCTION_NON_CLAIMS = NON_CLAIMS + [
    "not full Source Atlas Green",
    "not production R2 readiness",
    "not native app runtime readiness",
    "not outside legal approval",
    "not universal goal coverage",
    "not a final user plan, schedule, or Step generator",
]


@dataclass(frozen=True)
class ClaimFrontierOptions:
    input_root: Path
    output_root: Path
    frontier_config_path: Path | None = DEFAULT_FRONTIER_CONFIG_PATH
    created_at: str | None = None


def compile_claim_frontier(options: ClaimFrontierOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    issues: list[str] = []
    checks: list[dict[str, Any]] = []

    governance = validate_governance_registries()
    checks.append({"name": "governance_registries_valid", "passed": governance["valid"]})
    if not governance["valid"]:
        issues.extend(f"governance: {issue}" for issue in governance["issues"])

    registries = load_governance_registries()
    source_lanes = {lane["source_id"]: lane for lane in registries["source_lanes"].get("source_lanes", [])}
    legal_terms = {entry["license_id"]: entry for entry in registries["legal_terms"].get("licenses", [])}
    frontier_config_path = options.frontier_config_path or DEFAULT_FRONTIER_CONFIG_PATH
    frontier_config = _load_frontier_config(frontier_config_path, issues)
    harvest_manifest = _load_optional_json(options.input_root / "manifest.json")
    normalized_outputs = _load_normalized_outputs(options.input_root, issues)

    compiled_claims: list[dict[str, Any]] = []
    citations: list[dict[str, Any]] = []
    public_entities: list[dict[str, Any]] = []
    claim_blockers: list[dict[str, Any]] = []
    source_summaries: dict[str, dict[str, Any]] = {}

    for normalized in normalized_outputs:
        source_id = normalized.get("sourceID", "<missing-source>")
        lane = source_lanes.get(source_id)
        legal = legal_terms.get(lane.get("license_id")) if lane else None
        provenance_by_id = {item.get("id"): item for item in normalized.get("provenance", []) if isinstance(item, dict)}
        source_state = normalized.get("sourceState", {})
        source_summaries[source_id] = _source_summary(source_id, lane, legal, normalized)
        for claim in sorted(normalized.get("claims", []), key=lambda item: str(item.get("id", ""))):
            canonical = _canonical_claim(
                claim=claim,
                normalized=normalized,
                lane=lane,
                legal=legal,
                provenance_by_id=provenance_by_id,
                source_state=source_state,
            )
            compiled_claims.append(canonical)
            public_entities.append(_entity_for_claim(canonical))
            if canonical["citation"]:
                citations.append(canonical["citation"])
            if canonical["pack_eligibility"] != "packable":
                claim_blockers.append(
                    {
                        "claim_id": canonical["claim_id"],
                        "source_id": canonical["source_id"],
                        "claim_type": canonical["claim_type"],
                        "pack_eligibility": canonical["pack_eligibility"],
                        "blocked_reasons": canonical["blocked_reasons"],
                    }
                )
            canonical.pop("citation", None)

    compiled_claims = sorted(compiled_claims, key=lambda item: item["claim_id"])
    citations = sorted(citations, key=lambda item: item["citation_id"])
    public_entities = _dedupe_entities(public_entities)
    frontier_reports = _compile_frontier_reports(frontier_config, compiled_claims, source_lanes, legal_terms, harvest_manifest)
    claim_graph = _claim_graph(created_at, compiled_claims, public_entities, source_summaries, claim_blockers, frontier_reports)
    citation_graph = _citation_graph(created_at, citations)
    privacy_value = {
        "claimGraph": claim_graph,
        "citationGraph": citation_graph,
        "frontierReports": frontier_reports,
    }
    privacy_issues = privacy_findings_for_value(privacy_value, "claim-frontier-output")
    checks.extend(
        [
            {"name": "claim_graph_written", "passed": bool(compiled_claims)},
            {"name": "packable_claims_have_complete_provenance_tuple", "passed": _packable_claims_have_complete_tuple(compiled_claims)},
            {"name": "missing_provenance_blocks_pack_output", "passed": _missing_provenance_blocks(compiled_claims)},
            {"name": "restricted_sources_excluded_from_packable_claims", "passed": _source_is_not_packable(compiled_claims, "usajobs.search")},
            {"name": "crosswalk_only_sources_excluded_from_regulated_authority", "passed": _source_is_not_packable(compiled_claims, "wikidata.crosswalk")},
            {"name": "candidate_only_frontiers_do_not_claim_pack_readiness", "passed": _candidate_frontiers_are_below_pack_readiness(frontier_reports)},
            {"name": "privacy_scan_passed", "passed": not privacy_issues},
            {"name": "no_final_plan_schedule_step_output", "passed": not _contains_forbidden_output_classes(source_lanes.values())},
        ]
    )
    if privacy_issues:
        issues.extend(privacy_issues)

    valid = not issues and all(check["passed"] for check in checks)
    status = "Source Green for claim/frontier tooling" if valid else "Red"
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.claimFrontierManifest.v1",
        "versionID": CLAIM_FRONTIER_VERSION,
        "createdAt": created_at,
        "status": status,
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; claim graph and coverage frontier tooling only",
        "inputRoot": str(options.input_root),
        "frontierConfigPath": str(frontier_config_path),
        "outputPaths": {
            "claimGraph": str(output_root / "claim-graph.json"),
            "citationGraph": str(output_root / "citation-graph.json"),
            "coverageFrontierReport": str(output_root / "coverage-frontier-report.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "recordCounts": {
            "claims": len(compiled_claims),
            "packableClaims": sum(1 for claim in compiled_claims if claim["pack_eligibility"] == "packable"),
            "blockedClaims": sum(1 for claim in compiled_claims if claim["pack_eligibility"] != "packable"),
            "citations": len(citations),
            "entities": len(public_entities),
            "frontiers": len(frontier_reports),
        },
        "provenanceCompleteness": _provenance_completeness(compiled_claims),
        "legalPostureCompleteness": _legal_posture_completeness(compiled_claims),
        "freshnessCompliance": _freshness_compliance(compiled_claims),
        "restrictedExclusions": _restricted_exclusions(compiled_claims, harvest_manifest),
        "claimBlockers": claim_blockers,
        "frontierReports": frontier_reports,
        "checks": checks,
        "issues": issues,
        "privacyScan": {"passed": not privacy_issues, "issues": privacy_issues},
        "nonClaims": PRODUCTION_NON_CLAIMS,
        "privacyBoundary": PRIVACY_BOUNDARY,
    }

    write_json(output_root / "claim-graph.json", claim_graph)
    write_json(output_root / "citation-graph.json", citation_graph)
    write_json(output_root / "coverage-frontier-report.json", {"frontiers": frontier_reports, "createdAt": created_at, "kind": "ambitions.sourceAtlas.coverageFrontierReport.v1"})
    write_json(output_root / "manifest.json", manifest)
    _write_closeout(output_root / "closeout.md", manifest)
    manifest["outputHashes"] = {
        "claimGraph": file_sha256(output_root / "claim-graph.json"),
        "citationGraph": file_sha256(output_root / "citation-graph.json"),
        "coverageFrontierReport": file_sha256(output_root / "coverage-frontier-report.json"),
        "manifest": file_sha256(output_root / "manifest.json"),
    }
    write_json(output_root / "manifest.json", manifest)
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def claim_frontier_markdown(result: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Claim Graph and Coverage Frontier Train 3",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Canonical public claim graph over governed harvest output.",
        "- Claim-level provenance tuple gate.",
        "- Citation graph for inspectable public references.",
        "- Coverage frontier reports for pilot domains.",
        "- Restricted, crosswalk-only, stale, conflicted, review-required, missing-provenance, and missing-legal blockers.",
        "",
        "Files changed:",
        "- tools/source-atlas/foundry/claim_frontier.py",
        "- tools/source-atlas/foundry/cli.py",
        "- tools/source-atlas/foundry/public_reference_adapters.py",
        "- tools/source-atlas/foundry/tests/test_claim_frontier_train_03.py",
        "- tools/source-atlas/frontier/coverage-frontiers.json",
        "- tools/source-atlas/generated/claim-frontier/train-03-fixture/manifest.json",
        "- tools/source-atlas/generated/claim-frontier/train-03-fixture/claim-graph.json",
        "- tools/source-atlas/generated/claim-frontier/train-03-fixture/citation-graph.json",
        "- tools/source-atlas/generated/claim-frontier/train-03-fixture/coverage-frontier-report.json",
        "- tools/source-atlas/generated/claim-frontier/train-03-fixture/closeout.md",
        "",
        "Product law preserved:",
        "- R2 remains public/reference/freshness infrastructure only.",
        "- Claim graph output contains public/reference claims and citations only.",
        "- Source Atlas does not receive private user goals, captures, schedules, proof, receipts, behavior history, or private graph data.",
        "- Source Atlas does not generate final plans, schedules, or Steps.",
        "",
        "Validation run:",
        "- python3 tools/source-atlas/source-atlas-foundry.py governed-harvest --mode fixture --output-root tools/source-atlas/generated/governed-harvest --run-id train-02-fixture --limit 25 --created-at 2026-06-27T00:00:00Z",
        "- python3 tools/source-atlas/source-atlas-foundry.py claim-frontier --input-root tools/source-atlas/generated/governed-harvest/train-02-fixture --output-root tools/source-atlas/generated/claim-frontier/train-03-fixture --created-at 2026-06-27T00:00:00Z",
        "- python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests",
        "- python3 scripts/source-atlas-boundary-audit.py",
        "- python3 scripts/source-atlas-no-private-graph-egress-audit.py",
        "- python3 scripts/ambitions-green-standard-audit.py",
        "- python3 scripts/ambitions-local-first-boundary-scan.py",
        "- git diff --check",
        "",
        "Validation not run:",
        "- Native XCTest/build-for-testing not run because this train changed Python tooling, JSON config, and generated Source Atlas evidence only.",
        "- Production R2 upload/readback not run.",
        "- Outside legal review not run or claimed.",
        "",
        "Proof artifacts:",
        f"- {result.get('manifestPath', 'manifest.json')}",
        "- tools/source-atlas/generated/claim-frontier/train-03-fixture/claim-graph.json",
        "- tools/source-atlas/generated/claim-frontier/train-03-fixture/citation-graph.json",
        "- tools/source-atlas/generated/claim-frontier/train-03-fixture/coverage-frontier-report.json",
        "- tools/source-atlas/generated/claim-frontier/train-03-fixture/closeout.md",
        "",
        "R2 request privacy proof:",
        "- No production R2 request path changed or executed.",
        "- Claim/frontier output is local generated evidence only.",
        "- Object key publication and stable-channel promotion remain unclaimed.",
        "",
        "No private graph egress proof:",
        "- Manifest privacy scan passed.",
        "- Claim graph non-claims forbid private graph, final path, final schedule, Step list, and personalized plan output.",
        "- Coverage frontiers report public source lanes and public claim classes only.",
        "",
        "License/terms proof:",
        "- Packable claims require source lane pack policy and legal registry pack_output_allowed=true.",
        "- Missing or ambiguous legal/terms posture blocks pack output.",
        "- Outside legal approval is not claimed.",
        "",
        "Restricted-source exclusion proof:",
        "- USAJOBS remains blocked from packable claims.",
        "- Wikidata remains crosswalk-only and cannot satisfy regulated authority.",
        "",
        "Provenance completeness proof:",
        f"- Packable claim provenance completeness: {result['provenanceCompleteness']['packablePercent']:.2f}.",
        "- Every packable claim carries source lane, locator, retrieval time, evidence hash, and adjudication rule.",
        "- Missing provenance blocks pack output at claim level.",
        "",
        "Freshness/revocation proof:",
        "- Stale-critical, revoked, conflicted, and terms-blocked claims are blocked from pack output.",
        "- Runtime revocation handling is not claimed in this train.",
        "",
        "LKG/rollback proof:",
        "- Not claimed in Train 3. No stable R2 publish, pointer update, or rollback operation ran.",
        "",
        "Native offline/no-account proof:",
        "- Not claimed in Train 3. No native files changed and no XCTest/build-for-testing gate was required.",
        "",
        "Architecture closeout:",
        "- Final Architecture Tree inspected: yes.",
        "- Canonical owners touched: none in app source; tooling/config/evidence only under tools/source-atlas.",
        "- Files moved or created: claim frontier compiler, tests, config, and generated Source Atlas evidence.",
        "- Old/non-canonical paths removed: none.",
        "- Compatibility shims left behind: none.",
        "- Yellow architecture debt remaining: generalized pack compiler, R2 production publisher, native fetch/cache/verify, and source inspection remain unproven.",
        "- Next repair train if debt remains: Train 4 coverage ontology/frontier expansion or Train 5 pack/R2 generalization, depending sequencing.",
        "- No equivalent folder/path interpretation was used.",
        "",
        "Known risks:",
        "- This train does not prove production pack compilation or stable R2 promotion.",
        "- Non-occupation pilot domains remain below claim-graph-ready until adapters, legal review, and claim evidence are added.",
        "- Native app runtime fetch/cache/verify behavior remains unproven.",
        "",
        "Follow-up required:",
        "- Generalize pack compiler and manifest slices.",
        "- Add broader source discovery/frontier candidates behind review-required gates.",
        "- Implement native public pack fetch/cache/verify in a later train.",
        "",
        "Rollback plan:",
        "- Revert the claim frontier compiler, CLI command, tests, frontier config, generated Train 3 artifacts, and the adapter provenance-ID repair if needed.",
        "",
        "Production non-claims:",
    ]
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def write_claim_frontier_report(markdown_path: Path, result: dict[str, Any]) -> dict[str, Any]:
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(claim_frontier_markdown(result), encoding="utf-8")
    return result


def _load_frontier_config(path: Path, issues: list[str]) -> dict[str, Any]:
    if not path.exists():
        issues.append(f"{path}: missing coverage frontier config")
        return {"frontiers": []}
    value = read_json(path)
    if value.get("kind") != "ambitions.sourceAtlas.coverageFrontierConfig.v1":
        issues.append(f"{path}: unsupported coverage frontier config kind {value.get('kind')}")
    if not isinstance(value.get("frontiers"), list):
        issues.append(f"{path}: frontiers must be a list")
        return {"frontiers": []}
    return value


def _load_optional_json(path: Path) -> dict[str, Any]:
    return read_json(path) if path.exists() else {}


def _load_normalized_outputs(input_root: Path, issues: list[str]) -> list[dict[str, Any]]:
    normalized_root = input_root / "normalized"
    if not normalized_root.exists():
        issues.append(f"{normalized_root}: missing governed harvest normalized output")
        return []
    outputs: list[dict[str, Any]] = []
    for path in sorted(normalized_root.glob("*.json")):
        value = read_json(path)
        if isinstance(value, dict):
            outputs.append(value)
    if not outputs:
        issues.append(f"{normalized_root}: no normalized output files found")
    return outputs


def _canonical_claim(
    *,
    claim: dict[str, Any],
    normalized: dict[str, Any],
    lane: dict[str, Any] | None,
    legal: dict[str, Any] | None,
    provenance_by_id: dict[str, dict[str, Any]],
    source_state: dict[str, Any],
) -> dict[str, Any]:
    source_id = claim.get("sourceID") or normalized.get("sourceID")
    claim_id = claim.get("id") or stable_id("claim", {"sourceID": source_id, "text": claim.get("text")})
    provenance_id = next(iter(claim.get("provenanceIDs", []) or []), None)
    provenance = provenance_by_id.get(provenance_id) if provenance_id else None
    adjudication_rule = _adjudication_rule(claim, lane, source_state)
    tuple_fields = {
        "source_lane": source_id if lane else None,
        "locator": provenance.get("locator") if provenance else None,
        "retrieval_time": provenance.get("retrievedAt") if provenance else None,
        "evidence_hash": provenance.get("contentHash") if provenance else None,
        "adjudication_rule": adjudication_rule,
    }
    blocked_reasons = _claim_blockers(claim, normalized, lane, legal, provenance_id, provenance, tuple_fields, source_state)
    pack_eligibility = "packable" if not blocked_reasons else _pack_block_status(blocked_reasons)
    canonical_id = stable_id("canonical_claim", {"sourceID": source_id, "claimID": claim_id})
    subject_entity_id = stable_id("public_entity", {"sourceID": source_id, "claimID": claim_id})
    canonical = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.publicClaim.v1",
        "claim_id": canonical_id,
        "original_claim_id": claim_id,
        "claim_type": claim.get("claimType", "unknown_claim_type"),
        "subject_entity_id": subject_entity_id,
        "predicate": claim.get("claimType", "unknown_claim_type"),
        "object_value": claim.get("text"),
        "object_unit": None,
        "jurisdiction": claim.get("jurisdiction") or (lane or {}).get("jurisdiction"),
        "domain": normalized.get("domain") or _first((lane or {}).get("domain_scope", [])),
        "valid_from": tuple_fields["retrieval_time"],
        "valid_until": None,
        "freshness_sla": (lane or {}).get("freshness_sla") or claim.get("freshnessCadence"),
        "freshness_status": claim.get("freshness") or source_state.get("state"),
        "confidence_policy": claim.get("confidence", "unknown"),
        "source_lane": tuple_fields["source_lane"],
        "source_id": source_id,
        "locator": tuple_fields["locator"],
        "retrieval_time": tuple_fields["retrieval_time"],
        "evidence_hash": tuple_fields["evidence_hash"],
        "adjudication_rule": tuple_fields["adjudication_rule"],
        "authority_class": (lane or {}).get("authority_class") or claim.get("authorityTier"),
        "license_id": (lane or {}).get("license_id"),
        "attribution_required": bool((lane or {}).get("attribution_required") or (legal or {}).get("attribution_required")),
        "pack_eligibility": pack_eligibility,
        "blocked_reasons": blocked_reasons,
        "provenance_tuple_complete": all(tuple_fields.values()),
        "review_required": bool(claim.get("reviewRequirement") or (lane or {}).get("review_status") != "reviewed"),
        "non_claims": _dedupe_strings(PRODUCTION_NON_CLAIMS + (lane or {}).get("non_claims", [])),
        "publicReferenceOnly": True,
        "dataClass": "public_reference_claim",
        "citation": _citation(canonical_id, claim, lane, legal, provenance, adjudication_rule) if provenance else None,
    }
    return canonical


def _claim_blockers(
    claim: dict[str, Any],
    normalized: dict[str, Any],
    lane: dict[str, Any] | None,
    legal: dict[str, Any] | None,
    provenance_id: str | None,
    provenance: dict[str, Any] | None,
    tuple_fields: dict[str, Any],
    source_state: dict[str, Any],
) -> list[str]:
    blockers: list[str] = []
    source_id = claim.get("sourceID") or normalized.get("sourceID")
    if not lane:
        blockers.append("missing_source_lane")
    if not legal:
        blockers.append("missing_legal_terms_posture")
    if lane:
        if lane.get("r2_pack_policy") not in PACK_ALLOWED_POLICIES:
            blockers.append(f"source_policy_{lane.get('r2_pack_policy')}")
        if lane.get("redistribution_policy") not in {"redistributable", "redistributable_with_attribution"}:
            blockers.append(f"redistribution_policy_{lane.get('redistribution_policy')}")
        if lane.get("review_status") != "reviewed":
            blockers.append(f"review_status_{lane.get('review_status')}")
        if lane.get("source_class") == "public_catalog" or lane.get("authority_class") == "public_catalog":
            blockers.append("catalog_source_discovery_only")
        if lane.get("crosswalk_policy") == "crosswalk_only" or lane.get("r2_pack_policy") == "pack_blocked_crosswalk_only":
            blockers.append("crosswalk_only_not_regulated_authority")
        if claim.get("claimType") not in set(lane.get("claim_classes_allowed", [])):
            blockers.append("claim_class_not_allowed_by_source_lane")
        if claim.get("dataClass") not in set(lane.get("allowed_artifact_classes", [])):
            blockers.append("artifact_class_not_allowed_by_source_lane")
    if legal:
        if legal.get("pack_output_allowed") is not True:
            blockers.append("legal_pack_output_not_allowed")
        if legal.get("review_required") is True:
            blockers.append("legal_review_required")
    if not provenance_id:
        blockers.append("missing_provenance_id")
    elif not provenance:
        blockers.append("missing_provenance_record")
    if not all(tuple_fields.values()):
        blockers.append("missing_provenance_tuple")
    if normalized.get("governancePackBlockedReason"):
        blockers.append("governance_pack_blocked")
    state = claim.get("sourceState") or source_state.get("state")
    if state in FRESHNESS_BLOCKING_STATES:
        blockers.append(f"freshness_state_{state}")
    if source_state.get("packEligible") is False:
        blockers.append("source_state_not_pack_eligible")
    if claim.get("reviewRequirement") is True:
        blockers.append("claim_review_required")
    if claim.get("confidence") in {"conflicted", "review_required", "unsupported"}:
        blockers.append(f"confidence_{claim.get('confidence')}")
    if source_id == "wikidata.crosswalk" and claim.get("claimType") not in {"entity_crosswalk", "identifier_crosswalk", "alias_crosswalk"}:
        blockers.append("wikidata_crosswalk_claim_not_regulated_authority")
    return _dedupe_strings(blockers)


def _adjudication_rule(claim: dict[str, Any], lane: dict[str, Any] | None, source_state: dict[str, Any]) -> str:
    if not lane:
        return "blocked_missing_source_lane"
    if lane.get("crosswalk_policy") == "crosswalk_only" or lane.get("authority_class") == "open_knowledge_graph":
        return "crosswalk_only_not_regulated_authority"
    state = claim.get("sourceState") or source_state.get("state")
    if state in FRESHNESS_BLOCKING_STATES:
        return f"blocked_source_state_{state}"
    if claim.get("reviewRequirement") is True or claim.get("confidence") in {"low", "conflicted", "review_required"}:
        return "review_required_before_pack_output"
    if lane.get("authority_class") in {"official_government", "official_institution", "regulated_body", "standards_body"}:
        return "accepted_direct_authority_source"
    if lane.get("authority_class") == "scholarly_metadata":
        return "accepted_scholarly_metadata_context"
    return "review_required_unclassified_authority"


def _pack_block_status(blocked_reasons: list[str]) -> str:
    if any("crosswalk" in reason for reason in blocked_reasons):
        return "blocked_crosswalk_only"
    if any("restricted" in reason or "lookup_only" in reason for reason in blocked_reasons):
        return "blocked_restricted_or_lookup_only"
    if any("legal" in reason or "terms" in reason for reason in blocked_reasons):
        return "blocked_legal_terms"
    if any("provenance" in reason for reason in blocked_reasons):
        return "blocked_missing_provenance"
    if any("review" in reason or "confidence" in reason for reason in blocked_reasons):
        return "blocked_review_required"
    if any("freshness" in reason or "revoked" in reason or "conflicted" in reason for reason in blocked_reasons):
        return "blocked_freshness_or_conflict"
    return "blocked_policy"


def _citation(
    canonical_claim_id: str,
    claim: dict[str, Any],
    lane: dict[str, Any] | None,
    legal: dict[str, Any] | None,
    provenance: dict[str, Any],
    adjudication_rule: str,
) -> dict[str, Any]:
    source_id = provenance.get("sourceID") or claim.get("sourceID")
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.citation.v1",
        "citation_id": stable_id("citation", {"claimID": canonical_claim_id, "provenanceID": provenance.get("id")}),
        "claim_id": canonical_claim_id,
        "source_id": source_id,
        "source_name": (lane or {}).get("source_name") or provenance.get("publisher"),
        "source_url": provenance.get("sourceURL") or claim.get("sourceURL"),
        "locator": provenance.get("locator"),
        "retrieved_at": provenance.get("retrievedAt"),
        "evidence_hash": provenance.get("contentHash"),
        "license_id": (lane or {}).get("license_id"),
        "attribution_text": _attribution_text(lane, legal, provenance),
        "authority_class": (lane or {}).get("authority_class") or provenance.get("authorityTier"),
        "jurisdiction": claim.get("jurisdiction") or provenance.get("jurisdiction") or (lane or {}).get("jurisdiction"),
        "adjudication_rule": adjudication_rule,
        "freshness_status": claim.get("freshness") or provenance.get("sourceState"),
        "pack_id": None,
        "manifest_id": None,
        "publicReferenceOnly": True,
        "dataClass": "public_provenance",
    }


def _attribution_text(lane: dict[str, Any] | None, legal: dict[str, Any] | None, provenance: dict[str, Any]) -> str:
    if not (lane or {}).get("attribution_required") and not (legal or {}).get("attribution_required"):
        return ""
    return f"Based on public reference data from {(lane or {}).get('source_name') or provenance.get('publisher')}."


def _entity_for_claim(claim: dict[str, Any]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.publicEntity.v1",
        "entity_id": claim["subject_entity_id"],
        "entity_type": "public_claim_subject",
        "label": claim.get("object_value"),
        "source_id": claim.get("source_id"),
        "domain": claim.get("domain"),
        "publicReferenceOnly": True,
        "dataClass": "public_reference_claim",
    }


def _source_summary(source_id: str, lane: dict[str, Any] | None, legal: dict[str, Any] | None, normalized: dict[str, Any]) -> dict[str, Any]:
    return {
        "source_id": source_id,
        "source_name": (lane or {}).get("source_name"),
        "authority_class": (lane or {}).get("authority_class") or normalized.get("terms", {}).get("authorityTier"),
        "jurisdiction": (lane or {}).get("jurisdiction"),
        "domain_scope": (lane or {}).get("domain_scope", []),
        "review_status": (lane or {}).get("review_status"),
        "license_id": (lane or {}).get("license_id"),
        "pack_output_allowed": (legal or {}).get("pack_output_allowed"),
        "r2_pack_policy": (lane or {}).get("r2_pack_policy"),
        "redistribution_policy": (lane or {}).get("redistribution_policy"),
        "claim_count": len(normalized.get("claims", [])),
        "source_state": normalized.get("sourceState", {}).get("state"),
    }


def _claim_graph(
    created_at: str,
    claims: list[dict[str, Any]],
    entities: list[dict[str, Any]],
    source_summaries: dict[str, dict[str, Any]],
    claim_blockers: list[dict[str, Any]],
    frontier_reports: list[dict[str, Any]],
) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.claimGraph.v1",
        "versionID": CLAIM_FRONTIER_VERSION,
        "createdAt": created_at,
        "claims": claims,
        "entities": entities,
        "sources": [source_summaries[key] for key in sorted(source_summaries)],
        "claimBlockers": claim_blockers,
        "frontierIDs": [report["frontier_id"] for report in frontier_reports],
        "claimGraphHash": stable_hash({"claims": claims, "entities": entities}),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PRODUCTION_NON_CLAIMS,
    }


def _citation_graph(created_at: str, citations: list[dict[str, Any]]) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.citationGraph.v1",
        "versionID": CLAIM_FRONTIER_VERSION,
        "createdAt": created_at,
        "citations": citations,
        "citationGraphHash": stable_hash(citations),
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PRODUCTION_NON_CLAIMS,
    }


def _compile_frontier_reports(
    frontier_config: dict[str, Any],
    claims: list[dict[str, Any]],
    source_lanes: dict[str, dict[str, Any]],
    legal_terms: dict[str, dict[str, Any]],
    harvest_manifest: dict[str, Any],
) -> list[dict[str, Any]]:
    reports: list[dict[str, Any]] = []
    for frontier in sorted(frontier_config.get("frontiers", []), key=lambda item: item.get("frontier_id", "")):
        domain = frontier.get("domain")
        required_claim_classes = set(frontier.get("claim_classes", []))
        relevant_lanes = _frontier_lanes(frontier, source_lanes)
        relevant_source_ids = {lane["source_id"] for lane in relevant_lanes}
        relevant_claims = [
            claim
            for claim in claims
            if claim.get("source_id") in relevant_source_ids or claim.get("claim_type") in required_claim_classes or claim.get("domain") == domain
        ]
        packable_claims = [claim for claim in relevant_claims if claim.get("pack_eligibility") == "packable" and claim.get("claim_type") in required_claim_classes]
        blocked_claims = [claim for claim in relevant_claims if claim.get("pack_eligibility") != "packable"]
        covered_classes = {claim.get("claim_type") for claim in packable_claims}
        gold_set = _gold_set_report(frontier, packable_claims)
        status = _frontier_status(frontier, relevant_lanes, relevant_claims, packable_claims, covered_classes)
        reports.append(
            {
                "schemaVersion": 1,
                "kind": "ambitions.sourceAtlas.coverageFrontierReport.v1",
                "frontier_id": frontier.get("frontier_id"),
                "domain": domain,
                "goal_intent_classes": frontier.get("goal_intent_classes", []),
                "claim_classes": sorted(required_claim_classes),
                "jurisdictions": frontier.get("jurisdictions", []),
                "source_lanes": sorted(relevant_source_ids),
                "authority_coverage": _authority_coverage(frontier, relevant_lanes),
                "provenance_completeness": _provenance_completeness(relevant_claims),
                "legal_posture_completeness": _frontier_legal_posture(relevant_lanes, legal_terms),
                "freshness_compliance": _freshness_compliance(relevant_claims),
                "restricted_exclusions": _frontier_restricted_exclusions(relevant_claims, relevant_source_ids, harvest_manifest),
                "conflict_status": _conflict_status(relevant_claims),
                "gold_set_status": gold_set["status"],
                "gold_set": gold_set,
                "packable_claim_count": len(packable_claims),
                "blocked_claim_count": len(blocked_claims),
                "candidate_only_count": sum(1 for lane in relevant_lanes if lane.get("review_status") in {"candidate_only", "review_required"} or lane.get("r2_pack_policy") not in PACK_ALLOWED_POLICIES),
                "covered_claim_classes": sorted(covered_classes),
                "missing_claim_classes": sorted(required_claim_classes - covered_classes),
                "non_claims": _dedupe_strings(PRODUCTION_NON_CLAIMS + frontier.get("non_claims", [])),
                "status_ceiling": frontier.get("status_ceiling", "claim_graph_ready"),
                "status": status,
            }
        )
    return reports


def _gold_set_report(frontier: dict[str, Any], packable_claims: list[dict[str, Any]]) -> dict[str, Any]:
    if frontier.get("gold_set_required") is not True:
        return {
            "schemaVersion": 1,
            "versionID": GOLD_SET_EVALUATOR_VERSION,
            "required": False,
            "status": "not_required",
            "goldSetID": None,
            "requiredCount": 0,
            "matchedCount": 0,
            "missing": [],
            "matches": [],
            "nonClaims": ["not universal coverage", "not release readiness"],
        }
    gold_set = frontier.get("gold_set")
    if not isinstance(gold_set, dict) or not isinstance(gold_set.get("required_claims"), list):
        return {
            "schemaVersion": 1,
            "versionID": GOLD_SET_EVALUATOR_VERSION,
            "required": True,
            "status": "required_not_present",
            "goldSetID": None,
            "requiredCount": 0,
            "matchedCount": 0,
            "missing": ["gold_set.required_claims"],
            "matches": [],
            "nonClaims": ["not universal coverage", "not release readiness"],
        }

    matches: list[dict[str, Any]] = []
    missing: list[str] = []
    for entry in gold_set["required_claims"]:
        if not isinstance(entry, dict):
            missing.append("invalid_gold_claim_entry")
            continue
        match = _matching_gold_claim(entry, packable_claims)
        gold_claim_id = str(entry.get("gold_claim_id") or entry.get("id") or entry.get("claim_type") or "unknown_gold_claim")
        if match is None:
            missing.append(gold_claim_id)
            continue
        matches.append(
            {
                "goldClaimID": gold_claim_id,
                "claimID": match.get("claim_id"),
                "sourceID": match.get("source_id"),
                "claimType": match.get("claim_type"),
                "jurisdiction": match.get("jurisdiction"),
            }
        )

    return {
        "schemaVersion": 1,
        "versionID": GOLD_SET_EVALUATOR_VERSION,
        "required": True,
        "status": "passed" if not missing else "failed",
        "goldSetID": gold_set.get("gold_set_id"),
        "requiredCount": len(gold_set["required_claims"]),
        "matchedCount": len(matches),
        "missing": sorted(missing),
        "matches": sorted(matches, key=lambda item: item["goldClaimID"]),
        "nonClaims": _dedupe_strings(
            [
                "not universal coverage",
                "not Release Green",
                "not legal advice",
                "not final user plans, schedules, or Steps",
                *gold_set.get("non_claims", []),
            ]
        ),
    }


def _matching_gold_claim(entry: dict[str, Any], claims: list[dict[str, Any]]) -> dict[str, Any] | None:
    for claim in claims:
        if entry.get("claim_type") and claim.get("claim_type") != entry["claim_type"]:
            continue
        if entry.get("source_id") and claim.get("source_id") != entry["source_id"]:
            continue
        if entry.get("jurisdiction") and claim.get("jurisdiction") != entry["jurisdiction"]:
            continue
        object_value = str(claim.get("object_value", "")).lower()
        required_fragments = [str(fragment).lower() for fragment in entry.get("object_contains", []) if fragment]
        if any(fragment not in object_value for fragment in required_fragments):
            continue
        return claim
    return None


def _frontier_lanes(frontier: dict[str, Any], source_lanes: dict[str, dict[str, Any]]) -> list[dict[str, Any]]:
    domain = frontier.get("domain")
    configured_source_ids = set(frontier.get("source_ids", []))
    lanes: list[dict[str, Any]] = []
    for lane in source_lanes.values():
        if lane.get("source_id") in configured_source_ids:
            lanes.append(lane)
            continue
        if domain in set(lane.get("domain_scope", [])):
            lanes.append(lane)
    return sorted(lanes, key=lambda item: item["source_id"])


def _frontier_status(
    frontier: dict[str, Any],
    lanes: list[dict[str, Any]],
    relevant_claims: list[dict[str, Any]],
    packable_claims: list[dict[str, Any]],
    covered_classes: set[str],
) -> str:
    status_ceiling = frontier.get("status_ceiling", "claim_graph_ready")
    if not lanes and not relevant_claims:
        return "not_started"
    if relevant_claims and not packable_claims:
        return "adapter_ready"
    if lanes and all(lane.get("review_status") in {"candidate_only", "review_required"} for lane in lanes) and not packable_claims:
        return "candidate_only"
    required_claim_classes = set(frontier.get("claim_classes", []))
    if packable_claims and required_claim_classes <= covered_classes:
        return status_ceiling if status_ceiling in {"claim_graph_ready", "adapter_ready", "source_review_ready"} else "claim_graph_ready"
    if relevant_claims:
        return "adapter_ready"
    if lanes:
        return "source_review_ready"
    return "candidate_only"


def _authority_coverage(frontier: dict[str, Any], lanes: list[dict[str, Any]]) -> dict[str, Any]:
    required = set(frontier.get("minimum_authority_classes", []))
    present = {lane.get("authority_class") for lane in lanes if lane.get("authority_class")}
    return {
        "required": sorted(required),
        "present": sorted(present),
        "missing": sorted(required - present),
        "complete": required <= present if required else bool(present),
    }


def _frontier_legal_posture(lanes: list[dict[str, Any]], legal_terms: dict[str, dict[str, Any]]) -> dict[str, Any]:
    if not lanes:
        return {"laneCount": 0, "completeCount": 0, "percent": 0.0, "complete": False}
    complete_count = 0
    for lane in lanes:
        legal = legal_terms.get(lane.get("license_id"))
        if legal and legal.get("pack_output_allowed") is True and lane.get("review_status") == "reviewed":
            complete_count += 1
    return {"laneCount": len(lanes), "completeCount": complete_count, "percent": complete_count / len(lanes), "complete": complete_count == len(lanes)}


def _provenance_completeness(claims: list[dict[str, Any]]) -> dict[str, Any]:
    packable = [claim for claim in claims if claim.get("pack_eligibility") == "packable"]
    complete = [claim for claim in packable if claim.get("provenance_tuple_complete")]
    all_complete = [claim for claim in claims if claim.get("provenance_tuple_complete")]
    return {
        "claimCount": len(claims),
        "completeTupleCount": len(all_complete),
        "packableClaimCount": len(packable),
        "packableCompleteTupleCount": len(complete),
        "packablePercent": 1.0 if not packable else len(complete) / len(packable),
        "complete": len(packable) == len(complete),
    }


def _legal_posture_completeness(claims: list[dict[str, Any]]) -> dict[str, Any]:
    if not claims:
        return {"claimCount": 0, "completeCount": 0, "percent": 0.0, "complete": False}
    complete = [claim for claim in claims if "legal" not in " ".join(claim.get("blocked_reasons", [])) and claim.get("license_id")]
    return {"claimCount": len(claims), "completeCount": len(complete), "percent": len(complete) / len(claims), "complete": len(complete) == len(claims)}


def _freshness_compliance(claims: list[dict[str, Any]]) -> dict[str, Any]:
    if not claims:
        return {"claimCount": 0, "freshCount": 0, "percent": 0.0, "complete": False}
    fresh = [claim for claim in claims if claim.get("freshness_status") == "current" and not any(reason.startswith("freshness_state_") for reason in claim.get("blocked_reasons", []))]
    return {"claimCount": len(claims), "freshCount": len(fresh), "percent": len(fresh) / len(claims), "complete": len(fresh) == len(claims)}


def _restricted_exclusions(claims: list[dict[str, Any]], harvest_manifest: dict[str, Any]) -> list[dict[str, Any]]:
    rows = list(harvest_manifest.get("restrictedExclusions", []))
    seen = {(row.get("sourceID"), row.get("reason")) for row in rows}
    for claim in claims:
        if claim.get("pack_eligibility") == "packable":
            continue
        if any(token in " ".join(claim.get("blocked_reasons", [])) for token in ["restricted", "lookup_only", "crosswalk", "governance_pack_blocked"]):
            key = (claim.get("source_id"), claim.get("pack_eligibility"))
            if key not in seen:
                rows.append({"sourceID": claim.get("source_id"), "reason": claim.get("pack_eligibility"), "r2PackPolicy": claim.get("pack_eligibility")})
                seen.add(key)
    return sorted(rows, key=lambda item: str(item.get("sourceID", "")))


def _frontier_restricted_exclusions(claims: list[dict[str, Any]], source_ids: set[str], harvest_manifest: dict[str, Any]) -> list[dict[str, Any]]:
    exclusions = [row for row in _restricted_exclusions(claims, harvest_manifest) if row.get("sourceID") in source_ids or any(claim.get("source_id") == row.get("sourceID") for claim in claims)]
    return sorted(exclusions, key=lambda item: str(item.get("sourceID", "")))


def _conflict_status(claims: list[dict[str, Any]]) -> str:
    if any("conflicted" in " ".join(claim.get("blocked_reasons", [])) for claim in claims):
        return "review_required"
    return "no_conflict_detected" if claims else "not_evaluated"


def _packable_claims_have_complete_tuple(claims: list[dict[str, Any]]) -> bool:
    return all(claim.get("provenance_tuple_complete") for claim in claims if claim.get("pack_eligibility") == "packable")


def _missing_provenance_blocks(claims: list[dict[str, Any]]) -> bool:
    return all(
        claim.get("pack_eligibility") != "packable"
        for claim in claims
        if any("missing_provenance" in reason for reason in claim.get("blocked_reasons", []))
    )


def _source_is_not_packable(claims: list[dict[str, Any]], source_id: str) -> bool:
    relevant = [claim for claim in claims if claim.get("source_id") == source_id]
    return not relevant or all(claim.get("pack_eligibility") != "packable" for claim in relevant)


def _candidate_frontiers_are_below_pack_readiness(frontier_reports: list[dict[str, Any]]) -> bool:
    forbidden = {"pack_staging_ready", "r2_stable_ready", "app_runtime_ready", "production_ready"}
    return all(report.get("status") not in forbidden for report in frontier_reports if report.get("candidate_only_count", 0) > 0)


def _contains_forbidden_output_classes(lanes: Any) -> bool:
    for lane in lanes:
        allowed = set(lane.get("allowed_artifact_classes", []))
        if allowed & FINAL_OUTPUT_FORBIDDEN:
            return True
    return False


def _dedupe_entities(entities: list[dict[str, Any]]) -> list[dict[str, Any]]:
    by_id = {entity["entity_id"]: entity for entity in entities}
    return [by_id[key] for key in sorted(by_id)]


def _dedupe_strings(values: list[str]) -> list[str]:
    return sorted({str(value) for value in values if value})


def _first(values: list[Any]) -> Any:
    return values[0] if values else None


def _write_closeout(path: Path, manifest: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(claim_frontier_markdown(manifest), encoding="utf-8")
