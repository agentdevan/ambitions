import XCTest
@testable import Ambitions

final class ShellChromeAuditTests: XCTestCase {
    func testRootShellAuditPassesForCanonicalStagePolicy() {
        let policy = StagePathStore.chromePolicy(
            routeDepth: .root,
            overlayPresentation: .none,
            dynamicTypeIsAccessibilitySize: false
        )

        let report = ShellChromeAudit.audit(policy: policy)

        XCTAssertTrue(report.passed, report.findings.joined(separator: "\n"))
        XCTAssertEqual(StageDockDestination.all.map(\.surface), AmbitionsSurface.allCases)
        XCTAssertEqual(StageDockDestination.all.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertFalse(policy.showsDockBackdrop)
    }

    func testShellChromeAuditRejectsDuplicateBottomNavigation() {
        let policy = StagePathStore.chromePolicy(
            routeDepth: .root,
            overlayPresentation: .none,
            dynamicTypeIsAccessibilitySize: false
        )

        let report = ShellChromeAudit.audit(
            policy: policy,
            hasDuplicateBottomNavigationShelf: true
        )

        XCTAssertFalse(report.passed)
        XCTAssertTrue(report.findings.contains("Root shell must not expose duplicate bottom navigation chrome."))
    }

    func testShellChromeAuditRequiresDockHiddenForDrilldowns() {
        let policy = StagePathStore.chromePolicy(
            routeDepth: .drilldown,
            overlayPresentation: .none,
            dynamicTypeIsAccessibilitySize: false
        )

        let report = ShellChromeAudit.audit(policy: policy)

        XCTAssertTrue(report.passed, report.findings.joined(separator: "\n"))
        XCTAssertFalse(policy.showsRootDock)
        XCTAssertEqual(policy.stageContentBottomClearance, 0)
    }

    func testShellChromeAuditKeepsActivatedCaptureOutOfRootDockChrome() {
        let policy = StagePathStore.chromePolicy(
            routeDepth: .root,
            overlayPresentation: .activatedCaptureComposer,
            dynamicTypeIsAccessibilitySize: false
        )

        let report = ShellChromeAudit.audit(policy: policy)

        XCTAssertTrue(report.passed, report.findings.joined(separator: "\n"))
        XCTAssertFalse(policy.showsRootDock)
        XCTAssertGreaterThan(policy.captureComposerClearance, 0)
    }
}
