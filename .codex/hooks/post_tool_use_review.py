#!/usr/bin/env python3
"""Post-tool-use review notes for ambiguous or risky command outcomes."""

from __future__ import annotations

import json

RISKY_TOKENS = [
    "swift",
    "xcodebuild",
    "project.yml",
    "entitlements",
    "xcarchive",
    "swiftdata",
    ".swift",
    "xcscheme",
    "app",
]


def _collect_text(payload) -> str:
    fragments = []
    if isinstance(payload, dict):
        for key in ("tool_input", "tool_output", "output", "command", "result"):
            value = payload.get(key)
            if isinstance(value, dict):
                fragments.append(str(value))
            elif isinstance(value, str):
                fragments.append(value)
    return "\n".join(fragments).lower()


def _command(payload):
    if not isinstance(payload, dict):
        return ""
    ti = payload.get("tool_input")
    if isinstance(ti, dict):
        command = ti.get("command", "")
        if isinstance(command, str):
            return command
    return ""


def main() -> None:
    try:
        payload = json.load(open(0))
    except Exception:
        payload = {}

    command = _command(payload)
    text = _collect_text(payload)

    hints = []
    if any(token in text for token in ("error", "failed", "denied", "permission")):
        hints.append("Command output indicates a warning/failure; run validator and doctor before continuing.")

    if any(token in command.lower() for token in RISKY_TOKENS):
        hints.append("Command touched app/source-like paths or project tooling; verify scope against allowed files before claiming completion.")

    if command and "python3" in command and "validate" in command:
        hints.append("Validator run attempted; check build/reports/ambitions-codex-os-validate.json for hard evidence.")

    payload_out = {
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "validatorReminder": "Run scripts/ambitions-codex-os-validate.py and scripts/ambitions-codex-os-doctor.py after control-plane edits.",
            "notes": hints,
        },
        "continue": True,
    }

    if any(hints):
        payload_out["message"] = "Post-tool review: follow notes before green closeout"

    print(json.dumps(payload_out))


if __name__ == "__main__":
    main()
