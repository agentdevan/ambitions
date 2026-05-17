#!/usr/bin/env python3
from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

COMMANDS = [
    ["python3", "scripts/governance/ambitions-canon-impact-map.py"],
    ["python3", "scripts/governance/ambitions-canon-propagation-engine.py"],
    ["python3", "scripts/governance/ambitions-spec-synthesis.py"],
    ["python3", "scripts/governance/ambitions-prompt-rewrite-planner.py"],
    ["python3", "scripts/governance/ambitions-supersession-rewriter.py"],
    ["python3", "scripts/governance/ambitions-global-train-resequencer.py"],
    ["python3", "scripts/governance/ambitions-implementation-expectation-map.py"],
    ["python3", "scripts/governance/ambitions-cleanup-action-plan.py"],
    ["python3", "scripts/governance/ambitions-architecture-debt-score.py"],
    ["python3", "scripts/governance/ambitions-repo-doctor.py"],
    ["python3", "scripts/codex-os/ambitions-codex-os-sync-governance.py"],
]


def run(cmd: list[str]) -> int:
    print(f"RUNNING: {' '.join(cmd)}")
    return subprocess.run(cmd, cwd=ROOT).returncode


def main() -> int:
    failures: list[tuple[list[str], int]] = []

    for cmd in COMMANDS:
        code = run(cmd)
        if code != 0:
            failures.append((cmd, code))

    if failures:
        print("Canon installer completed with failures:")
        for cmd, code in failures:
            print(f"- {' '.join(cmd)} -> {code}")
        return 1

    print("Canon installer completed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
