import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamTrustReceiptModelsTests: XCTestCase {
    private let validator = AmbitionsOSLivingDreamTrustReceiptValidator()

    func testReadyTrustReceiptBundleRoundTripsWithHandlingSourceAndRefusalReceipts() throws {
        let bundle = makeBundle()

        let data = try JSONEncoder().encode(bundle)
        let decoded = try JSONDecoder().decode(AmbitionsOSLivingDreamTrustReceiptBundle.self, from: data)
        let evaluation = validator.evaluate(bundle: decoded)

        XCTAssertEqual(evaluation.issues, [])
        XCTAssertEqual(evaluation.readiness, .ready)
        XCTAssertEqual(evaluation.receiptIDs, ["handling", "refusal", "source-review", "user-confirmed"])
        XCTAssertEqual(evaluation.receiptKinds, [.handling, .refusal, .sourceReview, .userConfirmation])
        XCTAssertEqual(evaluation.sourceReviewReceiptIDs, ["source-review"])
        XCTAssertEqual(evaluation.refusalReceiptIDs, ["refusal"])
    }

    func testHandlingReceiptRequiresCanonicalLane() {
        let bundle = makeBundle(receipts: [
            receipt(id: "handling", kind: .handling, handlingLane: nil)
        ])

        let issues = validator.validate(bundle: bundle)

        XCTAssertTrue(issues.contains(.missingHandlingLane))
        XCTAssertEqual(validator.evaluate(bundle: bundle).readiness, .needsUserReview)
    }

    func testSourceStaleAndUnverifiedReceiptsRequireReviewBeforeReadiness() {
        let stale = makeBundle(receipts: [
            receipt(
                id: "stale",
                kind: .staleSourceReview,
                sourceState: .sourceBacked,
                freshnessState: .staleCritical,
                reviewState: .needsSourceReview
            )
        ])
        let unverified = makeBundle(receipts: [
            receipt(
                id: "unverified",
                kind: .unverifiedSourceReview,
                sourceClaimIDs: [],
                sourceReferenceIDs: [],
                sourcePackIDs: [],
                sourceState: .sourceNeeded,
                freshnessState: .notApplicable,
                reviewState: .needsSourceReview
            )
        ])

        let staleIssues = validator.validate(bundle: stale)
        let unverifiedIssues = validator.validate(bundle: unverified)

        XCTAssertTrue(staleIssues.contains(.staleSourceReviewRequired))
        XCTAssertTrue(staleIssues.contains(.sourceReviewRequired))
        XCTAssertTrue(unverifiedIssues.contains(.missingSourceReference))
        XCTAssertTrue(unverifiedIssues.contains(.unverifiedSourceReviewRequired))
        XCTAssertEqual(validator.evaluate(bundle: unverified).readiness, .needsSourceReview)
    }

    func testMutationReceiptRequiresUserApprovalChangedFactsAndNoSilentMutation() {
        let unsafe = makeBundle(receipts: [
            receipt(
                id: "mutation",
                kind: .mutationReview,
                changedFactSummaries: [],
                mutationPermission: .reviewOnly,
                mutatesCommitments: true,
                reversible: false
            )
        ])
        let safe = makeBundle(receipts: [
            receipt(
                id: "mutation",
                kind: .mutationReview,
                changedFactSummaries: ["User approved a review-only change."],
                mutationPermission: .userApproved,
                mutatesCommitments: true,
                reversible: true
            )
        ])

        let unsafeIssues = validator.validate(bundle: unsafe)

        XCTAssertTrue(unsafeIssues.contains(.mutationMissingUserApproval))
        XCTAssertTrue(unsafeIssues.contains(.silentMutationRisk))
        XCTAssertEqual(validator.evaluate(bundle: unsafe).readiness, .needsMutationReview)
        XCTAssertEqual(validator.validate(bundle: safe), [])
    }

    func testRefusalReceiptsRequireSafeAlternative() {
        let bundle = makeBundle(receipts: [
            receipt(
                id: "refusal",
                kind: .refusal,
                refusalReason: "Unsafe request",
                safeAlternativeSummary: nil
            )
        ])

        let issues = validator.validate(bundle: bundle)

        XCTAssertTrue(issues.contains(.refusalMissingSafeAlternative))
        XCTAssertEqual(validator.evaluate(bundle: bundle).readiness, .needsUserReview)
    }

    func testSafeTranslationAndOCRReceiptsStayReviewBounded() {
        let unsafeTranslation = makeBundle(receipts: [
            receipt(
                id: "translation",
                kind: .safeTranslation,
                originalTextSummary: "Unreviewed source",
                translatedTextSummary: "",
                surfaceLanguageSamples: ["No review needed; officially verified."]
            )
        ])
        let ocrNeedsReview = makeBundle(receipts: [
            receipt(
                id: "ocr",
                kind: .ocrReview,
                reviewState: .needsSourceReview
            )
        ])

        XCTAssertTrue(validator.validate(bundle: unsafeTranslation).contains(.unsafeTranslationClaim))
        XCTAssertEqual(validator.evaluate(bundle: unsafeTranslation).readiness, .blocked)
        XCTAssertTrue(validator.validate(bundle: ocrNeedsReview).contains(.ocrReviewRequired))
        XCTAssertEqual(validator.evaluate(bundle: ocrNeedsReview).readiness, .needsSourceReview)
    }

    func testHiddenRuntimeServerAndProfessionalBoundaryIssuesBlockOrRouteReview() {
        let blocked = makeBundle(
            receipts: [
                receipt(
                    id: "hidden",
                    kind: .userConfirmation,
                    visibleToUser: false,
                    userControlIDs: [],
                    usesUserDataServer: true,
                    runtimeBoundary: SourceAtlasRuntimeBoundary(
                        storesUserData: true,
                        performsNetworkFetches: true,
                        mutatesPlans: false,
                        writesPersistence: false
                    )
                )
            ],
            usesUserDataServer: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: false,
                mutatesPlans: false,
                writesPersistence: false
            )
        )
        let professionalReview = makeBundle(receipts: [
            receipt(
                id: "professional",
                kind: .sourceReview,
                professionalBoundaryReviewRequired: true
            )
        ])

        let blockedIssues = validator.validate(bundle: blocked)

        XCTAssertTrue(blockedIssues.contains(.hiddenReceipt))
        XCTAssertTrue(blockedIssues.contains(.missingUserControl))
        XCTAssertTrue(blockedIssues.contains(.userDataServerBoundaryBroken))
        XCTAssertTrue(blockedIssues.contains(.runtimeBoundaryBroken))
        XCTAssertEqual(validator.evaluate(bundle: blocked).readiness, .blocked)
        XCTAssertTrue(validator.validate(bundle: professionalReview).contains(.professionalBoundaryReviewRequired))
        XCTAssertEqual(validator.evaluate(bundle: professionalReview).readiness, .needsProfessionalReview)
    }
}

