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

    @MainActor
    func testDemoTodaySurfaceProvidesGoalDetailRouteThatOpensInGoalsShell() async throws {
        let container = try await demoContainer()
        let experience = try await container.todayService.loadTodayExperience(
            userDisplayName: container.session.userDisplayName,
            now: .now
        )
        let target = try XCTUnwrap(todayGoalDetailTarget(from: experience))

        _ = try await container.goalsService.loadDetail(target: target)
        container.navigation.openGoalDetail(target)

        XCTAssertEqual(container.navigation.selectedTab, .goals)
        XCTAssertEqual(container.navigation.goalsPath, [target])
    }

    @MainActor
    func testDemoGoalsSurfaceProvidesGoalDetailRouteThatOpensInGoalsShell() async throws {
        let container = try await demoContainer()
        let overview = try await container.goalsService.loadOverview()
        let target = try XCTUnwrap(overview.items.first?.target)

        _ = try await container.goalsService.loadDetail(target: target)
        container.navigation.openGoalDetail(target)

        XCTAssertEqual(container.navigation.selectedTab, .goals)
        XCTAssertEqual(container.navigation.goalsPath, [target])
    }

    @MainActor
    func testDemoPlanSurfaceProvidesGoalDetailRouteThatOpensInGoalsShell() async throws {
        let container = try await demoContainer()
        let dashboard = try await container.planService.loadPlanDashboard(now: .now)
        let target = try XCTUnwrap(dashboard.goalShapingItems.first?.target)

        _ = try await container.goalsService.loadDetail(target: target)
        container.navigation.openGoalDetail(target)

        XCTAssertEqual(container.navigation.selectedTab, .goals)
        XCTAssertEqual(container.navigation.goalsPath, [target])
    }

    @MainActor
    func testDemoInsightsSurfaceProvidesGoalDetailRouteThatOpensInGoalsShell() async throws {
        let container = try await demoContainer()
        let dashboard = try await container.insightsService.loadInsightsDashboard()
        let target = try XCTUnwrap(dashboard.goalStatuses.first?.target)

        _ = try await container.goalsService.loadDetail(target: target)
        container.navigation.openGoalDetail(target)

        XCTAssertEqual(container.navigation.selectedTab, .goals)
        XCTAssertEqual(container.navigation.goalsPath, [target])
    }

    @MainActor
    private func demoContainer() async throws -> AppContainer {
        try await AppContainerFactory.make(configuration: .demo)
    }

    private func todayGoalDetailTarget(from experience: TodayExperience) -> GoalRouteTarget? {
        if let target = todayGoalDetailTarget(from: experience.focus) {
            return target
        }

        if let action = experience.milestone.action, action.kind == .openDetail {
            return GoalRouteTarget(goalID: action.target.goalID, draftID: action.target.draftID)
        }

        if let action = experience.reflection.actions.first(where: { $0.kind == .openDetail }) {
            return GoalRouteTarget(goalID: action.target.goalID, draftID: action.target.draftID)
        }

        return nil
    }

    private func todayGoalDetailTarget(from focus: TodayFocusState) -> GoalRouteTarget? {
        let actions: [TodayInlineAction]

        switch focus {
        case let .planned(state):
            actions = state.actions
        case let .starter(state):
            actions = state.actions
        case let .clarification(state):
            actions = state.actions
        case let .blocked(state):
            actions = state.actions
        case let .empty(state):
            actions = state.actions
        }

        guard let action = actions.first(where: { $0.kind == .openDetail || $0.kind == .askForHelp }) else {
            return nil
        }

        return GoalRouteTarget(
            goalID: action.target.goalID,
            draftID: action.target.draftID,
            launchContext: action.kind == .askForHelp ? .help : .standard
        )
    }
}
