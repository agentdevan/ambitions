import XCTest
@testable import Ambitions

final class AmbitionsOSInteroperabilityModelsTests: XCTestCase {
    private let validator = AmbitionsOSInteroperabilityValidator()

    func testReviewReadyInteroperabilityPlanRoundTripsAndValidates() throws {
        let plan = interoperabilityPlan()

        let data = try JSONEncoder().encode(plan)
        let decoded = try JSONDecoder().decode(AmbitionsOSInteroperabilityPlan.self, from: data)

        XCTAssertEqual(decoded.schemaVersion, ambitionsOSInteroperabilitySchemaVersion)
        XCTAssertEqual(decoded.surface, .appIntent)
        XCTAssertEqual(decoded.actionKind, .prepareIntentPayload)
        XCTAssertEqual(validator.validate(decoded), [])
    }

    func testInvalidSchemaMalformedPlanAndBlockedCapabilityAreRejected() {
        let plan = interoperabilityPlan(
            id: "",
            capabilityState: .blocked,
            payloadSummary: "",
            receipts: [receipt(id: "", action: "", occurredAt: "")],
            schemaVersion: "old.schema"
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedPlan))
        XCTAssertTrue(issues.contains(.blockedCapability))
    }

    func testPlatformImplementationActionsAreBlockedInPlanningBatch() {
        let invoke = interoperabilityPlan(actionKind: .invokeExternalAction)
        let write = interoperabilityPlan(
            actionKind: .writeCalendar,
            writesExternalSystem: true
        )
        let permission = interoperabilityPlan(
            actionKind: .requestPlatformPermission,
            requestsPlatformPermission: true
        )

        XCTAssertTrue(validator.validate(invoke).contains(.implementationBoundaryViolation))

        let writeIssues = validator.validate(write)
        XCTAssertTrue(writeIssues.contains(.implementationBoundaryViolation))
        XCTAssertTrue(writeIssues.contains(.platformWriteNotAllowed))

        let permissionIssues = validator.validate(permission)
        XCTAssertTrue(permissionIssues.contains(.permissionPromptNotAllowed))
    }

    func testSourceSensitiveSuggestionsRequireReviewReadySource() {
        let plan = interoperabilityPlan(
            actionKind: .prepareCalendarSuggestion,
            sourceState: .sourceNeeded,
            freshnessState: .stale,
            reviewState: .needsSourceReview
        )

        XCTAssertTrue(validator.validate(plan).contains(.sourceConfirmationMissing))
    }

    func testExternalPayloadRequiresRedactedPrivacyProjection() {
        let plan = interoperabilityPlan(
            privacyClass: .sensitive,
            sensitiveAreas: [.location, .thirdPartyPersonalData],
            projectionPolicy: .fullLocal,
            redactionSummary: ""
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.privacyProjectionMissing))
        XCTAssertTrue(issues.contains(.rawSensitiveExternalPayload))
    }

    func testApprovalReceiptsPerformanceAndCompatibilityAreRequired() {
        let plan = interoperabilityPlan(
            toolApprovalState: .requiresPrivacyReview,
            receipts: [receipt(userReviewed: false)],
            hasPerformanceBudget: false,
            hasCompatibilityReview: false
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.userApprovalMissing))
        XCTAssertTrue(issues.contains(.performanceBudgetMissing))
        XCTAssertTrue(issues.contains(.compatibilityReviewMissing))
    }

    func testRuntimeMutationRemoteDependencyAndReleaseLanguageAreBlocked() {
        let plan = interoperabilityPlan(
            changesAppState: true,
            dependsOnNetworkOrHostedService: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            ),
            surfaceLanguageSamples: [
                "Calendar replacement is platform ready and App Store ready."
            ]
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.hostedOrRemoteDependency))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
        XCTAssertTrue(issues.contains(.forbiddenLanguage))
        XCTAssertTrue(issues.contains(.releaseClaimWithoutEvidence))
    }
}

private extension AmbitionsOSInteroperabilityModelsTests {
    func interoperabilityPlan(
        id: String = "interop-app-intent-start-here",
        surface: AmbitionsOSInteroperabilitySurface = .appIntent,
        ownerSurface: AmbitionsOSControlPlaneSurface = .externalProjection,
        actionKind: AmbitionsOSInteroperabilityActionKind = .prepareIntentPayload,
        capabilityState: AmbitionsOSInteroperabilityCapabilityState = .plannedOnly,
        payloadSummary: String = "Prepare a redacted Start Here intent payload for review.",
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sensitiveAreas: [AmbitionsOSPrivacySensitiveArea] = [],
        projectionPolicy: AmbitionsOSPrivacyProjectionPolicy = .externalRedacted,
        redactionSummary: String = "Only object title, owning surface, and review reason leave the app.",
        toolApprovalState: AmbitionsOSLocalLanguageToolApprovalState = .reviewOnly,
        receipts: [AmbitionsOSInteroperabilityReceipt]? = nil,
        hasPerformanceBudget: Bool = true,
        hasCompatibilityReview: Bool = true,
        changesAppState: Bool = false,
        requestsPlatformPermission: Bool = false,
        writesExternalSystem: Bool = false,
        dependsOnNetworkOrHostedService: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = ["Prepared for review, not executed."],
        schemaVersion: String = ambitionsOSInteroperabilitySchemaVersion
    ) -> AmbitionsOSInteroperabilityPlan {
        AmbitionsOSInteroperabilityPlan(
            id: id,
            surface: surface,
            ownerSurface: ownerSurface,
            actionKind: actionKind,
            capabilityState: capabilityState,
            payloadSummary: payloadSummary,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            sensitiveAreas: sensitiveAreas,
            projectionPolicy: projectionPolicy,
            redactionSummary: redactionSummary,
            toolApprovalState: toolApprovalState,
            receipts: receipts ?? [receipt()],
            hasPerformanceBudget: hasPerformanceBudget,
            hasCompatibilityReview: hasCompatibilityReview,
            changesAppState: changesAppState,
            requestsPlatformPermission: requestsPlatformPermission,
            writesExternalSystem: writesExternalSystem,
            dependsOnNetworkOrHostedService: dependsOnNetworkOrHostedService,
            runtimeBoundary: runtimeBoundary,
            surfaceLanguageSamples: surfaceLanguageSamples,
            schemaVersion: schemaVersion
        )
    }

    func receipt(
        id: String = "receipt-interop-reviewed",
        action: String = "interoperability plan reviewed",
        occurredAt: String = "2026-05-07T02:10:00Z",
        userReviewed: Bool = true
    ) -> AmbitionsOSInteroperabilityReceipt {
        AmbitionsOSInteroperabilityReceipt(
            id: id,
            action: action,
            occurredAt: occurredAt,
            userReviewed: userReviewed
        )
    }
}
