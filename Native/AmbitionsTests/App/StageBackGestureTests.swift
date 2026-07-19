@testable import Ambitions
import XCTest

final class StageBackGestureTests: XCTestCase {
    @MainActor
    func testPopFocusedRouteReturnsGoalsTimeAndYouDrilldownsWithoutChangingRootSurfaceSet() {
        let goalsNavigation = StageStore(selectedSurface: .today)
        goalsNavigation.openGoalDetail(goalID: "goal-swipe-back")
        XCTAssertEqual(goalsNavigation.selectedTab, .goals)
        XCTAssertEqual(goalsNavigation.stageRouteDepth, .drilldown)

        goalsNavigation.popFocusedRoute()

        XCTAssertEqual(goalsNavigation.selectedTab, .goals)
        XCTAssertEqual(goalsNavigation.stageRouteDepth, .root)
        XCTAssertTrue(goalsNavigation.goalsPath.isEmpty)
        XCTAssertEqual(goalsNavigation.lastStageTransition.kind, .rootReturn)
        XCTAssertEqual(goalsNavigation.lastEffectRun.proofArtifactIDs, ["stage.surface.goals.swipe-back"])

        let timeNavigation = StageStore(selectedSurface: .today)
        timeNavigation.openTimeRoute(.weeklyReview)
        timeNavigation.popFocusedRoute()
        XCTAssertEqual(timeNavigation.selectedTab, .time)
        XCTAssertTrue(timeNavigation.timePath.isEmpty)
        XCTAssertEqual(timeNavigation.lastStageFocusPlan.target, .rootObject(.time))

        let youNavigation = StageStore(selectedSurface: .today)
        youNavigation.openYouRoute(.history)
        youNavigation.popFocusedRoute()
        XCTAssertEqual(youNavigation.selectedTab, .you)
        XCTAssertTrue(youNavigation.youPath.isEmpty)
        XCTAssertEqual(youNavigation.lastEffectRun.accessibilityAnnouncements, ["Back to You"])
    }

    @MainActor
    func testPopFocusedRouteDoesNothingAtRootAndNeverCreatesCaptureOrMotionRoots() {
        let navigation = StageStore(selectedSurface: .today)

        navigation.popFocusedRoute()

        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertEqual(navigation.stageRouteDepth, .root)
        XCTAssertEqual(AmbitionsSurface.allCases, [.today, .goals, .time, .you])
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("capture"))
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("motion"))
        XCTAssertTrue(navigation.lastEffectRun.proofArtifactIDs.isEmpty)
    }

    func testShellScaffoldOwnsBackSwipeThroughInteractionGestureMap() throws {
        let appShellSource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/App/AppShellView.swift"),
            encoding: .utf8
        )
        let rootHostSource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(appShellSource.contains("SurfaceGestureMap.isEdgeBackSwipe"))
        XCTAssertTrue(appShellSource.contains("DragGesture(minimumDistance: 12"))
        XCTAssertTrue(rootHostSource.contains("navigation.popFocusedRoute()"))
        XCTAssertFalse(rootHostSource.contains("onBack: { navigation.resetGoalsPath() }"))
        XCTAssertFalse(rootHostSource.contains("onBack: { navigation.resetTimePath() }"))
        XCTAssertFalse(rootHostSource.contains("onBack: { navigation.resetYouPath() }"))
    }
}

private extension StageBackGestureTests {
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
