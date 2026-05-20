#!/usr/bin/env python3
"""Fail fast when Ambitions runner access is not full/approval-enabled.

This validates the repo-scoped Codex config used by local trusted runs. It does
not grant OS permissions by itself; it ensures the Ambitions repo config keeps
the operator-approved posture explicit and auditable.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / ".codex/config.toml"

REQUIRED = {
    "approval_policy": "on-request",
    "sandbox_mode": "danger-full-access",
}


def read_config() -> str:
    try:
        return CONFIG.read_text(encoding="utf-8")
    except FileNotFoundError:
        print(f"RED: missing {CONFIG.relative_to(ROOT)}", file=sys.stderr)
        raise SystemExit(1)


def find_value(text: str, key: str) -> str | None:
    pattern = re.compile(rf"^\s*{re.escape(key)}\s*=\s*\"([^\"]+)\"\s*$", re.MULTILINE)
    match = pattern.search(text)
    return match.group(1) if match else None


def main() -> int:
    text = read_config()
    failures: list[str] = []

    for key, expected in REQUIRED.items():
        actual = find_value(text, key)
        if actual != expected:
            failures.append(f"{key} is {actual!r}; expected {expected!r}")

    if failures:
        print("RED: Ambitions runner is not configured for full-access approval-enabled execution")
        for failure in failures:
            print(f"- {failure}")
        print("Fix .codex/config.toml or intentionally bypass this guard with explicit operator policy.")
        return 1

    print("GREEN: Ambitions runner access posture is full-access approval-enabled")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
