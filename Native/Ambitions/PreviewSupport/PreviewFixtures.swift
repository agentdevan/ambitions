import Foundation

struct PreviewFixtures: Sendable {
    let preferences: AppPreferences
    let todayDashboard: TodayDashboard
    let captures: [Capture]
    let goalsDashboard: GoalsDashboard
    let habitsDashboard: HabitsDashboard
    let insightsDashboard: InsightsDashboard
    let profileDashboard: ProfileDashboard

    static let `default` = PreviewFixtures(
        preferences: AppPreferences(
            preferredTab: .today,
            userDisplayName: "Preview User",
            appearancePreference: .system
        ),
        todayDashboard: TodayDashboard(
            title: "Steady execution, light load",
            subtitle: "Three deliberate moves are enough to keep momentum today.",
            completionLabel: "58% aligned",
            targets: [
                DashboardProgressItem(id: "today-1", title: "Ship native shell", detail: "Wire target, bootstrap, and tabs", progress: 0.82, trailingValue: "82%", statusLabel: "In flight"),
                DashboardProgressItem(id: "today-2", title: "Refine goal engine contract", detail: "Keep TS as spec reference only", progress: 0.45, trailingValue: "45%", statusLabel: "Queued"),
                DashboardProgressItem(id: "today-3", title: "Draft app architecture note", detail: "Clarify native pivot for future work", progress: 0.67, trailingValue: "67%", statusLabel: "Ready")
            ],
            focus: FocusSession(
                headline: "Protect the native source of truth",
                subtitle: "Build the shell once, stop extending React Native UI",
                reason: "The fastest path to a shippable App Store client is to make SwiftUI the only UI track and keep the TypeScript engine as behavior reference.",
                durationLabel: "45 min block",
                energyLabel: "Confidence",
                progress: 0.74,
                supportSteps: [
                    "Keep Expo code isolated under the legacy prototype boundary.",
                    "Push shared visuals through AmbitionsDesignSystem.",
                    "Render first-class native surfaces with WidgetUI building blocks."
                ]
            ),
            freeTime: FreeTimeSuggestion(
                title: "Recovery window available",
                subtitle: "You have margin after the native shell pass.",
                windowLabel: "30 min free",
                suggestionTitle: "Sketch detail routes for Today and Goals",
                suggestionDetail: "Use the spare window to define drill-in navigation contracts without touching legacy screens."
            )
        ),
        captures: [
            Capture(
                id: "preview-capture-1",
                createdAt: "2026-04-15T09:20:00Z",
                updatedAt: "2026-04-15T09:20:00Z",
                rawText: "Capture an idea from the Today flow before it disappears.",
                sourceType: .todayQuickCapture,
                status: .goalBound,
                linkedGoalID: "goal-native",
                triage: CaptureTriageMetadata(destination: .attachToGoal, hint: "Keep with the native pivot.")
            ),
            Capture(
                id: "preview-capture-2",
                createdAt: "2026-04-15T08:15:00Z",
                updatedAt: "2026-04-15T08:30:00Z",
                rawText: "Review the notification handoff copy before the next hardening pass.",
                sourceType: .notification,
                status: .seed,
                linkedGoalID: nil,
                triage: CaptureTriageMetadata(destination: .saveAsSeed),
                revisitAfter: "2026-04-22T09:00:00Z"
            )
        ],
        goalsDashboard: GoalsDashboard(
            title: "Active ambitions",
            subtitle: "Three outcome tracks are currently shaping the roadmap.",
            goals: [
                GoalSummary(id: "goal-native", title: "Native iOS pivot", subtitle: "SwiftUI app shell and production architecture", progressLabel: "Foundation", statusLabel: "Highest leverage"),
                GoalSummary(id: "goal-engine", title: "Goal intelligence parity", subtitle: "Translate TS reference behavior into native contracts", progressLabel: "Spec phase", statusLabel: "Reference only"),
                GoalSummary(id: "goal-growth", title: "Retention loop", subtitle: "Habit and insights surfaces that reinforce weekly review", progressLabel: "Discovery", statusLabel: "Upcoming")
            ],
            milestone: MilestonePrompt(
                title: "Lock the first native vertical slice",
                subtitle: "Today + Goals should be the first real production flow.",
                prompt: "Once the shell is stable, the next milestone is replacing placeholder Today data with a real persistence-backed pipeline.",
                confidenceLabel: "Clear next step"
            )
        ),
        habitsDashboard: PreviewHabitsScenarios.seeded,
        insightsDashboard: InsightsDashboard(
            title: "Behavioral readout",
            subtitle: "Signals are organized to make drift, momentum, and adaptation easier to trust at a glance.",
            stats: [
                MetricSummary(id: "insight-1", title: "Focus quality", value: "76", detail: "Composite score", icon: "scope"),
                MetricSummary(id: "insight-2", title: "Plan adherence", value: "63%", detail: "Week to date", icon: "chart.bar"),
                MetricSummary(id: "insight-3", title: "Recovery speed", value: "1.8x", detail: "Vs prior week", icon: "waveform.path.ecg"),
                MetricSummary(id: "insight-4", title: "Drift alerts", value: "2", detail: "Open", icon: "bell")
            ],
            summary: "Recent adaptation works best when the next step stays small, explicit, and grounded in visible evidence.",
            trendTitle: "Weekly trend",
            trendSubtitle: "A calm weekly read on throughput and confidence.",
            timeframeLabel: "Last 7 days",
            trendPoints: [
                TrendPoint(id: "mon", label: "M", value: 0.48),
                TrendPoint(id: "tue", label: "T", value: 0.56),
                TrendPoint(id: "wed", label: "W", value: 0.68),
                TrendPoint(id: "thu", label: "T", value: 0.61),
                TrendPoint(id: "fri", label: "F", value: 0.79),
                TrendPoint(id: "sat", label: "S", value: 0.52),
                TrendPoint(id: "sun", label: "S", value: 0.73)
            ],
            trendSummary: "Execution improved once the scope narrowed to a single native client.",
            activitiesTitle: "Recent signals",
            activitiesSubtitle: "Recent evidence, decisions, and changes that explain the current readout.",
            activities: [
                ActivitySummary(id: "activity-1", title: "Completed deep work block", subtitle: "Today", timestamp: "09:40", icon: "checkmark.circle.fill", badge: "Win"),
                ActivitySummary(id: "activity-2", title: "Rescoped feature backlog", subtitle: "Yesterday", timestamp: "17:15", icon: "arrow.triangle.branch", badge: "Decision"),
                ActivitySummary(id: "activity-3", title: "Updated native architecture note", subtitle: "Yesterday", timestamp: "14:05", icon: "doc.text", badge: nil)
            ]
        ),
        profileDashboard: ProfileDashboard(
            title: "Preview User",
            subtitle: "This build keeps planning data in explicit local-only mode. Notifications, widgets, Live Activity, routes, and navigation shortcuts are \(ExternalSurfaceTruth.pendingBatch36Validation). Share Extension status: \(ExternalSurfaceTruth.notShippedInThisBuild).",
            initials: "PU",
            badges: ["Local-first", "Native pivot", "Design system"],
            stats: [
                MetricSummary(id: "profile-1", title: "Open ambitions", value: "3", detail: "In active review", icon: "target"),
                MetricSummary(id: "profile-2", title: "Tracked habits", value: "6", detail: "Current set", icon: "repeat"),
                MetricSummary(id: "profile-3", title: "Review cadence", value: "Weekly", detail: "Sunday reset", icon: "calendar"),
                MetricSummary(id: "profile-4", title: "Appearance", value: "System", detail: "Follows the device by default", icon: "circle.lefthalf.filled")
            ],
            settingsTitle: "Native app configuration",
            settingsSubtitle: "Core local preferences and external-surface status stay aligned to the Batch 36 validation result without overstating unverified platform behavior.",
            settings: [
                SettingsItem(id: "profile-setting-1", title: "Planning storage", subtitle: "Native persistence is active for goals, habits, and evidence", icon: "internaldrive", valueLabel: "Local-first"),
                SettingsItem(id: "profile-setting-2", title: "Default tab", subtitle: "Used on the next cold launch", icon: "square.grid.2x2", valueLabel: "Today"),
                SettingsItem(id: "profile-setting-3", title: "Appearance", subtitle: "System follows the device while explicit themes stay selectable", icon: "circle.lefthalf.filled", valueLabel: "System"),
                SettingsItem(id: "profile-setting-4", title: "Review cadence", subtitle: "How often the app should frame a reset", icon: "clock.arrow.circlepath", valueLabel: "Weekly"),
                SettingsItem(id: "profile-setting-5", title: "Notifications", subtitle: "\(ExternalSurfaceTruth.pendingBatch36Validation). Authorization: Not requested yet.", icon: "bell.badge", valueLabel: "Not requested"),
                SettingsItem(id: "profile-setting-6", title: "Widgets and Live Activity", subtitle: "\(ExternalSurfaceTruth.pendingBatch36Validation). These surfaces stay read-only in this batch and still need explicit manual checks.", icon: "rectangle.3.group", valueLabel: ExternalSurfaceTruth.pendingBatch36Validation),
                SettingsItem(id: "profile-setting-7", title: "Navigation shortcuts", subtitle: "\(ExternalSurfaceTruth.pendingBatch36Validation). App Intents stay navigation-only and open Today, Plan, or the Captures inbox without creating or mutating records.", icon: "sparkles.rectangle.stack", valueLabel: ExternalSurfaceTruth.pendingBatch36Validation),
                SettingsItem(id: "profile-setting-8", title: "Share Extension", subtitle: "\(ExternalSurfaceTruth.notShippedInThisBuild). Share intake remains deferred until a dedicated extension target and handoff path exist.", icon: "square.and.arrow.up", valueLabel: ExternalSurfaceTruth.notShippedInThisBuild)
            ],
            settingsFooter: "Everything in this version runs from an explicit local-only trust posture. Capture storage is live under Today, routine review lives under Plan, portable backup and restore can stay local-first, validated route claims stay narrow, and unverified platform surfaces stay conservative in copy.",
            notificationAuthorization: ProfileNotificationAuthorization(
                statusLabel: "Not requested",
                detail: "Not requested yet.",
                canRequestAuthorization: true,
                actionTitle: "Enable notifications"
            ),
            preferences: ProfilePreferencesState(preferredTab: .today, appearancePreference: .system, reviewCadenceDays: 7, localOnlyModeEnabled: true)
        )
    )
}
