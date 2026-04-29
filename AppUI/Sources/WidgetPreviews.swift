#if canImport(SwiftUI)
import AmbitionsDesignSystem
import SwiftUI

private enum WidgetFixtures {
    static let defaultActions: [WidgetInlineActionDescriptor] = [
        .init(kind: .complete, title: "Complete", icon: "checkmark.circle.fill", state: .success),
        .init(kind: .delay, title: "Delay", icon: "clock.arrow.circlepath", state: .warning),
        .init(kind: .openDetail, title: "Open", icon: "arrow.up.right.circle")
    ]

    static func metadata(
        family: AmbitionsWidgetFamily,
        variant: WidgetDisplayVariant = .medium,
        priority: WidgetDisplayPriority = .standard,
        chrome: WidgetChromeStyle = .appCard,
        supportedActions: Set<WidgetActionKind> = Set(WidgetActionKind.allCases)
    ) -> WidgetMetadata {
        .init(
            identity: .init(
                family: family,
                instanceID: "preview-\(family.rawValue)-\(variant.rawValue)",
                analyticsID: "preview.\(family.rawValue)",
                debugLabel: "Preview"
            ),
            priority: priority,
            variant: variant,
            chrome: chrome,
            supportedActions: supportedActions
        )
    }
}

public extension DailyTargetsWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .dailyTargets), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .dailyTargets), state: .empty(.init(title: "No targets yet", message: "Planner output can slot here once the day is assembled.", icon: "target", actionTitle: "Refine plan"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .dailyTargets), state: .ready(.init(title: "Daily targets", subtitle: "Three well-supported moves for today.", completionLabel: "2 of 3", targets: [.init(id: "1", title: "Ship widget framework", detail: "Architecture and previews", progress: 0.7, trailingValue: "70%", statusLabel: "Focus", state: .selected), .init(id: "2", title: "Review trend summary", detail: "Spot weak consistency pockets", progress: 0.45, trailingValue: "45%", statusLabel: "Next"), .init(id: "3", title: "Log ritual evidence", detail: "Evening check-in", progress: 0.2, trailingValue: "20%", statusLabel: "Later")], actions: WidgetFixtures.defaultActions))))
    static let expanded = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .dailyTargets, variant: .expanded, priority: .high), state: ready.snapshot.state))
}

public extension FocusNowWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .focusNow, priority: .hero, chrome: .heroCard), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .focusNow, priority: .hero, chrome: .heroCard), state: .empty(.init(title: "No focus card", message: "Once the day is clear enough, the top block can become one main action.", icon: "scope", actionTitle: "Make it smaller"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .focusNow, priority: .hero, chrome: .heroCard), state: .ready(.init(headline: "Draft the Today feed contracts", subtitle: "Do this next for the current session.", reason: "This unblocks every downstream widget family and keeps visual logic out of business orchestration.", duration: "35 min", energyLabel: "Fit", progress: 0.82, supportSteps: ["Define shared widget action payloads", "Reuse WidgetCard and HeroCard surfaces", "Add preview fixtures before persistence"], actions: [.init(kind: .complete, title: "Mark done", icon: "checkmark.circle.fill", state: .success), .init(kind: .askWhyThisMatters, title: "Why it matters", icon: "questionmark.circle"), .init(kind: .askForSmallerStep, title: "Smaller step", icon: "arrow.down.circle")]))))
    static let expanded = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .focusNow, variant: .expanded, priority: .hero, chrome: .heroCard), state: ready.snapshot.state))
}

public extension FreeTimeWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .freeTime, chrome: .widgetCard), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .freeTime, chrome: .widgetCard), state: .empty(.init(title: "No free-time suggestion", message: "Leave this calm and optional until scheduling signals are clear.", icon: "clock.badge.questionmark", actionTitle: "Open day"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .freeTime, chrome: .widgetCard), state: .ready(.init(title: "Free time", subtitle: "A small open window appeared after lunch.", availableWindow: "26 min", suggestionTitle: "Outline one smaller step", suggestionDetail: "Use the gap for a low-friction planning pass instead of deep work.", actions: [.init(kind: .quickLog, title: "Quick log", icon: "plus.circle"), .init(kind: .skip, title: "Skip", icon: "forward.fill", state: .warning)]))))
}

