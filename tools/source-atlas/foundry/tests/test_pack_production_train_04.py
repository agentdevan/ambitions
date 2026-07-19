from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.claim_frontier import ClaimFrontierOptions, compile_claim_frontier
from foundry.harvest_runner import GovernedHarvestOptions, run_governed_harvest
from foundry.model import read_json
from foundry.pack_production import PackProductionOptions, build_pack_production, validate_pack_production_artifacts
from foundry.terms_approval_packet import build_terms_approval_packet
from foundry.terms_registry import terms_entry


CREATED_AT = "2026-06-27T00:00:00Z"


def test_pack_production_compiles_public_pack_slices_and_dry_run_plan(tmp_path: Path):
    claim_frontier_root = _claim_frontier_fixture(tmp_path)
    result = build_pack_production(
        PackProductionOptions(
            input_root=claim_frontier_root,
            output_root=tmp_path / "pack-production",
            domain="occupation_foundation",
            environment="staging",
            channel="candidate",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for pack compiler/R2 dry-run controls"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; pack compiler and R2 dry-run controls only"
    assert result["recordCounts"]["claims"] == 26
    assert result["recordCounts"]["blockedClaimsExcluded"] == 2
    assert result["dryRunPlan"]["dryRun"] is True
    assert result["dryRunPlan"]["wouldUpload"] is False
    assert result["nonPrivateScan"]["passed"]

    output_root = Path(result["outputRoot"])
    pack = read_json(output_root / "pack.json")
    manifest = read_json(output_root / "manifest.json")
    lkg = read_json(output_root / "lkg.json")
    claims = read_json(output_root / "claims.json")["claims"]
    assert len(claims) == 26
    assert all(claim["pack_eligibility"] == "packable" for claim in claims)
    assert all(claim["source_id"] not in {"usajobs.search", "wikidata.crosswalk"} for claim in claims)
    assert pack["claims"] == claims
    assert manifest["claim_graph_hash"]
    assert manifest["revocation_manifest_key"].endswith("/revocations.json")
    assert manifest["lkg_pointer_key"].endswith("/lkg.json")
    assert len(lkg["sha256"]) == 64
    assert lkg["sha256"] != manifest["sha256"]
    assert "not production R2 readiness" in manifest["non_claims"]


def test_pack_production_artifact_validator_fails_when_required_slice_is_missing(tmp_path: Path):
    claim_frontier_root = _claim_frontier_fixture(tmp_path)
    result = build_pack_production(
        PackProductionOptions(
            input_root=claim_frontier_root,
            output_root=tmp_path / "pack-production",
            domain="occupation_foundation",
            created_at=CREATED_AT,
        )
    )
    assert result["valid"], result["issues"]
    (Path(result["outputRoot"]) / "non_claims.json").unlink()

    validation = validate_pack_production_artifacts(Path(result["outputRoot"]))

    assert not validation["valid"]
    assert "missing required artifact: non_claims.json" in validation["issues"]


def test_pack_production_execute_path_requires_production_approval_and_budget(tmp_path: Path):
    claim_frontier_root = _claim_frontier_fixture(tmp_path)
    result = build_pack_production(
        PackProductionOptions(
            input_root=claim_frontier_root,
            output_root=tmp_path / "pack-production",
            domain="occupation_foundation",
            environment="staging",
            channel="candidate",
            created_at=CREATED_AT,
            execute=True,
        )
    )

    assert not result["valid"]
    assert "execute requires --environment production" in result["issues"]
    assert "execute requires --approval-artifact" in result["issues"]
    assert "execute requires --budget-policy" in result["issues"]
    assert next(check for check in result["checks"] if check["name"] == "execute_requires_approval_artifact")["passed"] is False


def test_pack_production_production_stable_requires_legal_approval_packet(tmp_path: Path):
    claim_frontier_root = _claim_frontier_fixture(tmp_path)
    result = build_pack_production(
        PackProductionOptions(
            input_root=claim_frontier_root,
            output_root=tmp_path / "pack-production",
            domain="occupation_foundation",
            environment="production",
            channel="stable",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert "production/stable pack production requires --legal-approval-packet" in result["issues"]
    assert next(check for check in result["checks"] if check["name"] == "legal_terms_approval_packet_valid")["passed"] is False


def test_pack_production_accepts_source_matched_legal_approval_packet_for_stable(tmp_path: Path):
    claim_frontier_root = _claim_frontier_fixture(tmp_path)
    approval_packet = tmp_path / "terms-approval.json"
    build_terms_approval_packet(
        [
            terms_entry("onet.database"),
            terms_entry("bls.public.data.api"),
            terms_entry("openalex.dataset"),
        ],
        output_path=approval_packet,
        created_at=CREATED_AT,
    )
    result = build_pack_production(
        PackProductionOptions(
            input_root=claim_frontier_root,
            output_root=tmp_path / "pack-production",
            domain="occupation_foundation",
            environment="production",
            channel="stable",
            created_at=CREATED_AT,
            legal_approval_packet=approval_packet,
        )
    )

    assert result["valid"], result["issues"]
    assert result["legalTermsApprovalPacketValidation"]["valid"]
    assert next(check for check in result["checks"] if check["name"] == "legal_terms_approval_packet_valid")["passed"] is True


def test_pack_production_blocks_private_object_key_segments(tmp_path: Path):
    claim_frontier_root = _claim_frontier_fixture(tmp_path)
    result = build_pack_production(
        PackProductionOptions(
            input_root=claim_frontier_root,
            output_root=tmp_path / "pack-production",
            domain="users",
            environment="staging",
            channel="candidate",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert any("private_r2_object_key_segment" in issue for issue in result["issues"])


def test_pack_production_not_started_domain_cannot_claim_pack_ready(tmp_path: Path):
    claim_frontier_root = _claim_frontier_fixture(tmp_path)
    result = build_pack_production(
        PackProductionOptions(
            input_root=claim_frontier_root,
            output_root=tmp_path / "pack-production",
            domain="finance_public_reference",
            environment="staging",
            channel="candidate",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert "finance_public_reference: no packable claims available for pack production" in result["issues"]
    assert result["recordCounts"]["claims"] == 0


def _claim_frontier_fixture(tmp_path: Path) -> Path:
    harvest = run_governed_harvest(
        GovernedHarvestOptions(
            output_root=tmp_path / "governed-harvest",
            run_id="fixture",
            mode="fixture",
            source_ids=["onet.database", "bls.public.data.api", "openalex.dataset", "wikidata.crosswalk", "usajobs.search"],
            limit=25,
            created_at=CREATED_AT,
        ),
        env={},
    )
    assert harvest["valid"], harvest["issues"]
    claim_frontier = compile_claim_frontier(
        ClaimFrontierOptions(
            input_root=Path(harvest["runRoot"]),
            output_root=tmp_path / "claim-frontier",
            created_at=CREATED_AT,
        )
    )
    assert claim_frontier["valid"], claim_frontier["issues"]
    return Path(claim_frontier["outputRoot"])
