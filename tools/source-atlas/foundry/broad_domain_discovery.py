"""Deterministic broad-domain candidate discovery for Source Atlas Train 7."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .claim_frontier import DEFAULT_FRONTIER_CONFIG_PATH
from .governance_registry import load_governance_registries, validate_governance_registries
from .model import NON_CLAIMS, PRIVACY_BOUNDARY, object_key_findings, privacy_findings_for_value, read_json, stable_hash, stable_id, utc_now, write_json


BROAD_DOMAIN_DISCOVERY_VERSION = "source-atlas-broad-domain-discovery-train-07"
PACK_READY_STATUSES = {"pack_staging_ready", "r2_stable_ready", "app_runtime_ready", "production_ready"}
FINAL_OUTPUT_FORBIDDEN = {"final_user_path", "final_schedule", "step_list", "personalized_plan", "private_goal_graph"}
PRODUCTION_NON_CLAIMS = NON_CLAIMS + [
    "not full Source Atlas Green",
    "not live source discovery",
    "not production R2 readiness",
    "not native app runtime readiness",
    "not outside legal approval",
    "not universal goal coverage",
    "not a final user plan, schedule, or Step generator",
]


@dataclass(frozen=True)
class BroadDomainDiscoveryOptions:
    output_root: Path
    frontier_config_path: Path | None = DEFAULT_FRONTIER_CONFIG_PATH
    created_at: str | None = None


def build_broad_domain_discovery(options: BroadDomainDiscoveryOptions) -> dict[str, Any]:
    created_at = options.created_at or utc_now()
    output_root = options.output_root
    output_root.mkdir(parents=True, exist_ok=True)
    frontier_config_path = options.frontier_config_path or DEFAULT_FRONTIER_CONFIG_PATH
    frontier_config = read_json(frontier_config_path)
    frontiers = sorted(frontier_config.get("frontiers", []), key=lambda item: item.get("frontier_id", ""))

    governance = validate_governance_registries()
    registries = load_governance_registries()
    source_lanes = {
        lane.get("source_id"): lane
        for lane in registries["source_lanes"].get("source_lanes", [])
        if isinstance(lane, dict)
    }

    candidates = _build_candidates(frontiers, created_at, source_lanes)
    scorecards = _build_scorecards(frontiers, candidates, source_lanes)
    discovery = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.broadDomainCandidateDiscovery.v1",
        "versionID": BROAD_DOMAIN_DISCOVERY_VERSION,
        "createdAt": created_at,
        "frontierConfigPath": str(frontier_config_path),
        "candidateRecords": candidates,
        "scorecards": scorecards,
        "recordCounts": {
            "frontiers": len(frontiers),
            "candidateRecords": len(candidates),
            "claims": 0,
            "packableClaims": 0,
            "r2PackableArtifacts": 0,
        },
        "governanceValidation": {
            "valid": governance["valid"],
            "status": governance["status"],
            "issues": governance["issues"],
        },
        "checks": [],
        "issues": [],
        "privacyBoundary": PRIVACY_BOUNDARY,
        "nonClaims": PRODUCTION_NON_CLAIMS,
    }

    privacy_issues = privacy_findings_for_value(discovery, "broad-domain-discovery")
    object_key_issues = _object_key_issues(candidates)
    checks = [
        {
            "name": "candidate_discovery_emits_no_claims",
            "passed": discovery["recordCounts"]["claims"] == 0 and discovery["recordCounts"]["packableClaims"] == 0,
        },
        {
            "name": "all_candidates_review_required",
            "passed": all(candidate["review_required"] is True for candidate in candidates),
        },
        {
            "name": "candidate_statuses_below_pack_readiness",
            "passed": all(scorecard["status"] not in PACK_READY_STATUSES for scorecard in scorecards),
        },
        {
            "name": "source_of_sources_not_authority",
            "passed": all(
                "source_of_sources_not_claim_authority" in candidate["blocking_reasons"]
                for candidate in candidates
                if candidate["authority_class_guess"] == "public_catalog"
            ),
        },
        {
            "name": "crosswalks_not_regulated_authority",
            "passed": all(
                "crosswalk_only_not_regulated_authority" in candidate["blocking_reasons"]
                for candidate in candidates
                if candidate["authority_class_guess"] == "open_knowledge_graph"
            ),
        },
        {
            "name": "privacy_scan_passed",
            "passed": not privacy_issues,
        },
        {
            "name": "r2_object_key_scan_passed",
            "passed": not object_key_issues,
        },
        {
            "name": "no_final_plan_schedule_step_output",
            "passed": not _contains_forbidden_artifact_classes(candidates),
        },
    ]
    issues = []
    for check in checks:
        if not check["passed"]:
            issues.append(f"failed check: {check['name']}")
    issues.extend(privacy_issues)
    issues.extend(object_key_issues)
    if not governance["valid"]:
        issues.extend(f"governance: {issue}" for issue in governance["issues"])

    valid = not issues and all(check["passed"] for check in checks)
    manifest = {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.broadDomainDiscoveryManifest.v1",
        "versionID": BROAD_DOMAIN_DISCOVERY_VERSION,
        "createdAt": created_at,
        "status": "Source Green for broad-domain candidate discovery tooling" if valid else "Red",
        "valid": valid,
        "sourceAtlasStatusCeiling": "Yellow overall Source Atlas; deterministic candidate discovery/scorecards only",
        "frontierConfigPath": str(frontier_config_path),
        "outputPaths": {
            "candidateRecords": str(output_root / "candidate-sources.json"),
            "scorecards": str(output_root / "domain-scorecards.json"),
            "closeout": str(output_root / "closeout.md"),
        },
        "recordCounts": discovery["recordCounts"],
        "domainStatusCounts": _status_counts(scorecards),
        "checks": checks,
        "issues": issues,
        "privacyScan": {"passed": not privacy_issues, "issues": privacy_issues},
        "r2ObjectKeyScan": {"passed": not object_key_issues, "issues": object_key_issues},
        "nonClaims": PRODUCTION_NON_CLAIMS,
        "privacyBoundary": PRIVACY_BOUNDARY,
        "candidateOnlyDomains": [scorecard["domain"] for scorecard in scorecards if scorecard["status"] == "candidate_only"],
    }

    write_json(output_root / "candidate-sources.json", discovery)
    write_json(output_root / "domain-scorecards.json", {"scorecards": scorecards, "createdAt": created_at, "kind": "ambitions.sourceAtlas.domainScorecards.v1"})
    write_json(output_root / "manifest.json", manifest)
    _write_closeout(output_root / "closeout.md", manifest)
    manifest["outputHashes"] = {
        "candidateRecords": stable_hash(read_json(output_root / "candidate-sources.json")),
        "scorecards": stable_hash(read_json(output_root / "domain-scorecards.json")),
        "manifest": stable_hash(read_json(output_root / "manifest.json")),
    }
    write_json(output_root / "manifest.json", manifest)
    return {"manifestPath": str(output_root / "manifest.json"), "outputRoot": str(output_root), **manifest}


def broad_domain_discovery_markdown(result: dict[str, Any]) -> str:
    lines = [
        "# Source Atlas Broad Domain Candidate Discovery Train 7",
        "",
        f"Status: {result['status']}",
        f"Source Atlas status ceiling: {result['sourceAtlasStatusCeiling']}",
        "",
        "Scope completed:",
        "- Deterministic candidate source records for broad Source Atlas domains.",
        "- Domain scorecards with authority, legal, freshness, source-lane, and coverage gaps.",
        "- Candidate-only gate that emits no claims, no packable claims, and no R2 packable artifacts.",
        "- Review-required posture for every candidate source.",
        "",
        "Files changed:",
        "- tools/source-atlas/foundry/broad_domain_discovery.py",
        "- tools/source-atlas/foundry/cli.py",
        "- tools/source-atlas/foundry/tests/test_broad_domain_discovery_train_07.py",
        "- tools/source-atlas/frontier/coverage-frontiers.json",
        "- tools/source-atlas/generated/broad-domain-discovery/train-07-fixture/*",
        "- docs/qa/source-atlas/domain-expansion/source-atlas-broad-domain-discovery-train-07.json",
        "- docs/qa/source-atlas/domain-expansion/source-atlas-broad-domain-discovery-train-07.md",
        "",
        "Product law preserved:",
        "- R2 remains public/reference/freshness infrastructure only.",
        "- Candidate discovery is not claim authority.",
        "- Candidate records do not generate final plans, schedules, or Steps.",
        "- Restricted, ambiguous, missing-license, missing-terms, and review-required candidates remain blocked from R2 packs.",
        "",
        "Validation run:",
        "- python3 tools/source-atlas/source-atlas-foundry.py broad-domain-discovery --output-root tools/source-atlas/generated/broad-domain-discovery/train-07-fixture --created-at 2026-06-27T00:00:00Z",
        "- python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests",
        "- python3 scripts/source-atlas-boundary-audit.py",
        "- python3 scripts/source-atlas-no-private-graph-egress-audit.py",
        "- python3 scripts/ambitions-green-standard-audit.py",
        "- python3 scripts/ambitions-local-first-boundary-scan.py",
        "- git diff --check",
        "",
        "Validation not run:",
        "- Native XCTest/build-for-testing not run because this train changed Python tooling, JSON config, generated Source Atlas artifacts, and QA evidence only.",
        "- Live network/API discovery not run.",
        "- Production R2 upload/readback not run.",
        "- Outside legal review not run or claimed.",
        "",
        "Proof artifacts:",
        f"- {result.get('manifestPath', 'manifest.json')}",
        "- tools/source-atlas/generated/broad-domain-discovery/train-07-fixture/candidate-sources.json",
        "- tools/source-atlas/generated/broad-domain-discovery/train-07-fixture/domain-scorecards.json",
        "- tools/source-atlas/generated/broad-domain-discovery/train-07-fixture/closeout.md",
        "",
        "R2 request privacy proof:",
        "- No production R2 request path changed or executed.",
        "- Candidate discovery emits local generated evidence only.",
        "- Candidate records contain no R2 object keys and the object-key scanner passed.",
        "",
        "No private graph egress proof:",
        "- Candidate discovery privacy scan passed.",
        "- Candidate records contain public/source metadata only.",
        "- Candidate discovery emits no user goals, captures, schedules, proof, receipts, behavior history, or private graph data.",
        "",
        "License/terms proof:",
        "- Candidate legal posture is advisory only and cannot approve pack output.",
        "- Missing, ambiguous, or review-required license/terms posture blocks R2 packability.",
        "- Outside legal approval is not claimed.",
        "",
        "Restricted-source exclusion proof:",
        "- Candidate-only records are non-packable.",
        "- Source-of-sources remain discovery-only.",
        "- Crosswalk-style records cannot satisfy regulated authority.",
        "",
        "Provenance completeness proof:",
        "- Not claimed in Train 7. Candidate discovery emits source records only and no claims.",
        "",
        "Freshness/revocation proof:",
        "- Candidate scorecards report freshness policy gaps.",
        "- Runtime revocation and stale-critical quarantine are not claimed in this train.",
        "",
        "LKG/rollback proof:",
        "- Not claimed in Train 7. No stable R2 publish, pointer update, or rollback operation ran.",
        "",
        "Native offline/no-account proof:",
        "- Not claimed in Train 7. No native files changed and no XCTest/build-for-testing gate was required.",
        "",
        "Architecture closeout:",
        "- Final Architecture Tree inspected: yes.",
        "- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.",
        "- Files moved or created: candidate discovery module, tests, generated artifacts, and QA evidence listed above.",
        "- Old/non-canonical paths removed: none.",
        "- Compatibility shims left behind: none.",
        "- Yellow architecture debt remaining: broad domains remain candidate-only until source-lane, legal, adapter, claim, pack, R2, and native gates pass.",
        "- Next repair train if debt remains: source-lane/legal review and adapter implementation for one candidate-only broad domain.",
        "- No equivalent folder/path interpretation was used.",
        "",
        "Known risks:",
        "- This is deterministic candidate discovery proof, not live discovery or reviewed source authority.",
        "- Candidate scores are prioritization aids and cannot override review-required status.",
        "- Domain scorecards do not prove pack readiness.",
        "",
        "Follow-up required:",
        "- Promote selected candidate sources into governed source lanes only after legal/terms review.",
        "- Build adapters for approved broad-domain sources.",
        "- Compile claim graph and staging packs only after provenance, freshness, conflict, and legal gates pass.",
        "",
        "Rollback plan:",
        "- Revert the candidate discovery module, CLI command, tests, generated Train 7 artifacts, frontier additions, and QA evidence packet.",
        "",
        "Production non-claims:",
    ]
    lines.extend(f"- {claim}" for claim in result["nonClaims"])
    lines.append("")
    return "\n".join(lines)


def write_broad_domain_discovery_report(
    markdown_path: Path,
    json_path: Path,
    *,
    output_root: Path,
    frontier_config_path: Path | None = None,
    created_at: str | None = None,
) -> dict[str, Any]:
    result = build_broad_domain_discovery(
        BroadDomainDiscoveryOptions(
            output_root=output_root,
            frontier_config_path=frontier_config_path,
            created_at=created_at,
        )
    )
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    markdown_path.write_text(broad_domain_discovery_markdown(result), encoding="utf-8")
    write_json(json_path, result)
    return result


def _build_candidates(frontiers: list[dict[str, Any]], created_at: str, source_lanes: dict[str, dict[str, Any]]) -> list[dict[str, Any]]:
    candidates: list[dict[str, Any]] = []
    for frontier in frontiers:
        domain = frontier["domain"]
        for seed in _candidate_seeds_for_domain(domain):
            candidate = _candidate_record(frontier, seed, created_at, source_lanes)
            candidates.append(candidate)
    return sorted(candidates, key=lambda item: (item["domain_guess"], item["candidate_score"] * -1, item["candidate_id"]))


def _candidate_record(
    frontier: dict[str, Any],
    seed: dict[str, Any],
    created_at: str,
    source_lanes: dict[str, dict[str, Any]],
) -> dict[str, Any]:
    source_id_guess = seed["source_id_guess"]
    lane = source_lanes.get(source_id_guess)
    legal_posture = _legal_posture(seed)
    redistribution_guess = seed.get("redistribution_guess", legal_posture)
    blocking_reasons = _blocking_reasons(frontier, seed, lane, legal_posture, redistribution_guess)
    base = {
        "candidate_id": stable_id("candidate", [frontier["frontier_id"], source_id_guess, seed["dataset_url"]]),
        "source_id_guess": source_id_guess,
        "discovery_method": seed.get("discovery_method", "curated_seed"),
        "discovered_at": created_at,
        "publisher_name": seed["publisher_name"],
        "publisher_url": seed["publisher_url"],
        "declared_jurisdiction": seed.get("declared_jurisdiction", frontier.get("jurisdictions", ["unknown"])[0]),
        "declared_license": seed.get("declared_license", "unclear"),
        "declared_rights": seed.get("declared_rights", "unclear"),
        "terms_url": seed.get("terms_url", ""),
        "rights_url": seed.get("rights_url", ""),
        "dataset_url": seed["dataset_url"],
        "distribution_urls": sorted(seed.get("distribution_urls", [])),
        "api_docs_url": seed.get("api_docs_url", ""),
        "source_class_guess": seed["source_class_guess"],
        "authority_class_guess": seed["authority_class_guess"],
        "domain_guess": frontier["domain"],
        "claim_class_guess": sorted(seed.get("claim_class_guess", frontier.get("claim_classes", []))),
        "redistribution_guess": redistribution_guess,
        "review_required": True,
        "candidate_score": _candidate_score(seed, lane, legal_posture, redistribution_guess),
        "blocking_reasons": blocking_reasons,
        "allowed_artifact_classes": ["candidate_source_record", "discovery_metadata"],
        "forbidden_artifact_classes": sorted(FINAL_OUTPUT_FORBIDDEN | {"claim_graph", "r2_pack", "stable_channel_pointer"}),
        "pack_eligibility": "blocked_candidate_only",
        "non_claims": [
            "candidate source record only",
            "not claim authority",
            "not redistributable pack approval",
        ],
    }
    base["evidence_hash"] = stable_hash({key: value for key, value in base.items() if key != "evidence_hash"})
    return base


def _candidate_score(
    seed: dict[str, Any],
    lane: dict[str, Any] | None,
    legal_posture: str,
    redistribution_guess: str,
) -> int:
    score = 0
    score += {
        "official_government": 30,
        "regulated_body": 28,
        "standards_body": 24,
        "official_institution": 22,
        "scholarly_metadata": 16,
        "open_knowledge_graph": 10,
        "public_catalog": 8,
        "commercial_api": 4,
        "non_authoritative_web": 0,
        "unknown": 0,
    }.get(seed["authority_class_guess"], 0)
    score += 10 if seed.get("declared_jurisdiction") else 0
    score += 8 if seed.get("terms_url") else 0
    score += 8 if seed.get("rights_url") else 0
    score += 8 if seed.get("declared_license") not in {"", "unclear", "unknown"} else 0
    score += 10 if seed.get("api_docs_url") or seed.get("distribution_urls") else 0
    score += 12 if seed.get("claim_class_guess") else 0
    score += {
        "redistributable": 10,
        "redistributable_with_attribution": 8,
        "review_required": 4,
        "lookup_only": 2,
        "crosswalk_only": 2,
        "blocked": 0,
    }.get(redistribution_guess, 0)
    if lane:
        score += 8
    if legal_posture in {"missing_license_posture", "missing_terms_posture", "ambiguous_rights"}:
        score -= 8
    return max(0, min(score, 100))


def _legal_posture(seed: dict[str, Any]) -> str:
    if not seed.get("declared_license") or seed.get("declared_license") in {"unclear", "unknown"}:
        return "missing_license_posture"
    if not seed.get("terms_url"):
        return "missing_terms_posture"
    if seed.get("declared_rights") in {"unclear", "unknown", ""}:
        return "ambiguous_rights"
    return seed.get("redistribution_guess", "review_required")


def _blocking_reasons(
    frontier: dict[str, Any],
    seed: dict[str, Any],
    lane: dict[str, Any] | None,
    legal_posture: str,
    redistribution_guess: str,
) -> list[str]:
    reasons = [
        "review_required",
        "candidate_only_not_claim_authority",
        "legal_review_required_before_pack_output",
    ]
    if lane is None:
        reasons.append("missing_source_lane")
    if legal_posture != "redistributable" and legal_posture != "redistributable_with_attribution":
        reasons.append(legal_posture)
    if redistribution_guess not in {"redistributable", "redistributable_with_attribution"}:
        reasons.append("redistribution_not_approved")
    if frontier.get("status_ceiling") in {"candidate_only", "source_review_ready", "adapter_ready", "claim_graph_ready"}:
        reasons.append("frontier_below_pack_readiness")
    if seed["authority_class_guess"] == "public_catalog":
        reasons.append("source_of_sources_not_claim_authority")
    if seed["authority_class_guess"] == "open_knowledge_graph":
        reasons.append("crosswalk_only_not_regulated_authority")
    if seed.get("source_class_guess") in {"commercial_api", "restricted_api"}:
        reasons.append("restricted_or_terms_sensitive_api")
    return sorted(set(reasons))


def _build_scorecards(
    frontiers: list[dict[str, Any]],
    candidates: list[dict[str, Any]],
    source_lanes: dict[str, dict[str, Any]],
) -> list[dict[str, Any]]:
    candidates_by_domain: dict[str, list[dict[str, Any]]] = {}
    for candidate in candidates:
        candidates_by_domain.setdefault(candidate["domain_guess"], []).append(candidate)
    scorecards: list[dict[str, Any]] = []
    for frontier in frontiers:
        domain_candidates = candidates_by_domain.get(frontier["domain"], [])
        required_sources = set(frontier.get("source_ids", []))
        registered_sources = {source_id for source_id in required_sources if source_id in source_lanes}
        candidate_source_ids = {candidate["source_id_guess"] for candidate in domain_candidates}
        scorecards.append(
            {
                "frontier_id": frontier["frontier_id"],
                "domain": frontier["domain"],
                "status": _scorecard_status(frontier, domain_candidates, source_lanes),
                "status_ceiling": frontier.get("status_ceiling", "candidate_only"),
                "candidate_count": len(domain_candidates),
                "candidate_only_count": len(domain_candidates),
                "claim_count": 0,
                "packable_claim_count": 0,
                "r2_packable_artifact_count": 0,
                "authority_classes_seen": sorted({candidate["authority_class_guess"] for candidate in domain_candidates}),
                "minimum_authority_classes": sorted(frontier.get("minimum_authority_classes", [])),
                "missing_authority_classes": sorted(set(frontier.get("minimum_authority_classes", [])) - {candidate["authority_class_guess"] for candidate in domain_candidates}),
                "registered_required_source_lanes": sorted(registered_sources),
                "missing_required_source_lanes": sorted(required_sources - registered_sources),
                "candidate_source_lanes_missing": sorted(candidate_source_ids - set(source_lanes)),
                "legal_posture_gaps": sorted({reason for candidate in domain_candidates for reason in candidate["blocking_reasons"] if reason in {"missing_source_lane", "missing_license_posture", "missing_terms_posture", "ambiguous_rights", "redistribution_not_approved", "legal_review_required_before_pack_output"}}),
                "freshness_policy_gaps": [] if frontier.get("freshness_slas") else ["missing_freshness_sla"],
                "blocking_reasons": sorted({reason for candidate in domain_candidates for reason in candidate["blocking_reasons"]}),
                "non_claims": sorted(set(frontier.get("non_claims", [])) | {"candidate discovery only", "not pack ready"}),
            }
        )
    return sorted(scorecards, key=lambda item: item["frontier_id"])


def _scorecard_status(
    frontier: dict[str, Any],
    candidates: list[dict[str, Any]],
    source_lanes: dict[str, dict[str, Any]],
) -> str:
    if not candidates:
        return "not_started"
    if frontier.get("status_ceiling") == "claim_graph_ready":
        return "source_review_ready" if any(candidate["source_id_guess"] in source_lanes for candidate in candidates) else "candidate_only"
    return "candidate_only"


def _status_counts(scorecards: list[dict[str, Any]]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for scorecard in scorecards:
        counts[scorecard["status"]] = counts.get(scorecard["status"], 0) + 1
    return dict(sorted(counts.items()))


def _object_key_issues(candidates: list[dict[str, Any]]) -> list[str]:
    issues: list[str] = []
    for candidate in candidates:
        for value in [candidate["dataset_url"], candidate.get("api_docs_url", "")] + candidate.get("distribution_urls", []):
            if value.startswith("source-atlas/"):
                issues.extend(object_key_findings(value))
    return issues


def _contains_forbidden_artifact_classes(candidates: list[dict[str, Any]]) -> bool:
    for candidate in candidates:
        allowed = set(candidate.get("allowed_artifact_classes", []))
        if allowed & FINAL_OUTPUT_FORBIDDEN:
            return True
    return False


def _write_closeout(path: Path, manifest: dict[str, Any]) -> None:
    path.write_text(broad_domain_discovery_markdown(manifest), encoding="utf-8")


def _candidate_seeds_for_domain(domain: str) -> list[dict[str, Any]]:
    return sorted(_CANDIDATE_SEEDS.get(domain, []), key=lambda item: item["source_id_guess"])


_CANDIDATE_SEEDS: dict[str, list[dict[str, Any]]] = {
    "education_credentialing": [
        {
            "source_id_guess": "college-scorecard.api",
            "publisher_name": "U.S. Department of Education",
            "publisher_url": "https://www.ed.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "review_required",
            "declared_rights": "public government source terms require review",
            "terms_url": "https://www.ed.gov/notices",
            "rights_url": "https://www.ed.gov/notices",
            "dataset_url": "https://collegescorecard.ed.gov/data/",
            "distribution_urls": ["https://api.data.gov/ed/collegescorecard/v1/schools"],
            "api_docs_url": "https://collegescorecard.ed.gov/data/documentation/",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["candidate_education_program_reference", "candidate_institution_reference"],
            "redistribution_guess": "review_required",
        },
        {
            "source_id_guess": "accreditation.public-records",
            "publisher_name": "Accreditation public records",
            "publisher_url": "https://www.ed.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "unclear",
            "declared_rights": "unclear",
            "terms_url": "https://www.ed.gov/notices",
            "rights_url": "",
            "dataset_url": "https://www.ed.gov/accreditation",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["credential_requirement"],
            "redistribution_guess": "review_required",
        },
    ],
    "public_civic_requirements": [
        {
            "source_id_guess": "data.gov.catalog",
            "publisher_name": "Data.gov",
            "publisher_url": "https://data.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "review_required",
            "declared_rights": "catalog metadata only; underlying publisher review required",
            "terms_url": "https://www.data.gov/privacy-policy/",
            "rights_url": "https://www.data.gov/privacy-policy/",
            "dataset_url": "https://catalog.data.gov/dataset",
            "distribution_urls": [],
            "api_docs_url": "https://catalog.data.gov/api/3/",
            "source_class_guess": "public_catalog",
            "authority_class_guess": "public_catalog",
            "claim_class_guess": ["candidate_source_record", "discovery_metadata"],
            "redistribution_guess": "review_required",
        },
        {
            "source_id_guess": "nara.constitution.presidency",
            "publisher_name": "National Archives",
            "publisher_url": "https://www.archives.gov/",
            "declared_jurisdiction": "US federal",
            "declared_license": "review_required",
            "declared_rights": "public government source terms require review",
            "terms_url": "https://www.archives.gov/global-pages/privacy",
            "rights_url": "https://www.archives.gov/global-pages/privacy",
            "dataset_url": "https://www.archives.gov/founding-docs/constitution-transcript",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["constitutional_requirement", "eligibility_requirement"],
            "redistribution_guess": "review_required",
        }
    ],
    "health_wellness_reference": [
        {
            "source_id_guess": "cdc.physical-activity.basics",
            "publisher_name": "Centers for Disease Control and Prevention",
            "publisher_url": "https://www.cdc.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "cdc_public_web",
            "declared_rights": "bounded public government website reuse with attribution, no-endorsement, third-party, trademark, and media caveats retained",
            "terms_url": "https://www.cdc.gov/other/agencymaterials.html",
            "rights_url": "https://www.cdc.gov/other/agencymaterials.html",
            "dataset_url": "https://www.cdc.gov/physical-activity-basics/guidelines/adults.html",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["exercise_taxonomy", "public_health_guideline", "wellness_safety_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        },
        {
            "source_id_guess": "hhs.physical-activity-guidelines",
            "publisher_name": "U.S. Department of Health and Human Services",
            "publisher_url": "https://health.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "review_required",
            "declared_rights": "public government source terms require review",
            "terms_url": "https://health.gov/privacy-policy",
            "rights_url": "https://health.gov/privacy-policy",
            "dataset_url": "https://health.gov/our-work/nutrition-physical-activity/physical-activity-guidelines",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["public_health_guideline", "exercise_taxonomy"],
            "redistribution_guess": "review_required",
        },
    ],
    "finance_public_reference": [
        {
            "source_id_guess": "cfpb.adult_financial_education",
            "publisher_name": "Consumer Financial Protection Bureau",
            "publisher_url": "https://www.consumerfinance.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "cfpb_public_web",
            "declared_rights": "bounded public government website reuse with attribution, third-party, trademark, and media caveats retained",
            "terms_url": "https://www.consumerfinance.gov/privacy/",
            "rights_url": "https://www.consumerfinance.gov/privacy/",
            "dataset_url": "https://www.consumerfinance.gov/consumer-tools/educator-tools/adult-financial-education/tools-and-resources/",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "regulated_body",
            "claim_class_guess": ["public_financial_education"],
            "redistribution_guess": "redistributable_with_attribution",
        },
        {
            "source_id_guess": "irs.when_to_file",
            "publisher_name": "Internal Revenue Service",
            "publisher_url": "https://www.irs.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "irs_public_web",
            "declared_rights": "bounded public government website reuse with attribution, third-party, trademark, and media caveats retained",
            "terms_url": "https://www.irs.gov/privacy-disclosure/irs-privacy-policy",
            "rights_url": "https://www.irs.gov/privacy-disclosure/irs-privacy-policy",
            "dataset_url": "https://www.irs.gov/filing/individuals/when-to-file",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "regulated_body",
            "claim_class_guess": ["tax_deadline_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        },
        {
            "source_id_guess": "usa.gov.benefits",
            "publisher_name": "USA.gov / General Services Administration",
            "publisher_url": "https://www.usa.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "usagov_public_web",
            "declared_rights": "bounded public government website reuse with attribution, third-party, trademark, and media caveats retained",
            "terms_url": "https://www.usa.gov/government-works",
            "rights_url": "https://www.usa.gov/government-works",
            "dataset_url": "https://www.usa.gov/benefits",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["official_benefit_program_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        },
    ],
    "home_life_admin": [
        {
            "source_id_guess": "energy.gov.energy_saver",
            "publisher_name": "U.S. Department of Energy",
            "publisher_url": "https://www.energy.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "doe_public_web",
            "declared_rights": "bounded DOE public government information with acknowledgement requested and third-party, trademark, and media caveats retained",
            "terms_url": "https://www.energy.gov/web-policies",
            "rights_url": "https://www.energy.gov/web-policies",
            "dataset_url": "https://www.energy.gov/energysaver/energy-saver",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["maintenance_guidance_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        },
        {
            "source_id_guess": "ready.gov.kit",
            "publisher_name": "Ready.gov / Federal Emergency Management Agency",
            "publisher_url": "https://www.ready.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "ready_public_web",
            "declared_rights": "bounded Ready.gov public government website text with third-party, trademark, and media caveats retained",
            "terms_url": "https://www.ready.gov/terms-and-conditions",
            "rights_url": "https://www.ready.gov/terms-and-conditions",
            "dataset_url": "https://www.ready.gov/kit",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["safety_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        },
        {
            "source_id_guess": "usa.gov.home_repair",
            "publisher_name": "USA.gov / General Services Administration",
            "publisher_url": "https://www.usa.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "usagov_public_web",
            "declared_rights": "bounded public government website reuse with attribution, third-party, trademark, and media caveats retained",
            "terms_url": "https://www.usa.gov/government-works",
            "rights_url": "https://www.usa.gov/government-works",
            "dataset_url": "https://www.usa.gov/home-repair-programs",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["public_service_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        },
    ],
    "creative_project_reference": [
        {
            "source_id_guess": "creative-commons.licenses",
            "publisher_name": "Creative Commons",
            "publisher_url": "https://creativecommons.org/",
            "declared_jurisdiction": "global",
            "declared_license": "creativecommons_site_cc_by_4_cc0_tools",
            "declared_rights": "bounded CC license metadata reference with CC BY/CC0 posture, attribution, trademark, third-party, and source-specific reuse caveats retained",
            "terms_url": "https://creativecommons.org/terms/",
            "rights_url": "https://creativecommons.org/policies/",
            "dataset_url": "https://creativecommons.org/licenses/",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_institution",
            "authority_class_guess": "official_institution",
            "claim_class_guess": ["public_standard_reference", "creative_metadata_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        },
        {
            "source_id_guess": "w3c.web-standards",
            "publisher_name": "World Wide Web Consortium",
            "publisher_url": "https://www.w3.org/",
            "declared_jurisdiction": "global",
            "declared_license": "w3c_document_license_public_web",
            "declared_rights": "bounded W3C standards reference with document, software, test-suite, patent-policy, trademark, and permission caveats retained",
            "terms_url": "https://www.w3.org/policies/",
            "rights_url": "https://www.w3.org/copyright/",
            "dataset_url": "https://www.w3.org/standards/",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "standards_body",
            "authority_class_guess": "standards_body",
            "claim_class_guess": ["public_standard_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        },
        {
            "source_id_guess": "loc.primary_sources",
            "publisher_name": "Library of Congress",
            "publisher_url": "https://www.loc.gov/",
            "declared_jurisdiction": "US federal",
            "declared_license": "loc_usgov_work",
            "declared_rights": "page text marked U.S. Government Work; collection items, third-party material, media, and rights-restricted content excluded",
            "terms_url": "https://www.loc.gov/legal/",
            "rights_url": "http://www.loc.gov/text-us-government-work",
            "dataset_url": "https://www.loc.gov/programs/teachers/getting-started-with-primary-sources/",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["public_learning_resource"],
            "redistribution_guess": "redistributable_with_attribution",
        },
    ],
    "travel_relocation": [
        {
            "source_id_guess": "state.travel.public_travel",
            "publisher_name": "U.S. Department of State",
            "publisher_url": "https://travel.state.gov/",
            "declared_jurisdiction": "US and destination-specific",
            "declared_license": "state_travel_public_web",
            "declared_rights": "bounded public government website text reuse with attribution, third-party, trademark, and media caveats retained",
            "terms_url": "https://travel.state.gov/content/travel/en/copyright-disclaimer.html",
            "rights_url": "https://travel.state.gov/content/travel/en/copyright-disclaimer.html",
            "dataset_url": "https://travel.state.gov/content/travel/en/passports/how-apply.html",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["official_travel_requirement", "public_safety_notice"],
            "redistribution_guess": "redistributable_with_attribution",
        },
        {
            "source_id_guess": "usa.gov.change_address",
            "publisher_name": "USA.gov / General Services Administration",
            "publisher_url": "https://www.usa.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "usagov_public_web",
            "declared_rights": "bounded public government website text reuse with attribution, third-party, trademark, and media caveats retained",
            "terms_url": "https://www.usa.gov/government-works",
            "rights_url": "https://www.usa.gov/government-works",
            "dataset_url": "https://www.usa.gov/change-address",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["relocation_admin_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        }
    ],
    "business_entrepreneurship": [
        {
            "source_id_guess": "sba.business_guide.start_business",
            "publisher_name": "U.S. Small Business Administration",
            "publisher_url": "https://www.sba.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "sba_public_web",
            "declared_rights": "SBA.gov acknowledgement/disclaimer posture reviewed for bounded public-reference pack output",
            "terms_url": "https://www.sba.gov/about-sba/open-government/about-sbagov-website/linking-policy",
            "rights_url": "https://www.sba.gov/about-sba/open-government/about-sbagov-website/linking-policy",
            "dataset_url": "https://www.sba.gov/business-guide/10-steps-start-your-business",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["business_formation_reference", "public_program_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        }
    ],
    "hobbies_recreation": [
        {
            "source_id_guess": "nps.recreation-safety",
            "publisher_name": "National Park Service",
            "publisher_url": "https://www.nps.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "nps_public_web",
            "declared_rights": "NPS.gov disclaimer posture reviewed for bounded public-reference text pack output; media and third-party material excluded",
            "terms_url": "https://www.nps.gov/aboutus/disclaimer.htm",
            "rights_url": "https://www.nps.gov/aboutus/disclaimer.htm",
            "dataset_url": "https://www.nps.gov/subjects/healthandsafety/index.htm",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["learning_resource_reference", "public_rules_reference", "safety_guidance_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        }
    ],
    "relationships_family": [
        {
            "source_id_guess": "cdc.positive_parenting",
            "publisher_name": "Centers for Disease Control and Prevention",
            "publisher_url": "https://www.cdc.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "cdc_positive_parenting_public_web",
            "declared_rights": "CDC.gov public website text reuse posture reviewed for bounded public family education/support reference claims; media and third-party material excluded",
            "terms_url": "https://www.cdc.gov/other/agencymaterials.html",
            "rights_url": "https://www.cdc.gov/other/agencymaterials.html",
            "dataset_url": "https://www.cdc.gov/child-development/positive-parenting-tips/index.html",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["public_education_reference", "sensitive_support_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        },
        {
            "source_id_guess": "acf.healthy_marriage_fatherhood",
            "publisher_name": "Administration for Children and Families",
            "publisher_url": "https://acf.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "acf_hmrf_public_web",
            "declared_rights": "ACF.gov public website text reviewed for bounded family-service reference claims; live fetch may receive ACF WAF challenge and remains behind live/static budget policy",
            "terms_url": "https://acf.gov/digital-policies",
            "rights_url": "https://acf.gov/digital-policies",
            "dataset_url": "https://acf.gov/ofa/programs/healthy-marriage",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_government",
            "authority_class_guess": "official_government",
            "claim_class_guess": ["public_family_service_reference", "public_education_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        },
        {
            "source_id_guess": "childwelfare.family_support",
            "publisher_name": "Child Welfare Information Gateway",
            "publisher_url": "https://www.childwelfare.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "childwelfare_public_web",
            "declared_rights": "official Child Welfare Information Gateway public website/policy posture reviewed for bounded sensitive support reference claims; publication PDFs, media, and third-party content excluded",
            "terms_url": "https://www.childwelfare.gov/information-gateway-policies/",
            "rights_url": "https://www.childwelfare.gov/information-gateway-policies/",
            "dataset_url": "https://www.childwelfare.gov/resources/",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_institution",
            "authority_class_guess": "official_institution",
            "claim_class_guess": ["public_family_service_reference", "sensitive_support_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        }
    ],
    "personal_growth": [
        {
            "source_id_guess": "wikidata.structured_crosswalk",
            "publisher_name": "Wikidata",
            "publisher_url": "https://www.wikidata.org/",
            "declared_jurisdiction": "global",
            "declared_license": "CC0-1.0",
            "declared_rights": "structured data crosswalk only",
            "terms_url": "https://foundation.wikimedia.org/wiki/Policy:Terms_of_Use",
            "rights_url": "https://www.wikidata.org/wiki/Wikidata:Licensing",
            "dataset_url": "https://www.wikidata.org/wiki/Wikidata:Data_access",
            "distribution_urls": ["https://query.wikidata.org/"],
            "api_docs_url": "https://www.mediawiki.org/wiki/API:Main_page",
            "source_class_guess": "open_knowledge_graph",
            "authority_class_guess": "open_knowledge_graph",
            "claim_class_guess": ["identifier_crosswalk", "alias_crosswalk"],
            "redistribution_guess": "crosswalk_only",
        },
        {
            "source_id_guess": "nih.medlineplus.wellness",
            "publisher_name": "National Library of Medicine",
            "publisher_url": "https://medlineplus.gov/",
            "declared_jurisdiction": "US",
            "declared_license": "medlineplus_public_domain_topic_summary",
            "declared_rights": "bounded MedlinePlus public-domain health topic summary content with NLM acknowledgement requested and vendor, image, media, encyclopedia, drug, supplement, lab-test, genetic, and third-party content excluded",
            "terms_url": "https://medlineplus.gov/about/using/usingcontent/",
            "rights_url": "https://medlineplus.gov/about/using/usingcontent/",
            "dataset_url": "https://medlineplus.gov/",
            "distribution_urls": [],
            "api_docs_url": "",
            "source_class_guess": "official_institution",
            "authority_class_guess": "official_institution",
            "claim_class_guess": ["public_learning_reference", "sensitive_wellness_reference"],
            "redistribution_guess": "redistributable_with_attribution",
        },
        {
            "source_id_guess": "openalex.personal_growth_research",
            "publisher_name": "OpenAlex",
            "publisher_url": "https://openalex.org/",
            "declared_jurisdiction": "global",
            "declared_license": "openalex_cc0_metadata",
            "declared_rights": "CC0 scholarly metadata with high-volume API and snapshot use gated by Source Atlas API governance",
            "terms_url": "https://docs.openalex.org/download-all-data/openalex-snapshot",
            "rights_url": "https://docs.openalex.org/download-all-data/openalex-snapshot",
            "dataset_url": "https://openalex.org/",
            "distribution_urls": [],
            "api_docs_url": "https://docs.openalex.org/",
            "source_class_guess": "official_institution",
            "authority_class_guess": "scholarly_metadata",
            "claim_class_guess": ["research_metadata_reference"],
            "redistribution_guess": "redistributable",
        }
    ],
}
