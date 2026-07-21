import XCTest
@testable import Ambitions

final class ContextualToolbarStateTests: XCTestCase {
    func testToolbarCatalogCoversCanonicalSurfaceToolbars() {
        XCTAssertEqual(AppShellContextualToolbarCatalog.canonicalSurfaceCoverage, ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(ToolbarPreviewCatalog.coveredSurfaces, AppShellContextualToolbarCatalog.canonicalSurfaceCoverage)

        for tab in AmbitionsSurface.allCases {
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

        for tab in AmbitionsSurface.allCases {
            for action in AppShellContextualToolbarCatalog.actions(for: tab) {
                XCTAssertFalse(action.requiresConfirmationBeforeDestructiveEffect)
            }
        }
    }

    func testToolbarActionsCarryTypedRoutesInsteadOfDisplayIdentifierRouting() throws {
        let expectedRoutes: [AmbitionsSurface: [String]] = [
            .today: ["selectToday", "capture(today)"],
            .goals: ["createGoal", "capture(goals)"],
            .time: ["weeklyReview", "capture(time)"],
            .you: ["memoryLens", "capture(you)"]
        ]

        for surface in AmbitionsSurface.allCases {
            let routes = AppShellContextualToolbarCatalog.actions(for: surface).map { action in
                Mirror(reflecting: action).children.first(where: { $0.label == "route" }).map {
                    String(describing: $0.value)
                }
            }
            XCTAssertEqual(routes.compactMap { $0 }, expectedRoutes[surface])
        }

        let stageSource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Stage/AmbitionsStage.swift"),
            encoding: .utf8
        )
        XCTAssertFalse(stageSource.contains("switch action.id"))
        XCTAssertTrue(stageSource.contains("navigation.performToolbarAction(action)"))
    }

    @MainActor
    func testEveryTypedToolbarRouteDispatchesReducerOwnedStageSemantics() {
        for surface in AmbitionsSurface.allCases {
            let navigation = StageStore(selectedSurface: surface)
            let actions = AppShellContextualToolbarCatalog.actions(for: surface)

            navigation.performToolbarAction(actions[0])

            switch surface {
            case .today:
                XCTAssertEqual(navigation.selectedTab, .today)
                XCTAssertEqual(navigation.lastEffectRun.proofArtifactIDs, ["stage.surface.today"])
            case .goals:
                XCTAssertEqual(navigation.activeOverlay?.typedCaptureRoute?.kind, .goalSeed)
                XCTAssertEqual(navigation.lastStageFocusPlan.target, .overlay("quiet-command-sheet"))
            case .time:
                XCTAssertEqual(navigation.timePath, [.weeklyReview])
                XCTAssertEqual(navigation.lastStageFocusPlan.target, .drilldownBackButton(.time))
            case .you:
                XCTAssertEqual(navigation.activeOverlay?.kind, .memoryLens)
                XCTAssertEqual(navigation.lastStageFocusPlan.target, .overlay("memory-lens"))
            }

            navigation.performToolbarAction(actions[1])
            XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
            XCTAssertEqual(navigation.lastStageFocusPlan.target, .overlay("quiet-command-sheet"))
        }
    }

    func testPreviewCatalogRemainsProofBounded() {
        XCTAssertEqual(ToolbarPreviewCatalog.ownerIssue, "AMB-995")
        XCTAssertEqual(ToolbarPreviewCatalog.claimUnlocked, "Fast access to key actions.")
        XCTAssertFalse(ToolbarPreviewCatalog.claimsScreenshotProof)
        XCTAssertFalse(ToolbarPreviewCatalog.claimsAccessibilityApproval)
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
