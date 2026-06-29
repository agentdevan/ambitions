from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.claim_frontier import DEFAULT_FRONTIER_CONFIG_PATH, ClaimFrontierOptions, compile_claim_frontier
from foundry.harvest_runner import GovernedHarvestOptions, run_governed_harvest
from foundry.model import read_json
from foundry.pack_production import PackProductionOptions, build_pack_production
from foundry.public_reference_adapters import ADAPTER_IDS, adapter_instances
from foundry.volunteering_public_reference_activation import (
    DOMAIN,
    SOURCE_ID,
    VolunteeringPublicReferenceActivationOptions,
    run_volunteering_public_reference_activation,
)


CREATED_AT = "2026-06-29T05:30:00Z"


def test_americorps_volunteering_fixture_adapter_is_governed_and_pack_candidate_ready(tmp_path: Path):
    result = _harvest_americorps(tmp_path)

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for governed harvest runner"
    assert result["recordCounts"]["sourcesHarvested"] == 1
    assert result["recordCounts"]["claims"] == 3
    assert result["recordCounts"]["packCandidates"] == 1
    assert result["restrictedExclusions"] == []
    assert result["privacyScan"]["passed"]

    normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{SOURCE_ID}.json")
    assert normalized["sourceID"] == SOURCE_ID
    assert normalized["adapterID"] == ADAPTER_IDS[SOURCE_ID]
    assert normalized["domain"] == DOMAIN
    assert normalized["termsValidation"]["packable"] is True
    assert normalized["termsValidation"]["r2Ready"] is True
    assert {claim["claimType"] for claim in normalized["claims"]} == {
        "civic_engagement_reference",
        "public_dataset_scope_reference",
        "volunteer_rate_reference",
    }
    assert normalized["apiLanes"]["liveMode"] == "requires_live_flag_execute_flag_and_socrata_public_dataset_budget"
    assert normalized["packCandidates"]


def test_volunteering_frontier_staged_config_reaches_claim_graph_ready(tmp_path: Path):
    harvest = _harvest_americorps(tmp_path)
    staged_frontier = _write_staged_frontier(tmp_path)
    result = _claim_frontier(tmp_path, Path(harvest["runRoot"]), staged_frontier)

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["claims"] == 3
    assert result["recordCounts"]["packableClaims"] == 3
    assert result["recordCounts"]["blockedClaims"] == 0
    assert result["provenanceCompleteness"]["packablePercent"] == 1.0

    volunteering = next(report for report in result["frontierReports"] if report["frontier_id"] == DOMAIN)
    assert volunteering["status"] == "claim_graph_ready"
    assert volunteering["status_ceiling"] == "pack_staging_ready"
    assert volunteering["packable_claim_count"] == 3
    assert volunteering["blocked_claim_count"] == 0
    assert volunteering["missing_claim_classes"] == []
    assert volunteering["authority_coverage"]["complete"] is True
    assert volunteering["legal_posture_completeness"]["complete"] is True
    assert volunteering["provenance_completeness"]["complete"] is True
    assert volunteering["gold_set_status"] == "passed"
    assert volunteering["gold_set"]["goldSetID"] == "gold.volunteering_public_reference.americorps_state_volunteer_rate.v1"
    assert volunteering["gold_set"]["matchedCount"] == 3

    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    claims = [claim for claim in claim_graph["claims"] if claim["source_id"] == SOURCE_ID]
    assert len(claims) == 3
    assert all(claim["pack_eligibility"] == "packable" for claim in claims)
    assert all(claim["provenance_tuple_complete"] for claim in claims)
    encoded = json.dumps([claim["object_value"] for claim in claims], sort_keys=True)
    assert "not as a current opportunity listing" in encoded
    assert "not as service-program legal advice" in encoded
    assert "real-time volunteer opportunity availability" in encoded


