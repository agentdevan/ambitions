import XCTest
@testable import Ambitions

final class HighRiskSafetyJurisdictionGateTests: XCTestCase {
    func testApprovedLowRiskSourceBackedRecordCanDriveHighRiskSafetySegment() throws {
        let record = HighRiskSafetyJurisdictionGate().evaluate(
            HighRiskSafetyGateInput(
                anyGoalRecord: anyGoalRecord(),
                sourceAuthorityInspection: sourceAuthorityInspection(action: .userControlledShare, shareRight: .publicExport),
                context: HighRiskJurisdictionContext(domain: .standard, reviewState: .notRequired),
                evaluatedAt: "2026-06-14T18:00:00Z"
            )
        )

        XCTAssertEqual(record.mode, .allowed)
        XCTAssertEqual(record.issues, [])
        XCTAssertTrue(record.canContinueToRuntimeCore)
        XCTAssertTrue(record.canGenerateVisibleStep)
        XCTAssertTrue(record.canInstallSchedule)
        XCTAssertTrue(record.canShare)
        XCTAssertEqual(record.handoffs, [])
        XCTAssertEqual(record.runtimeCoreSegment.kind, .highRiskSafety)
        XCTAssertEqual(record.runtimeCoreSegment.state, .ready)
        XCTAssertEqual(record.runtimeCoreSegment.replayTraceID, record.trace.id)
        XCTAssertEqual(record.runtimeCoreSegment.whatAmbitionsKnowsRoute, record.receipt.whatAmbitionsKnowsRoute)
        XCTAssertTrue(record.runtimeCoreSegment.sourceRecordIDs.contains("SourceRecord.goal.low-risk.approved"))
        XCTAssertTrue(record.runtimeCoreSegment.receiptIDs.contains("Receipt.goal.low-risk"))
        XCTAssertTrue(record.runtimeCoreSegment.receiptIDs.contains(record.receipt.id))
        XCTAssertTrue(record.runtimeCoreSegment.canDriveVisibleExecution)
        XCTAssertFalse(record.runtimeCoreSegment.blocksDownstream)
    }

    func testUnsafeAnyGoalBlocksAllVisibleInstallAndShareOutputs() {
        let record = HighRiskSafetyJurisdictionGate().evaluate(
            HighRiskSafetyGateInput(
                anyGoalRecord: anyGoalRecord(
                    id: "goal.unsafe",
                    family: .legalCivic,
                    supportState: .unsupported,
                    safetyState: .unsafe,
                    sourceAuthority: unsupportedSourceAuthority(),
                    missingSourceTypes: [.highRiskReview],
                    seedGapCategories: [.highRiskReview]
                ),
                context: HighRiskJurisdictionContext(domain: .legalCivic, reviewState: .needed),
                evaluatedAt: "2026-06-14T18:05:00Z"
            )
        )

        XCTAssertEqual(record.mode, .unsafeBlocked)
        XCTAssertTrue(record.issues.contains(.unsafeBlocked))
        XCTAssertTrue(record.issues.contains(.upstreamCoverageBlocked))
        XCTAssertTrue(record.issues.contains(.privateProjectionBlocked))
        XCTAssertTrue(record.trace.blockedOutputs.contains("coverage_request"))
        XCTAssertTrue(record.trace.blockedOutputs.contains("visible_step"))
        XCTAssertTrue(record.trace.blockedOutputs.contains("schedule_install"))
        XCTAssertTrue(record.trace.blockedOutputs.contains("share_projection"))
        XCTAssertFalse(record.canContinueToRuntimeCore)
        XCTAssertFalse(record.canGenerateVisibleStep)
        XCTAssertFalse(record.canInstallSchedule)
        XCTAssertFalse(record.canShare)
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
        XCTAssertTrue(record.runtimeCoreSegment.blocksDownstream)
        XCTAssertNil(record.runtimeCoreSegment.replayTraceID)
        XCTAssertNil(record.runtimeCoreSegment.whatAmbitionsKnowsRoute)
    }

