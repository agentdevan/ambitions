import XCTest
@testable import Ambitions

final class ProfileFeatureServiceTests: XCTestCase {
    func testDashboardCopyStatesCurrentNativeTruthWithoutOverclaimingExternalSurfaces() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertTrue(dashboard.hero.subtitle.contains("Configuration"))
        XCTAssertTrue(dashboard.trustCenter.pulse.subtitle.contains("Local-first"))
        XCTAssertTrue(dashboard.trustCenter.items.contains(where: { $0.id == "profile-trust-sync" && $0.valueLabel == "Ambitions is running in explicit local-only mode." }))
        XCTAssertTrue(dashboard.integrationsSection.items.contains(where: { $0.id == "profile-integration-notifications" && $0.valueLabel == "Not requested" }))
        XCTAssertTrue(dashboard.integrationsSection.items.contains(where: { $0.id == "profile-integration-shortcuts" && $0.valueLabel == ExternalSurfaceTruth.productizedNeedsPlatformReview }))
        XCTAssertTrue(dashboard.integrationsSection.items.contains(where: { $0.id == "profile-integration-share" && $0.valueLabel == ExternalSurfaceTruth.productizedNeedsPlatformReview }))
        XCTAssertTrue(dashboard.trustCenter.footer.contains("states what is local now"))
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

        XCTAssertEqual(dashboard.contextVault.title, "Context Vault")
        XCTAssertTrue(dashboard.contextVault.items.contains(where: { $0.id == "profile-vault-planning" }))
        XCTAssertTrue(dashboard.defaultsSection.items.contains(where: { $0.id == "profile-default-tab" }))
        XCTAssertTrue(dashboard.integrationsSection.items.contains(where: { $0.id == "profile-integration-widgets" }))
        XCTAssertEqual(dashboard.appearanceStudio.title, "Appearance Studio")
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
