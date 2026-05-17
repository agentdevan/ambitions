#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

TREND = Path("docs/governance/generated/governance_trend_history.json")
OUT = Path("docs/governance/generated/drift_forecast.md")


def main() -> int:
    if not TREND.exists():
        OUT.write_text("# Drift Forecast\n\nNo trend history yet.\n")
        return 0

    history = json.loads(TREND.read_text())
    latest = history[-1] if history else {}

    unresolved = latest.get("needs_reconciliation_count", 0)
    stale = latest.get("stale_overlay_count", 0)

    lines = ["# Drift Forecast", ""]

    if unresolved > 0:
        lines.append(f"- Governance drift risk remains elevated due to {unresolved} unresolved reconciliation states.")
    else:
        lines.append("- Reconciliation trend currently stable.")

    if stale > 0:
        lines.append(f"- Stale overlay risk remains elevated due to {stale} stale overlay findings.")

    lines.append("- Canon changes should continue to trigger repo doctor immediately.")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines) + "\n")
    print(f"wrote {OUT}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
