#!/usr/bin/env python3
"""Run one base-owned validation command against an exact candidate checkout."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
if str(REPOSITORY_ROOT) not in sys.path:
    sys.path.insert(0, str(REPOSITORY_ROOT))

from tools.ambitions_canon.authorization import (
    AuthorizationError,
    _load_base_trust_state,
    canonical_json_bytes,
    load_base_policy,
    validate_task_authorization,
)


_INDEPENDENT_REVIEW_COMMAND = "independent-review-evidence"
_INDEPENDENT_REVIEW_ARGV = [
    "python3",
    "scripts/ambitions-canon-independent-review-evidence.py",
]


def resolve_validation_execution(
    *,
    command_id: str,
    manifest_argv: list[str],
    trusted_root: Path,
    candidate_root: Path,
) -> tuple[list[str], Path]:
    if command_id != _INDEPENDENT_REVIEW_COMMAND:
        return list(manifest_argv), candidate_root
    if manifest_argv != _INDEPENDENT_REVIEW_ARGV:
        raise AuthorizationError(
            "AUTH_PLATFORM_COMMAND",
            "independent-review command does not name the fixed trusted verifier",
        )
    return (
        [
            sys.executable,
            str(
                trusted_root.resolve()
                / "scripts/ambitions-canon-independent-review-evidence.py"
            ),
        ],
        trusted_root,
    )


def resolve_validation_environment(
    *,
    command_id: str,
    source_environment: dict[str, str],
) -> dict[str, str]:
    environment = dict(source_environment)
    github_token = environment.pop("GH_TOKEN", None)
    if command_id == _INDEPENDENT_REVIEW_COMMAND and github_token:
        environment["GH_TOKEN"] = github_token
    return environment


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, required=True)
    parser.add_argument("--candidate-root", type=Path, required=True)
    parser.add_argument("--authorization", type=Path, required=True)
    parser.add_argument("--command-id", required=True)
    arguments = parser.parse_args(argv)
    try:
        raw = json.loads(arguments.authorization.read_text(encoding="utf-8"))
        if not isinstance(raw, dict):
            raise AuthorizationError(
                "AUTH_PLATFORM_COMMAND", "authorization is not a JSON object"
            )
        authorization = validate_task_authorization(raw)
        intake = authorization["intake"]
        event = authorization["trusted_event_provenance"]
        assert isinstance(intake, dict)
        assert isinstance(event, dict)
        base_sha = str(event["trusted_base_sha"])
        policy = load_base_policy(arguments.repo_root, base_sha)
        (
            _policy,
            _bindings,
            manifest,
            _anchors,
            _nonces,
            _skills,
        ) = _load_base_trust_state(
            arguments.repo_root, base_sha, intake, policy
        )
        commands = manifest["commands"]
        assert isinstance(commands, list)
        matches = [
            item
            for item in commands
            if item["command_id"] == arguments.command_id
        ]
        if len(matches) != 1 or arguments.command_id not in authorization[
            "computed_required_checks"
        ]:
            raise AuthorizationError(
                "AUTH_PLATFORM_COMMAND", "command is not required by authorization"
            )
        command = matches[0]
        observed_digest = hashlib.sha256(
            canonical_json_bytes(command["argv"])
        ).hexdigest()
        if observed_digest != authorization["computed_command_digests"][
            arguments.command_id
        ]:
            raise AuthorizationError(
                "AUTH_PLATFORM_COMMAND", "command argv digest changed"
            )
        manifest_argv = command["argv"]
        assert isinstance(manifest_argv, list)
        execution_argv, execution_root = resolve_validation_execution(
            command_id=arguments.command_id,
            manifest_argv=[str(item) for item in manifest_argv],
            trusted_root=arguments.repo_root,
            candidate_root=arguments.candidate_root,
        )
        environment = resolve_validation_environment(
            command_id=arguments.command_id,
            source_environment=dict(os.environ),
        )
        if arguments.command_id == _INDEPENDENT_REVIEW_COMMAND:
            environment.update(
                {
                    "AMBITIONS_CANON_REVIEW_REPOSITORY": str(
                        event["repository_full_name"]
                    ),
                    "AMBITIONS_CANON_REVIEW_PULL_REQUEST": str(
                        event["pull_request_number"]
                    ),
                    "AMBITIONS_CANON_REVIEW_HEAD_SHA": str(
                        event["trusted_head_sha"]
                    ),
                }
            )
        completed = subprocess.run(
            execution_argv,
            cwd=execution_root,
            check=False,
            env=environment,
        )
        if completed.returncode != 0:
            print(
                "P0_BLOCKER PLATFORM_COMMAND_FAILED "
                f"command={arguments.command_id} exit={completed.returncode}"
            )
            return completed.returncode or 1
        print(f"GREEN platform command command={arguments.command_id}")
        return 0
    except (OSError, UnicodeError, json.JSONDecodeError, AuthorizationError) as error:
        print(f"P0_BLOCKER PLATFORM_COMMAND_INVALID {error}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
