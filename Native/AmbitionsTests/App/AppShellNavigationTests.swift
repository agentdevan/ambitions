import XCTest
@testable import Ambitions

final class AppShellNavigationTests: XCTestCase {
    func testCanonicalTopLevelTabsMatchProductSpec() {
        XCTAssertEqual(AppTab.allCases, [.today, .goals, .capture, .time, .you])
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertEqual(AppTab.allCases.map(\.rawValue), ["today", "goals", "capture", "time", "you"])
        XCTAssertFalse(AppTab.allCases.contains(.habits))
        XCTAssertFalse(AppTab.allCases.contains(.insights))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains { $0.localizedCaseInsensitiveContains("plan") })
    }

    func testLegacyTabRawValuesRemainDecodableAndNormalizeSafely() {
        XCTAssertEqual(AppTab(rawValue: "capture"), .capture)
        XCTAssertEqual(AppTab(rawValue: "captures"), .capture)
        XCTAssertEqual(AppTab(rawValue: "time"), .time)
        XCTAssertEqual(AppTab(rawValue: "plan"), .time)
        XCTAssertEqual(AppTab(rawValue: "you"), .you)
        XCTAssertEqual(AppTab(rawValue: "profile"), .you)
        XCTAssertEqual(AppTab(rawValue: "habits"), .habits)
        XCTAssertEqual(AppTab(rawValue: "insights"), .insights)
        XCTAssertEqual(AppTab.capture.canonicalTopLevelTab, .capture)
        XCTAssertEqual(AppTab.time.canonicalTopLevelTab, .time)
        XCTAssertEqual(AppTab.you.canonicalTopLevelTab, .you)
        XCTAssertEqual(AppTab.habits.canonicalTopLevelTab, .time)
        XCTAssertEqual(AppTab.insights.canonicalTopLevelTab, .you)
        XCTAssertEqual(AppTab.time.rawValue, "time")
        XCTAssertEqual(AppTab.time.title, "Time")
        XCTAssertEqual(AppTab.you.rawValue, "you")
        XCTAssertEqual(AppTab.you.title, "You")
        XCTAssertEqual(AppTab.habits.title, "Rituals")
        XCTAssertEqual(AppTab.insights.title, "History")
        XCTAssertTrue(AppTab.capture.isCanonicalTopLevel)
        XCTAssertTrue(AppTab.time.isCanonicalTopLevel)
        XCTAssertTrue(AppTab.you.isCanonicalTopLevel)
        XCTAssertFalse(AppTab.habits.isCanonicalTopLevel)
        XCTAssertFalse(AppTab.insights.isCanonicalTopLevel)
    }

    func testFCP08ShellPresentationModeDefaultsToMeridianWithNativeRollback() {
        XCTAssertEqual(
            AppShellPresentationMode.resolved(arguments: ["Ambitions"], environment: [:]),
            .meridian
        )

        XCTAssertEqual(
            AppShellPresentationMode.resolved(
                arguments: ["Ambitions", "--ambitions-shell=native"],
                environment: [:]
            ),
            .nativeFallback
        )
    }

    func testShellPresentationModeLaunchArgumentEnablesMeridian() {
        XCTAssertEqual(
            AppShellPresentationMode.resolved(
                arguments: ["Ambitions", "--ambitions-shell=meridian"],
                environment: [:]
            ),
            .meridian
        )

        XCTAssertEqual(
            AppShellPresentationMode.resolved(
                arguments: ["Ambitions", "--ambitions-shell", "meridian"],
                environment: [:]
            ),
            .meridian
        )
    }

    func testShellPresentationModeLaunchArgumentCanRollbackToNativeFallback() {
        XCTAssertEqual(
            AppShellPresentationMode.resolved(
                arguments: ["Ambitions", "--ambitions-shell=native"],
                environment: ["AMBITIONS_SHELL_PRESENTATION": "meridian"]
            ),
            .nativeFallback
        )
    }

    func testShellPresentationModeEnvironmentEnablesMeridian() {
        XCTAssertEqual(
            AppShellPresentationMode.resolved(
                arguments: ["Ambitions"],
                environment: ["AMBITIONS_SHELL_PRESENTATION": "enabled"]
            ),
            .meridian
        )
    }

    func testMeridianDestinationsMirrorCanonicalTabsWithoutNewRouteOwnership() {
        let destinations = AppMeridianDestination.all

        XCTAssertEqual(destinations.map(\.tab), AppTab.allCases)
        XCTAssertEqual(destinations.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertEqual(
            destinations.map(\.accessibilityIdentifier),
            [
                "shell.meridian.destination.today",
                "shell.meridian.destination.goals",
                "shell.meridian.destination.capture",
                "shell.meridian.destination.time",
                "shell.meridian.destination.you"
            ]
        )
        XCTAssertFalse(destinations.map(\.title).contains { $0.localizedCaseInsensitiveContains("plan") })
        XCTAssertFalse(destinations.map(\.accessibilityIdentifier).contains { $0.localizedCaseInsensitiveContains("plan") })
    }

    func testFCP08MeridianShellChromeContractPreservesFiveTabsAndReceiptZone() {
        let chrome = AppMeridianShellChromeState.launchDefault

        XCTAssertEqual(chrome.title, "Ambition Meridian")
        XCTAssertEqual(chrome.destinations.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertTrue(chrome.destinationRailLabel.contains("Today, Goals, Capture, Time, You"))
        XCTAssertTrue(chrome.receiptOverlayZoneLabel.contains("temporary and dismissible"))
        XCTAssertTrue(chrome.globalActionLabel.contains("without changing tabs"))
        XCTAssertTrue(chrome.safeAreaLabel.contains("safe areas"))
        XCTAssertTrue(chrome.rollbackLabel.contains("--ambitions-shell=native"))
        XCTAssertFalse(chrome.accessibilitySummary.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(chrome.accessibilitySummary.localizedCaseInsensitiveContains("AI confidence"))
        XCTAssertFalse(chrome.accessibilitySummary.localizedCaseInsensitiveContains("sixth"))
    }

    @MainActor
    func testMeridianOneTapDestinationsUseCanonicalNavigationSelection() {
        for destination in AppMeridianDestination.all {
            let navigation = AppNavigationModel(selectedTab: .today)
            navigation.presentMemoryLens(source: .shellUtility)

            navigation.selectTab(destination.tab)

            XCTAssertEqual(navigation.selectedTab, destination.tab)
            XCTAssertNil(navigation.activeOverlay)
            XCTAssertTrue(navigation.goalsPath.isEmpty)
            XCTAssertTrue(navigation.timePath.isEmpty)
            XCTAssertTrue(navigation.youPath.isEmpty)
        }
    }

    @MainActor
    func testShellPresentationRollbackDoesNotMutateExistingRouteState() {
        let navigation = AppNavigationModel(selectedTab: .goals)
        navigation.openGoalDetail(goalID: "goal-shell-rollback")

        XCTAssertEqual(
            AppShellPresentationMode.resolved(
                arguments: ["Ambitions", "--ambitions-shell=meridian"],
                environment: [:]
            ),
            .meridian
        )
        XCTAssertEqual(
            AppShellPresentationMode.resolved(
                arguments: ["Ambitions", "--ambitions-shell=native"],
                environment: [:]
            ),
            .nativeFallback
        )
        XCTAssertEqual(navigation.selectedTab, .goals)
        XCTAssertEqual(navigation.goalsPath.first?.goalID, "goal-shell-rollback")
    }

    @MainActor
    func testNavigationInitializesCapturePreferenceIntoTopLevelCaptureRoute() {
        let navigation = AppNavigationModel(selectedTab: .capture)

        XCTAssertEqual(navigation.selectedTab, .capture)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertTrue(navigation.youPath.isEmpty)
    }

    @MainActor
    func testNavigationInitializesLegacyHabitsPreferenceIntoPlanHabitsRoute() {
        let navigation = AppNavigationModel(selectedTab: .habits)

        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertEqual(navigation.timePath, [.habits])
        XCTAssertTrue(navigation.youPath.isEmpty)
    }

    @MainActor
    func testLegacyHabitsSelectionPreservesRitualPlanSemanticsWithoutDuplicateDestination() {
        let navigation = AppNavigationModel(selectedTab: .today)

        navigation.selectTab(.habits)

        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertEqual(navigation.timePath, [.habits])
        XCTAssertTrue(navigation.youPath.isEmpty)
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertFalse(AppTab.allCases.contains(.habits))
        XCTAssertEqual(AppTab(rawValue: "plan"), .time)
        XCTAssertEqual(AppTab.time.rawValue, "time")
        XCTAssertEqual(AppTab.time.title, "Time")
        XCTAssertEqual(AppTab.habits.title, "Rituals")
        XCTAssertEqual(AppTab.habits.canonicalTopLevelTab, .time)
    }

    @MainActor
    func testNavigationInitializesLegacyInsightsPreferenceIntoYouSupportRoute() {
        let navigation = AppNavigationModel(selectedTab: .insights)

        XCTAssertEqual(navigation.selectedTab, .you)
        XCTAssertEqual(navigation.youPath, [.history])
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(AppTab.insights.rawValue, "insights")
        XCTAssertEqual(AppTab.insights.title, "History")
        XCTAssertFalse(AppTab.allCases.contains(.insights))
    }

    @MainActor
    func testLegacyInsightsSelectionPreservesPlanCanonWithoutDuplicateDestination() {
        let navigation = AppNavigationModel(selectedTab: .today)

        navigation.selectTab(.insights)

        XCTAssertEqual(navigation.selectedTab, .you)
        XCTAssertEqual(navigation.youPath, [.history])
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertFalse(AppTab.allCases.contains(.insights))
        XCTAssertEqual(AppTab.time.title, "Time")
        XCTAssertEqual(AppTab.insights.canonicalTopLevelTab, .you)
    }

    @MainActor
    func testShellOverlayRoutesStayOwnedByTheShellLayer() {
        let navigation = AppNavigationModel(selectedTab: .today)

        navigation.presentMemoryLens(source: .shellUtility)

        XCTAssertEqual(navigation.activeOverlay?.kind, .memoryLens)
        XCTAssertEqual(navigation.activeOverlay?.intent, .memoryLens)
        XCTAssertEqual(navigation.activeOverlay?.entrySource, .shellUtility)
        XCTAssertEqual(navigation.selectedTab, .today)
    }

    @MainActor
    func testNavigationCanPresentCommandSheetWithStructuredIntentContext() {
        let navigation = AppNavigationModel(selectedTab: .today)

        navigation.presentCommandSheet(
            intent: .quickCapture,
            source: .todayQuickCapture,
            presentationContext: .quickCapture
        )

        XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
        XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
        XCTAssertEqual(navigation.activeOverlay?.presentationContext, .quickCapture)
        XCTAssertEqual(navigation.selectedTab, .today)
    }

    @MainActor
    func testCurrentTabReselectionFirstTapRequestsScrollThenSecondTapReturnsToRoot() {
        let navigation = AppNavigationModel(selectedTab: .time)
        navigation.openHabits()

        let firstTap = navigation.handleCurrentTabReselection(now: Date(timeIntervalSince1970: 100))
        XCTAssertEqual(firstTap, .scrollToTop)
        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertEqual(navigation.timePath, [.habits])

        let secondTap = navigation.handleCurrentTabReselection(now: Date(timeIntervalSince1970: 100.4))
        XCTAssertEqual(secondTap, .returnToRoot)
        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertTrue(navigation.timePath.isEmpty)
    }

    @MainActor
    func testCurrentTabReselectionThresholdKeepsLaterTapAsScrollOnly() {
        let navigation = AppNavigationModel(selectedTab: .goals)
        navigation.openGoalDetail(goalID: "goal-shell")

        XCTAssertEqual(navigation.handleCurrentTabReselection(now: Date(timeIntervalSince1970: 100)), .scrollToTop)
        XCTAssertEqual(navigation.handleCurrentTabReselection(now: Date(timeIntervalSince1970: 101)), .scrollToTop)
        XCTAssertEqual(navigation.goalsPath.first?.goalID, "goal-shell")
    }

    @MainActor
    func testTodayReentryContextCanBeCarriedAndConsumed() {
        let navigation = AppNavigationModel(selectedTab: .time)

        navigation.selectToday(entryContext: .recovery)

        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertEqual(navigation.takeTodayEntryContext(), .recovery)
        XCTAssertEqual(navigation.takeTodayEntryContext(), .standard)
    }

    func testStoredLegacyPreferredTabsLoadIntoCanonicalPreferences() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let appState = SwiftDataAppStateRepository(store: store)
        var state = AppStateSnapshot.default
        state.preferredTab = .habits
        try await appState.saveState(state)

        let preferences = try await RepositoryBackedAppPreferencesStore(appStateRepository: appState).loadPreferences()

        XCTAssertEqual(preferences.preferredTab, .time)
    }

    func testStoredProfilePreferredTabLoadsIntoYouSurfaceCompatibility() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let appState = SwiftDataAppStateRepository(store: store)
        var state = AppStateSnapshot.default
        state.preferredTab = .profile
        try await appState.saveState(state)

        let preferences = try await RepositoryBackedAppPreferencesStore(appStateRepository: appState).loadPreferences()

        XCTAssertEqual(preferences.preferredTab, .you)
        XCTAssertEqual(preferences.preferredTab.title, "You")
        XCTAssertEqual(preferences.preferredTab.rawValue, "you")
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
        let dashboard = try await container.timeService.loadTimeDashboard(now: .now)
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
        let actions = [experience.hero.primaryAction.action] + experience.hero.primaryAction.supportingActions
        if let action = actions.first(where: { $0.kind == .openDetail || $0.kind == .askForHelp }) {
            return GoalRouteTarget(
                goalID: action.target.goalID,
                draftID: action.target.draftID,
                launchContext: action.kind == .askForHelp ? .help : .standard
            )
        }

        return nil
    }
}
