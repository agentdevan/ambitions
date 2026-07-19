import XCTest
@testable import Ambitions

final class ScheduleInstallKernelTests: XCTestCase {
    func testCommittedInstallBuildsPreviewReceiptRollbackAndRuntimeSegment() throws {
        let record = ScheduleInstallKernel().evaluate(defaultInput())

        XCTAssertTrue(record.canDriveScheduleInstallSegment)
        XCTAssertEqual(record.issues, [])

        let preview = try XCTUnwrap(record.preview)
        XCTAssertEqual(preview.selectedVariantID, "variant.shrink")
        XCTAssertEqual(preview.selectedWindowID, "window.open.morning")
        XCTAssertEqual(preview.candidateWindows.map(\.id), ["window.open.morning", "window.open.midday", "window.protected.family"])
        XCTAssertEqual(preview.protectedWindowIDs, ["window.protected.family"])
        XCTAssertTrue(preview.sourceRecordIDs.contains("SourceRecord.elasticity.shrink"))
        XCTAssertTrue(preview.sourceRecordIDs.contains("SourceRecord.window.open.morning"))
        XCTAssertTrue(preview.receiptIDs.contains("Receipt.protected.boundary"))
        XCTAssertTrue(preview.replayTraceIDs.contains("ReplayTrace.window.open.morning"))
        XCTAssertTrue(preview.whatAmbitionsKnowsRoutes.contains("you://what-ambitions-knows/protected-time"))

        let receipt = try XCTUnwrap(record.installReceipt)
        XCTAssertEqual(receipt.selectedVariantID, "variant.shrink")
        XCTAssertEqual(receipt.selectedWindowID, "window.open.morning")
        XCTAssertEqual(receipt.decisionReceiptID, "Receipt.decision.commit")
        XCTAssertTrue(receipt.receiptIDs.contains(receipt.id))
        XCTAssertTrue(receipt.sourceRecordIDs.contains("SourceRecord.rollback"))
        XCTAssertTrue(receipt.reversible)
        XCTAssertTrue(receipt.localOnly)

        let rollback = try XCTUnwrap(record.rollbackTrace)
        XCTAssertEqual(rollback.previousScheduleSnapshotID, "schedule.snapshot.before")
        XCTAssertEqual(rollback.rollbackReceiptID, "Receipt.rollback.plan")
        XCTAssertTrue(rollback.receiptIDs.contains("Receipt.rollback.plan"))
        XCTAssertTrue(rollback.reversible)
        XCTAssertTrue(rollback.localOnly)

        XCTAssertEqual(record.trace.previewID, preview.id)
        XCTAssertEqual(record.trace.installReceiptID, receipt.id)
        XCTAssertEqual(record.trace.rollbackTraceID, rollback.id)
        XCTAssertEqual(record.trace.issueIDs, [])
        XCTAssertTrue(record.trace.replayTraceIDs.contains("ReplayTrace.rollback"))

        XCTAssertEqual(record.runtimeCoreSegment.kind, .scheduleInstall)
        XCTAssertEqual(record.runtimeCoreSegment.state, .ready)
        XCTAssertEqual(record.runtimeCoreSegment.replayTraceID, record.trace.id)
        XCTAssertFalse(record.runtimeCoreSegment.blocksDownstream)
        XCTAssertTrue(record.runtimeCoreSegment.canDriveVisibleExecution)
        XCTAssertTrue(record.runtimeCoreSegment.isReversible)
    }

    func testPreviewAndReceiptsStayDeterministicAcrossWindowOrdering() {
        let first = ScheduleInstallKernel().evaluate(defaultInput())
        let second = ScheduleInstallKernel().evaluate(
            defaultInput(candidateWindows: Array(timeWindows().reversed()))
        )

        XCTAssertEqual(first.preview, second.preview)
        XCTAssertEqual(first.installReceipt, second.installReceipt)
        XCTAssertEqual(first.rollbackTrace, second.rollbackTrace)
        XCTAssertEqual(first.trace, second.trace)
        XCTAssertEqual(first.runtimeCoreSegment, second.runtimeCoreSegment)
    }

