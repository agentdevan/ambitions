import AmbitionsDesignSystem
import Foundation
import XCTest

final class CaptureRoutingPrimitiveFamilyTests: XCTestCase {
    func testAMB580CaptureRoutingPrimitiveFamilyContract() {
        let contract = CaptureRoutingPrimitiveFamilyContract.current

        XCTAssertEqual(contract.primitiveID, "capture-routing-family")
        XCTAssertEqual(contract.ownerSurface, "Global Capture")
        XCTAssertEqual(contract.productObjects, ["Capture Routing", "Atmosphere Composer", "Receipt"])
        XCTAssertEqual(contract.stageName, "Capture Routing Primitive Family")
        XCTAssertEqual(contract.screenshotIdentifier, "CaptureRoutingPrimitiveFamily")
        XCTAssertTrue(contract.replacesStructures.contains("generic routing panels"))
        XCTAssertTrue(contract.replacesStructures.contains("route category grids"))
        XCTAssertTrue(contract.replacesStructures.contains("route proof pills"))
        XCTAssertTrue(contract.replacesStructures.contains("rounded route option cards"))
        XCTAssertEqual(contract.routingOrder, [
            "input source",
            "deterministic route basis",
            "review state",
            "correction control",
            "receipt path",
            "no silent placement",
        ])
        XCTAssertTrue(contract.forbiddenPatterns.contains("fake confidence theater"))
        XCTAssertTrue(contract.forbiddenPatterns.contains("category grid"))
        XCTAssertTrue(contract.forbiddenPatterns.contains("chat transcript"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
        XCTAssertEqual(CaptureRoutingPrimitiveRole.routeReveal.semanticState, .review)
        XCTAssertEqual(CaptureRoutingPrimitiveRole.routeOption.semanticState, .focus)
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

        XCTAssertTrue(seamSource.contains("CaptureAtmosphereComposer("))
        XCTAssertTrue(seamSource.contains("CaptureDraftRouteService"))
        XCTAssertTrue(seamSource.contains("selectedDraftRouteType"))
        XCTAssertTrue(seamSource.contains("decision.createCaptureRequest(rawText: rawText, sourceType: sourceType)"))
        XCTAssertTrue(seamSource.contains("sourceType: sourceType"))
        XCTAssertTrue(seamSource.contains("shell.activated-capture.route-choice."))
        XCTAssertTrue(seamSource.contains("Keyboard dictation ready"))
        XCTAssertTrue(seamSource.contains("Ambitions does not record audio here."))
        XCTAssertTrue(seamSource.contains("shell.activated-capture-seam"))
        XCTAssertTrue(seamSource.contains("shell.activated-capture.route-reveal"))

        let composerOffset = try XCTUnwrap(offset(of: "private var composer", in: seamSource))
        let sourceTrustOffset = try XCTUnwrap(offset(of: "private var sourceTrust", in: seamSource))
        let saveOffset = try XCTUnwrap(offset(of: "private func saveCapture", in: seamSource))
        XCTAssertLessThan(composerOffset, sourceTrustOffset)
        XCTAssertLessThan(sourceTrustOffset, saveOffset)

        XCTAssertFalse(seamSource.contains("ActivatedCaptureRouteState"))
        XCTAssertFalse(seamSource.contains("LazyVGrid"))
        XCTAssertFalse(seamSource.contains("CaptureRoutingPrimitiveStage("))
        XCTAssertFalse(seamSource.contains("No cloud classifier"))
        XCTAssertFalse(seamSource.contains("Voice capture"))
    }

    func testAMB580QuickCaptureSheetUsesSharedComposerWithoutUnsupportedControlRail() throws {
        let appShellSource = try source("Native/Ambitions/App/AppShellView.swift", root: repoRoot())

        XCTAssertTrue(appShellSource.contains("CaptureAtmosphereComposer("))
        XCTAssertTrue(appShellSource.contains("quickCaptureRoutePreview"))
        XCTAssertTrue(appShellSource.contains("selectedDraftRouteType"))
        XCTAssertTrue(appShellSource.contains("decision.createCaptureRequest(rawText: rawText, sourceType: sourceType)"))
        XCTAssertTrue(appShellSource.contains("shell.overlay.quick-capture.route-choice."))
        XCTAssertTrue(appShellSource.contains("Keyboard dictation ready"))
        XCTAssertFalse(appShellSource.contains("quickCaptureControlRail"))
        XCTAssertFalse(appShellSource.contains("composerExpansionRail"))
        XCTAssertFalse(appShellSource.contains("Camera\", systemImage: \"camera\""))
        XCTAssertFalse(appShellSource.contains("Photos\", systemImage: \"photo.on.rectangle\""))
        XCTAssertFalse(appShellSource.contains("Files\", systemImage: \"folder\""))
    }

    func testAMB580CaptureRoutingPathRemainsLocalInspectableAndCorrectable() throws {
        let seamSource = try source("Native/Ambitions/App/AppShellActivatedCaptureSeam.swift", root: repoRoot())
        let sourcePolicy = try source("Native/Ambitions/App/AppShellCaptureSourcePolicy.swift", root: repoRoot())

        XCTAssertTrue(seamSource.contains("Saved on this device. Source, receipt, and route stay inspectable."))
        XCTAssertTrue(seamSource.contains("Route set to \\(routeType.userFacingLabel). Save writes that route locally."))
        XCTAssertTrue(seamSource.contains("Saved locally as \\(capture.route.title). Receipt path stays inspectable."))
        XCTAssertTrue(seamSource.contains("draftRouteService.draftRouteDecision"))
        XCTAssertTrue(seamSource.contains("decision.createCaptureRequest(rawText: rawText, sourceType: sourceType)"))
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
