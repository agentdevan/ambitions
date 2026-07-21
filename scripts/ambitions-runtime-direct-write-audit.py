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
import tempfile
from dataclasses import asdict, dataclass
from pathlib import Path

from meaningful_mutation_registry import (
    KNOWN_STATUSES,
    POSITIVE_STATUSES,
    RegistryIssue,
    parse_registry,
    parse_registry_file,
)


ROOT = Path(__file__).resolve().parents[1]
AUTHORITY_MAP = ROOT / "docs" / "audits" / "runtime-authority-map.md"
MUTATION_REGISTRY = ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Commands" / "MeaningfulMutationRegistry.swift"

PRODUCTION_SWIFT_ROOTS = (
    "Native/Ambitions/",
    "Native/AmbitionsWidgetExtension/",
    "Native/AmbitionsShareExtension/",
    "Packages/AmbitionsDesignSystem/Sources/",
    "Packages/AmbitionsDesignSystem/AppUI/Sources/",
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
    proof_test_ids: tuple[str, ...]
    rationale: str


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


def load_registry() -> tuple[dict[str, RegistryWritePath], set[str], list[Finding]]:
    if not MUTATION_REGISTRY.exists():
        return {}, set(), [Finding(rel(MUTATION_REGISTRY), "meaningful mutation registry is missing")]

    inventory = parse_registry_file(MUTATION_REGISTRY)
    rows: dict[str, RegistryWritePath] = {}
    findings = [Finding(rel(MUTATION_REGISTRY), f"line {issue.line}: {issue.message}") for issue in inventory.issues]
    for registry_row in inventory.write_paths:
        path = registry_row.source_path
        status = registry_row.status
        if not path or status not in REGISTRY_STATUS_CLASSIFICATIONS:
            continue
        if path in rows:
            findings.append(Finding(path, "meaningful mutation registry contains a duplicate write-path row"))
            continue
        rows[path] = RegistryWritePath(path, status, tuple(registry_row.proof_test_ids), registry_row.rationale)

    if not rows:
        findings.append(Finding(rel(MUTATION_REGISTRY), "meaningful mutation registry has no write-path rows"))
    for registry_row in inventory.mutations:
        if registry_row.status not in POSITIVE_STATUSES:
            continue
        for proof_test_id in [registry_row.replay_test_id, *registry_row.proof_test_ids]:
            if "MeaningfulMutationRegistryTests" in proof_test_id:
                findings.append(Finding(registry_row.source_path, "inventory/governance tests cannot prove positive executable mutation lineage"))
            elif not proof_test_is_executable(proof_test_id):
                findings.append(Finding(registry_row.source_path, f"registry proof test `{proof_test_id}` is not executable in AmbitionsTests"))
    mutation_sources = {row.source_path for row in inventory.mutations if row.source_path}
    return rows, mutation_sources, findings


def proof_test_is_executable(proof_test_id: str) -> bool:
    parts = proof_test_id.split("/")
    if len(parts) != 3 or parts[0] != "AmbitionsTests":
        return False
    suite, method = parts[1], parts[2]
    tests = ROOT / "Native" / "AmbitionsTests"
    candidates = list(tests.rglob(f"{suite}.swift"))
    return any(re.search(rf"\bfunc\s+{re.escape(method)}\s*\(", path.read_text(encoding="utf-8", errors="replace")) for path in candidates)


SEMANTIC_MUTATION_SINK_PATTERNS = tuple(
    re.compile(pattern)
    for pattern in (
        r"\b(?:commandRouter|commandExecutor|externalActionService|runtimeExecutor|actionExecutor)\.execute\s*\(",
        r"\bTimeFieldMutationCoordinator\(\)\.(?:perform|undo)\s*\(",
        r"\b(?:captureService|service|receiptCommands|preferencesCommands)\.(?:createGoal|createCapture|performAction|submitClarificationAnswer|submitExplainabilityCorrection|saveYouPreferences|makeTimeCalendarAware|updateCaptureState|routeToTimeSeed|markAsWaiting|markAsOptionalSomeday|markAsDeliverableSeed|attachCaptureToGoal|turnCaptureIntoGoal)\s*\(",
        r"\b(?:repositories\.[A-Za-z0-9_]+|repository|appStateRepository|eventLedger|recorder|outbox)\.(?:save[A-Za-z0-9_]*|append|insert|delete|record[A-Za-z0-9_]*|enqueue[A-Za-z0-9_]*)\s*\(",
        r"\b(?:commandJournal|eventStore|runtimeEventStore)\.(?:append|commit)\s*\(",
        r"\.(?:enqueueDurableRequest|enqueueExternalCreation|recordCalendarSideEffect|recordCalendarResult|recordResult)\s*\(",
        r"\b(?:replaceLocalStore|mergeWithConflictReport|importSnapshot)\s*\(",
    )
)

# Discovered candidates may be excluded only when the function is demonstrably
# non-mutating; each exclusion is reviewed as a row with its own rationale.
SEMANTIC_NON_MUTATING_EXCLUSIONS: dict[str, str] = {}


def _swift_code_skip(text: str, index: int) -> int:
    if text.startswith("//", index):
        newline = text.find("\n", index + 2)
        return len(text) if newline == -1 else newline + 1
    if text.startswith("/*", index):
        end = text.find("*/", index + 2)
        return len(text) if end == -1 else end + 2
    if text[index] == '"':
        index += 1
        while index < len(text):
            if text[index] == "\\":
                index += 2
            elif text[index] == '"':
                return index + 1
            else:
                index += 1
        return len(text)
    return index


def _matching_swift_brace(text: str, open_index: int) -> int | None:
    depth = 0
    index = open_index
    while index < len(text):
        skipped = _swift_code_skip(text, index)
        if skipped != index:
            index = skipped
            continue
        if text[index] == "{":
            depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0:
                return index
        index += 1
    return None


def _function_body_open(text: str, start: int) -> int | None:
    parentheses = 0
    index = start
    while index < len(text):
        skipped = _swift_code_skip(text, index)
        if skipped != index:
            index = skipped
            continue
        char = text[index]
        if char == "(":
            parentheses += 1
        elif char == ")":
            parentheses -= 1
        elif char == "{" and parentheses == 0:
            return index
        elif char == "}" and parentheses == 0:
            return None
        index += 1
    return None


def _swift_type_spans(text: str) -> list[tuple[int, int, str]]:
    spans: list[tuple[int, int, str]] = []
    pattern = re.compile(r"\b(?:class|struct|actor|enum|extension)\s+([A-Za-z_][A-Za-z0-9_.]*)[^\{]*\{")
    for match in pattern.finditer(text):
        open_index = text.find("{", match.start())
        close_index = _matching_swift_brace(text, open_index)
        if close_index is not None:
            spans.append((open_index, close_index, match.group(1).split(".")[-1]))
    return spans


def semantic_functions_in_text(text: str) -> set[str]:
    discovered: set[str] = set()
    type_spans = _swift_type_spans(text)
    function_pattern = re.compile(
        r"(?m)^[ \t]*(?P<mods>(?:(?:public|internal|package|private|fileprivate|static|class|nonisolated|mutating|nonmutating|override|final)\s+)*)func\s+(?P<name>[A-Za-z_][A-Za-z0-9_]*)\b"
    )
    for match in function_pattern.finditer(text):
        body_open = _function_body_open(text, match.end())
        if body_open is None:
            continue
        body_close = _matching_swift_brace(text, body_open)
        if body_close is None:
            continue
        owners = [span for span in type_spans if span[0] < match.start() < span[1]]
        if not owners:
            continue
        owner = min(owners, key=lambda span: span[1] - span[0])[2]
        body = text[body_open + 1:body_close]
        if any(pattern.search(body) for pattern in SEMANTIC_MUTATION_SINK_PATTERNS):
            discovered.add(f"{owner}.{match.group('name')}")
    return discovered


def production_swift_scan_roots() -> tuple[Path, ...]:
    return tuple(ROOT / prefix.rstrip("/") for prefix in PRODUCTION_SWIFT_ROOTS)


def discover_semantic_entry_points(
    scan_roots: tuple[Path, ...] | None = None,
    *,
    enforce_production_scope: bool = True,
) -> set[str]:
    if scan_roots is None:
        scan_roots = production_swift_scan_roots()
    discovered: set[str] = set()
    seen: set[Path] = set()
    for root in scan_roots:
        if not root.exists():
            continue
        for path in sorted(root.rglob("*.swift")):
            if path in seen or (enforce_production_scope and not is_production_swift(path)):
                continue
            seen.add(path)
            discovered.update(semantic_functions_in_text(path.read_text(encoding="utf-8", errors="replace")))
    return discovered


def semantic_entrypoint_findings(
    discovered: set[str],
    registered: set[str],
    exclusions: dict[str, str] = SEMANTIC_NON_MUTATING_EXCLUSIONS,
) -> list[Finding]:
    findings = [
        Finding(source, "machine-detected semantic mutation entry point is missing from MeaningfulMutationRegistry or the reviewed non-mutating exclusions")
        for source in sorted(discovered - registered - set(exclusions))
    ]
    for source, rationale in sorted(exclusions.items()):
        if not rationale.strip():
            findings.append(Finding(source, "semantic non-mutating exclusion requires a row-specific rationale"))
    return findings


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
    mutation_sources: set[str],
    registry_findings: list[Finding],
) -> list[Finding]:
    findings = list(registry_findings)
    findings.extend(semantic_entrypoint_findings(discover_semantic_entry_points(), mutation_sources))
    for row in rows:
        if row.classification == UNSAFE_CLASSIFICATION:
            findings.append(Finding(row.path, "unsafe production direct-write marker must move under Core/LocalRuntimeOS, become an adapter, or become test-only"))
            continue
        if row.classification == UNKNOWN_CLASSIFICATION:
            findings.append(Finding(row.path, "direct-write marker lacks a semantic mutation-registry row"))
            continue
        registry_row = registry[row.path]
        if registry_row.status in POSITIVE_STATUSES:
            if not registry_row.proof_test_ids:
                findings.append(Finding(row.path, "positive registry status has no row-specific executable proof test ID"))
            for proof_test_id in registry_row.proof_test_ids:
                if "MeaningfulMutationRegistryTests" in proof_test_id:
                    findings.append(Finding(row.path, "inventory/governance tests cannot prove a positive write-path status"))
                elif not proof_test_is_executable(proof_test_id):
                    findings.append(Finding(row.path, f"registry proof test `{proof_test_id}` is not executable in AmbitionsTests"))

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
    valid_fixture = '''
    static let declaredMutationRowCount = 1
    static let declaredWritePathRowCount = 1
    static let descriptors = [
    mutation(
        id: "capture.fixture",
        sourcePath: "CaptureViewModel.fixture",
        commandKind: .quickCapture,
        status: .unproven,
        rationale: "Fixture lacks executable lineage."
    )
    ]
    static let writePaths = [
    writePath(
        sourcePath: "Native/Ambitions/Fixture.swift",
        status: .unproven,
        rationale: "Fixture write is unproven."
    )
    ]
    '''
    parsed = parse_registry(valid_fixture)
    assert not parsed.issues
    assert len(parsed.mutations) == 1 and len(parsed.write_paths) == 1
    assert semantic_entrypoint_findings({"CaptureViewModel.fixture"}, set())
    assert not semantic_entrypoint_findings({"CaptureViewModel.fixture"}, {"CaptureViewModel.fixture"})
    assert production_swift_scan_roots() == tuple(ROOT / prefix.rstrip("/") for prefix in PRODUCTION_SWIFT_ROOTS)
    default_discovered = discover_semantic_entry_points()
    required_production_entries = {
        "TodayCommandActionHandler.performAction",
        "ShareViewController.save",
    }
    assert required_production_entries <= default_discovered
    production_registry = parse_registry_file(MUTATION_REGISTRY)
    assert not production_registry.issues
    registered_production_entries = {row.source_path for row in production_registry.mutations}
    for source in required_production_entries:
        assert semantic_entrypoint_findings({source}, registered_production_entries - {source})
    production_write_paths = {row.source_path: row for row in production_registry.write_paths}
    today_descriptor = next(
        row for row in production_registry.mutations
        if row.fields.get("id") == '"today.goal-step-action"'
    )
    assert today_descriptor.source_path == "SwiftDataTodayGoalStepActionMaterializer.materialize"
    repository_descriptor = next(
        row for row in production_registry.mutations
        if row.fields.get("id") == '"today.goal-step-action.repository-materializer"'
    )
    assert repository_descriptor.source_path == "RepositoryTodayGoalStepActionMaterializer.materialize"
    assert repository_descriptor.status == "projectionOnly"
    assert set(repository_descriptor.proof_test_ids) == {
        "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testEveryHandledKindReopensAndReplaysExactAuthorityOnce",
        "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testDuplicateCompleteCommitsOneSemanticEventAndMaterializesOnce",
        "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testAllHandledKindsProduceDeterministicPlansWithoutPreAuthorityWrites",
        "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testJournalFailureLeavesAllDerivedStoresUnchanged",
    }
    today_projection_path = "Native/Ambitions/Core/LocalRuntimeOS/Storage/TodayGoalStepActionMaterializer.swift"
    today_projection_row = production_write_paths[today_projection_path]
    assert today_projection_row.status == "projectionOnly"
    assert set(today_projection_row.proof_test_ids) == set(today_descriptor.proof_test_ids)
    assert classify(today_projection_path, {
        today_projection_path: RegistryWritePath(
            today_projection_row.source_path,
            today_projection_row.status,
            tuple(today_projection_row.proof_test_ids),
            today_projection_row.rationale,
        )
    })[0] == PROJECTION_CLASSIFICATION
    with tempfile.TemporaryDirectory() as temporary_directory:
        unseen_root = Path(temporary_directory) / "PreviouslyUnseen" / "NestedMutationDirectory"
        unseen_root.mkdir(parents=True)
        unseen_file = unseen_root / "NewSemanticMutation.swift"
        unseen_file.write_text(
            """
            struct NewSemanticMutation {
                func commitPreviouslyUnseenMutation() async {
                    _ = await commandExecutor.execute(command)
                }
            }
            """,
            encoding="utf-8",
        )
        unseen = discover_semantic_entry_points((Path(temporary_directory),), enforce_production_scope=False)
        assert unseen == {"NewSemanticMutation.commitPreviouslyUnseenMutation"}
        assert semantic_entrypoint_findings(unseen, set())
        assert not semantic_entrypoint_findings(unseen, unseen)
        assert not semantic_entrypoint_findings(
            unseen,
            set(),
            {"NewSemanticMutation.commitPreviouslyUnseenMutation": "Fixture is demonstrably non-mutating."},
        )
        assert semantic_entrypoint_findings(unseen, set(), {})
    malformed = valid_fixture.replace('rationale: "Fixture lacks executable lineage."\n    )', 'rationale: "Fixture lacks executable lineage."\n    mutation(')
    assert any(issue.code == "registry-call-unbalanced" for issue in parse_registry(malformed).issues)
    assert any(issue.code == "registry-status-unknown" for issue in parse_registry(valid_fixture.replace(".unproven", ".mystery", 1)).issues)
    assert any(issue.code == "registry-field-missing" for issue in parse_registry(valid_fixture.replace("status: .unproven,", "", 1)).issues)
    assert any(issue.code == "registry-positive-proof-missing" for issue in parse_registry(valid_fixture.replace(".unproven", ".durable", 1)).issues)
    durable_empty_store_fixture = valid_fixture.replace(
        "status: .unproven,",
        '''executorOwner: "FixtureExecutor",
        durableStores: [],
        eventKind: "fixture.event",
        projectionOwner: "FixtureProjection",
        receiptOwner: "FixtureReceiptStore",
        replayTestID: "FixtureTests/testReplay",
        proofTestIDs: ["FixtureTests/testProof"],
        status: .durable,''',
        1,
    )
    assert any(
        issue.code == "registry-positive-proof-missing" and "`durableStores`" in issue.message
        for issue in parse_registry(durable_empty_store_fixture).issues
    )
    assert any(issue.code == "registry-parser-count-loss" for issue in parse_registry(valid_fixture.replace("declaredMutationRowCount = 1", "declaredMutationRowCount = 2")).issues)
    assert proof_test_is_executable("AmbitionsTests/MeaningfulMutationRegistryTests/testRegistryRowsHaveUniqueIdentityExplicitClassificationAndRationale")
    fixture = {
        "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandJournal.swift": RegistryWritePath(
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandJournal.swift",
            "unproven",
            (),
            "Fixture is unproven.",
        )
    }
    assert classify("Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandJournal.swift", fixture)[0] == UNPROVEN_CLASSIFICATION
    assert classify("Native/Ambitions/Core/LocalRuntimeOS/Storage/NewStore.swift", fixture)[0] == UNKNOWN_CLASSIFICATION
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

    registry, mutation_sources, registry_findings = load_registry()
    rows = audit_rows(registry)
    findings = findings_for(rows, map_text(), registry, mutation_sources, registry_findings)
    discovered_semantic_entries = discover_semantic_entry_points()
    summary_payload = summary(rows, findings)
    summary_payload.update(
        {
            "semanticEntryPointCount": len(discovered_semantic_entries),
            "registeredSemanticEntryPointCount": len(discovered_semantic_entries & mutation_sources),
            "excludedSemanticEntryPointCount": len(discovered_semantic_entries & set(SEMANTIC_NON_MUTATING_EXCLUSIONS)),
            "missingSemanticEntryPointCount": len(discovered_semantic_entries - mutation_sources - set(SEMANTIC_NON_MUTATING_EXCLUSIONS)),
        }
    )
    payload = {
        "summary": summary_payload,
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
