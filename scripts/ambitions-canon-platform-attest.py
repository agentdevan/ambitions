#!/usr/bin/env python3
"""Produce exact CI authorization and finalization artifacts on GitHub."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import sys
import time

REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
if str(REPOSITORY_ROOT) not in sys.path:
    sys.path.insert(0, str(REPOSITORY_ROOT))

from tools.ambitions_canon.authorization import (
    AuthorizationError,
    _load_base_trust_state,
    load_base_policy,
    load_trusted_bindings,
    task_finalize,
    validate_task_intake,
    write_json_atomic,
)
from tools.ambitions_canon.platform_attestations import (
    create_start_attestations,
    create_validation_attestations,
)
from tools.ambitions_canon.platform_signing import (
    PlatformSigningError,
    load_private_key_from_environment,
)


def read_object(path: Path) -> dict[str, object]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise AuthorizationError(
            "AUTH_PLATFORM_INPUT", f"unable to read JSON input: {path}"
        ) from exc
    if not isinstance(value, dict):
        raise AuthorizationError("AUTH_PLATFORM_INPUT", "JSON input is not an object")
    return value


def command_matrix(
    repo_root: Path, authorization: dict[str, object]
) -> dict[str, object]:
    intake = authorization["intake"]
    event = authorization["trusted_event_provenance"]
    assert isinstance(intake, dict)
    assert isinstance(event, dict)
    base_sha = str(event["trusted_base_sha"])
    policy = load_base_policy(repo_root, base_sha)
    (
        _normalized_policy,
        _bindings,
        command_manifest,
        _anchors,
        _nonces,
        _skills,
    ) = _load_base_trust_state(repo_root, base_sha, intake, policy)
    commands = command_manifest["commands"]
    assert isinstance(commands, list)
    by_id = {str(item["command_id"]): item for item in commands}
    include = []
    for command_id in authorization["computed_required_checks"]:
        item = by_id[str(command_id)]
        include.append(
            {
                "command_id": command_id,
                "argv": item["argv"],
                "argv_digest": authorization["computed_command_digests"][
                    command_id
                ],
            }
        )
    return {"include": include}


def start(arguments: argparse.Namespace) -> None:
    intake = validate_task_intake(read_object(arguments.intake_json))
    event, approval, authorization = create_start_attestations(
        repo_root=arguments.repo_root,
        intake_data=intake,
        base_ref=arguments.base_ref,
        trusted_base_sha=arguments.base_sha,
        trusted_head_sha=arguments.head_sha,
        pull_request_number=arguments.pull_request_number,
        verification_epoch=arguments.verification_epoch,
        workflow_run_id=arguments.workflow_run_id,
        workflow_run_attempt=arguments.workflow_run_attempt,
        authenticated_principal=arguments.authenticated_principal,
        event_private_key_pem=load_private_key_from_environment(
            "AMBITIONS_CANON_ATTESTATION_PRIVATE_KEY"
        ),
        approval_private_key_pem=load_private_key_from_environment(
            "AMBITIONS_CANON_APPROVAL_PRIVATE_KEY"
        ),
    )
    arguments.output_dir.mkdir(parents=True, exist_ok=True)
    write_json_atomic(arguments.output_dir / "trusted-event.json", event)
    write_json_atomic(arguments.output_dir / "approval-attestation.json", approval)
    write_json_atomic(arguments.output_dir / "task-authorization.json", authorization)
    write_json_atomic(
        arguments.output_dir / "validation-matrix.json",
        command_matrix(arguments.repo_root, authorization),
    )


def finalize(arguments: argparse.Namespace) -> None:
    authorization = read_object(arguments.authorization)
    event = read_object(arguments.trusted_event)
    approval = read_object(arguments.approval_attestation)
    delegation_authorization = (
        read_object(arguments.delegation_authorization)
        if arguments.delegation_authorization is not None
        else None
    )
    delegation_event = (
        read_object(arguments.delegation_event)
        if arguments.delegation_event is not None
        else None
    )
    delegation_approval = (
        read_object(arguments.delegation_approval)
        if arguments.delegation_approval is not None
        else None
    )
    intake = authorization.get("intake")
    if not isinstance(intake, dict):
        raise AuthorizationError(
            "AUTH_PLATFORM_INPUT", "authorization has no embedded intake"
        )
    evidence = read_object(arguments.evidence)
    typed_evidence: dict[str, dict[str, object]] = {}
    for command_id, item in evidence.items():
        if not isinstance(command_id, str) or not isinstance(item, dict):
            raise AuthorizationError(
                "AUTH_PLATFORM_INPUT", "validation evidence is malformed"
            )
        typed_evidence[command_id] = item
    validations = create_validation_attestations(
        repo_root=arguments.repo_root,
        authorization=authorization,
        evidence=typed_evidence,
        validation_private_key_pem=load_private_key_from_environment(
            "AMBITIONS_CANON_ATTESTATION_PRIVATE_KEY"
        ),
    )
    base_sha = str(event["trusted_base_sha"])
    policy = load_base_policy(arguments.repo_root, base_sha)
    bindings = load_trusted_bindings(
        arguments.repo_root, base_sha, intake, policy
    )
    receipt = task_finalize(
        repo_root=arguments.repo_root,
        authorization=authorization,
        intake_data=intake,
        trusted_event_data=event,
        trusted_bindings=bindings,
        policy_data=policy,
        approval_attestations=(approval,),
        validation_attestations=validations,
        verification_epoch=int(event["verification_epoch"]),
        evaluation_epoch=int(time.time()),
        delegation_start_authorization=delegation_authorization,
        delegation_start_event=delegation_event,
        delegation_start_approval=delegation_approval,
    )
    arguments.output_dir.mkdir(parents=True, exist_ok=True)
    for index, validation in enumerate(validations, start=1):
        write_json_atomic(
            arguments.output_dir / f"validation-{index:03d}.json", validation
        )
    write_json_atomic(arguments.output_dir / "task-finalization.json", receipt)


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser()
    result.add_argument("--repo-root", type=Path, default=Path.cwd())
    subparsers = result.add_subparsers(dest="command", required=True)

    start_parser = subparsers.add_parser("start")
    start_parser.add_argument("--intake-json", type=Path, required=True)
    start_parser.add_argument("--base-ref", required=True)
    start_parser.add_argument("--base-sha", required=True)
    start_parser.add_argument("--head-sha", required=True)
    start_parser.add_argument("--pull-request-number", type=int, required=True)
    start_parser.add_argument("--verification-epoch", type=int, required=True)
    start_parser.add_argument("--workflow-run-id", type=int, required=True)
    start_parser.add_argument("--workflow-run-attempt", type=int, required=True)
    start_parser.add_argument("--authenticated-principal", required=True)
    start_parser.add_argument("--output-dir", type=Path, required=True)
    start_parser.set_defaults(function=start)

    finalize_parser = subparsers.add_parser("finalize")
    finalize_parser.add_argument("--authorization", type=Path, required=True)
    finalize_parser.add_argument("--trusted-event", type=Path, required=True)
    finalize_parser.add_argument("--approval-attestation", type=Path, required=True)
    finalize_parser.add_argument("--delegation-authorization", type=Path)
    finalize_parser.add_argument("--delegation-event", type=Path)
    finalize_parser.add_argument("--delegation-approval", type=Path)
    finalize_parser.add_argument("--evidence", type=Path, required=True)
    finalize_parser.add_argument("--output-dir", type=Path, required=True)
    finalize_parser.set_defaults(function=finalize)
    return result


def main(argv: list[str] | None = None) -> int:
    arguments = parser().parse_args(argv)
    try:
        arguments.function(arguments)
    except (AuthorizationError, PlatformSigningError, KeyError, ValueError) as error:
        print(f"P0_BLOCKER PLATFORM_ATTESTATION_FAILED {error}")
        return 1
    print(f"GREEN platform attestation {arguments.command}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
