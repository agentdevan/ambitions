import XCTest
@testable import Ambitions

final class AppShellNavigationTests: XCTestCase {
    func testCanonicalTopLevelTabsMatchProductSpec() {
        XCTAssertEqual(AppTab.allCases, [.today, .goals, .time, .you])
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(AppTab.allCases.map(\.rawValue), ["today", "goals", "time", "you"])
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("habits"))
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("insights"))
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("capture"))
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("pulse"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains { $0.localizedCaseInsensitiveContains("plan") })
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Review"))
    }

    func testCanonicalRawValuesStayLimitedToActiveTopLevelTabs() {
        XCTAssertNil(AppTab(rawValue: "capture"))
        XCTAssertEqual(AppTab(rawValue: "time"), .time)
        XCTAssertNil(AppTab(rawValue: "motion"))
        XCTAssertEqual(AppTab(rawValue: "you"), .you)
        XCTAssertNil(AppTab(rawValue: "captures"))
        XCTAssertNil(AppTab(rawValue: "pulse"))
        XCTAssertNil(AppTab(rawValue: "plan"))
        XCTAssertNil(AppTab(rawValue: "profile"))
        XCTAssertNil(AppTab(rawValue: "habits"))
        XCTAssertNil(AppTab(rawValue: "insights"))
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "captures"), .today)
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "pulse"), .today)
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "plan"), .time)
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "profile"), .you)
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "habits"), .time)
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "insights"), .you)
        XCTAssertEqual(AppTab.time.canonicalTopLevelTab, .time)
        XCTAssertEqual(AppTab.you.canonicalTopLevelTab, .you)
        XCTAssertEqual(AppTab.time.rawValue, "time")
        XCTAssertEqual(AppTab.time.title, "Time")
        XCTAssertEqual(AppTab.you.rawValue, "you")
        XCTAssertEqual(AppTab.you.title, "You")
        XCTAssertTrue(AppTab.time.isCanonicalTopLevel)
        XCTAssertTrue(AppTab.you.isCanonicalTopLevel)
    }

    func testRootShellTopInsetDoesNotPullSurfaceContentUnderHeader() {
        XCTAssertGreaterThanOrEqual(
            AppShellGeometry.topInsetSpacing(
                hasBackButton: false,
                dynamicTypeIsAccessibilitySize: false
            ),
            0
        )
        XCTAssertGreaterThanOrEqual(
            AppShellGeometry.topInsetSpacing(
                hasBackButton: false,
                dynamicTypeIsAccessibilitySize: true
            ),
            0
        )
        XCTAssertEqual(
            AppShellGeometry.topInsetSpacing(
                hasBackButton: true,
                dynamicTypeIsAccessibilitySize: false
            ),
            0
        )
        XCTAssertGreaterThanOrEqual(
            AppShellGeometry.topContentClearance(
                reservesPrimaryObjectTopClearance: true,
                dynamicTypeIsAccessibilitySize: false
            ),
            80
        )
        XCTAssertGreaterThan(
            AppShellGeometry.topContentClearance(
                reservesPrimaryObjectTopClearance: true,
                dynamicTypeIsAccessibilitySize: true
            ),
            AppShellGeometry.topContentClearance(
                reservesPrimaryObjectTopClearance: true,
                dynamicTypeIsAccessibilitySize: false
            )
        )
        XCTAssertEqual(
            AppShellGeometry.topContentClearance(
                reservesPrimaryObjectTopClearance: false,
                dynamicTypeIsAccessibilitySize: true
            ),
            0
        )
    }

    func testCanonicalSurfaceContractsBindEachTabToOnePrimaryObject() {
        XCTAssertEqual(AmbitionsSurfaceContractRegistry.validate(), [])
        XCTAssertEqual(
            AppTab.allCases.map(\.primaryObjectTitle),
            [
                "Reality Meridian",
                "Direction Atlas",
                "LifeShape Field",
                "Personal system"
            ]
        )
        XCTAssertEqual(AppTab.today.surfaceContract.title, "Today")
        XCTAssertEqual(AppTab.goals.surfaceContract.primaryObjectTitle, "Direction Atlas")
        XCTAssertEqual(AppTab.time.surfaceContract.primaryObjectTitle, "LifeShape Field")
        XCTAssertEqual(AppTab.you.surfaceContract.primaryObjectTitle, "Personal system")
        XCTAssertFalse(AmbitionsSurfaceContractRegistry.canonicalContracts.map(\.tab.rawValue).contains("capture"))
    }

    func testSurfaceContractsPreserveRuntimeInspectionRequirements() {
        for contract in AmbitionsSurfaceContractRegistry.canonicalContracts {
            XCTAssertEqual(
                Set(contract.runtimeInspectionRequirements),
                Set(["SourceRecord", "Receipt", "ReplayTrace", "You / Search Ambitions"])
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
        XCTAssertEqual(destinations.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(
            destinations.map(\.accessibilityIdentifier),
            [
                "shell.meridian.destination.today",
                "shell.meridian.destination.goals",
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
        XCTAssertEqual(chrome.destinations.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertTrue(chrome.destinationRailLabel.contains("Today, Goals, Time, You"))
        XCTAssertFalse(chrome.destinationRailLabel.localizedCaseInsensitiveContains("Pulse"))
        XCTAssertFalse(chrome.destinationRailLabel.contains("Today, Goals, Capture, Time, You"))
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
    func testLegacyCapturePreferenceLoadsIntoTodayCompatibilityFallback() {
        let navigation = AppNavigationModel(legacyTabRawValue: "capture")

        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertTrue(navigation.youPath.isEmpty)
    }

    @MainActor
    func testLegacyCapturesPreferenceLoadsIntoTodayCompatibilityFallback() {
        let navigation = AppNavigationModel(legacyTabRawValue: "captures")

        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertNil(navigation.activeOverlay)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("capture"))
    }

    @MainActor
    func testOpenCapturesInboxPresentsGlobalCaptureOverlayWithoutSelectingCapture() {
        let navigation = AppNavigationModel(selectedTab: .time)

        navigation.openCapturesInbox()

        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
        XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
        XCTAssertEqual(navigation.activeOverlay?.presentationContext, .quickCapture)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(navigation.recentCommandHistory.first?.title, "Capture")
        XCTAssertEqual(navigation.recentCommandHistory.first?.destinationLabel, "Add something")
    }

    @MainActor
    func testTimeRouteCaptureInboxIsCompatibilityOverlayOnly() {
        let navigation = AppNavigationModel(selectedTab: .today)

        navigation.openTimeRoute(.captureInbox)

        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
        XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("capture"))
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
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Time", "You"])
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
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("insights"))
        XCTAssertEqual(AppTab.time.title, "Time")
    }

    @MainActor
    func testLegacyPulsePreferenceLoadsIntoMotionCompatibilityOnly() {
        let navigation = AppNavigationModel(legacyTabRawValue: "pulse")

        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("pulse"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Pulse"))
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
    func testContextualCaptureEntrySourcesExistForEveryCanonicalSurface() {
        let expectedSources: [AppTab: ShellCommandEntrySource] = [
            .today: .todayQuickCapture,
            .goals: .goalsQuickCapture,
            .time: .timeQuickCapture,
            .you: .youQuickCapture
        ]

        XCTAssertEqual(Set(expectedSources.keys), Set(AppTab.allCases))

        for tab in AppTab.allCases {
            let navigation = AppNavigationModel(selectedTab: tab)

            navigation.presentSurfaceCapture(for: tab)

            XCTAssertEqual(navigation.selectedTab, tab)
            XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
            XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
            XCTAssertEqual(navigation.activeOverlay?.presentationContext, .quickCapture)
            XCTAssertEqual(navigation.activeOverlay?.entrySource, expectedSources[tab])
            XCTAssertTrue(navigation.isActivatedCaptureComposerVisible)
        }
    }

    func testToolbarCaptureFallbackMetadataIsAccessibleForEveryCanonicalSurface() {
        XCTAssertEqual(AppShellCaptureAccessModel.toolbarTitle, "Capture")
        XCTAssertEqual(AppShellCaptureAccessModel.toolbarAccessibilityLabel, "Capture")
        XCTAssertEqual(AppShellCaptureAccessModel.toolbarAccessibilityHint, "Opens the Capture composer for this surface/context.")

        XCTAssertEqual(
            AppTab.allCases.map { AppShellCaptureAccessModel.toolbarAccessibilityIdentifier(for: $0) },
            [
                "shell.today.capture-button",
                "shell.goals.capture-button",
                "shell.time.capture-button",
                "shell.you.capture-button"
            ]
        )
    }

    @MainActor
    func testActivatedCaptureComposerSeamAppearsOnlyAfterCaptureActivation() {
        let navigation = AppNavigationModel(selectedTab: .today)

        XCTAssertFalse(navigation.isActivatedCaptureComposerVisible)

        navigation.presentMemoryLens(source: .shellUtility)
        XCTAssertFalse(navigation.isActivatedCaptureComposerVisible)

        navigation.presentSurfaceCapture(for: .today)
        XCTAssertTrue(navigation.isActivatedCaptureComposerVisible)
        XCTAssertEqual(navigation.activeOverlay?.entrySource, .todayQuickCapture)

        navigation.dismissOverlay()
        XCTAssertFalse(navigation.isActivatedCaptureComposerVisible)
    }

    @MainActor
    func testDebugLaunchConfigurationDefaultsRespectCanonicalInitialSurfaceOnly() {
        let bootstrapper = AppBootstrapper()

        XCTAssertNil(bootstrapper.debugLaunchConfiguration().initialSurface)
        XCTAssertFalse(bootstrapper.debugLaunchConfiguration().screenshotModeEnabled)
    }

    @MainActor
    func testDebugLaunchConfigurationParsesAllowedInitialSurfaceArguments() {
        let bootstrapper = AppBootstrapper()

        let expected: [(String, AppTab)] = [
            ("today", .today),
            ("goals", .goals),
            ("time", .time),
            ("you", .you)
        ]

        for (surface, tab) in expected {
            let configuration = bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions", "-AmbitionsInitialSurface", surface])

            XCTAssertEqual(configuration.initialSurface, tab)
            XCTAssertFalse(configuration.screenshotModeEnabled)
        }
    }

    @MainActor
    func testDebugLaunchConfigurationRejectsInvalidOrLegacyInitialSurfaceArguments() {
        let bootstrapper = AppBootstrapper()
        let invalidValues = ["capture", "pulse", "plan", "habits", "insights", "review", "profile", "unknown"]

        for value in invalidValues {
            let configuration = bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions", "-AmbitionsInitialSurface", value])

            XCTAssertNil(configuration.initialSurface, "Legacy or invalid value '\(value)' must not map to top-level launch targets.")
            XCTAssertFalse(configuration.screenshotModeEnabled)
        }
    }

    @MainActor
    func testDebugLaunchConfigurationIgnoresEnvironmentValues() {
        let bootstrapper = AppBootstrapper()

        let configuration = bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions"])

        XCTAssertNil(configuration.initialSurface)
        XCTAssertFalse(configuration.screenshotModeEnabled)
    }

    @MainActor
    func testDebugLaunchConfigurationParsesScreenshotModeStrictly() {
        let bootstrapper = AppBootstrapper()

        XCTAssertTrue(
            bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions", "-AmbitionsScreenshotMode", "YES"]).screenshotModeEnabled
        )
        XCTAssertTrue(
            bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions", "-AmbitionsScreenshotMode", "yes"]).screenshotModeEnabled
        )
        XCTAssertFalse(
            bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions", "-AmbitionsScreenshotMode", "No"]).screenshotModeEnabled
        )
        XCTAssertFalse(
            bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions"]).screenshotModeEnabled
        )
    }

    @MainActor
    func testDebugLaunchConfigurationDoesNotSelectCaptureOrLegacySurfaces() {
        let bootstrapper = AppBootstrapper()
        let captureLikeInputs = [
            ["Ambitions", "-AmbitionsInitialSurface", "capture"],
            ["Ambitions", "-AmbitionsInitialSurface", "captures"],
            ["Ambitions", "-AmbitionsInitialSurface", "pulse"],
            ["Ambitions", "-AmbitionsInitialSurface", "plan"],
            ["Ambitions", "-AmbitionsInitialSurface", "habits"],
            ["Ambitions", "-AmbitionsInitialSurface", "insights"]
        ]

        for arguments in captureLikeInputs {
            let configuration = bootstrapper.debugLaunchConfiguration(arguments: arguments)

            XCTAssertNil(configuration.initialSurface)
        }
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
