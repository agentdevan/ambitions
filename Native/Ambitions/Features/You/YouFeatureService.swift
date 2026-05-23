import AmbitionsDesignSystem
import Foundation

/// A production-grade implementation of `YouServicing` that aggregates and orchestrates settings,
/// system preferences, trust parameters, and external service permissions.
///
/// `RepositoryBackedYouService` is responsible for querying local repositories concurrently to load active database state,
/// resolving on-device security policies, and compiling them into a thread-safe `YouDashboard`.
struct RepositoryBackedYouService: YouServicing {
    let repositories: AppRepositories
    let syncCapability: any SyncCapability
    let notificationService: any NotificationServicing
    let calendarRemindersService: any CalendarRemindersServicing

    /// Initializes the service with designated repositories and integration dependencies.
    ///
    /// - Parameters:
    ///   - repositories: The container holding references to all on-device data repositories.
    ///   - syncCapability: The sync capability engine, defaulting to local-only sync.
    ///   - notificationService: The system-level notification coordinator, defaulting to a stub implementation.
    ///   - calendarRemindersService: The coordination agent for EventKit boundaries, defaulting to a stub implementation.
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

    /// Compiles a thread-safe dashboard representation by reading user data models and authorization parameters concurrently.
    ///
    /// - Returns: A `YouDashboard` projection suited for rendering in visual and non-visual surfaces.
    /// - Throws: An error if loading data snapshot fails.
    func loadYouDashboard() async throws -> YouDashboard {
        async let snapshot = loadSnapshot()
        async let syncStatus = syncCapability.status()
        async let notificationAuthorization = notificationService.currentAuthorizationState()
        async let remindersAuthorization = calendarRemindersService.authorizationState(for: .reminders)
        async let calendarAuthorization = calendarRemindersService.authorizationState(for: .calendarEvents)
        
        return try await makeDashboard(
            snapshot: snapshot,
            syncStatus: syncStatus,
            notificationAuthorization: notificationAuthorization,
            remindersAuthorization: remindersAuthorization,
            calendarAuthorization: calendarAuthorization
        )
    }

    /// Persists visual accent and functional preference updates to on-device storage.
    /// Enforces programmatic preconditions and strict local-only privacy invariants.
    ///
    /// - Parameter preferences: The preference patch containing requested changes.
    /// - Returns: The updated, thread-safe dashboard representation.
    /// - Throws: An error if persistence fails.
    func saveYouPreferences(_ preferences: YouPreferencesUpdate) async throws -> YouDashboard {
        // Assert thread-safety and input range integrity under Swift 6 rules
        precondition(preferences.reviewCadenceDays >= 0, "Review cadence days cannot be negative.")
        
        var state = try await repositories.appState.loadState()
        state.preferredTab = preferences.preferredTab.canonicalTopLevelTab
        state.appearancePreference = preferences.appearancePreference
        state.accentFamily = preferences.accentFamily
        state.reviewCadenceDays = max(1, preferences.reviewCadenceDays)
        
        // Enforce the core local-first privacy boundary
        state.localOnlyModeEnabled = true
        
        try await repositories.appState.saveState(state)
        return try await loadYouDashboard()
    }
}

