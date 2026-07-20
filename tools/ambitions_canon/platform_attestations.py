"""Construct exact GitHub event, approval, and validation attestations."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import secrets
import subprocess
from typing import Mapping, Sequence

from .authorization import (
    AuthorizationError,
    _load_base_trust_state,
    _task_rule,
    canonical_json_bytes,
    load_base_policy,
    load_trusted_bindings,
    task_start,
    trusted_event_projection_digest,
    validate_task_authorization,
    validate_task_intake,
)
from .platform_signing import embedded_anchor, sign_attestation


def _git(repo_root: Path, *arguments: str) -> str:
    completed = subprocess.run(
        ["git", "-C", str(repo_root), *arguments],
        check=False,
        capture_output=True,
        text=True,
    )
    if completed.returncode != 0:
        raise AuthorizationError(
            "AUTH_PLATFORM_GIT", "unable to resolve exact platform commit range"
        )
    return completed.stdout.strip()


def create_start_attestations(
    *,
    repo_root: Path,
    intake_data: Mapping[str, object],
    base_ref: str,
    trusted_base_sha: str,
    trusted_head_sha: str,
    pull_request_number: int,
    verification_epoch: int,
    workflow_run_id: int,
    workflow_run_attempt: int,
    authenticated_principal: str,
    event_private_key_pem: str,
    approval_private_key_pem: str,
) -> tuple[dict[str, object], dict[str, object], dict[str, object]]:
    """Create signed start inputs and the exact CI-range authorization."""

    intake = validate_task_intake(intake_data)
    policy = load_base_policy(repo_root, trusted_base_sha)
    bindings = load_trusted_bindings(
        repo_root, trusted_base_sha, intake, policy
    )
    (
        _normalized_policy,
        _recomputed_bindings,
        command_manifest,
        _trust_anchors,
        _nonce_snapshot,
        _skill_context,
    ) = _load_base_trust_state(
        repo_root, trusted_base_sha, intake, policy
    )
    task_rule = _task_rule(policy, intake)
    identity = policy["repository_identity"]
    issue_state = policy["issue_state"]
    nonce_state = policy["approval_nonce_state"]
    workflow = command_manifest["trusted_workflow"]
    assert isinstance(identity, Mapping)
    assert isinstance(issue_state, Mapping)
    assert isinstance(nonce_state, Mapping)
    assert isinstance(workflow, Mapping)
    merge_base_sha = _git(
        repo_root, "merge-base", trusted_base_sha, trusted_head_sha
    )
    if merge_base_sha != trusted_base_sha:
        raise AuthorizationError(
            "AUTH_PLATFORM_DIVERGED",
            "candidate head must contain the exact trusted base",
        )

    unsigned_event: dict[str, object] = {
        "schema_version": 1,
        "event_provider": "github",
        "event_attestation_origin": "trusted-ci",
        "repository_id": identity["repository_id"],
        "repository_full_name": identity["repository_full_name"],
        "pull_request_number": pull_request_number,
        "base_ref": base_ref,
        "trusted_base_sha": trusted_base_sha,
        "trusted_head_sha": trusted_head_sha,
        "merge_base_sha": merge_base_sha,
        "verification_epoch": verification_epoch,
        "expires_at_epoch": verification_epoch + 3600,
        "workflow_run_id": workflow_run_id,
        "workflow_run_attempt": workflow_run_attempt,
        "consumption_generation": nonce_state["consumption_generation"],
        "issue_state_transition": {
            "schema_version": 1,
            "snapshot_revision": "github-platform-event-v1",
            "base_issue_state_sha256": hashlib.sha256(
                canonical_json_bytes(issue_state)
            ).hexdigest(),
            "completed_task_receipts": [],
        },
    }
    unsigned_event["event_projection_digest"] = trusted_event_projection_digest(
        unsigned_event
    )
    event_anchor_id = str(policy["event_trust_anchor_id"])
    event = sign_attestation(
        unsigned_event,
        anchor=embedded_anchor(
            policy, anchor_id=event_anchor_id, purpose="event"
        ),
        purpose="event",
        private_key_pem=event_private_key_pem,
    )

    approval_references = task_rule["approval_policy_ids"]
    assert isinstance(approval_references, list)
    if len(approval_references) != 1 or "@" not in approval_references[0]:
        raise AuthorizationError(
            "AUTH_APPROVAL_POLICY", "platform signer requires one exact approval policy"
        )
    approval_policy_id, approval_policy_revision = str(
        approval_references[0]
    ).rsplit("@", 1)
    policies = policy["approval_policies"]
    assert isinstance(policies, list)
    matching_policies = [
        item
        for item in policies
        if item["policy_id"] == approval_policy_id
        and item["policy_revision"] == approval_policy_revision
    ]
    if len(matching_policies) != 1 or authenticated_principal not in (
        matching_policies[0]["authenticated_principals"]
    ):
        raise AuthorizationError(
            "AUTH_APPROVAL_POLICY", "platform principal is not base allowlisted"
        )
    intake_digest = hashlib.sha256(canonical_json_bytes(intake)).hexdigest()
    unsigned_approval: dict[str, object] = {
        "schema_version": 1,
        "attestation_id": (
            f"APPROVAL-{intake['task_id']}-{workflow_run_id}-"
            f"{workflow_run_attempt}"
        ),
        "attestation_origin": "platform-authenticated",
        "repository_id": identity["repository_id"],
        "repository_full_name": identity["repository_full_name"],
        "pull_request_number": pull_request_number,
        "task_id": intake["task_id"],
        "intake_id": intake["intake_id"],
        "trusted_base_sha": trusted_base_sha,
        "trusted_head_sha": trusted_head_sha,
        "merge_base_sha": merge_base_sha,
        "intake_digest": intake_digest,
        "policy_revision": policy["policy_revision"],
        "command_manifest_digest": bindings["command_manifest_sha256"],
        "workflow_path": workflow["path"],
        "workflow_ref": workflow["ref"],
        "workflow_digest": workflow["digest"],
        "workflow_run_id": workflow_run_id,
        "workflow_run_attempt": workflow_run_attempt,
        "event_projection_digest": event["event_projection_digest"],
        "consumption_generation": event["consumption_generation"],
        "check_identity": workflow["check_identity"],
        "integration_id": workflow["integration_id"],
        "app_id": workflow["app_id"],
        "approval_policy_id": approval_policy_id,
        "approval_policy_revision": approval_policy_revision,
        "authenticated_principal": authenticated_principal,
        "approved_scope": intake["requested_scope"],
        "one_time_use_nonce": secrets.token_urlsafe(32),
        "verification_epoch": verification_epoch,
        "consumed": False,
        "expires_at_epoch": verification_epoch + 3600,
        "revoked": False,
        "break_glass": False,
        "incident_id": None,
        "rollback_ref": None,
        "post_action_review_required": False,
    }
    approval_anchor_id = str(policy["approval_trust_anchor_id"])
    approval = sign_attestation(
        unsigned_approval,
        anchor=embedded_anchor(
            policy, anchor_id=approval_anchor_id, purpose="approval"
        ),
        purpose="approval",
        private_key_pem=approval_private_key_pem,
    )
    authorization = task_start(
        repo_root=repo_root,
        mode="ci-pr-range",
        intake_data=intake,
        trusted_event_data=event,
        trusted_bindings=bindings,
        policy_data=policy,
        approval_attestations=(approval,),
        verification_epoch=verification_epoch,
    )
    return event, approval, authorization


def create_validation_attestations(
    *,
    repo_root: Path,
    authorization: Mapping[str, object],
    evidence: Mapping[str, Mapping[str, object]],
    validation_private_key_pem: str,
) -> list[dict[str, object]]:
    """Sign Green evidence only for every command required by authorization."""

    normalized_authorization = validate_task_authorization(authorization)
    intake = normalized_authorization["intake"]
    event = normalized_authorization["trusted_event_provenance"]
    bindings = normalized_authorization["trusted_bindings"]
    assert isinstance(intake, Mapping)
    assert isinstance(event, Mapping)
    assert isinstance(bindings, Mapping)
    policy = load_base_policy(repo_root, str(event["trusted_base_sha"]))
    (
        _normalized_policy,
        _recomputed_bindings,
        command_manifest,
        _trust_anchors,
        _nonce_snapshot,
        _skill_context,
    ) = _load_base_trust_state(
        repo_root, str(event["trusted_base_sha"]), intake, policy
    )
    workflow = command_manifest["trusted_workflow"]
    assert isinstance(workflow, Mapping)
    required_checks = sorted(
        str(item) for item in normalized_authorization["computed_required_checks"]
    )
    if sorted(evidence) != required_checks:
        raise AuthorizationError(
            "AUTH_VALIDATION_MISSING", "platform evidence does not cover exact checks"
        )
    authorization_digest = hashlib.sha256(
        canonical_json_bytes(normalized_authorization)
    ).hexdigest()
    anchor_id = str(policy["validation_trust_anchor_id"])
    anchor = embedded_anchor(policy, anchor_id=anchor_id, purpose="validation")
    attestations: list[dict[str, object]] = []
    for command_id in required_checks:
        observed = evidence[command_id]
        artifact_digest = observed.get("artifact_digest")
        if (
            observed.get("status") != "green"
            or observed.get("exit_status") != 0
            or not isinstance(artifact_digest, str)
            or len(artifact_digest) != 64
            or any(character not in "0123456789abcdef" for character in artifact_digest)
            or artifact_digest == "0" * 64
        ):
            raise AuthorizationError(
                "AUTH_VALIDATION_NOT_GREEN", f"platform check is not Green: {command_id}"
            )
        unsigned: dict[str, object] = {
            "schema_version": 1,
            "attestation_id": (
                f"VALIDATION-{intake['task_id']}-{command_id}-"
                f"{event['workflow_run_id']}-{event['workflow_run_attempt']}"
            ),
            "attestation_origin": "trusted-ci",
            "pull_request_number": event["pull_request_number"],
            "task_id": intake["task_id"],
            "intake_id": intake["intake_id"],
            "intake_digest": normalized_authorization["intake_digest"],
            "policy_revision": bindings["policy_revision"],
            "authorization_digest": authorization_digest,
            "command_manifest_digest": bindings["command_manifest_sha256"],
            "workflow_path": workflow["path"],
            "workflow_ref": workflow["ref"],
            "workflow_digest": workflow["digest"],
            "command_id": command_id,
            "command_argv_digest": normalized_authorization[
                "computed_command_digests"
            ][command_id],
            "check_identity": workflow["check_identity"],
            "repository_id": event["repository_id"],
            "repository_full_name": event["repository_full_name"],
            "trusted_base_sha": event["trusted_base_sha"],
            "trusted_head_sha": event["trusted_head_sha"],
            "merge_base_sha": event["merge_base_sha"],
            "integration_id": workflow["integration_id"],
            "app_id": workflow["app_id"],
            "exit_status": 0,
            "artifact_digest": artifact_digest,
            "proof_obligation_ids": normalized_authorization[
                "computed_proof_command_bindings"
            ][command_id],
            "skipped": False,
            "skipped_reason": None,
            "status": "green",
            "claim_ceiling": normalized_authorization["computed_claim_ceiling"],
            "ci_owned": True,
        }
        attestations.append(
            sign_attestation(
                unsigned,
                anchor=anchor,
                purpose="validation",
                private_key_pem=validation_private_key_pem,
            )
        )
    return attestations
