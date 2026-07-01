#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable


ROOT = Path(__file__).resolve().parents[1]
ARCHITECTURE_INVENTORY = ROOT / "scripts" / "ambitions-architecture-inventory.py"
IMPLEMENTATION_TRUTH = ROOT / "docs" / "truth" / "IMPLEMENTATION_TRUTH.md"
PRODUCT_DESIGN_TRUTH = ROOT / "docs" / "truth" / "PRODUCT_DESIGN_TRUTH.md"

LOCAL_RUNTIME_ROOT = ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS"
PRODUCTION_SWIFT_ROOTS = [
    ROOT / "Native" / "Ambitions",
    ROOT / "Native" / "AmbitionsWidgetExtension",
    ROOT / "Native" / "AmbitionsShareExtension",
]

REQUIRED_LOCAL_RUNTIME_OWNERS = [
    "RuntimeBoundary",
    "CommandSpine",
    "TransactionKernel",
    "EventJournal",
    "ObjectState",
    "ProjectionEngine",
    "PrivateLifeRuntimeKernel",
    "PlanningEngine",
    "TimeEngine",
    "CaptureRouteGraph",
    "TrustSystem",
    "SearchRecall",
    "SideEffectSystem",
    "SyncContinuity",
    "SourceAtlas",
    "PrivacySecurity",
    "Storage",
    "MigrationRepair",
    "Diagnostics",
]

INTEGRATION_MARKERS = {
    "command_journal_live_wiring": {
        "path": "Native/Ambitions/App/AppContainerFactory.swift",
        "markers": [
            "AmbitionsCommandExecutor",
            "commandJournal",
            "runtimeEventStore",
            "FileCommandJournal.defaultLiveStore",
            "EventStoreSQLite.defaultLiveStore",
        ],
    },
    "runtime_event_sqlite_live_authority": {
        "path": "Native/Ambitions/App/AppContainerFactory.swift",
        "markers": [
            "return EventStoreSQLite.defaultLiveStore()",
            "return InMemoryRuntimeEventStore()",
        ],
    },
    "command_journal_runtime_linkage": {
        "path": "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandJournal.swift",
        "markers": [
            "CommandJournalRuntimeLink",
            "linkRuntimeCommit",
            "runtimeEventID",
            "runtimeReceiptID",
        ],
    },
    "command_event_reconciliation_diagnostics": {
        "path": "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/CommandInspector.swift",
        "markers": [
            "inspectJournalLinkage",
            "command.event_without_journal",
            "command.event_missing_journal_reference",
            "command.journal_link_missing_event",
        ],
    },
    "runtime_doctor_replay_repair": {
        "path": "Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RuntimeDoctor.swift",
        "markers": [
            "replay_repair_required",
            "command_record_missing_runtime_event",
            "runtime_event_missing_command_record",
            "commandEventReplayIssues",
        ],
    },
    "today_command_append_before_mutation": {
        "path": "Native/Ambitions/Interaction/TodayCommandActionHandler.swift",
        "markers": [
            "RuntimeEventCommandReplayAdapter",
            "commandJournal.append",
            "persistCommandExecution",
            "RuntimeTransactionCommitPolicy.resultByCommittingRuntimeTransaction",
            "runtimeTransactionIdempotencyStore",
            "CommandJournalAppendReceipt",
        ],
    },
    "transaction_event_projection_commit": {
        "path": "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeTransactionCoordinator.swift",
        "markers": [
            "RuntimeEventStore",
            "ProjectionMaterializer",
            "RuntimeCommitReceipt",
            "RuntimeRollbackPlan",
            "RuntimeIdempotencyStore",
        ],
    },
    "search_rebuild_from_runtime_events": {
        "path": "Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/SearchRebuildPipeline.swift",
        "markers": [
            "RuntimeEventStore",
            "ProjectionMaterializer",
            "SearchRebuildReceipt",
        ],
    },
    "app_intent_bridge_outbox_owner": {
        "path": "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/AppIntentBridge.swift",
        "markers": [
            "SideEffectOutboxRequest",
            "SideEffectOutboxing",
            "enqueueExternalCreation",
        ],
    },
}

