#!/usr/bin/env python3
"""Fail newly introduced weak implementation patterns in changed lines."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ALLOW_RE = re.compile(r'AMBitionsAllowWeakPattern\(reason:\s*"([^"]+)"\)')
GENERIC_REASON_RE = re.compile(r"\b(todo|fixme|later|temporary|placeholder|stub|test|fixture|because)\b", re.I)


@dataclass(frozen=True)
class Finding:
    path: str
    line: int
    pattern: str
    reason: str


PATTERNS: list[tuple[re.Pattern[str], str, str]] = [
    (re.compile(r"\bTODO\b", re.I), "TODO", "new deferred implementation language"),
    (re.compile(r"\bFIXME\b", re.I), "FIXME", "new known-broken implementation language"),
    (re.compile(r"\bstub\b", re.I), "stub", "new stub implementation claim"),
    (re.compile(r"\bplaceholder\b", re.I), "placeholder", "new placeholder implementation claim"),
    (re.compile(r"\bnoop\b|\bno-op\b", re.I), "noop", "new no-op implementation claim"),
    (re.compile(r"\bnot implemented\b", re.I), "not implemented", "new not-implemented path"),
    (re.compile(r'fatalError\s*\(\s*"not implemented"\s*\)', re.I), 'fatalError("not implemented")', "new runtime crash placeholder"),
    (re.compile(r"\bXCTSkip\b", re.I), "XCTSkip", "new skipped test"),
    (re.compile(r"\bDISABLED_|\.disabled\b|@disabled\b", re.I), "disabled test", "new disabled test marker"),
    (re.compile(r"\bcatch\s*\{\s*\}", re.I), "empty catch", "new swallowed error path"),
    (re.compile(r"\bfake\s+fixtures?\b|\bfake[-_]fixtures?\b", re.I), "fake fixtures", "new fake fixture claim"),
    (re.compile(r"\btemporary\b.{0,60}\b(implementation|impl|path|validator|audit|check)\b", re.I), "temporary implementation", "new temporary implementation claim"),
]

VALIDATOR_RETURN_TRUE_RE = re.compile(r"\breturn\s+(true|True)\b")
EMPTY_VALIDATOR_RE = re.compile(r"\bpass\b|\breturn\s+None\b|\breturn\s+\[\]\b")


def run_git(args: list[str], check: bool = False) -> str:
    result = subprocess.run(["git", *args], cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if check and result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "git command failed")
    return result.stdout


def resolve_base() -> str | None:
    for candidate in [
        *([__import__("os").environ.get("GITHUB_BASE_SHA", "")] if __import__("os").environ.get("GITHUB_BASE_SHA") else []),
        "origin/" + __import__("os").environ.get("GITHUB_BASE_REF", "main"),
        "origin/main",
    ]:
        if not candidate:
            continue
        result = subprocess.run(["git", "rev-parse", "--verify", candidate], cwd=ROOT, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if result.returncode == 0:
            if candidate.startswith("origin/"):
                merge_base = run_git(["merge-base", "HEAD", candidate]).strip()
                return merge_base or None
            return candidate
    return None


def changed_lines_from_diff(args: list[str]) -> dict[str, set[int]]:
    changed: dict[str, set[int]] = {}
    output = run_git(["diff", "--unified=0", "--no-ext-diff", *args])
    current_path: str | None = None
    new_line = 0
    for line in output.splitlines():
        if line.startswith("+++ b/"):
            current_path = line[6:]
            changed.setdefault(current_path, set())
            continue
        if line.startswith("@@ "):
            match = re.search(r"\+(\d+)(?:,(\d+))?", line)
            if match:
                new_line = int(match.group(1)) - 1
            continue
        if current_path is None:
            continue
        if line.startswith("+") and not line.startswith("+++"):
            new_line += 1
            changed[current_path].add(new_line)
        elif not line.startswith("-"):
            new_line += 1
    return changed


def merge_changed_lines() -> dict[str, set[int]]:
    merged: dict[str, set[int]] = {}
    base = resolve_base()
    if base:
        for path, lines in changed_lines_from_diff([base, "--"]).items():
            merged.setdefault(path, set()).update(lines)
    for path, lines in changed_lines_from_diff(["--"]).items():
        merged.setdefault(path, set()).update(lines)

    untracked = [line for line in run_git(["ls-files", "--others", "--exclude-standard"]).splitlines() if line]
    for path in untracked:
        full = ROOT / path
        if full.is_file():
            try:
                line_count = len(full.read_text(encoding="utf-8", errors="ignore").splitlines())
            except OSError:
                continue
            merged[path] = set(range(1, line_count + 1))
    return merged


def is_text_path(path: str) -> bool:
    suffix = Path(path).suffix.lower()
    return suffix in {".swift", ".py", ".sh", ".md", ".yml", ".yaml", ".json", ".toml", ".txt", ".rb"}


def is_policy_definition_path(path: str) -> bool:
    return (
        path == "scripts/ci/ambitions-no-weak-implementation-scan.py"
        or path.startswith(".semgrep/")
        or path in {
            ".gitleaks.toml",
            ".markdownlint-cli2.yaml",
            ".swiftlint.yml",
            ".yamllint.yml",
        }
    )


def is_fixture_or_test(path: str) -> bool:
    lower = path.lower()
    return any(part in lower for part in ["test", "tests", "fixture", "fixtures", "preview"])


def is_production_swift(path: str) -> bool:
    return path.startswith("Native/Ambitions/") and path.endswith(".swift")


def is_validation_or_audit_script(path: str) -> bool:
    lower = path.lower()
    return path.startswith("scripts/") and any(word in lower for word in ["audit", "scan", "lint", "gate", "validator", "validation"])


def is_code_path(path: str) -> bool:
    return Path(path).suffix.lower() in {".py", ".sh", ".swift", ".rb"}


def is_validator_context(path: str, line: str) -> bool:
    lower = line.lower()
    return any(word in lower for word in ["validator", "validate", "audit", "scan", "gate", "lint", "check"])


def concrete_allow_reason(reason: str) -> bool:
    words = re.findall(r"[A-Za-z0-9]+", reason)
    return len(reason.strip()) >= 18 and len(words) >= 4 and not GENERIC_REASON_RE.search(reason)


def allow_marker(lines: list[str], index: int) -> str | None:
    window = lines[max(0, index - 2) : min(len(lines), index + 1)]
    for candidate in window:
        match = ALLOW_RE.search(candidate)
        if match:
            return match.group(1)
    return None


def scan_file(path: str, changed_lines: set[int]) -> list[Finding]:
    full_path = ROOT / path
    try:
        lines = full_path.read_text(encoding="utf-8", errors="ignore").splitlines()
    except OSError:
        return []

    findings: list[Finding] = []
    if is_policy_definition_path(path):
        return findings

    for line_number in sorted(changed_lines):
        if line_number < 1 or line_number > len(lines):
            continue
        line = lines[line_number - 1]
        stripped = line.strip()
        if not stripped:
            continue

        marker_match = ALLOW_RE.search(line)
        if marker_match and (is_production_swift(path) or is_validation_or_audit_script(path)):
            reason = marker_match.group(1)
            if not concrete_allow_reason(reason):
                findings.append(
                    Finding(path, line_number, "AMBitionsAllowWeakPattern", "allow marker in production/validation code needs a concrete reason")
                )

        allowed_reason = allow_marker(lines, line_number - 1)
        allowed = allowed_reason is not None and (is_fixture_or_test(path) or concrete_allow_reason(allowed_reason))

        for regex, label, reason in PATTERNS:
            if regex.search(line) and not allowed:
                findings.append(Finding(path, line_number, label, reason))

        if is_code_path(path) and VALIDATOR_RETURN_TRUE_RE.search(line) and is_validator_context(path, line) and not allowed:
            findings.append(Finding(path, line_number, "return true", "validator/audit returns success without visible checks"))

        if is_code_path(path) and EMPTY_VALIDATOR_RE.search(line) and is_validator_context(path, line) and not allowed:
            findings.append(Finding(path, line_number, "empty validator", "validator/audit body appears empty"))

        if re.search(r"\bcatch\b", line) and line_number < len(lines):
            next_line = lines[line_number].strip()
            if next_line == "}" and not allowed:
                findings.append(Finding(path, line_number, "empty catch", "new catch block swallows errors"))

    return findings


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--all", action="store_true", help="scan tracked text files instead of changed lines")
    args = parser.parse_args()

    if args.all:
        changed = {
            path: set(range(1, len((ROOT / path).read_text(encoding="utf-8", errors="ignore").splitlines()) + 1))
            for path in run_git(["ls-files"]).splitlines()
            if is_text_path(path) and (ROOT / path).is_file()
        }
    else:
        changed = {path: lines for path, lines in merge_changed_lines().items() if is_text_path(path)}

    findings: list[Finding] = []
    for path, lines in sorted(changed.items()):
        if lines:
            findings.extend(scan_file(path, lines))

    print("# Ambitions Weak Implementation Scan")
    if findings:
        for finding in findings:
            print(f"{finding.path}:{finding.line}: {finding.pattern}: {finding.reason}", file=sys.stderr)
        return 1

    print("GREEN: no newly introduced weak implementation patterns found")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
