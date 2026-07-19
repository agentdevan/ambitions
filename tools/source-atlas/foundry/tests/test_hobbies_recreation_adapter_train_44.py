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
SOURCE_ID = "nps.recreation-safety"
DOMAIN = "hobbies_recreation"


def test_nps_recreation_safety_fixture_adapter_is_governed_and_pack_candidate_ready(tmp_path: Path):
    result = _harvest_nps(tmp_path)

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
    assert normalized["termsValidation"]["packable"] is True
    assert normalized["termsValidation"]["r2Ready"] is True
    assert normalized["termsValidation"]["r2PackPolicy"] == "r2_pack_allowed"
    assert {claim["claimType"] for claim in normalized["claims"]} == {
        "learning_resource_reference",
        "public_rules_reference",
        "safety_guidance_reference",
    }
    assert all(claim["reviewRequirement"] is False for claim in normalized["claims"])
    assert normalized["packCandidates"]
    assert normalized["apiLanes"]["fixtureMode"] == "no_network_static_nps_public_reference"


def test_hobbies_recreation_frontier_reaches_claim_graph_ready_with_nps_gold_set(tmp_path: Path):
    harvest = _harvest_nps(tmp_path)
    result = _claim_frontier(tmp_path, Path(harvest["runRoot"]))

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["claims"] == 3
    assert result["recordCounts"]["packableClaims"] == 3
    assert result["recordCounts"]["blockedClaims"] == 0
    assert result["provenanceCompleteness"]["packablePercent"] == 1.0

    hobbies = next(report for report in result["frontierReports"] if report["frontier_id"] == DOMAIN)
    assert hobbies["status"] == "claim_graph_ready"
    assert hobbies["status_ceiling"] == "pack_staging_ready"
    assert hobbies["packable_claim_count"] == 3
    assert hobbies["blocked_claim_count"] == 0
    assert hobbies["missing_claim_classes"] == []
    assert hobbies["authority_coverage"]["complete"] is True
    assert hobbies["legal_posture_completeness"]["complete"] is True
    assert hobbies["provenance_completeness"]["complete"] is True
    assert hobbies["gold_set_status"] == "passed"
    assert hobbies["gold_set"]["goldSetID"] == "gold.hobbies_recreation.nps_health_safety_public_reference.v1"
    assert hobbies["gold_set"]["requiredCount"] == 3
    assert hobbies["gold_set"]["matchedCount"] == 3
    assert hobbies["gold_set"]["missing"] == []

    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    claims = [claim for claim in claim_graph["claims"] if claim["source_id"] == SOURCE_ID]
    assert len(claims) == 3
    assert all(claim["pack_eligibility"] == "packable" for claim in claims)
    assert all(claim["provenance_tuple_complete"] for claim in claims)
    encoded = json.dumps([claim["object_value"] for claim in claims], sort_keys=True)
    assert "not emergency advice" in encoded
    assert "not unsafe instructions" in encoded
    assert "general reference only" in encoded


def test_hobbies_recreation_pack_production_dry_run_emits_public_r2_plan(tmp_path: Path):
    harvest = _harvest_nps(tmp_path)
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
    assert all("/hobbies_recreation/" in key for key in result["objectKeys"].values())

    output_root = Path(result["outputRoot"])
    pack = read_json(output_root / "pack.json")
    manifest = read_json(output_root / "manifest.json")
    claims = read_json(output_root / "claims.json")["claims"]
    licenses = read_json(output_root / "licenses.json")["licenses"]
    attribution = read_json(output_root / "attribution.json")["attribution"]
    assert len(claims) == 3
    assert pack["claims"] == claims
    assert licenses and licenses[0]["license_id"] == "nps_public_web"
    assert attribution
    assert pack["frontier_id"] == DOMAIN
    assert manifest["pack_id"].endswith(f"/{DOMAIN}/20260628T000000Z")
    assert manifest["revocation_manifest_key"].endswith("/revocations.json")
    assert manifest["lkg_pointer_key"].endswith("/lkg.json")
    assert "not production R2 readiness" in manifest["non_claims"]


def test_nps_recreation_safety_adapter_outputs_no_private_or_final_user_artifacts(tmp_path: Path):
    result = _harvest_nps(tmp_path)
    normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{SOURCE_ID}.json")
    encoded = json.dumps(normalized, sort_keys=True)

    assert result["privacyScan"]["passed"]
    assert "final_user_path" not in encoded
    assert "final_schedule" not in encoded
    assert "step_list" not in encoded
    assert "personalized_plan" not in encoded
    assert "private_goal_graph" not in encoded
    assert "emergency advice" in " ".join(claim["text"].lower() for claim in normalized["claims"])
    assert "unsafe instructions" in " ".join(claim["text"].lower() for claim in normalized["claims"])


def test_nps_recreation_safety_adapter_is_registered_once():
    matching = [adapter for adapter in adapter_instances() if adapter.source_id == SOURCE_ID]

    assert len(matching) == 1
    assert matching[0].adapter_id == "nps_recreation_safety_adapter"


def _harvest_nps(tmp_path: Path) -> dict[str, object]:
    return run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="nps-recreation-safety-fixture",
            mode="fixture",
            source_ids=[SOURCE_ID],
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
