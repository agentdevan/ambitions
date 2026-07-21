import Foundation
import SQLite3

struct RuntimeStoreMigrationControlDurability: Sendable, Equatable {
    let journalMode: String
    let synchronous: Int32
    let foreignKeys: Int32
}

enum RuntimeStoreMigrationIntentKind: String, Codable, Sendable {
    case activation
    case rollback
}

struct RuntimeStoreMigrationPendingIntent: Codable, Sendable, Equatable {
    let intentIdentity: String
    let kind: RuntimeStoreMigrationIntentKind
    let expectedGeneration: Int64
    let oldPointer: RuntimeStoreActivePointer?
    let newPointer: RuntimeStoreActivePointer
    let reservationIdentity: String?
    let verificationIdentity: String?
    let candidateFilename: String?
    let finalFilename: String?
}

extension RuntimeStoreMigrationControlConnection {
    func configureDurability() throws {
        let journalMode = try textPragma("PRAGMA journal_mode=WAL")
        try execute("PRAGMA synchronous=FULL")
        try execute("PRAGMA foreign_keys=ON")
        let settings = try durabilitySettings()
        guard journalMode.lowercased() == "wal",
              settings.journalMode.lowercased() == "wal",
              settings.synchronous == 2,
              settings.foreignKeys == 1
        else {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "configure migration control durability",
                description: "SQLite durability pragmas were not retained."
            )
        }
    }

    func durabilitySettings() throws -> RuntimeStoreMigrationControlDurability {
        RuntimeStoreMigrationControlDurability(
            journalMode: try textPragma("PRAGMA journal_mode"),
            synchronous: try integerPragma("PRAGMA synchronous"),
            foreignKeys: try integerPragma("PRAGMA foreign_keys")
        )
    }

    func pendingIntent() throws -> RuntimeStoreMigrationPendingIntent? {
        let statement = try prepare(
            "SELECT intent_json FROM migration_pending_intent WHERE singleton = 1"
        )
        defer { sqlite3_finalize(statement) }
        let result = sqlite3_step(statement)
        guard result == SQLITE_ROW else {
            if result == SQLITE_DONE { return nil }
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "read pending migration authority intent",
                description: message
            )
        }
        return try JSONDecoder().decode(
            RuntimeStoreMigrationPendingIntent.self,
            from: Self.blob(statement, column: 0)
        )
    }

    func insertPendingIntent(
        _ intent: RuntimeStoreMigrationPendingIntent
    ) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        try execute(
            """
            INSERT INTO migration_pending_intent(singleton, intent_json)
            VALUES (1, ?)
            """,
            bindings: [.blob(try encoder.encode(intent))]
        )
    }

    func deletePendingIntent(identity: String) throws {
        guard let pending = try pendingIntent(),
              pending.intentIdentity == identity
        else {
            throw RuntimeStoreMigrationError.pendingAuthorityDivergence(identity)
        }
        try execute(
            "DELETE FROM migration_pending_intent WHERE singleton = 1"
        )
        guard sqlite3_changes(database) == 1 else {
            throw RuntimeStoreMigrationError.pendingAuthorityDivergence(identity)
        }
    }

    private func textPragma(_ sql: String) throws -> String {
        let statement = try prepare(sql)
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW,
              let value = sqlite3_column_text(statement, 0)
        else {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "read migration control durability pragma",
                description: message
            )
        }
        return String(cString: value)
    }

    private func integerPragma(_ sql: String) throws -> Int32 {
        let statement = try prepare(sql)
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "read migration control durability pragma",
                description: message
            )
        }
        return sqlite3_column_int(statement, 0)
    }
}

extension RuntimeStoreMigrationControlDatabase {
    func durabilitySettings() throws -> RuntimeStoreMigrationControlDurability {
        try RuntimeStoreMigrationControlConnection(
            url: url,
            rootDescriptor: rootDescriptor
        ).durabilitySettings()
    }
}