MUTATION_PATTERNS = [
    (
        "today-direct-action-closure-service",
        re.compile(r"\bservice\.recordActionClosure\s*\("),
        "Today action closure writes through a service call; LocalRuntimeProof requires command-spine coverage for the mutation.",
    ),
    (
        "today-direct-recommendation-rejection-service",
        re.compile(r"\bservice\.recordRecommendationRejection\s*\("),
        "Today recommendation rejection writes through a service call; LocalRuntimeProof requires command-spine coverage for the mutation.",
    ),
    (
        "surface-viewmodel-save",
        re.compile(r"\bviewModel\.save\s*\("),
        "Surface save call must compile into a command before object-state mutation.",
    ),
    (
        "repository-save-outside-runtime-spine",
        re.compile(r"\b[A-Za-z0-9_]*(?:Repository|repository)\.save\s*\("),
        "Repository save outside a sanctioned runtime reducer/object-state adapter is a mutation-spine bypass candidate.",
    ),
    (
        "repository-create-update-delete-outside-runtime-spine",
        re.compile(r"\b[A-Za-z0-9_]*(?:Repository|repository)\.(?:create|update|delete|archive|persist|upsert|record)\s*\("),
        "Repository mutation outside a sanctioned runtime reducer/object-state adapter is a mutation-spine bypass candidate.",
    ),
    (
        "share-extension-direct-append",
        re.compile(r"\bstore\.append\s*\(\s*request\s*\)"),
        "Share extension intake append must be proven through SideEffectSystem/ShareExtensionIntake.",
    ),
    (
        "app-intent-nil-outbox-recorder",
        re.compile(r"AppIntentBridge\s*\(\s*recorder:\s*nil"),
        "App Intent bridge creation without a durable outbox recorder blocks app-wide side-effect proof.",
    ),
    (
        "eventkit-direct-save",
        re.compile(r"\btry\s+store\.save\s*\("),
        "EventKit writes must be separated behind the EventKitOutbox with local commit proof before external effect.",
    ),
    (
        "swiftdata-direct-context-mutation",
        re.compile(r"\b(?:modelContext|context)\.(?:insert|delete|save)\s*\("),
        "SwiftData context mutation outside LocalRuntimeOS storage/object-state owners blocks app-wide command-only proof.",
    ),
]

MUTATION_SCAN_EXCLUDED_PREFIXES = [
    "Native/Ambitions/Core/LocalRuntimeOS/",
    "Native/Ambitions/Core/Persistence/",
    "Native/Ambitions/Core/Domain/",
    "Native/Ambitions/PreviewSupport/",
]

MUTATION_SCAN_INCLUDED_PREFIXES = [
    "Native/Ambitions/App/",
    "Native/Ambitions/Stage/",
    "Native/Ambitions/Surfaces/",
    "Native/Ambitions/Composer/",
    "Native/Ambitions/Interaction/",
    "Native/Ambitions/Projection/",
    "Native/Ambitions/Core/Permissions/",
    "Native/AmbitionsWidgetExtension/",
    "Native/AmbitionsShareExtension/",
]

RUNTIME_EVENT_APPEND_ALLOWED_PATHS = {
    "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeTransactionCoordinator.swift",
}

PROJECTION_MATERIALIZATION_ALLOWED_PATHS = {
    "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeTransactionCoordinator.swift",
    "Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/SearchRebuildPipeline.swift",
}

RUNTIME_MUTATION_CONTEXT_PATH = "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeMutationContext.swift"
RUNTIME_TRANSACTION_PATH = "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeTransaction.swift"
OBJECT_STATE_CORE_PATH = "Native/Ambitions/Core/LocalRuntimeOS/ObjectState/ObjectStateCore.swift"
OBJECT_STATE_CONTRACTS_PATH = "Native/Ambitions/Core/LocalRuntimeOS/ObjectState/ObjectStateContracts.swift"
APP_STATE_STORE_PATH = "Native/Ambitions/Core/LocalRuntimeOS/ObjectState/AppStateStore.swift"
FEATURE_SERVICE_MUTATION_AUTHORITY_PATH = "docs/qa/local-runtime-proof/feature-service-mutation-authority.json"

SERVICE_MUTATION_CALL_PATTERN = re.compile(
    r"\b((?:repositories\.[A-Za-z0-9_]+|[A-Za-z0-9_]*(?:Repository|repository)|repository|"
    r"eventLedger|reminderRepository|appStateRepository|capturePromotionUnitOfWork)"
    r"\.(?:save[A-Za-z0-9_]*|append|create|update|delete|archive|persist|upsert|record[A-Za-z0-9_]*))\s*\("
)

TRUTH_GAP_PATTERNS = [
    (
        "truth-declares-localruntimeos-incomplete",
        "does not prove the full local runtime OS until later implementation trains",
    ),
    (
        "truth-declares-command-spine-not-app-wide",
        "does not prove app-wide command-only mutation",
    ),
    (
        "truth-declares-unsupported-all-mutations-claim",
        "all meaningful state changes route only through `Command -> Event -> Projection -> Receipt -> Replay`",
    ),
]


@dataclass(frozen=True)
class Finding:
    severity: str
    code: str
    path: str
    line: int | None
    message: str


@dataclass(frozen=True)
class CheckResult:
    check_id: str
    status: str
    summary: str
    findings: list[Finding]


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def production_swift_files() -> list[Path]:
    files: list[Path] = []
    ignored_parts = {".build", "DerivedData", "Resources", "PreviewSupport", "Previews"}
    for source_root in PRODUCTION_SWIFT_ROOTS:
        if not source_root.exists():
            continue
        for path in source_root.rglob("*.swift"):
            parts = set(path.relative_to(ROOT).parts)
            if parts & ignored_parts:
                continue
            files.append(path)
    return sorted(files)


