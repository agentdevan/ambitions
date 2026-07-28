import AmbitionsRuntimeSQLite
import Foundation

let canonicalCommandSemanticFingerprintCodecVersion = 1
let canonicalIdempotencyClaimVersion = 1
let canonicalIdempotencyFinalResultVersion = 1

struct CanonicalCommandSemanticFingerprint: Sendable, Equatable, Hashable {
    let codecVersion: Int
    let digestSHA256: String

    init(
        codecVersion: Int = canonicalCommandSemanticFingerprintCodecVersion,
        digestSHA256: String
    ) throws {
        guard codecVersion == canonicalCommandSemanticFingerprintCodecVersion else {
            throw CanonicalRuntimeTransactionError.unsupportedFingerprintCodec(
                maximumSupported: canonicalCommandSemanticFingerprintCodecVersion,
                actual: codecVersion
            )
        }
        guard RuntimeStoreManifestCodec.isSHA256Hex(digestSHA256) else {
            throw CanonicalRuntimeTransactionError.malformedInput
        }
        self.codecVersion = codecVersion
        self.digestSHA256 = digestSHA256
    }

    static func semanticV2(command: AmbitionsCommand) throws -> Self {
        struct SemanticCommand: Encodable {
            let schemaVersion: Int
            let source: AmbitionsCommandSource
            let actor: AmbitionsCommandActor
            let localOnly: Bool
            let privacy: EventLedgerPrivacyClassification
            let expectedRevision: RuntimeExpectedRevision
            let payload: RuntimeCommandPayload
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let bytes = try encoder.encode(SemanticCommand(
            schemaVersion: runtimeCommandSchemaVersion,
            source: command.source,
            actor: command.actor,
            localOnly: command.localOnly,
            privacy: command.privacy,
            expectedRevision: command.expectedRevision,
            payload: command.typedPayload
        ))
        return try Self(
            digestSHA256: LocalRuntimeStorageChecksum.sha256Hex(for: bytes)
        )
    }
}

struct CanonicalIdempotencyClaimIdentity: Sendable, Equatable, Hashable {
    let scope: String
    let key: String
    let ownerID: String

    init(scope: String, key: String, ownerID: String) throws {
        guard Self.isValidIdentity(scope),
              Self.isValidIdentity(key),
              Self.isValidIdentity(ownerID) else {
            throw CanonicalRuntimeTransactionError.malformedInput
        }
        self.scope = scope
        self.key = key
        self.ownerID = ownerID
    }

    fileprivate static func isValidIdentity(_ value: String) -> Bool {
        value.isEmpty == false &&
            value.utf8.count <= 1_024 &&
            value == value.trimmingCharacters(in: .whitespacesAndNewlines) &&
            value == value.precomposedStringWithCanonicalMapping &&
            value.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false
    }
}

struct CanonicalIdempotencyClaimRequest: Sendable, Equatable {
    let scope: String
    let key: String
    let commandID: String
    let fingerprint: CanonicalCommandSemanticFingerprint
    let ownerID: String
    let claimedAtMilliseconds: Int64
    let claimIdentity: CanonicalIdempotencyClaimIdentity

    init(
        scope: String,
        key: String,
        commandID: String,
        fingerprint: CanonicalCommandSemanticFingerprint,
        ownerID: String,
        claimedAtMilliseconds: Int64
    ) throws {
        guard CanonicalIdempotencyClaimIdentity.isValidIdentity(commandID),
              claimedAtMilliseconds >= 0 else {
            throw CanonicalRuntimeTransactionError.malformedInput
        }
        let claimIdentity = try CanonicalIdempotencyClaimIdentity(
            scope: scope,
            key: key,
            ownerID: ownerID
        )
        self.scope = scope
        self.key = key
        self.commandID = commandID
        self.fingerprint = fingerprint
        self.ownerID = ownerID
        self.claimedAtMilliseconds = claimedAtMilliseconds
        self.claimIdentity = claimIdentity
    }
}

struct CanonicalIdempotencyClaim: Sendable, Equatable {
    let identity: CanonicalIdempotencyClaimIdentity
    let commandID: String
    let fingerprint: CanonicalCommandSemanticFingerprint
    let claimedAtMilliseconds: Int64
}

struct CanonicalIdempotencyFinalization: Sendable, Equatable {
    let ownerID: String
    let resultVersion: Int
    let resultPayload: Data
    let finalizedAtMilliseconds: Int64

