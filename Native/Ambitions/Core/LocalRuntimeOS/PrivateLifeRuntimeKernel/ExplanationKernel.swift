import Foundation

struct ExplanationKernel: Sendable, Equatable {
    func makeExplanation(
        goalText: String,
        readiness: PrivateLifeRuntimeLifeContextReadiness,
        projection: LifeContextRuntimeProjection?,
        signals: PrivateLifeRuntimeSignalSet
    ) -> String {
        guard projection != nil else {
            return "\(goalText) stays in clarification until life context is provided."
        }

        var reasonParts: [String] = []
        switch readiness {
        case .clarification:
            reasonParts.append("missing context keeps the runtime in clarification")
        case .review:
            reasonParts.append("active context needs review before a faster recommendation")
        case .ready:
            break
        }

        if let pathwayLabel = signals.firstLabel(for: .explicitEligibilityPathway) {
            reasonParts.append("the explicit pathway is \(pathwayLabel)")
        } else if signals.contains(.earlyTimeline) {
            reasonParts.append("the timeline is still early")
        } else if signals.contains(.compressedTimeline) {
            reasonParts.append("the timeline is compressed")
        }

        if signals.contains(.makerSpaceAccess) {
            reasonParts.append("maker-space access shapes the first step")
        }
        if signals.contains(.homePracticeAccess) && signals.contains(.equipmentContext) {
            reasonParts.append("equipment and local practice matter before maker-space access")
        }
        if signals.contains(.excludedContext) {
            reasonParts.append("paused or deleted context stays out of the runtime path")
        }
        if signals.contains(.recoveryContext) {
            reasonParts.append("older injury or blocked-attempt context keeps the plan conservative")
        }

        if reasonParts.isEmpty {
            reasonParts.append("the local life context keeps the recommendation specific")
        }

        return "\(goalText) " + reasonParts.joined(separator: ", ") + "."
    }
}
