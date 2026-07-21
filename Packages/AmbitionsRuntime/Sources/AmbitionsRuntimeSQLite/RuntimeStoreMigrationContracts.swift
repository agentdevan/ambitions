import CryptoKit
import Foundation
import AmbitionsRuntimeCore

public struct RuntimeStoreMigrationReservation: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let reservationIdentity: String
    public let migrationIdentity: String
    public let stagingDirectoryURL: URL
    public let stagedStoreURL: URL

    public init(
        schemaVersion: Int = 2,
        reservationIdentity: String = "",
        migrationIdentity: String,
        stagingDirectoryURL: URL,
        stagedStoreURL: URL
    ) {
        self.schemaVersion = schemaVersion
        self.reservationIdentity = reservationIdentity
        self.migrationIdentity = migrationIdentity
        self.stagingDirectoryURL = stagingDirectoryURL
        self.stagedStoreURL = stagedStoreURL
    }
}

public struct RuntimeStoreVerificationCounts: Codable, Sendable, Equatable {
    public let stateCount: Int
    public let eventCount: Int
    public let projectionCount: Int
    public let receiptCount: Int
    public let outboxCount: Int

    public init(
        stateCount: Int,
        eventCount: Int,
        projectionCount: Int,
        receiptCount: Int,
        outboxCount: Int
    ) {
        self.stateCount = stateCount
        self.eventCount = eventCount
        self.projectionCount = projectionCount
        self.receiptCount = receiptCount
        self.outboxCount = outboxCount
    }
}

public struct RuntimeStoreStableChecksums: Codable, Sendable, Equatable {
    public let stateChecksum: String
    public let eventChecksum: String
    public let projectionChecksum: String
    public let receiptChecksum: String
    public let outboxChecksum: String

    public init(
        stateChecksum: String,
        eventChecksum: String,
        projectionChecksum: String,
        receiptChecksum: String,
        outboxChecksum: String
    ) {
        self.stateChecksum = stateChecksum
        self.eventChecksum = eventChecksum
        self.projectionChecksum = projectionChecksum
        self.receiptChecksum = receiptChecksum
        self.outboxChecksum = outboxChecksum
    }

    public init(
        snapshot: RuntimeStoreSnapshot,
        outbox: [RuntimeExternalEffectRecord]
    ) throws {
        stateChecksum = try Self.checksum(snapshot.stateChanges)
        eventChecksum = try Self.checksum(snapshot.events)
        projectionChecksum = try Self.checksum(snapshot.projectionChanges)
        receiptChecksum = try Self.checksum(snapshot.receipts)
        outboxChecksum = try Self.checksum(
            outbox.map(RuntimeStoreStableOutboxRecord.init)
        )
    }

    private static func checksum<Value: Encodable>(_ value: Value) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return SHA256.hash(data: try encoder.encode(value))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

public struct RuntimeStoreVerificationExpectations: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let migrationIdentity: String
    public let canonicalRevision: Int64
    public let counts: RuntimeStoreVerificationCounts
    public let checksums: RuntimeStoreStableChecksums
    public let sqliteIntegrityResult: String
    public let restartEquivalent: Bool

    public init(
        schemaVersion: Int = 1,
        migrationIdentity: String,
        canonicalRevision: Int64,
        counts: RuntimeStoreVerificationCounts,
        checksums: RuntimeStoreStableChecksums,
        sqliteIntegrityResult: String = "ok",
        restartEquivalent: Bool = true
    ) {
        self.schemaVersion = schemaVersion
        self.migrationIdentity = migrationIdentity
        self.canonicalRevision = canonicalRevision
        self.counts = counts
        self.checksums = checksums
        self.sqliteIntegrityResult = sqliteIntegrityResult
        self.restartEquivalent = restartEquivalent
    }
}

