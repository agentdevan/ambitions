import AmbitionsDesignSystem
import Foundation

extension TodayExecutionViewState {
    // Compatibility seam. Keep until F15 legacy identifier migration verifies route/test/persistence safety.
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
            title: "Recommended step",
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
            subtitle: support.recoveryBloom?.subtitle.todayShortSentence ?? "Make the step smaller before making the day louder.",
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
            title: "Close the loop",
            subtitle: "One step can become Completed, Still Counts, Rescheduled, Waiting, or Needs Recovery.",
            value: "Needs a quick check",
            semanticState: .review,
            action: TodayInlineAction(kind: .closeActionClosure, title: "Close the loop", systemImage: "checkmark.bubble", state: .default, target: primary.target),
            explanation: TodayExplanationAffordanceState(
                id: "today2.closure.checkin",
                title: "Needs a quick check",
                summary: "Past scheduled steps ask for closure instead of becoming stale or punitive.",
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
            subtitle: planItems.isEmpty ? "Start with one real step." : "The planned day stays visible.",
            compactTimelineLabel: timeline,
            openWindowLabel: support.timeAperture.bestUseTitle,
            calendarSourceLabel: "Based on your plan",
            items: Array(planItems),
            moveAction: TodayInlineAction(kind: .openPlan, title: "Adjust plan", systemImage: "arrow.right.arrow.left", state: .default, target: primary.target),
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
        let dayRail = AmbitionsDayRailViewState.compatibility(
            mode: mode,
            hero: executionHero,
            todayPlanLayer: todayPlanLayer,
            closure: closure,
            sourceLabel: "Based on your plan"
        )
        return TodayExecutionViewState(
            dayRail: dayRail,
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

extension TodayExecutionViewState {
    func replacingDayRail(_ dayRail: AmbitionsDayRailViewState) -> TodayExecutionViewState {
        TodayExecutionViewState(
            dayRail: dayRail,
            activeLens: activeLens,
            availableLenses: availableLenses,
            lensSummary: lensSummary,
            dayState: dayState,
            dayStateSummary: dayStateSummary,
            protectedMustDo: protectedMustDo,
            bestNextMove: bestNextMove,
            notToday: notToday,
            recoveryFallback: recoveryFallback,
            whyThisMatters: whyThisMatters,
            actionClosureEntry: actionClosureEntry,
            saveTheDayAction: saveTheDayAction,
            frictionSignal: frictionSignal,
            hero: hero,
            todayPlanLayer: todayPlanLayer,
            oneStepGoalsPanel: oneStepGoalsPanel,
            supportingPanels: supportingPanels,
            deeperSections: deeperSections,
            commandMappings: commandMappings,
            planRequestsCalendarPermission: planRequestsCalendarPermission,
            emptyGuidance: emptyGuidance
        )
    }
}

extension TodayExecutionViewState {
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
        case .startStepSession:
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