def is_included_mutation_scan_path(path: Path) -> bool:
    rel = relative(path)
    if any(rel.startswith(prefix) for prefix in MUTATION_SCAN_EXCLUDED_PREFIXES):
        return False
    return any(rel.startswith(prefix) for prefix in MUTATION_SCAN_INCLUDED_PREFIXES)


def make_result(check_id: str, findings: list[Finding], pass_summary: str, fail_summary: str) -> CheckResult:
    blockers = [finding for finding in findings if finding.severity == "blocker"]
    warnings = [finding for finding in findings if finding.severity == "warning"]
    if blockers:
        return CheckResult(check_id, "fail", fail_summary.format(count=len(blockers)), findings)
    if warnings:
        return CheckResult(check_id, "warn", fail_summary.format(count=len(warnings)), findings)
    return CheckResult(check_id, "pass", pass_summary, findings)


def check_architecture_inventory() -> CheckResult:
    if not ARCHITECTURE_INVENTORY.exists():
        return CheckResult(
            "architecture_inventory",
            "fail",
            "Architecture inventory script is missing.",
            [
                Finding(
                    "blocker",
                    "missing-architecture-inventory",
                    relative(ARCHITECTURE_INVENTORY),
                    None,
                    "LocalRuntimeProof requires final architecture inventory as a prerequisite.",
                )
            ],
        )

    completed = subprocess.run(
        [sys.executable, str(ARCHITECTURE_INVENTORY), "--json"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    findings: list[Finding] = []
    if completed.returncode != 0:
        findings.append(
            Finding(
                "blocker",
                "architecture-inventory-red",
                relative(ARCHITECTURE_INVENTORY),
                None,
                completed.stderr.strip() or "Final architecture inventory exited non-zero.",
            )
        )
    else:
        try:
            payload = json.loads(completed.stdout)
        except json.JSONDecodeError as error:
            findings.append(
                Finding(
                    "blocker",
                    "architecture-inventory-invalid-json",
                    relative(ARCHITECTURE_INVENTORY),
                    None,
                    f"Architecture inventory did not emit valid JSON: {error}",
                )
            )
        else:
            summary = payload.get("summary", {})
            if not summary.get("green"):
                findings.append(
                    Finding(
                        "blocker",
                        "architecture-inventory-not-green",
                        relative(ARCHITECTURE_INVENTORY),
                        None,
                        f"Architecture inventory has {summary.get('blocking_entries', 'unknown')} blocking entries.",
                    )
                )

    return make_result(
        "architecture_inventory",
        findings,
        "Final architecture tree source parity is green.",
        "{count} architecture inventory blocker(s) remain.",
    )


def check_owner_directories() -> CheckResult:
    findings: list[Finding] = []
    for owner in REQUIRED_LOCAL_RUNTIME_OWNERS:
        owner_dir = LOCAL_RUNTIME_ROOT / owner
        if not owner_dir.exists():
            findings.append(
                Finding(
                    "blocker",
                    "missing-localruntimeos-owner",
                    relative(owner_dir),
                    None,
                    f"Required LocalRuntimeOS owner `{owner}` is missing.",
                )
            )
            continue
        swift_count = len(list(owner_dir.glob("*.swift")))
        if swift_count == 0:
            findings.append(
                Finding(
                    "blocker",
                    "empty-localruntimeos-owner",
                    relative(owner_dir),
                    None,
                    f"Required LocalRuntimeOS owner `{owner}` has no production Swift files.",
                )
            )
    return make_result(
        "owner_directories",
        findings,
        "All 19 LocalRuntimeOS owners are source-present.",
        "{count} LocalRuntimeOS owner directory blocker(s) remain.",
    )


def check_integration_markers() -> CheckResult:
    findings: list[Finding] = []
    for check_id, spec in INTEGRATION_MARKERS.items():
        path = ROOT / spec["path"]
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    f"{check_id}-missing-file",
                    spec["path"],
                    None,
                    f"Required integration file for `{check_id}` is missing.",
                )
            )
            continue
        text = read_text(path)
        for marker in spec["markers"]:
            if marker not in text:
                findings.append(
                    Finding(
                        "blocker",
                        f"{check_id}-missing-marker",
                        spec["path"],
                        None,
                        f"Missing integration marker `{marker}` for `{check_id}`.",
                    )
                )
    return make_result(
        "integration_markers",
        findings,
        "Core command, event, projection, replay, search, and outbox integration markers are present.",
        "{count} required integration marker blocker(s) remain.",
    )


