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

    func testReflectionAdaptationRecordRoundTripsAndCanInformFutureRecommendations() throws {
        let record = reflectionRecord()

        let data = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(AmbitionsOSReflectionAdaptationRecord.self, from: data)

        XCTAssertEqual(decoded.schemaVersion, ambitionsOSAdaptationSchemaVersion)
        XCTAssertEqual(decoded.intent, .futureRecommendationInput)
        XCTAssertTrue(decoded.canInformFutureRecommendations)
        XCTAssertEqual(decoded.controlActions, ["disable", "review", "reset"])
        XCTAssertEqual(validator.validate(decoded), [])
    }

    func testReflectionRecordsRejectHiddenInferenceAndMissingControlPath() {
        let record = reflectionRecord(
            userVisible: false,
            localOnly: false,
            deterministic: false,
            receiptIDs: [],
            controlActions: []
        )

        let issues = validator.validate(record)

        XCTAssertFalse(record.canInformFutureRecommendations)
        XCTAssertTrue(issues.contains(.hiddenReflection))
        XCTAssertTrue(issues.contains(.reflectionMissingReceipt))
        XCTAssertTrue(issues.contains(.missingControlAction))
    }

    func testReflectionRecordsRejectModelRequiredAndMissingFallbackPaths() {
        let record = reflectionRecord(
            deterministicFallbackAvailable: false,
            requiresModelToApply: true
        )

        let issues = validator.validate(record)

        XCTAssertFalse(record.canInformFutureRecommendations)
        XCTAssertTrue(issues.contains(.deterministicFallbackMissing))
        XCTAssertTrue(issues.contains(.modelRequiredPath))
    }

    func testReflectionRecordsRejectDiaryAndChatbotBehavior() {
        let diary = reflectionRecord(
            id: "reflection-diary",
            intent: .privateDiary,
            surfaceLanguageSamples: ["Diary entry about how the day felt."]
        )
        let chatbot = reflectionRecord(
            id: "reflection-chatbot",
            intent: .chatbotConversation,
            surfaceLanguageSamples: ["Chat transcript where assistant says what to do."]
        )

        let diaryIssues = validator.validate(diary)
        let chatbotIssues = validator.validate(chatbot)

        XCTAssertFalse(diary.canInformFutureRecommendations)
        XCTAssertTrue(diaryIssues.contains(.diaryBehavior))
        XCTAssertTrue(diaryIssues.contains(.forbiddenLanguage))
        XCTAssertFalse(chatbot.canInformFutureRecommendations)
        XCTAssertTrue(chatbotIssues.contains(.chatbotBehavior))
        XCTAssertTrue(chatbotIssues.contains(.forbiddenLanguage))
    }

    func testReflectionRecordsRejectForbiddenLanguageSilentMutationAndRuntimeStoreBehavior() {
        let record = reflectionRecord(
            mutatesAutomatically: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: false,
                performsNetworkFetches: false,
                mutatesPlans: true,
                writesPersistence: true
            ),
            surfaceLanguageSamples: [
                "AI confidence says this is the best future pattern."
            ]
        )

        let issues = validator.validate(record)

        XCTAssertFalse(record.canInformFutureRecommendations)
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

    func reflectionRecord(
        id: String = "reflection-recovery-fit",
        sourceObjectID: String = "recovery-thread-1",
        surface: AmbitionsOSControlPlaneSurface = .you,
        kind: AmbitionsOSReflectionAdaptationKind = .recoveryLearning,
        intent: AmbitionsOSReflectionAdaptationIntent = .futureRecommendationInput,
        summary: String = "Shortened steps helped recovery after a blocked day.",
        recommendationInfluenceSummary: String = "Prefer smaller re-entry steps after similar recovery signals.",
        dimensions: [AmbitionsOSAdaptationDimension] = [.capacity, .recovery],
        userVisible: Bool = true,
        localOnly: Bool = true,
        deterministic: Bool = true,
        deterministicFallbackAvailable: Bool = true,
        requiresModelToApply: Bool = false,
        mutatesAutomatically: Bool = false,
        receiptIDs: [String] = ["receipt-recovery-reflection"],
        controlActions: [String] = ["review", "reset", "disable"],
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        reviewState: HumanProgressReviewState = .ready,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = ["You can review, reset, or disable this local learning."],
        schemaVersion: String = ambitionsOSAdaptationSchemaVersion
    ) -> AmbitionsOSReflectionAdaptationRecord {
        AmbitionsOSReflectionAdaptationRecord(
            id: id,
            sourceObjectID: sourceObjectID,
            surface: surface,
            kind: kind,
            intent: intent,
            summary: summary,
            recommendationInfluenceSummary: recommendationInfluenceSummary,
            dimensions: dimensions,
            userVisible: userVisible,
            localOnly: localOnly,
            deterministic: deterministic,
            deterministicFallbackAvailable: deterministicFallbackAvailable,
            requiresModelToApply: requiresModelToApply,
            mutatesAutomatically: mutatesAutomatically,
            receiptIDs: receiptIDs,
            controlActions: controlActions,
            privacyClass: privacyClass,
            reviewState: reviewState,
            runtimeBoundary: runtimeBoundary,
            surfaceLanguageSamples: surfaceLanguageSamples,
            schemaVersion: schemaVersion
        )
    }
}
