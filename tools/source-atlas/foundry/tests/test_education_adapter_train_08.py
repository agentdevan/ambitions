from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.claim_frontier import ClaimFrontierOptions, compile_claim_frontier
from foundry.harvest_runner import GovernedHarvestOptions, run_governed_harvest
from foundry.model import read_json
from foundry.public_reference_adapters import ADAPTER_IDS, adapter_instances


CREATED_AT = "2026-06-27T00:00:00Z"
SOURCE_ID = "college-scorecard.api"
WEST_POINT_SOURCE_ID = "westpoint.redbook.computer_science_major"


def test_college_scorecard_fixture_adapter_is_governed_and_packable_after_internal_terms_review(tmp_path: Path):
    result = _harvest_college_scorecard(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for governed harvest runner"
    assert result["recordCounts"]["sourcesHarvested"] == 1
    assert result["recordCounts"]["claims"] > 0
    assert result["recordCounts"]["packCandidates"] == 1
    assert all(item["sourceID"] != SOURCE_ID for item in result["restrictedExclusions"])

    normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{SOURCE_ID}.json")
    assert normalized["sourceID"] == SOURCE_ID
    assert normalized["adapterID"] == ADAPTER_IDS[SOURCE_ID]
    assert normalized["claims"]
    assert normalized["requirements"]
    assert normalized["atoms"]
    assert normalized["provenance"]
    assert normalized["packCandidates"]
    assert "governancePackBlockedReason" not in normalized
    assert normalized["termsValidation"]["packable"] is True
    assert normalized["termsValidation"]["r2PackPolicy"] == "r2_pack_allowed"
    assert normalized["terms"]["attributionRequired"] is True
    assert normalized["apiLanes"]["packOutput"] == "allowed_for_bounded_public_reference_metadata_with_attribution"


def test_education_frontier_accepts_bounded_college_scorecard_claims_after_internal_terms_review(tmp_path: Path):
    harvest = _harvest_college_scorecard(tmp_path)
    result = compile_claim_frontier(
        ClaimFrontierOptions(
            input_root=Path(harvest["runRoot"]),
            output_root=tmp_path / "claim-frontier",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["packableClaims"] > 0

    education = next(report for report in result["frontierReports"] if report["frontier_id"] == "education_credentialing")
    assert education["status"] == "adapter_ready"
    assert education["status_ceiling"] == "pack_staging_ready"
    assert education["packable_claim_count"] > 0
    assert education["legal_posture_completeness"]["complete"] is True
    assert education["provenance_completeness"]["completeTupleCount"] > 0
    assert "credential_requirement" in education["missing_claim_classes"]

    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    claims = [claim for claim in claim_graph["claims"] if claim["source_id"] == SOURCE_ID]
    assert claims
    assert all(claim["pack_eligibility"] == "packable" for claim in claims)
    claim_values = json.dumps([claim["object_value"] for claim in claims], sort_keys=True)
    assert "admissions advice" not in claim_values
    assert "financial aid guidance" not in claim_values
    assert "final user plan" not in claim_values
    assert "Step generator" in json.dumps([claim["non_claims"] for claim in claims], sort_keys=True)


def test_education_frontier_reaches_claim_graph_ready_with_official_institution_credential_gold_set(tmp_path: Path):
    harvest = _harvest_bounded_education_credential_fixture(tmp_path)
    assert harvest["valid"], harvest["issues"]

    result = compile_claim_frontier(
        ClaimFrontierOptions(
            input_root=Path(harvest["runRoot"]),
            output_root=tmp_path / "claim-frontier",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]

    education = next(report for report in result["frontierReports"] if report["frontier_id"] == "education_credentialing")
    assert education["status"] == "claim_graph_ready"
    assert education["status_ceiling"] == "pack_staging_ready"
    assert education["missing_claim_classes"] == []
    assert education["covered_claim_classes"] == [
        "candidate_education_program_reference",
        "candidate_institution_reference",
        "credential_requirement",
    ]
    assert education["authority_coverage"]["complete"] is True
    assert education["gold_set_status"] == "passed"
    assert education["gold_set"]["matchedCount"] == 3
    assert education["legal_posture_completeness"]["complete"] is True
    assert education["provenance_completeness"]["packablePercent"] == 1.0
    assert set(education["source_lanes"]) == {SOURCE_ID, WEST_POINT_SOURCE_ID}

    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    west_point_claims = [claim for claim in claim_graph["claims"] if claim["source_id"] == WEST_POINT_SOURCE_ID]
    assert {claim["claim_type"] for claim in west_point_claims} == {"credential_requirement"}
    assert all(claim["pack_eligibility"] == "packable" for claim in west_point_claims)
    object_values = json.dumps([claim["object_value"] for claim in west_point_claims], sort_keys=True)
    assert "Computer Science major curriculum requirements" in object_values
    assert "admissions advice" not in object_values
    assert "personalized degree plan" not in object_values
    assert "final user plan" not in object_values


def test_college_scorecard_fixture_mode_does_not_require_key_or_live_network(tmp_path: Path):
    result = _harvest_college_scorecard(tmp_path, env={})

    assert result["valid"], result["issues"]
    assert result["liveRequested"] is False
    assert result["executeRequested"] is False
    assert result["apiPolicies"] == ["api.college_scorecard.v1"]
    assert all("COLLEGE_SCORECARD_API_KEY" not in issue for issue in result["issues"])


def test_college_scorecard_adapter_outputs_no_private_or_final_user_artifacts(tmp_path: Path):
    result = _harvest_college_scorecard(tmp_path)
    encoded = json.dumps(read_json(Path(result["runRoot"]) / "normalized" / f"{SOURCE_ID}.json"), sort_keys=True)

    assert result["privacyScan"]["passed"]
    assert "final_user_path" not in encoded
    assert "final_schedule" not in encoded
    assert "step_list" not in encoded
    assert "personalized_plan" not in encoded
    assert "private_goal_graph" not in encoded
    assert "does not create final user paths" in encoded
    assert "does not create final schedules" in encoded
    assert "does not create Step lists" in encoded


def test_college_scorecard_adapter_is_registered_once():
    matching = [adapter for adapter in adapter_instances() if adapter.source_id == SOURCE_ID]

    assert len(matching) == 1
    assert matching[0].adapter_id == "college_scorecard_education_adapter"


def test_west_point_redbook_credential_adapter_is_registered_once():
    matching = [adapter for adapter in adapter_instances() if adapter.source_id == WEST_POINT_SOURCE_ID]

    assert len(matching) == 1
    assert matching[0].adapter_id == "west_point_redbook_computer_science_credential_adapter"


def _harvest_college_scorecard(tmp_path: Path, env: dict[str, str] | None = None) -> dict[str, object]:
    return run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="college-scorecard-fixture",
            mode="fixture",
            source_ids=[SOURCE_ID],
            limit=25,
            created_at=CREATED_AT,
        ),
        env={} if env is None else env,
    )


def _harvest_bounded_education_credential_fixture(tmp_path: Path, env: dict[str, str] | None = None) -> dict[str, object]:
    return run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="education-credential-fixture",
            mode="fixture",
            source_ids=[SOURCE_ID, WEST_POINT_SOURCE_ID],
            limit=6,
            created_at=CREATED_AT,
        ),
        env={} if env is None else env,
    )
