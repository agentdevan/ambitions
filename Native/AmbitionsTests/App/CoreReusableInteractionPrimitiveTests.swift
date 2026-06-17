import AmbitionsDesignSystem
import SwiftUI
import XCTest

@MainActor
final class CoreReusableInteractionPrimitiveTests: XCTestCase {
    func testAMB1061CatalogCoversLaunchPathRolesInOrder() {
        XCTAssertEqual(AmbitionCoreInteractionPrimitiveCatalog.ownerBatch, "AMB-1061")
        XCTAssertEqual(
            AmbitionCoreInteractionPrimitiveCatalog.requiredLaunchPathRoles.map(\.title),
            [
                "Start here",
                "Start now",
                "Open step",
                "Open goal thread",
                "Review time fit",
                "Inspect proof",
                "Recovery option",
                "Capture context",
                "Private by default",
                "Confirm change"
            ]
        )

        XCTAssertEqual(
            AmbitionCoreInteractionPrimitiveCatalog.canonicalTopLevelSurfaces,
            ["Today", "Goals", "Time", "You"]
        )
        XCTAssertFalse(AmbitionCoreInteractionPrimitiveCatalog.canonicalTopLevelSurfaces.contains("Capture"))
    }

    func testAMB1061ContractsMapToExistingPrimitiveFamilies() {
        let contracts = AmbitionCoreInteractionPrimitiveCatalog.contracts
        XCTAssertEqual(contracts.count, AmbitionCoreInteractionRole.allCases.count)

        XCTAssertEqual(AmbitionCoreInteractionRole.startHere.family, .primaryAction)
        XCTAssertEqual(AmbitionCoreInteractionRole.openStep.family, .disclosureRow)
        XCTAssertEqual(AmbitionCoreInteractionRole.recoveryOption.family, .recoveryAction)
        XCTAssertEqual(AmbitionCoreInteractionRole.captureContext.family, .globalCaptureAction)
        XCTAssertEqual(AmbitionCoreInteractionRole.trustPreference.family, .preferenceToggle)
        XCTAssertEqual(AmbitionCoreInteractionRole.confirmChange.family, .destructiveConfirmation)

        for contract in contracts {
            XCTAssertFalse(contract.existingPrimitiveBridge.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            XCTAssertFalse(contract.accessibilitySummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    func testAMB1061AccessibilityStatesAreExplicitAndAdaptive() {
        XCTAssertTrue(AmbitionCoreInteractionPrimitiveCatalog.validationFailures().isEmpty)

        for contract in AmbitionCoreInteractionPrimitiveCatalog.contracts {
            XCTAssertGreaterThanOrEqual(contract.minimumTapTarget, 44)
            XCTAssertTrue(contract.supportsDynamicType)
            XCTAssertTrue(contract.supportsReduceMotion)
            XCTAssertTrue(contract.supportsReduceTransparency)
            XCTAssertTrue(contract.supportsIncreaseContrast)
            XCTAssertEqual(contract.supportedStates, AmbitionCoreInteractionState.allCases)
        }

        for state in AmbitionCoreInteractionState.allCases {
            XCTAssertFalse(state.accessibilityValue.isEmpty)
            XCTAssertFalse(state.nonColorCue.isEmpty)
            XCTAssertFalse(state.semanticState.accessibilityText.isEmpty)
        }
    }

    func testAMB1061CaptureStaysGlobalAndNotRootNavigation() {
        let capture = AmbitionCoreInteractionPrimitiveCatalog.contract(for: .captureContext)

        XCTAssertEqual(capture.ownerSurface, "Global Capture")
        XCTAssertEqual(capture.primaryObject, "Atmosphere Composer")
        XCTAssertFalse(capture.isTopLevelSurface)
        XCTAssertFalse(AmbitionCoreInteractionPrimitiveCatalog.canonicalTopLevelSurfaces.contains("Global Capture"))
        XCTAssertFalse(AmbitionCoreInteractionPrimitiveCatalog.canonicalTopLevelSurfaces.contains("Capture"))
    }

    func testAMB1061ContractsAvoidGenericDriftAndUnsupportedClaims() {
        let combined = (
            AmbitionCoreInteractionPrimitiveCatalog.contracts.map(\.accessibilitySummary)
            + AmbitionCoreInteractionState.allCases.map { "\($0.title) \($0.accessibilityValue) \($0.nonColorCue)" }
            + AmbitionCoreInteractionPreviewMatrix.rows.map(\.accessibilitySummary)
        ).joined(separator: " ")

        for phrase in AmbitionCoreInteractionPrimitiveCatalog.forbiddenLanguage {
            XCTAssertFalse(
                combined.localizedCaseInsensitiveContains(phrase),
                "Unexpected forbidden phrase: \(phrase)"
            )
        }

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("top-level Capture"))
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("SourceRecord"))
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("Receipt"))
        XCTAssertTrue(combined.localizedCaseInsensitiveContains("ReplayTrace"))
    }

    func testAMB1061PreviewMatrixCoversEveryRoleAndState() {
        XCTAssertEqual(
            AmbitionCoreInteractionPreviewMatrix.rows.map(\.role),
            AmbitionCoreInteractionRole.allCases
        )

        for row in AmbitionCoreInteractionPreviewMatrix.rows {
            XCTAssertEqual(row.cells.map(\.state), AmbitionCoreInteractionState.allCases)
            XCTAssertTrue(row.accessibilitySummary.contains(row.role.title))
            XCTAssertTrue(row.accessibilitySummary.contains(row.role.ownerSurface))
        }

        XCTAssertEqual(
            AmbitionCoreInteractionPreviewMatrix.variants,
            [
                "Component inventory",
                "Dynamic Type",
                "Reduce Motion",
                "Reduce Transparency",
                "Increase Contrast",
                "Non-color state"
            ]
        )
        XCTAssertTrue(AmbitionCoreInteractionPreviewMatrix.validationFailures().isEmpty)
    }

    func testAMB1061SwiftUIWrappersCompileWithCanonicalCopy() {
        _ = AmbitionCoreInteractionActionButton(role: .startHere, state: .selected, action: {})
        _ = AmbitionCoreInteractionActionButton(role: .startNow, state: .ready, action: {})
        _ = AmbitionCoreInteractionActionButton(role: .openStep, state: .loading, action: {})
        _ = AmbitionCoreInteractionActionButton(role: .recoveryOption, state: .recovery, action: {})

        _ = AmbitionCoreInteractionDisclosureRow(
            role: .inspectProof,
            state: .sourceNeeded,
            subtitle: "SourceRecord, Receipt, and ReplayTrace are available.",
            action: {}
        )

        _ = AmbitionCoreInteractionStatusPill(role: .reviewTimeFit, state: .localOnly)
        _ = AmbitionCoreInteractionPreferenceRow(
            subtitle: "Hide sensitive details in compact views.",
            isOn: .constant(true)
        )
        _ = CoreReusableInteractionPrimitivePreviewGallery()

        XCTAssertEqual(AmbitionCoreInteractionRole.startNow.title, "Start now")
        XCTAssertEqual(AmbitionCoreInteractionRole.openStep.title, "Open step")
    }
}
