import XCTest
@testable import Ambitions

final class AppShellNavigationTests: XCTestCase {
    func testCanonicalTopLevelTabsMatchProductSpec() {
        XCTAssertEqual(AppTab.allCases, [.today, .goals, .plan, .insights, .profile])
        XCTAssertFalse(AppTab.allCases.contains(.captures))
        XCTAssertFalse(AppTab.allCases.contains(.habits))
    }

    func testLegacyTabRawValuesRemainDecodableAndNormalizeSafely() {
        XCTAssertEqual(AppTab(rawValue: "captures"), .captures)
        XCTAssertEqual(AppTab(rawValue: "habits"), .habits)
        XCTAssertEqual(AppTab.captures.canonicalTopLevelTab, .plan)
        XCTAssertEqual(AppTab.habits.canonicalTopLevelTab, .plan)
        XCTAssertFalse(AppTab.captures.isCanonicalTopLevel)
        XCTAssertFalse(AppTab.habits.isCanonicalTopLevel)
    }

    @MainActor
    func testNavigationInitializesLegacyCapturesPreferenceIntoPlanInboxRoute() {
        let navigation = AppNavigationModel(selectedTab: .captures)

        XCTAssertEqual(navigation.selectedTab, .plan)
        XCTAssertEqual(navigation.planPath, [.capturesInbox])
        XCTAssertTrue(navigation.insightsPath.isEmpty)
    }

    @MainActor
    func testNavigationInitializesLegacyHabitsPreferenceIntoPlanHabitsRoute() {
        let navigation = AppNavigationModel(selectedTab: .habits)

        XCTAssertEqual(navigation.selectedTab, .plan)
        XCTAssertEqual(navigation.planPath, [.habits])
        XCTAssertTrue(navigation.insightsPath.isEmpty)
    }

    @MainActor
    func testShellOverlayRoutesStayOwnedByTheShellLayer() {
        let navigation = AppNavigationModel(selectedTab: .today)

        navigation.presentOverlay(.memoryLens)

        XCTAssertEqual(navigation.activeOverlay, .memoryLens)
        XCTAssertEqual(navigation.selectedTab, .today)
    }

    func testStoredLegacyPreferredTabsLoadIntoCanonicalPreferences() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let appState = SwiftDataAppStateRepository(store: store)
        var state = AppStateSnapshot.default
        state.preferredTab = .habits
        try await appState.saveState(state)

        let preferences = try await RepositoryBackedAppPreferencesStore(appStateRepository: appState).loadPreferences()

        XCTAssertEqual(preferences.preferredTab, .plan)
    }
}
