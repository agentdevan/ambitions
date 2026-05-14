#!/usr/bin/env python3
from __future__ import annotations

import re

from ambitions_visual_100_common import BASE, scan_frontend_text_files, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-vocabulary-full-corpus.json"
FORBIDDEN = [
    "best next move",
    "next best move",
    "Begin Focus",
    "Start Focus",
    "chatbot",
    "assistant",
    "AI assistant",
    "streak",
    "score",
    "ring",
    "leaderboard",
    "sportsbook",
    "gambling",
]
SUPPORT_FILES = {
    "ACTIVE_IA_AND_SURFACE_MAP.md",
    "TERM_ALIAS_AND_DEPRECATION_REGISTRY.md",
    "VISUAL_ANTI_SLOP_RULES.md",
    "VISUAL_DECISION_RECORDS.md",
    "VISUAL_ENCYCLOPEDIA_PERFECTION_PLAN.md",
    "VISUAL_ENCYCLOPEDIA_RUTHLESS_AUDIT.md",
    "VISUAL_ITEM_REGISTRY.md",
    "VISUAL_ITEM_REGISTRY.yaml",
    "VISUAL_OBJECT_FIRST_REVIEW_RUBRIC.md",
    "VISUAL_RECIPE_SHORT_FORM_TEMPLATE.md",
    "VISUAL_SOURCE_LINKS.yaml",
    "VISUAL_VOCABULARY_BOUNDARY.md",
    "SURFACE_RECIPE_INDEX.md",
    "SURFACE_RECIPE_INVENTORY.md",
    "SURFACE_RECIPE_INVENTORY.yaml",
    "FRONTEND_SOURCE_PRECEDENCE_LEDGER.md",
    "VISUAL_DIRECTION_SOURCE_FAMILY_EXTRACTION_LEDGER.md",
    "VISUAL_100_FLAG_RESOLUTION_MATRIX.yaml",
}


def negative_context(line: str, heading: str) -> bool:
    text = f"{heading} {line}".lower()
    return bool(
        re.search(
            r"\b(no|not|never|without|avoid|instead of|replace|do not|does not|cannot|can't|won't|forbidden|historical|compatibility|obsolete|internal|example|boundary|negative|anti-generic|score system|rank or score|non-score|gambling|benchmark)\b",
            text,
        )
    )


def main() -> int:
    violations = []
    for path in scan_frontend_text_files():
        rel = path.relative_to(BASE)
        if path.name in SUPPORT_FILES or path.name.endswith("_SCORECARD.md"):
            continue
        text = path.read_text(encoding="utf-8")
        current_heading = ""
        for line in text.splitlines():
            stripped = line.strip()
            if stripped.startswith("#"):
                current_heading = stripped.lstrip("#").strip().lower()
                continue
            if negative_context(line, current_heading):
                continue
            lower = line.lower()
            if any(keyword in current_heading for keyword in ["forbidden", "anti", "banned", "red flag", "failure", "misuse", "example", "boundary", "historical", "obsolete", "compatibility"]):
                continue
            for term in FORBIDDEN:
                pattern = rf"\b{re.escape(term)}\b" if " " not in term else re.escape(term)
                if re.search(pattern, line, re.IGNORECASE):
                    violations.append({"file": str(rel), "term": term, "line": line.strip()})
    status = "green" if not violations else "red"
    write_json(REPORT, {"violations": violations, "status": status})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
