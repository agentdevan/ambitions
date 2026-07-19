from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.autonomous_cycle_runner import AutonomousCycleRunnerOptions, run_autonomous_cycle_runner  # noqa: E402
from foundry.model import read_json, write_json  # noqa: E402


CREATED_AT = "2026-06-29T02:00:00Z"
DOMAINS = ("education_credentialing", "finance_public_reference")


def test_autonomous_cycle_runner_emits_recurring_monitor_and_hold_actions(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["overallReadinessStatus"] == "autonomous_operations_cycle_ready"
    assert result["recordCounts"]["configuredDomainMonitorActions"] == 2
    assert result["recordCounts"]["r2ExecuteGateHoldActions"] == 1
    assert result["recordCounts"]["unknownCandidateOnlyActions"] == 1
    assert result["recordCounts"]["releaseLegalUniversalHoldActions"] == 3
    assert result["recordCounts"]["automaticWriteActions"] == 0
    assert result["recordCounts"]["newRemoteWritesExecuted"] == 0
    assert result["recordCounts"]["finalOutputsGenerated"] == 0
    assert "autonomous_operations_cycle_ready_for_recurring_public_reference_runs" in result["allowedClaims"]
    assert "execute_gated_r2_actions_held" in result["allowedClaims"]
    assert "release_green" in result["blockedClaims"]
    assert _check(result, "r2_write_execute_gate_held")


def test_autonomous_cycle_runner_blocks_invalid_control_loop(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    control_loop = read_json(paths["control_loop"])
    control_loop["valid"] = False
    control_loop["issues"] = ["fixture control loop invalid"]
    write_json(paths["control_loop"], control_loop)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert not _check(result, "control_loop_valid")
    assert any("fixture control loop invalid" in issue for issue in result["issues"])


def test_autonomous_cycle_runner_blocks_automatic_write_attempts(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    control_loop = read_json(paths["control_loop"])
    control_loop["r2WriteDecision"]["automaticWriteAllowed"] = True
    write_json(paths["control_loop"], control_loop)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert not _check(result, "r2_write_execute_gate_held")
    assert any("automatic writes blocked" in issue or "automatic writes" in issue for issue in result["issues"])


def test_autonomous_cycle_runner_proves_idempotent_replay(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    first = _run(tmp_path, paths)
    paths["previous"] = Path(first["outputPaths"]["report"])

    second = _run(tmp_path, paths)

    assert second["valid"], second["issues"]
    assert second["cycleDelta"]["previousCycleSupplied"] is True
    assert second["cycleDelta"]["unchangedFromPrevious"] is True
    assert "idempotent_cycle_replay_proof" in second["allowedClaims"]


def _run(tmp_path: Path, paths: dict[str, Path]) -> dict:
    return run_autonomous_cycle_runner(
        AutonomousCycleRunnerOptions(
            control_loop_path=paths["control_loop"],
            output_root=tmp_path / f"cycle-{len(list(tmp_path.glob('cycle-*')))}",
            previous_cycle_path=paths.get("previous"),
            created_at=CREATED_AT,
            cycle_label="test-cycle",
        )
    )


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    root = tmp_path / "fixtures"
    paths = {"control_loop": root / "autonomous-control-loop.json"}
    write_json(paths["control_loop"], _control_loop())
    return paths


def _control_loop() -> dict:
    return {
        "schemaVersion": 1,
        "kind": "ambitions.sourceAtlas.autonomousControlLoop.v1",
        "valid": True,
        "controlLoopID": "source_atlas.autonomous_control_loop.test",
        "allowedClaims": [
            "autonomous_control_loop_ready_for_configured_public_reference_domains",
            "r2_write_preflight_ready_execute_still_required",
            "unknown_domains_candidate_only_controlled",
            "release_legal_universal_claim_holds_enforced",
        ],
        "blockedClaims": [
            "release_green",
            "outside_legal_approval",
            "literal_universal_coverage",
            "new_remote_r2_write_executed_by_control_loop",
            "automatic_r2_write_without_execute_budget_approval",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        ],
        "domainControlDecisions": [_domain_decision(domain) for domain in DOMAINS],
        "r2WriteDecision": {
            "decision": "preflight_ready_execute_still_required",
            "preflightReady": True,
            "executeRequired": True,
            "automaticWriteAllowed": False,
            "blockedReasons": [],
        },
        "unknownDomainDecision": {
            "candidateOnly": True,
            "r2PublishAllowed": False,
            "productionWriteAllowed": False,
            "blockedReasons": [],
        },
        "releaseDecision": {
            "held": True,
            "releaseGreenAllowed": False,
            "issues": [],
        },
        "outsideLegalDecision": {
            "held": True,
            "outsideLegalApprovalAllowed": False,
            "issues": [],
        },
        "universalCoverageDecision": {
            "held": True,
            "literalUniversalCoverageAllowed": False,
            "issues": [],
        },
        "issues": [],
    }


def _domain_decision(domain: str) -> dict:
    version = "20260628T000000Z"
    return {
        "domainID": domain,
        "controlAction": "monitor_current_production_runtime",
        "readyForMonitoring": True,
        "packReady": True,
        "r2Ready": True,
        "nativeRuntimeReady": True,
        "automaticWriteAllowed": False,
        "packID": f"source-atlas/v1/domain/{domain}/{version}",
        "packVersion": version,
        "manifestKey": f"source-atlas/v1/production/stable/{domain}/{version}/manifest.json",
        "sourceIDs": [f"{domain}.official_source"],
        "issues": [],
    }


def _check(result: dict, name: str) -> bool:
    return any(check["name"] == name and check["passed"] for check in result["checks"])
