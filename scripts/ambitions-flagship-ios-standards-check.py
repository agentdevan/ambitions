#!/usr/bin/env python3
"""Enforce flagship iOS engineering standards for Ambitions validation lanes."""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TEST_ROOTS = [
    ROOT / "Native" / "AmbitionsTests",
    ROOT / "Native" / "AmbitionsUITests",
]
SUPPORT_ROOTS = [
    ROOT / "Native" / "AmbitionsTests",
    ROOT / "Native" / "AmbitionsUITests",
]
SUPPORT_CHANGED_LINE_CAP = 600

EXPECTED_FAILURE_PATTERNS = [
    r"\bXCTExpectFailure\b",
    r"\bXCTExpectedFailure\b",
    r"\bwithKnownIssue\b",
    r"\bexpectedFailure\b",
    r"\bisExpectedFailure\b",
]

FLAKE_LANGUAGE_PATTERNS = [
    r"\bflaky\b",
    r"\bflake\b",
    r"\bintermittent\b",
    r"\btest\s+quarantine\b",
    r"\bquarantined\s+test\b",
    r"\brerun until pass\b",
    r"\bpasses locally sometimes\b",
]

UI_SLEEP_PATTERNS = [
    r"\bThread\.sleep\b",
    r"\bsleep\s*\(",
    r"\busleep\s*\(",
]

APPROVED_SKIP_REASON_PATTERNS = [
    r"SOURCE_ATLAS_LIVE_R2_ENDPOINT",
    r"DEBUG builds?",
    r"Repo source tree is unavailable",
    r"Unable to locate repository root",
    r"Historical primitive registry is not retained",
]

REQUIRED_TRUTH_SNIPPETS = {
    "docs/truth/CODEX_PROCESS_TRUTH.md": [
        "Flagship iOS engineering standard",
        "zero unexpected failures, zero expected failures, zero unreviewed skips",
        "Wrapper timeouts are not test results",
    ],
    "docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md": [
        "Flagship UI Test Standard",
        "no expected-failure lane may be counted as passing proof",
        "tests must assert rendered hierarchy or frames",
    ],
    "docs/truth/RELEASE_TRUTH.md": [
        "Flagship Test Evidence Standard",
        "expected failures count as failures",
        "wrapper timeout is inconclusive",
    ],
}

REQUIRED_UI_PROOF_HELPERS = {
    "Native/AmbitionsUITests/AmbitionsUITestCase.swift": [
        "assertFrame",
        "accessibilityText",
    ],
    "Native/AmbitionsUITests/AmbitionsScreenshotUITestSupport.swift": [
        "XCTAttachment",
        "screenshot",
    ],
    "Native/AmbitionsUITests/DeterministicScreenshotLaneUITests.swift": [
        "proofScope",
        "not Visual Green",
    ],
}


@dataclass(frozen=True)
class Finding:
    gate: str
    path: str
    detail: str


