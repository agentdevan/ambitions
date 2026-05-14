#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import scan_frontend_text_files, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-hidden-automation.json"


def main() -> int:
    terms = ["preview", "automation", "user control", "inspectable", "stale source", "learned pattern"]
    hits = []
    for path in scan_frontend_text_files():
        text = path.read_text(encoding="utf-8").lower()
        if all(term in text for term in terms[:2]) and any(term in text for term in terms[2:]):
            hits.append(str(path.relative_to(path.parents[3])))
    status = "green" if hits else "red"
    write_json(REPORT, {"hits": hits, "status": status})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
