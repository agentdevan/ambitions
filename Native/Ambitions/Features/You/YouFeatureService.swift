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

extension RepositoryBackedYouService {
    func makePersonalRuntimeLearningSignalInspectionItems(
        _ signals: [PersonalRuntimeLearningSignal]
    ) -> [YouRuntimeInspectionItem] {
        signals.map { signal in
            let state: AmbitionVisualState
            switch signal.confidenceState {
            case .active:
                state = .success
            case .reviewRequired:
                state = .warning
            case .disabled, .reset, .deleted:
                state = .default
            }

            return YouRuntimeInspectionItem(
                id: "runtime-inspection-personal-\(signal.signalType.rawValue)-\(signal.id)",
                kind: .learned,
                title: "What Personal Runtime learned from momentum reflow",
                summary: signal.personalRuntimeInspectableSummary,
                sourceLabel: signal.sourceRecordLabel,
                controlLabel: signal.isExcludedFromFutureRanking
                    ? "Reset, disable, delete, or export in What Ambitions knows"
                    : "Inspect in What Ambitions knows",
                privacyLabel: signal.personalRuntimeInspectionLabel,
                state: state,
                accessibilityLabel: "Momentum reflow learning signal",
                accessibilityValue: signal.personalRuntimeInspectableSummary,
                accessibilityHint: "Shows the source-tied momentum reflow learning signal, its review boundary, and the local controls available in What Ambitions knows."
            )
        }
    }

