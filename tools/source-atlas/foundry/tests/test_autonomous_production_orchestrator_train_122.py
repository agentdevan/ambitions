from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.autonomous_production_orchestrator import (  # noqa: E402
    AutonomousProductionOrchestratorOptions,
    run_autonomous_production_orchestrator,
)
from foundry.model import read_json, write_json  # noqa: E402


CREATED_AT = "2026-06-29T02:30:00Z"
DOMAINS = ("education_credentialing", "finance_public_reference")
VERSION = "20260628T000000Z"


def test_autonomous_production_orchestrator_reconciles_full_bounded_operating_envelope(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["overallReadinessStatus"] == "bounded_autonomous_production_operational"
    assert result["configuredDomainCount"] == 2
    assert result["recordCounts"]["productionDomainsReady"] == 2
    assert result["recordCounts"]["remoteR2UploadsReconciled"] == 2
    assert result["recordCounts"]["localMonitorChecksExecuted"] == 2
    assert result["recordCounts"]["remoteMutations"] == 0
    assert result["recordCounts"]["nativeRuntimeMutations"] == 0
    assert result["recordCounts"]["finalOutputsGenerated"] == 0
    assert "bounded_autonomous_source_atlas_production_orchestrator_green" in result["allowedClaims"]
    assert "current_remote_r2_upload_readback_reconciled_for_configured_domains" in result["allowedClaims"]
    assert "full_source_atlas_green" in result["blockedClaims"]
    assert "outside_legal_approval" in result["blockedClaims"]
    assert "release_green" in result["blockedClaims"]
    assert "literal_universal_coverage" in result["blockedClaims"]
    assert _matrix_ready(result, "production_target")
    assert _matrix_ready(result, "live_transport_and_r2")
    assert _matrix_ready(result, "autonomous_cycle_execution")
    assert _check(result, "remaining_work_is_human_or_forbidden_only")


def test_autonomous_production_orchestrator_blocks_when_r2_reconciliation_drops(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    sweep = read_json(paths["sweep"])
    sweep["recordCounts"]["remoteR2UploadsReconciled"] = 1
    write_json(paths["sweep"], sweep)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert not _matrix_ready(result, "live_transport_and_r2")
    assert not _check(result, "r2_readback_reconciled_for_every_configured_domain")
    assert any("remote R2 upload/readback count does not match" in issue for issue in result["issues"])


def test_autonomous_production_orchestrator_blocks_release_green_overclaim(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    finish_line = read_json(paths["finish_line"])
    finish_line["allowedClaims"].append("release_green")
    finish_line["blockedClaims"].remove("release_green")
    write_json(paths["finish_line"], finish_line)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert not _matrix_ready(result, "ambitions_runtime_boundary")
    assert any("incorrectly allowed blocked claim: release_green" in issue for issue in result["issues"])


def test_autonomous_production_orchestrator_blocks_cycle_remote_mutation_attempt(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    cycle = read_json(paths["cycle"])
    cycle["operationActions"][0]["mutatesRemote"] = True
    write_json(paths["cycle"], cycle)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert not _matrix_ready(result, "autonomous_cycle_execution")
    assert any("monitor action must not mutate remote state" in issue for issue in result["issues"])


def _run(tmp_path: Path, paths: dict[str, Path]) -> dict:
    return run_autonomous_production_orchestrator(
        AutonomousProductionOrchestratorOptions(
            production_target_ledger_path=paths["ledger"],
            production_finish_line_gate_path=paths["finish_line"],
            production_sweep_path=paths["sweep"],
            arbitrary_domain_gate_path=paths["arbitrary"],
            goal_domain_gauntlet_path=paths["gauntlet"],
            autonomous_control_loop_path=paths["control_loop"],
            autonomous_cycle_path=paths["cycle"],
            output_root=tmp_path / "orchestrator",
            created_at=CREATED_AT,
            run_label="test-production",
        )
    )


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    paths = {
        "ledger": root / "production-target-ledger.json",
        "finish_line": root / "production-finish-line-gate.json",
        "sweep": root / "production-sweep.json",
        "arbitrary": root / "arbitrary-domain-gate.json",
        "gauntlet": root / "goal-domain-gauntlet.json",
        "control_loop": root / "autonomous-control-loop.json",
        "cycle": root / "autonomous-cycle.json",
    }
    write_json(paths["ledger"], _ledger())
    write_json(paths["finish_line"], _finish_line())
    write_json(paths["sweep"], _sweep())
    write_json(paths["arbitrary"], _arbitrary())
    write_json(paths["gauntlet"], _gauntlet())
    write_json(paths["control_loop"], _control_loop())
    write_json(paths["cycle"], _cycle())
    return paths


def _ledger() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionTargetLedger.v1",
        "valid": True,
        "overallReadinessStatus": "configured_frontiers_bounded_production_target_ready",
        "recordCounts": {
            "configuredFrontiers": 2,
            "boundedProductionTargetReady": 2,
            "configuredDomainsNotReady": 0,
            "orphanProductionDomains": 0,
        },
        "allowedClaims": [
            "bounded_production_target_for_configured_frontiers",
            "bounded_production_target_per_ready_frontier",
        ],
        "blockedClaims": [
            "full_source_atlas_green",
            "outside_legal_approval",
            "release_green",
            "literal_universal_coverage",
        ],
        "domains": [{"domainID": domain, "readinessStatus": "bounded_production_target_ready"} for domain in DOMAINS],
        "issues": [],
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
            "bounded_configured_runtime_green",
            "gateway_native_runtime_recertification",
        ],
        "blockedClaims": [
            "outside_legal_approval",
            "runtime_green",
            "release_green",
            "universal_coverage",
        ],
        "recordCounts": {
            "productionDomains": 2,
            "r2ReportsValid": 2,
            "r2ReportsBlocked": 0,
            "recertifiedDomains": 2,
            "recertificationBlockedDomains": 0,
        },
        "issues": [],
    }


def _sweep() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.productionSweep.v1",
        "valid": True,
        "overallReadinessStatus": "current_configured_production_operational_sweep_green",
        "allowedClaims": [
            "current_configured_frontier_production_sweep",
            "current_remote_r2_upload_readback_reconciled",
            "governed_arbitrary_public_reference_domain_routing_reconciled",
            "future_remote_r2_write_preflight_ready",
            "representative_goal_domain_gauntlet_reconciled",
        ],
        "blockedClaims": [
            "full_source_atlas_green",
            "outside_legal_approval",
            "release_green",
            "literal_universal_coverage",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        ],
        "recordCounts": {
            "configuredDomains": 2,
            "domainsReady": 2,
            "domainsBlocked": 0,
            "remoteR2UploadsReconciled": 2,
            "goalDomainGauntletCases": 2,
            "privacyIssues": 0,
        },
        "issues": [],
    }


def _arbitrary() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.arbitraryDomainHandlingGate.v1",
        "valid": True,
        "allowedClaims": ["governed_arbitrary_public_reference_domain_handling"],
        "blockedClaims": [
            "full_source_atlas_green",
            "outside_legal_approval",
            "release_green",
            "literal_universal_coverage",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        ],
        "recordCounts": {
            "configuredFrontiers": 2,
            "configuredMonitorDomains": 2,
            "candidateClaims": 0,
            "candidateProductionWrites": 0,
            "candidateR2PublishOperations": 0,
            "unknownProbeDomains": 2,
            "unknownUnmatchedDomains": 2,
        },
        "issues": [],
    }


