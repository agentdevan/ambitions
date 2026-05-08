import XCTest
@testable import Ambitions

final class ProfileFeatureServiceTests: XCTestCase {
    func testDashboardCopyStatesCurrentNativeTruthWithoutOverclaimingExternalSurfaces() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertTrue(dashboard.hero.subtitle.contains("Your System"))
        XCTAssertTrue(dashboard.trustCenter.pulse.subtitle.contains("Local-first"))
        XCTAssertTrue(dashboard.trustCenter.items.contains(where: { $0.id == "profile-trust-sync" && $0.valueLabel == "Ambitions is running in explicit local-only mode." }))
        XCTAssertTrue(dashboard.trustCenter.items.contains(where: { $0.id == "profile-trust-accessibility" && $0.valueLabel == "Claims locked" }))
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

        XCTAssertEqual(dashboard.hero.title, "Your System")
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

    func testFCP24AppearanceStudioPreviewsRealAmbitionsObjectsWithoutThemeShopClaims() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()
        let studio = dashboard.appearanceStudio

        XCTAssertEqual(studio.previewSwatches.map(\.id), [
            "preview-now",
            "preview-rail",
            "preview-lifeshape",
            "preview-receipt"
        ])
        XCTAssertEqual(studio.previewSwatches.map(\.objectKind), [
            .startHere,
            .realityRail,
            .lifeShape,
            .receiptDrawer
        ])
        XCTAssertTrue(studio.previewSwatches.contains(where: { $0.title == "Start Here" }))
        XCTAssertTrue(studio.previewSwatches.contains(where: { $0.title == "Reality Meridian" }))
        XCTAssertTrue(studio.previewSwatches.contains(where: { $0.title == "LifeShape" }))
        XCTAssertTrue(studio.previewSwatches.contains(where: { $0.title == "Receipt Drawer" }))
        XCTAssertTrue(studio.previewSummary.contains("real Ambitions objects"))

