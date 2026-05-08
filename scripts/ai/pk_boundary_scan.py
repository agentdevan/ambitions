#!/usr/bin/env python3
"""PK02 boundary scanner for Ambitions Platform Kernel package/module drift."""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence


ROOT = Path(__file__).resolve().parents[2]


@dataclass(frozen=True)
class Finding:
    severity: str
    rule: str
    path: Path
    line: int
    detail: str

    def render(self) -> str:
        rel = self.path.relative_to(ROOT)
        return f"- {self.severity}: {self.rule}: {rel}:{self.line}: {self.detail}"


IMPORT_RE = re.compile(r"^\s*import\s+([A-Za-z0-9_]+)")
PACKAGE_PRODUCT_RE = re.compile(r"\.library\(\s*\n\s*name:\s*\"([^\"]+)\"", re.MULTILINE)


def swift_files(root: Path) -> Iterable[Path]:
    if not root.exists():
        return []
    return sorted(path for path in root.rglob("*.swift") if path.is_file())


def iter_lines(path: Path) -> Iterable[tuple[int, str]]:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return []
    return enumerate(text.splitlines(), start=1)


def scan_imports(path: Path, blocked: set[str], rule: str, detail_prefix: str) -> list[Finding]:
    findings: list[Finding] = []
    for line_no, line in iter_lines(path):
        match = IMPORT_RE.match(line)
        if not match:
            continue
        module = match.group(1)
        if module in blocked:
            findings.append(
                Finding(
                    "Yellow",
                    rule,
                    path,
                    line_no,
                    f"{detail_prefix}: imports {module}",
                )
            )
    return findings


def scan_domain() -> list[Finding]:
    blocked = {"SwiftUI", "SwiftData", "WidgetKit", "AppIntents", "EventKit"}
    findings: list[Finding] = []
    for path in swift_files(ROOT / "Native" / "Ambitions" / "Domain"):
        findings.extend(scan_imports(path, blocked, "domain_blocked_import", "Domain should stay package-ready"))
    return findings


def scan_persistence() -> list[Finding]:
    blocked = {"SwiftUI", "WidgetKit", "AppIntents", "EventKit"}
    findings: list[Finding] = []
    for path in swift_files(ROOT / "Native" / "Ambitions" / "Persistence"):
        findings.extend(scan_imports(path, blocked, "persistence_ui_or_platform_import", "Persistence should stay storage-owned"))
    return findings


def scan_runtime_and_services() -> list[Finding]:
    blocked = {"SwiftUI"}
    findings: list[Finding] = []
    for root in [
        ROOT / "Native" / "Ambitions" / "Runtime",
        ROOT / "Native" / "Ambitions" / "Services",
    ]:
        for path in swift_files(root):
            findings.extend(scan_imports(path, blocked, "runtime_service_swiftui_import", "Runtime/services should not own feature UI"))
    return findings


def scan_external_snapshots() -> list[Finding]:
    findings: list[Finding] = []
    root = ROOT / "Native" / "Ambitions" / "ExternalSnapshots"
    risky_terms = {
        "ModelContext": "external snapshots must not directly mutate SwiftData context",
        "SwiftData": "external snapshots must not import SwiftData directly",
    }
    for path in swift_files(root):
        for line_no, line in iter_lines(path):
            for term, detail in risky_terms.items():
                if term in line:
                    findings.append(Finding("Yellow", "external_snapshot_storage_boundary", path, line_no, detail))
    return findings


def scan_package_products() -> list[Finding]:
    package = ROOT / "Package.swift"
    if not package.exists():
        return [Finding("Red", "package_manifest_missing", package, 1, "Package.swift is missing")]
    text = package.read_text(encoding="utf-8", errors="replace")
    products = set(PACKAGE_PRODUCT_RE.findall(text))
    allowed = {"AmbitionsDesignSystem", "AmbitionsWidgetUI"}
    findings: list[Finding] = []
    for product in sorted(products - allowed):
        findings.append(
            Finding(
                "Yellow",
                "unscaffolded_package_product",
                package,
                1,
                f"Package product {product} needs owner batch and focused build proof",
            )
        )
    return findings


def scan() -> list[Finding]:
    findings: list[Finding] = []
    findings.extend(scan_domain())
    findings.extend(scan_persistence())
    findings.extend(scan_runtime_and_services())
    findings.extend(scan_external_snapshots())
    findings.extend(scan_package_products())
    return findings


def print_report(findings: Sequence[Finding]) -> int:
    print("# PK Boundary Scan")
    if not findings:
        print("Result: Green")
        print("No boundary drift findings detected by PK02 scanner.")
        return 0

    has_red = any(finding.severity == "Red" for finding in findings)
    result = "Red" if has_red else "Yellow"
    print(f"Result: {result}")
    print(f"Findings: {len(findings)}")
    print("\n## Findings")
    for finding in findings:
        print(finding.render())
    print("\n## Claim Boundary")
    print("Scanner findings are architecture evidence only. They do not claim package split safety or backend completion.")
    return 2 if has_red else 0


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Scan Platform Kernel module-boundary drift.")
    parser.add_argument("--strict", action="store_true", help="Return non-zero for Yellow findings as a future hard gate.")
    args = parser.parse_args(argv)
    findings = scan()
    code = print_report(findings)
    if args.strict and findings:
        return 1 if code == 0 else code
    return code


if __name__ == "__main__":
    raise SystemExit(main())
