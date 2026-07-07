import XCTest
@testable import Ambitions

final class AmbitionsOSExperienceModelsTests: XCTestCase {
    private let validator = AmbitionsOSExperienceValidator()
    private let compiler = AmbitionsOSExperienceCompiler()

    func testValidExperienceContractRoundTripsAndValidates() throws {
        let contract = experienceContract()

        let data = try JSONEncoder().encode(contract)
        let decoded = try JSONDecoder().decode(AmbitionsOSExperienceContract.self, from: data)

        XCTAssertEqual(decoded.schemaVersion, ambitionsOSExperienceSchemaVersion)
        XCTAssertEqual(decoded.primaryObject, .startHere)
        XCTAssertEqual(validator.validate(decoded), [])
    }

    func testCanonicalUserSurfaceContractOnlyAcceptsTodayGoalsTimeYou() {
        let rootSurfaces = AmbitionsOSControlPlaneSurface.canonicalPersistentUserSurfaces
        let nonRootSurfaces: [AmbitionsOSControlPlaneSurface] = [
            .captureComposer,
            .inspectionDetail,
            .externalProjection,
            .runtimeContract
        ]

        XCTAssertEqual(rootSurfaces.map(\.rawValue), ["today", "goals", "time", "you"])
        XCTAssertEqual(rootSurfaces.map(\.rawValue), AmbitionsSurface.allCases.map(\.rawValue))
        XCTAssertTrue(rootSurfaces.allSatisfy(\.isPersistentUserSurface))
        XCTAssertTrue(rootSurfaces.allSatisfy { experienceContract(surface: $0).isCanonicalUserSurface })
        XCTAssertTrue(nonRootSurfaces.allSatisfy { experienceContract(surface: $0).isCanonicalUserSurface == false })
        XCTAssertEqual(
            AmbitionsOSControlPlaneSurface.allCases.map(\.rawValue).filter {
                ["capture", "captures", "plan", "profile", "motion"].contains($0)
            },
            []
        )
    }

    func testCaptureComposerExperienceUsesSeparateNonRootValidationPath() {
        let contract = experienceContract(
            id: "capture-composer-experience",
            surface: .captureComposer,
            primaryObject: .captureComposer,
            copySamples: [
                "Capture",
                "Review before saving",
                "You are in control"
            ],
            recoveryLanguageSamples: [
                "Keep it private",
                "Choose where it belongs"
            ]
        )

        XCTAssertFalse(contract.isCanonicalUserSurface)
        XCTAssertTrue(contract.isGlobalComposerExperience)
        XCTAssertFalse(contract.surface.isPersistentUserSurface)
        XCTAssertEqual(validator.validate(contract), [])
    }

    func testOnlyCanonicalUserSurfacesCanCarryExperienceContracts() {
        let contract = experienceContract(surface: .runtimeContract)

        XCTAssertTrue(validator.validate(contract).contains(.nonCanonicalSurface))
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

    func testExperienceCompilerIsDeterministicForSameSemanticInputs() {
        let input = semanticVisualInput(
            capacity: .tight,
            protectedPressure: .reserved,
            proofStrength: .strong,
            goalPull: .urgent
        )

        let first = compiler.compile(input)
        let second = compiler.compile(input)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.livingState, .pressured)
        XCTAssertTrue(first.semanticCauseIDs.contains("capacity.tight"))
        XCTAssertTrue(first.semanticCauseIDs.contains("protected_pressure.reserved"))
        XCTAssertTrue(first.semanticCauseIDs.contains("proof_strength.strong"))
        XCTAssertTrue(first.semanticCauseIDs.contains("goal_pull.urgent"))
    }

    func testExperienceCompilerMapsEveryRuntimeInputIntoSemanticCausality() {
        let baseline = compiler.compile(semanticVisualInput())
        let variations: [(String, AmbitionsOSExperienceSemanticVisualInput, AmbitionsOSExperienceLivingVisualState?)] = [
            (
                "capacity.depleted",
                semanticVisualInput(capacity: .depleted),
                .pressured
            ),
            (
                "protected_pressure.conflict",
                semanticVisualInput(protectedPressure: .conflict),
                .pressured
            ),
            (
                "closure_residue.recovery",
                semanticVisualInput(closureResidue: .recovery),
                .recovery
            ),
            (
                "source_freshness.stale",
                semanticVisualInput(sourceFreshness: .stale),
                .stale
            ),
            (
                "proof_strength.decisive",
                semanticVisualInput(proofStrength: .decisive, goalPull: .neutral),
                .proof
            ),
            (
                "goal_pull.urgent",
                semanticVisualInput(proofStrength: .absent, goalPull: .urgent),
                .active
            ),
            (
                "recovery_need.required",
                semanticVisualInput(recoveryNeed: .required),
                .recovery
            ),
            (
                "privacy_mode.sensitive",
                semanticVisualInput(privacyMode: .sensitive),
                .sensitive
            )
        ]

        for (causeID, input, expectedState) in variations {
            let compiled = compiler.compile(input)

            XCTAssertNotEqual(compiled.snapshotKey, baseline.snapshotKey, causeID)
            XCTAssertTrue(compiled.semanticCauseIDs.contains(causeID), causeID)
            if let expectedState {
                XCTAssertEqual(compiled.livingState, expectedState, causeID)
            }
        }
    }

