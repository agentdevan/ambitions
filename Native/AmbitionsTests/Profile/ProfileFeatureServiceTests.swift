import XCTest
@testable import Ambitions

final class ProfileFeatureServiceTests: XCTestCase {
    func testDashboardCopyStatesCurrentNativeTruthWithoutOverclaimingExternalSurfaces() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedProfileService(repositories: repositories)

        let dashboard = try await service.loadProfileDashboard()

        XCTAssertTrue(dashboard.subtitle.contains("on-device"))
        XCTAssertTrue(dashboard.subtitle.contains("capture"))
        XCTAssertTrue(dashboard.subtitle.contains("account sync is not implemented"))
        XCTAssertTrue(dashboard.settings.contains(where: { $0.id == "profile-scope" && $0.valueLabel == "Native foundations" }))
        XCTAssertTrue(dashboard.settingsFooter.contains("widget and Live Activity foundations still need validation"))
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
        XCTAssertTrue(dashboard.settings.contains(where: { $0.id == "profile-appearance" && $0.valueLabel == "System" }))
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
