import XCTest
@testable import Ambitions

final class AmbitionsOSPerformanceEnergyModelsTests: XCTestCase {
    private let validator = AmbitionsOSPerformanceEnergyValidator()

    func testBoundedPerformanceBudgetRoundTripsAndValidates() throws {
        let budget = performanceBudget()

        let data = try JSONEncoder().encode(budget)
        let decoded = try JSONDecoder().decode(AmbitionsOSPerformanceEnergyBudget.self, from: data)

        XCTAssertEqual(decoded.schemaVersion, ambitionsOSPerformanceEnergySchemaVersion)
        XCTAssertEqual(decoded.workloadKind, .recommendation)
        XCTAssertEqual(decoded.surface, .today)
        XCTAssertEqual(validator.validate(decoded), [])
    }

    func testInvalidSchemaMalformedAndUnboundedRuntimeAreRejected() {
        let budget = performanceBudget(
            id: "",
            envelope: envelope(
                maxInteractiveLatencyMilliseconds: 0,
                maxBackgroundDurationSeconds: -1,
                maxMemoryMegabytes: 0,
                maxTraversalItems: 0,
                maxWakeupsPerHour: -1
            ),
            measurementPlan: measurementPlan(metricIDs: [], fixtureGroups: []),
            schemaVersion: "old.schema"
        )

        let issues = validator.validate(budget)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedBudget))
        XCTAssertTrue(issues.contains(.unboundedRuntime))
        XCTAssertTrue(issues.contains(.measurementPlanMissing))
    }

    func testBackgroundWorkMustBeDeferredOrIdleOnly() {
        let budget = performanceBudget(
            workloadKind: .backgroundMaintenance,
            scheduler: scheduler(mode: .immediate)
        )

        let issues = validator.validate(budget)

        XCTAssertTrue(issues.contains(.backgroundWorkNotDeferred))
    }

    func testLowPowerAndThermalFallbacksAreRequired() {
        let budget = performanceBudget(
            scheduler: AmbitionsOSPerformanceSchedulerContract(
                mode: .userInitiated,
                allowedDeviceStates: [.normal],
                fallbackDeviceStates: []
            )
        )

        let issues = validator.validate(budget)

        XCTAssertTrue(issues.contains(.lowPowerFallbackMissing))
        XCTAssertTrue(issues.contains(.thermalFallbackMissing))
    }

    func testSourceAtlasAndLocalLanguageBudgetsAreInherited() {
        let sourceTraversal = performanceBudget(
            workloadKind: .sourceTraversal,
            sourceTraversalBudgetAttached: false
        )
        let localLanguage = performanceBudget(
            workloadKind: .localLanguagePlanning,
            localLanguageBudgetAttached: false
        )

        XCTAssertTrue(validator.validate(sourceTraversal).contains(.sourceTraversalBudgetMissing))
        XCTAssertTrue(validator.validate(localLanguage).contains(.localLanguageBudgetMissing))
    }

    func testReleaseClaimsNeedMeasuredEvidence() {
        let budget = performanceBudget(
            measurementPlan: measurementPlan(
                evidenceLevel: .contractOnly,
                requiresInstrumentsBeforeReleaseClaim: true
            )
        )

        XCTAssertTrue(validator.validate(budget).contains(.releaseClaimWithoutEvidence))

        let measured = performanceBudget(
            measurementPlan: measurementPlan(
                evidenceLevel: .instrumentsMeasured,
                requiresInstrumentsBeforeReleaseClaim: true
            )
        )

        XCTAssertFalse(validator.validate(measured).contains(.releaseClaimWithoutEvidence))
    }

    func testPrivacyMutationAndRuntimeStoreBoundariesAreEnforced() {
        let budget = performanceBudget(
            scheduler: scheduler(allowsSilentMutation: true),
            projectsExternally: true,
            changesAppState: true,
            privacyClass: .sensitive,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        let issues = validator.validate(budget)

        XCTAssertTrue(issues.contains(.externalSensitiveProjectionRisk))
        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
    }

    func testPerformanceBudgetEvaluatorKeepsContractAndClaimBoundariesSeparate() {
        let budget = performanceBudget(
            measurementPlan: measurementPlan(
                evidenceLevel: .contractOnly,
                requiresInstrumentsBeforeReleaseClaim: true
            )
        )
        let estimate = AmbitionsOSPerformanceWorkloadEstimate(
            interactiveLatencyMilliseconds: 180,
            backgroundDurationSeconds: 4,
            memoryMegabytes: 48,
            traversalItems: 120,
            wakeupsPerHour: 0,
            evidenceLevel: .contractOnly,
            fixtureGroup: "PK35 large-store fixture"
        )

        let assessment = AmbitionsOSPerformanceBudgetEvaluator().assess(budget: budget, estimate: estimate)

        XCTAssertTrue(assessment.isWithinBudget)
        XCTAssertEqual(assessment.exceededMetrics, [])
        XCTAssertFalse(assessment.canSupportPerformanceClaim)
        XCTAssertTrue(assessment.disclosureSummary.contains("separate proof gate"))
    }

    func testPerformanceBudgetEvaluatorFlagsExceededMetrics() {
        let budget = performanceBudget()
        let estimate = AmbitionsOSPerformanceWorkloadEstimate(
            interactiveLatencyMilliseconds: 251,
            backgroundDurationSeconds: 11,
            memoryMegabytes: 65,
            traversalItems: 251,
            wakeupsPerHour: 1,
            evidenceLevel: .simulatorMeasured,
            fixtureGroup: "Over-budget fixture"
        )

        let assessment = AmbitionsOSPerformanceBudgetEvaluator().assess(budget: budget, estimate: estimate)

        XCTAssertFalse(assessment.isWithinBudget)
        XCTAssertEqual(
            assessment.exceededMetrics,
            [.interactiveLatency, .backgroundDuration, .memory, .traversalItems, .wakeups]
        )
        XCTAssertFalse(assessment.canSupportPerformanceClaim)
    }

    func testPerformanceBudgetEvaluatorAllowsClaimOnlyWithMeasuredEvidenceAndCleanBudget() {
        let budget = performanceBudget(
            measurementPlan: measurementPlan(
                evidenceLevel: .instrumentsMeasured,
                requiresInstrumentsBeforeReleaseClaim: true
            )
        )
        let estimate = AmbitionsOSPerformanceWorkloadEstimate(
            interactiveLatencyMilliseconds: 180,
            backgroundDurationSeconds: 4,
            memoryMegabytes: 48,
            traversalItems: 120,
            wakeupsPerHour: 0,
            evidenceLevel: .instrumentsMeasured,
            fixtureGroup: "Measured large-store fixture"
        )

        let assessment = AmbitionsOSPerformanceBudgetEvaluator().assess(budget: budget, estimate: estimate)

        XCTAssertTrue(assessment.isWithinBudget)
        XCTAssertTrue(assessment.canSupportPerformanceClaim)
    }
}

