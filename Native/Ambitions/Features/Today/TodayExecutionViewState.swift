import AmbitionsDesignSystem
import Foundation

enum TodayExecutionHeroKind: String, Equatable {
    case nextAction
    case recovery
    case empty
}

enum TodayExecutionPanelKind: String, Equatable {
    case contextLens
    case capture
    case plan
    case todayPlan
    case oneStepGoals
    case priority
    case recovery
    case waiting
    case friction
    case closure
}

enum TodayContractEntryKind: String, Equatable {
    case protectedMustDo
    case bestNextMove
    case notToday
    case recoveryFallback
    case whyThisMatters
    case actionClosure
}

enum TodayQualitativeDayState: String, Equatable {
    case clear = "Clear"
    case steady = "Steady"
    case tight = "Tight"
    case fragile = "Fragile"
    case atRisk = "At risk"
    case recovered = "Recovered"
    case protected = "Kept in view"
}

struct TodayLensChipState: Identifiable, Equatable {
    let id: String
    let title: String
    let icon: String
    let state: AmbitionVisualState
    let isActive: Bool
}

struct TodayCommandMappingState: Identifiable, Equatable {
    let id: String
    let actionKind: TodayActionKind
    let commandKind: AmbitionsCommandKind
    let destination: AmbitionsCommandDestination?
    let validationState: AmbitionsCommandValidationState
    let explanationID: String?
    let recoveryOptionID: String?
}

struct TodayExplanationAffordanceState: Identifiable, Equatable {
    let id: String
    let title: String
    let summary: String
    let explanationID: String?
    let state: AmbitionVisualState
}

struct TodayExecutionHeroState: Equatable {
    let kind: TodayExecutionHeroKind
    let eyebrow: String
    let title: String
    let subtitle: String
    let semanticState: AmbitionSemanticState
    let confidenceLabel: String
    let primaryAction: TodayInlineAction
    let secondaryActions: [TodayInlineAction]
    let explanation: TodayExplanationAffordanceState?
    let smallestUsefulNextStep: String?
    let accessibilityLabel: String
    let accessibilityValue: String
}

struct TodayContractEntryState: Identifiable, Equatable {
    let id: String
    let kind: TodayContractEntryKind
    let title: String
    let subtitle: String
    let value: String
    let semanticState: AmbitionSemanticState
    let action: TodayInlineAction?
    let explanation: TodayExplanationAffordanceState?
}

struct TodayExecutionPanelState: Identifiable, Equatable {
    let id: String
    let kind: TodayExecutionPanelKind
    let title: String
    let subtitle: String
    let value: String
    let semanticState: AmbitionSemanticState
    let action: TodayInlineAction?
    let explanation: TodayExplanationAffordanceState?
}

struct TodayExecutionDeepDiveState: Identifiable, Equatable {
    let id: String
    let title: String
    let rows: [TodayExecutionPanelState]
}

struct TodayPlanLayerItemState: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let timingLabel: String
    let sourceLabel: String
    let semanticState: AmbitionSemanticState
    let action: TodayInlineAction?
}

struct TodayPlanLayerState: Equatable {
    let title: String
    let subtitle: String
    let compactTimelineLabel: String
    let openWindowLabel: String
    let calendarSourceLabel: String
    let items: [TodayPlanLayerItemState]
    let moveAction: TodayInlineAction
    let parkAction: TodayInlineAction
    let markDoneAction: TodayInlineAction?
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct TodayOneStepGoalPreviewState: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let statusLabel: String
    let semanticState: AmbitionSemanticState
    let action: TodayInlineAction?
}

