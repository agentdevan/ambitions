#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import json
import re
import sys
from collections import Counter, defaultdict


ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs/canon/frontend"
REPORT = ROOT / "build/reports/visual-template-residue.json"

SCANNED_FILES = [
    "VISUAL_ENCYCLOPEDIA_RUTHLESS_AUDIT.md",
    "VISUAL_ENCYCLOPEDIA_PERFECTION_PLAN.md",
    "VISUAL_VOCABULARY_BOUNDARY.md",
    "VISUAL_RECIPE_SHORT_FORM_TEMPLATE.md",
    "VISUAL_OBJECT_FIRST_REVIEW_RUBRIC.md",
    "VISUAL_ACCESSIBILITY_ADHD_REQUIREMENTS.md",
    "VISUAL_ANTI_SLOP_RULES.md",
    "objects/PRIMARY_OBJECT_ANATOMY_CANON.md",
    "objects/LABEL_OFF_SIGNATURE_TESTS.md",
    "objects/REALITY_MERIDIAN_ANATOMY.md",
    "objects/CONSTELLATION_ATLAS_ANATOMY.md",
    "objects/ATMOSPHERE_COMPOSER_ANATOMY.md",
    "objects/LIFESHAPE_FIELD_ANATOMY.md",
    "objects/USER_SYSTEM_PROFILE_ANATOMY.md",
    "primitives/TRUST_SEAM.md",
    "primitives/PROOF_PRIMITIVES.md",
    "primitives/LOCAL_RUNTIME_PRIMITIVES.md",
    "primitives/PRESSURE_AND_CAPACITY_PRIMITIVES.md",
    "primitives/MATERIAL_PRIMITIVE_ROLES.md",
    "behavior/AMBITIONS_TRANSACTION_MODEL.md",
    "behavior/RECOVERY_MODE.md",
    "behavior/NO_FALSE_MOMENTUM.md",
    "behavior/CROSS_SURFACE_STATE_GRAMMAR.md",
    "behavior/ACCESSIBILITY_AND_ADHD_LAWS.md",
    "behavior/ANTI_GENERIC_KILL_SWITCHES.md",
    "gates/NORTH_STAR_100_ACCEPTANCE_GATE.md",
    "trace/VISUAL_CONFLICT_LEDGER.md",
    "trace/VISUAL_SOURCE_LINKAGE_LEDGER.md",
    "trace/VISUAL_SURFACE_GRAPH_LEDGER.md",
]

SKIP_HEADING_PREFIXES = (
    "forbidden",
    "anti-generic",
    "must never be",
    "what it is not",
    "what it is not",
    "boundary",
    "kill switch",
    "proof boundary",
    "notes",
)

FORBIDDEN_PHRASES = [
    "show semantic hierarchy",
    "use premium materials",
    "make it calm",
    "avoid generic ui",
    "surface trusted context",
    "proof-aware state",
    "make it native",
    "shared object system",
    "related commitments, proof, source, state markers",
]

EXEMPT_FORBIDDEN_PHRASE_FILES = {
    "VISUAL_ENCYCLOPEDIA_RUTHLESS_AUDIT.md",
    "VISUAL_ANTI_SLOP_RULES.md",
    "VISUAL_VOCABULARY_BOUNDARY.md",
    "VISUAL_OBJECT_FIRST_REVIEW_RUBRIC.md",
    "gates/NORTH_STAR_100_ACCEPTANCE_GATE.md",
}

EXEMPT_GENERIC_FILES = {
    "primitives/MATERIAL_PRIMITIVE_ROLES.md",
}


def is_meta_paragraph(paragraph: str) -> bool:
    stripped = paragraph.strip()
    if not stripped:
        return True
    if stripped.startswith("#"):
        return True
    if stripped.lower().startswith("status:"):
        return True
    if stripped.lower().startswith("destination:"):
        return True
    if len(stripped) < 40 and ":" in stripped:
        return True
    return False


def split_paragraphs(text: str):
    parts = re.split(r"\n\s*\n", text.strip())
    return [part.strip() for part in parts if part.strip()]


def normalize(paragraph: str) -> str:
    return re.sub(r"\s+", " ", paragraph).strip().lower()


def tokenize(paragraph: str):
    return re.findall(r"[a-z0-9]+", paragraph.lower())


def main() -> int:
    files = [BASE / rel for rel in SCANNED_FILES]

    paragraphs_by_file = {}
    all_paragraphs = []
    exact_paragraph_counts = Counter()
    opener_counts = Counter()
    phrase_hits = defaultdict(list)
    generic_hits = defaultdict(list)

    for path in files:
        paragraphs = []
        current_heading = ""
        for raw in split_paragraphs(path.read_text()):
            if raw.startswith("#"):
                current_heading = raw.lstrip("#").strip().lower()
            paragraphs.append(raw)
            if not is_meta_paragraph(raw):
                all_paragraphs.append((path, raw, current_heading))
                exact_paragraph_counts[normalize(raw)] += 1
                opener = tokenize(raw)[:4]
                if opener:
                    opener_counts[" ".join(opener)] += 1

                lowered = raw.lower()
                for phrase in FORBIDDEN_PHRASES:
                    if phrase in lowered and path.name not in EXEMPT_FORBIDDEN_PHRASE_FILES:
                        phrase_hits[phrase].append(str(path.relative_to(ROOT)))
                if (
                    "semantic" in lowered
                    and path.name not in EXEMPT_GENERIC_FILES
                    and ("object" not in lowered and "source" not in lowered and "receipt" not in lowered and "role" not in lowered)
                ):
                    generic_hits["semantic_without_concrete_anchor"].append(str(path.relative_to(ROOT)))
                if "premium" in lowered and ("anatomy" not in lowered and "source" not in lowered and "proof" not in lowered):
                    generic_hits["premium_without_anatomy"].append(str(path.relative_to(ROOT)))

        paragraphs_by_file[str(path.relative_to(ROOT))] = paragraphs

    repeated_exact = {p: c for p, c in exact_paragraph_counts.items() if c > 1}
    repeated_openers = {o: c for o, c in opener_counts.items() if c > 2}

    near_duplicates = []
    paragraph_tokens = [set(tokenize(p)) for _, p, _ in all_paragraphs]
    for i in range(len(all_paragraphs)):
        for j in range(i + 1, len(all_paragraphs)):
            a = paragraph_tokens[i]
            b = paragraph_tokens[j]
            if not a or not b:
                continue
            jaccard = len(a & b) / len(a | b)
            if jaccard >= 0.82:
                near_duplicates.append(
                    {
                        "a": str(all_paragraphs[i][0].relative_to(ROOT)),
                        "b": str(all_paragraphs[j][0].relative_to(ROOT)),
                        "score": round(jaccard, 3),
                    }
                )

    report = {
        "file_count": len(files),
        "exact_duplicate_paragraphs": repeated_exact,
        "near_duplicate_pairs": near_duplicates,
        "repeated_sentence_openers": repeated_openers,
        "forbidden_phrase_hits": {k: v for k, v in phrase_hits.items()},
        "generic_phrase_hits": {k: v for k, v in generic_hits.items()},
        "status": "green",
    }

    if repeated_exact or phrase_hits or generic_hits:
        report["status"] = "red"

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")

    if report["status"] == "red":
        print("FAIL: template residue found")
        return 1

    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
