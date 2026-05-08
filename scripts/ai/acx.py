#!/usr/bin/env python3
"""ACX: Ambitions Command eXtractor.

Non-executing helper for bounded reads, saved-log summaries, changed-file
grouping, advisory scans, and compact gate reports.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
KEY_PATTERNS = [
    "error:",
    "warning:",
    "BUILD FAILED",
    "TEST FAILED",
    "FAILED",
    "STOPPED ON RED",
    "Hard Red",
    "Red",
    "Yellow",
    "Green",
    "Traceback",
    "fatal:",
]
SWIFT_LINE_RE = re.compile(r"\.swift:\d+")
CONCERNS = [
    (".codex", lambda p: p.startswith(".codex/")),
    ("docs/canon", lambda p: p.startswith("docs/canon/")),
    ("docs/codex", lambda p: p.startswith("docs/codex/")),
    ("docs", lambda p: p.startswith("docs/")),
    ("scripts", lambda p: p.startswith("scripts/")),
    ("source", lambda p: p.startswith(("Native/", "Sources/", "AppUI/Sources/"))),
    ("tests", lambda p: "Tests/" in p or p.endswith("Tests.swift")),
    ("config", lambda p: p in {"AGENTS.md", "project.yml", ".gitignore"} or p.endswith((".yml", ".yaml", ".toml", ".json"))),
]
SCAN_TERMS = {
    "unsupported_release_claims": [
        "production-ready",
        "release-ready",
        "fully tested",
        "fully accessible",
        "App Store ready",
        "TestFlight ready",
        "device verified",
        "privacy compliant",
        "legally approved",
        "performance safe",
    ],
    "product_drift": [
        "top-level Tasks",
        "Plan tab",
        "Plan screen",
        "top-level Plan",
        "ACUI",
        "Habits tab",
        "AI confidence",
        "AI explanation",
        "chatbot",
        "productivity score",
    ],
}


def rel(path: Path) -> Path:
    resolved = (ROOT / path).resolve()
    if ROOT not in resolved.parents and resolved != ROOT:
        raise SystemExit(f"Refusing path outside repo: {path}")
    return resolved


def command_read(args: argparse.Namespace) -> int:
    target = rel(Path(args.path))
    if not target.exists() or not target.is_file():
        print(f"ACX Red: file not found: {args.path}", file=sys.stderr)
        return 1
    lines = target.read_text(encoding="utf-8", errors="replace").splitlines()
    limit = max(1, args.lines)
    for idx, line in enumerate(lines[:limit], start=1):
        print(f"{idx}: {line}")
    if len(lines) > limit:
        print(f"... truncated after {limit} of {len(lines)} lines")
    return 0


def key_lines(text: str) -> list[str]:
    out: list[str] = []
    for line in text.splitlines():
        if any(pattern in line for pattern in KEY_PATTERNS) or SWIFT_LINE_RE.search(line):
            out.append(line)
    return out


def command_summarize_log(args: argparse.Namespace) -> int:
    target = rel(Path(args.path))
    if not target.exists() or not target.is_file():
        print(f"ACX Red: log not found: {args.path}", file=sys.stderr)
        return 1
    text = target.read_text(encoding="utf-8", errors="replace")
    matches = key_lines(text)
    print(f"# ACX Log Summary\n\nRaw log: `{args.path}`\nLines: {len(text.splitlines())}\nKey lines: {len(matches)}")
    for line in matches[: args.max_lines]:
        print(f"- {line[:240]}")
    if len(matches) > args.max_lines:
        print(f"- ... truncated {len(matches) - args.max_lines} additional key lines")
    return 0


def extract_status_path(line: str) -> str | None:
    if not line or line.startswith("##"):
        return None
    body = line[3:] if len(line) > 3 else line
    if " -> " in body:
        body = body.split(" -> ", 1)[1]
    return body.strip()


def group_paths(paths: list[str]) -> dict[str, list[str]]:
    grouped: dict[str, list[str]] = {name: [] for name, _ in CONCERNS}
    grouped["other"] = []
    for path in paths:
        bucket = next((name for name, test in CONCERNS if test(path)), "other")
        grouped[bucket].append(path)
    return grouped


def command_group_status(args: argparse.Namespace) -> int:
    target = rel(Path(args.path))
    text = target.read_text(encoding="utf-8", errors="replace")
    paths = [p for p in (extract_status_path(line) for line in text.splitlines()) if p]
    print("# ACX Changed Files By Ambitions Concern")
    for bucket, items in group_paths(paths).items():
        if not items:
            continue
        print(f"\n## {bucket}")
        for item in items:
            print(f"- {item}")
    return 0


def command_scan(args: argparse.Namespace) -> int:
    findings: list[str] = []
    for raw in args.paths:
        path = rel(Path(raw))
        files = [path] if path.is_file() else [p for p in path.rglob("*") if p.is_file() and ".git" not in p.parts]
        for file_path in files:
            if file_path.suffix in {".png", ".jpg", ".jpeg", ".gif", ".xcresult"}:
                continue
            text = file_path.read_text(encoding="utf-8", errors="ignore")
            for family, terms in SCAN_TERMS.items():
                for term in terms:
                    if term.lower() in text.lower():
                        findings.append(f"{family}: {file_path.relative_to(ROOT)} contains `{term}`")
    if findings:
        print("ACX Yellow: advisory scan findings")
        for finding in findings[: args.max_findings]:
            print(f"- {finding}")
        if len(findings) > args.max_findings:
            print(f"- ... truncated {len(findings) - args.max_findings} findings")
        return 0
    print("ACX Green: advisory scan found no configured terms")
    return 0


def command_gate(args: argparse.Namespace) -> int:
    print("# ACX Gate Report")
    print(f"Mode: {args.gate}")
    missing = [raw for raw in args.paths if not rel(Path(raw)).exists()]
    if missing:
        print("Result: Yellow")
        for item in missing:
            print(f"- Missing optional path: {item}")
        return 0
    print("Result: Green")
    print("- Paths exist and can be scanned by non-executing ACX.")
    if args.gate == "all":
        scan_args = argparse.Namespace(paths=args.paths, max_findings=40)
        command_scan(scan_args)
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="ACX non-executing extraction helper.")
    sub = parser.add_subparsers(dest="command", required=True)

    read = sub.add_parser("read", help="Bounded file read")
    read.add_argument("path")
    read.add_argument("--lines", type=int, default=80)
    read.set_defaults(func=command_read)

    summarize = sub.add_parser("summarize-log", help="Summarize a saved raw log")
    summarize.add_argument("path")
    summarize.add_argument("--max-lines", type=int, default=80)
    summarize.set_defaults(func=command_summarize_log)

    group = sub.add_parser("group-status", help="Group saved git status text")
    group.add_argument("path")
    group.set_defaults(func=command_group_status)

    scan = sub.add_parser("scan", help="Advisory claim/product-drift scan")
    scan.add_argument("paths", nargs="+")
    scan.add_argument("--max-findings", type=int, default=80)
    scan.set_defaults(func=command_scan)

    gate = sub.add_parser("gate", help="Compact advisory gate report")
    gate.add_argument("gate", choices=["all", "claims", "scope", "routes"])
    gate.add_argument("paths", nargs="+")
    gate.set_defaults(func=command_gate)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
