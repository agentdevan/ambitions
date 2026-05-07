import XCTest
@testable import Ambitions

final class AmbitionsOSLocalLanguageModelsTests: XCTestCase {
    private let validator = AmbitionsOSLocalLanguageValidator()

    func testDeterministicCapturePlanRoundTripsAndValidates() throws {
        let plan = makePlan()

        let data = try JSONEncoder().encode(plan)
        let decoded = try JSONDecoder().decode(AmbitionsOSLocalLanguagePlan.self, from: data)

        XCTAssertEqual(decoded, plan)
        XCTAssertEqual(decoded.schemaVersion, ambitionsOSLocalLanguageSchemaVersion)
        XCTAssertTrue(decoded.deterministicFallbackAvailable)
        XCTAssertEqual(validator.validate(decoded), [])
    }

    func testInvalidSchemaMalformedPlanAndUnsupportedSurfaceAreRejected() {
        let plan = makePlan(
            id: " ",
            surface: .today,
            inputSummary: " ",
            fields: [],
            schemaVersion: "future.schema"
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedPlan))
        XCTAssertTrue(issues.contains(.unsupportedSurface))
    }

    func testModelAdapterPlanningRequiresFallbackAndNeverInvokesRuntime() {
        let plan = makePlan(
            adapterTier: .tier2PlatformLocalAdapter,
            deterministicFallbackAvailable: false,
            invokesModelRuntime: true,
            hasPerformanceBudget: false
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.missingDeterministicFallback))
        XCTAssertTrue(issues.contains(.modelRuntimeNotAllowed))
        XCTAssertTrue(issues.contains(.performanceBudgetMissing))
    }

    func testBlockedModelTierCannotBecomeCorePath() {
        let plan = makePlan(adapterTier: .tier4BundledCustomModel)

        XCTAssertTrue(validator.validate(plan).contains(.blockedAdapterTier))
    }

    func testSourceFreshnessAndPrivacyGatesAreEnforced() {
        let plan = makePlan(
            sourceState: .sourceNeeded,
            freshnessState: .staleCritical,
            reviewState: .needsPrivacyReview,
            privacyClass: .sensitive,
            sensitiveAreaLabels: ["medical"]
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.sourceReviewRequired))
        XCTAssertTrue(issues.contains(.staleSourceReviewRequired))
        XCTAssertTrue(issues.contains(.privacyReviewRequired))
    }

    func testToolExternalProjectionAndHiddenMutationBoundariesAreEnforced() {
        let plan = makePlan(
            intent: .toolProposal,
            privacyClass: .sensitive,
            sensitiveAreaLabels: ["family"],
            projectsExternally: true,
            toolApprovalState: .notAllowed,
            changesAppState: true
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.externalProjectionRisk))
        XCTAssertTrue(issues.contains(.toolApprovalRequired))
        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
    }

    func testLanguageRuntimeAndStoreBoundariesStayCompact() {
        let plan = makePlan(
            exposesConfidenceLanguage: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            ),
            surfaceLanguageSamples: [
                "AI " + "confidence and productivity " + "score are not allowed."
            ]
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.confidenceLanguage))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
    }

    private func makePlan(
        id: String = "language-plan-1",
        intent: AmbitionsOSLocalLanguageIntent = .captureParse,
        surface: AmbitionsOSControlPlaneSurface = .capture,
        inputSummary: String = "Clarify a captured intention before placement.",
        fields: [AmbitionsOSLocalLanguageField] = [
            AmbitionsOSLocalLanguageField(
                id: "field-1",
                name: "possible_step",
                valueSummary: "Call the advisor office.",
                sourceBoundary: "User-entered capture text",
                reviewState: .needsUserReview
            )
        ],
        adapterTier: AmbitionsOSLocalLanguageAdapterTier = .tier0Deterministic,
        fallbackState: AmbitionsOSLocalLanguageFallbackState = .deterministicAvailable,
        deterministicFallbackAvailable: Bool = true,
        invokesModelRuntime: Bool = false,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sensitiveAreaLabels: [String] = [],
        projectsExternally: Bool = false,
        toolApprovalState: AmbitionsOSLocalLanguageToolApprovalState = .reviewOnly,
        changesAppState: Bool = false,
        hasPerformanceBudget: Bool = true,
        exposesConfidenceLanguage: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = [],
        schemaVersion: String = ambitionsOSLocalLanguageSchemaVersion
    ) -> AmbitionsOSLocalLanguagePlan {
        AmbitionsOSLocalLanguagePlan(
            id: id,
            intent: intent,
            surface: surface,
            inputSummary: inputSummary,
            fields: fields,
            adapterTier: adapterTier,
            fallbackState: fallbackState,
            deterministicFallbackAvailable: deterministicFallbackAvailable,
            invokesModelRuntime: invokesModelRuntime,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            sensitiveAreaLabels: sensitiveAreaLabels,
            projectsExternally: projectsExternally,
            toolApprovalState: toolApprovalState,
            changesAppState: changesAppState,
            hasPerformanceBudget: hasPerformanceBudget,
            exposesConfidenceLanguage: exposesConfidenceLanguage,
            runtimeBoundary: runtimeBoundary,
            surfaceLanguageSamples: surfaceLanguageSamples,
            schemaVersion: schemaVersion
        )
    }
}