    func testBlockedElasticityDoesNotCreatePreviewOrInstallReceipt() {
        let record = ScheduleInstallKernel().evaluate(
            defaultInput(elasticityRecord: blockedElasticityRecord())
        )

        XCTAssertFalse(record.canDriveScheduleInstallSegment)
        XCTAssertTrue(record.issues.contains(.elasticityBlocked))
        XCTAssertTrue(record.issues.contains(.missingSchedulePreview))
        XCTAssertNil(record.preview)
        XCTAssertNil(record.installReceipt)
        XCTAssertNil(record.rollbackTrace)
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
        XCTAssertTrue(record.runtimeCoreSegment.blocksDownstream)
    }

    func testPreviewOnlyStateDoesNotInstallWithoutExplicitCommitDecision() {
        let record = ScheduleInstallKernel().evaluate(defaultInput(decision: nil))

        XCTAssertFalse(record.canDriveScheduleInstallSegment)
        XCTAssertNotNil(record.preview)
        XCTAssertTrue(record.issues.contains(.missingCommitDecision))
        XCTAssertTrue(record.issues.contains(.missingSelectedWindow))
        XCTAssertNil(record.installReceipt)
        XCTAssertNil(record.rollbackTrace)
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
    }

    func testProtectedTimeSelectionIsBlockedEvenWithVisibleProof() {
        let record = ScheduleInstallKernel().evaluate(
            defaultInput(
                decision: commitDecision(selectedWindowID: "window.protected.family")
            )
        )

        XCTAssertFalse(record.canDriveScheduleInstallSegment)
        XCTAssertTrue(record.issues.contains(.protectedTimeConflict))
        XCTAssertFalse(record.issues.contains(.missingProtectedTimeProof))
        XCTAssertNil(record.installReceipt)
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
    }

    func testMissingRollbackPlanBlocksCommit() {
        let record = ScheduleInstallKernel().evaluate(defaultInput(rollbackPlan: nil))

        XCTAssertFalse(record.canDriveScheduleInstallSegment)
        XCTAssertTrue(record.issues.contains(.missingRollbackTrace))
        XCTAssertNotNil(record.preview)
        XCTAssertNil(record.installReceipt)
        XCTAssertNil(record.rollbackTrace)
        XCTAssertTrue(record.runtimeCoreSegment.blocksDownstream)
    }

    func testSilentTimeMutationAndNonLocalDecisionAreBlocked() {
        let record = ScheduleInstallKernel().evaluate(
            defaultInput(
                decision: commitDecision(localOnly: false, silentlyMutatesTime: true),
                localOnly: false
            )
        )

        XCTAssertFalse(record.canDriveScheduleInstallSegment)
        XCTAssertTrue(record.issues.contains(.silentTimeMutation))
        XCTAssertTrue(record.issues.contains(.nonLocalRuntimeBoundary))
        XCTAssertTrue(record.issues.contains(.opaqueInstall))
        XCTAssertNil(record.installReceipt)
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
    }
}

private extension ScheduleInstallKernelTests {
    func defaultInput(
        elasticityRecord: StepElasticityRecord? = nil,
        selectedVariantID: String? = "variant.shrink",
        candidateWindows: [ScheduleInstallTimeWindow]? = nil,
        decision: ScheduleInstallDecision? = ScheduleInstallKernelTests.commitDecision(),
        rollbackPlan: ScheduleInstallRollbackPlan? = ScheduleInstallKernelTests.rollbackPlan(),
        protectedTimeProof: ScheduleInstallProtectedTimeProof? = ScheduleInstallKernelTests.protectedTimeProof(),
        localOnly: Bool = true
    ) -> ScheduleInstallInput {
        ScheduleInstallInput(
            elasticityRecord: elasticityRecord ?? self.elasticityRecord(),
            selectedVariantID: selectedVariantID,
            candidateWindows: candidateWindows ?? timeWindows(),
            decision: decision,
            rollbackPlan: rollbackPlan,
            protectedTimeProof: protectedTimeProof,
            evaluatedAt: "2026-06-14T16:30:00Z",
            localOnly: localOnly
        )
    }