def rel(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def swift_test_files() -> list[Path]:
    files: list[Path] = []
    for root in TEST_ROOTS:
        if root.exists():
            files.extend(sorted(root.rglob("*.swift")))
    return files


def changed_paths() -> set[str]:
    result = subprocess.run(
        ["git", "status", "--short"],
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    paths: set[str] = set()
    for raw in result.stdout.splitlines():
        if not raw:
            continue
        value = raw[3:].strip()
        if " -> " in value:
            _, value = value.rsplit(" -> ", 1)
        paths.add(value)
    return paths


def line_count(text: str) -> int:
    return len(text.splitlines())


def base_line_count(relative: str) -> int | None:
    result = subprocess.run(
        ["git", "show", f"HEAD:{relative}"],
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        return None
    return line_count(result.stdout)


def support_file(path: Path) -> bool:
    return any(path.is_relative_to(root) for root in SUPPORT_ROOTS if root.exists())


def add_regex_findings(
    findings: list[Finding],
    gate: str,
    path: Path,
    text: str,
    patterns: list[str],
) -> None:
    for index, line in enumerate(text.splitlines(), start=1):
        for pattern in patterns:
            if re.search(pattern, line, flags=re.IGNORECASE):
                findings.append(Finding(gate, rel(path), f"line {index}: {line.strip()[:180]}"))
                break


def skip_reason(line: str) -> str:
    match = re.search(r"XCTSkip\s*\(\s*\"([^\"]*)\"", line)
    if match:
        return match.group(1)
    return line.strip()


def is_approved_skip(reason: str) -> bool:
    return any(re.search(pattern, reason, flags=re.IGNORECASE) for pattern in APPROVED_SKIP_REASON_PATTERNS)


def check_test_source_policy(files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        text = read(path)
        add_regex_findings(findings, "expected-failure-lane", path, text, EXPECTED_FAILURE_PATTERNS)
        add_regex_findings(findings, "flaky-test-language", path, text, FLAKE_LANGUAGE_PATTERNS)
        if rel(path).startswith("Native/AmbitionsUITests/"):
            add_regex_findings(findings, "ui-sleep", path, text, UI_SLEEP_PATTERNS)

        for index, line in enumerate(text.splitlines(), start=1):
            if "XCTSkip" not in line:
                continue
            reason = skip_reason(line)
            if is_approved_skip(reason):
                continue
            findings.append(
                Finding(
                    "unapproved-skip",
                    rel(path),
                    f"line {index}: XCTSkip reason is not approved for a flagship readiness lane: {reason[:180]}",
                )
            )
    return findings


def check_changed_support_size(changed: set[str]) -> list[Finding]:
    findings: list[Finding] = []
    for path in swift_test_files():
        relative = rel(path)
        if relative not in changed or not support_file(path):
            continue
        count = line_count(read(path))
        base_count = base_line_count(relative)
        if count > SUPPORT_CHANGED_LINE_CAP and (base_count is None or count > base_count):
            findings.append(
                Finding(
                    "oversized-changed-test-file",
                    relative,
                    f"{count} support lines exceeds {SUPPORT_CHANGED_LINE_CAP} and grew from {base_count or 'new'}; split into focused tests, fixtures, or helpers",
                )
            )
    return findings


def check_truth_snippets() -> list[Finding]:
    findings: list[Finding] = []
    for relative, snippets in REQUIRED_TRUTH_SNIPPETS.items():
        path = ROOT / relative
        if not path.exists():
            findings.append(Finding("truth-standard", relative, "required truth file is missing"))
            continue
        text = read(path)
        for snippet in snippets:
            if snippet not in text:
                findings.append(Finding("truth-standard", relative, f"missing snippet: {snippet}"))
    return findings


def check_ui_proof_helpers() -> list[Finding]:
    findings: list[Finding] = []
    for relative, snippets in REQUIRED_UI_PROOF_HELPERS.items():
        path = ROOT / relative
        if not path.exists():
            findings.append(Finding("ui-proof-helper", relative, "required UI proof helper is missing"))
            continue
        text = read(path)
        for snippet in snippets:
            if snippet not in text:
                findings.append(Finding("ui-proof-helper", relative, f"missing snippet: {snippet}"))
    return findings


def summarize(findings: list[Finding], max_per_gate: int) -> dict[str, list[Finding]]:
    grouped: dict[str, list[Finding]] = {}
    for finding in findings:
        grouped.setdefault(finding.gate, []).append(finding)
    return {gate: rows[:max_per_gate] for gate, rows in sorted(grouped.items())}


def run_self_test() -> int:
    assert re.search(EXPECTED_FAILURE_PATTERNS[0], "XCTExpectFailure(\"known\")")
    assert not is_approved_skip("Fixture must produce a plannable result.")
    assert is_approved_skip("Set SOURCE_ATLAS_LIVE_R2_ENDPOINT to run live public R2 lifecycle proof.")
    assert is_approved_skip("Demo bootstrap fixtures are only available in DEBUG builds.")
    assert re.search(UI_SLEEP_PATTERNS[0], "Thread.sleep(forTimeInterval: 1)")
    assert skip_reason('throw XCTSkip("Demo bootstrap fixtures are only available in DEBUG builds.")') == (
        "Demo bootstrap fixtures are only available in DEBUG builds."
    )
    print("ambitions-flagship-ios-standards-check self-test passed")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit Ambitions flagship iOS engineering standards.")
    parser.add_argument("--json", action="store_true", help="Emit JSON findings.")
    parser.add_argument("--max-per-gate", type=int, default=80)
    parser.add_argument("--self-test", action="store_true", help="Run self-test only.")
    args = parser.parse_args()

    if args.self_test:
        return run_self_test()

    files = swift_test_files()
    findings: list[Finding] = []
    findings.extend(check_truth_snippets())
    findings.extend(check_ui_proof_helpers())
    findings.extend(check_test_source_policy(files))
    findings.extend(check_changed_support_size(changed_paths()))

    grouped = summarize(findings, args.max_per_gate)
    if args.json:
        print(json.dumps({gate: [asdict(row) for row in rows] for gate, rows in grouped.items()}, indent=2))
    else:
        print("ambitions-flagship-ios-standards-check")
        print(f"test_swift_files={len(files)}")
        if not findings:
            print("GREEN flagship iOS standards gate passed")
            return 0
        print(f"RED {len(findings)} flagship iOS standards finding(s)")
        for gate, rows in grouped.items():
            total = sum(1 for finding in findings if finding.gate == gate)
            print(f"\n[{gate}] showing {len(rows)} of {total}")
            for row in rows:
                print(f"{row.path}: {row.detail}")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
