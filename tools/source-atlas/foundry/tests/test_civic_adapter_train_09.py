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


CREATED_AT = "2026-06-27T00:00:00Z"
SOURCE_ID = "nara.constitution.presidency"
DOMAIN = "public_civic_requirements"


def test_nara_civic_adapter_fixture_is_governed_and_pack_candidate_ready(tmp_path: Path):
    result = _harvest_nara(tmp_path)

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["sourcesHarvested"] == 1
    assert result["recordCounts"]["claims"] == 2
    assert result["recordCounts"]["packCandidates"] == 1
    assert result["restrictedExclusions"] == []
    assert result["privacyScan"]["passed"]

    normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{SOURCE_ID}.json")
    assert normalized["sourceID"] == SOURCE_ID
    assert normalized["adapterID"] == ADAPTER_IDS[SOURCE_ID]
    assert normalized["termsValidation"]["packable"] is True
    assert normalized["termsValidation"]["r2Ready"] is True
    assert normalized["termsValidation"]["r2PackPolicy"] == "r2_pack_allowed"
    assert {claim["claimType"] for claim in normalized["claims"]} == {"constitutional_requirement", "eligibility_requirement"}
    assert all(claim["reviewRequirement"] is False for claim in normalized["claims"])
    assert normalized["packCandidates"]


def test_public_civic_frontier_compiles_packable_claims_with_complete_provenance(tmp_path: Path):
    harvest = _harvest_nara(tmp_path)
    result = _claim_frontier(tmp_path, Path(harvest["runRoot"]))

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["claims"] == 2
    assert result["recordCounts"]["packableClaims"] == 2
    assert result["recordCounts"]["blockedClaims"] == 0
    assert result["provenanceCompleteness"]["packablePercent"] == 1.0

    public_civic = next(report for report in result["frontierReports"] if report["frontier_id"] == DOMAIN)
    assert public_civic["status"] == "claim_graph_ready"
    assert public_civic["packable_claim_count"] == 2
    assert public_civic["blocked_claim_count"] == 0
    assert public_civic["legal_posture_completeness"]["complete"] is True
    assert public_civic["provenance_completeness"]["complete"] is True
    assert public_civic["gold_set_status"] == "passed"
    assert public_civic["gold_set"]["goldSetID"] == "gold.public_civic_requirements.us_presidential_eligibility.v1"
    assert public_civic["gold_set"]["requiredCount"] == 2
    assert public_civic["gold_set"]["matchedCount"] == 2
    assert public_civic["gold_set"]["missing"] == []

    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    claims = [claim for claim in claim_graph["claims"] if claim["source_id"] == SOURCE_ID]
    assert len(claims) == 2
    assert all(claim["pack_eligibility"] == "packable" for claim in claims)
    assert all(claim["provenance_tuple_complete"] for claim in claims)
    assert "not legal advice" in json.dumps(public_civic["non_claims"])


def test_public_civic_pack_production_dry_run_emits_public_r2_plan(tmp_path: Path):
    harvest = _harvest_nara(tmp_path)
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
    assert result["recordCounts"]["claims"] == 2
    assert result["recordCounts"]["blockedClaimsExcluded"] == 0
    assert result["dryRunPlan"]["dryRun"] is True
    assert result["dryRunPlan"]["wouldUpload"] is False
    assert result["nonPrivateScan"]["passed"]
    assert all("/public_civic_requirements/" in key for key in result["objectKeys"].values())

    output_root = Path(result["outputRoot"])
    pack = read_json(output_root / "pack.json")
    manifest = read_json(output_root / "manifest.json")
    claims = read_json(output_root / "claims.json")["claims"]
    licenses = read_json(output_root / "licenses.json")["licenses"]
    attribution = read_json(output_root / "attribution.json")["attribution"]
    assert len(claims) == 2
    assert pack["claims"] == claims
    assert licenses and licenses[0]["license_id"] == "us_federal_public_source"
    assert attribution
    assert pack["frontier_id"] == DOMAIN
    assert manifest["pack_id"].endswith(f"/{DOMAIN}/20260627T000000Z")
    assert manifest["revocation_manifest_key"].endswith("/revocations.json")
    assert manifest["lkg_pointer_key"].endswith("/lkg.json")
    assert "not production R2 readiness" in manifest["non_claims"]


def test_nara_civic_adapter_outputs_no_private_or_final_user_artifacts(tmp_path: Path):
    result = _harvest_nara(tmp_path)
    normalized = read_json(Path(result["runRoot"]) / "normalized" / f"{SOURCE_ID}.json")
    encoded = json.dumps(normalized, sort_keys=True)

    assert result["privacyScan"]["passed"]
    assert "final_user_path" not in encoded
    assert "final_schedule" not in encoded
    assert "step_list" not in encoded
    assert "personalized_plan" not in encoded
    assert "private_goal_graph" not in encoded
    assert "legal advice" not in " ".join(claim["text"].lower() for claim in normalized["claims"])


def test_nara_civic_adapter_is_registered_once():
    matching = [adapter for adapter in adapter_instances() if adapter.source_id == SOURCE_ID]

    assert len(matching) == 1
    assert matching[0].adapter_id == "nara_constitution_civic_adapter"


def _harvest_nara(tmp_path: Path) -> dict[str, object]:
    return run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="nara-civic-fixture",
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
