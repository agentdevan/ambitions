#!/usr/bin/env python3
"""Fail closed when Flagship targets acquire legacy or mutating dependencies."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path


PRESENTATION_ROOT = Path("Packages/AmbitionsPresentation/Sources")
TARGET_RULES = {
    "AmbitionsPresentationContracts": {
        "imports": {"Foundation"},
        "symbols": {
            "AppContainer", "StageStore", "RuntimeCommandClient",
            "CaptureServicing", "GoalsServicing", "TodayServicing",
            "SwiftData", "ModelContext", "NSManagedObjectContext",
        },
    },
    "AmbitionsFlagshipFoundation": {
        "imports": {"Foundation", "SwiftUI", "UIKit", "AppKit"},
        "symbols": {
            "AmbitionsDesignSystem", "AppContainer", "StageStore",
            "RuntimeCommandClient", "ModelContext", "SwiftData",
        },
    },
    "AmbitionsFlagshipUI": {
        "imports": {
            "Foundation", "SwiftUI", "UIKit", "AppKit",
            "AmbitionsPresentationContracts", "AmbitionsFlagshipFoundation",
        },
        "symbols": {
            "AmbitionsDesignSystem", "AppContainer", "StageStore",
            "RuntimeCommandClient", "CaptureServicing", "GoalsServicing",
            "TodayServicing", "SwiftData", "ModelContext",
            "NSManagedObjectContext",
        },
    },
}
EXPECTED_TARGET_DEPENDENCIES = {
    "AmbitionsPresentationContracts": [],
    "AmbitionsFlagshipFoundation": [],
    "AmbitionsFlagshipUI": [
        "AmbitionsFlagshipFoundation",
        "AmbitionsPresentationContracts",
    ],
}
REQUIRED_APP_PRODUCTS = {
    "AmbitionsRuntimeCore",
    "AmbitionsRuntimeSQLite",
    "AmbitionsPresentationContracts",
    "AmbitionsFlagshipFoundation",
    "AmbitionsFlagshipUI",
}
FORBIDDEN_PRODUCTION_PRODUCTS = {"AmbitionsRuntimeTestSupport"}
IMPORT_RE = re.compile(r"(?m)^\s*(?:@testable\s+)?import\s+([A-Za-z_]\w*)")


def _code_only(text: str) -> str:
    """Remove comments and string contents before forbidden-symbol scanning."""
    output: list[str] = []
    index = 0
    state = "code"
    while index < len(text):
        pair = text[index:index + 2]
        character = text[index]
        if state == "code":
            if pair == "//":
                state = "line"
                output.extend("  ")
                index += 2
            elif pair == "/*":
                state = "block"
                output.extend("  ")
                index += 2
            elif character == '"':
                state = "string"
                output.append(" ")
                index += 1
            else:
                output.append(character)
                index += 1
        elif state == "line":
            output.append("\n" if character == "\n" else " ")
            if character == "\n":
                state = "code"
            index += 1
        elif state == "block":
            if pair == "*/":
                output.extend("  ")
                index += 2
                state = "code"
            else:
                output.append("\n" if character == "\n" else " ")
                index += 1
        else:
            if character == "\\" and index + 1 < len(text):
                output.extend("  ")
                index += 2
            elif character == '"':
                output.append(" ")
                index += 1
                state = "code"
            else:
                output.append("\n" if character == "\n" else " ")
                index += 1
    return "".join(output)


def scan_source_boundaries(root: Path) -> list[str]:
    findings: list[str] = []
    for target, rules in TARGET_RULES.items():
        target_root = root / PRESENTATION_ROOT / target
        if not target_root.is_dir():
            findings.append(f"missing Flagship target source directory: {target_root.relative_to(root)}")
            continue
        for path in sorted(target_root.rglob("*.swift")):
            relative = path.relative_to(root).as_posix()
            text = path.read_text(encoding="utf-8", errors="replace")
            imports = set(IMPORT_RE.findall(text))
            for module in sorted(imports - rules["imports"]):
                findings.append(f"{target} forbidden import {module} in {relative}")
            code = _code_only(text)
            for symbol in sorted(rules["symbols"]):
                if re.search(rf"\b{re.escape(symbol)}\b", code):
                    findings.append(f"{target} forbidden symbol {symbol} in {relative}")
    return findings


def validate_package_descriptor(descriptor: dict) -> list[str]:
    findings: list[str] = []
    targets = {
        row.get("name"): row
        for row in descriptor.get("targets", [])
        if row.get("type") == "library"
    }
    for name, expected in EXPECTED_TARGET_DEPENDENCIES.items():
        row = targets.get(name)
        if row is None:
            findings.append(f"missing presentation package target: {name}")
            continue
        actual = sorted(row.get("target_dependencies", []))
        if actual != expected:
            findings.append(
                f"{name} target dependencies must be {expected}: {actual}"
            )
    return findings


def validate_resolved_xcode_graph(graph: dict) -> list[str]:
    findings: list[str] = []
    objects = graph.get("objects", {})
    app = next(
        (
            row for row in objects.values()
            if row.get("isa") == "PBXNativeTarget" and row.get("name") == "Ambitions"
        ),
        None,
    )
    if app is None:
        return ["resolved XcodeGen graph has no Ambitions production target"]
    product_ids = app.get("packageProductDependencies", [])
    products = {
        objects.get(identifier, {}).get("productName")
        for identifier in product_ids
    }
    products.discard(None)
    missing = sorted(REQUIRED_APP_PRODUCTS - products)
    if missing:
        findings.append(
            "Ambitions production target is missing package products: "
            + ", ".join(missing)
        )
    for product in sorted(FORBIDDEN_PRODUCTION_PRODUCTS & products):
        findings.append(f"Ambitions production target links forbidden {product}")

    local_paths = {
        row.get("relativePath")
        for row in objects.values()
        if row.get("isa") == "XCLocalSwiftPackageReference"
    }
    for path in ("Packages/AmbitionsPresentation", "Packages/AmbitionsRuntime"):
        if path not in local_paths:
            findings.append(f"resolved XcodeGen graph is missing local package: {path}")
    return findings


def _package_descriptor(root: Path) -> dict:
    result = subprocess.run(
        [
            "swift", "package", "--package-path",
            str(root / "Packages/AmbitionsPresentation"),
            "describe", "--type", "json",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def _resolved_xcode_graph(project: Path) -> dict:
    pbxproj = project / "project.pbxproj" if project.is_dir() else project
    result = subprocess.run(
        ["plutil", "-convert", "json", "-o", "-", str(pbxproj)],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--project", type=Path, default=Path("Ambitions.xcodeproj"))
    arguments = parser.parse_args()
    root = arguments.root.resolve()
    project = arguments.project
    if not project.is_absolute():
        project = root / project

    findings = scan_source_boundaries(root)
    findings.extend(validate_package_descriptor(_package_descriptor(root)))
    findings.extend(validate_resolved_xcode_graph(_resolved_xcode_graph(project)))
    if findings:
        for finding in findings:
            print(f"FAIL: {finding}")
        return 1
    print("Flagship boundary audit passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
