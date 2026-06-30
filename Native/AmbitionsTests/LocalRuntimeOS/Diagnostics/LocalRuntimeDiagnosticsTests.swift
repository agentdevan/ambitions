@testable import Ambitions
import XCTest

final class LocalRuntimeDiagnosticsTests: XCTestCase {
    func testDiagnosticsOwnerFilesExistUnderCanonicalLocalRuntimeOSOwner() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/LocalBackendHealth.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/RuntimeTraceInspector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/ProjectionInspector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/CommandInspector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/PrivacyInspector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/SyncInspector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/StoreInspector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/PerformanceBudgetLedger.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
    }

    func testDiagnosticRecordRedactsPrivateDetailsAndKeepsDeterministicIDs() {
        let record = LocalRuntimeDiagnosticRecord(
            id: "privacy leak check",
            area: .privacy,
            componentID: "PrivacyInspector",
            severity: .critical,
            summary: "Contact devan@example.com about goal.secret-12345",
            detail: "Call 555-010-2222 and inspect capture.private-99999 for 01234567-89AB-CDEF-0123-456789ABCDEF.",
            repairHint: "Regenerate diagnostics through the redactor.",
            evidenceIDs: ["goal.secret-12345", "goal.secret-12345"],
            privacy: .privateSensitive,
            generatedAt: "2026-06-30T11:30:00Z"
        )

        XCTAssertEqual(record.id, "privacy_leak_check")
        XCTAssertFalse(record.summary.contains("devan@example.com"))
        XCTAssertFalse(record.summary.contains("goal.secret-12345"))
        XCTAssertFalse(record.redactedDetail.contains("555-010-2222"))
        XCTAssertFalse(record.redactedDetail.contains("capture.private-99999"))
        XCTAssertFalse(record.redactedDetail.contains("01234567-89AB-CDEF-0123-456789ABCDEF"))
        XCTAssertTrue(record.summary.contains("[redacted-email]"))
        XCTAssertTrue(record.redactedDetail.contains("[redacted-phone]"))
        XCTAssertTrue(record.redactedDetail.contains("[redacted-uuid]"))
        XCTAssertEqual(record.evidenceIDs.count, 1)
        XCTAssertTrue(record.requiresAttention)
    }

    func testRuntimeTraceInspectorReportsNonAppendOnlyAndLocalOnlyViolations() throws {
        let first = try RuntimeEventEnvelope.make(
            sequence: 1,
            previousChecksum: nil,
            event: correctionEvent(id: "first", localOnly: true),
            deviceID: "diagnostics-test"
        )
        let third = try RuntimeEventEnvelope.make(
            sequence: 3,
            previousChecksum: first.checksum,
            event: correctionEvent(id: "third", localOnly: false),
            deviceID: "diagnostics-test"
        )

        let diagnostics = RuntimeTraceInspector().inspect(
            envelopes: [third, first],
            generatedAt: "2026-06-30T11:31:00Z"
        )

        XCTAssertTrue(diagnostics.contains { $0.id.hasPrefix("runtime_trace.sequence.") && $0.severity == .critical })
        XCTAssertTrue(diagnostics.contains { $0.id.hasPrefix("runtime_trace.local_only.") && $0.severity == .critical })
        XCTAssertFalse(diagnostics.flatMap(\.evidenceIDs).contains("command-third"))
    }

    func testProjectionInspectorIsDuplicateSafeAndReportsChecksumDrift() {
        let payload = Data(#"{"title":"Start here"}"#.utf8)
        let cursor = ProjectionCursor(
            projectionID: .today,
            eventCursor: RuntimeEventCursor(
                sequence: 1,
                eventID: "runtime.event.1",
                checksum: "event-checksum",
                occurredAt: "2026-06-30T11:32:00Z"
            ),
            checksum: "cursor-checksum",
            materializedAt: "2026-06-30T11:32:00Z"
        )
        let good = StoredProjectionRecord(
            id: .today,
            cursor: cursor,
            payloadChecksum: LocalRuntimeStorageChecksum.sha256Hex(for: payload),
            payloadSchemaVersion: "test.projection.v1",
            payloadData: payload,
            materializedAt: "2026-06-30T11:32:00Z",
            updatedAt: "2026-06-30T11:32:01Z"
        )
        let bad = StoredProjectionRecord(
            id: .today,
            cursor: cursor,
            payloadChecksum: "wrong",
            payloadSchemaVersion: "test.projection.v1",
            payloadData: payload,
            materializedAt: "2026-06-30T11:32:00Z",
            updatedAt: "2026-06-30T11:32:02Z"
        )

        let diagnostics = ProjectionInspector().inspect(
            definitions: ProjectionDefinition.allCanonical + [ProjectionDefinition.canonical(.today)],
            storedRecords: [good, bad],
            generatedAt: "2026-06-30T11:32:03Z"
        )

        XCTAssertTrue(diagnostics.contains { $0.id == "projection.definition_duplicate.today" && $0.severity == .critical })
        XCTAssertTrue(diagnostics.contains { $0.id == "projection.stored_duplicate.today" && $0.severity == .critical })
        XCTAssertTrue(diagnostics.contains { $0.id == "projection.checksum.today" && $0.severity == .critical })
    }

    func testStoreInspectorReportsDuplicateSamplesAndSchemaFailuresWithoutTrapping() {
        let manifest = LocalRuntimeStorageManifest(tiers: [
            LocalRuntimeStorageTierDescriptor(
                id: .eventStoreSQLite,
                rootPath: "Core/LocalRuntimeOS/Storage/EventStoreSQLite",
                privacyScope: .privateRuntime,
                authoritativeFor: ["runtime events"],
                excludedResponsibilities: ["object graph"]
            ),
            LocalRuntimeStorageTierDescriptor(
                id: .projectionStoreSQLite,
                rootPath: "Core/LocalRuntimeOS/Storage/ProjectionStoreSQLite",
                privacyScope: .privateRuntime,
                authoritativeFor: ["projections"],
                excludedResponsibilities: ["mutation"]
            ),
        ])
        let diagnostics = StoreInspector().inspect(
            storageManifest: manifest,
            tierSamples: [
                LocalRuntimeStoreHealthSample(tier: .eventStoreSQLite, schemaVersion: "", recordCount: 2),
                LocalRuntimeStoreHealthSample(tier: .eventStoreSQLite, schemaVersion: eventStoreSQLiteSchemaVersion, recordCount: 2),
            ],
            generatedAt: "2026-06-30T11:33:00Z"
        )

        XCTAssertTrue(diagnostics.contains { $0.id == "store.tier_duplicate.event_store_sqlite" && $0.severity == .warning })
        XCTAssertTrue(diagnostics.contains { $0.id == "store.schema_missing.event_store_sqlite" && $0.severity == .critical })
        XCTAssertTrue(diagnostics.contains { $0.id == "store.tier_missing.projection_store_sqlite" && $0.severity == .warning })
    }

    func testEventStoreSQLiteHealthSampleIncludesStoreKindCursorCountAndChecksum() {
        let cursor = RuntimeEventCursor(
            sequence: 2,
            eventID: "runtime.event.2",
            checksum: "checksum-head",
            occurredAt: "2026-06-30T11:33:30Z"
        )
        let health = EventStoreSQLiteHealth(
            schemaVersion: eventStoreSQLiteSchemaVersion,
            storeKind: .sqlite,
            eventCount: 2,
            latestCursor: cursor,
            checksumHead: "checksum-head",
            storageTier: .eventStoreSQLite
        )

        let sample = LocalRuntimeStoreHealthSample(health)

        XCTAssertEqual(sample.tier, .eventStoreSQLite)
        XCTAssertEqual(sample.recordCount, 2)
        XCTAssertEqual(sample.checksumHead, "checksum-head")
        XCTAssertTrue(sample.detail.contains("Runtime event store kind: sqlite."))
        XCTAssertTrue(sample.detail.contains("runtime.event.2"))
    }

    func testPerformanceBudgetLedgerSurfacesOverBudgetMeasurements() throws {
        let budget = AFEPQueryBudgetDescriptor(
            scope: .today,
            maximumReads: 2,
            measurementEvidenceState: .localMeasured,
            notes: "Diagnostics focused budget."
        )
        let ledger = PerformanceBudgetLedger(
            generatedAt: "2026-06-30T11:34:00Z",
            budgets: [budget],
            measurements: [
                PerformanceBudgetMeasurement(
                    scope: .today,
                    operationID: "today.projection.read",
                    observedReads: 3,
                    measuredAt: "2026-06-30T11:34:01Z"
                )
            ]
        )

        let entry = try XCTUnwrap(ledger.overBudgetEntries.first)
        XCTAssertEqual(entry.scope, .today)
        XCTAssertEqual(entry.severity, .warning)

        let diagnostics = ledger.diagnosticRecords()
        XCTAssertTrue(diagnostics.contains { $0.area == .performance && $0.severity == .warning })
        XCTAssertFalse(diagnostics.flatMap(\.evidenceIDs).contains("today.projection.read"))
    }
}

private extension LocalRuntimeDiagnosticsTests {
    func correctionEvent(id: String, localOnly: Bool) -> RuntimeEvent {
        RuntimeEvent(
            commandID: "command-\(id)",
            actor: .user,
            source: .today,
            privacy: .standard,
            localOnly: localOnly,
            occurredAt: "2026-06-30T11:31:00Z",
            payload: .correctionRecorded(
                RuntimeCorrectionEventPayload(
                    correctionID: "correction-\(id)",
                    objectID: "capture-\(id)",
                    correctionKind: "diagnostic-test"
                )
            )
        )
    }

    func repoRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath)
        while candidate.path != "/" {
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }
        throw NSError(domain: "LocalRuntimeDiagnosticsTests", code: 1)
    }
}
