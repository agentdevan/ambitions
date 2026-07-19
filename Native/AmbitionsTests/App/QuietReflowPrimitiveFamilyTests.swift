import AmbitionsDesignSystem
import Foundation
import XCTest

final class QuietReflowPrimitiveFamilyTests: XCTestCase {
    func testAMB579QuietReflowPrimitiveFamilyContract() {
        let contract = QuietReflowPrimitiveFamilyContract.current

        XCTAssertEqual(contract.primitiveID, "quiet-reflow-family")
        XCTAssertEqual(contract.ownerSurface, "Global action-state")
        XCTAssertEqual(contract.productObjects, ["Quiet Reflow", "Preview-before-commit", "Receipt"])
        XCTAssertEqual(contract.stageName, "Quiet Reflow Primitive Family")
        XCTAssertEqual(contract.screenshotIdentifier, "QuietReflowPrimitiveFamily")
        XCTAssertTrue(contract.replacesStructures.contains("generic reflow panels"))
        XCTAssertTrue(contract.replacesStructures.contains("rounded reflow option cards"))
        XCTAssertTrue(contract.replacesStructures.contains("review preview cards"))
        XCTAssertEqual(contract.previewOrder, [
            "current state",
            "proposed state",
            "reason",
            "user control",
            "review preview",
            "user choice"
        ])
        XCTAssertTrue(contract.forbiddenPatterns.contains("silent schedule mutation"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
        XCTAssertEqual(QuietReflowPrimitiveRole.preview.semanticState, .review)
        XCTAssertEqual(QuietReflowPrimitiveRole.option.semanticState, .focus)
        XCTAssertEqual(QuietReflowPrimitiveRole.receipt.semanticState, .trust)
        XCTAssertEqual(QuietReflowPrimitiveRole.noSilentChange.semanticState, .protected)
    }

    func testAMB579ActiveQuietReflowSurfacesUsePrimitiveFamily() throws {
        let root = repoRoot()
        let timeFieldSource = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift", root: root)
        let timeReflowSource = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldReflow.swift", root: root)
        let todayReplacementSource = try source("Native/Ambitions/Surfaces/Today/Overlays/TodayStepReplacementSheet+04-TodayStepReplacementSheet.swift", root: root)

        XCTAssertTrue(timeReflowSource.contains("QuietReflowPrimitiveStage("))
        XCTAssertTrue(timeReflowSource.contains("QuietReflowBeforeAfterPrimitive("))
        XCTAssertTrue(timeReflowSource.contains("time.life-shape-field.change-review-seam"))
        XCTAssertTrue(timeReflowSource.contains("time.life-shape-field.change-review."))
        XCTAssertTrue(timeFieldSource.contains("-AmbitionsTimeFocus"))
        XCTAssertTrue(timeFieldSource.contains("screenshotFocusesQuietReflow()"))
        XCTAssertTrue(todayReplacementSource.contains("QuietReflowPrimitiveStage("))
        XCTAssertTrue(todayReplacementSource.contains("TodayStepReplacementReceiptPreview"))
        XCTAssertTrue(todayReplacementSource.contains("replacementOptionSystemImage"))

        XCTAssertFalse(timeFieldSource.contains("AppCard(state: decision.visualState)"))
        XCTAssertFalse(todayReplacementSource.contains("replacementOptionBackground"))
        XCTAssertFalse(todayReplacementSource.contains("replacementOptionBorder"))
        XCTAssertFalse(todayReplacementSource.contains("surfaceSecondary.opacity(0.72)"))
        XCTAssertFalse(todayReplacementSource.contains("surfaceOverlay)\n        }\n        .overlay"))
    }

    func testAMB579PreviewBeforeCommitAndReceiptPathRemainInspectable() throws {
        let root = repoRoot()
        let timeReflowSource = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldReflow.swift", root: root)
        let todayReplacementSource = try source("Native/Ambitions/Surfaces/Today/Overlays/TodayStepReplacementSheet+04-TodayStepReplacementSheet.swift", root: root)

        XCTAssertTrue(timeReflowSource.contains("beforeLabel: option.beforeAfterPreview.beforeLabel"))
        XCTAssertTrue(timeReflowSource.contains("receiptLabel: option.beforeAfterPreview.receiptPreviewLabel"))
        XCTAssertTrue(timeReflowSource.contains("receiptPreview.confirmationRequired"))
        XCTAssertTrue(todayReplacementSource.contains("state.approvalReceiptPreview(for: selectedAlternative)"))
        XCTAssertTrue(todayReplacementSource.contains("state.noSilentChangesLabel"))
        XCTAssertTrue(todayReplacementSource.contains("onApprove(selectedAlternative)"))
    }

    func testAMB579PrimitiveRegistryIncludesQuietReflowFamilyEntry() throws {
        let registryURL = repoRoot().appendingPathComponent("docs/codex/ambitions_primitive_invention_registry.md")
        guard FileManager.default.fileExists(atPath: registryURL.path) else {
            throw XCTSkip("Historical primitive registry is not retained in current repo truth.")
        }
        let registry = try String(contentsOf: registryURL, encoding: .utf8)

        XCTAssertTrue(registry.contains("| quiet-reflow-family | Promoted | Global action-state | Quiet Reflow / Receipt | AMB-579 |"))
        XCTAssertTrue(registry.contains("### quiet-reflow-family"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/action-state/AMB-579-quiet-reflow-family.md"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/screenshots/quiet-reflow-family-amb-579.png"))
    }

    func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
