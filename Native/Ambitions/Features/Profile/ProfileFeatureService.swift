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
        state.accentFamily = preferences.accentFamily
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
        let clarificationCount = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }.count
        let blockedCount = snapshot.drafts.filter { $0.latestResultKind == .blocked }.count
        let openCaptures = snapshot.feedback.filter(isPlanningFriction).count

        return ProfileDashboard(
            title: profileTitle,
            subtitle: "Defaults, personalization, and local-only trust status all stay explicit here without turning Profile into a workflow surface.",
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
            planningSummary: ProfilePlanningSummary(
                title: "Planning defaults",
                subtitle: "Profile keeps the current local planning posture legible without taking over day-to-day workflow.",
                items: [
                    SettingsItem(id: "profile-plan-active-goals", title: "Active goals", subtitle: "Goals currently shaping the local portfolio.", icon: "target", valueLabel: "\(activeGoals)"),
                    SettingsItem(id: "profile-plan-review-cadence", title: "Review cadence", subtitle: "How often the app frames a reset.", icon: "clock.arrow.circlepath", valueLabel: reviewLabel(days: snapshot.appState.reviewCadenceDays)),
                    SettingsItem(id: "profile-plan-clarity", title: "Needs clarification", subtitle: blockedCount + clarificationCount == 0 ? "No planning draft is waiting on unblock work right now." : "Blocked or clarification-first drafts remain visible here so planning truth stays explicit.", icon: "questionmark.bubble", valueLabel: "\(blockedCount + clarificationCount)"),
                    SettingsItem(id: "profile-plan-friction", title: "Recent planning friction", subtitle: openCaptures == 0 ? "No recent correction signal is changing the planning posture right now." : "Recent feedback suggests some work still needs gentler scope.", icon: "waveform.path.ecg", valueLabel: "\(openCaptures)")
                ]
            ),
            preferencesSection: ProfileSectionGroup(
                title: "Personalization",
                subtitle: "These controls write directly into the persisted app state the shell already uses.",
                items: [
                    SettingsItem(id: "profile-storage", title: "Planning storage", subtitle: "Goals, habits, evidence, and feedback all read from the native repository.", icon: "internaldrive", valueLabel: "Local-only mode"),
                    SettingsItem(id: "profile-tab", title: "Default tab", subtitle: "Used on the next cold launch.", icon: "square.grid.2x2", valueLabel: snapshot.appState.preferredTab.canonicalTopLevelTab.title),
                    SettingsItem(id: "profile-appearance", title: "Appearance", subtitle: "Choose whether Ambitions follows the system or stays explicit.", icon: "circle.lefthalf.filled", valueLabel: snapshot.appState.appearancePreference.title),
                    SettingsItem(id: "profile-accent", title: "Accent family", subtitle: "Curated accents keep the shared system expressive without turning personalization into a toy.", icon: "paintpalette", valueLabel: snapshot.appState.accentFamily.title),
                    SettingsItem(id: "profile-review", title: "Review cadence", subtitle: "The same reset rhythm used by the current local planning flow.", icon: "calendar", valueLabel: reviewLabel(days: snapshot.appState.reviewCadenceDays))
                ],
                footer: nil
            ),
            trustSection: ProfileSectionGroup(
                title: "Trust and external status",
                subtitle: "\(ExternalSurfaceTruth.verifiedRoutingTruth). Other external surfaces stay conservative here until manual checks confirm them.",
                items: [
                    SettingsItem(id: "profile-trust", title: "Trust posture", subtitle: "Portable backup/restore is designed for local-first continuity without implying a live cloud backend.", icon: "lock.shield", valueLabel: syncStatus.detail),
                    SettingsItem(
                        id: "profile-notifications",
                        title: "Notifications",
                        subtitle: "\(ExternalSurfaceTruth.availableButNeedsManualVerification). Authorization: \(notificationStatus.detail)",
                        icon: "bell.badge",
                        valueLabel: notificationStatus.statusLabel
                    ),
                    SettingsItem(
                        id: "profile-widgets",
                        title: "Widgets and Live Activity",
                        subtitle: "\(ExternalSurfaceTruth.availableButNeedsManualVerification). These surfaces stay read-only and still need explicit manual checks.",
                        icon: "rectangle.3.group",
                        valueLabel: ExternalSurfaceTruth.availableButNeedsManualVerification
                    ),
                    SettingsItem(
                        id: "profile-app-intents",
                        title: "Navigation shortcuts",
                        subtitle: "\(ExternalSurfaceTruth.availableButNeedsManualVerification). App Intents stay navigation-only and open Today, Plan, or the Captures inbox without creating or mutating records.",
                        icon: "sparkles.rectangle.stack",
                        valueLabel: ExternalSurfaceTruth.availableButNeedsManualVerification
                    ),
                    SettingsItem(
                        id: "profile-share-extension",
                        title: "Share Extension",
                        subtitle: "\(ExternalSurfaceTruth.notShippedInThisBuild). Share intake remains deferred until a dedicated extension target and handoff path exist.",
                        icon: "square.and.arrow.up",
                        valueLabel: ExternalSurfaceTruth.notShippedInThisBuild
                    )
                ],
                footer: "Everything in this version runs from an explicit local-only trust posture. Capture storage is live under Today, routine review lives under Plan, portable backup and restore can stay local-first, routing truth stays explicit, and unverified platform surfaces stay conservative in copy."
            ),
            notificationAuthorization: notificationStatus,
            preferences: ProfilePreferencesState(
                preferredTab: snapshot.appState.preferredTab.canonicalTopLevelTab,
                appearancePreference: snapshot.appState.appearancePreference,
                accentFamily: snapshot.appState.accentFamily,
                reviewCadenceDays: snapshot.appState.reviewCadenceDays,
                localOnlyModeEnabled: true
            )
        )
    }

    func isPlanningFriction(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .skipped, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
            return true
        default:
            return false
        }
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
