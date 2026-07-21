import CryptoKit
import Foundation

extension RuntimeStoreMigrationCoordinator {
    static func compare(
        _ observation: RuntimeStoreMigrationObservation,
        with expectations: RuntimeStoreVerificationExpectations
    ) throws {
        try requireEqual(
            field: "canonicalRevision",
            expected: expectations.canonicalRevision,
            actual: observation.snapshot.canonicalRevision
        )
        try requireEqual(
            field: "stateCount",
            expected: expectations.counts.stateCount,
            actual: observation.counts.stateCount
        )
        try requireEqual(
            field: "eventCount",
            expected: expectations.counts.eventCount,
            actual: observation.counts.eventCount
        )
        try requireEqual(
            field: "projectionCount",
            expected: expectations.counts.projectionCount,
            actual: observation.counts.projectionCount
        )
        try requireEqual(
            field: "receiptCount",
            expected: expectations.counts.receiptCount,
            actual: observation.counts.receiptCount
        )
        try requireEqual(
            field: "outboxCount",
            expected: expectations.counts.outboxCount,
            actual: observation.counts.outboxCount
        )
        try requireEqual(
            field: "stateChecksum",
            expected: expectations.checksums.stateChecksum,
            actual: observation.checksums.stateChecksum
        )
        try requireEqual(
            field: "eventChecksum",
            expected: expectations.checksums.eventChecksum,
            actual: observation.checksums.eventChecksum
        )
        try requireEqual(
            field: "projectionChecksum",
            expected: expectations.checksums.projectionChecksum,
            actual: observation.checksums.projectionChecksum
        )
        try requireEqual(
            field: "receiptChecksum",
            expected: expectations.checksums.receiptChecksum,
            actual: observation.checksums.receiptChecksum
        )
        try requireEqual(
            field: "outboxChecksum",
            expected: expectations.checksums.outboxChecksum,
            actual: observation.checksums.outboxChecksum
        )
        try requireEqual(
            field: "sqliteIntegrityResult",
            expected: expectations.sqliteIntegrityResult,
            actual: observation.integrityResult
        )
    }

    static func stableDigest<Value: Encodable>(
        _ value: Value
    ) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return SHA256.hash(data: try encoder.encode(value))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    static func validateMigrationIdentity(_ identity: String) throws {
        let permitted = CharacterSet.alphanumerics.union(
            CharacterSet(charactersIn: "-._")
        )
        guard !identity.isEmpty,
              identity.utf8.count <= 80,
              identity != ".",
              identity != "..",
              identity.unicodeScalars.allSatisfy(permitted.contains)
        else {
            throw RuntimeStoreMigrationError.invalidMigrationIdentity(identity)
        }
    }

    static func validateStoreFilename(_ filename: String) throws {
        guard !filename.isEmpty,
              filename == URL(fileURLWithPath: filename).lastPathComponent,
              !filename.contains("/"),
              !filename.contains("\\"),
              filename != ".",
              filename != "..",
              !filename.contains("\0")
        else {
            throw RuntimeStoreMigrationError.unsafeStoreFilename(filename)
        }
    }

    private static func requireEqual<Value: Equatable>(
        field: String,
        expected: Value,
        actual: Value
    ) throws {
        guard expected == actual else {
            throw RuntimeStoreMigrationError.verificationMismatch(
                field: field,
                expected: String(describing: expected),
                actual: String(describing: actual)
            )
        }
    }
}
