import Foundation

enum ScenarioCatalog {
    static let surfaces: [RuntimeScenarioSurface] = [
        .today,
        .goals,
        .time,
        .you,
        .captureComposer,
        .trustInspection,
        .stageMotion,
        .externalSurface
    ]

    static let requiredSurfaceStates: [RuntimeScenarioState] = RuntimeScenarioState.allCases

    static let requiredAccessibilityModes: [RuntimeScenarioAccessibilityMode] = RuntimeScenarioAccessibilityMode.allCases

    static let requiredDeviceContexts: [RuntimeScenarioDeviceContext] = RuntimeScenarioDeviceContext.allCases

    static let proofStepsForMeaningfulAction: [RuntimeScenarioProofStep] = RuntimeScenarioProofStep.allCases

    static let previewMatrix: [RuntimeScenario] =
        persistentSurfaceStateCoverage +
        YouScenarios.all +
        CaptureScenarios.all +
        SearchScenarios.all +
        ClosureScenarios.all +
        InspectionScenarios.all +
        StageMotionScenarios.all +
        CrossSurfaceMotionScenarios.all +
        PostMutationMotionScenarios.all +
        RecoveryMotionScenarios.all +
        AccessibilityScenarios.all +
        BrokenSourceScenarios.all +
        EmptyStateScenarios.all +
        DenseStateScenarios.all +
        PostMutationScenarios.all +
        deviceContextCoverage

    static let persistentSurfaceStateCoverage: [RuntimeScenario] = [
        .today,
        .goals,
        .time
    ].flatMap { surface in
        stateCoverage(for: surface, owner: "persistent-root")
    }

    static let deviceContextCoverage: [RuntimeScenario] = surfaces.flatMap { surface in
        deviceCoverage(for: surface, owner: "device-context")
    }

    static func stateCoverage(
        for surface: RuntimeScenarioSurface,
        owner: String,
        states: [RuntimeScenarioState] = RuntimeScenarioState.allCases
    ) -> [RuntimeScenario] {
        states.map { state in
            RuntimeScenario(
                id: scenarioID(owner: owner, surface: surface, state: state, mode: .standard, context: .largeIPhone),
                surface: surface,
                state: state,
                accessibilityMode: .standard,
                deviceContext: .largeIPhone,
                requiredProof: state == .postMutation ? proofStepsForMeaningfulAction : []
            )
        }
    }

    static func accessibilityCoverage(
        for surface: RuntimeScenarioSurface,
        owner: String,
        modes: [RuntimeScenarioAccessibilityMode] = RuntimeScenarioAccessibilityMode.allCases
    ) -> [RuntimeScenario] {
        modes.map { mode in
            RuntimeScenario(
                id: scenarioID(owner: owner, surface: surface, state: .normal, mode: mode, context: .largeIPhone),
                surface: surface,
                state: .normal,
                accessibilityMode: mode,
                deviceContext: .largeIPhone,
                requiredProof: []
            )
        }
    }

    static func deviceCoverage(
        for surface: RuntimeScenarioSurface,
        owner: String,
        contexts: [RuntimeScenarioDeviceContext] = RuntimeScenarioDeviceContext.allCases
    ) -> [RuntimeScenario] {
        contexts.map { context in
            RuntimeScenario(
                id: scenarioID(owner: owner, surface: surface, state: .normal, mode: .standard, context: context),
                surface: surface,
                state: .normal,
                accessibilityMode: .standard,
                deviceContext: context,
                requiredProof: []
            )
        }
    }

    static func scenarioID(
        owner: String,
        surface: RuntimeScenarioSurface,
        state: RuntimeScenarioState,
        mode: RuntimeScenarioAccessibilityMode,
        context: RuntimeScenarioDeviceContext
    ) -> String {
        "\(owner)-\(surface.rawValue)-\(state.rawValue)-\(mode.rawValue)-\(context.rawValue)"
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
    }
}