        let visibleCopy = ([studio.title, studio.subtitle, studio.previewSummary, studio.footer] +
            studio.previewSwatches.flatMap { [$0.title, $0.subtitle, $0.eyebrow, $0.accessibilityLabel] })
            .joined(separator: " ")

        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("theme shop"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("personality"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("behavior"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("skin store"))
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

    func testEB10PersonalOperatingManualNamesPreferenceMemoryBoundaries() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()
        let rules = dashboard.constitution.rules

        XCTAssertTrue(rules.contains(where: {
            $0.id == "constitution-low-risk-preferences" &&
            $0.detail.contains("Display, density, recovery, and repeated routing preferences") &&
            $0.detail.contains("visible, source-tied, and correctable") &&
            $0.statusLabel == "Receipt first"
        }))
        XCTAssertTrue(rules.contains(where: {
            $0.id == "constitution-sensitive-memory" &&
            $0.detail.contains("Health, relationship, financial, location, calendar-derived") &&
            $0.statusLabel == "Approval required"
        }))
        XCTAssertTrue(rules.contains(where: {
            $0.id == "constitution-operating-manual-evidence" &&
            $0.detail.contains("must admit when context is thin") &&
            $0.statusLabel == "Evidence-light"
        }))
        XCTAssertFalse(rules.map(\.detail).joined(separator: " ").localizedCaseInsensitiveContains("cloud memory"))
        XCTAssertFalse(rules.map(\.detail).joined(separator: " ").localizedCaseInsensitiveContains("automatic profile"))
    }

    func testD17SystemCenterGroupsYouWithoutAddingTopLevelTabsOrOverclaiming() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()
        let items = dashboard.systemCenter.sections.flatMap(\.items)
        let titles = items.map(\.title)

        XCTAssertEqual(dashboard.systemCenter.title, "Your System")
        XCTAssertTrue(dashboard.systemCenter.subtitle.contains("User System Profile"))
        XCTAssertEqual(titles, [
            "Schedule & Availability",
            "Time Behavior",
            "Trust & Automation",
            "Vacation / Away Time",
            "Durations",
            "What Ambitions Knows",
            "Trust Center",
            "Receipts & History",
            "Corrections",
            "Reviews",
            "Proof",
            "Archive / Completed",
            "About You",
            "Personalization",
            "Appearance",
            "Notifications",
            "Integrations",
            "Widgets / Live Activities / Shortcuts",
            "Export / Import",
            "Accessibility",
            "Help / Support",
            "About"
        ])
        XCTAssertEqual(dashboard.systemCenter.sections.map(\.id), [
            "planning-behavior",
            "memory-and-trust",
            "reviews-and-progress",
            "personal-defaults",
            "system-edges",
            "accessibility-and-support"
        ])
        XCTAssertEqual(dashboard.systemCenter.sections.first?.title, "Planning Setup")
        XCTAssertTrue(dashboard.systemCenter.footer.contains("without changing anything silently"))
        XCTAssertTrue(items.allSatisfy { !$0.accessibilityHint.isEmpty })
        XCTAssertTrue(items.contains(where: {
            $0.id == "appearance" &&
            $0.title == "Appearance"
        }))
        XCTAssertTrue(items.contains(where: {
            $0.id == "what-ambitions-knows" &&
            $0.title == "What Ambitions Knows"
        }))
        XCTAssertTrue(items.contains(where: {
            $0.id == "export-import" &&
            $0.statusLabel == "Manual"
        }))
        XCTAssertTrue(items.contains(where: {
            $0.id == "automation-trust" &&
            $0.statusLabel == "Guided"
        }))
        XCTAssertTrue(items.contains(where: {
            $0.id == "vacation-away-time" &&
            $0.statusLabel == "Unavailable"
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
            $0.id == "trust-route-why-this" &&
            $0.title == "Why This?" &&
            $0.statusLabel == "Explain first" &&
            $0.subtitle.contains("source, reason, uncertainty, user control, and receipt behavior")
        }))
        XCTAssertTrue(routes.contains(where: {
            $0.id == "trust-route-quiet-reflow" &&
            $0.statusLabel == "Preview first" &&
            $0.subtitle.contains("manual planning remains available")
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

    func testEB14TrustCenterDataMapNamesSourcesControlsAndFutureOwnedEdges() async throws {
        let repositories = try await makeRepositories()
        try await repositories.eventLedger.append(
            EventLedgerEntry(
                id: "ledger-eb14",
                kind: .userCorrectionAdded,
                occurredAt: "2026-05-03T23:40:00Z",
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
        let dataMap = dashboard.trustCenter.dataMap

        XCTAssertEqual(dataMap.map(\.id), [
            "trust-data-map-local-context",
            "trust-data-map-permissions",
            "trust-data-map-receipts",
            "trust-data-map-future-owned"
        ])
        XCTAssertTrue(dataMap.contains(where: {
            $0.id == "trust-data-map-local-context" &&
            $0.dataTypes.contains("Goals, captures, proof") &&
            $0.controlLabel == "Inspect and correct from owning surfaces" &&
            $0.privacyLabel == "Private by default"
        }))
        XCTAssertTrue(dataMap.contains(where: {
            $0.id == "trust-data-map-permissions" &&
            $0.privacyLabel == "No silent calendar writes"
        }))
        XCTAssertTrue(dataMap.contains(where: {
            $0.id == "trust-data-map-future-owned" &&
            $0.controlLabel == "Blocked until owner batch proves safety" &&
            $0.privacyLabel == "No hidden account or cloud claim"
        }))
        XCTAssertFalse(dataMap.map(\.sourceLabel).joined(separator: " ").localizedCaseInsensitiveContains("synced everywhere"))
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
        XCTAssertEqual(dashboard.memoryControls.consent.title, "Personalization consent")
        XCTAssertEqual(dashboard.memoryControls.consent.sourceLabel, "Based on local records")
        XCTAssertEqual(dashboard.memoryControls.consent.sensitiveMemoryLabel, "Sensitive memory requires approval")
        XCTAssertEqual(dashboard.memoryControls.consent.hiddenMemoryLabel, "No hidden memory creation")
        XCTAssertEqual(dashboard.memoryControls.consent.controlLabel, "You are in control")
        XCTAssertEqual(dashboard.memoryControls.privateModeControls.map(\.id), [
            "private-mode-compact-detail",
            "private-mode-external-surfaces",
            "private-mode-sensitive-memory",
            "private-mode-destructive-controls"
        ])
        XCTAssertTrue(dashboard.memoryControls.privateModeControls.contains(where: {
            $0.id == "private-mode-sensitive-memory" &&
            $0.statusLabel == "Approval required" &&
            $0.privacyLabel == "No sensitive inference" &&
            $0.controlLabel == "Review first"
        }))
        XCTAssertTrue(dashboard.memoryControls.privateModeControls.contains(where: {
            $0.id == "private-mode-destructive-controls" &&
            $0.statusLabel == "Future-owned" &&
            $0.privacyLabel == "No silent deletion" &&
            $0.controlLabel == "Blocked safely"
        }))
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
            $0.usedFor.contains("progress summaries")
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
            $0.id == "reject-teaching" &&
            $0.statusLabel == "Review first" &&
            $0.detail.contains("receipt-backed rejection")
        }))
        XCTAssertTrue(actions.contains(where: {
            $0.id == "pause-proof" &&
            $0.statusLabel == "Review later"
        }))
        XCTAssertTrue(dashboard.memoryControls.recoverySummary.contains("Broad delete, forget, and pause controls remain confirmation-gated"))
        XCTAssertFalse(dashboard.memoryControls.footer.localizedCaseInsensitiveContains("confidence"))
        XCTAssertFalse(dashboard.memoryControls.footer.localizedCaseInsensitiveContains("cloud memory"))
    }

    func testM08NarrativeMemoryUsesExplicitLocalEvidenceAndReviewableControls() async throws {
        let repositories = try await makeRepositories()
        try await repositories.teaching.saveSignals([
            GoalTeachingSignal(
                id: "teaching-m08",
                goalID: "goal-1",
                createdAt: "2026-04-28T10:00:00Z",
                updatedAt: "2026-04-28T10:00:00Z",
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
                id: "ledger-m08-correction",
                kind: .userCorrectionAdded,
                occurredAt: "2026-04-28T10:01:00Z",
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
        let narrative = try XCTUnwrap(dashboard.memoryControls.narrativeMemories.first(where: { $0.id == "narrative-memory-corrections" }))
        let pattern = try XCTUnwrap(dashboard.memoryControls.conservativePatterns.first(where: { $0.id == "memory-pattern-corrections" }))

        XCTAssertEqual(narrative.freshness, .current)
        XCTAssertEqual(narrative.sourceLabel, "Manual corrections")
        XCTAssertEqual(narrative.sensitiveStatusLabel, "No sensitive inference")
        XCTAssertTrue(narrative.usedFor.contains("Why Changed"))
        XCTAssertTrue(narrative.actions.contains(where: { $0.id == "narrative-correct" && $0.statusLabel == "Use owning surface" }))
        XCTAssertTrue(narrative.actions.contains(where: { $0.id == "narrative-reject" && $0.statusLabel == "Review first" }))
        XCTAssertTrue(narrative.actions.contains(where: { $0.id == "narrative-delete" && $0.statusLabel == "Needs confirmation" }))
        XCTAssertTrue(narrative.actions.contains(where: { $0.id == "narrative-pause" && $0.statusLabel == "Review later" }))
        XCTAssertEqual(pattern.reviewLabel, "Review before reuse")
        XCTAssertTrue(pattern.summary.contains("user-confirmed correction"))
        XCTAssertFalse(dashboard.memoryControls.footer.localizedCaseInsensitiveContains("confidence"))
        XCTAssertFalse(dashboard.memoryControls.footer.localizedCaseInsensitiveContains("black-box"))
        XCTAssertFalse(dashboard.memoryControls.conservativePatterns.map(\.summary).joined(separator: " ").localizedCaseInsensitiveContains("black-box"))
        XCTAssertFalse(dashboard.memoryControls.narrativeMemories.map(\.summary).joined(separator: " ").localizedCaseInsensitiveContains("sensitive identity"))
    }

    func testEB11MemoryControlsExposeCorrectionDeletionAndRejectionBoundaries() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()
        let rejected = try XCTUnwrap(dashboard.memoryControls.items.first(where: { $0.id == "profile-memory-rejected" }))
        let correctionActions = dashboard.memoryControls.groups
            .flatMap(\.items)
            .first(where: { $0.id == "memory-item-corrections" })?
            .actions ?? []

        XCTAssertEqual(rejected.title, "Rejected memory")
        XCTAssertEqual(rejected.valueLabel, "Review first")
        XCTAssertTrue(rejected.subtitle?.contains("source-tied") ?? false)
        XCTAssertTrue(rejected.subtitle?.contains("durable rejection rules wait") ?? false)
        XCTAssertTrue(correctionActions.contains(where: {
            $0.id == "correct-teaching" &&
            $0.statusLabel == "Available when present"
        }))
        XCTAssertTrue(correctionActions.contains(where: {
            $0.id == "reject-teaching" &&
            $0.detail.contains("receipt-backed rejection")
        }))
        XCTAssertTrue(correctionActions.contains(where: {
            $0.id == "delete-teaching" &&
            $0.detail.contains("Deletion is not claimed")
        }))
        XCTAssertTrue(dashboard.memoryControls.footer.contains("durable rejected-memory rules remain manual/future"))
    }

    func testEB12MemoryReceiptsExplainWhyRememberedThisWithoutDurableReceiptClaims() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()
        let memoryReceipt = try XCTUnwrap(dashboard.receiptAudit.items.first(where: { $0.id == "profile-receipts-memory" }))

        XCTAssertEqual(memoryReceipt.title, "Memory receipts")
        XCTAssertEqual(memoryReceipt.valueLabel, "Evidence-light")
        XCTAssertTrue(memoryReceipt.subtitle?.contains("Why remembered this") ?? false)
        XCTAssertTrue(memoryReceipt.subtitle?.contains("source, freshness, use, privacy posture") ?? false)
        XCTAssertTrue(memoryReceipt.subtitle?.contains("correction or delete availability") ?? false)
        XCTAssertFalse(memoryReceipt.subtitle?.localizedCaseInsensitiveContains("synced") ?? true)
        XCTAssertFalse(memoryReceipt.subtitle?.localizedCaseInsensitiveContains("permanent") ?? true)
    }

    func testFCP23MemoryLensVisualLayerShowsSourceAgeWhyRememberedAndPrivacyShutters() async throws {
        let repositories = try await makeRepositories()
        try await repositories.evidence.saveEvidence([
            ProgressEvidence(
                id: "proof-fcp23",
                goalID: "goal-fcp23",
                stepID: "step-fcp23",
                evidenceKind: .stepCompleted,
                source: .manual,
                capturedAt: "2026-05-05T12:00:00Z",
                progressDelta: nil,
                confidenceDelta: nil,
                minutesInvested: 15,
                note: "Grounded recall proof."
            )
        ])
        try await repositories.captures.saveCaptures([
            Capture(
                id: "capture-fcp23",
                createdAt: "2026-05-05T12:05:00Z",
                updatedAt: "2026-05-05T12:05:00Z",
                rawText: "Renew passport before the trip",
                sourceType: nil,
                status: .needsTriage,
                linkedGoalID: nil
            )
        ])
        try await repositories.teaching.saveSignals([
            GoalTeachingSignal(
                id: "teaching-fcp23",
                goalID: "goal-fcp23",
                createdAt: "2026-05-05T12:10:00Z",
                updatedAt: "2026-05-05T12:10:00Z",
                source: .explicitManualCorrection,
                kind: .energyFitCorrection,
                disposition: .active,
                anchor: GoalTeachingStableAnchor(
                    artifactKind: .energyEvaluation,
                    canonicalField: nil,
                    candidateID: nil,
                    stageID: nil,
                    stepID: "step-fcp23",
                    targetFingerprint: "energy::step-fcp23",
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
        let lensItems = dashboard.memoryControls.memoryLensItems
        let visibleCopy = lensItems.map {
            [
                $0.title,
                $0.summary,
                $0.sourceLabel,
                $0.sourceAgeLabel,
                $0.whyRemembered,
                $0.privacyShutterLabel,
                $0.reviewLabel,
                $0.correctionLabel,
                $0.rejectionLabel
            ].joined(separator: " ")
        }.joined(separator: " ")

        XCTAssertEqual(lensItems.map(\.id), [
            "memory-lens-current-plan",
            "memory-lens-corrections",
            "memory-lens-open-captures"
        ])
        XCTAssertTrue(lensItems.contains(where: {
            $0.id == "memory-lens-current-plan" &&
                $0.sourceAgeLabel == "Current" &&
                $0.privacyShutterLabel == "Summary only" &&
                $0.reviewLabel == "Safe for context recall"
        }))
        XCTAssertTrue(lensItems.contains(where: {
            $0.id == "memory-lens-corrections" &&
                $0.whyRemembered.contains("prevent repeated bad assumptions") &&
                $0.reviewLabel == "Review before durable memory" &&
                $0.rejectionLabel == "Deletion waits for receipt proof"
        }))
        XCTAssertTrue(lensItems.contains(where: {
            $0.id == "memory-lens-open-captures" &&
                $0.sourceLabel == "Captured thought" &&
                $0.correctionLabel == "Edit in Capture" &&
                $0.rejectionLabel == "Archive from Capture"
        }))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("omniscient"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("cloud memory"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("durable delete"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("AI confidence"))
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

    func testPD15TrustHistoryCenterDistinguishesReceiptsProofSourceChangesPrivacyAndAutomation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.evidence.saveEvidence([
            ProgressEvidence(
                id: "proof-pd15",
                goalID: "goal-pd15",
                stepID: "step-pd15",
                evidenceKind: .stepCompleted,
                source: .manual,
                capturedAt: "2026-05-05T04:00:00Z",
                progressDelta: nil,
                confidenceDelta: nil,
                minutesInvested: 25,
                note: "Saved one local proof point."
            )
        ])
        try await repositories.eventLedger.append(
            EventLedgerEntry(
                id: "ledger-pd15-review",
                kind: .planRecovered,
                occurredAt: "2026-05-05T04:01:00Z",
                source: .plan,
                title: "Plan recovery recorded",
                summary: "A smaller plan shape was kept for review.",
                tone: .recovering,
                trust: EventLedgerTrustMetadata(isUserConfirmed: true, requiresReview: true),
                privacy: .privateUserText,
                localOnly: true
            )
        )
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()
        let history = dashboard.trustHistoryCenter
        let categories = Set(history.items.map(\.category))
        let visibleCopy = ([history.title, history.subtitle, history.footer] + history.items.flatMap {
            [$0.title, $0.summary, $0.sourceLabel, $0.reviewLabel, $0.privacyLabel, $0.reversibilityLabel]
        }).joined(separator: " ")

        XCTAssertEqual(history.title, "Trust History")
        XCTAssertTrue(categories.isSuperset(of: Set(ProfileTrustHistoryCategory.allCases)))
        XCTAssertTrue(history.items.contains(where: {
            $0.category == .receipts &&
            $0.sourceLabel.hasPrefix("Source:") &&
            ($0.reversibilityLabel.localizedCaseInsensitiveContains("undo") || $0.reviewLabel.localizedCaseInsensitiveContains("review"))
        }))
        XCTAssertTrue(history.items.contains(where: {
            $0.category == .proof &&
            $0.summary.contains("1 proof records") &&
            $0.summary.contains("without turning proof into performance copy")
        }))
        XCTAssertTrue(history.items.contains(where: {
            $0.category == .changes &&
            $0.sourceLabel == "Source: Plan" &&
            $0.privacyLabel == "Private detail hidden" &&
            $0.reviewLabel == "Review source"
        }))
        XCTAssertTrue(history.items.contains(where: {
            $0.category == .sourceReview &&
            $0.privacyLabel == "Review boundary only" &&
            $0.reviewLabel == "Review source"
        }))
        XCTAssertTrue(history.items.contains(where: {
            $0.category == .privacy &&
            $0.reversibilityLabel == "No destructive action from this center"
        }))
        XCTAssertTrue(history.items.contains(where: {
            $0.category == .automation &&
            $0.summary.contains("confirmation-gated or blocked") &&
            $0.privacyLabel == "Permission posture only"
        }))
        XCTAssertTrue(history.footer.contains("not a feed"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("activity feed"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("notification feed"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("AI confidence"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("AI verified"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("AI certification"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("productivity loss"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("surveillance"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("trophy"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("achievement"))
    }

    func testPD16PlanningDefaultsCenterExplainsWhySetupMattersWithoutPressure() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()
        let center = dashboard.planningDefaultsCenter
        let sectionIDs = center.sections.map(\.id)
        let visibleCopy = ([center.title, center.subtitle, center.footer] + center.sections.flatMap { section in
            [section.title, section.subtitle, section.footer] + section.preferences.flatMap {
                [$0.title, $0.whyItMatters, $0.statusLabel, $0.privacyLabel, $0.defaultLabel ?? "", $0.accessibilityHint]
            }
        }).joined(separator: " ")

        XCTAssertEqual(sectionIDs, [
            "schedule-availability",
            "planning-defaults",
            "vacation-away-time",
            "automation-trust"
        ])
        XCTAssertTrue(center.subtitle.contains("without treating setup as homework"))
        XCTAssertTrue(visibleCopy.contains("Calendar awareness is Plan-owned"))
        XCTAssertTrue(visibleCopy.contains("Open time is not automatically filled"))
        XCTAssertTrue(visibleCopy.contains("Vacation is not free time by default"))
        XCTAssertTrue(visibleCopy.contains("Per-vacation override"))
        XCTAssertTrue(visibleCopy.contains("Guided automation"))
        XCTAssertTrue(visibleCopy.contains("Ambitions proposes first and asks before consequential changes"))
        XCTAssertTrue(visibleCopy.contains("This center explains the default. It does not execute calendar writes, permission requests, or broad reflow."))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("calendar sync"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("calendar written"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("AI confidence"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("AI verified"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("productivity score"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("permission grab"))
    }

    func testFCP17AvailabilityCenterProtectsHardContextAndTrustDefaults() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()
        let center = dashboard.availabilityCenter
        let visibleCopy = (
            [center.title, center.subtitle, center.footer] +
            center.hardContextStack.flatMap(itemCopy) +
            center.protectedPocketMap.flatMap(itemCopy) +
            center.planningDefaults.flatMap(itemCopy) +
            center.automationTrustControls.flatMap(itemCopy) +
            center.durationSourceProof.flatMap(itemCopy) +
            center.vacationAwayBehavior.flatMap(itemCopy)
        ).joined(separator: " ")

        XCTAssertEqual(center.title, "Availability Center")
        XCTAssertTrue(visibleCopy.contains("Committed blocks, sleep, care, commute, and buffers win"))
        XCTAssertTrue(visibleCopy.contains("Open time is not auto-filled"))
        XCTAssertTrue(visibleCopy.contains("Day, Week, and Month are capacity lenses"))
        XCTAssertTrue(visibleCopy.contains("Guided automation"))
        XCTAssertTrue(visibleCopy.contains("Calendar writes require confirmation"))
        XCTAssertTrue(visibleCopy.contains("Vacation is not free time by default"))
        XCTAssertTrue(visibleCopy.contains("does not request permissions, write calendars, auto-fill open time, or run broad reflow"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("auto-scheduler"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("calendar clone"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("calendar sync"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("AI confidence"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("productivity score"))
    }

    func testPD17CrossSurfaceProofReviewConnectsOwningSurfacesWithoutNewDashboard() async throws {
        let repositories = try await makeRepositories()
        try await repositories.evidence.saveEvidence([
            ProgressEvidence(
                id: "proof-pd17-step",
                goalID: "goal-pd17",
                stepID: "step-pd17",
                evidenceKind: .stepCompleted,
                source: .manual,
                capturedAt: "2026-05-05T09:00:00Z",
                progressDelta: nil,
                confidenceDelta: nil,
                minutesInvested: 20,
                note: nil
            )
        ])
        try await repositories.eventLedger.append(
            EventLedgerEntry(
                id: "ledger-pd17-plan",
                kind: .planRecovered,
                occurredAt: "2026-05-05T09:05:00Z",
                source: .plan,
                planID: "plan-pd17",
                title: "Plan recovery recorded",
                summary: "Plan kept a smaller shape for review.",
                tone: .recovering,
                trust: EventLedgerTrustMetadata(isUserConfirmed: true, requiresReview: true),
                privacy: .standard,
                localOnly: true
            )
        )
        try await repositories.eventLedger.append(
            EventLedgerEntry(
                id: "ledger-pd17-goal",
                kind: .goalUpdated,
                occurredAt: "2026-05-05T09:06:00Z",
                source: .goals,
                goalID: "goal-pd17",
                title: "Goal changed",
                summary: "Goal change saved as local review context.",
                tone: .positive,
                trust: EventLedgerTrustMetadata(isUserConfirmed: true),
                privacy: .standard,
                localOnly: true
            )
        )
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()
        let state = dashboard.crossSurfaceProofReview
        let itemIDs = state.items.map(\.id)
        let visibleCopy = ([state.title, state.subtitle, state.footer] + state.items.flatMap {
            [$0.title, $0.summary, $0.sourceLabel, $0.reviewLabel, $0.privacyLabel, $0.routeLabel]
        }).joined(separator: " ")

        XCTAssertEqual(itemIDs, [
            "cross-review-capture-goal-proof",
            "cross-review-today-goal-proof",
            "cross-review-plan-reflow-receipt",
            "cross-review-goal-you-history",
            "cross-review-receipt-detail-navigation",
            "cross-review-sparse-prompts"
        ])
        XCTAssertTrue(visibleCopy.contains("Capture to Goal proof"))
        XCTAssertTrue(visibleCopy.contains("Today completion to Goal proof"))
        XCTAssertTrue(visibleCopy.contains("Plan reflow to receipt"))
        XCTAssertTrue(visibleCopy.contains("Goal change to You history"))
        XCTAssertTrue(visibleCopy.contains("Review in Today or Goal Detail"))
        XCTAssertTrue(visibleCopy.contains("Review in Plan or Receipts"))
        XCTAssertTrue(visibleCopy.contains("Receipt, not notification"))
        XCTAssertTrue(visibleCopy.contains("This map does not create a dashboard, raw log, or new tab."))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("activity feed"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("notification feed"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("new top-level tab"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("AI confidence"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("AI verified"))
    }

    func testTopLevelShellStillExcludesLegacyProfileInsightsAndHabitsTabs() {
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Profile"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Insights"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Habits"))
    }
}

private extension ProfileFeatureServiceTests {
    func itemCopy(_ item: ProfileAvailabilityCenterItem) -> [String] {
        [item.title, item.summary, item.statusLabel, item.sourceLabel]
    }

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
