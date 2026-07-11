import AmbitionsDesignSystem
import AmbitionsTimeFoundation
import Foundation

extension TodayExecutionProjector {
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
                TodayInlineAction(kind: .openTime, title: "Open Time", systemImage: "calendar.badge.clock", state: .selected, target: TodayActionTarget(goalID: $0))
            } ?? hero.primaryAction,
            explanation: explanation(input, preferred: input.nowState.nextActionExplanationID, fallbackTitle: "Why this?")
        )
        let best = TodayContractEntryState(
            id: "today2.contract.best-next",
            kind: .recommendedStep,
            title: "Recommended step",
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
            title: "Close the loop",
            subtitle: "Completed, Still counts, Rescheduled, Waiting, or Needs Recovery can be recorded here.",
            value: "Needs a quick check",
            semanticState: .review,
            action: TodayInlineAction(kind: .closeActionClosure, title: "Close the loop", systemImage: "checkmark.bubble", state: .default, target: hero.primaryAction.target),
            explanation: TodayExplanationAffordanceState(
                id: "today2.closure.checkin",
                title: "Needs a quick check",
                summary: "Past scheduled steps ask for closure instead of becoming stale or punitive.",
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
            subtitle: (parkedTitle.map { "\($0) can wait." } ?? "Nothing extra is being pulled into today.").todayShortSentence,
            value: parkedTitle == nil ? "Nothing heavy" : "Parked",
            semanticState: .trust,
            action: nil,
            explanation: nil
        )
    }

    func recoveryFallbackEntry(_ input: TodayExecutionProjectionInput, hero: TodayExecutionHeroState) -> TodayContractEntryState {
        let option = input.resilienceAssessment.recommendedRecoveryOption
        let action = option.map { self.action(for: $0, fallback: hero.primaryAction) } ?? openTimeAction(title: "Make smaller")
        return TodayContractEntryState(
            id: "today2.contract.fallback",
            kind: .recoveryFallback,
            title: "Fallback",
            subtitle: (input.resilienceAssessment.smallestUsefulNextStep ?? option?.summary ?? "Make the step smaller or protect it in Time.").todayShortSentence,
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
        return TodayInlineAction(kind: .openTime, title: "Save the day", systemImage: "arrow.uturn.backward.circle", state: .default, target: TodayActionTarget())
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
                action: openTimeAction(),
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
                action: openTimeAction(title: "View all"),
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
                action: openTimeAction(),
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

    func todayTimeLayer(_ input: TodayExecutionProjectionInput, hero: TodayExecutionHeroState) -> TodayTimeLayerState {
        var items: [TodayTimeLayerItemState] = (input.realitySnapshot?.scheduledBlocks ?? []).prefix(3).map { block in
            TodayTimeLayerItemState(
                id: "today2.time.life-calendar.\(block.id)",
                title: block.title.shortened(maxLength: 48),
                subtitle: "Saved locally in Life Calendar.",
                timingLabel: Self.timeLabel(block.start),
                sourceLabel: "Based on your Time",
                semanticState: .focus,
                action: TodayInlineAction(
                    kind: .openTime,
                    title: "Open Time",
                    systemImage: "calendar.badge.clock",
                    state: .selected,
                    target: TodayActionTarget(goalID: block.relatedGoalID, stepID: block.relatedPlanID)
                )
            )
        }

        if items.count < 3 {
            let fixedItems = input.legacySupport.fixedCommitments.items.prefix(3 - items.count).map {
            TodayTimeLayerItemState(
                id: "today2.time.fixed.\($0.id)",
                title: $0.title.shortened(maxLength: 48),
                subtitle: $0.subtitle.todayShortSentence,
                timingLabel: $0.label,
                sourceLabel: calendarSourceLabel(input),
                semanticState: .protected,
                action: $0.action ?? hero.primaryAction
            )
            }
            items.append(contentsOf: fixedItems)
        }

        if items.count < 3 {
            let flexibleItems = input.legacySupport.flexibleRoom.items.prefix(3 - items.count).map {
                TodayTimeLayerItemState(
                    id: "today2.time.flexible.\($0.id)",
                    title: $0.title.shortened(maxLength: 48),
                    subtitle: $0.subtitle.todayShortSentence,
                    timingLabel: $0.label,
                    sourceLabel: "Based on your Time",
                    semanticState: .trust,
                    action: $0.action
                )
            }
            items.append(contentsOf: flexibleItems)
        }

        if items.isEmpty, input.mode != .empty {
            items.append(
                TodayTimeLayerItemState(
                    id: "today2.time.best-next",
                    title: hero.smallestUsefulNextStep?.shortened(maxLength: 48) ?? hero.title,
                    subtitle: hero.subtitle.todayShortSentence,
                    timingLabel: "Now",
                    sourceLabel: "Based on your Time",
                    semanticState: hero.semanticState,
                    action: hero.primaryAction
                )
            )
        }

        let compactTimeline = items.isEmpty
            ? "No fixed Time yet"
            : items.map(\.timingLabel).prefix(3).joined(separator: " / ")
        let openWindow = input.realitySnapshot?.openWindowCandidates.first?.fitSummary.todayShortSentence
            ?? input.legacySupport.timeAperture.bestUseTitle
        let source = calendarSourceLabel(input)
        let moveAction = TodayInlineAction(
            kind: .openTime,
            title: "Adjust Time",
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
        return TodayTimeLayerState(
            title: "Today schedule",
            subtitle: items.isEmpty ? "Start with one real step." : "The planned day stays visible.",
            compactTimelineLabel: compactTimeline,
            openWindowLabel: openWindow,
            calendarSourceLabel: source,
            items: items,
            moveAction: moveAction,
            parkAction: parkAction,
            markDoneAction: markDoneAction,
            accessibilityLabel: "Today schedule",
            accessibilityValue: items.isEmpty
                ? "No fixed Time yet. \(source). \(openWindow)."
                : "\(items.count) planned item\(items.count == 1 ? "" : "s"). \(compactTimeline). \(source). \(openWindow).",
            accessibilityHint: "Shows the planned day and visible buttons to start, adjust, park, or mark done without requesting calendar access here."
        )
    }

    private static func timeLabel(_ date: Date) -> String {
        RuntimeTickPolicy.system.shortTimeLabel(for: date)
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
                    kind: .openTime,
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
            subtitle: total == 0 ? "No loose step is pulling on Today." : "Loose steps stay contained.",
            value: total == 0 ? "None today" : "\(total) open",
            previews: Array(previews),
            emptyMessage: "No One-Step Goals on Today",
            accessibilityLabel: "One-Step Goals",
            accessibilityValue: total == 0 ? "No loose step is pulling on Today." : "\(total) open loose step\(total == 1 ? "" : "s").",
            accessibilityHint: "One-Step Goals stay intentionally small. Steps remain inside Goals, Paths, or Time."
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
        case .waiting, .lowData, .noTime:
            return .fragile
        }
    }

    func dayStateSummary(_ input: TodayExecutionProjectionInput) -> String {
        switch dayState(input) {
        case .clear:
            return "The day has room for one real step."
        case .steady:
            return "One step is clear enough to keep in view."
        case .tight:
            return "Keep today narrow."
        case .fragile:
            return "Use the fallback before adding pressure."
        case .atRisk:
            return "Reduce pressure before adding new work."
        case .recovered:
            return "Recovery is already shaping the day."
        case .protected:
            return "The important step gets the first claim."
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
                    action: TodayInlineAction(kind: .openTime, title: "View all", systemImage: "square.grid.2x2", state: .default, target: TodayActionTarget()),
                    explanation: nil
                )
            )
        }
        panels.append(capturePanel(input))
        panels.append(timePanel(input))
        if panels.count < 2 {
            panels.append(priorityPanel(input))
        }
        return panels
    }

}
