import XCTest
@testable import Ambitions

final class AmbitionsOSOptionValueModelsTests: XCTestCase {
    func testReviewedOptionValueEntryRoundTrips() throws {
        let entry = optionValueEntry(
            transferState: .partiallyReusable,
            requirementOverlapState: .supportingProof,
            proofReceiptIDs: ["proof.one"],
            sourceClaimIDs: ["claim.one"],
            reviewState: .ready
        )

        let data = try JSONEncoder().encode(entry)
        let decoded = try JSONDecoder().decode(AmbitionsOSOptionValueEntry.self, from: data)

        XCTAssertEqual(decoded, entry)
        XCTAssertTrue(decoded.validationIssues.isEmpty)
    }

    func testInvalidSchemaAndMissingPathReferencesAreRejected() {
        let entry = optionValueEntry(
            id: "",
            sourcePathID: "",
            targetPathID: "",
            northStarContinuity: "",
            schemaVersion: "future"
        )

        let issues = entry.validationIssues

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedEntry))
        XCTAssertTrue(issues.contains(.missingPathReferences))
    }

    func testProofTransferRequiresRequirementAndSourceOverlap() {
        let entry = optionValueEntry(
            transferState: .directlyReusable,
            requirementOverlapState: .narrativeOnly,
            proofReceiptIDs: ["proof.old"],
            sourceClaimIDs: []
        )

        XCTAssertTrue(entry.validationIssues.contains(.proofTransferWithoutOverlap))
    }

    func testSourceAndFreshnessReviewGatesAreEnforced() {
        let entry = optionValueEntry(
            transferState: .needsSourceReview,
            requirementOverlapState: .sourceNeeded,
            sourceState: .sourceNeeded,
            freshnessState: .unknown,
            reviewState: .needsSourceReview
        )

        XCTAssertTrue(entry.validationIssues.contains(.sourceReviewRequired))
    }

    func testNorthStarContinuityMustBeUserReviewedAndNonDestinyLanguage() {
        let entry = optionValueEntry(
            family: .northStarContinuity,
            reviewState: .needsUserReview,
            surfaceLanguageSamples: ["This is the path you are destined to follow."]
        )

        let issues = entry.validationIssues

        XCTAssertTrue(issues.contains(.northStarNotUserReviewed))
        XCTAssertTrue(issues.contains(.destinyLanguage))
    }

    func testStillCountsReceiptDoesNotClaimCompletionOrShamePriorWork() {
        let entry = optionValueEntry(
            family: .stillCountsReceipt,
            claimsCompletion: true,
            surfaceLanguageSamples: ["This failed path was wasted."]
        )

        let issues = entry.validationIssues

        XCTAssertTrue(issues.contains(.fakeCompletionRisk))
        XCTAssertTrue(issues.contains(.shameLanguage))
    }

    func testUnsafeLiteralPlanAndGuaranteedOutcomeAreBlocked() {
        let entry = optionValueEntry(
            claimsGuaranteedOutcome: true,
            validatesLiteralUnsafePlan: true
        )

        let issues = entry.validationIssues

        XCTAssertTrue(issues.contains(.guaranteedOutcomeOverclaim))
        XCTAssertTrue(issues.contains(.harmfulLiteralPlanRisk))
    }

    func testSilentMutationRuntimeStoreAndSensitivePrivacyReviewAreBlocked() {
        let entry = optionValueEntry(
            reviewState: .needsPrivacyReview,
            privacyClass: .sensitive,
            mutationPermissionState: .userApproved,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: false,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        let issues = entry.validationIssues

        XCTAssertTrue(issues.contains(.privacyReviewRequired))
        XCTAssertTrue(issues.contains(.silentMutationRisk))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
    }

    private func optionValueEntry(
        id: String = "option.value.one",
        sourcePathID: String = "path.source",
        targetPathID: String = "path.target",
        family: AmbitionsOSOptionValueFamily = .optionValueEntry,
        transferState: AmbitionsOSOptionValueTransferState = .supportsNarrative,
        requirementOverlapState: AmbitionsOSRequirementOverlapState = .supportingSkill,
        proofReceiptIDs: [String] = [],
        sourceClaimIDs: [String] = [],
        northStarContinuity: String = "The direction still matters.",
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .needsUserReview,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        mutationPermissionState: AmbitionsOSOptionValueMutationPermission = .reviewOnly,
        claimsGuaranteedOutcome: Bool = false,
        claimsCompletion: Bool = false,
        validatesLiteralUnsafePlan: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = ["This still counts as context."],
        schemaVersion: String = ambitionsOSOptionValueSchemaVersion
    ) -> AmbitionsOSOptionValueEntry {
        AmbitionsOSOptionValueEntry(
            id: id,
            sourcePathID: sourcePathID,
            targetPathID: targetPathID,
            family: family,
            transferState: transferState,
            requirementOverlapState: requirementOverlapState,
            proofReceiptIDs: proofReceiptIDs,
            sourceClaimIDs: sourceClaimIDs,
            northStarContinuity: northStarContinuity,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            mutationPermissionState: mutationPermissionState,
            claimsGuaranteedOutcome: claimsGuaranteedOutcome,
            claimsCompletion: claimsCompletion,
            validatesLiteralUnsafePlan: validatesLiteralUnsafePlan,
            runtimeBoundary: runtimeBoundary,
            surfaceLanguageSamples: surfaceLanguageSamples,
            schemaVersion: schemaVersion
        )
    }
}
