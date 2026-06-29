from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.goal_domain_gauntlet import GoalDomainGauntletOptions, run_goal_domain_gauntlet  # noqa: E402
from foundry.model import read_json, write_json  # noqa: E402
from foundry.r2_owner_approval import R2OwnerApprovalOptions, build_r2_owner_approval, validate_r2_owner_approval_artifact  # noqa: E402


CREATED_AT = "2026-06-29T01:30:00Z"


def test_goal_domain_gauntlet_proves_configured_unknown_and_local_only_boundaries(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = run_goal_domain_gauntlet(
        GoalDomainGauntletOptions(
            frontier_config_path=paths["frontiers"],
            production_target_ledger_path=paths["ledger"],
            arbitrary_domain_gate_path=paths["arbitrary_gate"],
            native_runtime_report_path=paths["native"],
            output_root=tmp_path / "gauntlet",
            created_at=CREATED_AT,
            unknown_probe_domains=("unrepresented_public_reference_domain",),
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["configuredFrontiers"] == 2
    assert result["recordCounts"]["configuredCasesPassed"] == 2
    assert result["recordCounts"]["unknownCasesCandidateOnly"] == 1
    assert result["recordCounts"]["finalOutputsGenerated"] == 0
    assert "representative_goal_domain_gauntlet_green" in result["allowedClaims"]
    assert "literal_universal_coverage" in result["blockedClaims"]
    assert _check(result, "configured_cases_route_to_current_public_reference_runtime")
    assert _check(result, "unknown_cases_remain_candidate_only")


def test_goal_domain_gauntlet_blocks_missing_ledger_frontier(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    ledger = read_json(paths["ledger"])
    ledger["domains"] = [domain for domain in ledger["domains"] if domain["domainID"] != "finance_public_reference"]
    write_json(paths["ledger"], ledger)

    result = run_goal_domain_gauntlet(
        GoalDomainGauntletOptions(
            frontier_config_path=paths["frontiers"],
            production_target_ledger_path=paths["ledger"],
            arbitrary_domain_gate_path=paths["arbitrary_gate"],
            native_runtime_report_path=paths["native"],
            output_root=tmp_path / "gauntlet",
            created_at=CREATED_AT,
        )
    )

    assert not result["valid"]
    assert result["recordCounts"]["configuredCasesBlocked"] == 1
    assert not _check(result, "configured_cases_route_to_current_public_reference_runtime")


def test_r2_owner_approval_validates_all_configured_domains(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    approval = build_r2_owner_approval(
        R2OwnerApprovalOptions(
            production_target_ledger_path=paths["ledger"],
            production_finish_line_gate_path=paths["finish_line"],
            output_root=tmp_path / "approval",
            created_at=CREATED_AT,
            bucket="ambitions-source-atlas-prod",
        )
    )
    approval_path = Path(approval["outputPaths"]["report"])
    validation = validate_r2_owner_approval_artifact(
        approval_path,
        environment="production",
        channel="stable",
        bucket="ambitions-source-atlas-prod",
        domain_ids=["education_credentialing", "finance_public_reference"],
    )

    assert approval["valid"], approval["issues"]
    assert validation["valid"], validation["issues"]
    assert validation["domainCount"] == 2


def test_r2_owner_approval_validation_blocks_missing_domain(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    approval = build_r2_owner_approval(
        R2OwnerApprovalOptions(
            production_target_ledger_path=paths["ledger"],
            production_finish_line_gate_path=paths["finish_line"],
            output_root=tmp_path / "approval",
            created_at=CREATED_AT,
        )
    )

    validation = validate_r2_owner_approval_artifact(
        Path(approval["outputPaths"]["report"]),
        environment="production",
        channel="stable",
        bucket="ambitions-source-atlas-prod",
        domain_ids=["education_credentialing", "finance_public_reference", "travel_relocation"],
    )

    assert not validation["valid"]
    assert any("missing configured domains: travel_relocation" in issue for issue in validation["issues"])


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    paths = {
        "frontiers": root / "coverage-frontiers.json",
        "ledger": root / "production-target-ledger.json",
        "arbitrary_gate": root / "arbitrary-domain-gate.json",
        "native": root / "native-runtime.json",
        "finish_line": root / "finish-line.json",
    }
    write_json(paths["frontiers"], _frontiers())
    write_json(paths["ledger"], _ledger())
    write_json(paths["arbitrary_gate"], _arbitrary_gate())
    write_json(paths["native"], _native_runtime())
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
                "goal_intent_classes": ["education_program_reference"],
                "claim_classes": ["candidate_education_program_reference"],
                "jurisdictions": ["US"],
                "minimum_authority_classes": ["official_government"],
                "source_ids": ["college-scorecard.api"],
            },
            {
                "frontier_id": "finance_public_reference",
                "domain": "finance_public_reference",
                "goal_intent_classes": ["public_finance_reference"],
                "claim_classes": ["public_financial_education_reference"],
                "jurisdictions": ["US"],
                "minimum_authority_classes": ["official_government"],
                "source_ids": ["cfpb.adult_financial_education"],
            },
        ],
    }


def _ledger() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "domains": [
            _ledger_domain("education_credentialing", 8),
            _ledger_domain("finance_public_reference", 3),
        ],
    }


def _ledger_domain(domain: str, claim_count: int) -> dict:
    return {
        "domainID": domain,
        "readinessStatus": "bounded_production_target_ready",
        "frontierConfigured": True,
        "claimGraphProofComplete": True,
        "packProductionProofComplete": True,
        "r2ProductionProofComplete": True,
        "gatewayProofComplete": True,
        "nativeRegistryProofComplete": True,
        "nativeRuntimeBoundaryProofComplete": True,
        "nativeUsabilityProofComplete": True,
        "packableClaimCount": claim_count,
        "sourceIDs": [f"{domain}.official_source"],
    }


def _arbitrary_gate() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.arbitraryDomainHandlingGate.v1",
        "valid": True,
        "recordCounts": {
            "candidateClaims": 0,
            "candidateR2PublishOperations": 0,
            "candidateNativeActivationOperations": 0,
            "candidateProductionWrites": 0,
        },
        "privateContextProbe": {
            "rejected": True,
            "privacyIssueCount": 2,
            "persistentArtifactWritten": False,
            "rawProbePersisted": False,
        },
        "issues": [],
    }


def _native_runtime() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.nativeRuntimeCurrentProof.v1",
        "valid": True,
        "domainProofs": [
            {"domainID": "education_credentialing", "runtimeReady": True},
            {"domainID": "finance_public_reference", "runtimeReady": True},
        ],
        "allowedClaims": ["bounded_configured_runtime_green"],
        "issues": [],
    }


def _finish_line() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionFinishLineGate.v1",
        "valid": True,
        "blockedClaims": ["release_green", "universal_coverage", "outside_legal_approval"],
        "issues": [],
    }


def _check(result: dict, name: str) -> bool:
    return any(check["name"] == name and check["passed"] for check in result["checks"])
