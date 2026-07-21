import Foundation

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

extension RuntimeStoreMigrationCoordinator {
    public func resolveActiveStore() throws -> URL {
        _ = try reconcilePendingIntent()
        guard let pointer = try readPointerIfPresent() else {
            throw RuntimeStoreMigrationError.noActiveStore
        }
        guard pointer.migrationIdentity == pointer.currentStore.migrationIdentity else {
            throw RuntimeStoreMigrationError.invalidPointer(
                "Current store migration identity does not match the pointer."
            )
        }
        return try validateStore(pointer.currentStore)
    }

    public func rollback(
        activatedAt: Date,
        failurePoint: RuntimeStoreMigrationFailurePoint? = nil
    ) throws -> RuntimeStoreActivePointer {
        let intent = try prepareOrResumeRollback(activatedAt: activatedAt)
        return try publishRollback(intent, failurePoint: failurePoint)
    }

    func expectedReservation(
        for migrationIdentity: String,
        reservationIdentity: String
    ) -> RuntimeStoreMigrationReservation {
        let stagingDirectory = rootDirectoryURL
            .appendingPathComponent("MigrationStaging", isDirectory: true)
            .appendingPathComponent(migrationIdentity, isDirectory: true)
        return RuntimeStoreMigrationReservation(
            reservationIdentity: reservationIdentity,
            migrationIdentity: migrationIdentity,
            stagingDirectoryURL: stagingDirectory,
            stagedStoreURL: stagingDirectory.appendingPathComponent(
                "RuntimeStore.sqlite.next",
                isDirectory: false
            )
        )
    }

    func validateReservationStructure(
        _ reservation: RuntimeStoreMigrationReservation
    ) throws {
        guard reservation.schemaVersion == 2 else {
            throw RuntimeStoreMigrationError.unsupportedReservationSchemaVersion(
                reservation.schemaVersion
            )
        }
        try Self.validateMigrationIdentity(reservation.migrationIdentity)
        let expected = expectedReservation(
            for: reservation.migrationIdentity,
            reservationIdentity: reservation.reservationIdentity
        )
        let actualStore = reservation.stagedStoreURL.standardizedFileURL
        let expectedStore = expected.stagedStoreURL.standardizedFileURL
        guard actualStore == expectedStore else {
            throw RuntimeStoreMigrationError.reservationPathMismatch(
                expected: expected.stagedStoreURL,
                actual: actualStore
            )
        }
        let actualDirectory = reservation.stagingDirectoryURL.standardizedFileURL
        let expectedDirectory = expected.stagingDirectoryURL.standardizedFileURL
        guard actualDirectory == expectedDirectory else {
            throw RuntimeStoreMigrationError.reservationPathMismatch(
                expected: expected.stagingDirectoryURL,
                actual: actualDirectory
            )
        }
    }

    func captureStagedStore(
        reservation: RuntimeStoreMigrationReservation,
        verificationIdentity: String
    ) throws -> URL {
        let stagingRootDescriptor = try RuntimeStoreMigrationFileSystem
            .openDirectory(
                parentDescriptor: rootDescriptor,
                name: "MigrationStaging"
            )
        defer {
            RuntimeStoreMigrationFileSystem.close(stagingRootDescriptor)
        }
        let stagingDescriptor = try RuntimeStoreMigrationFileSystem
            .openDirectory(
                parentDescriptor: stagingRootDescriptor,
                name: reservation.migrationIdentity
            )
        defer {
            RuntimeStoreMigrationFileSystem.close(stagingDescriptor)
        }
        let captureDirectoryName = ".RuntimeStore.verification.\(verificationIdentity)"
        let captureDescriptor = try RuntimeStoreMigrationFileSystem
            .ensureDirectory(
                parentDescriptor: rootDescriptor,
                name: captureDirectoryName
            )
        defer {
            RuntimeStoreMigrationFileSystem.close(captureDescriptor)
        }

        let storeName = "RuntimeStore.sqlite.next"
        try RuntimeStoreMigrationFileSystem.requireRegularEntry(
            parentDescriptor: stagingDescriptor,
            name: storeName
        )
        for name in [storeName, storeName + "-wal", storeName + "-shm"] {
            guard RuntimeStoreMigrationFileSystem.entryExists(
                parentDescriptor: stagingDescriptor,
                name: name
            ) else { continue }
            try RuntimeStoreMigrationFileSystem.rename(
                sourceParentDescriptor: stagingDescriptor,
                sourceName: name,
                destinationParentDescriptor: captureDescriptor,
                destinationName: name,
                operation: "capture staged runtime-store artifact"
            )
            try RuntimeStoreMigrationFileSystem.requireRegularEntry(
                parentDescriptor: captureDescriptor,
                name: name
            )
        }
        try RuntimeStoreMigrationFileSystem.syncDescriptor(
            stagingDescriptor,
            operation: "sync captured staging directory"
        )
        try RuntimeStoreMigrationFileSystem.syncDescriptor(
            captureDescriptor,
            operation: "sync verification capture directory"
        )
        try RuntimeStoreMigrationFileSystem.syncDescriptor(
            rootDescriptor,
            operation: "sync verification capture parent"
        )
        return rootDirectoryURL
            .appendingPathComponent(captureDirectoryName, isDirectory: true)
            .appendingPathComponent(storeName)
    }

