import Foundation

enum CloudKitContinuityRecordFamily: String, Codable, Sendable, CaseIterable {
    case goal
    case step
    case capture
    case proof
    case receipt
    case memorySignal = "memory_signal"
    case preference
    case tombstone
    case syncLedger = "sync_ledger"

    static var approvedFamilies: [CloudKitContinuityRecordFamily] {
        allCases
    }
}

enum CloudKitContinuityRecordReviewState: String, Codable, Sendable, CaseIterable {
    case ready
    case needsReview = "needs_review"
    case conflict
    case tombstoned
}

enum SyncEnvelopePayloadClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case eventEnvelopeMetadata = "event_envelope_metadata"
    case tombstoneMetadata = "tombstone_metadata"
    case preferenceMetadata = "preference_metadata"
    case receiptMetadata = "receipt_metadata"
    case syncLedger = "sync_ledger"
    case privateLifeGraphObject = "private_life_graph_object"
    case privateSensitivePayload = "private_sensitive_payload"

    var eligibleForContinuityEnvelope: Bool {
        switch self {
        case .eventEnvelopeMetadata, .tombstoneMetadata, .preferenceMetadata, .receiptMetadata, .syncLedger:
            return true
        case .privateLifeGraphObject, .privateSensitivePayload:
            return false
        }
    }
}

struct CloudKitContinuityTombstoneMetadata: Codable, Sendable, Equatable, Hashable {
    let entityKind: String
    let entityID: String
    let reason: String
    let recordedAt: String
    let localOnly: Bool
}

struct CloudKitContinuityPortableRecordEnvelope: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let family: CloudKitContinuityRecordFamily
    let recordName: String
    let schemaVersion: String
    let localRevision: Int
    let createdAt: String
    let updatedAt: String
    let sourceRecordID: String?
    let receiptID: String?
    let replayTraceID: String?
    let reviewState: CloudKitContinuityRecordReviewState
    let tombstone: CloudKitContinuityTombstoneMetadata?
    let payloadClass: SyncEnvelopePayloadClass
    let payloadData: Data

    var canEnterCloudKitContinuity: Bool {
        reviewState != .conflict && payloadClass.eligibleForContinuityEnvelope && tombstone?.localOnly != true
    }
}

struct SyncEnvelope: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let record: CloudKitContinuityPortableRecordEnvelope
    let causalClock: SyncCausalClock
    let localStoreAuthoritative: Bool
    let queuedAt: String
    let reasons: [String]

    init(
        record: CloudKitContinuityPortableRecordEnvelope,
        causalClock: SyncCausalClock,
        localStoreAuthoritative: Bool = true,
        queuedAt: String,
        reasons: [String] = []
    ) {
        self.id = "sync_envelope.\(record.id)"
        self.record = record
        self.causalClock = causalClock
        self.localStoreAuthoritative = localStoreAuthoritative
        self.queuedAt = queuedAt.trimmingCharacters(in: .whitespacesAndNewlines).syncEnvelopeNilIfEmpty ?? record.updatedAt
        self.reasons = Array(Set(reasons.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    var canEnterCloudKitContinuity: Bool {
        localStoreAuthoritative && record.canEnterCloudKitContinuity
    }
}

protocol CloudKitContinuityPortableRecordCoding: Sendable {
    static var family: CloudKitContinuityRecordFamily { get }
    static var schemaVersion: String { get }
}

private extension String {
    var syncEnvelopeNilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

enum CloudKitContinuityPortableRecordCodec {
    static func encode<Payload: Codable & Sendable>(
        _ payload: Payload,
        family: CloudKitContinuityRecordFamily,
        recordName: String,
        schemaVersion: String,
        localRevision: Int,
        createdAt: String,
        updatedAt: String,
        sourceRecordID: String? = nil,
        receiptID: String? = nil,
        replayTraceID: String? = nil,
        reviewState: CloudKitContinuityRecordReviewState = .ready,
        tombstone: CloudKitContinuityTombstoneMetadata? = nil,
        payloadClass: SyncEnvelopePayloadClass? = nil,
        encoder: JSONEncoder? = nil
    ) throws -> CloudKitContinuityPortableRecordEnvelope {
        let encoder = encoder ?? makeEncoder()
        let payloadData = try encoder.encode(payload)
        let payloadClass = payloadClass ?? defaultPayloadClass(family: family, tombstone: tombstone)
        return CloudKitContinuityPortableRecordEnvelope(
            id: "\(family.rawValue).\(recordName)",
            family: family,
            recordName: recordName,
            schemaVersion: schemaVersion,
            localRevision: localRevision,
            createdAt: createdAt,
            updatedAt: updatedAt,
            sourceRecordID: sourceRecordID,
            receiptID: receiptID,
            replayTraceID: replayTraceID,
            reviewState: reviewState,
            tombstone: tombstone,
            payloadClass: payloadClass,
            payloadData: payloadData
        )
    }

    static func decode<Payload: Codable & Sendable>(
        _ envelope: CloudKitContinuityPortableRecordEnvelope,
        as type: Payload.Type,
        family: CloudKitContinuityRecordFamily,
        decoder: JSONDecoder? = nil
    ) throws -> Payload {
        precondition(envelope.family == family)
        let decoder = decoder ?? makeDecoder()
        return try decoder.decode(Payload.self, from: envelope.payloadData)
    }

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        JSONDecoder()
    }

    private static func defaultPayloadClass(
        family: CloudKitContinuityRecordFamily,
        tombstone: CloudKitContinuityTombstoneMetadata?
    ) -> SyncEnvelopePayloadClass {
        if tombstone != nil {
            return .tombstoneMetadata
        }
        switch family {
        case .preference:
            return .preferenceMetadata
        case .receipt:
            return .receiptMetadata
        case .syncLedger:
            return .syncLedger
        case .tombstone:
            return .tombstoneMetadata
        case .goal, .step, .capture, .proof, .memorySignal:
            return .eventEnvelopeMetadata
        }
    }
}

enum CloudKitContinuityOperationKind: String, Codable, Sendable, CaseIterable {
    case upsert
    case delete
    case review
    case noop
}

struct CloudKitContinuityLedgerEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let family: CloudKitContinuityRecordFamily
    let recordName: String
    let operation: CloudKitContinuityOperationKind
    let localRevision: Int
    let syncState: CloudKitContinuitySyncState
    let createdAt: String
    let updatedAt: String
    let detail: String
}

struct CloudKitContinuityOutboxEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let envelope: CloudKitContinuityPortableRecordEnvelope
    let operation: CloudKitContinuityOperationKind
    let syncMode: CloudKitContinuityMode
    let syncState: CloudKitContinuitySyncState
    let queuedAt: String
    let detail: String
}

struct CloudKitContinuityConflictReview: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let family: CloudKitContinuityRecordFamily
    let recordName: String
    let localEnvelope: CloudKitContinuityPortableRecordEnvelope?
    let remoteEnvelope: CloudKitContinuityPortableRecordEnvelope?
    let reviewState: CloudKitContinuityRecordReviewState
    let createdAt: String
    let detail: String
}

struct CloudKitContinuitySyncLedgerSnapshot: Codable, Sendable, Equatable, Hashable {
    let deviceID: String
    let schemaVersion: String
    let lastProcessedRevision: Int
    let lastSyncedAt: String?
    let pendingRecordCount: Int
    let reviewRecordCount: Int
    let syncState: CloudKitContinuitySyncState
}
