#!/usr/bin/env python3
"""Classify Ambitions batch failures into fast train actions.

This helper reads text from stdin or --file and prints a deterministic category. It is
intended to reduce deliberation time, not to weaken proof requirements.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

CATEGORIES = {
    "repairable_in_scope": [
        "compile error", "unit test failed", "missing import", "type error", "lint", "format", "fixture", "validator failed"
    ],
    "accepted_yellow_candidate": [
        "optional", "warning", "degraded", "lane none", "not available", "informational", "yellow"
    ],
    "hard_red_scope_violation": [
        "out of scope", "forbidden", "scope violation", "unexpected file", "reactivate completed"
    ],
    "hard_red_dirty_worktree": [
        "dirty worktree", "unknown dirty", "uncommitted user work", "external dirty"
    ],
    "hard_red_queue_corruption": [
        "queue corruption", "canonical id drift", "missing batch", "duplicate executable", "pk17 reactivation"
    ],
    "hard_red_release_claim": [
        "release ready", "app store", "testflight", "device proof", "privacy approval", "legal approval"
    ],
    "hard_red_hbi_guard": [
        "historical baseline train guard: fail", "hbi guard", "historical baseline guard"
    ],
    "hard_red_mri_conflict": [
        "mri conflict", "mri routing conflict", "moat runtime conflict"
    ],
}

SEVERITY_ORDER = [
    "hard_red_dirty_worktree",
    "hard_red_queue_corruption",
    "hard_red_scope_violation",
    "hard_red_release_claim",
    "hard_red_hbi_guard",
    "hard_red_mri_conflict",
    "repairable_in_scope",
    "accepted_yellow_candidate",
]


def classify(text: str) -> dict[str, Any]:
    lower = text.lower()
    hits: dict[str, list[str]] = {}
    for category, terms in CATEGORIES.items():
        matched = [term for term in terms if term in lower]
        if matched:
            hits[category] = matched
    chosen = "repairable_in_scope" if not hits else next((cat for cat in SEVERITY_ORDER if cat in hits), "repairable_in_scope")
    if chosen.startswith("hard_red"):
        action = "stop_and_report_red"
    elif chosen == "accepted_yellow_candidate":
        action = "document_yellow_if_source_truth_allows_then_continue"
    else:
        action = "repair_within_current_batch_scope"
    return {
        "classification": chosen,
        "recommended_action": action,
        "matches": hits,
        "claim_boundary": "classification aid only; final decision must follow active source truth and batch report evidence",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Classify Ambitions batch failure text.")
    parser.add_argument("--file", type=Path)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    if args.file:
        text = args.file.read_text(encoding="utf-8", errors="replace")
    else:
        text = sys.stdin.read()
    result = classify(text)
    if args.json:
        print(json.dumps(result, indent=2, sort_keys=True))
    else:
        print(result["classification"])
        print(result["recommended_action"])
    return 1 if result["classification"].startswith("hard_red") else 0


if __name__ == "__main__":
    raise SystemExit(main())