public extension GoalsListWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .goalsList), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .goalsList), state: .empty(.init(title: "No active goals", message: "This stays empty until intake and planner data are connected.", icon: "target", actionTitle: "Refine intake"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .goalsList), state: .ready(.init(title: "Goal portfolio", subtitle: "Ordered for attention, not permanence.", goals: [.init(id: "g1", title: "Launch premium Today screen", subtitle: "UI architecture and interaction polish", progressLabel: "68%", statusLabel: "On track"), .init(id: "g2", title: "Stabilize goal orchestration", subtitle: "Improve planner handoff clarity", progressLabel: "42%", statusLabel: "Watching"), .init(id: "g3", title: "Reduce setup friction", subtitle: "You and settings cleanup", progressLabel: "31%", statusLabel: "Queued")], actions: [.init(kind: .refinePlan, title: "Refine", icon: "slider.horizontal.3"), .init(kind: .expand, title: "Expand", icon: "arrow.up.left.and.arrow.down.right")]))))
    static let expanded = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .goalsList, variant: .expanded, priority: .high), state: ready.snapshot.state))
}

public extension MilestonePromptWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .milestonePrompt), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .milestonePrompt), state: .empty(.init(title: "No milestone prompt", message: "Keep this optional until there is enough history to show a prompt.", icon: "flag.checkered", actionTitle: "View plan"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .milestonePrompt), state: .ready(.init(title: "Milestone prompt", subtitle: "Reflect before the next planning pass.", prompt: "You completed two focused sessions faster than expected. Capture what made the cadence sustainable.", confidenceLabel: "Recent pattern", actions: [.init(kind: .markHelpful, title: "Helpful", icon: "hand.thumbsup.fill", state: .success), .init(kind: .dismiss, title: "Dismiss", icon: "xmark.circle"), .init(kind: .openDetail, title: "Open detail", icon: "arrow.right.circle")]))))
    static let expanded = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .milestonePrompt, variant: .expanded, priority: .high, chrome: .heroCard), state: ready.snapshot.state))
}

public extension HabitSummaryWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .habitSummary), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .habitSummary), state: .empty(.init(title: "No ritual snapshot", message: "Use preview fixtures until logging and persistence settle down.", icon: "repeat", actionTitle: "Quick log"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .habitSummary), state: .ready(.init(title: "Ritual summary", subtitle: "Daily routines with enough structure to stay glanceable.", stats: [.init(id: "h1", title: "Consistency", value: "84%", detail: "Last 14 days", icon: "waveform.path.ecg", state: .success), .init(id: "h2", title: "Sessions", value: "18", detail: "This week", icon: "calendar.badge.clock", state: .selected)], habits: [.init(id: "hb1", title: "Morning review", detail: "10-minute alignment", progress: 0.9, trailingValue: "9/10", statusLabel: "Strong", state: .success), .init(id: "hb2", title: "Evening log", detail: "Close the day with evidence", progress: 0.62, trailingValue: "5/8", statusLabel: "Recover"), .init(id: "hb3", title: "Movement reset", detail: "Mobility between work blocks", progress: 0.5, trailingValue: "4/8", statusLabel: "Watch", state: .warning)], actions: [.init(kind: .quickLog, title: "Log", icon: "plus.circle.fill", state: .success), .init(kind: .openDetail, title: "Inspect", icon: "chart.bar")]))))
}

public extension StreakWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .streak, chrome: .widgetCard), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .streak, chrome: .widgetCard), state: .empty(.init(title: "No streak yet", message: "This should feel encouraging, not punitive, when there is not enough evidence.", icon: "flame", actionTitle: "Quick log"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .streak, chrome: .widgetCard), state: .ready(.init(title: "7 day streak", subtitle: "Cadence stayed stable despite schedule movement.", stats: [.init(id: "s1", title: "Current", value: "7", detail: "days", icon: "flame.fill", state: .celebration), .init(id: "s2", title: "Best", value: "11", detail: "days", icon: "trophy.fill", state: .success)], recoveryNote: "A lighter step tomorrow keeps momentum better than an all-or-nothing push.", actions: [.init(kind: .markHelpful, title: "Helpful", icon: "heart.fill", state: .celebration), .init(kind: .askForSmallerStep, title: "Smaller step", icon: "arrow.down.circle")]))))
}

