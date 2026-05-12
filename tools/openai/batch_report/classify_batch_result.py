#!/usr/bin/env python3
"""Classify a batch closeout report from extracted fields."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.openai.batch_report.summarize_batch_report import summarize  # noqa: E402


def classify(summary: dict) -> dict:
    status = (summary.get("status") or "MISSING").upper()
    if status == "RED":
        level = "red"
    elif status == "GREEN":
        if summary.get("rollback_present") and summary.get("no_claim_language_present") and summary.get("next_handoff_present"):
            level = "green"
        else:
            level = "yellow"
    elif status == "YELLOW":
        level = "yellow"
    else:
        level = "yellow"

    return {
        "status": status,
        "classification": level,
        "changed_files_count": len(summary.get("changed_files", [])),
        "validation_count": len(summary.get("validation_commands", [])),
        "issues": {
            "missing_rollback": not summary.get("rollback_present"),
            "missing_no_claim_language": not summary.get("no_claim_language_present"),
            "missing_next_handoff": not summary.get("next_handoff_present"),
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Classify a batch closeout report")
    parser.add_argument("report")
    args = parser.parse_args()

    path = Path(args.report)
    if not path.exists():
        print(f"Missing report: {path}")
        return 1

    summary = summarize(path)
    print(json.dumps(classify(summary), indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