    init(
        ownerID: String,
        resultVersion: Int = canonicalIdempotencyFinalResultVersion,
        resultPayload: Data,
        finalizedAtMilliseconds: Int64
    ) throws {
        guard CanonicalIdempotencyClaimIdentity.isValidIdentity(ownerID),
              resultVersion == canonicalIdempotencyFinalResultVersion,
              resultPayload.count <= Int(CanonicalRuntimeStore.maximumSQLiteValueBytes),
              finalizedAtMilliseconds >= 0 else {
            throw CanonicalRuntimeTransactionError.malformedInput
        }
        self.ownerID = ownerID
        self.resultVersion = resultVersion
        self.resultPayload = resultPayload
        self.finalizedAtMilliseconds = finalizedAtMilliseconds
    }
}

struct CanonicalIdempotencyFinalResult: Sendable, Equatable {
    let version: Int
    let payload: Data
    let payloadChecksumSHA256: String
    let finalizedAtMilliseconds: Int64
}

enum CanonicalIdempotencyClaimOutcome: Sendable, Equatable {
    case claimed(CanonicalIdempotencyClaim)
    case replay(CanonicalIdempotencyFinalResult)
}

struct CanonicalAggregateKey: Sendable, Equatable, Hashable, Comparable {
    let kind: String
    let id: String

    init(kind: String, id: String) throws {
        guard CanonicalIdempotencyClaimIdentity.isValidIdentity(kind),
              CanonicalIdempotencyClaimIdentity.isValidIdentity(id) else {
            throw CanonicalRuntimeTransactionError.malformedInput
        }
        self.kind = kind
        self.id = id
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.kind, lhs.id) < (rhs.kind, rhs.id)
    }
}

struct CanonicalAggregateCASMutation: Sendable, Equatable {
    let key: CanonicalAggregateKey
    let expectedRevision: RuntimeExpectedRevision
    let payloadVersion: Int
    let payload: Data
    let payloadChecksumSHA256: String

    init(
        key: CanonicalAggregateKey,
        expectedRevision: RuntimeExpectedRevision,
        payloadVersion: Int,
        payload: Data
    ) throws {
        guard payloadVersion > 0,
              payload.count <= Int(CanonicalRuntimeStore.maximumSQLiteValueBytes) else {
            throw CanonicalRuntimeTransactionError.malformedInput
        }
        self.key = key
        self.expectedRevision = expectedRevision
        self.payloadVersion = payloadVersion
        self.payload = payload
        payloadChecksumSHA256 = LocalRuntimeStorageChecksum.sha256Hex(for: payload)
    }
}

struct CanonicalAggregateCASResult: Sendable, Equatable {
    let key: CanonicalAggregateKey
    let revision: UInt64
}

struct CanonicalRevisionConflictEvidence: Sendable, Equatable {
    let sortedMutationIndex: Int
    let expected: RuntimeExpectedRevision
    let observedRevision: UInt64?
}

enum CanonicalRuntimeTransactionError: Error, Sendable, Equatable {
    case malformedInput
    case idempotencyCollision
    case claimOwnershipMismatch
    case corruptStoredRecord
    case unsupportedFingerprintCodec(maximumSupported: Int, actual: Int)
    case unsupportedFinalResultVersion(maximumSupported: Int, actual: Int)
    case duplicateAggregateKey(sortedMutationIndex: Int)
    case revisionConflict(CanonicalRevisionConflictEvidence)
}

