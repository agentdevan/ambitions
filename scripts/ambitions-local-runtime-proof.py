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
KNOWN_ISSUES = ROOT / "docs" / "qa" / "KNOWN_ISSUES.md"
PR_REVIEW_WORKFLOW = ROOT / ".github" / "workflows" / "ambitions-pr-review.yml"

LOCAL_RUNTIME_ROOT = ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS"
PRODUCTION_SWIFT_ROOTS = [
    ROOT / "Native" / "Ambitions",
    ROOT / "Native" / "AmbitionsWidgetExtension",
    ROOT / "Native" / "AmbitionsShareExtension",
]

REQUIRED_LOCAL_RUNTIME_OWNERS = [
    "Boundary",
    "Commands",
    "Transactions",
    "EventJournal",
    "State",
    "Projections",
    "PrivateLifeRuntimeKernel",
    "Planning",
    "TimeEngine",
    "CaptureRouteGraph",
    "Inspection",
    "Search",
    "ExternalWrites",
    "SyncContinuity",
    "SourceAtlas",
    "PrivacySecurity",
    "Storage",
    "Repair",
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
        "path": "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandJournal.swift",
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
        "path": "Native/Ambitions/Core/LocalRuntimeOS/Repair/RuntimeDoctor.swift",
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
        "path": "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeTransactionCoordinator.swift",
        "markers": [
            "RuntimeEventStore",
            "ProjectionMaterializer",
            "projectionStore?.saveWithReceipt",
            "searchIndex?.rebuild",
            "RuntimeCommitReceipt",
            "RuntimeRollbackPlan",
            "RuntimeIdempotencyStore",
        ],
    },
    "surface_projection_store_consumption": {
        "path": "Native/Ambitions/Core/LocalRuntimeOS/Projections/ProjectionStoreSurfaceReadAdapter.swift",
        "markers": [
            "ProjectionStoreSurfaceReadAdapter",
            "readToday",
            "readGoals",
            "readTime",
            "readYou",
            "readSearchProjection",
            "ProjectionStoreSurfaceReadStatus",
            ".rebuildInputOnly",
            "projectionStore.fetchRecord(id: projectionID)",
            "searchIndex.search",
        ],
    },
    "search_rebuild_from_runtime_events": {
        "path": "Native/Ambitions/Core/LocalRuntimeOS/Search/SearchRebuildPipeline.swift",
        "markers": [
            "RuntimeEventStore",
            "ProjectionMaterializer",
            "SearchRebuildReceipt",
        ],
    },
    "app_intent_bridge_outbox_owner": {
        "path": "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/AppIntentBridge.swift",
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
        "Today action closure writes through a service call; LocalRuntimeProof requires Commands coverage for the mutation.",
    ),
    (
        "today-direct-recommendation-rejection-service",
        re.compile(r"\bservice\.recordRecommendationRejection\s*\("),
        "Today recommendation rejection writes through a service call; LocalRuntimeProof requires Commands coverage for the mutation.",
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
        "Share extension intake append must be proven through ExternalWrites/ShareExtensionIntake.",
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

EXTERNAL_SURFACE_SCAN_INCLUDED_PREFIXES = [
    "Native/Ambitions/App/Intents/",
    "Native/AmbitionsWidgetExtension/",
    "Native/AmbitionsShareExtension/",
]

EXTERNAL_SURFACE_PRIVATE_GRAPH_READ_PATTERNS = [
    (
        "external-surface-app-repositories-read",
        re.compile(r"\bAppRepositories\b"),
        "External surfaces must not read the app repository bundle or private object graph directly.",
    ),
    (
        "external-surface-goal-repository-read",
        re.compile(r"\bGoalRepository\b|\blistGoals\s*\("),
        "External surfaces must consume sanitized projections or durable intake records, not goals repositories.",
    ),
    (
        "external-surface-capture-repository-read",
        re.compile(r"\bCaptureRepository\b|\blistCaptures\s*\("),
        "External surfaces must consume sanitized projections or durable intake records, not captures repositories.",
    ),
    (
        "external-surface-swiftdata-read",
        re.compile(r"\bSwiftData\b|\bModelContext\b|\bAmbitionsPersistenceStore\b"),
        "External surfaces must not open SwiftData/private persistence directly.",
    ),
    (
        "external-surface-runtime-store-read",
        re.compile(r"\bProjectionStoreSQLite\b|\bEventStoreSQLite\b|\bRuntimeEventStore\b"),
        "Extensions/App Intents must not open LocalRuntimeOS stores directly; app-owned projection writers create sanitized handoff records.",
    ),
]

RUNTIME_EVENT_APPEND_ALLOWED_PATHS = {
    "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeTransactionCoordinator.swift",
}

PROJECTION_MATERIALIZATION_ALLOWED_PATHS = {
    "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeTransactionCoordinator.swift",
    "Native/Ambitions/Core/LocalRuntimeOS/Search/SearchRebuildPipeline.swift",
}

RUNTIME_MUTATION_CONTEXT_PATH = "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeMutationContext.swift"
RUNTIME_TRANSACTION_PATH = "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeTransaction.swift"
OBJECT_STATE_CORE_PATH = "Native/Ambitions/Core/LocalRuntimeOS/State/ObjectStateCore.swift"
OBJECT_STATE_CONTRACTS_PATH = "Native/Ambitions/Core/LocalRuntimeOS/State/ObjectStateContracts.swift"
APP_STATE_STORE_PATH = "Native/Ambitions/Core/LocalRuntimeOS/State/AppStateStore.swift"
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
        "truth-declares-commands-not-app-wide",
        "does not prove app-wide command-only mutation",
    ),
    (
        "truth-declares-unsupported-all-mutations-claim",
        "all meaningful state changes route only through `Command -> Event -> Projection -> Receipt -> Replay`",
    ),
]


@dataclass(frozen=True)
class ChecklistSpec:
    checklist_id: str
    category: str
    title: str
    check_id: str
    requirement: str


