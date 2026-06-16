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
        let timeDecisionSource = try source("Native/Ambitions/Features/Time/TimeReflowDecisionCard.swift", root: root)
        let timeFieldSource = try source("Native/Ambitions/Features/Time/TimeLifeShapeField.swift", root: root)
        let todayReplacementSource = try source("Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift", root: root)

        XCTAssertTrue(timeDecisionSource.contains("QuietReflowPrimitiveStage("))
        XCTAssertTrue(timeDecisionSource.contains("QuietReflowBeforeAfterPrimitive("))
        XCTAssertTrue(timeDecisionSource.contains("time.reflow-decision.option."))
        XCTAssertTrue(timeFieldSource.contains("QuietReflowPrimitiveStage("))
        XCTAssertTrue(timeFieldSource.contains("QuietReflowBeforeAfterPrimitive("))
        XCTAssertTrue(timeFieldSource.contains("time.life-shape-field.reflow-trust-seam"))
        XCTAssertTrue(timeFieldSource.contains("-AmbitionsTimeFocus"))
        XCTAssertTrue(timeFieldSource.contains("screenshotFocusesQuietReflow()"))
        XCTAssertTrue(todayReplacementSource.contains("QuietReflowPrimitiveStage("))
        XCTAssertTrue(todayReplacementSource.contains("TodayStepReplacementReceiptPreview"))
        XCTAssertTrue(todayReplacementSource.contains("replacementOptionSystemImage"))

        XCTAssertFalse(timeDecisionSource.contains("AppCard(state: decision.visualState)"))
        XCTAssertFalse(timeDecisionSource.contains("RoundedRectangle(cornerRadius: theme.radius.lg"))
        XCTAssertFalse(timeDecisionSource.contains("RoundedRectangle(cornerRadius: theme.radius.md"))
        XCTAssertFalse(todayReplacementSource.contains("replacementOptionBackground"))
        XCTAssertFalse(todayReplacementSource.contains("replacementOptionBorder"))
        XCTAssertFalse(todayReplacementSource.contains("surfaceSecondary.opacity(0.72)"))
        XCTAssertFalse(todayReplacementSource.contains("surfaceOverlay)\n        }\n        .overlay"))
    }

    func testAMB579PreviewBeforeCommitAndReceiptPathRemainInspectable() throws {
        let root = repoRoot()
        let timeDecisionSource = try source("Native/Ambitions/Features/Time/TimeReflowDecisionCard.swift", root: root)
        let timeFieldSource = try source("Native/Ambitions/Features/Time/TimeLifeShapeField.swift", root: root)
        let todayReplacementSource = try source("Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift", root: root)

        XCTAssertTrue(timeDecisionSource.contains("beforeLabel: preview.beforeLabel"))
        XCTAssertTrue(timeDecisionSource.contains("receiptLabel: preview.receiptPreviewLabel"))
        XCTAssertTrue(timeFieldSource.contains("beforeLabel: option.beforeAfterPreview.beforeLabel"))
        XCTAssertTrue(timeFieldSource.contains("receiptLabel: option.beforeAfterPreview.receiptPreviewLabel"))
        XCTAssertTrue(timeFieldSource.contains("receiptPreview.confirmationRequired"))
        XCTAssertTrue(todayReplacementSource.contains("state.approvalReceiptPreview(for: selectedAlternative)"))
        XCTAssertTrue(todayReplacementSource.contains("state.noSilentChangesLabel"))
        XCTAssertTrue(todayReplacementSource.contains("onApprove(selectedAlternative)"))
    }

    func testAMB579PrimitiveRegistryIncludesQuietReflowFamilyEntry() throws {
        let registry = try source("docs/codex/ambitions_primitive_invention_registry.md", root: repoRoot())

        XCTAssertTrue(registry.contains("| quiet-reflow-family | Promoted | Global action-state | Quiet Reflow / Receipt | AMB-579 |"))
        XCTAssertTrue(registry.contains("### quiet-reflow-family"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/action-state/AMB-579-quiet-reflow-family.md"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/screenshots/quiet-reflow-family-amb-579.png"))
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