extension RuntimeStoreMigrationCoordinator {
    func controlDurabilitySettings() throws
        -> RuntimeStoreMigrationControlDurability {
        try controlDatabase.durabilitySettings()
    }

    func reconcilePendingIntent() throws
        -> RuntimeStoreMigrationPendingIntent? {
        try controlDatabase.withImmediateTransaction { connection in
            try reconcilePendingIntent(connection: connection)
        }
    }

    func reconcilePendingIntent(
        connection: RuntimeStoreMigrationControlConnection
    ) throws -> RuntimeStoreMigrationPendingIntent? {
        guard let intent = try connection.pendingIntent() else { return nil }
        let pointer = try readPointerIfPresent()
        if pointer == intent.newPointer {
            try finalize(intent, connection: connection)
            return nil
        }
        guard pointer == intent.oldPointer else {
            throw RuntimeStoreMigrationError.pendingAuthorityDivergence(
                intent.intentIdentity
            )
        }
        return intent
    }

    func requireNoPendingIntent() throws {
        guard let intent = try reconcilePendingIntent() else { return }
        throw RuntimeStoreMigrationError.pendingAuthorityIntent(
            intent.intentIdentity
        )
    }

    func prepareOrResumeActivation(
        reservation: RuntimeStoreMigrationReservation,
        verifiedReport: RuntimeStoreVerificationReport,
        activatedAt: Date
    ) throws -> RuntimeStoreMigrationPendingIntent {
        if let pending = try reconcilePendingIntent() {
            guard pending.kind == .activation,
                  pending.reservationIdentity == reservation.reservationIdentity,
                  pending.verificationIdentity
                    == verifiedReport.verificationIdentity
            else {
                throw RuntimeStoreMigrationError.pendingAuthorityIntent(
                    pending.intentIdentity
                )
            }
            try controlDatabase.withImmediateTransaction { connection in
                let issuance = try connection.requireVerification(
                    identity: verifiedReport.verificationIdentity
                )
                guard !issuance.consumed,
                      issuance.report == verifiedReport
                else {
                    throw RuntimeStoreMigrationError.verificationIdentityMismatch
                }
            }
            return pending
        }

        return try controlDatabase.withImmediateTransaction { connection in
            if let pending = try connection.pendingIntent() {
                guard pending.kind == .activation,
                      pending.reservationIdentity
                        == reservation.reservationIdentity,
                      pending.verificationIdentity
                        == verifiedReport.verificationIdentity
                else {
                    throw RuntimeStoreMigrationError.pendingAuthorityIntent(
                        pending.intentIdentity
                    )
                }
                let issuance = try connection.requireVerification(
                    identity: verifiedReport.verificationIdentity
                )
                guard !issuance.consumed,
                      issuance.report == verifiedReport
                else {
                    throw RuntimeStoreMigrationError.verificationIdentityMismatch
                }
                return pending
            }
            try connection.requireReservation(reservation)
            let issuance = try connection.requireVerification(
                identity: verifiedReport.verificationIdentity
            )
            guard !issuance.consumed else {
                throw RuntimeStoreMigrationError.verificationAlreadyConsumed(
                    verifiedReport.verificationIdentity
                )
            }
            guard issuance.report == verifiedReport,
                  issuance.report.reservationIdentity
                    == reservation.reservationIdentity,
                  issuance.report.migrationIdentity
                    == reservation.migrationIdentity,
                  try Self.stableDigest(issuance.expectations)
                    == verifiedReport.expectationsDigest
            else {
                throw RuntimeStoreMigrationError.verificationIdentityMismatch
            }

            let candidate = try inspectRootStore(
                filename: issuance.candidateFilename
            )
            guard candidate.digest == verifiedReport.candidateDigest else {
                throw RuntimeStoreMigrationError.digestMismatch(
                    filename: issuance.candidateFilename,
                    expected: verifiedReport.candidateDigest,
                    actual: candidate.digest
                )
            }
            try Self.compare(candidate.observation, with: issuance.expectations)
            let oldPointer = try readPointerIfPresent()
            if let oldPointer { _ = try validateStore(oldPointer.currentStore) }
            let finalFilename = "RuntimeStore.\(reservation.migrationIdentity)."
                + "\(candidate.digest).sqlite"
            try Self.validateStoreFilename(finalFilename)
            if RuntimeStoreMigrationFileSystem.entryExists(
                parentDescriptor: rootDescriptor,
                name: finalFilename
            ) {
                throw RuntimeStoreMigrationError.finalStoreAlreadyExists(
                    finalFilename
                )
            }
            let currentStore = RuntimeStoreFileIdentity(
                filename: finalFilename,
                digest: candidate.digest,
                migrationIdentity: reservation.migrationIdentity
            )
            let newPointer = RuntimeStoreActivePointer(
                currentStore: currentStore,
                previousStore: oldPointer?.currentStore,
                migrationIdentity: reservation.migrationIdentity,
                activatedAt: activatedAt
            )
            let intent = RuntimeStoreMigrationPendingIntent(
                intentIdentity: UUID().uuidString,
                kind: .activation,
                expectedGeneration: try connection.authorityGeneration(),
                oldPointer: oldPointer,
                newPointer: newPointer,
                reservationIdentity: reservation.reservationIdentity,
                verificationIdentity: verifiedReport.verificationIdentity,
                candidateFilename: issuance.candidateFilename,
                finalFilename: finalFilename
            )
            try connection.insertPendingIntent(intent)
            return intent
        }
    }

