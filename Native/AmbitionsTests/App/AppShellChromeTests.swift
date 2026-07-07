@testable import Ambitions
import AmbitionsDesignSystem
import XCTest

final class AppShellChromeTests: XCTestCase {
    func testModeLensUsesPresentationLabelsOnly() {
        XCTAssertEqual(AmbitionModeLens.allCases.map(\.title), ["Focus", "Sort", "Time", "Recover", "Review"])
    }

    func testAmbientStatusOrbStatesStayQualitative() {
        XCTAssertEqual(AmbitionAmbientStatus.allCases.map(\.title), ["Clear", "Steady", "Tight", "Too much planned", "Needs attention", "Recovered", "Private"])
        XCTAssertFalse(AmbitionAmbientStatus.allCases.map(\.title).contains { title in
            title.contains("%") ||
                title.localizedCaseInsensitiveContains("score") ||
                title.localizedCaseInsensitiveContains("confidence") ||
                title.localizedCaseInsensitiveContains("protected")
        })
    }

    func testMissionControlLaneLabelsDoNotCreateTopLevelTabs() {
        XCTAssertEqual(AmbitionMissionLane.allCases.map(\.title), ["Overview", "Path", "Steps", "Proof", "Decisions", "Risks", "Archive"])
        XCTAssertEqual(AmbitionsSurface.allCases.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.title).contains { $0.localizedCaseInsensitiveContains("plan") })
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("plan"))
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.title).contains("Capture"))
    }

    func testAppTabSequenceMatchesCanonicalShellContract() {
        XCTAssertEqual(AmbitionsSurface.allCases.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(AmbitionsSurface.allCases.map(\.rawValue), ["today", "goals", "time", "you"])
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.title).contains("Capture"))
        XCTAssertEqual(Set(AmbitionsSurface.allCases.map(\.title)).count, AmbitionsSurface.allCases.count)
    }

    func testShellIdentifiersStayStableForMeridianDestinations() {
        XCTAssertEqual(
            StageDockDestination.all.map(\.accessibilityIdentifier),
            [
                "shell.meridian.destination.today",
                "shell.meridian.destination.goals",
                "shell.meridian.destination.time",
                "shell.meridian.destination.you",
            ]
        )
        XCTAssertTrue(StageChromeContract.launchDefault.rollbackLabel.contains("Stage shell migration commit"))
        XCTAssertFalse(StageChromeContract.launchDefault.rollbackLabel.contains("--ambitions-shell"))
    }

    func testTrustBadgeCopyDoesNotClaimGlobalSyncByDefault() {
        XCTAssertEqual(AmbitionTrustBadgeState.localOnly.title, "Local only")
        XCTAssertEqual(AmbitionTrustBadgeState.calendarLocal.title, "From calendar")
        XCTAssertEqual(AmbitionTrustBadgeState.needsBackup.title, "Needs backup")
    }

    func testHeaderPosturesResolveToSafeModeLensPresentation() {
        XCTAssertEqual(AppShellHeaderPosture.execution.modeLens, .focus)
        XCTAssertEqual(AppShellHeaderPosture.direction.modeLens, .focus)
        XCTAssertEqual(AppShellHeaderPosture.shaping.modeLens, .time)
        XCTAssertEqual(AppShellHeaderPosture.reflection.modeLens, .review)
        XCTAssertEqual(AppShellHeaderPosture.utility.modeLens, .focus)
    }

    func testShellThemeKeepsHeaderAndTabChromeReadableInBothModes() {
        for mode in AmbitionThemeMode.allCases {
            let theme = AmbitionTheme.theme(for: mode)

            XCTAssertEqual(theme.surfaces.backgroundBlurOpacity, 1.0)
            XCTAssertGreaterThanOrEqual(theme.panel.minimumTapTarget, 44)
            XCTAssertGreaterThanOrEqual(theme.spacing.sm, 16)
            XCTAssertGreaterThan(theme.radius.md, 0)
        }
    }

    func testAMB1194DockRailUsesIconOnlySelectionWithoutVisibleContainerChrome() throws {
        let source = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Stage/Chrome/StageDockRail.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("theme.shell.activeTabForeground"))
        XCTAssertTrue(source.contains("theme.shell.inactiveTabForeground"))
        XCTAssertTrue(source.contains("shell.stage-os.invisible-rail"))
        XCTAssertFalse(source.contains("Text(destination.title)"))
        XCTAssertFalse(source.contains("theme.shell.controlBackground"))
        XCTAssertFalse(source.contains("theme.shell.bottomBarMaterial"))
        XCTAssertFalse(source.contains("theme.colors.surfaceOverlay"))
        XCTAssertFalse(source.contains("theme.shell.divider"))
        XCTAssertFalse(source.contains(".stroke("))
        XCTAssertFalse(source.contains("LinearGradient("))
        XCTAssertFalse(source.contains("LiquidGlass.darkDockCore"))
        XCTAssertFalse(source.contains("LiquidGlass.darkDockBase"))
        XCTAssertFalse(source.contains("Separator.darkNonOpaque"))
    }

    func testM12HeaderPosturesExposeContinuityWithoutHiddenNavigation() {
        let messages = [
            AppShellHeaderPosture.execution.continuityMessage,
            AppShellHeaderPosture.direction.continuityMessage,
            AppShellHeaderPosture.shaping.continuityMessage,
            AppShellHeaderPosture.reflection.continuityMessage,
            AppShellHeaderPosture.utility.continuityMessage,
        ]

        XCTAssertEqual(messages.count, Set(messages).count)
        XCTAssertTrue(messages.allSatisfy { $0.isEmpty == false })
        XCTAssertFalse(messages.contains { message in
            message.localizedCaseInsensitiveContains("dashboard") ||
                message.localizedCaseInsensitiveContains("AI") ||
                message.localizedCaseInsensitiveContains("sync") ||
                message.localizedCaseInsensitiveContains("sixth tab")
        })
    }

    func testM12ContinuityMaturityReportCoversRequiredSurfacesAndLayer3Blockers() {
        XCTAssertEqual(
            CrossSurfaceContinuityMaturityReport.handoffs.map(\.surface),
            [.today, .captureComposer, .goals, .time, .you, .trustInspection, .externalSurface, .goals]
        )
        XCTAssertTrue(CrossSurfaceContinuityMaturityReport.handoffs.contains { $0.id == "path-builder" })
        XCTAssertTrue(CrossSurfaceContinuityMaturityReport.handoffs.allSatisfy { $0.owningRoute.isEmpty == false })
        XCTAssertFalse(CrossSurfaceContinuityMaturityReport.handoffs.contains { $0.continuityBehavior.localizedCaseInsensitiveContains("top-level Insights") })
        XCTAssertFalse(CrossSurfaceContinuityMaturityReport.handoffs.contains { $0.continuityBehavior.localizedCaseInsensitiveContains("Tasks tab") })

        XCTAssertEqual(
            CrossSurfaceContinuityMaturityReport.performanceChecks.map(\.id),
            ["life-graph", "ledger-receipts", "trust-memory", "path-portfolio", "external-snapshots", "device-responsiveness"]
        )
        XCTAssertEqual(CrossSurfaceContinuityMaturityReport.layer3Blockers.map(\.ownerBatch), ["R01", "R02", "R03", "R04-R05"])
        XCTAssertTrue(CrossSurfaceContinuityMaturityReport.completionSummary.contains("R04/R05 own remaining external release truth"))
    }

    func testSI03SurfaceShellKindsDoNotCreateNavigationDestinations() {
        XCTAssertEqual(
            AmbitionsSurfaceShellKind.allCases,
            [.topLevelSurface, .drillDown, .utilityHub, .overlayHost]
        )

        for kind in AmbitionsSurfaceShellKind.allCases {
            XCTAssertFalse(kind.title.isEmpty)
            XCTAssertFalse(kind.accessibilityRole.isEmpty)
            XCTAssertTrue(AmbitionModeLens.allCases.contains(kind.defaultLens))
            XCTAssertTrue(AmbitionAmbientStatus.allCases.contains(kind.defaultStatus))
        }

        XCTAssertEqual(AmbitionsSurface.allCases.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(StageDockDestination.all.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(
            StageDockDestination.all.map(\.accessibilityIdentifier),
            [
                "shell.meridian.destination.today",
                "shell.meridian.destination.goals",
                "shell.meridian.destination.time",
                "shell.meridian.destination.you",
            ]
        )
        XCTAssertEqual(StageDockDestination.all.map(\.glyphRole), [.startHere, .goalsAtlas, .timeCapacity, .userProfile])
        XCTAssertFalse(StageDockDestination.all.map(\.accessibilityIdentifier).contains { $0.localizedCaseInsensitiveContains("capture") })
        XCTAssertFalse(StageDockDestination.all.map(\.accessibilityIdentifier).contains { $0.localizedCaseInsensitiveContains("plan") })
    }

    func testAMB1194RootStageHostDoesNotExposeInternalObjectNamesInRootShellSubtitles() throws {
        let source = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift"),
            encoding: .utf8
        )

        XCTAssertFalse(source.contains("subtitle: \"Life Area Atlas\""))
        XCTAssertFalse(source.contains("subtitle: \"Profile and settings\""))
        XCTAssertEqual(source.components(separatedBy: "subtitle: \"Life Calendar\"").count - 1, 2)
        XCTAssertTrue(source.contains("title: \"Time\""))
        XCTAssertTrue(source.contains("title: \"Goals\""))
        XCTAssertTrue(source.contains("title: \"You\""))
    }

    func testRootFirstLayerCopyAvoidsInternalCompatibilityNames() throws {
        let root = repoRoot()
        let today = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailViewCurrentMoment.swift"),
            encoding: .utf8
        )
        let goals = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift"),
            encoding: .utf8
        )
        let you = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Surfaces/You/YouRootSurface.swift"),
            encoding: .utf8
        )

        XCTAssertFalse(today.contains("Open Field stays available"))
        XCTAssertFalse(today.contains("Start here appears when this window can hold it."))
        XCTAssertTrue(today.contains("Capture stays ready when something new needs a place."))
        XCTAssertTrue(today.contains("When a step fits here, it will appear with a clear next action."))

        XCTAssertFalse(goals.contains("isOpenField"))
        XCTAssertFalse(goals.contains("region.isOpenField ? \"Add thought\""))

        XCTAssertFalse(you.contains("Text(\"User System Profile\")"))
        XCTAssertFalse(you.contains("title: \"Open Field\""))
        XCTAssertTrue(you.contains("Text(\"Your settings\")"))
        XCTAssertTrue(you.contains("title: \"Capture\""))
    }
}

private extension AppShellChromeTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("project.yml").path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
