from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.claim_frontier import ClaimFrontierOptions, compile_claim_frontier
from foundry.harvest_runner import GovernedHarvestOptions, run_governed_harvest
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-27T00:00:00Z"


def test_claim_frontier_compiles_packable_claims_with_complete_provenance(tmp_path: Path):
    run_root = _harvest_fixture(tmp_path, ["onet.database", "bls.public.data.api", "openalex.dataset", "wikidata.crosswalk", "usajobs.search"], limit=3)
    result = compile_claim_frontier(
        ClaimFrontierOptions(
            input_root=run_root,
            output_root=tmp_path / "claim-frontier",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for claim/frontier tooling"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; claim graph and coverage frontier tooling only"
    assert result["recordCounts"]["packableClaims"] > 0
    assert result["provenanceCompleteness"]["packablePercent"] == 1.0
    assert next(check for check in result["checks"] if check["name"] == "packable_claims_have_complete_provenance_tuple")["passed"]

    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    packable = [claim for claim in claim_graph["claims"] if claim["pack_eligibility"] == "packable"]
    assert packable
    assert all(claim["source_lane"] and claim["locator"] and claim["retrieval_time"] and claim["evidence_hash"] and claim["adjudication_rule"] for claim in packable)
    assert "not production R2 readiness" in claim_graph["nonClaims"]


def test_adapter_provenance_ids_match_emitted_provenance_records(tmp_path: Path):
    run_root = _harvest_fixture(tmp_path, ["onet.database"], limit=1)
    normalized = read_json(run_root / "normalized" / "onet.database.json")

    emitted_id = normalized["provenance"][0]["id"]
    assert normalized["claims"][0]["provenanceIDs"] == [emitted_id]


def test_claim_frontier_missing_provenance_blocks_pack_output(tmp_path: Path):
    run_root = _harvest_fixture(tmp_path, ["onet.database"], limit=1)
    normalized_path = run_root / "normalized" / "onet.database.json"
    normalized = read_json(normalized_path)
    normalized["claims"][0]["provenanceIDs"] = ["provenance.missing"]
    write_json(normalized_path, normalized)

    result = compile_claim_frontier(
        ClaimFrontierOptions(
            input_root=run_root,
            output_root=tmp_path / "claim-frontier",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    claim = next(claim for claim in claim_graph["claims"] if "missing_provenance_record" in claim["blocked_reasons"])
    assert claim["pack_eligibility"] == "blocked_missing_provenance"
    assert "missing_provenance_record" in claim["blocked_reasons"]
    assert "missing_provenance_tuple" in claim["blocked_reasons"]


def test_claim_frontier_excludes_restricted_and_crosswalk_only_sources(tmp_path: Path):
    run_root = _harvest_fixture(tmp_path, ["wikidata.crosswalk", "usajobs.search"], limit=2)
    result = compile_claim_frontier(
        ClaimFrontierOptions(
            input_root=run_root,
            output_root=tmp_path / "claim-frontier",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert next(check for check in result["checks"] if check["name"] == "restricted_sources_excluded_from_packable_claims")["passed"]
    assert next(check for check in result["checks"] if check["name"] == "crosswalk_only_sources_excluded_from_regulated_authority")["passed"]

    claim_graph = read_json(Path(result["outputRoot"]) / "claim-graph.json")
    assert all(claim["pack_eligibility"] != "packable" for claim in claim_graph["claims"])
    assert any(item["sourceID"] == "usajobs.search" for item in result["restrictedExclusions"])
    assert any(item["sourceID"] == "wikidata.crosswalk" for item in result["restrictedExclusions"])


def test_frontier_reports_keep_candidate_domains_below_pack_readiness(tmp_path: Path):
    run_root = _harvest_fixture(tmp_path, ["onet.database", "bls.public.data.api", "openalex.dataset", "wikidata.crosswalk", "usajobs.search"], limit=3)
    result = compile_claim_frontier(
        ClaimFrontierOptions(
            input_root=run_root,
            output_root=tmp_path / "claim-frontier",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    forbidden = {"pack_staging_ready", "r2_stable_ready", "app_runtime_ready", "production_ready"}
    assert next(check for check in result["checks"] if check["name"] == "candidate_only_frontiers_do_not_claim_pack_readiness")["passed"]
    assert all(report["status"] not in forbidden for report in result["frontierReports"])
    occupation = next(report for report in result["frontierReports"] if report["frontier_id"] == "occupation_foundation")
    assert occupation["status"] == "claim_graph_ready"
    assert occupation["packable_claim_count"] > 0
    education = next(report for report in result["frontierReports"] if report["frontier_id"] == "education_credentialing")
    assert education["status"] in {"candidate_only", "source_review_ready"}
    assert education["packable_claim_count"] == 0


def _harvest_fixture(tmp_path: Path, source_ids: list[str], limit: int) -> Path:
    result = run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="fixture",
            mode="fixture",
            source_ids=source_ids,
            limit=limit,
            created_at=CREATED_AT,
        ),
        env={},
    )
    assert result["valid"], result["issues"]
    return Path(result["runRoot"])
