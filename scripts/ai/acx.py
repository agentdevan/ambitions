#!/usr/bin/env python3
"""ACX — Ambitions Command eXtractor.

Non-executing repo-local extractor for Ambitions Codex OS. It summarizes saved
logs, scans advisory gates, reads bounded files, and groups changed-file text
without invoking shell commands itself.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Sequence

MAX_KEY_LINES = 80
MAX_GROUPED_LINES = 12

DEPRECATED_LANGUAGE = [
    (r"\bnext best move\b", "Use `Start here` or `Recommended step`."),
    (r"\bYour best next move\b", "Use `Start here`."),
    (r"\bInsights\b", "Insights is not a canonical top-level destination."),
    (r"\bHabit streak\b|\bstreaks?\b", "Avoid habit-tracker framing unless historical context requires it."),
]

RELEASE_CLAIMS = [
    (r"\bproduction[- ]ready\b", "Requires explicit production evidence and signoff."),
    (r"\brelease[- ]ready\b", "Requires release evidence and signoff."),
    (r"\bApp Store ready\b", "Requires App Store proof and review path."),
    (r"\bTestFlight ready\b", "Requires signing/TestFlight proof."),
    (r"\bfully tested\b", "Requires complete test evidence."),
    (r"\bfully accessible\b|\baccessibility verified\b", "Requires accessibility proof or explicit Yellow."),
    (r"\bdevice verified\b|\bphysical-device proof\b", "Requires physical-device evidence."),
]

KEY_PATTERNS = [
    r"\berror:", r"\bwarning:", r"\bBUILD FAILED\b", r"\bTEST FAILED\b",
    r"\bFAILED\b", r"\bSTOPPED ON RED\b", r"\bHard Red\b", r"\bRed\b",
    r"\bYellow\b", r"\bGreen\b", r"\bException\b", r"\bTraceback\b",
    r"\bfatal:", r"\.swift:\d+",
]


def repo_root() -> Path:
    current = Path.cwd().resolve()
    for candidate in [current, *current.parents]:
        if (candidate / ".git").exists() or (candidate / ".codex").exists() or (candidate / "docs" / "codex").exists():
            return candidate
    return current


def rel(path: Path, root: Path) -> str:
    try:
        return str(path.resolve().relative_to(root.resolve()))
    except Exception:
        return str(path)


def key_lines(text: str) -> list[str]:
    compiled = [re.compile(pattern, re.IGNORECASE) for pattern in KEY_PATTERNS]
    output: list[str] = []
    seen: set[str] = set()
    for line in text.splitlines():
        clean = line.rstrip()
        if clean and clean not in seen and any(pattern.search(clean) for pattern in compiled):
            output.append(clean)
            seen.add(clean)
        if len(output) >= MAX_KEY_LINES:
            break
    return output


def categorize(path: str) -> str:
    path = path.strip().lstrip("/")
    if " -> " in path:
        path = path.split(" -> ", 1)[1].strip()
    if path.startswith(".codex/"):
        return ".codex"
    if path.startswith("docs/canon/"):
        return "docs/canon"
    if path.startswith("docs/codex/"):
        return "docs/codex"
    if path.startswith("docs/"):
        return "docs"
    if path.startswith("scripts/"):
        return "scripts"
    if path.startswith(("Native/", "Sources/", "AppUI/")):
        return "source"
    if "Tests/" in path or path.endswith("Tests.swift") or path.startswith("Tests/"):
        return "tests"
    if path.startswith(".github/") or path in {"project.yml", "Package.swift", "README.md", "AGENTS.md", ".gitignore"}:
        return "config"
    return "other"


def safe_file(root: Path, raw: str) -> Path | None:
    target = (root / raw).resolve()
    try:
        target.relative_to(root.resolve())
    except ValueError:
        return None
    return target


def cmd_read(args: argparse.Namespace) -> int:
    root = repo_root()
    target = safe_file(root, args.file)
    if target is None:
        print("RED: refusing to read outside repo root.", file=sys.stderr)
        return 2
    if not target.is_file():
        print(f"RED: file not found: {args.file}", file=sys.stderr)
        return 1
    lines = target.read_text(encoding="utf-8", errors="replace").splitlines()
    start = max(args.start, 1)
    end = min(len(lines), start + max(args.lines, 1) - 1)
    print(f"# ACX Read `{args.file}` lines {start}-{end} of {len(lines)}")
    for number in range(start, end + 1):
        print(f"{number:>5}: {lines[number - 1]}")
    return 0


def cmd_summarize_log(args: argparse.Namespace) -> int:
    root = repo_root()
    target = safe_file(root, args.file)
    if target is None:
        print("RED: refusing to summarize outside repo root.", file=sys.stderr)
        return 2
    if not target.is_file():
        print(f"RED: log not found: {args.file}", file=sys.stderr)
        return 1
    text = target.read_text(encoding="utf-8", errors="replace")
    keys = key_lines(text)
    print(f"# ACX Log Summary — `{args.file}`")
    print(f"- Source log: `{rel(target, root)}`")
    print(f"- Lines: `{len(text.splitlines())}`")
    print("\n## Key Lines")
    if keys:
        for line in keys:
            print(f"- {line}")
    else:
        first = [line.rstrip() for line in text.splitlines() if line.strip()][:20]
        for line in first or ["No output."]:
            print(f"- {line}")
    return 0


def parse_changed_text(text: str) -> dict[str, list[tuple[str, str]]]:
    grouped: dict[str, list[tuple[str, str]]] = {}
    for line in text.splitlines():
        if not line or line.startswith("##"):
            continue
        code = line[:2]
        path = line[3:].strip() if len(line) > 3 else line.strip()
        if path:
            grouped.setdefault(categorize(path), []).append((code, path))
    return grouped


def cmd_changed_from(args: argparse.Namespace) -> int:
    root = repo_root()
    target = safe_file(root, args.file)
    if target is None or not target.is_file():
        print(f"RED: status log not found: {args.file}", file=sys.stderr)
        return 1
    grouped = parse_changed_text(target.read_text(encoding="utf-8", errors="replace"))
    print("# ACX Changed Files By Ambitions Concern")
    if not grouped:
        print("- No changed files detected in provided status text.")
    for group in sorted(grouped):
        print(f"\n## {group}")
        for code, path in grouped[group]:
            print(f"- `{code}` {path}")
    return 0


def scan(patterns: list[tuple[str, str]], args: argparse.Namespace, title: str) -> int:
    root = repo_root()
    paths = args.paths or ["AGENTS.md", "README.md", "docs", ".codex", "scripts"]
    compiled = [(re.compile(pattern, re.IGNORECASE), reason) for pattern, reason in patterns]
    findings: list[tuple[str, int, str, str]] = []
    for item in paths:
        path = safe_file(root, item)
        if path is None or not path.exists():
            continue
        candidates = [path] if path.is_file() else [p for p in path.rglob("*") if p.is_file()]
        for file_path in candidates:
            if ".git" in file_path.parts or ".codex/logs" in str(file_path):
                continue
            if file_path.suffix.lower() in {".png", ".jpg", ".jpeg", ".gif", ".webp", ".pdf", ".xcresult"}:
                continue
            text = file_path.read_text(encoding="utf-8", errors="replace")
            for line_number, line in enumerate(text.splitlines(), start=1):
                for pattern, reason in compiled:
                    if pattern.search(line):
                        findings.append((rel(file_path, root), line_number, line.strip(), reason))
    print(f"# ACX Gate — {title}")
    if not findings:
        print("Green: no matching advisory findings.")
        return 0
    for file_path, line_number, line, reason in findings[:200]:
        print(f"- {file_path}:{line_number}: {line}\n  - Advisory: {reason}")
    if args.strict:
        print("Red: strict mode converts advisory findings to failure.")
        return 1
    print("Accepted Yellow: advisory findings require owner review; strict mode not enabled.")
    return 0


def cmd_gate(args: argparse.Namespace) -> int:
    if args.name == "deprecated-language":
        return scan(DEPRECATED_LANGUAGE, args, "Deprecated Language")
    if args.name == "release-claims":
        return scan(RELEASE_CLAIMS, args, "Release Claims")
    if args.name == "all":
        return max(scan(DEPRECATED_LANGUAGE, args, "Deprecated Language"), scan(RELEASE_CLAIMS, args, "Release Claims"))
    return 2


def cmd_gate_report(args: argparse.Namespace) -> int:
    root = repo_root()
    logs = root / ".codex" / "logs"
    print("# ACX Gate Report")
    if not logs.exists():
        print("- No `.codex/logs/` directory found.")
        return 0
    files = sorted([p for p in logs.rglob("*") if p.is_file()], key=lambda p: p.stat().st_mtime, reverse=True)[: args.limit]
    markers = re.compile(r"STOPPED ON RED|Hard Red|\bRed\b|\bYellow\b|\bGreen\b|error:|warning:|BUILD FAILED|TEST FAILED", re.IGNORECASE)
    found = False
    for file_path in files:
        matches = [line.strip() for line in file_path.read_text(encoding="utf-8", errors="replace").splitlines() if markers.search(line)][:12]
        if matches:
            found = True
            print(f"\n## {rel(file_path, root)}")
            for line in matches:
                print(f"- {line}")
    if not found:
        print("- No Green/Yellow/Red, STOPPED ON RED, error, warning, build, or test markers found in recent logs.")
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="acx", description="Ambitions Command eXtractor: non-executing log/context extractor.")
    sub = p.add_subparsers(dest="command_name", required=True)
    read = sub.add_parser("read")
    read.add_argument("file")
    read.add_argument("--start", type=int, default=1)
    read.add_argument("--lines", type=int, default=120)
    read.set_defaults(func=cmd_read)
    summary = sub.add_parser("summarize-log")
    summary.add_argument("file")
    summary.set_defaults(func=cmd_summarize_log)
    changed = sub.add_parser("changed-files-from")
    changed.add_argument("file")
    changed.set_defaults(func=cmd_changed_from)
    gate = sub.add_parser("gate")
    gate.add_argument("name", choices=["deprecated-language", "release-claims", "all"])
    gate.add_argument("--strict", action="store_true")
    gate.add_argument("paths", nargs="*")
    gate.set_defaults(func=cmd_gate)
    report = sub.add_parser("gate-report")
    report.add_argument("--limit", type=int, default=60)
    report.set_defaults(func=cmd_gate_report)
    return p


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
