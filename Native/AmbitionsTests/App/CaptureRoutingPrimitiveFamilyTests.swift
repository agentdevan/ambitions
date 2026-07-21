import AmbitionsDesignSystem
import Foundation
import XCTest

final class CaptureRoutingPrimitiveFamilyTests: XCTestCase {
    func testAMB580CaptureRoutingPrimitiveFamilyContract() {
        let contract = CaptureRoutingPrimitiveFamilyContract.current

        XCTAssertEqual(contract.primitiveID, "capture-placement-family")
        XCTAssertEqual(contract.ownerSurface, "Global Capture")
        XCTAssertEqual(contract.productObjects, ["Placement Preview", "Atmosphere Composer", "Saved Capture"])
        XCTAssertEqual(contract.stageName, "Capture Placement Primitive Family")
        XCTAssertEqual(contract.screenshotIdentifier, "CapturePlacementPrimitiveFamily")
        XCTAssertTrue(contract.replacesStructures.contains("generic placement panels"))
        XCTAssertTrue(contract.replacesStructures.contains("category grids"))
        XCTAssertTrue(contract.replacesStructures.contains("proof pills"))
        XCTAssertTrue(contract.replacesStructures.contains("rounded placement option cards"))
        XCTAssertEqual(contract.routingOrder, [
            "input source",
            "deterministic placement basis",
            "review state",
            "correction control",
            "saved state",
            "no silent placement"
        ])
        XCTAssertTrue(contract.forbiddenPatterns.contains("fake confidence theater"))
        XCTAssertTrue(contract.forbiddenPatterns.contains("category grid"))
        XCTAssertTrue(contract.forbiddenPatterns.contains("chat transcript"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
        XCTAssertEqual(CaptureRoutingPrimitiveRole.placementPreview.semanticState, .review)
        XCTAssertEqual(CaptureRoutingPrimitiveRole.placementOption.semanticState, .focus)
        XCTAssertEqual(CaptureRoutingPrimitiveRole.receipt.semanticState, .trust)
        XCTAssertEqual(CaptureRoutingPrimitiveRole.noSilentPlacement.semanticState, .protected)
    }

    func testAMB580ActivatedCaptureSeamUsesSharedAtmosphereComposer() throws {
        let appShellSource = try source("Native/Ambitions/App/AppShellView.swift", root: repoRoot())
        XCTAssertFalse(appShellSource.contains("struct AppShellActivatedCaptureSeam: View"))
        XCTAssertFalse(appShellSource.contains("quickCaptureControlRail"))
        XCTAssertFalse(appShellSource.contains("composerExpansionRail"))
        XCTAssertFalse(appShellSource.contains("quickCaptureControlChip"))
        XCTAssertFalse(appShellSource.contains("Camera\", systemImage: \"camera\""))

        let seamSource = try source("Native/Ambitions/App/AppShellActivatedCaptureSeam.swift", root: repoRoot())

        XCTAssertTrue(seamSource.contains("CaptureObjectView("))
        XCTAssertTrue(seamSource.contains("CaptureDraftRouteService"))
        XCTAssertTrue(seamSource.contains("selectedDraftRouteType"))
        XCTAssertTrue(seamSource.contains("await command.execute("))
        XCTAssertTrue(seamSource.contains("selectedCaptureRouteType: selectedDraftRouteType ?? decision.routeType"))
        XCTAssertFalse(seamSource.contains("appContainer.captureService.createCapture("))
        XCTAssertTrue(seamSource.contains("sourceType: sourceType"))
        XCTAssertTrue(seamSource.contains("CaptureProposalStage("))
        XCTAssertTrue(seamSource.contains("presentProposal()"))
        XCTAssertTrue(seamSource.contains("let command: ActivatedCaptureCommand"))
        XCTAssertTrue(seamSource.contains("shell.activated-capture-seam"))
        XCTAssertFalse(seamSource.contains("shell.activated-capture.receipt"))

        let composerOffset = try XCTUnwrap(offset(of: "private var composer", in: seamSource))
        let saveOffset = try XCTUnwrap(offset(of: "private func saveCapture", in: seamSource))
        XCTAssertLessThan(composerOffset, saveOffset)

        XCTAssertFalse(seamSource.contains("ActivatedCaptureRouteState"))
        XCTAssertFalse(seamSource.contains("LazyVGrid"))
        XCTAssertFalse(seamSource.contains("CaptureRoutingPrimitiveStage("))
        XCTAssertFalse(seamSource.contains("No cloud classifier"))
        XCTAssertFalse(seamSource.contains("Voice capture"))
    }

    func testAMB580QuickCaptureSheetRoutesToActivatedComposerWithoutFallbackSave() throws {
        let stageSource = try source("Native/Ambitions/Stage/AmbitionsStage.swift", root: repoRoot())
        let seamSource = try source("Native/Ambitions/App/AppShellActivatedCaptureSeam.swift", root: repoRoot())
        let quietSource = try source("Native/Ambitions/Stage/Overlays/QuietCommandCaptureOverlay.swift", root: repoRoot())

        XCTAssertTrue(stageSource.contains("shellActivatedCaptureComposerSeam"))
        XCTAssertTrue(stageSource.contains("activeSheetOverlayBinding"))
        XCTAssertTrue(stageSource.contains("guard navigation.activeOverlay?.isActivatedCaptureComposer != true,"))
        XCTAssertTrue(stageSource.contains("navigation.activeOverlay?.kind != .memoryLens else"))
        XCTAssertTrue(seamSource.contains("CaptureObjectView("))
        XCTAssertTrue(seamSource.contains("CaptureProposalStage("))
        XCTAssertTrue(seamSource.contains("selectedDraftRouteType"))
        XCTAssertTrue(seamSource.contains("await command.execute("))
        XCTAssertTrue(seamSource.contains("selectedCaptureRouteType: selectedDraftRouteType ?? decision.routeType"))
        XCTAssertFalse(seamSource.contains("appContainer.captureService.createCapture("))
        XCTAssertTrue(quietSource.contains("captureComposerRedirect"))
        XCTAssertTrue(quietSource.contains("actions.presentGlobalCapture"))
        XCTAssertFalse(quietSource.contains("CaptureObjectView("))
        XCTAssertFalse(quietSource.contains("saveCapture()"))
        XCTAssertFalse(seamSource.contains("presentationDetents"))
        XCTAssertFalse(seamSource.contains("quickCaptureControlRail"))
        XCTAssertFalse(seamSource.contains("composerExpansionRail"))
        XCTAssertFalse(seamSource.contains("Camera\", systemImage: \"camera\""))
        XCTAssertFalse(seamSource.contains("Photos\", systemImage: \"photo.on.rectangle\""))
        XCTAssertFalse(seamSource.contains("Files\", systemImage: \"folder\""))
    }

    func testAMB580CaptureRoutingPathRemainsLocalInspectableAndCorrectable() throws {
        let seamSource = try source("Native/Ambitions/App/AppShellActivatedCaptureSeam.swift", root: repoRoot())
        let routerSource = try source("Native/Ambitions/App/ShellCommandRouter.swift", root: repoRoot())
        let sourcePolicy = try source("Native/Ambitions/App/AppShellCaptureSourcePolicy.swift", root: repoRoot())

        XCTAssertFalse(seamSource.contains("Destination: \\(savedCapture.route.title)"))
        XCTAssertFalse(seamSource.contains("shell.activated-capture.receipt.change-destination"))
        XCTAssertTrue(seamSource.contains("draftRouteService.draftRouteDecision"))
        XCTAssertTrue(seamSource.contains("await command.execute("))
        XCTAssertTrue(routerSource.contains("Saved locally in Capture. Placement stays editable."))
        XCTAssertTrue(seamSource.contains("let command: ActivatedCaptureCommand"))
        XCTAssertTrue(sourcePolicy.contains("return .shellComposer"))
        XCTAssertTrue(sourcePolicy.contains("return .todayQuickCapture"))
    }

    func testAMB580PrimitiveRegistryIncludesCaptureRoutingFamilyEntry() throws {
        let registryURL = repoRoot().appendingPathComponent("docs/codex/ambitions_primitive_invention_registry.md")
        guard FileManager.default.fileExists(atPath: registryURL.path) else {
            throw XCTSkip("Historical primitive registry is not retained in current repo truth.")
        }
        let registry = try String(contentsOf: registryURL, encoding: .utf8)

        XCTAssertTrue(registry.contains("| capture-routing-family | Promoted | Global Capture | Capture Routing / Receipt | AMB-580 |"))
        XCTAssertTrue(registry.contains("### capture-routing-family"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/action-state/AMB-580-capture-routing-family.md"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/screenshots/capture-routing-family-amb-580.png"))
    }

    private func offset(of needle: String, in source: String) -> Int? {
        guard let range = source.range(of: needle) else { return nil }
        return source.distance(from: source.startIndex, to: range.lowerBound)
    }

    private func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