def test_volunteering_pack_production_dry_run_emits_public_r2_plan(tmp_path: Path):
    harvest = _harvest_americorps(tmp_path)
    frontier = _claim_frontier(tmp_path, Path(harvest["runRoot"]), _write_staged_frontier(tmp_path))
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
    assert all(f"/{DOMAIN}/" in key for key in result["objectKeys"].values())

    output_root = Path(result["outputRoot"])
    pack = read_json(output_root / "pack.json")
    claims = read_json(output_root / "claims.json")["claims"]
    licenses = read_json(output_root / "licenses.json")["licenses"]
    manifest = read_json(output_root / "manifest.json")
    assert len(claims) == 3
    assert pack["claims"] == claims
    assert licenses and licenses[0]["license_id"] == "americorps_public_domain"
    assert pack["frontier_id"] == DOMAIN
    assert manifest["pack_id"].endswith(f"/{DOMAIN}/20260629T053000Z")
    assert "not production R2 readiness" in manifest["non_claims"]


def test_volunteering_public_reference_activation_generates_staged_end_to_end_evidence(tmp_path: Path):
    result = run_volunteering_public_reference_activation(
        VolunteeringPublicReferenceActivationOptions(
            output_root=tmp_path / "activation",
            created_at=CREATED_AT,
            run_label="test",
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for volunteering public-reference staged activation"
    assert result["recordCounts"]["packClaims"] == 3
    assert result["frontierReport"]["gold_set_status"] == "passed"
    assert result["frontierReport"]["status"] == "claim_graph_ready"
    assert result["productionR2Executed"] is False
    assert result["nativeRuntimeChanged"] is False
    assert result["outsideLegalApprovalClaimed"] is False
    assert result["activeCoverageFrontierMutations"] == 0
    assert Path(result["outputPaths"]["closeout"]).exists()
    assert "not current volunteer opportunity availability" in result["nonClaims"]

    staged_frontier = read_json(Path(result["outputPaths"]["stagedFrontierConfig"]))
    assert any(frontier["frontier_id"] == DOMAIN for frontier in staged_frontier["frontiers"])
    active_frontier = read_json(DEFAULT_FRONTIER_CONFIG_PATH)
    assert any(frontier["frontier_id"] == DOMAIN for frontier in active_frontier["frontiers"])


def test_americorps_volunteering_adapter_outputs_no_private_or_final_user_artifacts(tmp_path: Path):
    result = _harvest_americorps(tmp_path)
    normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{SOURCE_ID}.json")
    encoded = json.dumps(normalized, sort_keys=True)

    assert result["privacyScan"]["passed"]
    assert "final_user_path" not in encoded
    assert "final_schedule" not in encoded
    assert "step_list" not in encoded
    assert "personalized_plan" not in encoded
    assert "private_goal_graph" not in encoded
    assert "current opportunity listing" in encoded
    assert "personalized placement recommendation" in encoded


def test_americorps_volunteering_adapter_is_registered_once():
    matching = [adapter for adapter in adapter_instances() if adapter.source_id == SOURCE_ID]

    assert len(matching) == 1
    assert matching[0].adapter_id == "americorps_volunteer_rate_state_adapter"


def _harvest_americorps(tmp_path: Path) -> dict[str, object]:
    return run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="americorps-volunteer-rate-fixture",
            mode="fixture",
            source_ids=[SOURCE_ID],
            limit=6,
            created_at=CREATED_AT,
        ),
        env={},
    )


def _claim_frontier(tmp_path: Path, run_root: Path, staged_frontier: Path) -> dict[str, object]:
    return compile_claim_frontier(
        ClaimFrontierOptions(
            input_root=run_root,
            output_root=tmp_path / "claim-frontier",
            frontier_config_path=staged_frontier,
            created_at=CREATED_AT,
        )
    )


def _write_staged_frontier(tmp_path: Path) -> Path:
    from foundry.volunteering_public_reference_activation import _write_staged_frontier_config

    staged_frontier = tmp_path / "staged-coverage-frontiers.json"
    _write_staged_frontier_config(DEFAULT_FRONTIER_CONFIG_PATH, staged_frontier)
    return staged_frontier
