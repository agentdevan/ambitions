from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.autonomous_operations_planner import (  # noqa: E402
    AutonomousOperationsPlannerOptions,
    compile_autonomous_operations_plan,
)
from foundry.model import read_json, write_json  # noqa: E402


CREATED_AT = "2026-06-28T21:00:00Z"


def test_autonomous_operations_plan_monitors_current_recertified_domains(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["executionMode"] == "plan_only"
    assert result["actionSummary"] == {"monitor_current_production_runtime": 2}
    assert result["recordCounts"]["monitorDomains"] == 2
    assert result["recordCounts"]["actionableDomains"] == 0
    assert all(plan["nextAction"] == "monitor_current_production_runtime" for plan in result["domainPlans"])


def test_autonomous_operations_plan_routes_ready_ledger_without_recertification_to_recert_gate(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths, recertification_path=None)

    assert result["valid"], result["issues"]
    assert result["actionSummary"] == {"run_production_recertification": 2}
    assert all(plan["requiredGate"] == "ledger_gateway_native_registry_runtime_coherence" for plan in result["domainPlans"])
    assert all("production_recertification_domain_missing" in plan["blockers"] for plan in result["domainPlans"])


def test_autonomous_operations_plan_routes_incomplete_ledger_to_pack_production(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    ledger = read_json(paths["ledger"])
    ledger["domains"][0]["packProductionProofComplete"] = False
    ledger["domains"][0]["readinessStatus"] = "claim_graph_ready"
    ledger["domains"][0]["blockedReasons"] = ["pack_production_proof_missing_or_incomplete"]
    write_json(paths["ledger"], ledger)

    result = _run(tmp_path, paths)

    plan = _domain_plan(result, "education_credentialing")
    assert result["valid"], result["issues"]
    assert plan["nextAction"] == "run_pack_production"
    assert plan["requiredGate"] == "pack_schema_license_provenance_private_scan"
    assert "pack_production_proof_missing_or_incomplete" in plan["blockers"]


def test_autonomous_operations_plan_blocks_unknown_requested_domain_until_frontier_exists(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths, requested_domains=("new_public_domain",))

    plan = _domain_plan(result, "new_public_domain")
    assert result["valid"], result["issues"]
    assert plan["frontierConfigured"] is False
    assert plan["readiness"] == "blocked"
    assert plan["nextAction"] == "define_coverage_frontier"
    assert "coverage_frontier_missing" in plan["blockers"]


def test_autonomous_operations_plan_resolves_requested_alias_to_configured_frontier(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    _add_finance_public_reference(paths)

    result = _run(tmp_path, paths, requested_domains=("public_benefits_reference",))

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["requestedDomains"] == 1
    assert result["recordCounts"]["resolvedRequestedDomainAliases"] == 1
    assert result["recordCounts"]["unmatchedRequestedDomains"] == 0
    assert result["recordCounts"]["plannedDomains"] == 3
    assert result["actionSummary"] == {"monitor_current_production_runtime": 3}
    assert "public_benefits_reference" not in {plan["domainID"] for plan in result["domainPlans"]}

    plan = _domain_plan(result, "finance_public_reference")
    assert plan["requested"] is True
    assert plan["requestedAliases"] == ["public_benefits_reference"]
    assert plan["frontierConfigured"] is True
    assert plan["readiness"] == "current_production_runtime_recertified"
    assert plan["nextAction"] == "monitor_current_production_runtime"


def test_autonomous_operations_plan_rejects_private_requested_domain(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths, requested_domains=("my schedule",))

    assert not result["valid"]
    assert result["privacyIssues"]
    assert any("first_person_private_context" in issue for issue in result["issues"])


def _run(
    tmp_path: Path,
    paths: dict[str, Path],
    *,
    recertification_path: Path | None | bool = True,
    requested_domains: tuple[str, ...] = (),
) -> dict:
    if recertification_path is True:
        recertification = paths["recertification"]
    else:
        recertification = recertification_path
    return compile_autonomous_operations_plan(
        AutonomousOperationsPlannerOptions(
            frontier_config_path=paths["frontiers"],
            source_lane_registry_path=paths["source_lanes"],
            production_target_ledger_path=paths["ledger"],
            production_recertification_path=recertification,
            requested_domains=requested_domains,
            output_root=tmp_path / "autonomous-operations",
            created_at=CREATED_AT,
        )
    )


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    paths = {
        "frontiers": root / "coverage-frontiers.json",
        "source_lanes": root / "source-lane-registry.json",
        "ledger": root / "production-target-ledger.json",
        "recertification": root / "production-recertification.json",
    }
    write_json(paths["frontiers"], _frontiers())
    write_json(paths["source_lanes"], _source_lanes())
    write_json(paths["ledger"], _ledger())
    write_json(paths["recertification"], _recertification())
    return paths


def _frontiers() -> dict:
    return {
        "schema_version": "1.0.0",
        "kind": "ambitions.sourceAtlas.coverageFrontiers.v1",
        "frontiers": [
            {
                "frontier_id": "education_credentialing",
                "domain": "education_credentialing",
                "source_ids": ["college-scorecard.api"],
                "claim_classes": ["program_reference"],
            },
            {
                "frontier_id": "public_civic_requirements",
                "domain": "public_civic_requirements",
                "source_ids": ["nara.constitution.presidency"],
                "claim_classes": ["public_requirement_reference"],
            },
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
            },
            {
                "source_id": "nara.constitution.presidency",
                "review_status": "approved",
                "next_review_due_at": "2026-09-28",
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
            _ledger_domain("public_civic_requirements", 2),
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
        "blockedReasons": [],
    }


def _recertification() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionRecertificationGate.v1",
        "valid": True,
        "domains": [
            {"domainID": "education_credentialing", "recertified": True, "blockers": []},
            {"domainID": "public_civic_requirements", "recertified": True, "blockers": []},
        ],
    }


def _add_finance_public_reference(paths: dict[str, Path]) -> None:
    frontiers = read_json(paths["frontiers"])
    frontiers["frontiers"].append(
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

    ledger = read_json(paths["ledger"])
    ledger["domains"].append(_ledger_domain("finance_public_reference", 3))
    write_json(paths["ledger"], ledger)

    recertification = read_json(paths["recertification"])
    recertification["domains"].append({"domainID": "finance_public_reference", "recertified": True, "blockers": []})
    write_json(paths["recertification"], recertification)


def _domain_plan(result: dict, domain_id: str) -> dict:
    return next(item for item in result["domainPlans"] if item["domainID"] == domain_id)
