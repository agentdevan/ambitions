from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.claim_frontier import ClaimFrontierOptions, compile_claim_frontier
from foundry.harvest_runner import GovernedHarvestOptions, run_governed_harvest
from foundry.model import read_json
from foundry.pack_production import PackProductionOptions, build_pack_production
from foundry.public_reference_adapters import ADAPTER_IDS, adapter_instances


CREATED_AT = "2026-06-28T00:00:00Z"
STATE_SOURCE_ID = "state.travel.public_travel"
USAGOV_SOURCE_ID = "usa.gov.change_address"
SOURCE_IDS = [STATE_SOURCE_ID, USAGOV_SOURCE_ID]
DOMAIN = "travel_relocation"


def test_travel_relocation_fixture_adapters_are_governed_and_pack_candidate_ready(tmp_path: Path):
    result = _harvest_travel(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for governed harvest runner"
    assert result["recordCounts"]["sourcesHarvested"] == 2
    assert result["recordCounts"]["claims"] == 3
    assert result["recordCounts"]["packCandidates"] == 2
    assert result["restrictedExclusions"] == []
    assert result["privacyScan"]["passed"]

    state_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{STATE_SOURCE_ID}.json")
    assert state_normalized["sourceID"] == STATE_SOURCE_ID
    assert state_normalized["adapterID"] == ADAPTER_IDS[STATE_SOURCE_ID]
    assert state_normalized["termsValidation"]["packable"] is True
    assert state_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in state_normalized["claims"]} == {
        "official_travel_requirement",
        "public_safety_notice",
    }
    assert all(claim["reviewRequirement"] is False for claim in state_normalized["claims"])
    assert state_normalized["apiLanes"]["fixtureMode"] == "no_network_static_state_travel_public_reference"

    usagov_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{USAGOV_SOURCE_ID}.json")
    assert usagov_normalized["sourceID"] == USAGOV_SOURCE_ID
    assert usagov_normalized["adapterID"] == ADAPTER_IDS[USAGOV_SOURCE_ID]
    assert usagov_normalized["termsValidation"]["packable"] is True
    assert usagov_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in usagov_normalized["claims"]} == {"relocation_admin_reference"}
    assert all(claim["reviewRequirement"] is False for claim in usagov_normalized["claims"])
    assert usagov_normalized["apiLanes"]["fixtureMode"] == "no_network_static_usagov_public_reference"


def test_travel_relocation_frontier_reaches_claim_graph_ready_with_gold_set(tmp_path: Path):
    harvest = _harvest_travel(tmp_path)
    result = _claim_frontier(tmp_path, Path(harvest["runRoot"]))

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["claims"] == 3
    assert result["recordCounts"]["packableClaims"] == 3
    assert result["recordCounts"]["blockedClaims"] == 0
    assert result["provenanceCompleteness"]["packablePercent"] == 1.0

    travel = next(report for report in result["frontierReports"] if report["frontier_id"] == DOMAIN)
    assert travel["status"] == "claim_graph_ready"
    assert travel["status_ceiling"] == "pack_staging_ready"
    assert travel["packable_claim_count"] == 3
    assert travel["blocked_claim_count"] == 0
    assert travel["missing_claim_classes"] == []
    assert travel["authority_coverage"]["complete"] is True
    assert travel["legal_posture_completeness"]["complete"] is True
    assert travel["provenance_completeness"]["complete"] is True
    assert travel["gold_set_status"] == "passed"
    assert travel["gold_set"]["goldSetID"] == "gold.travel_relocation.state_usagov_public_reference.v1"
    assert travel["gold_set"]["requiredCount"] == 3
    assert travel["gold_set"]["matchedCount"] == 3
    assert travel["gold_set"]["missing"] == []

    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    claims = [claim for claim in claim_graph["claims"] if claim["source_id"] in SOURCE_IDS]
    assert len(claims) == 3
    assert all(claim["pack_eligibility"] == "packable" for claim in claims)
    assert all(claim["provenance_tuple_complete"] for claim in claims)
    encoded = json.dumps([claim["object_value"] for claim in claims], sort_keys=True)
    assert "not visa advice" in encoded
    assert "not emergency advice" in encoded
    assert "not address submission" in encoded


