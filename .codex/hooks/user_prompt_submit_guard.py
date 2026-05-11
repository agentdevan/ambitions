#!/usr/bin/env python3
"""Guard ambiguous Ambitions control-plane prompts during UserPromptSubmit."""

from __future__ import annotations

import json
import re

RUNNER_HEADER_PAT = re.compile(r"<!--\s*AMBITIONS_RUNNER_REQUIRED:\s*true\s*-->", re.IGNORECASE)
BYPASS_PHRASE = "bypass the Ambitions runner"

RISK_PHRASES = [
    "ambitions",
    "runner",
    "batch",
    "run",
    "implement",
    "implementation",
    "patch",
    "codex os",
    "repo",
    "release",
    "modify",
    "change",
]

FORBIDDEN_HINTS = [
    "openai api",
    "openai-sdk",
    "github actions",
    "hosted",
    "ci",
    "subscription",
    "gpt-oss",
    "install",
    "npm ",
    "xcodebuild archive",
]


def _extract_prompt(payload) -> str:
    if not isinstance(payload, dict):
        return ""
    candidates = [
        payload.get("prompt"),
        payload.get("text"),
        payload.get("input"),
        payload.get("message"),
    ]
    tool_input = payload.get("tool_input")
    if isinstance(tool_input, dict):
        candidates.extend([
            tool_input.get("prompt"),
            tool_input.get("text"),
            tool_input.get("command"),
            tool_input.get("raw_prompt"),
        ])

    for value in candidates:
        if isinstance(value, str):
            txt = value.strip()
            if txt:
                return txt.lower()
    return ""


def _looks_high_risk(text: str) -> bool:
    score = sum(1 for p in RISK_PHRASES if p in text)
    has_forbidden = any(f in text for f in FORBIDDEN_HINTS)
    return score >= 3 or has_forbidden


def main() -> None:
    try:
        payload = json.load(open(0))
    except Exception:
        payload = {}

    text = _extract_prompt(payload).lower()
    decision = {
        "continue": True,
        "decision": "approve",
        "permissionDecision": "allow",
    }

    if not text:
        print(json.dumps(decision))
        return

    if BYPASS_PHRASE in text:
        print(json.dumps(decision))
        return

    if _looks_high_risk(text):
        header_ok = bool(RUNNER_HEADER_PAT.search(text))
        if header_ok:
            print(json.dumps(decision))
            return

        decision.update(
            {
                "continue": False,
                "decision": "deny",
                "permissionDecision": "deny",
                "permissionDecisionReason": "Ambitions implementation/control prompts should include the runner-required header unless explicitly bypassed",
                "reason": "Ambitions implementation/control prompt lacks required runner marker",
            }
        )

    print(json.dumps(decision))


if __name__ == "__main__":
    main()
