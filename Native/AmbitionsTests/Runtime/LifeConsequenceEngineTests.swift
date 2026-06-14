import XCTest
@testable import Ambitions

final class LifeConsequenceEngineTests: XCTestCase {
    func testTreatyAwareCrossGoalReflowBuildsReceiptsTraceAndRuntimeSegment() throws {
        let record = LifeConsequenceEngine().evaluate(defaultInput())

        XCTAssertTrue(record.canDriveConsequenceReflowSegment)
        XCTAssertEqual(record.issues, [])
        XCTAssertEqual(record.highestSeverity, .warn)
        XCTAssertEqual(record.receipts.map(\.affectedGoalID), ["goal.debt-review", "goal.release"])
        XCTAssertTrue(record.receipts.allSatisfy { $0.visibility == .reviewRequired })
        XCTAssertTrue(record.receipts.allSatisfy(\.reversible))
        XCTAssertTrue(record.receipts.allSatisfy(\.localOnly))
        XCTAssertTrue(record.receipts.flatMap(\.sourceRecordIDs).contains("SourceRecord.schedule.install"))
        XCTAssertTrue(record.receipts.flatMap(\.receiptIDs).contains("Receipt.schedule.install"))

        let treatyOutput = try XCTUnwrap(record.treatyOutputs.first)
        XCTAssertEqual(treatyOutput.treatyID, "treaty.deep-work")
        XCTAssertTrue(treatyOutput.affectedGoalIDs.contains("goal.release"))
        XCTAssertTrue(treatyOutput.affectedGoalIDs.contains("goal.debt-review"))
        XCTAssertEqual(treatyOutput.severity, .warn)
        XCTAssertTrue(treatyOutput.violated)

        XCTAssertEqual(record.trace.scheduleInstallTraceID, "ReplayTrace.schedule.install")
        XCTAssertEqual(record.trace.receiptIDs, record.receipts.map(\.id).sorted())
        XCTAssertTrue(record.trace.replayTraceIDs.contains("ReplayTrace.impact.debt"))
        XCTAssertTrue(record.trace.treatyOutputIDs.contains(treatyOutput.id))

        XCTAssertEqual(record.runtimeCoreSegment.kind, .consequenceReflow)
        XCTAssertEqual(record.runtimeCoreSegment.state, .ready)
        XCTAssertEqual(record.runtimeCoreSegment.replayTraceID, record.trace.id)
        XCTAssertTrue(record.runtimeCoreSegment.canDriveVisibleExecution)
        XCTAssertFalse(record.runtimeCoreSegment.blocksDownstream)
        XCTAssertTrue(record.runtimeCoreSegment.isReversible)
    }

    func testReceiptsAndTraceStayDeterministicAcrossInputOrdering() {
        let first = LifeConsequenceEngine().evaluate(defaultInput())
        let second = LifeConsequenceEngine().evaluate(
            defaultInput(
                impacts: Array(impacts().reversed()),
                treaties: Array(treaties().reversed())
            )
        )

        XCTAssertEqual(first.receipts, second.receipts)
        XCTAssertEqual(first.treatyOutputs, second.treatyOutputs)
        XCTAssertEqual(first.trace, second.trace)
        XCTAssertEqual(first.runtimeCoreSegment, second.runtimeCoreSegment)
    }

    func testBlockedScheduleInstallFailsClosedWithoutConsequenceReceipts() {
        let record = LifeConsequenceEngine().evaluate(
            defaultInput(scheduleInstallRecord: blockedScheduleInstallRecord())
        )

        XCTAssertFalse(record.canDriveConsequenceReflowSegment)
        XCTAssertTrue(record.issues.contains(.scheduleInstallBlocked))
        XCTAssertTrue(record.issues.contains(.missingScheduleInstallReceipt))
        XCTAssertTrue(record.issues.contains(.missingRollbackTrace))
        XCTAssertEqual(record.receipts, [])
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
        XCTAssertTrue(record.runtimeCoreSegment.blocksDownstream)
    }

