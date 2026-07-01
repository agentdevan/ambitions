from __future__ import annotations

import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.missing_shard_review_gate import (  # noqa: E402
    APPROVED_STATUS,
    MISSING_SHARD_REVIEW_APPROVAL_KIND,
    MissingShardReviewGateOptions,
    compile_missing_shard_review_gate,
)
from foundry.model import read_json, write_json  # noqa: E402


SOURCE_ATLAS_ROOT = Path(__file__).resolve().parents[2]
REPO_ROOT = Path(__file__).resolve().parents[4]

CURRENT_QUEUE = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-missing-shard-event-queue-lff-m04.json"


def test_missing_shard_review_gate_blocks_current_queue_without_approval(tmp_path: Path):
    result = compile_missing_shard_review_gate(
        MissingShardReviewGateOptions(
            missing_shard_queue_path=CURRENT_QUEUE,
            output_root=tmp_path / "review-gate",
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["queuedEvents"] == 200
    assert result["recordCounts"]["gateDecisions"] == 200
    assert result["recordCounts"]["approvedEvents"] == 0
    assert result["recordCounts"]["blockedEvents"] == 200
    assert result["recordCounts"]["plannedRegistryMutations"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["coverageCounterMutations"] == 0
    assert result["recordCounts"]["claims"] == 0
    assert result["recordCounts"]["r2PublishOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert result["recordCounts"]["finalOutputArtifacts"] == 0
    assert result["lffM00Counters"]["missingShardEventsWithReviewGateDecision"] == 200
    assert result["lffM00Counters"]["coverageCounterMutations"] == 0
    assert result["allowedClaims"] == [
        "missing_shard_review_gate_tooling_green",
        "candidate_events_blocked_until_all_gates_pass",
    ]
    assert result["activeRegistryMutations"] == []
    assert len(result["approvalTemplate"]["approvedEvents"]) == 200


def test_missing_shard_review_gate_valid_approval_creates_dry_run_reversible_plan(tmp_path: Path):
    queue_path = tmp_path / "queue.json"
    approval_path = tmp_path / "approval.json"
    event = _queue_event("approved-event")
    write_json(queue_path, {"kind": "ambitions.sourceAtlas.missingShardEventQueue.v1", "events": [event]})
    write_json(approval_path, _approval(event["eventID"]))

    result = compile_missing_shard_review_gate(
        MissingShardReviewGateOptions(
            missing_shard_queue_path=queue_path,
            approval_artifact_path=approval_path,
            output_root=tmp_path / "review-gate",
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["queuedEvents"] == 1
    assert result["recordCounts"]["approvedEvents"] == 1
    assert result["recordCounts"]["plannedRegistryMutations"] == 1
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["recordCounts"]["coverageCounterMutations"] == 0
    assert result["allowedClaims"] == [
        "missing_shard_review_gate_tooling_green",
        "candidate_events_blocked_until_all_gates_pass",
        "approved_events_have_dry_run_registry_mutation_plan",
    ]
    plan = result["plannedRegistryMutations"][0]
    assert plan["status"] == "dry_run_ready_for_separate_registry_apply"
    assert plan["activeRegistryWritten"] is False
    assert plan["coverageCountersAffected"] is False
    assert plan["sourceLaneEntry"]["source_id"] == "synthetic.public.source"
    assert plan["legalTermsEntry"]["license_id"] == "synthetic_public_license"
    assert plan["apiPolicyEntry"]["api_policy_id"] == "api.synthetic.public.v1"
    assert plan["reversalPlan"]["activeRegistryRollbackRequired"] is False


def test_missing_shard_review_gate_rejects_malformed_approval(tmp_path: Path):
    queue_path = tmp_path / "queue.json"
    approval_path = tmp_path / "approval.json"
    event = _queue_event("malformed-approval-event")
    approval = _approval(event["eventID"])
    approval["approvedEvents"][0]["sourceLaneEntry"]["review_status"] = "candidate_only"
    approval["approvedEvents"][0]["legalTermsEntry"]["pack_output_allowed"] = False
    write_json(queue_path, {"kind": "ambitions.sourceAtlas.missingShardEventQueue.v1", "events": [event]})
    write_json(approval_path, approval)

    result = compile_missing_shard_review_gate(
        MissingShardReviewGateOptions(
            missing_shard_queue_path=queue_path,
            approval_artifact_path=approval_path,
            output_root=tmp_path / "review-gate",
        )
    )

    assert result["valid"] is False
    assert result["recordCounts"]["approvedEvents"] == 0
    assert result["recordCounts"]["plannedRegistryMutations"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert any("sourceLaneEntry.review_status must be reviewed" in issue for issue in result["issues"])
    assert any("legalTermsEntry.pack_output_allowed must be true" in issue for issue in result["issues"])


def test_missing_shard_review_gate_rejects_private_approval_payload(tmp_path: Path):
    queue_path = tmp_path / "queue.json"
    approval_path = tmp_path / "approval.json"
    event = _queue_event("private-approval-event")
    approval = _approval(event["eventID"])
    approval["approvedEvents"][0]["privateScheduleNote"] = "private schedule context must not enter Source Atlas"
    write_json(queue_path, {"kind": "ambitions.sourceAtlas.missingShardEventQueue.v1", "events": [event]})
    write_json(approval_path, approval)

    result = compile_missing_shard_review_gate(
        MissingShardReviewGateOptions(
            missing_shard_queue_path=queue_path,
            approval_artifact_path=approval_path,
            output_root=tmp_path / "review-gate",
        )
    )

    assert result["valid"] is False
    assert result["recordCounts"]["plannedRegistryMutations"] == 0
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert any("privateScheduleNote" in issue or "private schedule" in issue for issue in result["privacyIssues"])


def test_missing_shard_review_gate_execute_flags_fail_without_writes(tmp_path: Path):
    result = compile_missing_shard_review_gate(
        MissingShardReviewGateOptions(
            missing_shard_queue_path=CURRENT_QUEUE,
            output_root=tmp_path / "review-gate",
            execute=True,
            allow_active_registry_write=True,
        )
    )

    assert result["valid"] is False
    assert result["recordCounts"]["activeRegistryMutations"] == 0
    assert result["activeRegistryMutations"] == []
    assert any("never executes active registry writes" in issue for issue in result["issues"])
    assert any("allow_active_registry_write is ignored" in issue for issue in result["issues"])


def test_missing_shard_review_gate_cli_emits_evidence(tmp_path: Path):
    output_root = tmp_path / "review-gate"
    emit_evidence = tmp_path / "review-gate.json"
    markdown = tmp_path / "review-gate.md"

    completed = subprocess.run(
        [
            sys.executable,
            "tools/source-atlas/source-atlas-foundry.py",
            "missing-shard-review-gate",
            "--missing-shard-queue",
            str(CURRENT_QUEUE),
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
    assert report["recordCounts"]["gateDecisions"] == 200
    assert report["recordCounts"]["activeRegistryMutations"] == 0
    assert (output_root / "missing-shard-review-gate.json").exists()
    assert markdown.exists()


def _queue_event(event_id: str) -> dict:
    return {
        "eventID": event_id,
        "queueItemID": f"source_atlas.missing_shard_queue_item.{event_id}",
        "workItemID": f"source_atlas.expansion_work_item.{event_id}",
        "domainID": "synthetic_public_reference",
        "subdomainID": "synthetic_public_reference_scope",
        "sourceIntentID": f"source_atlas.golden_intent.{event_id}",
        "sourceAuditProvenance": {"sourceEventID": event_id, "fallbackMetricID": "source_atlas.metric.fixture"},
        "publicReferenceOnly": True,
        "privateContextPresent": False,
        "privateContextAllowed": False,
        "finalOutputAllowed": False,
        "lawfulIntent": True,
        "expansionState": "queued",
        "candidateState": "candidate_only_until_approved",
    }


def _approval(event_id: str) -> dict:
    return {
        "kind": MISSING_SHARD_REVIEW_APPROVAL_KIND,
        "approvalArtifactID": "source_atlas.missing_shard_review_approval.synthetic",
        "approvalStatus": APPROVED_STATUS,
        "reviewOwner": "Ambitions owner technical review",
        "reviewedAt": "2026-07-01T00:00:00Z",
        "outsideLegalStatus": "not_claimed",
        "selectedEventIDs": [event_id],
        "approvedEvents": [
            {
                "eventID": event_id,
                "gateDecisions": {
                    "publicReferenceClassification": "passed",
                    "sourceLaneReview": "approved",
                    "legalTermsReview": "approved",
                    "apiPolicyReview": "approved",
                    "noPrivateDataScan": "passed",
                    "ownerApproval": "approved",
                },
                "sourceLaneEntry": {
                    "source_id": "synthetic.public.source",
                    "source_name": "Synthetic public source",
                    "source_class": "official_public_reference",
                    "authority_class": "official_public_reference",
                    "jurisdiction": "US",
                    "domain_scope": ["synthetic_public_reference"],
                    "license_id": "synthetic_public_license",
                    "api_policy_id": "api.synthetic.public.v1",
                    "review_status": "reviewed",
                    "r2_pack_policy": "pack_allowed_with_attribution",
                    "allowed_artifact_classes": ["public_reference_claim"],
                    "forbidden_artifact_classes": ["restricted_media"],
                },
                "legalTermsEntry": {
                    "license_id": "synthetic_public_license",
                    "license_name": "Synthetic public license",
                    "license_url": "https://example.test/license",
                    "terms_url": "https://example.test/terms",
                    "rights_url": "https://example.test/rights",
                    "redistribution_allowed": True,
                    "pack_output_allowed": True,
                    "review_required": False,
                    "review_owner": "Ambitions owner technical review",
                    "reviewed_at": "2026-07-01",
                    "outside_legal_status": "not_claimed",
                },
                "apiPolicyEntry": {
                    "api_policy_id": "api.synthetic.public.v1",
                    "source_id": "synthetic.public.source",
                    "api_mode": "static_https_fixture_first",
                    "missing_key_behavior": "no_key_required",
                    "live_flag_required": True,
                    "execute_flag_required": True,
                    "secret_redaction_required": True,
                    "retry_policy": "retry_429_500_502_503_504_only",
                    "backoff_policy": "exponential_jitter",
                    "circuit_breaker_policy": "stop_after_retry_budget",
                    "budget_owner": "source-atlas-foundry",
                    "evidence_output_policy": "mode_and_rate_metadata_only",
                },
            }
        ],
    }