LRO_100_CHECKLIST: list[ChecklistSpec] = [
    ChecklistSpec(
        "lro100-01-final-tree-source-parity",
        "architecture",
        "Final Architecture Tree source parity",
        "architecture_inventory",
        "Final architecture inventory must be green before LocalRuntimeProof can claim runtime law coverage.",
    ),
    ChecklistSpec(
        "lro100-02-owner-coverage",
        "architecture",
        "LocalRuntimeOS owner coverage",
        "owner_directories",
        "All 19 LocalRuntimeOS owners must exist with production Swift source.",
    ),
    ChecklistSpec(
        "lro100-03-core-integration",
        "integration",
        "Core runtime integration evidence",
        "integration_markers",
        "Command, event, projection, replay, search, and outbox integration points must be source-present.",
    ),
    ChecklistSpec(
        "lro100-04-event-store-authority",
        "event-store authority",
        "Live event-store authority",
        "live_event_store_authority",
        "Production runtime event authority must be SQLite and must not fall back to JSONL authority.",
    ),
    ChecklistSpec(
        "lro100-05-command-event-reconciliation",
        "command authority",
        "Command journal to RuntimeEvent reconciliation",
        "command_event_reconciliation",
        "Command journal records, RuntimeEvents, receipts, replay, diagnostics, and RuntimeDoctor drift signals must reconcile.",
    ),
    ChecklistSpec(
        "lro100-06-fail-closed-transaction-commit",
        "transaction commit",
        "Fail-closed meaningful mutation commit",
        "meaningful_mutation_commit_policy",
        "Meaningful successful mutations must require transaction, event, projection, receipt, rollback, and replay evidence.",
    ),
    ChecklistSpec(
        "lro100-07-transaction-coordinator-ownership",
        "transaction commit",
        "RuntimeTransactionCoordinator ownership",
        "transaction_coordinator_commit_ownership",
        "Runtime event append and mutation projection materialization must be owned by the transaction coordinator or approved rebuild path.",
    ),
    ChecklistSpec(
        "lro100-08-projection-consumption",
        "projection consumption",
        "ProjectionStore/SearchStore consumption",
        "projection_store_surface_read_gate",
        "Today, Goals, Time, You, Search, and rebuild paths must consume ProjectionStore/SearchStore evidence rather than raw private graph reads.",
    ),
    ChecklistSpec(
        "lro100-09-external-surface-sanitized-reads",
        "projection consumption",
        "Sanitized external-surface reads",
        "external_surface_sanitized_projection_gate",
        "Widgets, App Intents, notifications, and share surfaces must use sanitized projections or durable intake records.",
    ),
    ChecklistSpec(
        "lro100-10-privacy-boundary",
        "privacy",
        "PrivacySecurity external boundary",
        "privacy_security_external_boundary_gate",
        "PrivacySecurity must gate egress, export, diagnostics, external snapshots, App Intent/share bridges, and file protection.",
    ),
    ChecklistSpec(
        "lro100-11-source-atlas-r2-public-only",
        "privacy",
        "Source Atlas/R2 public-only boundary",
        "source_atlas_r2_public_only_gate",
        "Source Atlas/R2 request and cache paths must remain public-reference-only and deny private graph payloads.",
    ),
    ChecklistSpec(
        "lro100-12-sync-non-authority",
        "sync",
        "SyncContinuity non-authority",
        "sync_continuity_backend_authority_gate",
        "SyncContinuity must not become backend authority and must preserve local runtime/projection authority.",
    ),
    ChecklistSpec(
        "lro100-13-capture-durable-intake",
        "command authority",
        "Capture durable intake before promotion",
        "capture_intake_durability_gate",
        "Capture accepted input must be durably journaled before classification, attachment staging, promotion, and restart lookup.",
    ),
    ChecklistSpec(
        "lro100-14-side-effect-receipt-gating",
        "side-effect",
        "Side-effect local commit receipt gating",
        "side_effect_local_commit_receipt_gate",
        "External side effects must require prior local runtime commit receipt evidence.",
    ),
    ChecklistSpec(
        "lro100-15-inspection-lineage",
        "receipt/replay",
        "Inspection runtime lineage",
        "inspection_runtime_lineage_gate",
        "Inspection receipt, proof, undo, audit, source, and history records must carry runtime commit receipt lineage.",
    ),
    ChecklistSpec(
        "lro100-16-runtime-mutation-context",
        "repository boundary",
        "RuntimeMutationContext boundaries",
        "runtime_mutation_context_boundaries",
        "Canonical object-state writes must require coordinator-issued RuntimeMutationContext.",
    ),
    ChecklistSpec(
        "lro100-17-runtime-doctor-drift-repair",
        "RuntimeDoctor",
        "RuntimeDoctor local drift repair previews",
        "runtime_doctor_local_drift_repair_gate",
        "RuntimeDoctor must detect local drift with redacted readers and produce receipt-backed reviewable repair previews.",
    ),
    ChecklistSpec(
        "lro100-18-mutation-bypass-scan",
        "repository boundary",
        "High-risk mutation bypass scan",
        "mutation_bypass_scan",
        "Production surface/app/interaction/extension code must not contain high-risk direct mutation or external-write bypasses.",
    ),
    ChecklistSpec(
        "lro100-19-feature-service-boundary",
        "repository boundary",
        "Feature/service write authority classification",
        "feature_service_mutation_authority",
        "Feature/service repository writes must be command-owned, transaction-owned, migration-owned, test-only, or non-canonical.",
    ),
    ChecklistSpec(
        "lro100-20-proof-ceiling-and-ci",
        "proof/CI",
        "Known Issues, truth, and CI evidence",
        "proof_ceiling_and_ci_evidence",
        "Known Issues/truth files must reflect the proof ceiling, stale runtime-source blockers must be absent, and CI must run LocalRuntimeProof.",
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


def normalize_source_atlas_egress_value(value: str) -> str:
    return value.lower().replace("-", "_").replace(" ", "_").replace(".", "_")


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
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Commands" / "CommandJournal.swift": [
            "CommandJournalRuntimeLink",
            "CommandJournalRuntimeLinkChecksum",
            "linkRuntimeCommit",
            "runtimeEventID",
            "runtimeReceiptID",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Commands" / "RuntimeTransactionCommitPolicy.swift": [
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
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Repair" / "RuntimeDoctor.swift": [
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
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Commands" / "AmbitionsCommandExecutor.swift": [
            "RuntimeEventCommandReplayAdapter",
            "runtimeEvents: runtimeEvents",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Commands" / "RuntimeCommandMutationCommitter.swift": [
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
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Commands" / "RuntimeTransactionCommitPolicy.swift": [
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
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Transactions" / "RuntimeTransactionFailureReceipt.swift": [
            "RuntimeTransactionFailureReceipt",
            "runtime_transaction_failure_receipt.native.v1",
            "runtimeCommitFailureReceiptID",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Commands" / "AmbitionsCommandExecutor+ReceiptPersistence.swift": [
            "RuntimeTransactionCommitPolicy.resultByCommittingRuntimeTransaction",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Commands" / "RuntimeCommandMutationCommitter.swift": [
            "RuntimeTransactionCommitPolicy.resultByCommittingRuntimeTransaction",
        ],
        ROOT / "Native" / "Ambitions" / "Interaction" / "TodayCommandActionHandler.swift": [
            "RuntimeTransactionCommitPolicy.resultByCommittingRuntimeTransaction",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Transactions" / "RuntimeTransaction.swift": [
            "youPreferencesObjectID",
            "updateUserPreferences",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Transactions" / "RuntimeMutation.swift": [
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
                        "Projection materialization for mutation commits must be owned by RuntimeTransactionCoordinator; Search may rebuild from runtime events.",
                    )
                )
    return make_result(
        "transaction_coordinator_commit_ownership",
        findings,
        "Runtime event append and projection materialization ownership is restricted to the coordinator and approved rebuild path.",
        "{count} transaction coordinator ownership blocker(s) remain.",
    )


def check_projection_store_surface_read_gate() -> CheckResult:
    findings: list[Finding] = []
    adapter_path = ROOT / "Native/Ambitions/Core/LocalRuntimeOS/Projections/ProjectionStoreSurfaceReadAdapter.swift"
    if not adapter_path.exists():
        findings.append(
            Finding(
                "blocker",
                "projection-store-surface-adapter-missing",
                relative(adapter_path),
                None,
                "Today, Goals, Time, You, and Search must have a ProjectionStore-backed read adapter.",
            )
        )
    else:
        adapter = read_text(adapter_path)
        required_surface_markers = {
            "today": ["readToday", ".today", "TodayProjection"],
            "goals": ["readGoals", ".goals", "GoalsProjection"],
            "time": ["readTime", ".time", "TimeProjection"],
            "you": ["readYou", ".you", "YouProjection"],
            "search": ["readSearchProjection", ".search", "SearchProjection", "searchIndex.search"],
        }
        for surface, markers in required_surface_markers.items():
            for marker in markers:
                if marker not in adapter:
                    findings.append(
                        Finding(
                            "blocker",
                            "projection-store-surface-read-bypass",
                            relative(adapter_path),
                            None,
                            f"`{surface}` is missing ProjectionStore/SearchStore consumption marker `{marker}`.",
                        )
                    )
        for marker in [
            ".staleProjection",
            ".missingProjection",
            "ProjectionStoreReadRepairReceipt",
            "safeRebuildRequired",
            ".rebuildInputOnly",
        ]:
            if marker not in adapter:
                findings.append(
                    Finding(
                        "blocker",
                        "projection-store-freshness-repair-marker-missing",
                        relative(adapter_path),
                        None,
                        f"ProjectionStore surface reads must expose freshness/rebuild marker `{marker}`.",
                    )
                )

    commit_path = ROOT / "Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeTransactionCommitPolicy.swift"
    commit_text = read_text(commit_path) if commit_path.exists() else ""
    for marker in [
        "projectionStore: ProjectionStoreSQLite?",
        "searchIndex: FTSIndex?",
        "runtimeProjectionStoreStatus",
        "runtimeSearchStoreStatus",
    ]:
        if marker not in commit_text:
            findings.append(
                Finding(
                    "blocker",
                    "projection-store-commit-policy-marker-missing",
                    relative(commit_path),
                    None,
                    f"Command commit policy must expose projection/search commit marker `{marker}`.",
                )
            )

    return make_result(
        "projection_store_surface_read_gate",
        findings,
        "ProjectionStore/SearchStore surface read adapter and command-commit projection persistence markers are present.",
        "{count} ProjectionStore surface-read blocker(s) remain.",
    )


