import AmbitionsDesignSystem
import Foundation

enum PreviewTodayScenarios {
    static let seededRitual = TodayRitualLoopState(
        kind: .middayReset,
        title: "Midday reset",
        subtitle: "Use a smaller next move before pressure turns into drift.",
        thesis: "Anchor the day around one next move.",
        stateLabel: "Reset needed",
        signalLabels: ["4 active goals", "1 done today", "2 friction signals", "moderate pressure"],
        action: TodayInlineAction(kind: .askForSmallerStep, title: "Smaller step", systemImage: "scissors", state: .selected, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1"))
    )

    static let emptyRitual = TodayRitualLoopState(
        kind: .morningSetup,
        title: "Morning setup",
        subtitle: "Add a real goal or capture before Ambitions suggests a repeat loop.",
        thesis: "No day thesis yet because Ambitions has no live signal.",
        stateLabel: "Waiting",
        signalLabels: ["0 active goals", "0 done today", "low pressure"],
        action: nil
    )

    static let seeded = TodayExperience(
        mode: .seeded,
        header: TodayHeaderState(
            greeting: "Good afternoon, Preview User",
            title: "Today",
            subtitle: "The native execution center is reading seeded repository data and real orchestration states.",
            contextPills: [
                TodayPillState(id: "goals", title: "4 active goals", icon: "scope", state: .selected),
                TodayPillState(id: "moves", title: "6 live moves", icon: "bolt.fill", state: .default),
                TodayPillState(id: "seeded", title: "Seeded demo", icon: "sparkles", state: .celebration)
            ]
        ),
        ritual: seededRitual,
        dailyTargets: TodayDailyTargetsState(
            title: "Daily targets",
            subtitle: "A short list from the native planner and repository layers.",
            completionLabel: "38% through visible plan work",
            items: [
                TodayTargetItem(
                    id: "a",
                    title: "Draft the talk outline",
                    subtitle: "Submit my conference talk proposal",
                    timingLabel: "Due 2026-05-15",
                    statusLabel: "Planned",
                    progress: 0.62,
                    state: .default,
                    primaryAction: TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
                    secondaryAction: TodayInlineAction(kind: .delay, title: "Delay", systemImage: "clock.arrow.circlepath", state: .default, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1"))
                ),
                TodayTargetItem(
                    id: "b",
                    title: "Record one rough vocal pass",
                    subtitle: "Learn how to mix vocals",
                    timingLabel: "No deadline",
                    statusLabel: "Starter plan",
                    progress: 0.34,
                    state: .selected,
                    primaryAction: nil,
                    secondaryAction: nil
                )
            ],
            emptyMessage: nil
        ),
        focus: .planned(
            TodayFocusPlannedState(
                title: "Draft the talk outline",
                subtitle: "Submit my conference talk proposal",
                reason: "This is the cleanest next move from the current native plan.",
                timingLabel: "Due 2026-05-15",
                energyLabel: "Deliberate",
                progress: 0.72,
                supportingText: ["Due 2026-05-15", "A visible draft exists", "You know what done looks like"],
                actions: [
                    TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
                    TodayInlineAction(kind: .delay, title: "Delay", systemImage: "clock.arrow.circlepath", state: .default, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
                    TodayInlineAction(kind: .askForSmallerStep, title: "Smaller step", systemImage: "scissors", state: .selected, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
                    TodayInlineAction(kind: .askWhyThisMatters, title: "Why this matters", systemImage: "questionmark.circle", state: .default, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1"))
                ]
            )
        ),
        freeTime: TodayFreeTimeState(
            title: "Free time opportunities",
            subtitle: "Valid flexible moves for untimed, delegated, or exploratory work.",
            opportunities: [
                TodayOpportunityState(
                    id: "c",
                    title: "Record one rough vocal pass",
                    subtitle: "A good flexible learning session",
                    timingLabel: "No deadline",
                    state: .default,
                    action: TodayInlineAction(kind: .quickLog, title: "Quick log", systemImage: "plus.bubble", state: .success, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2"))
                )
            ]
        ),
        milestone: TodayMilestoneState(
            title: "Submit my conference talk proposal",
            subtitle: "Milestone prompt",
            prompt: "Confirm the final proposal angle after the outline exists.",
            confidenceLabel: "Live plan",
            action: TodayInlineAction(kind: .openDetail, title: "Open detail", systemImage: "flag.checkered.2.crossed", state: .selected, target: TodayActionTarget(goalID: "goal-1"))
        ),
        momentum: TodayMomentumState(
            title: "Momentum",
            subtitle: "Progress summary",
            metrics: [
                TodayMetricState(id: "1", title: "Completed today", value: "1", detail: "Recorded from native evidence", icon: "checkmark.circle.fill", state: .success),
                TodayMetricState(id: "2", title: "Active goals", value: "4", detail: "Live in the repository", icon: "scope", state: .selected),
                TodayMetricState(id: "3", title: "Logged minutes", value: "55", detail: "Captured evidence", icon: "timer", state: .default),
                TodayMetricState(id: "4", title: "Friction signals", value: "2", detail: "Feedback worth respecting", icon: "waveform.path.ecg", state: .warning)
            ],
            note: "Supportive goals are in the mix, so momentum stays non-punitive."
        ),
        celebration: TodayCelebrationState(
            title: "Momentum is already real",
            subtitle: "A visible win landed today.",
            achievements: ["Captured one completed session", "Recorded fresh progress evidence"],
            actions: [TodayInlineAction(kind: .dismissCelebration, title: "Keep going", systemImage: "arrow.right", state: .celebration, target: TodayActionTarget())]
        ),
        quickCapture: TodayQuickCaptureState(
            title: "Quick capture",
            subtitle: "Ask for help when the next move is still too large or too vague.",
            prompt: "Use quick log when progress happened without a clean completion event.",
            helpText: "If the active step feels heavy, ask for a smaller step before the day turns into avoidance.",
            actions: [
                TodayInlineAction(kind: .quickLog, title: "Quick log", systemImage: "plus.bubble", state: .success, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")),
                TodayInlineAction(kind: .askForHelp, title: "Ask for help", systemImage: "lifepreserver", state: .default, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1"))
            ]
        ),
        reflection: TodayReflectionState(
            title: "End-of-day reflection",
            subtitle: "A calm close matters more than squeezing in one more noisy panel.",
            prompt: "When tonight arrives, what do you want to feel good about?",
            highlights: ["Captured one completed session", "Skipped one step without punishment"],
            actions: [TodayInlineAction(kind: .quickLog, title: "Quick log", systemImage: "square.and.pencil", state: .default, target: TodayActionTarget(goalID: "goal-1", stepID: "step-1"))]
        )
    )

    static let empty = TodayExperience(
        mode: .empty,
        header: TodayHeaderState(
            greeting: "Good morning",
            title: "Today",
            subtitle: "Today becomes useful as soon as one real goal or draft exists. Nothing here is faking urgency.",
            contextPills: [TodayPillState(id: "empty", title: "No live goals", icon: "moon.zzz", state: .default)]
        ),
        ritual: emptyRitual,
        dailyTargets: TodayDailyTargetsState(
            title: "No live targets yet",
            subtitle: "Once a goal exists, Today will surface only the few moves worth acting on.",
            completionLabel: "No fake completion bars",
            items: [],
            emptyMessage: "Import, seed, or create a goal and Today will immediately fill from persisted steps and draft states."
        ),
        focus: .empty(TodayEmptyPanelState(title: "Nothing needs a push", message: "Today stays calm when there is no clear next move.", actions: [])),
        freeTime: TodayFreeTimeState(title: "Free time can stay open", subtitle: "Nothing here is pretending a flexible goal is late.", opportunities: []),
        milestone: TodayMilestoneState(title: "Milestone prompt", subtitle: "No active milestone yet", prompt: "Once a goal exists, Today will pull the next milestone cue from the real plan.", confidenceLabel: "Waiting on first goal", action: nil),
        momentum: TodayMomentumState(title: "Momentum", subtitle: "Progress summary", metrics: [], note: "The first real goal will light this up."),
        celebration: nil,
        quickCapture: TodayQuickCaptureState(title: "Quick capture", subtitle: "Capture is ready when the first goal is.", prompt: "Quick log will attach to a real step once one exists.", helpText: "Ask for help now routes into the native Goal Detail help path.", actions: []),
        reflection: TodayReflectionState(title: "End-of-day reflection", subtitle: "A calm close still counts.", prompt: "What do you want future Today to help you protect?", highlights: [], actions: [])
    )

    static let starter = TodayExperience(
        mode: .active,
        header: seeded.header,
        ritual: seededRitual,
        dailyTargets: seeded.dailyTargets,
        focus: .starter(
            TodayFocusStarterState(
                title: "Record one rough vocal pass",
                subtitle: "Learn how to mix vocals",
                reassurance: "This plan was built from safe assumptions so you can start without technical warning energy.",
                timingLabel: "No deadline",
                assumptions: ["Starting with one rough pass is enough signal.", "You do not need the whole system figured out first."],
                actions: [
                    TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2")),
                    TodayInlineAction(kind: .askForSmallerStep, title: "Smaller step", systemImage: "scissors", state: .selected, target: TodayActionTarget(goalID: "goal-2", stepID: "step-2"))
                ]
            )
        ),
        freeTime: seeded.freeTime,
        milestone: seeded.milestone,
        momentum: seeded.momentum,
        celebration: nil,
        quickCapture: seeded.quickCapture,
        reflection: seeded.reflection
    )

    static let clarification = TodayExperience(
        mode: .active,
        header: seeded.header,
        ritual: seededRitual,
        dailyTargets: seeded.dailyTargets,
        focus: .clarification(
            TodayFocusClarificationState(
                title: "Break this down for someone else",
                subtitle: "A short clarification here will unlock a better plan than pretending certainty.",
                questions: [
                    TodayClarificationQuestionState(id: "q1", prompt: "Who is this for?", rationale: "The planner needs to know whose work is actually being supported.", gentleDefault: "If you are not sure, assume you are helping without taking ownership."),
                    TodayClarificationQuestionState(id: "q2", prompt: "What outcome matters most?", rationale: "One clear success definition is worth more than five vague tasks.", gentleDefault: "Start with the smallest visible improvement you would notice.")
                ],
                actions: [TodayInlineAction(kind: .openDetail, title: "Answer", systemImage: "arrow.right.circle", state: .selected, target: TodayActionTarget(draftID: "draft-1"))]
            )
        ),
        freeTime: seeded.freeTime,
        milestone: seeded.milestone,
        momentum: seeded.momentum,
        celebration: nil,
        quickCapture: seeded.quickCapture,
        reflection: seeded.reflection
    )

    static let blocked = TodayExperience(
        mode: .active,
        header: seeded.header,
        ritual: seededRitual,
        dailyTargets: seeded.dailyTargets,
        focus: .blocked(
            TodayFocusBlockedState(
                title: "Break this down for someone else",
                subtitle: "There is a blocker, but Today still offers the next best move instead of a dead end.",
                blockerSummary: "Planning is blocked because the owner of the goal is unclear.",
                nextBestAction: "Open the draft and answer who this goal is actually for.",
                actions: [TodayInlineAction(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .warning, target: TodayActionTarget(draftID: "draft-2"))]
            )
        ),
        freeTime: seeded.freeTime,
        milestone: seeded.milestone,
        momentum: seeded.momentum,
        celebration: nil,
        quickCapture: seeded.quickCapture,
        reflection: seeded.reflection
    )

    static let freshGoal = TodayExperience(
        mode: .active,
        header: TodayHeaderState(
            greeting: "Good afternoon, Preview User",
            title: "Today",
            subtitle: "A newly created goal is already part of the same native execution flow.",
            contextPills: [
                TodayPillState(id: "goals", title: "1 active goal", icon: "scope", state: .selected),
                TodayPillState(id: "moves", title: "3 live moves", icon: "bolt.fill", state: .default)
            ]
        ),
        ritual: TodayRitualLoopState(
            kind: .morningSetup,
            title: "Morning setup",
            subtitle: "Pick one next move before the day gets noisy.",
            thesis: "Anchor the day around one next move.",
            stateLabel: "Ready",
            signalLabels: ["1 active goal", "0 done today", "low pressure"],
            action: TodayInlineAction(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .default, target: TodayActionTarget(goalID: "goal-fresh", stepID: "goal-fresh-step-1", draftID: "draft-fresh"))
        ),
        dailyTargets: TodayDailyTargetsState(
            title: "Daily targets",
            subtitle: "Freshly created goals can surface here immediately when the next step is concrete enough to act on.",
            completionLabel: "0% through visible plan work",
            items: [
                TodayTargetItem(
                    id: "fresh-step-1",
                    title: "Define scope",
                    subtitle: "Ship the native create goal flow",
                    timingLabel: "No deadline",
                    statusLabel: "Planned",
                    progress: 0.48,
                    state: .default,
                    primaryAction: TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: TodayActionTarget(goalID: "goal-fresh", stepID: "goal-fresh-step-1", draftID: "draft-fresh")),
                    secondaryAction: TodayInlineAction(kind: .delay, title: "Delay", systemImage: "clock.arrow.circlepath", state: .default, target: TodayActionTarget(goalID: "goal-fresh", stepID: "goal-fresh-step-1", draftID: "draft-fresh"))
                )
            ],
            emptyMessage: nil
        ),
        focus: .planned(
            TodayFocusPlannedState(
                title: "Define scope",
                subtitle: "Ship the native create goal flow",
                reason: "This is the cleanest next move from the newly created micro-plan.",
                timingLabel: "No deadline",
                energyLabel: "Deliberate",
                progress: 0.48,
                supportingText: ["No deadline", "Scope is written in a few lines.", "Open detail stays available if the step needs context."],
                actions: [
                    TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: TodayActionTarget(goalID: "goal-fresh", stepID: "goal-fresh-step-1", draftID: "draft-fresh")),
                    TodayInlineAction(kind: .delay, title: "Delay", systemImage: "clock.arrow.circlepath", state: .default, target: TodayActionTarget(goalID: "goal-fresh", stepID: "goal-fresh-step-1", draftID: "draft-fresh")),
                    TodayInlineAction(kind: .askForSmallerStep, title: "Smaller step", systemImage: "scissors", state: .selected, target: TodayActionTarget(goalID: "goal-fresh", stepID: "goal-fresh-step-1", draftID: "draft-fresh")),
                    TodayInlineAction(kind: .askWhyThisMatters, title: "Why this matters", systemImage: "questionmark.circle", state: .default, target: TodayActionTarget(goalID: "goal-fresh", stepID: "goal-fresh-step-1", draftID: "draft-fresh")),
                    TodayInlineAction(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .default, target: TodayActionTarget(goalID: "goal-fresh", stepID: "goal-fresh-step-1", draftID: "draft-fresh"))
                ]
            )
        ),
        freeTime: TodayFreeTimeState(
            title: "Free time opportunities",
            subtitle: "Fresh goals can still leave room for optional movement later in the day.",
            opportunities: [
                TodayOpportunityState(
                    id: "fresh-step-2",
                    title: "List constraints",
                    subtitle: "A calm use of spare time",
                    timingLabel: "No deadline",
                    state: .default,
                    action: TodayInlineAction(kind: .quickLog, title: "Quick log", systemImage: "plus.bubble", state: .success, target: TodayActionTarget(goalID: "goal-fresh", stepID: "goal-fresh-step-2", draftID: "draft-fresh"))
                )
            ]
        ),
        milestone: TodayMilestoneState(
            title: "Ship the native create goal flow",
            subtitle: "Milestone prompt",
            prompt: "Do the first pass once scope and constraints are written down.",
            confidenceLabel: "Live plan",
            action: TodayInlineAction(kind: .openDetail, title: "Open detail", systemImage: "flag.checkered.2.crossed", state: .selected, target: TodayActionTarget(goalID: "goal-fresh", draftID: "draft-fresh"))
        ),
        momentum: TodayMomentumState(
            title: "Momentum",
            subtitle: "Progress summary",
            metrics: [
                TodayMetricState(id: "fresh-1", title: "Completed today", value: "0", detail: "Recorded from native evidence", icon: "checkmark.circle.fill", state: .default),
                TodayMetricState(id: "fresh-2", title: "Active goals", value: "1", detail: "Live in the repository", icon: "scope", state: .selected),
                TodayMetricState(id: "fresh-3", title: "Logged minutes", value: "0", detail: "Captured evidence", icon: "timer", state: .default),
                TodayMetricState(id: "fresh-4", title: "Friction signals", value: "0", detail: "Feedback worth respecting", icon: "waveform.path.ecg", state: .success)
            ],
            note: "A fresh goal is visible without pretending momentum already exists."
        ),
        celebration: nil,
        quickCapture: TodayQuickCaptureState(
            title: "Quick capture",
            subtitle: "Ask for help when the next move is still too large or too vague.",
            prompt: "Use quick log when progress happened without a clean completion event.",
            helpText: "If the step still feels heavy, ask for a smaller step before it turns into drift.",
            actions: [
                TodayInlineAction(kind: .quickLog, title: "Quick log", systemImage: "plus.bubble", state: .success, target: TodayActionTarget(goalID: "goal-fresh", stepID: "goal-fresh-step-1", draftID: "draft-fresh")),
                TodayInlineAction(kind: .askForHelp, title: "Ask for help", systemImage: "lifepreserver", state: .default, target: TodayActionTarget(goalID: "goal-fresh", stepID: "goal-fresh-step-1", draftID: "draft-fresh"))
            ]
        ),
        reflection: TodayReflectionState(
            title: "End-of-day reflection",
            subtitle: "A calm close matters more than squeezing in one more noisy panel.",
            prompt: "What would make this new goal feel genuinely started by tonight?",
            highlights: ["The first step is already clear."],
            actions: [
                TodayInlineAction(kind: .quickLog, title: "Quick log", systemImage: "square.and.pencil", state: .default, target: TodayActionTarget(goalID: "goal-fresh", stepID: "goal-fresh-step-1", draftID: "draft-fresh"))
            ]
        )
    )
}
