import Foundation

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
    let renderPlan: CanvasPrimitiveRenderPlan

    init(
        dayRail: AmbitionsDayRailViewState,
        continuity: RealityMeridianContinuityProjectionState? = nil
    ) {
        let voiceOverOrder = continuity?.voiceOverOrder ?? Self.voiceOverOrder(for: dayRail)
        let sourceUnavailable = dayRail.heroStep?.receiptItem.freshness == .unavailable ||
            dayRail.heroStep?.sourceRecordLabel == "Source record unavailable"

        self.primaryObjectTitle = continuity?.primaryObjectTitle ?? UserFacingLanguage.Object.realityMeridian
        self.dateTitle = dayRail.dateTitle
        self.mode = dayRail.mode
        self.contextSummary = dayRail.contextSummary
        self.reducedMotionSummary = continuity?.reducedMotionSummary ?? "Reduce Motion keeps Start here in a static current-time relationship."
        self.dynamicTypeSummary = continuity?.dynamicTypeSummary ?? "Dynamic Type keeps Start here before supporting day rows."
        self.voiceOverOrder = voiceOverOrder
        self.noStepSummary = dayRail.heroStep == nil ? "No step is required right now." : nil
        self.sourceUnavailable = sourceUnavailable
        self.renderPlan = MeridianRenderer.plan(
            mode: dayRail.mode,
            contextSummary: dayRail.contextSummary,
            hasHeroStep: dayRail.heroStep != nil,
            sourceUnavailable: sourceUnavailable,
            semanticElementCount: voiceOverOrder.count
        )
    }

    private static func voiceOverOrder(for dayRail: AmbitionsDayRailViewState) -> [String] {
        var order = [UserFacingLanguage.Object.realityMeridian, UserFacingLanguage.Action.startHere]
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