    func makePersonalRuntimeLearningSignalControls(
        _ signals: [PersonalRuntimeLearningSignal]
    ) -> [YouLocalLearningControl] {
        signals.flatMap { signal in
            let sourceLabel = signal.sourceRecordLabel
            let availabilityLabel = signal.requiresSensitiveReview
                ? "Review required"
                : (signal.isExcludedFromFutureRanking ? "Excluded from future ranking" : "Available in What Ambitions knows")
            let boundaryLabel = signal.medicalAdviceBoundarySummary

            return [
                YouLocalLearningControl(
                    id: "personal-runtime-reset-\(signal.id)",
                    title: "Reset momentum reflow learning",
                    summary: signal.resetting().personalRuntimeInspectableSummary,
                    sourceLabel: sourceLabel,
                    availabilityLabel: availabilityLabel,
                    receiptLabel: signal.exportSelection(includingRelatedSource: true).summary,
                    boundaryLabel: boundaryLabel,
                    state: signal.isExcludedFromFutureRanking ? .warning : .default,
                    accessibilityLabel: "Reset momentum reflow learning",
                    accessibilityValue: availabilityLabel,
                    accessibilityHint: "Resets the momentum reflow learning signal while preserving the local receipt and replay boundary."
                ),
                YouLocalLearningControl(
                    id: "personal-runtime-disable-\(signal.id)",
                    title: "Disable momentum reflow learning",
                    summary: signal.disabling().personalRuntimeInspectableSummary,
                    sourceLabel: sourceLabel,
                    availabilityLabel: availabilityLabel,
                    receiptLabel: signal.deleteSelection(includingRelatedSource: false).summary,
                    boundaryLabel: boundaryLabel,
                    state: signal.isExcludedFromFutureRanking ? .warning : .default,
                    accessibilityLabel: "Disable momentum reflow learning",
                    accessibilityValue: availabilityLabel,
                    accessibilityHint: "Disables reuse of the momentum reflow learning signal without silently mutating the source record."
                ),
                YouLocalLearningControl(
                    id: "personal-runtime-delete-\(signal.id)",
                    title: "Delete momentum reflow learning",
                    summary: signal.deleting().personalRuntimeInspectableSummary,
                    sourceLabel: sourceLabel,
                    availabilityLabel: "Needs confirmation",
                    receiptLabel: signal.deleteSelection(includingRelatedSource: true).summary,
                    boundaryLabel: boundaryLabel,
                    state: .warning,
                    accessibilityLabel: "Delete momentum reflow learning",
                    accessibilityValue: "Needs confirmation",
                    accessibilityHint: "Deletes or tombstones the momentum reflow learning signal according to the selected choice."
                ),
                YouLocalLearningControl(
                    id: "personal-runtime-export-\(signal.id)",
                    title: "Export momentum reflow learning",
                    summary: signal.exportSelection(includingRelatedSource: true).summary,
                    sourceLabel: sourceLabel,
                    availabilityLabel: "Summary plus related source",
                    receiptLabel: signal.exportSelection(includingRelatedSource: true).summary,
                    boundaryLabel: boundaryLabel,
                    state: .success,
                    accessibilityLabel: "Export momentum reflow learning",
                    accessibilityValue: "Summary plus related source",
                    accessibilityHint: "Exports the momentum reflow signal and related source when selected."
                )
            ]
        }
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

    struct EverythingSearchDocument {
        let id: String
        let kind: YouEverythingSearchObjectKind
        let title: String
        let summary: String
        let sourceLabel: String
        let freshness: YouMemoryFreshness
        let actions: [YouEverythingSearchAction]
        let createdAt: String
        let updatedAt: String
        let searchableText: String
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
        let memoryControls = makeMemoryControls(snapshot: snapshot, personalRuntimeLearningSignals: [])
        let personalVault = makePersonalVaultState(
            snapshot: snapshot,
            syncStatus: syncStatus,
            notificationStatus: notificationStatus,
            remindersAuthorization: remindersAuthorization,
            calendarAuthorization: calendarAuthorization,
            receipts: policyReceipts,
            memoryControls: memoryControls
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
            memoryControls: memoryControls,
            personalVault: personalVault,
            everythingSearch: makeEverythingSearchState(snapshot: snapshot),
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
                subtitle: "Truthful status for local-first data, permissions, personal vault rows, external surfaces, sync, automation, and recovery.",
                pulse: YouTrustPulseState(
                    title: "Local trust pulse",
                    subtitle: syncPulseTitle(for: syncStatus),
                    detail: "Stored on this device. Optional permissions are explicit. Future sync and external surfaces remain labeled until verified.",
                    state: syncState
                ),
                items: [
                    SettingsItem(
                        id: "you-trust-personal-vault",
                        title: "Personal vault",
                        subtitle: "Sensitive local signal rows stay inspectable before stronger policy or export work lands.",
                        icon: "lock.shield",
                        valueLabel: personalVault.sections.flatMap(\.rows).isEmpty ? "Summary only" : "\(personalVault.sections.flatMap(\.rows).count) rows"
                    ),
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
                    receipts: policyReceipts,
                    personalVault: personalVault
                ),
                sections: makeTrustCenterSections(
                    syncStatus: syncStatus,
                    notificationStatus: notificationStatus,
                    calendarAuthorization: calendarAuthorization,
                    receipts: policyReceipts,
                    teachingSignalCount: snapshot.teachingSignals.count,
                    personalVault: personalVault
                ),
                receiptSummaries: ActionReceiptProjection(receipts: policyReceipts).displaySummaries(limit: 3),
                footer: "Trust-sensitive features are labeled as available, manual, unavailable, or future planned. Ambitions does not claim live sync, account systems, verified accessibility, or complete personal vault coverage here."
            ),
            contextVault: YouContextVaultState(
                title: "Local memory map",
                subtitle: "A compact inventory of local signal types, not an automatic profile or vault engine.",
                items: [
                    YouContextVaultItem(
                        id: "you-vault-signals",
                        title: "Recommendation evidence",
                        subtitle: "These categories can explain recommendations without claiming cloud intelligence.",
                        icon: "tray.full",
                        detail: "\(snapshot.evidence.count) evidence records, \(snapshot.feedback.count) feedback events, \(snapshot.teachingSignals.count) teaching signals, \(eventLedgerCount) recent ledger events"
                    ),
                    YouContextVaultItem(
                        id: "you-vault-personal-vault",
                        title: "Personal vault",
                        subtitle: "Sensitive signal rows and permission labels stay reviewable through You.",
                        icon: "lock.shield",
                        detail: personalVault.sections.flatMap(\.rows).isEmpty ? "Summary only" : "\(personalVault.sections.flatMap(\.rows).count) rows, local-first"
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
                        id: "you-policy-vault",
                        title: "Personal vault is explicit",
                        detail: "Sensitive local signals should stay inspectable, resettable, and confirmation-gated until the owning surface proves more.",
                        state: .selected
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
                footer: "This is a foundation layer, not a full privacy admin surface. It keeps current local context and personal vault boundaries understandable without inventing account, sync, or export flows."
            ),
            sourceAtlasKnowledge: makeSourceAtlasKnowledgeState(snapshot: snapshot),
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
        receipts: [ActionReceipt],
        personalVault: YouPersonalVaultState
    ) -> [YouTrustDataMapItem] {
        let openCaptures = snapshot.captures.filter { $0.status != .archived }.count
        let receiptCount = ActionReceiptProjection(receipts: receipts).displaySummaries().count
        let localSignalCount = snapshot.evidence.count + snapshot.feedback.count + snapshot.teachingSignals.count + snapshot.eventLedger.count
        let personalVaultRowCount = personalVault.sections.flatMap(\.rows).count
        return [
            YouTrustDataMapItem(
                id: "trust-data-map-personal-vault",
                title: "Personal vault",
                dataTypes: "Sensitive local signals, permissions, export, reset, delete, provenance, privacy policy",
                sourceLabel: personalVaultRowCount == 0 ? "Summary only" : "\(personalVaultRowCount) rows in You",
                controlLabel: "Inspect in What Ambitions knows",
                privacyLabel: "Private by default",
                statusLabel: "Local and inspectable",
                semanticState: .trust
            ),
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
        teachingSignalCount: Int,
        personalVault: YouPersonalVaultState
    ) -> [YouTrustCenterSection] {
        let receiptProjection = ActionReceiptProjection(receipts: receipts)
        let undoCount = receiptProjection.undoAvailableReceipts().count
        let receiptCount = receiptProjection.displaySummaries().count
        let personalVaultRowCount = personalVault.sections.flatMap(\.rows).count

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
                    ),
                    YouTrustCenterRoute(
                        id: "trust-route-personal-vault",
                        title: "Personal vault",
                        subtitle: "Sensitive local signal rows, provenance, and permission labels stay visible before broader policy work.",
                        icon: "lock.shield",
                        statusLabel: personalVaultRowCount == 0 ? "Summary only" : "\(personalVaultRowCount) rows",
                        semanticState: .trust,
                        accessibilityHint: "Shows personal vault and permissions posture."
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
                        id: "trust-route-vault-export",
                        title: "Vault export boundary",
                        subtitle: "Personal vault rows stay explicit about what can be exported, reset, deleted, or kept summary-only.",
                        icon: "square.and.arrow.up",
                        statusLabel: personalVaultRowCount == 0 ? "Summary only" : "Review only",
                        semanticState: .caution,
                        accessibilityHint: "Shows vault export and delete boundary."
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
            subtitle: "User System Profile keeps Planning Setup, Trust & Automation, Privacy, Receipts & History, and Defaults visible.",
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
                            subtitle: "SourceRecord-backed local context you can inspect, correct, reset, or hold back.",
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

    func makeMemoryControls(
        snapshot: Snapshot,
        personalRuntimeLearningSignals: [PersonalRuntimeLearningSignal] = []
    ) -> YouMemoryControlState {
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
        let personalRuntimeInspectionItems = makePersonalRuntimeLearningSignalInspectionItems(personalRuntimeLearningSignals)
        let localLearningControls = makeLocalLearningControls(
            eventCount: eventCount,
            proofFeedbackCount: proofFeedbackCount,
            correctionCount: correctionCount,
            openCaptures: openCaptures
        )
        let personalRuntimeLearningControls = makePersonalRuntimeLearningSignalControls(personalRuntimeLearningSignals)
        return YouMemoryControlState(
            title: "What Ambitions Knows",
            subtitle: "SourceRecord-backed local memory areas Ambitions can use, what each one is for, and where you can correct, reset, disable, delete, or export it.",
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
                summary: "Ambitions can use current local memory to explain and suggest, but stronger memory changes stay reviewable, resettable, and receipt-aware.",
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
            runtimeInspectionItems: runtimeInspectionItems + personalRuntimeInspectionItems,
            localLearningControls: localLearningControls + personalRuntimeLearningControls,
            recoverySummary: hasRecentMemory ? "Memory can be reviewed and corrected from the owning surfaces. Broad delete, forget, and pause controls remain confirmation-gated or future-owned." : "There is little local memory yet. Ambitions should say when a recommendation is evidence-light instead of pretending it knows more.",
            footer: "What Ambitions Knows is local, inspectable, and correctable through existing safe seams. Narrative memory only appears from explicit local evidence, receipts, corrections, reviews, or confirmations; broad forgetting, deletion, and export remain confirmation-gated, export-bounded, and durable rejected-memory rules remain manual/future until the safe boundary can prove the result."
        )
    }

    func makePersonalVaultState(
        snapshot: Snapshot,
        syncStatus: SyncCapabilityStatus,
        notificationStatus: YouNotificationAuthorization,
        remindersAuthorization: CalendarRemindersAuthorizationState,
        calendarAuthorization: CalendarRemindersAuthorizationState,
        receipts: [ActionReceipt],
        memoryControls: YouMemoryControlState
    ) -> YouPersonalVaultState {
        let receiptCount = ActionReceiptProjection(receipts: receipts).displaySummaries().count
        let learningControlCount = memoryControls.localLearningControls.count
        let personalDefaultsRow = makePersonalVaultRow(
            id: "personal-vault-defaults",
            kind: .signal,
            title: "Personal defaults",
            summary: "Name, landing tab, appearance, and review cadence stay separate from the surfaces they influence.",
            sourceLabel: "User System Profile",
            storageLabel: snapshot.appState.localOnlyModeEnabled ? "Stored on this device" : "Needs review",
            exportLabel: "Summary export only",
            resetLabel: "Reset in You",
            deleteLabel: "Delete requires confirmation",
            provenanceLabel: "SourceRecord-backed profile state",
            privacyPolicyLabel: "Private by default",
            permissionLabel: "User-owned",
            state: snapshot.appState.userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .default : .selected,
            accessibilityHint: "Shows the profile defaults row and the visible storage, export, reset, delete, provenance, privacy, and permission labels."
        )
        let learningRow = makePersonalVaultRow(
            id: "personal-vault-learning",
            kind: .signal,
            title: "Local learning signals",
            summary: memoryControls.localLearningControls.isEmpty ? "Local learning stays summary-only until the current runtime collects signals." : "\(learningControlCount) local learning controls stay reviewable in What Ambitions knows.",
            sourceLabel: "What Ambitions knows",
            storageLabel: "Stored on this device",
            exportLabel: "Summary plus receipt labels",
            resetLabel: "Reset in What Ambitions knows",
            deleteLabel: "Delete requires confirmation",
            provenanceLabel: "SourceRecord / Receipt / ReplayTrace",
            privacyPolicyLabel: "Private by default",
            permissionLabel: "Review gated",
            state: memoryControls.localLearningControls.isEmpty ? .default : .selected,
            accessibilityHint: "Shows the learning signal row and how local learning remains inspectable without hidden inference."
        )
        let proofRow = makePersonalVaultRow(
            id: "personal-vault-proof",
            kind: .signal,
            title: "Proof and receipts",
            summary: receiptCount == 0 ? "Receipt summaries are not present yet." : "\(receiptCount) receipt summaries stay visible without exposing raw logs by default.",
            sourceLabel: "Receipts and History",
            storageLabel: "Stored on this device",
            exportLabel: "Summary export only",
            resetLabel: "Reset in Receipts",
            deleteLabel: "Delete requires confirmation",
            provenanceLabel: "Receipt-backed provenance",
            privacyPolicyLabel: "Summaries first",
            permissionLabel: "Inspect in Trust Center",
            state: receiptCount == 0 ? .default : .selected,
            accessibilityHint: "Shows the proof and receipt row and the local boundaries around export, reset, and delete."
        )
        let permissionsRow = makePersonalVaultRow(
            id: "personal-vault-permissions",
            kind: .permission,
            title: "Permission matrix",
            summary: "Notifications, calendar, export, and destructive delete stay explicit instead of implied.",
            sourceLabel: "Trust Center",
            storageLabel: "Status stored locally",
            exportLabel: "Export status only",
            resetLabel: "Revoke or re-request in system settings",
            deleteLabel: "Delete remains confirmation-gated",
            provenanceLabel: "System authorization state",
            privacyPolicyLabel: "No silent writes",
            permissionLabel: "Permission-gated",
            state: (notificationStatus.statusLabel == "Denied" || calendarAuthorization == .denied || remindersAuthorization == .denied || syncStatus.availability == .unavailable) ? .warning : .selected,
            accessibilityHint: "Shows the permission matrix row and its local-first trust boundary."
        )
        let storageRow = makePersonalVaultRow(
            id: "personal-vault-storage",
            kind: .permission,
            title: "Protected storage boundary",
            summary: snapshot.appState.localOnlyModeEnabled ? "On-device storage is active, but protected-storage proof and broader export claims remain unverified." : "Storage mode needs review before broader protection claims can be made.",
            sourceLabel: "AppStateSnapshot",
            storageLabel: snapshot.appState.localOnlyModeEnabled ? "Local-only" : "Needs review",
            exportLabel: "Portable snapshot pending proof",
            resetLabel: "Reset on device",
            deleteLabel: "Delete requires confirmation",
            provenanceLabel: "SourceRecord / Receipt",
            privacyPolicyLabel: "No silent retention or export",
            permissionLabel: "Future-owned",
            state: snapshot.appState.localOnlyModeEnabled ? .warning : .default,
            accessibilityHint: "Shows the storage boundary row and the current proof gap around protected storage."
        )

        return YouPersonalVaultState(
            title: "Personal Vault",
            subtitle: "Sensitive local signal rows keep storage, export, reset, delete, provenance, privacy, and permission labels visible without hidden inference.",
            sections: [
                YouPersonalVaultSection(
                    id: "personal-vault-signals",
                    title: "Sensitive local signals",
                    subtitle: "Visible rows stay local-first and explainable before stronger policy work lands.",
                    rows: [
                        personalDefaultsRow,
                        learningRow,
                        proofRow
                    ]
                ),
                YouPersonalVaultSection(
                    id: "personal-vault-permissions",
                    title: "Permissions center",
                    subtitle: "Permission rows stay explicit and reviewable instead of implied.",
                    rows: [
                        permissionsRow,
                        storageRow
                    ]
                )
            ],
            footer: "Personal Vault stays local-first, inspectable, and explicit about what is not complete yet. Protected-storage proof, privacy review, and release claims remain unverified here."
        )
    }

    func makePersonalVaultRow(
        id: String,
        kind: YouPersonalVaultRowKind,
        title: String,
        summary: String,
        sourceLabel: String,
        storageLabel: String,
        exportLabel: String,
        resetLabel: String,
        deleteLabel: String,
        provenanceLabel: String,
        privacyPolicyLabel: String,
        permissionLabel: String,
        state: AmbitionVisualState,
        accessibilityHint: String
    ) -> YouPersonalVaultRow {
        let accessibilityValue = [
            storageLabel,
            exportLabel,
            resetLabel,
            deleteLabel,
            provenanceLabel,
            privacyPolicyLabel,
            permissionLabel
        ]
        .joined(separator: ". ")

        return YouPersonalVaultRow(
            id: id,
            kind: kind,
            title: title,
            summary: summary,
            sourceLabel: sourceLabel,
            storageLabel: storageLabel,
            exportLabel: exportLabel,
            resetLabel: resetLabel,
            deleteLabel: deleteLabel,
            provenanceLabel: provenanceLabel,
            privacyPolicyLabel: privacyPolicyLabel,
            permissionLabel: permissionLabel,
            state: state,
            accessibilityLabel: "\(title) personal vault row",
            accessibilityValue: accessibilityValue,
            accessibilityHint: accessibilityHint
        )
    }

    func makeEverythingSearchState(snapshot: Snapshot) -> YouEverythingSearchState {
        let documents = makeEverythingSearchDocuments(snapshot: snapshot)
        let filters = makeEverythingSearchFilters(documents: documents)
        let ordered = documents.sorted { lhs, rhs in
            if lhs.updatedAt != rhs.updatedAt {
                return lhs.updatedAt > rhs.updatedAt
            }
            if lhs.kind.rawValue != rhs.kind.rawValue {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            if lhs.title != rhs.title {
                return lhs.title < rhs.title
            }
            return lhs.id < rhs.id
        }

        let maximumResults = 12
        let candidateCount = documents.count
        let matchedCount = ordered.count
        let returnedCount = min(ordered.count, maximumResults)
        let scannedCount = min(candidateCount, 64)
        let hitPerformanceBudget = candidateCount > maximumResults

        return YouEverythingSearchState(
            title: "Everything Search",
            subtitle: "Find anything local across goals, captures, proof, feedback, teaching, event history, and life context.",
            queryPrompt: "Find anything local",
            filters: filters,
            scannedCandidateCount: scannedCount,
            matchedCandidateCount: matchedCount,
            returnedItemCount: returnedCount,
            hitPerformanceBudget: hitPerformanceBudget,
            performanceBudgetSummary: "Scanned \(scannedCount) local candidates; matched \(matchedCount); returned \(returnedCount) within a 64-candidate / \(maximumResults)-result budget.",
            items: ordered.map { document in
                YouEverythingSearchItem(
                    id: document.id,
                    kind: document.kind,
                    title: document.title,
                    summary: document.summary,
                    sourceLabel: document.sourceLabel,
                    freshness: document.freshness,
                    primaryActions: document.actions,
                    matchedTerms: document.searchableText
                        .split(separator: " ")
                        .prefix(8)
                        .map(String.init),
                    accessibilityLabel: "\(document.kind.title) search result",
                    accessibilityValue: "\(document.sourceLabel). \(document.freshness.label).",
                    accessibilityHint: "Search stays local and inspectable."
                )
            },
            footer: "Search stays local, inspectable, and source-tied. No external service is used."
        )
    }

    func makeEverythingSearchDocuments(snapshot: Snapshot) -> [EverythingSearchDocument] {
        var documents: [EverythingSearchDocument] = []

        documents.append(contentsOf: snapshot.goals.map { goal in
            EverythingSearchDocument(
                id: "goal-\(goal.id)",
                kind: .goal,
                title: goal.title,
                summary: goal.summary ?? goal.mode.displayTitle,
                sourceLabel: "Goals",
                freshness: goal.searchFreshness,
                actions: searchActions(
                    baseID: goal.id,
                    titles: ["Open goal", "Open step", "Inspect proof"],
                    statusLabel: goal.state.rawValue.capitalized,
                    detail: "Open the canonical Goal Detail surface.",
                    state: goal.state == .active ? .success : .default
                ),
                createdAt: goal.createdAt,
                updatedAt: goal.updatedAt,
                searchableText: normalizedSearchText([
                    goal.title,
                    goal.summary ?? "",
                    goal.mode.displayTitle,
                    goal.state.rawValue,
                    goal.tags.joined(separator: " ")
                ])
            )
        })

        documents.append(contentsOf: snapshot.captures.map { capture in
            EverythingSearchDocument(
                id: "capture-\(capture.id)",
                kind: .capture,
                title: capture.rawText,
                summary: capture.assumptionSummary ?? capture.route.title,
                sourceLabel: capture.searchSourceLabel,
                freshness: capture.searchFreshness,
                actions: searchActions(
                    baseID: capture.id,
                    titles: capture.searchPrimaryActionTitles,
                    statusLabel: capture.status.title,
                    detail: capture.searchObjectTypeLabel,
                    state: capture.status == .archived ? .default : .success
                ),
                createdAt: capture.createdAt,
                updatedAt: capture.updatedAt,
                searchableText: normalizedSearchText([
                    capture.rawText,
                    capture.assumptionSummary ?? "",
                    capture.searchObjectTypeLabel,
                    capture.searchSourceLabel,
                    capture.status.title,
                    capture.route.title,
                    capture.kind.title,
                    capture.linkedGoalID ?? "",
                    capture.recommendationExplanationIDs.joined(separator: " ")
                ])
            )
        })

        documents.append(contentsOf: snapshot.evidence.map { evidence in
            EverythingSearchDocument(
                id: "evidence-\(evidence.id)",
                kind: .proof,
                title: evidence.note ?? "Progress evidence",
                summary: evidence.evidenceKind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                sourceLabel: "Proof",
                freshness: .current,
                actions: searchActions(
                    baseID: evidence.id,
                    titles: ["Open proof", "Open goal", "Inspect receipt"],
                    statusLabel: evidence.source.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                    detail: "Proof remains local and inspectable.",
                    state: .success
                ),
                createdAt: evidence.capturedAt,
                updatedAt: evidence.capturedAt,
                searchableText: normalizedSearchText([
                    evidence.note ?? "",
                    evidence.evidenceKind.rawValue,
                    evidence.source.rawValue,
                    evidence.goalID,
                    evidence.stepID ?? ""
                ])
            )
        })

        documents.append(contentsOf: snapshot.feedback.map { event in
            EverythingSearchDocument(
                id: "feedback-\(event.base.id)",
                kind: .feedback,
                title: event.searchTitle,
                summary: event.searchSummary,
                sourceLabel: "Feedback",
                freshness: event.searchFreshness,
                actions: searchActions(
                    baseID: event.base.id,
                    titles: ["Open review", "Correct assumption", "Inspect receipt"],
                    statusLabel: event.kind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                    detail: "Feedback stays tied to the owning goal surface.",
                    state: .success
                ),
                createdAt: event.base.occurredAt,
                updatedAt: event.base.occurredAt,
                searchableText: normalizedSearchText([
                    event.searchTitle,
                    event.searchSummary,
                    event.kind.rawValue,
                    event.base.note ?? "",
                    event.stepID,
                    event.base.id
                ])
            )
        })

        documents.append(contentsOf: snapshot.teachingSignals.map { signal in
            EverythingSearchDocument(
                id: "teaching-\(signal.id)",
                kind: .teaching,
                title: signal.userNote ?? signal.kind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                summary: signal.source.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                sourceLabel: "Teaching",
                freshness: signal.disposition == .active ? .mayNeedReview : .basedOnOlderContext,
                actions: searchActions(
                    baseID: signal.id,
                    titles: ["Inspect correction", "Use owning surface", "Reject reuse"],
                    statusLabel: signal.disposition.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                    detail: "Teaching stays source-tied and reviewable.",
                    state: signal.disposition == .active ? .warning : .default
                ),
                createdAt: signal.createdAt,
                updatedAt: signal.updatedAt,
                searchableText: normalizedSearchText([
                    signal.userNote ?? "",
                    signal.kind.rawValue,
                    signal.source.rawValue,
                    signal.goalID,
                    signal.applicationKey,
                    signal.anchor.normalizedIdentity
                ])
            )
        })

        documents.append(contentsOf: snapshot.eventLedger.map { event in
            EverythingSearchDocument(
                id: "event-\(event.id)",
                kind: .eventLedger,
                title: event.title,
                summary: event.summary ?? event.kind.rawValue.replacingOccurrences(of: "_", with: " "),
                sourceLabel: "Event Ledger",
                freshness: event.localOnly ? .current : .mayNeedReview,
                actions: searchActions(
                    baseID: event.id,
                    titles: ["Inspect event", "Open source", "Open receipt"],
                    statusLabel: event.source.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                    detail: "Recent local actions and changes stay inspectable.",
                    state: event.localOnly ? .success : .warning
                ),
                createdAt: event.occurredAt,
                updatedAt: event.updatedAt,
                searchableText: normalizedSearchText([
                    event.title,
                    event.summary ?? "",
                    event.kind.rawValue,
                    event.source.rawValue,
                    event.goalID ?? "",
                    event.captureID ?? "",
                    event.planID ?? "",
                    event.reviewID ?? ""
                ])
            )
        })

        documents.append(contentsOf: snapshot.lifeContextBundles.filter { $0.isDeleted == false }.map { bundle in
            EverythingSearchDocument(
                id: "life-context-\(bundle.id)",
                kind: .lifeContext,
                title: lifeContextDisplayTitle(for: bundle.profile),
                summary: lifeContextDisplaySummary(for: bundle.profile),
                sourceLabel: "Life Context",
                freshness: bundle.historicalFacts.contains(where: { $0.isDeletedOrPaused }) ? .mayNeedReview : .current,
                actions: searchActions(
                    baseID: bundle.id,
                    titles: ["Open fact", "Edit", "Pause use"],
                    statusLabel: bundle.historicalFacts.count == 0 ? "Empty" : "\(bundle.historicalFacts.count) facts",
                    detail: "Life context stays local and editable through You.",
                    state: bundle.historicalFacts.isEmpty ? .default : .success
                ),
                createdAt: bundle.createdAt,
                updatedAt: bundle.updatedAt,
                searchableText: normalizedSearchText([
                    lifeContextDisplayTitle(for: bundle.profile),
                    lifeContextDisplaySummary(for: bundle.profile),
                    bundle.historicalFacts.map(\.title).joined(separator: " "),
                    bundle.historicalFacts.compactMap(\.detail).joined(separator: " "),
                    bundle.sources.map(\.label).joined(separator: " "),
                    bundle.eligibilityPathways.map(\.eligibilityRulesSummary).joined(separator: " ")
                ])
            )
        })

        return documents
    }

    func makeEverythingSearchFilters(documents: [EverythingSearchDocument]) -> [SettingsItem] {
        let countsByKind = Dictionary(grouping: documents, by: \.kind).mapValues(\.count)

        return [
            SettingsItem(
                id: "search-filter-goals",
                title: "Goals",
                subtitle: "Goal threads and canonical steps",
                icon: "target",
                valueLabel: "\(countsByKind[.goal, default: 0])"
            ),
            SettingsItem(
                id: "search-filter-captures",
                title: "Captures",
                subtitle: "Open captures and route previews",
                icon: "tray.full",
                valueLabel: "\(countsByKind[.capture, default: 0])"
            ),
            SettingsItem(
                id: "search-filter-proof",
                title: "Proof",
                subtitle: "Evidence and receipts",
                icon: "checkmark.seal",
                valueLabel: "\(countsByKind[.proof, default: 0])"
            ),
            SettingsItem(
                id: "search-filter-feedback",
                title: "Feedback",
                subtitle: "Corrections and review signals",
                icon: "bubble.left.and.bubble.right",
                valueLabel: "\(countsByKind[.feedback, default: 0])"
            ),
            SettingsItem(
                id: "search-filter-teaching",
                title: "Teaching",
                subtitle: "Local learning signals",
                icon: "slider.horizontal.3",
                valueLabel: "\(countsByKind[.teaching, default: 0])"
            ),
            SettingsItem(
                id: "search-filter-event-ledger",
                title: "Event Ledger",
                subtitle: "Recent local actions",
                icon: "list.bullet.rectangle",
                valueLabel: "\(countsByKind[.eventLedger, default: 0])"
            ),
            SettingsItem(
                id: "search-filter-life-context",
                title: "Life Context",
                subtitle: "Facts and eligibility context",
                icon: "map",
                valueLabel: "\(countsByKind[.lifeContext, default: 0])"
            )
        ]
    }

    func searchActions(
        baseID: String,
        titles: [String],
        statusLabel: String,
        detail: String,
        state: AmbitionVisualState
    ) -> [YouEverythingSearchAction] {
        titles.enumerated().map { index, title in
            YouEverythingSearchAction(
                id: "\(baseID).\(index)",
                title: title,
                statusLabel: statusLabel,
                detail: detail,
                state: state
            )
        }
    }

    func normalizedSearchText(_ values: [String]) -> String {
        values
            .joined(separator: " ")
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9]+"#, with: " ", options: .regularExpression)
    }

    func makeSourceAtlasKnowledgeState(snapshot: Snapshot) -> YouSourceAtlasKnowledgeState {
        YouSourceAtlasKnowledgeState(
            title: "Source Atlas & Goal Knowledge",
            subtitle: "What Ambitions used, why it used it, and where review or correction stays supported.",
            sections: [
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-goal-knowledge-sources",
                    title: "Goal Knowledge Sources",
                    subtitle: "What Ambitions reads before it shapes goal knowledge or a step path.",
                    rows: makeGoalKnowledgeSourceRows(snapshot: snapshot),
                    footer: "These rows stay local and inspectable. They do not imply a hidden profile or remote model."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-active-source-packs",
                    title: "Active Source Packs",
                    subtitle: "Local source bundles that are currently able to influence planning.",
                    rows: makeActiveSourcePackRows(snapshot: snapshot),
                    footer: "Active means the bundle can still affect local planning. It is not a claim of official coverage."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-needs-review",
                    title: "Needs Review",
                    subtitle: "Source areas that should not be treated as settled yet.",
                    rows: makeNeedsReviewRows(snapshot: snapshot),
                    footer: "Review paths stay visible so unsupported or stale context does not look complete."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-unsupported-goal-areas",
                    title: "Unsupported Goal Areas",
                    subtitle: "Goal areas that currently lack enough source to drive a safe path.",
                    rows: makeUnsupportedGoalAreaRows(snapshot: snapshot),
                    footer: "Unsupported does not mean blocked forever. It means this surface should show the gap."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-recent-goal-compilations",
                    title: "Recent Goal Compilations",
                    subtitle: "Recent compile output that can be inspected without turning You into a console.",
                    rows: makeRecentGoalCompilationRows(snapshot: snapshot),
                    footer: "Recent compilations stay local and reviewable through the owning goal surface."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-path-sources",
                    title: "Path Sources",
                    subtitle: "Source bundles that describe the path shape before a step is picked.",
                    rows: makePathSourceRows(snapshot: snapshot),
                    footer: "Path sources are a preview of the current route, not a silent plan change."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-step-sources",
                    title: "Step Sources",
                    subtitle: "Individual step-level sources and why they were used or rejected.",
                    rows: makeStepSourceRows(snapshot: snapshot),
                    footer: "Steps stay tied to their owning goal or draft and keep correction paths visible."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-corrections",
                    title: "Corrections",
                    subtitle: "Local correction signals that can change future goal knowledge.",
                    rows: makeSourceAtlasCorrectionRows(snapshot: snapshot),
                    footer: "Corrections stay reviewable from the owning goal or capture surface."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-replay-receipts",
                    title: "Replay Receipts",
                    subtitle: "Replay receipts that explain the current Source Atlas bridge posture.",
                    rows: makeReplayReceiptRows(snapshot: snapshot),
                    footer: "Replay receipts are local and inspectable. They are not a release claim."
                )
            ],
            footer: "Goal Knowledge stays local-first, inspectable, and correction-aware."
        )
    }

    func makeGoalKnowledgeSourceRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let activeGoals = snapshot.goals.filter { $0.state == .active }
        let blockedDraftCount = snapshot.drafts.filter { $0.latestResultKind == .blocked }.count
        let clarificationCount = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }.count
        let hasEvidence = snapshot.evidence.isEmpty == false || snapshot.feedback.isEmpty == false
        let hasEventLedger = snapshot.eventLedger.isEmpty == false
        let hasLifeContext = snapshot.lifeContextBundles.isEmpty == false

        return [
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-goals",
                icon: "target",
                title: "Goals repository",
                usedWhat: activeGoals.isEmpty ? "No active goals yet." : "\(activeGoals.count) active goals, \(snapshot.goals.count) total goals",
                whyUsed: "Used to keep goal knowledge tied to the user-owned goal graph instead of a hidden profile.",
                sourceName: "Goals",
                sourceState: activeGoals.isEmpty ? .sourceNeeded : .locallyProven,
                freshnessState: activeGoals.isEmpty ? .unknown : .current,
                riskState: activeGoals.isEmpty ? .medium : .low,
                runtimeUseState: activeGoals.isEmpty ? .notUsed : .usedToPlan,
                needsReview: activeGoals.isEmpty,
                correctionPath: "Open Goal Detail > Edit Goal",
                reviewPath: "Open Goal Detail > Review Goal",
                iconState: activeGoals.isEmpty ? .warning : .selected
            ),
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-drafts",
                icon: "square.and.pencil",
                title: "Drafts and staged plans",
                usedWhat: snapshot.drafts.isEmpty ? "No draft compilations yet." : "\(snapshot.drafts.count) drafts, \(snapshot.drafts.filter { $0.stagedPlan != nil }.count) staged plans",
                whyUsed: "Used to explain which drafts can become steps and which ones still need review.",
                sourceName: "Goal drafts",
                sourceState: snapshot.drafts.isEmpty ? .sourceNeeded : .current,
                freshnessState: snapshot.drafts.isEmpty ? .unknown : .current,
                riskState: blockedDraftCount > 0 || clarificationCount > 0 ? .medium : .low,
                runtimeUseState: snapshot.drafts.contains(where: { $0.stagedPlan != nil && $0.latestResultKind != .blocked }) ? .usedToPlan : .notUsed,
                needsReview: blockedDraftCount > 0 || clarificationCount > 0 || snapshot.drafts.isEmpty,
                correctionPath: "Open Goal Detail > Correct Draft",
                reviewPath: "Open Goal Detail > Recompile",
                iconState: blockedDraftCount > 0 ? .warning : .default
            ),
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-evidence",
                icon: "checkmark.seal",
                title: "Evidence and feedback",
                usedWhat: hasEvidence ? "\(snapshot.evidence.count) evidence records, \(snapshot.feedback.count) feedback events" : "No evidence or feedback yet.",
                whyUsed: "Used to avoid intention-only planning and to keep recommendations grounded in proof.",
                sourceName: "Evidence",
                sourceState: hasEvidence ? .locallyProven : .sourceNeeded,
                freshnessState: hasEvidence ? .current : .unknown,
                riskState: hasEvidence ? .low : .medium,
                runtimeUseState: hasEvidence ? .usedToPlan : .notUsed,
                needsReview: hasEvidence == false,
                correctionPath: "Open Goal Detail > Add Evidence",
                reviewPath: "Open Goal Detail > Review Evidence",
                iconState: hasEvidence ? .selected : .warning
            ),
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-captures",
                icon: "tray.full",
                title: "Captures",
                usedWhat: snapshot.captures.isEmpty ? "No open captures." : "\(snapshot.captures.filter { $0.status != .archived }.count) open captures, \(snapshot.captures.count) total captures",
                whyUsed: "Used to surface unresolved intent and keep the capture queue visible to planning.",
                sourceName: "Capture",
                sourceState: snapshot.captures.isEmpty ? .sourceNeeded : .current,
                freshnessState: snapshot.captures.isEmpty ? .unknown : .current,
                riskState: snapshot.captures.contains(where: { $0.status != .archived }) ? .medium : .low,
                runtimeUseState: snapshot.captures.contains(where: { $0.status != .archived }) ? .usedToPlan : .notUsed,
                needsReview: snapshot.captures.contains(where: { $0.status != .archived }) || snapshot.captures.isEmpty,
                correctionPath: "Open Capture > Route Capture",
                reviewPath: "Open Capture > Review Capture",
                iconState: snapshot.captures.contains(where: { $0.status != .archived }) ? .selected : .default
            ),
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-teaching",
                icon: "bubble.left.and.bubble.right",
                title: "Teaching signals",
                usedWhat: snapshot.teachingSignals.isEmpty ? "No teaching signals yet." : "\(snapshot.teachingSignals.count) teaching signals",
                whyUsed: "Used to correct explanation language and keep future goal knowledge source-tied.",
                sourceName: "Corrections",
                sourceState: snapshot.teachingSignals.isEmpty ? .sourceNeeded : .locallyProven,
                freshnessState: snapshot.teachingSignals.isEmpty ? .unknown : .current,
                riskState: snapshot.teachingSignals.isEmpty ? .medium : .low,
                runtimeUseState: snapshot.teachingSignals.isEmpty ? .notUsed : .usedToPlan,
                needsReview: snapshot.teachingSignals.isEmpty,
                correctionPath: "Open Goal Detail > Save Teaching",
                reviewPath: "Open Goal Detail > Review Teaching",
                iconState: snapshot.teachingSignals.isEmpty ? .warning : .selected
            ),
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-ledger",
                icon: "list.bullet.rectangle",
                title: "Event ledger",
                usedWhat: hasEventLedger ? "\(snapshot.eventLedger.count) recent ledger entries" : "No recent ledger entries.",
                whyUsed: "Used to explain what changed and to keep replay evidence local.",
                sourceName: "Event Ledger",
                sourceState: hasEventLedger ? .locallyProven : .sourceNeeded,
                freshnessState: hasEventLedger ? .current : .unknown,
                riskState: hasEventLedger ? .low : .medium,
                runtimeUseState: hasEventLedger ? .usedToPlan : .notUsed,
                needsReview: hasEventLedger == false,
                correctionPath: "Open Goal Detail > Review History",
                reviewPath: "Open Goal Detail > Replay History",
                iconState: hasEventLedger ? .selected : .default
            ),
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-life-context",
                icon: "person.2",
                title: "Life context bundles",
                usedWhat: hasLifeContext ? "\(snapshot.lifeContextBundles.count) local context bundle(s)" : "No life context bundle yet.",
                whyUsed: "Used to fit goals to the user's real life before a path or step is accepted.",
                sourceName: "Life Context",
                sourceState: hasLifeContext ? .locallyProven : .sourceNeeded,
                freshnessState: hasLifeContext ? .current : .unknown,
                riskState: hasLifeContext ? .medium : .unknown,
                runtimeUseState: hasLifeContext ? .usedToPlan : .notUsed,
                needsReview: hasLifeContext == false,
                correctionPath: "Open Life Context > Correct Facts",
                reviewPath: "Open Life Context > Review Context",
                iconState: hasLifeContext ? .selected : .warning
            )
        ]
    }

    func makeActiveSourcePackRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let activeGoals = snapshot.goals.filter { $0.state == .active }
        let goalsWithPlans = snapshot.goals.filter { $0.plan != nil }
        let totalPlannedSteps = goalsWithPlans.flatMap { $0.plan?.sections ?? [] }.flatMap(\.steps).count

        return [
            makeSourceAtlasKnowledgeRow(
                id: "pack-goals",
                icon: "scope",
                title: "Goal source pack",
                usedWhat: activeGoals.isEmpty ? "No active goal pack yet." : "\(activeGoals.count) active goals feed the pack",
                whyUsed: "Used to keep the current goal set available for planning and review.",
                sourceName: "Goals + plans",
                sourceState: activeGoals.isEmpty ? .sourceNeeded : .locallyProven,
                freshnessState: activeGoals.isEmpty ? .unknown : .current,
                riskState: activeGoals.isEmpty ? .medium : .low,
                runtimeUseState: activeGoals.isEmpty ? .notUsed : .usedToPlan,
                needsReview: activeGoals.isEmpty,
                correctionPath: "Open Goals > Edit Pack",
                reviewPath: "Open Goals > Review Pack",
                iconState: activeGoals.isEmpty ? .warning : .selected
            ),
            makeSourceAtlasKnowledgeRow(
                id: "pack-paths",
                icon: "arrow.triangle.branch",
                title: "Path source pack",
                usedWhat: goalsWithPlans.isEmpty ? "No path pack yet." : "\(goalsWithPlans.count) goals with plans",
                whyUsed: "Used to keep the path shape visible before a step is accepted.",
                sourceName: "Goal plans",
                sourceState: goalsWithPlans.isEmpty ? .sourceNeeded : .locallyProven,
                freshnessState: goalsWithPlans.isEmpty ? .unknown : .current,
                riskState: goalsWithPlans.isEmpty ? .medium : .low,
                runtimeUseState: goalsWithPlans.isEmpty ? .notUsed : .usedToPlan,
                needsReview: goalsWithPlans.isEmpty,
                correctionPath: "Open Goal Detail > Edit Path",
                reviewPath: "Open Goal Detail > Review Path",
                iconState: goalsWithPlans.isEmpty ? .warning : .selected
            ),
            makeSourceAtlasKnowledgeRow(
                id: "pack-steps",
                icon: "checklist",
                title: "Step source pack",
                usedWhat: totalPlannedSteps == 0 ? "No step pack yet." : "\(totalPlannedSteps) planned step(s)",
                whyUsed: "Used to keep step-level planning local and inspectable.",
                sourceName: "Plan steps",
                sourceState: totalPlannedSteps == 0 ? .sourceNeeded : .locallyProven,
                freshnessState: totalPlannedSteps == 0 ? .unknown : .current,
                riskState: totalPlannedSteps == 0 ? .medium : .low,
                runtimeUseState: totalPlannedSteps == 0 ? .notUsed : .usedToPlan,
                needsReview: totalPlannedSteps == 0,
                correctionPath: "Open Goal Detail > Edit Steps",
                reviewPath: "Open Goal Detail > Review Steps",
                iconState: totalPlannedSteps == 0 ? .warning : .selected
            ),
            makeSourceAtlasKnowledgeRow(
                id: "pack-replay",
                icon: "arrow.clockwise",
                title: "Replay source pack",
                usedWhat: snapshot.eventLedger.isEmpty ? "No replay pack yet." : "\(snapshot.eventLedger.count) replayable local event(s)",
                whyUsed: "Used to explain the current bridge receipt and replay posture.",
                sourceName: "Replay receipts",
                sourceState: snapshot.eventLedger.isEmpty ? .sourceNeeded : .locallyProven,
                freshnessState: snapshot.eventLedger.isEmpty ? .unknown : .current,
                riskState: snapshot.eventLedger.isEmpty ? .medium : .low,
                runtimeUseState: snapshot.eventLedger.isEmpty ? .notUsed : .usedToPlan,
                needsReview: snapshot.eventLedger.isEmpty,
                correctionPath: "Open Receipts > Correct Replay",
                reviewPath: "Open Receipts > Review Replay",
                iconState: snapshot.eventLedger.isEmpty ? .warning : .selected
            )
        ]
    }

    func makeNeedsReviewRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let blockedDraftCount = snapshot.drafts.filter { $0.latestResultKind == .blocked }.count
        let clarificationCount = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }.count
        let goalsWithoutPlans = snapshot.goals.filter { $0.plan == nil && $0.state == .active }.count
        let staleSignals = snapshot.eventLedger.isEmpty || snapshot.evidence.isEmpty

        var rows: [YouSourceAtlasKnowledgeRow] = []

        if blockedDraftCount > 0 {
            rows.append(
                makeSourceAtlasKnowledgeRow(
                    id: "review-blocked-drafts",
                    icon: "exclamationmark.triangle",
                    title: "Blocked drafts",
                    usedWhat: "\(blockedDraftCount) blocked draft(s)",
                    whyUsed: "These drafts need review before they can become a source-backed path.",
                    sourceName: "Drafts",
                    sourceState: .sourceNeeded,
                    freshnessState: .stale,
                    riskState: .medium,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Goal Detail > Fix Draft",
                    reviewPath: "Open Goal Detail > Review Blocker",
                    iconState: .warning
                )
            )
        }

        if clarificationCount > 0 {
            rows.append(
                makeSourceAtlasKnowledgeRow(
                    id: "review-clarifications",
                    icon: "questionmark.circle",
                    title: "Clarification needed",
                    usedWhat: "\(clarificationCount) draft(s) still need an answer",
                    whyUsed: "Clarification keeps source use honest instead of guessing.",
                    sourceName: "Draft clarifications",
                    sourceState: .sourceNeeded,
                    freshnessState: .unknown,
                    riskState: .medium,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Goal Detail > Answer Question",
                    reviewPath: "Open Goal Detail > Recompile",
                    iconState: .warning
                )
            )
        }

        if goalsWithoutPlans > 0 {
            rows.append(
                makeSourceAtlasKnowledgeRow(
                    id: "review-goals-without-plans",
                    icon: "circle.dashed",
                    title: "Goals without plans",
                    usedWhat: "\(goalsWithoutPlans) active goal(s) have no plan yet",
                    whyUsed: "Goal knowledge stays incomplete until a plan or source pack exists.",
                    sourceName: "Goals",
                    sourceState: .sourceNeeded,
                    freshnessState: .unknown,
                    riskState: .high,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Goal Detail > Add Plan",
                    reviewPath: "Open Goal Detail > Review Goal",
                    iconState: .warning
                )
            )
        }

        if staleSignals {
            rows.append(
                makeSourceAtlasKnowledgeRow(
                    id: "review-stale-signals",
                    icon: "clock.arrow.circlepath",
                    title: "Stale local signals",
                    usedWhat: snapshot.eventLedger.isEmpty ? "No ledger replay yet." : "Evidence or ledger freshness needs another check.",
                    whyUsed: "This row stays visible when the local proof chain is still thin.",
                    sourceName: "Evidence / ledger",
                    sourceState: .stale,
                    freshnessState: .stale,
                    riskState: .medium,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Receipts > Refresh Evidence",
                    reviewPath: "Open Receipts > Review Freshness",
                    iconState: .warning
                )
            )
        }

        if rows.isEmpty {
            rows.append(
                makeSourceAtlasKnowledgeRow(
                    id: "review-none",
                    icon: "checkmark.seal",
                    title: "No current review gaps",
                    usedWhat: "No source area currently needs review.",
                    whyUsed: "The section stays visible so review gaps do not disappear from You.",
                    sourceName: "Local source atlas",
                    sourceState: .current,
                    freshnessState: .current,
                    riskState: .low,
                    runtimeUseState: .notUsed,
                    needsReview: false,
                    correctionPath: "Open Goal Detail > Correct If Needed",
                    reviewPath: "Open Goal Detail > Review Later",
                    iconState: .success
                )
            )
        }

        return rows
    }

    func makeUnsupportedGoalAreaRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let unsupportedGoals = snapshot.goals
            .filter { $0.plan == nil && $0.state != .archived }
            .sorted(by: goalSourceOrdering)

        if unsupportedGoals.isEmpty {
            return [
                makeSourceAtlasKnowledgeRow(
                    id: "unsupported-none",
                    icon: "checkmark.shield",
                    title: "No unsupported goal areas",
                    usedWhat: "All visible goal areas have a usable local source path.",
                    whyUsed: "This section stays visible so unsupported areas would be obvious if they appear.",
                    sourceName: "Goal knowledge",
                    sourceState: .current,
                    freshnessState: .current,
                    riskState: .low,
                    runtimeUseState: .usedToPlan,
                    needsReview: false,
                    correctionPath: "Open Goal Detail > No Correction Needed",
                    reviewPath: "Open Goal Detail > Review Later",
                    iconState: .selected
                )
            ]
        }

        return unsupportedGoals.prefix(3).map { goal in
            makeSourceAtlasKnowledgeRow(
                id: "unsupported-\(goal.id)",
                icon: "slash.circle",
                title: goal.title,
                usedWhat: goal.summary ?? "No summary recorded.",
                whyUsed: "This goal area still needs a source-backed plan before it can drive a safe path.",
                sourceName: "Goal \(goal.mode.rawValue.replacingOccurrences(of: "_", with: " "))",
                sourceState: .sourceNeeded,
                freshnessState: .unknown,
                riskState: .high,
                runtimeUseState: .notUsed,
                needsReview: true,
                correctionPath: "Open Goal Detail > Add Source",
                reviewPath: "Open Goal Detail > Rebuild Path",
                iconState: .warning
            )
        }
    }

    func makeRecentGoalCompilationRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let recentDrafts = snapshot.drafts.sorted {
            if $0.updatedAt != $1.updatedAt {
                return $0.updatedAt > $1.updatedAt
            }
            return $0.id > $1.id
        }.prefix(3)

        if recentDrafts.isEmpty {
            return [
                makeSourceAtlasKnowledgeRow(
                    id: "compilation-none",
                    icon: "rectangle.stack",
                    title: "No recent compilations yet",
                    usedWhat: "No draft compilation exists to inspect yet.",
                    whyUsed: "This row stays visible so the missing compiler output is explicit.",
                    sourceName: "Goal compiler",
                    sourceState: .sourceNeeded,
                    freshnessState: .unknown,
                    riskState: .medium,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Goals > Create Draft",
                    reviewPath: "Open Goals > Review Setup",
                    iconState: .warning
                )
            ]
        }

        return recentDrafts.map { draft in
            let hasPlan = draft.stagedPlan != nil
            return makeSourceAtlasKnowledgeRow(
                id: "compilation-\(draft.id)",
                icon: "rectangle.stack.badge.plus",
                title: draft.draft.title,
                usedWhat: draft.stagedPlan?.summary ?? draft.draft.summary ?? "No plan summary recorded.",
                whyUsed: hasPlan ? "Used to compile a source-backed plan for the next step path." : "This draft needs more source before it can become a step path.",
                sourceName: "Drafts",
                sourceState: hasPlan ? .locallyProven : .sourceNeeded,
                freshnessState: hasPlan ? .current : .unknown,
                riskState: hasPlan ? .low : .medium,
                runtimeUseState: hasPlan ? .usedToPlan : .notUsed,
                needsReview: draft.latestResultKind != nil || hasPlan == false,
                correctionPath: "Open Goal Detail > Correct Draft",
                reviewPath: "Open Goal Detail > Review Compilation",
                iconState: hasPlan ? .selected : .warning
            )
        }
    }

    func makePathSourceRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let plannedGoals = snapshot.goals
            .filter { $0.plan != nil }
            .sorted(by: goalSourceOrdering)
        let sections = plannedGoals.flatMap { goal -> [(goal: Goal, section: PlanSection)] in
            guard let plan = goal.plan else { return [] }
            return plan.sections
                .sorted(by: planSectionOrdering)
                .map { (goal, $0) }
        }.prefix(3)

        if sections.isEmpty {
            return [
                makeSourceAtlasKnowledgeRow(
                    id: "path-source-none",
                    icon: "arrow.triangle.branch",
                    title: "No path sources yet",
                    usedWhat: "No plan section is available to inspect.",
                    whyUsed: "The path source surface stays visible so missing route source is explicit.",
                    sourceName: "Goal plans",
                    sourceState: .sourceNeeded,
                    freshnessState: .unknown,
                    riskState: .medium,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Goal Detail > Add Path",
                    reviewPath: "Open Goal Detail > Review Path",
                    iconState: .warning
                )
            ]
        }

        return sections.map { goal, section in
            makeSourceAtlasKnowledgeRow(
                id: "path-source-\(goal.id)-\(section.id)",
                icon: "arrow.triangle.branch",
                title: "\(goal.title) / \(section.title)",
                usedWhat: section.summary ?? "\(section.steps.count) step(s)",
                whyUsed: "Used to shape the path before step-level source is chosen.",
                sourceName: goal.title,
                sourceState: .locallyProven,
                freshnessState: .current,
                riskState: section.steps.contains(where: { $0.evidenceRequired }) ? .medium : .low,
                runtimeUseState: .usedToPlan,
                needsReview: false,
                correctionPath: "Open Goal Detail > Edit Path",
                reviewPath: "Open Goal Detail > Review Path",
                iconState: .selected
            )
        }
    }

    func makeStepSourceRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let steps = snapshot.goals
            .sorted(by: goalSourceOrdering)
            .flatMap { goal -> [(goal: Goal, section: PlanSection, step: Step)] in
                guard let plan = goal.plan else { return [] }
                return plan.sections
                    .sorted(by: planSectionOrdering)
                    .flatMap { section in
                        section.steps
                            .sorted(by: stepSourceOrdering)
                            .map { step in (goal: goal, section: section, step: step) }
                    }
            }
            .prefix(4)

        if steps.isEmpty {
            return [
                makeSourceAtlasKnowledgeRow(
                    id: "step-source-none",
                    icon: "checklist",
                    title: "No step sources yet",
                    usedWhat: "No step has source detail yet.",
                    whyUsed: "This row stays visible so step source gaps remain obvious.",
                    sourceName: "Plan steps",
                    sourceState: .sourceNeeded,
                    freshnessState: .unknown,
                    riskState: .medium,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Goal Detail > Add Step",
                    reviewPath: "Open Goal Detail > Review Steps",
                    iconState: .warning
                )
            ]
        }

        return steps.map { source in
            let step = source.step
            let isActive = step.state == .active || step.state == .planned
            let reviewNeeded = step.state == .blocked || step.evidenceRequired
            return makeSourceAtlasKnowledgeRow(
                id: "step-source-\(step.id)",
                icon: "checklist",
                title: step.title,
                usedWhat: step.summary ?? step.type.rawValue.replacingOccurrences(of: "_", with: " "),
                whyUsed: step.evidenceRequired ? "Used because this step needs proof-aware planning." : "Used to keep the current step path concrete.",
                sourceName: "\(source.goal.title) / \(source.section.title)",
                sourceState: isActive ? .current : .locallyProven,
                freshnessState: step.state == .blocked ? .stale : .current,
                riskState: step.evidenceRequired || step.state == .blocked ? .medium : .low,
                runtimeUseState: isActive ? .usedToPlan : .notUsed,
                needsReview: reviewNeeded,
                correctionPath: "Open Goal Detail > Edit Step",
                reviewPath: "Open Goal Detail > Review Step",
                iconState: reviewNeeded ? .warning : .selected
            )
        }
    }

    func makeSourceAtlasCorrectionRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let correctionCount = snapshot.teachingSignals.count
        let feedbackCount = snapshot.feedback.count

        return [
            makeSourceAtlasKnowledgeRow(
                id: "correction-teaching",
                icon: "bubble.left.and.bubble.right",
                title: "Teaching signals",
                usedWhat: correctionCount == 0 ? "No correction signal yet." : "\(correctionCount) teaching signal(s)",
                whyUsed: "Used to correct future explanations where the user already taught Ambitions better context.",
                sourceName: "Teaching",
                sourceState: correctionCount == 0 ? .sourceNeeded : .locallyProven,
                freshnessState: correctionCount == 0 ? .unknown : .current,
                riskState: correctionCount == 0 ? .medium : .low,
                runtimeUseState: correctionCount == 0 ? .notUsed : .usedToPlan,
                needsReview: correctionCount == 0,
                correctionPath: "Open Goal Detail > Save Teaching",
                reviewPath: "Open Goal Detail > Review Teaching",
                iconState: correctionCount == 0 ? .warning : .selected
            ),
            makeSourceAtlasKnowledgeRow(
                id: "correction-feedback",
                icon: "checkmark.bubble",
                title: "Feedback events",
                usedWhat: feedbackCount == 0 ? "No feedback event yet." : "\(feedbackCount) feedback event(s)",
                whyUsed: "Used to keep correction language and goal knowledge honest after execution.",
                sourceName: "Feedback",
                sourceState: feedbackCount == 0 ? .sourceNeeded : .locallyProven,
                freshnessState: feedbackCount == 0 ? .unknown : .current,
                riskState: feedbackCount == 0 ? .medium : .low,
                runtimeUseState: feedbackCount == 0 ? .notUsed : .usedToPlan,
                needsReview: feedbackCount == 0,
                correctionPath: "Open Goal Detail > Add Feedback",
                reviewPath: "Open Goal Detail > Review Feedback",
                iconState: feedbackCount == 0 ? .warning : .selected
            )
        ]
    }

    func makeReplayReceiptRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let receipts = makeSourceAtlasReplayReceipts(snapshot: snapshot)

        return receipts.map { receipt in
            let reviewNeeded = receipt.kind == .sourceAtlasPackRejected || receipt.kind == .sourceAtlasFreshnessBlocked || receipt.kind == .sourceAtlasUnsupportedGoalFallback
            return makeSourceAtlasKnowledgeRow(
                id: "receipt-\(receipt.id)",
                icon: "arrow.clockwise",
                title: sourceAtlasReceiptTitle(for: receipt.kind),
                usedWhat: receipt.summary,
                whyUsed: receipt.details.isEmpty ? "Replay receipts stay visible so the bridge path can be checked." : receipt.details.joined(separator: " · "),
                sourceName: "Replay receipt",
                sourceState: .locallyProven,
                freshnessState: .current,
                riskState: reviewNeeded ? .medium : .low,
                runtimeUseState: reviewNeeded ? .notUsed : .usedToPlan,
                needsReview: reviewNeeded,
                correctionPath: "Open Receipts > Correct Replay",
                reviewPath: "Open Receipts > Review Replay",
                iconState: reviewNeeded ? .warning : .selected
            )
        }
    }

    func sourceAtlasReceiptTitle(for kind: SourceAtlasBridgeReceiptKind) -> String {
        switch kind {
        case .sourceAtlasIntentMatched:
            return "Intent matched"
        case .sourceAtlasPackSelected:
            return "Pack selected"
        case .sourceAtlasPackRejected:
            return "Pack rejected"
        case .sourceAtlasPathComposed:
            return "Path composed"
        case .sourceAtlasPathRejected:
            return "Path rejected"
        case .sourceAtlasStepCandidatesExpanded:
            return "Step candidates expanded"
        case .sourceAtlasUnsupportedGoalFallback:
            return "Unsupported goal fallback"
        case .sourceAtlasFreshnessBlocked:
            return "Freshness blocked"
        case .sourceAtlasUserCorrectionApplied:
            return "User correction applied"
        case .sourceAtlasReplayGenerated:
            return "Replay generated"
        }
    }

    func makeSourceAtlasReplayReceipts(snapshot: Snapshot) -> [SourceAtlasBridgeReceipt] {
        let generatedAt = snapshot.eventLedger.first?.occurredAt ?? "local.now"
        let goalIDs = snapshot.goals.map(\.id)
        let draftIDs = snapshot.drafts.map(\.id)
        let stepCount = snapshot.goals.compactMap(\.plan).flatMap(\.sections).flatMap(\.steps).count
        let hasEvidence = snapshot.evidence.isEmpty == false || snapshot.feedback.isEmpty == false
        let activeGoals = snapshot.goals.filter { $0.state == .active }
        let packCount = max(activeGoals.count, snapshot.drafts.count)

        return [
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasIntentMatched,
                recordedAt: generatedAt,
                summary: "Goal knowledge matched the current local source set.",
                details: [
                    "goal-count=\(snapshot.goals.count)",
                    "draft-count=\(snapshot.drafts.count)",
                    "evidence-count=\(snapshot.evidence.count)",
                    "feedback-count=\(snapshot.feedback.count)"
                ],
                relatedIDs: goalIDs + draftIDs
            ),
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasPackSelected,
                recordedAt: generatedAt,
                summary: "Local source packs stayed selected for planning.",
                details: [
                    "active-goals=\(activeGoals.count)",
                    "pack-count=\(packCount)",
                    "used-to-plan=\(activeGoals.isEmpty == false)"
                ],
                relatedIDs: goalIDs
            ),
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasPathComposed,
                recordedAt: generatedAt,
                summary: "A local path shape stayed available for goal knowledge.",
                details: [
                    "planned-goals=\(snapshot.goals.filter { $0.plan != nil }.count)",
                    "step-count=\(stepCount)"
                ],
                relatedIDs: goalIDs
            ),
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasStepCandidatesExpanded,
                recordedAt: generatedAt,
                summary: "Step candidates stayed expanded from local goal source.",
                details: [
                    "step-count=\(stepCount)",
                    "evidence-aware=\(hasEvidence)"
                ],
                relatedIDs: goalIDs
            ),
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasUserCorrectionApplied,
                recordedAt: generatedAt,
                summary: "Local corrections stayed visible to future goal knowledge.",
                details: [
                    "teaching-signals=\(snapshot.teachingSignals.count)",
                    "feedback-events=\(snapshot.feedback.count)"
                ],
                relatedIDs: goalIDs + draftIDs
            ),
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasReplayGenerated,
                recordedAt: generatedAt,
                summary: "Replay receipts stayed local and inspectable.",
                details: [
                    "event-ledger-count=\(snapshot.eventLedger.count)",
                    "life-context-bundles=\(snapshot.lifeContextBundles.count)"
                ],
                relatedIDs: goalIDs + draftIDs
            )
        ]
    }

    func makeSourceAtlasKnowledgeRow(
        id: String,
        icon: String,
        title: String,
        usedWhat: String,
        whyUsed: String,
        sourceName: String,
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        riskState: SourceAtlasRequirementRiskState,
        runtimeUseState: YouSourceAtlasKnowledgeRuntimeUseState,
        needsReview: Bool,
        correctionPath: String,
        reviewPath: String,
        iconState: AmbitionVisualState
    ) -> YouSourceAtlasKnowledgeRow {
        let reviewNeedLabel = needsReview ? "Needs Review" : "No Review Needed"
        let accessibilityLabel = title
        let accessibilityValue = "\(usedWhat). \(whyUsed). Source \(sourceName). Source state \(sourceAtlasSourceStateLabel(sourceState)). Freshness \(sourceAtlasFreshnessStateLabel(freshnessState)). Risk \(sourceAtlasRiskStateLabel(riskState)). \(runtimeUseState.label). \(reviewNeedLabel). Correction path \(correctionPath). Review path \(reviewPath)."
        let accessibilityHint = "Shows what Ambitions used, why it used it, and how to review or correct the source path."

        return YouSourceAtlasKnowledgeRow(
            id: id,
            icon: icon,
            title: title,
            usedWhat: usedWhat,
            whyUsed: whyUsed,
            sourceName: sourceName,
            sourceStateLabel: sourceAtlasSourceStateLabel(sourceState),
            freshnessStateLabel: sourceAtlasFreshnessStateLabel(freshnessState),
            riskStateLabel: sourceAtlasRiskStateLabel(riskState),
            runtimeUseState: runtimeUseState,
            reviewNeedLabel: reviewNeedLabel,
            correctionPath: correctionPath,
            reviewPath: reviewPath,
            state: iconState,
            accessibilityLabel: accessibilityLabel,
            accessibilityValue: accessibilityValue,
            accessibilityHint: accessibilityHint
        )
    }

    func sourceAtlasSourceStateLabel(_ state: SourceAtlasRequirementSourceState) -> String {
        switch state {
        case .unknown:
            return "Unknown"
        case .sourceNeeded:
            return "Source needed"
        case .stale:
            return "Stale"
        case .contradicted:
            return "Contradicted"
        case .revoked:
            return "Revoked"
        case .locallyProven:
            return "Locally proven"
        case .official:
            return "Official"
        case .officialCurrent:
            return "Official current"
        case .current:
            return "Current"
        }
    }

    func sourceAtlasFreshnessStateLabel(_ state: SourceAtlasRequirementFreshnessState) -> String {
        switch state {
        case .current:
            return "Current"
        case .stale:
            return "Stale"
        case .unknown:
            return "Unknown"
        }
    }

    func sourceAtlasRiskStateLabel(_ state: SourceAtlasRequirementRiskState) -> String {
        switch state {
        case .low:
            return "Low risk"
        case .medium:
            return "Medium risk"
        case .high:
            return "High risk"
        case .unknown:
            return "Unknown risk"
        }
    }

    func makeLifeContextState(snapshot: Snapshot) -> YouLifeContextState {
        let bundle = latestLifeContextBundle(from: snapshot.lifeContextBundles)
        let projection = bundle?.projection(asOf: .now)
        let ledger = PersonalizationFactorLedgerBuilder().build(
            PersonalizationFactorLedgerInput(
                goalID: bundle?.id,
                goalText: bundle?.profile.userNotes ?? bundle?.profile.schoolOrWorkContext,
                projection: projection
            )
        )
        let basePath = "You > What Ambitions Knows > Life Context"
        let futureProofContextCandidates = makeFutureProofContextCandidates(snapshot: snapshot, bundle: bundle)
        let summaryItems = makeLifeContextSummaryItems(
            bundle: bundle,
            projection: projection,
            ledger: ledger,
            futureProofContextCandidates: futureProofContextCandidates
        )
        let sections = makeLifeContextSections(bundle: bundle, projection: projection, ledger: ledger, basePath: basePath)
        let futureProofSection = makeFutureProofContextSection(candidates: futureProofContextCandidates, basePath: basePath)
        let allSections = sections + (futureProofSection.map { [$0] } ?? [])

        return YouLifeContextState(
            title: "Life Context",
            subtitle: "Help Ambitions plan from your real life.",
            intro: "Age, schedule, travel, access, history, and constraints help Ambitions make plans that actually fit.",
            summaryItems: summaryItems,
            sections: allSections,
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
        projection: LifeContextRuntimeProjection?,
        ledger: PersonalizationFactorLedger,
        futureProofContextCandidates: [FutureProofContextCandidate]
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
        let ledgerReviewCount = ledger.factors.filter { $0.allowedForRuntimeUse == false || $0.freshness.needsReview }.count
        let futureProofReviewCount = futureProofContextCandidates.filter { $0.reviewNeeded || $0.runtimeUseAllowed == false }.count
        let reviewCount = sourceReviewCount + excludedReviewCount + sensitiveReviewCount + questionReviewCount + ledgerReviewCount + futureProofReviewCount

        var items = [
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
                id: "life-context-runtime-factors",
                title: "Runtime Factors",
                subtitle: "What actually shapes recommendations right now.",
                icon: "waveform.path.ecg",
                valueLabel: "\(ledger.factors.count)"
            ),
            SettingsItem(
                id: "life-context-review-needed",
                title: "Needs Review",
                subtitle: "Stale, imported, inferred, and sensitive context.",
                icon: "exclamationmark.triangle",
                valueLabel: reviewCount == 0 ? "Clear" : "\(reviewCount)"
            )
        ]
        if let futureProofContextSummaryItem = futureProofContextSummaryItem(candidates: futureProofContextCandidates) {
            items.insert(futureProofContextSummaryItem, at: 6)
        }
        return items
    }

    func makeLifeContextSections(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        ledger: PersonalizationFactorLedger,
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
                id: "life-context-runtime-factors",
                title: "Runtime Factors",
                subtitle: "These are the current factors shaping recommendation behavior.",
                factRows: makeRuntimeFactorRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-recommendation-inputs",
                title: "Recommendation Inputs",
                subtitle: "Selected and rejected candidate inputs stay inspectable.",
                factRows: makeRecommendationInputRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-why-this-changes-plans",
                title: "Why This Changes Plans",
                subtitle: "The concrete reasons that are allowed to move a recommendation.",
                factRows: makeWhyThisChangesPlanRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-rejected-factors",
                title: "Rejected Factors",
                subtitle: "Factors that are blocked or intentionally excluded.",
                factRows: makeRejectedFactorRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-sensitive-context-usage",
                title: "Sensitive Context Usage",
                subtitle: "Sensitive inputs stay visible without leaking raw detail.",
                factRows: makeSensitiveContextUsageRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-context-confidence",
                title: "Context Confidence",
                subtitle: "Freshness and review posture together shape confidence.",
                factRows: makeContextConfidenceRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-review-needed",
                title: "Needs Review",
                subtitle: "These rows need a fresh check before runtime use.",
                factRows: makeReviewNeededRows(bundle: bundle, projection: projection, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-disabled-factors",
                title: "Disabled Factors",
                subtitle: "These factors are explicitly removed from runtime use.",
                factRows: makeDisabledFactorRows(ledger: ledger, basePath: basePath)
            ),
            YouLifeContextSection(
                id: "life-context-replay-receipts",
                title: "Replay & Receipts",
                subtitle: "The replay fingerprint and receipt seam stay visible.",
                factRows: makeReplayAndReceiptRows(ledger: ledger, basePath: basePath)
            )
        ]
    }

    func makeFutureProofContextSection(
        candidates: [FutureProofContextCandidate],
        basePath: String
    ) -> YouLifeContextSection? {
        let rows = makeFutureProofContextRows(candidates: candidates, basePath: basePath)
        guard rows.isEmpty == false else {
            return nil
        }

        return YouLifeContextSection(
            id: "life-context-future-proof-context",
            title: "Future-proof context",
            subtitle: "Captured context that can stay visible and reviewable for later planning.",
            factRows: rows
        )
    }

    func makeFutureProofContextRows(
        candidates: [FutureProofContextCandidate],
        basePath: String
    ) -> [YouLifeContextFactRow] {
        candidates.sorted { $0.id < $1.id }.map { candidate in
            let runtimeUseState = candidate.runtimeUseAllowed && candidate.reviewNeeded == false ? YouLifeContextRuntimeUseState.used : .needsReview
            let displayTitle = candidate.contextCategory == .skillContext
                ? FutureProofContextCategory.recurringCommitment.displayTitle
                : candidate.contextCategory.displayTitle
            return makeLifeContextFactRow(
                id: "future-proof-context-\(candidate.id)",
                title: displayTitle,
                detail: futureProofContextDetail(for: candidate),
                sourceLabel: candidate.sourceLabel,
                freshness: memoryFreshness(for: candidate.freshness),
                runtimeUseState: runtimeUseState,
                activityLabel: displayTitle,
                lastAffectedLabel: candidate.visibleInYou ? "Visible in You" : "Hidden from You",
                runtimePermissionLabel: candidate.runtimeUseAllowed ? "Allowed" : "Approval required",
                whereUsed: candidate.potentialFutureUses.joined(separator: " · "),
                updateTargets: [.historicalFact],
                captureRouteContext: candidate.reviewNeeded || candidate.runtimeUseAllowed == false ? .needsReview : .needsPlace,
                basePath: "\(basePath) > Future-proof context"
            )
        }
    }

    func futureProofContextSummaryItem(candidates: [FutureProofContextCandidate]) -> SettingsItem? {
        guard candidates.isEmpty == false else {
            return nil
        }

        return SettingsItem(
            id: "life-context-future-proof-context",
            title: "Future-proof context",
            subtitle: "Standalone captures and stored context you can reuse later without forcing goal attachment.",
            icon: "sparkles",
            valueLabel: "\(candidates.count) items"
        )
    }

    func makeFutureProofContextCandidates(snapshot: Snapshot, bundle: LifeContextBundle?) -> [FutureProofContextCandidate] {
        let storedCandidates = bundle?.futureProofContextCandidates ?? []
        let derivedCandidates = snapshot.captures
            .filter { $0.status != .archived }
            .compactMap { capture -> FutureProofContextCandidate? in
                let result = DefaultSmartAttachmentService().route(
                    SmartAttachmentInput(
                        rawText: capture.rawText,
                        sourceContext: SmartAttachmentSourceContext(
                            sourceType: capture.sourceType,
                            sourceSurface: "Capture"
                        )
                    ),
                    candidates: []
                )
                return result.futureProofContextCandidate
            }

        var ordered = [String: FutureProofContextCandidate]()
        for candidate in storedCandidates + derivedCandidates {
            ordered[candidate.id] = candidate
        }
        return ordered.values.sorted { $0.id < $1.id }
    }

    func futureProofContextDetail(for candidate: FutureProofContextCandidate) -> String {
        let uses = candidate.potentialFutureUses.joined(separator: ", ")
        let runtimeLine = candidate.runtimeUseAllowed ? "Runtime use allowed." : "Runtime use blocked until approval."
        let reviewLine = candidate.reviewNeeded ? "Review needed." : "Review not required."
        return "\(candidate.contextCategory.displayTitle) from \(candidate.sourceLabel). \(uses). \(runtimeLine) \(reviewLine) Deletion supported: \(candidate.deletionSupported ? "yes" : "no")."
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

    func makeRuntimeFactorRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        ledger.factors.map { factor in
            makeLifeContextFactRow(
                id: "life-context-runtime-factor-\(factor.id)",
                title: displayLabel(for: factor.factorType),
                detail: factor.humanReadableReason,
                sourceLabel: factor.source.sourceLabel,
                freshness: memoryFreshness(for: factor.freshness.state),
                runtimeUseState: runtimeUseState(for: factor),
                activityLabel: factor.active ? "Active" : "Disabled",
                lastAffectedLabel: factor.lastAffectedLabel,
                runtimePermissionLabel: factor.allowedForRuntimeUse ? "Allowed" : "Blocked",
                whereUsed: factor.affectedRecommendationArea,
                updateTargets: factorUpdateTargets(for: factor),
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }
    }

    func makeRecommendationInputRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-recommendation-selected",
                title: "Selected candidate",
                detail: ledger.selectedCandidateID,
                sourceLabel: "Runtime output",
                freshness: ledger.replayProjection.canReplay ? .current : .mayNeedReview,
                runtimeUseState: ledger.replayProjection.canReplay ? .used : .needsReview,
                activityLabel: "Selected",
                lastAffectedLabel: "This run",
                runtimePermissionLabel: "Allowed",
                whereUsed: "Candidate competition",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-recommendation-rejected",
                title: "Rejected candidates",
                detail: ledger.rejectedCandidateIDs.isEmpty ? "None" : ledger.rejectedCandidateIDs.joined(separator: ", "),
                sourceLabel: "Runtime output",
                freshness: ledger.rejectedCandidateIDs.isEmpty ? .current : .mayNeedReview,
                runtimeUseState: ledger.rejectedCandidateIDs.isEmpty ? .used : .needsReview,
                activityLabel: ledger.rejectedCandidateIDs.isEmpty ? "None rejected" : "Rejected",
                lastAffectedLabel: ledger.replayProjection.stableFingerprint,
                runtimePermissionLabel: "Allowed",
                whereUsed: "Candidate competition",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-recommendation-sources",
                title: "Recommendation inputs",
                detail: ledger.explanationProjection.sourceLabels.isEmpty ? "No source labels yet." : ledger.explanationProjection.sourceLabels.joined(separator: ", "),
                sourceLabel: "Explanation projection",
                freshness: ledger.confidenceBand == .reviewNeeded ? .mayNeedReview : .current,
                runtimeUseState: ledger.confidenceBand == .reviewNeeded ? .needsReview : .used,
                activityLabel: "Explained",
                lastAffectedLabel: ledger.explanationProjection.confidenceLabel,
                runtimePermissionLabel: "Allowed",
                whereUsed: "Why the recommendation changed",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeWhyThisChangesPlanRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-why-summary",
                title: "Why this changes plans",
                detail: ledger.explanationProjection.summary,
                sourceLabel: "Explanation projection",
                freshness: ledger.confidenceBand == .reviewNeeded ? .mayNeedReview : .current,
                runtimeUseState: ledger.confidenceBand == .reviewNeeded ? .needsReview : .used,
                activityLabel: ledger.confidenceBand == .reviewNeeded ? "Needs review" : "Active",
                lastAffectedLabel: ledger.generatedAt,
                runtimePermissionLabel: "Allowed",
                whereUsed: "Plan-shaping explanation",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-why-reasons",
                title: "Reason stack",
                detail: ledger.explanationProjection.whyThisChangesPlans.isEmpty ? "No local reasons recorded yet." : ledger.explanationProjection.whyThisChangesPlans.joined(separator: " • "),
                sourceLabel: "Explanation projection",
                freshness: ledger.explanationProjection.whyThisChangesPlans.isEmpty ? .basedOnOlderContext : .current,
                runtimeUseState: ledger.explanationProjection.whyThisChangesPlans.isEmpty ? .needsReview : .used,
                activityLabel: "Active",
                lastAffectedLabel: ledger.replayProjection.stableFingerprint,
                runtimePermissionLabel: "Allowed",
                whereUsed: "Reasons allowed to change the plan",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeRejectedFactorRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let rejectedFactors = ledger.factors.filter {
            $0.allowedForRuntimeUse == false ||
                $0.control.active == false ||
                $0.sensitiveUse.permissionState == .blocked
        }
        if rejectedFactors.isEmpty {
            return [
                makeLifeContextFactRow(
                    id: "life-context-rejected-empty",
                    title: "Rejected factors",
                    detail: "None yet.",
                    sourceLabel: "Runtime output",
                    freshness: .current,
                    runtimeUseState: .used,
                    activityLabel: "None rejected",
                    lastAffectedLabel: ledger.generatedAt,
                    runtimePermissionLabel: "Allowed",
                    whereUsed: "No factor rejection yet",
                    updateTargets: [.historicalFact],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            ]
        }

        return rejectedFactors.map { factor in
            makeLifeContextFactRow(
                id: "life-context-rejected-\(factor.id)",
                title: displayLabel(for: factor.factorType),
                detail: factor.fallbackBehaviorIfRemoved,
                sourceLabel: factor.source.sourceLabel,
                freshness: memoryFreshness(for: factor.freshness.state),
                runtimeUseState: .notUsed,
                activityLabel: "Rejected",
                lastAffectedLabel: factor.lastAffectedLabel,
                runtimePermissionLabel: factor.sensitiveUse.permissionState.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                whereUsed: factor.affectedRecommendationArea,
                updateTargets: factorUpdateTargets(for: factor),
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }
    }

    func makeSensitiveContextUsageRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let sensitiveFactors = ledger.factors.filter { $0.sensitiveUse.isSensitive || $0.sensitiveUse.permissionState != .allowed }
        if sensitiveFactors.isEmpty {
            return [
                makeLifeContextFactRow(
                    id: "life-context-sensitive-empty",
                    title: "Sensitive context",
                    detail: "No sensitive factor is active.",
                    sourceLabel: "Runtime output",
                    freshness: .current,
                    runtimeUseState: .used,
                    activityLabel: "No sensitive use",
                    lastAffectedLabel: ledger.generatedAt,
                    runtimePermissionLabel: "Allowed",
                    whereUsed: "Sensitive inputs stay blocked unless approved",
                    updateTargets: [.historicalFact],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            ]
        }

        return sensitiveFactors.map { factor in
            makeLifeContextFactRow(
                id: "life-context-sensitive-\(factor.id)",
                title: displayLabel(for: factor.factorType),
                detail: factor.sensitiveUse.sensitiveUseLabel,
                sourceLabel: factor.source.sourceLabel,
                freshness: memoryFreshness(for: factor.freshness.state),
                runtimeUseState: factor.allowedForRuntimeUse ? .used : .needsReview,
                activityLabel: factor.sensitiveUse.permissionState == .allowed ? "Allowed" : "Blocked",
                lastAffectedLabel: factor.lastAffectedLabel,
                runtimePermissionLabel: factor.sensitiveUse.permissionState.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                whereUsed: factor.affectedRecommendationArea,
                updateTargets: factorUpdateTargets(for: factor),
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }
    }

    func makeContextConfidenceRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-confidence-band",
                title: "Confidence band",
                detail: ledger.confidenceBand.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                sourceLabel: "Runtime output",
                freshness: ledger.confidenceBand == .reviewNeeded ? .mayNeedReview : .current,
                runtimeUseState: ledger.confidenceBand == .reviewNeeded ? .needsReview : .used,
                activityLabel: "Active",
                lastAffectedLabel: ledger.replayProjection.stableFingerprint,
                runtimePermissionLabel: ledger.replayProjection.canReplay ? "Allowed" : "Blocked",
                whereUsed: "How sure the runtime is",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-confidence-review",
                title: "Needs review",
                detail: ledger.missingContextQuestions.isEmpty ? "No unanswered questions." : ledger.missingContextQuestions.joined(separator: ", "),
                sourceLabel: "Runtime output",
                freshness: ledger.missingContextQuestions.isEmpty ? .current : .mayNeedReview,
                runtimeUseState: ledger.missingContextQuestions.isEmpty ? .used : .needsReview,
                activityLabel: ledger.missingContextQuestions.isEmpty ? "Clear" : "Needs review",
                lastAffectedLabel: ledger.generatedAt,
                runtimePermissionLabel: ledger.missingContextQuestions.isEmpty ? "Allowed" : "Needs review",
                whereUsed: "What still needs attention before trust is higher",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeDisabledFactorRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let disabledFactors = ledger.factors.filter {
            $0.control.active == false || $0.allowedForRuntimeUse == false || $0.sensitiveUse.permissionState == .disabled
        }
        if disabledFactors.isEmpty {
            return [
                makeLifeContextFactRow(
                    id: "life-context-disabled-empty",
                    title: "Disabled factors",
                    detail: "None yet.",
                    sourceLabel: "Runtime output",
                    freshness: .current,
                    runtimeUseState: .used,
                    activityLabel: "None disabled",
                    lastAffectedLabel: ledger.generatedAt,
                    runtimePermissionLabel: "Allowed",
                    whereUsed: "Nothing has been disabled yet",
                    updateTargets: [.historicalFact],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            ]
        }

        return disabledFactors.map { factor in
            makeLifeContextFactRow(
                id: "life-context-disabled-\(factor.id)",
                title: displayLabel(for: factor.factorType),
                detail: factor.fallbackBehaviorIfRemoved,
                sourceLabel: factor.source.sourceLabel,
                freshness: memoryFreshness(for: factor.freshness.state),
                runtimeUseState: .notUsed,
                activityLabel: "Disabled",
                lastAffectedLabel: factor.lastAffectedLabel,
                runtimePermissionLabel: factor.sensitiveUse.permissionState.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                whereUsed: factor.affectedRecommendationArea,
                updateTargets: factorUpdateTargets(for: factor),
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }
    }

    func makeReplayAndReceiptRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-replay-fingerprint",
                title: "Replay fingerprint",
                detail: ledger.replayProjection.stableFingerprint,
                sourceLabel: "Replay projection",
                freshness: ledger.replayProjection.canReplay ? .current : .mayNeedReview,
                runtimeUseState: ledger.replayProjection.canReplay ? .used : .needsReview,
                activityLabel: ledger.replayProjection.canReplay ? "Replayable" : "Needs review",
                lastAffectedLabel: ledger.generatedAt,
                runtimePermissionLabel: ledger.replayProjection.canReplay ? "Allowed" : "Blocked",
                whereUsed: "Deterministic replay",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-replay-candidate",
                title: "Selected / rejected candidates",
                detail: "Selected \(ledger.replayProjection.selectedCandidateID); rejected \(ledger.replayProjection.rejectedCandidateIDs.isEmpty ? "none" : ledger.replayProjection.rejectedCandidateIDs.joined(separator: ", "))",
                sourceLabel: "Replay projection",
                freshness: ledger.replayProjection.canReplay ? .current : .mayNeedReview,
                runtimeUseState: ledger.replayProjection.canReplay ? .used : .needsReview,
                activityLabel: "Replayable",
                lastAffectedLabel: ledger.replayProjection.stableFingerprint,
                runtimePermissionLabel: "Allowed",
                whereUsed: "Selected and rejected candidate memory",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
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
        activityLabel: String = "Active",
        lastAffectedLabel: String = "This run",
        runtimePermissionLabel: String = "Allowed",
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
            activityLabel: activityLabel,
            lastAffectedLabel: lastAffectedLabel,
            runtimePermissionLabel: runtimePermissionLabel,
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
            accessibilityValue: "\(detail). Source \(sourceLabel). Freshness \(freshness.label). Runtime use \(runtimeUseState.label). Activity \(activityLabel). Last affected \(lastAffectedLabel). Permission \(runtimePermissionLabel). Used for \(whereUsed).",
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

    func memoryFreshness(for freshness: PersonalizationFactorLedgerFreshnessState) -> YouMemoryFreshness {
        switch freshness {
        case .current:
            return .current
        case .mayNeedReview:
            return .mayNeedReview
        case .basedOnOlderContext, .stale:
            return .basedOnOlderContext
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

    func displayLabel(for factorType: PersonalizationFactorLedgerFactorType) -> String {
        switch factorType {
        case .goalRequirement:
            return "Goal requirement"
        case .deadlinePressure:
            return "Deadline pressure"
        case .availabilityWindow:
            return "Availability window"
        case .travelFit:
            return "Travel fit"
        case .transportationConstraint:
            return "Transportation constraint"
        case .facilityAccess:
            return "Facility access"
        case .equipmentAccess:
            return "Equipment access"
        case .historicalContext:
            return "Historical context"
        case .pastFailure:
            return "Past failure"
        case .pastSuccess:
            return "Past success"
        case .recoveryConstraint:
            return "Recovery constraint"
        case .executionBehavior:
            return "Execution behavior"
        case .timeOfDayFit:
            return "Time of day fit"
        case .energyPattern:
            return "Energy pattern"
        case .eligibilityPathway:
            return "Eligibility pathway"
        case .seasonality:
            return "Seasonality"
        case .dependencyConstraint:
            return "Dependency constraint"
        case .budgetConstraint:
            return "Budget constraint"
        case .preference:
            return "Preference"
        case .trustAllowance:
            return "Trust allowance"
        case .recentProof:
            return "Recent proof"
        case .recentDrift:
            return "Recent drift"
        case .safetyConstraint:
            return "Safety constraint"
        }
    }

    func runtimeUseState(for factor: PersonalizationFactorLedgerFactor) -> YouLifeContextRuntimeUseState {
        if factor.allowedForRuntimeUse == false || factor.active == false {
            return .notUsed
        }
        return factor.freshness.state == .current ? .used : .needsReview
    }

    func factorUpdateTargets(for factor: PersonalizationFactorLedgerFactor) -> [YouLifeContextUpdateTarget] {
        switch factor.factorCategory {
        case .eligibility:
            return [.profile, .eligibilityPathway]
        case .access:
            return [.profile, .opportunityContext]
        case .history:
            return [.historicalFact]
        case .recovery, .safety:
            return [.profile, .historicalFact]
        case .timing, .preference, .trust, .proof, .freshness, .sensitivity, .replay, .goal:
            return [.historicalFact]
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

    func lifeContextDisplayTitle(for profile: LifeContextProfile?) -> String {
        guard let profile else { return "Life Context Profile" }
        if let schoolOrWorkContext = profile.schoolOrWorkContext, schoolOrWorkContext.isEmpty == false {
            return schoolOrWorkContext
        }
        if let location = profile.generalLocationLabel, location.isEmpty == false {
            return location
        }
        if let timezone = profile.timezone, timezone.isEmpty == false {
            return "Life context (\(timezone))"
        }
        return "Life context bundle"
    }

    func lifeContextDisplaySummary(for profile: LifeContextProfile?) -> String {
        guard let profile else { return "Life context bundle" }
        var parts: [String] = []
        let locationSummary = profileLocationSummary(for: profile)
        if locationSummary != "Not captured" {
            parts.append(locationSummary)
        }
        let transport = profile.transportationAccess == .unknown ? "Not captured" : displayLabel(for: profile.transportationAccess)
        if transport != "Not captured" {
            parts.append(transport)
        }
        let travel = travelRadiusSummary(for: profile)
        if travel != "Not captured" {
            parts.append(travel)
        }
        return parts.isEmpty ? "Life context bundle" : parts.joined(separator: " · ")
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
                    : "\(correctionCount) correction signal\(correctionCount == 1 ? "" : "s") can be reset, disabled, or deleted from the owning correction path after confirmation.",
                sourceLabel: "Manual corrections",
                availabilityLabel: correctionCount == 0 ? "Available when present" : "Confirmation required",
                receiptLabel: "Receipt required before future reuse changes",
                boundaryLabel: "Does not erase proof, captures, or raw Event Ledger history; changes stay source-tied and reversible",
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
        let stagedInputs = CaptureStagedInputProjection.supported(sourceSurface: "Capture")
        return [
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
            ),
            YouMemoryLensItem(
                id: "memory-lens-capture-staging",
                title: "Capture staging boundary",
                summary: "\(stagedInputs.count) staged input kind\(stagedInputs.count == 1 ? "" : "s") keep local privacy, export, redaction, and retention labels before save.",
                sourceLabel: "Capture",
                sourceAgeLabel: "Current",
                whyRemembered: "Why remembered: Capture staging should stay inspectable and local before it becomes a route or receipt.",
                privacyShutterLabel: "Stored on this device",
                reviewLabel: "Review before stronger use",
                correctionLabel: "Edit in Capture",
                rejectionLabel: "Archive from Capture",
                state: .success,
                accessibilityLabel: "Memory Lens capture staging boundary",
                accessibilityValue: "Current. Stored on this device. Review before stronger use.",
                accessibilityHint: "Shows the local staging policy for text, voice, image, share, proof, and context input kinds."
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
                title: "What Personal Runtime learned",
                summary: correctionCount == 0
                    ? "No Personal Runtime learning signal is saved yet."
                    : "\(correctionCount) correction signal\(correctionCount == 1 ? "" : "s") can teach Personal Runtime how to reject or reuse similar recommendations.",
                sourceLabel: "Personal Runtime",
                controlLabel: correctionCount == 0 ? "Available when present" : "Reset or delete in What Ambitions knows",
                privacyLabel: "Local and source-tied",
                state: correctionCount == 0 ? .default : .success,
                accessibilityLabel: "What Personal Runtime learned",
                accessibilityValue: correctionCount == 0 ? "No Personal Runtime learning signal saved yet. Local and source-tied." : "\(correctionCount) correction signals. Personal Runtime, local and source-tied.",
                accessibilityHint: "Shows learned local correction state and where reuse can be reset, deleted, corrected, or rejected."
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
            status.trustPosture == .localOnly &&
            status.detail.contains("explicit local-only mode") {
            return "Not currently connected"
        }
        return status.detail
    }

    func syncExportTruthSubtitle(_ status: SyncCapabilityStatus) -> String {
        if status.availability == .unavailable &&
            status.trustPosture == .localOnly &&
            status.detail.contains("explicit local-only mode") {
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

    func goalSourceOrdering(lhs: Goal, rhs: Goal) -> Bool {
        if lhs.updatedAt != rhs.updatedAt {
            return lhs.updatedAt > rhs.updatedAt
        }
        let titleCompare = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if titleCompare != .orderedSame {
            return titleCompare == .orderedAscending
        }
        return lhs.id < rhs.id
    }

    func planSectionOrdering(lhs: PlanSection, rhs: PlanSection) -> Bool {
        if lhs.orderIndex != rhs.orderIndex {
            return lhs.orderIndex < rhs.orderIndex
        }
        let titleCompare = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if titleCompare != .orderedSame {
            return titleCompare == .orderedAscending
        }
        return lhs.id < rhs.id
    }

    func stepSourceOrdering(lhs: Step, rhs: Step) -> Bool {
        if lhs.state != rhs.state {
            return stepStateRank(lhs.state) < stepStateRank(rhs.state)
        }
        let titleCompare = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if titleCompare != .orderedSame {
            return titleCompare == .orderedAscending
        }
        return lhs.id < rhs.id
    }

    func stepStateRank(_ state: StepLifecycleState) -> Int {
        switch state {
        case .planned, .active:
            return 0
        case .blocked:
            return 1
        case .completed, .cancelled:
            return 2
        }
    }
}
