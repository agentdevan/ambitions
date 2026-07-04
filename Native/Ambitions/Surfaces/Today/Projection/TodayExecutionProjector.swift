import AmbitionsDesignSystem
import Foundation

struct TodayExecutionProjectionInput {
    let mode: TodayExperienceMode
    let legacyHero: TodayHeroState
    let legacySupport: TodaySupportLayerState
    let nowState: CanonicalNowState
    let realitySnapshot: RealitySnapshot?
    let believabilityAssessments: [GoalBelievabilityAssessment]
    let resilienceAssessment: ExecutionResilienceAssessment
    let explanations: [RecommendationExplanation]
    let captures: [Capture]
    let oneStepGoalsProjection: OneStepGoalsProjection
}

struct TodayExecutionProjector {
    func project(_ input: TodayExecutionProjectionInput) -> TodayExecutionViewState {
        let activeLens = lensChip(input.nowState.activeContextLens, active: true)
        let lenses = input.nowState.availableContextLenses.map { lensChip($0, active: $0 == input.nowState.activeContextLens) }
        let hero = heroState(input)
        let contract = contractEntries(input, hero: hero)
        let friction = frictionSignal(input)
        let todayTime = todayTimeLayer(input, hero: hero)
        let oneStepGoals = oneStepGoalsPanel(input)
        let saveTheDay = saveTheDayAction(input, hero: hero)
        let support = supportingPanels(input)
        let deeper = deeperSections(input)
        let dayRail = dayRailState(
            input,
            hero: hero,
            contract: contract,
            todayTime: todayTime,
            friction: friction
        )
        let realityMeridianContinuity = RealityMeridianContinuityProjectionState.make(
            dayRail: dayRail,
            heroStep: dayRail.heroStep,
            recommendedStep: contract.best,
            todayTimeLayer: todayTime,
            dayState: dayState(input),
            recoveryLabel: dayRail.continuity.pressureLabel
        )
        let contractActions = [
            contract.protected.action,
            contract.best.action,
            contract.notToday.action,
            contract.fallback.action,
            contract.why.action,
            contract.closure.action,
            saveTheDay,
            friction.action,
        ].compactMap { $0 }
        let planActions = todayTime.items.compactMap(\.action) + [
            todayTime.moveAction,
            todayTime.parkAction,
            todayTime.markDoneAction,
        ].compactMap { $0 }
        let oneStepGoalActions = oneStepGoals.previews.compactMap(\.action)
        let supportActions = support.compactMap(\.action)
        let deeperActions = deeper.flatMap { section in section.rows.compactMap(\.action) }
        var actions = [hero.primaryAction]
        actions.append(contentsOf: hero.secondaryActions)
        actions.append(contentsOf: contractActions)
        actions.append(contentsOf: planActions)
        actions.append(contentsOf: oneStepGoalActions)
        actions.append(contentsOf: supportActions)
        actions.append(contentsOf: deeperActions)

        return TodayExecutionViewState(
            dayRail: dayRail,
            activeLens: activeLens,
            availableLenses: lenses,
            lensSummary: lensSummary(input.nowState),
            dayState: dayState(input),
            dayStateSummary: dayStateSummary(input),
            protectedMustDo: contract.protected,
            recommendedStep: contract.best,
            notToday: contract.notToday,
            recoveryFallback: contract.fallback,
            whyThisMatters: contract.why,
            actionClosureEntry: contract.closure,
            saveTheDayAction: saveTheDay,
            frictionSignal: friction,
            hero: hero,
            todayTimeLayer: todayTime,
            oneStepGoalsPanel: oneStepGoals,
            supportingPanels: [friction] + Array(support.filter { $0.id != friction.id }.prefix(1)),
            deeperSections: deeper,
            commandMappings: TodayExecutionViewState.commandMappings(
                for: actions,
                explanations: input.explanations,
                recoveryOptionID: input.resilienceAssessment.recommendedRecoveryOptionID
            ),
            timeRequestsCalendarPermission: false,
            emptyGuidance: input.mode == .empty ? emptyGuidance(input) : nil,
            realityMeridianContinuity: realityMeridianContinuity
        )
    }
}