def check_external_surface_sanitized_projection_gate() -> CheckResult:
    findings: list[Finding] = []
    required_markers = {
        ROOT / "Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift": [
            "projectionStore.fetchRecord(id: .widget)",
            "projectionStore.fetchRecord(id: .privacy)",
            "LocalRuntimeStorageCoding.decode(WidgetProjection.self",
            "LocalRuntimeStorageCoding.decode(PrivacyProjection.self",
            "validateExternalSurfacePrivacy(widget: widget, privacy: privacy)",
            "builder.makeSnapshot(widget: widget, privacy: privacy",
            "AppGroupSnapshotRecord(",
            "SharedExternalSnapshotStore.snapshotRecordID",
            "SharedExternalSnapshotStore.snapshotKind",
            "appGroupSnapshotStore.write(record)",
            "privacy.redactionRequiredEventIDs",
        ],
        ROOT / "Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotBuilder.swift": [
            "func makeSnapshot(widget: WidgetProjection, privacy: PrivacyProjection, now: Date)",
            "nextAction: nil",
            "Glance-safe updates only",
        ],
        ROOT / "Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift": [
            "snapshotRecordID",
            "snapshotRecordFileURL",
            "struct SharedExternalSnapshotRecord",
            "payloadChecksum",
            "isSafeForExternalProcess",
            "verifiedPayloadData",
            "SHA256.hash",
        ],
        ROOT / "Native/AmbitionsWidgetExtension/NextStepWidget.swift": [
            "SharedExternalSnapshotStore.snapshotRecordFileURL()",
            "SharedExternalSnapshotRecord.self",
            "record.verifiedPayloadData()",
        ],
        ROOT / "Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift": [
            "SharedExternalSnapshotStore.snapshotRecordFileURL()",
            "SharedExternalSnapshotRecord.self",
            "record.verifiedPayloadData()",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/Projections/ProjectionStoreSurfaceReadAdapter.swift": [
            "readWidget",
            "WidgetProjection.self",
            "readAppIntent",
            "AppIntentProjection.self",
            "readPrivacy",
            "PrivacyProjection.self",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/Projections/AppIntentProjection.swift": [
            "canRunFromIntent = record.isPrivacySafeForExternalSurface && record.resultStatus != .failed",
            'title = canRunFromIntent ? record.summary : "Open Ambitions"',
            "blockedReason = canRunFromIntent ? nil",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/AppIntentBridge.swift": [
            "SharedExternalCreationStore",
            "enqueueExternalCreation",
            "commitRequirement: .committedProjection",
            "requestedBoundary: .localOnly",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ShareExtensionIntake.swift": [
            "recordDurableIntake",
            "commitRequirement: .committedProjection",
            "without direct private graph mutation",
        ],
        ROOT / "Native/AmbitionsShareExtension/ShareViewController.swift": [
            "store.enqueueDurableRequest(request)",
            "ExternalCreationRequest(",
        ],
    }
    for path, markers in required_markers.items():
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "external-surface-sanitized-projection-missing-source",
                    relative(path),
                    None,
                    "External-surface sanitized projection source is missing.",
                )
            )
            continue
        text = read_text(path)
        for marker in markers:
            if marker not in text:
                findings.append(
                    Finding(
                        "blocker",
                        "external-surface-sanitized-projection-marker-missing",
                        relative(path),
                        None,
                        f"Missing external-surface sanitized projection marker `{marker}`.",
                    )
                )

    writer_path = ROOT / "Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift"
    if writer_path.exists():
        writer_text = read_text(writer_path)
        forbidden_writer_markers = [
            "repositories.goals.listGoals",
            "repositories.captures.listCaptures",
            "FileExternalSurfaceSnapshotDataSink",
            "SharedExternalSnapshotStore.snapshotFileURL()",
        ]
        for marker in forbidden_writer_markers:
            if marker in writer_text:
                findings.append(
                    Finding(
                        "blocker",
                        "external-surface-writer-raw-graph-or-plain-file-path",
                        relative(writer_path),
                        None,
                        f"ExternalSurfaceSnapshotWriter must not use `{marker}`.",
                    )
                )

    for path in production_swift_files():
        rel = relative(path)
        if not any(rel.startswith(prefix) for prefix in EXTERNAL_SURFACE_SCAN_INCLUDED_PREFIXES):
            continue
        lines = read_text(path).splitlines()
        for index, line in enumerate(lines, start=1):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            for code, pattern, message in EXTERNAL_SURFACE_PRIVATE_GRAPH_READ_PATTERNS:
                if pattern.search(stripped):
                    findings.append(Finding("blocker", code, rel, index, message))

    return make_result(
        "external_surface_sanitized_projection_gate",
        findings,
        "Widget/runtime readers use safe AppGroup snapshot records; writer consumes sanitized projections; App Intents/share use sanitized or durable-intake bridges.",
        "{count} external-surface sanitized projection blocker(s) remain.",
    )


def check_privacy_security_external_boundary_gate() -> CheckResult:
    findings: list[Finding] = []
    required_markers = {
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyExternalBoundaryGate.swift": [
            "enum PrivacyExternalBoundaryKind",
            "case networkEgress",
            "case export",
            "case diagnosticsRedaction",
            "case externalSnapshot",
            "case appIntentResponse",
            "case shareHandoff",
            "case fileProtection",
            "struct PrivacyExternalBoundaryGate",
            "func evaluateEgress(_ decision: PrivacyEgressDecision)",
            "func evaluateExport(_ decision: PrivacyExportDecision)",
            "func evaluateDiagnostics(_ redaction: PrivacyRedactionResult)",
            "func evaluateExternalSnapshot(",
            "func evaluateExternalSurfaceBridge(",
            "func evaluateFileProtection(_ decision: FileProtectionDecision)",
            "func requirePermitted(_ decision: PrivacyExternalBoundaryDecision)",
            ".rawPrivateRuntimeData",
            ".externalSurfaceBridgeContainsPrivateRuntimeData",
            "SourceAtlasNoPrivateGraphEgressAudit.validate",
        ],
        ROOT / "Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift": [
            "private let privacyGate: PrivacyExternalBoundaryGate",
            "privacyGate.evaluateExternalSnapshot(record: record, widget: widget, privacy: privacy)",
            "try privacyGate.requirePermitted(privacyDecision)",
            "appGroupSnapshotStore.write(record)",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/AppIntentBridge.swift": [
            "private let privacyGate: PrivacyExternalBoundaryGate",
            "PrivacyExternalSurfaceBridgeEvidence(",
            "kind: .appIntentResponse",
            "commitRequirement: outboxRequest.commitRequirement",
            "requestedBoundary: outboxRequest.requestedBoundary",
            "containsPrivateRuntimeData: false",
            "try privacyGate.requirePermitted(privacyDecision)",
            "try store.enqueueDurableRequest(request)",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ShareExtensionIntake.swift": [
            "private let privacyGate: PrivacyExternalBoundaryGate",
            "PrivacyExternalSurfaceBridgeEvidence(",
            "kind: .shareHandoff",
            "commitRequirement: request.commitRequirement",
            "requestedBoundary: request.requestedBoundary",
            "containsPrivateRuntimeData: false",
            "guard privacyDecision.isPermitted else { return }",
        ],
        ROOT / "Native/AmbitionsTests/LocalRuntimeOS/PrivacySecurity/PrivacySecurityTests.swift": [
            "testPrivacyExternalBoundaryGateEvaluatesEgressExportDiagnosticsAndFiles",
            "testPrivacyExternalBoundaryGateEvaluatesExternalSnapshotsAndBridgeHandoffs",
            "gate.evaluateEgress",
            "gate.evaluateExport",
            "gate.evaluateDiagnostics",
            "gate.evaluateExternalSnapshot",
            "gate.evaluateExternalSurfaceBridge",
            "gate.evaluateFileProtection",
        ],
    }
    for path, markers in required_markers.items():
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "privacy-security-external-boundary-source-missing",
                    relative(path),
                    None,
                    "PrivacySecurity external boundary gate source is missing.",
                )
            )
            continue
        text = read_text(path)
        for marker in markers:
            if marker not in text:
                findings.append(
                    Finding(
                        "blocker",
                        "privacy-security-external-boundary-marker-missing",
                        relative(path),
                        None,
                        f"Missing PrivacySecurity external-boundary marker `{marker}`.",
                    )
                )

    return make_result(
        "privacy_security_external_boundary_gate",
        findings,
        "PrivacySecurity gates egress, export, diagnostics, external snapshots, App Intent/share bridges, and file protection.",
        "{count} PrivacySecurity external-boundary blocker(s) remain.",
    )


