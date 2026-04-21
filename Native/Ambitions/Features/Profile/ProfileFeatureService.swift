import Foundation

struct RepositoryBackedProfileService: ProfileServicing {
    let repositories: AppRepositories
    let syncCapability: any SyncCapability
    let notificationService: any NotificationServicing

    init(
        repositories: AppRepositories,
        syncCapability: any SyncCapability = LocalOnlySyncCapability(),
        notificationService: any NotificationServicing = StubNotificationService()
    ) {
        self.repositories = repositories
        self.syncCapability = syncCapability
        self.notificationService = notificationService
    }

    func loadProfileDashboard() async throws -> ProfileDashboard {
        let snapshot = try await loadSnapshot()
        let syncStatus = await syncCapability.status()
        let notificationAuthorization = await notificationService.currentAuthorizationState()
        return makeDashboard(
            snapshot: snapshot,
            syncStatus: syncStatus,
            notificationAuthorization: notificationAuthorization
        )
    }

    func saveProfilePreferences(_ preferences: ProfilePreferencesUpdate) async throws -> ProfileDashboard {
        var state = try await repositories.appState.loadState()
        state.preferredTab = preferences.preferredTab.canonicalTopLevelTab
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

    func makeDashboard(
        snapshot: Snapshot,
        syncStatus: SyncCapabilityStatus,
        notificationAuthorization: NotificationAuthorizationState
    ) -> ProfileDashboard {
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
        let notificationStatus = notificationAuthorizationStatus(notificationAuthorization)

        return ProfileDashboard(
            title: profileTitle,
            subtitle: "This build keeps planning data in explicit local-only mode. Notifications, widgets, Live Activity, routes, and navigation shortcuts are \(ExternalSurfaceTruth.pendingBatch36Validation). Share Extension status: \(ExternalSurfaceTruth.notShippedInThisBuild).",
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
            settingsSubtitle: "These preferences are persisted on device and external-surface status stays aligned to the Batch 36 validation result without overstating unverified platform behavior.",
            settings: [
                SettingsItem(id: "profile-storage", title: "Planning storage", subtitle: "Goals, habits, evidence, and feedback all read from the native repository.", icon: "internaldrive", valueLabel: "Local-only mode"),
                SettingsItem(id: "profile-tab", title: "Default tab", subtitle: "Used on the next cold launch.", icon: "square.grid.2x2", valueLabel: snapshot.appState.preferredTab.canonicalTopLevelTab.title),
                SettingsItem(id: "profile-appearance", title: "Appearance", subtitle: "Choose whether Ambitions follows the system or stays explicit.", icon: "circle.lefthalf.filled", valueLabel: snapshot.appState.appearancePreference.title),
                SettingsItem(id: "profile-review", title: "Review cadence", subtitle: "How often Profile frames a planning reset.", icon: "clock.arrow.circlepath", valueLabel: reviewLabel(days: snapshot.appState.reviewCadenceDays)),
                SettingsItem(id: "profile-trust", title: "Trust posture", subtitle: "Portable backup/restore is designed for local-first continuity without implying a live cloud backend.", icon: "lock.shield", valueLabel: syncStatus.detail),
                SettingsItem(
                    id: "profile-notifications",
                    title: "Notifications",
                    subtitle: "\(ExternalSurfaceTruth.pendingBatch36Validation). Authorization: \(notificationStatus.detail)",
                    icon: "bell.badge",
                    valueLabel: notificationStatus.statusLabel
                ),
                SettingsItem(
                    id: "profile-widgets",
                    title: "Widgets and Live Activity",
                    subtitle: "\(ExternalSurfaceTruth.pendingBatch36Validation). These surfaces stay read-only in this batch and still need explicit manual checks.",
                    icon: "rectangle.3.group",
                    valueLabel: ExternalSurfaceTruth.pendingBatch36Validation
                ),
                SettingsItem(
                    id: "profile-app-intents",
                    title: "Navigation shortcuts",
                    subtitle: "\(ExternalSurfaceTruth.pendingBatch36Validation). App Intents stay navigation-only and open Today, Plan, or the Captures inbox without creating or mutating records.",
                    icon: "sparkles.rectangle.stack",
                    valueLabel: ExternalSurfaceTruth.pendingBatch36Validation
                ),
                SettingsItem(
                    id: "profile-share-extension",
                    title: "Share Extension",
                    subtitle: "\(ExternalSurfaceTruth.notShippedInThisBuild). Share intake remains deferred until a dedicated extension target and handoff path exist.",
                    icon: "square.and.arrow.up",
                    valueLabel: ExternalSurfaceTruth.notShippedInThisBuild
                ),
            ],
            settingsFooter: "Everything in this version runs from an explicit local-only trust posture. Capture storage is live under Today, routine review lives under Plan, portable backup and restore can stay local-first, validated route claims stay narrow, and unverified platform surfaces stay conservative in copy.",
            notificationAuthorization: notificationStatus,
            preferences: ProfilePreferencesState(
                preferredTab: snapshot.appState.preferredTab.canonicalTopLevelTab,
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

    func notificationAuthorizationStatus(_ state: NotificationAuthorizationState) -> ProfileNotificationAuthorization {
        switch state {
        case .notDetermined:
            return ProfileNotificationAuthorization(
                statusLabel: "Not requested",
                detail: "Not requested yet.",
                canRequestAuthorization: true,
                actionTitle: "Enable notifications"
            )
        case .denied:
            return ProfileNotificationAuthorization(
                statusLabel: "Denied",
                detail: "Denied in system settings.",
                canRequestAuthorization: false,
                actionTitle: nil
            )
        case .authorized:
            return ProfileNotificationAuthorization(
                statusLabel: "Allowed",
                detail: "Allowed for local reminders.",
                canRequestAuthorization: false,
                actionTitle: nil
            )
        case .provisional:
            return ProfileNotificationAuthorization(
                statusLabel: "Allowed",
                detail: "Provisionally allowed for local reminders.",
                canRequestAuthorization: false,
                actionTitle: nil
            )
        case .ephemeral:
            return ProfileNotificationAuthorization(
                statusLabel: "Allowed",
                detail: "Temporarily allowed for local reminders.",
                canRequestAuthorization: false,
                actionTitle: nil
            )
        }
    }
}
