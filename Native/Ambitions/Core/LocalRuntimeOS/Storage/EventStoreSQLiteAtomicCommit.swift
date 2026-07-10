import Foundation
import SQLite3

struct RuntimeSQLiteAuthorityCommit: Sendable, Equatable {
    let disposition: RuntimeTransactionCommitDisposition
    let receipt: RuntimeCommitReceipt
}

struct RuntimeOutboxIntent: Sendable, Codable, Equatable, Hashable {
    let id: String
    let kind: String
    let payload: Data
}

struct RuntimeEventQuarantineRecord: Sendable, Codable, Equatable, Hashable {
    let id: String
    let typeID: String
    let schemaVersion: Int
    let reason: String
}

enum RuntimeSQLiteAuthorityError: Error, Equatable {
    case semanticEventRequired(commandID: String)
}

extension EventStoreSQLite {
    func commitAuthority(
        transaction: RuntimeTransaction,
        semanticEvent: RuntimeDomainEvent?,
        outboxIntents: [RuntimeOutboxIntent] = [],
        committedAt: String
    ) throws -> RuntimeSQLiteAuthorityCommit {
        let database = try openDatabase()
        try createSchema(database)
        try createAuthoritySchema(database)

        return try database.transaction {
            if let receipt = try authorityReceipt(commandID: transaction.commandID, database: database) {
                return RuntimeSQLiteAuthorityCommit(disposition: .replayedExistingReceipt, receipt: receipt)
            }

            if Self.requiresSemanticEvent(transaction.mutationPlan.command.kind), semanticEvent == nil {
                throw RuntimeSQLiteAuthorityError.semanticEventRequired(commandID: transaction.commandID)
            }
            var previous = try latestEnvelope(database)
            if let semanticEvent {
                let event = RuntimeEvent(
                    commandID: transaction.commandID,
                    actor: transaction.mutationPlan.command.actor,
                    source: transaction.mutationPlan.command.source,
                    target: transaction.mutationPlan.command.target,
                    privacy: transaction.mutationPlan.command.privacy,
                    localOnly: true,
                    occurredAt: committedAt,
                    payload: .domainMutation(RuntimeDomainEventRecord(semanticEvent))
                )
                let envelope = try RuntimeEventEnvelope.make(
                    sequence: (previous?.sequence ?? 0) + 1,
                    previousChecksum: previous?.checksum,
                    event: event,
                    deviceID: deviceID
                )
                try insert(envelope, database: database)
                previous = envelope
            }

            let eventEnvelope = try RuntimeEventEnvelope.make(
                sequence: (previous?.sequence ?? 0) + 1,
                previousChecksum: previous?.checksum,
                event: transaction.writeSet.event,
                deviceID: deviceID
            )
            try insert(eventEnvelope, database: database)
            let cursors = Dictionary(uniqueKeysWithValues: transaction.mutationPlan.expectedProjectionIDs.map { projectionID in
                let checksum = RuntimeTransactionDigest.digest([projectionID.rawValue, eventEnvelope.checksum])
                return (projectionID, ProjectionCursor(projectionID: projectionID, eventCursor: eventEnvelope.cursor, checksum: checksum, materializedAt: committedAt))
            })
            let receipt = RuntimeCommitReceipt(
                transaction: transaction,
                eventEnvelope: eventEnvelope,
                projectionCursors: cursors,
                committedAt: committedAt
            )
            try insertAuthorityReceipt(receipt, transaction: transaction, outboxIntents: outboxIntents, database: database)
            return RuntimeSQLiteAuthorityCommit(disposition: .committed, receipt: receipt)
        }
    }

    func authorityReceipt(commandID: String) throws -> RuntimeCommitReceipt? {
        let database = try openDatabase()
        try createAuthoritySchema(database)
        return try authorityReceipt(commandID: commandID, database: database)
    }

    func outboxIntents(commandID: String) throws -> [RuntimeOutboxIntent] {
        let database = try openDatabase()
        try createAuthoritySchema(database)
        let sql = "SELECT outbox_intents_json FROM runtime_authority_commits WHERE command_id = ? LIMIT 1"
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try LocalRuntimeSQLite.bind(commandID, to: statement, at: 1, parameter: "command_id")
        guard sqlite3_step(statement) == SQLITE_ROW else { return [] }
        return try LocalRuntimeStorageCoding.decode([RuntimeOutboxIntent].self, from: LocalRuntimeSQLite.blob(statement, 0, column: "outbox_intents_json"))
    }