    func testJurisdictionNeededCreatesInspectableHandoffBeforeRuntimePathing() throws {
        let record = HighRiskSafetyJurisdictionGate().evaluate(
            HighRiskSafetyGateInput(
                anyGoalRecord: anyGoalRecord(
                    id: "goal.jurisdiction",
                    supportState: .sourceNeeded,
                    jurisdictionState: .needed,
                    sourceAuthority: unsupportedSourceAuthority(),
                    missingSourceTypes: [.jurisdiction],
                    seedGapCategories: [.jurisdiction]
                ),
                context: HighRiskJurisdictionContext(domain: .regulatedGoods, requiresJurisdiction: true),
                evaluatedAt: "2026-06-14T18:10:00Z"
            )
        )

        XCTAssertEqual(record.mode, .jurisdictionNeeded)
        XCTAssertTrue(record.issues.contains(.jurisdictionNeeded))
        XCTAssertTrue(record.issues.contains(.upstreamCoverageBlocked))
        let handoff = try XCTUnwrap(record.handoffs.first { $0.issue == .jurisdictionNeeded })
        XCTAssertTrue(handoff.route.contains("what-ambitions-knows/jurisdiction"))
        XCTAssertTrue(handoff.blockedOutputs.contains("coverage_request"))
        XCTAssertTrue(handoff.blockedOutputs.contains("visible_step"))
        XCTAssertTrue(handoff.blockedOutputs.contains("schedule_install"))
        XCTAssertTrue(handoff.blockedOutputs.contains("share_projection"))
        XCTAssertFalse(record.canContinueToRuntimeCore)
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
    }

    func testSourceAuthorityJurisdictionMismatchBlocksScheduleInstall() {
        let record = HighRiskSafetyJurisdictionGate().evaluate(
            HighRiskSafetyGateInput(
                anyGoalRecord: anyGoalRecord(),
                sourceAuthorityInspection: sourceAuthorityInspection(
                    action: .scheduleInstall,
                    contextJurisdictionID: "us.ca",
                    sourceJurisdictionIDs: ["us.ny"],
                    shareRight: .publicExport
                ),
                context: HighRiskJurisdictionContext(
                    domain: .regulatedGoods,
                    requestedJurisdictionID: "us.ca",
                    requiresJurisdiction: true,
                    reviewState: .approved
                ),
                evaluatedAt: "2026-06-14T18:15:00Z"
            )
        )

        XCTAssertEqual(record.mode, .jurisdictionNeeded)
        XCTAssertTrue(record.issues.contains(.jurisdictionIncompatible))
        XCTAssertTrue(record.issues.contains(.sourceAuthorityBlocked))
        XCTAssertFalse(record.canInstallSchedule)
        XCTAssertTrue(record.trace.blockedOutputs.contains("schedule_install"))
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
    }

    func testHighRiskProfessionalDomainRequiresApprovedReviewBeforeContinuation() throws {
        let pendingRecord = HighRiskSafetyJurisdictionGate().evaluate(
            HighRiskSafetyGateInput(
                anyGoalRecord: anyGoalRecord(
                    id: "goal.legal.pending",
                    family: .legalCivic,
                    safetyState: .highRisk
                ),
                sourceAuthorityInspection: sourceAuthorityInspection(action: .userControlledShare, shareRight: .publicExport),
                context: HighRiskJurisdictionContext(domain: .legalCivic, requestedJurisdictionID: "us.ny", reviewState: .needed),
                evaluatedAt: "2026-06-14T18:20:00Z"
            )
        )

        XCTAssertEqual(pendingRecord.mode, .professionalBoundary)
        XCTAssertTrue(pendingRecord.issues.contains(.highRiskReviewRequired))
        XCTAssertTrue(pendingRecord.issues.contains(.professionalBoundaryRequired))
        let handoff = try XCTUnwrap(pendingRecord.handoffs.first { $0.issue == .professionalBoundaryRequired })
        XCTAssertTrue(handoff.route.contains("what-ambitions-knows/high-risk-review"))
        XCTAssertFalse(pendingRecord.canContinueToRuntimeCore)

        let approvedRecord = HighRiskSafetyJurisdictionGate().evaluate(
            HighRiskSafetyGateInput(
                anyGoalRecord: anyGoalRecord(
                    id: "goal.legal.approved",
                    family: .legalCivic,
                    safetyState: .highRisk
                ),
                sourceAuthorityInspection: sourceAuthorityInspection(action: .userControlledShare, shareRight: .publicExport),
                context: HighRiskJurisdictionContext(domain: .legalCivic, requestedJurisdictionID: "us.ny", reviewState: .approved),
                evaluatedAt: "2026-06-14T18:25:00Z"
            )
        )

        XCTAssertEqual(approvedRecord.mode, .allowed)
        XCTAssertEqual(approvedRecord.issues, [])
        XCTAssertTrue(approvedRecord.canContinueToRuntimeCore)
        XCTAssertEqual(approvedRecord.runtimeCoreSegment.state, .ready)
    }

