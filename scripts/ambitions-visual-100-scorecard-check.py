#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import BASE, read_text, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-scorecard.json"
SCORECARD_DOCS = [
    "reviews/VISUAL_100_OBJECT_SCORECARD.md",
    "reviews/VISUAL_100_DESTINATION_SCORECARD.md",
    "reviews/VISUAL_100_RECIPE_SCORECARD.md",
    "reviews/VISUAL_100_PRIMITIVE_SCORECARD.md",
]


def main() -> int:
    missing = []
    score_100_violations = []
    rows = {}
    for rel in SCORECARD_DOCS:
        text = read_text(BASE / rel)
        rows[rel] = {"table_rows": text.count("|"), "has_evidence": "Evidence" in text}
        if "provisional" not in text.lower():
            missing.append(rel)
        if "| 100 |" in text or "|100|" in text:
            score_100_violations.append(rel)
        if "Evidence" not in text or "Score" not in text:
            missing.append(f"{rel}:structure")
    status = "green" if not missing and not score_100_violations else "red"
    write_json(REPORT, {"rows": rows, "missing": missing, "score_100_violations": score_100_violations, "status": status})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
