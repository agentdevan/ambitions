import Foundation

struct RuntimeRecommendation: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let action: NowAction?
    let title: String
    let fitSummary: String
    let requiresConfirmation: Bool
    let needsReview: Bool
    let proofReferenceIDs: [String]

    var hasAction: Bool {
        action != nil
    }
}

struct RecommendationEngine: Sendable, Equatable {
    func recommendation(from nowState: CanonicalNowState) -> RuntimeRecommendation {
        let action = nowState.bestNextAction
        let needsReview = nowState.recoveryState != .stable ||
            nowState.blockersWaiting.blockedCount > 0 ||
            nowState.privacy != .standard

        return RuntimeRecommendation(
            id: "runtime.recommendation.\(nowState.id)",
            action: action,
            title: action?.title ?? "Start here",
            fitSummary: fitSummary(nowState: nowState, action: action),
            requiresConfirmation: actionRequiresConfirmation(action),
            needsReview: needsReview,
            proofReferenceIDs: proofReferences(nowState: nowState, action: action)
        )
    }

    private func fitSummary(nowState: CanonicalNowState, action: NowAction?) -> String {
        guard let action else {
            return nowState.priorityPressure.summary
        }
        if nowState.schedulePressure.level == .high || nowState.schedulePressure.level == .critical {
            return "\(action.title) fits only if protected time stays intact."
        }
        if nowState.recoveryState != .stable {
            return "\(action.title) fits with recovery state visible."
        }
        return "\(action.title) fits the current local context."
    }

    private func actionRequiresConfirmation(_ action: NowAction?) -> Bool {
        guard let action else { return false }
        switch action.kind {
        case .schedule, .routeCommitment, .recover:
            return true
        case .none, .focus, .completeAction, .openGoal, .openTime, .capture, .review, .wait, .explain:
            return false
        }
    }

    private func proofReferences(nowState: CanonicalNowState, action: NowAction?) -> [String] {
        Array(Set(
            nowState.eventLedgerEntryIDs +
            nowState.recommendationExplanationIDs +
            (action?.eventLedgerEntryIDs ?? [])
        )).filter { $0.isEmpty == false }.sorted()
    }
}
