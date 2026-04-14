import Foundation

enum PreviewHabitsScenarios {
    static let active = HabitsDashboard(
        mode: .active,
        title: "Consistency that stays calm",
        subtitle: "Three habit loops are active today, and the screen is biasing toward fast logging instead of guilt-inducing noise.",
        summaryLabel: "2 of 3 habits touched today",
        summaryDetail: "A minimum version already counted, so the rhythm is protected even without a perfect day.",
        stats: [
            MetricSummary(id: "active-complete", title: "Completed", value: "1", detail: "Full versions today", icon: "checkmark.circle.fill"),
            MetricSummary(id: "active-minimum", title: "Minimum versions", value: "1", detail: "Still valid", icon: "leaf.circle"),
            MetricSummary(id: "active-recovery", title: "Recovery", value: "1", detail: "Needs gentler restart", icon: "arrow.uturn.backward.circle"),
            MetricSummary(id: "active-streak", title: "Best streak", value: "14", detail: "Across current set", icon: "flame.fill")
        ],
        habits: [
            makeHabit(id: "habit-planning", title: "Morning planning reset", subtitle: "A 10 minute alignment pass before the workday hardens.", cadence: "Daily rhythm", streak: "6-day streak", consistency: "86% consistency • best 9", progress: 0.86, progressLabel: "86% consistency", status: .completed, note: "Today's full version is already in the log.", minimumVersion: "Open the daily plan and define one deliberate win.", supportLabel: nil),
            makeHabit(id: "habit-review", title: "Evening review", subtitle: "Capture what moved and what still feels heavier than it should.", cadence: "Daily rhythm", streak: "Restart gently today", consistency: "57% consistency • best 5", progress: 0.57, progressLabel: "57% consistency", status: .minimumDone, note: "The minimum version counted today. That still protects the rhythm.", minimumVersion: "Write one sentence about the day and one sentence about tomorrow.", supportLabel: nil)
        ],
        recoveryHabits: [
            makeHabit(id: "habit-stretch", title: "Weekly stretching reset", subtitle: "Keep mobility alive without turning it into a performative workout.", cadence: "Every 3 days", streak: "Restart gently today", consistency: "43% consistency • best 4", progress: 0.43, progressLabel: "43% consistency", status: .recovery, note: "This loop wants a gentler restart or a smaller ask.", minimumVersion: "Do two minutes of the easiest stretch sequence and log it.", supportLabel: nil)
        ],
        streak: StreakSummary(
            title: "Consistency survives misses",
            subtitle: "Recovery is shown as part of the system instead of being treated like moral failure.",
            stats: [
                MetricSummary(id: "streak-a", title: "Current streak", value: "6", detail: "Best live rhythm", icon: "flame"),
                MetricSummary(id: "streak-b", title: "Consistency", value: "62%", detail: "Last 14 days", icon: "checkmark.seal"),
                MetricSummary(id: "streak-c", title: "Recovered slips", value: "3", detail: "Recent rebounds", icon: "waveform.path.ecg")
            ],
            recoveryNote: "If a habit is slipping, shrink the next version before you ask for more discipline."
        ),
        guidanceTitle: "How to use the screen",
        guidanceBody: "Use full completion when the full routine landed, minimum version when the smallest valid version happened, and quick log when signal matters more than ceremony.",
        emptyTitle: nil,
        emptyMessage: nil
    )

    static let recovery = HabitsDashboard(
        mode: .recovery,
        title: "Recovery is part of consistency",
        subtitle: "Several loops need a gentler restart, so the screen is prioritizing easier versions and plan correction first.",
        summaryLabel: "0 of 2 habits touched today",
        summaryDetail: "Recovery is leading the screen today so the next action gets easier instead of louder.",
        stats: [
            MetricSummary(id: "recovery-complete", title: "Completed", value: "0", detail: "Full versions today", icon: "checkmark.circle.fill"),
            MetricSummary(id: "recovery-minimum", title: "Minimum versions", value: "0", detail: "Today", icon: "leaf.circle"),
            MetricSummary(id: "recovery-recovery", title: "Recovery", value: "2", detail: "Need care", icon: "arrow.uturn.backward.circle"),
            MetricSummary(id: "recovery-streak", title: "Best streak", value: "8", detail: "Still recoverable", icon: "flame.fill")
        ],
        habits: [],
        recoveryHabits: [
            makeHabit(id: "habit-support", title: "Reading support check-in", subtitle: "Create a calm support window instead of pressuring Maya to perform.", cadence: "Support rhythm every 2 days", streak: "Restart gently today", consistency: "36% consistency • best 3", progress: 0.36, progressLabel: "36% consistency", status: .needsEasierVersion, note: "The plan is asking for a smaller version before it asks for more consistency.", minimumVersion: "Ask Maya what kind of reading support would feel easiest tonight.", supportLabel: "Support Maya without making them the task."),
            makeHabit(id: "habit-walk", title: "Recovery walk", subtitle: "Keep the loop gentle enough that it can survive lower-energy days.", cadence: "Daily rhythm", streak: "Restart gently today", consistency: "29% consistency • best 5", progress: 0.29, progressLabel: "29% consistency", status: .recovery, note: "This loop wants a gentler restart or a smaller ask.", minimumVersion: "Walk for five minutes or step outside and breathe once before logging it.", supportLabel: nil)
        ],
        streak: StreakSummary(
            title: "Recovery stays visible",
            subtitle: "The goal is to restart the loop cleanly, not to preserve a perfect score.",
            stats: [
                MetricSummary(id: "recovery-streak-a", title: "Current streak", value: "0", detail: "Fresh restart", icon: "flame"),
                MetricSummary(id: "recovery-streak-b", title: "Consistency", value: "33%", detail: "Last 14 days", icon: "checkmark.seal"),
                MetricSummary(id: "recovery-streak-c", title: "Recovered slips", value: "2", detail: "Past month", icon: "waveform.path.ecg")
            ],
            recoveryNote: "Mark the routine as needing an easier version before you let it become another source of pressure."
        ),
        guidanceTitle: "How to recover cleanly",
        guidanceBody: "If a loop is slipping, ask for a smaller version first. Recovery should change the size of the ask before it changes your self-story.",
        emptyTitle: nil,
        emptyMessage: nil
    )

