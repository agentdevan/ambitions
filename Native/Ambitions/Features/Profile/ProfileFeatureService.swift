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
        let eventLedger: [EventLedgerEntry]
        let appState: AppStateSnapshot
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let captures = repositories.captures.listCaptures()
        async let teachingSignals = repositories.teaching.listSignals(goalID: nil)
        async let eventLedger = repositories.eventLedger.fetchRecent(limit: 12)
        async let appState = repositories.appState.loadState()

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            captures: captures,
            teachingSignals: teachingSignals,
            eventLedger: eventLedger,
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
        let clarificationCount = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }.count
        let blockedCount = snapshot.drafts.filter { $0.latestResultKind == .blocked }.count
        let openCaptures = snapshot.captures.filter { $0.status != .archived }.count
        let trimmedName = snapshot.appState.userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let profileTitle = trimmedName.isEmpty ? "Your system" : "\(trimmedName)'s system"
        let notificationStatus = notificationAuthorizationStatus(notificationAuthorization)
        let syncState = syncVisualState(syncStatus)
        let appearanceSummary = "\(snapshot.appState.appearancePreference.title) mode with \(snapshot.appState.accentFamily.title)"
        let eventLedgerCount = snapshot.eventLedger.count
        let contextSignals = snapshot.evidence.count + snapshot.feedback.count + snapshot.teachingSignals.count + eventLedgerCount
        let safetySamples = safetyBoundarySamples()
        let policyReceipts = makePolicyReceipts(safetySamples: safetySamples)
        let reviews = makeReviews(
            snapshot: snapshot,
            receipts: policyReceipts,
            calendarAuthorization: calendarAuthorization
        )

        return ProfileDashboard(
            hero: ProfileHeroState(
                title: profileTitle,
                subtitle: "Your Trust Center for what Ambitions knows, what it can do, and what it will not change silently.",
                dominantTruth: dominantTruth(
                    syncStatus: syncStatus,
                    notificationStatus: notificationStatus,
                    appearanceSummary: appearanceSummary
                ),
                supportingTruth: "Ambitions starts local-first, keeps risky actions confirmation-gated, and treats memory as something you can inspect and correct.",
                trustWhisper: "No silent calendar changes. No active cloud sync claim. No destructive memory deletion from this surface.",
                status: syncState,
                pills: [
                    ProfileStatusPill(id: "profile-pill-appearance", title: appearanceSummary, icon: "paintpalette", state: .selected),
                    ProfileStatusPill(id: "profile-pill-sync", title: syncStatus.detail, icon: "lock.shield", state: syncState),
                    ProfileStatusPill(
                        id: "profile-pill-context",
                        title: contextSignals == 0 ? "No local memory signals yet" : "\(contextSignals) local memory signals",
                        icon: "waveform.path.ecg",
                        state: contextSignals == 0 ? .default : .default
                    )
                ],
                stats: [
                    MetricSummary(id: "profile-active-goals", title: "Open goals", value: "\(activeGoals)", detail: "Active native goals", icon: "target"),
                    MetricSummary(id: "profile-confirmation", title: "Confirmation rules", value: "\(safetySamples.confirmationRequired)", detail: "Sampled risky actions", icon: "hand.raised"),
                    MetricSummary(id: "profile-corrections", title: "Corrections", value: "\(snapshot.teachingSignals.count)", detail: "User teaching signals", icon: "checkmark.seal"),
                    MetricSummary(id: "profile-context", title: "Memory areas", value: "\(contextSignals)", detail: "Evidence, feedback, teaching, ledger", icon: "sparkles")
                ]
            ),
            systemCenter: makeSystemCenter(
                snapshot: snapshot,
                syncStatus: syncStatus,
                notificationStatus: notificationStatus,
                calendarAuthorization: calendarAuthorization,
                reviews: reviews,
                contextSignals: contextSignals,
                appearanceSummary: appearanceSummary
            ),
            controlRoom: ProfileControlRoomState(
                title: "Control room",
                subtitle: "A short map of the trust areas you can inspect without turning You into a settings dump.",
                entries: [
                    ProfileControlRoomEntry(
                        id: "profile-control-constitution",
                        title: "Personal Operating Constitution",
                        subtitle: "Recommendation posture, recovery tone, planning strictness, and confirmation rules.",
                        icon: "scroll",
                        statusLabel: "Local defaults",
                        state: .selected
                    ),
                    ProfileControlRoomEntry(
                        id: "profile-control-memory",
                        title: "What Ambitions Knows",
                        subtitle: "Local evidence, feedback, corrections, captures, and event history Ambitions can explain and let you correct.",
                        icon: "brain.head.profile",
                        statusLabel: "Stored on this device",
                        state: .default
                    ),
                    ProfileControlRoomEntry(
                        id: "profile-control-corrections",
                        title: "Corrections and assumptions",
                        subtitle: "Assumptions can be corrected through existing teaching and explanation paths.",
                        icon: "checkmark.bubble",
                        statusLabel: snapshot.teachingSignals.isEmpty ? "Available when present" : "\(snapshot.teachingSignals.count) active",
                        state: snapshot.teachingSignals.isEmpty ? .default : .success
                    ),
                    ProfileControlRoomEntry(
                        id: "profile-control-receipts",
                        title: "Receipts and audit posture",
                        subtitle: "Reviews turns local receipts, recovery, proof, and corrections into a calm receipt layer.",
                        icon: "doc.text.magnifyingglass",
                        statusLabel: reviews.projection.period.title,
                        state: .default
                    )
                ],
                footer: "Open detail from the owning surfaces for deep review. This page stays oriented around trust, control, and next-safe status."
            ),
            constitution: makeConstitution(
                snapshot: snapshot,
                calendarAuthorization: calendarAuthorization,
                notificationStatus: notificationStatus,
                safetySamples: safetySamples
            ),
            memoryControls: makeMemoryControls(snapshot: snapshot),
            assumptionCorrections: makeAssumptionCorrections(snapshot: snapshot),
            automationBoundary: makeAutomationBoundary(safetySamples: safetySamples),
            receiptAudit: makeReceiptAudit(snapshot: snapshot, receipts: policyReceipts),
            reviews: reviews,
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
                subtitle: "Truthful status for local-first data, permissions, external surfaces, sync, automation, and recovery.",
                pulse: ProfileTrustPulseState(
                    title: "Local trust pulse",
                    subtitle: syncPulseTitle(for: syncStatus),
                    detail: "Stored on this device. Optional permissions are explicit. Future sync and external surfaces remain labeled until verified.",
                    state: syncState
                ),
                items: [
                    SettingsItem(
                        id: "profile-trust-sync",
                        title: "System trust posture",
                        subtitle: "The current runtime uses on-device storage. Apple-first sync is future-owned and not currently connected.",
                        icon: "lock.shield",
                        valueLabel: syncStatus.detail
                    ),
                    SettingsItem(
                        id: "profile-trust-calendar",
                        title: "Calendar boundary",
                        subtitle: "Plan may request calendar awareness after a clear action. Ambitions does not silently write calendar changes.",
                        icon: "calendar.badge.clock",
                        valueLabel: calendarAuthorizationLabel(calendarAuthorization)
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
                    ),
                    SettingsItem(
                        id: "profile-trust-accessibility",
                        title: "Accessibility Nutrition",
                        subtitle: "Internal checklist infrastructure exists. Public claims are locked until manual verification is recorded.",
                        icon: "figure",
                        valueLabel: "Claims locked"
                    ),
                    SettingsItem(
                        id: "profile-trust-export-import",
                        title: "Export and disaster recovery",
                        subtitle: "Portable snapshot foundations exist, but the proof drill is not complete. This surface does not claim export is production-ready.",
                        icon: "externaldrive.badge.icloud",
                        valueLabel: "Future planned"
                    )
                ],
                sections: makeTrustCenterSections(
                    syncStatus: syncStatus,
                    notificationStatus: notificationStatus,
                    calendarAuthorization: calendarAuthorization,
                    receipts: policyReceipts,
                    teachingSignalCount: snapshot.teachingSignals.count
                ),
                receiptSummaries: ActionReceiptProjection(receipts: policyReceipts).displaySummaries(limit: 3),
                footer: "Trust-sensitive features are labeled as available, manual, unavailable, or future planned. Ambitions does not claim live sync, account systems, or verified accessibility here."
            ),
            contextVault: ProfileContextVaultState(
                title: "Local memory map",
                subtitle: "A compact inventory of local signal types, not an automatic profile.",
                items: [
                    ProfileContextVaultItem(
                        id: "profile-vault-signals",
                        title: "Recommendation evidence",
                        subtitle: "These categories can explain recommendations without claiming cloud intelligence.",
                        icon: "tray.full",
                        detail: "\(snapshot.evidence.count) evidence records, \(snapshot.feedback.count) feedback events, \(snapshot.teachingSignals.count) teaching signals, \(eventLedgerCount) recent ledger events"
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
                footer: "This is a foundation layer, not a full privacy admin surface. It keeps current local context understandable without inventing account, sync, or export flows."
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
                footer: "Notification and integration status should answer whether anything important needs attention without turning You into an admin checklist."
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
                        id: "profile-default-rituals",
                        title: "Rituals",
                        subtitle: "Recurring support lives under Plan, Today, Goal Detail, and Reviews instead of a standalone area.",
                        icon: "repeat",
                        valueLabel: "Plan-owned"
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
                subtitle: "This build stays explicit about what is not configured yet so You never implies hidden account requirements.",
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

    func makeTrustCenterSections(
        syncStatus: SyncCapabilityStatus,
        notificationStatus: ProfileNotificationAuthorization,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        receipts: [ActionReceipt],
        teachingSignalCount: Int
    ) -> [ProfileTrustCenterSection] {
        let receiptProjection = ActionReceiptProjection(receipts: receipts)
        let undoCount = receiptProjection.undoAvailableReceipts().count
        let receiptCount = receiptProjection.displaySummaries().count

        return [
            ProfileTrustCenterSection(
                id: "trust-center-status",
                title: "Status and boundaries",
                footer: "These rows describe current runtime truth. They do not request permissions or enable future services by themselves.",
                routes: [
                    ProfileTrustCenterRoute(
                        id: "trust-route-local-data",
                        title: "Local data status",
                        subtitle: "Goals, captures, proof, corrections, receipts, and reviews read from this device in the current runtime.",
                        icon: "internaldrive",
                        statusLabel: "Stored on this device",
                        semanticState: .trust,
                        accessibilityHint: "Shows local storage trust status."
                    ),
                    ProfileTrustCenterRoute(
                        id: "trust-route-calendar",
                        title: "Calendar boundary",
                        subtitle: "Calendar awareness is Plan-owned. Writes require confirmation and are never silent.",
                        icon: "calendar.badge.clock",
                        statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                        semanticState: .calendarDerived,
                        accessibilityHint: "Shows calendar permission and write boundary."
                    ),
                    ProfileTrustCenterRoute(
                        id: "trust-route-notifications",
                        title: "Notification boundary",
                        subtitle: "Local reminders are optional and permission-gated. Ambitions still works without notification access.",
                        icon: "bell.badge",
                        statusLabel: notificationStatus.statusLabel,
                        semanticState: notificationStatus.statusLabel == "Denied" ? .caution : .neutral,
                        accessibilityHint: "Shows notification permission status."
                    ),
                    ProfileTrustCenterRoute(
                        id: "trust-route-external-surfaces",
                        title: "External surfaces",
                        subtitle: "Widgets, Live Activities, Shortcuts, and Share Extension must use privacy snapshots and fallback routes.",
                        icon: "rectangle.3.group",
                        statusLabel: ExternalSurfaceTruth.productizedNeedsPlatformReview,
                        semanticState: .caution,
                        accessibilityHint: "Shows external-surface verification status."
                    )
                ]
            ),
            ProfileTrustCenterSection(
                id: "trust-center-receipts",
                title: "Receipts, corrections, and explanations",
                footer: "Receipt rows summarize policy and action history without exposing raw logs by default.",
                routes: [
                    ProfileTrustCenterRoute(
                        id: "trust-route-receipts",
                        title: "Receipts",
                        subtitle: "Receipts say what happened, what changed, why, and what can be corrected or undone.",
                        icon: "doc.text.magnifyingglass",
                        statusLabel: receiptCount == 0 ? "No recent receipts" : "\(receiptCount) examples",
                        semanticState: .review,
                        accessibilityHint: "Shows receipt history posture."
                    ),
                    ProfileTrustCenterRoute(
                        id: "trust-route-corrections",
                        title: "Correction routes",
                        subtitle: "Supported corrections stay tied to existing Goal Detail, Capture, teaching, and explanation seams.",
                        icon: "checkmark.bubble",
                        statusLabel: teachingSignalCount == 0 ? "Available where shown" : "\(teachingSignalCount) local",
                        semanticState: .trust,
                        accessibilityHint: "Shows correction availability."
                    ),
                    ProfileTrustCenterRoute(
                        id: "trust-route-undo",
                        title: "Undo rules",
                        subtitle: "Local undo is shown only where safe. Broad, external, destructive, or unsupported changes stay blocked or confirmation-gated.",
                        icon: "arrow.uturn.backward",
                        statusLabel: undoCount == 0 ? "No silent undo" : "\(undoCount) available",
                        semanticState: .caution,
                        accessibilityHint: "Shows undo safety posture."
                    ),
                    ProfileTrustCenterRoute(
                        id: "trust-route-explanations",
                        title: "Explanations",
                        subtitle: "Why This, Why Now, Why Changed, and What This Uses should cite local evidence or admit when detail is unavailable.",
                        icon: "text.bubble",
                        statusLabel: "Evidence-led",
                        semanticState: .trust,
                        accessibilityHint: "Shows explanation rule posture."
                    )
                ]
            ),
            ProfileTrustCenterSection(
                id: "trust-center-privacy-future",
                title: "Privacy and future-owned capabilities",
                footer: "Unavailable states stay visible so this surface does not imply hidden accounts, cloud sync, or production-ready export.",
                routes: [
                    ProfileTrustCenterRoute(
                        id: "trust-route-privacy",
                        title: "Privacy defaults",
                        subtitle: "Sensitive details should be hidden on compact and external surfaces unless the user chooses otherwise.",
                        icon: "hand.raised",
                        statusLabel: "Private by default",
                        semanticState: .protected,
                        accessibilityHint: "Shows privacy-safe display posture."
                    ),
                    ProfileTrustCenterRoute(
                        id: "trust-route-sync-export",
                        title: "Sync / Export truth",
                        subtitle: "Sync is not connected. Export and import proof remain future-owned until the disaster drill passes.",
                        icon: "externaldrive",
                        statusLabel: syncStatus.detail,
                        semanticState: .caution,
                        accessibilityHint: "Shows sync and export truth."
                    ),
                    ProfileTrustCenterRoute(
                        id: "trust-route-accessibility-claims",
                        title: "Accessibility claims",
                        subtitle: "Internal evidence exists. Public claims stay locked until manual VoiceOver, Dynamic Type, Reduce Motion, contrast, and motor review is recorded.",
                        icon: "figure",
                        statusLabel: "Claims locked",
                        semanticState: .accessibilityUnverified,
                        accessibilityHint: "Shows accessibility claim status."
                    )
                ]
            )
        ]
    }

    func makeSystemCenter(
        snapshot: Snapshot,
        syncStatus: SyncCapabilityStatus,
        notificationStatus: ProfileNotificationAuthorization,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        reviews: ProfileReviewsState,
        contextSignals: Int,
        appearanceSummary: String
    ) -> ProfileSystemCenterState {
        ProfileSystemCenterState(
            title: "You",
            subtitle: "Your settings, memory, and trust controls.",
            sections: [
                ProfileSystemCenterSection(
                    id: "me",
                    title: "Me",
                    footer: nil,
                    items: [
                        ProfileSystemCenterItem(
                            id: "profile",
                            title: "Profile",
                            subtitle: "Name and default landing tab.",
                            icon: "person.crop.circle",
                            statusLabel: snapshot.appState.userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Optional" : "Local",
                            semanticState: .neutral,
                            accessibilityHint: "Opens profile settings."
                        ),
                        ProfileSystemCenterItem(
                            id: "personalization",
                            title: "Personalization",
                            subtitle: "Tone and planning defaults.",
                            icon: "slider.horizontal.3",
                            statusLabel: "Defaults",
                            semanticState: .trust,
                            accessibilityHint: "Opens personalization settings."
                        ),
                        ProfileSystemCenterItem(
                            id: "appearance",
                            title: "Appearance",
                            subtitle: "Mode and accent.",
                            icon: "paintpalette",
                            statusLabel: snapshot.appState.appearancePreference.title,
                            semanticState: .success,
                            accessibilityHint: "Opens Appearance Studio."
                        )
                    ]
                ),
                ProfileSystemCenterSection(
                    id: "memory-and-trust",
                    title: "Memory and Trust",
                    footer: nil,
                    items: [
                        ProfileSystemCenterItem(
                            id: "what-ambitions-knows",
                            title: "What Ambitions Knows",
                            subtitle: "Saved local context.",
                            icon: "brain.head.profile",
                            statusLabel: contextSignals == 0 ? "Empty" : "Local",
                            semanticState: contextSignals == 0 ? .neutral : .trust,
                            accessibilityHint: "Opens local memory controls."
                        ),
                        ProfileSystemCenterItem(
                            id: "trust-center",
                            title: "Trust Center",
                            subtitle: "Permissions, privacy, and boundaries.",
                            icon: "checkmark.shield",
                            statusLabel: "Review",
                            semanticState: .trust,
                            accessibilityHint: "Opens Trust Center."
                        ),
                        ProfileSystemCenterItem(
                            id: "receipts-history",
                            title: "Receipts & History",
                            subtitle: "What changed and why.",
                            icon: "doc.text.magnifyingglass",
                            statusLabel: "Local",
                            semanticState: .neutral,
                            accessibilityHint: "Opens receipt history."
                        ),
                        ProfileSystemCenterItem(
                            id: "corrections",
                            title: "Corrections",
                            subtitle: "Fix assumptions and teaching signals.",
                            icon: "checkmark.bubble",
                            statusLabel: snapshot.teachingSignals.isEmpty ? "Ready" : "\(snapshot.teachingSignals.count)",
                            semanticState: .caution,
                            accessibilityHint: "Opens corrections."
                        )
                    ]
                ),
                ProfileSystemCenterSection(
                    id: "reviews-and-progress",
                    title: "Reviews and Progress",
                    footer: nil,
                    items: [
                        ProfileSystemCenterItem(
                            id: "reviews",
                            title: "Reviews",
                            subtitle: "Recovery and progress check-ins.",
                            icon: "rectangle.stack.badge.play",
                            statusLabel: "Review",
                            semanticState: .review,
                            accessibilityHint: "Opens Reviews."
                        ),
                        ProfileSystemCenterItem(
                            id: "proof",
                            title: "Proof",
                            subtitle: "Evidence and progress notes.",
                            icon: "checkmark.seal",
                            statusLabel: "Local",
                            semanticState: .success,
                            accessibilityHint: "Opens proof summary."
                        ),
                        ProfileSystemCenterItem(
                            id: "archive-completed",
                            title: "Archive / Completed",
                            subtitle: "Saved learning from finished work.",
                            icon: "archivebox",
                            statusLabel: "Saved",
                            semanticState: .neutral,
                            accessibilityHint: "Opens archive summary."
                        )
                    ]
                ),
                ProfileSystemCenterSection(
                    id: "system-edges",
                    title: "System Edges",
                    footer: nil,
                    items: [
                        ProfileSystemCenterItem(
                            id: "notifications",
                            title: "Notifications",
                            subtitle: "Reminder permission.",
                            icon: "bell.badge",
                            statusLabel: notificationStatus.statusLabel,
                            semanticState: notificationStatus.statusLabel == "Denied" ? .caution : .neutral,
                            accessibilityHint: "Opens notification settings."
                        ),
                        ProfileSystemCenterItem(
                            id: "integrations",
                            title: "Integrations",
                            subtitle: "Calendar and reminders.",
                            icon: "rectangle.connected.to.line.below",
                            statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                            semanticState: .calendarDerived,
                            accessibilityHint: "Opens integrations."
                        ),
                        ProfileSystemCenterItem(
                            id: "widgets-live-activities-shortcuts",
                            title: "Widgets / Live Activities / Shortcuts",
                            subtitle: "External surface status.",
                            icon: "square.grid.2x2",
                            statusLabel: "Bounded",
                            semanticState: .neutral,
                            accessibilityHint: "Opens external surface status."
                        ),
                        ProfileSystemCenterItem(
                            id: "export-import",
                            title: "Export / Import",
                            subtitle: "Local backup and restore posture.",
                            icon: "externaldrive",
                            statusLabel: syncStatus.availability == .unavailable ? "Manual" : "Review",
                            semanticState: .caution,
                            accessibilityHint: "Opens export and import status."
                        )
                    ]
                ),
                ProfileSystemCenterSection(
                    id: "accessibility-and-support",
                    title: "Accessibility and Support",
                    footer: "Rows open details; nothing here changes plans silently.",
                    items: [
                        ProfileSystemCenterItem(
                            id: "accessibility",
                            title: "Accessibility",
                            subtitle: "Claims and manual review status.",
                            icon: "figure",
                            statusLabel: "Locked",
                            semanticState: .accessibilityUnverified,
                            accessibilityHint: "Opens accessibility status."
                        ),
                        ProfileSystemCenterItem(
                            id: "help-support",
                            title: "Help / Support",
                            subtitle: "Guidance and support posture.",
                            icon: "questionmark.circle",
                            statusLabel: "Guide",
                            semanticState: .neutral,
                            accessibilityHint: "Opens help and support."
                        ),
                        ProfileSystemCenterItem(
                            id: "about",
                            title: "About",
                            subtitle: "Local-first app status.",
                            icon: "info.circle",
                            statusLabel: "Local",
                            semanticState: .neutral,
                            accessibilityHint: "Opens about Ambitions."
                        )
                    ]
                )
            ],
            footer: "You keeps settings, history, trust, and controls together."
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

    struct SafetyBoundarySamples {
        let calendarWrite: SafeAutomationPolicyDecision
        let broadReflow: SafeAutomationPolicyDecision
        let forgetMemory: SafeAutomationPolicyDecision
        let prepareExport: SafeAutomationPolicyDecision
        let localCorrection: SafeAutomationPolicyDecision

        var confirmationRequired: Int {
            [calendarWrite, broadReflow, forgetMemory, prepareExport, localCorrection]
                .filter(\.mustNeverBeSilent)
                .count
        }

        var destructiveBlocked: Bool {
            forgetMemory.permissionLevel == .neverAutomate &&
                forgetMemory.receiptRecommendation.resultState == .failedSafely
        }
    }

    func safetyBoundarySamples() -> SafetyBoundarySamples {
        let evaluator = SafeAutomationPolicyEvaluator()
        let planBlock = LifeGraphObjectReference(kind: .action, id: "you-policy-calendar-write", sourceDomain: .plan)
        let planStep = LifeGraphObjectReference(kind: .step, id: "you-policy-reflow", sourceDomain: .plan)
        let memoryObject = LifeGraphObjectReference(kind: .correction, id: "you-policy-memory", sourceDomain: .you)
        let correctionObject = LifeGraphObjectReference(kind: .correction, id: "you-policy-correction", sourceDomain: .you)

        return SafetyBoundarySamples(
            calendarWrite: evaluator.evaluate(
                SafeAutomationProposedAction(kind: .writeCalendarBlock, sourceDomain: .plan, targetObjects: [planBlock])
            ),
            broadReflow: evaluator.evaluate(
                SafeAutomationProposedAction(kind: .splitAction, sourceDomain: .plan, targetObjects: [planStep])
            ),
            forgetMemory: evaluator.evaluate(
                SafeAutomationProposedAction(kind: .forgetMemory, sourceDomain: .you, targetObjects: [memoryObject])
            ),
            prepareExport: evaluator.evaluate(
                SafeAutomationProposedAction(kind: .prepareExport, sourceDomain: .you)
            ),
            localCorrection: evaluator.evaluate(
                SafeAutomationProposedAction(kind: .correctRecommendation, sourceDomain: .you, targetObjects: [correctionObject])
            )
        )
    }

    func makeConstitution(
        snapshot: Snapshot,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        notificationStatus: ProfileNotificationAuthorization,
        safetySamples: SafetyBoundarySamples
    ) -> ProfileConstitutionState {
        ProfileConstitutionState(
            title: "Personal Operating Constitution",
            subtitle: "The local rules Ambitions uses to stay useful without becoming pushy or silent.",
            postureSummary: "Calm, conservative, correction-aware, and local-first by default.",
            rules: [
                ProfileConstitutionRule(
                    id: "constitution-local-first",
                    title: "Start from local truth",
                    detail: "Goals, captures, evidence, corrections, and recent ledger events are read from this device. Sync is not currently connected.",
                    statusLabel: "Stored on this device",
                    state: .selected
                ),
                ProfileConstitutionRule(
                    id: "constitution-recommendation-posture",
                    title: "Suggest one doable move",
                    detail: "Suggestions should be explainable by goal, plan, evidence, or recent feedback, not vague intelligence claims.",
                    statusLabel: snapshot.eventLedger.isEmpty ? "Evidence-light" : "Uses local evidence",
                    state: .default
                ),
                ProfileConstitutionRule(
                    id: "constitution-recovery-tone",
                    title: "Recover without shame",
                    detail: "Delays, skips, and smaller-version requests are treated as recovery context, not blame.",
                    statusLabel: "Calm recovery",
                    state: .success
                ),
                ProfileConstitutionRule(
                    id: "constitution-calendar",
                    title: "Ask before calendar writes",
                    detail: "Calendar access is explicit and Plan-owned. Calendar writes require confirmation and are never silent.",
                    statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                    state: safetySamples.calendarWrite.mustNeverBeSilent ? .warning : .default
                ),
                ProfileConstitutionRule(
                    id: "constitution-interruptions",
                    title: "Interruptions stay optional",
                    detail: "Notifications can support reminders, but Ambitions still works when notification access is denied or not requested.",
                    statusLabel: notificationStatus.statusLabel,
                    state: notificationStatus.statusLabel == "Denied" ? .warning : .default
                )
            ],
            footer: "These are current local defaults, not a broad account/preferences system. Deeper Constitution maturity remains future-owned."
        )
    }

    func makeMemoryControls(snapshot: Snapshot) -> ProfileMemoryControlState {
        let correctionCount = snapshot.teachingSignals.count
        let correctionStatus = correctionCount == 0 ? "None yet" : "\(correctionCount) local"
        let openCaptures = snapshot.captures.filter { $0.status != .archived }.count
        let proofFeedbackCount = snapshot.evidence.count + snapshot.feedback.count
        let eventCount = snapshot.eventLedger.count
        let hasRecentMemory = eventCount + proofFeedbackCount + correctionCount + openCaptures > 0
        let narrativeMemories = makeNarrativeMemories(
            eventCount: eventCount,
            proofFeedbackCount: proofFeedbackCount,
            correctionCount: correctionCount,
            openCaptures: openCaptures
        )
        let conservativePatterns = makeConservativeMemoryPatterns(
            eventCount: eventCount,
            proofFeedbackCount: proofFeedbackCount,
            correctionCount: correctionCount,
            openCaptures: openCaptures
        )
        return ProfileMemoryControlState(
            title: "What Ambitions Knows",
            subtitle: "Local memory areas Ambitions can use, what each one is for, and where you can correct it.",
            items: [
                SettingsItem(
                    id: "profile-memory-ledger",
                    title: "Event Ledger",
                    subtitle: "Recent meaningful actions and changes can support explanations. Full raw history stays off this top-level surface.",
                    icon: "list.bullet.rectangle",
                    valueLabel: snapshot.eventLedger.isEmpty ? "No recent events" : "\(snapshot.eventLedger.count) recent"
                ),
                SettingsItem(
                    id: "profile-memory-evidence",
                    title: "Proof and feedback",
                    subtitle: "Progress evidence and feedback help Ambitions avoid relying only on intention.",
                    icon: "checkmark.seal",
                    valueLabel: "\(snapshot.evidence.count + snapshot.feedback.count) local"
                ),
                SettingsItem(
                    id: "profile-memory-corrections",
                    title: "Corrections and teaching",
                    subtitle: "User-confirmed corrections can adjust future explanations where existing teaching signals support it.",
                    icon: "slider.horizontal.3",
                    valueLabel: correctionStatus
                ),
                SettingsItem(
                    id: "profile-memory-captures",
                    title: "Open captures",
                    subtitle: "Unarchived captures remain visible to the local planning loop until routed or archived.",
                    icon: "tray.full",
                    valueLabel: "\(snapshot.captures.filter { $0.status != .archived }.count) open"
                ),
                SettingsItem(
                    id: "profile-memory-forget",
                    title: "Forget or clear memory",
                    subtitle: "Destructive memory deletion is not exposed here because safe review, confirmation, and undo coverage are not complete.",
                    icon: "trash.slash",
                    valueLabel: "Unavailable"
                )
            ],
            groups: [
                ProfileMemoryGroup(
                    id: "memory-group-current",
                    title: "Current local memory",
                    subtitle: "Used only from local Ambitions records available in this runtime.",
                    footer: "Current does not mean permanent. It means the source is active in the local app right now.",
                    items: [
                        ProfileMemoryItem(
                            id: "memory-item-ledger",
                            title: "Recent actions and changes",
                            detail: eventCount == 0 ? "No recent local events are available yet." : "\(eventCount) recent local events are available for explanation and review context.",
                            sourceLabel: "Event Ledger",
                            freshness: eventCount == 0 ? .basedOnOlderContext : .current,
                            usedFor: "Used for Why Changed, reviews, recovery summaries, and receipt context.",
                            privacyLabel: "Private by default",
                            actions: [
                                memoryAction(id: "inspect-ledger", title: "Inspect", statusLabel: eventCount == 0 ? "Empty" : "Available", detail: "Review happens through receipts, reviews, and owning surfaces.", state: eventCount == 0 ? .default : .success),
                                memoryAction(id: "delete-ledger", title: "Delete", statusLabel: "Not exposed", detail: "Raw destructive deletion waits for a safe confirmation and undo boundary.", state: .warning)
                            ],
                            accessibilityLabel: "Recent actions and changes memory",
                            accessibilityValue: eventCount == 0 ? "Based on older context. Private by default." : "Current. Private by default.",
                            accessibilityHint: "Shows what the event ledger is used for and why deletion is not exposed here."
                        ),
                        ProfileMemoryItem(
                            id: "memory-item-proof-feedback",
                            title: "Proof and feedback",
                            detail: proofFeedbackCount == 0 ? "No proof or feedback records are available yet." : "\(proofFeedbackCount) proof or feedback records can ground progress and review language.",
                            sourceLabel: "Proof and feedback",
                            freshness: proofFeedbackCount == 0 ? .mayNeedReview : .current,
                            usedFor: "Used for progress summaries, review receipts, and avoiding intention-only recommendations.",
                            privacyLabel: "Detail hidden in compact views",
                            actions: [
                                memoryAction(id: "update-proof", title: "Update this", statusLabel: "Use owning surface", detail: "Proof and feedback stay corrected from Goal Detail, Capture, or Review context.", state: .default),
                                memoryAction(id: "pause-proof", title: "Pause use", statusLabel: "Review later", detail: "Pause is represented as a review need here until a safe preference exists.", state: .warning)
                            ],
                            accessibilityLabel: "Proof and feedback memory",
                            accessibilityValue: "\(proofFeedbackCount == 0 ? ProfileMemoryFreshness.mayNeedReview.label : ProfileMemoryFreshness.current.label). Detail hidden in compact views.",
                            accessibilityHint: "Shows what proof and feedback memory is used for and where it can be corrected."
                        ),
                        ProfileMemoryItem(
                            id: "memory-item-captures",
                            title: "Open captures",
                            detail: openCaptures == 0 ? "No open captures need placement." : "\(openCaptures) open captures may still need routing, review, or archiving.",
                            sourceLabel: "Capture",
                            freshness: openCaptures == 0 ? .current : .mayNeedReview,
                            usedFor: "Used for Needs a Place routing, planning prompts, and safe follow-up.",
                            privacyLabel: "Stored on this device",
                            actions: [
                                memoryAction(id: "edit-captures", title: "Edit", statusLabel: openCaptures == 0 ? "Nothing open" : "Available in Capture", detail: "Capture owns editing, routing, archiving, and receipts for captured items.", state: openCaptures == 0 ? .default : .success)
                            ],
                            accessibilityLabel: "Open captures memory",
                            accessibilityValue: openCaptures == 0 ? "Current. No open captures." : "May Need Review. Stored on this device.",
                            accessibilityHint: "Shows whether captures are contributing to local memory."
                        )
                    ]
                ),
                ProfileMemoryGroup(
                    id: "memory-group-corrections",
                    title: "Corrections and review signals",
                    subtitle: "User-corrected context is kept explicit and source-tied.",
                    footer: "No sensitive identity categories are inferred here. Correction signals stay bounded to the artifacts that created them.",
                    items: [
                        ProfileMemoryItem(
                            id: "memory-item-corrections",
                            title: "Corrections and teaching",
                            detail: correctionCount == 0 ? "No active teaching signals are saved yet." : "\(correctionCount) local teaching signals can influence future explanation language.",
                            sourceLabel: "Manual corrections",
                            freshness: correctionCount == 0 ? .basedOnOlderContext : .current,
                            usedFor: "Used for Why Changed, lighter-version preferences, and future recommendations that cite local evidence.",
                            privacyLabel: "Correctable",
                            actions: [
                                memoryAction(id: "correct-teaching", title: "Correct", statusLabel: correctionCount == 0 ? "Available when present" : "Available", detail: "Corrections stay tied to existing teaching and explanation paths.", state: correctionCount == 0 ? .default : .success),
                                memoryAction(id: "delete-teaching", title: "Delete", statusLabel: "Needs confirmation", detail: "Deletion is not claimed until safe review, confirmation, and undo coverage exist.", state: .warning)
                            ],
                            accessibilityLabel: "Corrections and teaching memory",
                            accessibilityValue: correctionCount == 0 ? "Based on Older Context. Correctable when present." : "Current. Correctable.",
                            accessibilityHint: "Shows how corrections affect future explanations and why deletion requires confirmation."
                        )
                    ]
                )
            ],
            narrativeMemories: narrativeMemories,
            conservativePatterns: conservativePatterns,
            recoverySummary: hasRecentMemory ? "Memory can be reviewed and corrected from the owning surfaces. Broad delete, forget, and pause controls remain confirmation-gated or future-owned." : "There is little local memory yet. Ambitions should say when a recommendation is evidence-light instead of pretending it knows more.",
            footer: "What Ambitions Knows is local, inspectable, and correctable through existing safe seams. Narrative memory only appears from explicit local evidence, receipts, corrections, reviews, or confirmations; broad forgetting and deletion remain manual/future until the safe boundary can prove the result."
        )
    }

    func makeNarrativeMemories(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> [ProfileNarrativeMemory] {
        var memories: [ProfileNarrativeMemory] = []

        if correctionCount > 0 {
            memories.append(
                ProfileNarrativeMemory(
                    id: "narrative-memory-corrections",
                    title: "You corrected how Ambitions reads something",
                    summary: "\(correctionCount) manual correction\(correctionCount == 1 ? "" : "s") can change future explanation language where the original artifact still exists.",
                    sourceLabel: "Manual corrections",
                    freshness: .current,
                    usedFor: "Used for Why Changed, recommendation wording, and future review prompts that cite the correction.",
                    sensitiveStatusLabel: "No sensitive inference",
                    actions: [
                        memoryAction(id: "narrative-correct", title: "Correct", statusLabel: "Use owning surface", detail: "Goal Detail, Capture, and explanation controls remain the supported correction paths.", state: .success),
                        memoryAction(id: "narrative-delete", title: "Delete", statusLabel: "Needs confirmation", detail: "Deletion is not claimed until safe review, confirmation, and undo coverage exist.", state: .warning),
                        memoryAction(id: "narrative-pause", title: "Pause use", statusLabel: "Review later", detail: "Pause is shown as a review need until a safe preference exists.", state: .warning)
                    ],
                    accessibilityLabel: "Narrative memory from corrections",
                    accessibilityValue: "Current. Manual corrections. Sensitive categories are not inferred.",
                    accessibilityHint: "Shows what this narrative memory uses and which correction, delete, and pause controls are safe or blocked."
                )
            )
        }

        if proofFeedbackCount > 0 {
            memories.append(
                ProfileNarrativeMemory(
                    id: "narrative-memory-proof",
                    title: "Recent proof can ground progress",
                    summary: "\(proofFeedbackCount) proof or feedback record\(proofFeedbackCount == 1 ? "" : "s") can make review language less intention-only.",
                    sourceLabel: "Proof and feedback",
                    freshness: .current,
                    usedFor: "Used for progress receipts, reviews, and deciding what still needs proof.",
                    sensitiveStatusLabel: "Private detail hidden",
                    actions: [
                        memoryAction(id: "narrative-proof-update", title: "Update this", statusLabel: "Use owning surface", detail: "Proof and feedback stay editable from Goal Detail, Capture, or Review context.", state: .default),
                        memoryAction(id: "narrative-proof-pause", title: "Pause use", statusLabel: "Review later", detail: "Pause is represented as a review need here until a safe preference exists.", state: .warning)
                    ],
                    accessibilityLabel: "Narrative memory from proof and feedback",
                    accessibilityValue: "Current. Private detail hidden in compact views.",
                    accessibilityHint: "Shows how proof and feedback can shape narrative memory without exposing sensitive detail."
                )
            )
        }

        if eventCount > 0 {
            memories.append(
                ProfileNarrativeMemory(
                    id: "narrative-memory-events",
                    title: "Recent actions can explain what changed",
                    summary: "\(eventCount) recent local event\(eventCount == 1 ? "" : "s") can support calm change explanations and recovery summaries.",
                    sourceLabel: "Event Ledger",
                    freshness: .current,
                    usedFor: "Used for Why Changed, recovery review, and receipt context.",
                    sensitiveStatusLabel: "Private by default",
                    actions: [
                        memoryAction(id: "narrative-events-inspect", title: "Inspect", statusLabel: "Available", detail: "Review happens through receipts, reviews, and owning surfaces.", state: .success),
                        memoryAction(id: "narrative-events-delete", title: "Delete", statusLabel: "Not exposed", detail: "Raw destructive deletion waits for a safe confirmation and undo boundary.", state: .warning)
                    ],
                    accessibilityLabel: "Narrative memory from recent actions",
                    accessibilityValue: "Current. Event Ledger. Private by default.",
                    accessibilityHint: "Shows how recent local actions can explain what changed and why deletion is not exposed here."
                )
            )
        }

        if memories.isEmpty {
            memories.append(
                ProfileNarrativeMemory(
                    id: "narrative-memory-empty",
                    title: "No narrative memory yet",
                    summary: openCaptures > 0 ? "Open captures may become reviewable memory after you place or archive them." : "Ambitions should stay evidence-light until local records, receipts, corrections, or reviews exist.",
                    sourceLabel: "Local records",
                    freshness: .basedOnOlderContext,
                    usedFor: "Used as a reminder not to pretend the app knows more than it does.",
                    sensitiveStatusLabel: "No sensitive inference",
                    actions: [
                        memoryAction(id: "narrative-empty-review", title: "Review", statusLabel: "Available later", detail: "Narrative memory appears only after explicit local evidence exists.", state: .default)
                    ],
                    accessibilityLabel: "No narrative memory yet",
                    accessibilityValue: "Based on Older Context. No sensitive category inferred.",
                    accessibilityHint: "Shows that Ambitions has no narrative memory to use yet."
                )
            )
        }

        return Array(memories.prefix(3))
    }

    func makeConservativeMemoryPatterns(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> [ProfileMemoryPattern] {
        var patterns: [ProfileMemoryPattern] = []

        if correctionCount > 0 {
            patterns.append(
                ProfileMemoryPattern(
                    id: "memory-pattern-corrections",
                    title: "Correction-shaped learning",
                    summary: "Only user-confirmed correction signals are treated as learning here.",
                    sourceLabel: "\(correctionCount) manual",
                    reviewLabel: "Review before reuse",
                    state: .success
                )
            )
        }

        if openCaptures > 0 {
            patterns.append(
                ProfileMemoryPattern(
                    id: "memory-pattern-open-captures",
                    title: "Loose items need a place",
                    summary: "Open captures may need routing before Ambitions should use them as context.",
                    sourceLabel: "\(openCaptures) open",
                    reviewLabel: "May Need Review",
                    state: .warning
                )
            )
        }

        if proofFeedbackCount + eventCount > 0 {
            patterns.append(
                ProfileMemoryPattern(
                    id: "memory-pattern-local-evidence",
                    title: "Local evidence exists",
                    summary: "Receipts, proof, feedback, or events can ground review language without becoming an automatic recommendation.",
                    sourceLabel: "\(proofFeedbackCount + eventCount) records",
                    reviewLabel: "Current",
                    state: .default
                )
            )
        }

        if patterns.isEmpty {
            patterns.append(
                ProfileMemoryPattern(
                    id: "memory-pattern-none",
                    title: "No pattern detected",
                    summary: "Ambitions should not invent a pattern when local evidence is thin.",
                    sourceLabel: "No evidence",
                    reviewLabel: "Based on Older Context",
                    state: .default
                )
            )
        }

        return Array(patterns.prefix(3))
    }

    func memoryAction(
        id: String,
        title: String,
        statusLabel: String,
        detail: String,
        state: AmbitionVisualState
    ) -> ProfileMemoryAction {
        ProfileMemoryAction(
            id: id,
            title: title,
            statusLabel: statusLabel,
            detail: detail,
            state: state
        )
    }

    func makeAssumptionCorrections(snapshot: Snapshot) -> ProfileAssumptionCorrectionState {
        let activeSignals = snapshot.teachingSignals.filter { $0.disposition == .active }
        let correctionEvents = snapshot.eventLedger.filter { $0.kind == .userCorrectionAdded }
        return ProfileAssumptionCorrectionState(
            title: "Corrections and assumptions",
            subtitle: "Ambitions should be teachable without asking you to understand its internals.",
            items: [
                SettingsItem(
                    id: "profile-correction-active",
                    title: "Active corrections",
                    subtitle: "Existing teaching signals are the current correction path. They are local and bounded to the artifacts they reference.",
                    icon: "checkmark.bubble",
                    valueLabel: activeSignals.isEmpty ? "None yet" : "\(activeSignals.count) active"
                ),
                SettingsItem(
                    id: "profile-correction-ledger",
                    title: "Correction events",
                    subtitle: "Correction-shaped ledger entries can be used as evidence for why future recommendations changed.",
                    icon: "clock.arrow.circlepath",
                    valueLabel: correctionEvents.isEmpty ? "No recent entries" : "\(correctionEvents.count) recent"
                ),
                SettingsItem(
                    id: "profile-correction-availability",
                    title: "You can correct this",
                    subtitle: "Goal Detail explanations and existing teaching flows remain the supported place to correct assumptions.",
                    icon: "pencil.and.list.clipboard",
                    valueLabel: "Supported where shown"
                )
            ],
            footer: "This is an entry point into existing correction systems, not a second memory model or a full Correction Review."
        )
    }

    func makeAutomationBoundary(safetySamples: SafetyBoundarySamples) -> ProfileAutomationBoundaryState {
        ProfileAutomationBoundaryState(
            title: "What Ambitions will not do silently",
            subtitle: "The safe automation policy keeps external, broad, destructive, and unsupported changes confirmation-gated or blocked.",
            rules: [
                ProfileConstitutionRule(
                    id: "automation-calendar",
                    title: "No silent calendar changes",
                    detail: safetySamples.calendarWrite.reasons.map(\.userFacingSummary).joined(separator: " "),
                    statusLabel: "Requires confirmation",
                    state: .warning
                ),
                ProfileConstitutionRule(
                    id: "automation-reflow",
                    title: "No silent broad reflow",
                    detail: safetySamples.broadReflow.reasons.map(\.userFacingSummary).joined(separator: " "),
                    statusLabel: "Requires confirmation",
                    state: .warning
                ),
                ProfileConstitutionRule(
                    id: "automation-memory",
                    title: "No unsupported forgetting",
                    detail: safetySamples.forgetMemory.blockedFacts.first ?? "No memory was forgotten.",
                    statusLabel: safetySamples.destructiveBlocked ? "Blocked safely" : "Unavailable",
                    state: .warning
                ),
                ProfileConstitutionRule(
                    id: "automation-correction",
                    title: "Corrections stay user-directed",
                    detail: "Correcting a recommendation is a local policy-recognized action when tied to an existing target.",
                    statusLabel: "User controlled",
                    state: .success
                )
            ],
            footer: "This describes policy decisions only. It does not execute calendar writes, sync resolution, deletion, or undo."
        )
    }

    func makePolicyReceipts(safetySamples: SafetyBoundarySamples) -> [ActionReceipt] {
        [
            safetySamples.calendarWrite.recommendedReceipt(occurredAt: "2026-04-27T00:00:00Z"),
            safetySamples.forgetMemory.recommendedReceipt(occurredAt: "2026-04-27T00:00:01Z"),
            safetySamples.localCorrection.recommendedReceipt(occurredAt: "2026-04-27T00:00:02Z")
        ]
    }

    func makeReceiptAudit(snapshot: Snapshot, receipts: [ActionReceipt]) -> ProfileReceiptAuditState {
        let projection = ActionReceiptProjection(receipts: receipts)
        return ProfileReceiptAuditState(
            title: "Receipts and audit posture",
            subtitle: "A compact trust summary of what can explain actions today. Reviews now turns these signals into a calm receipt layer.",
            items: [
                SettingsItem(
                    id: "profile-receipts-domain",
                    title: "Receipts",
                    subtitle: "Receipts can summarize what changed, why, correction availability, safe fallback, and undo status where supported.",
                    icon: "doc.text.magnifyingglass",
                    valueLabel: "\(projection.displaySummaries(limit: 3).count) policy examples"
                ),
                SettingsItem(
                    id: "profile-receipts-ledger",
                    title: "Recent Event Ledger",
                    subtitle: "Recent ledger entries remain local evidence. This page shows counts and status rather than raw logs.",
                    icon: "clock",
                    valueLabel: snapshot.eventLedger.isEmpty ? "No recent events" : "\(snapshot.eventLedger.count) recent"
                ),
                SettingsItem(
                    id: "profile-receipts-review",
                    title: "Reviews v1",
                    subtitle: "Recovery Review and Life OS Receipt summarize local events, receipts, proof, and corrections without creating a top-level Insights tab.",
                    icon: "rectangle.stack.badge.play",
                    valueLabel: snapshot.eventLedger.isEmpty ? "Nothing to review yet" : "Ready to review"
                )
            ],
            footer: "Receipts are exposed here as trust posture, not as a full history browser."
        )
    }

    func makeReviews(
        snapshot: Snapshot,
        receipts: [ActionReceipt],
        calendarAuthorization: CalendarRemindersAuthorizationState
    ) -> ProfileReviewsState {
        let projection = ReviewsV1Projector().project(
            ReviewsV1ProjectionInput(
                generatedAt: DomainTimestamp.string(from: .now),
                timeframeLabel: "Recent local review",
                eventLedgerEntries: snapshot.eventLedger,
                receipts: receipts,
                proofEvidence: snapshot.evidence,
                teachingSignals: snapshot.teachingSignals,
                calendarStatusLabel: calendarAuthorizationLabel(calendarAuthorization)
            )
        )

        return ProfileReviewsState(
            projection: projection,
            title: "Reviews",
            subtitle: "Recovery Review and Life OS Receipt for what happened, what changed, and what should carry forward.",
            footer: "Reviews uses existing local ledgers, receipts, proof, and correction signals. It does not restore Insights as a tab or claim live sync, account systems, or verified accessibility."
        )
    }

    func dominantTruth(
        syncStatus: SyncCapabilityStatus,
        notificationStatus: ProfileNotificationAuthorization,
        appearanceSummary: String
    ) -> String {
        if notificationStatus.statusLabel == "Denied" {
            return "Appearance is configured, but one trust edge still needs attention: notifications are denied."
        }
        return "Trust is \(syncStatus.trustPosture == .localOnly ? "local-first" : "bounded"), memory is inspectable, and risky changes require confirmation."
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
