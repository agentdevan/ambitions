import Foundation

struct PrivateLifeRuntimeCapacityFit: Sendable, Equatable {
    let cadence: String
    let urgency: String
    let supportingSignalIDs: [String]
}

struct CapacityFitKernel: Sendable, Equatable {
    func evaluate(
        projection: LifeContextRuntimeProjection?,
        readiness: PrivateLifeRuntimeLifeContextReadiness,
        signals: PrivateLifeRuntimeSignalSet
    ) -> PrivateLifeRuntimeCapacityFit {
        let cadence = cadence(projection: projection, readiness: readiness, signals: signals)
        let urgency = urgency(projection: projection, readiness: readiness, signals: signals)
        return PrivateLifeRuntimeCapacityFit(
            cadence: cadence,
            urgency: urgency,
            supportingSignalIDs: signals.supportingSignalIDs
        )
    }

    private func cadence(
        projection: LifeContextRuntimeProjection?,
        readiness: PrivateLifeRuntimeLifeContextReadiness,
        signals: PrivateLifeRuntimeSignalSet
    ) -> String {
        guard projection != nil else {
            return "review before cadence"
        }
        if readiness == .clarification {
            return "review before cadence"
        }
        if readiness == .review {
            return "rebuild from active context"
        }
        if signals.contains(.earlyTimeline) {
            return "school-week cadence"
        }
        if signals.contains(.compressedTimeline) {
            return "compressed portfolio cadence"
        }
        if signals.contains(.explicitEligibilityPathway) {
            return "pathway-specific cadence"
        }
        if signals.contains(.makerSpaceAccess) {
            return "weekly maker-space cadence"
        }
        if signals.contains(.localAccess) {
            return "local access cadence"
        }
        return "steady weekly cadence"
    }

    private func urgency(
        projection: LifeContextRuntimeProjection?,
        readiness: PrivateLifeRuntimeLifeContextReadiness,
        signals: PrivateLifeRuntimeSignalSet
    ) -> String {
        guard projection != nil else {
            return "clarification"
        }
        switch readiness {
        case .clarification:
            return "clarification"
        case .review:
            return "review"
        case .ready:
            if signals.contains(.earlyTimeline) {
                return "steady"
            }
            if signals.contains(.compressedTimeline) || signals.contains(.localAccess) || signals.contains(.explicitEligibilityPathway) {
                return "focused"
            }
            return "steady"
        }
    }
}