def check_live_event_store_authority() -> CheckResult:
    path = ROOT / "Native" / "Ambitions" / "App" / "AppContainerFactory.swift"
    findings: list[Finding] = []
    if not path.exists():
        findings.append(
            Finding(
                "blocker",
                "missing-app-container-factory",
                relative(path),
                None,
                "Live runtime event authority cannot be proven without AppContainerFactory source.",
            )
        )
        return make_result(
            "live_event_store_authority",
            findings,
            "Production runtime event authority is SQLite.",
            "{count} live event-store authority blocker(s) remain.",
        )

    lines = read_text(path).splitlines()
    for index, line in enumerate(lines, start=1):
        if "return FileRuntimeEventStore.defaultLiveStore()" in line:
            findings.append(
                Finding(
                    "blocker",
                    "live-runtime-event-authority-jsonl",
                    relative(path),
                    index,
                    "Production runtime event authority must be EventStoreSQLite; JSONL file-backed authority is migration/debug fallback only.",
                )
            )

    text = "\n".join(lines)
    if "return EventStoreSQLite.defaultLiveStore()" not in text:
        findings.append(
            Finding(
                "blocker",
                "live-runtime-event-authority-not-sqlite",
                relative(path),
                None,
                "Persistent AppContainerFactory runtimeEventStore(for:) must select EventStoreSQLite.defaultLiveStore().",
            )
        )
    if "return InMemoryRuntimeEventStore()" not in text:
        findings.append(
            Finding(
                "warning",
                "preview-runtime-event-authority-not-in-memory",
                relative(path),
                None,
                "Preview/demo/test runtime event authority should remain in-memory.",
            )
        )

    return make_result(
        "live_event_store_authority",
        findings,
        "Production runtime event authority is SQLite; JSONL authority is not selected by AppContainerFactory.",
        "{count} live event-store authority blocker(s) remain.",
    )


