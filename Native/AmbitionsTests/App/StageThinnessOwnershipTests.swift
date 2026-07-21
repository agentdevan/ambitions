import XCTest
@testable import Ambitions

final class StageThinnessOwnershipTests: XCTestCase {
    func testStageOverlayDirectoryRetainsOnlyShellPresentationFiles() throws {
        let root = repoRoot()
        let stageOverlayFiles = try swiftFileRelativePaths(
            under: root.appendingPathComponent("Native/Ambitions/Stage/Overlays"),
            root: root
        )

        XCTAssertEqual(
            Set(stageOverlayFiles),
            Set([
                "Native/Ambitions/Stage/Overlays/AppShellOverlayView.swift",
                "Native/Ambitions/Stage/Overlays/CapturePresentationRoute.swift",
                "Native/Ambitions/Stage/Overlays/QuietCommandCaptureOverlay.swift",
                "Native/Ambitions/Stage/Overlays/QuietCommandMemoryLensOverlay.swift",
                "Native/Ambitions/Stage/Overlays/QuietCommandSheetView.swift",
                "Native/Ambitions/Stage/Overlays/ShellOverlayState.swift"
            ])
        )
        XCTAssertFalse(stageOverlayFiles.contains { $0.contains("/Projection/") })
        XCTAssertFalse(stageOverlayFiles.contains { $0.split(separator: "/").last?.hasPrefix("Today") == true })

        for path in [
            "Native/Ambitions/Surfaces/Today/Overlays/TodayActionClosureSheet.swift",
            "Native/Ambitions/Surfaces/Today/Overlays/TodayRejectionReasonSheet.swift",
            "Native/Ambitions/Surfaces/Today/Overlays/TodayStepDetailSheet.swift",
            "Native/Ambitions/Surfaces/Today/Overlays/TodayStepReplacementSheet.swift",
            "Native/Ambitions/Surfaces/Today/Projection/ClosureLens.swift",
            "Native/Ambitions/Surfaces/Today/Projection/ClosureStageScene.swift",
            "Native/Ambitions/Surfaces/You/Projection/SearchLens.swift",
            "Native/Ambitions/Surfaces/You/Projection/SearchStageScene.swift"
        ] {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
    }

    func testSurfaceOwnedOverlayContractsCarryAccessibilityMotionAndDeepLinkSemantics() throws {
        let contracts = [SearchStageScene.contract, ClosureStageScene.contract]

        XCTAssertEqual(contracts.map(\.ownerLayer), ["Surfaces/You/Projection", "Surfaces/Today/Projection"])
        for contract in contracts {
            XCTAssertTrue(contract.satisfiesFinalCanon, contract.kind.rawValue)
            XCTAssertTrue(contract.semanticMirror.localizedCaseInsensitiveContains("accessibility"), contract.kind.rawValue)
            XCTAssertTrue(contract.motionBehavior.localizedCaseInsensitiveContains("Stage/Motion"), contract.kind.rawValue)
        }

        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://overlay/memory-lens?intent=open_goal&q=career"))
        XCTAssertEqual(
            translator.route(fromDeepLink: url),
            .presentOverlay(
                .memoryLens(
                    intent: .openGoal,
                    entrySource: .deepLink,
                    presentationContext: .recall,
                    query: "career"
                )
            )
        )
    }

    func testStageMotionReductionPolicyKeepsStageBehaviorStatic() {
        let policy = StageMotionReductionPolicy.current(reduceMotionEnabled: true)

        XCTAssertEqual(policy.displayStyle, .calm)
        XCTAssertFalse(policy.allowsAmbientMovement)
        XCTAssertTrue(policy.movementTextureDescription.localizedCaseInsensitiveContains("static"))
        XCTAssertEqual(policy.motionQuery(label: "review", action: .reviewHistory(nil)), "review")
        XCTAssertEqual(policy.motionQuery(label: "review", action: .reviewHistory("review-id")), "review:review-id")
    }

    func testShellPresentationViewsRequireExplicitNarrowDependencies() throws {
        let activatedCapture = try source("Native/Ambitions/App/AppShellActivatedCaptureSeam.swift")
        let overlayHost = try source("Native/Ambitions/Stage/Overlays/AppShellOverlayView.swift")
        let commandSheet = try source("Native/Ambitions/Stage/Overlays/QuietCommandSheetView.swift")
        let captureOverlay = try source("Native/Ambitions/Stage/Overlays/QuietCommandCaptureOverlay.swift")
        let memoryOverlay = try source("Native/Ambitions/Stage/Overlays/QuietCommandMemoryLensOverlay.swift")
        let stage = try source("Native/Ambitions/Stage/AmbitionsStage.swift")
        let presentationSources = [activatedCapture, overlayHost, commandSheet, captureOverlay, memoryOverlay]

        for viewSource in presentationSources {
            XCTAssertFalse(viewSource.contains("@Environment(\\.appContainer)"))
            XCTAssertFalse(viewSource.contains("appContainer?"))
            XCTAssertFalse(viewSource.contains("guard let appContainer"))
        }

        XCTAssertTrue(activatedCapture.contains("let command: ActivatedCaptureCommand"))
        XCTAssertTrue(activatedCapture.contains("await command.execute("))
        XCTAssertTrue(overlayHost.contains("let actions: ShellOverlayActions"))
        XCTAssertTrue(commandSheet.contains("let actions: ShellOverlayActions"))
        XCTAssertTrue(memoryOverlay.contains("await actions.search("))
        XCTAssertTrue(memoryOverlay.contains("guard query == memoryQuery else"))
        XCTAssertTrue(stage.contains("ShellOverlayActions("))
        XCTAssertTrue(stage.contains("ActivatedCaptureCommand("))
    }

    func testStageThinnessInventoryCoversRequiredLeakageCategories() throws {
        let inventory = try source("docs/audits/amb-1673-stage-thinness-inventory.md")

        for term in [
            "Routing",
            "Overlays",
            "Chrome",
            "Animation",
            "safe area",
            "Focus",
            "Mutation",
            "Projection",
            "Domain leakage",
            "Custom navigation",
            "Reduced motion",
            "VoiceOver",
            "Deep link"
        ] {
            XCTAssertTrue(inventory.localizedCaseInsensitiveContains(term), term)
        }
    }

    private func source(_ relativePath: String) throws -> String {
        try String(contentsOf: repoRoot().appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func swiftFileRelativePaths(under root: URL, root repoRoot: URL) throws -> [String] {
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return try enumerator.compactMap { item in
            guard let url = item as? URL else { return nil }
            let values = try url.resourceValues(forKeys: [.isRegularFileKey])
            guard values.isRegularFile == true, url.pathExtension == "swift" else { return nil }
            return String(url.path.dropFirst(repoRoot.path.count + 1))
        }.sorted()
    }
}
