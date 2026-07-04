import XCTest
@testable import Ambitions

final class RuntimeDoctorTests: XCTestCase {
    func testSeededHistoricalLedgerCreatesBlockedUpgradeMatrixForEverySwiftDataRecord() {
        let plan = MigrationPlanner().plan(
            from: .seededHistoricalV0,
            to: .current
        )

        XCTAssertEqual(plan.mutationEntries.count, SchemaLedger.current.swiftDataEntries.count)
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.action == .versionChange })
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.requiredGates == MigrationPlanEntry.requiredMutationGates })
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.executionAllowed == false })
        XCTAssertEqual(MigrationPlanValidator().validate(plan), [])
    }

    func testRecoveryAssessmentBlocksHistoricalUpgradeUntilBackupAndProofGatesExist() {
        let plan = MigrationPlanner().plan(
            from: .seededHistoricalV0,
            to: .current
        )
        let readiness = RepairPlanEngine().evaluate(
            plan: plan,
            proofs: []
        )
        let assessment = RuntimeDoctor(
            timestampProvider: { "2026-05-31T16:20:00Z" },
            idProvider: { "storage-recovery-test" }
        ).assess(
            plan: plan,
            readiness: readiness,
            preMigrationBackup: nil
        )

        XCTAssertEqual(assessment.mode, .migrationReviewRequired)
        XCTAssertTrue(assessment.canOpenRecoveryMode)
        XCTAssertFalse(assessment.canExecuteMigration)
        XCTAssertTrue(assessment.issues.contains { $0.kind == .migrationReadinessBlocked })
        XCTAssertTrue(assessment.issues.contains { $0.kind == .missingPreMigrationBackupReceipt })
        XCTAssertEqual(assessment.receipt.sourceRecordID, "SourceRecord.storage-recovery.storage-recovery-test")
        XCTAssertEqual(assessment.receipt.receiptID, "Receipt.storage-recovery.storage-recovery-test")
        XCTAssertEqual(assessment.receipt.replayTraceID, "ReplayTrace.storage-recovery.storage-recovery-test")
        XCTAssertEqual(assessment.receipt.inspectionSurfaceTitle, "Search Ambitions")
        XCTAssertFalse(assessment.receipt.migrationExecutionAllowed)
        XCTAssertFalse(assessment.receipt.destructiveResetAllowed)
    }

    func testCorruptStoreSignalOpensNonDestructiveRecoveryReview() {
        let plan = MigrationPlanner().plan(
            from: .current,
            to: .current
        )
        let readiness = RepairPlanEngine().evaluate(
            plan: plan,
            proofs: []
        )
        let assessment = RuntimeDoctor(
            timestampProvider: { "2026-05-31T16:25:00Z" },
            idProvider: { "corrupt-store-test" }
        ).assess(
            plan: plan,
            readiness: readiness,
            preMigrationBackup: nil,
            recoverySignals: [
                CorruptionQuarantineSignal(
                    id: "open",
                    kind: .corruptStoreOpenFailed,
                    message: "Simulated corrupt-store open failure."
                )
            ]
        )

        XCTAssertEqual(assessment.mode, .corruptionReviewRequired)
        XCTAssertTrue(assessment.canOpenRecoveryMode)
        XCTAssertFalse(assessment.canExecuteMigration)
        XCTAssertTrue(assessment.issues.contains { $0.kind == .corruptStoreSignal })
        XCTAssertTrue(assessment.issues.contains { $0.kind == .destructiveResetNotAuthorized })
        XCTAssertEqual(assessment.receipt.inspectionSummary, "You / Search Ambitions can inspect this storage migration source, receipt, and reason before any recovery action.")
        XCTAssertFalse(assessment.receipt.destructiveResetAllowed)
    }

    func testCommandEventReplayDriftOpensReplayRepairReview() throws {
        let plan = MigrationPlanner().plan(
            from: .current,
            to: .current
        )
        let readiness = RepairPlanEngine().evaluate(
            plan: plan,
            proofs: []
        )
        let staleRecordCommand = runtimeDoctorCommand(id: "command.record-without-event")
        let eventOnlyCommand = runtimeDoctorCommand(id: "command.event-without-record")
        let staleRecord = AmbitionsCommandExecutionRecord(
            command: staleRecordCommand,
            result: AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Receipt exists without runtime event.",
                target: AmbitionsCommandTarget(captureID: "capture-stale-record")
            ),
            recordedAt: "2026-05-31T16:30:00Z"
        )
        let eventOnlyEnvelope = try RuntimeEventEnvelope.make(
            sequence: 1,
            previousChecksum: nil,
            event: RuntimeEvent.commandExecution(
                command: eventOnlyCommand,
                result: AmbitionsCommandExecutionResult(
                    status: .succeeded,
                    summary: "Runtime event lacks materialized receipt.",
                    target: AmbitionsCommandTarget(captureID: "capture-event-only")
                ),
                recordedAt: "2026-05-31T16:31:00Z",
                commandRecordID: "command.execution.command.event-without-record"
            ),
            deviceID: "runtime-doctor-replay-drift"
        )

        let assessment = RuntimeDoctor(
            timestampProvider: { "2026-05-31T16:32:00Z" },
            idProvider: { "replay-repair-test" }
        ).assess(
            plan: plan,
            readiness: readiness,
            preMigrationBackup: nil,
            commandRecords: [staleRecord],
            runtimeEvents: [eventOnlyEnvelope]
        )

        XCTAssertEqual(assessment.mode, .replayRepairRequired)
        XCTAssertTrue(assessment.canOpenRecoveryMode)
        XCTAssertFalse(assessment.canExecuteMigration)
        XCTAssertTrue(assessment.issues.contains { $0.kind == .commandRecordMissingRuntimeEvent })
        XCTAssertTrue(assessment.issues.contains { $0.kind == .runtimeEventMissingCommandRecord })
        XCTAssertFalse(assessment.issues.contains { $0.kind == .migrationReadinessBlocked })
        XCTAssertTrue(assessment.issues.allSatisfy { $0.message.contains("runtime event") || $0.message.contains("Runtime command event") })
    }

    func testLocalDriftReadersReturnReceiptBackedPreviewPlansForEveryRequiredDomain() {
        let snapshot = RuntimeDoctorHealthSnapshot(
            generatedAt: "2026-07-01T19:00:00Z",
            readers: runtimeDoctorDriftReaders()
        )
        let assessment = RuntimeDoctor(
            timestampProvider: { "2026-07-01T19:01:00Z" },
            idProvider: { "repair-plan-test" }
        ).diagnoseLocalDrift(snapshot: snapshot)

        XCTAssertEqual(assessment.schemaVersion, runtimeDoctorRepairOperatorSchemaVersion)
        XCTAssertEqual(Set(assessment.driftSignals.map(\.domain)), Set(RuntimeDoctorHealthDomain.allCases))
        XCTAssertEqual(assessment.missingHealthDomains, [])
        XCTAssertTrue(assessment.hasRepairableDrift)
        XCTAssertFalse(assessment.canExecuteRepairs)
        XCTAssertTrue(assessment.localOnly)
        XCTAssertEqual(assessment.status, .red)

        let actions = Set(assessment.plans.map(\.action))
        XCTAssertTrue(actions.isSuperset(of: [
            .commandEventReconciliation,
            .projectionRebuild,
            .searchRebuild,
            .corruptBlobQuarantine,
            .sideEffectOutboxReconcile,
            .continuityHold,
            .privacyRedactionReview,
            .dryMigration,
            .preMigrationBackup,
            .restoreBackup,
            .restoreRollback,
            .storageInvariantCheck,
        ]))

        XCTAssertTrue(assessment.plans.allSatisfy(\.previewOnly))
        XCTAssertTrue(assessment.plans.allSatisfy(\.localOnly))
        XCTAssertTrue(assessment.plans.allSatisfy(\.requiresUserReview))
        XCTAssertTrue(assessment.plans.allSatisfy { $0.executionAllowed == false })
        XCTAssertTrue(assessment.plans.allSatisfy { $0.receipt.executionAllowed == false })
        XCTAssertTrue(assessment.plans.allSatisfy { $0.receipt.destructiveResetAllowed == false })
        XCTAssertTrue(assessment.plans.allSatisfy { $0.receipt.privatePayloadIncluded == false })
        XCTAssertTrue(assessment.plans.allSatisfy { $0.receipt.sourceRecordID.hasPrefix("SourceRecord.runtime-doctor.") })
        XCTAssertTrue(assessment.plans.allSatisfy { $0.receipt.receiptID.hasPrefix("Receipt.runtime-doctor.") })
        XCTAssertTrue(assessment.plans.allSatisfy { $0.receipt.replayTraceID.hasPrefix("ReplayTrace.runtime-doctor.") })
        XCTAssertTrue(assessment.plans.allSatisfy { $0.beforeProof.stage == .before })
        XCTAssertTrue(assessment.plans.allSatisfy { $0.expectedAfterProof.stage == .expectedAfter })
        XCTAssertTrue(assessment.plans.allSatisfy { $0.beforeProof.evidenceIDs.isEmpty == false })
        XCTAssertTrue(assessment.plans.allSatisfy { $0.expectedAfterProof.evidenceIDs.isEmpty == false })
    }

    func testYouDiagnosticsAreRedactedLocalOnlyAndDoNotExposePrivatePayloads() {
        let readers = RuntimeDoctorHealthReaders()
        let privateRecord = RuntimeDoctorTests.runtimeDoctorDiagnostic(
            id: "privacy.private_payload",
            area: .privacy,
            severity: .critical,
            summary: "Email devan@example.com about goal.secret-12345",
            detail: "Call 555-010-2222 about capture.private-99999 and 01234567-89AB-CDEF-0123-456789ABCDEF.",
            evidenceID: "goal.secret-12345",
            privacy: .privateSensitive
        )
        let snapshot = RuntimeDoctorHealthSnapshot(
            generatedAt: "2026-07-01T19:05:00Z",
            readers: [
                readers.privacyBoundary(
                    diagnostics: [privateRecord],
                    evidenceIDs: ["privacy-boundary-reader"],
                    generatedAt: "2026-07-01T19:05:00Z"
                )
            ]
        )

        let assessment = RuntimeDoctor(
            timestampProvider: { "2026-07-01T19:06:00Z" },
            idProvider: { "redaction-test" }
        ).diagnoseLocalDrift(snapshot: snapshot)

        let lines = assessment.youDiagnosticLines.joined(separator: "\n")
        XCTAssertTrue(assessment.plans.allSatisfy(\.localOnly))
        XCTAssertTrue(lines.contains("[redacted-email]"))
        XCTAssertFalse(lines.contains("devan@example.com"))
        XCTAssertFalse(lines.contains("555-010-2222"))
        XCTAssertFalse(lines.contains("capture.private-99999"))
        XCTAssertFalse(lines.contains("01234567-89AB-CDEF-0123-456789ABCDEF"))
        XCTAssertFalse(lines.contains("goal.secret-12345"))
        XCTAssertTrue(lines.contains("No private details leave this device."))
    }

    func testHealthyRuntimeDoctorReadersDoNotAuthorizeRepairExecution() {
        let snapshot = RuntimeDoctorHealthSnapshot(
            generatedAt: "2026-07-01T19:10:00Z",
            readers: RuntimeDoctorHealthDomain.allCases.map { domain in
                RuntimeDoctorHealthReader(
                    domain: domain,
                    componentID: "HealthyRuntimeDoctorHealthReader",
                    diagnostics: [
                        RuntimeDoctorTests.runtimeDoctorDiagnostic(
                            id: "healthy.\(domain.rawValue)",
                            severity: .healthy,
                            summary: "Healthy local diagnostic for \(domain.rawValue).",
                            detail: "No repair needed.",
                            evidenceID: domain.rawValue
                        )
                    ],
                    generatedAt: "2026-07-01T19:10:00Z"
                )
            }
        )

        let assessment = RuntimeDoctor(
            timestampProvider: { "2026-07-01T19:11:00Z" },
            idProvider: { "healthy-test" }
        ).diagnoseLocalDrift(snapshot: snapshot)

        XCTAssertEqual(assessment.status, .green)
        XCTAssertFalse(assessment.hasRepairableDrift)
        XCTAssertFalse(assessment.canExecuteRepairs)
        XCTAssertEqual(assessment.plans, [])
        XCTAssertEqual(assessment.youDiagnosticLines, [])
    }
}