def check_command_event_reconciliation() -> CheckResult:
    findings: list[Finding] = []
    required_markers = {
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "CommandSpine" / "CommandJournal.swift": [
            "CommandJournalRuntimeLink",
            "CommandJournalRuntimeLinkChecksum",
            "linkRuntimeCommit",
            "runtimeEventID",
            "runtimeReceiptID",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "CommandSpine" / "RuntimeTransactionCommitPolicy.swift": [
            "commandJournal.linkRuntimeCommit",
            "commandJournalRuntimeLinkStatus",
            "linkReceipt.resultMetadata",
            "runtimeMetadata.merge",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Diagnostics" / "CommandInspector.swift": [
            "inspectJournalLinkage",
            "command.event_without_journal",
            "command.event_missing_journal_reference",
            "command.journal_link_missing_event",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "MigrationRepair" / "RuntimeDoctor.swift": [
            "replay_repair_required",
            "command_record_missing_runtime_event",
            "runtime_event_missing_command_record",
            "commandEventReplayIssues",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "EventJournal" / "RuntimeEventCommandReplayAdapter.swift": [
            "RuntimeEventReplay(store: runtimeEvents).replay(commandID: command.id)",
            "commandRecordWithoutRuntimeEvent",
            "runtime_event_missing_for_command_record",
            "runtimeReplayAuthority",
            "repaired_from_runtime_event",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "CommandSpine" / "AmbitionsCommandExecutor.swift": [
            "RuntimeEventCommandReplayAdapter",
            "runtimeEvents: runtimeEvents",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "CommandSpine" / "RuntimeCommandMutationCommitter.swift": [
            "RuntimeEventCommandReplayAdapter",
            "runtimeEvents: runtimeEvents",
        ],
    }
    for path, markers in required_markers.items():
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "command-event-reconciliation-missing-source",
                    relative(path),
                    None,
                    "Command/event reconciliation source is missing.",
                )
            )
            continue
        text = read_text(path)
        for marker in markers:
            if marker not in text:
                findings.append(
                    Finding(
                        "blocker",
                        "command-event-reconciliation-marker-missing",
                        relative(path),
                        None,
                        f"Missing command/event reconciliation marker `{marker}`.",
                    )
                )

    return make_result(
        "command_event_reconciliation",
        findings,
        "Command journal/runtime event linkage and drift diagnostics are present.",
        "{count} command/event reconciliation blocker(s) remain.",
    )


def check_meaningful_mutation_commit_policy() -> CheckResult:
    findings: list[Finding] = []
    required_markers = {
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "CommandSpine" / "RuntimeTransactionCommitPolicy.swift": [
            "RuntimeTransactionCommitPolicy",
            "meaningful_mutation_requires_commit",
            "requiredEvidenceKeys",
            "runtimeRollbackPlanID",
            "runtimeReplayTraceID",
            "resultByCommittingRuntimeTransaction",
            "requiresCommit(command: command, result: result)",
            "failureResult",
            "RuntimeTransactionCoordinator",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "TransactionKernel" / "RuntimeTransactionFailureReceipt.swift": [
            "RuntimeTransactionFailureReceipt",
            "runtime_transaction_failure_receipt.native.v1",
            "runtimeCommitFailureReceiptID",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "CommandSpine" / "AmbitionsCommandExecutor+ReceiptPersistence.swift": [
            "RuntimeTransactionCommitPolicy.resultByCommittingRuntimeTransaction",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "CommandSpine" / "RuntimeCommandMutationCommitter.swift": [
            "RuntimeTransactionCommitPolicy.resultByCommittingRuntimeTransaction",
        ],
        ROOT / "Native" / "Ambitions" / "Interaction" / "TodayCommandActionHandler.swift": [
            "RuntimeTransactionCommitPolicy.resultByCommittingRuntimeTransaction",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "TransactionKernel" / "RuntimeTransaction.swift": [
            "youPreferencesObjectID",
            "updateUserPreferences",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "TransactionKernel" / "RuntimeMutation.swift": [
            "youPreferencesObjectID",
            "updateUserPreferences",
        ],
    }
    for path, markers in required_markers.items():
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "meaningful-mutation-commit-policy-missing-source",
                    relative(path),
                    None,
                    "Meaningful mutation commit policy source is missing.",
                )
            )
            continue
        text = read_text(path)
        for marker in markers:
            if marker not in text:
                findings.append(
                    Finding(
                        "blocker",
                        "meaningful-mutation-commit-policy-marker-missing",
                        relative(path),
                        None,
                        f"Missing meaningful mutation commit-policy marker `{marker}`.",
                    )
                )

    return make_result(
        "meaningful_mutation_commit_policy",
        findings,
        "Meaningful successful mutations require runtime transaction, event, receipt, rollback, and replay evidence or fail closed.",
        "{count} meaningful mutation commit-policy blocker(s) remain.",
    )


def scan_mutation_bypasses() -> CheckResult:
    findings: list[Finding] = []
    for path in production_swift_files():
        if not is_included_mutation_scan_path(path):
            continue
        rel = relative(path)
        lines = read_text(path).splitlines()
        for index, line in enumerate(lines, start=1):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            for code, pattern, message in MUTATION_PATTERNS:
                if pattern.search(stripped):
                    findings.append(Finding("blocker", code, rel, index, message))
    return make_result(
        "mutation_bypass_scan",
        findings,
        "No high-risk mutation or external-write bypass candidates were found.",
        "{count} mutation or external-write bypass candidate(s) block LocalRuntimeProof.",
    )


def load_feature_service_mutation_authority() -> tuple[dict[str, object] | None, dict[tuple[str, str], str], list[Finding]]:
    path = ROOT / FEATURE_SERVICE_MUTATION_AUTHORITY_PATH
    findings: list[Finding] = []
    if not path.exists():
        return None, {}, [
            Finding(
                "blocker",
                "feature-service-mutation-authority-missing",
                FEATURE_SERVICE_MUTATION_AUTHORITY_PATH,
                None,
                "Feature service mutation authority manifest is missing.",
            )
        ]

    try:
        manifest = json.loads(read_text(path))
    except json.JSONDecodeError as error:
        return None, {}, [
            Finding(
                "blocker",
                "feature-service-mutation-authority-invalid-json",
                FEATURE_SERVICE_MUTATION_AUTHORITY_PATH,
                error.lineno,
                f"Feature service mutation authority manifest is invalid JSON: {error.msg}",
            )
        ]

    allowed_pairs: dict[tuple[str, str], str] = {}
    classifications = set(manifest.get("allowedClassifications", []))
    entries = manifest.get("allowedWritePaths", [])
    if not isinstance(entries, list):
        findings.append(
            Finding(
                "blocker",
                "feature-service-mutation-authority-invalid-shape",
                FEATURE_SERVICE_MUTATION_AUTHORITY_PATH,
                None,
                "Feature service mutation authority manifest must contain allowedWritePaths.",
            )
        )
        return manifest, allowed_pairs, findings

    for entry in entries:
        if not isinstance(entry, dict):
            findings.append(
                Finding(
                    "blocker",
                    "feature-service-mutation-authority-invalid-entry",
                    FEATURE_SERVICE_MUTATION_AUTHORITY_PATH,
                    None,
                    "Feature service mutation authority entries must be objects.",
                )
            )
            continue
        rel = entry.get("path")
        classification = entry.get("classification")
        calls = entry.get("allowedCalls", [])
        if not isinstance(rel, str) or not isinstance(classification, str) or not isinstance(calls, list):
            findings.append(
                Finding(
                    "blocker",
                    "feature-service-mutation-authority-invalid-entry",
                    FEATURE_SERVICE_MUTATION_AUTHORITY_PATH,
                    None,
                    "Each mutation authority entry must include path, classification, and allowedCalls.",
                )
            )
            continue
        if classification not in classifications:
            findings.append(
                Finding(
                    "blocker",
                    "feature-service-mutation-authority-invalid-classification",
                    rel,
                    None,
                    f"Unknown feature service mutation classification `{classification}`.",
                )
            )
        source_path = ROOT / rel
        if not source_path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "feature-service-mutation-authority-stale-path",
                    rel,
                    None,
                    "Feature service mutation authority entry points at a missing source file.",
                )
            )
            continue
        source = read_text(source_path)
        for call in calls:
            if not isinstance(call, str):
                findings.append(
                    Finding(
                        "blocker",
                        "feature-service-mutation-authority-invalid-call",
                        rel,
                        None,
                        "Feature service mutation authority allowedCalls entries must be strings.",
                    )
                )
                continue
            allowed_pairs[(rel, call)] = classification
            if f"{call}(" not in source:
                findings.append(
                    Finding(
                        "blocker",
                        "feature-service-mutation-authority-stale-call",
                        rel,
                        None,
                        f"Feature service mutation authority allows `{call}`, but the call is not present.",
                    )
                )
    return manifest, allowed_pairs, findings


def scan_feature_service_mutation_authority() -> CheckResult:
    manifest, allowed_pairs, findings = load_feature_service_mutation_authority()
    if manifest is None:
        return make_result(
            "feature_service_mutation_authority",
            findings,
            "Feature service mutation authority manifest is present.",
            "{count} feature service mutation authority blocker(s) remain.",
        )

    prefixes = manifest.get("scanIncludedPrefixes", [])
    if not isinstance(prefixes, list) or not all(isinstance(prefix, str) for prefix in prefixes):
        findings.append(
            Finding(
                "blocker",
                "feature-service-mutation-authority-invalid-prefixes",
                FEATURE_SERVICE_MUTATION_AUTHORITY_PATH,
                None,
                "Feature service mutation authority manifest must contain string scanIncludedPrefixes.",
            )
        )
        prefixes = []

    for path in production_swift_files():
        rel = relative(path)
        if not any(rel.startswith(prefix) for prefix in prefixes):
            continue
        lines = read_text(path).splitlines()
        for index, line in enumerate(lines, start=1):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            for match in SERVICE_MUTATION_CALL_PATTERN.finditer(stripped):
                call = match.group(1)
                if (rel, call) in allowed_pairs:
                    continue
                findings.append(
                    Finding(
                        "blocker",
                        "feature-service-unclassified-mutation-write",
                        rel,
                        index,
                        f"Feature/service write `{call}` must be command-owned, transaction-owned, migration-owned, test-only, or explicitly non-canonical.",
                    )
                )

    return make_result(
        "feature_service_mutation_authority",
        findings,
        "Feature/service repository writes are classified as command-owned, transaction-owned, test-only, migration-owned, or explicitly non-canonical.",
        "{count} feature service mutation authority blocker(s) remain.",
    )


def check_transaction_coordinator_commit_ownership() -> CheckResult:
    findings: list[Finding] = []
    for path in production_swift_files():
        rel = relative(path)
        lines = read_text(path).splitlines()
        for index, line in enumerate(lines, start=1):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            if ("runtimeEvents.append(" in stripped or "eventStore.append(" in stripped) and rel not in RUNTIME_EVENT_APPEND_ALLOWED_PATHS:
                findings.append(
                    Finding(
                        "blocker",
                        "runtime-event-append-outside-coordinator",
                        rel,
                        index,
                        "Meaningful runtime event appends must be owned by RuntimeTransactionCoordinator.",
                    )
                )
            if (
                "ProjectionMaterializer(store:" in stripped or ".materializeAll(" in stripped
            ) and rel not in PROJECTION_MATERIALIZATION_ALLOWED_PATHS:
                findings.append(
                    Finding(
                        "blocker",
                        "projection-materialization-outside-approved-owner",
                        rel,
                        index,
                        "Projection materialization for mutation commits must be owned by RuntimeTransactionCoordinator; SearchRecall may rebuild from runtime events.",
                    )
                )
    return make_result(
        "transaction_coordinator_commit_ownership",
        findings,
        "Runtime event append and projection materialization ownership is restricted to the coordinator and approved rebuild path.",
        "{count} transaction coordinator ownership blocker(s) remain.",
    )


def check_runtime_mutation_context_boundaries() -> CheckResult:
    findings: list[Finding] = []
    required_markers = {
        ROOT / RUNTIME_MUTATION_CONTEXT_PATH: [
            "runtimeMutationContextSchemaVersion",
            "struct RuntimeMutationContext",
            "let commandID: String",
            "let transactionID: String",
            "let eventID: String",
            "let projectionID: ProjectionID",
            "let projectionPlan: [ProjectionID]",
            "let receiptID: String",
            "let replayTraceID: String",
            "let rollbackPlanID: String",
            "fileprivate init(",
            "extension RuntimeTransactionCoordinator",
            "func issueMutationContext(",
            "projectionPlan.contains(projectionID)",
            "RuntimeMutationContextIssuanceError",
            "func validated(for expectedFamily: ObjectStateFamily) throws",
        ],
        ROOT / RUNTIME_TRANSACTION_PATH: [
            "static let appStateObjectID = AppStateSnapshot.default.id",
            "objectIDs.append(appStateObjectID)",
            "families.append(.appState)",
        ],
        ROOT / OBJECT_STATE_CORE_PATH: [
            "ObjectStateWriteReceipt",
            "context: RuntimeMutationContext",
            "try context.validated(for: identity.family)",
        ],
        ROOT / OBJECT_STATE_CONTRACTS_PATH: [
            "protocol ObjectStateReadableStore",
            "protocol RuntimeObjectStateWritableStore",
            "func save(_ object: StoredObject, context: RuntimeMutationContext) async throws -> ObjectStateWriteReceipt",
            "protocol AppStateStore: RuntimeObjectStateWritableStore",
        ],
        ROOT / APP_STATE_STORE_PATH: [
            "struct SwiftDataAppStateStore: AppStateStore",
            "context: RuntimeMutationContext",
            "ObjectStateWriteReceipt",
        ],
    }
    for path, markers in required_markers.items():
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "runtime-mutation-context-missing-source",
                    relative(path),
                    None,
                    "RuntimeMutationContext boundary source is missing.",
                )
            )
            continue
        text = read_text(path)
        for marker in markers:
            if marker not in text:
                findings.append(
                    Finding(
                        "blocker",
                        "runtime-mutation-context-marker-missing",
                        relative(path),
                        None,
                        f"Missing RuntimeMutationContext boundary marker `{marker}`.",
                    )
                )

    object_state_core = ROOT / OBJECT_STATE_CORE_PATH
    if object_state_core.exists() and "struct RuntimeObjectStateMutationContext" in read_text(object_state_core):
        findings.append(
            Finding(
                "blocker",
                "legacy-object-state-context-still-owned-by-object-state",
                OBJECT_STATE_CORE_PATH,
                None,
                "RuntimeMutationContext must be owned by TransactionKernel, not ObjectState.",
            )
        )

    for path in production_swift_files():
        rel = relative(path)
        if rel == RUNTIME_MUTATION_CONTEXT_PATH:
            continue
        text = read_text(path)
        if "RuntimeObjectStateMutationContext" in text:
            findings.append(
                Finding(
                    "blocker",
                    "legacy-runtime-object-state-context-reference",
                    rel,
                    None,
                    "Production code must use RuntimeMutationContext for canonical object-state writes.",
                )
            )
        if "RuntimeMutationContext(" in text:
            findings.append(
                Finding(
                    "blocker",
                    "runtime-mutation-context-direct-construction",
                    rel,
                    None,
                    "Production code must obtain RuntimeMutationContext from RuntimeTransactionCoordinator.",
                )
            )

    return make_result(
        "runtime_mutation_context_boundaries",
        findings,
        "Canonical object-state write repositories require coordinator-issued TransactionKernel RuntimeMutationContext.",
        "{count} runtime mutation context boundary blocker(s) remain.",
    )


def check_truth_file_gaps() -> CheckResult:
    findings: list[Finding] = []
    truth_files = [IMPLEMENTATION_TRUTH, PRODUCT_DESIGN_TRUTH]
    for path in truth_files:
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "missing-truth-file",
                    relative(path),
                    None,
                    "Required truth file is missing.",
                )
            )
            continue
        text = read_text(path)
        lines = text.splitlines()
        for code, phrase in TRUTH_GAP_PATTERNS:
            if phrase not in text:
                continue
            line_number = next((idx for idx, line in enumerate(lines, start=1) if phrase in line), None)
            findings.append(
                Finding(
                    "blocker",
                    code,
                    relative(path),
                    line_number,
                    f"Truth file still declares this LocalRuntimeOS proof gap: {phrase}",
                )
            )
    return make_result(
        "truth_file_no_claim_gaps",
        findings,
        "Truth files no longer contain LocalRuntimeOS no-claim blockers.",
        "{count} truth-file no-claim blocker(s) remain.",
    )


