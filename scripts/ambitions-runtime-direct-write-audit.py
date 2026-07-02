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

CANONICAL_CLASSIFICATION = "canonical command"
ADAPTER_CLASSIFICATION = "adapter into command"
PROJECTION_CLASSIFICATION = "projection-only read"
UNSAFE_CLASSIFICATION = "unsafe write"
UNKNOWN_CLASSIFICATION = "unknown"
DIRECT_WRITE_PROOF_FOLLOW_UP = "AMB-1719"

KNOWN_FORBIDDEN_CLASSIFICATIONS: dict[str, tuple[str, str, str]] = {
    "Native/Ambitions/PreviewSupport/PreviewAppContainer.swift": (
        UNKNOWN_CLASSIFICATION,
        "AMB-1710",
        "Preview/debug fixture path uses temporary FileManager storage and needs fixture authority review.",
    ),
    "Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift": (
        ADAPTER_CLASSIFICATION,
        "AMB-1708",
        "External creation handoff queue is imported by DefaultExternalCreationImportService into AmbitionsCommand.",
    ),
    "Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift": (
        PROJECTION_CLASSIFICATION,
        "AMB-1708",
        "External snapshot export writes app-group projection data after privacy validation; it is not canonical private graph state.",
    ),
    "Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift": (
        PROJECTION_CLASSIFICATION,
        "AMB-1708",
        "Shared snapshot URL helper supports projection export and external-surface reads.",
    ),
    "Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift": (
        ADAPTER_CLASSIFICATION,
        "AMB-1708",
        "Notification scheduling reads safe external snapshots and records side effects; action payloads route back through app command handling.",
    ),
    "Native/Ambitions/Core/Domain/RealityModels.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Local schedule block file writes live in Core/Domain and must move under LocalRuntimeOS authority.",
    ),
    "Native/Ambitions/Core/Persistence/LifeContextPersistence.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy SwiftData persistence scaffolding remains outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/PortableSnapshotService+02-PortableSnapshotService.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Portable snapshot save path remains in legacy Core/Persistence scaffolding.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataModels+02-CaptureRecord.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy SwiftData model authority remains outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataModels+03-EntityRevisionTombstoneRecord.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy SwiftData tombstone model authority remains outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataModels+04-AmbitionGraphProjectionRecordModel.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy SwiftData projection-record model authority remains outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataModels.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy SwiftData model authority remains outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+02-persisted.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy SwiftData mapping scaffolding remains outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+03-feedbackRecord.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy SwiftData feedback mapping scaffolding remains outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+04-apply.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy SwiftData apply mapping scaffolding remains outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+05-entityRevisionTombstone.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy SwiftData tombstone mapping scaffolding remains outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy SwiftData mapping scaffolding remains outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataRepositories+03-Array.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy SwiftData repository helper remains outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataRepositories+04-SwiftDataGoalPersistence.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy goal persistence writes remain outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataRepositories+05-SwiftDataAmbitionGraphProjectionRecordRepository.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy graph projection record repository writes remain outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataRepositories+06-SwiftDataAppStateRepository.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy app-state repository writes remain outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataRepositories+07-SwiftDataRuntimeSnapshotLedgerRepository.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy runtime snapshot ledger repository writes remain outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataRepositories+08-SwiftDataReminderRepository.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy reminder repository writes remain outside Core/LocalRuntimeOS.",
    ),
    "Native/Ambitions/Core/Persistence/SwiftDataRepositories.swift": (
        UNSAFE_CLASSIFICATION,
        DIRECT_WRITE_PROOF_FOLLOW_UP,
        "Legacy SwiftData repository authority remains outside Core/LocalRuntimeOS.",
    ),
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


def classify(relative: str) -> tuple[str, str, str]:
    if relative.startswith("Native/Ambitions/Core/LocalRuntimeOS/"):
        return (
            CANONICAL_CLASSIFICATION,
            "",
            "Direct-write marker is inside the canonical LocalRuntimeOS owner and remains subject to command/event/projection/receipt/replay proof.",
        )
    if relative in KNOWN_FORBIDDEN_CLASSIFICATIONS:
        return KNOWN_FORBIDDEN_CLASSIFICATIONS[relative]
    return (
        UNKNOWN_CLASSIFICATION,
        "",
        "Direct-write marker is outside Core/LocalRuntimeOS and has no AMB-1665 classification.",
    )


def audit_rows() -> list[AuditRow]:
    rows: list[AuditRow] = []
    for path in swift_files():
        text = path.read_text(encoding="utf-8", errors="replace")
        markers = direct_write_markers(text)
        if not markers:
            continue
        relative = rel(path)
        classification, follow_up, detail = classify(relative)
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


def findings_for(rows: list[AuditRow], authority_map: str) -> list[Finding]:
    findings: list[Finding] = []
    for row in rows:
        known_forbidden = row.path in KNOWN_FORBIDDEN_CLASSIFICATIONS
        if row.classification == UNKNOWN_CLASSIFICATION and not row.follow_up:
            findings.append(Finding(row.path, "unclassified direct-write marker outside Core/LocalRuntimeOS"))
            continue
        if row.classification in {UNSAFE_CLASSIFICATION, UNKNOWN_CLASSIFICATION} and not row.follow_up:
            findings.append(Finding(row.path, f"{row.classification} classification requires a follow-up issue"))
        if known_forbidden and row.path not in authority_map:
            findings.append(Finding(row.path, f"{AUTHORITY_MAP.relative_to(ROOT)} does not mention classified path"))
        if known_forbidden and row.follow_up and row.follow_up not in authority_map:
            findings.append(Finding(row.path, f"{AUTHORITY_MAP.relative_to(ROOT)} does not mention follow-up {row.follow_up}"))

    known_paths = set(KNOWN_FORBIDDEN_CLASSIFICATIONS)
    found_paths = {row.path for row in rows}
    for stale_path in sorted(known_paths - found_paths):
        findings.append(Finding(stale_path, "classification table references a path without a current direct-write marker"))

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

    return {
        "status": "red" if findings else "yellow",
        "proofStatus": "Implemented Yellow",
        "directWriteMarkerCount": len(rows),
        "classificationCounts": dict(sorted(classification_counts.items())),
        "markerCounts": dict(sorted(marker_counts.items())),
        "findingCount": len(findings),
    }


def run_self_test() -> int:
    assert classify("Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandJournal.swift")[0] == CANONICAL_CLASSIFICATION
    assert classify("Native/Ambitions/Core/Persistence/SwiftDataRepositories.swift")[0] == UNSAFE_CLASSIFICATION
    assert classify("Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift")[0] == ADAPTER_CLASSIFICATION
    assert classify("Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift")[0] == PROJECTION_CLASSIFICATION
    assert classify("Native/Ambitions/PreviewSupport/PreviewAppContainer.swift")[0] == UNKNOWN_CLASSIFICATION
    assert classify("Native/Ambitions/Core/Domain/NewDirectStore.swift")[1] == ""
    assert "SwiftData" in direct_write_markers("import SwiftData\n")
    assert "write_call" in direct_write_markers("try data.write(to: url)")
    print("ambitions-runtime-direct-write-audit self-test passed")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Classify Ambitions runtime direct-write markers.")
    parser.add_argument("--json", action="store_true", help="Emit JSON.")
    parser.add_argument("--self-test", action="store_true", help="Run script self-tests.")
    args = parser.parse_args()

    if args.self_test:
        return run_self_test()

    rows = audit_rows()
    findings = findings_for(rows, map_text())
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
            print("YELLOW all current direct-write markers are classified; unsafe/unknown rows remain follow-up debt")

    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
