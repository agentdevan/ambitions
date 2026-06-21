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
