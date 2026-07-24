import AmbitionsRuntimeCore
import AmbitionsRuntimeSQLite
import Foundation

enum CanonicalRuntimeSemanticEventStoreError: Error, Sendable, Equatable {
    case invalidIdentity
    case aggregateMismatch
    case aggregateRevisionMismatch
    case invalidCausation
    case invalidSequence
    case hashChainBroken
    case malformedStoredRow
    case oversizeQuarantineDeferredUntilBlobAuthority
}

extension CanonicalRuntimeSemanticEventStoreError: CustomStringConvertible, LocalizedError {
    var description: String {
        switch self {
        case .invalidIdentity: "The event identity is invalid."
        case .aggregateMismatch: "The event aggregate does not match its typed family."
        case .aggregateRevisionMismatch: "The event revision does not match canonical authority."
        case .invalidCausation: "The event causation is invalid."
        case .invalidSequence: "The event sequence is invalid."
        case .hashChainBroken: "The event hash chain is invalid."
        case .malformedStoredRow: "The stored event row is malformed."
        case .oversizeQuarantineDeferredUntilBlobAuthority: "Oversized source quarantine is deferred until verified blob authority is available."
        }
    }
    var errorDescription: String? { description }
}

enum CanonicalRuntimeSemanticEventSchemaPlan {
    static let sourceSchemaVersion = 1
    static let targetSchemaVersion = 2
    static let maximumStoredEventBytes = RuntimeSemanticEventLimits.canonical.maximumEnvelopeBytes
    static let maximumInlineQuarantineBytes = 1_048_576

    static let tables: Set<String> = ["runtime_semantic_events", "runtime_semantic_event_quarantine"]
    static let indexes: Set<String> = [
        "runtime_semantic_events_command_sequence_idx",
        "runtime_semantic_events_aggregate_sequence_idx",
        "runtime_semantic_events_correlation_sequence_idx",
        "runtime_semantic_event_quarantine_sequence_idx",
    ]

    static let statements: [String] = [
        """
        CREATE TABLE runtime_semantic_events (
            sequence INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id TEXT NOT NULL UNIQUE CHECK (length(event_id) > 0),
            command_id TEXT NOT NULL CHECK (length(command_id) > 0),
            aggregate_kind TEXT NOT NULL CHECK (length(aggregate_kind) > 0),
            aggregate_id TEXT NOT NULL CHECK (length(aggregate_id) > 0),
            canonical_revision INTEGER NOT NULL CHECK (canonical_revision >= 0),
            correlation_id TEXT NOT NULL CHECK (length(correlation_id) > 0),
            causation_event_id TEXT,
            envelope_version INTEGER NOT NULL CHECK (envelope_version > 0),
            type_id TEXT NOT NULL CHECK (length(type_id) > 0),
            payload_version INTEGER NOT NULL CHECK (payload_version >= 0),
            source_bytes BLOB NOT NULL CHECK (length(source_bytes) <= 1048576),
            source_digest TEXT NOT NULL CHECK (length(source_digest) = 64 AND source_digest NOT GLOB '*[^0-9a-f]*'),
            previous_event_hash TEXT CHECK (previous_event_hash IS NULL OR (length(previous_event_hash) = 64 AND previous_event_hash NOT GLOB '*[^0-9a-f]*')),
            event_hash TEXT NOT NULL UNIQUE CHECK (length(event_hash) = 64 AND event_hash NOT GLOB '*[^0-9a-f]*'),
            occurred_at_ms INTEGER NOT NULL CHECK (occurred_at_ms >= 0),
            FOREIGN KEY (aggregate_kind, aggregate_id)
                REFERENCES runtime_aggregates(aggregate_kind, aggregate_id),
            FOREIGN KEY (command_id)
                REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (causation_event_id)
                REFERENCES runtime_semantic_events(event_id)
        )
        """,
        "CREATE INDEX runtime_semantic_events_command_sequence_idx ON runtime_semantic_events(command_id, sequence)",
        "CREATE INDEX runtime_semantic_events_aggregate_sequence_idx ON runtime_semantic_events(aggregate_kind, aggregate_id, sequence)",
        "CREATE INDEX runtime_semantic_events_correlation_sequence_idx ON runtime_semantic_events(correlation_id, sequence)",
        """
        CREATE TRIGGER runtime_semantic_events_immutable_update
        BEFORE UPDATE ON runtime_semantic_events
        BEGIN SELECT RAISE(ABORT, 'immutable semantic event'); END
        """,
        """
        CREATE TRIGGER runtime_semantic_events_immutable_delete
        BEFORE DELETE ON runtime_semantic_events
        BEGIN SELECT RAISE(ABORT, 'immutable semantic event'); END
        """,
        """
        CREATE TABLE runtime_semantic_event_quarantine (
            quarantine_sequence INTEGER PRIMARY KEY AUTOINCREMENT,
            quarantine_key TEXT NOT NULL UNIQUE CHECK (length(quarantine_key) = 64 AND quarantine_key NOT GLOB '*[^0-9a-f]*'),
            source_event_id TEXT,
            source_event_sequence INTEGER,
            reason TEXT NOT NULL CHECK (length(reason) > 0),
            source_digest TEXT NOT NULL CHECK (length(source_digest) = 64 AND source_digest NOT GLOB '*[^0-9a-f]*'),
            source_byte_count INTEGER NOT NULL CHECK (source_byte_count >= 0),
            inline_source_bytes BLOB NOT NULL CHECK (length(inline_source_bytes) <= 1048576),
            observed_at_ms INTEGER NOT NULL CHECK (observed_at_ms >= 0),
            CHECK (source_event_sequence IS NULL OR source_event_sequence > 0),
            CHECK (length(inline_source_bytes) = source_byte_count)
        )
        """,
        "CREATE INDEX runtime_semantic_event_quarantine_sequence_idx ON runtime_semantic_event_quarantine(quarantine_sequence)",
        """
        CREATE TRIGGER runtime_semantic_event_quarantine_immutable_update
        BEFORE UPDATE ON runtime_semantic_event_quarantine
        BEGIN SELECT RAISE(ABORT, 'immutable semantic event quarantine'); END
        """,
        """
        CREATE TRIGGER runtime_semantic_event_quarantine_immutable_delete
        BEFORE DELETE ON runtime_semantic_event_quarantine
        BEGIN SELECT RAISE(ABORT, 'immutable semantic event quarantine'); END
        """,
    ]