private extension RuntimeDoctorTests {
    func runtimeDoctorCommand(id: String) -> AmbitionsCommand {
        AmbitionsCommand(
            id: id,
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Runtime doctor drift fixture"),
            createdAt: "2026-05-31T16:30:00Z",
            actor: .user,
            sourceSurface: "today"
        )
    }

    func runtimeDoctorDriftReaders() -> [RuntimeDoctorHealthReader] {
        let readers = RuntimeDoctorHealthReaders()
        let generatedAt = "2026-07-01T19:00:00Z"
        return [
            readers.commandJournal(
                diagnostics: [
                    RuntimeDoctorTests.runtimeDoctorDiagnostic(
                        id: "command.journal_link_missing_event.fixture",
                        area: .command,
                        severity: .critical,
                        summary: "Command journal link is missing runtime event.",
                        detail: "Runtime event linkage drift.",
                        evidenceID: "command.missing-event"
                    )
                ],
                evidenceIDs: ["command-journal-reader"],
                generatedAt: generatedAt
            ),
            readers.eventStore(
                diagnostics: [
                    RuntimeDoctorTests.runtimeDoctorDiagnostic(
                        id: "event.cursor_gap.fixture",
                        area: .runtimeTrace,
                        severity: .critical,
                        summary: "Runtime event cursor has a gap.",
                        detail: "Append-only replay cursor drift.",
                        evidenceID: "event.cursor-gap"
                    )
                ],
                evidenceIDs: ["event-store-reader"],
                generatedAt: generatedAt
            ),
            readers.projectionStore(
                diagnostics: [
                    RuntimeDoctorTests.runtimeDoctorDiagnostic(
                        id: "projection.checksum.today",
                        area: .projection,
                        severity: .critical,
                        summary: "Projection checksum drift.",
                        detail: "Projection must be rebuilt from runtime events.",
                        evidenceID: "projection.today"
                    )
                ],
                evidenceIDs: ["projection-store-reader"],
                generatedAt: generatedAt
            ),
            readers.searchIndex(
                diagnostics: [
                    RuntimeDoctorTests.runtimeDoctorDiagnostic(
                        id: "search.index_stale.fixture",
                        area: .store,
                        severity: .warning,
                        summary: "Search index is stale.",
                        detail: "Search rebuild needs sanitized projection input.",
                        evidenceID: "search.index"
                    )
                ],
                evidenceIDs: ["search-index-reader"],
                generatedAt: generatedAt
            ),
            readers.blobVault(
                diagnostics: [
                    RuntimeDoctorTests.runtimeDoctorDiagnostic(
                        id: "blob.corrupt.fixture",
                        area: .store,
                        severity: .critical,
                        summary: "Blob checksum mismatch.",
                        detail: "Private attachment must be quarantined.",
                        evidenceID: "blob.corrupt"
                    )
                ],
                evidenceIDs: ["blob-vault-reader"],
                generatedAt: generatedAt
            ),
            readers.sideEffectOutbox(
                diagnostics: [
                    RuntimeDoctorTests.runtimeDoctorDiagnostic(
                        id: "side_effect.outbox_without_receipt.fixture",
                        area: .store,
                        severity: .critical,
                        summary: "External handoff lacks local receipt.",
                        detail: "Outbox item must not attempt an external effect.",
                        evidenceID: "side-effect.outbox"
                    )
                ],
                evidenceIDs: ["side-effect-reader"],
                generatedAt: generatedAt
            ),
            readers.continuity(
                diagnostics: [
                    RuntimeDoctorTests.runtimeDoctorDiagnostic(
                        id: "sync.private_graph_capture.fixture",
                        area: .sync,
                        severity: .critical,
                        summary: "Sync continuity attempted private graph capture.",
                        detail: "Continuity must remain metadata-only.",
                        evidenceID: "sync.private-graph"
                    )
                ],
                evidenceIDs: ["sync-reader"],
                generatedAt: generatedAt
            ),
            readers.privacyBoundary(
                diagnostics: [
                    RuntimeDoctorTests.runtimeDoctorDiagnostic(
                        id: "privacy.diagnostic_redaction.fixture",
                        area: .privacy,
                        severity: .critical,
                        summary: "Diagnostic redaction failed.",
                        detail: "Private detail must be regenerated through the redactor.",
                        evidenceID: "privacy.redaction"
                    )
                ],
                evidenceIDs: ["privacy-reader"],
                generatedAt: generatedAt
            ),
            readers.migrationState(
                diagnostics: [
                    RuntimeDoctorTests.runtimeDoctorDiagnostic(
                        id: "migration.readiness.fixture",
                        area: .store,
                        severity: .critical,
                        summary: "Migration readiness is blocked.",
                        detail: "Dry migration, backup, restore, and rollback review required.",
                        evidenceID: "migration.readiness"
                    )
                ],
                evidenceIDs: ["migration-reader"],
                generatedAt: generatedAt
            ),
            readers.storageTier(
                diagnostics: [
                    RuntimeDoctorTests.runtimeDoctorDiagnostic(
                        id: "store.schema_missing.event_store_sqlite",
                        area: .store,
                        severity: .critical,
                        summary: "Storage tier schema is missing.",
                        detail: "Storage invariant check required.",
                        evidenceID: "storage.schema"
                    )
                ],
                evidenceIDs: ["storage-reader"],
                generatedAt: generatedAt
            ),
        ]
    }

    static func runtimeDoctorDiagnostic(
        id: String,
        area: LocalRuntimeDiagnosticArea = .store,
        severity: LocalRuntimeDiagnosticSeverity,
        summary: String,
        detail: String,
        evidenceID: String,
        privacy: RuntimePrivacyClass = .systemOwned
    ) -> LocalRuntimeDiagnosticRecord {
        LocalRuntimeDiagnosticRecord(
            id: id,
            area: area,
            componentID: "RuntimeDoctorTests",
            severity: severity,
            summary: summary,
            detail: detail,
            repairHint: "Preview a local RuntimeDoctor repair plan.",
            evidenceIDs: [evidenceID],
            privacy: privacy,
            generatedAt: "2026-07-01T19:00:00Z"
        )
    }
}
