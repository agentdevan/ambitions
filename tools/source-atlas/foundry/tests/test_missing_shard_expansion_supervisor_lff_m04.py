from __future__ import annotations

import copy
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.missing_shard_expansion_supervisor import (  # noqa: E402
    MissingShardExpansionSupervisorOptions,
    compile_missing_shard_expansion_supervisor,
)
from foundry.model import read_json, write_json  # noqa: E402


REPO_ROOT = Path(__file__).resolve().parents[4]
CURRENT_QUEUE = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-missing-shard-event-queue-lff-m04.json"
CURRENT_REVIEW_GATE = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-missing-shard-review-gate-lff-m04.json"
CURRENT_ACTIVATION_EXECUTOR = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-missing-shard-activation-executor-lff-m04.json"
CURRENT_FALLBACK_METRIC = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-source-needed-fallback-metric-lff-m03.json"


def test_missing_shard_expansion_supervisor_audits_current_queue_without_mutation(tmp_path: Path):
    result = compile_missing_shard_expansion_supervisor(_current_options(tmp_path))

    assert result["valid"], result["issues"]
    counts = result["recordCounts"]
    assert counts["queueEvents"] == 200
    assert counts["supervisedEvents"] == 200
    assert counts["reviewOnlyEvents"] == 200
    assert counts["monitorOnlyEvents"] == 0
    assert counts["approvedExecuteEvents"] == 0
    assert counts["heldEvents"] == 0
    assert counts["blockedEvents"] == 0
    assert counts["staleEvents"] == 0
    assert counts["sourceLaneQueuedEvents"] == 200
    assert counts["legalQueuedEvents"] == 200
    assert counts["apiQueuedEvents"] == 200
    assert counts["resolvedEvents"] == 0
    assert counts["unresolvedEvents"] == 200
    assert counts["resolutionRateBps"] == 0
    assert counts["fallbackMetricLawfulGoals"] == 50_000
    assert counts["fallbackMetricSourceNeeded"] == 200
    assert counts["fallbackMetricRateBps"] == 40
    assert counts["r2WriteOperations"] == 0
    assert counts["nativeActivationOperations"] == 0
    assert counts["finalOutputArtifacts"] == 0
    assert result["backlogReport"]["totalBacklogItems"] == 200
    assert result["staleEventReport"]["staleEventCount"] == 0
    assert result["fallbackRegressionReport"]["regressionStatus"] == "no_previous_metric"
    assert "missing_shard_expansion_supervisor_green" in result["allowedClaims"]
    assert "launch_floor_complete" in result["blockedClaims"]


def test_missing_shard_expansion_supervisor_reports_stale_events_without_reclassifying_execution(tmp_path: Path):
    result = compile_missing_shard_expansion_supervisor(
        MissingShardExpansionSupervisorOptions(
            missing_shard_queue_path=CURRENT_QUEUE,
            review_gate_path=CURRENT_REVIEW_GATE,
            activation_executor_path=CURRENT_ACTIVATION_EXECUTOR,
            fallback_metric_path=CURRENT_FALLBACK_METRIC,
            output_root=tmp_path / "expansion-supervisor",
            as_of="2026-08-05T00:00:00Z",
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["staleEvents"] == 200
    assert result["recordCounts"]["firstReviewOverdueEvents"] == 200
    assert result["recordCounts"]["reviewOnlyEvents"] == 200
    assert result["recordCounts"]["approvedExecuteEvents"] == 0
    assert result["staleEventReport"]["staleEventCount"] == 200
    assert len(result["staleEventReport"]["staleEventIDs"]) == 200


def test_missing_shard_expansion_supervisor_compares_previous_fallback_metric(tmp_path: Path):
    previous = copy.deepcopy(read_json(CURRENT_FALLBACK_METRIC))
    previous["recordCounts"]["sourceNeededFallbacks"] = 250
    previous["recordCounts"]["sourceNeededFallbackNumerator"] = 250
    previous_path = tmp_path / "previous-fallback-metric.json"
    write_json(previous_path, previous)

    result = compile_missing_shard_expansion_supervisor(
        MissingShardExpansionSupervisorOptions(
            missing_shard_queue_path=CURRENT_QUEUE,
            review_gate_path=CURRENT_REVIEW_GATE,
            activation_executor_path=CURRENT_ACTIVATION_EXECUTOR,
            fallback_metric_path=CURRENT_FALLBACK_METRIC,
            previous_fallback_metric_path=previous_path,
            output_root=tmp_path / "expansion-supervisor",
        )
    )

    regression = result["fallbackRegressionReport"]
    assert result["valid"], result["issues"]
    assert regression["previousMetricPresent"] is True
    assert regression["previousRateBps"] == 50
    assert regression["currentRateBps"] == 40
    assert regression["deltaBps"] == -10
    assert regression["regressionStatus"] == "improved_or_flat"
    assert "fallback_regression_compared_to_previous_metric" in result["allowedClaims"]


def test_missing_shard_expansion_supervisor_cli_emits_evidence(tmp_path: Path):
    output_root = tmp_path / "expansion-supervisor"
    emit_evidence = tmp_path / "expansion-supervisor.json"
    markdown = tmp_path / "expansion-supervisor.md"

    completed = subprocess.run(
        [
            sys.executable,
            "tools/source-atlas/source-atlas-foundry.py",
            "missing-shard-expansion-supervisor",
            "--missing-shard-queue",
            str(CURRENT_QUEUE),
            "--review-gate",
            str(CURRENT_REVIEW_GATE),
            "--activation-executor",
            str(CURRENT_ACTIVATION_EXECUTOR),
            "--fallback-metric",
            str(CURRENT_FALLBACK_METRIC),
            "--output-root",
            str(output_root),
            "--emit-evidence",
            str(emit_evidence),
            "--markdown",
            str(markdown),
        ],
        cwd=REPO_ROOT,
        text=True,
        capture_output=True,
        check=False,
    )

    assert completed.returncode == 0, completed.stderr
    report = read_json(emit_evidence)
    assert report["valid"] is True
    assert report["recordCounts"]["supervisedEvents"] == 200
    assert (output_root / "backlog-by-governance-state.json").exists()
    assert (output_root / "stale-event-report.json").exists()
    assert (output_root / "resolution-fallback-regression-report.json").exists()
    assert markdown.exists()


def _current_options(tmp_path: Path) -> MissingShardExpansionSupervisorOptions:
    return MissingShardExpansionSupervisorOptions(
        missing_shard_queue_path=CURRENT_QUEUE,
        review_gate_path=CURRENT_REVIEW_GATE,
        activation_executor_path=CURRENT_ACTIVATION_EXECUTOR,
        fallback_metric_path=CURRENT_FALLBACK_METRIC,
        output_root=tmp_path / "expansion-supervisor",
    )
