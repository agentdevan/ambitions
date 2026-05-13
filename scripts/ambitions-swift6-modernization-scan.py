#!/usr/bin/env python3
"""Ambitions Swift 6 modernization guardrail scan.

This scan is intentionally repo-specific. It protects the Ambitions native app from
regressing back into older SwiftUI architecture patterns while Swift 6 migration is
in progress.

Default behavior is advisory. Pass --strict or set AMBITIONS_SWIFT6_SCAN_STRICT=1
to fail on blocking findings.
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

ALLOW_MARKER = "AMB_SWIFT6_ALLOW"

SOURCE_ROOTS = (
    "Native/Ambitions",
    "Native/AmbitionsWidgetExtension",
    "Native/AmbitionsShareExtension",
    "Sources",
    "AppUI/Sources",
)

SETTINGS_FILES = (
    "project.yml",
    "Package.swift",
)

EXCLUDED_DIR_NAMES = {
    ".git",
    ".codex",
    ".build",
    "build",
    "DerivedData",
    "node_modules",
    ".swiftpm",
}


@dataclass(frozen=True)
class Rule:
    code: str
    severity: str
    pattern: re.Pattern[str]
    message: str
    allowable: bool = True


@dataclass(frozen=True)
class Finding:
    severity: str
    code: str
    path: Path
    line: int
    message: str
    text: str
    allowed: bool


ARCHITECTURE_RULES: tuple[Rule, ...] = (
    Rule(
        "combine-import",
        "error",
        re.compile(r"^\s*import\s+Combine\b"),
        "Combine is edge-only. Prefer Observation and async/await; allowlist only adapter files.",
    ),
    Rule(
        "observable-object",
        "error",
        re.compile(r"\bObservableObject\b"),
        "ObservableObject is legacy for Ambitions app state. Prefer Observation/@Observable.",
    ),
    Rule(
        "published-wrapper",
        "error",
        re.compile(r"@Published\b"),
        "@Published is legacy for Ambitions app state. Prefer Observation/@Observable.",
    ),
    Rule(
        "any-cancellable",
        "error",
        re.compile(r"\bAnyCancellable\b"),
        "AnyCancellable indicates Combine-owned state. Keep Combine at explicit adapter edges only.",
    ),
    Rule(
        "unchecked-sendable",
        "error",
        re.compile(r"@unchecked\s+Sendable"),
        "Unchecked Sendable requires a local invariant, tests, and explicit allowlist proof.",
    ),
    Rule(
        "viper-naming",
        "error",
        re.compile(r"\b(VIPER|Wireframe|Presenter|Interactor)\b"),
        "VIPER-style architecture is forbidden for Ambitions SwiftUI surfaces.",
    ),
)

DEPENDENCY_RULES: tuple[Rule, ...] = (
    Rule(
        "hummingbird-dependency",
        "error",
        re.compile(r"\bHummingbird\b|hummingbird-project", re.IGNORECASE),
        "Hummingbird is forbidden in native app targets. It belongs only in future separate server/tooling scopes.",
    ),
)


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Scan Ambitions Swift 6 modernization guardrails.")
    parser.add_argument("root", nargs="?", default=".", help="Repository root. Defaults to current directory.")
    parser.add_argument("--strict", action="store_true", help="Exit nonzero on blocking findings.")
    parser.add_argument("--self-test", action="store_true", help="Run scanner self-tests.")
    return parser.parse_args(argv)


def is_strict(args: argparse.Namespace) -> bool:
    return args.strict or os.environ.get("AMBITIONS_SWIFT6_SCAN_STRICT") == "1"


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def has_allow_marker(line: str) -> bool:
    return ALLOW_MARKER in line


def iter_source_files(root: Path) -> Iterable[Path]:
    for relative_root in SOURCE_ROOTS:
        source_root = root / relative_root
        if not source_root.exists():
            continue
        for path in source_root.rglob("*.swift"):
            if any(part in EXCLUDED_DIR_NAMES for part in path.parts):
                continue
            yield path


def iter_settings_files(root: Path) -> Iterable[Path]:
    for relative in SETTINGS_FILES:
        path = root / relative
        if path.exists():
            yield path


def scan_rules(paths: Iterable[Path], rules: Sequence[Rule]) -> list[Finding]:
    findings: list[Finding] = []
    for path in paths:
        lines = read_text(path).splitlines()
        for index, line in enumerate(lines, start=1):
            for rule in rules:
                if rule.pattern.search(line):
                    allowed = rule.allowable and has_allow_marker(line)
                    findings.append(
                        Finding(
                            severity=rule.severity,
                            code=rule.code,
                            path=path,
                            line=index,
                            message=rule.message,
                            text=line.strip(),
                            allowed=allowed,
                        )
                    )
    return findings


def scan_settings(root: Path) -> list[Finding]:
    findings: list[Finding] = []
    project = root / "project.yml"
    package = root / "Package.swift"

    if not project.exists():
        findings.append(
            Finding("error", "missing-project-yml", project, 0, "project.yml is required for Ambitions XcodeGen settings.", "", False)
        )
    else:
        text = read_text(project)
        if "SWIFT_VERSION: 6.0" not in text:
            findings.append(
                Finding("error", "swift-version-not-6", project, 0, "project.yml must declare SWIFT_VERSION: 6.0.", "", False)
            )
        if "SWIFT_STRICT_CONCURRENCY: complete" not in text:
            findings.append(
                Finding(
                    "error",
                    "strict-concurrency-not-complete",
                    project,
                    0,
                    "project.yml must declare SWIFT_STRICT_CONCURRENCY: complete for Swift 6 migration proof.",
                    "",
                    False,
                )
            )

    if not package.exists():
        findings.append(
            Finding("error", "missing-package-swift", package, 0, "Package.swift is required for package/toolchain proof.", "", False)
        )
    else:
        first_line = read_text(package).splitlines()[0] if read_text(package).splitlines() else ""
        if "swift-tools-version: 6.0" not in first_line:
            findings.append(
                Finding("error", "package-tools-not-6", package, 1, "Package.swift must declare swift-tools-version: 6.0.", first_line, False)
            )

    return findings


def all_findings(root: Path) -> list[Finding]:
    source_findings = scan_rules(iter_source_files(root), ARCHITECTURE_RULES)
    settings_dependency_findings = scan_rules(iter_settings_files(root), DEPENDENCY_RULES)
    return scan_settings(root) + source_findings + settings_dependency_findings


def render(root: Path, findings: Sequence[Finding]) -> str:
    blocking = [finding for finding in findings if finding.severity == "error" and not finding.allowed]
    allowed = [finding for finding in findings if finding.allowed]
    status = "RED" if blocking else "GREEN"
    lines = [
        "Ambitions Swift 6 modernization scan",
        f"Root: {root}",
        f"Status: {status}",
        f"Findings: {len(findings)}",
        f"Blocking: {len(blocking)}",
        f"Allowed: {len(allowed)}",
        "",
    ]
    for finding in findings:
        relative = finding.path.relative_to(root) if finding.path.is_absolute() and root in finding.path.parents else finding.path
        allowance = "allowed" if finding.allowed else "blocking"
        line = f"{finding.severity.upper()} {finding.code} {relative}:{finding.line} [{allowance}] - {finding.message}"
        lines.append(line)
        if finding.text:
            lines.append(f"  >> {finding.text}")
    return "\n".join(lines)


def write_fixture(root: Path, project_swift_version: str = "6.0", strict: str = "complete", package_tools: str = "6.0") -> None:
    (root / "Native/Ambitions/Features/Today").mkdir(parents=True)
    (root / "Sources").mkdir(parents=True)
    (root / "project.yml").write_text(
        f"settings:\n  base:\n    SWIFT_VERSION: {project_swift_version}\n    SWIFT_STRICT_CONCURRENCY: {strict}\n",
        encoding="utf-8",
    )
    (root / "Package.swift").write_text(f"// swift-tools-version: {package_tools}\n", encoding="utf-8")
    (root / "Native/Ambitions/Features/Today/TodayViewModel.swift").write_text(
        "import Observation\n\n@MainActor @Observable final class TodayViewModel {}\n",
        encoding="utf-8",
    )


def run_self_test() -> int:
    with tempfile.TemporaryDirectory() as raw:
        root = Path(raw)
        write_fixture(root)
        clean = all_findings(root)
        clean_blocking = [finding for finding in clean if finding.severity == "error" and not finding.allowed]
        if clean_blocking:
            print(render(root, clean))
            print("SELF_TEST clean fixture unexpectedly blocked", file=sys.stderr)
            return 1

        legacy = root / "Native/Ambitions/Features/Today/LegacyViewModel.swift"
        legacy.write_text(
            "import Combine\n\nfinal class LegacyViewModel: ObservableObject {\n    @Published var title = \"\"\n    var cancellables: Set<AnyCancellable> = []\n}\n",
            encoding="utf-8",
        )
        findings = all_findings(root)
        blocking = [finding for finding in findings if finding.severity == "error" and not finding.allowed]
        expected_codes = {"combine-import", "observable-object", "published-wrapper", "any-cancellable"}
        actual_codes = {finding.code for finding in blocking}
        if not expected_codes.issubset(actual_codes):
            print(render(root, findings))
            print("SELF_TEST legacy fixture missed expected blocking codes", file=sys.stderr)
            return 1

    print("SELF_TEST_STATUS=GREEN")
    return 0


def main(argv: Sequence[str]) -> int:
    args = parse_args(argv)
    if args.self_test:
        return run_self_test()

    root = Path(args.root).resolve()
    findings = all_findings(root)
    print(render(root, findings))
    blocking = [finding for finding in findings if finding.severity == "error" and not finding.allowed]
    if blocking and is_strict(args):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