    func testQuietPreferenceCannotHideNonSuppressibleDeadlineImpossibleEvent() {
        let hiddenDeadline = impact(
            id: "impact.deadline.impossible",
            affectedGoalID: "goal.debt-review",
            affectedGoalTitle: "Debt review",
            trigger: .deadlineChange,
            deadlineMinutesDelta: 260,
            proofValueDelta: -80,
            userVisible: false
        )
        let record = LifeConsequenceEngine().evaluate(
            defaultInput(impacts: [hiddenDeadline], visibilityPreference: .quiet)
        )

        XCTAssertFalse(record.canDriveConsequenceReflowSegment)
        XCTAssertEqual(record.highestSeverity, .impossible)
        XCTAssertTrue(record.issues.contains(.deadlineImpossible))
        XCTAssertTrue(record.issues.contains(.nonSuppressibleEventHidden))
        XCTAssertTrue(record.issues.contains(.hiddenConsequenceMutation))
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
    }

    func testTreatyBlockAndProtectedTimeBreakBlockDownstreamRuntime() {
        let sleepImpact = impact(
            id: "impact.sleep.protected",
            affectedGoalID: "goal.sleep",
            affectedGoalTitle: "Sleep protection",
            trigger: .protectedTimeChange,
            densityMinutesDelta: 45,
            protectedTimeBroken: true,
            treatyIDs: ["treaty.sleep"],
            sourceRecordIDs: ["SourceRecord.impact.sleep"],
            receiptIDs: ["Receipt.impact.sleep"],
            replayTraceID: "ReplayTrace.impact.sleep",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/impact/sleep"
        )
        let record = LifeConsequenceEngine().evaluate(
            defaultInput(impacts: [sleepImpact], treaties: [sleepTreaty()])
        )

        XCTAssertFalse(record.canDriveConsequenceReflowSegment)
        XCTAssertEqual(record.highestSeverity, .block)
        XCTAssertTrue(record.issues.contains(.protectedTimeBroken))
        XCTAssertTrue(record.issues.contains(.treatyBlocked))
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
        XCTAssertTrue(record.runtimeCoreSegment.blocksDownstream)
    }

    func testMissingProofReferencesBlockMaterialReflowReceipt() {
        let missingProof = impact(
            id: "impact.missing-proof",
            affectedGoalID: "goal.release",
            affectedGoalTitle: "Music release",
            trigger: .scheduleInstall,
            deadlineMinutesDelta: 60,
            sourceRecordIDs: [],
            receiptIDs: [],
            replayTraceID: nil,
            whatAmbitionsKnowsRoute: nil
        )
        let record = LifeConsequenceEngine().evaluate(
            defaultInput(impacts: [missingProof], treaties: [])
        )

        XCTAssertFalse(record.canDriveConsequenceReflowSegment)
        XCTAssertTrue(record.issues.contains(.missingSourceRecord))
        XCTAssertTrue(record.issues.contains(.missingReceipt))
        XCTAssertTrue(record.issues.contains(.missingReplayTrace))
        XCTAssertTrue(record.issues.contains(.missingInspectionRoute))
        XCTAssertEqual(record.receipts, [])
    }

    func testNonLocalOrIrreversibleMaterialReflowIsBlocked() {
        let unsafeImpact = impact(
            id: "impact.nonlocal",
            affectedGoalID: "goal.release",
            affectedGoalTitle: "Music release",
            trigger: .sourceChange,
            deadlineMinutesDelta: 45,
            localOnly: false,
            reversible: false
        )
        let record = LifeConsequenceEngine().evaluate(
            defaultInput(impacts: [unsafeImpact], localOnly: false)
        )

        XCTAssertFalse(record.canDriveConsequenceReflowSegment)
        XCTAssertTrue(record.issues.contains(.nonLocalRuntimeBoundary))
        XCTAssertTrue(record.issues.contains(.irreversibleReflow))
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
    }
}

private extension LifeConsequenceEngineTests {
    func defaultInput(
        scheduleInstallRecord: ScheduleInstallRecord? = nil,
        impacts: [LifeConsequenceImpact]? = nil,
        treaties: [LifeConsequenceGoalTreaty]? = nil,
        visibilityPreference: LifeConsequenceVisibilityPreference = .balanced,
        localOnly: Bool = true
    ) -> LifeConsequenceEngineInput {
        LifeConsequenceEngineInput(
            scheduleInstallRecord: scheduleInstallRecord ?? readyScheduleInstallRecord(),
            impacts: impacts ?? self.impacts(),
            treaties: treaties ?? self.treaties(),
            visibilityPreference: visibilityPreference,
            evaluatedAt: "2026-06-14T17:00:00Z",
            localOnly: localOnly
        )
    }