def run_checks() -> list[CheckResult]:
    return [
        check_architecture_inventory(),
        check_owner_directories(),
        check_integration_markers(),
        check_live_event_store_authority(),
        check_command_event_reconciliation(),
        check_meaningful_mutation_commit_policy(),
        check_transaction_coordinator_commit_ownership(),
        check_runtime_mutation_context_boundaries(),
        scan_mutation_bypasses(),
        scan_feature_service_mutation_authority(),
        check_truth_file_gaps(),
    ]


def build_payload(results: list[CheckResult]) -> dict[str, object]:
    blockers = [
        finding
        for result in results
        for finding in result.findings
        if finding.severity == "blocker"
    ]
    warnings = [
        finding
        for result in results
        for finding in result.findings
        if finding.severity == "warning"
    ]
    status = "green" if not blockers else "red"
    return {
        "generatedAt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "status": status,
        "runtimeLaw": "Command -> Event -> Projection -> Receipt -> Replay",
        "summary": {
            "checks": len(results),
            "passed": sum(1 for result in results if result.status == "pass"),
            "warnings": len(warnings),
            "blockers": len(blockers),
            "green": status == "green",
        },
        "checks": [
            {
                "checkId": result.check_id,
                "status": result.status,
                "summary": result.summary,
                "findings": [asdict(finding) for finding in result.findings],
            }
            for result in results
        ],
        "allowedClaims": [
            "LocalRuntimeOS source-present owner inventory can be reported when architecture_inventory passes.",
            "LocalRuntimeProof Green can be claimed only when this gate is green and current focused runtime tests also pass.",
        ],
        "blockedClaims": [
            "all meaningful Ambitions state changes route only through Command -> Event -> Projection -> Receipt -> Replay",
            "LocalRuntimeOS is complete",
            "app-wide command-only mutation is proven",
            "app-wide event replay and projection consumption are proven",
            "full side-effect outbox enforcement is proven",
            "privacy/legal, Visual Green, Release Green, TestFlight, or App Store readiness",
        ],
    }


