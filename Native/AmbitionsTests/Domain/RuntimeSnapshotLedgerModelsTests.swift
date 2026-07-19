import XCTest
@testable import Ambitions

final class RuntimeSnapshotLedgerModelsTests: XCTestCase {
    func testEnvelopeCompatibilityAndRedactionProjectionAreDeterministic() {
        let envelope = RuntimeSnapshotLedgerEnvelope(
            generatedAt: "2026-06-01T04:00:00Z",
            sourceRecordIDs: ["source-2", "source-1"],
            receiptIDs: ["receipt-1"],
            replayTraceIDs: ["trace-1"],
            recommendationInputReferenceIDs: ["recommendation-1"],
            proofInputReferenceIDs: ["proof-1"],
            afep02LineageReferenceIDs: ["afep02-lineage-1"]
        )

        XCTAssertEqual(envelope.compatibilityStatus, .current)
        XCTAssertTrue(envelope.isCurrentVersion)
        XCTAssertTrue(envelope.isSupported)
        XCTAssertTrue(envelope.checksum.hasPrefix("sha256:"))
        XCTAssertTrue(envelope.provenanceHash.hasPrefix("sha256:"))
        XCTAssertEqual(envelope.references(for: .receipt).map(\.artifactID), ["receipt-1"])
        XCTAssertEqual(envelope.references(for: .proofInput).map(\.artifactID), ["proof-1"])

        let projection = envelope.exportSafeProjection
        XCTAssertTrue(projection.isExportSafe)
        XCTAssertEqual(projection.compatibilityStatus, .current)
        XCTAssertEqual(projection.fields.count, 6)
        XCTAssertEqual(projection.fields.first(where: { $0.fieldName == "receiptIDs" })?.redactionClass, .localOnly)
        XCTAssertTrue(projection.fields.first(where: { $0.fieldName == "receiptIDs" })?.visibleValues.isEmpty == true)
        XCTAssertEqual(projection.fields.first(where: { $0.fieldName == "receiptIDs" })?.redactedValue, "[redacted]")
        XCTAssertEqual(projection.fields.first(where: { $0.fieldName == "sourceRecordIDs" })?.redactionClass, .localOnly)

        let legacyEnvelope = RuntimeSnapshotLedgerEnvelope(
            schemaVersion: runtimeSnapshotLedgerLegacySchemaVersion,
            generatedAt: "2026-06-01T04:00:00Z",
            sourceRecordIDs: ["source-legacy"],
            receiptIDs: ["receipt-legacy"],
            replayTraceIDs: ["trace-legacy"],
            recommendationInputReferenceIDs: ["recommendation-legacy"],
            proofInputReferenceIDs: ["proof-legacy"],
            afep02LineageReferenceIDs: ["afep02-lineage-legacy"]
        )
        XCTAssertEqual(legacyEnvelope.compatibilityStatus, .migratedOlder)
        XCTAssertTrue(legacyEnvelope.isSupported)

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
        XCTAssertEqual(unsupportedEnvelope.compatibilityStatus, .unsupported)
        XCTAssertFalse(unsupportedEnvelope.isSupported)
    }

    func testValidationDistinguishesMissingUnsupportedAndChecksumMismatch() {
        let envelope = RuntimeSnapshotLedgerEnvelope(
            generatedAt: "2026-06-01T04:00:00Z",
            sourceRecordIDs: ["source-1"],
            receiptIDs: ["receipt-1"],
            replayTraceIDs: ["trace-1"],
            recommendationInputReferenceIDs: ["recommendation-1"],
            proofInputReferenceIDs: ["proof-1"],
            afep02LineageReferenceIDs: ["afep02-lineage-1"]
        )

        let validReference = RuntimeSnapshotLedgerArtifactReference(
            kind: .receipt,
            artifactID: "receipt-1",
            envelopeID: envelope.id,
            envelopeChecksum: envelope.checksum
        )
        let validReport = envelope.validate(reference: validReference)
        XCTAssertTrue(validReport.isValid)
        XCTAssertEqual(validReport.outcome, .valid)

        let missingReference = RuntimeSnapshotLedgerArtifactReference(
            kind: .receipt,
            artifactID: "missing-receipt",
            envelopeID: envelope.id,
            envelopeChecksum: envelope.checksum
        )
        let missingReport = envelope.validate(reference: missingReference)
        XCTAssertEqual(missingReport.outcome, .missingEnvelope)
        XCTAssertEqual(missingReport.matchedEnvelopeCount, 1)

        let checksumMismatchReference = RuntimeSnapshotLedgerArtifactReference(
            kind: .receipt,
            artifactID: "receipt-1",
            envelopeID: envelope.id,
            envelopeChecksum: "sha256:bogus"
        )
        let checksumMismatchReport = envelope.validate(reference: checksumMismatchReference)
        XCTAssertEqual(checksumMismatchReport.outcome, .checksumMismatch)
        XCTAssertEqual(checksumMismatchReport.expectedChecksum, "sha256:bogus")
        XCTAssertEqual(checksumMismatchReport.observedChecksum, envelope.checksum)

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
        let migratedReference = RuntimeSnapshotLedgerArtifactReference(
            kind: .receipt,
            artifactID: "receipt-legacy",
            envelopeID: migratedEnvelope.id,
            envelopeChecksum: migratedEnvelope.checksum
        )
        let migratedReport = migratedEnvelope.validate(reference: migratedReference)
        XCTAssertEqual(migratedReport.outcome, .valid)
        XCTAssertEqual(migratedReport.compatibilityStatus, .migratedOlder)

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
        let unsupportedReference = RuntimeSnapshotLedgerArtifactReference(
            kind: .receipt,
            artifactID: "receipt-unsupported",
            envelopeID: unsupportedEnvelope.id,
            envelopeChecksum: unsupportedEnvelope.checksum
        )
        let unsupportedReport = unsupportedEnvelope.validate(reference: unsupportedReference)
        XCTAssertEqual(unsupportedReport.outcome, .unsupportedEnvelope)
    }
}
