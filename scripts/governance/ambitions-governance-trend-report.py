#!/usr/bin/env python3
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

GENERATED = Path("docs/governance/generated")
OUT = GENERATED / "governance_trend_report.json"
HISTORY = GENERATED / "governance_trend_history.json"


def main() -> int:
    summary_path = GENERATED / "governance_reconciliation_summary.json"
    if not summary_path.exists():
        print("missing governance summary")
        return 1

    summary = json.loads(summary_path.read_text())

    point = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "train_count": summary.get("train_count", 0),
        "needs_reconciliation_count": summary.get("needs_reconciliation_count", 0),
        "stale_overlay_count": summary.get("stale_overlay_count", 0),
    }

    history = []
    if HISTORY.exists():
        history = json.loads(HISTORY.read_text())

    history.append(point)

    HISTORY.write_text(json.dumps(history[-200:], indent=2) + "\n")
    OUT.write_text(json.dumps(point, indent=2) + "\n")

    print("governance trend report updated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
