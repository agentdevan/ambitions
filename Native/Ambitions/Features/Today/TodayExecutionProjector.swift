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

private extension TodayExecutionProjector {
    func dayRailState(
        _ input: TodayExecutionProjectionInput,
        hero: TodayExecutionHeroState,
        contract: ContractEntries,
        todayTime: TodayTimeLayerState,
        friction: TodayExecutionPanelState
    ) -> AmbitionsDayRailViewState {
        let privacy = DayRailPrivacyProjectionState(classification: input.nowState.privacy)
        let sourceLabels = dayRailSourceLabels(input, source: todayTime.calendarSourceLabel)
        let publicSource = sourceLabels.first ?? DayRailSourceLabelState(id: "source.time", label: "Based on your Time", source: .standard)
        let heroAction = hero.primaryAction
        let detailTarget = DayRailDetailTargetState.from(heroAction)
        let duration = DayRailDurationState.placeholder(for: heroAction)
        let heroTitle = privacy.visibleTitle(hero.title)
        let heroSubtitle = privacy.visibleSubtitle(hero.subtitle)
        let sourceSummary = privacy.sourceSummary(from: sourceLabels)
        let heroBecause = privacy.visibleSubtitle(hero.explanation?.summary ?? contract.why.subtitle)
        let sourceFreshness = sourceFreshness(
            input,
            hero: hero,
            sourceLabels: sourceLabels,
            sourceSummary: sourceSummary
        )
        let sourceRecordLabel = sourceRecordLabel(for: sourceLabels, sourceFreshness: sourceFreshness)
        let replayTraceLabel = replayTraceLabel(for: input, sourceFreshness: sourceFreshness)
        let heroStep = input.mode == .empty ? nil : DayRailHeroStepState(
            id: "day-rail.hero.\(heroAction.id)",
            title: heroTitle,
            subtitle: heroSubtitle,
            duration: duration,
            fitLabel: fitLabel(for: hero),
            whySummary: heroBecause,
            sourceQualityLabel: sourceQualityLabel(
                input,
                sourceFreshness: sourceFreshness,
                sourceSummary: sourceSummary
            ),
            becauseLine: "Because \(heroBecause)",
            receiptLabel: "Start Here receipt seam",
            proofLabel: "No change has been made yet.",
            sourceRecordLabel: sourceRecordLabel,
            replayTraceLabel: replayTraceLabel,
            replayInspectionLabel: DayRailHeroStepState.replayInspectionLabel(
                sourceRecordLabel: sourceRecordLabel,
                replayTraceLabel: replayTraceLabel
            ),
            contextEdge: StartHereContextEdgeState(
                title: "Context edge",
                summary: privacy.visibleSubtitle("\(lensSummary(input.nowState)) \(todayTime.openWindowLabel)"),
                sourceLabel: sourceSummary
            ),
            timeFitProof: StartHereTimeFitProofState(
                title: "Time fit",
                summary: duration.label,
                detail: "\(fitLabel(for: hero)) from the current Time shape."
            ),
            goalThread: StartHereGoalThreadState(
                title: "Goal thread",
                summary: DayRailHeroStepState.goalThreadSummary(for: detailTarget),
                detail: DayRailHeroStepState.goalThreadDetail(for: detailTarget)
            ),
            receiptItem: DayRailHeroStepState.receiptItem(
                id: "start-here.\(heroAction.id)",
                title: heroTitle,
                sourceLabel: sourceSummary,
                freshness: sourceFreshness,
                privacyLabel: privacy.isSensitiveProjection ? "Private details hidden" : "Private by default",
                becauseLine: heroBecause
            ),
            primaryAction: heroAction,
            secondaryAction: hero.secondaryActions.first ?? DayRailStepDetailState.placeholderActions(target: heroAction.target).first,
            detailTarget: detailTarget,
            sourceLabels: sourceLabels
        )

        let rows = DayRailRowState.rows(
            from: todayTime.items,
            fallbackHero: heroStep,
            privacy: privacy,
            source: publicSource
        )
        let closureSlot = DayRailClosureSlotState(
            title: contract.closure.title,
            subtitle: contract.closure.subtitle,
            reservedForActionClosureSheet: true
        )
        let proofSlot = DayRailProofSlotState(
            title: "Proof saved",
            subtitle: input.nowState.evidenceSummaries.isEmpty
                ? "Start Here keeps the receipt seam visible before anything changes."
                : "\(input.nowState.evidenceSummaries.count) local evidence item\(input.nowState.evidenceSummaries.count == 1 ? "" : "s") counted.",
            noSilentChanges: true,
            reservedForReceiptPeek: false
        )
        let mode = dayRailMode(input, hero: hero, friction: friction)

        return AmbitionsDayRailViewState(
            id: "day-rail.\(input.nowState.id)",
            mode: mode,
            dateTitle: "Today",
            contextSummary: privacy.visibleSubtitle("\(lensSummary(input.nowState)) \(todayTime.openWindowLabel)"),
            heroStep: heroStep,
            rows: rows,
            primaryAction: input.mode == .empty ? nil : heroAction,
            rowTapDetailTargetPlaceholder: input.mode == .empty ? nil : detailTarget,
            durationSource: duration.source,
            contextLabels: sourceLabels,
            privacyProjection: privacy,
            continuity: DayRailContinuityState.make(
                heroStep: heroStep,
                rows: rows,
                closureSlot: closureSlot,
                proofSlot: proofSlot,
                mode: mode,
                pressureLabel: friction.value
            ),
            closureSlot: closureSlot,
            proofSlot: proofSlot
        )
    }

