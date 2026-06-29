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
CDC_SOURCE_ID = "cdc.positive_parenting"
ACF_SOURCE_ID = "acf.healthy_marriage_fatherhood"
CHILDWELFARE_SOURCE_ID = "childwelfare.family_support"
SOURCE_IDS = [CDC_SOURCE_ID, ACF_SOURCE_ID, CHILDWELFARE_SOURCE_ID]
DOMAIN = "relationships_family"


def test_relationships_family_fixture_adapters_are_governed_and_pack_candidate_ready(tmp_path: Path):
    result = _harvest_relationships_family(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for governed harvest runner"
    assert result["recordCounts"]["sourcesHarvested"] == 3
    assert result["recordCounts"]["claims"] == 5
    assert result["recordCounts"]["packCandidates"] == 3
    assert result["restrictedExclusions"] == []
    assert result["privacyScan"]["passed"]

    cdc_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{CDC_SOURCE_ID}.json")
    assert cdc_normalized["sourceID"] == CDC_SOURCE_ID
    assert cdc_normalized["adapterID"] == ADAPTER_IDS[CDC_SOURCE_ID]
    assert cdc_normalized["termsValidation"]["packable"] is True
    assert cdc_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in cdc_normalized["claims"]} == {
        "public_education_reference",
        "sensitive_support_reference",
    }
    assert cdc_normalized["apiLanes"]["fixtureMode"] == "no_network_static_cdc_positive_parenting_reference"

    acf_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{ACF_SOURCE_ID}.json")
    assert acf_normalized["sourceID"] == ACF_SOURCE_ID
    assert acf_normalized["adapterID"] == ADAPTER_IDS[ACF_SOURCE_ID]
    assert acf_normalized["termsValidation"]["packable"] is True
    assert acf_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in acf_normalized["claims"]} == {"public_family_service_reference"}
    assert "ACF WAF challenge" in acf_normalized["apiLanes"]["liveMode"]

    childwelfare_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{CHILDWELFARE_SOURCE_ID}.json")
    assert childwelfare_normalized["sourceID"] == CHILDWELFARE_SOURCE_ID
    assert childwelfare_normalized["adapterID"] == ADAPTER_IDS[CHILDWELFARE_SOURCE_ID]
    assert childwelfare_normalized["termsValidation"]["packable"] is True
    assert childwelfare_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in childwelfare_normalized["claims"]} == {"sensitive_support_reference"}


def test_relationships_family_frontier_reaches_claim_graph_ready_with_gold_set(tmp_path: Path):
    harvest = _harvest_relationships_family(tmp_path)
    result = _claim_frontier(tmp_path, Path(harvest["runRoot"]))

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["claims"] == 5
    assert result["recordCounts"]["packableClaims"] == 5
    assert result["recordCounts"]["blockedClaims"] == 0
    assert result["provenanceCompleteness"]["packablePercent"] == 1.0

    relationships = next(report for report in result["frontierReports"] if report["frontier_id"] == DOMAIN)
    assert relationships["status"] == "claim_graph_ready"
    assert relationships["status_ceiling"] == "pack_staging_ready"
    assert relationships["packable_claim_count"] == 5
    assert relationships["blocked_claim_count"] == 0
    assert relationships["missing_claim_classes"] == []
    assert relationships["authority_coverage"]["complete"] is True
    assert relationships["legal_posture_completeness"]["complete"] is True
    assert relationships["provenance_completeness"]["complete"] is True
    assert relationships["gold_set_status"] == "passed"
    assert relationships["gold_set"]["matchedCount"] == 3

    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    claims = [claim for claim in claim_graph["claims"] if claim["source_id"] in SOURCE_IDS]
    assert len(claims) == 5
    assert all(claim["pack_eligibility"] == "packable" for claim in claims)
    assert all(claim["provenance_tuple_complete"] for claim in claims)
    encoded = json.dumps([claim["object_value"] for claim in claims], sort_keys=True)
    assert "not therapy" in encoded
    assert "not legal custody advice" in encoded
    assert "personalized relationship plan" in encoded
    assert "emergency intervention" in encoded


def test_relationships_family_pack_production_dry_run_emits_public_r2_plan(tmp_path: Path):
    harvest = _harvest_relationships_family(tmp_path)
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
    assert result["recordCounts"]["claims"] == 5
    assert result["recordCounts"]["blockedClaimsExcluded"] == 0
    assert result["dryRunPlan"]["dryRun"] is True
    assert result["dryRunPlan"]["wouldUpload"] is False
    assert result["nonPrivateScan"]["passed"]
    assert all("/relationships_family/" in key for key in result["objectKeys"].values())

    output_root = Path(result["outputRoot"])
    pack = read_json(output_root / "pack.json")
    manifest = read_json(output_root / "manifest.json")
    claims = read_json(output_root / "claims.json")["claims"]
    licenses = read_json(output_root / "licenses.json")["licenses"]
    attribution = read_json(output_root / "attribution.json")["attribution"]
    assert len(claims) == 5
    assert pack["claims"] == claims
    assert {license_row["license_id"] for license_row in licenses} == {
        "acf_hmrf_public_web",
        "cdc_positive_parenting_public_web",
        "childwelfare_public_web",
    }
    assert {row["license_id"] for row in attribution} == {
        "acf_hmrf_public_web",
        "cdc_positive_parenting_public_web",
        "childwelfare_public_web",
    }
    assert pack["frontier_id"] == DOMAIN
    assert manifest["pack_id"].endswith(f"/{DOMAIN}/20260628T000000Z")
    assert manifest["revocation_manifest_key"].endswith("/revocations.json")
    assert manifest["lkg_pointer_key"].endswith("/lkg.json")
    assert "not production R2 readiness" in manifest["non_claims"]


def test_relationships_family_adapters_output_no_private_therapy_legal_or_final_user_artifacts(tmp_path: Path):
    result = _harvest_relationships_family(tmp_path)
    encoded = ""
    for source_id in SOURCE_IDS:
        encoded += json.dumps(read_json(Path(result["runRoot"]) / "normalized" / f"{source_id}.json"), sort_keys=True)

    assert result["privacyScan"]["passed"]
    assert "final_user_path" not in encoded
    assert "final_schedule" not in encoded
    assert "step_list" not in encoded
    assert "personalized_plan" not in encoded
    assert "private_goal_graph" not in encoded
    assert "doesNotCreateTherapy" in encoded
    assert "doesNotCreateLegalCustodyAdvice" in encoded
    assert "doesNotCreateRelationshipJudgment" in encoded
    assert "doesNotCreatePersonalizedFamilyAssessment" in encoded


def test_relationships_family_adapters_are_registered_once():
    matching = [adapter for adapter in adapter_instances() if adapter.source_id in SOURCE_IDS]

    assert len(matching) == 3
    assert {adapter.adapter_id for adapter in matching} == {
        "cdc_positive_parenting_reference_adapter",
        "acf_healthy_marriage_fatherhood_reference_adapter",
        "childwelfare_family_support_reference_adapter",
    }


def _harvest_relationships_family(tmp_path: Path) -> dict[str, object]:
    return run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="relationships-family-reference-fixture",
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