struct TodayOneStepGoalsPanelState: Equatable {
    let title: String
    let subtitle: String
    let value: String
    let previews: [TodayOneStepGoalPreviewState]
    let emptyMessage: String
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct TodayExecutionViewState: Equatable {
    let activeLens: TodayLensChipState
    let availableLenses: [TodayLensChipState]
    let lensSummary: String
    let dayState: TodayQualitativeDayState
    let dayStateSummary: String
    let protectedMustDo: TodayContractEntryState
    let bestNextMove: TodayContractEntryState
    let notToday: TodayContractEntryState
    let recoveryFallback: TodayContractEntryState
    let whyThisMatters: TodayContractEntryState
    let actionClosureEntry: TodayContractEntryState
    let saveTheDayAction: TodayInlineAction?
    let frictionSignal: TodayExecutionPanelState
    let hero: TodayExecutionHeroState
    let todayPlanLayer: TodayPlanLayerState
    let oneStepGoalsPanel: TodayOneStepGoalsPanelState
    let supportingPanels: [TodayExecutionPanelState]
    let deeperSections: [TodayExecutionDeepDiveState]
    let commandMappings: [TodayCommandMappingState]
    let planRequestsCalendarPermission: Bool
    let emptyGuidance: TodayExecutionPanelState?

    static func compatibility(
        mode: TodayExperienceMode,
        hero: TodayHeroState,
        support: TodaySupportLayerState
    ) -> TodayExecutionViewState {
        let activeLens = TodayLensChipState(id: "lens.all", title: "All", icon: "square.grid.2x2", state: .selected, isActive: true)
        let primary = hero.primaryAction.action
        let explanation = hero.truth.trustWhisper.map {
            TodayExplanationAffordanceState(
                id: "compat.why",
                title: $0.title,
                summary: $0.detail,
                explanationID: nil,
                state: $0.state
            )
        }
        let executionHero = TodayExecutionHeroState(
            kind: mode == .empty ? .empty : (support.recoveryBloom == nil ? .nextAction : .recovery),
            eyebrow: "Daily contract",
            title: hero.truth.dominantText.shortened(maxLength: 36),
            subtitle: hero.truth.supportingText.todayShortSentence,
            semanticState: semanticState(for: hero.truth.posture),
            confidenceLabel: hero.truth.posture.label,
            primaryAction: primary,
            secondaryActions: Array(hero.primaryAction.supportingActions.prefix(2)),
            explanation: explanation,
            smallestUsefulNextStep: hero.truth.nowTitle,
            accessibilityLabel: "Today. \(hero.truth.dominantText)",
            accessibilityValue: hero.truth.posture.label
        )
        let bestNext = TodayContractEntryState(
            id: "today2.contract.best-next",
            kind: .bestNextMove,
            title: "Do this next",
            subtitle: hero.truth.nowTitle.shortened(maxLength: 56),
            value: hero.truth.nowSubtitle.todayShortSentence,
            semanticState: semanticState(for: hero.truth.posture),
            action: primary,
            explanation: explanation
        )
        let protectedMustDo = TodayContractEntryState(
            id: "today2.contract.protected",
            kind: .protectedMustDo,
            title: "Keep this",
            subtitle: hero.truth.dominantText.shortened(maxLength: 56),
            value: hero.truth.posture == .noPlan ? "No must-do yet" : "Kept on today",
            semanticState: .protected,
            action: primary,
            explanation: nil
        )
        let notToday = TodayContractEntryState(
            id: "today2.contract.not-today",
            kind: .notToday,
            title: "Not today",
            subtitle: "Nothing extra is being pulled into today.",
            value: "Nothing heavy",
            semanticState: .trust,
            action: nil,
            explanation: nil
        )
        let fallback = TodayContractEntryState(
            id: "today2.contract.fallback",
            kind: .recoveryFallback,
            title: "Fallback",
            subtitle: support.recoveryBloom?.subtitle.todayShortSentence ?? "Make the move smaller before making the day louder.",
            value: support.recoveryBloom == nil ? "Smaller" : "Recovery ready",
            semanticState: support.recoveryBloom == nil ? .trust : .recovery,
            action: support.recoveryBloom?.options.first?.action ?? support.planAction,
            explanation: nil
        )
        let why = TodayContractEntryState(
            id: "today2.contract.why",
            kind: .whyThisMatters,
            title: "Why this matters",
            subtitle: explanation?.summary.todayShortSentence ?? hero.truth.supportingText.todayShortSentence,
            value: "Reason",
            semanticState: .trust,
            action: TodayInlineAction(kind: .askWhyThisMatters, title: "Why this?", systemImage: "questionmark.circle", state: .default, target: primary.target),
            explanation: explanation
        )
        let closure = TodayContractEntryState(
            id: "today2.contract.closure",
            kind: .actionClosure,
            title: "Closure entry",
            subtitle: "Completed, moved, protected, or recovered actions can land here later.",
            value: "Entry only",
            semanticState: .review,
            action: nil,
            explanation: TodayExplanationAffordanceState(
                id: "today2.closure.placeholder",
                title: "Entry only",
                summary: "This is a Today-level entry point only; future receipts stay owned by a later batch.",
                explanationID: nil,
                state: .default
            )
        )
        let capturePanel = TodayExecutionPanelState(
            id: "today2.capture",
            kind: .capture,
            title: support.quickCaptureTitle.shortened(maxLength: 28),
            subtitle: support.quickCaptureDetail.todayShortSentence,
            value: support.quickCaptureAction == nil ? "No capture pressure" : "Capture available",
            semanticState: .capture,
            action: support.quickCaptureAction,
            explanation: nil
        )
        let planPanel = TodayExecutionPanelState(
            id: "today2.plan",
            kind: .plan,
            title: "Plan guidance",
            subtitle: support.timeAperture.pressure.detail.todayShortSentence,
            value: support.timeAperture.pressure.label,
            semanticState: .calendarDerived,
            action: support.planAction,
            explanation: nil
        )
        let friction = TodayExecutionPanelState(
            id: "today2.friction.compat",
            kind: .friction,
            title: "Friction",
            subtitle: support.timeAperture.pressure.detail.todayShortSentence,
            value: support.timeAperture.pressure.label,
            semanticState: semanticState(for: hero.truth.posture),
            action: support.planAction,
            explanation: nil
        )
        let planItems = support.fixedCommitments.items.prefix(3).map {
            TodayPlanLayerItemState(
                id: "today2.plan.compat.\($0.id)",
                title: $0.title.shortened(maxLength: 48),
                subtitle: $0.subtitle.todayShortSentence,
                timingLabel: $0.label,
                sourceLabel: "Based on your plan",
                semanticState: semanticState(for: hero.truth.posture),
                action: $0.action ?? primary
            )
        }
        let timeline = planItems.isEmpty
            ? "No fixed plan yet"
            : planItems.map(\.timingLabel).prefix(3).joined(separator: " / ")
        let todayPlanLayer = TodayPlanLayerState(
            title: "Today Plan",
            subtitle: planItems.isEmpty ? "Start with one real move." : "The planned day stays visible.",
            compactTimelineLabel: timeline,
            openWindowLabel: support.timeAperture.bestUseTitle,
            calendarSourceLabel: "Based on your plan",
            items: Array(planItems),
            moveAction: TodayInlineAction(kind: .openPlan, title: "Move This", systemImage: "arrow.right.arrow.left", state: .default, target: primary.target),
            parkAction: TodayInlineAction(kind: .defer, title: "Park / Not Today", systemImage: "pause.circle", state: .default, target: primary.target),
            markDoneAction: primary.kind == .complete ? primary : TodayInlineAction(kind: .complete, title: "Mark Done", systemImage: "checkmark.circle", state: .success, target: primary.target),
            accessibilityLabel: "Today Plan",
            accessibilityValue: planItems.isEmpty ? "No fixed plan yet." : "\(planItems.count) planned item\(planItems.count == 1 ? "" : "s"). \(timeline).",
            accessibilityHint: "Shows the planned day without requesting calendar access here."
        )
        let oneStepGoalsPanel = TodayOneStepGoalsPanelState(
            title: "One-Step Goals",
            subtitle: "Standalone tasks stay small.",
            value: "None today",
            previews: [],
            emptyMessage: "No One-Step Goals on Today",
            accessibilityLabel: "One-Step Goals",
            accessibilityValue: "No standalone task is pulling on Today.",
            accessibilityHint: "Tasks are standalone One-Step Goals. Steps remain inside Goals, Paths, or Plans."
        )
        return TodayExecutionViewState(
            activeLens: activeLens,
            availableLenses: [activeLens],
            lensSummary: "Showing all available work.",
            dayState: dayState(for: hero.truth.posture),
            dayStateSummary: hero.truth.supportingText.todayShortSentence,
            protectedMustDo: protectedMustDo,
            bestNextMove: bestNext,
            notToday: notToday,
            recoveryFallback: fallback,
            whyThisMatters: why,
            actionClosureEntry: closure,
            saveTheDayAction: support.recoveryBloom?.options.first?.action ?? support.planAction,
            frictionSignal: friction,
            hero: executionHero,
            todayPlanLayer: todayPlanLayer,
            oneStepGoalsPanel: oneStepGoalsPanel,
            supportingPanels: [capturePanel, planPanel],
            deeperSections: [],
            commandMappings: commandMappings(for: [primary] + hero.primaryAction.supportingActions + [support.quickCaptureAction, support.planAction].compactMap { $0 }, explanations: [], recoveryOptionID: nil),
            planRequestsCalendarPermission: false,
            emptyGuidance: mode == .empty ? capturePanel : nil
        )
    }

    private static func semanticState(for posture: TodayDayPosture) -> AmbitionSemanticState {
        switch posture {
        case .stable:
            .focus
        case .tight:
            .protected
        case .drifted, .recovering:
            .recovery
        case .overloaded:
            .caution
        case .lowData:
            .trust
        case .noPlan:
            .capture
        }
    }

    private static func dayState(for posture: TodayDayPosture) -> TodayQualitativeDayState {
        switch posture {
        case .stable:
            .steady
        case .tight:
            .protected
        case .drifted:
            .fragile
        case .recovering:
            .recovered
        case .overloaded:
            .atRisk
        case .lowData, .noPlan:
            .clear
        }
    }
}

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
        let todayPlan = todayPlanLayer(input, hero: hero)
        let oneStepGoals = oneStepGoalsPanel(input)
        let saveTheDay = saveTheDayAction(input, hero: hero)
        let support = supportingPanels(input)
        let deeper = deeperSections(input)
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
        let planActions = todayPlan.items.compactMap(\.action) + [
            todayPlan.moveAction,
            todayPlan.parkAction,
            todayPlan.markDoneAction,
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
            activeLens: activeLens,
            availableLenses: lenses,
            lensSummary: lensSummary(input.nowState),
            dayState: dayState(input),
            dayStateSummary: dayStateSummary(input),
            protectedMustDo: contract.protected,
            bestNextMove: contract.best,
            notToday: contract.notToday,
            recoveryFallback: contract.fallback,
            whyThisMatters: contract.why,
            actionClosureEntry: contract.closure,
            saveTheDayAction: saveTheDay,
            frictionSignal: friction,
            hero: hero,
            todayPlanLayer: todayPlan,
            oneStepGoalsPanel: oneStepGoals,
            supportingPanels: [friction] + Array(support.filter { $0.id != friction.id }.prefix(1)),
            deeperSections: deeper,
            commandMappings: TodayExecutionViewState.commandMappings(
                for: actions,
                explanations: input.explanations,
                recoveryOptionID: input.resilienceAssessment.recommendedRecoveryOptionID
            ),
            planRequestsCalendarPermission: false,
            emptyGuidance: input.mode == .empty ? emptyGuidance(input) : nil
        )
    }
}

