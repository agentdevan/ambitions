#!/usr/bin/env python3
"""Conservative Private Life Runtime wiring presence check."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build/reports/intelligence-consolidation"
ROOTS = ["Native/Ambitions/Runtime", "Native/Ambitions/Domain", "Native/Ambitions/Services", "Native/Ambitions/Features/Today", "Native/Ambitions/Features/You", "Sources"]
TERMS = ["SourceRecord", "Receipt", "ReplayTrace", "Closure", "Proof", "RecommendationTrace", "RuntimeLearningSignal", "What Ambitions knows", "Personal Runtime"]


def files() -> list[Path]:
    out: list[Path] = []
    for root in ROOTS:
        base = ROOT / root
        if base.exists():
            out.extend(sorted(base.rglob("*.swift")))
    return out


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    text_by_file = {str(path.relative_to(ROOT)): path.read_text(encoding="utf-8", errors="replace") for path in files()}
    term_hits = {term: [path for path, text in text_by_file.items() if term.lower() in text.lower()] for term in TERMS}
    missing = [term for term, hits in term_hits.items() if not hits]
    status = "RED" if {"Receipt", "Proof"}.issubset(set(missing)) else ("YELLOW" if missing else "GREEN")
    payload = {"status": status, "terms": term_hits, "missing_terms": missing, "note": "Presence check only; does not prove end-to-end runtime wiring."}
    (OUT / "private-runtime-wiring-check.json").write_text(json.dumps(payload, indent=2), encoding="utf-8")
    lines = ["# Private Life Runtime Wiring Check", "", f"Status: {status}", "", "Presence check only; this is not proof of end-to-end runtime behavior.", "", "| Term | Files |", "| --- | --- |"]
    for term, hits in term_hits.items():
        lines.append(f"| {term} | {'<br>'.join(f'`{h}`' for h in hits[:20]) or 'MISSING'} |")
    (OUT / "private-runtime-wiring-check.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"STATUS: {status}")
    print(f"Report: {OUT / 'private-runtime-wiring-check.md'}")
    return 0 if status != "RED" else 1


if __name__ == "__main__":
    raise SystemExit(main())
