import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedProfileService: ProfileServicing {
    let repositories: AppRepositories
    let syncCapability: any SyncCapability
    let notificationService: any NotificationServicing
    let calendarRemindersService: any CalendarRemindersServicing

    init(
        repositories: AppRepositories,
        syncCapability: any SyncCapability = LocalOnlySyncCapability(),
        notificationService: any NotificationServicing = StubNotificationService(),
        calendarRemindersService: any CalendarRemindersServicing = StubCalendarRemindersService()
    ) {
        self.repositories = repositories
        self.syncCapability = syncCapability
        self.notificationService = notificationService
        self.calendarRemindersService = calendarRemindersService
    }

    func loadProfileDashboard() async throws -> ProfileDashboard {
        let snapshot = try await loadSnapshot()
        let syncStatus = await syncCapability.status()
        let notificationAuthorization = await notificationService.currentAuthorizationState()
        let remindersAuthorization = await calendarRemindersService.authorizationState(for: .reminders)
        let calendarAuthorization = await calendarRemindersService.authorizationState(for: .calendarEvents)
        return makeDashboard(
            snapshot: snapshot,
            syncStatus: syncStatus,
            notificationAuthorization: notificationAuthorization,
            remindersAuthorization: remindersAuthorization,
            calendarAuthorization: calendarAuthorization
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
        let captures: [Capture]
        let teachingSignals: [GoalTeachingSignal]
        let appState: AppStateSnapshot
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let captures = repositories.captures.listCaptures()
        async let teachingSignals = repositories.teaching.listSignals(goalID: nil)
        async let appState = repositories.appState.loadState()

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            captures: captures,
            teachingSignals: teachingSignals,
            appState: appState
        )
    }

    func makeDashboard(
        snapshot: Snapshot,
        syncStatus: SyncCapabilityStatus,
        notificationAuthorization: NotificationAuthorizationState,
        remindersAuthorization: CalendarRemindersAuthorizationState,
        calendarAuthorization: CalendarRemindersAuthorizationState
    ) -> ProfileDashboard {
        let activeGoals = snapshot.goals.filter { $0.state == .active }.count
        let liveHabits = snapshot.goals.filter { goal in
            guard let step = HabitGoalSemantics.preferredStep(in: goal) else { return false }
            return HabitGoalSemantics.isHabitLike(goal: goal, step: step)
        }.count
        let clarificationCount = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }.count
        let blockedCount = snapshot.drafts.filter { $0.latestResultKind == .blocked }.count
        let openCaptures = snapshot.captures.filter { $0.status != .archived }.count
        let trimmedName = snapshot.appState.userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let profileTitle = trimmedName.isEmpty ? "Your system" : "\(trimmedName)'s system"
        let notificationStatus = notificationAuthorizationStatus(notificationAuthorization)
        let syncState = syncVisualState(syncStatus)
        let appearanceSummary = "\(snapshot.appState.appearancePreference.title) mode with \(snapshot.appState.accentFamily.title)"
        let contextSignals = snapshot.evidence.count + snapshot.feedback.count + snapshot.teachingSignals.count

        return ProfileDashboard(
            hero: ProfileHeroState(
                title: profileTitle,
                subtitle: "Configuration, trust, and optional personalization stay calm and explicit here.",
                dominantTruth: dominantTruth(
                    syncStatus: syncStatus,
                    notificationStatus: notificationStatus,
                    appearanceSummary: appearanceSummary
                ),
                supportingTruth: "System configuration stays separate from workflow. Optional context stays inspectable, local-first, and reversible.",
                trustWhisper: "Current trust posture: \(syncStatus.detail) Notifications are \(notificationStatus.statusLabel.lowercased()) for local reminders.",
                status: syncState,
                pills: [
                    ProfileStatusPill(id: "profile-pill-appearance", title: appearanceSummary, icon: "paintpalette", state: .selected),
                    ProfileStatusPill(id: "profile-pill-sync", title: syncStatus.detail, icon: "lock.shield", state: syncState),
                    ProfileStatusPill(
                        id: "profile-pill-context",
                        title: contextSignals == 0 ? "No optional context signals yet" : "\(contextSignals) context signals on device",
                        icon: "waveform.path.ecg",
                        state: contextSignals == 0 ? .default : .default
                    )
                ],
                stats: [
                    MetricSummary(id: "profile-active-goals", title: "Open goals", value: "\(activeGoals)", detail: "Active native goals", icon: "target"),
                    MetricSummary(id: "profile-habits", title: "Tracked habits", value: "\(liveHabits)", detail: "Recurring loops in the same system", icon: "repeat"),
                    MetricSummary(id: "profile-review", title: "Review cadence", value: reviewLabel(days: snapshot.appState.reviewCadenceDays), detail: "Reset rhythm", icon: "calendar"),
                    MetricSummary(id: "profile-context", title: "Context signals", value: "\(contextSignals)", detail: "Evidence, feedback, and teaching", icon: "sparkles")
                ]
            ),
            appearanceStudio: ProfileAppearanceStudioState(
                title: "Appearance Studio",
                subtitle: "Curated, authored control over mode and accent so the shell feels personal without turning into a skin chooser.",
                previewSummary: "Preview the current palette against system-style hierarchy before you save.",
                modeOptions: AppAppearancePreference.allCases.map { preference in
                    ProfileAppearanceOption(
                        id: "appearance-\(preference.rawValue)",
                        title: preference.title,
                        subtitle: appearanceSubtitle(for: preference),
                        preference: preference
                    )
                },
                accentOptions: AmbitionAccentFamily.allCases.map { family in
                    ProfileAccentOption(
                        id: "accent-\(family.rawValue)",
                        title: family.title,
                        subtitle: accentSubtitle(for: family),
                        family: family
                    )
                },
                previewSwatches: makePreviewSwatches(
                    selectedAppearance: snapshot.appState.appearancePreference,
                    selectedAccent: snapshot.appState.accentFamily
                ),
                footer: "Appearance changes use the existing shared theme system. Save keeps the choice for the next launch; leaving without saving preserves the current persisted default."
            ),
            trustCenter: ProfileTrustCenterState(
                title: "Trust Center",
                subtitle: "Trust should read as configuration truth, not a debug console. The pulse below stays calm and human-readable.",
                pulse: ProfileTrustPulseState(
                    title: "Sync pulse",
                    subtitle: syncPulseTitle(for: syncStatus),
                    detail: "Portable continuity stays explicit and local-first in this build. Future cloud or continuity productization remains deferred.",
                    state: syncState
                ),
                items: [
                    SettingsItem(
                        id: "profile-trust-sync",
                        title: "System trust posture",
                        subtitle: "The current runtime runs from on-device storage, portable backup/restore, and no implied live cloud backend.",
                        icon: "lock.shield",
                        valueLabel: syncStatus.detail
                    ),
                    SettingsItem(
                        id: "profile-trust-notifications",
                        title: "Notification pulse",
                        subtitle: "Local reminder scheduling exists on the current runtime. Authorization stays explicit here so ambient trust never feels hidden.",
                        icon: "bell.badge",
                        valueLabel: notificationStatus.statusLabel
                    ),
                    SettingsItem(
                        id: "profile-trust-routing",
                        title: "System status",
                        subtitle: "\(ExternalSurfaceTruth.verifiedRoutingTruth). External routes stay on canonical destinations, and ambient surfaces preserve local-first continuity language.",
                        icon: "arrow.triangle.branch",
                        valueLabel: "Calm"
                    )
                ],
                footer: "Batch 52 establishes the trust framing layer only. Batch 54 owns deeper continuity/sync-trust productization, so this surface stays truthful about what exists today."
            ),
            contextVault: ProfileContextVaultState(
                title: "Context Vault",
                subtitle: "Optional personal context is inspectable here before later compliance work deepens policy and export surfaces.",
                items: [
                    ProfileContextVaultItem(
                        id: "profile-vault-signals",
                        title: "Signals in use",
                        subtitle: "These are the current categories the app can already read from its native repositories.",
                        icon: "tray.full",
                        detail: "\(snapshot.evidence.count) evidence records, \(snapshot.feedback.count) feedback events, \(snapshot.teachingSignals.count) teaching signals"
                    ),
                    ProfileContextVaultItem(
                        id: "profile-vault-planning",
                        title: "Planning memory",
                        subtitle: "Clarifications, blocked drafts, and open captures stay visible so future intelligence work remains auditable.",
                        icon: "rectangle.stack.badge.person.crop",
                        detail: "\(clarificationCount + blockedCount) draft signals, \(openCaptures) open captures"
                    ),
                    ProfileContextVaultItem(
                        id: "profile-vault-identity",
                        title: "Personal defaults",
                        subtitle: "Name, launch defaults, and appearance stay separate from the execution surfaces they influence.",
                        icon: "person.text.rectangle",
                        detail: trimmedName.isEmpty ? "No display name stored" : trimmedName
                    )
                ],
                policyItems: [
                    ProfileSignalPolicyItem(
                        id: "profile-policy-optional",
                        title: "Optional by design",
                        detail: "Context is there to improve fit and trust. It is not required to use the core planning system.",
                        state: .default
                    ),
                    ProfileSignalPolicyItem(
                        id: "profile-policy-local",
                        title: "Local-first posture",
                        detail: "Signals stay on device in this build and should remain inspectable before any future continuity expansion.",
                        state: .selected
                    ),
                    ProfileSignalPolicyItem(
                        id: "profile-policy-explicit",
                        title: "Inspectable and understandable",
                        detail: "The app should be able to explain what signal types exist without feeling invasive or technical.",
                        state: .default
                    )
                ],
                footer: "This is a foundation layer, not a full privacy admin surface. It prepares future compliance and trust work without inventing Batch 53 or Batch 54 flows early."
            ),
            integrationsSection: ProfileSectionGroup(
                title: "Integrations and permissions",
                subtitle: "Only the system edges that materially affect trust or routing belong here.",
                items: [
                    SettingsItem(
                        id: "profile-integration-notifications",
                        title: "Notifications",
                        subtitle: notificationAuthorizationSubtitle(for: notificationStatus),
                        icon: "bell.badge",
                        valueLabel: notificationStatus.statusLabel
                    ),
                    SettingsItem(
                        id: "profile-integration-reminders",
                        title: "Reminders integration",
                        subtitle: "Reminder write paths exist on the current EventKit seam. Authorization stays explicit so scheduling trust is legible.",
                        icon: "checklist",
                        valueLabel: calendarAuthorizationLabel(remindersAuthorization)
                    ),
                    SettingsItem(
                        id: "profile-integration-calendar",
                        title: "Calendar integration",
                        subtitle: "Calendar event creation and conflict detection exist on the shared EventKit seam. Read depth depends on authorization level.",
                        icon: "calendar.badge.clock",
                        valueLabel: calendarAuthorizationLabel(calendarAuthorization)
                    ),
                    SettingsItem(
                        id: "profile-integration-widgets",
                        title: "Widgets and Live Activity",
                        subtitle: "\(ExternalSurfaceTruth.productizedNeedsPlatformReview). Widgets and Live Activity read the shared external snapshot, Now State Lease, and local-first continuity posture.",
                        icon: "rectangle.3.group",
                        valueLabel: ExternalSurfaceTruth.productizedNeedsPlatformReview
                    ),
                    SettingsItem(
                        id: "profile-integration-shortcuts",
                        title: "Navigation shortcuts",
                        subtitle: "\(ExternalSurfaceTruth.productizedNeedsPlatformReview). Shortcuts support quick capture, focus, recovery, plan, and canonical open routes through the shared external handoff path.",
                        icon: "sparkles.rectangle.stack",
                        valueLabel: ExternalSurfaceTruth.productizedNeedsPlatformReview
                    ),
                    SettingsItem(
                        id: "profile-integration-share",
                        title: "Share Extension",
                        subtitle: "\(ExternalSurfaceTruth.productizedNeedsPlatformReview). Shared text and URLs enter local Ambitions captures first, then land in the normal review or goal-creation path.",
                        icon: "square.and.arrow.up",
                        valueLabel: ExternalSurfaceTruth.productizedNeedsPlatformReview
                    )
                ],
                footer: "Notification and integration status should answer whether anything important needs attention without turning Profile into an admin checklist."
            ),
            defaultsSection: ProfileSectionGroup(
                title: "Personal defaults",
                subtitle: "These choices shape the shell, not the truth of your goals or day.",
                items: [
                    SettingsItem(
                        id: "profile-default-tab",
                        title: "Default landing tab",
                        subtitle: "Used on the next cold launch so re-entry starts where you prefer.",
                        icon: "square.grid.2x2",
                        valueLabel: snapshot.appState.preferredTab.canonicalTopLevelTab.title
                    ),
                    SettingsItem(
                        id: "profile-default-review",
                        title: "Review cadence",
                        subtitle: "How often the app frames a planning reset using the current local planning loop.",
                        icon: "clock.arrow.circlepath",
                        valueLabel: reviewLabel(days: snapshot.appState.reviewCadenceDays)
                    ),
                    SettingsItem(
                        id: "profile-default-storage",
                        title: "Storage mode",
                        subtitle: "Goals, captures, evidence, and teaching signals persist through the native on-device repositories.",
                        icon: "internaldrive",
                        valueLabel: snapshot.appState.localOnlyModeEnabled ? "Local-only" : "Unknown"
                    )
                ],
                footer: nil
            ),
            accountSection: ProfileSectionGroup(
                title: "Account and billing",
                subtitle: "This build stays explicit about what is not configured yet so Profile never implies hidden account requirements.",
                items: [
                    SettingsItem(
                        id: "profile-account-mode",
                        title: "Account mode",
                        subtitle: "No sign-in or cloud account is required for the current shipping native experience.",
                        icon: "person.crop.circle",
                        valueLabel: "On-device only"
                    ),
                    SettingsItem(
                        id: "profile-account-billing",
                        title: "Billing",
                        subtitle: "Subscriptions, digital unlocks, and purchase flows are not active product scope in this build.",
                        icon: "creditcard",
                        valueLabel: "Not active"
                    )
                ],
                footer: "Future account or monetization work should land only when canon and release-compliance truth explicitly activate it."
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

    func makePreviewSwatches(
        selectedAppearance: AppAppearancePreference,
        selectedAccent: AmbitionAccentFamily
    ) -> [ProfilePreviewSwatch] {
        [
            ProfilePreviewSwatch(
                id: "preview-now",
                title: "Current shell",
                subtitle: "How the core hierarchy will render after save.",
                eyebrow: selectedAppearance.title,
                accentFamily: selectedAccent,
                appearancePreference: selectedAppearance,
                state: .selected
            ),
            ProfilePreviewSwatch(
                id: "preview-trust",
                title: "Trust calm",
                subtitle: "Trust status keeps a quieter layer than hero actions.",
                eyebrow: "Trust",
                accentFamily: selectedAccent,
                appearancePreference: selectedAppearance,
                state: .default
            ),
            ProfilePreviewSwatch(
                id: "preview-context",
                title: "Context optionality",
                subtitle: "Optional context stays helpful, not invasive.",
                eyebrow: "Context",
                accentFamily: selectedAccent,
                appearancePreference: selectedAppearance,
                state: .default
            )
        ]
    }

    func dominantTruth(
        syncStatus: SyncCapabilityStatus,
        notificationStatus: ProfileNotificationAuthorization,
        appearanceSummary: String
    ) -> String {
        if notificationStatus.statusLabel == "Denied" {
            return "Appearance is configured, but one trust edge still needs attention: notifications are denied."
        }
        return "Appearance is curated, trust is \(syncStatus.trustPosture == .localOnly ? "local-first" : "bounded"), and optional context remains inspectable."
    }

    func syncPulseTitle(for status: SyncCapabilityStatus) -> String {
        switch status.trustPosture {
        case .localOnly:
            return "Local-first and stable"
        }
    }

    func syncVisualState(_ status: SyncCapabilityStatus) -> AmbitionVisualState {
        switch status.trustPosture {
        case .localOnly:
            return .selected
        }
    }

    func appearanceSubtitle(for preference: AppAppearancePreference) -> String {
        switch preference {
        case .system:
            return "Follow the device while keeping Ambitions hierarchy intact."
        case .light:
            return "Use the warm light palette full time."
        case .dark:
            return "Use the flagship dark palette full time."
        }
    }

    func accentSubtitle(for family: AmbitionAccentFamily) -> String {
        switch family {
        case .sage:
            return "Quiet, grounded, and balanced."
        case .blueGray:
            return "Cooler and architectural."
        case .mutedGold:
            return "Warm emphasis with restrained glow."
        case .copper:
            return "Richer warmth for stronger highlights."
        case .sand:
            return "Soft neutral warmth with gentle contrast."
        }
    }

    func notificationAuthorizationSubtitle(for status: ProfileNotificationAuthorization) -> String {
        if status.statusLabel == "Denied" {
            return "Denied in system settings. Local reminders exist, but trust is clearer when notification delivery is enabled or intentionally left off."
        }
        return "Authorization: \(status.detail) Local reminders stay on-device and bounded to the current runtime."
    }

    func calendarAuthorizationLabel(_ state: CalendarRemindersAuthorizationState) -> String {
        switch state {
        case .notDetermined:
            return "Not requested"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .authorized:
            return "Authorized"
        case .writeOnly:
            return "Write only"
        case .fullAccess:
            return "Full access"
        }
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