public extension InsightStatsWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .insightStats), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .insightStats), state: .empty(.init(title: "No review stats", message: "Wait for enough history before implying precision.", icon: "chart.xyaxis.line", actionTitle: "Open reviews"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .insightStats), state: .ready(.init(title: "Review stats", subtitle: "Useful rollups for the current review window.", stats: [.init(id: "i1", title: "Focus depth", value: "73%", detail: "weighted quality", icon: "brain.head.profile", state: .selected), .init(id: "i2", title: "Completion", value: "81%", detail: "active steps", icon: "checkmark.circle.fill", state: .success), .init(id: "i3", title: "Drift", value: "14%", detail: "unplanned pivots", icon: "arrow.triangle.branch", state: .warning), .init(id: "i4", title: "Helpfulness", value: "4.7", detail: "prompt rating", icon: "hand.thumbsup.fill", state: .celebration)], summary: "Recent adaptation suggestions were most effective when the step size was under 35 minutes.", actions: [.init(kind: .markHelpful, title: "Helpful", icon: "hand.thumbsup.fill", state: .success), .init(kind: .openDetail, title: "Open", icon: "arrow.right.circle")]))))
}

public extension WeeklyTrendWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .weeklyTrend, variant: .expanded), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .weeklyTrend, variant: .expanded), state: .empty(.init(title: "No weekly trend", message: "Use the shell without implying real chart fidelity before data stabilizes.", icon: "chart.bar", actionTitle: "Open reviews"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .weeklyTrend, variant: .expanded, priority: .high), state: .ready(.init(title: "Weekly trend", subtitle: "Shell-backed chart for fit and throughput.", timeframeLabel: "Last 7 days", points: [.init(id: "m", label: "M", value: 0.54), .init(id: "t", label: "T", value: 0.82), .init(id: "w", label: "W", value: 0.68), .init(id: "th", label: "T", value: 0.91), .init(id: "f", label: "F", value: 0.73), .init(id: "sa", label: "S", value: 0.41), .init(id: "su", label: "S", value: 0.57)], summary: "Thursday carried the highest useful output, while the weekend stayed intentionally lighter.", actions: [.init(kind: .expand, title: "Expand", icon: "arrow.up.left.and.arrow.down.right"), .init(kind: .openDetail, title: "Inspect", icon: "chart.bar.doc.horizontal")]))))
}

public extension RecentActivityWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .recentActivity), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .recentActivity), state: .empty(.init(title: "No recent activity", message: "This should stay sparse and readable when history is young.", icon: "clock", actionTitle: "Quick log"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .recentActivity), state: .ready(.init(title: "Recent activity", subtitle: "Latest meaningful signals, not raw event spam.", activities: [.init(id: "a1", title: "Completed widget contract draft", subtitle: "Today", timestamp: "9:14 AM", icon: "checkmark.circle.fill", badge: "Done"), .init(id: "a2", title: "Skipped oversized focus step", subtitle: "Adaptation", timestamp: "Yesterday", icon: "forward.fill", badge: "Adjusted"), .init(id: "a3", title: "Logged evening reflection", subtitle: "Ritual", timestamp: "Yesterday", icon: "book.closed.fill", badge: nil)], actions: [.init(kind: .quickLog, title: "Log", icon: "plus.circle"), .init(kind: .expand, title: "Expand", icon: "rectangle.expand.vertical")]))))
}

public extension ProfileSummaryWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .profileSummary), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .profileSummary), state: .empty(.init(title: "No You summary", message: "Keep this driven by demo fixtures until preferences are wired.", icon: "person.crop.circle", actionTitle: "Open You"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .profileSummary), state: .ready(.init(title: "Preview User", subtitle: "Quiet settings, steady momentum.", initials: "PU", badges: ["On-device", "Calm"], stats: [.init(id: "p1", title: "Goals", value: "6", detail: "active", icon: "target"), .init(id: "p2", title: "Wins", value: "14", detail: "this month", icon: "sparkles", state: .celebration)], actions: [.init(kind: .openDetail, title: "Open You", icon: "person.crop.circle"), .init(kind: .refinePlan, title: "Adjust settings", icon: "slider.horizontal.3")]))))
}

