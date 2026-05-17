#!/usr/bin/env python3
from __future__ import annotations

import subprocess
from pathlib import Path

GENERATED = Path("docs/governance/generated")


def git(args: list[str]) -> str:
    return subprocess.run(["git", *args], text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout


def main() -> int:
    if not GENERATED.exists():
        print("generated governance directory missing")
        return 1

    before = git(["status", "--short", str(GENERATED)])
    subprocess.run(["python3", "scripts/governance/ambitions-governance-reconcile.py", "--write"], check=False)
    subprocess.run(["python3", "scripts/governance/ambitions-governance-dashboard.py"], check=False)
    subprocess.run(["python3", "scripts/governance/ambitions-lineage-confidence-score.py"], check=False)
    subprocess.run(["python3", "scripts/governance/ambitions-cleanup-action-plan.py"], check=False)
    subprocess.run(["python3", "scripts/governance/ambitions-canon-impact-map.py"], check=False)
    after = git(["status", "--short", str(GENERATED)])

    if after != before:
        print("Generated governance outputs changed after regeneration.")
        print("Commit regenerated governance outputs or repair the generator/source mismatch.")
        print(after)
        return 1

    print("Generated governance outputs are fresh")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
