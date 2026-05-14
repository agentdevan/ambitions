#!/usr/bin/env python3
from __future__ import annotations

from ambitions_visual_100_common import BASE, read_text, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-prompt-authority.json"


def main() -> int:
    path = BASE.parents[2] / "prompts/batches/VISUAL-ENCYCLOPEDIA-100-FINAL-PROOF-AUTHORITY-04.md"
    text = read_text(path)
    status = "green"
    missing = []
    required = [
        "AMBITIONS_RUNNER_REQUIRED",
        "VISUAL-ENCYCLOPEDIA-100-FINAL-PROOF-AUTHORITY-04",
        "VISUAL-ENCYCLOPEDIA-100-PERFECTION-INSTALL-01",
        "VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03",
        "VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03-MERGED",
        "GPT-5.4-mini",
    ]
    for marker in required:
        if marker not in text:
            missing.append(marker)
    if missing:
        status = "red"
    write_json(REPORT, {"missing": missing, "status": status})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
