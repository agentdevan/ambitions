#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys

# Canon propagation orchestration entrypoint.

COMMANDS = [
    ["python3", "scripts/governance/ambitions-canon-impact-map.py"],
    ["python3", "scripts/governance/ambitions-canon-propagation-engine.py"],
    ["python3", "scripts/governance/ambitions-spec-synthesis.py"],
    ["python3", "scripts/governance/ambitions-prompt-rewrite-planner.py"],
    ["python3", "scripts/governance/ambitions-supersession-rewriter.py"],
    ["python3", "scripts/governance/ambitions-global-train-resequencer.py"],
    ["python3", "scripts/governance/ambitions-implementation-expectation-map.py"],
    ["python3", "scripts/governance/ambitions-cleanup-action-plan.py"],
    ["python3", "scripts/governance/ambitions-repo-doctor.py"],
]


def main() -> int:
    failures = []

    for cmd in COMMANDS:
        print(f"RUNNING: {' '.join(cmd)}")
        result = subprocess.run(cmd)
        if result.returncode != 0:
            failures.append((cmd, result.returncode))

    if failures:
        print("Canon installer completed with failures:")
        for cmd, code in failures:
            print(f"- {' '.join(cmd)} -> {code}")
        return 1

    print("Canon installer completed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