    static func install(in database: isolated SQLiteDatabase) throws {
        for statement in statements { try database.execute(statement) }
    }
}

enum RuntimeSemanticEventSourceRetention: Sendable, Equatable {
    case inline(Data)
}

struct CanonicalRuntimeSemanticEventAppendRequest: Sendable, Equatable {
    let eventID: RuntimeEventID
    let commandID: RuntimeCommandID
    let aggregate: RuntimeSemanticAggregate
    let canonicalAggregateRevision: UInt64
    let correlationID: RuntimeCorrelationID
    let causationEventID: RuntimeEventID?
    let occurredAt: Date
    let canonicalBytes: Data
    let sourceRetention: RuntimeSemanticEventSourceRetention

    init(
        eventID: RuntimeEventID,
        commandID: RuntimeCommandID,
        aggregate: RuntimeSemanticAggregate,
        canonicalAggregateRevision: UInt64,
        correlationID: RuntimeCorrelationID,
        causationEventID: RuntimeEventID?,
        occurredAt: Date,
        canonicalBytes: Data,
        sourceRetention: RuntimeSemanticEventSourceRetention? = nil
    ) throws {
        let seconds = occurredAt.timeIntervalSince1970
        guard seconds.isFinite, seconds >= 0,
              canonicalAggregateRevision <= UInt64(Int64.max) else {
            throw CanonicalRuntimeSemanticEventStoreError.invalidIdentity
        }
        let retention = sourceRetention ?? .inline(canonicalBytes)
        switch retention {
        case let .inline(bytes):
            guard bytes == canonicalBytes,
                  bytes.count <= CanonicalRuntimeSemanticEventSchemaPlan.maximumInlineQuarantineBytes else {
                throw CanonicalRuntimeSemanticEventStoreError.oversizeQuarantineDeferredUntilBlobAuthority
            }
        }
        self.eventID = eventID
        self.commandID = commandID
        self.aggregate = aggregate
        self.canonicalAggregateRevision = canonicalAggregateRevision
        self.correlationID = correlationID
        self.causationEventID = causationEventID
        self.occurredAt = occurredAt
        self.canonicalBytes = canonicalBytes
        self.sourceRetention = retention
    }
}

struct RuntimeSemanticEventLineage: Sendable, Equatable, Hashable {
    let eventID: RuntimeEventID
    let commandID: RuntimeCommandID
    let aggregate: RuntimeSemanticAggregate
    let canonicalAggregateRevision: UInt64
    let sequence: UInt64
    let correlationID: RuntimeCorrelationID
    let causationEventID: RuntimeEventID?
    let occurredAt: Date
    let previousEventHash: SHA256Digest?
    let sourceDigest: SHA256Digest
    let eventHash: SHA256Digest
}