    static let seeded = HabitsDashboard(
        mode: .seeded,
        title: "Consistency that already lives in native data",
        subtitle: "The native demo seed is driving this surface through the real repository layer, not through a detached tracker.",
        summaryLabel: "2 of 4 habits touched today",
        summaryDetail: "The screen is already reading seeded native records through goals, steps, evidence, and feedback.",
        stats: active.stats,
        habits: active.habits,
        recoveryHabits: active.recoveryHabits,
        streak: active.streak,
        guidanceTitle: "Why this feels native",
        guidanceBody: "Every card here is derived from live native goal records, steps, evidence, and feedback, even though the current data set is still seeded.",
        emptyTitle: nil,
        emptyMessage: nil
    )

    static let empty = HabitsDashboard(
        mode: .empty,
        title: "Consistency, once it exists",
        subtitle: "Habits becomes real as soon as a recurring goal or routine exists. There is no detached subsystem behind this screen.",
        summaryLabel: "0 habits are active yet",
        summaryDetail: "When planning adds recurring structure, Habits will translate it into a quick daily interaction surface automatically.",
        stats: [
            MetricSummary(id: "empty-a", title: "Completed", value: "0", detail: "Full versions today", icon: "checkmark.circle.fill"),
            MetricSummary(id: "empty-b", title: "Minimum versions", value: "0", detail: "Today", icon: "leaf.circle"),
            MetricSummary(id: "empty-c", title: "Recovery", value: "0", detail: "Loops needing care", icon: "arrow.uturn.backward.circle"),
            MetricSummary(id: "empty-d", title: "Best streak", value: "0", detail: "No live rhythms yet", icon: "flame.fill")
        ],
        habits: [],
        recoveryHabits: [],
        streak: StreakSummary(
            title: "Consistency will appear here",
            subtitle: "Once a recurring routine exists, streak and recovery interpretation will be derived from native evidence.",
            stats: [
                MetricSummary(id: "empty-streak-a", title: "Current streak", value: "0", detail: "Waiting on first habit", icon: "flame"),
                MetricSummary(id: "empty-streak-b", title: "Consistency", value: "0%", detail: "No tracked windows yet", icon: "checkmark.seal")
            ],
            recoveryNote: "Habits is waiting on recurring structure from the native planner and goal engine, not on a separate tracker."
        ),
        guidanceTitle: "How Habits will wake up",
        guidanceBody: "As soon as a recurring goal or routine exists in the native planner, Habits will read it directly from the same repository Today and Goals use.",
        emptyTitle: "No habits are live yet",
        emptyMessage: "Create or import a recurring goal, maintenance loop, or recovery routine and this screen will begin rendering it natively."
    )

    private static func makeHabit(
        id: String,
        title: String,
        subtitle: String,
        cadence: String,
        streak: String,
        consistency: String,
        progress: Double,
        progressLabel: String,
        status: HabitTodayState,
        note: String,
        minimumVersion: String,
        supportLabel: String?
    ) -> HabitSummary {
        let target = HabitActionTarget(goalID: id, stepID: "step-\(id)", draftID: nil)
        return HabitSummary(
            id: id,
            target: target,
            title: title,
            subtitle: subtitle,
            cadenceLabel: cadence,
            streakLabel: streak,
            consistencyLabel: consistency,
            progress: progress,
            progressLabel: progressLabel,
            status: status,
            note: note,
            minimumVersionLabel: minimumVersion,
            supportLabel: supportLabel,
            actions: [
                HabitActionState(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: target),
                HabitActionState(kind: .minimumVersion, title: "Minimum version", systemImage: "leaf", state: .selected, target: target),
                HabitActionState(kind: .quickLog, title: "Quick log", systemImage: "plus.bubble", state: .default, target: target),
                HabitActionState(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .default, target: target)
            ]
        )
    }
}
