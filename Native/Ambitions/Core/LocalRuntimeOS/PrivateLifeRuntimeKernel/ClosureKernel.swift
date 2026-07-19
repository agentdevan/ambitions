import Foundation

struct PrivateLifeRuntimeClosureAssessment: Sendable, Equatable {
    let readiness: PrivateLifeRuntimeLifeContextReadiness
    let reasonIDs: [String]

    var canCloseWithoutReview: Bool {
        readiness == .ready
    }
}

struct ClosureKernel: Sendable, Equatable {
    func assess(projection: LifeContextRuntimeProjection?) -> PrivateLifeRuntimeClosureAssessment {
        guard let projection else {
            return PrivateLifeRuntimeClosureAssessment(
                readiness: .clarification,
                reasonIDs: ["life_context.missing_projection"]
            )
        }

        if projection.missingContextQuestions.isEmpty == false {
            return PrivateLifeRuntimeClosureAssessment(
                readiness: .clarification,
                reasonIDs: projection.missingContextQuestions.map(\.id).sorted()
            )
        }

        var reviewReasonIDs: [String] = []
        reviewReasonIDs += projection.excludedHistorySummary.map(\.factID)
        reviewReasonIDs += projection.sourceFreshnessSummary.filter { $0.freshness != .current }.map(\.sourceID)
        reviewReasonIDs += projection.historySummary.filter { $0.freshness != .current }.map(\.id)
        reviewReasonIDs += projection.sensitiveUseWarnings.map(\.factID)

        if reviewReasonIDs.isEmpty == false {
            return PrivateLifeRuntimeClosureAssessment(
                readiness: .review,
                reasonIDs: Array(Set(reviewReasonIDs)).sorted()
            )
        }

        return PrivateLifeRuntimeClosureAssessment(readiness: .ready, reasonIDs: [])
    }
}
