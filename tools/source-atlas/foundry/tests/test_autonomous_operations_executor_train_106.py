from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.autonomous_operations_executor import (  # noqa: E402
    AutonomousOperationsExecutorOptions,
    run_autonomous_operations_executor,
)
from foundry.model import read_json, write_json  # noqa: E402
from foundry.public_reference_delivery_chain import DEFAULT_SOURCE_IDS  # noqa: E402


CREATED_AT = "2026-06-28T21:20:00Z"


def test_autonomous_operations_executor_observes_and_plans_without_safe_execute(tmp_path: Path):
    plan_path = _plan_path(tmp_path, [_monitor_domain(), _frontier_domain()])

    result = run_autonomous_operations_executor(
        AutonomousOperationsExecutorOptions(
            operations_plan_path=plan_path,
            output_root=tmp_path / "execution",
            created_at=CREATED_AT,
        )
    )

    assert result["valid"], result["issues"]
    assert result["executionMode"] == "dry_run_plan_observation"
    assert result["recordCounts"]["observedDomains"] == 1
    assert result["recordCounts"]["plannedNotExecuted"] == 1
    assert result["recordCounts"]["safeActionsExecuted"] == 0
    assert result["artifacts"] == []
    assert _domain_result(result, "public_benefits_reference")["status"] == "planned_not_executed"


