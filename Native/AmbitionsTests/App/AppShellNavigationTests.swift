@testable import Ambitions
import AmbitionsDesignSystem
import XCTest

final class AppShellNavigationTests: XCTestCase {
    func testCanonicalTopLevelTabsMatchProductSpec() {
        XCTAssertEqual(AmbitionsSurface.allCases, [.today, .goals, .time, .you])
        XCTAssertEqual(AmbitionsSurface.allCases.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(AmbitionsSurface.allCases.map(\.rawValue), ["today", "goals", "time", "you"])
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("habits"))
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("insights"))
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("capture"))
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("pulse"))
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.title).contains { $0.localizedCaseInsensitiveContains("plan") })
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.title).contains("Review"))
    }

    func testCanonicalRawValuesStayLimitedToActiveTopLevelTabs() {
        XCTAssertNil(AmbitionsSurface(rawValue: "capture"))
        XCTAssertEqual(AmbitionsSurface(rawValue: "time"), .time)
        XCTAssertNil(AmbitionsSurface(rawValue: "motion"))
        XCTAssertEqual(AmbitionsSurface(rawValue: "you"), .you)
        XCTAssertNil(AmbitionsSurface(rawValue: "captures"))
        XCTAssertNil(AmbitionsSurface(rawValue: "pulse"))
        XCTAssertNil(AmbitionsSurface(rawValue: "plan"))
        XCTAssertNil(AmbitionsSurface(rawValue: "profile"))
        XCTAssertNil(AmbitionsSurface(rawValue: "habits"))
        XCTAssertNil(AmbitionsSurface(rawValue: "insights"))
        XCTAssertEqual(AmbitionsSurface.time.canonicalTopLevelTab, .time)
        XCTAssertEqual(AmbitionsSurface.you.canonicalTopLevelTab, .you)
        XCTAssertEqual(AmbitionsSurface.time.rawValue, "time")
        XCTAssertEqual(AmbitionsSurface.time.title, "Time")
        XCTAssertEqual(AmbitionsSurface.you.rawValue, "you")
        XCTAssertEqual(AmbitionsSurface.you.title, "You")
        XCTAssertTrue(AmbitionsSurface.time.isCanonicalTopLevel)
        XCTAssertTrue(AmbitionsSurface.you.isCanonicalTopLevel)
    }

    func testCanonicalSurfaceContractsBindEachTabToOnePrimaryObject() {
        XCTAssertEqual(AmbitionsSurfaceContractRegistry.validate(), [])
        XCTAssertEqual(
            AmbitionsSurface.allCases.map(\.primaryObjectTitle),
            [
                "Reality Meridian",
                "Life Area Atlas",
                "Life Calendar",
                "User System Profile"
            ]
        )
        XCTAssertEqual(AmbitionsSurface.today.surfaceContract.title, "Today")
        XCTAssertEqual(AmbitionsSurface.goals.surfaceContract.primaryObjectTitle, "Life Area Atlas")
        XCTAssertEqual(AmbitionsSurface.time.surfaceContract.primaryObjectTitle, "Life Calendar")
        XCTAssertEqual(AmbitionsSurface.you.surfaceContract.primaryObjectTitle, "User System Profile")
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

        XCTAssertTrue(issues.contains { $0.contains("Time must own Life Calendar") })
        XCTAssertTrue(issues.contains { $0.contains("Primary object Reality Meridian is assigned to multiple top-level surfaces") })
    }

    func testStageSurfaceOwnershipRegistryLimitsRootToFourSurfaces() {
        XCTAssertEqual(SurfaceOwnershipRegistry.validationIssues(), [])
        XCTAssertEqual(SurfaceOwnershipRegistry.persistentSurfaceTabs, [.today, .goals, .time, .you])
        XCTAssertEqual(SurfaceOwnershipRegistry.rootSurfaceTitles, ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(SurfaceOwnershipRegistry.rootSurfaceRawValues, ["today", "goals", "time", "you"])
        XCTAssertFalse(SurfaceOwnershipRegistry.isPersistentRoot(rawValue: "capture"))
        XCTAssertFalse(SurfaceOwnershipRegistry.isPersistentRoot(rawValue: "motion"))
    }

    func testStageSurfaceOwnershipKeepsCaptureAndMotionOutOfRootChrome() {
        XCTAssertEqual(SurfaceOwnershipRegistry.globalComposer.title, "Capture")
        XCTAssertEqual(SurfaceOwnershipRegistry.globalComposer.layer, .globalComposer)
        XCTAssertNil(SurfaceOwnershipRegistry.globalComposer.canonicalTab)
        XCTAssertEqual(SurfaceOwnershipRegistry.globalComposer.routePolicy, "Overlay/global composer only")
        XCTAssertEqual(SurfaceOwnershipRegistry.motionBehavior.title, "Motion")
        XCTAssertEqual(SurfaceOwnershipRegistry.motionBehavior.layer, .motionBehavior)
        XCTAssertNil(SurfaceOwnershipRegistry.motionBehavior.canonicalTab)
        XCTAssertEqual(SurfaceOwnershipRegistry.motionBehavior.routePolicy, "Behavior layer only")
    }

    func testMeridianDestinationsMirrorCanonicalTabsWithoutNewRouteOwnership() {
        let destinations = StageDockDestination.all

        XCTAssertEqual(destinations.map(\.surface), AmbitionsSurface.allCases)
        XCTAssertEqual(destinations.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(destinations.map(\.glyphRole), [.startHere, .goalsAtlas, .timeCapacity, .userProfile])
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

    func testFCP08MeridianShellChromeContractPreservesFourRootSurfacesAndReceiptZone() {
        let chrome = StageChromeContract.launchDefault

        XCTAssertEqual(chrome.title, "Ambition Meridian")
        XCTAssertEqual(chrome.destinations.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertTrue(chrome.destinationRailLabel.contains("Today, Goals, Time, You"))
        XCTAssertFalse(chrome.destinationRailLabel.localizedCaseInsensitiveContains("Pulse"))
        XCTAssertFalse(chrome.destinationRailLabel.contains("Today, Goals, Capture, Time, You"))
        XCTAssertTrue(chrome.receiptOverlayZoneLabel.contains("bounded and dismissible"))
        XCTAssertTrue(chrome.globalActionLabel.contains("without changing tabs"))
        XCTAssertTrue(chrome.safeAreaLabel.contains("safe areas"))
        XCTAssertTrue(chrome.rollbackLabel.contains("Stage shell migration commit"))
        XCTAssertFalse(chrome.rollbackLabel.contains("--ambitions-shell"))
        XCTAssertFalse(chrome.accessibilitySummary.localizedCaseInsensitiveContains("timeState"))
        let disallowedConfidencePhrase = ["AI", "confidence"].joined(separator: " ")
        XCTAssertFalse(chrome.accessibilitySummary.localizedCaseInsensitiveContains(disallowedConfidencePhrase))
        XCTAssertFalse(chrome.accessibilitySummary.localizedCaseInsensitiveContains("sixth"))
    }

    @MainActor
    func testMeridianOneTapDestinationsUseCanonicalNavigationSelection() {
        for destination in StageDockDestination.all {
            let navigation = StageStore(selectedSurface: .today)
            navigation.presentMemoryLens(source: .shellUtility)

            navigation.selectRootSurfaceFromDock(destination.surface)

            XCTAssertEqual(navigation.selectedTab, destination.surface)
            XCTAssertNil(navigation.activeOverlay)
            XCTAssertTrue(navigation.goalsPath.isEmpty)
            XCTAssertTrue(navigation.timePath.isEmpty)
            XCTAssertTrue(navigation.youPath.isEmpty)
        }
    }

    @MainActor
    func testStageDockReselectionReturnsCurrentSurfaceToRoot() {
        let navigation = StageStore(selectedSurface: .goals)
        navigation.openGoalDetail(goalID: "goal-shell-rollback")

        XCTAssertEqual(navigation.stageRouteDepth, .drilldown)
        XCTAssertEqual(navigation.selectedTab, .goals)
        XCTAssertEqual(navigation.goalsPath.first?.goalID, "goal-shell-rollback")

        let firstReselection = navigation.selectRootSurfaceFromDock(.goals, now: Date(timeIntervalSince1970: 10))
        let secondReselection = navigation.selectRootSurfaceFromDock(.goals, now: Date(timeIntervalSince1970: 10.4))

        XCTAssertEqual(firstReselection, .scrollToTop)
        XCTAssertEqual(secondReselection, .returnToRoot)
        XCTAssertEqual(navigation.stageRouteDepth, .root)
        XCTAssertTrue(navigation.goalsPath.isEmpty)
    }

    @MainActor
    func testStageDispatchProducesCanonicalSurfaceMorphAndFocusPlan() {
        let navigation = StageStore(selectedSurface: .today)

        navigation.selectRootSurfaceFromDock(.goals, now: Date(timeIntervalSince1970: 20))

        XCTAssertEqual(navigation.lastStageTransition.kind, .surfaceMorph)
        XCTAssertEqual(navigation.lastStageTransition.motion, .objectContinuity)
        XCTAssertEqual(navigation.lastStageFocusPlan.target, .rootObject(.goals))
        XCTAssertEqual(navigation.lastEffectRun.visibleMutationIDs, ["surface.goals.selected"])
        XCTAssertEqual(navigation.lastEffectRun.visibleMutations.first?.affectedObjectIDs, ["surface.goals"])
        XCTAssertEqual(navigation.lastEffectRun.accessibilityAnnouncements, ["Goals selected"])
        XCTAssertEqual(navigation.lastEffectRun.proofArtifactIDs, ["stage.surface.goals"])
        XCTAssertTrue(navigation.lastEffectRun.provesTypedObjectEffects)
        XCTAssertTrue(navigation.lastStageMutationAnimationPlan.provesActionFlow)
    }

    @MainActor
    func testStageDrilldownPushHidesDockAndRestoresFocusToBackButton() {
        let navigation = StageStore(selectedSurface: .today)

        navigation.openGoalDetail(goalID: "goal-stage-focus")

        XCTAssertEqual(navigation.selectedTab, .goals)
        XCTAssertEqual(navigation.stageRouteDepth, .drilldown)
        XCTAssertFalse(navigation.hasRootNavigationChrome)
        XCTAssertEqual(navigation.lastStageTransition.kind, .drilldownPush)
        XCTAssertEqual(navigation.lastStageFocusPlan.target, .drilldownBackButton(.goals))
        XCTAssertEqual(navigation.lastStageFocusPlan.proofArtifactID, "stage.focus.goals.drilldown-back")
    }

    @MainActor
    func testStageOverlayPresentationAndDismissalUseCanonicalFocusCoordinator() {
        let navigation = StageStore(selectedSurface: .today)

        navigation.presentMemoryLens(source: .shellUtility)

        XCTAssertEqual(navigation.lastStageTransition.kind, .overlayPresentation)
        XCTAssertEqual(navigation.lastStageFocusPlan.target, .overlay("memory-lens"))
        XCTAssertEqual(navigation.lastStageFocusPlan.proofArtifactID, "stage.focus.overlay.memory-lens")

        navigation.dismissOverlay()

        XCTAssertEqual(navigation.lastStageTransition.kind, .overlayDismissal)
        XCTAssertEqual(navigation.lastStageFocusPlan.target, .rootObject(.today))
        XCTAssertEqual(navigation.lastEffectRun.proofArtifactIDs, ["stage.overlay.dismissed"])
    }

    func testStageMorphCoordinatorUsesRestrainedReduceMotionTransition() {
        let previous = StageScene(
            surface: .today,
            routeDepth: .root,
            overlay: StageOverlay.current(nil),
            primaryObject: StageObject.primary(for: .today)
        )
        let next = StageScene(
            surface: .time,
            routeDepth: .root,
            overlay: StageOverlay.current(nil),
            primaryObject: StageObject.primary(for: .time)
        )
        let effectRun = StageEffectRunner().run(StageEffect.surfaceChanged(to: .time))

        let result = StageMorphCoordinator().coordinate(
            from: previous,
            to: next,
            effectRun: effectRun,
            reduceMotionEnabled: true
        )

        XCTAssertEqual(result.transition.kind, .surfaceMorph)
        XCTAssertEqual(result.transition.motion, .restrainedCrossfade)
        XCTAssertFalse(result.transition.animated)
        XCTAssertEqual(result.focusPlan.target, .rootObject(.time))
        XCTAssertTrue(result.animationPlan.provesActionFlow)
    }

    @MainActor
    func testOpenCaptureComposerPresentsGlobalCaptureOverlayWithoutSelectingCapture() {
        let navigation = StageStore(selectedSurface: .time)

        navigation.openCaptureComposer()

        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
        XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
        XCTAssertEqual(navigation.activeOverlay?.presentationContext, .quickCapture)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(navigation.recentCommandHistory.first?.title, "Capture")
        XCTAssertEqual(navigation.recentCommandHistory.first?.destinationLabel, "Add something")
    }

    @MainActor
    func testCaptureComposerDoesNotCreateTimeRoute() {
        let navigation = StageStore(selectedSurface: .today)

        navigation.openCaptureComposer()

        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
        XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("capture"))
    }

    @MainActor
    func testRitualsRouteStaysUnderTimeWithoutDuplicateDestination() {
        let navigation = StageStore(selectedSurface: .today)

        navigation.openTimeRoute(.rituals)

        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertEqual(navigation.timePath, [.rituals])
        XCTAssertTrue(navigation.youPath.isEmpty)
        XCTAssertEqual(AmbitionsSurface.allCases.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("habits"))
        XCTAssertEqual(AmbitionsSurface.time.rawValue, "time")
        XCTAssertEqual(AmbitionsSurface.time.title, "Time")
    }

    @MainActor
    func testHistoryRouteStaysUnderYouWithoutDuplicateDestination() {
        let navigation = StageStore(selectedSurface: .today)

        navigation.openYouRoute(.history)

        XCTAssertEqual(navigation.selectedTab, .you)
        XCTAssertEqual(navigation.youPath, [.history])
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(AmbitionsSurface.allCases.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("insights"))
        XCTAssertEqual(AmbitionsSurface.time.title, "Time")
    }

    @MainActor
    func testShellOverlayRoutesStayOwnedByTheShellLayer() {
        let navigation = StageStore(selectedSurface: .today)

        navigation.presentMemoryLens(source: .shellUtility)

        XCTAssertEqual(navigation.activeOverlay?.kind, .memoryLens)
        XCTAssertEqual(navigation.activeOverlay?.intent, .memoryLens)
        XCTAssertEqual(navigation.activeOverlay?.entrySource, .shellUtility)
        XCTAssertEqual(navigation.selectedTab, .today)
    }

    @MainActor
    func testNavigationCanPresentCommandSheetWithStructuredIntentContext() {
        let navigation = StageStore(selectedSurface: .today)

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
        let expectedSources: [AmbitionsSurface: ShellCommandEntrySource] = [
            .today: .todayQuickCapture,
            .goals: .goalsQuickCapture,
            .time: .timeQuickCapture,
            .you: .youQuickCapture
        ]

        XCTAssertEqual(Set(expectedSources.keys), Set(AmbitionsSurface.allCases))

        for tab in AmbitionsSurface.allCases {
            let navigation = StageStore(selectedSurface: tab)

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
            AmbitionsSurface.allCases.map { AppShellCaptureAccessModel.toolbarAccessibilityIdentifier(for: $0) },
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
        let navigation = StageStore(selectedSurface: .today)

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

        let expected: [(String, AmbitionsSurface)] = [
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
        let navigation = StageStore(selectedSurface: .time)
        navigation.openRituals()

        let firstTap = navigation.handleCurrentTabReselection(now: Date(timeIntervalSince1970: 100))
        XCTAssertEqual(firstTap, .scrollToTop)
        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertEqual(navigation.timePath, [.rituals])

        let secondTap = navigation.handleCurrentTabReselection(now: Date(timeIntervalSince1970: 100.4))
        XCTAssertEqual(secondTap, .returnToRoot)
        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertTrue(navigation.timePath.isEmpty)
    }

    @MainActor
    func testCurrentTabReselectionThresholdKeepsLaterTapAsScrollOnly() {
        let navigation = StageStore(selectedSurface: .goals)
        navigation.openGoalDetail(goalID: "goal-shell")

        XCTAssertEqual(navigation.handleCurrentTabReselection(now: Date(timeIntervalSince1970: 100)), .scrollToTop)
        XCTAssertEqual(navigation.handleCurrentTabReselection(now: Date(timeIntervalSince1970: 101)), .scrollToTop)
        XCTAssertEqual(navigation.goalsPath.first?.goalID, "goal-shell")
    }

    @MainActor
    func testTodayReentryContextCanBeCarriedAndConsumed() {
        let navigation = StageStore(selectedSurface: .time)

        navigation.selectToday(entryContext: .recovery)

        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertEqual(navigation.takeTodayEntryContext(), .recovery)
        XCTAssertEqual(navigation.takeTodayEntryContext(), .standard)
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
        let timeState = try await container.timeService.loadTimeSurfaceState(now: .now)
        let target = try XCTUnwrap(timeState.goalShapingItems.first?.target)

        _ = try await container.goalsService.loadDetail(target: target)
        container.navigation.openGoalDetail(target)

        XCTAssertEqual(container.navigation.selectedTab, .goals)
        XCTAssertEqual(container.navigation.goalsPath, [target])
    }

    @MainActor
    func testDemoInsightsSurfaceProvidesGoalDetailRouteThatOpensInGoalsShell() async throws {
        let container = try await demoContainer()
        let timeState = try await container.insightsService.loadInsightsDashboard()
        let target = try XCTUnwrap(timeState.goalStatuses.first?.target)

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