    func impacts() -> [LifeConsequenceImpact] {
        [
            impact(
                id: "impact.release",
                affectedGoalID: "goal.release",
                affectedGoalTitle: "Music release",
                trigger: .scheduleInstall,
                deadlineMinutesDelta: 35,
                densityMinutesDelta: 20,
                proofValueDelta: -5,
                dependencyIDs: ["dep.master-upload"],
                treatyIDs: ["treaty.deep-work"],
                sourceRecordIDs: ["SourceRecord.impact.release"],
                receiptIDs: ["Receipt.impact.release"],
                replayTraceID: "ReplayTrace.impact.release",
                whatAmbitionsKnowsRoute: "you://what-ambitions-knows/impact/release"
            ),
            impact(
                id: "impact.debt",
                affectedGoalID: "goal.debt-review",
                affectedGoalTitle: "Debt review",
                trigger: .availabilityChange,
                deadlineMinutesDelta: 95,
                densityMinutesDelta: 65,
                proofValueDelta: -20,
                recoveryImpact: .heavy,
                materialDisplacement: true,
                treatyIDs: ["treaty.deep-work"],
                sourceRecordIDs: ["SourceRecord.impact.debt"],
                receiptIDs: ["Receipt.impact.debt"],
                replayTraceID: "ReplayTrace.impact.debt",
                whatAmbitionsKnowsRoute: "you://what-ambitions-knows/impact/debt"
            )
        ]
    }

    func treaties() -> [LifeConsequenceGoalTreaty] {
        [
            LifeConsequenceGoalTreaty(
                id: "treaty.deep-work",
                title: "Evening deep-work treaty",
                participatingGoalIDs: ["goal.release", "goal.debt-review"],
                protectedGoalID: "goal.release",
                constraintSummary: "Music keeps the protected evening block while debt review stays visible.",
                violationSeverity: .warn,
                sourceRecordIDs: ["SourceRecord.treaty.deep-work"],
                receiptIDs: ["Receipt.treaty.deep-work"],
                replayTraceID: "ReplayTrace.treaty.deep-work",
                whatAmbitionsKnowsRoute: "you://what-ambitions-knows/treaty/deep-work"
            )
        ]
    }

    func sleepTreaty() -> LifeConsequenceGoalTreaty {
        LifeConsequenceGoalTreaty(
            id: "treaty.sleep",
            title: "Sleep protection treaty",
            participatingGoalIDs: ["goal.sleep", "goal.release"],
            protectedGoalID: "goal.sleep",
            constraintSummary: "Sleep protection wins after 10:30.",
            violationSeverity: .block,
            sourceRecordIDs: ["SourceRecord.treaty.sleep"],
            receiptIDs: ["Receipt.treaty.sleep"],
            replayTraceID: "ReplayTrace.treaty.sleep",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/treaty/sleep"
        )
    }

    func impact(
        id: String,
        affectedGoalID: String,
        affectedGoalTitle: String,
        trigger: LifeConsequenceTrigger,
        deadlineMinutesDelta: Int = 0,
        densityMinutesDelta: Int = 0,
        proofValueDelta: Int = 0,
        dependencyIDs: [String] = [],
        protectedTimeBroken: Bool = false,
        sourceAuthority: LifeConsequenceSourceAuthorityState = .current,
        recoveryImpact: LifeConsequenceRecoveryImpact = .none,
        materialDisplacement: Bool = false,
        highRiskReviewRequired: Bool = false,
        unsafeState: Bool = false,
        scheduleInstallFailure: Bool = false,
        treatyIDs: [String] = [],
        sourceRecordIDs: [String] = ["SourceRecord.impact.default"],
        receiptIDs: [String] = ["Receipt.impact.default"],
        replayTraceID: String? = "ReplayTrace.impact.default",
        whatAmbitionsKnowsRoute: String? = "you://what-ambitions-knows/impact/default",
        userVisible: Bool = true,
        localOnly: Bool = true,
        reversible: Bool = true
    ) -> LifeConsequenceImpact {
        LifeConsequenceImpact(
            id: id,
            affectedGoalID: affectedGoalID,
            affectedGoalTitle: affectedGoalTitle,
            trigger: trigger,
            deadlineMinutesDelta: deadlineMinutesDelta,
            densityMinutesDelta: densityMinutesDelta,
            proofValueDelta: proofValueDelta,
            dependencyIDs: dependencyIDs,
            protectedTimeBroken: protectedTimeBroken,
            sourceAuthority: sourceAuthority,
            recoveryImpact: recoveryImpact,
            materialDisplacement: materialDisplacement,
            highRiskReviewRequired: highRiskReviewRequired,
            unsafeState: unsafeState,
            scheduleInstallFailure: scheduleInstallFailure,
            treatyIDs: treatyIDs,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceID: replayTraceID,
            whatAmbitionsKnowsRoute: whatAmbitionsKnowsRoute,
            userVisible: userVisible,
            localOnly: localOnly,
            reversible: reversible
        )
    }

