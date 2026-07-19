import Foundation

enum RuntimeScenarioSurface: String, CaseIterable, Sendable, Hashable {
    case today = "Today"
    case goals = "Goals"
    case time = "Time"
    case you = "You"
    case captureComposer = "Capture composer"
    case trustInspection = "Trust inspection"
    case stageMotion = "Stage Motion"
    case externalSurface = "External surface"

    var isPersistentRoot: Bool {
        switch self {
        case .today, .goals, .time, .you:
            true
        case .captureComposer, .trustInspection, .stageMotion, .externalSurface:
            false
        }
    }
}

enum RuntimeScenarioState: String, CaseIterable, Sendable, Hashable {
    case empty
    case normal
    case dense
    case brokenSource
    case offline
    case permissionDenied
    case recovery
    case postMutation
}

enum RuntimeScenarioAccessibilityMode: String, CaseIterable, Sendable, Hashable {
    case standard
    case dynamicTypeXXXL
    case reduceMotion
    case reduceTransparency
    case highContrast
}

enum RuntimeScenarioDeviceContext: String, CaseIterable, Sendable, Hashable {
    case smallIPhone
    case largeIPhone
    case keyboardVisible
}

enum RuntimeScenarioProofStep: String, CaseIterable, Sendable, Hashable {
    case runtimeMutation
    case visibleStageMutation
    case accessibilityAnnouncement
    case proofArtifact
}

struct RuntimeScenario: Identifiable, Sendable, Hashable {
    let id: String
    let surface: RuntimeScenarioSurface
    let state: RuntimeScenarioState
    let accessibilityMode: RuntimeScenarioAccessibilityMode
    let deviceContext: RuntimeScenarioDeviceContext
    let requiredProof: [RuntimeScenarioProofStep]
}