def render_markdown(payload: dict[str, object]) -> str:
    summary = payload["summary"]
    assert isinstance(summary, dict)
    lines = [
        "# LocalRuntimeProof Gate",
        "",
        f"Generated: `{payload['generatedAt']}`",
        f"Status: `{payload['status']}`",
        f"Runtime law: `{payload['runtimeLaw']}`",
        "",
        "This artifact is a runtime-proof gate. It is not Visual Green, Release Green, privacy/legal approval, TestFlight readiness, or App Store readiness.",
        "",
        "## Summary",
        "",
        f"- Checks: `{summary['checks']}`",
        f"- Passed: `{summary['passed']}`",
        f"- Warnings: `{summary['warnings']}`",
        f"- Blockers: `{summary['blockers']}`",
        "",
        "## Checks",
        "",
    ]

    checks = payload["checks"]
    assert isinstance(checks, list)
    for check in checks:
        assert isinstance(check, dict)
        lines.append(f"### {check['checkId']}")
        lines.append("")
        lines.append(f"- Status: `{check['status']}`")
        lines.append(f"- Summary: {check['summary']}")
        findings = check["findings"]
        assert isinstance(findings, list)
        if findings:
            lines.append("")
            lines.append("| Severity | Code | Path | Line | Message |")
            lines.append("| -- | -- | -- | -- | -- |")
            for finding in findings:
                assert isinstance(finding, dict)
                line = "" if finding["line"] is None else str(finding["line"])
                lines.append(
                    "| {severity} | `{code}` | `{path}` | {line} | {message} |".format(
                        severity=finding["severity"],
                        code=finding["code"],
                        path=finding["path"],
                        line=line,
                        message=str(finding["message"]).replace("|", "\\|"),
                    )
                )
        lines.append("")

    lines.append("## Allowed Claims")
    lines.append("")
    for claim in payload["allowedClaims"]:
        lines.append(f"- {claim}")
    lines.append("")
    lines.append("## Blocked Claims")
    lines.append("")
    for claim in payload["blockedClaims"]:
        lines.append(f"- {claim}")
    lines.append("")
    return "\n".join(lines)


