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
        nextTitle: "Open Plan",
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
        nextSubtitle: "If the step still feels too large, move the shaping into Plan without shame.",
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
        nextSubtitle: "Use Plan to protect one block instead of trying to do all of it now.",
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
        primaryAction: TodayInlineAction(kind: .openPlan, title: "Build today", systemImage: "calendar.badge.plus", state: .selected, target: TodayActionTarget()),
        supportingActions: [],
        reentry: nil,
        celebrationLine: nil,
        mode: .empty
    )

    static let empty = noPlan

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
        default:
            nil
        }
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
                            action: primaryAction.kind == .openPlan ? nil : primaryAction
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
                focusScreenlet: reentry?.title.contains("Focus") == true
                    ? TodayFocusScreenletState(
                        title: title,
                        subtitle: nowSubtitle,
                        detail: "Focus is narrowed to one step so the rest of Today can stay quiet.",
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
                planAction: TodayInlineAction(kind: .openPlan, title: "Open Plan", systemImage: "calendar", state: .default, target: TodayActionTarget()),
                reflectionPrompt: "When tonight arrives, what do you want to feel good about?",
                reflectionHighlights: mode == .empty ? [] : ["Captured one completed session", "Kept the day from turning into dashboard noise"]
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
            options: Array(options)
        )
    }
}