struct CanonicalRuntimeSemanticEventRecord: Sendable, Equatable {
    let lineage: RuntimeSemanticEventLineage
    let event: RuntimeSemanticEvent
    let sourceBytes: Data
    let sourcePayloadVersion: Int
    let wasUpcast: Bool
    var sequence: UInt64 { lineage.sequence }
    func recomputedEventHash() throws -> SHA256Digest {
        try RuntimeSemanticEventHashing.eventHash(lineage: lineage, typeID: event.typeID, payloadVersion: sourcePayloadVersion)
    }
}

enum CanonicalRuntimeSemanticEventQuarantineReason: String, Codable, Sendable, Equatable, Hashable {
    case envelopeTooLarge = "envelope_too_large"
    case payloadTooLarge = "payload_too_large"
    case malformedEnvelope = "malformed_envelope"
    case corruptEnvelope = "corrupt_envelope"
    case truncatedEnvelope = "truncated_envelope"
    case futureEnvelopeVersion = "future_envelope_version"
    case unsupportedEnvelopeVersion = "unsupported_envelope_version"
    case unknownType = "unknown_type"
    case futurePayloadVersion = "future_payload_version"
    case unsupportedPayloadVersion = "unsupported_payload_version"
    case typeMismatch = "type_mismatch"
    case invalidPayload = "invalid_payload"
    case nonCanonicalBytes = "noncanonical_bytes"
    case normalizedColumnsMismatch = "normalized_columns_mismatch"
    case sourceDigestMismatch = "source_digest_mismatch"
    case eventHashMismatch = "event_hash_mismatch"
    case sequenceDiscontinuity = "sequence_discontinuity"
    case predecessorMismatch = "predecessor_mismatch"
    case predecessorBlocked = "predecessor_blocked"
    case invalidCausation = "invalid_causation"
    case malformedStoredRow = "malformed_stored_row"

    init(codecError: RuntimeSemanticEventCodecError) {
        self = switch codecError {
        case .envelopeTooLarge: .envelopeTooLarge
        case .payloadTooLarge: .payloadTooLarge
        case .malformedEnvelope: .malformedEnvelope
        case .corruptEnvelope: .corruptEnvelope
        case .truncatedEnvelope: .truncatedEnvelope
        case .futureEnvelopeVersion: .futureEnvelopeVersion
        case .unsupportedEnvelopeVersion: .unsupportedEnvelopeVersion
        case .unknownType: .unknownType
        case .futurePayloadVersion: .futurePayloadVersion
        case .unsupportedPayloadVersion: .unsupportedPayloadVersion
        case .typeMismatch: .typeMismatch
        case .invalidPayload, .encodingFailed: .invalidPayload
        case .nonCanonicalBytes: .nonCanonicalBytes
        }
    }
}

struct CanonicalRuntimeSemanticEventQuarantineRecord: Sendable, Equatable {
    let sequence: Int64
    let sourceEventID: String?
    let sourceEventSequence: UInt64?
    let reason: CanonicalRuntimeSemanticEventQuarantineReason
    let sourceDigest: SHA256Digest
    let sourceByteCount: UInt64
    let inlineSourceBytes: Data
    let observedAt: Date
}

struct CanonicalRuntimeSemanticEventQuarantineCursor: Sendable, Equatable, Hashable {
    let sequence: Int64
    init(sequence: Int64) throws {
        guard sequence > 0 else { throw CanonicalRuntimeSemanticEventStoreError.invalidSequence }
        self.sequence = sequence
    }
}

enum CanonicalRuntimeSemanticEventAppendOutcome: Sendable, Equatable {
    case appended(CanonicalRuntimeSemanticEventRecord)
    case quarantined(CanonicalRuntimeSemanticEventQuarantineRecord)
}

struct CanonicalRuntimeBlockedSemanticEvent: Sendable, Equatable {
    let sequence: UInt64
    let eventID: String
    let sourceDigest: SHA256Digest
    let reason: CanonicalRuntimeSemanticEventQuarantineReason
}

enum CanonicalRuntimeSemanticEventInspection: Sendable, Equatable {
    case supported(CanonicalRuntimeSemanticEventRecord)
    case blocked(CanonicalRuntimeBlockedSemanticEvent)
    var sequence: UInt64 { switch self { case let .supported(v): v.sequence; case let .blocked(v): v.sequence } }
}

enum RuntimeSemanticEventHashing {
    private struct Material: Codable {
        let eventID: RuntimeEventID
        let commandID: RuntimeCommandID
        let aggregate: RuntimeSemanticAggregate
        let canonicalAggregateRevision: UInt64
        let sequence: UInt64
        let correlationID: RuntimeCorrelationID
        let causationEventID: RuntimeEventID?
        let occurredAtMilliseconds: Int64
        let previousEventHash: SHA256Digest?
        let sourceDigest: SHA256Digest
        let typeID: RuntimeSemanticEventTypeID
        let payloadVersion: Int

