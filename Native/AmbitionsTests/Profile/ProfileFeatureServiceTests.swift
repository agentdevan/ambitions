import XCTest
@testable import Ambitions

final class ProfileFeatureServiceTests: XCTestCase {
    func testDashboardCopyStatesCurrentNativeTruthWithoutOverclaimingExternalSurfaces() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertTrue(dashboard.subtitle.contains("local-only"))
        XCTAssertTrue(dashboard.trustSection.subtitle.contains(ExternalSurfaceTruth.pendingBatch36Validation))
        XCTAssertTrue(dashboard.trustSection.items.contains(where: { $0.id == "profile-trust" && $0.valueLabel == "Ambitions is running in explicit local-only mode." }))
        XCTAssertTrue(dashboard.trustSection.items.contains(where: { $0.id == "profile-notifications" && $0.valueLabel == "Not requested" }))
        XCTAssertTrue(dashboard.trustSection.items.contains(where: { $0.id == "profile-app-intents" && $0.valueLabel == ExternalSurfaceTruth.pendingBatch36Validation }))
        XCTAssertTrue(dashboard.trustSection.items.contains(where: { $0.id == "profile-share-extension" && $0.valueLabel == ExternalSurfaceTruth.notShippedInThisBuild }))
        XCTAssertTrue(dashboard.trustSection.footer?.contains("local-only trust posture") == true)
        XCTAssertTrue(dashboard.trustSection.footer?.contains("validated route claims stay narrow") == true)
        XCTAssertTrue(dashboard.trustSection.footer?.contains("unverified platform surfaces stay conservative") == true)
        XCTAssertFalse(dashboard.subtitle.contains("are available as local device features"))
    }

    func testSavingPreferencesKeepsStorageOnDeviceOnly() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        _ = try await service.saveProfilePreferences(
            ProfilePreferencesUpdate(
                preferredTab: .goals,
                appearancePreference: .dark,
                reviewCadenceDays: 3,
                localOnlyModeEnabled: false
            )
        )

        let state = try await repositories.appState.loadState()
        XCTAssertEqual(state.preferredTab, .goals)
        XCTAssertEqual(state.appearancePreference, .dark)
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

        XCTAssertEqual(dashboard.title, "Your profile")
        XCTAssertEqual(dashboard.initials, "U")
        XCTAssertEqual(dashboard.preferences.appearancePreference, .system)
        XCTAssertTrue(dashboard.preferencesSection.items.contains(where: { $0.id == "profile-appearance" && $0.valueLabel == "System" }))
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

        XCTAssertTrue(dashboard.trustSection.items.contains(where: { $0.id == "profile-trust" && $0.valueLabel == "Injected runtime trust posture." }))
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
        XCTAssertTrue(dashboard.trustSection.items.contains(where: { $0.id == "profile-notifications" && $0.valueLabel == "Allowed" }))
    }

    func testDashboardAddsPlanningSummaryWithoutTurningProfileIntoWorkflow() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertEqual(dashboard.planningSummary.title, "Planning defaults")
        XCTAssertTrue(dashboard.planningSummary.items.contains(where: { $0.id == "profile-plan-review-cadence" }))
        XCTAssertTrue(dashboard.preferencesSection.items.contains(where: { $0.id == "profile-tab" }))
        XCTAssertTrue(dashboard.trustSection.items.contains(where: { $0.id == "profile-widgets" }))
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