    func readPointerIfPresent() throws -> RuntimeStoreActivePointer? {
        let descriptor: Int32
        do {
            descriptor = try RuntimeStoreMigrationFileSystem.openRegularFile(
                parentDescriptor: rootDescriptor,
                name: "RuntimeStore.active.json",
                flags: O_RDONLY
            )
        } catch is RuntimeStoreMigrationFileSystem.MissingEntry {
            return nil
        } catch let error as RuntimeStoreMigrationError {
            throw error
        }
        defer { RuntimeStoreMigrationFileSystem.close(descriptor) }
        do {
            let data = try RuntimeStoreMigrationFileSystem.readAll(descriptor)
            let envelope = try JSONDecoder().decode(
                RuntimeStorePointerSchemaEnvelope.self,
                from: data
            )
            guard envelope.schemaVersion == 1 else {
                throw RuntimeStoreMigrationError.unsupportedPointerSchemaVersion(
                    envelope.schemaVersion
                )
            }
            return try JSONDecoder().decode(
                RuntimeStoreActivePointer.self,
                from: data
            )
        } catch let error as RuntimeStoreMigrationError {
            throw error
        } catch {
            throw RuntimeStoreMigrationError.invalidPointer(
                String(describing: error)
            )
        }
    }

    func validateStore(
        _ identity: RuntimeStoreFileIdentity
    ) throws -> URL {
        try Self.validateStoreFilename(identity.filename)
        try Self.validateMigrationIdentity(identity.migrationIdentity)
        let inspected = try inspectRootStore(filename: identity.filename)
        guard inspected.digest == identity.digest else {
            throw RuntimeStoreMigrationError.digestMismatch(
                filename: identity.filename,
                expected: identity.digest,
                actual: inspected.digest
            )
        }
        guard inspected.observation.integrityResult == "ok" else {
            throw RuntimeStoreMigrationError.sqliteIntegrityFailed(
                inspected.observation.integrityResult
            )
        }
        return rootDirectoryURL.appendingPathComponent(identity.filename)
    }

    func inspectRootStore(
        filename: String
    ) throws -> RuntimeStoreMigrationInspectedFile {
        let descriptor = try RuntimeStoreMigrationFileSystem.openRegularFile(
            parentDescriptor: rootDescriptor,
            name: filename,
            flags: O_RDONLY
        )
        defer { RuntimeStoreMigrationFileSystem.close(descriptor) }
        try RuntimeStoreMigrationFileSystem.syncDescriptor(
            descriptor,
            operation: "sync sealed runtime store"
        )
        let digest = try RuntimeStoreMigrationFileSystem.digest(descriptor)
        let fileIdentity = try RuntimeStoreMigrationFileSystem.identity(descriptor)
        let descriptorURL = URL(
            fileURLWithPath: RuntimeStoreMigrationFileSystem.descriptorPath(
                descriptor
            )
        )
        let raw = try RuntimeStoreSQLite.migrationObservation(at: descriptorURL)
        guard raw.integrityResult == "ok" else {
            throw RuntimeStoreMigrationError.sqliteIntegrityFailed(
                raw.integrityResult
            )
        }
        let counts = RuntimeStoreVerificationCounts(
            stateCount: raw.snapshot.stateChanges.count,
            eventCount: raw.snapshot.events.count,
            projectionCount: raw.snapshot.projectionChanges.count,
            receiptCount: raw.snapshot.receipts.count,
            outboxCount: raw.outbox.count
        )
        let checksums = try RuntimeStoreStableChecksums(
            snapshot: raw.snapshot,
            outbox: raw.outbox
        )
        return RuntimeStoreMigrationInspectedFile(
            fileIdentity: fileIdentity,
            digest: digest,
            observation: RuntimeStoreMigrationObservation(
                snapshot: raw.snapshot,
                outbox: raw.outbox,
                counts: counts,
                checksums: checksums,
                integrityResult: raw.integrityResult
            )
        )
    }

    func writePointer(
        _ pointer: RuntimeStoreActivePointer,
        failurePoint: RuntimeStoreMigrationFailurePoint?
    ) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let data: Data
        do {
            data = try encoder.encode(pointer)
        } catch {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "encode active-store pointer",
                description: String(describing: error)
            )
        }
        let temporaryName = ".RuntimeStore.active.\(UUID().uuidString).tmp"
        let descriptor = try RuntimeStoreMigrationFileSystem
            .createExclusiveRegularFile(
                parentDescriptor: rootDescriptor,
                name: temporaryName
            )
        do {
            try RuntimeStoreMigrationFileSystem.writeAll(data, to: descriptor)
            try RuntimeStoreMigrationFileSystem.syncDescriptor(
                descriptor,
                operation: "sync temporary active-store pointer"
            )
            RuntimeStoreMigrationFileSystem.close(descriptor)
        } catch {
            RuntimeStoreMigrationFileSystem.close(descriptor)
            throw error
        }
        if failurePoint == .beforePointerRename {
            throw RuntimeStoreMigrationError.injectedFailure(.beforePointerRename)
        }
        try RuntimeStoreMigrationFileSystem.replace(
            sourceParentDescriptor: rootDescriptor,
            sourceName: temporaryName,
            destinationParentDescriptor: rootDescriptor,
            destinationName: "RuntimeStore.active.json",
            operation: "atomically rename active-store pointer"
        )
        try RuntimeStoreMigrationFileSystem.syncDescriptor(
            rootDescriptor,
            operation: "sync active-store pointer directory"
        )
        if failurePoint == .afterPointerRename {
            throw RuntimeStoreMigrationError.injectedFailure(.afterPointerRename)
        }
    }
}
