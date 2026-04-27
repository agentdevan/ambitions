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
                        title: "Memory Controls",
                        subtitle: "Local evidence, feedback, corrections, captures, and event history Ambitions may use.",
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
                        subtitle: "Internal checklist infrastructure exists. User-facing verification remains unavailable until a later verification batch.",
                        icon: "figure",
                        valueLabel: "Unverified"
                    ),
                    SettingsItem(
                        id: "profile-trust-export-import",
                        title: "Export and disaster recovery",
                        subtitle: "Portable snapshot foundations exist, but Batch 90 owns the proof drill. This surface does not claim export is production-ready.",
                        icon: "externaldrive.badge.icloud",
                        valueLabel: "Future planned"
                    )
                ],
                footer: "Trust-sensitive features are labeled as available, manual, unavailable, or future planned. Ambitions does not claim live sync, account systems, or verified accessibility here."
            ),
            contextVault: ProfileContextVaultState(
                title: "Local memory map",
                subtitle: "A compact inventory of local signal types, not a black-box profile.",
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
                    title: "Recommend one believable move",
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
            footer: "These are current local defaults, not a broad account/preferences system. Batch 108 owns deeper Constitution maturity."
        )
    }

    func makeMemoryControls(snapshot: Snapshot) -> ProfileMemoryControlState {
        let correctionCount = snapshot.teachingSignals.count
        let correctionStatus = correctionCount == 0 ? "None yet" : "\(correctionCount) local"
        return ProfileMemoryControlState(
            title: "Memory Controls",
            subtitle: "What Ambitions may use locally to explain recommendations and recovery.",
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
            footer: "You can inspect memory areas here. Broad forgetting and deletion remain manual/future until the safe boundary can prove the result."
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
                    title: "Action Closure receipts",
                    subtitle: "The receipt model can summarize what changed, why, correction availability, safe fallback, and undo status where supported.",
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
