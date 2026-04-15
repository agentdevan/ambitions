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
        state.appearancePreference = preferences.appearancePreference
        state.reviewCadenceDays = max(1, preferences.reviewCadenceDays)
        state.localOnlyModeEnabled = true
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
        let connectedFeaturesAvailable = false
        let activeGoals = snapshot.goals.filter { $0.state == .active }.count
        let liveHabits = snapshot.goals.filter { goal in
            guard let step = HabitGoalSemantics.preferredStep(in: goal) else { return false }
            return HabitGoalSemantics.isHabitLike(goal: goal, step: step)
        }.count
        let trimmedName = snapshot.appState.userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let initials = trimmedName
            .split(separator: " ")
            .prefix(2)
            .map { String($0.prefix(1)).uppercased() }
            .joined()
        let profileTitle = trimmedName.isEmpty ? "Your profile" : trimmedName

        return ProfileDashboard(
            title: profileTitle,
            subtitle: "This build keeps planning data on-device. Account sync, notifications, and widgets are not part of the current shipped feature surface.",
            initials: initials.isEmpty ? "U" : initials,
            badges: [
                "On-device only",
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
                SettingsItem(id: "profile-storage", title: "Planning storage", subtitle: "Goals, habits, evidence, and feedback all read from the native repository.", icon: "internaldrive", valueLabel: "On-device only"),
                SettingsItem(id: "profile-tab", title: "Default tab", subtitle: "Used on the next cold launch.", icon: "square.grid.2x2", valueLabel: snapshot.appState.preferredTab.title),
                SettingsItem(id: "profile-appearance", title: "Appearance", subtitle: "Choose whether Ambitions follows the system or stays explicit.", icon: "circle.lefthalf.filled", valueLabel: snapshot.appState.appearancePreference.title),
                SettingsItem(id: "profile-review", title: "Review cadence", subtitle: "How often Profile frames a planning reset.", icon: "clock.arrow.circlepath", valueLabel: reviewLabel(days: snapshot.appState.reviewCadenceDays)),
                SettingsItem(
                    id: "profile-scope",
                    title: "Connected features",
                    subtitle: connectedFeaturesAvailable
                        ? "This build can connect account-backed features."
                        : "Account sync, notifications, and widgets are not available in this build.",
                    icon: "person.badge.key",
                    valueLabel: connectedFeaturesAvailable ? "Available" : "Not included"
                )
            ],
            settingsFooter: "Everything in this version runs from on-device persistence. There is no connected account or background delivery path to configure yet.",
            preferences: ProfilePreferencesState(
                preferredTab: snapshot.appState.preferredTab,
                appearancePreference: snapshot.appState.appearancePreference,
                reviewCadenceDays: snapshot.appState.reviewCadenceDays,
                localOnlyModeEnabled: true
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
