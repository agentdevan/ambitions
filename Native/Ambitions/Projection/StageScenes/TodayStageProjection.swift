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

struct MeridianSemanticModel: Equatable {
    let primaryObjectTitle: String
    let dateTitle: String
    let mode: DayRailMode
    let contextSummary: String
    let reducedMotionSummary: String
    let dynamicTypeSummary: String
    let voiceOverOrder: [String]
    let noStepSummary: String?
    let sourceUnavailable: Bool

    init(
        dayRail: AmbitionsDayRailViewState,
        continuity: RealityMeridianContinuityProjectionState? = nil
    ) {
        self.primaryObjectTitle = continuity?.primaryObjectTitle ?? "Reality Meridian"
        self.dateTitle = dayRail.dateTitle
        self.mode = dayRail.mode
        self.contextSummary = dayRail.contextSummary
        self.reducedMotionSummary = continuity?.reducedMotionSummary ?? "Reduce Motion keeps Start here in a static current-time relationship."
        self.dynamicTypeSummary = continuity?.dynamicTypeSummary ?? "Dynamic Type keeps Start here before supporting day rows."
        self.voiceOverOrder = continuity?.voiceOverOrder ?? Self.voiceOverOrder(for: dayRail)
        self.noStepSummary = dayRail.heroStep == nil ? "No step is required right now." : nil
        self.sourceUnavailable = dayRail.heroStep?.receiptItem.freshness == .unavailable ||
            dayRail.heroStep?.sourceRecordLabel == "Source record unavailable"
    }

    private static func voiceOverOrder(for dayRail: AmbitionsDayRailViewState) -> [String] {
        var order = ["Reality Meridian", "Start here"]
        if let hero = dayRail.heroStep {
            order.append(hero.title)
            order.append(hero.sourceRecordLabel)
            order.append(hero.receiptLabel)
        } else {
            order.append("No step is required right now")
        }
        return order
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
