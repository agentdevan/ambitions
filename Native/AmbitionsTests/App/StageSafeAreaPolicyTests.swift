@testable import Ambitions
import XCTest

final class StageSafeAreaPolicyTests: XCTestCase {
    func testRootShellTopInsetDoesNotPullSurfaceContentUnderHeader() {
        XCTAssertGreaterThanOrEqual(
            StageSafeAreaPolicy.topInsetSpacing(
                hasBackButton: false,
                dynamicTypeIsAccessibilitySize: false
            ),
            8
        )
        XCTAssertGreaterThanOrEqual(
            StageSafeAreaPolicy.topInsetSpacing(
                hasBackButton: false,
                dynamicTypeIsAccessibilitySize: true
            ),
            12
        )
        XCTAssertEqual(
            StageSafeAreaPolicy.topInsetSpacing(
                hasBackButton: true,
                dynamicTypeIsAccessibilitySize: false
            ),
            0
        )
        XCTAssertGreaterThanOrEqual(
            StageSafeAreaPolicy.topContentClearance(
                reservesPrimaryObjectTopClearance: true,
                dynamicTypeIsAccessibilitySize: false
            ),
            80
        )
        XCTAssertGreaterThan(
            StageSafeAreaPolicy.topContentClearance(
                reservesPrimaryObjectTopClearance: true,
                dynamicTypeIsAccessibilitySize: true
            ),
            StageSafeAreaPolicy.topContentClearance(
                reservesPrimaryObjectTopClearance: true,
                dynamicTypeIsAccessibilitySize: false
            )
        )
        XCTAssertEqual(
            StageSafeAreaPolicy.topContentClearance(
                reservesPrimaryObjectTopClearance: false,
                dynamicTypeIsAccessibilitySize: true
            ),
            0
        )
    }

    func testStagePathPolicyComputesRootDockAndOverlayClearance() {
        let root = StagePathStore.chromePolicy(
            routeDepth: .root,
            overlayPresentation: .none,
            dynamicTypeIsAccessibilitySize: false
        )
        XCTAssertTrue(root.showsRootDock)
        XCTAssertFalse(root.showsDockBackdrop)
        XCTAssertEqual(root.dockClearance, 148)
        XCTAssertEqual(root.stageContentBottomClearance, 148)
        XCTAssertEqual(root.captureComposerClearance, 148)
        XCTAssertEqual(
            StageSafeAreaPolicy.rootSurfaceContentBottomInset(dynamicTypeIsAccessibilitySize: false),
            168
        )

        let capture = StagePathStore.chromePolicy(
            routeDepth: .root,
            overlayPresentation: .activatedCaptureComposer,
            dynamicTypeIsAccessibilitySize: false
        )
        XCTAssertFalse(capture.showsRootDock)
        XCTAssertFalse(capture.showsDockBackdrop)
        XCTAssertEqual(capture.stageContentBottomClearance, 0)
        XCTAssertEqual(capture.captureComposerClearance, 18)

        let search = StagePathStore.chromePolicy(
            routeDepth: .root,
            overlayPresentation: .memoryLens,
            dynamicTypeIsAccessibilitySize: false
        )
        XCTAssertFalse(search.showsRootDock)
        XCTAssertTrue(StageOverlay.current(.memoryLens(entrySource: .shellUtility)).hidesRootDock)

        let drilldown = StagePathStore.chromePolicy(
            routeDepth: .drilldown,
            overlayPresentation: .none,
            dynamicTypeIsAccessibilitySize: true
        )
        XCTAssertFalse(drilldown.showsRootDock)
        XCTAssertEqual(drilldown.stageContentBottomClearance, 0)
        XCTAssertEqual(drilldown.continuityReceiptBottomClearance, 40)
        XCTAssertEqual(
            StageSafeAreaPolicy.rootSurfaceContentBottomInset(dynamicTypeIsAccessibilitySize: true),
            184
        )
    }
}
