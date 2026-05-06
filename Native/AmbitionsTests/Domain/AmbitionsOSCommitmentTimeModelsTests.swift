import XCTest
@testable import Ambitions

final class AmbitionsOSCommitmentTimeModelsTests: XCTestCase {
    private let validator = AmbitionsOSCommitmentTimeValidator()

    func testCapacityFitUsesReviewReadyCommitmentsWithoutCalendarImplementation() {
        let projection = projection(
            commitments: [
                item(id: "step-1", durationMinutes: 30),
                item(id: "review-1", kind: .reviewWindow, durationMinutes: 20)
            ],
            capacityWindows: [window(availableMinutes: 90)]
        )

        XCTAssertEqual(validator.validate(projection), [])
        XCTAssertEqual(projection.requestedMinutes, 50)
        XCTAssertEqual(projection.capacityFit, .fits)
    }

    func testOverCapacityProjectionIsBlockedWithoutCreatingFantasySchedule() {
        let projection = projection(
            commitments: [
                item(id: "step-1", durationMinutes: 70),
                item(id: "prep-1", kind: .prep, durationMinutes: 40)
            ],
            capacityWindows: [window(availableMinutes: 60)]
        )

        XCTAssertEqual(projection.capacityFit, .overCapacity)
        XCTAssertTrue(validator.validate(projection).contains(.overCapacity))
    }

    func testProtectedTimeBlocksOrdinaryCommitmentPlacement() {
        let projection = projection(
            commitments: [item(id: "step-1", durationMinutes: 20)],
            capacityWindows: [window(availableMinutes: 45, protected: true)]
        )

        XCTAssertTrue(validator.validate(projection).contains(.protectedTimeViolation))
    }

    func testSourceNeededAndStaleDeadlineRequireReviewBeforeCapacityUse() {
        let projection = projection(
            commitments: [
                item(
                    id: "deadline-1",
                    kind: .deadline,
                    durationMinutes: 30,
                    sourceState: .sourceNeeded,
                    freshnessState: .staleCritical,
                    reviewState: .needsSourceReview
                )
            ],
            capacityWindows: [window(availableMinutes: 60)]
        )

        let issues = validator.validate(projection)

        XCTAssertEqual(projection.capacityFit, .needsReview)
        XCTAssertTrue(issues.contains(.sourceReviewRequired))
        XCTAssertTrue(issues.contains(.staleDeadlineSource))
    }

    func testSilentRescheduleAndPlatformCalendarImplementationAreRejected() {
        let projection = projection(
            commitments: [
                item(
                    id: "fixed-appointment",
                    kind: .appointment,
                    durationMinutes: 30,
                    flexibility: .fixed,
                    requiresUserReviewBeforeMove: false
                )
            ],
            capacityWindows: [window(availableMinutes: 60)],
            performsPlatformCalendarWork: true,
            writesScheduleAutomatically: true
        )

        let issues = validator.validate(projection)

        XCTAssertTrue(issues.contains(.silentRescheduleRisk))
        XCTAssertTrue(issues.contains(.platformCalendarImplementation))
    }

    func testSensitiveCommitmentIsBlockedFromExternalProjectionWithoutRedaction() {
        let projection = projection(
            commitments: [item(id: "private-care", durationMinutes: 30, privacyClass: .sensitive)],
            capacityWindows: [window(availableMinutes: 60)]
        )
        let redacted = item(id: "redacted-care", durationMinutes: 30, privacyClass: .externalRedacted)

        XCTAssertTrue(validator.validate(projection).contains(.privateExternalProjectionRisk))
        XCTAssertTrue(redacted.isExternalProjectionSafe)
    }

    func testRuntimeStoreBehaviorAndInvalidSchemaAreRejected() {
        let projection = projection(
            commitments: [
                item(id: "", title: "", durationMinutes: 0, schemaVersion: "old.schema")
            ],
            capacityWindows: [
                window(availableMinutes: -1, schemaVersion: "old.schema")
            ],
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: false,
                mutatesPlans: false,
                writesPersistence: true
            )
        )

        let issues = validator.validate(projection)

        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedCommitment))
        XCTAssertTrue(issues.contains(.malformedCapacityWindow))
        XCTAssertTrue(issues.contains(.invalidDuration))
    }
}

private extension AmbitionsOSCommitmentTimeModelsTests {
    func projection(
        commitments: [AmbitionsOSCommitmentTimeItem],
        capacityWindows: [AmbitionsOSCapacityWindow],
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        performsPlatformCalendarWork: Bool = false,
        writesScheduleAutomatically: Bool = false
    ) -> AmbitionsOSCommitmentTimeProjection {
        AmbitionsOSCommitmentTimeProjection(
            commitments: commitments,
            capacityWindows: capacityWindows,
            runtimeBoundary: runtimeBoundary,
            performsPlatformCalendarWork: performsPlatformCalendarWork,
            writesScheduleAutomatically: writesScheduleAutomatically
        )
    }

    func item(
        id: String,
        title: String = "Review the next commitment",
        kind: AmbitionsOSCommitmentTimeKind = .step,
        durationMinutes: Int,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        flexibility: AmbitionsOSCommitmentFlexibility = .movableSameDay,
        requiresUserReviewBeforeMove: Bool = true,
        schemaVersion: String = ambitionsOSCommitmentTimeSchemaVersion
    ) -> AmbitionsOSCommitmentTimeItem {
        AmbitionsOSCommitmentTimeItem(
            id: id,
            title: title,
            kind: kind,
            durationMinutes: durationMinutes,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            flexibility: flexibility,
            sourceClaimIDs: ["claim-1"],
            receiptIDs: ["receipt-1"],
            requiresUserReviewBeforeMove: requiresUserReviewBeforeMove,
            schemaVersion: schemaVersion
        )
    }

    func window(
        id: String = "window-1",
        availableMinutes: Int,
        protected: Bool = false,
        schemaVersion: String = ambitionsOSCommitmentTimeSchemaVersion
    ) -> AmbitionsOSCapacityWindow {
        AmbitionsOSCapacityWindow(
            id: id,
            title: "Morning capacity",
            availableMinutes: availableMinutes,
            protected: protected,
            schemaVersion: schemaVersion
        )
    }
}