    func dayRailMode(_ input: TodayExecutionProjectionInput, hero: TodayExecutionHeroState, friction: TodayExecutionPanelState) -> DayRailMode {
        if input.mode == .empty { return .empty }
        if hero.kind == .recovery { return .recovery }
        if input.nowState.todayPosture == .noTime { return .noSchedule }
        if input.nowState.todayPosture == .overloaded || friction.semanticState == .caution { return .overloaded }
        if input.nowState.todayPosture == .tight { return .protected }
        return .normal
    }

    func dayRailSourceLabels(_ input: TodayExecutionProjectionInput, source: String) -> [DayRailSourceLabelState] {
        var labels = [
            DayRailSourceLabelState(id: "source.time", label: source, source: input.nowState.privacy),
            DayRailSourceLabelState(id: "source.lens", label: input.nowState.activeContextLens.displayTitle, source: .standard),
        ]
        if input.realitySnapshot?.calendarContext?.hasCalendarReadAccess == true {
            labels.append(DayRailSourceLabelState(id: "source.calendar", label: "Calendar-aware", source: .calendarDerived))
        }
        if input.nowState.localOnly {
            labels.append(DayRailSourceLabelState(id: "source.local", label: "Stored on this device", source: .standard))
        }
        return Array(labels.prefix(3))
    }

    func sourceFreshness(
        _ input: TodayExecutionProjectionInput,
        hero: TodayExecutionHeroState,
        sourceLabels: [DayRailSourceLabelState],
        sourceSummary: String
    ) -> SourceFreshnessState {
        if input.mode == .empty {
            return .unavailable
        }
        if input.nowState.privacy == .privateUserText || input.nowState.privacy == .sensitive {
            return .localOnly
        }
        if sourceLabels.isEmpty {
            return .unavailable
        }
        if input.nowState.blockersWaiting.blockedCount > 0 {
            return .blocked
        }
        if input.nowState.blockersWaiting.waitingCount > 0 {
            return .partial
        }
        if input.nowState.todayPosture == .lowData || input.nowState.nextActionConfidence == .low {
            return .partial
        }
        if input.nowState.recoveryState == .recovering || hero.kind == .recovery {
            return .offline
        }
        if input.realitySnapshot?.calendarContext?.hasCalendarReadAccess == false && input.nowState.localOnly == false {
            return .denied
        }
        if input.nowState.localOnly {
            return .localOnly
        }
        return sourceSummary.isEmpty ? .unavailable : .fresh
    }