public struct RuntimeStoreVerificationReport: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let reservationIdentity: String
    public let verificationIdentity: String
    public let migrationIdentity: String
    public let canonicalRevision: Int64
    public let counts: RuntimeStoreVerificationCounts
    public let checksums: RuntimeStoreStableChecksums
    public let sqliteIntegrityResult: String
    public let restartEquivalent: Bool
    public let candidateDigest: String
    public let expectationsDigest: String

    public init(
        schemaVersion: Int = 2,
        reservationIdentity: String,
        verificationIdentity: String,
        migrationIdentity: String,
        canonicalRevision: Int64,
        counts: RuntimeStoreVerificationCounts,
        checksums: RuntimeStoreStableChecksums,
        sqliteIntegrityResult: String,
        restartEquivalent: Bool,
        candidateDigest: String,
        expectationsDigest: String = ""
    ) {
        self.schemaVersion = schemaVersion
        self.reservationIdentity = reservationIdentity
        self.verificationIdentity = verificationIdentity
        self.migrationIdentity = migrationIdentity
        self.canonicalRevision = canonicalRevision
        self.counts = counts
        self.checksums = checksums
        self.sqliteIntegrityResult = sqliteIntegrityResult
        self.restartEquivalent = restartEquivalent
        self.candidateDigest = candidateDigest
        self.expectationsDigest = expectationsDigest
    }
}

public struct RuntimeStoreFileIdentity: Codable, Sendable, Equatable {
    public let filename: String
    public let digest: String
    public let migrationIdentity: String

    public init(
        filename: String,
        digest: String,
        migrationIdentity: String
    ) {
        self.filename = filename
        self.digest = digest
        self.migrationIdentity = migrationIdentity
    }
}

public struct RuntimeStoreActivePointer: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let currentStore: RuntimeStoreFileIdentity
    public let previousStore: RuntimeStoreFileIdentity?
    public let migrationIdentity: String
    public let activatedAt: Date

    public init(
        schemaVersion: Int = 1,
        currentStore: RuntimeStoreFileIdentity,
        previousStore: RuntimeStoreFileIdentity?,
        migrationIdentity: String,
        activatedAt: Date
    ) {
        self.schemaVersion = schemaVersion
        self.currentStore = currentStore
        self.previousStore = previousStore
        self.migrationIdentity = migrationIdentity
        self.activatedAt = activatedAt
    }
}

public enum RuntimeStoreMigrationFailurePoint: String, Codable, Sendable, Equatable {
    case beforePointerRename = "before_pointer_rename"
    case afterPointerRename = "after_pointer_rename"
}

public enum RuntimeStoreMigrationError: Error, Sendable, Equatable {
    case invalidMigrationIdentity(String)
    case unsupportedReservationSchemaVersion(Int)
    case unsupportedVerificationSchemaVersion(Int)
    case unsupportedPointerSchemaVersion(Int)
    case mismatchedMigrationIdentity(expected: String, actual: String)
    case reservationPathMismatch(expected: URL, actual: URL)
    case unsafeStoreFilename(String)
    case storeIsNotRegularFile(String)
    case noActiveStore
    case noPreviousStore
    case verificationMismatch(field: String, expected: String, actual: String)
    case restartMismatch
    case sqliteIntegrityFailed(String)
    case digestMismatch(filename: String, expected: String, actual: String)
    case finalStoreAlreadyExists(String)
    case invalidPointer(String)
    case unsafeFilesystemEntry(String)
    case reservationNotIssued(String)
    case verificationNotIssued(String)
    case verificationAlreadyConsumed(String)
    case verificationIdentityMismatch
    case authorityConflict(expectedGeneration: Int64, actualGeneration: Int64)
    case injectedFailure(RuntimeStoreMigrationFailurePoint)
    case fileOperationFailed(operation: String, description: String)
}

private struct RuntimeStoreStableOutboxRecord: Codable {
    let envelope: RuntimeExternalEffectEnvelope
    let status: RuntimeExternalEffectStatus
    let attemptCount: Int64
    let claim: RuntimeExternalEffectClaim?
    let failureDescription: String?

    init(_ record: RuntimeExternalEffectRecord) {
        envelope = record.envelope
        status = record.status
        attemptCount = record.attemptCount
        claim = record.claim
        failureDescription = record.failureDescription
    }
}
