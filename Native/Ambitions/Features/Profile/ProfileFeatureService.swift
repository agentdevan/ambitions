import Foundation

struct RepositoryBackedProfileService: ProfileServicing {
    let repositories: AppRepositories

    func loadProfileDashboard() async throws -> ProfileDashboard {
        let snapshot = try await loadSnapshot()
        return makeDashboard(snapshot: snapshot)
    }

    func saveProfilePreferences(_ preferences: ProfilePreferencesUpdate) async throws -> ProfileDashboard {
        var state = try await repositories.appState.loadState()
        state.preferredTab = preferences.preferredTab
        state.reviewCadenceDays = max(1, preferences.reviewCadenceDays)
        state.localOnlyModeEnabled = preferences.localOnlyModeEnabled
        try await repositories.appState.saveState(state)
        return try await loadProfileDashboard()
    }
}

private extension RepositoryBackedProfileService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let appState: AppStateSnapshot
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let appState = repositories.appState.loadState()

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            appState: appState
        )
    }

    func makeDashboard(snapshot: Snapshot) -> ProfileDashboard {
        let activeGoals = snapshot.goals.filter { $0.state == .active }.count
        let liveHabits = snapshot.goals.filter { goal in
            guard let step = HabitGoalSemantics.preferredStep(in: goal) else { return false }
            return HabitGoalSemantics.isHabitLike(goal: goal, step: step)
        }.count
        let initials = snapshot.appState.userDisplayName
            .split(separator: " ")
            .prefix(2)
            .map { String($0.prefix(1)).uppercased() }
            .joined()

        return ProfileDashboard(
            title: snapshot.appState.userDisplayName,
            subtitle: snapshot.appState.localOnlyModeEnabled
                ? "Local-first RC build with native persistence as the source of truth."
                : "Native persistence is active while connected features stay intentionally out of scope for RC 1.0.",
            initials: initials.isEmpty ? "A" : initials,
            badges: [
                snapshot.appState.localOnlyModeEnabled ? "Local-first" : "Connected later",
                "Native persistence",
                snapshot.drafts.contains(where: { $0.latestResultKind == .clarificationRequired }) ? "Clarification-aware" : "Stable planner"
            ],
            stats: [
                MetricSummary(id: "profile-active-goals", title: "Open goals", value: "\(activeGoals)", detail: "Active native goals", icon: "target"),
                MetricSummary(id: "profile-habits", title: "Tracked habits", value: "\(liveHabits)", detail: "Recurring loops in the same repository", icon: "repeat"),
                MetricSummary(id: "profile-review", title: "Review cadence", value: reviewLabel(days: snapshot.appState.reviewCadenceDays), detail: "Local planning reset rhythm", icon: "calendar"),
                MetricSummary(id: "profile-evidence", title: "Evidence records", value: "\(snapshot.evidence.count)", detail: "Visible progress signals on device", icon: "sparkles")
            ],
            settingsTitle: "Local preferences",
            settingsSubtitle: "These preferences are persisted on device and already shape the native experience.",
            settings: [
                SettingsItem(id: "profile-storage", title: "Planning storage", subtitle: "Goals, habits, evidence, and feedback all read from the native repository.", icon: "internaldrive", valueLabel: snapshot.appState.localOnlyModeEnabled ? "Local-first" : "Hybrid later"),
                SettingsItem(id: "profile-tab", title: "Default tab", subtitle: "Used on the next cold launch.", icon: "square.grid.2x2", valueLabel: snapshot.appState.preferredTab.title),
                SettingsItem(id: "profile-review", title: "Review cadence", subtitle: "How often Profile frames a planning reset.", icon: "clock.arrow.circlepath", valueLabel: reviewLabel(days: snapshot.appState.reviewCadenceDays)),
                SettingsItem(id: "profile-scope", title: "Connected account", subtitle: "Account, sync, notifications, and widgets are intentionally outside RC 1.0 blocker scope.", icon: "person.badge.key", valueLabel: "Post-1.0")
            ],
            settingsFooter: "This RC build is intentionally local-first. Apple-side notification, widget, and account validation can happen after the core native product proves stable.",
            preferences: ProfilePreferencesState(
                preferredTab: snapshot.appState.preferredTab,
                reviewCadenceDays: snapshot.appState.reviewCadenceDays,
                localOnlyModeEnabled: snapshot.appState.localOnlyModeEnabled
            )
        )
    }

    func reviewLabel(days: Int) -> String {
        if days <= 1 {
            return "Daily"
        }
        if days == 7 {
            return "Weekly"
        }
        return "Every \(days) days"
    }
}