    func testLifeConsequenceBlockedKeepsSafetySegmentBlocked() {
        let consequence = LifeConsequenceEngine().evaluate(
            lifeConsequenceInput(
                impacts: [
                    lifeConsequenceImpact(
                        id: "impact.protected-time",
                        protectedTimeBroken: true,
                        sourceRecordIDs: ["SourceRecord.impact.protected-time"],
                        receiptIDs: ["Receipt.impact.protected-time"],
                        replayTraceID: "ReplayTrace.impact.protected-time",
                        whatAmbitionsKnowsRoute: "you://what-ambitions-knows/impact/protected-time"
                    )
                ],
                treaties: [
                    LifeConsequenceGoalTreaty(
                        id: "treaty.sleep",
                        title: "Sleep protection",
                        participatingGoalIDs: ["goal.sleep", "goal.low-risk"],
                        protectedGoalID: "goal.sleep",
                        constraintSummary: "Sleep protection remains protected.",
                        violationSeverity: .block,
                        sourceRecordIDs: ["SourceRecord.treaty.sleep"],
                        receiptIDs: ["Receipt.treaty.sleep"],
                        replayTraceID: "ReplayTrace.treaty.sleep",
                        whatAmbitionsKnowsRoute: "you://what-ambitions-knows/treaty/sleep"
                    )
                ]
            )
        )

        let record = HighRiskSafetyJurisdictionGate().evaluate(
            HighRiskSafetyGateInput(
                anyGoalRecord: anyGoalRecord(),
                sourceAuthorityInspection: sourceAuthorityInspection(action: .userControlledShare, shareRight: .publicExport),
                lifeConsequenceRecord: consequence,
                context: HighRiskJurisdictionContext(domain: .standard),
                evaluatedAt: "2026-06-14T18:30:00Z"
            )
        )

        XCTAssertTrue(consequence.highestSeverity.blocksDownstream)
        XCTAssertEqual(record.mode, .blocked)
        XCTAssertTrue(record.issues.contains(.consequenceBlocked))
        XCTAssertFalse(record.canContinueToRuntimeCore)
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
        XCTAssertTrue(record.runtimeCoreSegment.blocksDownstream)
        XCTAssertTrue(record.trace.blockedOutputs.contains("visible_step"))
        XCTAssertTrue(record.trace.blockedOutputs.contains("schedule_install"))
    }
}

private extension HighRiskSafetyJurisdictionGateTests {
    func anyGoalRecord(
        id: String = "goal.low-risk",
        family: AnyGoalFamily = .education,
        supportState: AnyGoalSupportState = .sourceBacked,
        safetyState: AnyGoalSafetyState = .safe,
        jurisdictionState: AnyGoalJurisdictionState = .notNeeded,
        sourceAuthority: AnyGoalSourceAuthoritySnapshot? = nil,
        missingSourceTypes: [CoverageNeedMissingSourceType] = [.publicSource],
        seedGapCategories: [CoverageNeedSeedGapCategory] = [.goalFamily]
    ) -> AnyGoalCoverageRecord {
        AnyGoalRuntimeCoverageEngine().evaluate(
            AnyGoalCoverageInput(
                id: id,
                rawGoalText: "Prepare a source-backed step.",
                family: family,
                domain: family.rawValue,
                supportState: supportState,
                safetyState: safetyState,
                jurisdictionState: jurisdictionState,
                requestedJurisdictionID: jurisdictionState == .needed ? "US.NY" : nil,
                sourceAuthority: sourceAuthority ?? supportedSourceAuthority(goalID: id),
                missingSourceTypes: missingSourceTypes,
                seedGapCategories: seedGapCategories,
                receiptID: "Receipt.\(id)",
                replayTraceID: "ReplayTrace.\(id)",
                whatAmbitionsKnowsRoute: "you://what-ambitions-knows/any-goal/\(id)"
            )
        )
    }

    func supportedSourceAuthority(goalID: String) -> AnyGoalSourceAuthoritySnapshot {
        AnyGoalSourceAuthoritySnapshot(
            canSupportCurrentUse: true,
            sourceRecordIDs: ["SourceRecord.\(goalID).approved"],
            sourceFingerprintIDs: ["source-fingerprint.\(goalID).v1"],
            authorityIssueCodes: []
        )
    }

    func unsupportedSourceAuthority() -> AnyGoalSourceAuthoritySnapshot {
        AnyGoalSourceAuthoritySnapshot(
            canSupportCurrentUse: false,
            sourceRecordIDs: [],
            sourceFingerprintIDs: [],
            authorityIssueCodes: ["source_needed"],
            freshnessReviewClass: .unreviewed
        )
    }

