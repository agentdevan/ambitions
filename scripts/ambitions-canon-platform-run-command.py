#!/usr/bin/env python3
"""Run one base-owned validation command against an exact candidate checkout."""

from __future__ import annotations

import argparse
import hashlib
import json
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
        completed = subprocess.run(
            command["argv"],
            cwd=arguments.candidate_root,
            check=False,
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
