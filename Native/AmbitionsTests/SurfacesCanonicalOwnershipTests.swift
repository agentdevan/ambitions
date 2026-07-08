@testable import Ambitions
import XCTest

final class SurfacesCanonicalOwnershipTests: XCTestCase {
    func testCanonicalSurfaceFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Surfaces/SurfaceContract.swift",
            "Native/Ambitions/Surfaces/SurfacePrimaryObject.swift",
            "Native/Ambitions/Surfaces/SurfaceActionContract.swift",
            "Native/Ambitions/Surfaces/SurfaceDisclosureContract.swift",
            "Native/Ambitions/Surfaces/SurfaceLaw.swift",
            "Native/Ambitions/Surfaces/SurfaceLawAudit.swift",
            "Native/Ambitions/Surfaces/Today/TodaySurface.swift",
            "Native/Ambitions/Surfaces/Today/TodayObjectView.swift",
            "Native/Ambitions/Surfaces/Today/TodayInteractions.swift",
            "Native/Ambitions/Surfaces/Goals/GoalsSurface.swift",
            "Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift",
            "Native/Ambitions/Surfaces/Goals/GoalsInteractions.swift",
            "Native/Ambitions/Surfaces/You/YouSurface.swift",
            "Native/Ambitions/Surfaces/You/YouObjectView.swift",
            "Native/Ambitions/Surfaces/You/YouInteractions.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical surface owner: \(requiredPath)"
            )
        }
    }

    func testStageConsumesCanonicalSurfaceContractOwner() throws {
        let root = repoRoot()
        let stageSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Stage/AmbitionsSurface.swift"),
            encoding: .utf8
        )
        let surfaceSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Surfaces/SurfaceContract.swift"),
            encoding: .utf8
        )

        XCTAssertFalse(stageSource.contains("struct AmbitionsSurfaceContract"))
        XCTAssertFalse(stageSource.contains("enum AmbitionsSurfaceContractRegistry"))
        XCTAssertTrue(surfaceSource.contains("struct AmbitionsSurfaceContract"))
        XCTAssertTrue(surfaceSource.contains("enum AmbitionsSurfaceContractRegistry"))
        XCTAssertEqual(AmbitionsSurfaceContractRegistry.validate(), [])
    }

    func testPersistentRootSurfacesRejectRemovedSurfaceNames() {
        XCTAssertEqual(AmbitionsSurface.allCases.map(\.rawValue), ["today", "goals", "time", "you"])
        for removed in [
            "activity",
            "activity-feed",
            "ai",
            "analytics",
            "assistant",
            "capture",
            "captures",
            "chatbot",
            "dashboard",
            "dashboards",
            "feed",
            "habit",
            "habits",
            "insights",
            "kpi",
            "motion",
            "plan",
            "profile",
            "productivity",
            "score",
            "streak",
            "task",
            "task-board",
            "taskboard",
            "tasks",
        ] {
            XCTAssertNil(AmbitionsSurface(rawValue: removed), "\(removed) must not become a persistent root surface")
            XCTAssertTrue(SurfaceLaw.blockedRootRawValues.contains(removed), "\(removed) must stay blocked by SurfaceLaw")
        }
    }

    func testRootHostUsesCanonicalSurfaceOwners() throws {
        let root = repoRoot()
        let source = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("TodaySurface(showsNavigationChrome: false)"))
        XCTAssertTrue(source.contains("GoalsSurface("))
        XCTAssertTrue(source.contains("TimeSurface(showsNavigationChrome: false)"))
        XCTAssertTrue(source.contains("YouSurface(showsNavigationChrome: false)"))
        XCTAssertFalse(source.contains("TodayScreen("))
        XCTAssertFalse(source.contains("GoalsScreen("))
        XCTAssertFalse(source.contains("YouScreen("))
    }

    func testOldRootScreenFilesAreRemoved() {
        let root = repoRoot()
        for removedPath in [
            "Native/Ambitions/Surfaces/Today/TodayScreen.swift",
            "Native/Ambitions/Surfaces/Goals/GoalsScreen.swift",
            "Native/Ambitions/Surfaces/You/YouScreen.swift",
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(removedPath).path),
                "Old root screen owner still exists: \(removedPath)"
            )
        }
    }
}

private extension SurfacesCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Surfaces")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