def test_autonomous_operations_executor_executes_candidate_frontier_intake_when_safe_actions_allowed(tmp_path: Path):
    plan_path = _plan_path(tmp_path, [_monitor_domain(), _frontier_domain()])

    result = run_autonomous_operations_executor(
        AutonomousOperationsExecutorOptions(
            operations_plan_path=plan_path,
            output_root=tmp_path / "execution",
            created_at=CREATED_AT,
            execute_safe_actions=True,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["observedDomains"] == 1
    assert result["recordCounts"]["safeActionsExecuted"] == 1
    assert result["recordCounts"]["frontierIntakeArtifacts"] == 5
    domain_result = _domain_result(result, "public_benefits_reference")
    assert domain_result["status"] == "executed_safe"
    assert domain_result["childValid"] is True

    manifest_path = Path(tmp_path / "execution" / "frontier-intake" / "public_benefits_reference" / "manifest.json")
    manifest = read_json(manifest_path)
    assert manifest["valid"], manifest["issues"]
    assert manifest["recordCounts"]["claims"] == 0
    assert manifest["recordCounts"]["packableClaims"] == 0
    assert manifest["recordCounts"]["r2PackableArtifacts"] == 0

    proposed = read_json(tmp_path / "execution" / "frontier-intake" / "public_benefits_reference" / "proposed-frontiers.json")
    frontier = proposed["proposedFrontiers"][0]
    assert frontier["status_ceiling"] == "candidate_only"
    assert frontier["claim_output_allowed"] is False
    assert frontier["pack_output_allowed"] is False
    assert "official_benefit_program_reference" in frontier["claim_classes"]


def test_autonomous_operations_executor_can_run_fixture_delivery_chain_only_with_explicit_safe_flags(tmp_path: Path):
    plan_path = _plan_path(tmp_path, [_harvest_domain()])

    blocked = run_autonomous_operations_executor(
        AutonomousOperationsExecutorOptions(
            operations_plan_path=plan_path,
            output_root=tmp_path / "blocked-execution",
            created_at=CREATED_AT,
            execute_safe_actions=True,
        )
    )

    assert blocked["valid"], blocked["issues"]
    assert blocked["recordCounts"]["blockedByGate"] == 1
    assert _domain_result(blocked, "occupation_foundation")["status"] == "blocked_by_gate"

    executed = run_autonomous_operations_executor(
        AutonomousOperationsExecutorOptions(
            operations_plan_path=plan_path,
            output_root=tmp_path / "executed",
            created_at=CREATED_AT,
            execute_safe_actions=True,
            allow_fixture_delivery_chain=True,
            delivery_chain_limit=3,
        )
    )

    assert executed["valid"], executed["issues"]
    assert executed["recordCounts"]["safeActionsExecuted"] == 1
    assert executed["recordCounts"]["deliveryChainArtifacts"] > 0
    assert executed["recordCounts"]["productionWritesExecuted"] == 0
    delivery_report = read_json(tmp_path / "executed" / "fixture-delivery-chain" / "occupation_foundation" / "public-reference-delivery-chain-report.json")
    assert delivery_report["valid"], delivery_report["issues"]
    assert delivery_report["r2Mode"] == "dry_run"
    assert delivery_report["recordCounts"]["r2PublishOperations"] == 0


def test_autonomous_operations_executor_blocks_production_r2_action_without_running_it(tmp_path: Path):
    plan_path = _plan_path(tmp_path, [_r2_domain()])

    result = run_autonomous_operations_executor(
        AutonomousOperationsExecutorOptions(
            operations_plan_path=plan_path,
            output_root=tmp_path / "execution",
            created_at=CREATED_AT,
            execute_safe_actions=True,
            allow_fixture_delivery_chain=True,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["blockedByGate"] == 1
    assert result["recordCounts"]["productionWritesExecuted"] == 0
    domain_result = _domain_result(result, "education_credentialing")
    assert domain_result["status"] == "blocked_by_gate"
    assert domain_result["productionAction"] is True
    assert "execute_budget_approval_credentials_upload_readback_sha256" in domain_result["message"]


def test_autonomous_operations_executor_rejects_private_plan_before_actions_run(tmp_path: Path):
    plan = _plan([_frontier_domain()])
    plan["goalText"] = "my schedule for this week"
    plan_path = tmp_path / "private-plan.json"
    write_json(plan_path, plan)

    result = run_autonomous_operations_executor(
        AutonomousOperationsExecutorOptions(
            operations_plan_path=plan_path,
            output_root=tmp_path / "execution",
            created_at=CREATED_AT,
            execute_safe_actions=True,
        )
    )

    assert not result["valid"]
    assert result["privacyIssues"]
    assert result["actionResults"] == []
    assert result["recordCounts"]["safeActionsExecuted"] == 0
    assert any("goal_text" in issue or "first_person_private_context" in issue for issue in result["issues"])


def _plan_path(tmp_path: Path, domain_plans: list[dict]) -> Path:
    frontier_config = tmp_path / "coverage-frontiers.json"
    write_json(frontier_config, {"schemaVersion": 1, "frontiers": []})
    plan = _plan(domain_plans)
    plan["evidencePaths"]["frontierConfig"] = str(frontier_config)
    path = tmp_path / "operations-plan.json"
    write_json(path, plan)
    return path


def _plan(domain_plans: list[dict]) -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousOperationsPlanner.v1",
        "versionID": "source-atlas-autonomous-operations-planner-train-105",
        "createdAt": CREATED_AT,
        "planID": "source_atlas.autonomous_operations_plan.fixture",
        "status": "Source Green for autonomous operations planning",
        "valid": True,
        "executionMode": "plan_only",
        "domainPlans": domain_plans,
        "evidencePaths": {"frontierConfig": ""},
        "privacyBoundary": "public/reference/freshness only; no private user context",
        "nonClaims": ["not full Source Atlas Green", "not final user plans, schedules, or Steps"],
    }


def _monitor_domain() -> dict:
    return {
        "domainID": "education_credentialing",
        "requested": False,
        "frontierConfigured": True,
        "readiness": "current_production_runtime_recertified",
        "nextAction": "monitor_current_production_runtime",
        "requiredGate": "next_due_review_or_freshness_window",
        "sourceIDs": ["college-scorecard.api"],
        "blockers": [],
    }


def _frontier_domain() -> dict:
    return {
        "domainID": "public_benefits_reference",
        "requested": True,
        "frontierConfigured": False,
        "readiness": "blocked",
        "nextAction": "define_coverage_frontier",
        "requiredGate": "frontier_governance_review",
        "sourceIDs": [],
        "blockers": ["coverage_frontier_missing"],
    }


def _harvest_domain() -> dict:
    return {
        "domainID": "occupation_foundation",
        "requested": False,
        "frontierConfigured": True,
        "readiness": "claim_graph_needed",
        "nextAction": "run_governed_harvest_and_claim_frontier",
        "requiredGate": "fixture_by_default_live_requires_live_execute_budget",
        "sourceIDs": list(DEFAULT_SOURCE_IDS),
        "blockers": ["claim_frontier_proof_missing_or_incomplete"],
    }


def _r2_domain() -> dict:
    return {
        "domainID": "education_credentialing",
        "requested": False,
        "frontierConfigured": True,
        "readiness": "r2_publish_needed",
        "nextAction": "run_r2_publisher",
        "requiredGate": "execute_budget_approval_credentials_upload_readback_sha256",
        "sourceIDs": ["college-scorecard.api"],
        "blockers": ["production_r2_upload_readback_missing_or_incomplete"],
    }


def _domain_result(result: dict, domain_id: str) -> dict:
    return next(item for item in result["actionResults"] if item["domainID"] == domain_id)
