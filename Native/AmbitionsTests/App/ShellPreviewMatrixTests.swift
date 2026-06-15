import XCTest
@testable import Ambitions

final class ShellPreviewMatrixTests: XCTestCase {
    func testAFRI005PreviewMatrixCoversCanonicalTabsAndRequiredVisualVariants() {
        XCTAssertEqual(ShellPreviewMatrix.canonicalTabs, AppTab.allCases)
        XCTAssertEqual(ShellPreviewMatrix.rows.count, AppTab.allCases.count * ShellPreviewMatrix.variants.count)
        XCTAssertTrue(ShellPreviewMatrix.variants.contains { $0.colorAppearance == .dark })
        XCTAssertTrue(ShellPreviewMatrix.variants.contains { $0.colorAppearance == .oled })
        XCTAssertTrue(ShellPreviewMatrix.variants.contains { $0.dynamicTypeCategory.contains("Accessibility") })
        XCTAssertTrue(ShellPreviewMatrix.variants.contains { $0.reduceMotion })
        XCTAssertTrue(ShellPreviewMatrix.validationFailures().isEmpty)
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("capture"))
    }

    func testAFRI005PreviewMatrixCoversMajorShellStates() {
        let coveredStates = Set(ShellPreviewMatrix.variants.map(\.shellState))

        XCTAssertEqual(coveredStates, Set(ShellPreviewState.allCases))
        XCTAssertTrue(ShellPreviewMatrix.rows.contains { $0.tab == .today && $0.variant.shellState == .steady })
        XCTAssertTrue(ShellPreviewMatrix.rows.contains { $0.tab == .motion && $0.variant.shellState == .globalEntryOpen })
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

    func testAFEP021AccessibilityCertificationProgramCoversCanonicalSurfacesAndPrimaryObjects() {
        let program = ShellPreviewMatrix.accessibilityCertificationProgram

        XCTAssertEqual(program.surfaceFixtures.map(\.tab), AppTab.allCases)
        XCTAssertEqual(program.surfaceFixtures.map(\.surfaceTitle), AppTab.allCases.map(\.title))
        XCTAssertEqual(program.surfaceFixtures.map(\.primaryObjectTitle), AppTab.allCases.map(\.primaryObjectTitle))
        XCTAssertEqual(program.rows.count, program.surfaceFixtures.count * program.gateMatrix.count)
        XCTAssertTrue(program.validationFailures().isEmpty)
    }

    func testAFEP021AccessibilityCertificationProgramRepresentsRequiredGatesAndBlockedProofKinds() {
        let program = ShellPreviewMatrix.accessibilityCertificationProgram

        XCTAssertEqual(Set(program.gateMatrix.map(\.kind)), Set(AFEP021AccessibilityGateKind.allCases))
        XCTAssertTrue(program.gateMatrix.allSatisfy { $0.publicClaimBlocked })
        XCTAssertEqual(Set(program.proofBoundary.blockedProofKinds), Set([
            .renderedScreenshot,
            .manualVoiceOver,
            .dynamicTypeScreenshotReview,
            .reduceMotionWalkthrough,
            .increaseContrastMeasuredReview,
            .tapTargetMotorReview,
            .physicalDeviceProof,
            .publicAccessibilityClaimApproval
        ]))
        XCTAssertFalse(program.proofBoundary.blockedProofKinds.contains(.sourceBackedSupport))
        XCTAssertFalse(program.proofBoundary.blockedProofKinds.contains(.automatedTest))
        XCTAssertTrue(program.proofBoundary.sourceBackedSupportClaimAllowed)
        XCTAssertTrue(program.proofBoundary.automatedTestClaimAllowed)
        XCTAssertFalse(program.proofBoundary.renderedScreenshotClaimAllowed)
        XCTAssertFalse(program.proofBoundary.manualVoiceOverClaimAllowed)
        XCTAssertFalse(program.proofBoundary.dynamicTypeScreenshotClaimAllowed)
        XCTAssertFalse(program.proofBoundary.reduceMotionWalkthroughClaimAllowed)
        XCTAssertFalse(program.proofBoundary.increaseContrastMeasuredReviewClaimAllowed)
        XCTAssertFalse(program.proofBoundary.tapTargetMotorReviewClaimAllowed)
        XCTAssertFalse(program.proofBoundary.physicalDeviceProofClaimAllowed)
        XCTAssertFalse(program.proofBoundary.publicAccessibilityCertificationClaimAllowed)
    }

    func testAFEP021AccessibilityCertificationProgramEvidencePacketsRecordCommandsArtifactsStatesAndFollowUps() {
        let program = ShellPreviewMatrix.accessibilityCertificationProgram

        XCTAssertEqual(Set(program.evidencePackets.map(\.surface)), Set(AppTab.allCases.map(\.title)))
        XCTAssertEqual(Set(program.evidencePackets.map(\.fixtureState)), Set(program.surfaceFixtures.map(\.fixtureState)))
        XCTAssertTrue(program.evidencePackets.contains { $0.result == .pass })
        XCTAssertTrue(program.evidencePackets.contains { $0.result == .skipped })
        XCTAssertTrue(program.evidencePackets.allSatisfy { !$0.command.isEmpty })
        XCTAssertTrue(program.evidencePackets.allSatisfy { !$0.artifactPath.isEmpty && $0.artifactPath.contains("docs/") })
        XCTAssertTrue(program.evidencePackets.allSatisfy { !$0.knownLimitation.isEmpty && !$0.owner.isEmpty && !$0.followUpProofRequirement.isEmpty })
        XCTAssertTrue(program.evidencePackets.contains { $0.proofKind == .manualVoiceOver })
        XCTAssertTrue(program.evidencePackets.contains { $0.proofKind == .renderedScreenshot })
        XCTAssertTrue(program.evidencePackets.contains { $0.proofKind == .publicAccessibilityClaimApproval })
    }

    func testAFEP021AccessibilityCertificationProgramKeepsProvenanceAndClaimFlagsLocalOnly() {
        let program = ShellPreviewMatrix.accessibilityCertificationProgram

        XCTAssertTrue(program.provenanceReferences.sourceRecordID.contains("SourceRecord"))
        XCTAssertTrue(program.provenanceReferences.receiptID.contains("Receipt"))
        XCTAssertTrue(program.provenanceReferences.replayTraceID.contains("ReplayTrace"))
        XCTAssertEqual(program.provenanceReferences.youInspectionLabel, "You / What Ambitions knows")
        XCTAssertEqual(program.provenanceReferences.inspectionSurfaceTitle, "What Ambitions knows")
        XCTAssertTrue(program.provenanceReferences.inspectionSummary.localizedCaseInsensitiveContains("public certification"))
        XCTAssertFalse(program.claimFlags.sourceBackedSupportClaimed)
        XCTAssertFalse(program.claimFlags.automatedTestClaimed)
        XCTAssertFalse(program.claimFlags.renderedScreenshotClaimed)
        XCTAssertFalse(program.claimFlags.manualVoiceOverClaimed)
        XCTAssertFalse(program.claimFlags.dynamicTypeScreenshotClaimed)
        XCTAssertFalse(program.claimFlags.reduceMotionWalkthroughClaimed)
        XCTAssertFalse(program.claimFlags.increaseContrastClaimed)
        XCTAssertFalse(program.claimFlags.tapTargetMotorClaimed)
        XCTAssertFalse(program.claimFlags.physicalDeviceClaimed)
        XCTAssertFalse(program.claimFlags.publicAccessibilityCertificationClaimed)
        XCTAssertFalse(program.claimFlags.releaseClaimed)
        XCTAssertTrue(program.proofBoundary.rollbackNote.contains("AFRI-034"))
        XCTAssertTrue(program.proofBoundary.rollbackNote.contains("AFRI-005"))
        XCTAssertEqual(program.proofBoundary.afri034RollbackBaselinePath, "docs/proof/afri/afri-034-accessibility-proof-matrix.md")
        XCTAssertEqual(program.proofBoundary.afri005ShellScreenshotProofPath, "docs/proof/afri/afri-005-shell-preview-screenshot-proof.md")
    }
}