extension TodayExecutionViewState {
    func screenContractSnapshot(
        topLevelTabTitles: [String] = ScreenContractValidator.canonicalTopLevelTabs
    ) -> ScreenContractImplementationSnapshot {
        ScreenContractImplementationSnapshot(
            screenID: .today,
            firstScreenContent: [
                "Hero Decision Panel",
                "Now Layer",
                "Today Plan Layer",
                "Compact timeline",
                "Relevant One-Step Goals",
                "Open-window awareness",
                "Recovery"
            ],
            panels: [.heroDecision, .nowLayer, .todayPlan, .compactTimeline, .oneStepGoals, .schedule, .recovery],
            actions: [.start, .move, .parkNotToday, .markDone, .saveTheDay],
            drillDowns: ["Goal Detail", "Plan", "Receipt", "Review"],
            copySamples: [
                hero.title,
                hero.subtitle,
                todayPlanLayer.title,
                todayPlanLayer.subtitle,
                todayPlanLayer.calendarSourceLabel,
                todayPlanLayer.openWindowLabel,
                oneStepGoalsPanel.title,
                oneStepGoalsPanel.subtitle,
                oneStepGoalsPanel.emptyMessage,
                saveTheDayAction?.title ?? "Save the day"
            ],
            topLevelTabTitles: topLevelTabTitles,
            supportsDensityBehavior: true,
            supportsPanelSizeBehavior: true,
            hasAccessibilitySummary: true,
            hasPrivacySafeState: true,
            hasGestureAlternative: true
        )
    }
}

private extension TodayExecutionProjector {
    func heroState(_ input: TodayExecutionProjectionInput) -> TodayExecutionHeroState {
        let recoveryNeeded = [.needsRecovery, .atRisk, .blocked, .recovering].contains(input.resilienceAssessment.status)
        if input.mode == .empty {
            let action = input.legacySupport.quickCaptureAction ?? TodayInlineAction(
                kind: .quickLog,
                title: "Capture something",
                systemImage: "tray.and.arrow.down",
                state: .selected,
                target: TodayActionTarget()
            )
            return TodayExecutionHeroState(
                kind: .empty,
                eyebrow: "Daily contract",
                title: "Start here",
                subtitle: "Capture one real thing.",
                semanticState: .capture,
                confidenceLabel: "Low data",
                primaryAction: action,
                secondaryActions: [openPlanAction()],
                explanation: TodayExplanationAffordanceState(id: "today2.empty.why", title: "Why?", summary: "There is not enough local goal or capture data to choose a best next move yet.", explanationID: nil, state: .default),
                smallestUsefulNextStep: "Capture one thing.",
                accessibilityLabel: "Today daily contract. Start with one real thing.",
                accessibilityValue: "Empty state"
            )
        }

        if recoveryNeeded {
            let option = input.resilienceAssessment.recommendedRecoveryOption
            let primary = action(for: option, fallback: input.legacyHero.primaryAction.action)
            return TodayExecutionHeroState(
                kind: .recovery,
                eyebrow: "Daily contract",
                title: (option?.title ?? "Recover with one move").shortened(maxLength: 36),
                subtitle: (input.resilienceAssessment.smallestUsefulNextStep ?? option?.summary ?? "Choose the smaller safe move.").todayShortSentence,
                semanticState: .recovery,
                confidenceLabel: recoveryLabel(input.resilienceAssessment.status),
                primaryAction: primary,
                secondaryActions: secondaryRecoveryActions(input, primary: primary),
                explanation: explanation(input, preferred: option?.relatedExplanationID, fallbackTitle: "Why recover?"),
                smallestUsefulNextStep: input.resilienceAssessment.smallestUsefulNextStep,
                accessibilityLabel: "Today recovery. \(option?.title ?? "Recovery needed")",
                accessibilityValue: recoveryLabel(input.resilienceAssessment.status)
            )
        }

        let best = input.nowState.bestNextAction
        let primary = action(for: best) ?? input.legacyHero.primaryAction.action
        return TodayExecutionHeroState(
            kind: .nextAction,
            eyebrow: "Daily contract",
            title: (best?.title ?? input.legacyHero.truth.nowTitle).shortened(maxLength: 36),
            subtitle: (best?.subtitle ?? input.legacyHero.truth.nowSubtitle).todayShortSentence,
            semanticState: semanticState(confidence: input.nowState.nextActionConfidence, posture: input.nowState.todayPosture),
            confidenceLabel: input.nowState.nextActionConfidence.rawValue.capitalized,
            primaryAction: primary,
            secondaryActions: secondaryStableActions(input, primary: primary),
            explanation: explanation(input, preferred: input.nowState.nextActionExplanationID, fallbackTitle: "Why this now?"),
            smallestUsefulNextStep: best?.title ?? input.legacyHero.truth.nowTitle,
            accessibilityLabel: "Today best next move. \(best?.title ?? input.legacyHero.truth.nowTitle)",
            accessibilityValue: input.nowState.nextActionConfidence.rawValue.capitalized
        )
    }