        enum CodingKeys: String, CodingKey {
            case eventID = "event_id"
            case commandID = "command_id"
            case aggregate
            case canonicalAggregateRevision = "canonical_aggregate_revision"
            case sequence
            case correlationID = "correlation_id"
            case causationEventID = "causation_event_id"
            case occurredAtMilliseconds = "occurred_at_ms"
            case previousEventHash = "previous_event_hash"
            case sourceDigest = "source_digest"
            case typeID = "type_id"
            case payloadVersion = "payload_version"
        }
    }

    static func eventHash(lineage: RuntimeSemanticEventLineage, typeID: RuntimeSemanticEventTypeID, payloadVersion: Int) throws -> SHA256Digest {
        try eventHash(
            eventID: lineage.eventID,
            commandID: lineage.commandID,
            aggregate: lineage.aggregate,
            canonicalAggregateRevision: lineage.canonicalAggregateRevision,
            sequence: lineage.sequence,
            correlationID: lineage.correlationID,
            causationEventID: lineage.causationEventID,
            occurredAt: lineage.occurredAt,
            previousEventHash: lineage.previousEventHash,
            sourceDigest: lineage.sourceDigest,
            typeID: typeID,
            payloadVersion: payloadVersion
        )
    }

    static func eventHash(
        eventID: RuntimeEventID,
        commandID: RuntimeCommandID,
        aggregate: RuntimeSemanticAggregate,
        canonicalAggregateRevision: UInt64,
        sequence: UInt64,
        correlationID: RuntimeCorrelationID,
        causationEventID: RuntimeEventID?,
        occurredAt: Date,
        previousEventHash: SHA256Digest?,
        sourceDigest: SHA256Digest,
        typeID: RuntimeSemanticEventTypeID,
        payloadVersion: Int
    ) throws -> SHA256Digest {
        try SHA256Digest.digest(canonicalEncoding: Material(
            eventID: eventID,
            commandID: commandID,
            aggregate: aggregate,
            canonicalAggregateRevision: canonicalAggregateRevision,
            sequence: sequence,
            correlationID: correlationID,
            causationEventID: causationEventID,
            occurredAtMilliseconds: try milliseconds(occurredAt),
            previousEventHash: previousEventHash,
            sourceDigest: sourceDigest,
            typeID: typeID,
            payloadVersion: payloadVersion
        ))
    }

    static func milliseconds(_ date: Date) throws -> Int64 {
        let value = date.timeIntervalSince1970 * 1_000
        guard value.isFinite, value >= 0, value <= Double(Int64.max) else {
            throw CanonicalRuntimeSemanticEventStoreError.invalidIdentity
        }
        return Int64(value.rounded())
    }
}

enum CanonicalRuntimeSemanticEventStore {
    static let defaultPageLimit = 50
    static let maximumPageLimit = 200