    func testExperienceCompilerProducesStableGoldenSnapshotOutput() throws {
        let input = semanticVisualInput(
            capacity: .depleted,
            protectedPressure: .conflict,
            closureResidue: .light,
            sourceFreshness: .current,
            proofStrength: .supporting,
            goalPull: .urgent,
            recoveryNeed: .gentle,
            privacyMode: .standard
        )

        let compiled = compiler.compile(input)
        let data = try JSONEncoder.stableAmbitionsSnapshotEncoder.encode(compiled)
        let snapshot = String(decoding: data, as: UTF8.self)

        XCTAssertEqual(compiled.livingState, .pressured)
        XCTAssertEqual(
            snapshot,
            #"{"accessibilityLabel":"Pressure visible. Caused by surface today, capacity depleted, protected pressure conflict, closure residue light, source freshness current, proof strength supporting, goal pull urgent, recovery need gentle, privacy mode standard.","criticalSignature":"pressured|capacity.depleted|closure_residue.light|goal_pull.urgent|privacy_mode.standard|proof_strength.supporting|protected_pressure.conflict|recovery_need.gentle|source_freshness.current|surface.today","intensity":0.96,"livingState":"pressured","semanticCauseIDs":["capacity.depleted","closure_residue.light","goal_pull.urgent","privacy_mode.standard","proof_strength.supporting","protected_pressure.conflict","recovery_need.gentle","source_freshness.current","surface.today"],"snapshotKey":"pressured|0.96|capacity.depleted|closure_residue.light|goal_pull.urgent|privacy_mode.standard|proof_strength.supporting|protected_pressure.conflict|recovery_need.gentle|source_freshness.current|surface.today"}"#
        )
    }

    func testDecorativeVariationCannotDriveProductCriticalVisualState() {
        let input = semanticVisualInput(
            capacity: .balanced,
            protectedPressure: .clear,
            closureResidue: .none,
            sourceFreshness: .current,
            proofStrength: .supporting,
            goalPull: .present,
            recoveryNeed: .none,
            privacyMode: .standard
        )

        let neutralDecoration = compiler.compile(
            input,
            decorativeVariation: AmbitionsOSExperienceDecorativeVariation(
                particlePhase: 0,
                grainSeed: 0,
                shimmerOffset: 0
            )
        )
        let noisyDecoration = compiler.compile(
            input,
            decorativeVariation: AmbitionsOSExperienceDecorativeVariation(
                particlePhase: 997,
                grainSeed: 811,
                shimmerOffset: 0.73
            )
        )

        XCTAssertEqual(noisyDecoration.criticalSignature, neutralDecoration.criticalSignature)
        XCTAssertEqual(noisyDecoration.snapshotKey, neutralDecoration.snapshotKey)
        XCTAssertEqual(noisyDecoration.livingState, neutralDecoration.livingState)
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

    func semanticVisualInput(
        surface: AmbitionsOSControlPlaneSurface = .today,
        capacity: AmbitionsOSExperienceCapacityState = .balanced,
        protectedPressure: AmbitionsOSExperienceProtectedPressure = .clear,
        closureResidue: AmbitionsOSExperienceClosureResidue = .none,
        sourceFreshness: AmbitionsOSExperienceSourceFreshness = .current,
        proofStrength: AmbitionsOSExperienceProofStrength = .supporting,
        goalPull: AmbitionsOSExperienceGoalPull = .present,
        recoveryNeed: AmbitionsOSExperienceRecoveryNeed = .none,
        privacyMode: AmbitionsOSExperiencePrivacyMode = .standard
    ) -> AmbitionsOSExperienceSemanticVisualInput {
        AmbitionsOSExperienceSemanticVisualInput(
            surface: surface,
            capacity: capacity,
            protectedPressure: protectedPressure,
            closureResidue: closureResidue,
            sourceFreshness: sourceFreshness,
            proofStrength: proofStrength,
            goalPull: goalPull,
            recoveryNeed: recoveryNeed,
            privacyMode: privacyMode
        )
    }
}

private extension JSONEncoder {
    static var stableAmbitionsSnapshotEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return encoder
    }
}
