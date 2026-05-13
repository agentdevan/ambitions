import XCTest
@testable import Ambitions

final class CorrectionFoldModelsTests: XCTestCase {
    func testWrongCaptureRouteCanBeCorrectedToConstraintWithReceipt() {
        let correction = CorrectionFoldRecord.captureRoute(
            id: "capture-route-correction-1",
            captureID: "capture-1",
            from: .readyToPlace,
            to: .constraint,
            reason: "The capture describes a real constraint, not something ready to place.",
            occurredAt: "2026-05-13T09:54:52Z",
            allowsFutureLearning: true
        )

        XCTAssertTrue(correction.isWellFormed)
        XCTAssertEqual(correction.target, .captureRoute)
        XCTAssertEqual(correction.correctedCaptureRoute, .constraint)
        XCTAssertEqual(correction.effect, .rerouteCapture)
        XCTAssertTrue(correction.allowsFutureLearning)
        XCTAssertTrue(correction.requiresUserVisibleReceipt)
        XCTAssertFalse(correction.permitsSilentMutation)
        XCTAssertEqual(correction.receipt.action, .corrected)
        XCTAssertTrue(correction.receipt.localOnly)
    }

    func testStaleOrWrongSourceClaimBlocksRecommendationUseUntilReview() {
        let correction = CorrectionFoldRecord.sourceClaim(
            id: "source-claim-correction-1",
            claimID: "claim-1",
            from: .current,
            to: .stale,
            reason: "The source is stale and needs review before it supports a recommendation.",
            occurredAt: "2026-05-13T09:54:52Z"
        )

        XCTAssertTrue(correction.isWellFormed)
        XCTAssertEqual(correction.target, .sourceClaim)
        XCTAssertEqual(correction.correctedSourceClaim, .stale)
        XCTAssertTrue(correction.correctedSourceClaim?.blocksRecommendationUse == true)
        XCTAssertEqual(correction.effect, .markSourceForReview)
        XCTAssertFalse(correction.allowsFutureLearning)
        XCTAssertTrue(correction.receipt.isWellFormed)
    }

    func testRejectedRecommendationSuppressesThatRecommendationAndCanInformFutureLocalLearning() {
        let correction = CorrectionFoldRecord.recommendation(
            id: "recommendation-correction-1",
            recommendationID: "recommendation-1",
            from: .stillUseful,
            to: .rejectedWrongTime,
            reason: "The recommendation is the wrong kind of work for the open time.",
            occurredAt: "2026-05-13T09:54:52Z"
        )

        XCTAssertTrue(correction.isWellFormed)
        XCTAssertEqual(correction.target, .recommendation)
        XCTAssertEqual(correction.correctedRecommendation, .rejectedWrongTime)
        XCTAssertTrue(correction.correctedRecommendation?.isRejection == true)
        XCTAssertEqual(correction.effect, .suppressRecommendation)
        XCTAssertTrue(correction.allowsFutureLearning)
        XCTAssertTrue(correction.requiresUserVisibleReceipt)
    }

    func testRejectedRecommendationCreatesInspectableLocalLearningInfluence() throws {
        let correction = CorrectionFoldRecord.recommendation(
            id: "recommendation-correction-wrong-time",
            recommendationID: "recommendation-1",
            from: .stillUseful,
            to: .rejectedWrongTime,
            reason: "The recommendation is the wrong kind of work for the open time.",
            occurredAt: "2026-05-13T10:30:43Z"
        )

        let influence = try XCTUnwrap(
            CorrectionFoldRecommendationLearningInfluence(
                correction: correction,
                similarRecommendationSignalKeys: ["capacity", "wrong_time", "capacity"]
            )
        )

        XCTAssertTrue(influence.isInspectableAndControllable)
        XCTAssertEqual(influence.correctionRecordID, correction.id)
        XCTAssertEqual(influence.recommendationID, "recommendation-1")
        XCTAssertEqual(influence.rejectionReason, .rejectedWrongTime)
        XCTAssertEqual(influence.adjustment, .downrankWrongTime)
        XCTAssertEqual(influence.similarRecommendationSignalKeys, ["capacity", "wrong_time"])
        XCTAssertEqual(influence.receiptID, correction.receipt.id)
        XCTAssertTrue(influence.localOnly)
        XCTAssertTrue(influence.resetDeleteCompatible)
        XCTAssertFalse(influence.permitsSilentMutation)
        XCTAssertEqual(
            influence.rankAdjustment(for: "recommendation-1"),
            CorrectionFoldRecommendationLearningAdjustment.suppressExactRecommendation.baseRankAdjustment
        )
        XCTAssertEqual(
            influence.rankAdjustment(for: "recommendation-2", candidateSignalKeys: ["wrong_time"]),
            CorrectionFoldRecommendationLearningAdjustment.downrankWrongTime.baseRankAdjustment
        )
        XCTAssertEqual(influence.rankAdjustment(for: "recommendation-3", candidateSignalKeys: ["source_truth"]), 0)
    }

