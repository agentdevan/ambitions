import AmbitionsDesignSystem
import Foundation

enum PreviewTodayScenarios {
    static let stable = makeScenario(
        posture: .stable,
        title: "Draft the talk outline",
        supporting: "The clearest next move is already visible and small enough to finish.",
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
        supporting: "The day is getting tight, so the safest move is to preserve the next meaningful block.",
        nowSubtitle: "Submit my conference talk proposal",
        nextTitle: "Record one rough vocal pass",
        nextSubtitle: "Keep this flexible unless the main block slips.",
        primaryAction: TodayInlineAction(kind: .protectLater, title: "Protect later", systemImage: "calendar.badge.clock", state: .selected, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
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
        title: "Split the next move",
        supporting: "A smaller version is the safest way back into the day.",
        nowSubtitle: "Ship the native create goal flow",
        nextTitle: "Open Plan",
        nextSubtitle: "If the day still feels too heavy, protect the block there.",
        primaryAction: TodayInlineAction(kind: .split, title: "Split", systemImage: "scissors", state: .selected, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2")),
        supportingActions: [
            TodayInlineAction(kind: .protectLater, title: "Protect later", systemImage: "calendar.badge.clock", state: .default, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2")),
            TodayInlineAction(kind: .askForHelp, title: "Ask for help", systemImage: "lifepreserver", state: .default, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2"))
        ],
        reentry: TodayReentryState(
            eyebrow: "Re-entry",
            title: "Recovery landed in Today",
            detail: "This pass is centered on one believable move instead of the whole backlog.",
            state: .selected
        ),
        celebrationLine: nil
    )

    static let overloaded = makeScenario(
        posture: .overloaded,
        title: "Lighten the day first",
        supporting: "There are too many active asks right now, so pressure needs to come down before new effort goes up.",
        nowSubtitle: "Four active goals are pulling on the same day.",
        nextTitle: "Protect later",
        nextSubtitle: "Use Plan to protect one block instead of trying to do all of it now.",
        primaryAction: TodayInlineAction(kind: .protectLater, title: "Protect later", systemImage: "calendar.badge.clock", state: .selected, target: TodayActionTarget()),
        supportingActions: [
            TodayInlineAction(kind: .reschedule, title: "Reschedule", systemImage: "forward.fill", state: .warning, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
            TodayInlineAction(kind: .split, title: "Split", systemImage: "scissors", state: .selected, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1"))
        ],
        reentry: nil,
        celebrationLine: nil
    )

    static let noPlan = makeScenario(
        posture: .noPlan,
        title: "Build today from one real move",
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
                        TodayPillState(id: "moves", title: mode == .empty ? "Waiting" : "3 live moves", icon: "bolt.fill", state: .default)
                    ],
                    trustWhisper: TodayTrustWhisperState(
                        title: "Why this now",
                        detail: "The top layer is reading live native planning and runtime summary truth.",
                        state: .selected
                    ),
                    shellSummary: GoalShellSummaryState(
                        explanationSummary: "This move is the cleanest next step from the current path and timing context.",
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
}
