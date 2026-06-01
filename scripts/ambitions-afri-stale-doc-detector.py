#!/usr/bin/env python3
"""Focused stale-doc detector for AFRI authority routing."""

from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]

ACTIVE_DOCS = [
    ROOT / "README.md",
    ROOT / "docs" / "README.md",
    ROOT / "AGENTS.md",
    ROOT / ".codex" / "os" / "ACTIVE_AUTHORITY_MAP.md",
    ROOT / "docs" / "governance" / "AUTHORITY_HIERARCHY.md",
    ROOT / "docs" / "codex" / "AFRI_ACTIVE_AUTHORITY_MANIFEST.md",
    ROOT / "docs" / "codex" / "AFRI_ACTIVE_AUTHORITY_MANIFEST.json",
]

STALE_PATTERNS = [
    (
        "legacy_canon_as_tier_one",
        re.compile(r"Tier 1.*Canon Truth|Primary location:\s*\n\s*-\s*docs/canon/", re.IGNORECASE | re.MULTILINE),
    ),
    (
        "plan_top_level_ia",
        re.compile(r"Today\s*/\s*Goals\s*/\s*Capture\s*/\s*Plan\s*/\s*You", re.IGNORECASE),
    ),
    (
        "truth_files_subordinate",
        re.compile(r"docs/truth/\*\s+(?:is|are)\s+subordinate", re.IGNORECASE),
    ),
    (
        "release_ready_claim",
        re.compile(r"\b(?:release-ready|TestFlight-ready|App Store-ready|production-ready)\b", re.IGNORECASE),
    ),
    (
        "cloud_ai_core_claim",
        re.compile(r"\b(?:required cloud AI|hosted inference|external LLM dependency)\b", re.IGNORECASE),
    ),
]

ALLOWED_NEGATIVE_CONTEXT = (
    "not ",
    "no ",
    "never ",
    "does not ",
    "do not ",
    "without ",
    "forbidden",
    "hard red",
    "hard stop",
    "stop conditions",
    "introducing ",
    "claim_boundaries",
)


def line_allowed(line: str) -> bool:
    lowered = line.lower()
    return any(marker in lowered for marker in ALLOWED_NEGATIVE_CONTEXT)


def main() -> int:
    findings: list[str] = []

    for path in ACTIVE_DOCS:
        if not path.exists():
            findings.append(f"RED missing active doc: {path.relative_to(ROOT)}")
            continue
        text = path.read_text(encoding="utf-8")
        for name, pattern in STALE_PATTERNS:
            for match in pattern.finditer(text):
                line_start = text.rfind("\n", 0, match.start()) + 1
                line_end = text.find("\n", match.end())
                if line_end == -1:
                    line_end = len(text)
                line = text[line_start:line_end]
                if name in {"release_ready_claim", "cloud_ai_core_claim"} and line_allowed(line):
                    continue
                line_no = text.count("\n", 0, match.start()) + 1
                findings.append(f"RED {path.relative_to(ROOT)}:{line_no}: stale active guidance {name}: {line.strip()}")

    if findings:
        print("# AFRI Stale Doc Detector")
        for finding in findings:
            print(finding)
        return 1

    print("# AFRI Stale Doc Detector")
    print("GREEN: active authority docs contain no focused stale-routing patterns")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
