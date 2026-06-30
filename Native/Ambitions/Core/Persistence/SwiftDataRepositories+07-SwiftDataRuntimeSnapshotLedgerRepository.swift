import AmbitionsDesignSystem
import Foundation
import SwiftData

struct SwiftDataRuntimeSnapshotLedgerRepository: RuntimeSnapshotLedgerRepository {
    let store: AmbitionsPersistenceStore

    struct RuntimeSnapshotLedgerValidationCandidate: Sendable {
        let envelope: RuntimeSnapshotLedgerEnvelope
        let storedChecksum: String
    }

    func append(_ envelope: RuntimeSnapshotLedgerEnvelope) async throws {
        try await store.write { context in
            if let persisted = try context.fetch(FetchDescriptor<RuntimeSnapshotLedgerRecord>())
                .first(where: { $0.id == envelope.id }) {
                try RepositoryMapping.apply(envelope, to: persisted)
            } else {
                context.insert(try RepositoryMapping.runtimeSnapshotLedgerRecord(from: envelope))
            }
        }
    }

    func fetchRecent(limit: Int) async throws -> [RuntimeSnapshotLedgerEnvelope] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<RuntimeSnapshotLedgerRecord>())
                .sorted {
                    if $0.generatedAt != $1.generatedAt {
                        return $0.generatedAt > $1.generatedAt
                    }
                    return $0.id > $1.id
                }
                .prefix(max(0, limit))
                .compactMap { try? RepositoryMapping.runtimeSnapshotLedgerEnvelope(from: $0) }
        }
    }

    func fetchEnvelope(id: String) async throws -> RuntimeSnapshotLedgerEnvelope? {
        try await store.read { context in
            try context.fetch(FetchDescriptor<RuntimeSnapshotLedgerRecord>())
                .first(where: { $0.id == id })
                .flatMap { try? RepositoryMapping.runtimeSnapshotLedgerEnvelope(from: $0) }
        }
    }

    func fetchEnvelopes(containing reference: RuntimeSnapshotLedgerArtifactReference) async throws -> [RuntimeSnapshotLedgerEnvelope] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<RuntimeSnapshotLedgerRecord>())
                .compactMap { try? RepositoryMapping.runtimeSnapshotLedgerEnvelope(from: $0) }
                .filter { envelope in
                    envelope.id == reference.envelopeID ||
                        envelope.references(for: reference.kind).contains { $0.artifactID == reference.artifactID }
                }
        }
    }

    func validate(reference: RuntimeSnapshotLedgerArtifactReference) async throws -> RuntimeSnapshotLedgerReplayValidationReport {
        let matches: [RuntimeSnapshotLedgerValidationCandidate] = try await store.read { context in
            try context.fetch(FetchDescriptor<RuntimeSnapshotLedgerRecord>())
                .compactMap { record in
                    guard let envelope = try? RepositoryMapping.runtimeSnapshotLedgerEnvelope(from: record) else {
                        return nil
                    }
                    guard record.id == reference.envelopeID || envelope.references(for: reference.kind).contains(where: { $0.artifactID == reference.artifactID }) else {
                        return nil
                    }
                    return RuntimeSnapshotLedgerValidationCandidate(
                        envelope: envelope,
                        storedChecksum: record.checksum
                    )
                }
        }

        guard matches.isEmpty == false else {
            return RuntimeSnapshotLedgerReplayValidationReport(
                reference: reference,
                outcome: .missingEnvelope,
                envelopeID: nil,
                envelopeSchemaVersion: nil,
                compatibilityStatus: nil,
                matchedEnvelopeCount: 0,
                observedChecksum: nil,
                expectedChecksum: reference.envelopeChecksum,
                message: "No runtime snapshot envelope matched reference \(reference.artifactID)."
            )
        }
        guard matches.count == 1 else {
            return RuntimeSnapshotLedgerReplayValidationReport(
                reference: reference,
                outcome: .ambiguousEnvelope,
                envelopeID: nil,
                envelopeSchemaVersion: nil,
                compatibilityStatus: nil,
                matchedEnvelopeCount: matches.count,
                observedChecksum: matches.map(\.envelope.checksum).sorted().joined(separator: ","),
                expectedChecksum: reference.envelopeChecksum,
                message: "Reference \(reference.artifactID) matched \(matches.count) runtime snapshot envelopes."
            )
        }

        let match = matches[0]
        guard match.storedChecksum == match.envelope.checksum else {
            return RuntimeSnapshotLedgerReplayValidationReport(
                reference: reference,
                outcome: .checksumMismatch,
                envelopeID: match.envelope.id,
                envelopeSchemaVersion: match.envelope.schemaVersion,
                compatibilityStatus: match.envelope.compatibilityStatus,
                matchedEnvelopeCount: 1,
                observedChecksum: match.envelope.checksum,
                expectedChecksum: match.storedChecksum,
                message: "Stored checksum for envelope \(match.envelope.id) does not match the decoded envelope."
            )
        }

        return match.envelope.validate(reference: reference)
    }

    func validateReceipt(referenceID: String, envelopeID: String?, checksum: String?) async throws -> RuntimeSnapshotLedgerReplayValidationReport {
        try await validate(reference: RuntimeSnapshotLedgerArtifactReference(kind: .receipt, artifactID: referenceID, envelopeID: envelopeID ?? "", envelopeChecksum: checksum))
    }

    func validateProof(referenceID: String, envelopeID: String?, checksum: String?) async throws -> RuntimeSnapshotLedgerReplayValidationReport {
        try await validate(reference: RuntimeSnapshotLedgerArtifactReference(kind: .proofInput, artifactID: referenceID, envelopeID: envelopeID ?? "", envelopeChecksum: checksum))
    }

    func validateReplayTrace(referenceID: String, envelopeID: String?, checksum: String?) async throws -> RuntimeSnapshotLedgerReplayValidationReport {
        try await validate(reference: RuntimeSnapshotLedgerArtifactReference(kind: .replayTrace, artifactID: referenceID, envelopeID: envelopeID ?? "", envelopeChecksum: checksum))
    }
}

struct SwiftDataAmbitionsCommandExecutionRecordRepository: AmbitionsCommandExecutionRecordRepository {
    let store: AmbitionsPersistenceStore

    func append(_ record: AmbitionsCommandExecutionRecord) async throws {
        try await store.write { context in
            if let persisted = try context.fetch(FetchDescriptor<CommandExecutionRecord>())
                .first(where: { $0.id == record.id || $0.commandID == record.command.id }) {
                try RepositoryMapping.apply(record, to: persisted)
            } else {
                context.insert(try RepositoryMapping.commandExecutionRecord(from: record))
            }
        }
    }

    func fetchRecent(limit: Int) async throws -> [AmbitionsCommandExecutionRecord] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<CommandExecutionRecord>())
                .sorted {
                    let lhsDate = PersistedTemporalValue.dateKey(primary: $0.recordedAtDate, rawValue: $0.recordedAt)
                    let rhsDate = PersistedTemporalValue.dateKey(primary: $1.recordedAtDate, rawValue: $1.recordedAt)
                    if lhsDate == rhsDate {
                        return $0.id > $1.id
                    }
                    return lhsDate > rhsDate
                }
                .prefix(max(0, limit))
                .map(RepositoryMapping.commandExecutionRecord(from:))
        }
    }

    func fetchRecord(commandID: String) async throws -> AmbitionsCommandExecutionRecord? {
        try await store.read { context in
            try context.fetch(FetchDescriptor<CommandExecutionRecord>())
                .first(where: { $0.commandID == commandID })
                .map(RepositoryMapping.commandExecutionRecord(from:))
        }
    }
}
