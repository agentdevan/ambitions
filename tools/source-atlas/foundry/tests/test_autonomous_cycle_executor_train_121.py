from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.autonomous_cycle_executor import AutonomousCycleExecutorOptions, run_autonomous_cycle_executor  # noqa: E402
from foundry.model import read_json, write_json  # noqa: E402


CREATED_AT = "2026-06-29T02:15:00Z"
DOMAINS = ("education_credentialing", "finance_public_reference")


def test_autonomous_cycle_executor_executes_local_monitor_checks_and_preserves_holds(tmp_path: Path):
    paths = _fixture_paths(tmp_path)

    result = _run(tmp_path, paths)

    assert result["valid"], result["issues"]
    assert result["overallReadinessStatus"] == "autonomous_cycle_local_execution_ready"
    assert result["recordCounts"]["actionsRead"] == 7
    assert result["recordCounts"]["localMonitorChecksExecuted"] == 2
    assert result["recordCounts"]["heldR2WriteActions"] == 1
    assert result["recordCounts"]["candidateOnlyActions"] == 1
    assert result["recordCounts"]["claimHoldActions"] == 3
    assert result["recordCounts"]["remoteMutations"] == 0
    assert result["recordCounts"]["finalOutputsGenerated"] == 0
    assert "autonomous_cycle_local_execution_green" in result["allowedClaims"]
    assert "release_green" in result["blockedClaims"]
    assert _check(result, "all_monitor_actions_executed_locally")


def test_autonomous_cycle_executor_blocks_invalid_cycle_report(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    cycle = read_json(paths["cycle"])
    cycle["valid"] = False
    cycle["issues"] = ["fixture cycle invalid"]
    write_json(paths["cycle"], cycle)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert not _check(result, "cycle_report_valid")
    assert any("fixture cycle invalid" in issue for issue in result["issues"])


def test_autonomous_cycle_executor_blocks_private_or_mismatched_monitor_key(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    cycle = read_json(paths["cycle"])
    cycle["operationActions"][0]["manifestKey"] = "source-atlas/v1/production/stable/goals/20260628T000000Z/manifest.json"
    write_json(paths["cycle"], cycle)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert not _check(result, "all_monitor_actions_executed_locally")
    assert any("private_r2_object_key_segment" in issue for issue in result["issues"])


def test_autonomous_cycle_executor_blocks_r2_automatic_write_attempt(tmp_path: Path):
    paths = _fixture_paths(tmp_path)
    cycle = read_json(paths["cycle"])
    cycle["operationActions"][2]["automaticWriteAllowed"] = True
    cycle["operationActions"][2]["mutatesRemote"] = True
    write_json(paths["cycle"], cycle)

    result = _run(tmp_path, paths)

    assert not result["valid"]
    assert not _check(result, "r2_write_actions_remain_held")
    assert any("automatic write" in issue or "remote mutation" in issue for issue in result["issues"])


def _run(tmp_path: Path, paths: dict[str, Path]) -> dict:
    return run_autonomous_cycle_executor(
        AutonomousCycleExecutorOptions(
            cycle_path=paths["cycle"],
            output_root=tmp_path / "cycle-executor",
            created_at=CREATED_AT,
            run_label="test-cycle",
        )
    )


def _fixture_paths(tmp_path: Path) -> dict[str, Path]:
    paths = {"cycle": tmp_path / "fixtures" / "autonomous-cycle.json"}
    write_json(paths["cycle"], _cycle())
    return paths


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
            "release_green",
            "outside_legal_approval",
            "literal_universal_coverage",
            "automatic_r2_write_without_execute_budget_approval",
            "new_remote_r2_write_executed_by_cycle_runner",
            "final_user_plans_schedules_steps_from_source_atlas_or_r2",
        ],
        "operationActions": [
            *[_monitor_action(index, domain) for index, domain in enumerate(DOMAINS, start=1)],
            {
                "actionID": "hold-r2-write",
                "order": 3,
                "actionKind": "hold_new_remote_r2_write_until_execute_gate",
                "state": "held_execute_required",
                "requiresExecute": True,
                "mutatesRemote": False,
                "automaticWriteAllowed": False,
                "issues": [],
            },
            {
                "actionID": "unknown-domain",
                "order": 4,
                "actionKind": "route_unknown_public_reference_domain_to_candidate_intake",
                "state": "candidate_only",
                "emitsClaims": False,
                "emitsPack": False,
                "mutatesRemote": False,
                "issues": [],
            },
            *_claim_holds(),
        ],
        "issues": [],
    }


def _monitor_action(order: int, domain: str) -> dict:
    version = "20260628T000000Z"
    return {
        "actionID": f"monitor-{domain}",
        "order": order,
        "actionKind": "monitor_current_production_runtime",
        "domainID": domain,
        "packID": f"source-atlas/v1/domain/{domain}/{version}",
        "manifestKey": f"source-atlas/v1/production/stable/{domain}/{version}/manifest.json",
        "sourceIDs": [f"{domain}.official_source"],
        "mutatesRemote": False,
        "mutatesNativeRuntime": False,
        "emitsFinalOutput": False,
        "issues": [],
    }


def _claim_holds() -> list[dict]:
    return [
        {
            "actionID": "hold-release",
            "order": 5,
            "actionKind": "hold_release_green",
            "state": "held",
            "emitsClaims": False,
            "issues": [],
        },
        {
            "actionID": "hold-legal",
            "order": 6,
            "actionKind": "hold_outside_legal_approval",
            "state": "held",
            "emitsClaims": False,
            "issues": [],
        },
        {
            "actionID": "hold-universal",
            "order": 7,
            "actionKind": "hold_literal_universal_coverage",
            "state": "held",
            "emitsClaims": False,
            "issues": [],
        },
    ]


def _check(result: dict, name: str) -> bool:
    return any(check["name"] == name and check["passed"] for check in result["checks"])
