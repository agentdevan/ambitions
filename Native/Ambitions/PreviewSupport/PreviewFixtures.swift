import AmbitionsDesignSystem
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
            appearancePreference: .system,
            accentFamily: .sage
        ),
        todayDashboard: TodayDashboard(
            title: "Steady execution, light load",
            subtitle: "Three deliberate moves are enough to keep momentum today.",
            completionLabel: "58% aligned",
            targets: [
                DashboardProgressItem(id: "today-1", title: "Tighten external-surface truth", detail: "Keep docs, Profile, and previews aligned", progress: 0.82, trailingValue: "82%", statusLabel: "In flight"),
                DashboardProgressItem(id: "today-2", title: "Review validation coverage", detail: "Keep routing, trust copy, and EventKit checks current", progress: 0.45, trailingValue: "45%", statusLabel: "Queued"),
                DashboardProgressItem(id: "today-3", title: "Prepare release notes", detail: "Make local build and test guidance reproducible", progress: 0.67, trailingValue: "67%", statusLabel: "Ready")
            ],
            focus: FocusSession(
                headline: "Keep the hardening pass honest",
                subtitle: "Reduce drift, keep scope tight, and only certify what we can prove",
                reason: "The fastest way to protect trust is to align copy, validation, and release notes with the product that actually ships today.",
                durationLabel: "45 min block",
                energyLabel: "Confidence",
                progress: 0.74,
                supportSteps: [
                    "Refresh external-surface status copy where it drifted.",
                    "Keep previews obviously non-production but current.",
                    "Use the existing build and test seams before widening scope."
                ]
            ),
            freeTime: FreeTimeSuggestion(
                title: "Recovery window available",
                subtitle: "You have margin after the validation pass.",
                windowLabel: "30 min free",
                suggestionTitle: "Review the conservative trust notes",
                suggestionDetail: "Use the spare window to confirm which external surfaces are proven here and which still need manual follow-up."
            )
        ),
        captures: [
            Capture(
                id: "preview-capture-1",
                createdAt: "2026-04-15T09:20:00Z",
                updatedAt: "2026-04-15T09:20:00Z",
                rawText: "Capture the repo-truth drift before the next docs pass.",
                sourceType: .todayQuickCapture,
                status: .goalBound,
                linkedGoalID: "goal-native",
                triage: CaptureTriageMetadata(destination: .attachToGoal, hint: "Keep with the hardening pass.")
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
            subtitle: "Three outcome tracks are currently shaping the week.",
            goals: [
                GoalSummary(id: "goal-native", title: "Close the hardening pass", subtitle: "Repo truth, validation coverage, and release readiness", progressLabel: "Hardening", statusLabel: "Highest leverage"),
                GoalSummary(id: "goal-learning", title: "Learn advanced vocal mixing", subtitle: "A learning track that stays untimed and evidence-based", progressLabel: "Starter path", statusLabel: "In motion"),
                GoalSummary(id: "goal-support", title: "Help Maya rebuild a reading rhythm", subtitle: "Supportive structure that keeps Maya as the owner", progressLabel: "Support rhythm", statusLabel: "Active")
            ],
            milestone: MilestonePrompt(
                title: "Keep the next validation step obvious",
                subtitle: "The app already ships the current shell; this pass keeps trust and release notes aligned.",
                prompt: "Once the truth sweep is clean, rerun the native validation flow and keep any remaining platform claims conservative.",
                confidenceLabel: "Clear next step"
            )
        ),
        habitsDashboard: PreviewHabitsScenarios.seeded,
        insightsDashboard: InsightsDashboard(
            title: "Behavioral readout",
            subtitle: "Signals are organized to make drift, momentum, and adaptation easier to trust at a glance.",
            posture: InsightsPostureSummary(
                title: "Adaptation is helping the plan stay believable",
                detail: "Corrections and smaller versions are turning into visible follow-through instead of churn.",
                label: "Adapting",
                visualState: .selected
            ),
            stats: [
                MetricSummary(id: "insight-1", title: "Focus quality", value: "76", detail: "Composite score", icon: "scope"),
                MetricSummary(id: "insight-2", title: "Plan adherence", value: "63%", detail: "Week to date", icon: "chart.bar"),
                MetricSummary(id: "insight-3", title: "Recovery speed", value: "1.8x", detail: "Vs prior week", icon: "waveform.path.ecg"),
                MetricSummary(id: "insight-4", title: "Drift alerts", value: "2", detail: "Open", icon: "bell")
            ],
            summary: "Recent adaptation works best when the next step stays small, explicit, and grounded in visible evidence.",
            changeSummaries: [
                InsightsChangeSummary(id: "insight-change-1", title: "Plan changes", detail: "Feedback is actively changing how the plan is being carried this week.", valueLabel: "2", icon: "arrow.triangle.branch", visualState: .selected),
                InsightsChangeSummary(id: "insight-change-2", title: "Drift and friction", detail: "Recent friction is the clearest reason some work needs gentler scope.", valueLabel: "1", icon: "waveform.path.ecg", visualState: .warning),
                InsightsChangeSummary(id: "insight-change-3", title: "Goals needing care", detail: "One active area still needs clarification before it can be trusted fully.", valueLabel: "1", icon: "lifepreserver", visualState: .warning),
                InsightsChangeSummary(id: "insight-change-4", title: "Visible follow-through", detail: "Completions and minimum versions are carrying the most useful signal right now.", valueLabel: "4", icon: "checkmark.circle", visualState: .success)
            ],
            goalStatuses: [
                InsightsGoalStatusItem(id: "insight-goal-1", target: GoalRouteTarget(goalID: "goal-native"), title: "Close the hardening pass", summary: "This goal has visible evidence this week, which keeps its current path grounded in real follow-through.", statusLabel: "Believable", visualState: .success),
                InsightsGoalStatusItem(id: "insight-goal-2", target: GoalRouteTarget(goalID: "goal-growth"), title: "Retention loop", summary: "Recent friction suggests the current version of the work needs a smaller or clearer next move.", statusLabel: "Adjusting", visualState: .selected)
            ],
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
            trendSummary: "Execution improved once the week narrowed to one clear hardening pass.",
            activitiesTitle: "Recent signals",
            activitiesSubtitle: "Recent evidence, decisions, and changes that explain the current readout.",
            activities: [
                ActivitySummary(id: "activity-1", title: "Completed deep work block", subtitle: "Today", timestamp: "09:40", icon: "checkmark.circle.fill", badge: "Win"),
                ActivitySummary(id: "activity-2", title: "Rescoped feature backlog", subtitle: "Yesterday", timestamp: "17:15", icon: "arrow.triangle.branch", badge: "Decision"),
                ActivitySummary(id: "activity-3", title: "Updated release validation notes", subtitle: "Yesterday", timestamp: "14:05", icon: "doc.text", badge: nil)
            ]
        ),
        profileDashboard: ProfileDashboard(
            title: "Preview User",
            subtitle: "Defaults, personalization, and local-only trust status all stay explicit here without turning Profile into a workflow surface.",
            initials: "PU",
            badges: ["Local-first", "Hardening pass", "Design system"],
            stats: [
                MetricSummary(id: "profile-1", title: "Open ambitions", value: "3", detail: "In active review", icon: "target"),
                MetricSummary(id: "profile-2", title: "Tracked habits", value: "6", detail: "Current set", icon: "repeat"),
                MetricSummary(id: "profile-3", title: "Review cadence", value: "Weekly", detail: "Sunday reset", icon: "calendar"),
                MetricSummary(id: "profile-4", title: "Appearance", value: "System", detail: "Follows the device by default", icon: "circle.lefthalf.filled")
            ],
            planningSummary: ProfilePlanningSummary(
                title: "Planning defaults",
                subtitle: "Profile keeps the current local planning posture legible without taking over day-to-day workflow.",
                items: [
                    SettingsItem(id: "profile-plan-1", title: "Active goals", subtitle: "Goals currently shaping the local portfolio.", icon: "target", valueLabel: "3"),
                    SettingsItem(id: "profile-plan-2", title: "Review cadence", subtitle: "How often the app frames a reset.", icon: "clock.arrow.circlepath", valueLabel: "Weekly"),
                    SettingsItem(id: "profile-plan-3", title: "Needs clarification", subtitle: "One planning draft remains visible before it can become trusted work.", icon: "questionmark.bubble", valueLabel: "1"),
                    SettingsItem(id: "profile-plan-4", title: "Recent planning friction", subtitle: "Recent feedback suggests some work still needs gentler scope.", icon: "waveform.path.ecg", valueLabel: "1")
                ]
            ),
            preferencesSection: ProfileSectionGroup(
                title: "Personalization",
                subtitle: "These controls write directly into the persisted app state the shell already uses.",
                items: [
                    SettingsItem(id: "profile-setting-1", title: "Planning storage", subtitle: "Native persistence is active for goals, habits, and evidence", icon: "internaldrive", valueLabel: "Local-first"),
                    SettingsItem(id: "profile-setting-2", title: "Default tab", subtitle: "Used on the next cold launch", icon: "square.grid.2x2", valueLabel: "Today"),
                    SettingsItem(id: "profile-setting-3", title: "Appearance", subtitle: "System follows the device while explicit themes stay selectable", icon: "circle.lefthalf.filled", valueLabel: "System"),
                    SettingsItem(id: "profile-setting-4", title: "Accent family", subtitle: "Curated accents keep the shared system expressive without turning personalization into a toy.", icon: "paintpalette", valueLabel: "Sage"),
                    SettingsItem(id: "profile-setting-5", title: "Review cadence", subtitle: "The same reset rhythm used by the current local planning flow.", icon: "calendar", valueLabel: "Weekly")
                ],
                footer: nil
            ),
            trustSection: ProfileSectionGroup(
                title: "Trust and external status",
                subtitle: "\(ExternalSurfaceTruth.verifiedRoutingTruth). Other external surfaces stay conservative here until manual checks confirm them.",
                items: [
                    SettingsItem(id: "profile-setting-6", title: "Notifications", subtitle: "\(ExternalSurfaceTruth.availableButNeedsManualVerification). Authorization: Not requested yet.", icon: "bell.badge", valueLabel: "Not requested"),
                    SettingsItem(id: "profile-setting-7", title: "Widgets and Live Activity", subtitle: "\(ExternalSurfaceTruth.availableButNeedsManualVerification). These surfaces stay read-only and still need explicit manual checks.", icon: "rectangle.3.group", valueLabel: ExternalSurfaceTruth.availableButNeedsManualVerification),
                    SettingsItem(id: "profile-setting-8", title: "Navigation shortcuts", subtitle: "\(ExternalSurfaceTruth.availableButNeedsManualVerification). App Intents stay navigation-only and open Today, Plan, or the Captures inbox without creating or mutating records.", icon: "sparkles.rectangle.stack", valueLabel: ExternalSurfaceTruth.availableButNeedsManualVerification),
                    SettingsItem(id: "profile-setting-9", title: "Share Extension", subtitle: "\(ExternalSurfaceTruth.notShippedInThisBuild). Share intake remains deferred until a dedicated extension target and handoff path exist.", icon: "square.and.arrow.up", valueLabel: ExternalSurfaceTruth.notShippedInThisBuild)
                ],
                footer: "Everything in this version runs from an explicit local-only trust posture. Capture storage is live under Today, routine review lives under Plan, portable backup and restore can stay local-first, routing truth stays explicit, and unverified platform surfaces stay conservative in copy."
            ),
            notificationAuthorization: ProfileNotificationAuthorization(
                statusLabel: "Not requested",
                detail: "Not requested yet.",
                canRequestAuthorization: true,
                actionTitle: "Enable notifications"
            ),
            preferences: ProfilePreferencesState(preferredTab: .today, appearancePreference: .system, accentFamily: .sage, reviewCadenceDays: 7, localOnlyModeEnabled: true)
        )
    )
}