def _gauntlet() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.goalDomainGauntlet.v1",
        "valid": True,
        "allowedClaims": [
            "representative_goal_domain_gauntlet_green",
            "configured_frontier_goal_domain_runtime_routing",
            "unknown_public_reference_domains_candidate_only",
        ],
        "blockedClaims": [
            "full_source_atlas_green",
            "outside_legal_approval",
            "release_green",
            "literal_universal_coverage",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        ],
        "recordCounts": {
            "configuredFrontiers": 2,
            "configuredGauntletCases": 2,
            "configuredCasesPassed": 2,
            "configuredCasesBlocked": 0,
            "unknownCasesCandidateOnly": 2,
            "unknownCasesBlocked": 0,
            "finalOutputsGenerated": 0,
            "privacyIssues": 0,
        },
        "issues": [],
    }


def _control_loop() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousControlLoop.v1",
        "valid": True,
        "allowedClaims": [
            "autonomous_control_loop_ready_for_configured_public_reference_domains",
            "r2_write_preflight_ready_execute_still_required",
            "unknown_domains_candidate_only_controlled",
            "release_legal_universal_claim_holds_enforced",
        ],
        "blockedClaims": [
            "full_source_atlas_green",
            "outside_legal_approval",
            "release_green",
            "literal_universal_coverage",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        ],
        "recordCounts": {
            "configuredDomains": 2,
            "domainsReadyForMonitoring": 2,
            "domainsBlocked": 0,
            "automaticR2WritesAllowed": 0,
            "privacyIssues": 0,
        },
        "issues": [],
    }


