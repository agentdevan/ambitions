import XCTest
@testable import Ambitions

@MainActor
final class GoalsRootDetailRebuildTests: XCTestCase {
    func testAMB1193DefaultLifeAreaAtlasRegionsExistWithoutFakeContent() {
        let regions = GoalsLifeAreaAtlasRegion.regions(from: PreviewGoalsScenarios.overview)
        let rootNames = regions.map(\.title)

        XCTAssertEqual(rootNames, ["Work", "Body", "Home", "People", "Self", "Future"])
        XCTAssertFalse(regions.contains { $0.id == "open-field" || $0.title == "Open Field" })
        XCTAssertTrue(regions.allSatisfy { $0.accessibilityHint.localizedCaseInsensitiveContains("opens") })
    }

    func testAMB1193GoalsRootSourceNoLongerRendersDiagnosticConsoleLanguage() throws {
        let rootSource = try [
            source("Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift"),
            source("Native/Ambitions/Surfaces/Goals/GoalsSurface.swift")
        ].joined(separator: "\n")

        XCTAssertTrue(rootSource.contains("goals.life-area-atlas"))
        XCTAssertFalse(rootSource.contains("Thread Focus"))
        XCTAssertFalse(rootSource.contains("Feeds Today"))
        XCTAssertFalse(rootSource.contains("No active thread yet"))
        XCTAssertFalse(rootSource.contains("Create your first goal"))
        XCTAssertFalse(rootSource.contains("GOALS · Life Area Atlas"))
        XCTAssertFalse(rootSource.contains("source-proof-trust"))
    }

    func testAMB1193GoalsPlusOpensTypedCaptureGoalSeed() {
        let navigation = StageStore(selectedSurface: .goals)

        navigation.presentTypedCaptureComposer(kind: .goalSeed, source: .goalsCreate, lifeAreaID: "work")

        let overlay = navigation.activeOverlay
        XCTAssertEqual(overlay?.typedCaptureRoute?.kind, .goalSeed)
        XCTAssertEqual(overlay?.typedCaptureRoute?.context.lifeAreaID, "work")
        XCTAssertEqual(overlay?.typedCaptureRoute?.context.sourceSurface, "Goals")
        XCTAssertEqual(overlay?.isActivatedCaptureComposer, true)
        XCTAssertEqual(navigation.stageOverlayPresentation, .activatedCaptureComposer)
    }

    func testAMB1193AreaAndGoalDrilldownsHideRootDockThroughRouteDepth() {
        XCTAssertEqual(
            StagePathStore.routeDepth(goalsPath: [GoalRouteTarget(lifeAreaID: "work")], timePath: [], youPath: []),
            .drilldown
        )
        XCTAssertFalse(
            StagePathStore.rootDockIsVisible(routeDepth: .drilldown, overlayPresentation: .none)
        )

        let target = GoalRouteTarget(goalID: "goal-1")
        XCTAssertEqual(
            StagePathStore.routeDepth(goalsPath: [target], timePath: [], youPath: []),
            .drilldown
        )
        XCTAssertTrue(target.hasAddressableContent)
    }

    func testAMB1193GoalDetailSourceShowsPathAndJournalFirst() throws {
        let detailSource = try source("Native/Ambitions/Surfaces/Goals/GoalDetailScreen.swift")

        XCTAssertTrue(detailSource.contains("GoalDetailPathFieldSurface(detail: detail)"))
        XCTAssertTrue(detailSource.contains("GoalDetailJournalSurface(detail: detail)"))
        XCTAssertFalse(detailSource.contains("GoalDetailMissionControlSurface(state: missionControl)"))
        XCTAssertFalse(detailSource.contains("GoalDetailBreadcrumbSurface(state: missionControl.breadcrumb)"))
    }

    private func source(_ relativePath: String) throws -> String {
        try String(contentsOf: repoRoot().appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
