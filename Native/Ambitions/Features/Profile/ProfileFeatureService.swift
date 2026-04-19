import Foundation

struct RepositoryBackedProfileService: ProfileServicing {
    let repositories: AppRepositories
    let syncCapability: any SyncCapability

    init(
        repositories: AppRepositories,
        syncCapability: any SyncCapability = LocalOnlySyncCapability()
    ) {
        self.repositories = repositories
        self.syncCapability = syncCapability
    }

    func loadProfileDashboard() async throws -> ProfileDashboard {
        let snapshot = try await loadSnapshot()
        let syncStatus = await syncCapability.status()
        return makeDashboard(snapshot: snapshot, syncStatus: syncStatus)
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

    func makeDashboard(snapshot: Snapshot, syncStatus: SyncCapabilityStatus) -> ProfileDashboard {
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
            subtitle: "This build keeps planning data in explicit local-only mode. Today quick capture and the Captures tab are active in the native app, while account sync is not implemented and external device surfaces still need separate validation.",
            initials: initials.isEmpty ? "U" : initials,
            badges: [
                "Local-only trust",
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
            settingsSubtitle: "These preferences are persisted on device and already shape the native local-only experience.",
            settings: [
                SettingsItem(id: "profile-storage", title: "Planning storage", subtitle: "Goals, habits, evidence, and feedback all read from the native repository.", icon: "internaldrive", valueLabel: "Local-only mode"),
                SettingsItem(id: "profile-tab", title: "Default tab", subtitle: "Used on the next cold launch.", icon: "square.grid.2x2", valueLabel: snapshot.appState.preferredTab.title),
                SettingsItem(id: "profile-appearance", title: "Appearance", subtitle: "Choose whether Ambitions follows the system or stays explicit.", icon: "circle.lefthalf.filled", valueLabel: snapshot.appState.appearancePreference.title),
                SettingsItem(id: "profile-review", title: "Review cadence", subtitle: "How often Profile frames a planning reset.", icon: "clock.arrow.circlepath", valueLabel: reviewLabel(days: snapshot.appState.reviewCadenceDays)),
                SettingsItem(id: "profile-trust", title: "Trust posture", subtitle: "Portable backup/restore is designed for local-first continuity without implying a live cloud backend.", icon: "lock.shield", valueLabel: syncStatus.detail),
                SettingsItem(
                    id: "profile-scope",
                    title: "Connected features",
                    subtitle: "Notification scheduling and calendar/reminder wiring exist in the native app. Widget and Live Activity foundations are present in the repo, but they still need their own validation pass.",
                    icon: "person.badge.key",
                    valueLabel: "Native foundations"
                )
            ],
            settingsFooter: "Everything in this version runs from an explicit local-only trust posture. Capture storage is live in the app today, portable backup and restore can stay local-first, widget and Live Activity foundations still need validation, and there is no account sync configuration to manage yet.",
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
