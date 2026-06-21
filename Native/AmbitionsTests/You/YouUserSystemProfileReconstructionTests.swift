import XCTest
@testable import Ambitions

final class YouUserSystemProfileReconstructionTests: XCTestCase {
    func testYouObjectStageContractOwnsUserSystemProfile() {
        let contract = YouObjectStageControlPrimitiveContract.current
        XCTAssertEqual(contract.ownerSurface, "You")
        XCTAssertEqual(contract.productObject, "User System Profile")
        XCTAssertEqual(contract.stageName, "User System Profile")
        XCTAssertTrue(contract.avoidsGenericProfileSettingsWall)
    }

    func testYouObjectStageContractCoversNativeSettingsMap() {
        let order = Set(YouObjectStageControlPrimitiveContract.current.sourceControlOrder)
        XCTAssertTrue(order.contains("account and profile"))
        XCTAssertTrue(order.contains("privacy and automation"))
        XCTAssertTrue(order.contains("appearance"))
        XCTAssertTrue(order.contains("notifications"))
        XCTAssertTrue(order.contains("learning"))
        XCTAssertTrue(order.contains("receipts and history"))
        XCTAssertTrue(order.contains("export"))
        XCTAssertTrue(order.contains("support"))
    }

    func testYouObjectStageContractRejectsBadProfileShapes() {
        let replaced = Set(YouObjectStageControlPrimitiveContract.current.replacesFirstViewportStructures)
        XCTAssertTrue(replaced.contains("social profile"))
        XCTAssertTrue(replaced.contains("admin panel"))
        XCTAssertTrue(replaced.contains("AI settings wall"))
        XCTAssertTrue(replaced.contains("verbose documentation UI"))
        XCTAssertTrue(replaced.contains("internal runtime console"))
        XCTAssertTrue(replaced.contains("generic settings wall"))
    }

    func testPriorityYouRowsUseStageOwnedRoutesInsteadOfLocalSheets() {
        XCTAssertEqual(YouRootDetail.automationTrust.routeTarget, .privacyAutomation)
        XCTAssertEqual(YouRootDetail.personalRuntime.routeTarget, .personalSystem)
        XCTAssertEqual(YouRootDetail.receiptsHistory.routeTarget, .receiptsHistory)
        XCTAssertEqual(YouRootDetail.appearance.routeTarget, .appearance)
    }

    func testYouDetailRouteHidesRootDockThroughStagePolicy() {
        let policy = StagePathStore.chromePolicy(
            goalsPath: [],
            timePath: [],
            youPath: [.privacyAutomation],
            activeOverlay: nil,
            dynamicTypeIsAccessibilitySize: false
        )

        XCTAssertFalse(policy.showsRootDock)
        XCTAssertEqual(
            StagePathStore.routeDepth(goalsPath: [], timePath: [], youPath: [.privacyAutomation]),
            .drilldown
        )
    }

    func testYouDetailRoutesHaveStableDeepLinkPaths() {
        XCTAssertEqual(YouRouteTarget.privacyAutomation.deepLinkPath, "privacy-automation")
        XCTAssertEqual(YouRouteTarget.receiptsHistory.deepLinkPath, "receipts-history")
        XCTAssertEqual(YouRouteTarget.monthlyReview.deepLinkPath, "monthly-review")
    }
}