    func decodeDomainEventOrQuarantine(
        _ data: Data,
        typeID: String,
        schemaVersion: Int,
        quarantinedAt: String
    ) throws -> RuntimeDomainEvent? {
        do {
            return try RuntimeDomainEventCodec().decode(data)
        } catch {
            let database = try openDatabase()
            try createAuthoritySchema(database)
            let id = "runtime.quarantine.\(LocalRuntimeStorageChecksum.sha256Hex(for: data))"
            let sql = "INSERT OR IGNORE INTO runtime_event_quarantine (quarantine_id, type_id, schema_version, payload, reason, quarantined_at) VALUES (?, ?, ?, ?, ?, ?)"
            let statement = try database.prepare(sql)
            defer { sqlite3_finalize(statement) }
            try LocalRuntimeSQLite.bind(id, to: statement, at: 1, parameter: "quarantine_id")
            try LocalRuntimeSQLite.bind(typeID, to: statement, at: 2, parameter: "type_id")
            try LocalRuntimeSQLite.bind(schemaVersion, to: statement, at: 3, parameter: "schema_version")
            try LocalRuntimeSQLite.bind(data, to: statement, at: 4, parameter: "payload")
            try LocalRuntimeSQLite.bind(String(describing: error), to: statement, at: 5, parameter: "reason")
            try LocalRuntimeSQLite.bind(quarantinedAt, to: statement, at: 6, parameter: "quarantined_at")
            guard sqlite3_step(statement) == SQLITE_DONE else {
                throw LocalRuntimeStorageError.sqliteStepFailed(sql: sql, message: database.sqliteMessage)
            }
            return nil
        }
    }

    func quarantineRecords() throws -> [RuntimeEventQuarantineRecord] {
        let database = try openDatabase()
        try createAuthoritySchema(database)
        let sql = "SELECT quarantine_id, type_id, schema_version, reason FROM runtime_event_quarantine ORDER BY quarantine_id"
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        var records: [RuntimeEventQuarantineRecord] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            records.append(RuntimeEventQuarantineRecord(
                id: try LocalRuntimeSQLite.text(statement, 0, column: "quarantine_id"),
                typeID: try LocalRuntimeSQLite.text(statement, 1, column: "type_id"),
                schemaVersion: Int(LocalRuntimeSQLite.int64(statement, 2)),
                reason: try LocalRuntimeSQLite.text(statement, 3, column: "reason")
            ))
        }
        return records
    }


    static func requiresSemanticEvent(_ kind: AmbitionsCommandKind) -> Bool {
        switch kind {
        case .quickCapture, .createTimeItem, .placeStepInTime: true
        default: false
        }
    }
}

private extension EventStoreSQLite {
    func createAuthoritySchema(_ database: LocalRuntimeSQLiteDatabase) throws {
        try database.execute(
            """
            CREATE TABLE IF NOT EXISTS runtime_authority_commits (
                command_id TEXT PRIMARY KEY,
                receipt_json BLOB NOT NULL,
                committed_at TEXT NOT NULL,
                committed_event_sequence INTEGER NOT NULL,
                projection_cursor_sequence INTEGER NOT NULL,
                rollback_metadata_json BLOB NOT NULL,
                outbox_intents_json BLOB NOT NULL,
                status TEXT NOT NULL CHECK(status = 'committed')
            );
            """
        )
        try database.execute(
            """
            CREATE TABLE IF NOT EXISTS runtime_event_quarantine (
                quarantine_id TEXT PRIMARY KEY,
                type_id TEXT NOT NULL,
                schema_version INTEGER NOT NULL,
                payload BLOB NOT NULL,
                reason TEXT NOT NULL,
                quarantined_at TEXT NOT NULL
            );
            """
        )
    }

    func authorityReceipt(commandID: String, database: LocalRuntimeSQLiteDatabase) throws -> RuntimeCommitReceipt? {
        let sql = "SELECT receipt_json FROM runtime_authority_commits WHERE command_id = ? LIMIT 1"
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try LocalRuntimeSQLite.bind(commandID, to: statement, at: 1, parameter: "command_id")
        guard sqlite3_step(statement) == SQLITE_ROW else { return nil }
        return try LocalRuntimeStorageCoding.decode(RuntimeCommitReceipt.self, from: LocalRuntimeSQLite.blob(statement, 0, column: "receipt_json"))
    }

    func insertAuthorityReceipt(
        _ receipt: RuntimeCommitReceipt,
        transaction: RuntimeTransaction,
        outboxIntents: [RuntimeOutboxIntent],
        database: LocalRuntimeSQLiteDatabase
    ) throws {
        let sql = """
        INSERT INTO runtime_authority_commits (
            command_id, receipt_json, committed_at, committed_event_sequence,
            projection_cursor_sequence, rollback_metadata_json, outbox_intents_json, status
        ) VALUES (?, ?, ?, ?, ?, ?, ?, 'committed')
        """
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try LocalRuntimeSQLite.bind(receipt.commandID, to: statement, at: 1, parameter: "command_id")
        try LocalRuntimeSQLite.bind(try LocalRuntimeStorageCoding.encode(receipt), to: statement, at: 2, parameter: "receipt_json")
        try LocalRuntimeSQLite.bind(receipt.committedAt, to: statement, at: 3, parameter: "committed_at")
        try LocalRuntimeSQLite.bind(receipt.eventCursor.sequence, to: statement, at: 4, parameter: "event_sequence")
        try LocalRuntimeSQLite.bind(receipt.projectionCursors.map(\.sequence).max() ?? 0, to: statement, at: 5, parameter: "projection_cursor")
        try LocalRuntimeSQLite.bind(try LocalRuntimeStorageCoding.encode(transaction.rollbackPlan), to: statement, at: 6, parameter: "rollback_metadata")
        try LocalRuntimeSQLite.bind(try LocalRuntimeStorageCoding.encode(outboxIntents), to: statement, at: 7, parameter: "outbox_intents")
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw LocalRuntimeStorageError.sqliteStepFailed(sql: sql, message: database.sqliteMessage)
        }
    }
}