    func elasticityRecord() -> StepElasticityRecord {
        let variants = StepElasticityActionKind.allCases.map { kind in
            StepElasticityVariant(
                id: "variant.\(kind.rawValue.replacingOccurrences(of: "_", with: "-"))",
                kind: kind,
                title: title(for: kind),
                summary: "Inspectable elastic action.",
                reason: "Keeps the selected path local and proof-bound.",
                sourceNodeID: "node.\(kind.rawValue)",
                replacementNodeID: kind == .replace ? "node.reserve" : nil,
                durationMinutes: kind == .shrink ? 20 : nil,
                sourceRecordIDs: ["SourceRecord.elasticity.\(kind.rawValue)"],
                receiptIDs: ["Receipt.elasticity.\(kind.rawValue)"],
                replayTraceID: "ReplayTrace.elasticity.\(kind.rawValue)",
                whatAmbitionsKnowsRoute: "you://what-ambitions-knows/elasticity/\(kind.rawValue)",
                preservesProof: true,
                preservesPartialProgress: kind == .stillCounts,
                recoverySafe: kind == .stillCounts || kind == .shrink,
                requiresUserApproval: true,
                silentlyMutatesPlan: false,
                localOnly: true
            )
        }
        let receipts = variants.map { variant in
            StepElasticityActionReceipt(
                id: "Receipt.elasticity.action.\(variant.kind.rawValue)",
                actionKind: variant.kind,
                variantID: variant.id,
                actionTaken: variant.title,
                affectedNodeID: variant.sourceNodeID,
                sourceRecordIDs: variant.sourceRecordIDs,
                receiptIDs: variant.receiptIDs + ["Receipt.elasticity.action.\(variant.kind.rawValue)"],
                replayTraceID: variant.replayTraceID ?? "ReplayTrace.elasticity.\(variant.kind.rawValue)",
                whatAmbitionsKnowsRoute: variant.whatAmbitionsKnowsRoute ?? "you://what-ambitions-knows/elasticity",
                partialProgressProofID: variant.kind == .stillCounts ? "PartialProgress.release.001" : nil,
                createdAt: "2026-06-14T16:20:00Z",
                reversible: true,
                localOnly: true
            )
        }
        return StepElasticityRecord(
            id: "elasticity.record.ready",
            goalReferenceID: "goal.release",
            graphSnapshotID: "graph.snapshot.primary",
            variants: variants,
            receipts: receipts,
            copyValidation: StepElasticityCopyValidation(
                inspectedVariantIDs: variants.map(\.id).sorted(),
                shameLanguageDetected: false,
                falseCompletionLanguageDetected: false,
                blockedTerms: [],
                localOnly: true
            ),
            trace: StepElasticityActionTrace(
                id: "ReplayTrace.elasticity.record",
                goalReferenceID: "goal.release",
                graphSnapshotID: "graph.snapshot.primary",
                variantIDs: variants.map(\.id).sorted(),
                receiptIDs: receipts.map(\.id).sorted(),
                issueIDs: [],
                replayTraceIDs: variants.compactMap(\.replayTraceID).sorted(),
                fingerprint: "elasticity.fingerprint.ready",
                localOnly: true
            ),
            issues: []
        )
    }

    func blockedElasticityRecord() -> StepElasticityRecord {
        StepElasticityRecord(
            id: "elasticity.record.blocked",
            goalReferenceID: "goal.release",
            graphSnapshotID: nil,
            variants: [],
            receipts: [],
            copyValidation: StepElasticityCopyValidation(
                inspectedVariantIDs: [],
                shameLanguageDetected: false,
                falseCompletionLanguageDetected: false,
                blockedTerms: [],
                localOnly: true
            ),
            trace: StepElasticityActionTrace(
                id: "ReplayTrace.elasticity.blocked",
                goalReferenceID: "goal.release",
                graphSnapshotID: nil,
                variantIDs: [],
                receiptIDs: [],
                issueIDs: [StepElasticityIssue.graphCompilerBlocked.rawValue],
                replayTraceIDs: [],
                fingerprint: "elasticity.fingerprint.blocked",
                localOnly: true
            ),
            issues: [.graphCompilerBlocked]
        )
    }

