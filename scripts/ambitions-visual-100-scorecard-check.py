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
    rows = {}
    for rel in SCORECARD_DOCS:
        text = read_text(BASE / rel)
        rows[rel] = text.count("|")
        if "provisional" not in text.lower():
            missing.append(rel)
    status = "green" if not missing else "red"
    write_json(REPORT, {"rows": rows, "missing": missing, "status": status})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