def check_source_atlas_r2_public_only_gate() -> CheckResult:
    findings: list[Finding] = []
    required_markers = {
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicOnlyBoundaryGate.swift": [
            "enum SourceAtlasPublicOnlyBoundarySurface",
            "case requestCompilation",
            "case remoteObjectRequest",
            "case remoteEndpoint",
            "case r2GatewayRequest",
            "case r2URLRequest",
            "case manifestCacheRollback",
            "case sourceAtlasProjection",
            "struct SourceAtlasPublicOnlyBoundaryGate",
            "func evaluatePublicPackRequest(",
            "func evaluateRemoteObjectRequest(",
            "func evaluateRemoteEndpoint(",
            "func evaluateR2GatewayRequest(",
            "func evaluateCompiledR2GatewayRequest(",
            "func evaluateURLRequest(_ request: URLRequest)",
            "func evaluateManifestCacheRollbackEvidence(",
            "func evaluateSourceAtlasProjection(",
            "func requireAllowed(_ decision: SourceAtlasPublicOnlyBoundaryDecision)",
            ".privateRuntimeDataTouched",
            "SourceAtlasNoPrivateGraphEgressAudit.validate",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/PublicPackRequestCompiler.swift": [
            "private let publicOnlyGate: SourceAtlasPublicOnlyBoundaryGate",
            "publicOnlyGate.evaluatePublicPackRequest(",
            "publicOnlyDecision.isAllowed == false",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/R2GatewayClient.swift": [
            "private let publicOnlyGate: SourceAtlasPublicOnlyBoundaryGate",
            "publicOnlyGate.evaluateR2GatewayRequest(",
            "publicOnlyGate.evaluateCompiledR2GatewayRequest(compiled)",
            "publicOnlyGate.evaluateURLRequest(request)",
            "\"X-Ambitions-Data-Class\"",
            "\"public-reference\"",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackRemoteTransportAdapters.swift": [
            "private let publicOnlyGate: SourceAtlasPublicOnlyBoundaryGate",
            "publicOnlyGate.evaluateRemoteEndpoint(endpoint)",
            "publicOnlyGate.evaluateRemoteObjectRequest(objectRequest)",
            "publicOnlyGate.evaluateURLRequest(urlRequest)",
            "\"X-Ambitions-Data-Class\"",
            "\"public-reference\"",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackRemoteTransport.swift": [
            "private let publicOnlyGate: SourceAtlasPublicOnlyBoundaryGate",
            "publicOnlyGate.evaluateRemoteObjectRequest(",
            "publicOnlyDecision.issues.contains(.privateRuntimeDataTouched)",
        ],
        ROOT / "Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicOnlyBoundaryGateTests.swift": [
            "testPublicOnlyBoundaryGateAllowsRequestGatewayEndpointCacheRollbackAndProjectionEvidence",
            "testPublicOnlyBoundaryGateRejectsPrivateRuntimeR2EndpointHeaderAndProjectionMarkers",
            "gate.evaluatePublicPackRequest",
            "gate.evaluateRemoteEndpoint",
            "gate.evaluateRemoteObjectRequest",
            "gate.evaluateCompiledR2GatewayRequest",
            "gate.evaluateURLRequest",
            "gate.evaluateManifestCacheRollbackEvidence",
            "gate.evaluateSourceAtlasProjection",
        ],
        ROOT / "Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasLocalRuntimeOSOwnershipTests.swift": [
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicOnlyBoundaryGate.swift",
        ],
    }

    for path, markers in required_markers.items():
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "source-atlas-r2-public-only-gate-missing-source",
                    relative(path),
                    None,
                    "SourceAtlas/R2 public-only gate source/test file is missing.",
                )
            )
            continue
        text = read_text(path)
        for marker in markers:
            if marker not in text:
                findings.append(
                    Finding(
                        "blocker",
                        "source-atlas-r2-public-only-gate-marker-missing",
                        relative(path),
                        None,
                        f"Missing SourceAtlas/R2 public-only marker `{marker}`.",
                    )
                )

    operational_request_paths = [
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/PublicPackRequestCompiler.swift",
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/R2GatewayClient.swift",
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackRemoteTransport.swift",
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackRemoteTransportAdapters.swift",
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasVerifiedPublicPackProvider.swift",
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPlanningContextModels.swift",
    ]
    forbidden_request_tokens = [
        "goal_text",
        "capture_text",
        "schedule_assumption",
        "proof_payload",
        "receipt_payload",
        "private_graph",
        "account_secret",
        "user_id",
        "inferred_priority",
        "behavior_history",
        "personal_context",
        "private_user_context",
        "calendar_context",
        "life_area",
    ]
    for path in operational_request_paths:
        if not path.exists():
            continue
        lines = read_text(path).splitlines()
        for index, line in enumerate(lines, start=1):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            normalized = normalize_source_atlas_egress_value(stripped)
            for token in forbidden_request_tokens:
                if token in normalized:
                    findings.append(
                        Finding(
                            "blocker",
                            "source-atlas-r2-request-private-marker",
                            relative(path),
                            index,
                            f"Operational SourceAtlas/R2 request code contains forbidden private marker `{token}`.",
                        )
                    )

    return make_result(
        "source_atlas_r2_public_only_gate",
        findings,
        "SourceAtlas/R2 request, gateway, endpoint, manifest/cache/LKG, and projection paths are gated as public-reference-only.",
        "{count} SourceAtlas/R2 public-only blocker(s) remain.",
    )


def check_sync_continuity_backend_authority_gate() -> CheckResult:
    findings: list[Finding] = []
    required_markers = {
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncContinuityAuthorityGate.swift": [
            "enum SyncContinuitySourceAuthority",
            "case runtimeEvent",
            "case approvedProjection",
            "case directObjectStore",
            "case remoteBackend",
            "struct SyncContinuityAuthorityGate",
            "func evaluate(_ evidence: SyncContinuityAuthorityEvidence)",
            ".nonRuntimeSource",
            ".privacyClassDenied",
            ".backendAuthorityAttempt",
            "allowedForCloudKitTransport",
            "localStoreRemainsAuthoritative",
            "productionCloudKitContinuityNonClaim",
            "privateLifeGraphBackendAuthorityDenied",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncEligibilityPolicy.swift": [
            "let authorityGate: SyncContinuityAuthorityGate",
            "authorityGate.evaluate",
            "sourceAuthority: SyncContinuitySourceAuthority",
            "privacyClass: RuntimePrivacyClass",
            "localStoreAuthoritative: Bool",
            "attemptsBackendAuthority: Bool",
            "accountRequiredForCoreUse: Bool",
            "outcome: outcome(for: authorityDecision)",
            "localStoreRemainsAuthoritative: authorityDecision.localStoreRemainsAuthoritative",
            "case deniedBackendAuthority",
            "case deniedPrivacyClass",
            "case deniedNonRuntimeAuthority",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SignOutDeleteResetCoordinator.swift": [
            "offlineCoreAvailableAfterCleanup",
            "privateGraphBackendAuthorityAllowed",
            "localDataRetained: true",
            "offlineCoreAvailableAfterCleanup: true",
            "privateGraphBackendAuthorityAllowed: false",
            "localStoreRemainsAuthoritative: true",
        ],
        ROOT / "Native/AmbitionsTests/LocalRuntimeOS/SyncContinuity/SyncContinuityTests.swift": [
            "testAuthorityGateAllowsOnlyRuntimeEventsAndApprovedProjections",
            "testAuthorityGateDeniesPrivatePrivacyClassesAndBackendAuthority",
            "testNoAccountOfflineCoreStaysLocalAuthoritative",
            "testSameClockPayloadDriftQueuesLocalReviewInsteadOfSilentOverwrite",
            "testSignOutDeleteResetCoordinatorRetainsLocalDataAndRevokesRemoteAuthority",
            "SyncContinuityAuthorityGate",
            ".directObjectStore",
            ".remoteBackend",
            ".privateUserText",
            "privateGraphBackendAuthorityAllowed",
        ],
    }

    for path, markers in required_markers.items():
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "sync-continuity-backend-authority-gate-missing-source",
                    relative(path),
                    None,
                    "SyncContinuity backend-authority gate source/test file is missing.",
                )
            )
            continue
        text = read_text(path)
        for marker in markers:
            if marker not in text:
                findings.append(
                    Finding(
                        "blocker",
                        "sync-continuity-backend-authority-gate-marker-missing",
                        relative(path),
                        None,
                        f"Missing SyncContinuity backend-authority marker `{marker}`.",
                    )
                )

    return make_result(
        "sync_continuity_backend_authority_gate",
        findings,
        "SyncContinuity gates transport eligibility by runtime/projection source, privacy class, local authority, conflict review, and account cleanup non-authority.",
        "{count} SyncContinuity backend-authority blocker(s) remain.",
    )


