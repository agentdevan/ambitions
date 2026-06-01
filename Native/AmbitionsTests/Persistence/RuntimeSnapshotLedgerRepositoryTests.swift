import XCTest
@testable import Ambitions

final class RuntimeSnapshotLedgerRepositoryTests: XCTestCase {
    func testSwiftDataRepositoryStoresAndResolvesEnvelopeReferences() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repository = SwiftDataRuntimeSnapshotLedgerRepository(store: store)
        let envelope = RuntimeSnapshotLedgerEnvelope(
            generatedAt: "2026-06-01T04:00:00Z",
            sourceRecordIDs: ["source-1", "source-2"],
            receiptIDs: ["receipt-1"],
            replayTraceIDs: ["trace-1"],
            recommendationInputReferenceIDs: ["recommendation-1"],
            proofInputReferenceIDs: ["proof-1"],
            afep02LineageReferenceIDs: ["afep02-lineage-1"]
        )

        try await repository.append(envelope)

        let fetchedEnvelope = try await repository.fetchEnvelope(id: envelope.id)
        XCTAssertEqual(fetchedEnvelope, envelope)

        let receiptReference = RuntimeSnapshotLedgerArtifactReference(
            kind: .receipt,
            artifactID: "receipt-1",
            envelopeID: envelope.id,
            envelopeChecksum: envelope.checksum
        )
        let referencedEnvelopes = try await repository.fetchEnvelopes(containing: receiptReference)
        XCTAssertEqual(referencedEnvelopes, [envelope])

        let receiptReport = try await repository.validate(reference: receiptReference)
        let proofReport = try await repository.validateProof(referenceID: "proof-1", envelopeID: envelope.id, checksum: envelope.checksum)
        let replayTraceReport = try await repository.validateReplayTrace(referenceID: "trace-1", envelopeID: envelope.id, checksum: envelope.checksum)

        XCTAssertEqual(receiptReport.outcome, .valid)
        XCTAssertEqual(proofReport.outcome, .valid)
        XCTAssertEqual(replayTraceReport.outcome, .valid)
        XCTAssertTrue(receiptReport.isValid)
        XCTAssertTrue(proofReport.isValid)
        XCTAssertTrue(replayTraceReport.isValid)
    }

    func testRepositoryReportsMissingUnsupportedAndChecksumMismatch() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repository = SwiftDataRuntimeSnapshotLedgerRepository(store: store)

        let currentEnvelope = RuntimeSnapshotLedgerEnvelope(
            generatedAt: "2026-06-01T04:00:00Z",
            sourceRecordIDs: ["source-current"],
            receiptIDs: ["receipt-current"],
            replayTraceIDs: ["trace-current"],
            recommendationInputReferenceIDs: ["recommendation-current"],
            proofInputReferenceIDs: ["proof-current"],
            afep02LineageReferenceIDs: ["afep02-lineage-current"]
        )
        let migratedEnvelope = RuntimeSnapshotLedgerEnvelope(
            schemaVersion: runtimeSnapshotLedgerLegacySchemaVersion,
            generatedAt: "2026-06-01T04:00:00Z",
            sourceRecordIDs: ["source-legacy"],
            receiptIDs: ["receipt-legacy"],
            replayTraceIDs: ["trace-legacy"],
            recommendationInputReferenceIDs: ["recommendation-legacy"],
            proofInputReferenceIDs: ["proof-legacy"],
            afep02LineageReferenceIDs: ["afep02-lineage-legacy"]
        )
        let unsupportedEnvelope = RuntimeSnapshotLedgerEnvelope(
            schemaVersion: "runtime_snapshot_ledger.native.v9",
            generatedAt: "2026-06-01T04:00:00Z",
            sourceRecordIDs: ["source-unsupported"],
            receiptIDs: ["receipt-unsupported"],
            replayTraceIDs: ["trace-unsupported"],
            recommendationInputReferenceIDs: ["recommendation-unsupported"],
            proofInputReferenceIDs: ["proof-unsupported"],
            afep02LineageReferenceIDs: ["afep02-lineage-unsupported"]
        )

        try await repository.append(currentEnvelope)
        try await repository.append(migratedEnvelope)
        try await repository.append(unsupportedEnvelope)

        let missingReport = try await repository.validateReceipt(
            referenceID: "receipt-missing",
            envelopeID: currentEnvelope.id,
            checksum: currentEnvelope.checksum
        )
        XCTAssertEqual(missingReport.outcome, .missingEnvelope)

        let migratedReport = try await repository.validate(reference: RuntimeSnapshotLedgerArtifactReference(
            kind: .receipt,
            artifactID: "receipt-legacy",
            envelopeID: migratedEnvelope.id,
            envelopeChecksum: migratedEnvelope.checksum
        ))
        XCTAssertEqual(migratedReport.outcome, .valid)
        XCTAssertEqual(migratedReport.compatibilityStatus, .migratedOlder)

        let unsupportedReport = try await repository.validate(reference: RuntimeSnapshotLedgerArtifactReference(
            kind: .receipt,
            artifactID: "receipt-unsupported",
            envelopeID: unsupportedEnvelope.id,
            envelopeChecksum: unsupportedEnvelope.checksum
        ))
        XCTAssertEqual(unsupportedReport.outcome, .unsupportedEnvelope)

        let checksumMismatchReport = try await repository.validate(reference: RuntimeSnapshotLedgerArtifactReference(
            kind: .receipt,
            artifactID: "receipt-current",
            envelopeID: currentEnvelope.id,
            envelopeChecksum: "sha256:bogus"
        ))
        XCTAssertEqual(checksumMismatchReport.outcome, .checksumMismatch)
        XCTAssertEqual(checksumMismatchReport.expectedChecksum, "sha256:bogus")
        XCTAssertEqual(checksumMismatchReport.observedChecksum, currentEnvelope.checksum)
    }
}
