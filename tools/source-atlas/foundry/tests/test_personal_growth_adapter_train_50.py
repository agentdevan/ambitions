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
MEDLINE_SOURCE_ID = "nih.medlineplus.wellness"
OPENALEX_SOURCE_ID = "openalex.personal_growth_research"
SOURCE_IDS = [MEDLINE_SOURCE_ID, OPENALEX_SOURCE_ID]
DOMAIN = "personal_growth"


def test_personal_growth_fixture_adapters_are_governed_and_pack_candidate_ready(tmp_path: Path):
    result = _harvest_personal_growth(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for governed harvest runner"
    assert result["recordCounts"]["sourcesHarvested"] == 2
    assert result["recordCounts"]["claims"] == 3
    assert result["recordCounts"]["packCandidates"] == 2
    assert result["restrictedExclusions"] == []
    assert result["privacyScan"]["passed"]

    medline_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{MEDLINE_SOURCE_ID}.json")
    assert medline_normalized["sourceID"] == MEDLINE_SOURCE_ID
    assert medline_normalized["adapterID"] == ADAPTER_IDS[MEDLINE_SOURCE_ID]
    assert medline_normalized["termsValidation"]["packable"] is True
    assert medline_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in medline_normalized["claims"]} == {
        "public_learning_reference",
        "sensitive_wellness_reference",
    }
    assert all(claim["reviewRequirement"] is False for claim in medline_normalized["claims"])
    assert medline_normalized["apiLanes"]["fixtureMode"] == "no_network_static_medlineplus_wellness_reference"

    openalex_normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{OPENALEX_SOURCE_ID}.json")
    assert openalex_normalized["sourceID"] == OPENALEX_SOURCE_ID
    assert openalex_normalized["adapterID"] == ADAPTER_IDS[OPENALEX_SOURCE_ID]
    assert openalex_normalized["termsValidation"]["packable"] is True
    assert openalex_normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in openalex_normalized["claims"]} == {"research_metadata_reference"}
    assert all(claim["reviewRequirement"] is False for claim in openalex_normalized["claims"])
    assert openalex_normalized["apiLanes"]["fixtureMode"] == "no_network_static_openalex_personal_growth_metadata_reference"


def test_personal_growth_frontier_reaches_claim_graph_ready(tmp_path: Path):
    harvest = _harvest_personal_growth(tmp_path)
    result = _claim_frontier(tmp_path, Path(harvest["runRoot"]))

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["claims"] == 3
    assert result["recordCounts"]["packableClaims"] == 3
    assert result["recordCounts"]["blockedClaims"] == 0
    assert result["provenanceCompleteness"]["packablePercent"] == 1.0

    personal = next(report for report in result["frontierReports"] if report["frontier_id"] == DOMAIN)
    assert personal["status"] == "claim_graph_ready"
    assert personal["status_ceiling"] == "pack_staging_ready"
    assert personal["packable_claim_count"] == 3
    assert personal["blocked_claim_count"] == 0
    assert personal["missing_claim_classes"] == []
    assert personal["authority_coverage"]["complete"] is True
    assert personal["legal_posture_completeness"]["complete"] is True
    assert personal["provenance_completeness"]["complete"] is True
    assert personal["gold_set_status"] == "not_required"

    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    claims = [claim for claim in claim_graph["claims"] if claim["source_id"] in SOURCE_IDS]
    assert len(claims) == 3
    assert all(claim["pack_eligibility"] == "packable" for claim in claims)
    assert all(claim["provenance_tuple_complete"] for claim in claims)
    encoded = json.dumps([claim["object_value"] for claim in claims], sort_keys=True)
    assert "not mental health treatment" in encoded
    assert "not diagnosis" in encoded
    assert "not normative authority" in encoded
    assert "final personal-growth plan" in encoded


def test_personal_growth_pack_production_dry_run_emits_public_r2_plan(tmp_path: Path):
    harvest = _harvest_personal_growth(tmp_path)
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
    assert all("/personal_growth/" in key for key in result["objectKeys"].values())

    output_root = Path(result["outputRoot"])
    pack = read_json(output_root / "pack.json")
    manifest = read_json(output_root / "manifest.json")
    claims = read_json(output_root / "claims.json")["claims"]
    licenses = read_json(output_root / "licenses.json")["licenses"]
    attribution = read_json(output_root / "attribution.json")["attribution"]
    assert len(claims) == 3
    assert pack["claims"] == claims
    assert {license_row["license_id"] for license_row in licenses} == {
        "medlineplus_public_domain_topic_summary",
        "openalex_cc0_metadata",
    }
    assert {row["license_id"] for row in attribution} == {"medlineplus_public_domain_topic_summary"}
    assert pack["frontier_id"] == DOMAIN
    assert manifest["pack_id"].endswith(f"/{DOMAIN}/20260628T000000Z")
    assert manifest["revocation_manifest_key"].endswith("/revocations.json")
    assert manifest["lkg_pointer_key"].endswith("/lkg.json")
    assert "not production R2 readiness" in manifest["non_claims"]


def test_personal_growth_adapters_output_no_private_clinical_or_final_user_artifacts(tmp_path: Path):
    result = _harvest_personal_growth(tmp_path)
    encoded = ""
    for source_id in SOURCE_IDS:
        encoded += json.dumps(read_json(Path(result["runRoot"]) / "normalized" / f"{source_id}.json"), sort_keys=True)

    assert result["privacyScan"]["passed"]
    assert "final_user_path" not in encoded
    assert "final_schedule" not in encoded
    assert "step_list" not in encoded
    assert "personalized_plan" not in encoded
    assert "private_goal_graph" not in encoded
    assert "doesNotCreateMentalHealthTreatment" in encoded
    assert "doesNotCreateDiagnosis" in encoded
    assert "doesNotCreateCloudPersonalizedPlan" in encoded
    assert "doesNotCreateNormativeAuthority" in encoded


def test_personal_growth_adapters_are_registered_once():
    matching = [adapter for adapter in adapter_instances() if adapter.source_id in SOURCE_IDS]

    assert len(matching) == 2
    assert {adapter.adapter_id for adapter in matching} == {
        "nih_medlineplus_wellness_reference_adapter",
        "openalex_personal_growth_research_adapter",
    }


def _harvest_personal_growth(tmp_path: Path) -> dict[str, object]:
    return run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="personal-growth-reference-fixture",
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