def check_capture_intake_durability_gate() -> CheckResult:
    findings: list[Finding] = []
    required_markers = {
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureDurableIntakePipeline.swift": [
            "struct CaptureDurableIntakePipeline",
            "try await services.intakeJournal.append",
            "try await services.intakeJournal.record",
            "try await services.attachmentVault.stage",
            "services.routeResolver.resolve",
            "CaptureRouteGraphPreparation",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureRouteGraphServices.swift": [
            "func durableIntakePipeline() -> CaptureDurableIntakePipeline",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureService+04-DefaultCaptureService.swift": [
            "captureRouteGraph.durableIntakePipeline().prepareAcceptedInput",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureAttachmentVault.swift": [
            "case missingDurableIntake",
            "guard request.intakeRecordID != nil",
        ],
        ROOT / "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CapturePromotionTransaction.swift": [
            "attachmentRecordIDs",
            "attachmentChecksums",
            "trustReceiptID",
            "RuntimeTombstoneEventPayload",
            "replayHistoryID",
            "runtimeEvent.metadata[\"capturePromotionReceiptID\"] == id",
        ],
        ROOT / "Native/AmbitionsTests/LocalRuntimeOS/CaptureRouteGraph/CaptureRouteGraphTests.swift": [
            "testDurablePipelineRecordsAcceptedExternalSourcesBeforeClassificationAndSurvivesRestart",
            "testDurablePipelineStagesAttachmentsAfterIntakeBeforePromotion",
            "testPromotionTransactionAndCorrectionLedgerUseDurableIntake",
            "testDirectLookupSurvivesRestartAfterCorrectionFlow",
        ],
        ROOT / "Native/AmbitionsTests/App/ExternalCreationImportServiceTests.swift": [
            "CaptureRouteGraphServices.fileBacked",
            "captureRouteGraph.intakeJournal.records",
            "captureRouteGraph.directLookupIndex.entry",
        ],
    }
    for path, markers in required_markers.items():
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "capture-intake-durability-missing-source",
                    relative(path),
                    None,
                    "Capture intake durability gate source/test file is missing.",
                )
            )
            continue
        text = read_text(path)
        for marker in markers:
            if marker not in text:
                findings.append(
                    Finding(
                        "blocker",
                        "capture-intake-durability-marker-missing",
                        relative(path),
                        None,
                        f"Missing Capture durable-intake marker `{marker}`.",
                    )
                )

    pipeline_path = ROOT / "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureDurableIntakePipeline.swift"
    if pipeline_path.exists():
        pipeline = read_text(pipeline_path)
        append_index = pipeline.find("try await services.intakeJournal.append")
        record_index = pipeline.find("try await services.intakeJournal.record")
        attachment_index = pipeline.find("try await services.attachmentVault.stage")
        resolve_index = pipeline.find("services.routeResolver.resolve")
        if min(append_index, record_index, resolve_index) == -1 or not (append_index < record_index < resolve_index):
            findings.append(
                Finding(
                    "blocker",
                    "capture-classification-before-durable-intake",
                    relative(pipeline_path),
                    None,
                    "Capture route resolution must occur only after append and durable record reload.",
                )
            )
        if attachment_index != -1 and not (append_index < record_index < attachment_index < resolve_index):
            findings.append(
                Finding(
                    "blocker",
                    "capture-attachment-before-durable-intake",
                    relative(pipeline_path),
                    None,
                    "Capture attachment checksum/metadata staging must occur after durable intake record reload and before route resolution/promotion.",
                )
            )

    allowed_route_resolution_paths = {
        "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureDurableIntakePipeline.swift",
        "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureRouteResolver.swift",
    }
    for path in production_swift_files():
        rel = relative(path)
        if rel in allowed_route_resolution_paths:
            continue
        text = read_text(path)
        if "routeResolver.resolve(" in text or "CaptureClassifier.classify(" in text:
            findings.append(
                Finding(
                    "blocker",
                    "capture-route-resolution-outside-durable-pipeline",
                    rel,
                    None,
                    "Capture classification/route resolution must go through CaptureDurableIntakePipeline after durable intake.",
                )
            )
        if "attachmentVault.stage(" in text and rel != "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureDurableIntakePipeline.swift":
            findings.append(
                Finding(
                    "blocker",
                    "capture-attachment-staging-outside-durable-pipeline",
                    rel,
                    None,
                    "Capture attachment staging must go through CaptureDurableIntakePipeline so metadata/checksum work follows durable intake.",
                )
            )

    return make_result(
        "capture_intake_durability_gate",
        findings,
        "Capture accepted input is journaled before classification, attachment staging, promotion, and restart lookup evidence.",
        "{count} Capture durable-intake blocker(s) remain.",
    )


