from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.goal_domain_production_lanes import GoalDomainProductionLaneOptions, compile_goal_domain_production_lanes
from foundry.goal_domain_router import GoalDomainRouterOptions, compile_goal_domain_router
from foundry.goal_domain_work_order_executor import GoalDomainWorkOrderExecutorOptions, run_goal_domain_work_order_executor
from foundry.model import read_json, write_json


CREATED_AT = "2026-06-28T00:00:00Z"
FIXTURE_PATH = Path("tools/source-atlas/fixtures/goal-domain-router/train-88-goal-domain-requests.json")
LEDGER_PATH = Path("tools/source-atlas/generated/production-target-ledger/train-86/production-target-ledger.json")


def test_goal_domain_work_order_executor_completes_safe_fixture_checks_and_blocks_gates(tmp_path: Path):
    lanes = _compile_lanes(tmp_path)
    result = _run_executor(tmp_path / "executor", Path(lanes["manifestPath"]))

    assert result["valid"], result["issues"]
    assert result["status"] == "Source Green for goal-domain work-order fixture executor"
    assert result["sourceAtlasStatusCeiling"] == "Yellow overall Source Atlas; fixture/dry-run work-order executor only"
    assert result["recordCounts"]["workOrders"] == 30
    assert result["recordCounts"]["executionRecords"] == 30
    assert result["recordCounts"]["completedFixtureChecks"] == 8
    assert result["recordCounts"]["completedDryRunChecks"] == 0
    assert result["recordCounts"]["blockedReviewRequired"] == 8
    assert result["recordCounts"]["blockedUpstreamEvidenceRequired"] == 14
    assert result["recordCounts"]["liveOperations"] == 0
    assert result["recordCounts"]["executeOperations"] == 0
    assert result["recordCounts"]["registryWriteOperations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert _check(result, "safe_stages_can_complete_without_live_or_execute")
    assert _check(result, "review_gates_remain_blocked")
    assert _check(result, "upstream_gates_remain_blocked")
    assert _check(result, "executor_performs_no_live_write_claim_pack_r2_or_native_operations")

    report = read_json(Path(result["outputRoot"]) / "work-order-executor-report.json")
    rollups = {item["requestID"]: item for item in report["domainRollups"]}
    assert rollups["known-education-credentialing"]["completedCount"] == 4
    assert rollups["known-education-credentialing"]["blockedCount"] == 0
    assert rollups["new-language-learning-public-reference"]["completedCount"] == 2
    assert rollups["new-language-learning-public-reference"]["blockedCount"] == 11
    assert rollups["ambiguous-public-program-reference"]["completedCount"] == 2
    assert rollups["ambiguous-public-program-reference"]["blockedCount"] == 11


def test_goal_domain_work_order_executor_dry_run_mode_uses_dry_run_completion_status(tmp_path: Path):
    lanes = _compile_lanes(tmp_path)
    result = _run_executor(tmp_path / "executor-dry-run", Path(lanes["manifestPath"]), mode="dry_run")

    assert result["valid"], result["issues"]
    assert result["mode"] == "dry_run"
    assert result["recordCounts"]["completedFixtureChecks"] == 0
    assert result["recordCounts"]["completedDryRunChecks"] == 8
    records = read_json(Path(result["outputRoot"]) / "execution-records.json")["executionRecords"]
    completed = [record for record in records if record["completed"]]
    assert completed
    assert all(record["executionStatus"] == "completed_dry_run_check" for record in completed)


def test_goal_domain_work_order_executor_records_are_non_executing_and_non_publishing(tmp_path: Path):
    lanes = _compile_lanes(tmp_path)
    result = _run_executor(tmp_path / "executor", Path(lanes["manifestPath"]))
    records = read_json(Path(result["outputRoot"]) / "execution-records.json")["executionRecords"]

    assert all(record["liveOperationPerformed"] is False for record in records)
    assert all(record["executeOperationPerformed"] is False for record in records)
    assert all(record["registryWritePerformed"] is False for record in records)
    assert all(record["r2PublishPerformed"] is False for record in records)
    assert all(record["nativeActivationPerformed"] is False for record in records)
    assert all(record["claimOutputEmitted"] is False for record in records)
    assert all(record["packOutputEmitted"] is False for record in records)

    review_records = [record for record in records if record["executionStatus"] == "blocked_review_required"]
    assert review_records
    assert all("review_artifact_required" in record["blockedBy"] for record in review_records)

    r2_records = [record for record in records if record["stage"] == "r2_publish_gate"]
    assert len(r2_records) == 2
    assert all(record["executionStatus"] == "blocked_upstream_evidence_required" for record in r2_records)
    assert all("upstream_evidence_required" in record["blockedBy"] for record in r2_records)


def test_goal_domain_work_order_executor_rejects_invalid_mode(tmp_path: Path):
    lanes = _compile_lanes(tmp_path)
    result = _run_executor(tmp_path / "executor", Path(lanes["manifestPath"]), mode="live")

    assert not result["valid"]
    assert not _check(result, "mode_valid")
    assert "unsupported executor mode: live" in result["issues"]


def test_goal_domain_work_order_executor_rejects_invalid_lanes_manifest(tmp_path: Path):
    manifest_path = tmp_path / "invalid-lanes-manifest.json"
    write_json(manifest_path, {"valid": False, "outputPaths": {}})

    result = _run_executor(tmp_path / "executor", manifest_path)

    assert not result["valid"]
    assert not _check(result, "production_lanes_manifest_valid")
    assert any("production lanes manifest must be valid" in issue for issue in result["issues"])


def test_goal_domain_work_order_executor_stable_ordering_is_deterministic(tmp_path: Path):
    lanes = _compile_lanes(tmp_path)
    first = _run_executor(tmp_path / "first", Path(lanes["manifestPath"]))
    second = _run_executor(tmp_path / "second", Path(lanes["manifestPath"]))

    first_records = read_json(Path(first["outputRoot"]) / "execution-records.json")["executionRecords"]
    second_records = read_json(Path(second["outputRoot"]) / "execution-records.json")["executionRecords"]
    assert [record["orderID"] for record in first_records] == [record["orderID"] for record in second_records]
    assert first_records == sorted(first_records, key=lambda item: (item["requestID"], item["stageIndex"], item["orderID"]))


def _compile_lanes(tmp_path: Path) -> dict[str, object]:
    router = compile_goal_domain_router(
        GoalDomainRouterOptions(
            input_path=FIXTURE_PATH,
            output_root=tmp_path / "router",
            production_target_ledger_path=LEDGER_PATH,
            created_at=CREATED_AT,
        )
    )
    return compile_goal_domain_production_lanes(
        GoalDomainProductionLaneOptions(
            router_manifest_path=Path(router["manifestPath"]),
            output_root=tmp_path / "lanes",
            production_target_ledger_path=LEDGER_PATH,
            created_at=CREATED_AT,
        )
    )


def _run_executor(tmp_path: Path, lanes_manifest_path: Path, *, mode: str = "fixture") -> dict[str, object]:
    return run_goal_domain_work_order_executor(
        GoalDomainWorkOrderExecutorOptions(
            production_lanes_manifest_path=lanes_manifest_path,
            output_root=tmp_path,
            mode=mode,
            created_at=CREATED_AT,
        )
    )


def _check(result: dict[str, object], name: str) -> bool:
    return next(check for check in result["checks"] if check["name"] == name)["passed"]