    func readyScheduleInstallRecord() -> ScheduleInstallRecord {
        let preview = ScheduleInstallPreview(
            id: "schedule-install.preview.ready",
            selectedVariantID: "variant.shrink",
            selectedWindowID: "window.open.morning",
            candidateWindows: [],
            protectedWindowIDs: [],
            sourceRecordIDs: ["SourceRecord.schedule.preview"],
            receiptIDs: ["Receipt.schedule.preview"],
            replayTraceIDs: ["ReplayTrace.schedule.preview"],
            whatAmbitionsKnowsRoutes: ["you://what-ambitions-knows/schedule-preview"]
        )
        let receipt = ScheduleInstallReceipt(
            id: "Receipt.schedule.install",
            previewID: preview.id,
            selectedVariantID: "variant.shrink",
            selectedWindowID: "window.open.morning",
            decisionReceiptID: "Receipt.decision.commit",
            sourceRecordIDs: ["SourceRecord.schedule.install"],
            receiptIDs: ["Receipt.schedule.install", "Receipt.decision.commit"],
            replayTraceID: "ReplayTrace.schedule.receipt",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/schedule-install",
            rollbackTraceID: "schedule-install.rollback.ready",
            createdAt: "2026-06-14T17:00:00Z",
            reversible: true,
            localOnly: true
        )
        let rollback = ScheduleInstallRollbackTrace(
            id: "schedule-install.rollback.ready",
            previewID: preview.id,
            installReceiptID: receipt.id,
            previousScheduleSnapshotID: "schedule.snapshot.before",
            rollbackReceiptID: "Receipt.rollback.ready",
            sourceRecordIDs: ["SourceRecord.rollback.ready"],
            receiptIDs: ["Receipt.rollback.ready"],
            replayTraceID: "ReplayTrace.rollback.ready",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/schedule-rollback",
            reversible: true,
            localOnly: true
        )
        let trace = ScheduleInstallTrace(
            id: "ReplayTrace.schedule.install",
            goalReferenceID: "goal.release",
            previewID: preview.id,
            installReceiptID: receipt.id,
            rollbackTraceID: rollback.id,
            issueIDs: [],
            replayTraceIDs: ["ReplayTrace.schedule.preview", "ReplayTrace.schedule.receipt", "ReplayTrace.rollback.ready"],
            fingerprint: "schedule-install.fingerprint.ready",
            localOnly: true
        )
        return ScheduleInstallRecord(
            id: "schedule-install.record.ready",
            goalReferenceID: "goal.release",
            preview: preview,
            installReceipt: receipt,
            rollbackTrace: rollback,
            trace: trace,
            issues: []
        )
    }

    func blockedScheduleInstallRecord() -> ScheduleInstallRecord {
        ScheduleInstallRecord(
            id: "schedule-install.record.blocked",
            goalReferenceID: "goal.release",
            preview: nil,
            installReceipt: nil,
            rollbackTrace: nil,
            trace: ScheduleInstallTrace(
                id: "ReplayTrace.schedule.blocked",
                goalReferenceID: "goal.release",
                previewID: nil,
                installReceiptID: nil,
                rollbackTraceID: nil,
                issueIDs: [ScheduleInstallIssue.protectedTimeConflict.rawValue],
                replayTraceIDs: [],
                fingerprint: "schedule-install.fingerprint.blocked",
                localOnly: true
            ),
            issues: [.protectedTimeConflict]
        )
    }
}
