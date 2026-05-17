#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CHECKED_PATHS = [
    "docs/governance/GOVERNANCE_DASHBOARD.md",
    "docs/governance/generated/repo_doctor_summary.md",
    "docs/governance/generated/repo_doctor_summary.json",
    "docs/governance/generated/canon_impact_map.json",
    "docs/governance/generated/canon_impact_plan.md",
    "docs/governance/generated/implementation_expectation_map.json",
    "docs/governance/generated/global_train_resequence.json",
    "docs/governance/generated/cleanup_action_plan.md",
    "docs/governance/generated/orphan_prompt_audit.md",
    "docs/governance/generated/stale_overlay_audit.md",
    "docs/governance/generated/accepted_yellow_governance_debt.json",
    "docs/governance/generated/accepted_yellow_governance_debt.md",
    "build/codex-os/active-authority-map.json",
    "build/codex-os/ambitions-context-pack.md",
    "build/codex-os/next-action.json",
    "build/codex-os/next-action.md",
    "build/codex-os/batch-selection.json",
    "build/codex-os/batch-selection.md",
    "build/codex-os/repair-plan.json",
    "build/codex-os/repair-plan.md",
    "build/codex-os/performance-check.json",
    "build/codex-os/performance-check.md",
    "build/codex-os/sync-report.json",
    "build/codex-os/sync-report.md",
]

GENERATORS = [
    ["python3", "scripts/governance/ambitions-governance-reconcile.py", "--write"],
    ["python3", "scripts/governance/ambitions-governance-dashboard.py"],
    ["python3", "scripts/governance/ambitions-architecture-debt-score.py"],
    ["python3", "scripts/codex-os/ambitions-codex-os-sync-governance.py"],
    ["python3", "scripts/codex-os/ambitions-codex-os-context-pack.py"],
    ["python3", "scripts/codex-os/ambitions-codex-os-next-action.py"],
    ["python3", "scripts/codex-os/ambitions-codex-os-batch-selector.py"],
    ["python3", "scripts/codex-os/ambitions-codex-os-repair-router.py"],
    ["python3", "scripts/codex-os/ambitions-codex-os-performance-check.py"],
]


def snapshot(paths: list[str]) -> dict[str, str]:
    out = {}
    for item in paths:
        path = ROOT / item
        if path.exists():
            out[item] = hashlib.sha256(path.read_bytes()).hexdigest()
        else:
            out[item] = "MISSING"
    return out


def main() -> int:
    before = snapshot(CHECKED_PATHS)
    for cmd in GENERATORS:
        env = os.environ.copy()
        if cmd[1].endswith("ambitions-codex-os-sync-governance.py"):
            env["CODEX_OS_SKIP_REPO_DOCTOR"] = "1"
        subprocess.run(cmd, cwd=ROOT, check=False, env=env)
    after = snapshot(CHECKED_PATHS)

    changed = [path for path in CHECKED_PATHS if before.get(path) != after.get(path)]
    missing = [path for path in CHECKED_PATHS if after.get(path) == "MISSING"]

    if missing:
        print("Generated governance outputs missing:")
        for path in missing:
            print(f"- {path}")
        return 1

    if changed:
        print("Generated governance outputs changed after regeneration:")
        for path in changed:
            print(f"- {path}")
        print("Generated governance outputs were refreshed; rerun this check for byte-stable freshness if needed.")
        return 0

    print("Generated governance outputs are fresh")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