    typealias ContractEntries = (
        protected: TodayContractEntryState,
        best: TodayContractEntryState,
        notToday: TodayContractEntryState,
        fallback: TodayContractEntryState,
        why: TodayContractEntryState,
        closure: TodayContractEntryState
    )

    func contractEntries(_ input: TodayExecutionProjectionInput, hero: TodayExecutionHeroState) -> ContractEntries {
        let bestTitle = input.nowState.bestNextAction?.title ?? hero.smallestUsefulNextStep ?? input.legacyHero.truth.nowTitle
        let protectedSummary = input.resilienceAssessment.protectedHighPriorityWork.first
        let protected = TodayContractEntryState(
            id: "today2.contract.protected",
            kind: .protectedMustDo,
            title: "Keep this",
            subtitle: (protectedSummary?.title ?? bestTitle).shortened(maxLength: 56),
            value: protectedSummary == nil && input.mode == .empty ? "No must-do yet" : "Kept on today",
            semanticState: .protected,
            action: protectedSummary?.relatedGoalID.map {
                TodayInlineAction(kind: .openPlan, title: "Open Plan", systemImage: "calendar.badge.clock", state: .selected, target: TodayActionTarget(goalID: $0))
            } ?? hero.primaryAction,
            explanation: explanation(input, preferred: input.nowState.nextActionExplanationID, fallbackTitle: "Why this?")
        )
        let best = TodayContractEntryState(
            id: "today2.contract.best-next",
            kind: .bestNextMove,
            title: "Do this next",
            subtitle: bestTitle.shortened(maxLength: 56),
            value: input.nowState.nextActionConfidence == .low ? "Doable enough" : "Ready",
            semanticState: hero.semanticState,
            action: hero.primaryAction,
            explanation: hero.explanation
        )
        let notToday = notTodayEntry(input)
        let fallback = recoveryFallbackEntry(input, hero: hero)
        let why = TodayContractEntryState(
            id: "today2.contract.why",
            kind: .whyThisMatters,
            title: "Why this matters",
            subtitle: (hero.explanation?.summary ?? input.nowState.priorityPressure.summary).todayShortSentence,
            value: "Reason",
            semanticState: .trust,
            action: TodayInlineAction(kind: .askWhyThisMatters, title: "Why this?", systemImage: "questionmark.circle", state: .default, target: hero.primaryAction.target),
            explanation: hero.explanation
        )
        let closure = TodayContractEntryState(
            id: "today2.contract.closure",
            kind: .actionClosure,
            title: "Closure entry",
            subtitle: "Completed, moved, protected, or recovered actions can land here later.",
            value: "Entry only",
            semanticState: .review,
            action: nil,
            explanation: TodayExplanationAffordanceState(
                id: "today2.closure.placeholder",
                title: "Entry only",
                summary: "Today is reserving this place for future receipts without creating a receipt system in this batch.",
                explanationID: nil,
                state: .default
            )
        )
        return (protected, best, notToday, fallback, why, closure)
    }

    func notTodayEntry(_ input: TodayExecutionProjectionInput) -> TodayContractEntryState {
        let passive = input.resilienceAssessment.passiveWorkDeferredCalmly.first
        let passivePressure = input.nowState.passiveGoalPressure.first
        let parkedTitle = passive?.title ?? passivePressure?.title
        return TodayContractEntryState(
            id: "today2.contract.not-today",
            kind: .notToday,
            title: "Not today",
            subtitle: (parkedTitle.map { "\($0) can move slowly." } ?? "Nothing extra is being pulled into today.").todayShortSentence,
            value: parkedTitle == nil ? "Nothing heavy" : "Parked",
            semanticState: .trust,
            action: nil,
            explanation: nil
        )
    }

    func recoveryFallbackEntry(_ input: TodayExecutionProjectionInput, hero: TodayExecutionHeroState) -> TodayContractEntryState {
        let option = input.resilienceAssessment.recommendedRecoveryOption
        let action = option.map { self.action(for: $0, fallback: hero.primaryAction) } ?? openPlanAction(title: "Make smaller")
        return TodayContractEntryState(
            id: "today2.contract.fallback",
            kind: .recoveryFallback,
            title: "Fallback",
            subtitle: (input.resilienceAssessment.smallestUsefulNextStep ?? option?.summary ?? "Make the move smaller or protect it in Plan.").todayShortSentence,
            value: option == nil ? "Smaller" : "Recovery ready",
            semanticState: option == nil ? .trust : .recovery,
            action: action,
            explanation: explanation(input, preferred: option?.relatedExplanationID, fallbackTitle: "Why this fallback?")
        )
    }

    func saveTheDayAction(_ input: TodayExecutionProjectionInput, hero: TodayExecutionHeroState) -> TodayInlineAction? {
        guard input.mode != .empty else { return nil }
        if let option = input.resilienceAssessment.recommendedRecoveryOption {
            let action = action(for: option, fallback: hero.primaryAction)
            return TodayInlineAction(kind: action.kind, title: "Save the day", systemImage: "arrow.uturn.backward.circle", state: .selected, target: action.target)
        }
        return TodayInlineAction(kind: .openPlan, title: "Save the day", systemImage: "arrow.uturn.backward.circle", state: .default, target: TodayActionTarget())
    }