def write_output(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")


def run_self_test() -> int:
    sample = "try await historyRepository.save([record])"
    assert MUTATION_PATTERNS[3][1].search(sample)
    assert is_included_mutation_scan_path(ROOT / "Native" / "Ambitions" / "Surfaces" / "You" / "YouSurface.swift")
    assert not is_included_mutation_scan_path(ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Storage" / "ObjectStoreSwiftData.swift")
    assert "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeTransactionCoordinator.swift" in RUNTIME_EVENT_APPEND_ALLOWED_PATHS
    assert "Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/SearchRebuildPipeline.swift" in PROJECTION_MATERIALIZATION_ALLOWED_PATHS
    assert RUNTIME_MUTATION_CONTEXT_PATH.endswith("TransactionKernel/RuntimeMutationContext.swift")
    service_write = "try await repositories.goals.saveGoals([goal])"
    service_match = SERVICE_MUTATION_CALL_PATTERN.search(service_write)
    assert service_match is not None
    assert service_match.group(1) == "repositories.goals.saveGoals"
    result = make_result(
        "fixture",
        [Finding("blocker", "fixture-blocker", "Fixture.swift", 1, "Fixture blocker.")],
        "pass",
        "{count} blocker(s) remain.",
    )
    assert result.status == "fail"
    payload = build_payload([result])
    assert payload["status"] == "red"
    assert "fixture-blocker" in render_markdown(payload)
    print("ambitions-local-runtime-proof self-test passed")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Ambitions LocalRuntimeProof gate.")
    parser.add_argument("--json", action="store_true", help="Print JSON output.")
    parser.add_argument("--markdown", action="store_true", help="Print Markdown output.")
    parser.add_argument("--write-json", type=Path, help="Write JSON output to a file.")
    parser.add_argument("--write-markdown", type=Path, help="Write Markdown output to a file.")
    parser.add_argument("--audit-only", action="store_true", help="Exit 0 even when the gate is red.")
    parser.add_argument("--self-test", action="store_true", help="Run script self-tests.")
    args = parser.parse_args()

    if args.self_test:
        return run_self_test()

    results = run_checks()
    payload = build_payload(results)
    markdown = render_markdown(payload)

    if args.write_json:
        write_output(args.write_json, json.dumps(payload, indent=2, sort_keys=True))
    if args.write_markdown:
        write_output(args.write_markdown, markdown)

    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
    elif args.markdown:
        print(markdown)
    else:
        summary = payload["summary"]
        assert isinstance(summary, dict)
        print("ambitions-local-runtime-proof")
        print(f"status={payload['status']}")
        print(f"checks={summary['checks']}")
        print(f"passed={summary['passed']}")
        print(f"warnings={summary['warnings']}")
        print(f"blockers={summary['blockers']}")
        print("GREEN LocalRuntimeProof achieved" if payload["status"] == "green" else "RED LocalRuntimeProof blocked")

    if payload["status"] == "green" or args.audit_only:
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
