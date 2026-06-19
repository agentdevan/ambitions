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

    static let previewMatrix: [RuntimeScenario] = surfaces.flatMap { surface in
        requiredSurfaceStates.map { state in
            RuntimeScenario(
                id: "\(surface.rawValue)-\(state.rawValue)-standard-large",
                surface: surface,
                state: state,
                accessibilityMode: .standard,
                deviceContext: .largeIPhone,
                requiredProof: state == .postMutation ? proofStepsForMeaningfulAction : []
            )
        }
    } + surfaces.flatMap { surface in
        requiredAccessibilityModes.map { mode in
            RuntimeScenario(
                id: "\(surface.rawValue)-normal-\(mode.rawValue)-large",
                surface: surface,
                state: .normal,
                accessibilityMode: mode,
                deviceContext: .largeIPhone,
                requiredProof: []
            )
        }
    } + surfaces.flatMap { surface in
        requiredDeviceContexts.map { context in
            RuntimeScenario(
                id: "\(surface.rawValue)-normal-standard-\(context.rawValue)",
                surface: surface,
                state: .normal,
                accessibilityMode: .standard,
                deviceContext: context,
                requiredProof: []
            )
        }
    }
}
