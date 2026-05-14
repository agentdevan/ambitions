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
]
EXEMPT_FILES = {
    "VISUAL_ANTI_SLOP_RULES.md",
    "VISUAL_ENCYCLOPEDIA_RUTHLESS_AUDIT.md",
    "TYPOGRAPHY.md",
}


def main() -> int:
    hits = {}
    for path in scan_frontend_text_files():
        if path.name in EXEMPT_FILES:
            continue
        text = path.read_text(encoding="utf-8")
        for line in text.splitlines():
            lower = line.lower()
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
