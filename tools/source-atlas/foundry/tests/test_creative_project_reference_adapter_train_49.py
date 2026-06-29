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
CC_SOURCE_ID = "creative-commons.licenses"
W3C_SOURCE_ID = "w3c.web-standards"
LOC_SOURCE_ID = "loc.primary_sources"
SOURCE_IDS = [CC_SOURCE_ID, W3C_SOURCE_ID, LOC_SOURCE_ID]
DOMAIN = "creative_project_reference"


def test_creative_project_reference_fixture_adapters_are_governed_and_pack_candidate_ready(tmp_path: Path):
    result = _harvest_creative(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for governed harvest runner"
    assert result["recordCounts"]["sourcesHarvested"] == 3
    assert result["recordCounts"]["claims"] == 3
    assert result["recordCounts"]["packCandidates"] == 3
    assert result["restrictedExclusions"] == []
    assert result["privacyScan"]["passed"]

    cc_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{CC_SOURCE_ID}.json")
    assert cc_normalized["sourceID"] == CC_SOURCE_ID
    assert cc_normalized["adapterID"] == ADAPTER_IDS[CC_SOURCE_ID]
    assert cc_normalized["termsValidation"]["packable"] is True
    assert cc_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in cc_normalized["claims"]} == {"creative_metadata_reference"}
    assert all(claim["reviewRequirement"] is False for claim in cc_normalized["claims"])
    assert cc_normalized["apiLanes"]["fixtureMode"] == "no_network_static_creative_commons_license_reference"

    w3c_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{W3C_SOURCE_ID}.json")
    assert w3c_normalized["sourceID"] == W3C_SOURCE_ID
    assert w3c_normalized["adapterID"] == ADAPTER_IDS[W3C_SOURCE_ID]
    assert w3c_normalized["termsValidation"]["packable"] is True
    assert w3c_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in w3c_normalized["claims"]} == {"public_standard_reference"}
    assert all(claim["reviewRequirement"] is False for claim in w3c_normalized["claims"])
    assert w3c_normalized["apiLanes"]["fixtureMode"] == "no_network_static_w3c_web_standards_reference"

    loc_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{LOC_SOURCE_ID}.json")
    assert loc_normalized["sourceID"] == LOC_SOURCE_ID
    assert loc_normalized["adapterID"] == ADAPTER_IDS[LOC_SOURCE_ID]
    assert loc_normalized["termsValidation"]["packable"] is True
    assert loc_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in loc_normalized["claims"]} == {"public_learning_resource"}
    assert all(claim["reviewRequirement"] is False for claim in loc_normalized["claims"])
    assert loc_normalized["apiLanes"]["fixtureMode"] == "no_network_static_loc_primary_sources_learning_reference"


def test_creative_project_reference_frontier_reaches_claim_graph_ready_with_gold_set(tmp_path: Path):
    harvest = _harvest_creative(tmp_path)
    result = _claim_frontier(tmp_path, Path(harvest["runRoot"]))

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["claims"] == 3
    assert result["recordCounts"]["packableClaims"] == 3
    assert result["recordCounts"]["blockedClaims"] == 0
    assert result["provenanceCompleteness"]["packablePercent"] == 1.0

    creative = next(report for report in result["frontierReports"] if report["frontier_id"] == DOMAIN)
    assert creative["status"] == "claim_graph_ready"
    assert creative["status_ceiling"] == "pack_staging_ready"
    assert creative["packable_claim_count"] == 3
    assert creative["blocked_claim_count"] == 0
    assert creative["missing_claim_classes"] == []
    assert creative["authority_coverage"]["complete"] is True
    assert creative["legal_posture_completeness"]["complete"] is True
    assert creative["provenance_completeness"]["complete"] is True
    assert creative["gold_set_status"] == "passed"
    assert creative["gold_set"]["goldSetID"] == "gold.creative_project_reference.cc_w3c_loc_public_reference.v1"
    assert creative["gold_set"]["requiredCount"] == 3
    assert creative["gold_set"]["matchedCount"] == 3
    assert creative["gold_set"]["missing"] == []

    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    claims = [claim for claim in claim_graph["claims"] if claim["source_id"] in SOURCE_IDS]
    assert len(claims) == 3
    assert all(claim["pack_eligibility"] == "packable" for claim in claims)
    assert all(claim["provenance_tuple_complete"] for claim in claims)
    encoded = json.dumps([claim["object_value"] for claim in claims], sort_keys=True)
    assert "not copyright permission" in encoded
    assert "not implementation advice" in encoded
    assert "not copyright clearance" in encoded
    assert "final creative project plan" in encoded


def test_creative_project_reference_pack_production_dry_run_emits_public_r2_plan(tmp_path: Path):
    harvest = _harvest_creative(tmp_path)
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
    assert all("/creative_project_reference/" in key for key in result["objectKeys"].values())

    output_root = Path(result["outputRoot"])
    pack = read_json(output_root / "pack.json")
    manifest = read_json(output_root / "manifest.json")
    claims = read_json(output_root / "claims.json")["claims"]
    licenses = read_json(output_root / "licenses.json")["licenses"]
    attribution = read_json(output_root / "attribution.json")["attribution"]
    assert len(claims) == 3
    assert pack["claims"] == claims
    assert {license_row["license_id"] for license_row in licenses} == {
        "creativecommons_site_cc_by_4_cc0_tools",
        "w3c_document_license_public_web",
        "loc_usgov_work",
    }
    assert len(attribution) == 3
    assert {row["license_id"] for row in attribution} == {
        "creativecommons_site_cc_by_4_cc0_tools",
        "w3c_document_license_public_web",
        "loc_usgov_work",
    }
    assert pack["frontier_id"] == DOMAIN
    assert manifest["pack_id"].endswith(f"/{DOMAIN}/20260628T000000Z")
    assert manifest["revocation_manifest_key"].endswith("/revocations.json")
    assert manifest["lkg_pointer_key"].endswith("/lkg.json")
    assert "not production R2 readiness" in manifest["non_claims"]


def test_creative_project_reference_adapters_output_no_private_or_final_user_artifacts(tmp_path: Path):
    result = _harvest_creative(tmp_path)
    encoded = ""
    for source_id in SOURCE_IDS:
        encoded += json.dumps(read_json(Path(result["runRoot"]) / "normalized" / f"{source_id}.json"), sort_keys=True)

    assert result["privacyScan"]["passed"]
    assert "final_user_path" not in encoded
    assert "final_schedule" not in encoded
    assert "step_list" not in encoded
    assert "personalized_plan" not in encoded
    assert "private_goal_graph" not in encoded
    assert "not copyright permission" in encoded
    assert "not implementation advice" in encoded
    assert "not copyright clearance" in encoded


def test_creative_project_reference_adapters_are_registered_once():
    matching = [adapter for adapter in adapter_instances() if adapter.source_id in SOURCE_IDS]

    assert len(matching) == 3
    assert {adapter.adapter_id for adapter in matching} == {
        "creative_commons_licenses_reference_adapter",
        "w3c_web_standards_reference_adapter",
        "library_of_congress_primary_sources_reference_adapter",
    }


def _harvest_creative(tmp_path: Path) -> dict[str, object]:
    return run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="creative-project-reference-fixture",
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
