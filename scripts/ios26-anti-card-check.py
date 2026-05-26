#!/usr/bin/env python3
"""IOS26 object-frontend anti-card validator.

This is a structural source scan. It is not visual, accessibility,
performance, privacy, release, or device proof.
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_REPORT_DIR = ROOT / "build/reports/frontend-object-purity"

SCAN_ROOTS = [
    "Native/Ambitions/App",
    "Native/Ambitions/Features",
    "Native/AmbitionsTests",
    "Native/AmbitionsUITests",
    "Sources",
    "AppUI/Sources",
    "Package.swift",
    "project.yml",
]

EXCLUDED_PARTS = {
    "docs",
    "build",
    ".codex",
    "DerivedData",
    "output",
    ".git",
    "__pycache__",
}

TEXT_SUFFIXES = {".swift", ".yml", ".yaml"}
TEXT_FILES = {"Package.swift", "project.yml"}

SURFACE_EVIDENCE = {
    "shell": [
        "LivingChrome",
        "AppShellScaffold",
        "Command",
        "ContinuityDock",
        "ContextCrown",
        "TrustSeam",
    ],
    "today": ["RealityMeridian", "StartHere", "Start here"],
    "time": ["LifeShape", "LifeShapeField", "TimeLifeShape"],
    "goals": ["ConstellationAtlas", "GoalThread", "OrbitalLens"],
    "capture": ["AtmosphereComposer", "CaptureRouteLens", "CaptureAtmosphereComposer"],
    "you": ["UserSystemProfile", "YouRootSurface", "TrustAutomation"],
    "proof": ["Receipt", "Proof", "Closure", "Recovery", "ReplayTrace"],
}

GLOBAL_SURFACES = ["shell", "today", "time", "goals", "capture", "you", "proof"]

RED_PATTERNS = [
    ("card_type", re.compile(r"\b(struct|class|enum)\s+\w*Card\w*\b")),
    ("card_accessibility_identifier", re.compile(r'accessibilityIdentifier\s*\([^)]*"[^"]*\.card[^"]*"')),
    ("dashboard_copy", re.compile(r'\b(Text|Label)\s*\(\s*"[^"]*Dashboard[^"]*"')),
    ("assistant_copy", re.compile(r'\b(Text|Label)\s*\(\s*"[^"]*(AI assistant|Assistant)[^"]*"')),
    ("feed_root", re.compile(r"\b\w*Feed\w*(Screen|View|Root|Surface)\b")),
    ("chat_root", re.compile(r"\b\w*Chat\w*(Screen|View|Root|Surface)\b")),
    ("calendar_clone_root", re.compile(r"\b(CalendarGrid|AgendaRoot|CalendarClone|AgendaView)\b")),
    ("kanban_board_root", re.compile(r"\b(Kanban|BoardRoot|BoardView)\b")),
    ("kpi_score_ring", re.compile(r"\b(KPI|Score|Streak|Ring)\b")),
    ("hero_active_term", re.compile(r"\b(HeroStepPanel|Hero Step Panel|TodayHero|Today Hero)\b")),
]

YELLOW_PATTERNS = [
    ("compat_marker", re.compile(r"AMB_FRONTEND_COMPAT_YELLOW")),
]


@dataclass(frozen=True)
class Finding:
    kind: str
    path: str
    line: int
    text: str


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def iter_scan_files() -> tuple[list[Path], int]:
    files: list[Path] = []
    ignored = 0
    for root_name in SCAN_ROOTS:
        root = ROOT / root_name
        if not root.exists():
            continue
        if root.is_file():
            files.append(root)
            continue
        for path in root.rglob("*"):
            parts = set(path.relative_to(ROOT).parts)
            if parts & EXCLUDED_PARTS:
                ignored += 1
                continue
            if path.is_file() and (path.suffix in TEXT_SUFFIXES or path.name in TEXT_FILES):
                files.append(path)
    return sorted(set(files)), ignored


def evidence_terms(surface: str) -> list[str]:
    if surface == "global":
        terms: list[str] = []
        for key in GLOBAL_SURFACES:
            terms.extend(SURFACE_EVIDENCE[key])
        return terms
    return SURFACE_EVIDENCE[surface]


def scan(surface: str) -> dict[str, object]:
    files, ignored = iter_scan_files()
    red: list[Finding] = []
    yellow: list[Finding] = []
    evidence: dict[str, list[str]] = {term: [] for term in evidence_terms(surface)}
    preview_evidence: list[str] = []
    test_evidence: list[str] = []
    accessibility_evidence: list[str] = []

    for path in files:
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        relative = rel(path)
        is_test = "Tests" in path.parts[-2:] or "Tests" in relative
        for index, line in enumerate(text.splitlines(), start=1):
            stripped = line.strip()
            for kind, pattern in RED_PATTERNS:
                if pattern.search(line):
                    red.append(Finding(kind, relative, index, stripped[:240]))
            for kind, pattern in YELLOW_PATTERNS:
                if pattern.search(line):
                    yellow.append(Finding(kind, relative, index, stripped[:240]))
            for term in evidence:
                if term in line:
                    evidence[term].append(f"{relative}:{index}")
            if "Preview" in line or "#Preview" in line:
                preview_evidence.append(f"{relative}:{index}")
            if is_test and ("func test" in line or "XCTest" in line):
                test_evidence.append(f"{relative}:{index}")
            if "accessibility" in line:
                accessibility_evidence.append(f"{relative}:{index}")

    missing_evidence = [term for term, locations in evidence.items() if not locations]
    status = "Green"
    if red or missing_evidence:
        status = "Red"
    elif yellow:
        status = "Yellow"

    return {
        "generated_at": utc_now(),
        "status": status,
        "surface": surface,
        "files_scanned": len(files),
        "historical_ignored": ignored,
        "red_findings": [finding.__dict__ for finding in red],
        "yellow_findings": [finding.__dict__ for finding in yellow],
        "object_root_evidence": {term: locations[:20] for term, locations in evidence.items() if locations},
        "missing_object_root_evidence": missing_evidence,
        "preview_evidence": preview_evidence[:50],
        "test_evidence": test_evidence[:50],
        "accessibility_evidence": accessibility_evidence[:50],
        "next_gate": next_gate(status, surface),
        "claim_boundary": "This validator is structural source evidence only and does not prove visual quality, accessibility, performance, privacy, release readiness, TestFlight readiness, App Store readiness, or device behavior.",
    }


def next_gate(status: str, surface: str) -> str:
    if status == "Green":
        return f"Run focused implementation validation for {surface} and capture current proof before making product claims."
    if status == "Yellow":
        return "Record owner, reason, no-claim boundary, and follow-up gate for compatibility markers before proceeding."
    return "Repair Red findings or keep the batch Red/Yellow without claiming object-purity completion."


def render_markdown(result: dict[str, object], batch: str) -> str:
    red = result["red_findings"]
    yellow = result["yellow_findings"]
    evidence = result["object_root_evidence"]
    missing = result["missing_object_root_evidence"]
    lines = [
        f"# IOS26 Anti-Card Check - {batch}",
        "",
        f"Generated: {result['generated_at']}",
        f"Status: {result['status']}",
        f"Surface: {result['surface']}",
        f"Batch: {batch}",
        f"Files scanned: {result['files_scanned']}",
        f"Red findings: {len(red)}",
        f"Yellow findings: {len(yellow)}",
        f"Historical ignored: {result['historical_ignored']}",
        "",
        "## Object Root Evidence",
    ]
    if evidence:
        for term, locations in evidence.items():
            lines.append(f"- {term}: {', '.join(locations[:8])}")
    else:
        lines.append("- none")
    lines.extend(["", "## Missing Object Root Evidence"])
    lines.extend([f"- {term}" for term in missing] or ["- none"])
    lines.extend(["", "## Red Findings"])
    for finding in red[:100]:
        lines.append(f"- {finding['kind']}: {finding['path']}:{finding['line']} - `{finding['text']}`")
    if not red:
        lines.append("- none")
    lines.extend(["", "## Yellow Findings"])
    for finding in yellow[:100]:
        lines.append(f"- {finding['kind']}: {finding['path']}:{finding['line']} - `{finding['text']}`")
    if not yellow:
        lines.append("- none")
    lines.extend(
        [
            "",
            "## Preview Evidence",
            "\n".join(f"- {item}" for item in result["preview_evidence"][:20]) or "- none",
            "",
            "## Test Evidence",
            "\n".join(f"- {item}" for item in result["test_evidence"][:20]) or "- none",
            "",
            "## Accessibility Evidence",
            "\n".join(f"- {item}" for item in result["accessibility_evidence"][:20]) or "- none",
            "",
            "## Next Gate",
            str(result["next_gate"]),
            "",
            "## Claim Boundary",
            str(result["claim_boundary"]),
            "",
        ]
    )
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate IOS26 object frontend anti-card posture.")
    parser.add_argument("--surface", required=True, choices=[*GLOBAL_SURFACES, "global"])
    parser.add_argument("--batch", required=True)
    parser.add_argument("--report-dir", default=str(DEFAULT_REPORT_DIR))
    parser.add_argument("--json", action="store_true", help="Print JSON result to stdout.")
    parser.add_argument("--markdown", action="store_true", help="Print Markdown result to stdout.")
    parser.add_argument("--strict", action="store_true", help="Exit non-zero on Yellow as well as Red.")
    args = parser.parse_args()

    report_dir = Path(args.report_dir)
    if not report_dir.is_absolute():
        report_dir = ROOT / report_dir
    report_dir.mkdir(parents=True, exist_ok=True)

    result = scan(args.surface)
    md = render_markdown(result, args.batch)
    json_path = report_dir / f"{args.batch}-anti-card.json"
    md_path = report_dir / f"{args.batch}-anti-card.md"
    json_path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    md_path.write_text(md, encoding="utf-8")

    if args.json:
        print(json.dumps(result, indent=2))
    if args.markdown:
        print(md)
    if not args.json and not args.markdown:
        print(f"Status: {result['status']}")
        print(f"Surface: {result['surface']}")
        print(f"Batch: {args.batch}")
        print(f"Files scanned: {result['files_scanned']}")
        print(f"Red findings: {len(result['red_findings'])}")
        print(f"Yellow findings: {len(result['yellow_findings'])}")
        print(f"Historical ignored: {result['historical_ignored']}")
        print(f"Object root evidence: {len(result['object_root_evidence'])}")
        print(f"Preview evidence: {len(result['preview_evidence'])}")
        print(f"Test evidence: {len(result['test_evidence'])}")
        print(f"Accessibility evidence: {len(result['accessibility_evidence'])}")
        print(f"Next gate: {result['next_gate']}")
        print(f"Markdown report: {rel(md_path)}")
        print(f"JSON report: {rel(json_path)}")

    if result["status"] == "Red":
        return 1
    if args.strict and result["status"] == "Yellow":
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
