import Foundation

struct PrivateLifeRuntimeRecoveryAssessment: Sendable, Equatable {
    let milestone: String
    let supportingSignalIDs: [String]
}

struct RecoveryKernel: Sendable, Equatable {
    func evaluate(
        projection: LifeContextRuntimeProjection?,
        readiness: PrivateLifeRuntimeLifeContextReadiness,
        signals: PrivateLifeRuntimeSignalSet
    ) -> PrivateLifeRuntimeRecoveryAssessment {
        PrivateLifeRuntimeRecoveryAssessment(
            milestone: milestone(projection: projection, readiness: readiness, signals: signals),
            supportingSignalIDs: signals.supportingSignalIDs
        )
    }

    private func milestone(
        projection: LifeContextRuntimeProjection?,
        readiness: PrivateLifeRuntimeLifeContextReadiness,
        signals: PrivateLifeRuntimeSignalSet
    ) -> String {
        guard projection != nil else {
            return "capture the missing context"
        }
        if readiness == .clarification {
            return "capture the missing context"
        }
        if signals.contains(.excludedContext) {
            return "confirm paused context stays excluded"
        }
        if signals.contains(.recoveryContext) {
            return "confirm the recovery-safe re-entry milestone"
        }
        if let pathwayLabel = signals.firstLabel(for: .explicitEligibilityPathway) {
            return "\(pathwayLabel) exposure milestone"
        }
        if signals.contains(.earlyTimeline) {
            return "lock one guardian-transport build block"
        }
        if signals.contains(.compressedTimeline) {
            return "tighten portfolio readiness around school access"
        }
        if signals.contains(.homePracticeAccess) && signals.contains(.equipmentContext) {
            return "confirm equipment and local practice"
        }
        if signals.contains(.makerSpaceAccess) {
            return "reach the first maker-space build"
        }
        if signals.contains(.localAccess) {
            return "confirm local access and equipment"
        }
        return "name the next visible milestone"
    }
}