    func frictionSignal(_ input: TodayExecutionProjectionInput) -> TodayExecutionPanelState {
        if input.resilienceAssessment.status != .stable {
            return TodayExecutionPanelState(
                id: "today2.friction.recovery",
                kind: .friction,
                title: "Friction",
                subtitle: input.resilienceAssessment.recommendedRecoveryOption?.summary.todayShortSentence ?? "Recovery is the dominant signal.",
                value: recoveryLabel(input.resilienceAssessment.status),
                semanticState: .recovery,
                action: openPlanAction(),
                explanation: explanation(input, preferred: input.resilienceAssessment.recommendedRecoveryOption?.relatedExplanationID, fallbackTitle: "Why recover?")
            )
        }
        if input.nowState.urgentOutsideLens.count > 0 {
            return TodayExecutionPanelState(
                id: "today2.friction.outside-lens",
                kind: .friction,
                title: "Friction",
                subtitle: input.nowState.urgentOutsideLens.summary.todayShortSentence,
                value: "\(input.nowState.urgentOutsideLens.count) outside",
                semanticState: .caution,
                action: openPlanAction(title: "View all"),
                explanation: nil
            )
        }
        if input.nowState.blockersWaiting.blockedCount + input.nowState.blockersWaiting.waitingCount > 0 {
            return TodayExecutionPanelState(
                id: "today2.friction.waiting",
                kind: .friction,
                title: "Friction",
                subtitle: input.nowState.blockersWaiting.summary.todayShortSentence,
                value: "Waiting",
                semanticState: .waiting,
                action: nil,
                explanation: nil
            )
        }
        if [.elevated, .high, .critical].contains(input.nowState.schedulePressure.level) {
            return TodayExecutionPanelState(
                id: "today2.friction.schedule",
                kind: .friction,
                title: "Friction",
                subtitle: input.nowState.schedulePressure.summary.todayShortSentence,
                value: pressureLabel(input.nowState.schedulePressure.level),
                semanticState: .protected,
                action: openPlanAction(),
                explanation: nil
            )
        }
        return TodayExecutionPanelState(
            id: "today2.friction.none",
            kind: .friction,
            title: "Friction",
            subtitle: "No major friction detected.",
            value: "Clear",
            semanticState: .trust,
            action: nil,
            explanation: nil
        )
    }

    func todayPlanLayer(_ input: TodayExecutionProjectionInput, hero: TodayExecutionHeroState) -> TodayPlanLayerState {
        var items: [TodayPlanLayerItemState] = input.legacySupport.fixedCommitments.items.prefix(3).map {
            TodayPlanLayerItemState(
                id: "today2.plan.fixed.\($0.id)",
                title: $0.title.shortened(maxLength: 48),
                subtitle: $0.subtitle.todayShortSentence,
                timingLabel: $0.label,
                sourceLabel: calendarSourceLabel(input),
                semanticState: .protected,
                action: $0.action ?? hero.primaryAction
            )
        }

        if items.count < 3 {
            let flexibleItems = input.legacySupport.flexibleRoom.items.prefix(3 - items.count).map {
                TodayPlanLayerItemState(
                    id: "today2.plan.flexible.\($0.id)",
                    title: $0.title.shortened(maxLength: 48),
                    subtitle: $0.subtitle.todayShortSentence,
                    timingLabel: $0.label,
                    sourceLabel: "Based on your plan",
                    semanticState: .trust,
                    action: $0.action
                )
            }
            items.append(contentsOf: flexibleItems)
        }

        if items.isEmpty, input.mode != .empty {
            items.append(
                TodayPlanLayerItemState(
                    id: "today2.plan.best-next",
                    title: hero.smallestUsefulNextStep?.shortened(maxLength: 48) ?? hero.title,
                    subtitle: hero.subtitle.todayShortSentence,
                    timingLabel: "Now",
                    sourceLabel: "Based on your plan",
                    semanticState: hero.semanticState,
                    action: hero.primaryAction
                )
            )
        }

        let compactTimeline = items.isEmpty
            ? "No fixed plan yet"
            : items.map(\.timingLabel).prefix(3).joined(separator: " / ")
        let openWindow = input.realitySnapshot?.openWindowCandidates.first?.fitSummary.todayShortSentence
            ?? input.legacySupport.timeAperture.bestUseTitle
        let source = calendarSourceLabel(input)
        let moveAction = TodayInlineAction(
            kind: .openPlan,
            title: "Move This",
            systemImage: "arrow.right.arrow.left",
            state: .default,
            target: hero.primaryAction.target
        )
        let parkAction = TodayInlineAction(
            kind: .defer,
            title: "Park / Not Today",
            systemImage: "pause.circle",
            state: .default,
            target: hero.primaryAction.target
        )
        let markDoneAction = TodayInlineAction(
            kind: .complete,
            title: "Mark Done",
            systemImage: "checkmark.circle",
            state: .success,
            target: hero.primaryAction.target
        )
        return TodayPlanLayerState(
            title: "Today Plan",
            subtitle: items.isEmpty ? "Start with one real move." : "The planned day stays visible.",
            compactTimelineLabel: compactTimeline,
            openWindowLabel: openWindow,
            calendarSourceLabel: source,
            items: items,
            moveAction: moveAction,
            parkAction: parkAction,
            markDoneAction: markDoneAction,
            accessibilityLabel: "Today Plan",
            accessibilityValue: items.isEmpty
                ? "No fixed plan yet. \(source). \(openWindow)."
                : "\(items.count) planned item\(items.count == 1 ? "" : "s"). \(compactTimeline). \(source). \(openWindow).",
            accessibilityHint: "Shows the planned day and visible buttons to start, move, park, or mark done without requesting calendar access here."
        )
    }

    func oneStepGoalsPanel(_ input: TodayExecutionProjectionInput) -> TodayOneStepGoalsPanelState {
        let summaries = input.oneStepGoalsProjection.areas.flatMap(\.oneStepGoals)
            .filter { $0.status.isOpen }
            .prefix(3)
        let previews = summaries.map { summary in
            TodayOneStepGoalPreviewState(
                id: summary.id.rawValue,
                title: summary.title.shortened(maxLength: 48),
                subtitle: oneStepGoalSubtitle(summary),
                statusLabel: summary.status.displayName,
                semanticState: oneStepGoalSemanticState(summary.status),
                action: TodayInlineAction(
                    kind: .openPlan,
                    title: "Review",
                    systemImage: "arrow.right.circle",
                    state: .default,
                    target: TodayActionTarget()
                )
            )
        }
        let total = input.oneStepGoalsProjection.counts.openCount
        return TodayOneStepGoalsPanelState(
            title: "One-Step Goals",
            subtitle: total == 0 ? "No standalone task is pulling on Today." : "Standalone tasks stay small.",
            value: total == 0 ? "None today" : "\(total) open",
            previews: Array(previews),
            emptyMessage: "No One-Step Goals on Today",
            accessibilityLabel: "One-Step Goals",
            accessibilityValue: total == 0 ? "No standalone task is pulling on Today." : "\(total) open standalone task\(total == 1 ? "" : "s").",
            accessibilityHint: "Tasks are standalone One-Step Goals. Steps remain inside Goals, Paths, or Plans."
        )
    }

