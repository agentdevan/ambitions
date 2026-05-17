#!/usr/bin/env python3
from __future__ import annotations

import re

from ambitions_visual_100_common import scan_frontend_text_files, write_json, REPORT_DIR


REPORT = REPORT_DIR / "visual-100-anti-generic.json"
PHRASES = [
    "semantic hierarchy",
    "use premium materials",
    "make it calm",
    "avoid generic ui",
    "surface trusted context",
    "proof-aware state",
    "make it native",
    "shared object system",
    "related commitments, proof, source, state markers",
    "task list",
    "calendar clone",
    "chatbot persona",
    "settings clone",
    "dashboard",
    "card stack",
    "assistant panel",
]
EXEMPT_FILES = {
    "ACTIVE_IA_AND_SURFACE_MAP.md",
    "FRONTEND_SOURCE_PRECEDENCE_LEDGER.md",
    "SURFACE_RECIPE_INDEX.md",
    "SURFACE_RECIPE_INVENTORY.md",
    "SURFACE_RECIPE_INVENTORY.yaml",
    "TERM_ALIAS_AND_DEPRECATION_REGISTRY.md",
    "VISUAL_ANTI_SLOP_RULES.md",
    "VISUAL_DIRECTION_SOURCE_FAMILY_EXTRACTION_LEDGER.md",
    "VISUAL_ENCYCLOPEDIA_RUTHLESS_AUDIT.md",
    "VISUAL_ENCYCLOPEDIA_PERFECTION_PLAN.md",
    "VISUAL_ITEM_REGISTRY.md",
    "VISUAL_ITEM_REGISTRY.yaml",
    "VISUAL_OBJECT_FIRST_REVIEW_RUBRIC.md",
    "VISUAL_SOURCE_LINKS.yaml",
    "VISUAL_VOCABULARY_BOUNDARY.md",
    "SURFACE_RECIPE_INDEX.md",
    "SURFACE_RECIPE_INVENTORY.md",
    "SURFACE_RECIPE_INVENTORY.yaml",
    "TYPOGRAPHY.md",
}


def negative_context(line: str, heading: str) -> bool:
    text = f"{heading} {line}".lower()
    return bool(
        re.search(
            r"\b(no|not|never|without|avoid|avoids|avoiding|prevent|prevents|instead of|rather than|replace|do not|does not|cannot|can't|won't|forbidden|misuse|historical|compatibility|obsolete|internal|example|examples|bad|fail|fails|failure|regression|boundary|negative|anti-generic|non-generic|supersede|supersedes|superseded|benchmark)\b",
            text,
        )
    )


def main() -> int:
    hits = {}
    for path in scan_frontend_text_files():
        if path.name in EXEMPT_FILES or any(part in {"gates", "trace", "reviews"} for part in path.parts):
            continue
        text = path.read_text(encoding="utf-8")
        current_heading = ""
        for line in text.splitlines():
            stripped = line.strip()
            if stripped.startswith("#"):
                current_heading = stripped.lstrip("#").strip()
                continue
            if stripped.endswith(":"):
                current_heading = stripped.rstrip(":").strip()
                continue
            lower = line.lower()
            if negative_context(line, current_heading):
                continue
            if any(word in lower for word in ["forbidden", "anti-", "historical", "compatibility", "obvious", "example"]):
                continue
            for phrase in PHRASES:
                if phrase in lower:
                    hits.setdefault(str(path.relative_to(path.parents[3])), []).append(line.strip())
    status = "green" if not hits else "red"
    write_json(REPORT, {"hits": hits, "status": status})
    print("PASS" if status == "green" else "FAIL")
    return 0 if status == "green" else 1


if __name__ == "__main__":
    raise SystemExit(main())