    func sourceQualityLabel(
        _ input: TodayExecutionProjectionInput,
        sourceFreshness: SourceFreshnessState,
        sourceSummary: String
    ) -> String {
        if input.nowState.privacy == .privateUserText || input.nowState.privacy == .sensitive {
            return "Private source"
        }
        switch sourceFreshness {
        case .fresh:
            if input.realitySnapshot?.calendarContext?.hasCalendarReadAccess == true {
                return "Time source with calendar awareness"
            }
            return "Source-backed by current Time"
        case .partial:
            return input.nowState.blockersWaiting.waitingCount > 0 ? "Waiting on source" : "Low confidence"
        case .stale:
            return "Source needs review"
        case .denied:
            return "Source unavailable"
        case .offline:
            return "Recovery stays local"
        case .localOnly:
            return "Local source on this device"
        case .blocked:
            return "Blocked or waiting"
        case .unavailable:
            return input.mode == .empty ? "Manual fallback" : "Source unavailable"
        }
    }

    func sourceRecordLabel(
        for sourceLabels: [DayRailSourceLabelState],
        sourceFreshness: SourceFreshnessState
    ) -> String {
        if sourceLabels.isEmpty {
            return sourceFreshness == .unavailable ? "Source record unavailable" : "Source record missing"
        }
        if sourceFreshness == .blocked || sourceFreshness == .partial {
            return "Source record needs review"
        }
        return "Source record stays local"
    }

    func replayTraceLabel(
        for input: TodayExecutionProjectionInput,
        sourceFreshness: SourceFreshnessState
    ) -> String {
        switch sourceFreshness {
        case .blocked:
            return "Replay trace blocked safely"
        case .denied, .unavailable:
            return "Replay trace unavailable"
        case .partial:
            return input.nowState.blockersWaiting.waitingCount > 0 ? "Replay trace waits on review" : "Replay trace needs proof"
        case .offline, .localOnly, .fresh, .stale:
            return DayRailHeroStepState.replayTraceLabel(localOnly: input.nowState.localOnly)
        }
    }