    func dayState(_ input: TodayExecutionProjectionInput) -> TodayQualitativeDayState {
        switch input.resilienceAssessment.status {
        case .recovering:
            return .recovered
        case .needsRecovery:
            return .fragile
        case .atRisk, .blocked:
            return .atRisk
        case .watch:
            return .tight
        case .stable:
            break
        }
        switch input.nowState.todayPosture {
        case .open:
            return .clear
        case .steady:
            return .steady
        case .tight:
            return .protected
        case .overloaded:
            return .atRisk
        case .recovering:
            return .recovered
        case .waiting, .lowData, .noPlan:
            return .fragile
        }
    }

    func dayStateSummary(_ input: TodayExecutionProjectionInput) -> String {
        switch dayState(input) {
        case .clear:
            return "The day has room for one real move."
        case .steady:
            return "One move is clear enough to keep in view."
        case .tight:
            return "Keep today narrow."
        case .fragile:
            return "Use the fallback before adding pressure."
        case .atRisk:
            return "Reduce pressure before adding new work."
        case .recovered:
            return "Recovery is already shaping the day."
        case .protected:
            return "The important move gets the first claim."
        }
    }

    func supportingPanels(_ input: TodayExecutionProjectionInput) -> [TodayExecutionPanelState] {
        var panels: [TodayExecutionPanelState] = []
        if input.nowState.urgentOutsideLens.count > 0 {
            panels.append(
                TodayExecutionPanelState(
                    id: "today2.outside-lens",
                    kind: .contextLens,
                    title: "Outside this lens",
                    subtitle: input.nowState.urgentOutsideLens.summary.todayShortSentence,
                    value: "\(input.nowState.urgentOutsideLens.count) item\(input.nowState.urgentOutsideLens.count == 1 ? "" : "s")",
                    semanticState: .caution,
                    action: TodayInlineAction(kind: .openPlan, title: "View all", systemImage: "square.grid.2x2", state: .default, target: TodayActionTarget()),
                    explanation: nil
                )
            )
        }
        panels.append(capturePanel(input))
        panels.append(planPanel(input))
        if panels.count < 2 {
            panels.append(priorityPanel(input))
        }
        return panels
    }

    func deeperSections(_ input: TodayExecutionProjectionInput) -> [TodayExecutionDeepDiveState] {
        let pressureRows = [
            priorityPanel(input),
            waitingPanel(input),
        ]
        let recoveryRows = recoveryDetailPanels(input)
        return [
            TodayExecutionDeepDiveState(id: "today2.deep.priority", title: "Priority reality", rows: pressureRows),
            TodayExecutionDeepDiveState(id: "today2.deep.recovery", title: "Recovery details", rows: recoveryRows),
        ].filter { $0.rows.isEmpty == false }
    }

    func capturePanel(_ input: TodayExecutionProjectionInput) -> TodayExecutionPanelState {
        let level = input.nowState.captureUrgency.level
        return TodayExecutionPanelState(
            id: "today2.capture",
            kind: .capture,
            title: input.nowState.captureUrgency.level == .none ? "Capture is clear" : "Capture pressure",
            subtitle: input.nowState.captureUrgency.summary.todayShortSentence,
            value: pressureLabel(level),
            semanticState: level == .none ? .trust : .capture,
            action: input.legacySupport.quickCaptureAction ?? TodayInlineAction(kind: .quickLog, title: "Open Capture", systemImage: "tray.and.arrow.down", state: .selected, target: TodayActionTarget()),
            explanation: nil
        )
    }

    func planPanel(_ input: TodayExecutionProjectionInput) -> TodayExecutionPanelState {
        let summary = input.realitySnapshot?.availability.summary ?? input.nowState.schedulePressure.summary
        let calendarLine = input.realitySnapshot?.calendarContext?.hasCalendarReadAccess == true
            ? "Calendar-aware and local."
            : "Plan works without calendar access."
        return TodayExecutionPanelState(
            id: "today2.plan",
            kind: .plan,
            title: planTitle(input.nowState.schedulePressure.level),
            subtitle: "\(summary.todayShortSentence) \(calendarLine)",
            value: pressureLabel(input.nowState.schedulePressure.level),
            semanticState: .calendarDerived,
            action: openPlanAction(),
            explanation: nil
        )
    }

    func calendarSourceLabel(_ input: TodayExecutionProjectionInput) -> String {
        if input.realitySnapshot?.calendarContext?.hasCalendarReadAccess == true {
            return "From your calendar"
        }
        if input.realitySnapshot?.scheduledBlocks.isEmpty == false {
            return "Created in Ambitions"
        }
        return "Based on your plan"
    }

    func oneStepGoalSubtitle(_ summary: OneStepGoalSummary) -> String {
        [
            summary.timingLabel,
            summary.linkedActiveGoalCount > 0 ? "\(summary.linkedActiveGoalCount) linked goal\(summary.linkedActiveGoalCount == 1 ? "" : "s")" : nil,
            summary.suggestedNextAction
        ].compactMap { $0 }.joined(separator: " · ").todayShortSentence
    }

    func oneStepGoalSemanticState(_ status: OneStepGoalStatus) -> AmbitionSemanticState {
        switch status {
        case .today, .ready:
            return .focus
        case .scheduled:
            return .calendarDerived
        case .waiting:
            return .waiting
        case .reviewLater, .parked:
            return .trust
        case .completed:
            return .success
        case .archived:
            return .review
        }
    }

    func priorityPanel(_ input: TodayExecutionProjectionInput) -> TodayExecutionPanelState {
        let active = input.nowState.activeGoalPressure.count
        let passive = input.nowState.passiveGoalPressure.count
        return TodayExecutionPanelState(
            id: "today2.priority",
            kind: .priority,
            title: "Active balance",
            subtitle: "Active work stays ahead.",
            value: "\(active) active / \(passive) passive",
            semanticState: input.nowState.priorityPressure.overallPressure == .none ? .trust : .protected,
            action: nil,
            explanation: TodayExplanationAffordanceState(id: "today2.priority.why", title: "Why?", summary: input.nowState.priorityPressure.summary.todayShortSentence, explanationID: input.nowState.nextActionExplanationID, state: .selected)
        )
    }

    func waitingPanel(_ input: TodayExecutionProjectionInput) -> TodayExecutionPanelState {
        TodayExecutionPanelState(
            id: "today2.waiting",
            kind: .waiting,
            title: "Waiting and blocked",
            subtitle: input.nowState.blockersWaiting.summary.todayShortSentence,
            value: "\(input.nowState.blockersWaiting.waitingCount) waiting / \(input.nowState.blockersWaiting.blockedCount) blocked",
            semanticState: .waiting,
            action: nil,
            explanation: nil
        )
    }

