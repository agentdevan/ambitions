import AmbitionsDesignSystem
import Foundation

extension TodayExecutionProjector {
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
            receiptLabel: "Start here review history",
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
                ? "Start here keeps the review history visible before anything changes."
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
            return "Needs context"
        case .offline:
            return "Recovery stays local"
        case .localOnly:
            return "Local source on this device"
        case .blocked:
            return "Blocked or waiting"
        case .unavailable:
            return input.mode == .empty ? "User choice" : "Needs context"
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
            return "Review path blocked safely"
        case .denied, .unavailable:
            return "Review path unavailable"
        case .partial:
            return input.nowState.blockersWaiting.waitingCount > 0 ? "Review path waits on review" : "Review path needs proof"
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

}