    func fitLabel(for hero: TodayExecutionHeroState) -> String {
        switch hero.semanticState {
        case .focus, .success:
            return "Strong fit"
        case .confidenceMedium, .protected:
            return "Good fit"
        case .recovery, .review, .waiting:
            return "Needs review"
        default:
            return "Light fit"
        }
    }

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
                secondaryActions: [openTimeAction()],
                explanation: TodayExplanationAffordanceState(id: "today2.empty.why", title: "Why?", summary: "There is not enough local goal or capture data to choose a recommended Time yet.", explanationID: nil, state: .default),
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
                title: (option?.title ?? "Recover with one step").shortened(maxLength: 36),
                subtitle: (input.resilienceAssessment.smallestUsefulNextStep ?? option?.summary ?? "Choose the smaller safe step.").todayShortSentence,
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
            accessibilityLabel: "Today recommended step. \(best?.title ?? input.legacyHero.truth.nowTitle)",
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
            subtitle: "Completed, Still Counts, Rescheduled, Waiting, or Needs Recovery can be recorded here.",
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
        var items: [TodayTimeLayerItemState] = input.legacySupport.fixedCommitments.items.prefix(3).map {
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

    func timePanel(_ input: TodayExecutionProjectionInput) -> TodayExecutionPanelState {
        let summary = input.realitySnapshot?.availability.summary ?? input.nowState.schedulePressure.summary
        let calendarLine = input.realitySnapshot?.calendarContext?.hasCalendarReadAccess == true
            ? "Calendar-aware and local."
            : "Time works without calendar access."
        return TodayExecutionPanelState(
            id: "today2.time",
            kind: .time,
            title: timeTitle(input.nowState.schedulePressure.level),
            subtitle: "\(summary.todayShortSentence) \(calendarLine)",
            value: pressureLabel(input.nowState.schedulePressure.level),
            semanticState: .calendarDerived,
            action: openTimeAction(),
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
        return "Based on your Time"
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
            TodayExecutionPanelState(id: "today2.protected.\($0.id)", kind: .recovery, title: "Kept in view", subtitle: $0.summary.todayShortSentence, value: $0.title.shortened(maxLength: 24), semanticState: .protected, action: openTimeAction(), explanation: nil)
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
                    action: openTimeAction(),
                    explanation: nil
                ),
            ]
        }
        let passive = input.resilienceAssessment.passiveWorkDeferredCalmly.prefix(1).map {
            TodayExecutionPanelState(id: "today2.passive.\($0.id)", kind: .priority, title: "Can wait", subtitle: $0.summary.todayShortSentence, value: $0.title.shortened(maxLength: 24), semanticState: .trust, action: nil, explanation: nil)
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
            value: "No false certainty",
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
            return TodayInlineAction(kind: .startStepSession, title: "Start now", systemImage: "scope", state: .selected, target: target)
        case .completeAction:
            return TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: target)
        case .openGoal:
            return TodayInlineAction(kind: .openDetail, title: "Open Goal", systemImage: "arrow.right.circle", state: .default, target: target)
        case .openTime, .schedule:
            return openTimeAction()
        case .capture, .routeCommitment:
            return TodayInlineAction(kind: .quickLog, title: "Open Capture", systemImage: "tray.and.arrow.down", state: .selected, target: target)
        case .recover:
            return TodayInlineAction(kind: .protectLater, title: "Recover", systemImage: "arrow.uturn.backward.circle", state: .selected, target: target)
        case .explain:
            return TodayInlineAction(kind: .askWhyThisMatters, title: "Why this?", systemImage: "questionmark.circle", state: .default, target: target)
        case .wait:
            return TodayInlineAction(kind: .openTime, title: "View waiting", systemImage: "hourglass", state: .default, target: target)
        case .review, .none:
            return nil
        }
    }

    func action(for option: ExecutionRecoveryOption?, fallback: TodayInlineAction) -> TodayInlineAction {
        guard let option else { return fallback }
        let target = TodayActionTarget(goalID: option.relatedGoalID, draftID: nil)
        switch option.strategy {
        case .openTime, .protectDeadlineWork, .rescheduleLater, .acceptSlip:
            return TodayInlineAction(kind: .openTime, title: "Open Time", systemImage: "calendar", state: .selected, target: target)
        case .openCapture, .clarifyNextStep, .askForDecision:
            return TodayInlineAction(kind: .quickLog, title: "Open Capture", systemImage: "tray.and.arrow.down", state: .selected, target: target)
        case .openGoal, .reduceScope:
            return TodayInlineAction(kind: .openDetail, title: "Open Goal", systemImage: "arrow.right.circle", state: .selected, target: target)
        case .splitIntoSmallerStep, .doSmallestNextStep:
            return TodayInlineAction(kind: .split, title: "Smallest step", systemImage: "scissors", state: .selected, target: target)
        case .deferPassiveWork, .keepAsSomeday:
            return TodayInlineAction(kind: .defer, title: "Let it wait", systemImage: "clock", state: .default, target: target)
        case .moveToWaiting:
            return TodayInlineAction(kind: .openTime, title: "Keep waiting", systemImage: "hourglass", state: .default, target: target)
        }
    }

    func secondaryRecoveryActions(_ input: TodayExecutionProjectionInput, primary: TodayInlineAction) -> [TodayInlineAction] {
        let optionActions = input.resilienceAssessment.recoveryOptions.map { action(for: $0, fallback: primary) }
        return unique(optionActions + [openTimeAction(), TodayInlineAction(kind: .askWhyThisMatters, title: "Why recover?", systemImage: "questionmark.circle", state: .default, target: primary.target)], excluding: primary)
    }

    func secondaryStableActions(_ input: TodayExecutionProjectionInput, primary: TodayInlineAction) -> [TodayInlineAction] {
        unique([
            TodayInlineAction(kind: .askWhyThisMatters, title: "Why this?", systemImage: "questionmark.circle", state: .default, target: primary.target),
            openTimeAction(),
            input.legacySupport.quickCaptureAction,
        ].compactMap { $0 }, excluding: primary)
    }

    func unique(_ actions: [TodayInlineAction], excluding primary: TodayInlineAction) -> [TodayInlineAction] {
        var seen = Set([primary.id])
        return actions.filter { seen.insert($0.id).inserted }.prefix(3).map { $0 }
    }

    func openTimeAction(title: String = "Open Time") -> TodayInlineAction {
        TodayInlineAction(kind: .openTime, title: title, systemImage: "calendar", state: .default, target: TodayActionTarget())
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

    func timeTitle(_ level: NowPressureLevel) -> String {
        switch level {
        case .none, .low:
            "Time has room"
        case .moderate:
            "Time is getting tight"
        case .elevated, .high, .critical:
            "Time needs attention"
        }
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
