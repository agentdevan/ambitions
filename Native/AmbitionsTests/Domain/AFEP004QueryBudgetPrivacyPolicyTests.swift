import XCTest
@testable import Ambitions

final class AFEP004QueryBudgetPrivacyPolicyTests: XCTestCase {
    func testMajorSurfaceReadBudgetsRemainContractBoundedAndUnverified() {
        let budgets = RepositoryQueryBudget.majorSurfaceReadBudgets
        let projectionBudgets = RepositoryQueryBudget.projectionReadBudgets

        XCTAssertEqual(budgets.map(\.scope), [.today, .goals, .capture, .time, .you])
        XCTAssertEqual(projectionBudgets.map(\.scope), [.runtimeSnapshotLedger, .operationalProjection, .proofProjection, .portableExport])
        XCTAssertEqual(RepositoryQueryBudget.allBudgets.count, 9)
        XCTAssertTrue(budgets.allSatisfy { $0.maximumReads > 0 })
        XCTAssertTrue(projectionBudgets.allSatisfy { $0.maximumReads > 0 })
        XCTAssertTrue(RepositoryQueryBudget.allBudgets.allSatisfy { $0.isContractOnly })
        XCTAssertTrue(RepositoryQueryBudget.allBudgets.allSatisfy { $0.measurementEvidenceState == .planned })
    }

    func testRuntimeSnapshotEnvelopeDefaultsToNonIndexedRedactedPolicies() {
        let envelope = RuntimeSnapshotLedgerEnvelope(
            generatedAt: "2026-06-01T04:00:00Z",
            sourceRecordIDs: ["source-2", "source-1"],
            receiptIDs: ["receipt-1"],
            replayTraceIDs: ["trace-1"],
            recommendationInputReferenceIDs: ["recommendation-1"],
            proofInputReferenceIDs: ["proof-1"],
            afep02LineageReferenceIDs: ["afep02-lineage-1"]
        )

        XCTAssertEqual(RuntimeSnapshotLedgerEnvelope.afepReadBudget.scope, .runtimeSnapshotLedger)
        XCTAssertEqual(RuntimeSnapshotLedgerEnvelope.afepReadBudget.maximumReads, 4)
        XCTAssertEqual(RuntimeSnapshotLedgerEnvelope.afepReadBudget.measurementEvidenceState, .planned)

        let sourcePolicy = RuntimeSnapshotLedgerEnvelope.afepFieldPolicies["sourceRecordIDs"]
        let receiptPolicy = RuntimeSnapshotLedgerEnvelope.afepFieldPolicies["receiptIDs"]
        let replayPolicy = RuntimeSnapshotLedgerEnvelope.afepFieldPolicies["replayTraceIDs"]
        let lineagePolicy = RuntimeSnapshotLedgerEnvelope.afepFieldPolicies["afep02LineageReferenceIDs"]

        XCTAssertEqual(sourcePolicy?.privacyClass, .localOnly)
        XCTAssertEqual(sourcePolicy?.indexingPolicy, .notIndexed)
        XCTAssertEqual(sourcePolicy?.exportPolicy, .redacted)
        XCTAssertEqual(receiptPolicy?.privacyClass, .proofRestricted)
        XCTAssertEqual(receiptPolicy?.indexingPolicy, .notIndexed)
        XCTAssertEqual(receiptPolicy?.exportPolicy, .redacted)
        XCTAssertEqual(replayPolicy?.privacyClass, .replayRestricted)
        XCTAssertEqual(replayPolicy?.indexingPolicy, .notIndexed)
        XCTAssertEqual(replayPolicy?.exportPolicy, .redacted)
        XCTAssertEqual(lineagePolicy?.privacyClass, .lineageRestricted)
        XCTAssertEqual(lineagePolicy?.indexingPolicy, .notIndexed)
        XCTAssertEqual(lineagePolicy?.exportPolicy, .redacted)

        let projection = envelope.exportSafeProjection
        XCTAssertTrue(projection.isExportSafe)
        XCTAssertEqual(projection.fields.count, 6)

        let receiptField = projection.fields.first(where: { $0.fieldName == "receiptIDs" })
        XCTAssertEqual(receiptField?.storagePrivacyClass, .proofRestricted)
        XCTAssertEqual(receiptField?.indexingPolicy, .notIndexed)
        XCTAssertEqual(receiptField?.exportPolicy, .redacted)
        XCTAssertEqual(receiptField?.measurementEvidenceState, .planned)
        XCTAssertEqual(receiptField?.redactionClass, .localOnly)
        XCTAssertEqual(receiptField?.redactedValue, "[redacted]")
    }

    func testRuntimeSnapshotExportPolicyOverridesUnsafeClearRedaction() {
        let envelope = RuntimeSnapshotLedgerEnvelope(
            generatedAt: "2026-06-01T04:00:00Z",
            receiptIDs: ["receipt-private"],
            fieldRedactions: [
                RuntimeSnapshotLedgerFieldRedaction(fieldName: "receiptIDs", redactionClass: .clear)
            ]
        )

        let projection = envelope.exportSafeProjection
        let receiptField = projection.fields.first(where: { $0.fieldName == "receiptIDs" })

        XCTAssertTrue(projection.isExportSafe)
        XCTAssertEqual(receiptField?.exportPolicy, .redacted)
        XCTAssertEqual(receiptField?.redactionClass, .redacted)
        XCTAssertTrue(receiptField?.visibleValues.isEmpty == true)
        XCTAssertEqual(receiptField?.redactedValue, "[redacted]")
    }

    func testSplitRecordPoliciesKeepSensitiveFieldsNonIndexed() {
        let operationalPolicy = AmbitionGraphOperationalRecord.afepFieldPolicies["sourceFields"]
        let proofPolicy = AmbitionGraphProofRecord.afepFieldPolicies["checksum"]
        let projectionPolicy = AmbitionGraphProjectionRecord.afepFieldPolicies["projectionHash"]

        XCTAssertEqual(operationalPolicy?.privacyClass, .privateSensitive)
        XCTAssertEqual(operationalPolicy?.indexingPolicy, .notIndexed)
        XCTAssertEqual(operationalPolicy?.exportPolicy, .redacted)
        XCTAssertEqual(proofPolicy?.privacyClass, .systemOwned)
        XCTAssertEqual(proofPolicy?.indexingPolicy, .notIndexed)
        XCTAssertEqual(proofPolicy?.exportPolicy, .safe)
        XCTAssertEqual(projectionPolicy?.privacyClass, .systemOwned)
        XCTAssertEqual(projectionPolicy?.indexingPolicy, .notIndexed)
        XCTAssertEqual(projectionPolicy?.exportPolicy, .safe)
    }
}
