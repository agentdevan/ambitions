#!/usr/bin/env python3
"""Classify runtime direct-write markers for AMB-1665.

This is a static source audit. It does not prove runtime correctness. It
guards against unclassified direct-write markers outside Core/LocalRuntimeOS
while preserving the current Yellow debt as explicit, linked classifications.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
AUTHORITY_MAP = ROOT / "docs" / "audits" / "runtime-authority-map.md"
MUTATION_REGISTRY = ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Commands" / "MeaningfulMutationRegistry.swift"

PRODUCTION_SWIFT_ROOTS = (
    "Native/Ambitions/",
    "Native/AmbitionsWidgetExtension/",
    "Native/AmbitionsShareExtension/",
    "Sources/",
    "AppUI/Sources/",
    "Packages/AmbitionsExperienceKernel/Sources/",
)

EXCLUDED_PATH_PARTS = {
    ".build",
    "DerivedData",
    "Resources",
}

DIRECT_WRITE_PATTERNS = (
    ("SwiftData", r"\bimport\s+SwiftData\b"),
    ("ModelContext", r"\bModelContext\b"),
    ("FileManager", r"\bFileManager\b"),
    ("UserDefaults", r"\bUserDefaults\b"),
    ("write_call", r"\.write\s*\("),
    (
        "context_insert",
        r"\b(?:modelContext|context|modelContainer|viewContext|managedObjectContext)\.insert\s*\(",
    ),
    (
        "context_delete",
        r"\b(?:modelContext|context|modelContainer|viewContext|managedObjectContext)\.delete\s*\(",
    ),
    (
        "context_save",
        r"\b(?:modelContext|context|modelContainer|viewContext|managedObjectContext)\.save\s*\(",
    ),
    (
        "try_save",
        r"\btry\s+(?:await\s+)?(?:modelContext|context|modelContainer|viewContext|managedObjectContext|store|repository|writer|client)\.save\s*\(",
    ),
)

CANONICAL_CLASSIFICATION = "durable"
ADAPTER_CLASSIFICATION = "adapter"
PROJECTION_CLASSIFICATION = "projection-only"
TEST_ONLY_CLASSIFICATION = "preview-only"
UNPROVEN_CLASSIFICATION = "unproven"
UNSAFE_CLASSIFICATION = "unsafe write"
UNKNOWN_CLASSIFICATION = "unknown"
DIRECT_WRITE_PROOF_FOLLOW_UP = "AMB-1719"

REGISTRY_STATUS_CLASSIFICATIONS = {
    "durable": CANONICAL_CLASSIFICATION,
    "projectionOnly": PROJECTION_CLASSIFICATION,
    "adapter": ADAPTER_CLASSIFICATION,
    "previewOnly": TEST_ONLY_CLASSIFICATION,
    "unproven": UNPROVEN_CLASSIFICATION,
}


@dataclass(frozen=True)
class AuditRow:
    path: str
    markers: list[str]
    classification: str
    follow_up: str
    detail: str


@dataclass(frozen=True)
class Finding:
    path: str
    detail: str


@dataclass(frozen=True)
class RegistryWritePath:
    path: str
    status: str
    proof_test_id: str


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT))


def is_production_swift(path: Path) -> bool:
    relative = rel(path)
    if not relative.endswith(".swift"):
        return False
    if "/Tests/" in relative or relative.startswith(("Native/AmbitionsTests/", "Native/AmbitionsUITests/")):
        return False
    if any(part in EXCLUDED_PATH_PARTS for part in path.parts):
        return False
    return relative.startswith(PRODUCTION_SWIFT_ROOTS)


def swift_files() -> list[Path]:
    files: list[Path] = []
    for prefix in PRODUCTION_SWIFT_ROOTS:
        root = ROOT / prefix
        if not root.exists():
            continue
        files.extend(path for path in root.rglob("*.swift") if is_production_swift(path))
    return sorted(files)


def direct_write_markers(text: str) -> list[str]:
    return [name for name, pattern in DIRECT_WRITE_PATTERNS if re.search(pattern, text)]


def load_registry_write_paths() -> tuple[dict[str, RegistryWritePath], list[Finding]]:
    if not MUTATION_REGISTRY.exists():
        return {}, [Finding(rel(MUTATION_REGISTRY), "meaningful mutation registry is missing")]

    text = MUTATION_REGISTRY.read_text(encoding="utf-8", errors="replace")
    proof_match = re.search(r'private static let inventoryProof\s*=\s*\n?\s*"([^"]+)"', text)
    if proof_match is None:
        return {}, [Finding(rel(MUTATION_REGISTRY), "meaningful mutation registry has no inventory proof test ID")]
    proof_test_id = proof_match.group(1)

    rows: dict[str, RegistryWritePath] = {}
    findings: list[Finding] = []
    for path, status in re.findall(r'writePath\(\s*"([^"]+)"\s*,\s*\.(\w+)\s*\)', text):
        if status not in REGISTRY_STATUS_CLASSIFICATIONS:
            findings.append(Finding(path, f"meaningful mutation registry uses unknown status `{status}`"))
            continue
        if path in rows:
            findings.append(Finding(path, "meaningful mutation registry contains a duplicate write-path row"))
            continue
        rows[path] = RegistryWritePath(path, status, proof_test_id)

    if not rows:
        findings.append(Finding(rel(MUTATION_REGISTRY), "meaningful mutation registry has no write-path rows"))
    return rows, findings


def proof_test_is_executable(proof_test_id: str) -> bool:
    parts = proof_test_id.split("/")
    if len(parts) != 3 or parts[0] != "AmbitionsTests":
        return False
    suite, method = parts[1], parts[2]
    tests = ROOT / "Native" / "AmbitionsTests"
    candidates = list(tests.rglob(f"{suite}.swift"))
    return any(re.search(rf"\bfunc\s+{re.escape(method)}\s*\(", path.read_text(encoding="utf-8", errors="replace")) for path in candidates)


def classify(relative: str, registry: dict[str, RegistryWritePath]) -> tuple[str, str, str]:
    row = registry.get(relative)
    if row is not None:
        classification = REGISTRY_STATUS_CLASSIFICATIONS[row.status]
        return (
            classification,
            "" if classification in {CANONICAL_CLASSIFICATION, TEST_ONLY_CLASSIFICATION} else DIRECT_WRITE_PROOF_FOLLOW_UP,
            f"Explicit MeaningfulMutationRegistry write-path row classifies this marker as {row.status}; path placement alone is not proof.",
        )
    return (
        UNKNOWN_CLASSIFICATION,
        "",
        "Direct-write marker has no explicit MeaningfulMutationRegistry write-path row.",
    )


def audit_rows(registry: dict[str, RegistryWritePath]) -> list[AuditRow]:
    rows: list[AuditRow] = []
    for path in swift_files():
        text = path.read_text(encoding="utf-8", errors="replace")
        markers = direct_write_markers(text)
        if not markers:
            continue
        relative = rel(path)
        classification, follow_up, detail = classify(relative, registry)
        rows.append(
            AuditRow(
                path=relative,
                markers=markers,
                classification=classification,
                follow_up=follow_up,
                detail=detail,
            )
        )
    return rows


def map_text() -> str:
    if not AUTHORITY_MAP.exists():
        return ""
    return AUTHORITY_MAP.read_text(encoding="utf-8", errors="replace")


def findings_for(
    rows: list[AuditRow],
    authority_map: str,
    registry: dict[str, RegistryWritePath],
    registry_findings: list[Finding],
) -> list[Finding]:
    findings = list(registry_findings)
    for row in rows:
        if row.classification == UNSAFE_CLASSIFICATION:
            findings.append(Finding(row.path, "unsafe production direct-write marker must move under Core/LocalRuntimeOS, become an adapter, or become test-only"))
            continue
        if row.classification == UNKNOWN_CLASSIFICATION:
            findings.append(Finding(row.path, "direct-write marker lacks a semantic mutation-registry row"))
            continue
        registry_row = registry[row.path]
        if not registry_row.proof_test_id or not proof_test_is_executable(registry_row.proof_test_id):
            findings.append(Finding(row.path, f"registry proof test `{registry_row.proof_test_id}` is not executable"))

    found_paths = {row.path for row in rows}
    for stale_path in sorted(set(registry) - found_paths):
        findings.append(Finding(stale_path, "meaningful mutation registry references a path without a current direct-write marker"))

    if not AUTHORITY_MAP.exists():
        findings.append(Finding(rel(AUTHORITY_MAP), "runtime authority map document is missing"))

    return findings


def summary(rows: list[AuditRow], findings: list[Finding]) -> dict[str, object]:
    classification_counts: dict[str, int] = {}
    marker_counts: dict[str, int] = {}
    for row in rows:
        classification_counts[row.classification] = classification_counts.get(row.classification, 0) + 1
        for marker in row.markers:
            marker_counts[marker] = marker_counts.get(marker, 0) + 1

    unsafe_or_unknown_count = (
        classification_counts.get(UNSAFE_CLASSIFICATION, 0)
        + classification_counts.get(UNKNOWN_CLASSIFICATION, 0)
    )

    unproven_count = classification_counts.get(UNPROVEN_CLASSIFICATION, 0)
    return {
        "status": "red" if findings or unsafe_or_unknown_count else "green",
        "proofStatus": "Implemented Yellow" if findings or unsafe_or_unknown_count or unproven_count else "Implemented Green",
        "directWriteMarkerCount": len(rows),
        "classificationCounts": dict(sorted(classification_counts.items())),
        "markerCounts": dict(sorted(marker_counts.items())),
        "findingCount": len(findings),
        "unsafeOrUnknownProductionRowCount": unsafe_or_unknown_count,
        "unprovenProductionRowCount": unproven_count,
    }


def run_self_test() -> int:
    fixture = {
        "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandJournal.swift": RegistryWritePath(
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandJournal.swift",
            "durable",
            "AmbitionsTests/MeaningfulMutationRegistryTests/testRegistryRowsHaveUniqueSemanticIdentityAndExecutableProofIDs",
        )
    }
    assert classify("Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandJournal.swift", fixture)[0] == CANONICAL_CLASSIFICATION
    assert classify("Native/Ambitions/Core/LocalRuntimeOS/Storage/NewStore.swift", fixture)[0] == UNKNOWN_CLASSIFICATION
    assert proof_test_is_executable(next(iter(fixture.values())).proof_test_id)
    assert "SwiftData" in direct_write_markers("import SwiftData\n")
    assert "write_call" in direct_write_markers("try data.write(to: url)")
    green_summary = summary(
        [
            AuditRow(
                path="Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift",
                markers=["SwiftData"],
                classification=CANONICAL_CLASSIFICATION,
                follow_up="",
                detail="",
            )
        ],
        [],
    )
    assert green_summary["status"] == "green"
    print("ambitions-runtime-direct-write-audit self-test passed")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Classify Ambitions runtime direct-write markers.")
    parser.add_argument("--json", action="store_true", help="Emit JSON.")
    parser.add_argument("--self-test", action="store_true", help="Run script self-tests.")
    args = parser.parse_args()

    if args.self_test:
        return run_self_test()

    registry, registry_findings = load_registry_write_paths()
    rows = audit_rows(registry)
    findings = findings_for(rows, map_text(), registry, registry_findings)
    payload = {
        "summary": summary(rows, findings),
        "findings": [asdict(finding) for finding in findings],
        "rows": [asdict(row) for row in rows],
    }

    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print("ambitions-runtime-direct-write-audit")
        print(f"status={payload['summary']['status']}")
        print(f"proofStatus={payload['summary']['proofStatus']}")
        print(f"directWriteMarkerCount={payload['summary']['directWriteMarkerCount']}")
        print(f"classificationCounts={payload['summary']['classificationCounts']}")
        if findings:
            print(f"RED {len(findings)} runtime direct-write finding(s)")
            for finding in findings:
                print(f"{finding.path}: {finding.detail}")
        else:
            print("GREEN no unsafe/unknown production direct-write rows remain")

    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