extension CanonicalRuntimeTransactionError: CustomStringConvertible, LocalizedError {
    var description: String {
        switch self {
        case .malformedInput:
            "Canonical runtime transaction input is malformed."
        case .idempotencyCollision:
            "Canonical idempotency identity is already bound to different semantics."
        case .claimOwnershipMismatch:
            "Canonical idempotency claim ownership does not match."
        case .corruptStoredRecord:
            "Canonical runtime transaction authority is corrupt."
        case let .unsupportedFingerprintCodec(maximumSupported, actual):
            "Canonical fingerprint codec is unsupported (maximum \(maximumSupported), actual \(actual))."
        case let .unsupportedFinalResultVersion(maximumSupported, actual):
            "Canonical final-result version is unsupported (maximum \(maximumSupported), actual \(actual))."
        case let .duplicateAggregateKey(sortedMutationIndex):
            "Canonical aggregate mutation is duplicated at sorted index \(sortedMutationIndex)."
        case let .revisionConflict(evidence):
            "Canonical aggregate revision conflict at sorted index \(evidence.sortedMutationIndex)."
        }
    }

    var errorDescription: String? { description }
}

extension CanonicalRuntimeStore {
    /// Transaction-local primitive for the future T09 authority transaction.
    /// This must not be exposed as a standalone actor operation because a
    /// durable pending claim is not authority.
    static func claimIdempotency(
        in database: isolated SQLiteDatabase,
        request: CanonicalIdempotencyClaimRequest
    ) throws -> CanonicalIdempotencyClaimOutcome {
        if let stored = try storedIdempotency(
            in: database,
            scope: request.scope,
            key: request.key
        ) {
            guard stored.fingerprint.codecVersion == request.fingerprint.codecVersion,
                  stored.fingerprint.digestSHA256 == request.fingerprint.digestSHA256 else {
                throw CanonicalRuntimeTransactionError.idempotencyCollision
            }
            if let finalResult = stored.finalResult {
                return .replay(finalResult)
            }
            guard stored.claim.identity.ownerID == request.ownerID else {
                throw CanonicalRuntimeTransactionError.claimOwnershipMismatch
            }
            return .claimed(stored.claim)
        }

        let commandRows = try database.query(
            """
            SELECT 1 AS present
            FROM runtime_command_idempotency
            WHERE command_id = ?
            LIMIT 2
            """,
            bindings: [.text(request.commandID)]
        )
        guard commandRows.isEmpty else {
            throw CanonicalRuntimeTransactionError.idempotencyCollision
        }

        try database.execute(
            """
            INSERT INTO runtime_command_idempotency(
                scope, idempotency_key, command_id,
                command_fingerprint, claim_version, claim_payload, claimed_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(request.scope),
                .text(request.key),
                .text(request.commandID),
                .text(request.fingerprint.digestSHA256),
                .integer(Int64(canonicalIdempotencyClaimVersion)),
                .blob(try encodedClaimPayload(request)),
                .integer(request.claimedAtMilliseconds),
            ]
        )
        return .claimed(CanonicalIdempotencyClaim(
            identity: request.claimIdentity,
            commandID: request.commandID,
            fingerprint: request.fingerprint,
            claimedAtMilliseconds: request.claimedAtMilliseconds
        ))
    }

    static func finalizeIdempotency(
        in database: isolated SQLiteDatabase,
        identity: CanonicalIdempotencyClaimIdentity,
        finalization: CanonicalIdempotencyFinalization
    ) throws -> CanonicalIdempotencyFinalResult {
        guard identity.ownerID == finalization.ownerID,
              let stored = try storedIdempotency(
                in: database,
                scope: identity.scope,
                key: identity.key
              ) else {
            throw CanonicalRuntimeTransactionError.claimOwnershipMismatch
        }
        guard stored.claim.identity.ownerID == identity.ownerID else {
            throw CanonicalRuntimeTransactionError.claimOwnershipMismatch
        }
        if let original = stored.finalResult {
            return original
        }
        guard finalization.finalizedAtMilliseconds >= stored.claim.claimedAtMilliseconds else {
            throw CanonicalRuntimeTransactionError.malformedInput
        }

        let checksum = LocalRuntimeStorageChecksum.sha256Hex(
            for: finalization.resultPayload
        )
        let result = try database.execute(
            """
            UPDATE runtime_command_idempotency
            SET final_result_version = ?,
                final_result_payload = ?,
                final_result_checksum = ?,
                finalized_at_ms = ?
            WHERE scope = ? AND idempotency_key = ?
              AND final_result_version IS NULL
            """,
            bindings: [
                .integer(Int64(finalization.resultVersion)),
                .blob(finalization.resultPayload),
                .text(checksum),
                .integer(finalization.finalizedAtMilliseconds),
                .text(identity.scope),
                .text(identity.key),
            ]
        )
        guard result.changedRowCount == 1 else {
            throw CanonicalRuntimeTransactionError.claimOwnershipMismatch
        }
        return CanonicalIdempotencyFinalResult(
            version: finalization.resultVersion,
            payload: finalization.resultPayload,
            payloadChecksumSHA256: checksum,
            finalizedAtMilliseconds: finalization.finalizedAtMilliseconds
        )
    }

    static func applyAggregateCAS(
        in database: isolated SQLiteDatabase,
        mutations: [CanonicalAggregateCASMutation]
    ) throws -> [CanonicalAggregateCASResult] {
        let sorted = mutations.sorted { $0.key < $1.key }
        for index in sorted.indices.dropFirst()
        where sorted[index - 1].key == sorted[index].key {
            throw CanonicalRuntimeTransactionError.duplicateAggregateKey(
                sortedMutationIndex: index
            )
        }

        var results: [CanonicalAggregateCASResult] = []
        results.reserveCapacity(sorted.count)
        for (index, mutation) in sorted.enumerated() {
            let observed = try observedAggregateRevision(
                in: database,
                key: mutation.key
            )
            switch mutation.expectedRevision {
            case .absent:
                guard observed == nil else {
                    throw revisionConflict(
                        index: index,
                        expected: mutation.expectedRevision,
                        observed: observed
                    )
                }
                try database.execute(
                    """
                    INSERT INTO runtime_aggregates(
                        aggregate_kind, aggregate_id, revision,
                        payload_version, payload, payload_checksum
                    ) VALUES (?, ?, 0, ?, ?, ?)
                    """,
                    bindings: [
                        .text(mutation.key.kind),
                        .text(mutation.key.id),
                        .integer(Int64(mutation.payloadVersion)),
                        .blob(mutation.payload),
                        .text(mutation.payloadChecksumSHA256),
                    ]
                )
                results.append(CanonicalAggregateCASResult(
                    key: mutation.key,
                    revision: 0
                ))
            case let .exact(expected):
                guard observed == expected,
                      expected < UInt64(Int64.max) else {
                    throw revisionConflict(
                        index: index,
                        expected: mutation.expectedRevision,
                        observed: observed
                    )
                }
                let next = expected + 1
                let update = try database.execute(
                    """
                    UPDATE runtime_aggregates
                    SET revision = ?, payload_version = ?,
                        payload = ?, payload_checksum = ?
                    WHERE aggregate_kind = ? AND aggregate_id = ?
                      AND revision = ?
                    """,
                    bindings: [
                        .integer(Int64(next)),
                        .integer(Int64(mutation.payloadVersion)),
                        .blob(mutation.payload),
                        .text(mutation.payloadChecksumSHA256),
                        .text(mutation.key.kind),
                        .text(mutation.key.id),
                        .integer(Int64(expected)),
                    ]
                )
                guard update.changedRowCount == 1 else {
                    let current = try observedAggregateRevision(
                        in: database,
                        key: mutation.key
                    )
                    throw revisionConflict(
                        index: index,
                        expected: mutation.expectedRevision,
                        observed: current
                    )
                }
                results.append(CanonicalAggregateCASResult(
                    key: mutation.key,
                    revision: next
                ))
            }
        }
        return results
    }
}

private extension CanonicalRuntimeStore {
    struct CanonicalIdempotencyClaimPayload: Codable {
        let fingerprintCodecVersion: Int
        let ownerID: String
    }

    struct StoredCanonicalIdempotency {
        let claim: CanonicalIdempotencyClaim
        let fingerprint: CanonicalCommandSemanticFingerprint
        let finalResult: CanonicalIdempotencyFinalResult?
    }

    static func storedIdempotency(
        in database: isolated SQLiteDatabase,
        scope: String,
        key: String
    ) throws -> StoredCanonicalIdempotency? {
        let rows = try database.query(
            """
            SELECT command_id, command_fingerprint, claim_version,
                   claim_payload, claimed_at_ms,
                   final_result_version, final_result_payload,
                   final_result_checksum, finalized_at_ms
            FROM runtime_command_idempotency
            WHERE scope = ? AND idempotency_key = ?
            LIMIT 2
            """,
            bindings: [.text(scope), .text(key)]
        )
        guard rows.count <= 1 else {
            throw CanonicalRuntimeTransactionError.corruptStoredRecord
        }
        guard let row = rows.first else { return nil }
        guard try requiredInt(row, "claim_version") == canonicalIdempotencyClaimVersion,
              let payload = try? JSONDecoder().decode(
                  CanonicalIdempotencyClaimPayload.self,
                  from: requiredBlob(row, "claim_payload")
              ) else {
            throw CanonicalRuntimeTransactionError.corruptStoredRecord
        }
        let codecVersion = payload.fingerprintCodecVersion
        guard codecVersion <= canonicalCommandSemanticFingerprintCodecVersion else {
            throw CanonicalRuntimeTransactionError.unsupportedFingerprintCodec(
                maximumSupported: canonicalCommandSemanticFingerprintCodecVersion,
                actual: codecVersion
            )
        }
        guard codecVersion == canonicalCommandSemanticFingerprintCodecVersion,
              let fingerprint = try? CanonicalCommandSemanticFingerprint(
                  codecVersion: codecVersion,
                  digestSHA256: requiredText(row, "command_fingerprint")
              ),
              let identity = try? CanonicalIdempotencyClaimIdentity(
                  scope: scope,
                  key: key,
                  ownerID: payload.ownerID
              ) else {
            throw CanonicalRuntimeTransactionError.corruptStoredRecord
        }
        let claim = CanonicalIdempotencyClaim(
            identity: identity,
            commandID: try requiredText(row, "command_id"),
            fingerprint: fingerprint,
            claimedAtMilliseconds: try requiredInt64(row, "claimed_at_ms")
        )
        let finalResult: CanonicalIdempotencyFinalResult?
        if row.value(named: "final_result_version") == .null {
            guard try allNull(
                row,
                [
                    "final_result_version", "final_result_payload",
                    "final_result_checksum", "finalized_at_ms",
                ]
            ) else {
                throw CanonicalRuntimeTransactionError.corruptStoredRecord
            }
            finalResult = nil
        } else {
            let version = try requiredInt(row, "final_result_version")
            guard version <= canonicalIdempotencyFinalResultVersion else {
                throw CanonicalRuntimeTransactionError.unsupportedFinalResultVersion(
                    maximumSupported: canonicalIdempotencyFinalResultVersion,
                    actual: version
                )
            }
            guard version == canonicalIdempotencyFinalResultVersion else {
                throw CanonicalRuntimeTransactionError.corruptStoredRecord
            }
            let payload = try requiredBlob(row, "final_result_payload")
            let checksum = try requiredText(row, "final_result_checksum")
            guard RuntimeStoreManifestCodec.isSHA256Hex(checksum),
                  checksum == LocalRuntimeStorageChecksum.sha256Hex(for: payload) else {
                throw CanonicalRuntimeTransactionError.corruptStoredRecord
            }
            let finalizedAt = try requiredInt64(row, "finalized_at_ms")
            guard finalizedAt >= claim.claimedAtMilliseconds else {
                throw CanonicalRuntimeTransactionError.corruptStoredRecord
            }
            finalResult = CanonicalIdempotencyFinalResult(
                version: version,
                payload: payload,
                payloadChecksumSHA256: checksum,
                finalizedAtMilliseconds: finalizedAt
            )
        }
        return StoredCanonicalIdempotency(
            claim: claim,
            fingerprint: fingerprint,
            finalResult: finalResult
        )
    }

    static func encodedClaimPayload(
        _ request: CanonicalIdempotencyClaimRequest
    ) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        guard let payload = try? encoder.encode(CanonicalIdempotencyClaimPayload(
            fingerprintCodecVersion: request.fingerprint.codecVersion,
            ownerID: request.ownerID
        )) else {
            throw CanonicalRuntimeTransactionError.malformedInput
        }
        return payload
    }

    static func observedAggregateRevision(
        in database: isolated SQLiteDatabase,
        key: CanonicalAggregateKey
    ) throws -> UInt64? {
        let rows = try database.query(
            """
            SELECT revision FROM runtime_aggregates
            WHERE aggregate_kind = ? AND aggregate_id = ?
            LIMIT 2
            """,
            bindings: [.text(key.kind), .text(key.id)]
        )
        guard rows.count <= 1 else {
            throw CanonicalRuntimeTransactionError.corruptStoredRecord
        }
        guard let row = rows.first else { return nil }
        let value = try requiredInt64(row, "revision")
        guard value >= 0 else {
            throw CanonicalRuntimeTransactionError.corruptStoredRecord
        }
        return UInt64(value)
    }

    static func revisionConflict(
        index: Int,
        expected: RuntimeExpectedRevision,
        observed: UInt64?
    ) -> CanonicalRuntimeTransactionError {
        .revisionConflict(CanonicalRevisionConflictEvidence(
            sortedMutationIndex: index,
            expected: expected,
            observedRevision: observed
        ))
    }

    static func requiredText(_ row: SQLiteRow, _ name: String) throws -> String {
        guard let value = row.value(named: name),
              case let .text(text) = value,
              CanonicalIdempotencyClaimIdentity.isValidIdentity(text) else {
            throw CanonicalRuntimeTransactionError.corruptStoredRecord
        }
        return text
    }

    static func requiredBlob(_ row: SQLiteRow, _ name: String) throws -> Data {
        guard let value = row.value(named: name), case let .blob(data) = value else {
            throw CanonicalRuntimeTransactionError.corruptStoredRecord
        }
        return data
    }

    static func requiredInt64(_ row: SQLiteRow, _ name: String) throws -> Int64 {
        guard let value = row.value(named: name), case let .integer(number) = value else {
            throw CanonicalRuntimeTransactionError.corruptStoredRecord
        }
        return number
    }

    static func requiredInt(_ row: SQLiteRow, _ name: String) throws -> Int {
        let value = try requiredInt64(row, name)
        guard let result = Int(exactly: value) else {
            throw CanonicalRuntimeTransactionError.corruptStoredRecord
        }
        return result
    }

    static func allNull(_ row: SQLiteRow, _ names: [String]) throws -> Bool {
        try names.allSatisfy { name in
            guard let value = row.value(named: name) else {
                throw CanonicalRuntimeTransactionError.corruptStoredRecord
            }
            return value == .null
        }
    }
}
