from __future__ import annotations

import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from foundry.missing_shard_activation_executor import (  # noqa: E402
    ACTIVATION_APPROVED_STATUS,
    MISSING_SHARD_ACTIVATION_APPROVAL_KIND,
    MissingShardActivationExecutorOptions,
    compile_missing_shard_activation_executor,
)
from foundry.missing_shard_review_gate import (  # noqa: E402
    APPROVED_STATUS,
    MISSING_SHARD_REVIEW_APPROVAL_KIND,
    MissingShardReviewGateOptions,
    compile_missing_shard_review_gate,
)
from foundry.model import read_json, write_json  # noqa: E402


REPO_ROOT = Path(__file__).resolve().parents[4]
CURRENT_REVIEW_GATE = REPO_ROOT / "docs" / "qa" / "source-atlas" / "source-atlas-missing-shard-review-gate-lff-m04.json"


def test_missing_shard_activation_executor_blocks_current_review_gate_without_approval(tmp_path: Path):
    result = compile_missing_shard_activation_executor(
        MissingShardActivationExecutorOptions(
            review_gate_path=CURRENT_REVIEW_GATE,
            output_root=tmp_path / "activation-executor",
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["reviewGateDecisions"] == 200
    assert result["recordCounts"]["plannedRegistryMutations"] == 0
    assert result["recordCounts"]["stageAuditGates"] == 6
    assert result["recordCounts"]["stageDecisions"] == 1200
    assert result["recordCounts"]["blockedStageDecisions"] == 1200
    assert result["recordCounts"]["dryRunOperations"] == 0
    assert result["recordCounts"]["executionAuthorizations"] == 0
    assert result["recordCounts"]["r2WriteOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert result["recordCounts"]["coverageCounterMutations"] == 0
    assert result["recordCounts"]["finalOutputArtifacts"] == 0
    assert result["allowedClaims"] == [
        "missing_shard_activation_executor_gate_green",
        "activation_stages_blocked_until_explicit_approval",
    ]
    assert result["r2OperationPlan"]["writeOperationsPerformed"] == 0
    assert result["nativeActivationPlan"]["nativeActivationOperationsPerformed"] == 0


def test_missing_shard_activation_executor_approved_review_gate_waits_for_activation_approval(tmp_path: Path):
    review_gate_path = _approved_review_gate_path(tmp_path)

    result = compile_missing_shard_activation_executor(
        MissingShardActivationExecutorOptions(
            review_gate_path=review_gate_path,
            output_root=tmp_path / "activation-executor",
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["plannedRegistryMutations"] == 1
    assert result["recordCounts"]["stageDecisions"] == 6
    assert result["recordCounts"]["blockedStageDecisions"] == 6
    assert result["recordCounts"]["dryRunOperations"] == 0
    assert {item["status"] for item in result["blockedStageWork"]} == {"blocked_pending_activation_approval"}


def test_missing_shard_activation_executor_dry_run_emits_reversible_stage_plan(tmp_path: Path):
    review_gate_path = _approved_review_gate_path(tmp_path)
    review_gate = read_json(review_gate_path)
    mutation_id = review_gate["plannedRegistryMutations"][0]["mutationID"]
    activation_approval_path = tmp_path / "activation-approval.json"
    write_json(activation_approval_path, _activation_approval(mutation_id))

    result = compile_missing_shard_activation_executor(
        MissingShardActivationExecutorOptions(
            review_gate_path=review_gate_path,
            activation_approval_path=activation_approval_path,
            output_root=tmp_path / "activation-executor",
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["stageDecisions"] == 6
    assert result["recordCounts"]["blockedStageDecisions"] == 0
    assert result["recordCounts"]["dryRunOperations"] == 6
    assert result["recordCounts"]["r2WriteOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert "approved_mutations_have_reversible_dry_run_activation_plan" in result["allowedClaims"]
    r2_operation = next(item for item in result["dryRunOperations"] if item["stage"] == "r2Promotion")
    assert r2_operation["rollbackPlan"]["r2RollbackRequiredIfPublished"] is True
    assert all(key.startswith("source-atlas/v1/staging/missing-shard/") for key in r2_operation["publicR2ObjectKeys"])
    native_operation = next(item for item in result["dryRunOperations"] if item["stage"] == "nativeActivation")
    assert native_operation["rollbackPlan"]["nativeRefreshTargetRollbackRequiredIfActivated"] is True
    assert result["r2OperationPlan"]["writeOperationsPerformed"] == 0
    assert result["nativeActivationPlan"]["verifiedPublicManifestRequired"] is True


def test_missing_shard_activation_executor_execute_requires_activation_approval(tmp_path: Path):
    result = compile_missing_shard_activation_executor(
        MissingShardActivationExecutorOptions(
            review_gate_path=CURRENT_REVIEW_GATE,
            output_root=tmp_path / "activation-executor",
            execute=True,
        )
    )

    assert result["valid"] is False
    assert result["recordCounts"]["r2WriteOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert any("execute mode requires an activation approval artifact" in issue for issue in result["issues"])


def test_missing_shard_activation_executor_rejects_private_activation_approval(tmp_path: Path):
    review_gate_path = _approved_review_gate_path(tmp_path)
    review_gate = read_json(review_gate_path)
    mutation_id = review_gate["plannedRegistryMutations"][0]["mutationID"]
    activation_approval_path = tmp_path / "activation-approval.json"
    approval = _activation_approval(mutation_id)
    approval["privateScheduleNote"] = "private schedule context must never enter Source Atlas"
    write_json(activation_approval_path, approval)

    result = compile_missing_shard_activation_executor(
        MissingShardActivationExecutorOptions(
            review_gate_path=review_gate_path,
            activation_approval_path=activation_approval_path,
            output_root=tmp_path / "activation-executor",
        )
    )

    assert result["valid"] is False
    assert result["recordCounts"]["dryRunOperations"] == 0
    assert result["recordCounts"]["r2WriteOperations"] == 0
    assert any("privateScheduleNote" in issue or "private schedule" in issue for issue in result["privacyIssues"])


def test_missing_shard_activation_executor_execute_authorizes_without_claiming_writes(tmp_path: Path):
    review_gate_path = _approved_review_gate_path(tmp_path)
    review_gate = read_json(review_gate_path)
    mutation_id = review_gate["plannedRegistryMutations"][0]["mutationID"]
    activation_approval_path = tmp_path / "activation-approval.json"
    write_json(
        activation_approval_path,
        _activation_approval(
            mutation_id,
            allow_r2=True,
            allow_native=True,
        ),
    )

    result = compile_missing_shard_activation_executor(
        MissingShardActivationExecutorOptions(
            review_gate_path=review_gate_path,
            activation_approval_path=activation_approval_path,
            output_root=tmp_path / "activation-executor",
            execute=True,
            allow_r2_write=True,
            allow_native_activation=True,
        )
    )

    assert result["valid"], result["issues"]
    assert result["recordCounts"]["executionAuthorizations"] == 6
    assert result["recordCounts"]["r2WriteOperations"] == 0
    assert result["recordCounts"]["nativeActivationOperations"] == 0
    assert "approved_mutations_have_stage_execution_authorizations_without_write_claims" in result["allowedClaims"]


def test_missing_shard_activation_executor_cli_emits_evidence(tmp_path: Path):
    output_root = tmp_path / "activation-executor"
    emit_evidence = tmp_path / "activation-executor.json"
    markdown = tmp_path / "activation-executor.md"

    completed = subprocess.run(
        [
            sys.executable,
            "tools/source-atlas/source-atlas-foundry.py",
            "missing-shard-activation-executor",
            "--review-gate",
            str(CURRENT_REVIEW_GATE),
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
    assert report["recordCounts"]["stageDecisions"] == 1200
    assert report["recordCounts"]["r2WriteOperations"] == 0
    assert (output_root / "missing-shard-activation-executor.json").exists()
    assert markdown.exists()


def _approved_review_gate_path(tmp_path: Path) -> Path:
    queue_path = tmp_path / "queue.json"
    review_approval_path = tmp_path / "review-approval.json"
    output_root = tmp_path / "review-gate"
    event = _queue_event("approved-event")
    write_json(queue_path, {"kind": "ambitions.sourceAtlas.missingShardEventQueue.v1", "events": [event]})
    write_json(review_approval_path, _review_approval(event["eventID"]))
    result = compile_missing_shard_review_gate(
        MissingShardReviewGateOptions(
            missing_shard_queue_path=queue_path,
            approval_artifact_path=review_approval_path,
            output_root=output_root,
        )
    )
    assert result["valid"], result["issues"]
    return Path(result["outputPaths"]["report"])


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


def _review_approval(event_id: str) -> dict:
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


def _activation_approval(
    mutation_id: str,
    *,
    allow_r2: bool = False,
    allow_native: bool = False,
) -> dict:
    return {
        "kind": MISSING_SHARD_ACTIVATION_APPROVAL_KIND,
        "activationApprovalID": "source_atlas.missing_shard_activation_approval.synthetic",
        "activationStatus": ACTIVATION_APPROVED_STATUS,
        "reviewOwner": "Ambitions owner technical review",
        "reviewedAt": "2026-07-01T00:00:00Z",
        "publicReferenceOnly": True,
        "privateContextPresent": False,
        "finalOutputAllowed": False,
        "coverageCounterMutationAllowed": False,
        "reversibleActivation": True,
        "selectedMutationIDs": [mutation_id],
        "stageApprovals": {
            "harvest": "approved",
            "claimExtraction": "approved",
            "adjudication": "approved",
            "packCompile": "approved",
            "r2Promotion": "approved",
            "nativeActivation": "approved",
        },
        "r2WriteApproval": {
            "allowed": allow_r2,
            "publicReferenceOnly": True,
            "reversible": True,
        },
        "nativeActivationApproval": {
            "allowed": allow_native,
            "verifiedPublicManifestRequired": True,
            "noPrivateEgressRequired": True,
        },
    }
