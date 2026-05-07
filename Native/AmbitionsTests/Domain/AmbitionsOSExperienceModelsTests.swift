import XCTest
@testable import Ambitions

final class AmbitionsOSExperienceModelsTests: XCTestCase {
    private let validator = AmbitionsOSExperienceValidator()

    func testValidExperienceContractRoundTripsAndValidates() throws {
        let contract = experienceContract()

        let data = try JSONEncoder().encode(contract)
        let decoded = try JSONDecoder().decode(AmbitionsOSExperienceContract.self, from: data)

        XCTAssertEqual(decoded.schemaVersion, ambitionsOSExperienceSchemaVersion)
        XCTAssertEqual(decoded.primaryObject, .startHere)
        XCTAssertEqual(validator.validate(decoded), [])
    }

    func testInvalidSchemaAndMalformedContractAreRejected() {
        let contract = experienceContract(
            id: "",
            primaryDecisionCount: -1,
            visibleSectionCount: 0,
            copySamples: [],
            recoveryLanguageSamples: [],
            schemaVersion: "old.schema"
        )

        let issues = validator.validate(contract)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedContract))
    }

    func testOnlyCanonicalUserSurfacesCanCarryExperienceContracts() {
        let contract = experienceContract(surface: .runtimeContract)

        XCTAssertTrue(validator.validate(contract).contains(.nonCanonicalSurface))
    }

    func testPrimaryObjectAndDecisionBudgetAreRequired() {
        let contract = experienceContract(
            primaryObject: .none,
            primaryDecisionCount: 4,
            visibleSectionCount: 9
        )

        let issues = validator.validate(contract)

        XCTAssertTrue(issues.contains(.missingPrimaryObject))
        XCTAssertTrue(issues.contains(.tooManyPrimaryDecisions))
        XCTAssertTrue(issues.contains(.tooManyVisibleSections))
    }

    func testAmbiguousWayfindingAndTodayFullPathDepthAreRejected() {
        let contract = experienceContract(
            wayfindingState: .ambiguous,
            permitsFullPathDepth: true
        )

        let issues = validator.validate(contract)

        XCTAssertTrue(issues.contains(.ambiguousWayfinding))
        XCTAssertTrue(issues.contains(.todayFullPathDepth))
    }

    func testDashboardDriftAndForbiddenLanguageAreRejected() {
        let contract = experienceContract(
            densityState: .dashboardDrift,
            copySamples: [
                "Task dashboard",
                "AI confidence",
                "Productivity score"
            ]
        )

        let issues = validator.validate(contract)

        XCTAssertTrue(issues.contains(.genericDashboardDrift))
        XCTAssertTrue(issues.contains(.forbiddenLanguage))
    }

    func testAccessibilityAndPrivacySafeLabelsArePreDeviceGates() {
        let contract = experienceContract(
            accessibility: AmbitionsOSExperienceAccessibilityContract(
                voiceOverReady: false,
                dynamicTypeReady: true,
                reduceMotionReady: true,
                nonColorMeaningReady: true,
                hitTargetsReady: true,
                cognitiveLoadReviewReady: false,
                privacySafeLabelsReady: false
            ),
            privacyClass: .sensitive
        )

        let issues = validator.validate(contract)

        XCTAssertTrue(issues.contains(.accessibilityReviewMissing))
        XCTAssertTrue(issues.contains(.privacySafeLabelMissing))
    }

    func testRecoveryLanguageMustStayNonShaming() {
        let contract = experienceContract(
            recoveryLanguageSamples: [
                "You failed because this is overdue."
            ]
        )

        XCTAssertTrue(validator.validate(contract).contains(.recoveryLanguageMissing))
    }

    func testHiddenMutationAndRuntimeStoreBehaviorAreRejected() {
        let contract = experienceContract(
            changesAppState: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        let issues = validator.validate(contract)

        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
    }
}

private extension AmbitionsOSExperienceModelsTests {
    func experienceContract(
        id: String = "today-start-here-experience",
        surface: AmbitionsOSControlPlaneSurface = .today,
        primaryObject: AmbitionsOSExperiencePrimaryObject = .startHere,
        wayfindingState: AmbitionsOSExperienceWayfindingState = .oriented,
        densityState: AmbitionsOSExperienceDensityState = .focused,
        primaryDecisionCount: Int = 1,
        visibleSectionCount: Int = 4,
        permitsFullPathDepth: Bool = false,
        preservesTopLevelIADestination: Bool = true,
        copySamples: [String] = [
            "Start here",
            "Close the loop",
            "You are in control"
        ],
        recoveryLanguageSamples: [String] = [
            "Still counts",
            "Make today doable"
        ],
        accessibility: AmbitionsOSExperienceAccessibilityContract = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        changesAppState: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSExperienceSchemaVersion
    ) -> AmbitionsOSExperienceContract {
        AmbitionsOSExperienceContract(
            id: id,
            surface: surface,
            primaryObject: primaryObject,
            wayfindingState: wayfindingState,
            densityState: densityState,
            primaryDecisionCount: primaryDecisionCount,
            visibleSectionCount: visibleSectionCount,
            permitsFullPathDepth: permitsFullPathDepth,
            preservesTopLevelIADestination: preservesTopLevelIADestination,
            copySamples: copySamples,
            recoveryLanguageSamples: recoveryLanguageSamples,
            accessibility: accessibility,
            privacyClass: privacyClass,
            changesAppState: changesAppState,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }
}