    func publishActivation(
        _ intent: RuntimeStoreMigrationPendingIntent,
        verifiedReport: RuntimeStoreVerificationReport,
        failurePoint: RuntimeStoreMigrationFailurePoint?
    ) throws -> RuntimeStoreActivePointer {
        try controlDatabase.withImmediateTransaction { connection in
            guard try connection.pendingIntent() == intent,
                  try readPointerIfPresent() == intent.oldPointer,
                  let candidateFilename = intent.candidateFilename,
                  let finalFilename = intent.finalFilename
            else {
                throw RuntimeStoreMigrationError.pendingAuthorityDivergence(
                    intent.intentIdentity
                )
            }
            let candidateExists = RuntimeStoreMigrationFileSystem.entryExists(
                parentDescriptor: rootDescriptor,
                name: candidateFilename
            )
            let finalExists = RuntimeStoreMigrationFileSystem.entryExists(
                parentDescriptor: rootDescriptor,
                name: finalFilename
            )
            if candidateExists && finalExists {
                throw RuntimeStoreMigrationError.finalStoreAlreadyExists(
                    finalFilename
                )
            }
            if candidateExists {
                do {
                    try RuntimeStoreMigrationFileSystem.rename(
                        sourceParentDescriptor: rootDescriptor,
                        sourceName: candidateFilename,
                        destinationParentDescriptor: rootDescriptor,
                        destinationName: finalFilename,
                        operation: "promote sealed runtime-store candidate"
                    )
                } catch {
                    if RuntimeStoreMigrationFileSystem.entryExists(
                        parentDescriptor: rootDescriptor,
                        name: finalFilename
                    ) {
                        throw RuntimeStoreMigrationError.finalStoreAlreadyExists(
                            finalFilename
                        )
                    }
                    throw error
                }
                try RuntimeStoreMigrationFileSystem.syncDescriptor(
                    rootDescriptor,
                    operation: "sync promoted runtime-store directory"
                )
            } else if !finalExists {
                _ = try inspectRootStore(filename: candidateFilename)
            }
            let promoted = try inspectRootStore(filename: finalFilename)
            try validatePromotedStore(promoted, report: verifiedReport)
            try writePointer(intent.newPointer, failurePoint: failurePoint)
            try finalize(intent, connection: connection)
            return intent.newPointer
        }
    }

