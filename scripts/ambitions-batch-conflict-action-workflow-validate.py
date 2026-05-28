#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / "docs/ops/batch-ledger/conflict-action-workflow.md"
CONFLICT_JSON = ROOT / "docs/ops/batch-ledger/conflict-report.json"

REQUIRED_ACTIONS = [
    "Retire",
    "Expedite",
    "Merge",
    "Rewrite",
    "Finish proof",
    "Cancel",
    "Keep planned",
]

REQUIRED_PHRASES = [
    "Do not bulk-create conflict issues.",
    "Do not auto-resolve conflicts.",
    "Do not treat source-only work as complete.",
    "Linear status is not repo truth.",
    "one issue per ledger item by default",
    "one issue per conflict by default",
    "No-claim boundary",
    "Closure proof",
    "AMB-39 Green criteria",
]

def main() -> int:
    if not WORKFLOW.exists():
        raise SystemExit(f"missing {WORKFLOW.relative_to(ROOT)}")

    text = WORKFLOW.read_text(encoding="utf-8")

    missing = []

    for action in REQUIRED_ACTIONS:
        marker = f"## Action: {action}"
        if marker not in text:
            missing.append(marker)

    for phrase in REQUIRED_PHRASES:
        if phrase not in text:
            missing.append(phrase)

    if CONFLICT_JSON.exists() and CONFLICT_JSON.read_text(encoding="utf-8").strip():
        payload = json.loads(CONFLICT_JSON.read_text(encoding="utf-8"))
        recommended = set()
        for conflict in payload.get("conflicts", []):
            action = conflict.get("recommended_action")
            if action:
                recommended.add(action)

        normalized_required = {
            "retire": "Retire",
            "expedite": "Expedite",
            "merge": "Merge",
            "rewrite": "Rewrite",
            "finish": "Finish proof",
            "cancel": "Cancel",
            "keep planned": "Keep planned",
            "keep_planned": "Keep planned",
        }

        for action in recommended:
            if action not in normalized_required:
                missing.append(f"unmapped recommended action from conflict report: {action}")

    if missing:
        print("AMB-39 validation failed:")
        for item in missing:
            print(f"- {item}")
        return 1

    print("AMB-39 conflict action workflow validation passed")
    print(f"workflow: {WORKFLOW.relative_to(ROOT)}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
