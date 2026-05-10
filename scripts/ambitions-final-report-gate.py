#!/usr/bin/env python3
"""Validate Ambitions batch final reports before accepting Green/Yellow.

Read-only. This script is intentionally conservative: it checks that a report has
standard Ambitions closeout sections, records validation/non-claims, and does
not smuggle release/readiness claims without framing them as non-claims or
forbidden claims.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

REQUIRED_SECTION_PATTERNS = {
    "status": r"^#{1,3}\s*Status\b|^Status\s*:",
    "scope": r"^#{1,3}\s*Scope\b|^Scope\s*:",
    "files_changed": r"^#{1,3}\s*Files Changed\b|^Files changed\s*:",
    "evidence": r"^#{1,3}\s*Evidence\b|^Evidence\s*:",
    "validation": r"^#{1,3}\s*Validation\b|^Validation\s*:",
    "risks_or_gaps": r"^#{1,3}\s*(Risks|Remaining Gaps|Risks / Remaining Gaps)\b",
    "claims_not_made": r"^#{1,3}\s*Claims Not Made\b|^Claims not made\s*:",
    "next_step": r"^#{1,3}\s*Next (Recommended )?Step\b|^Next recommended step\s*:",
}

FORBIDDEN_CLAIM_PHRASES = [
    "production-ready",
    "release-ready",
    "App Store-ready",
    "TestFlight-ready",
    "device-verified",
    "physical-device validated",
    "fully tested",
    "fully accessible",
    "VoiceOver verified",
    "Dynamic Type verified",
    "Reduce Motion verified",
    "performance validated",
    "privacy approved",
    "legally approved",
    "sync-ready",
    "cloud-ready",
    "global train complete",
]

SAFE_NEGATION_MARKERS = [
    "not claim",
    "not made",
    "not proven",
    "no ",
    "without proof",
    "forbidden",
    "unproven",
    "does not claim",
    "claim is not",
    "remain non-claims",
]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def has_pattern(text: str, pattern: str) -> bool:
    return re.search(pattern, text, flags=re.IGNORECASE | re.MULTILINE) is not None


def claim_defects(text: str) -> list[str]:
    defects: list[str] = []
    lines = text.splitlines()
    for number, line in enumerate(lines, start=1):
        lowered = line.lower()
        for phrase in FORBIDDEN_CLAIM_PHRASES:
            if phrase.lower() not in lowered:
                continue
            if any(marker in lowered for marker in SAFE_NEGATION_MARKERS):
                continue
            defects.append(f"line {number}: forbidden-readiness phrase without clear non-claim framing: {phrase}")
    return defects


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Ambitions final report shape")
    parser.add_argument("report", help="Path to the Markdown final report to validate")
    parser.add_argument("--strict", action="store_true", help="Exit non-zero when defects are found")
    parser.add_argument("--json", action="store_true", help="Emit JSON output")
    args = parser.parse_args()

    report_path = Path(args.report)
    defects: list[str] = []
    warnings: list[str] = []

    if not report_path.exists():
        defects.append(f"missing report: {report_path}")
        text = ""
    else:
        text = read_text(report_path)

    if text:
        for section_name, pattern in REQUIRED_SECTION_PATTERNS.items():
            if not has_pattern(text, pattern):
                defects.append(f"missing required closeout section: {section_name}")

        if not re.search(r"\b(Green|Accepted Yellow|accepted Yellow|Yellow|Red)\b", text):
            defects.append("missing explicit Green / Accepted Yellow / Yellow / Red status language")

        if "exit code" not in text.lower() and "not run" not in text.lower():
            warnings.append("validation section does not appear to include exit codes or explicit not-run rationale")

        defects.extend(claim_defects(text))

    status = "RED" if defects else "YELLOW" if warnings else "GREEN"
    payload = {
        "status": status,
        "report": str(report_path),
        "defects": defects,
        "warnings": warnings,
        "required_sections": sorted(REQUIRED_SECTION_PATTERNS),
    }

    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(f"STATUS: {status}")
        print("Defects:")
        for item in defects or ["none"]:
            print(f"- {item}")
        print("Warnings:")
        for item in warnings or ["none"]:
            print(f"- {item}")

    return 1 if args.strict and defects else 0


if __name__ == "__main__":
    raise SystemExit(main())