def test_travel_relocation_pack_production_dry_run_emits_public_r2_plan(tmp_path: Path):
    harvest = _harvest_travel(tmp_path)
    frontier = _claim_frontier(tmp_path, Path(harvest["runRoot"]))
    result = build_pack_production(
        PackProductionOptions(
            input_root=Path(frontier["outputRoot"]),
            output_root=tmp_path / "pack-production",
            domain=DOMAIN,
            environment="staging",
            channel="candidate",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for pack compiler/R2 dry-run controls"
    assert result["recordCounts"]["claims"] == 3
    assert result["recordCounts"]["blockedClaimsExcluded"] == 0
    assert result["dryRunPlan"]["dryRun"] is True
    assert result["dryRunPlan"]["wouldUpload"] is False
    assert result["nonPrivateScan"]["passed"]
    assert all("/travel_relocation/" in key for key in result["objectKeys"].values())

    output_root = Path(result["outputRoot"])
    pack = read_json(output_root / "pack.json")
    manifest = read_json(output_root / "manifest.json")
    claims = read_json(output_root / "claims.json")["claims"]
    licenses = read_json(output_root / "licenses.json")["licenses"]
    attribution = read_json(output_root / "attribution.json")["attribution"]
    assert len(claims) == 3
    assert pack["claims"] == claims
    assert {license_row["license_id"] for license_row in licenses} == {
        "state_travel_public_web",
        "usagov_public_web",
    }
    assert len(attribution) == 3
    assert {row["license_id"] for row in attribution} == {"state_travel_public_web", "usagov_public_web"}
    assert pack["frontier_id"] == DOMAIN
    assert manifest["pack_id"].endswith(f"/{DOMAIN}/20260628T000000Z")
    assert manifest["revocation_manifest_key"].endswith("/revocations.json")
    assert manifest["lkg_pointer_key"].endswith("/lkg.json")
    assert "not production R2 readiness" in manifest["non_claims"]


def test_travel_relocation_adapters_output_no_private_or_final_user_artifacts(tmp_path: Path):
    result = _harvest_travel(tmp_path)
    encoded = json.dumps(read_json(Path(result["runRoot"]) / "normalized" / f"{STATE_SOURCE_ID}.json"), sort_keys=True)
    encoded += json.dumps(read_json(Path(result["runRoot"]) / "normalized" / f"{USAGOV_SOURCE_ID}.json"), sort_keys=True)

    assert result["privacyScan"]["passed"]
    assert "final_user_path" not in encoded
    assert "final_schedule" not in encoded
    assert "step_list" not in encoded
    assert "personalized_plan" not in encoded
    assert "private_goal_graph" not in encoded
    assert "custom itinerary" in encoded
    assert "not address submission" in encoded


def test_travel_relocation_adapters_are_registered_once():
    matching = [adapter for adapter in adapter_instances() if adapter.source_id in SOURCE_IDS]

    assert len(matching) == 2
    assert {adapter.adapter_id for adapter in matching} == {
        "state_travel_public_reference_adapter",
        "usagov_change_address_adapter",
    }


def _harvest_travel(tmp_path: Path) -> dict[str, object]:
    return run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="travel-relocation-fixture",
            mode="fixture",
            source_ids=SOURCE_IDS,
            limit=6,
            created_at=CREATED_AT,
        ),
        env={},
    )


def _claim_frontier(tmp_path: Path, run_root: Path) -> dict[str, object]:
    return compile_claim_frontier(
        ClaimFrontierOptions(
            input_root=run_root,
            output_root=tmp_path / "claim-frontier",
            created_at=CREATED_AT,
        )
    )