def check_side_effect_local_commit_receipt_gate() -> CheckResult:
    findings: list[Finding] = []
    required_markers = {
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "ExternalWrites" / "SideEffectPolicyEngine.swift": [
            "let runtimeTransactionID: String?",
            "let runtimeEventID: String?",
            "let runtimeReceiptID: String?",
            "let rollbackPlanID: String?",
            "init(runtimeReceipt: RuntimeCommitReceipt",
            "runtimeTransactionID: runtimeReceipt.transactionID",
            "runtimeEventID: runtimeReceipt.eventID",
            "runtimeReceiptID: runtimeReceipt.receiptID",
            "rollbackPlanID: runtimeReceipt.rollbackPlanID",
            "runtimeTransactionID != nil",
            "runtimeEventID != nil",
            "runtimeReceiptID != nil",
            "rollbackPlanID != nil",
            "request.externalEffect && request.commitRequirement != .localCommitRequired",
            "External side effect must declare a local runtime commit receipt requirement.",
            "External side effect cannot be attempted before a committed local mutation receipt.",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "ExternalWrites" / "EventKitOutbox.swift": [
            "async -> SideEffectAttempt?",
            "commitRequirement: externalEffect ? .localCommitRequired : .noUserStateMutation",
            "localCommit: localCommit",
            "return try? await recorder.enqueue(request)",
            "func recordCalendarResult(",
            "return try? await recorder.recordResult(result, for: attempt, occurredAt: now)",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "Permissions" / "CalendarReminders" / "EventKitIntegrationService.swift": [
            "case missingLocalCommitReceipt(scope: CalendarRemindersScope)",
            "A local runtime commit receipt is required before creating reminder items.",
            "A local runtime commit receipt is required before creating calendar events.",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "Permissions" / "CalendarReminders" / "EventKitIntegrationService+02-EventKitIntegrationService.swift": [
            "localCommit: SideEffectLocalCommitEvidence?",
            "guard attempt?.mayAttemptExternalWrite == true else",
            "throw CalendarRemindersError.missingLocalCommitReceipt(scope: .reminders)",
            "throw CalendarRemindersError.missingLocalCommitReceipt(scope: .calendarEvents)",
            "localCommit: localCommit",
            "storeClient.saveReminder(payload)",
            "Reminder write completed through EventKit side-effect owner.",
            "recordCalendarResult(",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "Permissions" / "CalendarReminders" / "EventKitIntegrationService+03-EventKitIntegrationService.swift": [
            "localCommit: SideEffectLocalCommitEvidence?",
            "guard attempt?.mayAttemptExternalWrite == true else",
            "throw CalendarRemindersError.missingLocalCommitReceipt(scope: .calendarEvents)",
            "localCommit: localCommit",
        ],
        ROOT / "Native" / "AmbitionsTests" / "LocalRuntimeOS" / "ExternalWrites" / "ExternalWritesTests.swift": [
            "SideEffectLocalCommitEvidence(runtimeReceipt: localCommitOutcome.receipt)",
            "RuntimeTransactionCoordinator(eventStore: eventStore)",
            "testLegacyUnitOfWorkReceiptDoesNotPermitExternalWriteWithoutRuntimeReceiptProof",
            "External side effect must declare a local runtime commit receipt requirement.",
            "External side effect cannot be attempted before a committed local mutation receipt.",
            "ExternalWrites/ReminderOutbox.swift",
        ],
    }

    for path, markers in required_markers.items():
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "side-effect-local-commit-missing-source",
                    relative(path),
                    None,
                    "Side-effect local commit receipt gate source is missing.",
                )
            )
            continue
        text = read_text(path)
        for marker in markers:
            if marker not in text:
                findings.append(
                    Finding(
                        "blocker",
                        "side-effect-local-commit-marker-missing",
                        relative(path),
                        None,
                        f"Missing side-effect local commit receipt marker `{marker}`.",
                    )
                )

    side_effect_root = LOCAL_RUNTIME_ROOT / "ExternalWrites"
    if side_effect_root.exists():
        for path in sorted(side_effect_root.glob("*.swift")):
            rel = relative(path)
            lines = read_text(path).splitlines()
            for index, line in enumerate(lines, start=1):
                if "externalEffect: true" not in line:
                    continue
                nearby = "\n".join(lines[index - 1:index + 12])
                if "commitRequirement: .localCommitRequired" not in nearby:
                    findings.append(
                        Finding(
                            "blocker",
                            "external-side-effect-without-local-commit-requirement",
                            rel,
                            index,
                            "ExternalWrites external-effect requests must require a local runtime commit receipt.",
                        )
                    )

    return make_result(
        "side_effect_local_commit_receipt_gate",
        findings,
        "External side effects require local runtime commit receipt evidence before attempt.",
        "{count} side-effect local commit receipt blocker(s) remain.",
    )


def check_inspection_runtime_lineage_gate() -> CheckResult:
    findings: list[Finding] = []
    required_markers = {
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Inspection" / "RuntimeTrustLineage.swift": [
            "struct RuntimeTrustLineage",
            "init(runtimeCommitReceipt: RuntimeCommitReceipt)",
            "runtimeTransactionID: runtimeCommitReceipt.transactionID",
            "runtimeEventID: runtimeCommitReceipt.eventID",
            "runtimeReceiptID: runtimeCommitReceipt.receiptID",
            "runtimeRollbackPlanID: runtimeCommitReceipt.rollbackPlanID",
            "runtimeReplayTraceID: runtimeCommitReceipt.replayTraceID",
            "hasCompleteTrustTrace",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Inspection" / "InspectionCommitPlanner.swift": [
            "let runtimeCommitReceipt: RuntimeCommitReceipt",
            "let runtimeEventEnvelope: RuntimeEventEnvelope",
            "RuntimeTrustLineage(runtimeCommitReceipt: input.runtimeCommitReceipt)",
            "runtimeCommitReceipt.eventID == input.runtimeEventEnvelope.id",
            "runtimeCommitReceipt.eventCursor == input.runtimeEventEnvelope.cursor",
            "runtimeCommitReceipt.receiptID == input.receipt.id",
            "hasCompleteCommandEventProjectionReceiptReplayFlow",
            "proofLedger.hasRuntimeLineage",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Inspection" / "ActionReceiptHistoryRecord.swift": [
            "let runtimeLineage: RuntimeTrustLineage?",
            "var hasRuntimeLineage",
            "var runtimeTransactionID",
            "var runtimeEventID",
            "var runtimeReplayTraceID",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Inspection" / "ActionReceiptProofLedgerModels.swift": [
            "let runtimeLineage: RuntimeTrustLineage?",
            "var hasRuntimeLineage",
            "var runtimeTransactionID",
            "var runtimeEventID",
            "var runtimeReplayTraceID",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Inspection" / "ProofLedger.swift": [
            "let runtimeLineages: [RuntimeTrustLineage]",
            "var runtimeTransactionIDs",
            "var runtimeEventIDs",
            "var runtimeReplayTraceIDs",
            "var hasRuntimeLineage",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Inspection" / "UndoLedger.swift": [
            "let runtimeLineage: RuntimeTrustLineage?",
            "var runtimeRollbackPlanID",
            "var runtimeReplayTraceID",
            "var hasRuntimeRollbackLineage",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Inspection" / "AuditTrail.swift": [
            "let runtimeLineage: RuntimeTrustLineage?",
            "hasCompleteRuntimeLineage",
            "runtimeLineage: runtimeLineage",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Inspection" / "HistoryQueryEngine.swift": [
            "requiresRuntimeLineage",
            "runtimeTransactionIDs",
            "runtimeEventIDs",
            "runtimeReplayTraceIDs",
            "RuntimeTrustLineage.eventMetadataLineage",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Inspection" / "SourceRecordLedger.swift": [
            "let runtimeTransactionID: String?",
            "let runtimeEventID: String?",
            "let runtimeReceiptID: String?",
            "let runtimeReplayTraceID: String?",
            "var isPublicReferenceOnly",
            "var hasPrivateRuntimeLineage",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Storage" / "ObjectStoreEntityRevisionTombstoneRecord.swift": [
            "var runtimeLineageData: Data?",
        ],
        ROOT / "Native" / "AmbitionsTests" / "LocalRuntimeOS" / "Inspection" / "InspectionTests.swift": [
            "RuntimeTransactionCoordinator(eventStore: eventStore)",
            "runtimeCommitReceipt: fixture.runtimeCommitReceipt",
            "runtimeEventEnvelope: fixture.runtimeEventEnvelope",
            "hasCompleteRuntimeLineage",
            "hasPrivateRuntimeLineage",
        ],
        ROOT / "Native" / "AmbitionsTests" / "LocalRuntimeOS" / "Inspection" / "ActionReceiptHistoryRepositoryTests.swift": [
            "runtimeLineage:",
            "runtimeTransactionID",
            "runtimeReplayTraceID",
        ],
        ROOT / "Native" / "AmbitionsTests" / "LocalRuntimeOS" / "Inspection" / "TrustHistoryQueryRepositoryTests.swift": [
            "testSwiftDataTrustHistoryQueryFiltersByRuntimeLineage",
            "requiresRuntimeLineage: true",
            "runtimeTransactionIDs:",
            "runtimeEventIDs:",
        ],
    }
    for path, markers in required_markers.items():
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "inspection-runtime-lineage-missing-source",
                    relative(path),
                    None,
                    "Inspection runtime lineage source is missing.",
                )
            )
            continue
        text = read_text(path)
        for marker in markers:
            if marker not in text:
                findings.append(
                    Finding(
                        "blocker",
                        "inspection-runtime-lineage-marker-missing",
                        relative(path),
                        None,
                        f"Missing Inspection runtime lineage marker `{marker}`.",
                    )
                )

    return make_result(
        "inspection_runtime_lineage_gate",
        findings,
        "Inspection receipt, proof, undo, audit, source, and history records require runtime commit receipt lineage.",
        "{count} Inspection runtime lineage blocker(s) remain.",
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
                "RuntimeMutationContext must be owned by Transactions, not the State owner.",
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
        "Canonical object-state write repositories require coordinator-issued Transactions RuntimeMutationContext.",
        "{count} runtime mutation context boundary blocker(s) remain.",
    )


