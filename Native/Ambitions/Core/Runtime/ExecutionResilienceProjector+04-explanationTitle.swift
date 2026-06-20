import Foundation

extension ExecutionResilienceProjector {

    func explanationTitle(for type: RecommendationExplanationType) -> String {
        switch type {
        case .whyRecovered:
            return "Why this recovery helps"
        case .whyDeferred:
            return "Why this can wait"
        case .whyDisplaced:
            return "Why lower-priority work moved"
        case .whyPrioritized:
            return "Why this gets protected"
        case .whyScheduled:
            return "Why this belongs in Plan"
        case .whyCalendarAware:
            return "Why calendar-aware evidence matters"
        case .whyBelievable:
            return "Why this remains believable"
        case .whyNotBelievable:
            return "Why this is at risk"
        default:
            return "Why this recovery option"
        }
    }


    func correctionTitle(for kind: RecommendationExplanationCorrectionActionKind) -> String {
        switch kind {
        case .changeDomainContext: return "Change context"
        case .changeDeadline: return "Change deadline"
        case .changeImportance: return "Change importance"
        case .changeUrgency: return "Change urgency"
        case .changeConsequence: return "Change consequence"
        case .changeRoute: return "Change route"
        case .markGoalSupporting: return "Mark goal-supporting"
        case .markOneTimeTask: return "Mark one-time task"
        case .markOptionalSomeday: return "Mark optional someday"
        case .dismissRecommendation: return "Dismiss"
        case .explainMore: return "Explain more"
        }
    }


    func correctionField(for kind: RecommendationExplanationCorrectionActionKind) -> String? {
        switch kind {
        case .changeDomainContext: return "context"
        case .changeDeadline: return "deadline"
        case .changeImportance: return "importance"
        case .changeUrgency: return "urgency"
        case .changeConsequence: return "consequence"
        case .changeRoute: return "route"
        case .markGoalSupporting: return "goalRelationship"
        case .markOneTimeTask: return "commitmentKind"
        case .markOptionalSomeday: return "posture"
        case .dismissRecommendation, .explainMore: return nil
        }
    }


    func privacy(
        input: ExecutionResilienceProjectionInput,
        assessments: [GoalBelievabilityAssessment]
    ) -> EventLedgerPrivacyClassification {
        if input.captures.contains(where: { $0.privacy == .privateUserText }) { return .privateUserText }
        if input.eventLedgerEntries.contains(where: { $0.privacy == .privateUserText }) { return .privateUserText }
        if assessments.contains(where: { $0.privacy == .calendarDerived }) { return .calendarDerived }
        if input.realitySnapshot?.privacy == .calendarDerived { return .calendarDerived }
        if input.recommendationExplanations.contains(where: { $0.privacy == .calendarDerived }) { return .calendarDerived }
        return .standard
    }


    func unique(_ disruptions: [ExecutionDisruption]) -> [ExecutionDisruption] {
        var byID: [String: ExecutionDisruption] = [:]
        for disruption in disruptions {
            byID[disruption.id] = disruption
        }
        return byID.values.sorted { lhs, rhs in
            if lhs.severity != rhs.severity { return rank(lhs.severity) > rank(rhs.severity) }
            return lhs.id < rhs.id
        }
    }


    func unique(_ options: [ExecutionRecoveryOption]) -> [ExecutionRecoveryOption] {
        var byID: [String: ExecutionRecoveryOption] = [:]
        for option in options {
            byID[option.id] = option
        }
        return byID.values.sorted { $0.id < $1.id }
    }


    func unique(_ summaries: [DisplacedWorkSummary]) -> [DisplacedWorkSummary] {
        var byID: [String: DisplacedWorkSummary] = [:]
        for summary in summaries {
            byID[summary.id] = summary
        }
        return byID.values.sorted { $0.id < $1.id }
    }


    func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }


    func maxPressure(_ values: [NowPressureLevel]) -> NowPressureLevel {
        values.max { rank($0) < rank($1) } ?? .none
    }


    func rank(_ level: NowPressureLevel) -> Int {
        switch level {
        case .none: 0
        case .low: 1
        case .moderate: 2
        case .elevated: 3
        case .high: 4
        case .critical: 5
        }
    }
}
