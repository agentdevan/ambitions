#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
from pathlib import Path

GENERATED = Path("docs/governance/generated")
OUT = GENERATED / "governance_trend_report.json"
HISTORY = GENERATED / "governance_trend_history.json"


def git_commit_iso() -> str:
    proc = subprocess.run(
        ["git", "show", "-s", "--format=%cI", "HEAD"],
        cwd=Path(__file__).resolve().parents[2],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    return proc.stdout.strip() or "unknown"


def main() -> int:
    summary_path = GENERATED / "governance_reconciliation_summary.json"
    if not summary_path.exists():
        print("missing governance summary")
        return 1

    summary = json.loads(summary_path.read_text())

    point = {
        "timestamp": git_commit_iso(),
        "train_count": summary.get("train_count", 0),
        "needs_reconciliation_count": summary.get("needs_reconciliation_count", 0),
        "stale_overlay_count": summary.get("stale_overlay_count", 0),
    }

    history = []
    if HISTORY.exists():
        history = json.loads(HISTORY.read_text())

    if not history or history[-1] != point:
        history.append(point)

    HISTORY.write_text(json.dumps(history[-200:], indent=2) + "\n")
    OUT.write_text(json.dumps(point, indent=2) + "\n")

    print("governance trend report updated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
