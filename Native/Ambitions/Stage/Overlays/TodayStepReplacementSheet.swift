import AmbitionsDesignSystem
import SwiftUI

struct TodayStepReplacementOptionState: Identifiable, Equatable {
    let candidate: StepCandidate
    let label: String
    let title: String
    let summary: String
    let deadlineImpactLabel: String
    let timelineImpactLabel: String
    let receiptPreviewLabel: String
    let approvalHint: String
    let heroStep: DayRailHeroStepState

    var id: String { candidate.id }

    var state: AmbitionVisualState {
        switch candidate.validity {
        case .preferred:
            return .success
        case .review:
            return .selected
        case .fallback:
            return .warning
        case .blocked, .rejected:
            return .warning
        }
    }

    var visibleCopy: String {
        [
            label,
            title,
            summary,
            deadlineImpactLabel,
            "Timeline",
            timelineImpactLabel,
            receiptPreviewLabel,
            approvalHint,
            heroStep.visibleCopy
        ].joined(separator: " ")
    }
}
