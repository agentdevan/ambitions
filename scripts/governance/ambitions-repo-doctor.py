#!/usr/bin/env python3
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

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

SUMMARY = Path("docs/governance/generated/repo_doctor_summary.md")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--strict", action="store_true", help="Exit non-zero if any governance command fails")
    args = parser.parse_args()

    failures: list[tuple[list[str], int]] = []
    lines = ["# Repo Doctor Summary", ""]

    for cmd in COMMANDS:
        print(f"RUNNING: {' '.join(cmd)}")
        proc = subprocess.run(cmd)
        if proc.returncode != 0:
            print(f"FAILED: {' '.join(cmd)}")
            failures.append((cmd, proc.returncode))
            lines.append(f"- RED: `{' '.join(cmd)}` exited {proc.returncode}")
        else:
            lines.append(f"- GREEN: `{' '.join(cmd)}`")

    SUMMARY.parent.mkdir(parents=True, exist_ok=True)
    if failures:
        lines += ["", "## Result", "", "Governance Red remains. Feature expansion should wait until these failures are repaired."]
    else:
        lines += ["", "## Result", "", "Repo doctor passed."]
    SUMMARY.write_text("\n".join(lines) + "\n", encoding="utf-8")

    if failures:
        print(f"Ambitions repo doctor completed with {len(failures)} governance failure(s).")
        print(f"Summary: {SUMMARY}")
        return 1 if args.strict else 0

    print("Ambitions repo doctor completed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
