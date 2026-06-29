from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.arbitrary_goal_domain_gate import (  # noqa: E402
    ArbitraryDomainHandlingGateOptions,
    run_arbitrary_domain_handling_gate,
)
from foundry.model import read_json, write_json  # noqa: E402


CREATED_AT = "2026-06-29T00:05:00Z"


def test_arbitrary_domain_gate_proves_configured_unknown_and_private_lanes(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["overallReadinessStatus"] == "governed_arbitrary_domain_handling_ready"
    assert result["recordCounts"]["configuredFrontiers"] == 1
    assert result["recordCounts"]["configuredMonitorDomains"] == 1
    assert result["recordCounts"]["unknownProbeDomains"] == 1
    assert result["recordCounts"]["unknownFrontierIntakeArtifacts"] == 5
    assert result["recordCounts"]["candidateClaims"] == 0
    assert result["recordCounts"]["candidateR2PublishOperations"] == 0
    assert result["recordCounts"]["candidateNativeActivationOperations"] == 0
    assert result["privateContextProbe"]["rejected"] is True
    assert result["privateContextProbe"]["persistentArtifactWritten"] is False
    assert "governed_arbitrary_public_reference_domain_handling" in result["allowedClaims"]
    assert "literal_universal_coverage" in result["blockedClaims"]
    assert _check(result, "unknown_public_domains_route_to_candidate_frontier_intake")
    assert _check(result, "candidate_intake_emits_no_claims_packs_r2_or_native_activation")
    assert _check(result, "private_context_rejected_without_persistent_artifact")
    assert _output_tree_does_not_contain_private_probe(Path(result["outputPaths"]["report"]).parents[0])


def test_arbitrary_domain_gate_blocks_ambiguous_frontier_aliases(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    frontiers = read_json(paths["frontiers"])
    frontiers["frontiers"].append(
        {
            "frontier_id": "finance_public_reference",
            "domain": "finance_public_reference",
            "domain_aliases": ["learning_public_reference"],
            "source_ids": ["usa.gov.benefits"],
            "claim_classes": ["public_benefit_program_reference"],
        }
    )
    write_json(paths["frontiers"], frontiers)
    source_lanes = read_json(paths["source_lanes"])
    source_lanes["source_lanes"].append(
        {
            "source_id": "usa.gov.benefits",
            "review_status": "approved",
            "next_review_due_at": "2026-09-28",
        }
    )
    write_json(paths["source_lanes"], source_lanes)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert result["recordCounts"]["aliasConflicts"] == 1
    assert not _check(result, "frontier_aliases_are_unambiguous")


def _run(tmp_path: Path, paths: dict[str, Path]) -> dict:
    return run_arbitrary_domain_handling_gate(
        ArbitraryDomainHandlingGateOptions(
            frontier_config_path=paths["frontiers"],
            source_lane_registry_path=paths["source_lanes"],
            production_target_ledger_path=paths["ledger"],
            production_recertification_path=paths["recertification"],
            finish_line_gate_path=paths["finish_line"],
            output_root=tmp_path / "arbitrary-domain-gate",
            created_at=CREATED_AT,
            unknown_probe_domains=("unrepresented_public_reference_domain",),
        )
    )


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    paths = {
        "frontiers": root / "coverage-frontiers.json",
        "source_lanes": root / "source-lane-registry.json",
        "ledger": root / "production-target-ledger.json",
        "recertification": root / "production-recertification.json",
        "finish_line": root / "finish-line.json",
    }
    write_json(paths["frontiers"], _frontiers())
    write_json(paths["source_lanes"], _source_lanes())
    write_json(paths["ledger"], _ledger())
    write_json(paths["recertification"], _recertification())
    write_json(paths["finish_line"], _finish_line())
    return paths


def _frontiers() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.coverageFrontiers.v1",
        "frontiers": [
            {
                "frontier_id": "education_credentialing",
                "domain": "education_credentialing",
                "domain_aliases": ["learning_public_reference"],
                "goal_intent_classes": ["education_program_reference"],
                "source_ids": ["college-scorecard.api"],
                "claim_classes": ["program_reference"],
            }
        ],
    }


def _source_lanes() -> dict:
    return {
        "schemaVersion": 1,
        "source_lanes": [
            {
                "source_id": "college-scorecard.api",
                "review_status": "approved",
                "next_review_due_at": "2026-09-28",
            }
        ],
    }


def _ledger() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "domains": [
            {
                "domainID": "education_credentialing",
                "readinessStatus": "bounded_production_target_ready",
                "frontierConfigured": True,
                "claimGraphProofComplete": True,
                "packProductionProofComplete": True,
                "r2ProductionProofComplete": True,
                "gatewayProofComplete": True,
                "nativeRegistryProofComplete": True,
                "nativeRuntimeBoundaryProofComplete": True,
                "nativeUsabilityProofComplete": True,
                "packableClaimCount": 2,
                "blockedReasons": [],
            }
        ],
    }


def _recertification() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionRecertificationGate.v1",
        "valid": True,
        "domains": [
            {
                "domainID": "education_credentialing",
                "recertified": True,
                "blockers": [],
            }
        ],
    }


def _finish_line() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionFinishLineGate.v1",
        "valid": True,
        "allowedClaims": [
            "bounded_configured_production_target",
            "internal_terms_review",
            "production_r2_write_readback",
            "bounded_live_transport",
            "gateway_native_runtime_recertification",
        ],
        "blockedClaims": ["literal_universal_coverage"],
        "issues": [],
    }


def _check(result: dict, name: str) -> bool:
    return any(check["name"] == name and check["passed"] for check in result["checks"])


def _output_tree_does_not_contain_private_probe(output_root: Path) -> bool:
    for path in output_root.rglob("*.json"):
        if "I need source atlas" in path.read_text(encoding="utf-8"):
            return False
    for path in output_root.rglob("*.md"):
        if "I need source atlas" in path.read_text(encoding="utf-8"):
            return False
    return True
