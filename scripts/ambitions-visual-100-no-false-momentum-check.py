#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import scan_frontend_text_files, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-no-false-momentum.json"


def main() -> int:
    terms = [
        "Still Counts",
        "Waiting",
        "Blocked",
        "Captured but unplaced",
        "No False Momentum",
        "Moved is not progress",
        "Skipped is not failure",
        "Blocked is not user fault",
    ]
    hits = []
    for path in scan_frontend_text_files():
        text = path.read_text(encoding="utf-8")
        if any(term.lower() in text.lower() for term in terms):
            hits.append(str(path.relative_to(path.parents[3])))
    status = "green" if hits else "red"
    write_json(REPORT, {"hits": hits, "status": status, "terms": terms})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
