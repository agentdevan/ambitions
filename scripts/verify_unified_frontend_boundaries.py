#!/usr/bin/env python3
"""Validate Unified Maximum Polish frontend inventory and zero-legacy cutover."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path, PurePosixPath
from typing import Any


PROGRAM = "Ambitions Unified Maximum Polish Frontend Program"
CONTRACT_DIR = Path("docs/frontend/unified-maximum-polish-frontend")
REGISTRY_FILE = "COMPONENT_REGISTRY.json"
MANIFEST_FILE = "LEGACY_DELETION_MANIFEST.json"
FINAL_DISPOSITIONS = ["promote", "rebuild", "fixture-only", "historical", "delete"]
ENTRY_DISPOSITIONS = set(FINAL_DISPOSITIONS) | {"pending"}
REQUIRED_FINAL_METADATA = [
    "source_owner",
    "replacement",
    "dependency_edges",
    "proof_requirements",
    "removal_condition",
    "production_legacy",
]
REQUIRED_INVENTORY_ROOTS = {
    "Packages/AmbitionsPresentation/Sources/AmbitionsPresentationContracts",
    "Packages/AmbitionsPresentation/Sources/AmbitionsFlagshipFoundation",
    "Packages/AmbitionsPresentation/Sources/AmbitionsFlagshipUI",
    "Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry",
    "Packages/AmbitionsPresentation/Tests",
    "Packages/AmbitionsDesignSystem/Sources",
    "Packages/AmbitionsDesignSystem/AppUI/Sources",
    "Native/AmbitionsNativeFoundryHost",
    "Native/AmbitionsNativeFoundryHostUITests",
    "Native/AmbitionsShareExtension",
    "Native/AmbitionsWidgetExtension",
    "Native/AmbitionsUITests",
    "Native/AmbitionsTests",
    "Native/Ambitions/App",
    "Native/Ambitions/Composer",
    "Native/Ambitions/DesignSystem",
    "Native/Ambitions/Interaction",
    "Native/Ambitions/Language",
    "Native/Ambitions/PreviewSupport",
    "Native/Ambitions/Quality",
    "Native/Ambitions/Rendering",
    "Native/Ambitions/Scenarios",
    "Native/Ambitions/Stage",
    "Native/Ambitions/Surfaces",
    "Native/Ambitions/Trust",
}
CANONICAL_TARGETS = {
    "AmbitionsPresentationContracts": set(),
    "AmbitionsFlagshipFoundation": set(),
    "AmbitionsFlagshipUI": {
        "AmbitionsPresentationContracts",
        "AmbitionsFlagshipFoundation",
    },
    "AmbitionsNativeVisualFoundry": {"AmbitionsFlagshipUI"},
}
CANONICAL_IMPORTS = {
    "AmbitionsPresentationContracts": {"Foundation"},
    "AmbitionsFlagshipFoundation": {"Foundation", "SwiftUI", "UIKit", "AppKit"},
    "AmbitionsFlagshipUI": {
        "Foundation",
        "SwiftUI",
        "UIKit",
        "AppKit",
        "AmbitionsPresentationContracts",
        "AmbitionsFlagshipFoundation",
    },
}
REQUIRED_APP_PRODUCTS = {
    "AmbitionsPresentationContracts",
    "AmbitionsFlagshipFoundation",
    "AmbitionsFlagshipUI",
}
FORBIDDEN_APP_PRODUCTS = {"AmbitionsNativeVisualFoundry"}
IMPORT_RE = re.compile(r"(?m)^\s*(?:@testable\s+)?import\s+([A-Za-z_]\w*)")
IGNORED_SCAN_DIRECTORIES = {
    ".git",
    ".build",
    ".worktrees",
    ".codex-artifacts",
    ".generated",
    ".pytest_cache",
    ".ruff_cache",
    "DerivedData",
}


def load_json(path: Path) -> tuple[dict[str, Any] | None, list[str]]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return None, [f"missing contract file: {path.name}"]
    except json.JSONDecodeError as error:
        return None, [f"invalid JSON in {path.name}: {error.msg}"]
    if not isinstance(payload, dict):
        return None, [f"{path.name} root must be an object"]
    return payload, []


def valid_relative_path(value: object) -> bool:
    if not isinstance(value, str) or not value:
        return False
    path = PurePosixPath(value)
    return not path.is_absolute() and ".." not in path.parts and value == path.as_posix()


def validate_registry(root: Path, registry: dict[str, Any], mode: str) -> list[str]:
    findings: list[str] = []
    if registry.get("schema_version") != 1:
        findings.append("registry schema_version must be 1")
    if registry.get("program") != PROGRAM:
        findings.append(f"registry program must be {PROGRAM}")
    if registry.get("allowed_final_dispositions") != FINAL_DISPOSITIONS:
        findings.append(
            "registry allowed_final_dispositions must be " + ", ".join(FINAL_DISPOSITIONS)
        )
    if registry.get("required_final_metadata") != REQUIRED_FINAL_METADATA:
        findings.append(
            "registry required_final_metadata must be "
            + ", ".join(REQUIRED_FINAL_METADATA)
        )
    if registry.get("production_frontend_disposition") != (
        "legacy_in_full_delete_original_sources"
    ):
        findings.append(
            "registry production_frontend_disposition must require complete "
            "original-source deletion"
        )

    expected_gate = "pending_ufp_4" if mode == "transition" else "ufp_4_complete"
    if registry.get("gate_status") != expected_gate:
        if mode == "transition":
            findings.append("registry gate_status must be pending_ufp_4 in transition mode")
        else:
            findings.append("final mode requires registry gate_status ufp_4_complete")

    roots = registry.get("frontend_roots")
    entries = registry.get("entries")
    if not isinstance(roots, list) or not roots:
        findings.append("registry frontend_roots must be a non-empty array")
        roots = []
    if not isinstance(entries, list) or not entries:
        findings.append("registry entries must be a non-empty array")
        entries = []

    normalized_roots: list[str] = []
    for value in roots:
        if not valid_relative_path(value):
            findings.append(f"invalid frontend root: {value!r}")
        elif value in normalized_roots:
            findings.append(f"duplicate frontend root: {value}")
        else:
            normalized_roots.append(value)
    required_live_roots = {
        value for value in REQUIRED_INVENTORY_ROOTS if (root / value).is_dir()
    }
    for missing_root in sorted(required_live_roots - set(normalized_roots)):
        findings.append(f"missing required frontend inventory root: {missing_root}")

    seen_ids: set[str] = set()
    seen_paths: set[str] = set()
    valid_entries: list[dict[str, Any]] = []
    for index, entry in enumerate(entries):
        if not isinstance(entry, dict):
            findings.append(f"registry entry {index} must be an object")
            continue
        identifier = entry.get("id")
        path = entry.get("path")
        kind = entry.get("kind")
        disposition = entry.get("disposition")
        gate = entry.get("decision_gate")
        production_legacy = entry.get("production_legacy")
        if not isinstance(identifier, str) or not identifier:
            findings.append(f"registry entry {index} has invalid id")
        elif identifier in seen_ids:
            findings.append(f"duplicate component id: {identifier}")
        else:
            seen_ids.add(identifier)
        if not valid_relative_path(path):
            findings.append(f"registry entry {identifier or index} has invalid path")
        elif path in seen_paths:
            findings.append(f"duplicate component path: {path}")
        else:
            seen_paths.add(path)
        if kind not in {"file", "tree"}:
            findings.append(f"registry entry {identifier or index} kind must be file or tree")
        if disposition not in ENTRY_DISPOSITIONS:
            findings.append(f"invalid component disposition {disposition}")
        if disposition == "pending" and gate != "UFP-4":
            findings.append(f"pending component {identifier or index} must be gated by UFP-4")
        if mode == "final" and disposition == "pending":
            findings.append(f"final mode forbids pending component disposition: {identifier or index}")
        if mode == "final" and disposition in FINAL_DISPOSITIONS and gate != "UFP-4-complete":
            findings.append(f"final component {identifier or index} must record UFP-4-complete")
        if not isinstance(production_legacy, bool):
            findings.append(
                f"component {identifier or index} production_legacy must be boolean"
            )
        if mode == "final":
            for field in ("source_owner", "replacement", "removal_condition"):
                value = entry.get(field)
                if not isinstance(value, str) or not value.strip():
                    findings.append(
                        f"final component {identifier or index} needs {field}"
                    )
            dependency_edges = entry.get("dependency_edges")
            if not isinstance(dependency_edges, list) or any(
                not isinstance(value, str) or not value.strip()
                for value in dependency_edges
            ):
                findings.append(
                    f"final component {identifier or index} needs dependency_edges array"
                )
            proof_requirements = entry.get("proof_requirements")
            if not isinstance(proof_requirements, list) or not proof_requirements or any(
                not isinstance(value, str) or not value.strip()
                for value in proof_requirements
            ):
                findings.append(
                    f"final component {identifier or index} needs proof_requirements"
                )
            if production_legacy is True:
                if disposition not in {"rebuild", "delete"}:
                    findings.append(
                        f"production legacy component {identifier or index} must be "
                        "rebuild or delete"
                    )
                if valid_relative_path(path) and (root / path).exists():
                    findings.append(f"production legacy source remains: {path}")
        if (
            mode == "final"
            and disposition == "delete"
            and valid_relative_path(path)
            and (root / path).exists()
        ):
            findings.append(f"component classified delete remains: {path}")
        if valid_relative_path(path) and kind in {"file", "tree"}:
            valid_entries.append(entry)

    extensions = registry.get("inventory_extensions", [".swift"])
    if (
        not isinstance(extensions, list)
        or not extensions
        or any(not isinstance(item, str) or not item.startswith(".") for item in extensions)
    ):
        findings.append("registry inventory_extensions must be a non-empty extension array")
        extensions = [".swift"]

    for frontend_root in normalized_roots:
        absolute_root = root / frontend_root
        if not absolute_root.is_dir():
            root_entries = [
                entry
                for entry in valid_entries
                if entry["path"] == frontend_root
                or entry["path"].startswith(frontend_root.rstrip("/") + "/")
            ]
            deletion_is_complete = (
                mode == "final"
                and bool(root_entries)
                and all(entry.get("disposition") == "delete" for entry in root_entries)
            )
            if not deletion_is_complete:
                findings.append(f"missing frontend root: {frontend_root}")
            continue
        for path in sorted(item for item in absolute_root.rglob("*") if item.is_file()):
            if path.suffix not in extensions:
                continue
            relative = path.relative_to(root).as_posix()
            if not any(entry_covers(entry, relative) for entry in valid_entries):
                findings.append(f"unclassified frontend file: {relative}")
    return findings


def entry_covers(entry: dict[str, Any], relative: str) -> bool:
    entry_path = str(entry["path"])
    if entry["kind"] == "file":
        return relative == entry_path
    return relative == entry_path or relative.startswith(entry_path.rstrip("/") + "/")


def validate_manifest(manifest: dict[str, Any], mode: str) -> list[str]:
    findings: list[str] = []
    if manifest.get("schema_version") != 1:
        findings.append("legacy manifest schema_version must be 1")
    if manifest.get("program") != PROGRAM:
        findings.append(f"legacy manifest program must be {PROGRAM}")
    expected_gate = "transition" if mode == "transition" else "final"
    if manifest.get("gate_status") != expected_gate:
        findings.append(f"legacy manifest gate_status must be {expected_gate} in {mode} mode")
    if manifest.get("remove_by") != "UFP-7":
        findings.append("legacy manifest remove_by must be UFP-7")

    simple_arrays = (
        "legacy_paths",
        "legacy_package_products",
        "legacy_project_targets",
        "legacy_project_dependencies",
        "legacy_imports",
        "legacy_assets",
    )
    for key in simple_arrays:
        values = manifest.get(key)
        if not isinstance(values, list):
            findings.append(f"legacy manifest {key} must be an array")
            continue
        if len(values) != len(set(value for value in values if isinstance(value, str))):
            findings.append(f"legacy manifest {key} contains duplicates")
        for value in values:
            if not isinstance(value, str) or not value:
                findings.append(f"legacy manifest {key} contains an invalid value")
            elif key in {"legacy_paths", "legacy_assets"} and not valid_relative_path(value):
                findings.append(f"legacy manifest {key} contains invalid path {value!r}")

    for key in ("legacy_renderer_flags", "legacy_wrappers"):
        values = manifest.get(key)
        if not isinstance(values, list):
            findings.append(f"legacy manifest {key} must be an array")
            continue
        observed: set[tuple[str, str]] = set()
        for value in values:
            if not isinstance(value, dict):
                findings.append(f"legacy manifest {key} entries must be objects")
                continue
            path, symbol = value.get("path"), value.get("symbol")
            if not valid_relative_path(path) or not isinstance(symbol, str) or not symbol:
                findings.append(f"legacy manifest {key} entry requires relative path and symbol")
                continue
            identity = (path, symbol)
            if identity in observed:
                findings.append(f"legacy manifest {key} contains duplicate {symbol} in {path}")
            observed.add(identity)
    return findings


def validate_contract_alignment(
    registry: dict[str, Any], manifest: dict[str, Any]
) -> list[str]:
    findings: list[str] = []
    roots = [
        value
        for value in registry.get("frontend_roots", [])
        if valid_relative_path(value)
    ]
    for entry in registry.get("entries", []):
        if not isinstance(entry, dict) or not valid_relative_path(entry.get("path")):
            continue
        path = entry["path"]
        if not any(path == root or path.startswith(root.rstrip("/") + "/") for root in roots):
            findings.append(f"component entry is outside frontend_roots: {path}")
    for path in manifest.get("legacy_paths", []):
        if not valid_relative_path(path):
            continue
        if not any(path == root or path.startswith(root.rstrip("/") + "/") for root in roots):
            findings.append(f"legacy path is outside frontend_roots: {path}")
    return findings


def scan_canonical_imports(root: Path) -> list[str]:
    findings: list[str] = []
    source_root = root / "Packages/AmbitionsPresentation/Sources"
    for target, allowed in CANONICAL_IMPORTS.items():
        target_root = source_root / target
        if not target_root.is_dir():
            findings.append(f"missing canonical target source directory: {target_root.relative_to(root)}")
            continue
        for path in sorted(target_root.rglob("*.swift")):
            relative = path.relative_to(root).as_posix()
            imports = IMPORT_RE.findall(path.read_text(encoding="utf-8", errors="replace"))
            for module in sorted(set(imports) - allowed):
                findings.append(f"canonical UI forbidden import {module} in {relative}")
    return findings


def balanced_blocks(text: str, marker: str) -> list[str]:
    blocks: list[str] = []
    start = 0
    while True:
        marker_index = text.find(marker, start)
        if marker_index < 0:
            break
        open_index = marker_index + len(marker) - 1
        depth = 0
        in_string = False
        escaped = False
        for index in range(open_index, len(text)):
            character = text[index]
            if in_string:
                if escaped:
                    escaped = False
                elif character == "\\":
                    escaped = True
                elif character == '"':
                    in_string = False
                continue
            if character == '"':
                in_string = True
            elif character == "(":
                depth += 1
            elif character == ")":
                depth -= 1
                if depth == 0:
                    blocks.append(text[marker_index:index + 1])
                    start = index + 1
                    break
        else:
            break
    return blocks


def package_targets(text: str) -> dict[str, set[str]]:
    targets: dict[str, set[str]] = {}
    for block in balanced_blocks(text, ".target("):
        name_match = re.search(r"\bname\s*:\s*\"([^\"]+)\"", block)
        if name_match is None:
            continue
        dependency_match = re.search(r"\bdependencies\s*:\s*\[([^\]]*)\]", block, re.S)
        dependencies = (
            set(re.findall(r'\"([^\"]+)\"', dependency_match.group(1)))
            if dependency_match
            else set()
        )
        targets[name_match.group(1)] = dependencies
    return targets


def package_products(text: str) -> set[str]:
    products: set[str] = set()
    for block in balanced_blocks(text, ".library("):
        name_match = re.search(r"\bname\s*:\s*\"([^\"]+)\"", block)
        if name_match:
            products.add(name_match.group(1))
    return products


def validate_final_graph(root: Path) -> list[str]:
    findings: list[str] = []
    package_path = root / "Packages/AmbitionsPresentation/Package.swift"
    try:
        targets = package_targets(package_path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return ["missing Packages/AmbitionsPresentation/Package.swift"]
    for target, expected in CANONICAL_TARGETS.items():
        if target not in targets:
            findings.append(f"missing canonical package target: {target}")
        elif targets[target] != expected:
            if target == "AmbitionsNativeVisualFoundry" and "AmbitionsFlagshipUI" not in targets[target]:
                findings.append(
                    "AmbitionsNativeVisualFoundry target must depend on AmbitionsFlagshipUI"
                )
            findings.append(
                f"{target} target dependencies must be {sorted(expected)}: "
                f"{sorted(targets[target])}"
            )

    project_path = root / "project.yml"
    try:
        project = project_path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return findings + ["missing project.yml"]
    app_block = yaml_target_block(project, "Ambitions")
    products = set(re.findall(r"(?m)^\s+product:\s*([^\s#]+)", app_block))
    missing = sorted(REQUIRED_APP_PRODUCTS - products)
    if missing:
        findings.append("Ambitions target missing canonical products: " + ", ".join(missing))
    for product in sorted(FORBIDDEN_APP_PRODUCTS & products):
        findings.append(f"Ambitions target must not depend on Foundry product {product}")
    return findings


def yaml_target_block(text: str, target: str) -> str:
    match = re.search(rf"(?m)^  {re.escape(target)}:\s*$", text)
    if match is None:
        return ""
    next_target = re.search(r"(?m)^  [A-Za-z0-9_-]+:\s*$", text[match.end():])
    end = match.end() + next_target.start() if next_target else len(text)
    return text[match.start():end]


def all_swift_files(root: Path) -> list[Path]:
    paths: list[Path] = []
    for directory, names, files in os.walk(root):
        names[:] = [name for name in names if name not in IGNORED_SCAN_DIRECTORIES]
        paths.extend(Path(directory) / name for name in files if name.endswith(".swift"))
    return paths


def all_package_manifests(root: Path) -> list[Path]:
    paths: list[Path] = []
    for directory, names, files in os.walk(root):
        names[:] = [name for name in names if name not in IGNORED_SCAN_DIRECTORIES]
        if "Package.swift" in files:
            paths.append(Path(directory) / "Package.swift")
    return paths


def scan_final_legacy(root: Path, manifest: dict[str, Any]) -> list[str]:
    findings: list[str] = []
    for relative in manifest.get("legacy_paths", []):
        if (root / relative).exists():
            findings.append(f"legacy path remains: {relative}")

    products: set[str] = set()
    for package_path in all_package_manifests(root):
        products.update(package_products(package_path.read_text(encoding="utf-8", errors="replace")))
    for product in manifest.get("legacy_package_products", []):
        if product in products:
            findings.append(f"legacy package product remains: {product}")

    project_path = root / "project.yml"
    project = project_path.read_text(encoding="utf-8", errors="replace") if project_path.exists() else ""
    for target in manifest.get("legacy_project_targets", []):
        if re.search(rf"(?m)^  {re.escape(target)}:\s*$", project):
            findings.append(f"legacy project target remains: {target}")
    dependency_tokens = set(
        re.findall(r"(?m)^\s+(?:-\s+)?(?:package|product|target):\s*([^\s#]+)", project)
    )
    for dependency in manifest.get("legacy_project_dependencies", []):
        if dependency in dependency_tokens:
            findings.append(f"legacy project dependency remains: {dependency}")

    swift_files = all_swift_files(root)
    forbidden_imports = set(manifest.get("legacy_imports", []))
    for path in sorted(swift_files):
        imports = set(IMPORT_RE.findall(path.read_text(encoding="utf-8", errors="replace")))
        for module in sorted(imports & forbidden_imports):
            findings.append(
                f"legacy import remains: {module} in {path.relative_to(root).as_posix()}"
            )

    for field, label in (
        ("legacy_renderer_flags", "legacy renderer flag remains"),
        ("legacy_wrappers", "legacy wrapper remains"),
    ):
        for record in manifest.get(field, []):
            path = root / record["path"]
            if path.is_file() and re.search(
                rf"\b{re.escape(record['symbol'])}\b",
                path.read_text(encoding="utf-8", errors="replace"),
            ):
                findings.append(f"{label}: {record['symbol']} in {record['path']}")
    for relative in manifest.get("legacy_assets", []):
        if (root / relative).exists():
            findings.append(f"legacy asset remains: {relative}")
    return findings


def scan(root: Path, mode: str) -> list[str]:
    contract_dir = root / CONTRACT_DIR
    registry, findings = load_json(contract_dir / REGISTRY_FILE)
    manifest, manifest_findings = load_json(contract_dir / MANIFEST_FILE)
    findings.extend(manifest_findings)
    if registry is not None:
        findings.extend(validate_registry(root, registry, mode))
    if manifest is not None:
        findings.extend(validate_manifest(manifest, mode))
    if registry is not None and manifest is not None:
        findings.extend(validate_contract_alignment(registry, manifest))
    findings.extend(scan_canonical_imports(root))
    if mode == "final" and registry is not None and manifest is not None:
        findings.extend(validate_final_graph(root))
        findings.extend(scan_final_legacy(root, manifest))
    return findings


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate Unified Maximum Polish frontend boundaries"
    )
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--mode", choices=("transition", "final"), default="transition")
    arguments = parser.parse_args()
    findings = scan(arguments.root.resolve(), arguments.mode)
    if findings:
        for finding in findings:
            print(f"FAIL: {finding}")
        return 1
    print(f"PASS: unified frontend boundaries ({arguments.mode})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