    func prepareOrResumeRollback(
        activatedAt: Date
    ) throws -> RuntimeStoreMigrationPendingIntent {
        if let pending = try reconcilePendingIntent() {
            guard pending.kind == .rollback else {
                throw RuntimeStoreMigrationError.pendingAuthorityIntent(
                    pending.intentIdentity
                )
            }
            return pending
        }
        return try controlDatabase.withImmediateTransaction { connection in
            if let pending = try connection.pendingIntent() {
                guard pending.kind == .rollback else {
                    throw RuntimeStoreMigrationError.pendingAuthorityIntent(
                        pending.intentIdentity
                    )
                }
                return pending
            }
            guard let pointer = try readPointerIfPresent() else {
                throw RuntimeStoreMigrationError.noActiveStore
            }
            _ = try validateStore(pointer.currentStore)
            guard let previousStore = pointer.previousStore else {
                throw RuntimeStoreMigrationError.noPreviousStore
            }
            _ = try validateStore(previousStore)
            let rolledBack = RuntimeStoreActivePointer(
                currentStore: previousStore,
                previousStore: pointer.currentStore,
                migrationIdentity: previousStore.migrationIdentity,
                activatedAt: activatedAt
            )
            let intent = RuntimeStoreMigrationPendingIntent(
                intentIdentity: UUID().uuidString,
                kind: .rollback,
                expectedGeneration: try connection.authorityGeneration(),
                oldPointer: pointer,
                newPointer: rolledBack,
                reservationIdentity: nil,
                verificationIdentity: nil,
                candidateFilename: nil,
                finalFilename: nil
            )
            try connection.insertPendingIntent(intent)
            return intent
        }
    }

    func finalizePendingIntent(
        _ intent: RuntimeStoreMigrationPendingIntent
    ) throws {
        try controlDatabase.withImmediateTransaction { connection in
            guard try connection.pendingIntent() == intent,
                  try readPointerIfPresent() == intent.newPointer
            else {
                throw RuntimeStoreMigrationError.pendingAuthorityDivergence(
                    intent.intentIdentity
                )
            }
            try finalize(intent, connection: connection)
        }
    }

    func publishRollback(
        _ intent: RuntimeStoreMigrationPendingIntent,
        failurePoint: RuntimeStoreMigrationFailurePoint?
    ) throws -> RuntimeStoreActivePointer {
        try controlDatabase.withImmediateTransaction { connection in
            guard try connection.pendingIntent() == intent,
                  try readPointerIfPresent() == intent.oldPointer
            else {
                throw RuntimeStoreMigrationError.pendingAuthorityDivergence(
                    intent.intentIdentity
                )
            }
            try writePointer(intent.newPointer, failurePoint: failurePoint)
            try finalize(intent, connection: connection)
            return intent.newPointer
        }
    }

    private func finalize(
        _ intent: RuntimeStoreMigrationPendingIntent,
        connection: RuntimeStoreMigrationControlConnection
    ) throws {
        if let verificationIdentity = intent.verificationIdentity {
            try connection.consumeVerification(identity: verificationIdentity)
        }
        try connection.advanceAuthorityGeneration(
            expected: intent.expectedGeneration
        )
        try connection.deletePendingIntent(identity: intent.intentIdentity)
    }

    private func validatePromotedStore(
        _ promoted: RuntimeStoreMigrationInspectedFile,
        report: RuntimeStoreVerificationReport
    ) throws {
        guard promoted.digest == report.candidateDigest else {
            throw RuntimeStoreMigrationError.digestMismatch(
                filename: report.migrationIdentity,
                expected: report.candidateDigest,
                actual: promoted.digest
            )
        }
        guard promoted.observation.snapshot.canonicalRevision
                == report.canonicalRevision,
              promoted.observation.counts == report.counts,
              promoted.observation.checksums == report.checksums,
              promoted.observation.integrityResult
                == report.sqliteIntegrityResult
        else {
            throw RuntimeStoreMigrationError.verificationIdentityMismatch
        }
    }
}
