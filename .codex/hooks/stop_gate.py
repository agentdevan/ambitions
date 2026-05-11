#!/usr/bin/env python3
"""Stop gate for Codex OS bound report shape."""

from __future__ import annotations

import json
import re
import os

REQUIRED_MARKERS = [
    r"##\s*Status",
    r"##\s*Summary",
    r"##\s*Files changed",
    r"##\s*Validation run",
    r"##\s*No-cost proof",
    r"##\s*Source-truth notes",
    r"##\s*Rollback",
    r"STATUS:\s*(GREEN|YELLOW|RED)",
]


def _collect_text(payload) -> str:
    if not isinstance(payload, dict):
        return ""
    # Accept either a plain string final note or message payloads.
    texts = []
    for key in ("message", "final", "content", "text", "output"):
        value = payload.get(key)
        if isinstance(value, str):
            texts.append(value)
    if not texts and isinstance(payload.get("event"), str):
        texts.append(payload["event"])
    return "\n".join(texts)


def _is_active(payload) -> bool:
    return str(payload.get("stop_hook_active", "false")).lower() in {"1", "true", "yes"}


def main() -> None:
    try:
        payload = json.load(open(0))
    except Exception:
        payload = {}

    if _is_active(payload):
        print(json.dumps({"continue": True, "decision": "approve"}))
        return

    text = _collect_text(payload)
    missing = [pattern for pattern in REQUIRED_MARKERS if not re.search(pattern, text, re.IGNORECASE)]

    if missing:
        print(
            json.dumps(
                {
                    "continue": False,
                    "decision": "deny",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": "Final report is missing required status section(s)",
                    "legacy": {
                        "should_deny": True,
                        "reason": "Please include the required sections: STATUS, Summary, Files changed, Validation run, No-cost proof, Source-truth notes, Risks/limitations, Rollback, Next recommended batch.",
                    },
                    "continuationPrompt": "Please continue with a complete local report in required format before completion.",
                }
            )
        )
        return

    print(json.dumps({"continue": True, "decision": "approve"}))


if __name__ == "__main__":
    main()
