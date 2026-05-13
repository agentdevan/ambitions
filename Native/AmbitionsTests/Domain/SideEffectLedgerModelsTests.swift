import XCTest
@testable import Ambitions

final class SideEffectLedgerModelsTests: XCTestCase {
    func testCalendarWriteDecisionBecomesConfirmationRequiredExternalEffectRecord() {
        let decision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(
                kind: .writeCalendarBlock,
                sourceDomain: .plan,
                targetObjects: [object(.action, "plan-block-1", sourceDomain: .plan)]
            )
        )

        let record = SideEffectLedgerRecord(
            decision: decision,
            commandID: "command-calendar",
            occurredAt: "2026-05-12T12:00:00Z"
        )

        XCTAssertTrue(record.isWellFormed)
        XCTAssertEqual(record.effectKind, .calendar)
        XCTAssertEqual(record.status, .confirmationRequired)
        XCTAssertEqual(record.boundary, .externalEffect)
        XCTAssertEqual(record.requiresConfirmation, true)
        XCTAssertEqual(record.externalEffect, true)
        XCTAssertEqual(record.reasons, [.calendarIsPlanOwned, .externalSideEffect, .confirmationRequired])
        XCTAssertEqual(record.blockedFacts, ["No calendar data was changed."])
        XCTAssertFalse(record.mayExecuteWithoutUserConfirmation)
    }

    func testDraftOnlyExportAndSyncSafeFailureDoNotBecomeExecutableSideEffects() {
        let exportDecision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(kind: .prepareExport, sourceDomain: .you)
        )
        let syncDecision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(kind: .applySyncResolution, sourceDomain: .you)
        )

        let exportRecord = SideEffectLedgerRecord(decision: exportDecision, occurredAt: "2026-05-12T12:00:00Z")
        let syncRecord = SideEffectLedgerRecord(decision: syncDecision, occurredAt: "2026-05-12T12:01:00Z")

        XCTAssertEqual(exportRecord.effectKind, .export)
        XCTAssertEqual(exportRecord.status, .preparedDraft)
        XCTAssertEqual(exportRecord.boundary, .privacySensitive)
        XCTAssertEqual(exportRecord.degradedFacts, ["No export file is written by this policy."])
        XCTAssertFalse(exportRecord.mayExecuteWithoutUserConfirmation)

        XCTAssertEqual(syncRecord.effectKind, .sync)
        XCTAssertEqual(syncRecord.status, .failedSafely)
        XCTAssertEqual(syncRecord.boundary, .unsupported)
        XCTAssertEqual(syncRecord.blockedFacts, ["No sync conflict resolution was applied."])
        XCTAssertFalse(syncRecord.mayExecuteWithoutUserConfirmation)
    }

    func testLocalReversibleDecisionCanBeRecordedAsLocalOnlyWithoutExternalEffect() {
        let decision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(
                kind: .archiveItem,
                sourceDomain: .capture,
                targetObjects: [object(.capture, "capture-1", sourceDomain: .capture)]
            )
        )

        let record = SideEffectLedgerRecord(decision: decision, commandID: "command-local", occurredAt: "2026-05-12T12:00:00Z")

        XCTAssertEqual(record.effectKind, .localOnly)
        XCTAssertEqual(record.status, .recordedLocalOnly)
        XCTAssertEqual(record.boundary, .localOnly)
        XCTAssertEqual(record.localOnly, true)
        XCTAssertEqual(record.requiresConfirmation, false)
        XCTAssertEqual(record.externalEffect, false)
        XCTAssertTrue(record.mayExecuteWithoutUserConfirmation)
    }

    func testCommandBridgeExternalSurfaceProducesConfirmationGateRecord() {
        let command = AmbitionsCommand(
            id: "command-widget-archive",
            kind: .archiveItem,
            source: .widget,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            createdAt: "2026-05-12T12:00:00Z",
            actor: .externalSurface,
            sourceSurface: "widget"
        )

        let record = SideEffectLedgerRecord.fromCommand(command, occurredAt: "2026-05-12T12:00:01Z")

        XCTAssertEqual(record.commandID, "command-widget-archive")
        XCTAssertEqual(record.effectKind, .localOnly)
        XCTAssertEqual(record.status, .confirmationRequired)
        XCTAssertEqual(record.boundary, .externalEffect)
        XCTAssertEqual(record.sourceDomain, .externalSurface)
        XCTAssertEqual(record.reasons, [.unsupportedSource, .externalSideEffect])
        XCTAssertFalse(record.mayExecuteWithoutUserConfirmation)
    }

    func testInMemoryRepositoryDedupesAndSortsRecords() async throws {
        let repository = InMemorySideEffectLedgerRepository()
        let local = SideEffectLedgerRecord(
            id: "side-effect.local",
            effectKind: .localOnly,
            status: .recordedLocalOnly,
            boundary: .localOnly,
            actionKind: .archiveItem,
            sourceDomain: .capture,
            occurredAt: "2026-05-12T12:00:00Z",
            requiresConfirmation: false,
            externalEffect: false
        )
        let blocked = SideEffectLedgerRecord(
            id: "side-effect.blocked",
            effectKind: .calendar,
            status: .confirmationRequired,
            boundary: .externalEffect,
            actionKind: .writeCalendarBlock,
            sourceDomain: .plan,
            occurredAt: "2026-05-12T12:05:00Z",
            requiresConfirmation: true,
            externalEffect: true
        )

        try await repository.append(local)
        try await repository.append(blocked)
        try await repository.append(local)

        let recent = try await repository.fetchRecent(limit: 10)
        XCTAssertEqual(recent.map(\.id), ["side-effect.blocked", "side-effect.local"])
        let confirmationRequired = try await repository.fetchRecords(status: .confirmationRequired)
        XCTAssertEqual(confirmationRequired.map(\.id), ["side-effect.blocked"])
        let storedLocal = try await repository.fetchRecord(id: "side-effect.local")
        XCTAssertEqual(storedLocal?.id, "side-effect.local")
    }

    func testNotificationEffectKindIsPersistableAsAWellFormedRecord() {
        let record = SideEffectLedgerRecord(
            id: "notification.scheduled.1700000000",
            effectKind: .notification,
            status: .recordedLocalOnly,
            boundary: .localOnly,
            actionKind: .noOp,
            sourceDomain: .system,
            commandID: nil,
            occurredAt: "2026-06-01T10:00:00Z",
            localOnly: true,
            requiresConfirmation: false,
            externalEffect: false,
            reasons: [.noChangeNeeded],
            blockedFacts: [],
            degradedFacts: [],
            receiptID: nil
        )

        XCTAssertEqual(record.id, "notification.scheduled.1700000000")
        XCTAssertEqual(record.effectKind, .notification)
        XCTAssertEqual(record.status, .recordedLocalOnly)
        XCTAssertEqual(record.boundary, .localOnly)
        XCTAssertEqual(record.sourceDomain, .system)
        XCTAssertTrue(record.isWellFormed)
    }

    func testSideEffectLedgerRecordCanProduceDeterministicDiagnosticLedgerEntry() {
        let blockedRecord = SideEffectLedgerRecord(
            id: "side-effect.destructive.blocked",
            effectKind: .destructiveDataChange,
            status: .blocked,
            boundary: .destructive,
            actionKind: .deleteObject,
            sourceDomain: .goals,
            occurredAt: "2026-05-12T12:00:00Z",
            requiresConfirmation: true,
            externalEffect: true,
            reasons: [.destructiveAction],
            blockedFacts: ["No destructive change applied."],
            degradedFacts: ["Action was not executed."],
            receiptID: "receipt-1"
        )

        let diagnostic = blockedRecord.toDiagnosticLedgerEntry()

        XCTAssertEqual(diagnostic.signal, DiagnosticLedgerSignal.sideEffectLedger)
        XCTAssertEqual(diagnostic.sourceRecordID, blockedRecord.id)
        XCTAssertEqual(diagnostic.severity, DiagnosticLedgerSeverity.critical)
        XCTAssertEqual(diagnostic.localOnly, true)
        XCTAssertTrue(diagnostic.requiresReview)
        XCTAssertEqual(diagnostic.sideEffectBoundary, SideEffectLedgerBoundary.destructive)
        XCTAssertEqual(diagnostic.privacy, EventLedgerPrivacyClassification.privateUserText)
        XCTAssertEqual(diagnostic.payload["blockedFacts"], "No destructive change applied.")
    }
}

private extension SideEffectLedgerModelsTests {
    func object(
        _ kind: LifeGraphObjectKind,
        _ id: String,
        sourceDomain: LifeGraphSourceDomain
    ) -> LifeGraphObjectReference {
        LifeGraphObjectReference(kind: kind, id: id, sourceDomain: sourceDomain)
    }
}
