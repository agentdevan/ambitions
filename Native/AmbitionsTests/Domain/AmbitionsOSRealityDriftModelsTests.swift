import XCTest
@testable import Ambitions

final class AmbitionsOSRealityDriftModelsTests: XCTestCase {
    private let validator = AmbitionsOSRealityDriftValidator()

    func testReviewableSameDayReflowRoundTrips() throws {
        let proposal = proposal(
            signal: signal(level: .sameDayDrift),
            actions: [.makeSmaller, .moveLater],
            reviewScope: .sameDaySuggestion,
            changesCommitments: true,
            proofTrustReceipts: [receipt()]
        )

        let data = try JSONEncoder().encode(proposal)
        let decoded = try JSONDecoder().decode(AmbitionsOSBoundedReflowProposal.self, from: data)

        XCTAssertEqual(decoded.schemaVersion, ambitionsOSRealityDriftSchemaVersion)
        XCTAssertEqual(decoded.actions, [.makeSmaller, .moveLater])
        XCTAssertEqual(validator.validate(decoded), [])
        XCTAssertTrue(decoded.canProjectAsReviewableReflow)
    }

    func testInvalidSchemaAndMalformedSignalAreRejected() {
        let proposal = proposal(
            id: "",
            signal: signal(id: "", level: .sameDayDrift, plannedCommitmentIDs: [], schemaVersion: "old.schema"),
            actions: [],
            reviewScope: .sameDaySuggestion,
            schemaVersion: "old.schema"
        )

        let issues = validator.validate(proposal)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedSignal))
        XCTAssertTrue(issues.contains(.malformedProposal))
    }

    func testNoUpdateDoesNotBecomeFailureOrForcedReflow() {
        let safe = proposal(
            signal: signal(level: .noUpdate, noUpdateObserved: true, userConfirmedRealityChange: false),
            actions: [.keepPlan],
            reviewScope: .none
        )
        let unsafe = proposal(
            signal: signal(
                level: .noUpdate,
                noUpdateObserved: true,
                userConfirmedRealityChange: false,
                surfaceLanguageSamples: ["You failed because nothing changed."]
            ),
            actions: [.moveLater],
            reviewScope: .sameDaySuggestion
        )

        XCTAssertEqual(validator.validate(safe), [])
        XCTAssertTrue(validator.validate(unsafe).contains(.noUpdateTreatedAsFailure))
        XCTAssertTrue(validator.validate(unsafe).contains(.harmfulRecoveryLanguage))
    }

    func testWeekAndGoalDeadlineDriftRequireBoundedReviewScopes() {
        let week = proposal(signal: signal(level: .weekDrift), actions: [.requestReview], reviewScope: .sameDaySuggestion)
        let deadline = proposal(
            signal: signal(level: .goalDeadlineDrift, affectedGoalIDs: ["goal-1"]),
            actions: [.requestReview],
            reviewScope: .weekReview
        )

        XCTAssertTrue(validator.validate(week).contains(.weekDriftRequiresReview))
        XCTAssertTrue(validator.validate(deadline).contains(.goalDeadlineRequiresConfirmation))
        XCTAssertEqual(
            validator.validate(proposal(signal: signal(level: .weekDrift), actions: [.requestReview], reviewScope: .weekReview)),
            []
        )
    }

    func testSilentReschedulePlatformCalendarAndRuntimeStoreAreRejected() {
        let proposal = proposal(
            signal: signal(level: .sameDayDrift),
            actions: [.moveLater],
            reviewScope: .sameDaySuggestion,
            requiresUserApproval: false,
            changesCommitments: true,
            performsPlatformCalendarWork: true,
            writesScheduleAutomatically: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: false,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        let issues = validator.validate(proposal)

        XCTAssertTrue(issues.contains(.silentRescheduleRisk))
        XCTAssertTrue(issues.contains(.platformCalendarImplementation))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
    }

    func testCommitmentProjectionAndProofTrustGatesAreInherited() {
        let protected = commitmentProjection(
            commitments: [commitment(id: "step-1", durationMinutes: 20)],
            windows: [window(availableMinutes: 60, protected: true)]
        )
        let missingReceipt = proposal(
            signal: signal(level: .sameDayDrift),
            actions: [.moveLater],
            commitmentProjection: protected,
            reviewScope: .sameDaySuggestion,
            changesCommitments: true
        )
        let badReceipt = proposal(
            signal: signal(level: .sameDayDrift),
            actions: [.moveLater],
            reviewScope: .sameDaySuggestion,
            changesCommitments: true,
            proofTrustReceipts: [receipt(actionReceiptIDs: [], proofReferenceIDs: [])]
        )

        XCTAssertTrue(validator.validate(missingReceipt).contains(.protectedTimeViolation))
        XCTAssertTrue(validator.validate(missingReceipt).contains(.proofReceiptRequired))
        XCTAssertTrue(validator.validate(badReceipt).contains(.proofTrustReviewRequired))
    }

    func testSourceFreshnessPrivacyAndBlastRadiusBoundariesAreEnforced() {
        let proposal = proposal(
            signal: signal(
                level: .capacityShock,
                sourceState: .sourceNeeded,
                freshnessState: .staleCritical,
                reviewState: .needsSourceReview,
                privacyClass: .sensitive
            ),
            actions: [.requestReview],
            reviewScope: .weekReview,
            blastRadiusLevel: 6
        )

        let issues = validator.validate(proposal)

        XCTAssertTrue(issues.contains(.sourceReviewRequired))
        XCTAssertTrue(issues.contains(.staleSourceReviewRequired))
        XCTAssertTrue(issues.contains(.privateExternalProjectionRisk))
        XCTAssertTrue(issues.contains(.unboundedBlastRadius))
    }
}

