from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

import foundry.autonomous_end_to_end_chain as end_to_end_chain  # noqa: E402
from foundry.autonomous_end_to_end_chain import (  # noqa: E402
    AutonomousEndToEndChainOptions,
    run_autonomous_end_to_end_chain,
)
from foundry.model import read_json, write_json  # noqa: E402


CREATED_AT = "2026-06-28T23:45:00Z"


def test_end_to_end_chain_observes_production_ready_alias_without_candidate_expansion(tmp_path: Path):
    paths = _production_ready_fixture_paths(tmp_path)

    result = run_autonomous_end_to_end_chain(
        AutonomousEndToEndChainOptions(
            frontier_config_path=paths["frontiers"],
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            production_target_ledger_path=paths["ledger"],
            production_recertification_path=paths["recertification"],
            requested_domains=("public_benefits_reference",),
            output_root=tmp_path / "end-to-end",
            created_at=CREATED_AT,
            execute_safe_actions=True,
            reviewer="source-atlas-reviewer",
        )
    )

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for autonomous end-to-end operations chain"
    assert result["recordCounts"]["requestedDomains"] == 1
    assert result["recordCounts"]["resolvedRequestedDomainAliases"] == 1
    assert result["recordCounts"]["unmatchedRequestedDomains"] == 0
    assert result["recordCounts"]["observedDomains"] == 3
    assert result["recordCounts"]["frontierIntakeArtifacts"] == 0
    assert result["recordCounts"]["candidateExpansionStages"] == 0
    assert result["recordCounts"]["domainExpansionNotRequiredStages"] == 1
    assert result["recordCounts"]["registryActivationNotRequiredRoutes"] == 1
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert _check(result, "candidate_expansion_path_selected_only_when_needed")
    assert _check(result, "registry_activation_path_matches_expansion_path")
    assert _check(result, "chain_emits_no_claims_packs_r2_native_or_private_runtime_outputs")
    assert "domainExpansionNotRequired" in result["stageSummaries"]
    assert "registryActivationNotRequired" in result["stageSummaries"]
    assert "domainExpansion" not in result["stageSummaries"]
    assert "registryActivation" not in result["stageSummaries"]

    resolution = result["stages"]["operationsPlan"]["requestedDomainResolution"]
    assert resolution["aliasesByDomain"] == {"finance_public_reference": ["public_benefits_reference"]}


