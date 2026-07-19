from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.broad_domain_discovery import BroadDomainDiscoveryOptions, build_broad_domain_discovery
from foundry.model import read_json


CREATED_AT = "2026-06-27T00:00:00Z"
SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
FRONTIER_CONFIG = SOURCE_ATLAS_ROOT / "frontier" / "coverage-frontiers.json"


def test_broad_domain_discovery_emits_candidate_records_without_claims(tmp_path: Path):
    result = build_broad_domain_discovery(
        BroadDomainDiscoveryOptions(
            output_root=tmp_path / "broad-domain-discovery",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for broad-domain candidate discovery tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; deterministic candidate discovery/scorecards only"
    assert result["recordCounts"]["frontiers"] == _configured_frontier_count()
    assert result["recordCounts"]["candidateRecords"] >= 12
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["packableClaims"] == 0
    assert result["recordCounts"]["r2PackableArtifacts"] == 0
    assert _check(result, "candidate_discovery_emits_no_claims")
    assert _check(result, "all_candidates_review_required")
    assert _check(result, "candidate_statuses_below_pack_readiness")
    assert "not universal goal coverage" in result["nonClaims"]

    output_root = Path(result["outputRoot"])
    candidates = read_json(output_root / "candidate-sources.json")
    assert candidates["recordCounts"]["claims"] == 0
    assert candidates["recordCounts"]["packableClaims"] == 0
    assert all(candidate["review_required"] for candidate in candidates["candidateRecords"])
    assert all(candidate["pack_eligibility"] == "blocked_candidate_only" for candidate in candidates["candidateRecords"])
    assert all(candidate["evidence_hash"] for candidate in candidates["candidateRecords"])


def test_broad_domain_scorecards_keep_non_pack_ready_domains_below_pack_readiness(tmp_path: Path):
    result = build_broad_domain_discovery(
        BroadDomainDiscoveryOptions(
            output_root=tmp_path / "broad-domain-discovery",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    scorecards = read_json(Path(result["outputRoot"]) / "domain-scorecards.json")["scorecards"]
    by_domain = {scorecard["domain"]: scorecard for scorecard in scorecards}
    public_civic = by_domain["public_civic_requirements"]
    assert public_civic["status"] == "source_review_ready"
    assert public_civic["packable_claim_count"] == 0
    assert public_civic["r2_packable_artifact_count"] == 0
    assert "frontier_below_pack_readiness" in public_civic["blocking_reasons"]
    assert "not pack ready" in public_civic["non_claims"]
    education = by_domain["education_credentialing"]
    assert education["status"] == "candidate_only"
    assert education["status_ceiling"] == "pack_staging_ready"
    assert education["packable_claim_count"] == 0
    assert education["r2_packable_artifact_count"] == 0
    assert "candidate_only_not_claim_authority" in education["blocking_reasons"]
    assert "legal_review_required_before_pack_output" in education["blocking_reasons"]
    assert "not pack ready" in education["non_claims"]

    creative = by_domain["creative_project_reference"]
    assert creative["status"] == "candidate_only"
    assert creative["status_ceiling"] == "pack_staging_ready"
    assert creative["registered_required_source_lanes"] == [
        "creative-commons.licenses",
        "loc.primary_sources",
        "w3c.web-standards",
    ]
    assert creative["candidate_source_lanes_missing"] == []
    assert creative["packable_claim_count"] == 0
    assert creative["r2_packable_artifact_count"] == 0
    assert "candidate_only_not_claim_authority" in creative["blocking_reasons"]
    assert "legal_review_required_before_pack_output" in creative["blocking_reasons"]
    assert "frontier_below_pack_readiness" not in creative["blocking_reasons"]
    assert "not pack ready" in creative["non_claims"]

    personal = by_domain["personal_growth"]
    assert personal["status"] == "candidate_only"
    assert personal["status_ceiling"] == "pack_staging_ready"
    assert personal["registered_required_source_lanes"] == [
        "nih.medlineplus.wellness",
        "openalex.personal_growth_research",
    ]
    assert personal["candidate_source_lanes_missing"] == []
    assert personal["packable_claim_count"] == 0
    assert personal["r2_packable_artifact_count"] == 0
    assert "candidate_only_not_claim_authority" in personal["blocking_reasons"]
    assert "frontier_below_pack_readiness" not in personal["blocking_reasons"]
    assert "not pack ready" in personal["non_claims"]

    relationships = by_domain["relationships_family"]
    assert relationships["status"] == "candidate_only"
    assert relationships["status_ceiling"] == "pack_staging_ready"
    assert relationships["registered_required_source_lanes"] == [
        "acf.healthy_marriage_fatherhood",
        "cdc.positive_parenting",
        "childwelfare.family_support",
    ]
    assert relationships["candidate_source_lanes_missing"] == []
    assert relationships["packable_claim_count"] == 0
    assert relationships["r2_packable_artifact_count"] == 0
    assert "candidate_only_not_claim_authority" in relationships["blocking_reasons"]
    assert "frontier_below_pack_readiness" not in relationships["blocking_reasons"]
    assert "not pack ready" in relationships["non_claims"]

    home = by_domain["home_life_admin"]
    assert home["status"] == "candidate_only"
    assert home["status_ceiling"] == "pack_staging_ready"
    assert home["registered_required_source_lanes"] == [
        "energy.gov.energy_saver",
        "ready.gov.kit",
        "usa.gov.home_repair",
    ]
    assert home["candidate_source_lanes_missing"] == []
    assert home["packable_claim_count"] == 0
    assert home["r2_packable_artifact_count"] == 0
    assert "candidate_only_not_claim_authority" in home["blocking_reasons"]
    assert "legal_review_required_before_pack_output" in home["blocking_reasons"]
    assert "frontier_below_pack_readiness" not in home["blocking_reasons"]
    assert "not pack ready" in home["non_claims"]

    business = by_domain["business_entrepreneurship"]
    assert business["status"] == "candidate_only"
    assert business["status_ceiling"] == "pack_staging_ready"
    assert business["registered_required_source_lanes"] == ["sba.business_guide.start_business"]
    assert business["candidate_source_lanes_missing"] == []
    assert business["packable_claim_count"] == 0
    assert business["r2_packable_artifact_count"] == 0
    assert "candidate_only_not_claim_authority" in business["blocking_reasons"]
    assert "not pack ready" in business["non_claims"]

    hobbies = by_domain["hobbies_recreation"]
    assert hobbies["status"] == "candidate_only"
    assert hobbies["status_ceiling"] == "pack_staging_ready"
    assert hobbies["registered_required_source_lanes"] == ["nps.recreation-safety"]
    assert hobbies["candidate_source_lanes_missing"] == []
    assert hobbies["packable_claim_count"] == 0
    assert hobbies["r2_packable_artifact_count"] == 0
    assert "candidate_only_not_claim_authority" in hobbies["blocking_reasons"]
    assert "not pack ready" in hobbies["non_claims"]

    health = by_domain["health_wellness_reference"]
    assert health["status"] == "candidate_only"
    assert health["status_ceiling"] == "pack_staging_ready"
    assert health["registered_required_source_lanes"] == ["cdc.physical-activity.basics"]
    assert health["candidate_source_lanes_missing"] == ["hhs.physical-activity-guidelines"]
    assert health["packable_claim_count"] == 0
    assert health["r2_packable_artifact_count"] == 0
    assert "candidate_only_not_claim_authority" in health["blocking_reasons"]
    assert "missing_source_lane" in health["blocking_reasons"]
    assert "not pack ready" in health["non_claims"]

    travel = by_domain["travel_relocation"]
    assert travel["status"] == "candidate_only"
    assert travel["status_ceiling"] == "pack_staging_ready"
    assert travel["registered_required_source_lanes"] == [
        "state.travel.public_travel",
        "usa.gov.change_address",
    ]
    assert travel["candidate_source_lanes_missing"] == []
    assert travel["packable_claim_count"] == 0
    assert travel["r2_packable_artifact_count"] == 0
    assert "candidate_only_not_claim_authority" in travel["blocking_reasons"]
    assert "legal_review_required_before_pack_output" in travel["blocking_reasons"]
    assert "not pack ready" in travel["non_claims"]

    finance = by_domain["finance_public_reference"]
    assert finance["status"] == "candidate_only"
    assert finance["status_ceiling"] == "pack_staging_ready"
    assert finance["registered_required_source_lanes"] == [
        "cfpb.adult_financial_education",
        "irs.when_to_file",
        "usa.gov.benefits",
    ]
    assert finance["candidate_source_lanes_missing"] == []
    assert finance["packable_claim_count"] == 0
    assert finance["r2_packable_artifact_count"] == 0
    assert "candidate_only_not_claim_authority" in finance["blocking_reasons"]
    assert "legal_review_required_before_pack_output" in finance["blocking_reasons"]
    assert "not pack ready" in finance["non_claims"]


def test_candidate_records_have_required_contract_fields_and_stable_ordering(tmp_path: Path):
    result = build_broad_domain_discovery(
        BroadDomainDiscoveryOptions(
            output_root=tmp_path / "broad-domain-discovery",
            created_at=CREATED_AT,
        )
    )
    candidates = read_json(Path(result["outputRoot"]) / "candidate-sources.json")["candidateRecords"]

    required_fields = {
        "candidate_id",
        "source_id_guess",
        "discovery_method",
        "discovered_at",
        "publisher_name",
        "publisher_url",
        "declared_jurisdiction",
        "declared_license",
        "declared_rights",
        "terms_url",
        "rights_url",
        "dataset_url",
        "distribution_urls",
        "api_docs_url",
        "source_class_guess",
        "authority_class_guess",
        "domain_guess",
        "claim_class_guess",
        "redistribution_guess",
        "review_required",
        "candidate_score",
        "blocking_reasons",
        "evidence_hash",
    }
    assert all(required_fields.issubset(candidate) for candidate in candidates)
    assert candidates == sorted(candidates, key=lambda item: (item["domain_guess"], item["candidate_score"] * -1, item["candidate_id"]))
    assert all(candidate["review_required"] is True for candidate in candidates)
    assert all("candidate_only_not_claim_authority" in candidate["blocking_reasons"] for candidate in candidates)


def test_discovery_blocks_source_of_sources_crosswalks_and_private_outputs(tmp_path: Path):
    result = build_broad_domain_discovery(
        BroadDomainDiscoveryOptions(
            output_root=tmp_path / "broad-domain-discovery",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert _check(result, "source_of_sources_not_authority")
    assert _check(result, "crosswalks_not_regulated_authority")
    assert _check(result, "privacy_scan_passed")
    assert _check(result, "r2_object_key_scan_passed")
    assert _check(result, "no_final_plan_schedule_step_output")

    candidates = read_json(Path(result["outputRoot"]) / "candidate-sources.json")["candidateRecords"]
    catalog = next(candidate for candidate in candidates if candidate["source_id_guess"] == "data.gov.catalog")
    crosswalk = next(candidate for candidate in candidates if candidate["source_id_guess"] == "wikidata.structured_crosswalk")
    assert "source_of_sources_not_claim_authority" in catalog["blocking_reasons"]
    assert "crosswalk_only_not_regulated_authority" in crosswalk["blocking_reasons"]
    assert crosswalk["redistribution_guess"] == "crosswalk_only"
    assert all("final_user_path" in candidate["forbidden_artifact_classes"] for candidate in candidates)
    assert all("final_schedule" in candidate["forbidden_artifact_classes"] for candidate in candidates)
    assert all("step_list" in candidate["forbidden_artifact_classes"] for candidate in candidates)
    assert all("private_goal_graph" in candidate["forbidden_artifact_classes"] for candidate in candidates)


def _check(result: dict[str, object], name: str) -> bool:
    return next(check["passed"] for check in result["checks"] if check["name"] == name)


def _configured_frontier_count() -> int:
    return len(read_json(FRONTIER_CONFIG)["frontiers"])
