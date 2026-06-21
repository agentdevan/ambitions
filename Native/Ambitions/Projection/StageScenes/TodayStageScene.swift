import Foundation

struct TodayStageScene: Equatable {
    let generatedAt: Date
    let meridian: MeridianSemanticModel
    let startHere: StartHereToken?
    let primaryActionTitle: String?
    let showsBlockedOrWaitingState: Bool
    let showsCompletedProofState: Bool

    init(execution: TodayExecutionViewState, generatedAt: Date) {
        self.generatedAt = generatedAt
        self.meridian = MeridianSemanticModel(dayRail: execution.dayRail, continuity: execution.realityMeridianContinuity)
        self.startHere = execution.dayRail.heroStep.map { StartHereToken(heroStep: $0, privacy: execution.dayRail.privacyProjection) }
        self.primaryActionTitle = execution.dayRail.heroStep.map { StartHereToken.primaryActionTitle(for: $0.primaryAction) }
        self.showsBlockedOrWaitingState = execution.dayRail.continuity.markers.contains { marker in
            marker.kind == .blocked || marker.kind == .waiting
        } || execution.dayRail.heroStep?.receiptItem.freshness == .blocked
        self.showsCompletedProofState = execution.dayRail.proofSlot.noSilentChanges ||
            execution.dayRail.continuity.markers.contains { marker in marker.kind == .proof || marker.kind == .closure }
    }
}

struct StartHereToken: Equatable {
    let id: String
    let title: String
    let subtitle: String
    let primaryActionTitle: String
    let secondaryActionTitle: String?
    let accessibilitySummary: String
    let sourceRecordLabel: String
    let receiptLabel: String

    init(heroStep: DayRailHeroStepState, privacy: DayRailPrivacyProjectionState) {
        self.id = heroStep.id
        self.title = privacy.detailTitle(heroStep.title)
        self.subtitle = privacy.visibleSubtitle(heroStep.subtitle)
        self.primaryActionTitle = Self.primaryActionTitle(for: heroStep.primaryAction)
        self.secondaryActionTitle = heroStep.secondaryAction.map(Self.secondaryActionTitle(for:))
        self.accessibilitySummary = heroStep.receiptItem.accessibilitySummary
        self.sourceRecordLabel = heroStep.sourceRecordLabel
        self.receiptLabel = heroStep.receiptLabel
    }

    static func primaryActionTitle(for action: TodayInlineAction) -> String {
        switch action.kind {
        case .openDetail:
            return "Open step"
        case .closeActionClosure:
            return "Still counts"
        default:
            return "Start now"
        }
    }

    static func secondaryActionTitle(for action: TodayInlineAction) -> String {
        switch action.kind {
        case .split:
            return "Shorten"
        case .defer:
            return "Waiting"
        case .askForHelp:
            return "Blocked"
        case .markNotRelevant:
            return "Not needed"
        default:
            return "Move it"
        }
    }
}
