from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.deep_research_frontier_intake import DeepResearchFrontierIntakeOptions, run_deep_research_frontier_intake
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-29T12:00:00Z"


def test_deep_research_frontier_intake_extracts_markdown_and_emits_candidate_only_artifacts(tmp_path: Path):
    input_path = _write_markdown_fixture(tmp_path)

    result = _run(input_path, tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for Deep Research frontier intake normalization"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; Deep Research candidate normalization only"
    assert result["extraction"]["mode"] == "markdown_fenced_json"
    assert result["recordCounts"]["frontierCandidates"] == 4
    assert result["recordCounts"]["sourceCandidates"] == 5
    assert result["recordCounts"]["goldClaimReviewMarkers"] == 5
    assert result["recordCounts"]["productionRegistryMutations"] == 0
    assert result["recordCounts"]["r2Objects"] == 0
    assert _check(result, "frontier_intake_valid")
    assert _check(result, "candidate_intake_emits_no_claims")
    assert _check(result, "gold_claims_are_review_markers_only")
    assert _check(result, "production_mutation_blocked")
    assert _check(result, "workflow_queue_review_bound")

    intake_manifest = read_json(Path(result["outputRoot"]) / "frontier-intake" / "manifest.json")
    assert intake_manifest["recordCounts"]["claims"] == 0
    assert intake_manifest["recordCounts"]["packableClaims"] == 0
    assert intake_manifest["recordCounts"]["r2PackableArtifacts"] == 0


def test_normalized_ids_preserve_research_frontiers_without_f_prefix(tmp_path: Path):
    result = _run(_write_markdown_fixture(tmp_path), tmp_path)

    frontiers = read_json(Path(result["outputRoot"]) / "normalized-frontiers.json")["frontiers"]
    frontier_ids = {frontier["frontier_id"] for frontier in frontiers}
    assert "geo_temporal_reference" in frontier_ids
    assert "health_provider_medication" in frontier_ids
    assert "law_regulation_and_tax" in frontier_ids
    assert "education_career_labor" in frontier_ids
    assert all(frontier["status_ceiling"] == "candidate_only" for frontier in frontiers)
    assert all(frontier["pack_output_allowed"] is False for frontier in frontiers)
    assert all(frontier["r2_output_allowed"] is False for frontier in frontiers)

    sources = read_json(Path(result["outputRoot"]) / "normalized-source-candidates.json")["sourceCandidates"]
    source_ids = {source["source_id"] for source in sources}
    assert {"iana.tzdb", "nppes", "openfda", "federal.register.api", "bls.api"}.issubset(source_ids)
    assert all(source["review_required"] is True for source in sources)
    assert all(source["claim_authority_allowed"] is False for source in sources)
    assert all(source["r2_output_allowed"] is False for source in sources)


def test_gold_claims_are_review_markers_not_claim_output(tmp_path: Path):
    result = _run(_write_markdown_fixture(tmp_path), tmp_path)

    markers = read_json(Path(result["outputRoot"]) / "gold-claim-review-queue.json")["goldClaimReviewMarkers"]
    assert markers
    assert any(marker["gold_claim_review_marker_id"] == "gold.geo_temporal_reference.iana_tzdb.timezone_assignment" for marker in markers)
    assert all(marker["status_ceiling"] == "review_marker_only" for marker in markers)
    assert all(marker["review_required"] is True for marker in markers)
    assert all(marker["claim_output_allowed"] is False for marker in markers)
    assert all(marker["pack_output_allowed"] is False for marker in markers)
    assert all(marker["r2_output_allowed"] is False for marker in markers)
    assert all("claim_frontier_review_required" in marker["blocking_reasons"] for marker in markers)


def test_workflow_queue_keeps_every_step_blocked_by_review_gates(tmp_path: Path):
    result = _run(_write_markdown_fixture(tmp_path), tmp_path)

    workflow = read_json(Path(result["outputRoot"]) / "workflow-queue.json")["workflowItems"]
    assert workflow
    assert {item["work_type"] for item in workflow} == {
        "adapter_contract_planning",
        "api_governance_review",
        "frontier_governance_review",
        "gated_r2_promotion_review",
        "gold_claim_review",
        "legal_terms_review",
        "local_candidate_harvest_review",
        "production_target_readiness_review",
        "source_lane_review",
    }
    assert all(item["status"] == "blocked_review_required" for item in workflow)
    assert all(item["candidate_only"] is True for item in workflow)
    assert all(item["r2_output_allowed"] is False for item in workflow)
    assert all("r2_owner_approval_required" in item["blocking_reasons"] for item in workflow)


def test_private_boundary_issue_fails_before_candidate_use(tmp_path: Path):
    input_path = tmp_path / "private.json"
    write_json(
        input_path,
        {
            "frontiers": [
                {
                    "frontier_id": "F99_PRIVATE_CONTEXT",
                    "domain": "private_context",
                    "goal_text": "I need a private plan",
                    "claim_classes": ["public_reference"],
                    "jurisdictions": ["US"],
                    "minimum_authority_classes": ["federal_primary"],
                }
            ],
            "source_candidates": [],
            "gold_claims": [],
        },
    )

    result = _run(input_path, tmp_path)

    assert not result["valid"]
    assert not _check(result, "input_privacy_scan_passed")
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def test_safe_api_credential_metadata_alias_is_preserved_for_review_queue(tmp_path: Path):
    input_path = tmp_path / "safe-alias.json"
    write_json(
        input_path,
        {
            "frontiers": [
                {
                    "frontier_id": "F09_EDUCATION_CAREER_LABOR",
                    "domain": "education_workforce_labor_reference",
                    "goal_intent_classes": ["learn"],
                    "claim_classes": ["published_labor_series_value"],
                    "jurisdictions": ["US_primary"],
                    "minimum_authority_classes": ["federal_primary"],
                    "freshness_sla": "bls_as_series_release",
                }
            ],
            "source_candidates": [
                {
                    "source_id": "SRC_BLS_API",
                    "source_name": "BLS Public Data API",
                    "publisher": "U.S. Bureau of Labor Statistics",
                    "source_class": "federal_api",
                    "authority_class": "federal_primary",
                    "homepage_url": "https://www.bls.gov/developers/",
                    "data_url/api_url": "https://api.bls.gov/publicAPI/v2/",
                    "documentation_url": "https://www.bls.gov/bls/api_features.htm",
                    "terms_url": "https://www.bls.gov/developers/termsOfService.htm",
                    "apiCredentialRequirementMetadata": "registration_key_for_version_2_0_features",
                    "claim_classes_supported": ["published_labor_series_value"],
                    "jurisdictions_covered": ["US"],
                }
            ],
            "gold_claims": [],
        },
    )

    result = _run(input_path, tmp_path)

    assert result["valid"], result["issues"]
    sources = read_json(Path(result["outputRoot"]) / "normalized-source-candidates.json")["sourceCandidates"]
    assert sources[0]["api_key_required"] == "registration_key_for_version_2_0_features"
    workflow = read_json(Path(result["outputRoot"]) / "workflow-queue.json")["workflowItems"]
    assert any("api_credentials_or_budget_review_required" in item["blocking_reasons"] for item in workflow)


def _run(input_path: Path, tmp_path: Path) -> dict[str, object]:
    return run_deep_research_frontier_intake(
        DeepResearchFrontierIntakeOptions(
            input_path=input_path,
            output_root=tmp_path / "deep-research-intake",
            created_at=CREATED_AT,
        )
    )


def _write_markdown_fixture(tmp_path: Path) -> Path:
    payload = {
        "frontiers": [
            {
                "frontier_id": "F01_GEO_TEMPORAL_REFERENCE",
                "domain": "place_time_identity",
                "goal_intent_classes": ["orient", "normalize"],
                "claim_classes": ["timezone_assignment", "zip_to_geo_crosswalk"],
                "jurisdictions": ["global_baseline", "US_enhanced"],
                "minimum_authority_classes": ["standards_body_primary", "federal_primary"],
                "freshness_sla": "timezone_changes_within_7d; boundaries_annual",
                "explicit_exclusions": ["parcel ownership"],
                "forbidden_claims": ["mail deliverability guarantee"],
                "non_claims": ["best route"],
            },
            {
                "frontier_id": "F06_HEALTH_PROVIDER_MEDICATION",
                "domain": "healthcare_reference_and_drug_safety",
                "goal_intent_classes": ["find_care", "avoid_risk"],
                "claim_classes": ["provider_identity", "drug_recall_fact"],
                "jurisdictions": ["US_primary"],
                "minimum_authority_classes": ["federal_primary"],
                "freshness_sla": "provider_directory_live; recalls_weekly",
                "explicit_exclusions": ["diagnosis"],
                "forbidden_claims": ["medical care advice"],
                "non_claims": ["best doctor"],
            },
            {
                "frontier_id": "F08_LAW_REGULATION_AND_TAX",
                "domain": "public_law_regulation_tax_reference",
                "goal_intent_classes": ["comply", "research"],
                "claim_classes": ["federal_register_notice_presence", "tax_threshold_reference"],
                "jurisdictions": ["US_federal_primary"],
                "minimum_authority_classes": ["federal_primary", "federal_primary_unofficial_presentation_with_official_backstop"],
                "freshness_sla": "federal_register_daily; tax_publications_as_issued",
                "explicit_exclusions": ["legal advice"],
                "forbidden_claims": ["this is legal advice"],
                "non_claims": ["case-specific tax advice"],
            },
            {
                "frontier_id": "F09_EDUCATION_CAREER_LABOR",
                "domain": "education_workforce_labor_reference",
                "goal_intent_classes": ["learn", "budget"],
                "claim_classes": ["published_labor_series_value"],
                "jurisdictions": ["US_primary"],
                "minimum_authority_classes": ["federal_primary"],
                "freshness_sla": "bls_as_series_release",
                "explicit_exclusions": ["salary promises"],
                "forbidden_claims": ["guaranteed salary outcome"],
                "non_claims": ["macro prediction"],
            },
        ],
        "source_candidates": [
            {
                "source_id": "SRC_IANA_TZDB",
                "source_name": "IANA Time Zone Database",
                "publisher": "Internet Assigned Numbers Authority",
                "source_class": "standards_body_reference",
                "authority_class": "standards_primary",
                "homepage_url": "https://www.iana.org/time-zones",
                "data_url/api_url": "https://data.iana.org/time-zones/",
                "documentation_url": "https://www.iana.org/time-zones/repository/tz-link.html",
                "terms_url": "https://www.iana.org/time-zones/repository/tz-link.html",
                "rights_url": "https://www.iana.org/time-zones/repository/tz-link.html",
                "license_url": "https://www.iana.org/time-zones/repository/tz-link.html",
                "declared_license": "public domain",
                "redistribution_allowed_guess": "yes",
                "pack_output_allowed_guess": "yes",
                "known_restrictions": ["none_material_found"],
                "api_key_required": False,
                "claim_classes_supported": ["timezone_assignment"],
                "jurisdictions_covered": ["global"],
            },
            {
                "source_id": "SRC_NPPES",
                "source_name": "NPPES NPI Registry API",
                "publisher": "Centers for Medicare & Medicaid Services",
                "source_class": "federal_api",
                "authority_class": "federal_primary",
                "homepage_url": "https://npiregistry.cms.hhs.gov/",
                "data_url/api_url": "https://npiregistry.cms.hhs.gov/api-page",
                "documentation_url": "https://npiregistry.cms.hhs.gov/api-page",
                "terms_url": "https://npiregistry.cms.hhs.gov/api-page",
                "declared_license": "public data api",
                "redistribution_allowed_guess": "yes",
                "pack_output_allowed_guess": "yes",
                "known_restrictions": ["200_results_per_request"],
                "api_key_required": False,
                "claim_classes_supported": ["provider_identity"],
                "jurisdictions_covered": ["US"],
            },
            {
                "source_id": "SRC_OPENFDA",
                "source_name": "openFDA",
                "publisher": "U.S. Food and Drug Administration",
                "source_class": "federal_api",
                "authority_class": "federal_primary",
                "homepage_url": "https://open.fda.gov/",
                "data_url/api_url": "https://api.fda.gov/",
                "documentation_url": "https://open.fda.gov/apis/",
                "terms_url": "https://open.fda.gov/terms/",
                "declared_license": "CC0_1_0_except_marked_exceptions",
                "redistribution_allowed_guess": "yes_except_marked_third_party_content",
                "pack_output_allowed_guess": "yes",
                "known_restrictions": ["do_not_use_for_medical_decisions"],
                "api_key_required": True,
                "claim_classes_supported": ["drug_recall_fact"],
                "jurisdictions_covered": ["US"],
            },
            {
                "source_id": "SRC_FEDERAL_REGISTER_API",
                "source_name": "FederalRegister.gov API",
                "publisher": "Office of the Federal Register / NARA",
                "source_class": "federal_api_unofficial_presentation",
                "authority_class": "federal_primary_unofficial_presentation",
                "homepage_url": "https://www.federalregister.gov/",
                "data_url/api_url": "https://www.federalregister.gov/api/v1/",
                "documentation_url": "https://www.federalregister.gov/reader-aids/developer-resources/rest-api",
                "terms_url": "https://www.federalregister.gov/reader-aids/developer-resources/rest-api",
                "declared_license": "public api unofficial site",
                "redistribution_allowed_guess": "yes_with_logo_limits",
                "pack_output_allowed_guess": "yes",
                "known_restrictions": ["not_official_legal_edition"],
                "api_key_required": False,
                "claim_classes_supported": ["federal_register_notice_presence"],
                "jurisdictions_covered": ["US_federal"],
            },
            {
                "source_id": "SRC_BLS_API",
                "source_name": "BLS Public Data API",
                "publisher": "U.S. Bureau of Labor Statistics",
                "source_class": "federal_api",
                "authority_class": "federal_primary",
                "homepage_url": "https://www.bls.gov/developers/",
                "data_url/api_url": "https://api.bls.gov/publicAPI/v2/",
                "documentation_url": "https://www.bls.gov/bls/api_features.htm",
                "terms_url": "https://www.bls.gov/developers/termsOfService.htm",
                "declared_license": "public api under citation terms",
                "redistribution_allowed_guess": "yes_with_citation",
                "pack_output_allowed_guess": "yes",
                "known_restrictions": ["must_cite_access_date_and_disclaimer"],
                "api_key_required": "registration_key_for_version_2_0_features",
                "claim_classes_supported": ["published_labor_series_value"],
                "jurisdictions_covered": ["US"],
            },
        ],
        "gold_claims": [
            {
                "gold_claim_id": "GC001",
                "frontier_id": "F01_GEO_TEMPORAL_REFERENCE",
                "claim_type": "timezone_assignment",
                "source_id": "SRC_IANA_TZDB",
                "jurisdiction": "global",
                "object_contains_markers": ["timezone_id"],
                "exclusions": ["mailing_address_validity"],
                "non_claims": ["travel_time"],
            },
            {
                "gold_claim_id": "GC014",
                "frontier_id": "F06_HEALTH_PROVIDER_MEDICATION",
                "claim_type": "provider_identity",
                "source_id": "SRC_NPPES",
                "jurisdiction": "US",
                "object_contains_markers": ["npi"],
                "exclusions": ["quality_scores"],
                "non_claims": ["best_provider"],
            },
            {
                "gold_claim_id": "GC015",
                "frontier_id": "F06_HEALTH_PROVIDER_MEDICATION",
                "claim_type": "drug_recall_fact",
                "source_id": "SRC_OPENFDA",
                "jurisdiction": "US",
                "object_contains_markers": ["recall_class"],
                "exclusions": ["medical_decision_support"],
                "non_claims": ["take_or_stop_medication_advice"],
            },
            {
                "gold_claim_id": "GC018",
                "frontier_id": "F08_LAW_REGULATION_AND_TAX",
                "claim_type": "federal_register_notice_reference",
                "source_id": "SRC_FEDERAL_REGISTER_API",
                "jurisdiction": "US_federal",
                "object_contains_markers": ["document_number"],
                "exclusions": ["official_legal_status_claim_without_backstop"],
                "non_claims": ["legal_advice"],
            },
            {
                "gold_claim_id": "GC025",
                "frontier_id": "F09_EDUCATION_CAREER_LABOR",
                "claim_type": "published_labor_series_value",
                "source_id": "SRC_BLS_API",
                "jurisdiction": "US",
                "object_contains_markers": ["series_id"],
                "exclusions": ["forecast_not_in_series"],
                "non_claims": ["macro_prediction"],
            },
        ],
    }
    input_path = tmp_path / "deep-research.md"
    input_path.write_text("# Source Atlas Frontier Coverage\n\n```json\n" + json.dumps(payload, indent=2) + "\n```\n", encoding="utf-8")
    return input_path


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
