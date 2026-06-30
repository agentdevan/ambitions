import XCTest
@testable import Ambitions

final class StoragePrivacySecurityBoundaryTests: XCTestCase {
    private let validator = StoragePrivacySecurityBoundaryValidator()

    func testProtectedModeAllowsReviewedRedactedLocalFirstStorageBoundaries() throws {
        let record = privateRecord(
            destinations: [.localStore, .portableExport, .supportBundle, .receiptReplayInspection, .whatAmbitionsKnows],
            redactionSummary: "Show role, proof state, and review path without raw private text.",
            userReviewed: true
        )

        let report = validator.validate(records: [record], protectedMode: .enforcedReview)

        XCTAssertTrue(report.isGreen)
        XCTAssertEqual(report.checkedRecordCount, 1)
        XCTAssertTrue(report.canPreparePortableExport)
        XCTAssertTrue(report.canPrepareSupportBundle)
        XCTAssertFalse(report.canPublishPublicSourcePack)

        let supportProjection = try XCTUnwrap(report.projections.first { $0.destination == .supportBundle })
        XCTAssertEqual(supportProjection.visibleTitle, "Private life item")
        XCTAssertTrue(supportProjection.redactionApplied)
        XCTAssertEqual(supportProjection.sourceRecordID, nil)
        XCTAssertEqual(supportProjection.receiptID, nil)
        XCTAssertEqual(supportProjection.replayTraceID, nil)
        XCTAssertTrue(supportProjection.isBoundaryPreserving)

        let inspectionProjection = try XCTUnwrap(report.projections.first { $0.destination == .whatAmbitionsKnows })
        XCTAssertEqual(inspectionProjection.visibleTitle, "Private ambition context")
        XCTAssertFalse(inspectionProjection.redactionApplied)
        XCTAssertEqual(inspectionProjection.sourceRecordID, "SourceRecord.storage.private")
        XCTAssertEqual(inspectionProjection.receiptID, "Receipt.storage.private")
        XCTAssertEqual(inspectionProjection.replayTraceID, "ReplayTrace.storage.private")
    }

    func testValidatorBlocksUnsafePrivateExportIndexAndPublicSourcePackPaths() {
        let record = StoragePrivacyBoundaryRecord(
            id: "unsafe-private",
            title: "Unsafe private context",
            privacyClass: .privateSensitive,
            indexingPolicy: .indexed,
            exportPolicy: .safe,
            destinations: [.portableExport, .supportBundle, .localIndex, .r2PublicSourcePack, .sourceAtlasCache],
            redactionSummary: "",
            sourceRecordID: nil,
            receiptID: nil,
            replayTraceID: nil,
            whatAmbitionsKnowsInspectionPath: nil,
            userReviewed: false
        )

        let report = validator.validate(records: [record], protectedMode: .notEnforced)
        let issues = Set(report.findings.map(\.issue))

        XCTAssertFalse(report.isGreen)
        XCTAssertFalse(report.canPreparePortableExport)
        XCTAssertFalse(report.canPrepareSupportBundle)
        XCTAssertFalse(report.canBuildLocalIndex)
        XCTAssertFalse(report.canPublishPublicSourcePack)
        XCTAssertTrue(issues.contains(.privateCategoryMarkedExportSafe))
        XCTAssertTrue(issues.contains(.privateCategoryIndexed))
        XCTAssertTrue(issues.contains(.privateCategoryPublicEligible))
        XCTAssertTrue(issues.contains(.privateCategorySupportVisibleWithoutRedaction))
        XCTAssertTrue(issues.contains(.protectedModeNotEnforced))
        XCTAssertTrue(issues.contains(.userReviewMissing))
        XCTAssertTrue(issues.contains(.redactionSummaryMissing))
        XCTAssertTrue(issues.contains(.sourceRecordBoundaryMissing))
        XCTAssertTrue(issues.contains(.receiptBoundaryMissing))
        XCTAssertTrue(issues.contains(.replayTraceBoundaryMissing))
        XCTAssertTrue(issues.contains(.whatAmbitionsKnowsInspectionMissing))
    }

    func testPublicReferenceMetadataCanEnterPublicSourcePackWithoutRedaction() throws {
        let record = StoragePrivacyBoundaryRecord(
            id: "public-source-rule",
            title: "Public source rule",
            privacyClass: .publicMetadata,
            indexingPolicy: .indexed,
            exportPolicy: .safe,
            destinations: [.r2PublicSourcePack, .sourceAtlasCache],
            sourceRecordID: "SourceRecord.public.rule",
            receiptID: "Receipt.public.rule",
            replayTraceID: "ReplayTrace.public.rule",
            whatAmbitionsKnowsInspectionPath: "You / Search Ambitions / Public sources",
            userReviewed: true
        )

        let report = validator.validate(records: [record], protectedMode: .enforcedReview)

        XCTAssertTrue(report.isGreen)
        XCTAssertTrue(report.canPublishPublicSourcePack)
        let publicProjection = try XCTUnwrap(report.projections.first { $0.destination == .r2PublicSourcePack })
        XCTAssertEqual(publicProjection.visibleTitle, "Public source rule")
        XCTAssertFalse(publicProjection.redactionApplied)
        XCTAssertEqual(publicProjection.sourceRecordID, "SourceRecord.public.rule")
    }

    func testPortableManifestPoliciesComposeIntoProtectedStorageBoundary() throws {
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

        let records = StoragePrivacyBoundaryCatalog.records(from: manifest, userReviewed: true)
        let report = validator.validate(records: records, protectedMode: .enforcedReview)

        XCTAssertEqual(records.count, PortableExportCategory.allCases.count)
        XCTAssertTrue(report.isGreen)
        XCTAssertTrue(report.canPreparePortableExport)
        XCTAssertTrue(report.canPrepareSupportBundle)
        XCTAssertFalse(report.canPublishPublicSourcePack)

        let goalsRecord = try XCTUnwrap(records.first { $0.id == "portable_export.goals_and_plans" })
        XCTAssertEqual(goalsRecord.privacyClass, .privateSensitive)
        XCTAssertEqual(goalsRecord.indexingPolicy, .notIndexed)
        XCTAssertEqual(goalsRecord.exportPolicy, .exportReviewOnly)
        XCTAssertTrue(goalsRecord.hasWhatAmbitionsKnowsInspection)

        let receiptProjection = try XCTUnwrap(report.projections.first {
            $0.recordID == "portable_export.receipts" && $0.destination == .receiptReplayInspection
        })
        XCTAssertTrue(receiptProjection.redactionApplied)
        XCTAssertTrue(receiptProjection.isBoundaryPreserving)
    }
}

private extension StoragePrivacySecurityBoundaryTests {
    func privateRecord(
        destinations: [StoragePrivacyBoundaryDestination],
        redactionSummary: String,
        userReviewed: Bool
    ) -> StoragePrivacyBoundaryRecord {
        StoragePrivacyBoundaryRecord(
            id: "private-storage",
            title: "Private ambition context",
            privacyClass: .privateSensitive,
            indexingPolicy: .notIndexed,
            exportPolicy: .exportReviewOnly,
            destinations: destinations,
            redactionSummary: redactionSummary,
            sourceRecordID: "SourceRecord.storage.private",
            receiptID: "Receipt.storage.private",
            replayTraceID: "ReplayTrace.storage.private",
            whatAmbitionsKnowsInspectionPath: "You / Search Ambitions / Private storage",
            userReviewed: userReviewed
        )
    }
}
