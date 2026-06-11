import AmbitionsDesignSystem
import Foundation

enum PreviewTodayScenarios {
    static let stable = makeScenario(
        posture: .stable,
        title: "Draft the talk outline",
        supporting: "The clearest next step is already visible and small enough to finish.",
        nowSubtitle: "Submit my conference talk proposal",
        nextTitle: "Record one rough vocal pass",
        nextSubtitle: "Flexible learning work if the main block lands early.",
        primaryAction: TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
        supportingActions: [
            TodayInlineAction(kind: .defer, title: "Defer", systemImage: "clock.arrow.circlepath", state: .default, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
            TodayInlineAction(kind: .split, title: "Split", systemImage: "scissors", state: .selected, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
            TodayInlineAction(kind: .askWhyThisMatters, title: "Why this matters", systemImage: "questionmark.circle", state: .default, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
            TodayInlineAction(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .default, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1"))
        ],
        reentry: nil,
        celebrationLine: "Momentum is already visible today."
    )

    static let tight = makeScenario(
        posture: .tight,
        title: "Protect the outline block",
        supporting: "The day is getting tight, so the safest choice is to preserve the next meaningful block.",
        nowSubtitle: "Submit my conference talk proposal",
        nextTitle: "Record one rough vocal pass",
        nextSubtitle: "Keep this flexible unless the main block slips.",
        primaryAction: TodayInlineAction(kind: .protectLater, title: "Adjust plan", systemImage: "calendar.badge.clock", state: .selected, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
        supportingActions: [
            TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
            TodayInlineAction(kind: .defer, title: "Defer", systemImage: "clock.arrow.circlepath", state: .default, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
            TodayInlineAction(kind: .reschedule, title: "Reschedule", systemImage: "forward.fill", state: .warning, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1"))
        ],
        reentry: nil,
        celebrationLine: nil
    )

    static let recovery = makeScenario(
        posture: .recovering,
        title: "Split the next step",
        supporting: "A smaller version is the safest way back into the day.",
        nowSubtitle: "Ship the native create goal flow",
        nextTitle: "Open Time",
        nextSubtitle: "If the day still feels too heavy, protect the block there.",
        primaryAction: TodayInlineAction(kind: .split, title: "Split", systemImage: "scissors", state: .selected, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2")),
        supportingActions: [
            TodayInlineAction(kind: .protectLater, title: "Adjust plan", systemImage: "calendar.badge.clock", state: .default, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2")),
            TodayInlineAction(kind: .askForHelp, title: "Ask for help", systemImage: "lifepreserver", state: .default, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2"))
        ],
        reentry: TodayReentryState(
            eyebrow: "Re-entry",
            title: "Recovery landed in Today",
            detail: "This pass is centered on one believable step instead of the whole backlog.",
            state: .selected
        ),
        celebrationLine: nil
    )

    static let drifted = makeScenario(
        posture: .drifted,
        title: "Return through the next believable step",
        supporting: "The earlier plan slipped, so Today is narrowing the path back to one calmer step.",
        nowSubtitle: "Ship the native create goal flow",
        nextTitle: "Adjust plan",
        nextSubtitle: "If the step still feels too large, move the shaping into Time with the block still inspectable.",
        primaryAction: TodayInlineAction(kind: .split, title: "Recover calmly", systemImage: "arrow.uturn.left.circle", state: .selected, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2")),
        supportingActions: [
            TodayInlineAction(kind: .protectLater, title: "Adjust plan", systemImage: "calendar.badge.clock", state: .default, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2")),
            TodayInlineAction(kind: .reschedule, title: "Reschedule", systemImage: "forward.fill", state: .warning, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2"))
        ],
        reentry: nil,
        celebrationLine: nil
    )

    static let overloaded = makeScenario(
        posture: .overloaded,
        title: "Lighten the day first",
        supporting: "There are too many active asks right now, so pressure needs to come down before new effort goes up.",
        nowSubtitle: "Four active goals are pulling on the same day.",
        nextTitle: "Adjust plan",
        nextSubtitle: "Use Time to protect one block instead of trying to do all of it now.",
        primaryAction: TodayInlineAction(kind: .protectLater, title: "Adjust plan", systemImage: "calendar.badge.clock", state: .selected, target: TodayActionTarget()),
        supportingActions: [
            TodayInlineAction(kind: .reschedule, title: "Reschedule", systemImage: "forward.fill", state: .warning, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
            TodayInlineAction(kind: .split, title: "Split", systemImage: "scissors", state: .selected, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1"))
        ],
        reentry: nil,
        celebrationLine: nil
    )

    static let lowData = makeScenario(
        posture: .lowData,
        title: "Clarify the next step first",
        supporting: "The day has room, but stronger timing claims would be fake until one missing answer lands.",
        nowSubtitle: "A draft is waiting on one clarification.",
        nextTitle: "Open detail",
        nextSubtitle: "Answer the smallest missing question before widening the day.",
        primaryAction: TodayInlineAction(kind: .openDetail, title: "Answer", systemImage: "arrow.right.circle", state: .selected, target: TodayActionTarget(draftID: "draft-1")),
        supportingActions: [],
        reentry: nil,
        celebrationLine: nil
    )

    static let noPlan = makeScenario(
        posture: .noPlan,
        title: "Build today from one real step",
        supporting: "Today stays calm until a real goal or draft exists.",
        nowSubtitle: "Nothing here is faking urgency.",
        nextTitle: nil,
        nextSubtitle: nil,
        primaryAction: TodayInlineAction(kind: .openTime, title: "Build today", systemImage: "calendar.badge.plus", state: .selected, target: TodayActionTarget()),
        supportingActions: [],
        reentry: nil,
        celebrationLine: nil,
        mode: .empty
    )

    static let empty = noPlan
    static let privateRail = makePrivateRailScenario(from: stable)
    static let unavailableRail = noPlan
    static let heroLoading = makeHeroActionScenario(
        from: stable,
        action: TodayInlineAction(
            kind: .openDetail,
            title: "Opening step",
            systemImage: "arrow.right.circle",
            state: .loading,
            target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")
        )
    )
    static let heroDisabled = makeHeroActionScenario(
        from: lowData,
        action: TodayInlineAction(
            kind: .openDetail,
            title: "Needs review",
            systemImage: "exclamationmark.triangle",
            state: .disabled,
            target: TodayActionTarget(draftID: "draft-1")
        )
    )
    static let startHereReady = makeHeroActionScenario(
        from: stable,
        action: TodayInlineAction(
            kind: .startStepSession,
            title: "Start now",
            systemImage: "scope",
            state: .selected,
            target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")
        )
    )
    static let sourceStale = makeSourceStateScenario(
        from: stable,
        sourceQualityLabel: "Source needs review",
        freshness: .stale,
        sourceLabels: [
            DayRailSourceLabelState(id: "source.stale.primary", label: "Older evidence", source: .standard),
            DayRailSourceLabelState(id: "source.stale.secondary", label: "Review before reuse", source: .syncMetadata)
        ],
        sourceRecordLabel: "Source record needs review",
        replayTraceLabel: "Replay trace needs proof"
    )
    static let blockedWaiting = makeSourceStateScenario(
        from: recovery,
        sourceQualityLabel: "Blocked or waiting",
        freshness: .blocked,
        sourceLabels: [
            DayRailSourceLabelState(id: "source.blocked.primary", label: "Waiting item", source: .standard)
        ],
        sourceRecordLabel: "Source record needs review",
        replayTraceLabel: "Replay trace blocked safely"
    )
    static let sourceUnavailable = makeSourceStateScenario(
        from: stable,
        sourceQualityLabel: "Source unavailable",
        freshness: .unavailable,
        sourceLabels: [],
        sourceRecordLabel: "Source record unavailable",
        replayTraceLabel: "Replay trace unavailable"
    )
    static let noSchedule = makeModeScenario(
        from: stable,
        mode: .noSchedule,
        pressureLabel: "No schedule connected",
        pressureDetail: "Today is attached to live step data while schedule is not yet shared."
    )
    static let protectedTime = makeModeScenario(
        from: stable,
        mode: .protected,
        pressureLabel: "Protected now",
        pressureDetail: "Today keeps protected blocks explicit before any new step starts."
    )
    static let missedRecoverable = makeSourceStateScenario(
        from: stable,
        sourceQualityLabel: "Recoverable miss",
        freshness: .partial,
        sourceLabels: [DayRailSourceLabelState(id: "source.partial.recoverable", label: "Recoverable gap open", source: .standard)],
        sourceRecordLabel: "Source record stays local",
        replayTraceLabel: "Replay trace stays inspectable"
    )
    static let nextSoon = makeModeScenario(
        from: stable,
        mode: .normal,
        pressureLabel: "Needs review soon",
        pressureDetail: "The next node opens the cleanest follow-on for now."
    )
    static let reflow = makeLongReflowScenario(
        from: stable,
        title: "Review this longer recommendation text so the Today surface can safely reflow at larger content sizes without dropping continuity.",
        subtitle: "When language increases in length, Start here should stay readably attached to the active Reality Meridian node while preserving proof labels.",
        nextTitle: "Draft one concise version of your highest-friction task before the next open block",
        nextSubtitle: "This follow-on remains available and still connected to the same proof seam."
    )
    static let stepDetailStartHere = makeStartHereStepDetail()
    static let stepDetailRow = stable.execution.dayRail.rows.first?.stepDetail(
        privacy: stable.execution.dayRail.privacyProjection,
        contextLabel: stable.execution.dayRail.contextSummary
    )
    static let privateStepDetail = privateRail.execution.dayRail.heroStep?.stepDetail(
        privacy: privateRail.execution.dayRail.privacyProjection,
        contextLabel: privateRail.execution.dayRail.contextSummary
    )
    static let missingDurationStepDetail = makeMissingDurationStepDetail()
    static let stepReplacementSheet: TodayStepReplacementSheetState = {
        guard let hero = stable.execution.dayRail.heroStep else {
            fatalError("Preview stable Today scenario must expose a hero step.")
        }
        return TodayStepReplacementSheetState.make(
            from: hero,
            privacy: stable.execution.dayRail.privacyProjection,
            contextLabel: stable.execution.dayRail.contextSummary,
            recordedAt: "2026-05-01T12:00:00Z"
        )
    }()

    static func named(_ name: String) -> TodayExperience? {
        switch name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "stable":
            stable
        case "tight":
            tight
        case "recovery", "recovering":
            recovery
        case "drifted":
            drifted
        case "overloaded":
            overloaded
        case "lowdata", "low-data", "low_data":
            lowData
        case "noplan", "no-plan", "no_plan":
            noPlan
        case "empty":
            empty
        case "private", "sensitive", "private-rail", "private_rail":
            privateRail
        case "stale", "source-stale", "source_stale":
            sourceStale
        case "blocked", "waiting", "blocked-waiting", "blocked_waiting":
            blockedWaiting
        case "source-unavailable", "source_unavailable":
            sourceUnavailable
        case "start-here-ready", "start_here_ready", "start-now", "start_now":
            startHereReady
        case "noschedule", "no-schedule", "no_schedule", "no-schedule-connected":
            noSchedule
        case "protected":
            protectedTime
        case "missed", "recoverable", "missed-recoverable":
            missedRecoverable
        case "next", "next-soon", "next_soon":
            nextSoon
        case "reflow", "reflowing", "reflow-preview":
            reflow
        case "unavailable", "empty-rail", "empty_rail":
            unavailableRail
        default:
            nil
        }
    }

    private static func makePrivateRailScenario(from experience: TodayExperience) -> TodayExperience {
        let privacy = DayRailPrivacyProjectionState(classification: .privateUserText)
        let baseRail = experience.execution.dayRail
        let privateHero = baseRail.heroStep.map { hero in
            DayRailHeroStepState(
                id: "\(hero.id).private",
                title: privacy.visibleTitle(hero.title),
                subtitle: privacy.visibleSubtitle(hero.subtitle),
                duration: hero.duration,
                fitLabel: hero.fitLabel,
                whySummary: privacy.visibleSubtitle(hero.whySummary),
                sourceQualityLabel: "Private source",
                becauseLine: privacy.visibleSubtitle(hero.becauseLine),
                contextEdge: StartHereContextEdgeState(
                    title: hero.contextEdge.title,
                    summary: privacy.visibleSubtitle(hero.contextEdge.summary),
                    sourceLabel: privacy.sourceLabel
                ),
                timeFitProof: hero.timeFitProof,
                goalThread: hero.goalThread,
                receiptItem: DayRailHeroStepState.receiptItem(
                    id: "\(hero.receiptItem.id).private",
                    title: "Private item",
                    sourceLabel: privacy.sourceLabel,
                    freshness: .localOnly,
                    privacyLabel: "Private details hidden",
                    becauseLine: "Details stay private on Today."
                ),
                primaryAction: hero.primaryAction,
                secondaryAction: hero.secondaryAction,
                detailTarget: hero.detailTarget,
                sourceLabels: [DayRailSourceLabelState(id: "source.private", label: privacy.sourceLabel, source: .privateUserText)]
            )
        }
        let privateRows = baseRail.rows.map { row in
            DayRailRowState(
                id: "\(row.id).private",
                slot: row.slot,
                title: privacy.visibleTitle(row.title),
                subtitle: privacy.visibleSubtitle(row.subtitle),
                duration: row.duration,
                detailTarget: row.detailTarget,
                sourceLabels: [DayRailSourceLabelState(id: "source.private.\(row.slot.rawValue)", label: privacy.sourceLabel, source: .privateUserText)]
            )
        }
        let privateRail = AmbitionsDayRailViewState(
            id: "\(baseRail.id).private",
            mode: baseRail.mode,
            dateTitle: baseRail.dateTitle,
            contextSummary: privacy.visibleSubtitle(baseRail.contextSummary),
            heroStep: privateHero,
            rows: privateRows,
            primaryAction: baseRail.primaryAction,
            rowTapDetailTargetPlaceholder: baseRail.rowTapDetailTargetPlaceholder,
            durationSource: baseRail.durationSource,
            contextLabels: [DayRailSourceLabelState(id: "source.private", label: privacy.sourceLabel, source: .privateUserText)],
            privacyProjection: privacy,
            continuity: DayRailContinuityState.make(
                heroStep: privateHero,
                rows: privateRows,
                closureSlot: baseRail.closureSlot,
                proofSlot: baseRail.proofSlot,
                mode: baseRail.mode,
                pressureLabel: baseRail.continuity.pressureLabel
            ),
            closureSlot: baseRail.closureSlot,
            proofSlot: baseRail.proofSlot
        )

        return TodayExperience(
            mode: experience.mode,
            hero: experience.hero,
            support: experience.support,
            execution: experience.execution.replacingDayRail(privateRail)
        )
    }

    private static func makeHeroActionScenario(
        from experience: TodayExperience,
        action: TodayInlineAction
    ) -> TodayExperience {
        let baseRail = experience.execution.dayRail
        guard let baseHero = baseRail.heroStep else { return experience }
        let hero = DayRailHeroStepState(
            id: "\(baseHero.id).\(action.state.rawValue)",
            title: baseHero.title,
            subtitle: baseHero.subtitle,
            duration: baseHero.duration,
            fitLabel: action.state == .disabled ? "Needs review" : baseHero.fitLabel,
            whySummary: action.state == .disabled
                ? "The source is visible, but the next action should wait for review."
                : baseHero.whySummary,
            sourceQualityLabel: action.state == .disabled ? "Source needs review" : baseHero.sourceQualityLabel,
            becauseLine: action.state == .disabled
                ? "Because the source is visible, but the next action should wait for review."
                : baseHero.becauseLine,
            receiptLabel: baseHero.receiptLabel,
            proofLabel: baseHero.proofLabel,
            sourceRecordLabel: baseHero.sourceRecordLabel,
            replayTraceLabel: baseHero.replayTraceLabel,
            replayInspectionLabel: baseHero.replayInspectionLabel,
            contextEdge: baseHero.contextEdge,
            timeFitProof: action.state == .disabled
                ? StartHereTimeFitProofState(title: baseHero.timeFitProof.title, summary: baseHero.timeFitProof.summary, detail: "Review before starting.")
                : baseHero.timeFitProof,
            goalThread: baseHero.goalThread,
            receiptItem: action.state == .disabled
                ? DayRailHeroStepState.receiptItem(
                    id: "\(baseHero.receiptItem.id).needs-review",
                    title: baseHero.title,
                    sourceLabel: baseHero.receiptItem.sourceLabel,
                    freshness: .partial,
                    privacyLabel: baseHero.receiptItem.privacyLabel,
                    becauseLine: "The source is visible, but the next action should wait for review."
                )
                : baseHero.receiptItem,
            primaryAction: action,
            secondaryAction: baseHero.secondaryAction,
            detailTarget: baseHero.detailTarget,
            sourceLabels: baseHero.sourceLabels
        )
        let rail = AmbitionsDayRailViewState(
            id: "\(baseRail.id).hero-\(action.state.rawValue)",
            mode: baseRail.mode,
            dateTitle: baseRail.dateTitle,
            contextSummary: baseRail.contextSummary,
            heroStep: hero,
            rows: baseRail.rows,
            primaryAction: action,
            rowTapDetailTargetPlaceholder: baseRail.rowTapDetailTargetPlaceholder,
            durationSource: baseRail.durationSource,
            contextLabels: baseRail.contextLabels,
            privacyProjection: baseRail.privacyProjection,
            continuity: DayRailContinuityState.make(
                heroStep: hero,
                rows: baseRail.rows,
                closureSlot: baseRail.closureSlot,
                proofSlot: baseRail.proofSlot,
                mode: baseRail.mode,
                pressureLabel: baseRail.continuity.pressureLabel
            ),
            closureSlot: baseRail.closureSlot,
            proofSlot: baseRail.proofSlot
        )
        return TodayExperience(
            mode: experience.mode,
            hero: experience.hero,
            support: experience.support,
            execution: experience.execution.replacingDayRail(rail)
        )
    }

    private static func makeSourceStateScenario(
        from experience: TodayExperience,
        sourceQualityLabel: String,
        freshness: SourceFreshnessState,
        sourceLabels: [DayRailSourceLabelState],
        sourceRecordLabel: String,
        replayTraceLabel: String
    ) -> TodayExperience {
        let baseRail = experience.execution.dayRail
        guard let baseHero = baseRail.heroStep else { return experience }

        let sourceLabel = sourceLabels.first?.label ?? sourceQualityLabel
        let hero = DayRailHeroStepState(
            id: "\(baseHero.id).\(freshness.rawValue)",
            title: baseHero.title,
            subtitle: baseHero.subtitle,
            duration: baseHero.duration,
            fitLabel: freshness == .blocked || freshness == .partial ? "Needs review" : baseHero.fitLabel,
            whySummary: baseHero.whySummary,
            sourceQualityLabel: sourceQualityLabel,
            becauseLine: baseHero.becauseLine,
            receiptLabel: baseHero.receiptLabel,
            proofLabel: baseHero.proofLabel,
            sourceRecordLabel: sourceRecordLabel,
            replayTraceLabel: replayTraceLabel,
            replayInspectionLabel: DayRailHeroStepState.replayInspectionLabel(
                sourceRecordLabel: sourceRecordLabel,
                replayTraceLabel: replayTraceLabel
            ),
            contextEdge: StartHereContextEdgeState(
                title: baseHero.contextEdge.title,
                summary: baseHero.contextEdge.summary,
                sourceLabel: sourceLabel
            ),
            timeFitProof: StartHereTimeFitProofState(
                title: baseHero.timeFitProof.title,
                summary: baseHero.timeFitProof.summary,
                detail: freshness == .blocked || freshness == .partial ? "Review before starting." : baseHero.timeFitProof.detail
            ),
            goalThread: baseHero.goalThread,
            receiptItem: DayRailHeroStepState.receiptItem(
                id: "\(baseHero.receiptItem.id).\(freshness.rawValue)",
                title: baseHero.receiptItem.redactedDetail ?? baseHero.title,
                sourceLabel: sourceLabel,
                freshness: freshness,
                privacyLabel: baseHero.receiptItem.privacyLabel,
                becauseLine: baseHero.receiptItem.whyLabel ?? baseHero.becauseLine
            ),
            primaryAction: baseHero.primaryAction,
            secondaryAction: baseHero.secondaryAction,
            detailTarget: baseHero.detailTarget,
            sourceLabels: sourceLabels
        )

        let rail = AmbitionsDayRailViewState(
            id: "\(baseRail.id).\(freshness.rawValue)",
            mode: baseRail.mode,
            dateTitle: baseRail.dateTitle,
            contextSummary: baseRail.contextSummary,
            heroStep: hero,
            rows: baseRail.rows,
            primaryAction: baseRail.primaryAction,
            rowTapDetailTargetPlaceholder: baseRail.rowTapDetailTargetPlaceholder,
            durationSource: baseRail.durationSource,
            contextLabels: sourceLabels,
            privacyProjection: baseRail.privacyProjection,
            continuity: DayRailContinuityState.make(
                heroStep: hero,
                rows: baseRail.rows,
                closureSlot: baseRail.closureSlot,
                proofSlot: baseRail.proofSlot,
                mode: baseRail.mode,
                pressureLabel: baseRail.continuity.pressureLabel
            ),
            closureSlot: baseRail.closureSlot,
            proofSlot: baseRail.proofSlot
        )

        return TodayExperience(
            mode: experience.mode,
            hero: experience.hero,
            support: experience.support,
            execution: experience.execution.replacingDayRail(rail)
        )
    }

    private static func makeModeScenario(
        from experience: TodayExperience,
        mode: DayRailMode,
        pressureLabel: String,
        pressureDetail: String
    ) -> TodayExperience {
        var pressure = pressureLabel
        if pressureLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            pressure = basePressureLabel(from: experience.execution.dayRail.mode, fallbackFrom: mode)
        }
        let detail = pressureDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? detailFor(mode: mode, pressureLabel: pressure)
            : pressureDetail

        let baseRail = experience.execution.dayRail
        let continuity = DayRailContinuityState.make(
            heroStep: baseRail.heroStep,
            rows: baseRail.rows,
            closureSlot: baseRail.closureSlot,
            proofSlot: baseRail.proofSlot,
            mode: mode,
            pressureLabel: pressure
        )
        let rail = AmbitionsDayRailViewState(
            id: "\(baseRail.id).mode-\(mode.rawValue)",
            mode: mode,
            dateTitle: baseRail.dateTitle,
            contextSummary: detail,
            heroStep: baseRail.heroStep,
            rows: baseRail.rows,
            primaryAction: baseRail.primaryAction,
            rowTapDetailTargetPlaceholder: baseRail.rowTapDetailTargetPlaceholder,
            durationSource: baseRail.durationSource,
            contextLabels: baseRail.contextLabels,
            privacyProjection: baseRail.privacyProjection,
            continuity: continuity,
            closureSlot: baseRail.closureSlot,
            proofSlot: baseRail.proofSlot
        )

        return TodayExperience(
            mode: experience.mode,
            hero: experience.hero,
            support: experience.support,
            execution: experience.execution.replacingDayRail(rail)
        )
    }

    private static func makeLongReflowScenario(
        from experience: TodayExperience,
        title: String,
        subtitle: String,
        nextTitle: String,
        nextSubtitle: String
    ) -> TodayExperience {
        let reflowSupportScenario = makeScenario(
            posture: .stable,
            title: "Reflow target",
            supporting: "A long text path should reflow instead of truncating core proof and continuity meaning.",
            nowSubtitle: subtitle,
            nextTitle: nextTitle,
            nextSubtitle: nextSubtitle,
            primaryAction: experience.execution.dayRail.heroStep?.primaryAction ?? TodayInlineAction(
                kind: .complete,
                title: "Complete",
                systemImage: "checkmark",
                state: .success,
                target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")
            ),
            supportingActions: [],
            reentry: nil,
            celebrationLine: nil
        )

        let baseRail = reflowSupportScenario.execution.dayRail
        guard let baseHero = baseRail.heroStep else { return reflowSupportScenario }
        let reflowHero = DayRailHeroStepState(
            id: "\(baseRail.id).reflow.hero",
            title: title,
            subtitle: subtitle,
            duration: baseHero.duration,
            fitLabel: baseHero.fitLabel,
            whySummary: subtitle,
            sourceQualityLabel: baseHero.sourceQualityLabel,
            becauseLine: subtitle,
            receiptLabel: baseHero.receiptLabel,
            proofLabel: baseHero.proofLabel,
            sourceRecordLabel: baseHero.sourceRecordLabel,
            replayTraceLabel: baseHero.replayTraceLabel,
            replayInspectionLabel: baseHero.replayInspectionLabel,
            contextEdge: baseHero.contextEdge,
            timeFitProof: baseHero.timeFitProof,
            goalThread: baseHero.goalThread,
            receiptItem: baseHero.receiptItem,
            primaryAction: baseHero.primaryAction,
            secondaryAction: baseHero.secondaryAction,
            detailTarget: baseHero.detailTarget,
            sourceLabels: baseHero.sourceLabels
        )
        let reflowRows = baseRail.rows.map { row in
            let detail = [row.detailTarget.placeholderLabel, row.title].first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                ?? "Reflow-safe continuity"
            return DayRailRowState(
                id: "\(row.id).reflow",
                slot: row.slot,
                title: "\(row.title) · reflow target",
                subtitle: "\(row.subtitle). \(detail)",
                duration: row.duration,
                detailTarget: row.detailTarget,
                sourceLabels: row.sourceLabels
            )
        }
        let rail = AmbitionsDayRailViewState(
            id: "\(baseRail.id).reflow",
            mode: baseRail.mode,
            dateTitle: baseRail.dateTitle,
            contextSummary: baseRail.contextSummary,
            heroStep: reflowHero,
            rows: reflowRows,
            primaryAction: baseRail.primaryAction,
            rowTapDetailTargetPlaceholder: baseRail.rowTapDetailTargetPlaceholder,
            durationSource: baseRail.durationSource,
            contextLabels: baseRail.contextLabels,
            privacyProjection: baseRail.privacyProjection,
            continuity: DayRailContinuityState.make(
                heroStep: reflowHero,
                rows: reflowRows,
                closureSlot: baseRail.closureSlot,
                proofSlot: baseRail.proofSlot,
                mode: baseRail.mode,
                pressureLabel: baseRail.continuity.pressureLabel
            ),
            closureSlot: baseRail.closureSlot,
            proofSlot: baseRail.proofSlot
        )
        return TodayExperience(
            mode: experience.mode,
            hero: reflowSupportScenario.hero,
            support: reflowSupportScenario.support,
            execution: reflowSupportScenario.execution.replacingDayRail(rail)
        )
    }

    private static func makeMissingDurationStepDetail() -> DayRailStepDetailState {
        let rail = stable.execution.dayRail
        let row = DayRailRowState(
            id: "preview.step-detail.missing-duration",
            slot: .later,
            title: "Review launch notes",
            subtitle: "A flexible follow-up if the main block lands.",
            duration: DayRailDurationState(minutes: nil, source: .notSet, label: "Duration not set"),
            detailTarget: DayRailDetailTargetState(
                kind: .stepDetail,
                goalID: "goal-preview",
                stepID: "step-preview",
                draftID: nil,
                placeholderLabel: "Open Step Detail."
            ),
            sourceLabels: [DayRailSourceLabelState(id: "source.preview", label: "Based on your goal path", source: .standard)]
        )
        return row.stepDetail(
            privacy: rail.privacyProjection,
            contextLabel: "Later can stay open."
        )
    }

    private static func makeStartHereStepDetail() -> DayRailStepDetailState? {
        guard let baseHero = stable.execution.dayRail.heroStep else { return nil }
        let rail = stable.execution.dayRail
        let hero = DayRailHeroStepState(
            id: "preview.step-detail.start-here",
            title: baseHero.title,
            subtitle: baseHero.subtitle,
            duration: DayRailDurationState(minutes: 25, source: .suggested, label: "25 min suggested"),
            fitLabel: baseHero.fitLabel,
            whySummary: baseHero.whySummary,
            sourceQualityLabel: baseHero.sourceQualityLabel,
            becauseLine: baseHero.becauseLine,
            contextEdge: baseHero.contextEdge,
            timeFitProof: baseHero.timeFitProof,
            goalThread: baseHero.goalThread,
            receiptItem: baseHero.receiptItem,
            primaryAction: DayRailStepDetailState.reservedStartNowAction(target: baseHero.primaryAction.target),
            secondaryAction: baseHero.secondaryAction,
            detailTarget: baseHero.detailTarget,
            sourceLabels: baseHero.sourceLabels
        )
        return hero.stepDetail(
            privacy: rail.privacyProjection,
            contextLabel: rail.contextSummary
        )
    }

    private static func makeScenario(
        posture: TodayDayPosture,
        title: String,
        supporting: String,
        nowSubtitle: String,
        nextTitle: String?,
        nextSubtitle: String?,
        primaryAction: TodayInlineAction,
        supportingActions: [TodayInlineAction],
        reentry: TodayReentryState?,
        celebrationLine: String?,
        mode: TodayExperienceMode = .active
    ) -> TodayExperience {
        TodayExperience(
            mode: mode,
            hero: TodayHeroState(
                truth: TodayHeroTruthState(
                    greeting: "Good afternoon, Preview User",
                    dominantText: title,
                    supportingText: supporting,
                    nowTitle: title,
                    nowSubtitle: nowSubtitle,
                    nextTitle: nextTitle,
                    nextSubtitle: nextSubtitle,
                    posture: posture,
                    contextPills: [
                        TodayPillState(id: "goals", title: mode == .empty ? "No live goals" : "4 active goals", icon: "scope", state: .selected),
                        TodayPillState(id: "moves", title: mode == .empty ? "Waiting" : "3 live steps", icon: "bolt.fill", state: .default)
                    ],
                    trustWhisper: TodayTrustWhisperState(
                        title: "Why this now",
                        detail: "The top layer is reading live native planning and runtime summary truth.",
                        state: .selected
                    ),
                    shellSummary: GoalShellSummaryState(
                        explanationSummary: "This step is the cleanest next step from the current path and timing context.",
                        pathSummary: "Primary path remains believable.",
                        indicators: [
                            GoalShellSummaryIndicatorState(kind: .freshness, title: "Freshness: Current Enough", systemImage: "clock.arrow.circlepath", state: .success),
                            GoalShellSummaryIndicatorState(kind: .energy, title: "Energy: Sustainable", systemImage: "bolt.heart", state: .selected)
                        ]
                    )
                ),
                primaryAction: TodayPrimaryActionState(
                    title: primaryAction.title,
                    subtitle: "One primary action stays visible so Today does not feel reconfigured.",
                    action: primaryAction,
                    supportingActions: supportingActions
                ),
                reentry: reentry
            ),
            support: TodaySupportLayerState(
                timeAperture: TodayTimeApertureState(
                    title: "Time Aperture",
                    subtitle: "Room and pressure stay visible without turning Today into a dense calendar.",
                    pressure: TodayDayPressureState(
                        title: pressureTitle(for: posture),
                        detail: pressureDetail(for: posture),
                        label: pressureLabel(for: posture),
                        state: pressureState(for: posture)
                    ),
                    windows: mode == .empty ? [] : [
                        TodayOpenWindowState(
                            id: "window-1",
                            title: "Next 45 minutes",
                            subtitle: posture == .overloaded ? "Protect one clean lane before adding more to today." : "A bounded near-term block is still available.",
                            timingLabel: "Afternoon room",
                            state: posture == .overloaded ? .warning : .default,
                            action: primaryAction.kind == .openTime ? nil : primaryAction
                        ),
                        TodayOpenWindowState(
                            id: "window-2",
                            title: "Later today",
                            subtitle: "If the first block lands, one lighter follow-on step still fits.",
                            timingLabel: "Later today",
                            state: .default,
                            action: supportingActions.first
                        )
                    ],
                    emptyMessage: mode == .empty ? "No open window needs to be filled right now." : nil,
                    bestUseTitle: posture == .overloaded ? "Lighten the day first" : title,
                    bestUseDetail: supporting,
                    bestUseAction: primaryAction,
                    trustWhisper: TodayTrustWhisperState(
                        title: posture == .lowData ? "May need confirmation" : "Based on",
                        detail: posture == .lowData
                            ? "Time pressure is inferred from the current draft shape and may change as answers land."
                            : "The remaining-time read is using the current plan shape and runtime summary truth.",
                        state: pressureState(for: posture)
                    )
                ),
                recoveryBloom: recoveryBloom(for: posture, primaryAction: primaryAction, supportingActions: supportingActions),
                stepSession: reentry?.title.contains("Step Session") == true || reentry?.title.contains("Focus") == true
                    ? TodayStepSessionState(
                        title: title,
                        subtitle: nowSubtitle,
                        detail: "Step Session is narrowed to one step so the rest of Today can stay quiet.",
                        primaryAction: supportingActions.first ?? primaryAction,
                        secondaryActions: Array(supportingActions.dropFirst().prefix(2)),
                        trustWhisper: TodayTrustWhisperState(
                            title: "Based on",
                            detail: "The focus handoff keeps the current recommendation visible without redesigning the rest of Today.",
                            state: .selected
                        )
                    )
                    : nil,
                fixedCommitments: TodayFixedCommitmentsState(
                    title: "Fixed commitments",
                    summary: "The fixed layer should stay obvious and compact.",
                    items: mode == .empty ? [] : [
                        TodaySupportItemState(
                            id: "fixed-1",
                            title: "Draft the talk outline",
                            subtitle: "Submit my conference talk proposal",
                            label: "Due 2026-05-15",
                            state: .default,
                            action: TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1"))
                        ),
                        TodaySupportItemState(
                            id: "fixed-2",
                            title: "Refine the goal setup copy",
                            subtitle: "Ship the native create goal flow",
                            label: "Today",
                            state: .selected,
                            action: TodayInlineAction(kind: .defer, title: "Defer", systemImage: "clock.arrow.circlepath", state: .default, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2"))
                        )
                    ],
                    emptyMessage: "No fixed commitments are live yet."
                ),
                flexibleRoom: TodayFlexibleRoomState(
                    title: "Flexible room",
                    summary: "The flexible layer stays clearly separate from fixed work.",
                    items: mode == .empty ? [] : [
                        TodaySupportItemState(
                            id: "flex-1",
                            title: "Record one rough vocal pass",
                            subtitle: "A good flexible learning session.",
                            label: "No deadline",
                            state: .default,
                            action: TodayInlineAction(kind: .quickLog, title: "Quick log", systemImage: "plus.bubble", state: .success, target: TodayActionTarget(goalID: "goal-3", stepID: "step-3"))
                        )
                    ],
                    emptyMessage: "Free space is allowed to stay free."
                ),
                momentum: TodayMomentumStripState(
                    title: "Momentum",
                    summary: "A calm summary of live progress.",
                    metrics: mode == .empty ? [] : [
                        TodayMetricState(id: "1", title: "Completed today", value: "1", detail: "Recorded from native evidence", icon: "checkmark.circle.fill", state: .success),
                        TodayMetricState(id: "2", title: "Active goals", value: "4", detail: "Live in the repository", icon: "scope", state: .selected),
                        TodayMetricState(id: "3", title: "Logged minutes", value: "55", detail: "Captured evidence", icon: "timer", state: .default),
                        TodayMetricState(id: "4", title: "Friction signals", value: posture == .stable ? "1" : "3", detail: "Feedback worth respecting", icon: "waveform.path.ecg", state: posture == .stable ? .default : .warning)
                    ],
                    note: mode == .empty ? "The first real goal will light this up." : "Support modules should reinforce the hero instead of competing with it.",
                    celebrationLine: celebrationLine
                ),
                quickCaptureAction: mode == .empty ? nil : TodayInlineAction(kind: .quickLog, title: "Quick log", systemImage: "plus.bubble", state: .success, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
                quickCaptureTitle: "Quick capture",
                quickCaptureDetail: "Capture and ask-for-help stay bounded and shell-owned.",
                timeAction: TodayInlineAction(kind: .openTime, title: "Open Time", systemImage: "calendar", state: .default, target: TodayActionTarget()),
                reflectionPrompt: "When tonight arrives, what do you want to feel good about?",
                reflectionHighlights: mode == .empty ? [] : ["Captured one completed session", "Kept the day from turning into metrics noise"]
            )
        )
    }

    private static func pressureTitle(for posture: TodayDayPosture) -> String {
        switch posture {
        case .stable: return "The day still has breathing room"
        case .tight: return "The day is getting tight"
        case .drifted: return "The day drifted off its first plan"
        case .overloaded: return "Too many asks are touching today"
        case .recovering: return "Recovery is already in progress"
        case .lowData: return "Time shape is present, but certainty is not"
        case .noPlan: return "Today has open room"
        }
    }

    private static func pressureDetail(for posture: TodayDayPosture) -> String {
        switch posture {
        case .stable: return "There is room for one deliberate block without making the day noisy."
        case .tight: return "One more meaningful step fits, but only if it stays singular."
        case .drifted: return "The real pressure is re-entry, not forcing more volume."
        case .overloaded: return "The day needs fewer simultaneous asks before effort goes up."
        case .recovering: return "Use the remaining room for one safe block, not for catching everything up."
        case .lowData: return "Clarification matters before stronger timing claims."
        case .noPlan: return "The first step should stay bounded and real."
        }
    }

    private static func basePressureLabel(from currentMode: DayRailMode, fallbackFrom fallback: DayRailMode) -> String {
        switch fallback {
        case .normal:
            return currentMode == .normal ? "Ready" : "Recalibrated"
        case .recovery:
            return "Recovery active"
        case .protected:
            return "Protected now"
        case .overloaded:
            return "Needs trim"
        case .empty:
            return "Open"
        case .noSchedule:
            return "No schedule connected"
        }
    }

    private static func detailFor(mode: DayRailMode, pressureLabel: String) -> String {
        switch mode {
        case .normal:
            return pressureLabel
        case .recovery:
            return "Recovery remains visible without opening a wider plan."
        case .protected:
            return "Protected segments stay visible and prioritized."
        case .overloaded:
            return "Pressure stays visible while the active node stays small."
        case .empty:
            return "No active recommendation."
        case .noSchedule:
            return "No schedule connected; Today stays anchored to active recommendation."
        }
    }

    private static func pressureLabel(for posture: TodayDayPosture) -> String {
        switch posture {
        case .stable: return "Strong fit"
        case .tight: return "Likely fit"
        case .drifted: return "Needs recovery"
        case .overloaded: return "Compressed"
        case .recovering: return "Recovering"
        case .lowData: return "Needs confirmation"
        case .noPlan: return "Open"
        }
    }

    private static func pressureState(for posture: TodayDayPosture) -> AmbitionVisualState {
        switch posture {
        case .stable: return .success
        case .tight, .recovering: return .selected
        case .drifted, .overloaded, .lowData: return .warning
        case .noPlan: return .default
        }
    }

    private static func recoveryBloom(
        for posture: TodayDayPosture,
        primaryAction: TodayInlineAction,
        supportingActions: [TodayInlineAction]
    ) -> TodayRecoveryBloomState? {
        guard posture == .tight || posture == .drifted || posture == .recovering || posture == .overloaded else {
            return nil
        }
        let options = ([primaryAction] + supportingActions).prefix(3).enumerated().map { index, action in
            TodayRecoveryOptionState(
                id: "recovery-\(index)",
                title: index == 0 ? "Safest next step" : action.title,
                detail: index == 0 ? "The first option should feel like relief, not punishment." : "A calmer alternative stays visible if the first step still feels too heavy.",
                state: action.state,
                action: action
            )
        }
        return TodayRecoveryBloomState(
            title: posture == .overloaded ? "Lighten today" : "Recovery Bloom",
            subtitle: "The safer path appears before any deeper explanation.",
            explanation: "Recovery reorganizes the day softly so the user never has to fight through a broken-plan feeling.",
            pressureFieldLabel: posture == .overloaded
                ? "Pressure field: too many asks are touching today at once."
                : "Pressure field: the day needs one calmer lane.",
            recoveryLoopLabel: "Recovery loop: shrink the next ask, keep Still Counts available, and preview the receipt.",
            smallerStepAnchorLabel: "Smaller step anchor: choose the lightest useful version first.",
            recoveryReceiptPreviewLabel: "Recovery receipt preview: records the lighter path and what stayed unchanged.",
            options: Array(options)
        )
    }
}