    func recoveryDetailPanels(_ input: TodayExecutionProjectionInput) -> [TodayExecutionPanelState] {
        var protected = input.resilienceAssessment.protectedHighPriorityWork.prefix(1).map {
            TodayExecutionPanelState(id: "today2.protected.\($0.id)", kind: .recovery, title: "Kept in view", subtitle: $0.summary.todayShortSentence, value: $0.title.shortened(maxLength: 24), semanticState: .protected, action: openPlanAction(), explanation: nil)
        }
        if protected.isEmpty, input.nowState.deadlinePressure.level != .none {
            protected = [
                TodayExecutionPanelState(
                    id: "today2.protected.deadline",
                    kind: .recovery,
                    title: "Kept in view",
                    subtitle: input.nowState.deadlinePressure.summary.todayShortSentence,
                    value: pressureLabel(input.nowState.deadlinePressure.level),
                    semanticState: .protected,
                    action: openPlanAction(),
                    explanation: nil
                ),
            ]
        }
        let passive = input.resilienceAssessment.passiveWorkDeferredCalmly.prefix(1).map {
            TodayExecutionPanelState(id: "today2.passive.\($0.id)", kind: .priority, title: "Can move slowly", subtitle: $0.summary.todayShortSentence, value: $0.title.shortened(maxLength: 24), semanticState: .trust, action: nil, explanation: nil)
        }
        let waiting = input.resilienceAssessment.waitingOrBlockedRemovedFromPressure.prefix(1).map {
            TodayExecutionPanelState(id: "today2.waiting.\($0.id)", kind: .waiting, title: "Waiting", subtitle: $0.summary.todayShortSentence, value: $0.title.shortened(maxLength: 24), semanticState: .waiting, action: nil, explanation: nil)
        }
        return protected + passive + waiting
    }

    func emptyGuidance(_ input: TodayExecutionProjectionInput) -> TodayExecutionPanelState {
        TodayExecutionPanelState(
            id: "today2.empty.guidance",
            kind: .capture,
            title: "Start by capturing",
            subtitle: "Today will not pretend certainty.",
            value: "No blank dashboard",
            semanticState: .capture,
            action: input.legacySupport.quickCaptureAction,
            explanation: nil
        )
    }
}

private extension TodayExecutionProjector {
    func action(for action: NowAction?) -> TodayInlineAction? {
        guard let action else { return nil }
        let target = TodayActionTarget(goalID: action.reference?.goalID, stepID: action.reference?.stepID)
        switch action.kind {
        case .focus:
            return TodayInlineAction(kind: .startFocus, title: "Start focus", systemImage: "scope", state: .selected, target: target)
        case .completeAction:
            return TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: target)
        case .openGoal:
            return TodayInlineAction(kind: .openDetail, title: "Open Goal", systemImage: "arrow.right.circle", state: .default, target: target)
        case .openPlan, .schedule:
            return openPlanAction()
        case .capture, .routeCommitment:
            return TodayInlineAction(kind: .quickLog, title: "Open Capture", systemImage: "tray.and.arrow.down", state: .selected, target: target)
        case .recover:
            return TodayInlineAction(kind: .protectLater, title: "Recover", systemImage: "arrow.uturn.backward.circle", state: .selected, target: target)
        case .explain:
            return TodayInlineAction(kind: .askWhyThisMatters, title: "Why this?", systemImage: "questionmark.circle", state: .default, target: target)
        case .wait:
            return TodayInlineAction(kind: .openPlan, title: "View waiting", systemImage: "hourglass", state: .default, target: target)
        case .review, .none:
            return nil
        }
    }

    func action(for option: ExecutionRecoveryOption?, fallback: TodayInlineAction) -> TodayInlineAction {
        guard let option else { return fallback }
        let target = TodayActionTarget(goalID: option.relatedGoalID, draftID: nil)
        switch option.strategy {
        case .openPlan, .protectDeadlineWork, .rescheduleLater, .acceptSlip:
            return TodayInlineAction(kind: .openPlan, title: "Open Plan", systemImage: "calendar", state: .selected, target: target)
        case .openCapture, .clarifyNextStep, .askForDecision:
            return TodayInlineAction(kind: .quickLog, title: "Open Capture", systemImage: "tray.and.arrow.down", state: .selected, target: target)
        case .openGoal, .reduceScope:
            return TodayInlineAction(kind: .openDetail, title: "Open Goal", systemImage: "arrow.right.circle", state: .selected, target: target)
        case .splitIntoSmallerStep, .doSmallestNextStep:
            return TodayInlineAction(kind: .split, title: "Smallest step", systemImage: "scissors", state: .selected, target: target)
        case .deferPassiveWork, .keepAsSomeday:
            return TodayInlineAction(kind: .defer, title: "Let it wait", systemImage: "clock", state: .default, target: target)
        case .moveToWaiting:
            return TodayInlineAction(kind: .openPlan, title: "Keep waiting", systemImage: "hourglass", state: .default, target: target)
        }
    }

    func secondaryRecoveryActions(_ input: TodayExecutionProjectionInput, primary: TodayInlineAction) -> [TodayInlineAction] {
        let optionActions = input.resilienceAssessment.recoveryOptions.map { action(for: $0, fallback: primary) }
        return unique(optionActions + [openPlanAction(), TodayInlineAction(kind: .askWhyThisMatters, title: "Why recover?", systemImage: "questionmark.circle", state: .default, target: primary.target)], excluding: primary)
    }

    func secondaryStableActions(_ input: TodayExecutionProjectionInput, primary: TodayInlineAction) -> [TodayInlineAction] {
        unique([
            TodayInlineAction(kind: .askWhyThisMatters, title: "Why this?", systemImage: "questionmark.circle", state: .default, target: primary.target),
            openPlanAction(),
            input.legacySupport.quickCaptureAction,
        ].compactMap { $0 }, excluding: primary)
    }

    func unique(_ actions: [TodayInlineAction], excluding primary: TodayInlineAction) -> [TodayInlineAction] {
        var seen = Set([primary.id])
        return actions.filter { seen.insert($0.id).inserted }.prefix(3).map { $0 }
    }

    func openPlanAction(title: String = "Open Plan") -> TodayInlineAction {
        TodayInlineAction(kind: .openPlan, title: title, systemImage: "calendar", state: .default, target: TodayActionTarget())
    }

    func explanation(_ input: TodayExecutionProjectionInput, preferred: String?, fallbackTitle: String) -> TodayExplanationAffordanceState? {
        let explanation = preferred.flatMap { id in input.explanations.first { $0.id == id } } ?? input.explanations.first
        return TodayExplanationAffordanceState(
            id: "today2.explanation.\(preferred ?? explanation?.id ?? fallbackTitle)",
            title: explanation?.title ?? fallbackTitle,
            summary: explanation?.summary ?? input.legacyHero.truth.trustWhisper?.detail ?? input.nowState.priorityPressure.summary,
            explanationID: explanation?.id ?? preferred,
            state: .selected
        )
    }

    func lensChip(_ lens: NowContextLens, active: Bool) -> TodayLensChipState {
        TodayLensChipState(id: "lens.\(lens.rawValue)", title: lens.displayTitle, icon: lens.icon, state: active ? .selected : .default, isActive: active)
    }

    func lensSummary(_ state: CanonicalNowState) -> String {
        let source = state.isManualLensOverrideActive ? "manual override" : state.lensSource.displayTitle
        if state.urgentOutsideLens.count > 0 {
            return "\(state.activeContextLens.displayTitle) lens from \(source). \(state.urgentOutsideLens.summary)"
        }
        return "\(state.activeContextLens.displayTitle) from \(source). Urgent work stays visible."
    }

    func semanticState(confidence: RecommendationConfidence, posture: NowPosture) -> AmbitionSemanticState {
        if posture == .tight || posture == .overloaded { return .protected }
        switch confidence {
        case .high:
            return .focus
        case .medium:
            return .confidenceMedium
        case .low:
            return .trust
        }
    }

    func recoveryLabel(_ status: ExecutionRecoveryStatus) -> String {
        switch status {
        case .stable: "Stable"
        case .watch: "Watch"
        case .needsRecovery: "Needs recovery"
        case .atRisk: "At risk"
        case .blocked: "Blocked"
        case .recovering: "Recovering"
        }
    }

    func pressureLabel(_ level: NowPressureLevel) -> String {
        switch level {
        case .none: "No pressure"
        case .low: "Low"
        case .moderate: "Moderate"
        case .elevated: "Elevated"
        case .high: "High"
        case .critical: "Critical"
        }
    }

    func planTitle(_ level: NowPressureLevel) -> String {
        switch level {
        case .none, .low:
            "Plan has room"
        case .moderate:
            "Plan is getting tight"
        case .elevated, .high, .critical:
            "Plan needs attention"
        }
    }
}

