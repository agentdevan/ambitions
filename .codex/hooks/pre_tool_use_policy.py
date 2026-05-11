#!/usr/bin/env python3
"""Pre-tool-use policy enforcement for Bash commands."""

from __future__ import annotations

import json
import os
import re
from pathlib import Path


FORBIDDEN = [
    re.compile(r"\bgit\s+push\b", re.IGNORECASE),
    re.compile(r"\bgit\s+reset\s+--hard\b", re.IGNORECASE),
    re.compile(r"\bgit\s+clean\s+-fdx\b", re.IGNORECASE),
    re.compile(r"\b(rm|del)\s+-rf\b", re.IGNORECASE),
    re.compile(r"\bcurl\b", re.IGNORECASE),
    re.compile(r"\bwget\b", re.IGNORECASE),
    re.compile(r"\bnpm\s+(install|i)\b", re.IGNORECASE),
    re.compile(r"\byarn\s+(install|add)\b", re.IGNORECASE),
    re.compile(r"\bpnpm\s+(install|add)\b", re.IGNORECASE),
    re.compile(r"\bpip\s+install\b", re.IGNORECASE),
    re.compile(r"\bbrew\s+install\b", re.IGNORECASE),
    re.compile(r"\b(OPENAI_API_KEY|CODEX_API_KEY|API_KEY)\s*=", re.IGNORECASE),
    re.compile(r"\bxcrun\s+(altool|notarytool)\b", re.IGNORECASE),
    re.compile(r"\bxcodebuild\s+archive\b", re.IGNORECASE),
]

ALLOWED_ABS_PATH_PREFIXES = {
    "/usr",
    "/bin",
    "/opt",
    "/tmp",
    "/var/tmp",
}


def _extract_command(payload) -> str:
    if not isinstance(payload, dict):
        return ""
    values = []
    tool_input = payload.get("tool_input")
    if isinstance(tool_input, dict):
        values.append(tool_input.get("command"))
        values.append(tool_input.get("tool_input"))
    values.append(payload.get("command"))
    values.append(payload.get("input"))
    for value in values:
        if isinstance(value, str):
            return value.strip()
    return ""


def _repo_root() -> Path:
    try:
        return Path(__import__("subprocess").check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip())
    except Exception:
        return Path.cwd()


def _writes_outside_repo(command: str, repo_root: Path) -> bool:
    tokens = command.split()
    out_candidates = [t for t in tokens if t.startswith("/")]
    abs_candidates = [t.strip('"\'"') for t in out_candidates if t.startswith("/")]
    for path in abs_candidates:
        candidate = Path(path).resolve()
        try:
            candidate.relative_to(repo_root)
        except ValueError:
            if any(str(candidate).startswith(prefix) for prefix in ALLOWED_ABS_PATH_PREFIXES):
                continue
            return True
    return False


def _deny(reason: str) -> None:
    print(
        json.dumps(
            {
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
                "decision": "deny",
                "block": True,
                "legacy": {
                    "should_deny": True,
                    "reason": reason,
                },
            }
        )
    )


def _allow() -> None:
    print(
        json.dumps(
            {
                "permissionDecision": "approve",
                "permissionDecisionReason": "command policy passed",
                "decision": "approve",
                "legacy": {
                    "should_deny": False,
                    "reason": "command allowed",
                },
            }
        )
    )


def main() -> None:
    try:
        payload = json.load(open(0))
    except Exception:
        return _allow()

    command = _extract_command(payload)
    if not command:
        return _allow()

    lower = command.lower()
    for pattern in FORBIDDEN:
        if pattern.search(lower):
            return _deny("Forbidden cost-risk, network, or destructive command pattern detected")

    repo_root = _repo_root()
    if _writes_outside_repo(command, repo_root):
        if re.search(r">\s*/(?!usr|bin|tmp|var/tmp)", command):
            return _deny("Command appears to write outside the repo root")

    _allow()


if __name__ == "__main__":
    main()