def check_runtime_doctor_local_drift_repair_gate() -> CheckResult:
    findings: list[Finding] = []
    required_markers = {
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Repair" / "RuntimeDoctorRepairTypes.swift": [
            "RuntimeDoctorHealthDomain",
            "case commandJournal = \"command_journal\"",
            "case eventStore = \"event_store\"",
            "case projectionStore = \"projection_store\"",
            "case searchIndex = \"search_index\"",
            "case blobVault = \"blob_vault\"",
            "case sideEffectOutbox = \"side_effect_outbox\"",
            "case syncContinuity = \"sync_continuity\"",
            "case privacyBoundary = \"privacy_boundary\"",
            "case migrationState = \"migration_state\"",
            "case storageTier = \"storage_tier\"",
            "RuntimeDoctorRepairActionKind",
            "case projectionRebuild = \"projection_rebuild\"",
            "case searchRebuild = \"search_rebuild\"",
            "case commandEventReconciliation = \"command_event_reconciliation\"",
            "case corruptBlobQuarantine = \"corrupt_blob_quarantine\"",
            "case dryMigration = \"dry_migration\"",
            "case preMigrationBackup = \"pre_migration_backup\"",
            "case restoreBackup = \"restore_backup\"",
            "case restoreRollback = \"restore_rollback\"",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Repair" / "RuntimeDoctorHealthReaders.swift": [
            "RuntimeDoctorHealthReaders",
            "func commandJournal(",
            "func eventStore(",
            "func projectionStore(",
            "func searchIndex(",
            "func blobVault(",
            "func sideEffectOutbox(",
            "func syncContinuity(",
            "func privacyBoundary(",
            "func migrationState(",
            "func storageTier(",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Repair" / "RuntimeDoctorRepairPlans.swift": [
            "RuntimeDoctorRepairPlan",
            "RuntimeDoctorRepairReceipt",
            "RuntimeDoctorRepairProof",
            "beforeProof",
            "expectedAfterProof",
            "No private details leave this device.",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Repair" / "RuntimeDoctorRepairOperator.swift": [
            "runtimeDoctorRepairOperatorSchemaVersion",
            "RuntimeDoctorRepairOperator",
            "diagnose(snapshot: RuntimeDoctorHealthSnapshot)",
            "repairActions(",
            "repairPlan(",
            "for signal: RuntimeDoctorDriftSignal",
            "privatePayloadIncluded: false",
            "executionAllowed: false",
            "destructiveResetAllowed: false",
        ],
        ROOT / "Native" / "Ambitions" / "Core" / "LocalRuntimeOS" / "Repair" / "RuntimeDoctor.swift": [
            "func diagnoseLocalDrift(",
            "RuntimeDoctorRepairOperator(",
            "diagnose(snapshot: snapshot)",
        ],
        ROOT / "Native" / "AmbitionsTests" / "LocalRuntimeOS" / "Repair" / "RuntimeDoctorTests.swift": [
            "testLocalDriftReadersReturnReceiptBackedPreviewPlansForEveryRequiredDomain",
            "testYouDiagnosticsAreRedactedLocalOnlyAndDoNotExposePrivatePayloads",
            "testHealthyRuntimeDoctorReadersDoNotAuthorizeRepairExecution",
            "RuntimeDoctorHealthDomain.allCases",
            "RuntimeDoctorHealthReaders",
            ".projectionRebuild",
            ".searchRebuild",
            ".commandEventReconciliation",
            ".corruptBlobQuarantine",
            ".dryMigration",
            ".preMigrationBackup",
            ".restoreBackup",
            ".restoreRollback",
            "privatePayloadIncluded == false",
        ],
        ROOT / "Native" / "AmbitionsTests" / "LocalRuntimeOS" / "Repair" / "RepairOwnershipTests.swift": [
            "RuntimeDoctorRepairOperator.swift",
            "RuntimeDoctorRepairTypes.swift",
            "RuntimeDoctorHealthReaders.swift",
            "RuntimeDoctorRepairPlans.swift",
        ],
    }
    for path, markers in required_markers.items():
        if not path.exists():
            findings.append(
                Finding(
                    "blocker",
                    "runtime-doctor-local-drift-repair-missing-source",
                    relative(path),
                    None,
                    "RuntimeDoctor local drift repair source or tests are missing.",
                )
            )
            continue
        text = read_text(path)
        for marker in markers:
            if marker not in text:
                findings.append(
                    Finding(
                        "blocker",
                        "runtime-doctor-local-drift-repair-marker-missing",
                        relative(path),
                        None,
                        f"Missing RuntimeDoctor local drift repair marker `{marker}`.",
                    )
                )

    return make_result(
        "runtime_doctor_local_drift_repair_gate",
        findings,
        "RuntimeDoctor has redacted local drift readers, receipt-backed preview repair plans, and focused tests.",
        "{count} RuntimeDoctor local drift repair blocker(s) remain.",
    )


def check_proof_ceiling_and_ci_evidence() -> CheckResult:
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

    if not KNOWN_ISSUES.exists():
        findings.append(
            Finding(
                "blocker",
                "known-issues-missing",
                relative(KNOWN_ISSUES),
                None,
                "Known Issues register is required for LocalRuntimeOS proof-ceiling reconciliation.",
            )
        )
    else:
        known_text = read_text(KNOWN_ISSUES)
        required_known_markers = [
            "2026-07-01 LocalRuntimeOS post-refactor proof ceiling",
            "LocalRuntimeProof Gate Green",
            "Runtime device Yellow",
            "Visual Yellow-Red",
            "Release Red-Yellow",
            "Device proof ceiling",
            "Visual proof ceiling",
            "Release proof ceiling",
            "Privacy/legal proof ceiling",
        ]
        for marker in required_known_markers:
            if marker not in known_text:
                findings.append(
                    Finding(
                        "blocker",
                        "known-issues-proof-ceiling-marker-missing",
                        relative(KNOWN_ISSUES),
                        None,
                        f"Known Issues must explicitly preserve proof-ceiling marker `{marker}`.",
                    )
                )
        stale_known_issue_phrases = [
            "Canonical runtime Commands validation, idempotency, and unit-of-work proof are missing.",
            "External side-effect unit-of-work is not proven.",
            "Local-first privacy boundary with account/R2 is not proven.",
            "Widgets, App Intents, and deep links may bypass command/runtime safety.",
            "Source Atlas / R2 provider, cache, freshness, ranking, and public-only boundary are not proven.",
            "Security, privacy manifest, local auth, and app-group protection proof are missing.",
        ]
        for phrase in stale_known_issue_phrases:
            if phrase in known_text:
                line_number = next(
                    (idx for idx, line in enumerate(known_text.splitlines(), start=1) if phrase in line),
                    None,
                )
                findings.append(
                    Finding(
                        "blocker",
                        "known-issues-stale-runtime-source-blocker",
                        relative(KNOWN_ISSUES),
                        line_number,
                        f"Known Issues still carries stale runtime-source blocker wording: {phrase}",
                    )
                )

    if not PR_REVIEW_WORKFLOW.exists():
        findings.append(
            Finding(
                "blocker",
                "ci-localruntimeproof-workflow-missing",
                relative(PR_REVIEW_WORKFLOW),
                None,
                "CI workflow evidence is required for LocalRuntimeProof.",
            )
        )
    else:
        workflow = read_text(PR_REVIEW_WORKFLOW)
        if "python3 scripts/ambitions-local-runtime-proof.py" not in workflow:
            findings.append(
                Finding(
                    "blocker",
                    "ci-localruntimeproof-command-missing",
                    relative(PR_REVIEW_WORKFLOW),
                    None,
                    "Ambitions PR CI must run `python3 scripts/ambitions-local-runtime-proof.py`.",
                )
            )
    return make_result(
        "proof_ceiling_and_ci_evidence",
        findings,
        "Known Issues, truth files, and CI workflow evidence preserve the LocalRuntimeOS proof ceiling.",
        "{count} proof-ceiling or CI evidence blocker(s) remain.",
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
        check_projection_store_surface_read_gate(),
        check_external_surface_sanitized_projection_gate(),
        check_privacy_security_external_boundary_gate(),
        check_source_atlas_r2_public_only_gate(),
        check_sync_continuity_backend_authority_gate(),
        check_capture_intake_durability_gate(),
        check_side_effect_local_commit_receipt_gate(),
        check_inspection_runtime_lineage_gate(),
        check_runtime_mutation_context_boundaries(),
        check_runtime_doctor_local_drift_repair_gate(),
        scan_mutation_bypasses(),
        scan_feature_service_mutation_authority(),
        check_proof_ceiling_and_ci_evidence(),
    ]


def checklist_status_for_result(result: CheckResult | None) -> str:
    if result is None or result.status == "fail":
        return "fail"
    if result.status == "warn":
        return "warn"
    return "pass"


