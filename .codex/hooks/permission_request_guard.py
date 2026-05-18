#!/usr/bin/env python3
"""Permission request guard for command requests likely to increase cost or risk."""

from __future__ import annotations

import json
import re


def _extract(payload: dict) -> str:
    if not isinstance(payload, dict):
        return ""
    for path in ("command", "prompt", "input", "tool_input.command", "tool_input.prompt"):
        if "." in path:
            parent, key = path.split(".")
            node = payload.get(parent)
            if isinstance(node, dict):
                value = node.get(key)
            else:
                value = None
        else:
            value = payload.get(path)
        if isinstance(value, str) and value.strip():
            return value
    return ""


def _deny(reason: str) -> None:
    print(
        json.dumps(
            {
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
                "legacy": {"should_deny": True, "reason": reason},
            }
        )
    )


def _allow() -> None:
    print(
        json.dumps(
            {
                "permissionDecision": "allow",
                "permissionDecisionReason": "permission request is in-policy",
                "legacy": {"should_deny": False, "reason": "allowed"},
            }
        )
    )


def _normalized(text: str) -> str:
    return " ".join(text.lower().split())


def _is_safe_xcode_validation(text: str) -> bool:
    normalized = _normalized(text)
    safe_prefixes = (
        "scripts/ambitions-xcode-validate.sh ",
        "./scripts/ambitions-xcode-validate.sh ",
        "bash scripts/ambitions-xcode-validate.sh ",
        "make xcode-validate",
        "make xcode-focused-test",
        "make xcode-build-for-testing",
        "make xcode-test-plan",
        "make build-lab-doctor",
    )
    if not normalized.startswith(safe_prefixes):
        return False

    forbidden_xcode_fragments = (
        " archive",
        " -exportarchive",
        " -allowprovisioningupdates",
        " altool",
        " notarytool",
        " security ",
        " codesign ",
        " productbuild ",
    )
    return not any(fragment in normalized for fragment in forbidden_xcode_fragments)


def main() -> None:
    try:
        payload = json.load(open(0))
    except Exception:
        return _allow()

    text = _extract(payload).lower()
    if not text:
        return _allow()

    if _is_safe_xcode_validation(text):
        return _allow()

    denied_phrases = (
        "git push",
        "git reset",
        "git clean -fdx",
        "npm install",
        "pip install",
        "brew install",
        "curl",
        "wget",
        "xcodebuild archive",
        "xcodebuild -exportarchive",
        "xcodebuild -allowprovisioningupdates",
        "xcrun altool",
        "xcrun notarytool",
        "gpt-oss",
        "openai_api_key",
        "codex_api_key",
        "api_key=",
    )

    if any(token in text for token in denied_phrases):
        return _deny("Permission denied by no-cost policy for command scope")

    # Delegate to shared policy-like parser without importing side effects.
    destructive_pattern = r"\b" + "rm" + r"\s+" + "-rf" + r"\b"
    if re.search(destructive_pattern, text):
        return _deny("Potential destructive command denied")

    _allow()


if __name__ == "__main__":
    main()