private extension AmbitionsOSLivingDreamTrustReceiptModelsTests {
    func makeBundle(
        receipts: [AmbitionsOSLivingDreamTrustReceipt]? = nil,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly
    ) -> AmbitionsOSLivingDreamTrustReceiptBundle {
        AmbitionsOSLivingDreamTrustReceiptBundle(
            id: "trust-bundle",
            todayBridgeID: "today-bridge",
            receipts: receipts ?? [
                receipt(id: "handling", kind: .handling, handlingLane: .sourceBackedPlan),
                receipt(id: "source-review", kind: .sourceReview),
                receipt(id: "user-confirmed", kind: .userConfirmation, assumptionIDs: ["assumption-1"]),
                receipt(
                    id: "refusal",
                    kind: .refusal,
                    refusalReason: "Cannot safely translate this into a plan.",
                    safeAlternativeSummary: "Keep it as a reviewed idea until sources are ready."
                )
            ],
            usesUserDataServer: usesUserDataServer,
            runtimeBoundary: runtimeBoundary
        )
    }

    func receipt(
        id: String,
        kind: AmbitionsOSLivingDreamTrustReceiptKind,
        handlingLane: AmbitionsOSLivingDreamHandlingLane? = nil,
        assumptionIDs: [String] = [],
        sourceClaimIDs: [String] = ["claim-1"],
        sourceReferenceIDs: [String] = ["source-1"],
        sourcePackIDs: [String] = ["pack-1"],
        proofReceiptIDs: [String] = ["proof-1"],
        changedFactSummaries: [String] = ["Trust state recorded."],
        originalTextSummary: String? = "Original reviewed source text.",
        translatedTextSummary: String? = "Plain-language summary for review.",
        refusalReason: String? = nil,
        safeAlternativeSummary: String? = nil,
        sourceState: HumanProgressSourceState = .sourceBacked,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready,
        mutationPermission: AmbitionsOSLivingDreamMutationPermission = .none,
        mutatesCommitments: Bool = false,
        reversible: Bool = true,
        visibleToUser: Bool = true,
        userControlIDs: [String] = ["review", "correct"],
        professionalBoundaryReviewRequired: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = ["Review before changing anything."]
    ) -> AmbitionsOSLivingDreamTrustReceipt {
        AmbitionsOSLivingDreamTrustReceipt(
            id: id,
            kind: kind,
            surface: .today,
            occurredAt: "2026-05-08T00:10:00Z",
            affectedObjectIDs: ["dream-1"],
            handlingLane: handlingLane,
            assumptionIDs: assumptionIDs,
            sourceClaimIDs: sourceClaimIDs,
            sourceReferenceIDs: sourceReferenceIDs,
            sourcePackIDs: sourcePackIDs,
            proofReceiptIDs: proofReceiptIDs,
            changedFactSummaries: changedFactSummaries,
            originalTextSummary: originalTextSummary,
            translatedTextSummary: translatedTextSummary,
            refusalReason: refusalReason,
            safeAlternativeSummary: safeAlternativeSummary,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            mutationPermission: mutationPermission,
            mutatesCommitments: mutatesCommitments,
            reversible: reversible,
            visibleToUser: visibleToUser,
            userControlIDs: userControlIDs,
            professionalBoundaryReviewRequired: professionalBoundaryReviewRequired,
            usesUserDataServer: usesUserDataServer,
            runtimeBoundary: runtimeBoundary,
            surfaceLanguageSamples: surfaceLanguageSamples
        )
    }
}
