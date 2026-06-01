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

    func testAFEP020VisualDiffLabCoversAllCanonicalSurfaces() {
        let lab = ShellPreviewMatrix.visualDiffLab

        XCTAssertEqual(lab.surfaceFixtures.map(\.tab), AppTab.allCases)
        XCTAssertEqual(lab.rows.count, lab.surfaceFixtures.count * lab.variantDimensions.count)
        XCTAssertEqual(Set(lab.surfaceFixtures.map(\.fixtureKey)).count, lab.surfaceFixtures.count)
        XCTAssertEqual(Set(lab.rows.map(\.id)).count, lab.rows.count)
        XCTAssertTrue(ShellPreviewMatrix.validationFailures().isEmpty)
    }

    func testAFEP020VisualDiffLabIncludesRequiredAccessibilityAndStateVariants() {
        let lab = ShellPreviewMatrix.visualDiffLab
        let scenarios = Set(lab.variantDimensions.map(\.scenario))

        XCTAssertEqual(
            scenarios,
            Set([
                AFEP020VisualDiffScenario.baseline,
                .loading,
                .empty,
                .privateSourceReview,
                .blockedRecovery,
                .overloaded,
                .reduceMotion,
                .increaseContrast,
                .dynamicType
            ])
        )
        XCTAssertTrue(lab.variantDimensions.contains { $0.reduceMotion })
        XCTAssertTrue(lab.variantDimensions.contains { $0.increaseContrast })
        XCTAssertTrue(lab.variantDimensions.contains { $0.dynamicTypeCategory.contains("Accessibility") })
    }

    func testAFEP020VisualDiffLabArtifactNamesStayDeterministicAndPathSafe() {
        let lab = ShellPreviewMatrix.visualDiffLab
        let firstPass = lab.rows.map(\.artifactPath)
        let secondPass = lab.rows.map(\.artifactPath)

        XCTAssertEqual(firstPass, secondPass)
        XCTAssertTrue(firstPass.allSatisfy { $0.contains("/") })
        XCTAssertTrue(firstPass.allSatisfy { $0.contains("//") == false && $0.contains("..") == false })
        XCTAssertTrue(firstPass.allSatisfy { $0 == $0.lowercased() })
    }

    func testAFEP020VisualDiffLabDoesNotClaimRenderedProofOrReleaseReadiness() {
        let lab = ShellPreviewMatrix.visualDiffLab

        XCTAssertFalse(lab.proofBoundary.renderedScreenshotProofClaim)
        XCTAssertFalse(lab.proofBoundary.accessibilityCertificationClaim)
        XCTAssertFalse(lab.proofBoundary.releaseReadinessClaim)
        XCTAssertFalse(lab.proofBoundary.deviceProofClaim)
        XCTAssertFalse(lab.proofBoundary.ciProofClaim)
        XCTAssertFalse(lab.claimFlags.renderedScreenshotProofClaimed)
        XCTAssertFalse(lab.claimFlags.accessibilityClaimed)
        XCTAssertFalse(lab.claimFlags.releaseClaimed)
        XCTAssertFalse(lab.claimFlags.deviceClaimed)
        XCTAssertFalse(lab.claimFlags.ciClaimed)
        XCTAssertFalse(lab.claimFlags.productionReadyClaimed)
        XCTAssertEqual(lab.proofBoundary.fallbackProofPath, ShellPreviewMatrix.visualDiffArtifactFallbackProofPath)
        XCTAssertTrue(lab.proofBoundary.rollbackNote.contains("AFRI-005"))
    }

    func testAFEP020VisualDiffLabCarriesSourceRecordReceiptReplayTraceAndYouInspectionProvenance() {
        let provenance = ShellPreviewMatrix.visualDiffLab.provenanceReferences

        XCTAssertTrue(provenance.sourceRecordID.contains("SourceRecord"))
        XCTAssertTrue(provenance.receiptID.contains("Receipt"))
        XCTAssertTrue(provenance.replayTraceID.contains("ReplayTrace"))
        XCTAssertEqual(provenance.youInspectionLabel, "You / What Ambitions knows")
        XCTAssertEqual(provenance.inspectionSurfaceTitle, "What Ambitions knows")
        XCTAssertTrue(provenance.inspectionSummary.contains("rendered proof"))
    }
}
