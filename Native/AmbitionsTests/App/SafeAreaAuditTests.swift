import XCTest
@testable import Ambitions

final class SafeAreaAuditTests: XCTestCase {
    func testSafeAreaAuditPassesForRootTimeChromePolicy() {
        let policy = StagePathStore.chromePolicy(
            routeDepth: .root,
            overlayPresentation: .none,
            dynamicTypeIsAccessibilitySize: false
        )

        let report = SafeAreaAudit.audit(policy: policy)

        XCTAssertTrue(report.passed, report.findings.joined(separator: "\n"))
        XCTAssertGreaterThanOrEqual(policy.stageContentBottomClearance, policy.dockClearance)
        XCTAssertGreaterThanOrEqual(policy.captureComposerClearance, policy.dockClearance)
        XCTAssertGreaterThan(
            StageSafeAreaPolicy.rootSurfaceContentBottomInset(dynamicTypeIsAccessibilitySize: false),
            policy.dockClearance
        )
    }

    func testSafeAreaAuditPassesForTimeDrilldownWithoutRootDockReserve() {
        let policy = StagePathStore.chromePolicy(
            routeDepth: .drilldown,
            overlayPresentation: .none,
            dynamicTypeIsAccessibilitySize: false
        )

        let report = SafeAreaAudit.audit(policy: policy)

        XCTAssertTrue(report.passed, report.findings.joined(separator: "\n"))
        XCTAssertFalse(policy.showsRootDock)
        XCTAssertEqual(policy.stageContentBottomClearance, 0)
        XCTAssertGreaterThan(StageSafeAreaPolicy.drilldownBottomClearance(dynamicTypeIsAccessibilitySize: false), 0)
    }

    func testSafeAreaAuditRequiresDynamicTypeClearanceExpansion() {
        let regular = StagePathStore.chromePolicy(
            routeDepth: .root,
            overlayPresentation: .none,
            dynamicTypeIsAccessibilitySize: false
        )
        let accessibility = StagePathStore.chromePolicy(
            routeDepth: .root,
            overlayPresentation: .none,
            dynamicTypeIsAccessibilitySize: true
        )

        let report = SafeAreaAudit.auditDynamicTypeExpansion(
            regular: regular,
            accessibility: accessibility
        )

        XCTAssertTrue(report.passed, report.findings.joined(separator: "\n"))
        XCTAssertGreaterThan(accessibility.dockClearance, regular.dockClearance)
        XCTAssertGreaterThan(
            StageSafeAreaPolicy.rootSurfaceContentBottomInset(dynamicTypeIsAccessibilitySize: true),
            StageSafeAreaPolicy.rootSurfaceContentBottomInset(dynamicTypeIsAccessibilitySize: false)
        )
    }

    func testRootSurfacesUseStageOwnedDockClearancePolicy() throws {
        let checkedPaths = [
            "Native/Ambitions/Surfaces/Goals/GoalsSurface.swift",
            "Native/Ambitions/Surfaces/Time/TimeSurface.swift",
            "Native/Ambitions/Surfaces/You/YouSurface.swift"
        ]

        for path in checkedPaths {
            let source = try String(contentsOf: repoRoot().appendingPathComponent(path), encoding: .utf8)
            XCTAssertTrue(
                source.contains("StageSafeAreaPolicy.rootSurfaceContentBottomInset"),
                "\(path) must reserve the root dock through StageSafeAreaPolicy."
            )
            XCTAssertFalse(source.contains("theme.spacing.xxxl + theme.spacing.xxl"), path)
        }

        let todaySource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Surfaces/Today/TodaySurface+02-autoLoad.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(todaySource.contains("StageSafeAreaPolicy.rootSurfaceContentBottomInset"))
        XCTAssertTrue(todaySource.contains("max("))
    }

    func testSafeAreaAuditKeepsActivatedCaptureClearOfKeyboardZone() {
        let policy = StagePathStore.chromePolicy(
            routeDepth: .root,
            overlayPresentation: .activatedCaptureComposer,
            dynamicTypeIsAccessibilitySize: true
        )

        let report = SafeAreaAudit.audit(policy: policy)

        XCTAssertTrue(report.passed, report.findings.joined(separator: "\n"))
        XCTAssertFalse(policy.showsRootDock)
        XCTAssertEqual(policy.stageContentBottomClearance, 0)
        XCTAssertGreaterThan(policy.captureComposerClearance, 0)
    }
}

private extension SafeAreaAuditTests {
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
