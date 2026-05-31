import XCTest
@testable import Ambitions

final class ShellPreviewMatrixTests: XCTestCase {
    func testAFRI005PreviewMatrixCoversCanonicalTabsAndRequiredVisualVariants() {
        XCTAssertEqual(ShellPreviewMatrix.canonicalTabs, [.today, .goals, .capture, .time, .you])
        XCTAssertEqual(ShellPreviewMatrix.rows.count, AppTab.allCases.count * ShellPreviewMatrix.variants.count)
        XCTAssertTrue(ShellPreviewMatrix.variants.contains { $0.colorAppearance == .dark })
        XCTAssertTrue(ShellPreviewMatrix.variants.contains { $0.colorAppearance == .oled })
        XCTAssertTrue(ShellPreviewMatrix.variants.contains { $0.dynamicTypeCategory.contains("Accessibility") })
        XCTAssertTrue(ShellPreviewMatrix.variants.contains { $0.reduceMotion })
        XCTAssertTrue(ShellPreviewMatrix.validationFailures().isEmpty)
    }

    func testAFRI005PreviewMatrixCoversMajorShellStates() {
        let coveredStates = Set(ShellPreviewMatrix.variants.map(\.shellState))

        XCTAssertEqual(coveredStates, Set(ShellPreviewState.allCases))
        XCTAssertTrue(ShellPreviewMatrix.rows.contains { $0.tab == .today && $0.variant.shellState == .steady })
        XCTAssertTrue(ShellPreviewMatrix.rows.contains { $0.tab == .capture && $0.variant.shellState == .globalEntryOpen })
        XCTAssertTrue(ShellPreviewMatrix.rows.contains { $0.tab == .time && $0.variant.shellState == .continuityReceipt })
        XCTAssertTrue(ShellPreviewMatrix.rows.contains { $0.tab == .you && $0.variant.shellState == .externalRoute })
    }

    func testAFRI005ScreenshotHookNamesFocusedUITestAndDurableProofBoundary() {
        XCTAssertEqual(
            ShellPreviewMatrix.screenshotHook.uiTestName,
            "AmbitionsUITests/testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs"
        )
        XCTAssertEqual(ShellPreviewMatrix.screenshotHook.attachmentPrefix, "afri-005-shell")
        XCTAssertEqual(ShellPreviewMatrix.screenshotHook.proofDirectory, "docs/proof/afri")
        XCTAssertTrue(ShellPreviewMatrix.screenshotHook.resultBundleExpectation.contains("xcresult"))
    }
}
