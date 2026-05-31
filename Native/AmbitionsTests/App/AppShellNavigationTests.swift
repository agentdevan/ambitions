import XCTest
@testable import Ambitions

final class AppShellNavigationTests: XCTestCase {
    func testCanonicalTopLevelTabsMatchProductSpec() {
        XCTAssertEqual(AppTab.allCases, [.today, .goals, .capture, .time, .you])
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertEqual(AppTab.allCases.map(\.rawValue), ["today", "goals", "capture", "time", "you"])
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("habits"))
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("insights"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains { $0.localizedCaseInsensitiveContains("plan") })
    }

    func testCanonicalRawValuesStayLimitedToActiveTopLevelTabs() {
        XCTAssertEqual(AppTab(rawValue: "capture"), .capture)
        XCTAssertEqual(AppTab(rawValue: "time"), .time)
        XCTAssertEqual(AppTab(rawValue: "you"), .you)
        XCTAssertNil(AppTab(rawValue: "captures"))
        XCTAssertNil(AppTab(rawValue: "plan"))
        XCTAssertNil(AppTab(rawValue: "profile"))
        XCTAssertNil(AppTab(rawValue: "habits"))
        XCTAssertNil(AppTab(rawValue: "insights"))
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "captures"), .capture)
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "plan"), .time)
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "profile"), .you)
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "habits"), .time)
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "insights"), .you)
        XCTAssertEqual(AppTab.capture.canonicalTopLevelTab, .capture)
        XCTAssertEqual(AppTab.time.canonicalTopLevelTab, .time)
        XCTAssertEqual(AppTab.you.canonicalTopLevelTab, .you)
        XCTAssertEqual(AppTab.time.rawValue, "time")
        XCTAssertEqual(AppTab.time.title, "Time")
        XCTAssertEqual(AppTab.you.rawValue, "you")
        XCTAssertEqual(AppTab.you.title, "You")
        XCTAssertTrue(AppTab.capture.isCanonicalTopLevel)
        XCTAssertTrue(AppTab.time.isCanonicalTopLevel)
        XCTAssertTrue(AppTab.you.isCanonicalTopLevel)
    }

    func testCanonicalSurfaceContractsBindEachTabToOnePrimaryObject() {
        XCTAssertEqual(AmbitionsSurfaceContractRegistry.validate(), [])
        XCTAssertEqual(
            AppTab.allCases.map(\.primaryObjectTitle),
            [
                "Reality Meridian",
                "Constellation Atlas",
                "Atmosphere Composer",
                "LifeShape Field",
                "User System Profile"
            ]
        )
        XCTAssertEqual(AppTab.today.surfaceContract.title, "Today")
        XCTAssertEqual(AppTab.goals.surfaceContract.primaryObjectTitle, "Constellation Atlas")
        XCTAssertEqual(AppTab.capture.surfaceContract.primaryObjectTitle, "Atmosphere Composer")
        XCTAssertEqual(AppTab.time.surfaceContract.primaryObjectTitle, "LifeShape Field")
        XCTAssertEqual(AppTab.you.surfaceContract.primaryObjectTitle, "User System Profile")
    }

    func testSurfaceContractsPreserveRuntimeInspectionRequirements() {
        for contract in AmbitionsSurfaceContractRegistry.canonicalContracts {
            XCTAssertEqual(
                Set(contract.runtimeInspectionRequirements),
                Set(["SourceRecord", "Receipt", "ReplayTrace", "You / What Ambitions knows"])
            )
        }
    }

    func testSurfaceContractValidationRejectsCompetingPrimaryObjectDefinitions() {
        let competing = AmbitionsSurfaceContract(
            tab: .time,
            title: "Time",
            primaryObjectTitle: "Reality Meridian"
        )
        let contracts = AmbitionsSurfaceContractRegistry.canonicalContracts.map {
            $0.tab == .time ? competing : $0
        }

        let issues = AmbitionsSurfaceContractRegistry.validate(contracts)

        XCTAssertTrue(issues.contains { $0.contains("Time must own LifeShape Field") })
        XCTAssertTrue(issues.contains { $0.contains("Primary object Reality Meridian is assigned to multiple top-level surfaces") })
    }

    func testShellPresentationModeDefaultsToNativeFallbackWithMeridianOptIn() {
        XCTAssertEqual(
            AppShellPresentationMode.resolved(arguments: ["Ambitions"], environment: [:]),
            .nativeFallback
        )

        XCTAssertEqual(
            AppShellPresentationMode.resolved(
                arguments: ["Ambitions", "--ambitions-shell=meridian"],
                environment: [:]
            ),
            .meridian
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

    func testShellPresentationModeEnvironmentDefaultsToNativeFallbackWhenNotMeridian() {
        XCTAssertEqual(
            AppShellPresentationMode.resolved(
                arguments: ["Ambitions"],
                environment: ["AMBITIONS_SHELL_PRESENTATION": "nativeFallback"]
            ),
            .nativeFallback
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
    func testNavigationInitializesLegacyHabitsPreferenceIntoTimeHabitsRoute() {
        let navigation = AppNavigationModel(legacyTabRawValue: "habits")

        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertEqual(navigation.timePath, [.habits])
        XCTAssertTrue(navigation.youPath.isEmpty)
    }

    @MainActor
    func testLegacyHabitsSelectionPreservesRitualTimeSemanticsWithoutDuplicateDestination() {
        let navigation = AppNavigationModel(selectedTab: .today)

        navigation.openTimeRoute(.habits)

        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertEqual(navigation.timePath, [.habits])
        XCTAssertTrue(navigation.youPath.isEmpty)
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("habits"))
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "plan"), .time)
        XCTAssertEqual(AppTab.time.rawValue, "time")
        XCTAssertEqual(AppTab.time.title, "Time")
    }

    @MainActor
    func testNavigationInitializesLegacyInsightsPreferenceIntoYouSupportRoute() {
        let navigation = AppNavigationModel(legacyTabRawValue: "insights")

        XCTAssertEqual(navigation.selectedTab, .you)
        XCTAssertEqual(navigation.youPath, [.history])
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "insights"), .you)
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("insights"))
    }

    @MainActor
    func testLegacyInsightsSelectionPreservesYouCanonWithoutDuplicateDestination() {
        let navigation = AppNavigationModel(selectedTab: .today)

        navigation.openYouRoute(.history)

        XCTAssertEqual(navigation.selectedTab, .you)
        XCTAssertEqual(navigation.youPath, [.history])
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("insights"))
        XCTAssertEqual(AppTab.time.title, "Time")
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
        let state = try legacyAppStateSnapshot(preferredTabRawValue: "habits")
        try await appState.saveState(state)

        let preferences = try await RepositoryBackedAppPreferencesStore(appStateRepository: appState).loadPreferences()

        XCTAssertEqual(preferences.preferredTab, .time)
    }

    func testStoredLegacyProfilePreferredTabLoadsIntoYouSurfaceCompatibility() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let appState = SwiftDataAppStateRepository(store: store)
        let state = try legacyAppStateSnapshot(preferredTabRawValue: "profile")
        try await appState.saveState(state)

        let preferences = try await RepositoryBackedAppPreferencesStore(appStateRepository: appState).loadPreferences()

        XCTAssertEqual(preferences.preferredTab, .you)
        XCTAssertEqual(preferences.preferredTab.title, "You")
        XCTAssertEqual(preferences.preferredTab.rawValue, "you")
    }

    private func legacyAppStateSnapshot(preferredTabRawValue: String) throws -> AppStateSnapshot {
        let encoded = """
        {
          "id": "app_state.default",
          "preferredTab": "\(preferredTabRawValue)",
          "userDisplayName": "",
          "appearancePreference": "system",
          "accentFamily": "sage",
          "reviewCadenceDays": 7,
          "localOnlyModeEnabled": true,
          "hasCompletedBootstrap": false,
          "hasCompletedOnboarding": false,
          "onboardingVersion": 1,
          "goalPriorityOrder": []
        }
        """
        return try JSONDecoder().decode(AppStateSnapshot.self, from: Data(encoded.utf8))
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
    func testDemoTimeSurfaceProvidesGoalDetailRouteThatOpensInGoalsShell() async throws {
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
