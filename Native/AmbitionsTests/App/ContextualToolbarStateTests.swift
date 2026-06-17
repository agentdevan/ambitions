import XCTest
@testable import Ambitions

final class ContextualToolbarStateTests: XCTestCase {
    func testToolbarCatalogCoversCanonicalSurfaceToolbars() {
        XCTAssertEqual(AppShellContextualToolbarCatalog.canonicalSurfaceCoverage, ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(ToolbarPreviewCatalog.coveredSurfaces, AppShellContextualToolbarCatalog.canonicalSurfaceCoverage)

        for tab in AppTab.allCases {
            let actions = AppShellContextualToolbarCatalog.actions(for: tab)
            XCTAssertEqual(actions.count, 2)
            XCTAssertEqual(actions.last?.kind, .captureFallback)
            XCTAssertEqual(actions.last?.title, "Capture")
        }
    }

    func testOneViewportActionDensityStaysBounded() {
        XCTAssertEqual(AppShellContextualToolbarCatalog.maxOneViewportActions, 2)
        XCTAssertTrue(ToolbarPreviewCatalog.supportsOneViewportActionDensity)

        for fixture in ToolbarPreviewCatalog.fixtures {
            XCTAssertLessThanOrEqual(fixture.oneViewportActionCount, AppShellContextualToolbarCatalog.maxOneViewportActions)
        }
    }

    func testDynamicTypeCompressionKeepsActionsAvailable() {
        XCTAssertTrue(ToolbarPreviewCatalog.supportsDynamicTypeCompression)

        for fixture in ToolbarPreviewCatalog.fixtures {
            XCTAssertTrue(fixture.dynamicTypeCompressionBehavior.contains("Actions menu"))
            XCTAssertTrue(fixture.actionTitles.contains("Capture"))
            XCTAssertEqual(
                AppShellContextualToolbarCatalog.shouldCompressActions(
                    dynamicTypeIsAccessibilitySize: true,
                    actionCount: fixture.oneViewportActionCount
                ),
                true
            )
            XCTAssertEqual(
                AppShellContextualToolbarCatalog.shouldCompressActions(
                    dynamicTypeIsAccessibilitySize: false,
                    actionCount: fixture.oneViewportActionCount
                ),
                false
            )
        }
    }

    func testNoDestructiveActionWithoutConfirmationBoundaryIsPreserved() {
        XCTAssertTrue(ToolbarPreviewCatalog.preservesNoDestructiveActionBoundary)

        for tab in AppTab.allCases {
            for action in AppShellContextualToolbarCatalog.actions(for: tab) {
                XCTAssertFalse(action.requiresConfirmationBeforeDestructiveEffect)
            }
        }
    }

    func testPreviewCatalogRemainsProofBounded() {
        XCTAssertEqual(ToolbarPreviewCatalog.ownerIssue, "AMB-995")
        XCTAssertEqual(ToolbarPreviewCatalog.claimUnlocked, "Fast access to key actions.")
        XCTAssertFalse(ToolbarPreviewCatalog.claimsScreenshotProof)
        XCTAssertFalse(ToolbarPreviewCatalog.claimsAccessibilityApproval)
    }
}
