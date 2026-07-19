import XCTest
@testable import Ambitions

final class ExportImportResetDataScopeMatrixTests: XCTestCase {
    func testDataScopeMatrixCoversEveryPortableCategoryAndCurrentManifestExclusion() throws {
        let categoryRows = ExportImportResetDataScopeMatrix.portableCategoryRows

        XCTAssertEqual(categoryRows.compactMap(\.category), PortableExportCategory.allCases)
        XCTAssertEqual(categoryRows.count, PortableExportCategory.allCases.count)
        XCTAssertTrue(categoryRows.allSatisfy { $0.kind == .portableCategory })

        let manifest = PortableExportManifest.make(
            selection: .all,
            goals: [],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [],
            teachingSignals: [],
            appState: .default
        )
        let manifestExclusionIDs = Set(manifest.exclusions.map(\.id))
        let matrixExclusionIDs = Set(ExportImportResetDataScopeMatrix.excludedScopeRows.map(\.id))
        let requiredExclusionIDs: Set<String> = [
            "excluded.raw-calendar-events",
            "excluded.cloud-sync-account",
            "excluded.external-rendered-state"
        ]

        XCTAssertEqual(matrixExclusionIDs, requiredExclusionIDs)
        XCTAssertTrue(requiredExclusionIDs.isSubset(of: manifestExclusionIDs))
        XCTAssertTrue(ExportImportResetDataScopeMatrix.excludedScopeRows.allSatisfy { row in
            row.kind == .excludedExternalScope
                && row.category == nil
                && row.includedInPortablePackage == false
                && row.replaceModeSemantics == .excludedFromPortableImport
                && row.mergeModeSemantics == .excludedFromPortableImport
        })
    }

    func testPortableRowsMirrorCategoryPrivacyExportAndPreviewPolicy() throws {
        for category in PortableExportCategory.allCases {
            let row = try XCTUnwrap(ExportImportResetDataScopeMatrix.row(for: category))

            XCTAssertEqual(row.id, category.rawValue)
            XCTAssertEqual(row.title, category.title)
            XCTAssertEqual(row.privacyClass, Optional(category.privacyClass))
            XCTAssertEqual(row.indexingPolicy, Optional(category.indexingPolicy))
            XCTAssertEqual(row.exportPolicy, Optional(category.exportPolicy))
            XCTAssertEqual(row.measurementEvidenceState, Optional(category.measurementEvidenceState))
            XCTAssertEqual(row.containsSensitiveUserText, category.containsSensitiveUserText)
            XCTAssertEqual(row.userReviewRequired, category.exportPolicy == .exportReviewOnly)
            XCTAssertEqual(row.previewRule, category.previewRule)
            XCTAssertEqual(row.detail, category.detail)
            XCTAssertFalse(row.storedDataKinds.isEmpty)
        }
    }

    func testSensitiveRowsRemainReviewOnlyAndSettingsRemainSafe() throws {
        let sensitiveCategories: [PortableExportCategory] = [
            .goalsAndPlans,
            .captures,
            .proof,
            .receipts,
            .memory
        ]

        for category in sensitiveCategories {
            let row = try XCTUnwrap(ExportImportResetDataScopeMatrix.row(for: category))

            XCTAssertTrue(row.containsSensitiveUserText)
            XCTAssertTrue(row.userReviewRequired)
            XCTAssertEqual(row.exportPolicy, .exportReviewOnly)
            XCTAssertEqual(row.indexingPolicy, .notIndexed)
            XCTAssertFalse(row.destructiveResetAllowed)
            XCTAssertFalse(row.durableDryRunMutationAllowed)
        }

        let settings = try XCTUnwrap(ExportImportResetDataScopeMatrix.row(for: .settings))
        XCTAssertFalse(settings.containsSensitiveUserText)
        XCTAssertFalse(settings.userReviewRequired)
        XCTAssertEqual(settings.exportPolicy, .safe)
        XCTAssertEqual(settings.indexingPolicy, .indexed)
        XCTAssertFalse(settings.destructiveResetAllowed)
        XCTAssertFalse(settings.durableDryRunMutationAllowed)
    }

    func testImportResetSemanticsKeepReplaceGatedAndMergeNonResetting() {
        let replace = ExportImportResetDataScopeMatrix.modeSemantics(for: .replaceLocalStore)
        let merge = ExportImportResetDataScopeMatrix.modeSemantics(for: .mergeWithConflictReport)

        XCTAssertEqual(replace.mode, .replaceLocalStore)
        XCTAssertTrue(replace.wouldResetLocalStore)
        XCTAssertTrue(replace.requiresExplicitConfirmation)
        XCTAssertFalse(replace.conflictReportRequired)
        XCTAssertFalse(replace.durableDryRunMutationAllowed)
        XCTAssertFalse(replace.destructiveResetAllowed)

        XCTAssertEqual(merge.mode, .mergeWithConflictReport)
        XCTAssertFalse(merge.wouldResetLocalStore)
        XCTAssertFalse(merge.requiresExplicitConfirmation)
        XCTAssertTrue(merge.conflictReportRequired)
        XCTAssertFalse(merge.durableDryRunMutationAllowed)
        XCTAssertFalse(merge.destructiveResetAllowed)

        XCTAssertTrue(ExportImportResetDataScopeMatrix.portableCategoryRows.allSatisfy { row in
            row.replaceModeMayResetLocalStore
                && row.mergeModeMayResetLocalStore == false
                && row.requiresExplicitConfirmationBeforeReset
        })
    }

    func testMatrixKeepsUnsupportedRestoreAndReleaseClaimsOutOfScope() {
        XCTAssertTrue(ExportImportResetDataScopeMatrix.rows.allSatisfy { row in
            row.proofCeiling == .sourceInvariantOnly
                && row.destructiveResetAllowed == false
                && row.durableDryRunMutationAllowed == false
                && row.nonClaimBoundary.contains("not destructive migration")
                && row.nonClaimBoundary.contains("release proof")
        })
    }
}