def build_checklist(results: list[CheckResult]) -> list[dict[str, object]]:
    results_by_id = {result.check_id: result for result in results}
    checklist: list[dict[str, object]] = []
    for spec in LRO_100_CHECKLIST:
        result = results_by_id.get(spec.check_id)
        if result is None:
            findings = [
                asdict(
                    Finding(
                        "blocker",
                        "checklist-linked-check-missing",
                        "scripts/ambitions-local-runtime-proof.py",
                        None,
                        f"Checklist item `{spec.checklist_id}` links to missing check `{spec.check_id}`.",
                    )
                )
            ]
            summary = f"Missing linked check `{spec.check_id}`."
        else:
            findings = [asdict(finding) for finding in result.findings]
            summary = result.summary
        checklist.append(
            {
                "checklistId": spec.checklist_id,
                "category": spec.category,
                "title": spec.title,
                "status": checklist_status_for_result(result),
                "linkedCheckId": spec.check_id,
                "requirement": spec.requirement,
                "summary": summary,
                "findings": findings,
            }
        )
    return checklist


def allowed_claims_for_status(status: str) -> list[str]:
    if status != "green":
        return [
            "LocalRuntimeOS source-present owner inventory can be reported only for passing architecture inventory checks.",
        ]
    return [
        "LocalRuntimeOS source-present owner inventory can be reported when architecture_inventory passes.",
        "LocalRuntimeProof Gate Green means the current 20-item LRO-100 checklist is semantic, fail-closed, and passing for the checked source tree.",
        "For the current checked source tree and the represented 20-item checklist, no known meaningful Ambitions state-change bypass remains outside Command -> Event -> Projection -> Receipt -> Replay.",
    ]


def blocked_claims_for_status(status: str) -> list[str]:
    claims = [
        "LocalRuntimeOS is complete across future or unscanned code paths",
        "physical-device behavior, rendered UI quality, accessibility conformance, privacy/legal approval, Visual Green, Release Green, TestFlight readiness, or App Store readiness",
        "production CloudKit continuity or production R2 deployment",
    ]
    if status != "green":
        claims.insert(0, "all meaningful Ambitions state changes route only through Command -> Event -> Projection -> Receipt -> Replay")
        claims.insert(1, "app-wide command-only mutation is proven")
        claims.insert(2, "app-wide event replay and projection consumption are proven")
    return claims


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
    checklist = build_checklist(results)
    checklist_failures = [item for item in checklist if item["status"] != "pass"]
    status = "green" if not blockers and not warnings and not checklist_failures else "red"
    return {
        "generatedAt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "status": status,
        "runtimeLaw": "Command -> Event -> Projection -> Receipt -> Replay",
        "summary": {
            "checks": len(results),
            "passed": sum(1 for result in results if result.status == "pass"),
            "warnings": len(warnings),
            "blockers": len(blockers),
            "checklistItems": len(checklist),
            "checklistPassed": sum(1 for item in checklist if item["status"] == "pass"),
            "checklistFailures": len(checklist_failures),
            "green": status == "green",
        },
        "checklist": checklist,
        "checks": [
            {
                "checkId": result.check_id,
                "status": result.status,
                "summary": result.summary,
                "findings": [asdict(finding) for finding in result.findings],
            }
            for result in results
        ],
        "allowedClaims": allowed_claims_for_status(status),
        "blockedClaims": blocked_claims_for_status(status),
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
        f"- Checklist items: `{summary['checklistItems']}`",
        f"- Checklist passed: `{summary['checklistPassed']}`",
        f"- Checklist failures: `{summary['checklistFailures']}`",
        "",
        "## LRO-100 Checklist",
        "",
        "| ID | Category | Status | Linked check | Requirement |",
        "| -- | -- | -- | -- | -- |",
    ]

    checklist = payload["checklist"]
    assert isinstance(checklist, list)
    for item in checklist:
        assert isinstance(item, dict)
        lines.append(
            "| `{checklist_id}` | {category} | `{status}` | `{linked_check}` | {requirement} |".format(
                checklist_id=item["checklistId"],
                category=str(item["category"]).replace("|", "\\|"),
                status=item["status"],
                linked_check=item["linkedCheckId"],
                requirement=str(item["requirement"]).replace("|", "\\|"),
            )
        )

    lines.extend([
        "",
        "## Checks",
        "",
    ])

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
    assert "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeTransactionCoordinator.swift" in RUNTIME_EVENT_APPEND_ALLOWED_PATHS
    assert "Native/Ambitions/Core/LocalRuntimeOS/Search/SearchRebuildPipeline.swift" in PROJECTION_MATERIALIZATION_ALLOWED_PATHS
    assert "surface_projection_store_consumption" in INTEGRATION_MARKERS
    assert any(prefix.endswith("AmbitionsWidgetExtension/") for prefix in EXTERNAL_SURFACE_SCAN_INCLUDED_PREFIXES)
    assert any(result.check_id == "external_surface_sanitized_projection_gate" for result in [check_external_surface_sanitized_projection_gate()])
    assert any(result.check_id == "privacy_security_external_boundary_gate" for result in [check_privacy_security_external_boundary_gate()])
    assert any(result.check_id == "source_atlas_r2_public_only_gate" for result in [check_source_atlas_r2_public_only_gate()])
    assert any(result.check_id == "sync_continuity_backend_authority_gate" for result in [check_sync_continuity_backend_authority_gate()])
    assert any(result.check_id == "capture_intake_durability_gate" for result in [check_capture_intake_durability_gate()])
    assert any(result.check_id == "side_effect_local_commit_receipt_gate" for result in [check_side_effect_local_commit_receipt_gate()])
    assert any(result.check_id == "inspection_runtime_lineage_gate" for result in [check_inspection_runtime_lineage_gate()])
    assert any(result.check_id == "runtime_doctor_local_drift_repair_gate" for result in [check_runtime_doctor_local_drift_repair_gate()])
    assert any(result.check_id == "proof_ceiling_and_ci_evidence" for result in [check_proof_ceiling_and_ci_evidence()])
    assert len(LRO_100_CHECKLIST) == 20
    assert {spec.check_id for spec in LRO_100_CHECKLIST} == {result.check_id for result in run_checks()}
    assert RUNTIME_MUTATION_CONTEXT_PATH.endswith("Transactions/RuntimeMutationContext.swift")
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

    green_results = [
        CheckResult(spec.check_id, "pass", f"{spec.checklist_id} fixture passed.", [])
        for spec in LRO_100_CHECKLIST
    ]
    green_payload = build_payload(green_results)
    assert green_payload["status"] == "green"
    green_summary = green_payload["summary"]
    assert isinstance(green_summary, dict)
    assert green_summary["checklistItems"] == 20
    assert green_summary["checklistPassed"] == 20
    assert green_summary["checklistFailures"] == 0
    assert len(green_payload["checklist"]) == 20
    assert any("Command -> Event -> Projection -> Receipt -> Replay" in claim for claim in green_payload["allowedClaims"])
    assert not any(str(claim).startswith("all meaningful Ambitions state changes") for claim in green_payload["blockedClaims"])
    assert "| `lro100-20-proof-ceiling-and-ci` |" in render_markdown(green_payload)

    missing_check_payload = build_payload(green_results[:-1])
    assert missing_check_payload["status"] == "red"
    missing_summary = missing_check_payload["summary"]
    assert isinstance(missing_summary, dict)
    assert missing_summary["checklistFailures"] == 1
    warning_results = list(green_results)
    warning_results[0] = CheckResult(
        LRO_100_CHECKLIST[0].check_id,
        "warn",
        "Fixture warning.",
        [Finding("warning", "fixture-warning", "Fixture.swift", 1, "Fixture warning.")],
    )
    warning_payload = build_payload(warning_results)
    assert warning_payload["status"] == "red"
    warning_summary = warning_payload["summary"]
    assert isinstance(warning_summary, dict)
    assert warning_summary["warnings"] == 1
    assert warning_summary["checklistFailures"] == 1
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
        print(f"checklist_items={summary['checklistItems']}")
        print(f"checklist_passed={summary['checklistPassed']}")
        print(f"checklist_failures={summary['checklistFailures']}")
        print("GREEN LocalRuntimeProof achieved" if payload["status"] == "green" else "RED LocalRuntimeProof blocked")

    if payload["status"] == "green" or args.audit_only:
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
