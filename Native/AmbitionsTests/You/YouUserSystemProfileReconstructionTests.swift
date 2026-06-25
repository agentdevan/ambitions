@testable import Ambitions
import XCTest

final class YouUserSystemProfileReconstructionTests: XCTestCase {
    func testYouObjectStageContractOwnsUserSystemProfile() {
        let contract = YouObjectStageControlPrimitiveContract.current
        XCTAssertEqual(contract.ownerSurface, "You")
        XCTAssertEqual(contract.productObject, "User System Profile")
        XCTAssertEqual(contract.stageName, "You settings")
        XCTAssertTrue(contract.avoidsGenericProfileSettingsWall)
    }

    func testAMB1198ObjectStageContractCoversRequiredNativeSettingsMap() {
        XCTAssertEqual(YouObjectStageControlPrimitiveContract.current.sourceControlOrder, [
            "appearance",
            "capture",
            "life areas",
            "privacy",
            "local data",
            "sources",
            "receipts and history",
            "accessibility",
            "about",
        ])
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
        XCTAssertEqual(YouRootDetail.lifeAreas.routeTarget, .lifeAreas)
        XCTAssertEqual(YouRootDetail.localDataControls.routeTarget, .localDataControls)
        XCTAssertEqual(YouRootDetail.accessibility.routeTarget, .accessibility)
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
        XCTAssertEqual(YouRouteTarget.lifeAreas.deepLinkPath, "life-areas")
    }

    func testAMB1198RootSourceRemovesInternalHeadersGovernanceWallDividerAndGlow() throws {
        let rootSource = try source("Native/Ambitions/Surfaces/You/YouRootSurface.swift")
        let surfaceSource = try source("Native/Ambitions/Surfaces/You/YouSurface.swift")

        XCTAssertFalse(rootSource.contains("YOU · Profile and settings"))
        XCTAssertFalse(rootSource.contains("Your System"))
        XCTAssertFalse(rootSource.contains("How Ambitions works for me"))
        XCTAssertFalse(rootSource.contains("Personal system / User System Profile"))
        XCTAssertFalse(surfaceSource.contains("LinearGradient("))
        XCTAssertTrue(rootSource.contains("UserSystemProfileRootView"))
        XCTAssertTrue(rootSource.contains("RootSettingsRow("))
        XCTAssertTrue(rootSource.contains("NativeSettingsGroup(title: group.title)"))
        XCTAssertTrue(rootSource.contains("title: \"Appearance\""))
        XCTAssertTrue(rootSource.contains("title: \"Open Field\""))
        XCTAssertTrue(rootSource.contains("title: \"Life Areas\""))
        XCTAssertTrue(rootSource.contains("title: \"Permissions\""))
        XCTAssertTrue(rootSource.contains("title: \"Local Data\""))
        XCTAssertTrue(rootSource.contains("title: \"Accessibility\""))
        XCTAssertTrue(rootSource.contains("title: \"About\""))
        XCTAssertFalse(rootSource.contains("PersonalSystemCenterRootView"))
        XCTAssertFalse(rootSource.contains("YouPersonalSystemNavigation("))
        XCTAssertFalse(rootSource.contains("id: \"source-settings\""))
        XCTAssertFalse(rootSource.contains("id: \"receipts-history\""))
    }

    func testAMB1198DetailsExposeHonestUnavailableAndConfirmationBoundaries() throws {
        let detailSource = try source("Native/Ambitions/Surfaces/You/YouRootDetailContent.swift")

        XCTAssertTrue(detailSource.contains("Gesture teaching reset"))
        XCTAssertTrue(detailSource.contains("Unavailable"))
        XCTAssertTrue(detailSource.contains("Broad destructive erase is not exposed from this detail."))
        XCTAssertTrue(detailSource.contains("Any destructive local-data action must require confirmation"))
        XCTAssertTrue(detailSource.contains("No connected external source is faked from this setting."))
        XCTAssertTrue(detailSource.contains("Manual accessibility proof is still pending."))
    }

    func testAMB1198AppearanceLiveUpdateHookStillExists() throws {
        let detailRouteSource = try source("Native/Ambitions/Surfaces/You/YouRootDetailRouteSurface.swift")

        XCTAssertTrue(detailRouteSource.contains(".onChange(of: viewModel.appearancePreference)"))
        XCTAssertTrue(detailRouteSource.contains(".onChange(of: viewModel.accentFamily)"))
        XCTAssertTrue(detailRouteSource.contains("applyAppearancePreviewFromEditor()"))
        XCTAssertTrue(detailRouteSource.contains("userSystem.applyAppearancePreference("))
    }

    private func source(_ relativePath: String) throws -> String {
        try String(contentsOf: repoRoot().appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func repoRoot() -> URL {
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