private extension String {
    var todayShortSentence: String {
        let normalized = split(whereSeparator: \.isNewline).joined(separator: " ")
        let first = normalized.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true).first.map(String.init) ?? normalized
        return first.shortened(maxLength: 64)
    }

    func shortened(maxLength: Int) -> String {
        guard count > maxLength else { return self }
        let end = index(startIndex, offsetBy: max(0, maxLength - 1), limitedBy: endIndex) ?? endIndex
        return String(self[..<end]).trimmingCharacters(in: .whitespacesAndNewlines) + "..."
    }
}

private extension TodayExecutionViewState {
    static func commandMappings(
        for actions: [TodayInlineAction],
        explanations: [RecommendationExplanation],
        recoveryOptionID: String?
    ) -> [TodayCommandMappingState] {
        let validator = AmbitionsCommandValidator()
        var mapped: [TodayCommandMappingState] = []
        var seen = Set<String>()
        for action in actions {
            guard let command = command(for: action, explanations: explanations, recoveryOptionID: recoveryOptionID) else {
                continue
            }
            guard seen.insert("\(action.id).\(command.kind.rawValue)").inserted else { continue }
            mapped.append(
                TodayCommandMappingState(
                    id: "today2.command.\(action.id).\(command.kind.rawValue)",
                    actionKind: action.kind,
                    commandKind: command.kind,
                    destination: command.target.destination,
                    validationState: validator.validate(command),
                    explanationID: command.target.explanationID ?? command.payload.explanationID,
                    recoveryOptionID: recoveryOptionID
                )
            )
        }
        return mapped
    }

    static func command(
        for action: TodayInlineAction,
        explanations: [RecommendationExplanation],
        recoveryOptionID: String?
    ) -> AmbitionsCommand? {
        let explanationID = explanations.first?.id
        let destination: AmbitionsCommandDestination?
        let kind: AmbitionsCommandKind
        switch action.kind {
        case .openPlan, .protectLater:
            kind = .openDestination
            destination = .plan
        case .quickLog:
            kind = .openDestination
            destination = .capture
        case .openDetail:
            kind = .openDestination
            destination = .goalDetail
        case .askWhyThisMatters:
            kind = .askWhy
            destination = nil
        case .startFocus:
            kind = .startFocus
            destination = nil
        case .complete:
            kind = .completeAction
            destination = nil
        case .defer, .reschedule:
            kind = .delayAction
            destination = nil
        case .split:
            kind = .splitAction
            destination = nil
        case .askForHelp:
            kind = .recoverAction
            destination = nil
        default:
            return nil
        }
        return AmbitionsCommand(
            id: "command.today2.\(action.id).\(kind.rawValue)",
            kind: kind,
            source: .today,
            target: AmbitionsCommandTarget(
                goalID: action.target.goalID,
                stepID: action.target.stepID,
                recommendationID: recoveryOptionID,
                explanationID: explanationID,
                destination: destination
            ),
            payload: AmbitionsCommandPayload(
                title: action.title,
                priorityHints: AmbitionsCommandPriorityHints(recoveryState: action.kind == .protectLater || action.kind == .askForHelp ? .needsRecovery : nil),
                explanationID: explanationID,
                metadata: recoveryOptionID.map { ["recoveryOptionID": $0] } ?? [:]
            ),
            createdAt: DomainTimestamp.string(from: Date(timeIntervalSince1970: 0)),
            sourceSurface: "today"
        )
    }
}

private extension NowContextLens {
    var displayTitle: String {
        switch self {
        case .work: "Work"
        case .personal: "Personal"
        case .freeTime: "Free Time"
        case .admin: "Admin"
        case .creative: "Creative"
        case .recovery: "Recovery"
        case .deepFocus: "Deep Focus"
        case .all: "All"
        }
    }

    var icon: String {
        switch self {
        case .work: "briefcase.fill"
        case .personal: "person.fill"
        case .freeTime: "sun.max.fill"
        case .admin: "tray.full.fill"
        case .creative: "paintbrush.pointed.fill"
        case .recovery: "heart.fill"
        case .deepFocus: "scope"
        case .all: "square.grid.2x2.fill"
        }
    }
}

private extension NowContextLensSource {
    var displayTitle: String {
        switch self {
        case .manual: "manual choice"
        case .schedule: "schedule"
        case .calendar: "calendar-derived context"
        case .domain: "domain fit"
        case .deadline: "deadline pressure"
        case .recovery: "recovery state"
        case .systemDefault: "local default"
        }
    }
}