public extension CelebrationWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .celebration, priority: .hero, chrome: .heroCard), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .celebration, priority: .hero, chrome: .heroCard), state: .empty(.init(title: "No celebration yet", message: "Only surface this when there is a real moment worth emphasizing.", icon: "sparkles", actionTitle: "Dismiss"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .celebration, variant: .expanded, priority: .hero, chrome: .heroCard), state: .ready(.init(title: "Momentum is building", subtitle: "You closed the top focus step and kept the next one clear before the day drifted.", achievements: ["Finished the architecture layer", "Kept the daily streak", "Captured why the focus card worked"], actions: [.init(kind: .markHelpful, title: "Helpful", icon: "hand.thumbsup.fill", state: .celebration), .init(kind: .dismiss, title: "Dismiss", icon: "xmark.circle")]))))
}

public extension SettingsGroupWidgetViewModel {
    static let loading = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .settingsGroup), state: .loading))
    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .settingsGroup), state: .empty(.init(title: "No settings group", message: "This remains app-side because the rows are product configuration, not design-system primitives.", icon: "gearshape.2", actionTitle: "Open settings"))))
    static let ready = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .settingsGroup), state: .ready(.init(title: "Settings", subtitle: "Controls grouped in reusable card chrome.", items: [.init(id: "sg1", title: "Focus defaults", subtitle: "Default session length and recovery margins", icon: "timer", valueLabel: "35 min"), .init(id: "sg2", title: "Notifications", subtitle: "Timely nudges only", icon: "bell.badge", valueLabel: "Quiet"), .init(id: "sg3", title: "Guidance tone", subtitle: "How assertive suggestions feel", icon: "dial.medium", valueLabel: "Calm")], footer: "Keep screen assembly in the app target. Only the visual row shell belongs to the design system."))))
}

private struct WidgetPreviewGallery: View {
    var body: some View {
        ScrollView {
            WidgetFeed(items: [
                WidgetFeedItem(id: "focus-loading", priority: .hero, variant: .medium) { FocusNowWidget(viewModel: .loading) },
                WidgetFeedItem(id: "focus-ready", priority: .hero, variant: .expanded) { FocusNowWidget(viewModel: .expanded) },
                WidgetFeedItem(id: "daily-loading", priority: .high, variant: .medium) { DailyTargetsWidget(viewModel: .loading) },
                WidgetFeedItem(id: "daily-ready", priority: .high, variant: .expanded) { DailyTargetsWidget(viewModel: .expanded) },
                WidgetFeedItem(id: "free-empty", priority: .standard, variant: .compact) { FreeTimeWidget(viewModel: .empty) },
                WidgetFeedItem(id: "free-ready", priority: .standard, variant: .medium) { FreeTimeWidget(viewModel: .ready) },
                WidgetFeedItem(id: "goals-ready", priority: .high, variant: .expanded) { GoalsListWidget(viewModel: .expanded) },
                WidgetFeedItem(id: "milestone-ready", priority: .high, variant: .expanded) { MilestonePromptWidget(viewModel: .expanded) },
                WidgetFeedItem(id: "habit-ready", priority: .standard, variant: .medium) { HabitSummaryWidget(viewModel: .ready) },
                WidgetFeedItem(id: "streak-ready", priority: .standard, variant: .compact) { StreakWidget(viewModel: .ready) },
                WidgetFeedItem(id: "insight-ready", priority: .standard, variant: .medium) { InsightStatsWidget(viewModel: .ready) },
                WidgetFeedItem(id: "trend-ready", priority: .standard, variant: .expanded) { WeeklyTrendWidget(viewModel: .ready) },
                WidgetFeedItem(id: "recent-ready", priority: .standard, variant: .medium) { RecentActivityWidget(viewModel: .ready) },
                WidgetFeedItem(id: "profile-ready", priority: .standard, variant: .medium) { ProfileSummaryWidget(viewModel: .ready) },
                WidgetFeedItem(id: "celebration-ready", priority: .hero, variant: .expanded) { CelebrationWidget(viewModel: .ready) },
                WidgetFeedItem(id: "settings-ready", priority: .supporting, variant: .medium) { SettingsGroupWidget(viewModel: .ready) }
            ])
            .padding(24)
        }
        .ambitionTheme(.dark)
    }
}

struct WidgetPreviewGallery_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetPreviewGallery()
                .previewDisplayName("Dark")

            WidgetPreviewGallery()
                .ambitionTheme(.theme(for: .light, accentFamily: .blueGray))
                .preferredColorScheme(.light)
                .previewDisplayName("Light Blue Gray")
        }
    }
}
#endif