    static func appendInTransaction(
        _ request: CanonicalRuntimeSemanticEventAppendRequest,
        to database: isolated SQLiteDatabase,
        codec: RuntimeSemanticEventCodec = RuntimeSemanticEventCodec()
    ) throws -> CanonicalRuntimeSemanticEventAppendOutcome {
        let decoded: RuntimeDecodedSemanticEvent
        let header: RuntimeSemanticEventHeader
        do {
            decoded = try codec.decode(request.canonicalBytes)
            header = try codec.inspectHeader(request.canonicalBytes)
        } catch let error as RuntimeSemanticEventCodecError {
            return .quarantined(try quarantine(
                request: request,
                sourceEventSequence: nil,
                reason: CanonicalRuntimeSemanticEventQuarantineReason(codecError: error),
                database: database
            ))
        }
        guard decoded.event.aggregateKind == request.aggregate.kind,
              decoded.event.mutation.aggregateID == request.aggregate.id else {
            throw CanonicalRuntimeSemanticEventStoreError.aggregateMismatch
        }
        guard decoded.event.mutation.resultingRevision == request.canonicalAggregateRevision else {
            throw CanonicalRuntimeSemanticEventStoreError.aggregateRevisionMismatch
        }
        try requireCanonicalRevision(request, database: database)
        let chain = try inspectWholeChain(database: database, codec: codec, quarantineBlocked: false)
        guard chain.allSatisfy({ if case .supported = $0 { true } else { false } }) else {
            throw CanonicalRuntimeSemanticEventStoreError.hashChainBroken
        }
        let allocator = try allocatorSequence(database)
        let tailSequence = chain.last?.sequence ?? 0
        guard allocator == tailSequence, allocator < UInt64(Int64.max) else {
            throw CanonicalRuntimeSemanticEventStoreError.invalidSequence
        }
        let sequence = allocator + 1
        let previousHash: SHA256Digest? = chain.last.flatMap {
            guard case let .supported(record) = $0 else { return nil }
            return record.lineage.eventHash
        }
        try requireCausation(request.causationEventID, correlationID: request.correlationID, before: sequence, chain: chain)
        let sourceDigest = SHA256Digest.digest(request.canonicalBytes)
        let eventHash = try RuntimeSemanticEventHashing.eventHash(
            eventID: request.eventID, commandID: request.commandID,
            aggregate: request.aggregate, canonicalAggregateRevision: request.canonicalAggregateRevision,
            sequence: sequence, correlationID: request.correlationID,
            causationEventID: request.causationEventID, occurredAt: request.occurredAt,
            previousEventHash: previousHash, sourceDigest: sourceDigest,
            typeID: decoded.event.typeID, payloadVersion: header.payloadVersion
        )
        let lineage = RuntimeSemanticEventLineage(
            eventID: request.eventID, commandID: request.commandID, aggregate: request.aggregate,
            canonicalAggregateRevision: request.canonicalAggregateRevision, sequence: sequence,
            correlationID: request.correlationID, causationEventID: request.causationEventID,
            occurredAt: request.occurredAt, previousEventHash: previousHash,
            sourceDigest: sourceDigest, eventHash: eventHash
        )
        try database.execute(
            """
            INSERT INTO runtime_semantic_events(
                sequence, event_id, command_id, aggregate_kind, aggregate_id,
                canonical_revision, correlation_id, causation_event_id,
                envelope_version, type_id, payload_version, source_bytes,
                source_digest, previous_event_hash, event_hash, occurred_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .integer(Int64(sequence)), .text(request.eventID.rawValue), .text(request.commandID.rawValue),
                .text(request.aggregate.kind.rawValue), .text(request.aggregate.id.rawValue),
                .integer(Int64(request.canonicalAggregateRevision)), .text(request.correlationID.rawValue),
                request.causationEventID.map { .text($0.rawValue) } ?? .null,
                .integer(Int64(header.envelopeVersion)), .text(header.typeID.rawValue),
                .integer(Int64(header.payloadVersion)), .blob(request.canonicalBytes),
                .text(sourceDigest.hexadecimal), previousHash.map { .text($0.hexadecimal) } ?? .null,
                .text(eventHash.hexadecimal), .integer(try RuntimeSemanticEventHashing.milliseconds(request.occurredAt)),
            ]
        )
        return .appended(CanonicalRuntimeSemanticEventRecord(
            lineage: lineage, event: decoded.event, sourceBytes: decoded.sourceBytes,
            sourcePayloadVersion: decoded.sourcePayloadVersion, wasUpcast: decoded.wasUpcast
        ))
    }

    static func readInTransaction(
        from database: isolated SQLiteDatabase,
        after cursor: CanonicalRuntimeEventCursor?,
        limit: Int,
        codec: RuntimeSemanticEventCodec = RuntimeSemanticEventCodec()
    ) throws -> CanonicalRuntimePage<CanonicalRuntimeSemanticEventInspection, CanonicalRuntimeEventCursor> {
        let all = try inspectWholeChain(database: database, codec: codec, quarantineBlocked: true)
        if let cursor {
            guard let cursorIndex = all.firstIndex(where: { $0.sequence == UInt64(cursor.sequence) }),
                  case let .supported(cursorRecord) = all[cursorIndex],
                  cursorRecord.lineage.eventID.rawValue == cursor.eventID,
                  all[...cursorIndex].allSatisfy({ inspection in
                      if case .supported = inspection { return true }
                      return false
                  }) else {
                throw CanonicalRuntimeSemanticEventStoreError.hashChainBroken
            }
        }
        let bounded = min(max(1, limit), maximumPageLimit)
        let remaining = all.filter { $0.sequence > UInt64(cursor?.sequence ?? 0) }
        let items = Array(remaining.prefix(bounded))
        let nextCursor: CanonicalRuntimeEventCursor?
        if remaining.count > bounded, let last = items.last {
            let eventID = switch last {
            case let .supported(record): record.lineage.eventID.rawValue
            case let .blocked(record): record.eventID
            }
            nextCursor = try CanonicalRuntimeEventCursor(sequence: Int64(last.sequence), eventID: eventID)
        } else { nextCursor = nil }
        return CanonicalRuntimePage(items: items, nextCursor: nextCursor)
    }

    static func quarantineInTransaction(
        from database: isolated SQLiteDatabase,
        after cursor: CanonicalRuntimeSemanticEventQuarantineCursor?,
        limit: Int
    ) throws -> CanonicalRuntimePage<CanonicalRuntimeSemanticEventQuarantineRecord, CanonicalRuntimeSemanticEventQuarantineCursor> {
        let bounded = min(max(1, limit), maximumPageLimit)
        let rows = try database.query(
            """
            SELECT quarantine_sequence, source_event_id, source_event_sequence,
                   reason, source_digest, source_byte_count, inline_source_bytes,
                   observed_at_ms
            FROM runtime_semantic_event_quarantine
            WHERE quarantine_sequence > ?
            ORDER BY quarantine_sequence ASC
            LIMIT ?
            """,
            bindings: [
                .integer(cursor?.sequence ?? 0),
                .integer(Int64(bounded + 1)),
            ],
            maximumDecodedBytes: (bounded + 1) * (CanonicalRuntimeSemanticEventSchemaPlan.maximumInlineQuarantineBytes + 4_096)
        )
        let records = try rows.prefix(bounded).map(quarantineRecord)
        let nextCursor: CanonicalRuntimeSemanticEventQuarantineCursor?
        if rows.count > bounded, let last = records.last {
            nextCursor = try CanonicalRuntimeSemanticEventQuarantineCursor(sequence: last.sequence)
        } else {
            nextCursor = nil
        }
        return CanonicalRuntimePage(items: records, nextCursor: nextCursor)
    }
}

private extension CanonicalRuntimeSemanticEventStore {
    static func inspectWholeChain(
        database: isolated SQLiteDatabase,
        codec: RuntimeSemanticEventCodec,
        quarantineBlocked: Bool
    ) throws -> [CanonicalRuntimeSemanticEventInspection] {
        let rows = try database.query(
            """
            SELECT sequence, event_id, command_id, aggregate_kind, aggregate_id,
                   canonical_revision, correlation_id, causation_event_id,
                   envelope_version, type_id, payload_version, source_bytes,
                   source_digest, previous_event_hash, event_hash, occurred_at_ms
            FROM runtime_semantic_events ORDER BY sequence ASC
            """,
            maximumDecodedBytes: 268_435_456
        )
        var expectedSequence: UInt64 = 1
        var expectedHash: SHA256Digest?
        var trusted = true
        var known: [String: (sequence: UInt64, correlation: String)] = [:]
        var result: [CanonicalRuntimeSemanticEventInspection] = []
        result.reserveCapacity(rows.count)
        for row in rows {
            let sequence = try uint64(row, "sequence")
            let eventID = try text(row, "event_id")
            let bytes = try blob(row, "source_bytes")
            let digest = SHA256Digest.digest(bytes)
            var reason: CanonicalRuntimeSemanticEventQuarantineReason?
            var record: CanonicalRuntimeSemanticEventRecord?
            do {
                guard sequence == expectedSequence else { throw InspectionFailure(.sequenceDiscontinuity) }
                guard trusted else { throw InspectionFailure(.predecessorBlocked) }
                guard try SHA256Digest(hexadecimal: text(row, "source_digest")) == digest else { throw InspectionFailure(.sourceDigestMismatch) }
                let decoded = try codec.decode(bytes)
                let header = try codec.inspectHeader(bytes)
                guard try int(row, "envelope_version") == header.envelopeVersion,
                      try text(row, "type_id") == header.typeID.rawValue,
                      try int(row, "payload_version") == header.payloadVersion else { throw InspectionFailure(.normalizedColumnsMismatch) }
                let aggregate = try RuntimeSemanticAggregate(
                    kind: aggregateKind(row, "aggregate_kind"),
                    id: RuntimeAggregateID(validating: text(row, "aggregate_id"))
                )
                let canonicalRevision = try revisionUInt64(row, "canonical_revision")
                guard decoded.event.aggregateKind == aggregate.kind,
                      decoded.event.mutation.aggregateID == aggregate.id,
                      decoded.event.mutation.resultingRevision == canonicalRevision else { throw InspectionFailure(.normalizedColumnsMismatch) }
                let previous = try optionalDigest(row, "previous_event_hash")
                guard previous == expectedHash else { throw InspectionFailure(.predecessorMismatch) }
                let correlation = try RuntimeCorrelationID(validating: text(row, "correlation_id"))
                let causation = try optionalText(row, "causation_event_id").map(RuntimeEventID.init(validating:))
                if let causation {
                    guard let causal = known[causation.rawValue], causal.sequence < sequence,
                          causal.correlation == correlation.rawValue else { throw InspectionFailure(.invalidCausation) }
                }
                let storedHash = try SHA256Digest(hexadecimal: text(row, "event_hash"))
                let lineage = RuntimeSemanticEventLineage(
                    eventID: try RuntimeEventID(validating: eventID),
                    commandID: try RuntimeCommandID(validating: text(row, "command_id")),
                    aggregate: aggregate, canonicalAggregateRevision: canonicalRevision,
                    sequence: sequence, correlationID: correlation, causationEventID: causation,
                    occurredAt: Date(timeIntervalSince1970: Double(try int64(row, "occurred_at_ms")) / 1_000),
                    previousEventHash: previous, sourceDigest: digest, eventHash: storedHash
                )
                let candidate = CanonicalRuntimeSemanticEventRecord(
                    lineage: lineage, event: decoded.event, sourceBytes: bytes,
                    sourcePayloadVersion: decoded.sourcePayloadVersion, wasUpcast: decoded.wasUpcast
                )
                guard try candidate.recomputedEventHash() == storedHash else { throw InspectionFailure(.eventHashMismatch) }
                record = candidate
            } catch let failure as InspectionFailure { reason = failure.reason }
            catch let error as RuntimeSemanticEventCodecError { reason = CanonicalRuntimeSemanticEventQuarantineReason(codecError: error) }
            catch { reason = .malformedStoredRow }
            if let record {
                result.append(.supported(record))
                expectedHash = record.lineage.eventHash
                known[eventID] = (sequence, record.lineage.correlationID.rawValue)
            } else {
                let blockedReason = reason ?? .malformedStoredRow
                if quarantineBlocked {
                    _ = try quarantine(
                        sourceEventID: eventID, sourceEventSequence: sequence,
                        reason: blockedReason, bytes: bytes, retention: .inline(bytes),
                        observedAtMilliseconds: max(0, (try? int64(row, "occurred_at_ms")) ?? 0), database: database
                    )
                }
                result.append(.blocked(CanonicalRuntimeBlockedSemanticEvent(
                    sequence: sequence, eventID: eventID, sourceDigest: digest, reason: blockedReason
                )))
                trusted = false
                expectedHash = try? SHA256Digest(hexadecimal: text(row, "event_hash"))
            }
            expectedSequence = sequence + 1
        }
        return result
    }

    static func allocatorSequence(_ database: isolated SQLiteDatabase) throws -> UInt64 {
        let rows = try database.query("SELECT seq FROM sqlite_sequence WHERE name = ?", bindings: [.text("runtime_semantic_events")])
        guard let row = rows.first else { return 0 }
        return try uint64(row, "seq")
    }

    static func requireCanonicalRevision(_ request: CanonicalRuntimeSemanticEventAppendRequest, database: isolated SQLiteDatabase) throws {
        let rows = try database.query(
            "SELECT revision FROM runtime_aggregates WHERE aggregate_kind = ? AND aggregate_id = ? LIMIT 2",
            bindings: [.text(request.aggregate.kind.rawValue), .text(request.aggregate.id.rawValue)]
        )
        guard rows.count == 1,
              try revisionUInt64(rows[0], "revision") == request.canonicalAggregateRevision else {
            throw CanonicalRuntimeSemanticEventStoreError.aggregateRevisionMismatch
        }
    }

    static func requireCausation(
        _ eventID: RuntimeEventID?, correlationID: RuntimeCorrelationID, before sequence: UInt64,
        chain: [CanonicalRuntimeSemanticEventInspection]
    ) throws {
        guard let eventID else { return }
        let matches = chain.compactMap { inspection -> RuntimeSemanticEventLineage? in
            guard case let .supported(record) = inspection, record.lineage.eventID == eventID else { return nil }
            return record.lineage
        }
        guard matches.count == 1, matches[0].sequence < sequence,
              matches[0].correlationID == correlationID else {
            throw CanonicalRuntimeSemanticEventStoreError.invalidCausation
        }
    }

    static func quarantine(
        request: CanonicalRuntimeSemanticEventAppendRequest,
        sourceEventSequence: UInt64?,
        reason: CanonicalRuntimeSemanticEventQuarantineReason,
        database: isolated SQLiteDatabase
    ) throws -> CanonicalRuntimeSemanticEventQuarantineRecord {
        try quarantine(
            sourceEventID: request.eventID.rawValue, sourceEventSequence: sourceEventSequence,
            reason: reason, bytes: request.canonicalBytes, retention: request.sourceRetention,
            observedAtMilliseconds: try RuntimeSemanticEventHashing.milliseconds(request.occurredAt), database: database
        )
    }

    static func quarantine(
        sourceEventID: String?, sourceEventSequence: UInt64?,
        reason: CanonicalRuntimeSemanticEventQuarantineReason,
        bytes: Data, retention: RuntimeSemanticEventSourceRetention,
        observedAtMilliseconds: Int64, database: isolated SQLiteDatabase
    ) throws -> CanonicalRuntimeSemanticEventQuarantineRecord {
        if let sourceEventSequence {
            guard sourceEventSequence <= UInt64(Int64.max) else {
                throw CanonicalRuntimeSemanticEventStoreError.invalidSequence
            }
        }
        let digest = SHA256Digest.digest(bytes)
        let byteCount = UInt64(bytes.count)
        let key = SHA256Digest.digest(Data("\(digest.hexadecimal):\(byteCount)".utf8))
        let inline: Data
        switch retention {
        case let .inline(value):
            guard value == bytes, value.count <= CanonicalRuntimeSemanticEventSchemaPlan.maximumInlineQuarantineBytes else {
                throw CanonicalRuntimeSemanticEventStoreError.oversizeQuarantineDeferredUntilBlobAuthority
            }
            inline = value
        }
        try database.execute(
            """
            INSERT OR IGNORE INTO runtime_semantic_event_quarantine(
                quarantine_key, source_event_id, source_event_sequence, reason,
                source_digest, source_byte_count, inline_source_bytes, observed_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(key.hexadecimal), sourceEventID.map(SQLiteBinding.text) ?? .null,
                sourceEventSequence.map { .integer(Int64($0)) } ?? .null, .text(reason.rawValue),
                .text(digest.hexadecimal), .integer(Int64(byteCount)), .blob(inline),
                .integer(observedAtMilliseconds),
            ]
        )
        let rows = try database.query(
            """
            SELECT quarantine_sequence, source_event_id, source_event_sequence,
                   reason, source_digest, source_byte_count, inline_source_bytes,
                   observed_at_ms
            FROM runtime_semantic_event_quarantine WHERE quarantine_key = ? LIMIT 1
            """,
            bindings: [.text(key.hexadecimal)]
        )
        guard let row = rows.first else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }
        return try quarantineRecord(row)
    }

    static func quarantineRecord(_ row: SQLiteRow) throws -> CanonicalRuntimeSemanticEventQuarantineRecord {
        guard let reason = CanonicalRuntimeSemanticEventQuarantineReason(rawValue: try text(row, "reason")) else {
            throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow
        }
        let eventSequence = try optionalInt64(row, "source_event_sequence")
        let byteCount = try int64(row, "source_byte_count")
        guard byteCount >= 0 else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }
        return CanonicalRuntimeSemanticEventQuarantineRecord(
            sequence: try int64(row, "quarantine_sequence"),
            sourceEventID: try optionalText(row, "source_event_id"),
            sourceEventSequence: try eventSequence.map { guard $0 > 0 else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }; return UInt64($0) },
            reason: reason, sourceDigest: try SHA256Digest(hexadecimal: text(row, "source_digest")),
            sourceByteCount: UInt64(byteCount), inlineSourceBytes: try blob(row, "inline_source_bytes"),
            observedAt: Date(timeIntervalSince1970: Double(try int64(row, "observed_at_ms")) / 1_000)
        )
    }

    static func aggregateKind(_ row: SQLiteRow, _ name: String) throws -> RuntimeSemanticAggregateKind {
        guard let value = RuntimeSemanticAggregateKind(rawValue: try text(row, name)) else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }
        return value
    }
    static func uint64(_ row: SQLiteRow, _ name: String) throws -> UInt64 { let value = try int64(row, name); guard value > 0 else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }; return UInt64(value) }
    static func revisionUInt64(_ row: SQLiteRow, _ name: String) throws -> UInt64 { let value = try int64(row, name); guard value >= 0 else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }; return UInt64(value) }
    static func int(_ row: SQLiteRow, _ name: String) throws -> Int { guard let value = Int(exactly: try int64(row, name)) else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }; return value }
    static func int64(_ row: SQLiteRow, _ name: String) throws -> Int64 { guard let value = row.value(named: name), case let .integer(result) = value else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }; return result }
    static func optionalInt64(_ row: SQLiteRow, _ name: String) throws -> Int64? { guard let value = row.value(named: name) else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }; switch value { case .null: return nil; case let .integer(v): return v; default: throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow } }
    static func text(_ row: SQLiteRow, _ name: String) throws -> String { guard let value = row.value(named: name), case let .text(result) = value else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }; return result }
    static func optionalText(_ row: SQLiteRow, _ name: String) throws -> String? { guard let value = row.value(named: name) else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }; switch value { case .null: return nil; case let .text(v): return v; default: throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow } }
    static func blob(_ row: SQLiteRow, _ name: String) throws -> Data { guard let value = row.value(named: name), case let .blob(result) = value else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }; return result }
    static func optionalDigest(_ row: SQLiteRow, _ name: String) throws -> SHA256Digest? { try optionalText(row, name).map(SHA256Digest.init(hexadecimal:)) }
}

private struct InspectionFailure: Error {
    let reason: CanonicalRuntimeSemanticEventQuarantineReason
    init(_ reason: CanonicalRuntimeSemanticEventQuarantineReason) { self.reason = reason }
}
