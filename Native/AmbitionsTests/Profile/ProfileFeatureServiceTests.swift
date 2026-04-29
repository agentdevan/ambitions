import XCTest
@testable import Ambitions

final class ProfileFeatureServiceTests: XCTestCase {
    func testDashboardCopyStatesCurrentNativeTruthWithoutOverclaimingExternalSurfaces() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertTrue(dashboard.hero.subtitle.contains("Trust Center"))
        XCTAssertTrue(dashboard.trustCenter.pulse.subtitle.contains("Local-first"))
        XCTAssertTrue(dashboard.trustCenter.items.contains(where: { $0.id == "profile-trust-sync" && $0.valueLabel == "Ambitions is running in explicit local-only mode." }))
        XCTAssertTrue(dashboard.trustCenter.items.contains(where: { $0.id == "profile-trust-accessibility" && $0.valueLabel == "Unverified" }))
        XCTAssertTrue(dashboard.trustCenter.items.contains(where: { $0.id == "profile-trust-export-import" && $0.valueLabel == "Future planned" }))
        XCTAssertTrue(dashboard.integrationsSection.items.contains(where: { $0.id == "profile-integration-notifications" && $0.valueLabel == "Not requested" }))
        XCTAssertTrue(dashboard.integrationsSection.items.contains(where: { $0.id == "profile-integration-shortcuts" && $0.valueLabel == ExternalSurfaceTruth.productizedNeedsPlatformReview }))
        XCTAssertTrue(dashboard.integrationsSection.items.contains(where: { $0.id == "profile-integration-share" && $0.valueLabel == ExternalSurfaceTruth.productizedNeedsPlatformReview }))
        XCTAssertTrue(dashboard.trustCenter.footer.contains("does not claim live sync"))
        XCTAssertFalse(dashboard.trustCenter.footer.contains("Batch 54"))
        XCTAssertTrue(dashboard.accountSection.items.contains(where: { $0.id == "profile-account-billing" && $0.valueLabel == "Not active" }))
        XCTAssertFalse(dashboard.hero.supportingTruth.contains("local device features"))
    }

    func testSavingPreferencesKeepsStorageOnDeviceOnly() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        _ = try await service.saveProfilePreferences(
            ProfilePreferencesUpdate(
                preferredTab: .goals,
                appearancePreference: .dark,
                accentFamily: .copper,
                reviewCadenceDays: 3,
                localOnlyModeEnabled: false
            )
        )

        let state = try await repositories.appState.loadState()
        XCTAssertEqual(state.preferredTab, .goals)
        XCTAssertEqual(state.appearancePreference, .dark)
        XCTAssertEqual(state.accentFamily, .copper)
        XCTAssertEqual(state.reviewCadenceDays, 3)
        XCTAssertTrue(state.localOnlyModeEnabled)
    }

    func testDashboardUsesNeutralIdentityWhenDisplayNameIsBlank() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        var state = try await repositories.appState.loadState()
        state.userDisplayName = "   "
        try await repositories.appState.saveState(state)

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertEqual(dashboard.hero.title, "Your system")
        XCTAssertEqual(dashboard.preferences.appearancePreference, .system)
        XCTAssertEqual(dashboard.preferences.accentFamily, .sage)
        XCTAssertTrue(dashboard.defaultsSection.items.contains(where: { $0.id == "profile-default-storage" && $0.valueLabel == "Local-only" }))
        XCTAssertTrue(dashboard.contextVault.items.contains(where: { $0.id == "profile-vault-identity" && $0.detail == "No display name stored" }))
    }

    func testDashboardUsesInjectedRuntimeSyncCapabilityStatus() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(
            repositories: repositories,
            syncCapability: StaticProfileSyncCapability(
                status: SyncCapabilityStatus(
                    backendKind: .localOnly,
                    trustPosture: .localOnly,
                    availability: .unavailable,
                    detail: "Injected runtime trust posture."
                )
            )
        )

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertTrue(dashboard.trustCenter.items.contains(where: { $0.id == "profile-trust-sync" && $0.valueLabel == "Injected runtime trust posture." }))
    }

    func testDashboardMapsNotificationAuthorizationIntoNarrowTrustSurface() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(
            repositories: repositories,
            notificationService: StaticProfileNotificationService(state: .authorized)
        )

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertEqual(dashboard.notificationAuthorization.statusLabel, "Allowed")
        XCTAssertFalse(dashboard.notificationAuthorization.canRequestAuthorization)
        XCTAssertNil(dashboard.notificationAuthorization.actionTitle)
        XCTAssertTrue(dashboard.trustCenter.items.contains(where: { $0.id == "profile-trust-notifications" && $0.valueLabel == "Allowed" }))
        XCTAssertTrue(dashboard.integrationsSection.items.contains(where: { $0.id == "profile-integration-notifications" && $0.valueLabel == "Allowed" }))
    }

    func testDashboardMapsDeniedNotificationAuthorizationIntoConservativeTrustSurface() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(
            repositories: repositories,
            notificationService: StaticProfileNotificationService(state: .denied)
        )

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertEqual(dashboard.notificationAuthorization.statusLabel, "Denied")
        XCTAssertFalse(dashboard.notificationAuthorization.canRequestAuthorization)
        XCTAssertNil(dashboard.notificationAuthorization.actionTitle)
        XCTAssertTrue(dashboard.integrationsSection.items.contains(where: {
            $0.id == "profile-integration-notifications" &&
            $0.valueLabel == "Denied" &&
            ($0.subtitle?.contains("Denied in system settings") ?? false)
        }))
    }

    func testDashboardAddsContextVaultAndDefaultsWithoutTurningProfileIntoWorkflow() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertEqual(dashboard.contextVault.title, "Local memory map")
        XCTAssertTrue(dashboard.contextVault.items.contains(where: { $0.id == "profile-vault-planning" }))
        XCTAssertTrue(dashboard.defaultsSection.items.contains(where: { $0.id == "profile-default-tab" }))
        XCTAssertTrue(dashboard.defaultsSection.items.contains(where: { $0.id == "profile-default-rituals" && $0.valueLabel == "Plan-owned" }))
        XCTAssertTrue(dashboard.integrationsSection.items.contains(where: { $0.id == "profile-integration-widgets" }))
        XCTAssertEqual(dashboard.appearanceStudio.title, "Appearance Studio")
    }

    func testYouControlRoomProjectsBatch87TrustAreasWithoutFutureBatchClaims() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertEqual(dashboard.controlRoom.entries.map(\.id), [
            "profile-control-constitution",
            "profile-control-memory",
            "profile-control-corrections",
            "profile-control-receipts"
        ])
        XCTAssertEqual(dashboard.constitution.title, "Personal Operating Constitution")
        XCTAssertTrue(dashboard.constitution.rules.contains(where: { $0.id == "constitution-calendar" && $0.detail.contains("never silent") }))
        XCTAssertTrue(dashboard.receiptAudit.items.contains(where: { $0.id == "profile-receipts-review" && $0.title == "Reviews v1" }))
        XCTAssertTrue(dashboard.receiptAudit.subtitle.contains("Reviews now"))
    }

    func testD17SystemCenterGroupsYouWithoutAddingTopLevelTabsOrOverclaiming() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()
        let items = dashboard.systemCenter.sections.flatMap(\.items)
        let titles = items.map(\.title)

        XCTAssertEqual(dashboard.systemCenter.title, "Personal System Center")
        XCTAssertTrue(dashboard.systemCenter.subtitle.contains("without adding more top-level tabs"))
        XCTAssertEqual(Set(titles), Set([
            "Profile",
            "Personalization",
            "Memory / What Ambitions Knows",
            "Reviews",
            "Analytics",
            "Trust & Explanations",
            "Privacy",
            "Sync / Export",
            "Integrations",
            "Appearance",
            "Notifications",
            "Accessibility",
            "Settings"
        ]))
        XCTAssertEqual(dashboard.systemCenter.sections.map(\.id), [
            "profile-system-personal",
            "profile-system-memory-trust",
            "profile-system-access"
        ])
        XCTAssertTrue(items.allSatisfy { !$0.accessibilityHint.isEmpty })
        XCTAssertTrue(items.contains(where: {
            $0.id == "profile-system-analytics" &&
            ($0.subtitle.contains("instead of becoming an Insights tab"))
        }))
        XCTAssertTrue(items.contains(where: {
            $0.id == "profile-system-sync-export" &&
            ($0.subtitle.contains("Sync is not connected"))
        }))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Profile"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Insights"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Habits"))
    }

    func testD18TrustCenterIsNavigableReceiptAwareAndPrivacySafe() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()
        let routes = dashboard.trustCenter.sections.flatMap(\.routes)

        XCTAssertEqual(dashboard.trustCenter.sections.map(\.id), [
            "trust-center-status",
            "trust-center-receipts",
            "trust-center-privacy-future"
        ])
        XCTAssertTrue(routes.contains(where: {
            $0.id == "trust-route-receipts" &&
            ($0.subtitle.contains("what happened, what changed, why"))
        }))
        XCTAssertTrue(routes.contains(where: {
            $0.id == "trust-route-corrections" &&
            ($0.subtitle.contains("existing Goal Detail, Capture, teaching, and explanation seams"))
        }))
        XCTAssertTrue(routes.contains(where: {
            $0.id == "trust-route-undo" &&
            ($0.subtitle.contains("blocked or confirmation-gated"))
        }))
        XCTAssertTrue(routes.contains(where: {
            $0.id == "trust-route-privacy" &&
            $0.statusLabel == "Private by default"
        }))
        XCTAssertTrue(routes.contains(where: {
            $0.id == "trust-route-sync-export" &&
            ($0.subtitle.contains("Sync is not connected"))
        }))
        XCTAssertEqual(dashboard.trustCenter.receiptSummaries.count, 3)
        XCTAssertTrue(dashboard.trustCenter.receiptSummaries.contains(where: {
            $0.safetyState == .confirmationRequired &&
            $0.undoAvailability == .requiresConfirmation
        }))
        XCTAssertTrue(dashboard.trustCenter.receiptSummaries.contains(where: {
            $0.safetyState == .safeFailure &&
            $0.summary.localizedCaseInsensitiveContains("No automation ran")
        }))
        XCTAssertFalse(dashboard.trustCenter.footer.localizedCaseInsensitiveContains("synced everywhere"))
        XCTAssertFalse(dashboard.trustCenter.footer.localizedCaseInsensitiveContains("verified accessible"))
    }

    func testReviewsV1IsYouOwnedAndTruthfulWithoutRestoringInsightsTab() async throws {
        let repositories = try await makeRepositories()
        try await repositories.eventLedger.append(
            EventLedgerEntry(
                id: "ledger-review-action",
                kind: .actionCompleted,
                occurredAt: "2026-04-27T10:30:00Z",
                source: .today,
                title: "Action completed",
                summary: "Finished one protected move.",
                tone: .positive
            )
        )
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertEqual(dashboard.reviews.title, "Reviews")
        XCTAssertEqual(dashboard.reviews.projection.lifeOSReceipt.statusLabel, "Based on recent actions")
        XCTAssertTrue(dashboard.reviews.projection.lifeOSReceipt.meaningfulEvents.contains(where: { $0.valueLabel == "Completed" }))
        XCTAssertTrue(dashboard.reviews.footer.contains("does not restore Insights as a tab"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Insights"))
        XCTAssertTrue(dashboard.reviews.projection.period.trustWhisper.contains("No live sync"))
        XCTAssertFalse(dashboard.reviews.projection.period.trustWhisper.localizedCaseInsensitiveContains("synced everywhere"))
        XCTAssertFalse(dashboard.reviews.projection.period.trustWhisper.localizedCaseInsensitiveContains("verified accessible"))
    }

    func testMemoryControlsDoNotExposeUnsupportedDestructiveDeletion() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()

        let forget = try XCTUnwrap(dashboard.memoryControls.items.first(where: { $0.id == "profile-memory-forget" }))
        XCTAssertEqual(forget.valueLabel, "Unavailable")
        XCTAssertTrue(forget.subtitle?.contains("Destructive memory deletion is not exposed here") ?? false)
        XCTAssertTrue(dashboard.automationBoundary.rules.contains(where: {
            $0.id == "automation-memory" &&
            $0.statusLabel == "Blocked safely"
        }))
        XCTAssertTrue(dashboard.automationBoundary.footer.contains("does not execute"))
    }

    func testD19WhatAmbitionsKnowsNamesMemoryFreshnessUseAndSafeControls() async throws {
        let repositories = try await makeRepositories()
        try await repositories.teaching.saveSignals([
            GoalTeachingSignal(
                id: "teaching-d19",
                goalID: "goal-1",
                createdAt: "2026-04-27T10:00:00Z",
                updatedAt: "2026-04-27T10:00:00Z",
                source: .explicitManualCorrection,
                kind: .energyFitCorrection,
                disposition: .active,
                anchor: GoalTeachingStableAnchor(
                    artifactKind: .energyEvaluation,
                    canonicalField: nil,
                    candidateID: nil,
                    stageID: nil,
                    stepID: "step-1",
                    targetFingerprint: "energy::step-1",
                    contradictionCode: nil,
                    contradictionArtifactRefs: []
                ),
                payload: .energyFit(.init(correctedDisposition: .lighterVersionNeeded)),
                applicationKey: "goal##energy##step",
                userNote: "Use a lighter version"
            )
        ])
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()
        let groups = dashboard.memoryControls.groups
        let items = groups.flatMap(\.items)
        let actions = items.flatMap(\.actions)

        XCTAssertEqual(dashboard.memoryControls.title, "What Ambitions Knows")
        XCTAssertEqual(groups.map(\.id), ["memory-group-current", "memory-group-corrections"])
        XCTAssertTrue(items.contains(where: {
            $0.id == "memory-item-ledger" &&
            $0.sourceLabel == "Event Ledger" &&
            $0.usedFor.contains("Why Changed") &&
            $0.privacyLabel == "Private by default"
        }))
        XCTAssertTrue(items.contains(where: {
            $0.id == "memory-item-proof-feedback" &&
            $0.freshness == .mayNeedReview &&
            $0.usedFor.contains("Goal Weather")
        }))
        XCTAssertTrue(items.contains(where: {
            $0.id == "memory-item-corrections" &&
            $0.freshness == .current &&
            $0.privacyLabel == "Correctable"
        }))
        XCTAssertTrue(actions.contains(where: {
            $0.id == "delete-teaching" &&
            $0.statusLabel == "Needs confirmation" &&
            $0.detail.contains("Deletion is not claimed")
        }))
        XCTAssertTrue(actions.contains(where: {
            $0.id == "pause-proof" &&
            $0.statusLabel == "Review later"
        }))
        XCTAssertTrue(dashboard.memoryControls.recoverySummary.contains("Broad delete, forget, and pause controls remain confirmation-gated"))
        XCTAssertFalse(dashboard.memoryControls.footer.localizedCaseInsensitiveContains("confidence"))
        XCTAssertFalse(dashboard.memoryControls.footer.localizedCaseInsensitiveContains("cloud memory"))
    }

    func testCorrectionsAndLedgerCountsUseExistingLocalRepositories() async throws {
        let repositories = try await makeRepositories()
        try await repositories.teaching.saveSignals([
            GoalTeachingSignal(
                id: "teaching-1",
                goalID: "goal-1",
                createdAt: "2026-04-27T10:00:00Z",
                updatedAt: "2026-04-27T10:00:00Z",
                source: .explicitManualCorrection,
                kind: .energyFitCorrection,
                disposition: .active,
                anchor: GoalTeachingStableAnchor(
                    artifactKind: .energyEvaluation,
                    canonicalField: nil,
                    candidateID: nil,
                    stageID: nil,
                    stepID: "step-1",
                    targetFingerprint: "energy::step-1",
                    contradictionCode: nil,
                    contradictionArtifactRefs: []
                ),
                payload: .energyFit(.init(correctedDisposition: .lighterVersionNeeded)),
                applicationKey: "goal##energy##step",
                userNote: "Use a lighter version"
            )
        ])
        try await repositories.eventLedger.append(
            EventLedgerEntry(
                id: "ledger-correction",
                kind: .userCorrectionAdded,
                occurredAt: "2026-04-27T10:01:00Z",
                source: .you,
                title: "Correction recorded",
                summary: "Use a lighter version.",
                tone: .correction,
                privacy: .standard,
                localOnly: true
            )
        )
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertTrue(dashboard.memoryControls.items.contains(where: { $0.id == "profile-memory-corrections" && $0.valueLabel == "1 local" }))
        XCTAssertTrue(dashboard.assumptionCorrections.items.contains(where: { $0.id == "profile-correction-active" && $0.valueLabel == "1 active" }))
        XCTAssertTrue(dashboard.assumptionCorrections.items.contains(where: { $0.id == "profile-correction-ledger" && $0.valueLabel == "1 recent" }))
        XCTAssertTrue(dashboard.contextVault.items.contains(where: { $0.id == "profile-vault-signals" && $0.detail.contains("1 recent ledger events") }))
    }

    func testTopLevelShellStillExcludesLegacyProfileInsightsAndHabitsTabs() {
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Plan", "You"])
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Profile"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Insights"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Habits"))
    }
}

private extension ProfileFeatureServiceTests {
    func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }
}

private struct StaticProfileSyncCapability: SyncCapability {
    let status: SyncCapabilityStatus

    func status() async -> SyncCapabilityStatus {
        status
    }
}

private struct StaticProfileNotificationService: NotificationServicing {
    let state: NotificationAuthorizationState

    func currentAuthorizationState() async -> NotificationAuthorizationState {
        state
    }

    func registerCategories() async {}
    func requestAuthorizationOptIn() async -> Bool { false }
    func refreshSchedule(now: Date) async { _ = now }
}