private extension RepositoryBackedYouService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let captures: [Capture]
        let teachingSignals: [GoalTeachingSignal]
        let eventLedger: [EventLedgerEntry]
        let lifeContextBundles: [LifeContextBundle]
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
        async let lifeContextBundles = loadLifeContextBundles()
        async let appState = repositories.appState.loadState()

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            captures: captures,
            teachingSignals: teachingSignals,
            eventLedger: eventLedger,
            lifeContextBundles: lifeContextBundles,
            appState: appState
        )
    }

    func loadLifeContextBundles() async throws -> [LifeContextBundle] {
        guard let repository = repositories.lifeContext else {
            return []
        }

        return try await repository.listBundles()
    }

    func makeDashboard(
        snapshot: Snapshot,
        syncStatus: SyncCapabilityStatus,
        notificationAuthorization: NotificationAuthorizationState,
        remindersAuthorization: CalendarRemindersAuthorizationState,
        calendarAuthorization: CalendarRemindersAuthorizationState
    ) -> YouDashboard {
        let activeGoals = snapshot.goals.filter { $0.state == .active }.count
        let clarificationCount = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }.count
        let blockedCount = snapshot.drafts.filter { $0.latestResultKind == .blocked }.count
        let openCaptures = snapshot.captures.filter { $0.status != .archived }.count
        let trimmedName = snapshot.appState.userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let profileTitle = trimmedName.isEmpty ? "Your System" : "\(trimmedName)'s System"
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
        let lifeContext = makeLifeContextState(snapshot: snapshot)

        return YouDashboard(
            hero: YouHeroState(
                title: profileTitle,
                subtitle: "Your System keeps trust, privacy, receipts, planning setup, and defaults visible.",
                dominantTruth: dominantTruth(
                    syncStatus: syncStatus,
                    notificationStatus: notificationStatus,
                    appearanceSummary: appearanceSummary
                ),
                supportingTruth: "Ambitions starts local-first, keeps risky actions confirmation-gated, and treats memory as something you can inspect and correct.",
                trustWhisper: "No silent calendar changes. \(syncTrustStatusLabel(syncStatus)). No destructive memory deletion from this surface.",
                status: syncState,
                pills: [
                    YouStatusPill(id: "you-pill-appearance", title: appearanceSummary, icon: "paintpalette", state: .selected),
                    YouStatusPill(id: "you-pill-sync", title: syncStatus.detail, icon: "lock.shield", state: syncState),
                    YouStatusPill(
                        id: "you-pill-context",
                        title: contextSignals == 0 ? "No local memory signals yet" : "\(contextSignals) local memory signals",
                        icon: "waveform.path.ecg",
                        state: contextSignals == 0 ? .default : .default
                    )
                ],
                stats: [
                    MetricSummary(id: "you-active-goals", title: "Open goals", value: "\(activeGoals)", detail: "Active native goals", icon: "target"),
                    MetricSummary(id: "you-confirmation", title: "Confirmation rules", value: "\(safetySamples.confirmationRequired)", detail: "Sampled risky actions", icon: "hand.raised"),
                    MetricSummary(id: "you-corrections", title: "Corrections", value: "\(snapshot.teachingSignals.count)", detail: "User teaching signals", icon: "checkmark.seal"),
                    MetricSummary(id: "you-context", title: "Memory areas", value: "\(contextSignals)", detail: "Evidence, feedback, teaching, ledger", icon: "sparkles")
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
            controlRoom: YouControlRoomState(
                title: "Control room",
                subtitle: "A short map of the trust areas you can inspect without turning You into a settings dump.",
                entries: [
                    YouControlRoomEntry(
                        id: "you-control-constitution",
                        title: "Personal Operating Constitution",
                        subtitle: "Recommendation posture, recovery tone, planning strictness, and confirmation rules.",
                        icon: "scroll",
                        statusLabel: "Local defaults",
                        state: .selected
                    ),
                    YouControlRoomEntry(
                        id: "you-control-memory",
                        title: "What Ambitions Knows",
                        subtitle: "Local evidence, feedback, corrections, captures, and event history Ambitions can explain and let you correct.",
                        icon: "brain.head.profile",
                        statusLabel: "Stored on this device",
                        state: .default
                    ),
                    YouControlRoomEntry(
                        id: "you-control-corrections",
                        title: "Corrections and assumptions",
                        subtitle: "Assumptions can be corrected through existing teaching and explanation paths.",
                        icon: "checkmark.bubble",
                        statusLabel: snapshot.teachingSignals.isEmpty ? "Available when present" : "\(snapshot.teachingSignals.count) active",
                        state: snapshot.teachingSignals.isEmpty ? .default : .success
                    ),
                    YouControlRoomEntry(
                        id: "you-control-receipts",
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
            planningDefaultsCenter: makePlanningDefaultsCenter(
                calendarAuthorization: calendarAuthorization,
                remindersAuthorization: remindersAuthorization,
                safetySamples: safetySamples
            ),
            availabilityCenter: makeAvailabilityCenter(
                calendarAuthorization: calendarAuthorization,
                remindersAuthorization: remindersAuthorization,
                safetySamples: safetySamples
            ),
            receiptAudit: makeReceiptAudit(snapshot: snapshot, receipts: policyReceipts),
            trustHistoryCenter: makeTrustHistoryCenter(
                snapshot: snapshot,
                receipts: policyReceipts,
                safetySamples: safetySamples,
                calendarAuthorization: calendarAuthorization,
                notificationStatus: notificationStatus
            ),
            crossSurfaceProofReview: makeCrossSurfaceProofReview(snapshot: snapshot),
            reviews: reviews,
            appearanceStudio: YouAppearanceStudioState(
                title: "Appearance Studio",
                subtitle: "Curated, authored control over mode and accent so the shell stays legible without turning into a palette catalog.",
                previewSummary: "Preview the current palette against real Ambitions objects before you save.",
                modeOptions: AppAppearancePreference.allCases.map { preference in
                    YouAppearanceOption(
                        id: "appearance-\(preference.rawValue)",
                        title: preference.title,
                        subtitle: appearanceSubtitle(for: preference),
                        preference: preference
                    )
                },
                accentOptions: AmbitionAccentFamily.allCases.map { family in
                    YouAccentOption(
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
            trustCenter: YouTrustCenterState(
                title: "Trust Center",
                subtitle: "Truthful status for local-first data, permissions, external surfaces, sync, automation, and recovery.",
                pulse: YouTrustPulseState(
                    title: "Local trust pulse",
                    subtitle: syncPulseTitle(for: syncStatus),
                    detail: "Stored on this device. Optional permissions are explicit. Future sync and external surfaces remain labeled until verified.",
                    state: syncState
                ),
                items: [
                    SettingsItem(
                        id: "you-trust-sync",
                        title: "System trust posture",
                        subtitle: "The current runtime uses on-device storage. Apple-first sync is future-owned and not currently connected.",
                        icon: "lock.shield",
                        valueLabel: syncTrustStatusLabel(syncStatus)
                    ),
                    SettingsItem(
                        id: "you-trust-calendar",
                        title: "Calendar boundary",
                        subtitle: "Time may request calendar awareness after a clear action. Ambitions does not silently write calendar changes.",
                        icon: "calendar.badge.clock",
                        valueLabel: calendarAuthorizationLabel(calendarAuthorization)
                    ),
                    SettingsItem(
                        id: "you-trust-notifications",
                        title: "Notification pulse",
                        subtitle: "Local reminder scheduling exists on the current runtime. Authorization stays explicit here so ambient trust never feels hidden.",
                        icon: "bell.badge",
                        valueLabel: notificationStatus.statusLabel
                    ),
                    SettingsItem(
                        id: "you-trust-routing",
                        title: "System status",
                        subtitle: "\(ExternalSurfaceTruth.verifiedRoutingTruth). External routes stay on canonical destinations, and ambient surfaces preserve local-first continuity language.",
                        icon: "arrow.triangle.branch",
                        valueLabel: "Calm"
                    ),
                    SettingsItem(
                        id: "you-trust-accessibility",
                        title: "Accessibility Nutrition",
                        subtitle: "Internal checklist infrastructure exists. Public claims are locked until manual verification is recorded.",
                        icon: "figure",
                        valueLabel: "Claims locked"
                    ),
                    SettingsItem(
                        id: "you-trust-export-import",
                        title: "Export and disaster recovery",
                        subtitle: "Portable snapshot foundations exist, but the proof drill is not complete. This surface does not claim export is production-ready.",
                        icon: "externaldrive.badge.icloud",
                        valueLabel: "Requires confirmation"
                    )
                ],
                dataMap: makeTrustDataMap(
                    snapshot: snapshot,
                    syncStatus: syncStatus,
                    notificationStatus: notificationStatus,
                    calendarAuthorization: calendarAuthorization,
                    receipts: policyReceipts
                ),
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
            contextVault: YouContextVaultState(
                title: "Local memory map",
                subtitle: "A compact inventory of local signal types, not an automatic profile.",
                items: [
                    YouContextVaultItem(
                        id: "you-vault-signals",
                        title: "Recommendation evidence",
                        subtitle: "These categories can explain recommendations without claiming cloud intelligence.",
                        icon: "tray.full",
                        detail: "\(snapshot.evidence.count) evidence records, \(snapshot.feedback.count) feedback events, \(snapshot.teachingSignals.count) teaching signals, \(eventLedgerCount) recent ledger events"
                    ),
                    YouContextVaultItem(
                        id: "you-vault-planning",
                        title: "Planning memory",
                        subtitle: "Clarifications, blocked drafts, and open captures stay visible so future intelligence work remains auditable.",
                        icon: "rectangle.stack.badge.person.crop",
                        detail: "\(clarificationCount + blockedCount) draft signals, \(openCaptures) open captures"
                    ),
                    YouContextVaultItem(
                        id: "you-vault-identity",
                        title: "Personal defaults",
                        subtitle: "Name, launch defaults, and appearance stay separate from the execution surfaces they influence.",
                        icon: "person.text.rectangle",
                        detail: trimmedName.isEmpty ? "No display name stored" : trimmedName
                    )
                ],
                policyItems: [
                    YouSignalPolicyItem(
                        id: "you-policy-optional",
                        title: "Optional by design",
                        detail: "Context is there to improve fit and trust. It is not required to use the core planning system.",
                        state: .default
                    ),
                    YouSignalPolicyItem(
                        id: "you-policy-local",
                        title: "Local-first posture",
                        detail: "Signals stay on device in this build and should remain inspectable before any future continuity expansion.",
                        state: .selected
                    ),
                    YouSignalPolicyItem(
                        id: "you-policy-explicit",
                        title: "Inspectable and understandable",
                        detail: "The app should be able to explain what signal types exist without feeling invasive or technical.",
                        state: .default
                    )
                ],
                footer: "This is a foundation layer, not a full privacy admin surface. It keeps current local context understandable without inventing account, sync, or export flows."
            ),
            lifeContext: lifeContext,
            integrationsSection: YouSectionGroup(
                title: "Integrations and permissions",
                subtitle: "Only the system edges that materially affect trust or routing belong here.",
                items: [
                    SettingsItem(
                        id: "you-integration-notifications",
                        title: "Notifications",
                        subtitle: notificationAuthorizationSubtitle(for: notificationStatus),
                        icon: "bell.badge",
                        valueLabel: notificationStatus.statusLabel
                    ),
                    SettingsItem(
                        id: "you-integration-reminders",
                        title: "Reminders integration",
                        subtitle: "Reminder write paths exist on the current EventKit seam. Authorization stays explicit so scheduling trust is legible.",
                        icon: "checklist",
                        valueLabel: calendarAuthorizationLabel(remindersAuthorization)
                    ),
                    SettingsItem(
                        id: "you-integration-calendar",
                        title: "Calendar integration",
                        subtitle: "Calendar event creation and conflict detection exist on the shared EventKit seam. Read depth depends on authorization level.",
                        icon: "calendar.badge.clock",
                        valueLabel: calendarAuthorizationLabel(calendarAuthorization)
                    ),
                    SettingsItem(
                        id: "you-integration-widgets",
                        title: "Widgets and Live Activity",
                        subtitle: "\(ExternalSurfaceTruth.productizedNeedsPlatformReview). Widgets and Live Activity read the shared external snapshot, Now State Lease, and local-first continuity posture.",
                        icon: "rectangle.3.group",
                        valueLabel: ExternalSurfaceTruth.productizedNeedsPlatformReview
                    ),
                    SettingsItem(
                        id: "you-integration-shortcuts",
                        title: "Navigation shortcuts",
                        subtitle: "\(ExternalSurfaceTruth.productizedNeedsPlatformReview). Shortcuts support quick capture, focus, recovery, plan, and canonical open routes through the shared external handoff path.",
                        icon: "sparkles.rectangle.stack",
                        valueLabel: ExternalSurfaceTruth.productizedNeedsPlatformReview
                    ),
                    SettingsItem(
                        id: "you-integration-share",
                        title: "Share Extension",
                        subtitle: "\(ExternalSurfaceTruth.productizedNeedsPlatformReview). Shared text and URLs enter local Ambitions captures first, then land in the normal review or goal-creation path.",
                        icon: "square.and.arrow.up",
                        valueLabel: ExternalSurfaceTruth.productizedNeedsPlatformReview
                    )
                ],
                footer: "Notification and integration status should answer whether anything important needs attention without turning You into an admin checklist."
            ),
            defaultsSection: YouSectionGroup(
                title: "Personal defaults",
                subtitle: "These choices shape the shell, not the truth of your goals or day.",
                items: [
                    SettingsItem(
                        id: "you-default-tab",
                        title: "Default landing tab",
                        subtitle: "Used on the next cold launch so re-entry starts where you prefer.",
                        icon: "square.grid.2x2",
                        valueLabel: snapshot.appState.preferredTab.canonicalTopLevelTab.title
                    ),
                    SettingsItem(
                        id: "you-default-review",
                        title: "Review cadence",
                        subtitle: "How often the app frames a planning reset using the current local planning loop.",
                        icon: "clock.arrow.circlepath",
                        valueLabel: reviewLabel(days: snapshot.appState.reviewCadenceDays)
                    ),
                    SettingsItem(
                        id: "you-default-rituals",
                        title: "Rituals",
                        subtitle: "Recurring support lives under Time, Today, Goal Detail, and Reviews instead of a standalone area.",
                        icon: "repeat",
                        valueLabel: "Time-owned"
                    ),
                    SettingsItem(
                        id: "you-default-storage",
                        title: "Storage mode",
                        subtitle: "Goals, captures, evidence, and teaching signals persist through the native on-device repositories.",
                        icon: "internaldrive",
                        valueLabel: snapshot.appState.localOnlyModeEnabled ? "Local-only" : "Unknown"
                    )
                ],
                footer: nil
            ),
            accountSection: YouSectionGroup(
                title: "Local app status",
                subtitle: "This build stays explicit about what is not configured yet so You never implies hidden account requirements.",
                items: [
                    SettingsItem(
                        id: "you-account-mode",
                        title: "Local mode",
                        subtitle: "No sign-in or cloud account is required for the current shipping native experience.",
                        icon: "person.crop.circle",
                        valueLabel: "On-device only"
                    ),
                    SettingsItem(
                        id: "you-account-billing",
                        title: "Purchases",
                        subtitle: "Subscriptions, digital unlocks, and purchase flows are not active product scope in this build.",
                        icon: "creditcard",
                        valueLabel: "Not active"
                    )
                ],
                footer: "Future account or monetization work should land only when canon and release-compliance truth explicitly activate it."
            ),
            notificationAuthorization: notificationStatus,
            preferences: YouPreferencesState(
                preferredTab: snapshot.appState.preferredTab.canonicalTopLevelTab,
                appearancePreference: snapshot.appState.appearancePreference,
                accentFamily: snapshot.appState.accentFamily,
                reviewCadenceDays: snapshot.appState.reviewCadenceDays,
                localOnlyModeEnabled: true
            )
        )
    }

    func makeTrustDataMap(
        snapshot: Snapshot,
        syncStatus: SyncCapabilityStatus,
        notificationStatus: YouNotificationAuthorization,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        receipts: [ActionReceipt]
    ) -> [YouTrustDataMapItem] {
        let openCaptures = snapshot.captures.filter { $0.status != .archived }.count
        let receiptCount = ActionReceiptProjection(receipts: receipts).displaySummaries().count
        let localSignalCount = snapshot.evidence.count + snapshot.feedback.count + snapshot.teachingSignals.count + snapshot.eventLedger.count
        return [
            YouTrustDataMapItem(
                id: "trust-data-map-local-context",
                title: "Local context",
                dataTypes: "Goals, captures, proof, corrections, receipts, reviews",
                sourceLabel: "\(localSignalCount) local signals, \(openCaptures) open captures",
                controlLabel: "Inspect and correct from owning surfaces",
                privacyLabel: "Private by default",
                statusLabel: "Stored on this device",
                semanticState: .trust
            ),
            YouTrustDataMapItem(
                id: "trust-data-map-permissions",
                title: "Permission boundaries",
                dataTypes: "Notifications and Time-owned calendar awareness",
                sourceLabel: "Notifications \(notificationStatus.statusLabel); calendar \(calendarAuthorizationLabel(calendarAuthorization))",
                controlLabel: "System permission controls stay explicit",
                privacyLabel: "No silent calendar writes",
                statusLabel: "Permission-gated",
                semanticState: .calendarDerived
            ),
            YouTrustDataMapItem(
                id: "trust-data-map-receipts",
                title: "Receipts and correction state",
                dataTypes: "Action receipts, undo posture, correction availability",
                sourceLabel: receiptCount == 0 ? "No recent receipts" : "\(receiptCount) receipt examples",
                controlLabel: "Change, correct, or review where supported",
                privacyLabel: "Summaries first",
                statusLabel: "Evidence-led",
                semanticState: .review
            ),
            YouTrustDataMapItem(
                id: "trust-data-map-future-owned",
                title: "Future-owned edges",
                dataTypes: "Sync, export proof, destructive delete, broad memory controls",
                sourceLabel: syncStatus.detail,
                controlLabel: "Blocked until owner proof confirms safety",
                privacyLabel: "No hidden account or cloud claim",
                statusLabel: "Future-owned",
                semanticState: .caution
            )
        ]
    }

    func makeTrustCenterSections(
        syncStatus: SyncCapabilityStatus,
        notificationStatus: YouNotificationAuthorization,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        receipts: [ActionReceipt],
        teachingSignalCount: Int
    ) -> [YouTrustCenterSection] {
        let receiptProjection = ActionReceiptProjection(receipts: receipts)
        let undoCount = receiptProjection.undoAvailableReceipts().count
        let receiptCount = receiptProjection.displaySummaries().count

        return [
            YouTrustCenterSection(
                id: "trust-center-status",
                title: "Status and boundaries",
                footer: "These rows describe current runtime truth. They do not request permissions or enable future services by themselves.",
                routes: [
                    YouTrustCenterRoute(
                        id: "trust-route-local-data",
                        title: "Local data status",
                        subtitle: "Goals, captures, proof, corrections, receipts, and reviews read from this device in the current runtime.",
                        icon: "internaldrive",
                        statusLabel: "Stored on this device",
                        semanticState: .trust,
                        accessibilityHint: "Shows local storage trust status."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-calendar",
                        title: "Calendar boundary",
                        subtitle: "Calendar awareness is Time-owned. Writes require confirmation and are never silent.",
                        icon: "calendar.badge.clock",
                        statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                        semanticState: .calendarDerived,
                        accessibilityHint: "Shows calendar permission and write boundary."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-notifications",
                        title: "Notification boundary",
                        subtitle: "Local reminders are optional and permission-gated. Ambitions still works without notification access.",
                        icon: "bell.badge",
                        statusLabel: notificationStatus.statusLabel,
                        semanticState: notificationStatus.statusLabel == "Denied" ? .caution : .neutral,
                        accessibilityHint: "Shows notification permission status."
                    ),
                    YouTrustCenterRoute(
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
            YouTrustCenterSection(
                id: "trust-center-receipts",
                title: "Receipts, corrections, and explanations",
                footer: "Receipt rows summarize policy and action history without exposing raw logs by default.",
                routes: [
                    YouTrustCenterRoute(
                        id: "trust-route-receipts",
                        title: "Receipts",
                        subtitle: "Receipts say what happened, what changed, why, and what can be corrected or undone.",
                        icon: "doc.text.magnifyingglass",
                        statusLabel: receiptCount == 0 ? "No recent receipts" : "\(receiptCount) examples",
                        semanticState: .review,
                        accessibilityHint: "Shows receipt history posture."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-why-this",
                        title: "Why This?",
                        subtitle: "Recommendations name the action, source, reason, uncertainty, user control, and receipt behavior before trust-sensitive action.",
                        icon: "questionmark.bubble",
                        statusLabel: "Explain first",
                        semanticState: .trust,
                        accessibilityHint: "Shows why this explanation posture."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-quiet-reflow",
                        title: "Quiet Reflow",
                        subtitle: "Meaningful time changes stay previewed before apply; manual planning remains available if a source is unavailable.",
                        icon: "arrow.triangle.2.circlepath",
                        statusLabel: "Preview first",
                        semanticState: .calendarDerived,
                        accessibilityHint: "Shows reflow preview and manual fallback posture."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-corrections",
                        title: "Correction routes",
                        subtitle: "Supported corrections stay tied to existing Goal Detail, Capture, teaching, and explanation seams.",
                        icon: "checkmark.bubble",
                        statusLabel: teachingSignalCount == 0 ? "Available where shown" : "\(teachingSignalCount) local",
                        semanticState: .trust,
                        accessibilityHint: "Shows correction availability."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-undo",
                        title: "Undo rules",
                        subtitle: "Local undo is shown only where safe. Broad, external, destructive, or unsupported changes stay blocked or confirmation-gated.",
                        icon: "arrow.uturn.backward",
                        statusLabel: undoCount == 0 ? "No silent undo" : "\(undoCount) available",
                        semanticState: .caution,
                        accessibilityHint: "Shows undo safety posture."
                    ),
                    YouTrustCenterRoute(
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
            YouTrustCenterSection(
                id: "trust-center-privacy-future",
                title: "Privacy and future-owned capabilities",
                footer: "Unavailable states stay visible so this surface does not imply hidden accounts, cloud sync, or production-ready export.",
                routes: [
                    YouTrustCenterRoute(
                        id: "trust-route-privacy",
                        title: "Privacy defaults",
                        subtitle: "Sensitive details should be hidden on compact and external surfaces unless the user chooses otherwise.",
                        icon: "hand.raised",
                        statusLabel: "Private by default",
                        semanticState: .protected,
                        accessibilityHint: "Shows privacy-safe display posture."
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-sync-export",
                        title: "Sync / Export truth",
                        subtitle: syncExportTruthSubtitle(syncStatus),
                        icon: "externaldrive",
                        statusLabel: syncTrustStatusLabel(syncStatus),
                        semanticState: .caution,
                        accessibilityHint: "Shows sync and export truth."
                    ),
                    YouTrustCenterRoute(
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
        notificationStatus: YouNotificationAuthorization,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        reviews: YouReviewsState,
        contextSignals: Int,
        appearanceSummary: String
    ) -> YouSystemCenterState {
        YouSystemCenterState(
            title: "Your System",
            subtitle: "User System You keeps Planning Setup, Trust & Automation, Privacy, Receipts & History, and Defaults visible.",
            sections: [
                YouSystemCenterSection(
                    id: "planning-behavior",
                    title: "Planning Setup",
                    footer: "Guided automation is the default. Ambitions does not fill open time just because it exists.",
                    items: [
                        YouSystemCenterItem(
                            id: "schedule-availability",
                            title: "Schedule & Availability",
                            subtitle: "Work, school, protected time, buffers, and anchors.",
                            icon: "calendar.badge.clock",
                            statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                            semanticState: .calendarDerived,
                            accessibilityHint: "Opens Schedule and Availability."
                        ),
                        YouSystemCenterItem(
                            id: "plan-behavior",
                            title: "Time Behavior",
                            subtitle: "Open time, protected free time, buffers, and reflow rules.",
                            icon: "slider.horizontal.below.rectangle",
                            statusLabel: "Do not fill",
                            semanticState: .protected,
                            accessibilityHint: "Opens Time Behavior."
                        ),
                        YouSystemCenterItem(
                            id: "automation-trust",
                            title: "Trust & Automation",
                            subtitle: "Trust comes before automation. \(AutomationLevel.defaultLevel.explanation)",
                            icon: "hand.raised",
                            statusLabel: AutomationLevel.defaultLevel.displayLabel,
                            semanticState: .trust,
                            accessibilityHint: "Opens Trust and Automation."
                        ),
                        YouSystemCenterItem(
                            id: "vacation-away-time",
                            title: "Vacation / Away Time",
                            subtitle: "Vacation is not free time unless you mark it open.",
                            icon: "airplane.departure",
                            statusLabel: VacationAvailabilityBehavior.defaultBehavior.displayLabel,
                            semanticState: .protected,
                            accessibilityHint: "Opens Vacation and Away Time."
                        ),
                        YouSystemCenterItem(
                            id: "durations",
                            title: "Durations",
                            subtitle: "Planned, suggested, historical, actual, or unset.",
                            icon: "timer",
                            statusLabel: "Grounded",
                            semanticState: .trust,
                            accessibilityHint: "Opens duration behavior."
                        )
                    ]
                ),
                YouSystemCenterSection(
                    id: "memory-and-trust",
                    title: "Memory and Trust",
                    footer: nil,
                    items: [
                        YouSystemCenterItem(
                            id: "what-ambitions-knows",
                            title: "What Ambitions Knows",
                            subtitle: "Saved local context you can inspect and correct.",
                            icon: "brain.head.profile",
                            statusLabel: contextSignals == 0 ? "Empty" : "Stored on this device",
                            semanticState: contextSignals == 0 ? .neutral : .trust,
                            accessibilityHint: "Opens local memory controls."
                        ),
                        YouSystemCenterItem(
                            id: "trust-center",
                            title: "Trust Center",
                            subtitle: "Permissions, privacy, and boundaries.",
                            icon: "checkmark.shield",
                            statusLabel: "Review",
                            semanticState: .trust,
                            accessibilityHint: "Opens Trust Center."
                        ),
                        YouSystemCenterItem(
                            id: "receipts-history",
                            title: "Receipts & History",
                            subtitle: "What changed and why.",
                            icon: "doc.text.magnifyingglass",
                            statusLabel: "Stored on this device",
                            semanticState: .neutral,
                            accessibilityHint: "Opens receipt history."
                        ),
                        YouSystemCenterItem(
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
                YouSystemCenterSection(
                    id: "reviews-and-progress",
                    title: "Reviews and Progress",
                    footer: nil,
                    items: [
                        YouSystemCenterItem(
                            id: "reviews",
                            title: "Reviews",
                            subtitle: "Recovery and progress check-ins.",
                            icon: "rectangle.stack.badge.play",
                            statusLabel: "Review",
                            semanticState: .review,
                            accessibilityHint: "Opens Reviews."
                        ),
                        YouSystemCenterItem(
                            id: "proof",
                            title: "Proof",
                            subtitle: "Evidence and progress notes.",
                            icon: "checkmark.seal",
                            statusLabel: "Local",
                            semanticState: .success,
                            accessibilityHint: "Opens proof summary."
                        ),
                        YouSystemCenterItem(
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
                YouSystemCenterSection(
                    id: "personal-defaults",
                    title: "Defaults",
                    footer: nil,
                    items: [
                        YouSystemCenterItem(
                            id: "you",
                            title: "User System Profile",
                            subtitle: "Name and default landing tab.",
                            icon: "person.crop.circle",
                            statusLabel: snapshot.appState.userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Optional" : "Local",
                            semanticState: .neutral,
                            accessibilityHint: "Opens User System Profile settings."
                        ),
                        YouSystemCenterItem(
                            id: "personalization",
                            title: "Personalization",
                            subtitle: "Tone and planning defaults.",
                            icon: "slider.horizontal.3",
                            statusLabel: "Defaults",
                            semanticState: .trust,
                            accessibilityHint: "Opens personalization settings."
                        ),
                        YouSystemCenterItem(
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
                YouSystemCenterSection(
                    id: "system-edges",
                    title: "System Edges",
                    footer: nil,
                    items: [
                        YouSystemCenterItem(
                            id: "notifications",
                            title: "Notifications",
                            subtitle: "Reminder permission.",
                            icon: "bell.badge",
                            statusLabel: notificationStatus.statusLabel,
                            semanticState: notificationStatus.statusLabel == "Denied" ? .caution : .neutral,
                            accessibilityHint: "Opens notification settings."
                        ),
                        YouSystemCenterItem(
                            id: "integrations",
                            title: "Integrations",
                            subtitle: "Calendar and reminders.",
                            icon: "rectangle.connected.to.line.below",
                            statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                            semanticState: .calendarDerived,
                            accessibilityHint: "Opens integrations."
                        ),
                        YouSystemCenterItem(
                            id: "widgets-live-activities-shortcuts",
                            title: "Widgets / Live Activities / Shortcuts",
                            subtitle: "External surface status.",
                            icon: "square.grid.2x2",
                            statusLabel: "Bounded",
                            semanticState: .neutral,
                            accessibilityHint: "Opens external surface status."
                        ),
                        YouSystemCenterItem(
                            id: "export-import",
                            title: "Export / Import",
                            subtitle: "Local backup and restore posture.",
                            icon: "externaldrive",
                            statusLabel: syncTrustStatusLabel(syncStatus),
                            semanticState: .caution,
                            accessibilityHint: "Opens export and import status."
                        )
                    ]
                ),
                YouSystemCenterSection(
                    id: "accessibility-and-support",
                    title: "Accessibility and Support",
                    footer: "Rows open details; nothing here changes plans silently.",
                    items: [
                        YouSystemCenterItem(
                            id: "accessibility",
                            title: "Accessibility",
                            subtitle: "Claims and manual review status.",
                            icon: "figure",
                            statusLabel: "Locked",
                            semanticState: .accessibilityUnverified,
                            accessibilityHint: "Opens accessibility status."
                        ),
                        YouSystemCenterItem(
                            id: "help-support",
                            title: "Help / Support",
                            subtitle: "Guidance and support posture.",
                            icon: "questionmark.circle",
                            statusLabel: "Guide",
                            semanticState: .neutral,
                            accessibilityHint: "Opens help and support."
                        ),
                        YouSystemCenterItem(
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
            footer: "You keeps setup, history, trust, and controls together without changing anything silently."
        )
    }

    func makePreviewSwatches(
        selectedAppearance: AppAppearancePreference,
        selectedAccent: AmbitionAccentFamily
    ) -> [YouPreviewSwatch] {
        [
            YouPreviewSwatch(
                id: "preview-now",
                title: "Start Here",
                subtitle: "Primary decision surface with one calm action and source proof.",
                eyebrow: "Decision",
                objectKind: .startHere,
                accentFamily: selectedAccent,
                appearancePreference: selectedAppearance,
                state: .selected,
                accessibilityLabel: "Appearance preview for Start Here decision surface"
            ),
            YouPreviewSwatch(
                id: "preview-rail",
                title: "Reality Meridian",
                subtitle: "Now, Next, and Later stay readable without status clutter.",
                eyebrow: "Continuity",
                objectKind: .realityRail,
                accentFamily: selectedAccent,
                appearancePreference: selectedAppearance,
                state: .default,
                accessibilityLabel: "Appearance preview for Reality Meridian continuity spine"
            ),
            YouPreviewSwatch(
                id: "preview-lifeshape",
                title: "LifeShape",
                subtitle: "Capacity contour keeps pressure visible without becoming a calendar.",
                eyebrow: "Capacity",
                objectKind: .lifeShape,
                accentFamily: selectedAccent,
                appearancePreference: selectedAppearance,
                state: .default,
                accessibilityLabel: "Appearance preview for LifeShape capacity contour"
            ),
            YouPreviewSwatch(
                id: "preview-receipt",
                title: "Receipt Drawer",
                subtitle: "Proof and source folds keep trust quieter than primary action.",
                eyebrow: "Proof",
                objectKind: .receiptDrawer,
                accentFamily: selectedAccent,
                appearancePreference: selectedAppearance,
                state: .default,
                accessibilityLabel: "Appearance preview for Receipt Drawer trust layer"
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
        let planBlock = LifeGraphObjectReference(kind: .action, id: "you-policy-calendar-write", sourceDomain: .time)
        let planStep = LifeGraphObjectReference(kind: .step, id: "you-policy-reflow", sourceDomain: .time)
        let memoryObject = LifeGraphObjectReference(kind: .correction, id: "you-policy-memory", sourceDomain: .you)
        let correctionObject = LifeGraphObjectReference(kind: .correction, id: "you-policy-correction", sourceDomain: .you)

        return SafetyBoundarySamples(
            calendarWrite: evaluator.evaluate(
                SafeAutomationProposedAction(kind: .writeCalendarBlock, sourceDomain: .time, targetObjects: [planBlock])
            ),
            broadReflow: evaluator.evaluate(
                SafeAutomationProposedAction(kind: .splitAction, sourceDomain: .time, targetObjects: [planStep])
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
        notificationStatus: YouNotificationAuthorization,
        safetySamples: SafetyBoundarySamples
    ) -> YouConstitutionState {
        YouConstitutionState(
            title: "Personal Operating Constitution",
            subtitle: "The local rules Ambitions uses to stay useful without becoming pushy or silent.",
            postureSummary: "Calm, conservative, correction-aware, and local-first by default.",
            rules: [
                YouConstitutionRule(
                    id: "constitution-local-first",
                    title: "Start from local truth",
                    detail: "Goals, captures, evidence, corrections, and recent ledger events are read from this device. Sync is not currently connected.",
                    statusLabel: "Stored on this device",
                    state: .selected
                ),
                YouConstitutionRule(
                    id: "constitution-recommendation-posture",
                    title: "Suggest one doable step",
                    detail: "Suggestions should be explainable by goal, plan, evidence, or recent feedback, not vague intelligence claims.",
                    statusLabel: snapshot.eventLedger.isEmpty ? "Evidence-light" : "Uses local evidence",
                    state: .default
                ),
                YouConstitutionRule(
                    id: "constitution-recovery-tone",
                    title: "Recover without shame",
                    detail: "Delays, skips, and smaller-version requests are treated as recovery context, not blame.",
                    statusLabel: "Calm recovery",
                    state: .success
                ),
                YouConstitutionRule(
                    id: "constitution-low-risk-preferences",
                    title: "Make low-risk preferences visible",
                    detail: "Display, density, recovery, and repeated routing preferences may be remembered only when they stay visible, source-tied, and correctable.",
                    statusLabel: "Receipt first",
                    state: .default
                ),
                YouConstitutionRule(
                    id: "constitution-sensitive-memory",
                    title: "Ask before sensitive memory",
                    detail: "Health, relationship, financial, location, calendar-derived, and sensitive Life Area context requires user review before stronger memory use.",
                    statusLabel: "Approval required",
                    state: .warning
                ),
                YouConstitutionRule(
                    id: "constitution-operating-manual-evidence",
                    title: "Do not invent an operating manual",
                    detail: "The personal operating manual can summarize explicit local choices and evidence, but it must admit when context is thin.",
                    statusLabel: snapshot.eventLedger.isEmpty && snapshot.teachingSignals.isEmpty ? "Evidence-light" : "Evidence-led",
                    state: snapshot.eventLedger.isEmpty && snapshot.teachingSignals.isEmpty ? .default : .success
                ),
                YouConstitutionRule(
                    id: "constitution-calendar",
                    title: "Ask before calendar writes",
                    detail: "Calendar access is explicit and Time-owned. Calendar writes require confirmation and are never silent.",
                    statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                    state: safetySamples.calendarWrite.mustNeverBeSilent ? .warning : .default
                ),
                YouConstitutionRule(
                    id: "constitution-interruptions",
                    title: "Interruptions stay optional",
                    detail: "Notifications can support reminders, but Ambitions still works when notification access is denied or not requested.",
                    statusLabel: notificationStatus.statusLabel,
                    state: notificationStatus.canRequestAuthorization ? .default : .warning
                )
            ],
            footer: "The Constitution is a local boundary, not a sync policy."
        )
    }

    func makeMemoryControls(snapshot: Snapshot) -> YouMemoryControlState {
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
        let memoryLensItems = makeMemoryLensItems(
            eventCount: eventCount,
            proofFeedbackCount: proofFeedbackCount,
            correctionCount: correctionCount,
            openCaptures: openCaptures
        )
        let runtimeInspectionItems = makeRuntimeInspectionItems(
            eventCount: eventCount,
            proofFeedbackCount: proofFeedbackCount,
            correctionCount: correctionCount,
            openCaptures: openCaptures
        )
        let localLearningControls = makeLocalLearningControls(
            eventCount: eventCount,
            proofFeedbackCount: proofFeedbackCount,
            correctionCount: correctionCount,
            openCaptures: openCaptures
        )
        return YouMemoryControlState(
            title: "What Ambitions Knows",
            subtitle: "Local memory areas Ambitions can use, what each one is for, and where you can correct it.",
            items: [
                SettingsItem(
                    id: "you-memory-ledger",
                    title: "Event Ledger",
                    subtitle: "Recent meaningful actions and changes can support explanations. Full raw history stays off this top-level surface.",
                    icon: "list.bullet.rectangle",
                    valueLabel: snapshot.eventLedger.isEmpty ? "No recent events" : "\(snapshot.eventLedger.count) recent"
                ),
                SettingsItem(
                    id: "you-memory-evidence",
                    title: "Proof and feedback",
                    subtitle: "Progress evidence and feedback help Ambitions avoid relying only on intention.",
                    icon: "checkmark.seal",
                    valueLabel: "\(snapshot.evidence.count + snapshot.feedback.count) local"
                ),
                SettingsItem(
                    id: "you-memory-corrections",
                    title: "Corrections and teaching",
                    subtitle: "User-confirmed corrections can adjust future explanations where existing teaching signals support it.",
                    icon: "slider.horizontal.3",
                    valueLabel: correctionStatus
                ),
                SettingsItem(
                    id: "you-memory-captures",
                    title: "Open captures",
                    subtitle: "Unarchived captures remain visible to the local planning loop until routed or archived.",
                    icon: "tray.full",
                    valueLabel: "\(snapshot.captures.filter { $0.status != .archived }.count) open"
                ),
                SettingsItem(
                    id: "you-memory-forget",
                    title: "Forget or clear memory",
                    subtitle: "Destructive memory deletion is not exposed here because safe review, confirmation, and undo coverage are not complete.",
                    icon: "trash.slash",
                    valueLabel: "Unavailable"
                ),
                SettingsItem(
                    id: "you-memory-rejected",
                    title: "Rejected memory",
                    subtitle: "Rejected learning stays reviewable and source-tied here; durable rejection rules wait for receipt-backed correction and delete coverage.",
                    icon: "xmark.seal",
                    valueLabel: "Review first"
                )
            ],
            consent: YouPersonalizationConsentState(
                title: "Personalization consent",
                summary: "Ambitions can use current local memory to explain and suggest, but stronger memory changes stay reviewable.",
                sourceLabel: "Based on local records",
                sensitiveMemoryLabel: "Sensitive memory requires approval",
                hiddenMemoryLabel: "No hidden memory creation",
                controlLabel: "You are in control"
            ),
            privateModeControls: [
                YouPrivateModeControl(
                    id: "private-mode-compact-detail",
                    title: "Compact private detail",
                    summary: "Proof, feedback, and narrative memory stay summarized before any detailed review.",
                    statusLabel: "Summaries first",
                    privacyLabel: "Detail hidden",
                    controlLabel: "Open owning surface",
                    state: .success
                ),
                YouPrivateModeControl(
                    id: "private-mode-external-surfaces",
                    title: "External surfaces",
                    summary: "Widgets, Live Activities, Shortcuts, and Share Extension must use privacy snapshots or fallback routes.",
                    statusLabel: "Protected",
                    privacyLabel: "Snapshot-safe",
                    controlLabel: "No raw memory",
                    state: .warning
                ),
                YouPrivateModeControl(
                    id: "private-mode-sensitive-memory",
                    title: "Sensitive memory",
                    summary: "Sensitive categories are not inferred here and require explicit approval before stronger use.",
                    statusLabel: "Approval required",
                    privacyLabel: "No sensitive inference",
                    controlLabel: "Review first",
                    state: .warning
                ),
                YouPrivateModeControl(
                    id: "private-mode-destructive-controls",
                    title: "Destructive controls",
                    summary: "Forget, delete, and broad pause remain blocked until confirmation, receipt, and undo coverage are proven.",
                    statusLabel: "Future-owned",
                    privacyLabel: "No silent deletion",
                    controlLabel: "Blocked safely",
                    state: .warning
                )
            ],
            groups: [
                YouMemoryGroup(
                    id: "memory-group-current",
                    title: "Current local memory",
                    subtitle: "Used only from local Ambitions records available in this runtime.",
                    footer: "Current does not mean permanent. It means the source is active in the local app right now.",
                    items: [
                        YouMemoryItem(
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
                        YouMemoryItem(
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
                            accessibilityValue: "\(proofFeedbackCount == 0 ? YouMemoryFreshness.mayNeedReview.label : YouMemoryFreshness.current.label). Detail hidden in compact views.",
                            accessibilityHint: "Shows what proof and feedback memory is used for and where it can be corrected."
                        ),
                        YouMemoryItem(
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
                YouMemoryGroup(
                    id: "memory-group-corrections",
                    title: "Corrections and review signals",
                    subtitle: "User-corrected context is kept explicit and source-tied.",
                    footer: "No sensitive identity categories are inferred here. Correction signals stay bounded to the artifacts that created them.",
                    items: [
                        YouMemoryItem(
                            id: "memory-item-corrections",
                            title: "Corrections and teaching",
                            detail: correctionCount == 0 ? "No active teaching signals are saved yet." : "\(correctionCount) local teaching signals can influence future explanation language.",
                            sourceLabel: "Manual corrections",
                            freshness: correctionCount == 0 ? .basedOnOlderContext : .current,
                            usedFor: "Used for Why Changed, lighter-version preferences, and future recommendations that cite local evidence.",
                            privacyLabel: "Correctable",
                            actions: [
                                memoryAction(id: "correct-teaching", title: "Correct", statusLabel: correctionCount == 0 ? "Available when present" : "Available", detail: "Corrections stay tied to existing teaching and explanation paths.", state: correctionCount == 0 ? .default : .success),
                                memoryAction(id: "reject-teaching", title: "Reject reuse", statusLabel: "Review first", detail: "Rejected correction memory is treated as a review need until receipt-backed rejection and delete coverage are proven.", state: .warning),
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
            memoryLensItems: memoryLensItems,
            runtimeInspectionItems: runtimeInspectionItems,
            localLearningControls: localLearningControls,
            recoverySummary: hasRecentMemory ? "Memory can be reviewed and corrected from the owning surfaces. Broad delete, forget, and pause controls remain confirmation-gated or future-owned." : "There is little local memory yet. Ambitions should say when a recommendation is evidence-light instead of pretending it knows more.",
            footer: "What Ambitions Knows is local, inspectable, and correctable through existing safe seams. Narrative memory only appears from explicit local evidence, receipts, corrections, reviews, or confirmations; broad forgetting, deletion, and export remain confirmation-gated, export-bounded, and durable rejected-memory rules remain manual/future until the safe boundary can prove the result."
        )
    }

    func makeLifeContextState(snapshot: Snapshot) -> YouLifeContextState {
        let bundle = latestLifeContextBundle(from: snapshot.lifeContextBundles)
        let projection = bundle?.projection(asOf: .now)
        let basePath = "You > What Ambitions Knows > Life Context"
        let summaryItems = makeLifeContextSummaryItems(bundle: bundle, projection: projection)
        let sections = makeLifeContextSections(bundle: bundle, projection: projection, basePath: basePath)

        return YouLifeContextState(
            title: "Life Context",
            subtitle: "Help Ambitions plan from your real life.",
            intro: "Age, schedule, travel, access, history, and constraints help Ambitions make plans that actually fit.",
            summaryItems: summaryItems,
            sections: sections,
            footer: "Catch Me Up stays under What Ambitions Knows, stays local-first, and keeps edit, pause, delete, review, and confirm paths visible where facts are shown."
        )
    }

    func latestLifeContextBundle(from bundles: [LifeContextBundle]) -> LifeContextBundle? {
        bundles.sorted {
            if $0.updatedAt != $1.updatedAt {
                return $0.updatedAt > $1.updatedAt
            }
            return $0.id > $1.id
        }.first
    }

    func makeLifeContextSummaryItems(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?
    ) -> [SettingsItem] {
        let ageValue: String
        if let ageYears = projection?.ageYears ?? bundle?.profile.exactAgeYears {
            ageValue = "\(ageYears)"
        } else if let birthdate = bundle?.profile.birthdate {
            ageValue = birthdate
        } else {
            ageValue = "Not captured"
        }

        let locationValue = bundle.map { profileLocationSummary(for: $0.profile) } ?? "Not captured"
        let scheduleValue = bundle?.profile.scheduleAnchors.isEmpty == false ? "\(bundle?.profile.scheduleAnchors.count ?? 0) anchors" : "Not captured"
        let opportunityCount = bundle?.opportunityContexts.count ?? 0
        let pathwayCount = projection?.eligibilityModel.count ?? bundle?.eligibilityPathways.count ?? 0
        let historyCount = projection?.historySummary.count ?? bundle?.historicalFacts.filter { $0.isDeletedOrPaused == false }.count ?? 0
        let constraintCount = (projection?.hardConstraints.count ?? 0) + (projection?.softConstraints.count ?? 0)
        let sourceReviewCount = projection?.sourceFreshnessSummary.filter { $0.freshness != .current }.count ?? 0
        let excludedReviewCount = projection?.excludedHistorySummary.count ?? 0
        let sensitiveReviewCount = projection?.sensitiveUseWarnings.count ?? 0
        let questionReviewCount = projection?.missingContextQuestions.count ?? 0
        let reviewCount = sourceReviewCount + excludedReviewCount + sensitiveReviewCount + questionReviewCount

        return [
            SettingsItem(
                id: "life-context-basics",
                title: "Basics",
                subtitle: "Age, stage, timezone, location, and school/work context.",
                icon: "calendar",
                valueLabel: ageValue
            ),
            SettingsItem(
                id: "life-context-schedule-availability",
                title: "Schedule & Availability",
                subtitle: "Anchors, protected time, and recovery defaults.",
                icon: "calendar.badge.clock",
                valueLabel: scheduleValue
            ),
            SettingsItem(
                id: "life-context-travel-access",
                title: "Travel & Access",
                subtitle: "Radius, transport, and access assumptions.",
                icon: "car",
                valueLabel: locationValue
            ),
            SettingsItem(
                id: "life-context-facilities-equipment",
                title: "Facilities & Equipment",
                subtitle: "Places, gear, and access limits.",
                icon: "building.2",
                valueLabel: "\(opportunityCount)"
            ),
            SettingsItem(
                id: "life-context-eligibility-pathways",
                title: "Eligibility & Pathways",
                subtitle: "Sport, school, career, and creative rules.",
                icon: "checkmark.seal",
                valueLabel: "\(pathwayCount)"
            ),
            SettingsItem(
                id: "life-context-history",
                title: "History",
                subtitle: "Prior attempts, past achievements, and old progress.",
                icon: "clock.arrow.circlepath",
                valueLabel: "\(historyCount)"
            ),
            SettingsItem(
                id: "life-context-constraints",
                title: "Constraints",
                subtitle: "Budget, energy, care, accessibility, and recovery.",
                icon: "slider.horizontal.3",
                valueLabel: "\(constraintCount)"
            ),
            SettingsItem(
                id: "life-context-review-needed",
                title: "Review Needed",
                subtitle: "Stale, imported, inferred, and sensitive context.",
                icon: "exclamationmark.triangle",
                valueLabel: reviewCount == 0 ? "Clear" : "\(reviewCount)"
            )
        ]
    }

    func makeLifeContextSections(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextSection] {
        return [
            YouLifeContextSection(
                id: "life-context-basics",
                title: "Basics",
                subtitle: "Start with the stable facts that give Ambitions a safe default.",
                factRows: makeBasicsRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-schedule-availability",
                title: "Schedule & Availability",
                subtitle: "Keep protected time and cadence visible before any suggestion.",
                factRows: makeScheduleAvailabilityRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-travel-access",
                title: "Travel & Access",
                subtitle: "Travel radius and access shape what is realistic.",
                factRows: makeTravelAccessRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-facilities-equipment",
                title: "Facilities & Equipment",
                subtitle: "Place and equipment should match the actual opportunity.",
                factRows: makeFacilitiesEquipmentRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-eligibility-pathways",
                title: "Eligibility & Pathways",
                subtitle: "Each pathway stays tied to the reason it exists.",
                factRows: makeEligibilityPathwayRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-history",
                title: "History",
                subtitle: "Past context stays visible so Ambitions can ask before it assumes too much.",
                factRows: makeHistoryRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-constraints",
                title: "Constraints",
                subtitle: "Keep budget, energy, care, accessibility, and recovery visible.",
                factRows: makeConstraintsRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-review-needed",
                title: "Review Needed",
                subtitle: "These rows need a fresh check before runtime use.",
                factRows: makeReviewNeededRows(bundle: bundle, projection: projection, basePath: basePath)
            )
        ]
    }

    func makeBasicsRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-age",
                title: "Birthday or exact age",
                detail: ageAnswer(bundle: bundle, projection: projection),
                sourceLabel: ageSourceLabel(bundle: bundle),
                freshness: ageFreshness(bundle: bundle, projection: projection),
                runtimeUseState: ageRuntimeUseState(bundle: bundle, projection: projection),
                whereUsed: "Eligibility, fit, and pacing",
                updateTargets: [.profile, .historicalFact, .eligibilityPathway],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-stage",
                title: "Life stage",
                detail: bundle.map { displayLabel(for: $0.profile.lifeStage) } ?? "Not captured",
                sourceLabel: "Profile",
                freshness: bundle == nil || bundle?.profile.lifeStage == .unknown ? .basedOnOlderContext : .current,
                runtimeUseState: bundle == nil || bundle?.profile.lifeStage == .unknown ? .needsReview : .used,
                whereUsed: "Safer defaults and pace",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-timezone",
                title: "Timezone",
                detail: bundle?.profile.timezone ?? "Not captured",
                sourceLabel: "Profile",
                freshness: bundle?.profile.timezone == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.timezone == nil ? .needsReview : .used,
                whereUsed: "Time, scheduling, and travel grounding",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-location",
                title: "General location",
                detail: bundle?.profile.generalLocationLabel ?? "Not captured",
                sourceLabel: "Profile",
                freshness: bundle?.profile.generalLocationLabel == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.generalLocationLabel == nil ? .needsReview : .used,
                whereUsed: "Time, travel, and opportunity paths",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-school-work",
                title: "School / work context",
                detail: bundle?.profile.schoolOrWorkContext ?? "Not captured",
                sourceLabel: "Profile",
                freshness: bundle?.profile.schoolOrWorkContext == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.schoolOrWorkContext == nil ? .needsReview : .used,
                whereUsed: "Avoid impossible steps",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeScheduleAvailabilityRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-work-school-anchors",
                title: "Work / school anchors",
                detail: bundle?.profile.schoolOrWorkContext ?? "Not captured",
                sourceLabel: "Profile",
                freshness: bundle?.profile.schoolOrWorkContext == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.schoolOrWorkContext == nil ? .needsReview : .used,
                whereUsed: "Protect the day shape before suggestions shift it",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-recurring-commitments",
                title: "Recurring commitments",
                detail: bundle?.profile.scheduleAnchors.isEmpty == false ? bundle!.profile.scheduleAnchors.joined(separator: ", ") : "Not captured",
                sourceLabel: "Profile",
                freshness: bundle == nil || bundle?.profile.scheduleAnchors.isEmpty == true ? .basedOnOlderContext : .current,
                runtimeUseState: bundle == nil || bundle?.profile.scheduleAnchors.isEmpty == true ? .needsReview : .used,
                whereUsed: "Avoid impossible scheduling",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-protected-time",
                title: "Protected time",
                detail: constraintDetail(
                    from: projection?.hardConstraints ?? [],
                    matching: ["Dependency constraint"],
                    fallback: bundle?.profile.dependencyConstraints.joined(separator: ", ") ?? "Not captured"
                ),
                sourceLabel: "Profile",
                freshness: (projection?.hardConstraints.contains(where: { $0.title == "Dependency constraint" }) ?? false) ? .current : .basedOnOlderContext,
                runtimeUseState: (projection?.hardConstraints.contains(where: { $0.title == "Dependency constraint" }) ?? false) ? .used : .needsReview,
                whereUsed: "Keep recovery-aware pacing visible",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-flexible-windows",
                title: "Flexible windows",
                detail: constraintDetail(
                    from: projection?.softConstraints ?? [],
                    matching: ["Energy pattern", "Budget"],
                    fallback: bundle.map { displayLabel(for: $0.profile.energyPattern) } ?? "Not captured"
                ),
                sourceLabel: "Profile",
                freshness: bundle == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle == nil ? .needsReview : .used,
                whereUsed: "Keep capacity honest",
                updateTargets: [.profile],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-recovery-defaults",
                title: "Recovery defaults",
                detail: bundle?.profile.recoveryConstraints.isEmpty == false ? bundle!.profile.recoveryConstraints.joined(separator: ", ") : "Not captured",
                sourceLabel: "Profile",
                freshness: bundle?.profile.recoveryConstraints.isEmpty == true ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.recoveryConstraints.isEmpty == true ? .needsReview : .used,
                whereUsed: "Keep recovery-aware pacing visible",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeTravelAccessRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-transport",
                title: "Transportation access",
                detail: bundle.map { displayLabel(for: $0.profile.transportationAccess) } ?? "Not captured",
                sourceLabel: "Profile",
                freshness: (bundle?.profile.transportationAccess ?? .unknown) == .unknown ? .basedOnOlderContext : .current,
                runtimeUseState: (bundle?.profile.transportationAccess ?? .unknown) == .unknown ? .needsReview : .used,
                whereUsed: "Fit travel and access assumptions",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-travel-radius",
                title: "Travel radius",
                detail: travelRadiusSummary(for: bundle?.profile),
                sourceLabel: "Profile",
                freshness: bundle?.profile.travelRadiusMinutes == nil && bundle?.profile.travelRadiusMiles == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.travelRadiusMinutes == nil && bundle?.profile.travelRadiusMiles == nil ? .needsReview : .used,
                whereUsed: "Route fit and nearby opportunity paths",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-location-precision",
                title: "Location precision",
                detail: bundle.map { displayLabel(for: $0.profile.locationPrecision) } ?? "Not captured",
                sourceLabel: "Profile",
                freshness: ((bundle?.profile.locationPrecision).map { $0 != LifeContextLocationPrecision.none } ?? false) ? .current : .basedOnOlderContext,
                runtimeUseState: ((bundle?.profile.locationPrecision).map { $0 != LifeContextLocationPrecision.none } ?? false) ? .used : .needsReview,
                whereUsed: "Keep location assumptions narrow",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-commute-tolerance",
                title: "Commute tolerance",
                detail: bundle?.profile.travelRadiusMinutes.map { "\($0) minutes" } ?? "Not captured",
                sourceLabel: "Profile",
                freshness: bundle?.profile.travelRadiusMinutes == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.travelRadiusMinutes == nil ? .needsReview : .used,
                whereUsed: "Keep route suggestions within comfort",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-parent-guardian",
                title: "Parent / guardian dependency",
                detail: bundle?.profile.transportationAccess == .parentGuardian ? "Parent or guardian transport is part of the plan." : "Not captured",
                sourceLabel: "Profile",
                freshness: bundle?.profile.transportationAccess == .parentGuardian ? .current : .basedOnOlderContext,
                runtimeUseState: bundle?.profile.transportationAccess == .parentGuardian ? .used : .needsReview,
                whereUsed: "Respect dependency-driven access",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-mobility-constraints",
                title: "Mobility constraints",
                detail: bundle?.profile.accessibilityNeeds.isEmpty == false ? bundle!.profile.accessibilityNeeds.joined(separator: ", ") : "Not captured",
                sourceLabel: "Profile",
                freshness: bundle?.profile.accessibilityNeeds.isEmpty == true ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.accessibilityNeeds.isEmpty == true ? .needsReview : .used,
                whereUsed: "Keep mobility assumptions honest",
                updateTargets: [.profile, .opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            )
        ]
    }

    func makeFacilitiesEquipmentRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let hasOpportunityContexts = bundle?.opportunityContexts.isEmpty == false

        return [
            makeLifeContextFactRow(
                id: "life-context-facilities",
                title: "Facilities access",
                detail: facilitiesSummary(for: bundle),
                sourceLabel: "Opportunity context",
                freshness: hasOpportunityContexts ? .current : .basedOnOlderContext,
                runtimeUseState: hasOpportunityContexts ? .used : .needsReview,
                whereUsed: "Avoid suggesting unavailable places",
                updateTargets: [.opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-equipment",
                title: "Equipment owned",
                detail: equipmentSummary(for: bundle),
                sourceLabel: "Opportunity context",
                freshness: hasOpportunityContexts ? .current : .basedOnOlderContext,
                runtimeUseState: hasOpportunityContexts ? .used : .needsReview,
                whereUsed: "Fit steps to real access",
                updateTargets: [.opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-equipment-needed",
                title: "Equipment needed",
                detail: equipmentNeedSummary(for: bundle),
                sourceLabel: "Opportunity context",
                freshness: hasOpportunityContexts ? .current : .basedOnOlderContext,
                runtimeUseState: hasOpportunityContexts ? .needsReview : .needsReview,
                whereUsed: "Fit steps to real access",
                updateTargets: [.opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-organizations",
                title: "Local organizations",
                detail: localOrganizationsSummary(for: bundle),
                sourceLabel: "Opportunity context",
                freshness: hasOpportunityContexts ? .current : .basedOnOlderContext,
                runtimeUseState: hasOpportunityContexts ? .used : .needsReview,
                whereUsed: "Point toward realistic access",
                updateTargets: [.opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-seasonal-limits",
                title: "Seasonal / access limits",
                detail: seasonalAccessSummary(for: bundle),
                sourceLabel: "Opportunity context",
                freshness: hasOpportunityContexts ? .current : .basedOnOlderContext,
                runtimeUseState: hasOpportunityContexts ? .needsReview : .needsReview,
                whereUsed: "Keep seasonal and access constraints visible",
                updateTargets: [.opportunityContext],
                captureRouteContext: .needsPlace,
                basePath: basePath
            )
        ]
    }

    func makeEligibilityPathwayRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let pathways = bundle?.eligibilityPathways ?? []
        var rows: [YouLifeContextFactRow] = []

        if let sexContext = bundle?.profile.sexOrEligibilityContext, sexContext.isEmpty == false {
            rows.append(
                makeLifeContextFactRow(
                    id: "life-context-eligibility-sex-context",
                    title: "Sex / eligibility context",
                    detail: sexContext,
                    sourceLabel: "Profile",
                    freshness: .current,
                    runtimeUseState: .needsReview,
                    whereUsed: "Only used where a pathway materially needs it",
                    updateTargets: [.profile, .eligibilityPathway],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            )
        }

        if pathways.isEmpty {
            rows.append(
                makeLifeContextFactRow(
                    id: "life-context-eligibility-placeholder",
                    title: "Sport / school / career / creative pathways",
                    detail: "Not captured",
                    sourceLabel: "Eligibility pathway",
                    freshness: .basedOnOlderContext,
                    runtimeUseState: .needsReview,
                    whereUsed: "Add a pathway when a rule materially matters",
                    updateTargets: [.eligibilityPathway],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            )
        } else {
            let grouped = Dictionary(grouping: pathways, by: { $0.pathwayType })
            let orderedTypes: [LifeContextEligibilityPathwayType] = [.sport, .academic, .career, .creative]

            for type in orderedTypes {
                if let pathway = grouped[type]?.first {
                    rows.append(
                        makeLifeContextFactRow(
                            id: "life-context-eligibility-\(type.rawValue)",
                            title: "\(displayLabel(for: type)) pathway",
                            detail: pathway.eligibilityRulesSummary,
                            sourceLabel: pathway.source.label,
                            freshness: memoryFreshness(for: pathway.freshness),
                            runtimeUseState: pathway.userConfirmed ? .used : .needsReview,
                            whereUsed: pathway.locationDependent ? "Used for route-aware eligibility" : "Used for eligibility checks",
                            updateTargets: [.eligibilityPathway],
                            captureRouteContext: .needsReview,
                            basePath: basePath
                        )
                    )
                } else {
                    rows.append(
                        makeLifeContextFactRow(
                            id: "life-context-eligibility-\(type.rawValue)-missing",
                            title: "\(displayLabel(for: type)) pathway",
                            detail: "Not captured",
                            sourceLabel: "Eligibility pathway",
                            freshness: .basedOnOlderContext,
                            runtimeUseState: .needsReview,
                            whereUsed: "Add when materially relevant",
                            updateTargets: [.eligibilityPathway],
                            captureRouteContext: .needsReview,
                            basePath: basePath
                        )
                    )
                }
            }
        }

        rows.append(
            makeLifeContextFactRow(
                id: "life-context-eligibility-constraints",
                title: "Age / grade / league constraints",
                detail: eligibilityConstraintSummary(for: pathways),
                sourceLabel: "Eligibility pathway",
                freshness: pathways.contains(where: { $0.freshness != .current }) ? .mayNeedReview : (pathways.isEmpty ? .basedOnOlderContext : .current),
                runtimeUseState: pathways.isEmpty ? .needsReview : (pathways.contains(where: { $0.userConfirmed == false }) ? .needsReview : .used),
                whereUsed: "Used before Ambitions assumes a pathway fits",
                updateTargets: [.eligibilityPathway],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        )

        return rows
    }

    func makeHistoryRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-history-experience",
                title: "Prior experience",
                detail: factSummary(for: bundle, matching: [.priorExperience, .trainingHistory, .workHistory, .creativeCatalog]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.priorExperience, .trainingHistory, .workHistory, .creativeCatalog]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.priorExperience, .trainingHistory, .workHistory, .creativeCatalog]),
                whereUsed: "Use only when the facts still feel current",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-history-attempts",
                title: "Prior attempts",
                detail: factSummary(for: bundle, matching: [.priorAttempt]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.priorAttempt]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.priorAttempt]),
                whereUsed: "Avoid repeating dead ends",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-history-achievements",
                title: "Past achievements",
                detail: factSummary(for: bundle, matching: [.pastAchievement]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.pastAchievement]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.pastAchievement]),
                whereUsed: "Keep proven signals visible",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-history-progress",
                title: "Old progress",
                detail: factSummary(for: bundle, matching: [.trainingHistory, .educationHistory, .workHistory]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.trainingHistory, .educationHistory, .workHistory]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.trainingHistory, .educationHistory, .workHistory]),
                whereUsed: "Keep older progress visible before Ambitions reuses it",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-history-injuries",
                title: "Injuries / limitations",
                detail: factSummary(for: bundle, matching: [.injuryLimitation, .healthBaseline, .relationshipDependency]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.injuryLimitation, .healthBaseline, .relationshipDependency]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.injuryLimitation, .healthBaseline, .relationshipDependency]),
                whereUsed: "Protect recovery and safety",
                updateTargets: [.historicalFact, .profile],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-history-tried",
                title: "Already-tried approaches",
                detail: factSummary(for: bundle, matching: [.priorAttempt, .trainingHistory, .workHistory, .creativeCatalog]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.priorAttempt, .trainingHistory, .workHistory, .creativeCatalog]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.priorAttempt, .trainingHistory, .workHistory, .creativeCatalog]),
                whereUsed: "Avoid repeating dead ends",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeConstraintsRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let hardConstraints = projection?.hardConstraints ?? []
        let softConstraints = projection?.softConstraints ?? []

        let budgetDetail = softConstraints.first(where: { $0.title == "Budget" })?.detail
            ?? (bundle.flatMap { displayLabel(for: $0.profile.budgetConstraintBand) } ?? "Not captured")

        let energyDetail = softConstraints.first(where: { $0.title == "Energy pattern" })?.detail
            ?? (bundle.flatMap { displayLabel(for: $0.profile.energyPattern) } ?? "Not captured")

        let familyDetail = constraintDetail(
            from: hardConstraints,
            matching: ["Dependency constraint", "School or work context"],
            fallback: bundle?.profile.dependencyConstraints.joined(separator: ", ") ?? "Not captured"
        )

        let accessibilityDetail = constraintDetail(
            from: hardConstraints,
            matching: ["Accessibility need"],
            fallback: bundle?.profile.accessibilityNeeds.joined(separator: ", ") ?? "Not captured"
        )

        let recoveryDetail = constraintDetail(
            from: hardConstraints,
            matching: ["Recovery constraint"],
            fallback: bundle?.profile.recoveryConstraints.joined(separator: ", ") ?? "Not captured"
        )

        return [
            makeLifeContextFactRow(
                id: "life-context-constraint-budget",
                title: "Budget",
                detail: budgetDetail,
                sourceLabel: "Profile",
                freshness: bundle?.profile.budgetConstraintBand == .unknown ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.budgetConstraintBand == .unknown ? .needsReview : .used,
                whereUsed: "Keep recommendations within real spending limits",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-constraint-energy",
                title: "Energy",
                detail: energyDetail,
                sourceLabel: "Profile",
                freshness: bundle?.profile.energyPattern == .unknown ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.energyPattern == .unknown ? .needsReview : .used,
                whereUsed: "Keep the day honest about capacity",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-constraint-family",
                title: "Family / caregiver dependencies",
                detail: familyDetail,
                sourceLabel: "Profile",
                freshness: familyDetail == "Not captured" ? .basedOnOlderContext : .current,
                runtimeUseState: familyDetail == "Not captured" ? .needsReview : .used,
                whereUsed: "Avoid impossible timing or access assumptions",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-constraint-accessibility",
                title: "Accessibility needs",
                detail: accessibilityDetail,
                sourceLabel: "Profile",
                freshness: accessibilityDetail == "Not captured" ? .basedOnOlderContext : .current,
                runtimeUseState: accessibilityDetail == "Not captured" ? .needsReview : .used,
                whereUsed: "Keep access and pace aligned with real needs",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-constraint-recovery",
                title: "Recovery needs",
                detail: recoveryDetail,
                sourceLabel: "Profile",
                freshness: recoveryDetail == "Not captured" ? .basedOnOlderContext : .current,
                runtimeUseState: recoveryDetail == "Not captured" ? .needsReview : .used,
                whereUsed: "Keep recovery-aware pacing visible",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-constraint-dont-assume",
                title: "Do not assume",
                detail: bundle?.profile.userNotes ?? "No assumptions logged yet.",
                sourceLabel: "Profile notes",
                freshness: bundle?.profile.userNotes == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.userNotes == nil ? .needsReview : .used,
                whereUsed: "Guardrail, not a default fact",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeReviewNeededRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        var rows: [YouLifeContextFactRow] = [
            makeLifeContextFactRow(
                id: "life-context-older-review",
                title: "Older context that may need review",
                detail: olderContextSummary(for: bundle, projection: projection),
                sourceLabel: "Freshness review",
                freshness: olderContextFreshness(for: bundle, projection: projection),
                runtimeUseState: olderContextRuntimeUseState(for: bundle, projection: projection),
                whereUsed: "Review before runtime use",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]

        rows.append(contentsOf: (bundle?.sources ?? []).compactMap { source in
            let freshness = projection?.sourceFreshnessSummary.first(where: { $0.sourceID == source.id })?.freshness ?? .basedOnOlderContext
            guard source.kind != .userConfirmed || freshness != .current else {
                return nil
            }

            return makeLifeContextFactRow(
                id: "life-context-source-\(source.id)",
                title: "\(displayLabel(for: source.kind)) fact",
                detail: source.visibleExplanation,
                sourceLabel: source.label,
                freshness: memoryFreshness(for: freshness),
                runtimeUseState: .needsReview,
                whereUsed: source.kind == .imported ? "Imported context needs review before runtime use" : "Review before runtime use",
                updateTargets: [.historicalFact, .profile],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        })

        rows.append(contentsOf: (projection?.excludedHistorySummary ?? []).map { exclusion in
            let title = bundle?.historicalFacts.first(where: { $0.id == exclusion.factID })?.title ?? exclusion.reason.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
            return makeLifeContextFactRow(
                id: "life-context-excluded-\(exclusion.factID)",
                title: title,
                detail: exclusion.reason == .deleted ? "Deleted from runtime use." : "Paused from runtime use.",
                sourceLabel: exclusion.reason == .deleted ? "Deleted history" : "Paused history",
                freshness: .basedOnOlderContext,
                runtimeUseState: .notUsed,
                whereUsed: "History only; not runtime input",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        })

        rows.append(contentsOf: (projection?.sensitiveUseWarnings ?? []).map { warning in
            makeLifeContextFactRow(
                id: "life-context-sensitive-\(warning.factID)",
                title: warning.title,
                detail: warning.detail,
                sourceLabel: "Sensitive context",
                freshness: .mayNeedReview,
                runtimeUseState: .needsReview,
                whereUsed: "Blocked until you allow runtime use",
                updateTargets: [.historicalFact, .profile],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        })

        rows.append(contentsOf: (projection?.missingContextQuestions ?? []).map { question in
            makeLifeContextFactRow(
                id: "life-context-question-\(question.id)",
                title: question.prompt,
                detail: question.reason,
                sourceLabel: "Open question",
                freshness: .basedOnOlderContext,
                runtimeUseState: .needsReview,
                whereUsed: "Needs an answer before Ambitions assumes more",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        })

        return rows
    }

    func makeHistoricalContextRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-experience",
                title: "Prior experience",
                detail: factSummary(for: bundle, matching: [.priorExperience, .trainingHistory, .workHistory, .creativeCatalog, .pastAchievement]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.priorExperience, .trainingHistory, .workHistory, .creativeCatalog, .pastAchievement]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.priorExperience, .trainingHistory, .workHistory, .creativeCatalog, .pastAchievement]),
                whereUsed: "Use only when the facts still feel current",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-attempts",
                title: "Prior attempts",
                detail: factSummary(for: bundle, matching: [.priorAttempt]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.priorAttempt]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.priorAttempt]),
                whereUsed: "Avoid repeating dead ends",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-blockers",
                title: "Blockers, injuries, and limitations",
                detail: factSummary(for: bundle, matching: [.injuryLimitation, .healthBaseline, .relationshipDependency]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.injuryLimitation, .healthBaseline, .relationshipDependency]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.injuryLimitation, .healthBaseline, .relationshipDependency]),
                whereUsed: "Protect recovery and safety",
                updateTargets: [.historicalFact, .profile],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-deadlines",
                title: "Important deadlines and windows",
                detail: deadlineSummary(for: bundle, projection: projection),
                sourceLabel: "Profile and historical facts",
                freshness: deadlineFreshness(for: bundle, projection: projection),
                runtimeUseState: deadlineRuntimeUseState(for: bundle, projection: projection),
                whereUsed: "Keep timing honest",
                updateTargets: [.profile, .historicalFact, .opportunityContext],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-dont-assume",
                title: "Things Ambitions should not assume",
                detail: bundle?.profile.userNotes ?? "No assumptions logged yet.",
                sourceLabel: "Profile notes",
                freshness: bundle?.profile.userNotes == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.userNotes == nil ? .needsReview : .used,
                whereUsed: "Guardrail, not a default fact",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeNeedsReviewRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        var rows: [YouLifeContextFactRow] = [
            makeLifeContextFactRow(
                id: "life-context-older-review",
                title: "Older context that may need review",
                detail: olderContextSummary(for: bundle, projection: projection),
                sourceLabel: "Freshness review",
                freshness: olderContextFreshness(for: bundle, projection: projection),
                runtimeUseState: olderContextRuntimeUseState(for: bundle, projection: projection),
                whereUsed: "Review before runtime use",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]

        rows.append(contentsOf: (projection?.sensitiveUseWarnings ?? []).map { warning in
            makeLifeContextFactRow(
                id: "life-context-sensitive-\(warning.factID)",
                title: warning.title,
                detail: warning.detail,
                sourceLabel: "Sensitive context",
                freshness: .mayNeedReview,
                runtimeUseState: .needsReview,
                whereUsed: "Blocked until you allow runtime use",
                updateTargets: [.historicalFact, .profile],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        })

        rows.append(contentsOf: (projection?.missingContextQuestions ?? []).map { question in
            makeLifeContextFactRow(
                id: "life-context-question-\(question.id)",
                title: question.prompt,
                detail: question.reason,
                sourceLabel: "Open question",
                freshness: .basedOnOlderContext,
                runtimeUseState: .needsReview,
                whereUsed: "Needs an answer before Ambitions assumes more",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        })

        return rows
    }

    func makePausedOrNotUsedRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let rows = (projection?.excludedHistorySummary ?? []).map { exclusion in
            let title = bundle?.historicalFacts.first(where: { $0.id == exclusion.factID })?.title ?? exclusion.reason.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
            return makeLifeContextFactRow(
                id: "life-context-excluded-\(exclusion.factID)",
                title: title,
                detail: exclusion.reason == .deleted ? "Deleted from runtime use." : "Paused from runtime use.",
                sourceLabel: exclusion.reason == .deleted ? "Deleted history" : "Paused history",
                freshness: .basedOnOlderContext,
                runtimeUseState: .notUsed,
                whereUsed: "History only; not runtime input",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }

        if rows.isEmpty {
            return [
                makeLifeContextFactRow(
                    id: "life-context-excluded-empty",
                    title: "Paused / not used",
                    detail: "No paused or deleted facts yet.",
                    sourceLabel: "History",
                    freshness: .basedOnOlderContext,
                    runtimeUseState: .notUsed,
                    whereUsed: "Nothing is currently excluded",
                    updateTargets: [.historicalFact],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            ]
        }

        return rows
    }

    func makeReceiptRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let sourceRows = (projection?.sourceFreshnessSummary ?? []).map { source in
            makeLifeContextFactRow(
                id: "life-context-receipt-source-\(source.sourceID)",
                title: source.label,
                detail: source.detail,
                sourceLabel: "Source receipt",
                freshness: memoryFreshness(for: source.freshness),
                runtimeUseState: receiptRuntimeUseState(for: source.freshness),
                whereUsed: "Explains whether this source can currently guide recommendations",
                updateTargets: [.historicalFact, .profile],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }

        let confirmationRows = (bundle?.eligibilityPathways ?? []).map { pathway in
            makeLifeContextFactRow(
                id: "life-context-receipt-pathway-\(pathway.id)",
                title: pathway.pathwayType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                detail: pathway.userConfirmed ? "Confirmed by the user." : "Needs confirmation.",
                sourceLabel: "Confirmation receipt",
                freshness: pathway.userConfirmed ? .current : .mayNeedReview,
                runtimeUseState: pathway.userConfirmed ? .used : .needsReview,
                whereUsed: "Shows the pathway was explicitly confirmed",
                updateTargets: [.eligibilityPathway],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }

        if sourceRows.isEmpty && confirmationRows.isEmpty {
            return [
                makeLifeContextFactRow(
                    id: "life-context-receipts-empty",
                    title: "Receipts",
                    detail: "No source or confirmation receipts yet.",
                    sourceLabel: "Receipt layer",
                    freshness: .basedOnOlderContext,
                    runtimeUseState: .needsReview,
                    whereUsed: "Receipts will appear when context is captured",
                    updateTargets: [.historicalFact, .eligibilityPathway],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            ]
        }

        return sourceRows + confirmationRows
    }

    func makeLifeContextFactRow(
        id: String,
        title: String,
        detail: String,
        sourceLabel: String,
        freshness: YouMemoryFreshness,
        runtimeUseState: YouLifeContextRuntimeUseState,
        whereUsed: String,
        updateTargets: [YouLifeContextUpdateTarget],
        captureRouteContext: CaptureBackgroundFactRoute,
        basePath: String
    ) -> YouLifeContextFactRow {
        let editPath = "\(basePath) > Edit"
        let pausePath = "\(basePath) > Pause"
        let deletePath = "\(basePath) > Delete"
        let reviewPath = "\(basePath) > Review"
        let confirmPath = "\(basePath) > Confirm"
        let editLabel = "Edit"
        let pauseLabel = "Pause"
        let deleteLabel = "Delete"
        let reviewLabel = "Review"
        let confirmLabel = "Confirm"

        return YouLifeContextFactRow(
            id: id,
            title: title,
            detail: detail,
            sourceLabel: sourceLabel,
            freshness: freshness,
            runtimeUseState: runtimeUseState,
            whereUsed: whereUsed,
            editPath: editPath,
            pausePath: pausePath,
            deletePath: deletePath,
            reviewPath: reviewPath,
            confirmPath: confirmPath,
            editLabel: editLabel,
            pauseLabel: pauseLabel,
            deleteLabel: deleteLabel,
            reviewLabel: reviewLabel,
            confirmLabel: confirmLabel,
            updateTargets: updateTargets,
            captureRouteContext: captureRouteContext,
            accessibilityLabel: title,
            accessibilityValue: "\(detail). Source \(sourceLabel). Freshness \(freshness.label). Runtime use \(runtimeUseState.label). Used for \(whereUsed).",
            accessibilityHint: "Edit, pause, delete, review, and confirm paths stay visible from the owning Life Context surface."
        )
    }

    func ageAnswer(bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> String {
        if let age = projection?.ageYears ?? bundle?.profile.exactAgeYears {
            return "\(age) years old"
        }
        if let birthdate = bundle?.profile.birthdate {
            return birthdate
        }
        return "Not captured"
    }

    func ageSourceLabel(bundle: LifeContextBundle?) -> String {
        bundle?.profile.ageSource?.label ?? "Profile"
    }

    func ageFreshness(bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> YouMemoryFreshness {
        guard let bundle else {
            return .basedOnOlderContext
        }
        if bundle.profile.ageSource == nil {
            return .basedOnOlderContext
        }
        if let sourceFreshness = projection?.sourceFreshnessSummary.first(where: { $0.sourceID == bundle.profile.ageSource?.id })?.freshness {
            return memoryFreshness(for: sourceFreshness)
        }
        return .current
    }

    func ageRuntimeUseState(bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> YouLifeContextRuntimeUseState {
        switch ageFreshness(bundle: bundle, projection: projection) {
        case .current:
            return .used
        case .mayNeedReview:
            return .needsReview
        case .basedOnOlderContext:
            return .needsReview
        }
    }

    func factRuntimeUseState(
        for bundle: LifeContextBundle?,
        matching categories: [HistoricalContextFactCategory]
    ) -> YouLifeContextRuntimeUseState {
        let facts = bundle?.historicalFacts.filter { $0.isDeletedOrPaused == false && categories.contains($0.category) } ?? []
        if facts.isEmpty {
            return .needsReview
        }
        if facts.contains(where: { $0.freshness == .current && $0.runtimeUseAllowed }) {
            return .used
        }
        if facts.contains(where: { $0.runtimeUseAllowed == false }) {
            return .needsReview
        }
        return .needsReview
    }

    func deadlineRuntimeUseState(
        for bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?
    ) -> YouLifeContextRuntimeUseState {
        switch deadlineFreshness(for: bundle, projection: projection) {
        case .current:
            return .used
        case .mayNeedReview, .basedOnOlderContext:
            return .needsReview
        }
    }

    func olderContextRuntimeUseState(
        for bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?
    ) -> YouLifeContextRuntimeUseState {
        switch olderContextFreshness(for: bundle, projection: projection) {
        case .current:
            return .used
        case .mayNeedReview, .basedOnOlderContext:
            return .needsReview
        }
    }

    func receiptRuntimeUseState(for freshness: LifeContextFreshness) -> YouLifeContextRuntimeUseState {
        switch freshness {
        case .current:
            return .used
        case .mayNeedReview:
            return .needsReview
        case .basedOnOlderContext, .stale:
            return .notUsed
        }
    }

    func displayLabel(for budgetConstraintBand: LifeContextBudgetConstraintBand) -> String {
        switch budgetConstraintBand {
        case .tight:
            return "Tight"
        case .moderate:
            return "Moderate"
        case .flexible:
            return "Flexible"
        case .custom:
            return "Custom"
        case .unknown:
            return "Not captured"
        }
    }

    func displayLabel(for energyPattern: LifeContextEnergyPattern) -> String {
        switch energyPattern {
        case .morning:
            return "Morning"
        case .midday:
            return "Midday"
        case .evening:
            return "Evening"
        case .variable:
            return "Variable"
        case .unknown:
            return "Not captured"
        }
    }

    func displayLabel(for locationPrecision: LifeContextLocationPrecision) -> String {
        switch locationPrecision {
        case .none:
            return "Not captured"
        case .timezone:
            return "Timezone only"
        case .cityRegion:
            return "City or region"
        case .userEnteredPlace:
            return "User-entered place"
        case .precisePermissioned:
            return "Precise with permission"
        }
    }

    func displayLabel(for sourceKind: LifeContextSourceKind) -> String {
        switch sourceKind {
        case .userConfirmed:
            return "Confirmed"
        case .imported:
            return "Imported"
        case .inferred:
            return "Inferred"
        case .corrected:
            return "Corrected"
        }
    }

    func displayLabel(for pathwayType: LifeContextEligibilityPathwayType) -> String {
        switch pathwayType {
        case .sport:
            return "Sport"
        case .academic:
            return "School"
        case .career:
            return "Career"
        case .creative:
            return "Creative"
        case .health:
            return "Health"
        case .finance:
            return "Finance"
        case .custom:
            return "Custom"
        }
    }

    func constraintDetail(
        from constraints: [LifeContextConstraintSummary],
        matching titles: [String],
        fallback: String
    ) -> String {
        let matches = constraints.filter { titles.contains($0.title) }.map(\.detail)
        return matches.isEmpty ? fallback : Array(Set(matches)).sorted().joined(separator: ", ")
    }

    func equipmentNeedSummary(for bundle: LifeContextBundle?) -> String {
        guard let bundle else { return "Not captured" }
        let needs = bundle.opportunityContexts.flatMap { opportunity -> [String] in
            var items: [String] = []
            if let travelRequirement = opportunity.travelRequirement {
                items.append(travelRequirement)
            }
            if let costRequirement = opportunity.costRequirement {
                items.append(costRequirement)
            }
            return items
        }
        return needs.isEmpty ? "Not captured" : Array(Set(needs)).sorted().joined(separator: ", ")
    }

    func seasonalAccessSummary(for bundle: LifeContextBundle?) -> String {
        guard let bundle else { return "Not captured" }
        let access = bundle.opportunityContexts.flatMap { opportunity -> [String] in
            var items: [String] = []
            if let seasonalAvailability = opportunity.seasonalAvailability {
                items.append(seasonalAvailability)
            }
            if let travelRequirement = opportunity.travelRequirement {
                items.append(travelRequirement)
            }
            if let costRequirement = opportunity.costRequirement {
                items.append(costRequirement)
            }
            return items
        }
        return access.isEmpty ? "Not captured" : Array(Set(access)).sorted().joined(separator: ", ")
    }

    func eligibilityConstraintSummary(for pathways: [LifeContextEligibilityPathway]) -> String {
        guard pathways.isEmpty == false else { return "Not captured" }
        let pieces = pathways.flatMap { pathway -> [String] in
            var items: [String] = []
            if let ageWindow = pathway.ageWindow {
                switch (ageWindow.lowerBoundYears, ageWindow.upperBoundYears) {
                case let (lower?, upper?):
                    items.append("\(lower) to \(upper) years")
                case let (lower?, nil):
                    items.append("\(lower)+ years")
                case let (nil, upper?):
                    items.append("Up to \(upper) years")
                case (nil, nil):
                    break
                }
            }
            if let gradeWindow = pathway.gradeWindow {
                items.append(gradeWindow)
            }
            if let sexLeaguePathway = pathway.sexLeaguePathway {
                items.append(sexLeaguePathway)
            }
            return items
        }
        return pieces.isEmpty ? "Not captured" : Array(Set(pieces)).sorted().joined(separator: ", ")
    }

    func profileLocationSummary(for profile: LifeContextProfile?) -> String {
        guard let profile else { return "Not captured" }
        var parts: [String] = []
        if let timezone = profile.timezone {
            parts.append(timezone)
        }
        if let location = profile.generalLocationLabel {
            parts.append(location)
        }
        if parts.isEmpty {
            return "Not captured"
        }
        return parts.joined(separator: " · ")
    }

    func travelRadiusSummary(for profile: LifeContextProfile?) -> String {
        guard let profile else { return "Not captured" }
        var parts: [String] = []
        if let minutes = profile.travelRadiusMinutes {
            parts.append("\(minutes) minutes")
        }
        if let miles = profile.travelRadiusMiles {
            parts.append(String(format: "%.1f miles", miles))
        }
        if parts.isEmpty {
            return "Not captured"
        }
        return parts.joined(separator: " · ")
    }

    func facilitiesSummary(for bundle: LifeContextBundle?) -> String {
        guard let bundle, bundle.opportunityContexts.isEmpty == false else {
            return "Not captured"
        }
        let labels = bundle.opportunityContexts.flatMap(\.facilities).map { $0.rawValue.replacingOccurrences(of: "_", with: " ") }
        return labels.isEmpty ? "Not captured" : Array(Set(labels)).sorted().joined(separator: ", ")
    }

    func equipmentSummary(for bundle: LifeContextBundle?) -> String {
        guard let bundle else { return "Not captured" }
        let labels = bundle.opportunityContexts.flatMap(\.equipmentAccess)
        return labels.isEmpty ? "Not captured" : Array(Set(labels)).sorted().joined(separator: ", ")
    }

    func localOrganizationsSummary(for bundle: LifeContextBundle?) -> String {
        guard let bundle else { return "Not captured" }
        let labels = bundle.opportunityContexts.flatMap(\.localOrganizations)
        return labels.isEmpty ? "Not captured" : Array(Set(labels)).sorted().joined(separator: ", ")
    }

    func factSummary(for bundle: LifeContextBundle?, matching categories: [HistoricalContextFactCategory]) -> String {
        guard let bundle else { return "Not captured" }
        let facts = bundle.historicalFacts.filter { $0.isDeletedOrPaused == false && categories.contains($0.category) }
        guard facts.isEmpty == false else {
            return "Not captured"
        }
        return facts.prefix(2).map { $0.title }.joined(separator: ", ")
    }

    func factFreshness(for bundle: LifeContextBundle?, matching categories: [HistoricalContextFactCategory]) -> YouMemoryFreshness {
        guard let bundle else { return .basedOnOlderContext }
        let facts = bundle.historicalFacts.filter { $0.isDeletedOrPaused == false && categories.contains($0.category) }
        guard facts.isEmpty == false else {
            return .basedOnOlderContext
        }
        if facts.contains(where: { $0.freshness == .current }) {
            return .current
        }
        if facts.contains(where: { $0.freshness == .mayNeedReview }) {
            return .mayNeedReview
        }
        return .basedOnOlderContext
    }

    func factState(for bundle: LifeContextBundle?, matching categories: [HistoricalContextFactCategory]) -> AmbitionVisualState {
        switch factFreshness(for: bundle, matching: categories) {
        case .current:
            return .success
        case .mayNeedReview:
            return .warning
        case .basedOnOlderContext:
            return .default
        }
    }

    func deadlineSummary(for bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> String {
        let anchors = bundle?.profile.scheduleAnchors ?? []
        let factWindows = bundle?.historicalFacts
            .filter { $0.isDeletedOrPaused == false && $0.usedFor.contains(.sequencing) }
            .prefix(2)
            .map { $0.title } ?? []
        let items = anchors + factWindows
        if items.isEmpty {
            return projection?.missingContextQuestions.isEmpty == false ? "Open questions still need review" : "Not captured"
        }
        return items.prefix(3).joined(separator: ", ")
    }

    func deadlineFreshness(for bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> YouMemoryFreshness {
        guard let bundle else {
            return .basedOnOlderContext
        }
        if bundle.profile.scheduleAnchors.isEmpty == false {
            return .current
        }
        if projection?.missingContextQuestions.isEmpty == false {
            return .mayNeedReview
        }
        return .basedOnOlderContext
    }

    func deadlineState(for bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> AmbitionVisualState {
        switch deadlineFreshness(for: bundle, projection: projection) {
        case .current:
            return .success
        case .mayNeedReview:
            return .warning
        case .basedOnOlderContext:
            return .default
        }
    }

    func olderContextSummary(for bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> String {
        let staleSources = projection?.sourceFreshnessSummary
            .filter { $0.freshness != .current }
            .prefix(3)
            .map { $0.label } ?? []
        let staleFacts = bundle?.historicalFacts
            .filter { $0.isDeletedOrPaused == false && $0.freshness != .current }
            .prefix(2)
            .map { $0.title } ?? []
        let items = staleSources + staleFacts
        if items.isEmpty {
            return "Current"
        }
        return items.joined(separator: ", ")
    }

    func olderContextFreshness(for bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> YouMemoryFreshness {
        let staleSources = projection?.sourceFreshnessSummary.contains(where: { $0.freshness != .current }) ?? false
        let staleFacts = bundle?.historicalFacts.contains(where: { $0.isDeletedOrPaused == false && $0.freshness != .current }) ?? false
        if staleSources || staleFacts {
            return .mayNeedReview
        }
        return .current
    }

    func olderContextState(for bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> AmbitionVisualState {
        switch olderContextFreshness(for: bundle, projection: projection) {
        case .current:
            return .success
        case .mayNeedReview:
            return .warning
        case .basedOnOlderContext:
            return .default
        }
    }

    func lifeContextFreshnessLabel(bundle: LifeContextBundle?, projection: LifeContextRuntimeProjection?) -> String {
        switch olderContextFreshness(for: bundle, projection: projection) {
        case .current:
            return "Current"
        case .mayNeedReview:
            return "May Need Review"
        case .basedOnOlderContext:
            return "Based on Older Context"
        }
    }

    func memoryFreshness(for freshness: LifeContextFreshness) -> YouMemoryFreshness {
        switch freshness {
        case .current:
            return .current
        case .mayNeedReview:
            return .mayNeedReview
        case .basedOnOlderContext, .stale:
            return .basedOnOlderContext
        }
    }

    func memoryFreshness(for freshness: HistoricalContextFactFreshness) -> YouMemoryFreshness {
        switch freshness {
        case .current:
            return .current
        case .mayNeedReview:
            return .mayNeedReview
        case .basedOnOlderContext, .stale:
            return .basedOnOlderContext
        }
    }

    func displayLabel(for lifeStage: LifeContextLifeStage) -> String {
        switch lifeStage {
        case .middleSchool:
            return "Middle school"
        case .highSchool:
            return "High school"
        case .college:
            return "College"
        case .earlyCareer:
            return "Early career"
        case .adult:
            return "Adult"
        case .parent:
            return "Parent"
        case .caregiver:
            return "Caregiver"
        case .custom:
            return "Custom"
        case .unknown:
            return "Not captured"
        }
    }

    func displayLabel(for transportationAccess: LifeContextTransportationAccess) -> String {
        switch transportationAccess {
        case .walk:
            return "Walk"
        case .bike:
            return "Bike"
        case .transit:
            return "Transit"
        case .rideshare:
            return "Rideshare"
        case .car:
            return "Car"
        case .parentGuardian:
            return "Parent or guardian"
        case .limited:
            return "Limited"
        case .custom:
            return "Custom"
        case .unknown:
            return "Not captured"
        }
    }

    func makeLocalLearningControls(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> [YouLocalLearningControl] {
        [
            YouLocalLearningControl(
                id: "local-learning-reset",
                title: "Reset learned corrections",
                summary: correctionCount == 0
                    ? "No correction learning is active yet; reset stays available as a review path when local teaching signals exist."
                    : "\(correctionCount) correction signal\(correctionCount == 1 ? "" : "s") can be reset from the owning correction path after confirmation.",
                sourceLabel: "Manual corrections",
                availabilityLabel: correctionCount == 0 ? "Available when present" : "Confirmation required",
                receiptLabel: "Receipt required before future reuse changes",
                boundaryLabel: "Does not erase proof, captures, or raw Event Ledger history",
                state: correctionCount == 0 ? .default : .warning,
                accessibilityLabel: "Reset learned corrections",
                accessibilityValue: correctionCount == 0 ? "No active correction learning. Local only." : "\(correctionCount) correction signals. Confirmation required.",
                accessibilityHint: "Explains the reset boundary for local correction learning without claiming broad deletion."
            ),
            YouLocalLearningControl(
                id: "local-learning-disable",
                title: "Disable learning from this signal",
                summary: "Learning reuse can be disabled only at the source-tied signal boundary; Ambitions keeps manual planning and correction available.",
                sourceLabel: "Source-tied learning",
                availabilityLabel: "Review first",
                receiptLabel: "Receipt records disabled reuse",
                boundaryLabel: "Local-only; no silent sync or hidden profile update",
                state: .warning,
                accessibilityLabel: "Disable learning from this signal",
                accessibilityValue: "Review first. Local-only.",
                accessibilityHint: "Explains that disabling learning is source-tied and confirmation-aware."
            ),
            YouLocalLearningControl(
                id: "local-learning-delete",
                title: "Delete a learning signal",
                summary: "Single-signal deletion remains confirmation-gated and receipt-aware. Broad destructive deletion is not claimed from this surface.",
                sourceLabel: "Correction or learning source",
                availabilityLabel: "Needs confirmation",
                receiptLabel: "Deletion receipt required",
                boundaryLabel: "No broad destructive delete claim",
                state: .warning,
                accessibilityLabel: "Delete a learning signal",
                accessibilityValue: "Needs confirmation. No broad destructive delete claim.",
                accessibilityHint: "Explains that deletion is bounded to a source-tied learning signal and does not claim full memory erasure."
            ),
            YouLocalLearningControl(
                id: "local-learning-export",
                title: "Export learning summary",
                summary: exportSummary(
                    eventCount: eventCount,
                    proofFeedbackCount: proofFeedbackCount,
                    correctionCount: correctionCount,
                    openCaptures: openCaptures
                ),
                sourceLabel: "Local summary",
                availabilityLabel: "Summary only",
                receiptLabel: "Export boundary shown before use",
                boundaryLabel: "No raw private text, sync payload, or external memory",
                state: .success,
                accessibilityLabel: "Export learning summary",
                accessibilityValue: "Summary only. No raw private text or external memory.",
                accessibilityHint: "Explains the export boundary for local learning summaries."
            )
        ]
    }

    func exportSummary(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> String {
        let signalCount = eventCount + proofFeedbackCount + correctionCount + openCaptures
        if signalCount == 0 {
            return "Export can summarize that no local learning signals are active, without creating sync or an external profile."
        }

        return "Export can summarize \(signalCount) local signal\(signalCount == 1 ? "" : "s") by category and boundary, without raw private text or broad account data."
    }

    func makeMemoryLensItems(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> [YouMemoryLensItem] {
        [
            YouMemoryLensItem(
                id: "memory-lens-current-plan",
                title: "Current plan context",
                summary: proofFeedbackCount == 0
                    ? "Memory Lens can return to the current plan, but progress proof is still light."
                    : "\(proofFeedbackCount) proof or feedback records can ground plan recall.",
                sourceLabel: "Current plan",
                sourceAgeLabel: proofFeedbackCount == 0 ? "May need review" : "Current",
                whyRemembered: "Why remembered: current goals, proof, and feedback help recall return to Plan or Goal Detail instead of inventing a second history.",
                privacyShutterLabel: "Summary only",
                reviewLabel: "Safe for context recall",
                correctionLabel: "Correct in owning surface",
                rejectionLabel: "No durable memory claim",
                state: proofFeedbackCount == 0 ? .warning : .success,
                accessibilityLabel: "Memory Lens current plan context",
                accessibilityValue: proofFeedbackCount == 0 ? "May need review. Summary only." : "Current. Summary only.",
                accessibilityHint: "Shows source age, why remembered, privacy boundary, and correction posture for current plan recall."
            ),
            YouMemoryLensItem(
                id: "memory-lens-corrections",
                title: "Correction memory",
                summary: correctionCount == 0
                    ? "No active correction memory is available yet."
                    : "\(correctionCount) user-confirmed corrections can shape future explanation language.",
                sourceLabel: "Manual corrections",
                sourceAgeLabel: correctionCount == 0 ? "Based on older context" : "Current",
                whyRemembered: "Why remembered: user corrections can prevent repeated bad assumptions, but reuse stays reviewable.",
                privacyShutterLabel: "No sensitive inference",
                reviewLabel: "Review before durable memory",
                correctionLabel: "Correct or reject reuse",
                rejectionLabel: "Deletion waits for receipt proof",
                state: correctionCount == 0 ? .default : .warning,
                accessibilityLabel: "Memory Lens correction memory",
                accessibilityValue: correctionCount == 0 ? "Based on older context. No sensitive inference." : "Current. Review before durable memory.",
                accessibilityHint: "Shows correction, rejection, and deletion boundaries for correction memory."
            ),
            YouMemoryLensItem(
                id: "memory-lens-open-captures",
                title: "Open capture context",
                summary: openCaptures == 0
                    ? "No open captures need Memory Lens recall right now."
                    : "\(openCaptures) open captures may need placement before they influence planning.",
                sourceLabel: "Captured thought",
                sourceAgeLabel: openCaptures == 0 ? "Current" : "May need review",
                whyRemembered: "Why remembered: unresolved captures may explain what needs a place without becoming hidden work.",
                privacyShutterLabel: "Stored on this device",
                reviewLabel: "Place before stronger use",
                correctionLabel: "Edit in Capture",
                rejectionLabel: "Archive from Capture",
                state: openCaptures == 0 ? .success : .warning,
                accessibilityLabel: "Memory Lens open capture context",
                accessibilityValue: openCaptures == 0 ? "Current. Stored on this device." : "May need review. Stored on this device.",
                accessibilityHint: "Shows source age, privacy boundary, and placement controls for open capture recall."
            )
        ]
    }

    func makeRuntimeInspectionItems(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> [YouRuntimeInspectionItem] {
        [
            YouRuntimeInspectionItem(
                id: "runtime-inspection-learned",
                kind: .learned,
                title: "What Ambitions learned",
                summary: correctionCount == 0
                    ? "No user-confirmed learning is saved yet."
                    : "\(correctionCount) correction signal\(correctionCount == 1 ? "" : "s") can teach future explanation language.",
                sourceLabel: "Manual corrections",
                controlLabel: correctionCount == 0 ? "Available when present" : "Correct or reject reuse",
                privacyLabel: "Local and source-tied",
                state: correctionCount == 0 ? .default : .success,
                accessibilityLabel: "What Ambitions learned",
                accessibilityValue: correctionCount == 0 ? "No user-confirmed learning saved yet. Local and source-tied." : "\(correctionCount) correction signals. Local and source-tied.",
                accessibilityHint: "Shows learned local correction state and where reuse can be corrected or rejected."
            ),
            YouRuntimeInspectionItem(
                id: "runtime-inspection-used",
                kind: .used,
                title: "What Ambitions used",
                summary: proofFeedbackCount + eventCount == 0
                    ? "No proof, feedback, or recent event records are available for current explanations."
                    : "\(proofFeedbackCount + eventCount) proof, feedback, or event record\(proofFeedbackCount + eventCount == 1 ? "" : "s") can ground reviews, receipts, and Why Changed.",
                sourceLabel: "Proof, feedback, Event Ledger",
                controlLabel: "Inspect in owning surfaces",
                privacyLabel: "Summary first",
                state: proofFeedbackCount + eventCount == 0 ? .warning : .success,
                accessibilityLabel: "What Ambitions used",
                accessibilityValue: proofFeedbackCount + eventCount == 0 ? "No current proof, feedback, or recent event records. Summary first." : "\(proofFeedbackCount + eventCount) local records. Summary first.",
                accessibilityHint: "Shows the local records used for review and change explanations."
            ),
            YouRuntimeInspectionItem(
                id: "runtime-inspection-ignored",
                kind: .ignored,
                title: "What Ambitions ignored or rejected",
                summary: openCaptures == 0
                    ? "No open captures are being held back from stronger memory use right now."
                    : "\(openCaptures) open capture\(openCaptures == 1 ? "" : "s") stay held until you place, edit, or archive them.",
                sourceLabel: "Capture review boundary",
                controlLabel: "Place, edit, archive, or reject reuse",
                privacyLabel: "No hidden work",
                state: openCaptures == 0 ? .success : .warning,
                accessibilityLabel: "What Ambitions ignored or rejected",
                accessibilityValue: openCaptures == 0 ? "No held open captures. No hidden work." : "\(openCaptures) open captures held for review. No hidden work.",
                accessibilityHint: "Shows what local context is being held back or rejected before stronger memory use."
            ),
            YouRuntimeInspectionItem(
                id: "runtime-inspection-changed",
                kind: .changed,
                title: "What Ambitions changed",
                summary: eventCount == 0
                    ? "No recent local change events are available yet."
                    : "\(eventCount) recent event\(eventCount == 1 ? "" : "s") can explain what changed without exposing raw history here.",
                sourceLabel: "Event Ledger",
                controlLabel: "Review receipt or owning surface",
                privacyLabel: "Private by default",
                state: eventCount == 0 ? .default : .success,
                accessibilityLabel: "What Ambitions changed",
                accessibilityValue: eventCount == 0 ? "No recent local change events. Private by default." : "\(eventCount) recent local change events. Private by default.",
                accessibilityHint: "Shows recent change state and keeps destructive controls outside this inspection row."
            )
        ]
    }

    func makeNarrativeMemories(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> [YouNarrativeMemory] {
        var memories: [YouNarrativeMemory] = []

        if correctionCount > 0 {
            memories.append(
                YouNarrativeMemory(
                    id: "narrative-memory-corrections",
                    title: "You corrected how Ambitions reads something",
                    summary: "\(correctionCount) manual correction\(correctionCount == 1 ? "" : "s") can change future explanation language where the original artifact still exists.",
                    sourceLabel: "Manual corrections",
                    freshness: .current,
                    usedFor: "Used for Why Changed, recommendation wording, and future review prompts that cite the correction.",
                    sensitiveStatusLabel: "No sensitive inference",
                    actions: [
                        memoryAction(id: "narrative-correct", title: "Correct", statusLabel: "Use owning surface", detail: "Goal Detail, Capture, and explanation controls remain the supported correction paths.", state: .success),
                        memoryAction(id: "narrative-reject", title: "Reject reuse", statusLabel: "Review first", detail: "Rejection is not durable memory behavior here; it is a safe review boundary until receipts and delete coverage exist.", state: .warning),
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
                YouNarrativeMemory(
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
                YouNarrativeMemory(
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
                YouNarrativeMemory(
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
    ) -> [YouMemoryPattern] {
        var patterns: [YouMemoryPattern] = []

        if correctionCount > 0 {
            patterns.append(
                YouMemoryPattern(
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
                YouMemoryPattern(
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
                YouMemoryPattern(
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
                YouMemoryPattern(
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
    ) -> YouMemoryAction {
        YouMemoryAction(
            id: id,
            title: title,
            statusLabel: statusLabel,
            detail: detail,
            state: state
        )
    }

    func makeAssumptionCorrections(snapshot: Snapshot) -> YouAssumptionCorrectionState {
        let activeSignals = snapshot.teachingSignals.filter { $0.disposition == .active }
        let correctionEvents = snapshot.eventLedger.filter { $0.kind == .userCorrectionAdded }
        return YouAssumptionCorrectionState(
            title: "Corrections and assumptions",
            subtitle: "Ambitions should be teachable without asking you to understand its internals.",
            items: [
                SettingsItem(
                    id: "you-correction-active",
                    title: "Active corrections",
                    subtitle: "Existing teaching signals are the current correction path. They are local and bounded to the artifacts they reference.",
                    icon: "checkmark.bubble",
                    valueLabel: activeSignals.isEmpty ? "None yet" : "\(activeSignals.count) active"
                ),
                SettingsItem(
                    id: "you-correction-ledger",
                    title: "Correction events",
                    subtitle: "Correction-shaped ledger entries can be used as evidence for why future recommendations changed.",
                    icon: "clock.arrow.circlepath",
                    valueLabel: correctionEvents.isEmpty ? "No recent entries" : "\(correctionEvents.count) recent"
                ),
                SettingsItem(
                    id: "you-correction-availability",
                    title: "You can correct this",
                    subtitle: "Goal Detail explanations and existing teaching flows remain the supported place to correct assumptions.",
                    icon: "pencil.and.list.clipboard",
                    valueLabel: "Supported where shown"
                )
            ],
            footer: "This is an entry point into existing correction systems, not a second memory model or a full Correction Review."
        )
    }

    func makeAutomationBoundary(safetySamples: SafetyBoundarySamples) -> YouAutomationBoundaryState {
        YouAutomationBoundaryState(
            title: "What Ambitions will not do silently",
            subtitle: "The safe automation policy keeps external, broad, destructive, and unsupported changes confirmation-gated or blocked.",
            rules: [
                YouConstitutionRule(
                    id: "automation-calendar",
                    title: "No silent calendar changes",
                    detail: safetySamples.calendarWrite.reasons.map(\.userFacingSummary).joined(separator: " "),
                    statusLabel: "Requires confirmation",
                    state: .warning
                ),
                YouConstitutionRule(
                    id: "automation-reflow",
                    title: "No silent broad reflow",
                    detail: safetySamples.broadReflow.reasons.map(\.userFacingSummary).joined(separator: " "),
                    statusLabel: "Requires confirmation",
                    state: .warning
                ),
                YouConstitutionRule(
                    id: "automation-memory",
                    title: "No unsupported forgetting",
                    detail: safetySamples.forgetMemory.blockedFacts.first ?? "No memory was forgotten.",
                    statusLabel: safetySamples.destructiveBlocked ? "Blocked safely" : "Unavailable",
                    state: .warning
                ),
                YouConstitutionRule(
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

    func makePlanningDefaultsCenter(
        calendarAuthorization: CalendarRemindersAuthorizationState,
        remindersAuthorization: CalendarRemindersAuthorizationState,
        safetySamples: SafetyBoundarySamples
    ) -> YouPlanningDefaultsCenterState {
        YouPlanningDefaultsCenterState(
            title: "Planning setup that earns its place",
            subtitle: "These defaults explain how Ambitions shapes Time suggestions without treating setup as homework.",
            sections: [
                YouPlanningDefaultsSection(
                    id: "schedule-availability",
                    title: "Schedule & Availability",
                    subtitle: "Time boundaries help the scheduling surface avoid treating committed or protected time as available.",
                    preferences: [
                        YouPlanningDefaultsPreference(
                            id: "schedule-anchors",
                            title: "Work, school, and anchors",
                            whyItMatters: "Plan can keep committed blocks, transitions, sleep, care, and recovery from being mistaken for open capacity.",
                            statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                            privacyLabel: "Calendar awareness is Time-owned and requested only after a clear Time action.",
                            defaultLabel: "Optional",
                            accessibilityHint: "Explains why schedule anchors improve planning fit.",
                            state: .default
                        ),
                        YouPlanningDefaultsPreference(
                            id: "schedule-buffers",
                            title: "Buffers and protected time",
                            whyItMatters: "Buffers and protected free time create breathing room before Ambitions suggests where work can fit.",
                            statusLabel: "Protected",
                            privacyLabel: "Open time is not automatically filled.",
                            defaultLabel: "Do not fill",
                            accessibilityHint: "Explains how buffers protect capacity.",
                            state: .success
                        )
                    ],
                    footer: "Setup remains optional. Ambitions should ask for clearer boundaries only when planning quality depends on them."
                ),
                YouPlanningDefaultsSection(
                    id: "planning-defaults",
                    title: "Planning Defaults",
                    subtitle: "Defaults keep Time useful without making hidden changes.",
                    preferences: [
                        YouPlanningDefaultsPreference(
                            id: "planning-open-time",
                            title: "Open time behavior",
                            whyItMatters: "Open windows are capacity signals, not an invitation to pack the day.",
                            statusLabel: AvailabilityState.doNotFill.displayLabel,
                            privacyLabel: "Your time, your rules.",
                            defaultLabel: "Default",
                            accessibilityHint: "Explains the open time default.",
                            state: .success
                        ),
                        YouPlanningDefaultsPreference(
                            id: "planning-reflow",
                            title: "Reflow permission",
                            whyItMatters: "Meaningful day changes stay reviewable so Plan can recover without taking over.",
                            statusLabel: "Ask first",
                            privacyLabel: "Receipts explain consequential changes.",
                            defaultLabel: nil,
                            accessibilityHint: "Explains the reflow permission boundary.",
                            state: .warning
                        )
                    ],
                    footer: "Day, Week, and Month remain capacity lenses. They are not calendar modes."
                ),
                YouPlanningDefaultsSection(
                    id: "vacation-away-time",
                    title: "Vacation / Away Time",
                    subtitle: "Away time protects recovery unless you explicitly mark a window open.",
                    preferences: [
                        YouPlanningDefaultsPreference(
                            id: "vacation-default",
                            title: "Away time default",
                            whyItMatters: "Vacation is not free time by default, so Plan does not turn recovery into a work queue.",
                            statusLabel: VacationAvailabilityBehavior.defaultBehavior.displayLabel,
                            privacyLabel: "The selected behavior applies only to planning fit.",
                            defaultLabel: "Default",
                            accessibilityHint: "Explains the away time default.",
                            state: .success
                        ),
                        YouPlanningDefaultsPreference(
                            id: "vacation-override",
                            title: "Per-vacation override",
                            whyItMatters: "A specific trip can be open, protected, or mixed without changing future away-time defaults unless you choose to.",
                            statusLabel: "Per away block",
                            privacyLabel: "Future defaults change only through visible user choice.",
                            defaultLabel: nil,
                            accessibilityHint: "Explains per-vacation override behavior.",
                            state: .default
                        )
                    ],
                    footer: "Away-time behavior is a planning boundary, not a judgment about how time should be spent."
                ),
                YouPlanningDefaultsSection(
                    id: "automation-trust",
                    title: "Trust & Automation",
                    subtitle: "Trust comes before automation; automation remains permission posture, not silent control.",
                    preferences: [
                        YouPlanningDefaultsPreference(
                            id: "automation-guided",
                            title: "Guided automation",
                            whyItMatters: AutomationLevel.defaultLevel.explanation,
                            statusLabel: AutomationLevel.defaultLevel.displayLabel,
                            privacyLabel: "Ambitions proposes first and asks before consequential changes.",
                            defaultLabel: "Default",
                            accessibilityHint: "Explains the Guided automation default.",
                            state: .selected
                        ),
                        YouPlanningDefaultsPreference(
                            id: "automation-confirmation",
                            title: "Confirmation boundary",
                            whyItMatters: safetySamples.calendarWrite.reasons.map(\.userFacingSummary).joined(separator: " "),
                            statusLabel: "Requires confirmation",
                            privacyLabel: "No silent calendar changes.",
                            defaultLabel: nil,
                            accessibilityHint: "Explains the automation confirmation boundary.",
                            state: .warning
                        )
                    ],
                    footer: "This center explains the default. It does not execute calendar writes, permission requests, or broad reflow."
                )
            ],
            footer: "Planning setup is useful when it makes recommendations fit real capacity. It should never pressure completion or imply hidden access."
        )
    }

    func makeAvailabilityCenter(
        calendarAuthorization: CalendarRemindersAuthorizationState,
        remindersAuthorization: CalendarRemindersAuthorizationState,
        safetySamples: SafetyBoundarySamples
    ) -> YouAvailabilityCenterState {
        YouAvailabilityCenterState(
            title: "Availability Center",
            subtitle: "The rules Time must respect before it suggests where work fits.",
            hardContextStack: [
                YouAvailabilityCenterItem(
                    id: "hard-context-work-school",
                    title: "Work, school, and fixed anchors",
                    summary: "Committed blocks, sleep, care, commute, and buffers win before any planning suggestion.",
                    statusLabel: calendarAuthorizationLabel(calendarAuthorization),
                    sourceLabel: "Source: Time-owned calendar boundary",
                    state: .default
                ),
                YouAvailabilityCenterItem(
                    id: "hard-context-protected-time",
                    title: "Protected time",
                    summary: "Protected pockets are treated as real commitments, not open capacity.",
                    statusLabel: "Hard context",
                    sourceLabel: "Source: User default",
                    state: .success
                )
            ],
            protectedPocketMap: [
                YouAvailabilityCenterItem(
                    id: "protected-pocket-open-time",
                    title: "Open time is not auto-filled",
                    summary: "Open windows can help Plan see possibility, but Ambitions must not pack them by default.",
                    statusLabel: AvailabilityState.doNotFill.displayLabel,
                    sourceLabel: "Source: Planning default",
                    state: .success
                ),
                YouAvailabilityCenterItem(
                    id: "protected-pocket-buffers",
                    title: "Buffers create breathing room",
                    summary: "Transitions, rest, and family/context margins stay visible before a day is reshaped.",
                    statusLabel: "Protected",
                    sourceLabel: "Source: Capacity boundary",
                    state: .success
                )
            ],
            planningDefaults: [
                YouAvailabilityCenterItem(
                    id: "planning-defaults-capacity-lenses",
                    title: "Day, Week, and Month are capacity lenses",
                    summary: "They are not calendar modes and should not become dense event grids.",
                    statusLabel: "Capacity lens",
                    sourceLabel: "Source: Product canon",
                    state: .default
                ),
                YouAvailabilityCenterItem(
                    id: "planning-defaults-reflow-review",
                    title: "Reflow stays reviewable",
                    summary: "Meaningful rearrangement needs a visible review boundary and receipt posture.",
                    statusLabel: "Ask first",
                    sourceLabel: "Source: Trust default",
                    state: .warning
                )
            ],
            automationTrustControls: [
                YouAvailabilityCenterItem(
                    id: "automation-guided-default",
                    title: "Guided automation is default",
                    summary: AutomationLevel.defaultLevel.explanation,
                    statusLabel: AutomationLevel.defaultLevel.displayLabel,
                    sourceLabel: "Source: Automation policy",
                    state: .selected
                ),
                YouAvailabilityCenterItem(
                    id: "automation-calendar-confirmation",
                    title: "Calendar writes require confirmation",
                    summary: safetySamples.calendarWrite.reasons.map(\.userFacingSummary).joined(separator: " "),
                    statusLabel: "Requires confirmation",
                    sourceLabel: "Source: Plan safety policy",
                    state: .warning
                )
            ],
            durationSourceProof: DurationSource.allCases.map { source in
                YouAvailabilityCenterItem(
                    id: "duration-source-\(source.rawValue)",
                    title: durationTitle(for: source),
                    summary: durationSubtitle(for: source),
                    statusLabel: "Labeled",
                    sourceLabel: "Source: Duration proof",
                    state: source == .unset ? .default : .success
                )
            },
            vacationAwayBehavior: [
                YouAvailabilityCenterItem(
                    id: "away-default",
                    title: "Vacation is not free time by default",
                    summary: "Away time protects recovery unless the user explicitly marks part of it available.",
                    statusLabel: VacationAvailabilityBehavior.defaultBehavior.displayLabel,
                    sourceLabel: "Source: Away behavior default",
                    state: .success
                ),
                YouAvailabilityCenterItem(
                    id: "away-override",
                    title: "Per-away override",
                    summary: "A specific away block can be open, protected, or mixed without changing future defaults.",
                    statusLabel: "Visible choice",
                    sourceLabel: "Source: User override",
                    state: .default
                )
            ],
            footer: "Availability Center explains how defaults affect Today and Plan. It does not request permissions, write calendars, auto-fill open time, or run broad reflow."
        )
    }

    private func durationTitle(for source: DurationSource) -> String {
        switch source {
        case .userSet: "User-set"
        case .userAccepted: "Accepted suggestion"
        case .suggested: "Suggested"
        case .historical: "Historical range"
        case .unset: "Unset"
        case .actual: "Actual"
        }
    }

    private func durationSubtitle(for source: DurationSource) -> String {
        switch source {
        case .userSet: "Shown as planned because you set it."
        case .userAccepted: "Shown as planned after you accept it."
        case .suggested: "Always labeled as suggested."
        case .historical: "Always labeled as usually."
        case .unset: "Shown as Duration not set."
        case .actual: "Shown only after completion evidence exists."
        }
    }

    func makePolicyReceipts(safetySamples: SafetyBoundarySamples) -> [ActionReceipt] {
        [
            safetySamples.calendarWrite.recommendedReceipt(occurredAt: "2026-04-27T00:00:00Z"),
            safetySamples.forgetMemory.recommendedReceipt(occurredAt: "2026-04-27T00:00:01Z"),
            safetySamples.localCorrection.recommendedReceipt(occurredAt: "2026-04-27T00:00:02Z")
        ]
    }

    func makeReceiptAudit(snapshot: Snapshot, receipts: [ActionReceipt]) -> YouReceiptAuditState {
        let projection = ActionReceiptProjection(receipts: receipts)
        return YouReceiptAuditState(
            title: "Receipts and audit posture",
            subtitle: "A compact trust summary of what can explain actions today. Reviews now turns these signals into a calm receipt layer.",
            items: [
                SettingsItem(
                    id: "you-receipts-domain",
                    title: "Receipts",
                    subtitle: "Receipts can summarize what changed, why, correction availability, safe fallback, and undo status where supported.",
                    icon: "doc.text.magnifyingglass",
                    valueLabel: "\(projection.displaySummaries(limit: 3).count) policy examples"
                ),
                SettingsItem(
                    id: "you-receipts-ledger",
                    title: "Recent Event Ledger",
                    subtitle: "Recent ledger entries remain local evidence. This page shows counts and status rather than raw logs.",
                    icon: "clock",
                    valueLabel: snapshot.eventLedger.isEmpty ? "No recent events" : "\(snapshot.eventLedger.count) recent"
                ),
                SettingsItem(
                    id: "you-receipts-memory",
                    title: "Memory receipts",
                    subtitle: "Why remembered this should cite source, freshness, use, privacy posture, and correction or delete availability before memory is reused.",
                    icon: "brain.head.profile",
                    valueLabel: snapshot.teachingSignals.isEmpty ? "Evidence-light" : "Why remembered"
                ),
                SettingsItem(
                    id: "you-receipts-review",
                    title: "Reviews v1",
                    subtitle: "Recovery Review and Life OS Receipt summarize local events, receipts, proof, and corrections without creating a separate top-level destination.",
                    icon: "rectangle.stack.badge.play",
                    valueLabel: snapshot.eventLedger.isEmpty ? "Nothing to review yet" : "Ready to review"
                )
            ],
            footer: "Receipts are exposed here as trust posture, not as a full history browser."
        )
    }

    func makeTrustHistoryCenter(
        snapshot: Snapshot,
        receipts: [ActionReceipt],
        safetySamples: SafetyBoundarySamples,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        notificationStatus: YouNotificationAuthorization
    ) -> YouTrustHistoryCenterState {
        YouTrustHistoryProjector().project(
            YouTrustHistoryProjector.Input(
                receipts: ActionReceiptProjection(receipts: receipts).displaySummaries(limit: 2),
                recentEvents: Array(snapshot.eventLedger.prefix(2)),
                proofCount: snapshot.evidence.count,
                sourceReviewCount: snapshot.eventLedger.filter(\.trust.requiresReview).count + snapshot.teachingSignals.count,
                automationReviewCount: safetySamples.confirmationRequired + (safetySamples.destructiveBlocked ? 1 : 0),
                permissionSummary: "Notifications \(notificationStatus.statusLabel); calendar \(calendarAuthorizationLabel(calendarAuthorization))."
            )
        )
    }

    func makeCrossSurfaceProofReview(snapshot: Snapshot) -> YouCrossSurfaceProofReviewState {
        let captureSeedCount = snapshot.captures.filter { $0.status != .archived }.count +
            snapshot.drafts.filter { draft in
                draft.latestResultKind == .planned ||
                    draft.latestResultKind == .starterPlanned ||
                    draft.latestResultKind == .clarificationRequired
            }.count
        let goalProofCount = snapshot.evidence.filter { !$0.goalID.isEmpty }.count
        let todayCompletionProofCount = snapshot.evidence.filter { evidence in
            evidence.evidenceKind == .stepCompleted || evidence.evidenceKind == .sessionLogged
        }.count
        let planReceiptCount = snapshot.eventLedger.filter { event in
            event.source == .plan ||
                event.source == .planner ||
                event.kind == .planRecovered ||
                event.kind == .planRescheduled ||
                event.kind == .planUpdated
        }.count
        let goalChangeCount = snapshot.eventLedger.filter { event in
            event.source == .goals ||
                event.source == .goalEngine ||
                event.kind == .goalCreated ||
                event.kind == .goalUpdated ||
                event.kind == .deadlineChanged ||
                event.kind == .priorityChanged
        }.count
        let reviewPromptCount = snapshot.eventLedger.filter(\.trust.requiresReview).count +
            snapshot.teachingSignals.count

        return YouCrossSurfaceProofReviewProjector().project(
            YouCrossSurfaceProofReviewProjector.Input(
                captureSeedCount: captureSeedCount,
                goalProofCount: goalProofCount,
                todayCompletionProofCount: todayCompletionProofCount,
                planReceiptCount: planReceiptCount,
                goalChangeCount: goalChangeCount,
                reviewPromptCount: reviewPromptCount
            )
        )
    }

    func makeReviews(
        snapshot: Snapshot,
        receipts: [ActionReceipt],
        calendarAuthorization: CalendarRemindersAuthorizationState
    ) -> YouReviewsState {
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

        return YouReviewsState(
            projection: projection,
            title: "Reviews",
            subtitle: "Recovery Review and Life OS Receipt for what happened, what changed, and what should carry forward.",
            footer: "Reviews uses existing local ledgers, receipts, proof, and correction signals. It does not restore Insights as a tab or claim live sync, account systems, or verified accessibility."
        )
    }

    func dominantTruth(
        syncStatus: SyncCapabilityStatus,
        notificationStatus: YouNotificationAuthorization,
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

    func syncTrustStatusLabel(_ status: SyncCapabilityStatus) -> String {
        if status.availability == .unavailable &&
            status.detail == "Ambitions is running in explicit local-only mode." {
            return "Not currently connected"
        }
        return status.detail
    }

    func syncExportTruthSubtitle(_ status: SyncCapabilityStatus) -> String {
        if status.availability == .unavailable &&
            status.detail == "Ambitions is running in explicit local-only mode." {
            return "Sync is not connected. Export and import proof remain future-owned until the disaster drill passes."
        }
        return "\(status.detail) Export and import proof remain future-owned until the disaster drill passes."
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

    func notificationAuthorizationSubtitle(for status: YouNotificationAuthorization) -> String {
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

    func notificationAuthorizationStatus(_ state: NotificationAuthorizationState) -> YouNotificationAuthorization {
        switch state {
        case .notDetermined:
            return YouNotificationAuthorization(
                statusLabel: "Not requested",
                detail: "Not requested yet.",
                canRequestAuthorization: true,
                actionTitle: "Enable notifications"
            )
        case .denied:
            return YouNotificationAuthorization(
                statusLabel: "Denied",
                detail: "Denied in system settings.",
                canRequestAuthorization: false,
                actionTitle: nil
            )
        case .authorized:
            return YouNotificationAuthorization(
                statusLabel: "Allowed",
                detail: "Allowed for local reminders.",
                canRequestAuthorization: false,
                actionTitle: nil
            )
        case .provisional:
            return YouNotificationAuthorization(
                statusLabel: "Allowed",
                detail: "Provisionally allowed for local reminders.",
                canRequestAuthorization: false,
                actionTitle: nil
            )
        case .ephemeral:
            return YouNotificationAuthorization(
                statusLabel: "Allowed",
                detail: "Temporarily allowed for local reminders.",
                canRequestAuthorization: false,
                actionTitle: nil
            )
        }
    }
}