    func sourceAuthorityInspection(
        action: SourceAtlasAuthorityAction,
        contextJurisdictionID: String = "us.ny",
        sourceJurisdictionIDs: [String] = ["us.ny"],
        shareRight: SourceAtlasAuthorityShareRight = .localOnly
    ) -> SourceAtlasAuthorityInspectionRecord {
        SourceAtlasAuthorityMesh().inspect(
            SourceAtlasAuthorityMeshInput(
                queryResponse: sourceAtlasResponse(),
                authorityRecords: [
                    SourceAtlasAuthorityRecord(
                        id: "authority.source.high-risk",
                        sourceID: "source.high-risk",
                        state: .accepted,
                        jurisdictionIDs: sourceJurisdictionIDs,
                        shareRight: shareRight,
                        lastReviewedAt: Date(timeIntervalSince1970: 1_780_000_000)
                    )
                ],
                context: SourceAtlasAuthorityMeshContext(
                    action: action,
                    jurisdictionID: contextJurisdictionID,
                    shareScope: .userControlled
                )
            )
        )
    }

    func sourceAtlasResponse() -> SourceAtlasQueryResponse {
        SourceAtlasQueryResponse(
            query: SourceAtlasQuery(domainID: "high-risk-safety"),
            results: [
                SourceAtlasQueryResult(
                    id: "pack.high-risk::requirement.current",
                    packID: "pack.high-risk",
                    domainID: "high-risk-safety",
                    goalIntent: "starter_goal",
                    claimID: "claim.current",
                    requirementID: "requirement.current",
                    sourceState: .officialCurrent,
                    freshnessState: .current,
                    riskState: .medium,
                    riskClass: .legalCivic,
                    reviewState: .approved,
                    provenanceSourceIDs: ["source.high-risk"],
                    proofEntryIDs: ["evidence.current"],
                    fallbackReason: nil,
                    sourceNeededDetail: nil
                )
            ],
            selectedResult: SourceAtlasQueryResult(
                id: "pack.high-risk::requirement.current",
                packID: "pack.high-risk",
                domainID: "high-risk-safety",
                goalIntent: "starter_goal",
                claimID: "claim.current",
                requirementID: "requirement.current",
                sourceState: .officialCurrent,
                freshnessState: .current,
                riskState: .medium,
                riskClass: .legalCivic,
                reviewState: .approved,
                provenanceSourceIDs: ["source.high-risk"],
                proofEntryIDs: ["evidence.current"],
                fallbackReason: nil,
                sourceNeededDetail: nil
            )
        )
    }

    func lifeConsequenceInput(
        impacts: [LifeConsequenceImpact],
        treaties: [LifeConsequenceGoalTreaty] = []
    ) -> LifeConsequenceEngineInput {
        LifeConsequenceEngineInput(
            scheduleInstallRecord: scheduleInstallRecord(),
            impacts: impacts,
            treaties: treaties,
            visibilityPreference: .balanced,
            evaluatedAt: "2026-06-14T18:30:00Z"
        )
    }

    func lifeConsequenceImpact(
        id: String,
        protectedTimeBroken: Bool = false,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?
    ) -> LifeConsequenceImpact {
        LifeConsequenceImpact(
            id: id,
            affectedGoalID: "goal.sleep",
            affectedGoalTitle: "Sleep protection",
            trigger: .protectedTimeChange,
            deadlineMinutesDelta: 0,
            densityMinutesDelta: 45,
            proofValueDelta: -20,
            dependencyIDs: [],
            protectedTimeBroken: protectedTimeBroken,
            sourceAuthority: .current,
            recoveryImpact: .heavy,
            materialDisplacement: true,
            highRiskReviewRequired: false,
            unsafeState: false,
            scheduleInstallFailure: false,
            treatyIDs: ["treaty.sleep"],
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceID: replayTraceID,
            whatAmbitionsKnowsRoute: whatAmbitionsKnowsRoute,
            userVisible: true,
            localOnly: true,
            reversible: true
        )
    }

    func scheduleInstallRecord() -> ScheduleInstallRecord {
        let preview = ScheduleInstallPreview(
            id: "schedule-install.preview.ready",
            selectedVariantID: "variant.safe",
            selectedWindowID: "window.safe",
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
            selectedVariantID: "variant.safe",
            selectedWindowID: "window.safe",
            decisionReceiptID: "Receipt.decision.commit",
            sourceRecordIDs: ["SourceRecord.schedule.install"],
            receiptIDs: ["Receipt.schedule.install", "Receipt.decision.commit"],
            replayTraceID: "ReplayTrace.schedule.receipt",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/schedule-install",
            rollbackTraceID: "schedule-install.rollback.ready",
            createdAt: "2026-06-14T18:30:00Z",
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
            goalReferenceID: "goal.low-risk",
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
            goalReferenceID: "goal.low-risk",
            preview: preview,
            installReceipt: receipt,
            rollbackTrace: rollback,
            trace: trace,
            issues: []
        )
    }
}
