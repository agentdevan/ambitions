import Foundation

public enum AmbitionsObjectLifecycle: String, CaseIterable, Sendable, Codable {
    case dormant
    case emerging
    case active
    case compressed
    case inspecting
    case closing
    case recovering
}

public enum AmbitionsSemanticCause: String, CaseIterable, Sendable, Codable {
    case capacityChanged
    case protectedTimeApproaching
    case closureResidueChanged
    case sourceFreshnessChanged
    case proofAttached
    case goalPullChanged
    case recoveryNeedChanged
    case privacyBoundaryChanged
    case userOpenedInspection
}

public struct AmbitionsVisualEffect: Equatable, Sendable, Codable {
    public let cause: AmbitionsSemanticCause
    public let intensity: Double
    public let duration: TimeInterval

    public init(cause: AmbitionsSemanticCause, intensity: Double, duration: TimeInterval) {
        self.cause = cause
        self.intensity = min(1, max(0, intensity))
        self.duration = duration
    }
}

public struct AmbitionsObjectRuntimeState: Equatable, Sendable, Codable {
    public let surface: AmbitionsSurface
    public let primaryObject: AmbitionsPrimaryObject
    public let lifecycle: AmbitionsObjectLifecycle
    public let field: AmbitionsVisualFieldState
    public let effects: [AmbitionsVisualEffect]

    public init(surface: AmbitionsSurface, primaryObject: AmbitionsPrimaryObject, lifecycle: AmbitionsObjectLifecycle, field: AmbitionsVisualFieldState, effects: [AmbitionsVisualEffect]) {
        self.surface = surface
        self.primaryObject = primaryObject
        self.lifecycle = lifecycle
        self.field = field
        self.effects = effects
    }
}

public enum AmbitionsExperienceReducer {
    public static func reduce(input: AmbitionsRuntimeSnapshotInput, previous: AmbitionsVisualFieldState? = nil, calibration: AmbitionsCompilerCalibration = .init()) -> AmbitionsObjectRuntimeState {
        let field = AmbitionsExperienceCompiler.compile(input, calibration: calibration)
        let contract = AmbitionsSurfaceContracts.contract(for: input.surface)
        let lifecycle = lifecycleFor(field)
        let effects = effectsFor(current: field, previous: previous)
        return .init(surface: input.surface, primaryObject: contract.primaryObject, lifecycle: lifecycle, field: field, effects: effects)
    }

    private static func lifecycleFor(_ field: AmbitionsVisualFieldState) -> AmbitionsObjectLifecycle {
        switch field.fit {
        case .recoveryFirst:
            return .recovering
        case .protectedTime:
            return .compressed
        case .needsBuffer, .tightFit:
            return .compressed
        case .fitsNow:
            return field.proofIntensity > 0.65 ? .active : .emerging
        }
    }

    private static func effectsFor(current: AmbitionsVisualFieldState, previous: AmbitionsVisualFieldState?) -> [AmbitionsVisualEffect] {
        guard let previous else {
            return [.init(cause: .capacityChanged, intensity: current.capacityGrain, duration: 0.260)]
        }
        var effects: [AmbitionsVisualEffect] = []
        appendIfChanged(&effects, cause: .capacityChanged, current: current.capacityGrain, previous: previous.capacityGrain)
        appendIfChanged(&effects, cause: .protectedTimeApproaching, current: current.protectedPressure, previous: previous.protectedPressure)
        appendIfChanged(&effects, cause: .closureResidueChanged, current: current.closureResidue, previous: previous.closureResidue)
        appendIfChanged(&effects, cause: .sourceFreshnessChanged, current: current.sourceFreshness, previous: previous.sourceFreshness)
        appendIfChanged(&effects, cause: .proofAttached, current: current.proofIntensity, previous: previous.proofIntensity)
        appendIfChanged(&effects, cause: .goalPullChanged, current: current.goalPull, previous: previous.goalPull)
        appendIfChanged(&effects, cause: .recoveryNeedChanged, current: current.recoveryWarmth, previous: previous.recoveryWarmth)
        appendIfChanged(&effects, cause: .privacyBoundaryChanged, current: current.privacyBoundary, previous: previous.privacyBoundary)
        return effects
    }

    private static func appendIfChanged(_ effects: inout [AmbitionsVisualEffect], cause: AmbitionsSemanticCause, current: Double, previous: Double) {
        let delta = abs(current - previous)
        guard delta >= 0.04 else { return }
        effects.append(.init(cause: cause, intensity: delta, duration: 0.260))
    }
}