private extension AmbitionsOSPerformanceEnergyModelsTests {
    func performanceBudget(
        id: String = "budget-1",
        workloadKind: AmbitionsOSPerformanceWorkloadKind = .recommendation,
        surface: AmbitionsOSControlPlaneSurface = .today,
        envelope: AmbitionsOSPerformanceBudgetEnvelope? = nil,
        scheduler: AmbitionsOSPerformanceSchedulerContract? = nil,
        measurementPlan: AmbitionsOSPerformanceMeasurementPlan? = nil,
        sourceTraversalBudgetAttached: Bool = true,
        localLanguageBudgetAttached: Bool = true,
        projectsExternally: Bool = false,
        changesAppState: Bool = false,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSPerformanceEnergySchemaVersion
    ) -> AmbitionsOSPerformanceEnergyBudget {
        AmbitionsOSPerformanceEnergyBudget(
            id: id,
            workloadKind: workloadKind,
            surface: surface,
            envelope: envelope ?? self.envelope(),
            scheduler: scheduler ?? self.scheduler(),
            measurementPlan: measurementPlan ?? self.measurementPlan(requiresInstrumentsBeforeReleaseClaim: false),
            sourceTraversalBudgetAttached: sourceTraversalBudgetAttached,
            localLanguageBudgetAttached: localLanguageBudgetAttached,
            projectsExternally: projectsExternally,
            changesAppState: changesAppState,
            privacyClass: privacyClass,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func envelope(
        maxInteractiveLatencyMilliseconds: Int = 250,
        maxBackgroundDurationSeconds: Int = 10,
        maxMemoryMegabytes: Int = 64,
        maxTraversalItems: Int = 250,
        maxWakeupsPerHour: Int = 0
    ) -> AmbitionsOSPerformanceBudgetEnvelope {
        AmbitionsOSPerformanceBudgetEnvelope(
            maxInteractiveLatencyMilliseconds: maxInteractiveLatencyMilliseconds,
            maxBackgroundDurationSeconds: maxBackgroundDurationSeconds,
            maxMemoryMegabytes: maxMemoryMegabytes,
            maxTraversalItems: maxTraversalItems,
            maxWakeupsPerHour: maxWakeupsPerHour
        )
    }

    func scheduler(
        mode: AmbitionsOSPerformanceSchedulerMode = .userInitiated,
        fallbackDeviceStates: [AmbitionsOSEnergyDeviceState] = [.lowPowerMode, .thermalPressure, .oldDeviceFallback],
        allowsSilentMutation: Bool = false
    ) -> AmbitionsOSPerformanceSchedulerContract {
        AmbitionsOSPerformanceSchedulerContract(
            mode: mode,
            fallbackDeviceStates: fallbackDeviceStates,
            allowsSilentMutation: allowsSilentMutation
        )
    }

    func measurementPlan(
        evidenceLevel: AmbitionsOSPerformanceEvidenceLevel = .contractOnly,
        metricIDs: [String] = ["latency", "memory", "wakeups"],
        fixtureGroups: [String] = ["Old-device fallback", "Low Power Mode fallback", "Large receipt history"],
        requiresInstrumentsBeforeReleaseClaim: Bool = true
    ) -> AmbitionsOSPerformanceMeasurementPlan {
        AmbitionsOSPerformanceMeasurementPlan(
            evidenceLevel: evidenceLevel,
            metricIDs: metricIDs,
            fixtureGroups: fixtureGroups,
            requiresInstrumentsBeforeReleaseClaim: requiresInstrumentsBeforeReleaseClaim
        )
    }
}
