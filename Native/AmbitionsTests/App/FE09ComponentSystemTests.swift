import XCTest
import AmbitionsDesignSystem

final class FE09ComponentSystemTests: XCTestCase {
    func testFE09ContractUsesAmbitionsSpecificRolesAndStates() {
        XCTAssertEqual(
            FE09ComponentSystemContract.roles.map(\.title),
            [
                "Trust Seam",
                "Receipt",
                "Source Freshness",
                "Primary CTA",
                "Disclosure Row",
                "Proof",
                "Recovery",
                "Reality Meridian",
                "Life Calendar",
                "Atmosphere Composer",
                "Life Area Atlas",
                "User System Profile"
            ]
        )

        XCTAssertEqual(
            FE09ComponentSystemContract.states.map(\.title),
            [
                "Normal",
                "Stale / context needed",
                "Local only / privacy",
                "Recovery",
                "Blocked / waiting",
                "Dynamic Type",
                "Reduce Motion",
                "Non-color state"
            ]
        )

        XCTAssertTrue(FE09ComponentSystemContract.validationFailures().isEmpty)
    }

    func testFE09ContractAvoidsGenericDriftAndUnsupportedClaims() {
        let combined = (FE09ComponentSystemContract.roles.map(\.accessibilitySummary) + FE09ComponentSystemContract.states.map(\.accessibilitySummary))
            .joined(separator: " ")

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("ui kit"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("component library"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("task list"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("chatbot"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("ai model"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("model"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("plan tab"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("profile tab"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("production " + "ready"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("release " + "ready"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("accessibility verified"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("fully accessible"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("color-only"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("color only"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("AI confidence"))
    }

    func testFE09RolesMapToOwnedSurfacesAndPrimaryObjects() {
        XCTAssertEqual(FE09ComponentSystemRole.trustSeam.ownerSurface, "You")
        XCTAssertEqual(FE09ComponentSystemRole.receipt.ownerSurface, "Today")
        XCTAssertEqual(FE09ComponentSystemRole.sourceFreshness.ownerSurface, "You")
        XCTAssertEqual(FE09ComponentSystemRole.primaryCTA.ownerSurface, "Today")
        XCTAssertEqual(FE09ComponentSystemRole.proof.ownerSurface, "Goals")
        XCTAssertEqual(FE09ComponentSystemRole.lifeShapeField.ownerSurface, "Time")
        XCTAssertEqual(FE09ComponentSystemRole.atmosphereComposer.ownerSurface, "Capture")
        XCTAssertEqual(FE09ComponentSystemRole.userSystemProfile.ownerSurface, "You")

        XCTAssertTrue(FE09ComponentSystemRole.userSystemProfile.accessibilitySummary.localizedCaseInsensitiveContains("User System Profile"))
        XCTAssertTrue(FE09ComponentSystemRole.trustSeam.accessibilitySummary.localizedCaseInsensitiveContains("Trust Seam"))
        XCTAssertTrue(FE09ComponentSystemRole.primaryCTA.accessibilitySummary.localizedCaseInsensitiveContains("Start Here"))
    }

    func testFE09PreviewMatrixCoversEveryRoleAndEveryStateInOrder() {
        XCTAssertEqual(FE09ComponentSystemPreviewMatrix.rows.count, FE09ComponentSystemContract.roles.count)

        for row in FE09ComponentSystemPreviewMatrix.rows {
            XCTAssertEqual(row.cells.count, FE09ComponentSystemContract.states.count)
            XCTAssertEqual(row.cells.map(\.state), FE09ComponentSystemContract.states)
            XCTAssertTrue(row.accessibilitySummary.localizedCaseInsensitiveContains(row.role.title))
        }

        XCTAssertTrue(FE09ComponentSystemPreviewMatrix.validationFailures().isEmpty)
    }

    func testFE09PreviewVariantsCoverAccessibilityProofModes() {
        XCTAssertEqual(
            FE09ComponentSystemPreviewMatrix.variants.map(\.title),
            [
                "Component System Matrix",
                "Dynamic Type",
                "Reduce Motion",
                "Non-Color State",
                "Increased Contrast"
            ]
        )

        for variant in FE09ComponentSystemPreviewMatrix.variants {
            XCTAssertFalse(variant.subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            XCTAssertFalse(variant.accessibilitySummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }

        XCTAssertTrue(FE09ComponentSystemPreviewMatrix.validationFailures().isEmpty)
    }

    func testFE09PreviewMatrixMakesAccessibilityAndNonColorMeaningExplicit() {
        let searchable = FE09ComponentSystemPreviewMatrix.rows
            .map(\.accessibilitySummary)
            .joined(separator: " ")

        XCTAssertTrue(searchable.localizedCaseInsensitiveContains("Dynamic Type"))
        XCTAssertTrue(searchable.localizedCaseInsensitiveContains("Reduce Motion"))
        XCTAssertTrue(searchable.localizedCaseInsensitiveContains("local only"))
        XCTAssertTrue(searchable.localizedCaseInsensitiveContains("source should be checked"))
        XCTAssertTrue(searchable.localizedCaseInsensitiveContains("non-color"))
        XCTAssertTrue(searchable.localizedCaseInsensitiveContains("symbol"))
        XCTAssertFalse(searchable.localizedCaseInsensitiveContains("AI model"))
        XCTAssertFalse(searchable.localizedCaseInsensitiveContains("plan tab"))
        XCTAssertFalse(searchable.localizedCaseInsensitiveContains("color-only"))
    }
}
