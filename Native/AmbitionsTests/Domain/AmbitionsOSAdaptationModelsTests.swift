import XCTest
@testable import Ambitions

final class AmbitionsOSAdaptationModelsTests: XCTestCase {
    private let validator = AmbitionsOSAdaptationValidator()

    func testReviewReadyAdaptationProfileRoundTripsAndValidates() throws {
        let profile = adaptationProfile()

        let data = try JSONEncoder().encode(profile)
        let decoded = try JSONDecoder().decode(AmbitionsOSAdaptationProfile.self, from: data)

        XCTAssertEqual(decoded.schemaVersion, ambitionsOSAdaptationSchemaVersion)
        XCTAssertEqual(decoded.surface, .you)
        XCTAssertEqual(decoded.permissionState, .userApproved)
        XCTAssertEqual(validator.validate(decoded), [])
    }

    func testInvalidSchemaMalformedProfileAndMissingControlsAreRejected() {
        let profile = adaptationProfile(
            id: "",
            objectID: "",
            dimensions: [],
            assumptions: [assumption(id: "", summary: "")],
            receipts: [receipt(id: "", occurredAt: "")],
            userControls: [],
            schemaVersion: "old.schema"
        )

        let issues = validator.validate(profile)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedProfile))
        XCTAssertTrue(issues.contains(.missingUserControl))
    }

    func testHiddenOrRejectedPersonalizationCannotDriveUse() {
        let profile = adaptationProfile(permissionState: .inferredNeedsReview)

        XCTAssertTrue(validator.validate(profile).contains(.hiddenPersonalization))
    }

    func testRejectedAndInvisibleAssumptionsAreBlocked() {
        let profile = adaptationProfile(
            assumptions: [
                assumption(id: "assumption-rejected", state: .rejected),
                assumption(id: "assumption-hidden", state: .needsReview, userVisible: false)
            ]
        )

        let issues = validator.validate(profile)

        XCTAssertTrue(issues.contains(.rejectedAssumptionStillActive))
        XCTAssertTrue(issues.contains(.unreviewedAssumption))
    }

    func testSeriousnessChangesRequireUserReviewedReceipt() {
        let profile = adaptationProfile(
            dimensions: [.seriousness],
            receipts: [receipt(kind: .approval)],
            changesSeriousness: true
        )

        XCTAssertTrue(validator.validate(profile).contains(.seriousnessChangeMissingReceipt))
    }

    func testSensitiveAdaptationNeedsPrivacyReviewAndReceipt() {
        let profile = adaptationProfile(
            receipts: [receipt(userReviewed: false)],
            privacyClass: .sensitive,
            reviewState: .needsPrivacyReview
        )

        XCTAssertTrue(validator.validate(profile).contains(.sensitiveAdaptationNeedsPrivacyReview))
    }

    func testDeterministicFallbackAndModelRequiredPathsAreBlocked() {
        let profile = adaptationProfile(
            deterministicFallbackAvailable: false,
            requiresModelToApply: true
        )

        let issues = validator.validate(profile)

        XCTAssertTrue(issues.contains(.deterministicFallbackMissing))
        XCTAssertTrue(issues.contains(.modelRequiredPath))
    }

    func testForbiddenLanguageHiddenMutationAndRuntimeStoreBehaviorAreBlocked() {
        let profile = adaptationProfile(
            mutatesAutomatically: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            ),
            surfaceLanguageSamples: [
                "AI confidence creates an autopersonalized productivity score."
            ]
        )

        let issues = validator.validate(profile)

        XCTAssertTrue(issues.contains(.forbiddenLanguage))
        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
    }
}

private extension AmbitionsOSAdaptationModelsTests {
    func adaptationProfile(
        id: String = "adaptation-you-capacity",
        surface: AmbitionsOSControlPlaneSurface = .you,
        objectID: String = "profile-local-calibration",
        dimensions: [AmbitionsOSAdaptationDimension] = [.capacity, .energy],
        permissionState: AmbitionsOSAdaptationPermissionState = .userApproved,
        assumptions: [AmbitionsOSAdaptationAssumption]? = nil,
        receipts: [AmbitionsOSAdaptationReceipt]? = nil,
        userControls: [String] = ["review", "correct", "reset"],
        changesSeriousness: Bool = false,
        deterministicFallbackAvailable: Bool = true,
        requiresModelToApply: Bool = false,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        reviewState: HumanProgressReviewState = .ready,
        mutatesAutomatically: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = ["You can review or reset this assumption."],
        schemaVersion: String = ambitionsOSAdaptationSchemaVersion
    ) -> AmbitionsOSAdaptationProfile {
        AmbitionsOSAdaptationProfile(
            id: id,
            surface: surface,
            objectID: objectID,
            dimensions: dimensions,
            permissionState: permissionState,
            assumptions: assumptions ?? [assumption()],
            receipts: receipts ?? [receipt()],
            userControls: userControls,
            changesSeriousness: changesSeriousness,
            deterministicFallbackAvailable: deterministicFallbackAvailable,
            requiresModelToApply: requiresModelToApply,
            privacyClass: privacyClass,
            reviewState: reviewState,
            mutatesAutomatically: mutatesAutomatically,
            runtimeBoundary: runtimeBoundary,
            surfaceLanguageSamples: surfaceLanguageSamples,
            schemaVersion: schemaVersion
        )
    }

    func assumption(
        id: String = "assumption-energy",
        summary: String = "Mornings usually fit high-focus work.",
        dimension: AmbitionsOSAdaptationDimension = .energy,
        state: AmbitionsOSAdaptationAssumptionState = .userConfirmed,
        userVisible: Bool = true
    ) -> AmbitionsOSAdaptationAssumption {
        AmbitionsOSAdaptationAssumption(
            id: id,
            summary: summary,
            dimension: dimension,
            state: state,
            userVisible: userVisible
        )
    }

    func receipt(
        id: String = "receipt-adaptation-approved",
        kind: AmbitionsOSAdaptationReceiptKind = .approval,
        occurredAt: String = "2026-05-07T01:00:00Z",
        assumptionIDs: [String] = ["assumption-energy"],
        userReviewed: Bool = true
    ) -> AmbitionsOSAdaptationReceipt {
        AmbitionsOSAdaptationReceipt(
            id: id,
            kind: kind,
            occurredAt: occurredAt,
            assumptionIDs: assumptionIDs,
            userReviewed: userReviewed
        )
    }
}