    func timeWindows() -> [ScheduleInstallTimeWindow] {
        [
            timeWindow(id: "window.open.midday", label: "Midday open block", startAt: "2026-06-15T16:00:00Z", endAt: "2026-06-15T16:30:00Z", isProtectedTime: false),
            timeWindow(id: "window.protected.family", label: "Family protected block", startAt: "2026-06-15T22:00:00Z", endAt: "2026-06-15T22:30:00Z", isProtectedTime: true),
            timeWindow(id: "window.open.morning", label: "Morning open block", startAt: "2026-06-15T13:00:00Z", endAt: "2026-06-15T13:30:00Z", isProtectedTime: false)
        ]
    }

    func timeWindow(
        id: String,
        label: String,
        startAt: String,
        endAt: String,
        isProtectedTime: Bool
    ) -> ScheduleInstallTimeWindow {
        ScheduleInstallTimeWindow(
            id: id,
            label: label,
            startAt: startAt,
            endAt: endAt,
            durationMinutes: 30,
            isProtectedTime: isProtectedTime,
            sourceRecordIDs: ["SourceRecord.\(id)"],
            receiptIDs: ["Receipt.\(id)"],
            replayTraceID: "ReplayTrace.\(id)",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/\(id)"
        )
    }

    static func commitDecision(
        selectedWindowID: String = "window.open.morning",
        localOnly: Bool = true,
        silentlyMutatesTime: Bool = false
    ) -> ScheduleInstallDecision {
        ScheduleInstallDecision(
            kind: .commit,
            selectedWindowID: selectedWindowID,
            userApproved: true,
            decisionReceiptID: "Receipt.decision.commit",
            decidedAt: "2026-06-14T16:25:00Z",
            sourceRecordIDs: ["SourceRecord.decision.commit"],
            receiptIDs: ["Receipt.decision.preview", "Receipt.decision.commit"],
            replayTraceID: "ReplayTrace.decision.commit",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/schedule-decision",
            localOnly: localOnly,
            silentlyMutatesTime: silentlyMutatesTime
        )
    }

    func commitDecision(
        selectedWindowID: String = "window.open.morning",
        localOnly: Bool = true,
        silentlyMutatesTime: Bool = false
    ) -> ScheduleInstallDecision {
        Self.commitDecision(
            selectedWindowID: selectedWindowID,
            localOnly: localOnly,
            silentlyMutatesTime: silentlyMutatesTime
        )
    }

    static func rollbackPlan() -> ScheduleInstallRollbackPlan {
        ScheduleInstallRollbackPlan(
            id: "rollback.plan.primary",
            previousScheduleSnapshotID: "schedule.snapshot.before",
            rollbackReceiptID: "Receipt.rollback.plan",
            sourceRecordIDs: ["SourceRecord.rollback"],
            receiptIDs: ["Receipt.rollback.plan"],
            replayTraceID: "ReplayTrace.rollback",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/schedule-rollback"
        )
    }

    static func protectedTimeProof() -> ScheduleInstallProtectedTimeProof {
        ScheduleInstallProtectedTimeProof(
            id: "protected-time.proof.primary",
            protectedWindowIDs: ["window.protected.family"],
            sourceRecordIDs: ["SourceRecord.protected.boundary"],
            receiptIDs: ["Receipt.protected.boundary"],
            replayTraceID: "ReplayTrace.protected.boundary",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/protected-time"
        )
    }

    func title(for kind: StepElasticityActionKind) -> String {
        switch kind {
        case .shrink:
            return "Shrink"
        case .replace:
            return "Replace"
        case .keepMomentum:
            return "Keep momentum"
        case .stillCounts:
            return "Still Counts"
        }
    }
}
