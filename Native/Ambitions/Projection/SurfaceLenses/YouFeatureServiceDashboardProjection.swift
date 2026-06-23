import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    // AMBITIONS-QUALITY-EXTRACTION: Dashboard assembly stays in one projection boundary while child projection groups are split into focused owner files.
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
        let profileTitle = trimmedName.isEmpty ? "Local profile" : "\(trimmedName)'s settings"
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
                subtitle: "Local settings keep privacy, receipts, appearance, and defaults inspectable.",
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
                title: "Profile map",
                subtitle: "A short map of the local settings and trust areas you can inspect.",
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
                footer: "Open details from their owning surfaces for deep review. You stays oriented around trust, control, and current status."
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
                footer: "Notification and integration status should answer whether anything important needs attention without becoming the first layer."
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

}
