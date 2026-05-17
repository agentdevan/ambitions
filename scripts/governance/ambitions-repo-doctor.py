#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys

COMMANDS = [
    ["python3", "scripts/governance/ambitions-governance-reconcile.py", "--write"],
    ["python3", "scripts/governance/ambitions-governance-dashboard.py"],
    ["python3", "scripts/governance/ambitions-lineage-confidence-score.py"],
    ["python3", "scripts/governance/ambitions-cleanup-action-plan.py"],
    ["python3", "scripts/governance/ambitions-auto-archive-candidates.py"],
    ["python3", "scripts/governance/ambitions-historical-registry-extract.py"],
    ["python3", "scripts/governance/ambitions-governance-trend-report.py"],
    ["python3", "scripts/governance/ambitions-authority-diff-report.py"],
    ["python3", "scripts/governance/ambitions-batch-closeout-validate.py"],
    ["python3", "scripts/governance/ambitions-governance-validate.py"],
    ["python3", "scripts/governance/ambitions-no-orphan-file-gate.py"],
    ["python3", "scripts/governance/ambitions-sprawl-budget-check.py"],
]


def main() -> int:
    for cmd in COMMANDS:
        print(f"RUNNING: {' '.join(cmd)}")
        proc = subprocess.run(cmd)
        if proc.returncode != 0:
            print(f"FAILED: {' '.join(cmd)}")
            print("Governance Red: repair repo hygiene before feature expansion.")
            return proc.returncode

    print("Ambitions repo doctor completed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
