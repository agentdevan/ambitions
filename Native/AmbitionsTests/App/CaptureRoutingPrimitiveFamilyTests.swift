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
            "no silent placement"
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

    func testAMB580ActivatedCaptureSeamUsesCaptureRoutingPrimitiveFamily() throws {
        let appShellSource = try source("Native/Ambitions/App/AppShellView.swift", root: repoRoot())
        let seamSource = try activatedCaptureSeamSource(from: appShellSource)

        XCTAssertTrue(seamSource.contains("CaptureRoutingPrimitiveStage("))
        XCTAssertTrue(seamSource.contains("CaptureRoutingPrimitiveLine("))
        XCTAssertTrue(seamSource.contains("shell.activated-capture.activation-strip"))
        XCTAssertTrue(seamSource.contains("shell.activated-capture.state.typing-compact"))
        XCTAssertTrue(seamSource.contains("shell.activated-capture.route-basis-compact"))
        XCTAssertTrue(seamSource.contains("shell.activated-capture.reduce-motion-compact"))
        XCTAssertTrue(seamSource.contains("shell.activated-capture.route-proof-strip"))
        XCTAssertTrue(seamSource.contains("shell.activated-capture.placement-review"))
        XCTAssertTrue(seamSource.contains("shell.activated-capture.correction-fold"))
        XCTAssertTrue(seamSource.contains("routeBasisTitle"))
        XCTAssertTrue(seamSource.contains("routeBasisIdentifier"))
        XCTAssertTrue(seamSource.contains("reviewLabel"))
        XCTAssertTrue(seamSource.contains("Static route labels keep placement meaning visible without animation."))

        let inputOffset = try XCTUnwrap(offset(of: "inputRow", in: seamSource))
        let activationOffset = try XCTUnwrap(offset(of: "composerActivationStrip", in: seamSource))
        let routeRevealOffset = try XCTUnwrap(offset(of: "routeProofStrip", in: seamSource))
        XCTAssertLessThan(inputOffset, activationOffset)
        XCTAssertLessThan(activationOffset, routeRevealOffset)

        XCTAssertFalse(seamSource.contains("LazyVGrid"))
        XCTAssertFalse(seamSource.contains("routeProofPill"))
        XCTAssertFalse(seamSource.contains("Capsule()"))
        XCTAssertFalse(seamSource.contains("confidenceTitle"))
        XCTAssertFalse(seamSource.contains("confidenceIdentifier"))
        XCTAssertFalse(seamSource.contains("isHighConfidence"))
        XCTAssertFalse(seamSource.contains("High-confidence"))
        XCTAssertFalse(seamSource.contains("Low-confidence"))
    }

    func testAMB580CaptureRoutingPathRemainsLocalInspectableAndCorrectable() throws {
        let appShellSource = try source("Native/Ambitions/App/AppShellView.swift", root: repoRoot())
        let seamSource = try activatedCaptureSeamSource(from: appShellSource)

        XCTAssertTrue(seamSource.contains("Detected locally"))
        XCTAssertTrue(seamSource.contains("Corrected locally"))
        XCTAssertTrue(seamSource.contains("No silent placement"))
        XCTAssertTrue(seamSource.contains("No cloud classifier and no route mutation happens without user-visible review."))
        XCTAssertTrue(seamSource.contains("Route corrected locally to \\(route.title). SourceRecord, Receipt, and ReplayTrace remain inspectable."))
        XCTAssertTrue(seamSource.contains("saveState = .saved(\"Captured locally as \\(routeAtSave.title). Receipt path stays inspectable.\")"))
        XCTAssertTrue(seamSource.contains("CreateCaptureRequest(rawText: rawText, sourceType: appShellCaptureSourceType(for: overlay.entrySource))"))
    }

    func testAMB580PrimitiveRegistryIncludesCaptureRoutingFamilyEntry() throws {
        let registry = try source("docs/codex/ambitions_primitive_invention_registry.md", root: repoRoot())

        XCTAssertTrue(registry.contains("| capture-routing-family | Promoted | Global Capture | Capture Routing / Receipt | AMB-580 |"))
        XCTAssertTrue(registry.contains("### capture-routing-family"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/action-state/AMB-580-capture-routing-family.md"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/screenshots/capture-routing-family-amb-580.png"))
    }

    private func activatedCaptureSeamSource(from appShellSource: String) throws -> String {
        guard let start = appShellSource.range(of: "struct AppShellActivatedCaptureSeam: View"),
              let end = appShellSource.range(of: "private func appShellCaptureSourceType", range: start.lowerBound..<appShellSource.endIndex) else {
            throw XCTSkip("Activated Capture seam source could not be located.")
        }
        return String(appShellSource[start.lowerBound..<end.lowerBound])
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