def test_end_to_end_chain_runs_candidate_expansion_and_registry_readiness_for_missing_frontier(tmp_path: Path):
    paths = _candidate_fixture_paths(tmp_path)

    result = run_autonomous_end_to_end_chain(
        AutonomousEndToEndChainOptions(
            frontier_config_path=paths["frontiers"],
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            production_target_ledger_path=paths["ledger"],
            production_recertification_path=paths["recertification"],
            requested_domains=("public_benefits_reference",),
            output_root=tmp_path / "end-to-end",
            created_at=CREATED_AT,
            execute_safe_actions=True,
            reviewer="source-atlas-reviewer",
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["requestedDomains"] == 1
    assert result["recordCounts"]["resolvedRequestedDomainAliases"] == 0
    assert result["recordCounts"]["unmatchedRequestedDomains"] == 1
    assert result["recordCounts"]["safeActionsExecuted"] == 1
    assert result["recordCounts"]["frontierIntakeArtifacts"] == 5
    assert result["recordCounts"]["candidateExpansionStages"] == 1
    assert result["recordCounts"]["candidateInputs"] == 1
    assert result["recordCounts"]["candidateRoutes"] == 1
    assert result["recordCounts"]["productionReadyRoutes"] == 0
    assert result["recordCounts"]["reviewPackets"] == 4
    assert result["recordCounts"]["reviewPacketTemplates"] == 4
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert _check(result, "candidate_expansion_path_selected_only_when_needed")
    assert _check(result, "registry_activation_path_matches_expansion_path")
    assert _check(result, "chain_emits_no_claims_packs_r2_native_or_private_runtime_outputs")
    assert "domainExpansion" in result["stageSummaries"]
    assert "registryActivation" in result["stageSummaries"]
    assert "domainExpansionNotRequired" not in result["stageSummaries"]
    assert "registryActivationNotRequired" not in result["stageSummaries"]

    review_templates = read_json(Path(result["stages"]["domainExpansion"]["outputPaths"]["reviewPacketTemplates"]))
    assert len(review_templates["reviewPackets"]) == 4
    assert all(packet["manualReviewRequired"] is True for packet in review_templates["reviewPackets"])
    assert all(packet["r2PublishAllowed"] is False for packet in review_templates["reviewPackets"])


def test_end_to_end_chain_can_refresh_production_recertification_before_planning(tmp_path: Path, monkeypatch):
    paths = _production_ready_fixture_paths(tmp_path)
    gateway = tmp_path / "fixtures" / "gateway-release.json"
    native_runtime = tmp_path / "fixtures" / "native-runtime.json"
    native_registry = tmp_path / "fixtures" / "native-registry.json"
    write_json(gateway, {"valid": True})
    write_json(native_runtime, {"valid": True})
    write_json(native_registry, {"valid": True})

    def fake_recertification(options):
        output_root = options.output_root
        output_root.mkdir(parents=True, exist_ok=True)
        report_path = output_root / "production-recertification-report.json"
        report = {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.productionRecertificationGate.v1",
            "status": "Source Green for bounded configured production/runtime recertification",
            "valid": True,
            "recordCounts": {
                "recertifiedDomains": 3,
                "blockedDomains": 0,
                "gatewayLiveDomains": 3,
                "nativeRegistryMatches": 3,
                "nativeRuntimeFrontiers": 3,
            },
            "domains": [
                {"domainID": "education_credentialing", "recertified": True, "blockers": []},
                {"domainID": "public_civic_requirements", "recertified": True, "blockers": []},
                {"domainID": "finance_public_reference", "recertified": True, "blockers": []},
            ],
            "issues": [],
            "outputPaths": {"report": str(report_path)},
        }
        write_json(report_path, report)
        return report

    monkeypatch.setattr(end_to_end_chain, "run_production_recertification_gate", fake_recertification)

    result = run_autonomous_end_to_end_chain(
        AutonomousEndToEndChainOptions(
            frontier_config_path=paths["frontiers"],
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            production_target_ledger_path=paths["ledger"],
            gateway_release_report_path=gateway,
            native_runtime_report_path=native_runtime,
            native_registry_artifact_path=native_registry,
            requested_domains=("public_benefits_reference",),
            output_root=tmp_path / "end-to-end",
            created_at=CREATED_AT,
            refresh_production_recertification=True,
        )
    )

    assert result["valid"], result["issues"]
    assert _check(result, "production_recertification_refreshed_when_requested")
    assert "productionRecertification" in result["stageSummaries"]
    assert result["recordCounts"]["recertifiedDomains"] == 3
    assert result["recordCounts"]["recertificationBlockedDomains"] == 0
    assert result["recordCounts"]["recertificationGatewayLiveDomains"] == 3
    assert result["recordCounts"]["recertificationNativeRegistryMatches"] == 3
    assert result["recordCounts"]["recertificationNativeRuntimeFrontiers"] == 3
    assert result["stages"]["operationsPlan"]["evidencePaths"]["productionRecertification"] == str(
        tmp_path / "end-to-end" / "00-production-recertification" / "production-recertification-report.json"
    )


def test_end_to_end_chain_rejects_private_requested_domain_before_stages(tmp_path: Path):
    paths = _candidate_fixture_paths(tmp_path)

    result = run_autonomous_end_to_end_chain(
        AutonomousEndToEndChainOptions(
            frontier_config_path=paths["frontiers"],
            source_lane_registry_path=paths["source"],
            legal_terms_registry_path=paths["legal"],
            api_governance_registry_path=paths["api"],
            production_target_ledger_path=paths["ledger"],
            production_recertification_path=paths["recertification"],
            requested_domains=("my schedule",),
            output_root=tmp_path / "end-to-end",
            created_at=CREATED_AT,
            execute_safe_actions=True,
        )
    )

    assert not result["valid"]
    assert result["stageSummaries"] == {}
    assert result["recordCounts"]["plannedDomains"] == 0
    assert result["recordCounts"]["safeActionsExecuted"] == 0
    assert result["recordCounts"]["frontierIntakeArtifacts"] == 0
    assert result["privacyIssues"]
    assert any("first_person_private_context" in issue for issue in result["issues"])


def _production_ready_fixture_paths(tmp_path: Path) -> dict[str, Path]:
    paths = _candidate_fixture_paths(tmp_path)
    write_json(
        paths["frontiers"],
        {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.coverageFrontiers.v1",
            "frontiers": [
                _frontier("education_credentialing", ["college-scorecard.api"]),
                _frontier("public_civic_requirements", ["nara.constitution.presidency"]),
                {
                    "frontier_id": "finance_public_reference",
                    "domain": "finance_public_reference",
                    "goal_intent_classes": [
                        "financial_education_reference",
                        "benefit_program_reference",
                        "public_benefit_reference",
                        "public_benefits_reference",
                    ],
                    "source_ids": ["usa.gov.benefits"],
                    "claim_classes": ["public_financial_education", "official_benefit_program_reference"],
                },
            ],
        },
    )
    source = read_json(paths["source"])
    source["source_lanes"] = [
        _source_lane("college-scorecard.api"),
        _source_lane("nara.constitution.presidency"),
        _source_lane("usa.gov.benefits"),
    ]
    write_json(paths["source"], source)
    write_json(
        paths["ledger"],
        {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
            "valid": True,
            "domains": [
                _ledger_domain("education_credentialing", 8),
                _ledger_domain("public_civic_requirements", 2),
                _ledger_domain("finance_public_reference", 3),
            ],
        },
    )
    write_json(
        paths["recertification"],
        {
            "schemaVersion": 1,
            "kind": "ambitions.sourceAtlas.productionRecertificationGate.v1",
            "valid": True,
            "domains": [
                {"domainID": "education_credentialing", "recertified": True, "blockers": []},
                {"domainID": "public_civic_requirements", "recertified": True, "blockers": []},
                {"domainID": "finance_public_reference", "recertified": True, "blockers": []},
            ],
        },
    )
    return paths


def _candidate_fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    root.mkdir(parents=True, exist_ok=True)
    paths = {
        "frontiers": root / "coverage-frontiers.json",
        "source": root / "source-lane-registry.json",
        "legal": root / "legal-terms-registry.json",
        "api": root / "api-governance-registry.json",
        "ledger": root / "production-target-ledger.json",
        "recertification": root / "production-recertification.json",
    }
    write_json(paths["frontiers"], {"schemaVersion": 1, "kind": "ambitions.sourceAtlas.coverageFrontiers.v1", "frontiers": []})
    write_json(
        paths["source"],
        {
            "kind": "ambitions.sourceAtlas.sourceLaneRegistry.v1",
            "registries_version": "test",
            "schema_version": "1.0.0",
            "updated_at": CREATED_AT,
            "source_lanes": [],
        },
    )
    write_json(
        paths["legal"],
        {
            "kind": "ambitions.sourceAtlas.legalTermsRegistry.v1",
            "registries_version": "test",
            "schema_version": "1.0.0",
            "updated_at": CREATED_AT,
            "licenses": [],
        },
    )
    write_json(
        paths["api"],
        {
            "kind": "ambitions.sourceAtlas.apiGovernanceRegistry.v1",
            "registries_version": "test",
            "schema_version": "1.0.0",
            "updated_at": CREATED_AT,
            "api_policies": [],
        },
    )
    write_json(paths["ledger"], {"schemaVersion": 1, "kind": "ambitions.sourceAtlas.productionTargetLedger.v1", "valid": True, "domains": []})
    write_json(
        paths["recertification"],
        {"schemaVersion": 1, "kind": "ambitions.sourceAtlas.productionRecertificationGate.v1", "valid": True, "domains": []},
    )
    return paths


def _frontier(domain: str, source_ids: list[str]) -> dict[str, object]:
    return {
        "frontier_id": domain,
        "domain": domain,
        "source_ids": source_ids,
        "claim_classes": ["public_reference"],
    }


def _source_lane(source_id: str) -> dict[str, str]:
    return {
        "source_id": source_id,
        "review_status": "approved",
        "next_review_due_at": "2026-09-28",
    }


def _ledger_domain(domain: str, claim_count: int) -> dict[str, object]:
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
        "blockedReasons": [],
    }


def _check(result: dict, name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