def _cycle() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousCycleRunner.v1",
        "valid": True,
        "cycleID": "source_atlas.autonomous_cycle.test",
        "cycleFingerprint": "cycle-fixture",
        "allowedClaims": [
            "autonomous_operations_cycle_ready_for_recurring_public_reference_runs",
            "configured_domain_monitor_actions_emitted",
            "execute_gated_r2_actions_held",
            "unknown_domain_candidate_intake_cycle_controlled",
        ],
        "blockedClaims": [
            "full_source_atlas_green",
            "outside_legal_approval",
            "release_green",
            "literal_universal_coverage",
            "automatic_r2_write_without_execute_budget_approval",
            "new_remote_r2_write_executed_by_cycle_runner",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        ],
        "recordCounts": {
            "operationActions": 7,
            "configuredDomainMonitorActions": 2,
            "r2ExecuteGateHoldActions": 1,
            "releaseLegalUniversalHoldActions": 3,
            "unknownCandidateOnlyActions": 1,
            "automaticWriteActions": 0,
            "newRemoteWritesExecuted": 0,
            "finalOutputsGenerated": 0,
            "privacyIssues": 0,
        },
        "operationActions": [
            *[_monitor_action(index, domain) for index, domain in enumerate(DOMAINS, start=1)],
            _r2_hold_action(),
            _unknown_action(),
            *_claim_holds(),
        ],
        "issues": [],
    }


def _monitor_action(order: int, domain: str) -> dict:
    return {
        "actionID": f"monitor-{domain}",
        "order": order,
        "actionKind": "monitor_current_production_runtime",
        "domainID": domain,
        "packID": f"source-atlas/v1/domain/{domain}/{VERSION}",
        "manifestKey": f"source-atlas/v1/production/stable/{domain}/{VERSION}/manifest.json",
        "sourceIDs": [f"{domain}.official_source"],
        "mutatesRemote": False,
        "mutatesNativeRuntime": False,
        "emitsFinalOutput": False,
        "issues": [],
    }


def _r2_hold_action() -> dict:
    return {
        "actionID": "hold-r2-write",
        "order": 3,
        "actionKind": "hold_new_remote_r2_write_until_execute_gate",
        "state": "held_execute_required",
        "requiresExecute": True,
        "mutatesRemote": False,
        "automaticWriteAllowed": False,
        "issues": [],
    }


def _unknown_action() -> dict:
    return {
        "actionID": "unknown-domain",
        "order": 4,
        "actionKind": "route_unknown_public_reference_domain_to_candidate_intake",
        "state": "candidate_only",
        "emitsClaims": False,
        "emitsPack": False,
        "mutatesRemote": False,
        "issues": [],
    }


def _claim_holds() -> list[dict]:
    return [
        {"actionID": "hold-release", "order": 5, "actionKind": "hold_release_green", "state": "held", "emitsClaims": False, "issues": []},
        {"actionID": "hold-legal", "order": 6, "actionKind": "hold_outside_legal_approval", "state": "held", "emitsClaims": False, "issues": []},
        {"actionID": "hold-universal", "order": 7, "actionKind": "hold_literal_universal_coverage", "state": "held", "emitsClaims": False, "issues": []},
    ]


def _matrix_ready(result: dict, area: str) -> bool:
    return any(item["area"] == area and item["ready"] for item in result["readinessMatrix"])


def _check(result: dict, name: str) -> bool:
    return any(check["name"] == name and check["passed"] for check in result["checks"])
