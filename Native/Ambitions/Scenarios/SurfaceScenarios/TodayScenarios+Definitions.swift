import AmbitionsDesignSystem
import Foundation

extension PreviewTodayScenarios {
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
        sourceQualityLabel: "Needs context",
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

}
