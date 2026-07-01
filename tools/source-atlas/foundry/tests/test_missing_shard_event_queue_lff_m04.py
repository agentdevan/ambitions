from __future__ import annotations

import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.missing_shard_event_queue import (  # noqa: E402
    MissingShardEventQueueOptions,
    compile_missing_shard_event_queue,
)
from foundry.model import read_json, write_json  # noqa: E402


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
REPO_ROOT = Path(__file__).resolve().parents[4]

MISSING_SHARD_EVENTS = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-missing-shard-events-lff-m03.json"
FALLBACK_METRIC = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-source-needed-fallback-metric-lff-m03.json"


def test_missing_shard_event_queue_current_repo_events_are_durable_public_reference(tmp_path: Path):
    result = compile_missing_shard_event_queue(
        MissingShardEventQueueOptions(
            missing_shard_events_path=MISSING_SHARD_EVENTS,
            fallback_metric_path=FALLBACK_METRIC,
            output_root=tmp_path / "queue",
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["sourceEvents"] == 200
    assert result["recordCounts"]["queuedEvents"] == 200
    assert result["recordCounts"]["durableExpansionEvents"] == 200
    assert result["recordCounts"]["privateContextEvents"] == 0
    assert result["recordCounts"]["finalOutputsGenerated"] == 0
    assert result["lffM00Counters"]["continuousMissingShardExpansionCounter"] == 1
    assert result["allowedClaims"] == ["durable_missing_shard_event_queue_started"]
    assert "not source review approval" in result["nonClaims"]
    assert "not R2 publication proof" in result["nonClaims"]
    for item in result["events"]:
        assert item["expansionState"] == "queued"
        assert item["candidateState"] == "candidate_only_until_approved"
        assert item["approvalState"] == "not_reviewed"
        assert item["publicReferenceOnly"] is True
        assert item["privateContextPresent"] is False
        assert item["privateContextAllowed"] is False
        assert item["finalOutputAllowed"] is False
        assert item["sourceAuditProvenance"]["sourceEventID"] == item["eventID"]
        assert item["sourceAuditProvenance"]["fallbackMetricID"]
        assert item["missingReason"]["source"] == "queued"
        assert item["missingReason"]["corpus"] == "queued"
        assert item["missingReason"]["review"] == "queued"
        assert item["missingReason"]["legal"] == "queued"
        assert item["missingReason"]["api"] == "queued"
        assert item["reviewGates"]["sourceLaneReview"] == "queued"
        assert item["reviewGates"]["legalTermsReview"] == "queued"
        assert item["reviewGates"]["apiPolicyReview"] == "queued"
        assert item["resolution"]["resolutionState"] == "unresolved"
        assert item["resolution"]["eventualResolutionRequiredBeforeLaunch"] is True


def test_missing_shard_event_queue_rejects_private_context_and_final_outputs(tmp_path: Path):
    event_path = tmp_path / "events.json"
    write_json(
        event_path,
        {
            "kind": "ambitions.sourceAtlas.missingShardEventLedger.v1",
            "events": [
                _event("private-event", private_context_present=True),
                _event("final-output-event", final_output_allowed=True),
            ],
        },
    )

    result = compile_missing_shard_event_queue(
        MissingShardEventQueueOptions(
            missing_shard_events_path=event_path,
            output_root=tmp_path / "queue",
        )
    )

    assert result["valid"] is False
    assert result["recordCounts"]["sourceEvents"] == 2
    assert result["recordCounts"]["queuedEvents"] == 0
    assert result["recordCounts"]["privateContextEvents"] == 1
    assert result["recordCounts"]["finalOutputsGenerated"] == 1
    assert any("private-event carries private context" in issue for issue in result["issues"])
    assert any("final-output-event allows final output" in issue for issue in result["issues"])
    assert result["lffM00Counters"]["continuousMissingShardExpansionCounter"] == 0


def test_missing_shard_event_queue_reconciles_duplicate_events(tmp_path: Path):
    event_path = tmp_path / "events.json"
    first = _event("duplicate-event")
    duplicate = {**first, "createdAt": "2026-07-01T00:01:00Z"}
    write_json(
        event_path,
        {
            "kind": "ambitions.sourceAtlas.missingShardEventLedger.v1",
            "events": [first, duplicate],
        },
    )

    result = compile_missing_shard_event_queue(
        MissingShardEventQueueOptions(
            missing_shard_events_path=event_path,
            output_root=tmp_path / "queue",
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["sourceEvents"] == 2
    assert result["recordCounts"]["queuedEvents"] == 1
    assert result["recordCounts"]["reconciledDuplicateEvents"] == 1
    assert result["events"][0]["eventID"] == "duplicate-event"


def test_missing_shard_event_queue_cli_emits_evidence(tmp_path: Path):
    output_root = tmp_path / "queue"
    emit_evidence = tmp_path / "queue-evidence.json"
    markdown = tmp_path / "queue.md"

    completed = subprocess.run(
        [
            sys.executable,
            "tools/source-atlas/source-atlas-foundry.py",
            "missing-shard-event-queue",
            "--missing-shard-events",
            str(MISSING_SHARD_EVENTS),
            "--fallback-metric",
            str(FALLBACK_METRIC),
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
    assert report["recordCounts"]["queuedEvents"] == 200
    assert (output_root / "missing-shard-event-queue.json").exists()
    assert markdown.exists()


def _event(
    event_id: str,
    *,
    private_context_present: bool = False,
    final_output_allowed: bool = False,
) -> dict:
    return {
        "eventID": event_id,
        "createdAt": "2026-07-01T00:00:00Z",
        "domainID": "language_learning_reference",
        "subdomainID": "language_learning_reference_eligibility_and_scope",
        "sourceIntentID": "source_atlas.golden_intent.fixture",
        "sourceNeededCause": "missing_shard",
        "coverageLabel": "missing_source",
        "eventType": "source_needed_fallback_metric",
        "expansionState": "metric_detected_pending_lff_m04",
        "expectedRoutingState": "source_needed",
        "workItemID": f"source_atlas.expansion_work_item.{event_id}",
        "publicReferenceOnly": True,
        "privateContextPresent": private_context_present,
        "finalOutputAllowed": final_output_allowed,
        "lawfulIntent": True,
    }