    func testRejectedRecommendationLearningInfluenceRequiresLocalFutureLearningPermission() {
        let noLearning = CorrectionFoldRecord.recommendation(
            id: "recommendation-correction-no-learning",
            recommendationID: "recommendation-1",
            from: .stillUseful,
            to: .rejectedWrongGoal,
            reason: "Do not learn from this rejection.",
            occurredAt: "2026-05-13T10:30:43Z",
            allowsFutureLearning: false
        )
        let stillUseful = CorrectionFoldRecord.recommendation(
            id: "recommendation-correction-still-useful",
            recommendationID: "recommendation-2",
            from: .stillUseful,
            to: .stillUseful,
            reason: "Keep this recommendation available.",
            occurredAt: "2026-05-13T10:30:43Z"
        )

        XCTAssertNil(CorrectionFoldRecommendationLearningInfluence(correction: noLearning))
        XCTAssertNil(CorrectionFoldRecommendationLearningInfluence(correction: stillUseful))
    }

    func testWrongTimeFitDecisionRequiresReviewWithoutSilentScheduleMutation() {
        let correction = CorrectionFoldRecord.timeFitDecision(
            id: "time-fit-correction-1",
            decisionID: "time-fit-1",
            from: .fitsNow,
            to: .protectedTimeConflict,
            reason: "The decision used protected time as if it were open time.",
            occurredAt: "2026-05-13T09:54:52Z"
        )

        XCTAssertTrue(correction.isWellFormed)
        XCTAssertEqual(correction.target, .timeFitDecision)
        XCTAssertEqual(correction.correctedTimeFit, .protectedTimeConflict)
        XCTAssertTrue(correction.correctedTimeFit?.requiresFitReview == true)
        XCTAssertEqual(correction.effect, .requireTimeFitReview)
        XCTAssertFalse(correction.permitsSilentMutation)
        XCTAssertTrue(correction.receipt.isWellFormed)
    }

    func testResetOrIgnoredLearningInputRemovesLearningUseAndRecordsResetReceipt() {
        let reset = CorrectionFoldRecord.learningInput(
            id: "learning-reset-correction-1",
            learningInputID: "learning-input-1",
            from: .use,
            to: .reset,
            reason: "The learned pattern should not be used for future recommendations.",
            occurredAt: "2026-05-13T09:54:52Z"
        )
        let ignored = CorrectionFoldRecord.learningInput(
            id: "learning-ignore-correction-1",
            learningInputID: "learning-input-2",
            from: .use,
            to: .ignore,
            reason: "This one input should be ignored.",
            occurredAt: "2026-05-13T09:54:52Z"
        )

        XCTAssertEqual(reset.target, .learningInput)
        XCTAssertEqual(reset.correctedLearningInput, .reset)
        XCTAssertTrue(reset.correctedLearningInput?.removesLearningUse == true)
        XCTAssertEqual(reset.effect, .removeLearningInput)
        XCTAssertEqual(reset.receipt.action, .reset)
        XCTAssertFalse(reset.allowsFutureLearning)

        XCTAssertEqual(ignored.correctedLearningInput, .ignore)
        XCTAssertTrue(ignored.correctedLearningInput?.removesLearningUse == true)
        XCTAssertEqual(ignored.effect, .removeLearningInput)
        XCTAssertEqual(ignored.receipt.action, .ignored)
        XCTAssertTrue(ignored.receipt.isWellFormed)
    }

    func testCorrectionFoldTaxonomyCoversOnlyApprovedTargets() throws {
        XCTAssertEqual(
            Set(CorrectionFoldTarget.allCases),
            [
                .captureRoute,
                .sourceClaim,
                .recommendation,
                .timeFitDecision,
                .learningInput
            ]
        )

        let corrections = [
            CorrectionFoldRecord.captureRoute(
                id: "capture-route-correction-1",
                captureID: "capture-1",
                from: .readyToPlace,
                to: .constraint,
                reason: "Wrong route.",
                occurredAt: "2026-05-13T09:54:52Z"
            ),
            CorrectionFoldRecord.sourceClaim(
                id: "source-claim-correction-1",
                claimID: "claim-1",
                from: .current,
                to: .wrongSource,
                reason: "Wrong source.",
                occurredAt: "2026-05-13T09:54:52Z"
            )
        ]

        let data = try JSONEncoder().encode(corrections)
        let decoded = try JSONDecoder().decode([CorrectionFoldRecord].self, from: data)

        XCTAssertEqual(decoded, corrections)
        XCTAssertTrue(decoded.allSatisfy(\.isWellFormed))
    }
}
