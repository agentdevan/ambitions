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
READY_SOURCE_ID = "ready.gov.kit"
ENERGY_SOURCE_ID = "energy.gov.energy_saver"
USAGOV_SOURCE_ID = "usa.gov.home_repair"
SOURCE_IDS = [READY_SOURCE_ID, ENERGY_SOURCE_ID, USAGOV_SOURCE_ID]
DOMAIN = "home_life_admin"


def test_home_life_admin_fixture_adapters_are_governed_and_pack_candidate_ready(tmp_path: Path):
    result = _harvest_home(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for governed harvest runner"
    assert result["recordCounts"]["sourcesHarvested"] == 3
    assert result["recordCounts"]["claims"] == 4
    assert result["recordCounts"]["packCandidates"] == 3
    assert result["restrictedExclusions"] == []
    assert result["privacyScan"]["passed"]

    ready_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{READY_SOURCE_ID}.json")
    assert ready_normalized["sourceID"] == READY_SOURCE_ID
    assert ready_normalized["adapterID"] == ADAPTER_IDS[READY_SOURCE_ID]
    assert ready_normalized["termsValidation"]["packable"] is True
    assert ready_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in ready_normalized["claims"]} == {"safety_reference"}
    assert all(claim["reviewRequirement"] is False for claim in ready_normalized["claims"])
    assert ready_normalized["apiLanes"]["fixtureMode"] == "no_network_static_ready_gov_emergency_kit_reference"

    energy_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{ENERGY_SOURCE_ID}.json")
    assert energy_normalized["sourceID"] == ENERGY_SOURCE_ID
    assert energy_normalized["adapterID"] == ADAPTER_IDS[ENERGY_SOURCE_ID]
    assert energy_normalized["termsValidation"]["packable"] is True
    assert energy_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in energy_normalized["claims"]} == {"maintenance_guidance_reference"}
    assert all(claim["reviewRequirement"] is False for claim in energy_normalized["claims"])
    assert energy_normalized["apiLanes"]["fixtureMode"] == "no_network_static_doe_energy_saver_home_reference"

    usagov_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{USAGOV_SOURCE_ID}.json")
    assert usagov_normalized["sourceID"] == USAGOV_SOURCE_ID
    assert usagov_normalized["adapterID"] == ADAPTER_IDS[USAGOV_SOURCE_ID]
    assert usagov_normalized["termsValidation"]["packable"] is True
    assert usagov_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in usagov_normalized["claims"]} == {"public_service_reference"}
    assert all(claim["reviewRequirement"] is False for claim in usagov_normalized["claims"])
    assert usagov_normalized["apiLanes"]["fixtureMode"] == "no_network_static_usagov_home_repair_public_reference"


def test_home_life_admin_frontier_reaches_claim_graph_ready_with_gold_set(tmp_path: Path):
    harvest = _harvest_home(tmp_path)
    result = _claim_frontier(tmp_path, Path(harvest["runRoot"]))

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["claims"] == 4
    assert result["recordCounts"]["packableClaims"] == 4
    assert result["recordCounts"]["blockedClaims"] == 0
    assert result["provenanceCompleteness"]["packablePercent"] == 1.0

    home = next(report for report in result["frontierReports"] if report["frontier_id"] == DOMAIN)
    assert home["status"] == "claim_graph_ready"
    assert home["status_ceiling"] == "pack_staging_ready"
    assert home["packable_claim_count"] == 4
    assert home["blocked_claim_count"] == 0
    assert home["missing_claim_classes"] == []
    assert home["authority_coverage"]["complete"] is True
    assert home["legal_posture_completeness"]["complete"] is True
    assert home["provenance_completeness"]["complete"] is True
    assert home["gold_set_status"] == "passed"
    assert home["gold_set"]["goldSetID"] == "gold.home_life_admin.ready_doe_usagov_public_reference.v1"
    assert home["gold_set"]["requiredCount"] == 4
    assert home["gold_set"]["matchedCount"] == 4
    assert home["gold_set"]["missing"] == []

    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    claims = [claim for claim in claim_graph["claims"] if claim["source_id"] in SOURCE_IDS]
    assert len(claims) == 4
    assert all(claim["pack_eligibility"] == "packable" for claim in claims)
    assert all(claim["provenance_tuple_complete"] for claim in claims)
    encoded = json.dumps([claim["object_value"] for claim in claims], sort_keys=True)
    assert "not emergency response advice" in encoded
    assert "not a contractor recommendation" in encoded
    assert "not a diagnosis of a private home condition" in encoded
    assert "not eligibility approval" in encoded


def test_home_life_admin_pack_production_dry_run_emits_public_r2_plan(tmp_path: Path):
    harvest = _harvest_home(tmp_path)
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
    assert result["recordCounts"]["claims"] == 4
    assert result["recordCounts"]["blockedClaimsExcluded"] == 0
    assert result["dryRunPlan"]["dryRun"] is True
    assert result["dryRunPlan"]["wouldUpload"] is False
    assert result["nonPrivateScan"]["passed"]
    assert all("/home_life_admin/" in key for key in result["objectKeys"].values())

    output_root = Path(result["outputRoot"])
    pack = read_json(output_root / "pack.json")
    manifest = read_json(output_root / "manifest.json")
    claims = read_json(output_root / "claims.json")["claims"]
    licenses = read_json(output_root / "licenses.json")["licenses"]
    attribution = read_json(output_root / "attribution.json")["attribution"]
    assert len(claims) == 4
    assert pack["claims"] == claims
    assert {license_row["license_id"] for license_row in licenses} == {
        "ready_public_web",
        "doe_public_web",
        "usagov_public_web",
    }
    assert len(attribution) == 4
    assert {row["license_id"] for row in attribution} == {
        "ready_public_web",
        "doe_public_web",
        "usagov_public_web",
    }
    assert pack["frontier_id"] == DOMAIN
    assert manifest["pack_id"].endswith(f"/{DOMAIN}/20260628T000000Z")
    assert manifest["revocation_manifest_key"].endswith("/revocations.json")
    assert manifest["lkg_pointer_key"].endswith("/lkg.json")
    assert "not production R2 readiness" in manifest["non_claims"]


def test_home_life_admin_adapters_output_no_private_or_final_user_artifacts(tmp_path: Path):
    result = _harvest_home(tmp_path)
    encoded = ""
    for source_id in SOURCE_IDS:
        encoded += json.dumps(read_json(Path(result["runRoot"]) / "normalized" / f"{source_id}.json"), sort_keys=True)

    assert result["privacyScan"]["passed"]
    assert "final_user_path" not in encoded
    assert "final_schedule" not in encoded
    assert "step_list" not in encoded
    assert "personalized_plan" not in encoded
    assert "private_goal_graph" not in encoded
    assert "not emergency response advice" in encoded
    assert "or a do-it-yourself repair plan" in encoded
    assert "not eligibility approval" in encoded


def test_home_life_admin_adapters_are_registered_once():
    matching = [adapter for adapter in adapter_instances() if adapter.source_id in SOURCE_IDS]

    assert len(matching) == 3
    assert {adapter.adapter_id for adapter in matching} == {
        "ready_gov_emergency_kit_adapter",
        "energy_gov_energy_saver_adapter",
        "usagov_home_repair_reference_adapter",
    }


def _harvest_home(tmp_path: Path) -> dict[str, object]:
    return run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="home-life-admin-fixture",
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
