#!/usr/bin/env python3
"""Draft champion scorecard from conservative scan outputs."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build/reports/intelligence-consolidation"
CONCEPTS = [
    "Today root surface",
    "Reality Meridian",
    "Start Here / Recommended Step",
    "Capture composer",
    "Capture routing / semantic extraction",
    "GoalThread / project model",
    "Recommendation engine",
    "Goal intent-to-day compiler",
    "Time availability engine",
    "LifeShape / Time surface",
    "Proof / Receipt service",
    "Replay trace service",
    "Closure / recovery logic",
    "Source ledger / Source Atlas",
    "User System Profile",
    "Design tokens/materials",
    "Motion/haptic primitives",
    "Accessibility helpers",
]


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    rows = []
    for concept in CONCEPTS:
        rows.append(
            {
                "concept": concept,
                "active_candidate": "UNKNOWN_REQUIRES_OWNER_REVIEW",
                "score": None,
                "canonical_champion": "UNKNOWN_REQUIRES_OWNER_REVIEW",
                "better_fragment_to_rescue": "UNKNOWN_REQUIRES_OWNER_REVIEW",
                "decision": "UNKNOWN_REQUIRES_OWNER_REVIEW",
                "reason": "Evidence requires owner review; this script does not fake champion scores.",
            }
        )
    payload = {"status": "YELLOW", "rows": rows}
    (OUT / "champion-scorecard.json").write_text(json.dumps(payload, indent=2), encoding="utf-8")
    lines = ["# Champion Scorecard", "", "Status: Yellow - draft scorecard; no fake scores.", "", "| Concept | Active candidate | Score | Canonical champion | Better fragment | Decision | Reason |", "| --- | --- | --- | --- | --- | --- | --- |"]
    for row in rows:
        lines.append(f"| {row['concept']} | {row['active_candidate']} | - | {row['canonical_champion']} | {row['better_fragment_to_rescue']} | {row['decision']} | {row['reason']} |")
    (OUT / "champion-scorecard.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("STATUS: YELLOW")
    print(f"Report: {OUT / 'champion-scorecard.md'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
