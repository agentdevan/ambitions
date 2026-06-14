#!/usr/bin/env python3
"""Fail if protected visible Step surfaces contain blocked generic or shame Step copy."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REPORT_DIR = ROOT / "build/reports/step-quality"
JSON_REPORT = REPORT_DIR / "AMB-1111-surface-guard.json"
MD_REPORT = REPORT_DIR / "AMB-1111-surface-guard.md"

PROTECTED_PATHS = [
    "Native/Ambitions/Features/Today",
    "Native/Ambitions/Features/Goals",
    "Native/Ambitions/ExternalSnapshots",
    "Native/AmbitionsWidgetExtension",
    "Native/Ambitions/AppIntents",
    "Native/Ambitions/App/AppIntentLaunchRouter.swift",
    "AppUI/Sources",
]

OPTIONAL_PROTECTED_PATHS = [
    "Native/Ambitions/Features/Year",
    "Native/Ambitions/Features/Sharing",
]

BLOCKED_PHRASES = [
    "work on your goal",
    "make progress",
    "research this",
    "review your plan",
    "continue",
    "do the next thing",
    "try to improve",
    "keep going",
    "make a plan",
    "work on it",
    "you should have",
    "no excuses",
    "you let everyone down",
    "not good enough",
    "disappointed in yourself",
    "stop falling behind",
]


def normalize(value: str) -> str:
    return re.sub(r"\s+", " ", re.sub(r"[^a-z0-9\s]", " ", value.lower())).strip()


def swift_strings(text: str) -> list[tuple[int, str]]:
    strings: list[tuple[int, str]] = []
    for line_number, line in enumerate(text.splitlines(), start=1):
        if line.lstrip().startswith("//"):
            continue
        for match in re.finditer(r'"([^"\\]*(?:\\.[^"\\]*)*)"', line):
            strings.append((line_number, match.group(1)))
    return strings


def phrase_is_blocked(phrase: str, value: str) -> bool:
    normalized_phrase = normalize(phrase)
    normalized_value = normalize(value)
    if " " not in normalized_phrase:
        return normalized_value == normalized_phrase
    return re.search(r"\b" + re.escape(normalized_phrase) + r"\b", normalized_value) is not None


def scan_file(path: Path) -> list[dict[str, str | int]]:
    findings: list[dict[str, str | int]] = []
    text = path.read_text(encoding="utf-8", errors="ignore")
    for line_number, literal in swift_strings(text):
        for phrase in BLOCKED_PHRASES:
            if phrase_is_blocked(phrase, literal):
                findings.append({
                    "path": str(path.relative_to(ROOT)),
                    "line": line_number,
                    "phrase": phrase,
                    "literal": literal,
                })
    return findings


def iter_swift_files() -> list[Path]:
    files: list[Path] = []
    for rel in PROTECTED_PATHS + OPTIONAL_PROTECTED_PATHS:
        path = ROOT / rel
        if path.is_file() and path.suffix == ".swift":
            files.append(path)
        elif path.is_dir():
            files.extend(sorted(path.rglob("*.swift")))
    return sorted(set(files))


def main() -> int:
    files = iter_swift_files()
    findings: list[dict[str, str | int]] = []
    for path in files:
        findings.extend(scan_file(path))

    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    payload = {
        "issue": "AMB-1111",
        "protected_surface_count": len(files),
        "blocked_phrase_count": len(BLOCKED_PHRASES),
        "findings": findings,
        "status": "FAIL" if findings else "PASS",
    }
    JSON_REPORT.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    lines = [
        "# AMB-1111 Step Quality Surface Guard",
        "",
        f"Status: {payload['status']}",
        f"Protected Swift files scanned: {len(files)}",
        f"Blocked phrases checked: {len(BLOCKED_PHRASES)}",
        "",
        "## Findings",
    ]
    if findings:
        lines.extend(f"- {item['path']}:{item['line']} `{item['phrase']}` in `{item['literal']}`" for item in findings)
    else:
        lines.append("- none")
    MD_REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")

    if findings:
        print(f"FAIL AMB-1111 surface guard found {len(findings)} protected Step copy issue(s)")
        print(f"Report: {MD_REPORT}")
        return 1
    print(f"PASS AMB-1111 surface guard scanned {len(files)} protected Swift files")
    print(f"Report: {MD_REPORT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