private extension AmbitionsOSRealityDriftModelsTests {
    func proposal(
        id: String = "reflow-1",
        signal: AmbitionsOSRealityDriftSignal,
        actions: [AmbitionsOSReflowActionKind],
        commitmentProjection: AmbitionsOSCommitmentTimeProjection? = nil,
        reviewScope: AmbitionsOSReflowReviewScope,
        blastRadiusLevel: Int = 1,
        requiresUserApproval: Bool = true,
        changesCommitments: Bool = false,
        proofTrustReceipts: [AmbitionsOSProofTrustReceipt] = [],
        performsPlatformCalendarWork: Bool = false,
        writesScheduleAutomatically: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSRealityDriftSchemaVersion
    ) -> AmbitionsOSBoundedReflowProposal {
        AmbitionsOSBoundedReflowProposal(
            id: id,
            signal: signal,
            actions: actions,
            commitmentProjection: commitmentProjection ?? self.commitmentProjection(),
            proofTrustReceipts: proofTrustReceipts,
            reviewScope: reviewScope,
            blastRadiusLevel: blastRadiusLevel,
            requiresUserApproval: requiresUserApproval,
            changesCommitments: changesCommitments,
            performsPlatformCalendarWork: performsPlatformCalendarWork,
            writesScheduleAutomatically: writesScheduleAutomatically,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func signal(
        id: String = "drift-1",
        level: AmbitionsOSRealityDriftLevel,
        plannedCommitmentIDs: [String] = ["step-1"],
        observedEventIDs: [String] = ["observed-1"],
        affectedGoalIDs: [String] = [],
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        noUpdateObserved: Bool = false,
        userConfirmedRealityChange: Bool = true,
        surfaceLanguageSamples: [String] = [],
        schemaVersion: String = ambitionsOSRealityDriftSchemaVersion
    ) -> AmbitionsOSRealityDriftSignal {
        AmbitionsOSRealityDriftSignal(
            id: id,
            level: level,
            plannedCommitmentIDs: plannedCommitmentIDs,
            observedEventIDs: observedEventIDs,
            affectedGoalIDs: affectedGoalIDs,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            noUpdateObserved: noUpdateObserved,
            userConfirmedRealityChange: userConfirmedRealityChange,
            surfaceLanguageSamples: surfaceLanguageSamples,
            schemaVersion: schemaVersion
        )
    }

    func commitmentProjection(
        commitments: [AmbitionsOSCommitmentTimeItem]? = nil,
        windows: [AmbitionsOSCapacityWindow]? = nil
    ) -> AmbitionsOSCommitmentTimeProjection {
        AmbitionsOSCommitmentTimeProjection(
            commitments: commitments ?? [commitment(id: "step-1", durationMinutes: 20)],
            capacityWindows: windows ?? [window(availableMinutes: 60)]
        )
    }

    func commitment(id: String, durationMinutes: Int) -> AmbitionsOSCommitmentTimeItem {
        AmbitionsOSCommitmentTimeItem(
            id: id,
            title: "Adjust plan with review",
            kind: .step,
            durationMinutes: durationMinutes,
            flexibility: .movableSameDay,
            sourceClaimIDs: ["claim-1"],
            receiptIDs: ["receipt-1"]
        )
    }

    func window(availableMinutes: Int, protected: Bool = false) -> AmbitionsOSCapacityWindow {
        AmbitionsOSCapacityWindow(
            id: "window-1",
            title: "Review window",
            availableMinutes: availableMinutes,
            protected: protected
        )
    }

    func receipt(
        actionReceiptIDs: [String] = ["action-receipt-1"],
        proofReferenceIDs: [String] = ["proof-1"]
    ) -> AmbitionsOSProofTrustReceipt {
        AmbitionsOSProofTrustReceipt(
            id: "receipt-1",
            kind: .mutation,
            surface: .plan,
            occurredAt: "2026-05-06T23:15:00Z",
            affectedObjectIDs: ["step-1"],
            actionReceiptIDs: actionReceiptIDs,
            proofReferenceIDs: proofReferenceIDs,
            sourceClaimIDs: ["claim-1"],
            changedFactSummaries: ["Previewed reflow before changing commitments."],
            closureOutcome: .needsReview,
            sourceState: .sourceBacked,
            freshnessState: .current,
            reviewState: .ready,
            reversible: true
        )
    }
}
