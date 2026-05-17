#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import json
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "frontend" / "visual-encyclopedia"
REPORT = ROOT / "build/reports/visual-vocabulary-boundary.json"

BOUNDARY_TERMS = {
    "Today": "user-facing allowed",
    "Goals": "user-facing allowed",
    "Capture": "user-facing allowed",
    "Time": "user-facing allowed",
    "You": "user-facing allowed",
    "Plan": "historical/supporting",
    "Start here": "user-facing allowed",
    "Recommended step": "user-facing allowed",
    "Start now": "user-facing allowed",
    "Open step": "user-facing allowed",
    "Hero Step Panel": "historical/supporting",
    "DayTimelineRail": "historical/supporting",
    "Reality Meridian": "user-facing allowed",
    "Constellation Atlas": "user-facing allowed",
    "Atmosphere Composer": "user-facing allowed",
    "LifeShape Field": "user-facing allowed",
    "User System Profile": "user-facing allowed",
    "QuietGlass": "internal canon only",
    "GraphiteRecess": "internal canon only",
    "LuminousTrace": "internal canon only",
    "CelestialField": "internal canon only",
    "confidence": "forbidden",
    "AI": "forbidden",
    "assistant": "forbidden",
    "chatbot": "forbidden",
    "streak": "forbidden",
    "score": "forbidden",
    "ring": "forbidden",
    "dashboard": "forbidden",
    "card stack": "forbidden",
    "proof": "user-facing allowed",
    "receipt": "user-facing allowed",
    "source": "user-facing allowed",
    "local runtime": "user-facing allowed",
    "Personal Runtime": "internal canon only",
    "Still Counts": "user-facing allowed",
    "closure": "user-facing allowed",
    "protected time": "user-facing allowed",
    "reflow": "user-facing allowed",
}

SCAN_FILES = [
    BASE / "README.md",
    BASE / "FRONTEND_AUTHORITY_INDEX.md",
    BASE / "AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md",
    BASE / "VISUAL_ENCYCLOPEDIA_RUTHLESS_AUDIT.md",
    BASE / "VISUAL_ENCYCLOPEDIA_PERFECTION_PLAN.md",
    BASE / "VISUAL_OBJECT_FIRST_REVIEW_RUBRIC.md",
    BASE / "VISUAL_ACCESSIBILITY_ADHD_REQUIREMENTS.md",
    BASE / "VISUAL_ANTI_SLOP_RULES.md",
    BASE / "VISUAL_RECIPE_SHORT_FORM_TEMPLATE.md",
    BASE / "trace/VISUAL_CONFLICT_LEDGER.md",
    BASE / "trace/VISUAL_SOURCE_LINKAGE_LEDGER.md",
    BASE / "trace/VISUAL_SURFACE_GRAPH_LEDGER.md",
    BASE / "gates/NORTH_STAR_100_ACCEPTANCE_GATE.md",
]


def main() -> int:
    boundary_doc = (BASE / "VISUAL_VOCABULARY_BOUNDARY.md").read_text()
    missing_terms = []
    for term, category in BOUNDARY_TERMS.items():
        if term not in boundary_doc:
            missing_terms.append(term)
        elif category not in boundary_doc:
            missing_terms.append(f"{term}::{category}")

    violations = []
    forbidden_terms = [
        "AI assistant",
        "AI",
        "assistant",
        "chatbot",
        "streak",
        "score",
        "ring",
        "dashboard",
        "card stack",
        "best next move",
        "next best move",
        "Begin Focus",
        "Start Focus",
    ]
    plan_leak_pattern = re.compile(r"\bPlan\b")

    def term_pattern(term: str) -> re.Pattern[str]:
        if " " in term:
            return re.compile(re.escape(term), re.IGNORECASE)
        return re.compile(rf"\b{re.escape(term)}\b", re.IGNORECASE)

    for path in SCAN_FILES:
        text = path.read_text()
        lowered = text.lower()
        for line in text.splitlines():
            line_lower = line.lower()
            if any(word in line_lower for word in ["forbidden", "excluded", "historical", "compatibility", "obsolete", "boundary", "kill switch", "anti-", "what it is not", "not a", "not an", "supersedes", "no chatbot", "no generic", "no ", "implementation-dashboard", "dashboard.json"]):
                continue
            for term in forbidden_terms:
                if term_pattern(term).search(line) and path.name not in {
                    "VISUAL_ANTI_SLOP_RULES.md",
                    "VISUAL_VOCABULARY_BOUNDARY.md",
                    "NORTH_STAR_100_ACCEPTANCE_GATE.md",
                    "VISUAL_OBJECT_FIRST_REVIEW_RUBRIC.md",
                    "VISUAL_ENCYCLOPEDIA_RUTHLESS_AUDIT.md",
                    "VISUAL_ENCYCLOPEDIA_PERFECTION_PLAN.md",
                }:
                    violations.append({"file": str(path.relative_to(ROOT)), "term": term, "line": line.strip()})
            if "plan" in line_lower and "compatibility" not in line_lower and "historical" not in line_lower and "internal" not in line_lower:
                if plan_leak_pattern.search(line) and "Plan" in line and path.name in {"README.md", "FRONTEND_AUTHORITY_INDEX.md", "AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md"}:
                    violations.append({"file": str(path.relative_to(ROOT)), "term": "Plan", "line": line.strip()})

    report = {
        "files_scanned": [str(path.relative_to(ROOT)) for path in SCAN_FILES],
        "missing_boundary_terms": missing_terms,
        "violations": violations,
        "status": "green" if not missing_terms and not violations else "red",
    }

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")

    if report["status"] == "red":
        print("FAIL: vocabulary boundary violations found")
        return 1

    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
