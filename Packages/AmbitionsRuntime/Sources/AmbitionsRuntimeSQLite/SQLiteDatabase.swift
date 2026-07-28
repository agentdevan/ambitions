import Foundation
import SQLite3
import CAmbitionsSQLiteSecureVFS
#if canImport(Darwin)
import Darwin
#endif

/// An actor-owned SQLite connection exposing prepared, value-oriented APIs.
///
/// The connection handle and prepared statements remain private to this actor.
/// This module provides storage mechanics and deliberately owns no Ambitions
/// command, migration, projection, receipt, or other product policy.
public actor SQLiteDatabase {
    public let databaseURL: URL
    public let configuration: SQLiteConfiguration

    // SQLite owns this opaque C handle; actor methods serialize all access.
    // `deinit` is nonisolated under Swift 6, so its final close needs the same
    // explicit unmanaged-handle boundary.
    private nonisolated(unsafe) var handle: OpaquePointer?
    private var terminalError: SQLiteError?
    private var retainedReadOnlyDescriptor: Int32?
    private var retainedReadOnlyDirectoryDescriptor: Int32?
    private var retainedReadOnlyCoordinationDescriptor: Int32?
    private var retainedReadOnlyNamespace: SQLiteReadOnlyNamespaceIdentity?
    // The C VFS owns a duplicate of an euid-owned parent that is not writable
    // by group or other. It outlives every SQLite file handle and is released
    // only after a non-deferred SQLite close succeeds.
    private nonisolated(unsafe) var retainedWritableVFSContext: OpaquePointer?
    private let authorizerState: SQLiteAuthorizerState

    public init(
        url: URL,
        configuration: SQLiteConfiguration = SQLiteConfiguration()
    ) throws {
        databaseURL = url.standardizedFileURL
        self.configuration = configuration
        handle = nil
        terminalError = nil
        retainedReadOnlyDescriptor = nil
        retainedReadOnlyDirectoryDescriptor = nil
        retainedReadOnlyCoordinationDescriptor = nil
        retainedReadOnlyNamespace = nil
        retainedWritableVFSContext = nil
        authorizerState = SQLiteAuthorizerState(
            connectionIsReadOnly: configuration.openMode == .readOnlyExisting ||
                configuration.openMode == .readOnlySnapshot
        )

        guard configuration.busyTimeoutMilliseconds >= 0,
              configuration.maximumValueBytes.map({ $0 > 0 }) ?? true
        else {
            throw SQLiteError(
                operation: .configure,
                extendedCode: SQLITE_MISUSE
            )
        }

        if configuration.openMode == .createOrOpen {
            do {
                try FileManager.default.createDirectory(
                    at: databaseURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
            } catch {
                throw SQLiteError(
                    operation: .open,
                    extendedCode: SQLITE_CANTOPEN
                )
            }
        }

        var immutableDescriptor: Int32?
        var snapshotDirectoryDescriptor: Int32?
        var snapshotCoordinationDescriptor: Int32?
        var immutableIdentity: (device: UInt64, inode: UInt64)?
        var initialNamespaceIdentity: SQLiteReadOnlyNamespaceIdentity?
        var writableVFSContext: OpaquePointer?
#if canImport(Darwin)
        if configuration.openMode == .readOnlyExisting ||
            configuration.openMode == .readOnlySnapshot {
            let parentURL = databaseURL.deletingLastPathComponent()
            let basename = databaseURL.lastPathComponent
            let snapshotAuthority = configuration.readOnlySnapshotAuthority
            guard basename.isEmpty == false, basename != ".", basename != "..",
                  basename.utf8.allSatisfy({ $0 != 0 && $0 != 47 }) else {
                throw SQLiteError(operation: .open, extendedCode: SQLITE_CANTOPEN)
            }
            if configuration.openMode == .readOnlySnapshot {
                guard let authority = snapshotAuthority,
                      authority.allowsBoundedSharedMemoryCoordination,
                      authority.appPrivateRootURL == parentURL,
                      authority.coordinationLockURL.deletingLastPathComponent() == parentURL,
                      authority.coordinationLockURL.lastPathComponent.isEmpty == false else {
                    throw SQLiteError(operation: .open, extendedCode: SQLITE_MISUSE)
                }
            } else if configuration.readOnlySnapshotAuthority != nil {
                throw SQLiteError(operation: .open, extendedCode: SQLITE_MISUSE)
            }
            let directoryDescriptor = Darwin.open(
                parentURL.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            )
            let descriptor = directoryDescriptor >= 0
                ? Darwin.openat(
                    directoryDescriptor, basename,
                    O_RDONLY | O_NOFOLLOW | O_CLOEXEC
                ) : -1
            let coordinationDescriptor: Int32
            if configuration.openMode == .readOnlySnapshot,
               let authority = snapshotAuthority {
                coordinationDescriptor = Darwin.openat(
                    directoryDescriptor,
                    authority.coordinationLockURL.lastPathComponent,
                    O_RDWR | O_NOFOLLOW | O_CLOEXEC
                )
            } else {
                coordinationDescriptor = -1
            }
            var descriptorStatus = stat()
            var pathStatus = stat()
            var directoryStatus = stat()
            var directoryPathStatus = stat()
            var coordinationStatus = stat()
            var coordinationPathStatus = stat()
            guard directoryDescriptor >= 0, descriptor >= 0,
                  fstat(directoryDescriptor, &directoryStatus) == 0,
                  Darwin.lstat(parentURL.path, &directoryPathStatus) == 0,
                  fstat(descriptor, &descriptorStatus) == 0,
                  fstatat(
                    directoryDescriptor, basename, &pathStatus, AT_SYMLINK_NOFOLLOW
                  ) == 0,
                  directoryStatus.st_mode & S_IFMT == S_IFDIR,
                  directoryStatus.st_dev == directoryPathStatus.st_dev,
                  directoryStatus.st_ino == directoryPathStatus.st_ino,
                  descriptorStatus.st_mode & S_IFMT == S_IFREG,
                  descriptorStatus.st_nlink == 1,
                  descriptorStatus.st_dev == pathStatus.st_dev,
                  descriptorStatus.st_ino == pathStatus.st_ino,
                  configuration.openMode != .readOnlySnapshot || (
                    coordinationDescriptor >= 0 &&
                    fstat(coordinationDescriptor, &coordinationStatus) == 0 &&
                    fstatat(
                        directoryDescriptor,
                        snapshotAuthority?.coordinationLockURL.lastPathComponent ?? "",
                        &coordinationPathStatus,
                        AT_SYMLINK_NOFOLLOW
                    ) == 0 &&
                    coordinationStatus.st_mode & S_IFMT == S_IFREG &&
                    coordinationStatus.st_nlink == 1 &&
                    coordinationStatus.st_dev == coordinationPathStatus.st_dev &&
                    coordinationStatus.st_ino == coordinationPathStatus.st_ino &&
                    flock(coordinationDescriptor, LOCK_EX | LOCK_NB) == 0
                  ) else {
                let owner = SQLiteDescriptorOwner(
                    descriptors: [descriptor, directoryDescriptor, coordinationDescriptor]
                )
                if owner.closeAll() == false {
                    SQLiteFailedResourceRegistry.shared.retain(owner)
                }
                throw SQLiteError(operation: .open, extendedCode: SQLITE_CANTOPEN)
            }
            immutableDescriptor = descriptor
            snapshotDirectoryDescriptor = directoryDescriptor
            snapshotCoordinationDescriptor = coordinationDescriptor >= 0
                ? coordinationDescriptor : nil
            immutableIdentity = (
                UInt64(descriptorStatus.st_dev), UInt64(descriptorStatus.st_ino)
            )
            do {
                initialNamespaceIdentity = try Self.captureReadOnlyNamespaceIdentity(
                    directoryDescriptor: directoryDescriptor,
                    databaseName: basename,
                    requireSidecarsAbsent: configuration.openMode == .readOnlyExisting
                )
            } catch {
                if coordinationDescriptor >= 0 {
                    _ = flock(coordinationDescriptor, LOCK_UN)
                }
                let owner = SQLiteDescriptorOwner(
                    descriptors: [descriptor, directoryDescriptor, coordinationDescriptor]
                )
                if owner.closeAll() == false {
                    SQLiteFailedResourceRegistry.shared.retain(owner)
                }
                throw error
            }
        }
#endif

#if canImport(Darwin)
        if configuration.openMode == .createOrOpen ||
            configuration.openMode == .existingOnly {
            let parentURL = databaseURL.deletingLastPathComponent()
            let basename = databaseURL.lastPathComponent
            guard basename.isEmpty == false, basename != ".", basename != "..",
                  basename.utf8.allSatisfy({ $0 != 0 && $0 != 47 }) else {
                throw SQLiteError(operation: .open, extendedCode: SQLITE_CANTOPEN)
            }
            let directoryDescriptor = Darwin.open(
                parentURL.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            )
            guard directoryDescriptor >= 0,
                  AmbitionsSQLiteSecureVFSInstall() == SQLITE_OK,
                  let context = AmbitionsSQLiteSecureVFSCreateContext(
                    directoryDescriptor, basename
                  ) else {
                if directoryDescriptor >= 0 { _ = Darwin.close(directoryDescriptor) }
                throw SQLiteError(operation: .open, extendedCode: SQLITE_CANTOPEN)
            }
            let directoryClosed = Darwin.close(directoryDescriptor) == 0
            guard directoryClosed else {
                AmbitionsSQLiteSecureVFSDestroyContext(context)
                SQLiteFailedResourceRegistry.shared.recordIndeterminateClose(count: 1)
                throw SQLiteError(operation: .open, extendedCode: SQLITE_IOERR)
            }
            writableVFSContext = context
        }
#endif

        var openedHandle: OpaquePointer?
        var flags = SQLITE_OPEN_FULLMUTEX
            | SQLITE_OPEN_URI
        switch configuration.openMode {
        case .createOrOpen:
            flags |= SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
        case .existingOnly:
            flags |= SQLITE_OPEN_READWRITE
        case .readOnlyExisting, .readOnlySnapshot:
            // Read-only paths are descriptor-pinned and may retain SQLite's
            // native no-follow enforcement. Writable paths are handled by the
            // descriptor-root VFS, because this host SQLite does not accept
            // SQLITE_OPEN_NOFOLLOW for create/open.
            flags |= SQLITE_OPEN_READONLY | SQLITE_OPEN_NOFOLLOW
        }
        let sqliteLocation: String
        let sqliteVFSName: UnsafePointer<CChar>?
        switch configuration.openMode {
        case .readOnlyExisting:
            guard let immutableDescriptor else {
                throw SQLiteError(operation: .open, extendedCode: SQLITE_CANTOPEN)
            }
            sqliteLocation = URL(
                fileURLWithPath: "/dev/fd/\(immutableDescriptor)"
            ).absoluteString + "?mode=ro&immutable=1"
            sqliteVFSName = nil
        case .readOnlySnapshot:
            guard let snapshotDirectoryDescriptor else {
                throw SQLiteError(operation: .open, extendedCode: SQLITE_CANTOPEN)
            }
            sqliteLocation = URL(
                fileURLWithPath:
                    "/dev/fd/\(snapshotDirectoryDescriptor)/\(databaseURL.lastPathComponent)"
            ).absoluteString + "?mode=ro"
            sqliteVFSName = nil
        case .createOrOpen, .existingOnly:
            guard let writableVFSContext,
                  let virtualPath = AmbitionsSQLiteSecureVFSDatabasePath(
                    writableVFSContext
                  ) else {
                throw SQLiteError(operation: .open, extendedCode: SQLITE_CANTOPEN)
            }
            sqliteLocation = String(cString: virtualPath)
            sqliteVFSName = AmbitionsSQLiteSecureVFSName()
        }
        let openResult = sqlite3_open_v2(
            sqliteLocation,
            &openedHandle,
            flags,
            sqliteVFSName
        )
        guard openResult == SQLITE_OK, let openedHandle else {
            let handleClosed = openedHandle.map {
                sqlite3_close($0) == SQLITE_OK
            } ?? true
            let coordinationUnlocked = snapshotCoordinationDescriptor.map {
                flock($0, LOCK_UN) == 0
            } ?? true
            let owner = SQLiteDescriptorOwner(
                descriptors: [
                    immutableDescriptor ?? -1,
                    snapshotDirectoryDescriptor ?? -1,
                    snapshotCoordinationDescriptor ?? -1,
                ]
            )
            let descriptorsClosed: Bool
            if handleClosed {
                descriptorsClosed = owner.closeAll()
            } else {
                descriptorsClosed = false
                SQLiteFailedResourceRegistry.shared.retain(owner)
                if let openedHandle {
                    SQLiteFailedResourceRegistry.shared.retainSQLiteConnection(
                        openedHandle,
                        writableVFSContext: writableVFSContext
                    )
                }
            }
            if let writableVFSContext {
                if handleClosed {
                    AmbitionsSQLiteSecureVFSDestroyContext(writableVFSContext)
                }
            }
            if descriptorsClosed == false, handleClosed {
                SQLiteFailedResourceRegistry.shared.retain(owner)
            }
            throw SQLiteError(
                operation: .open,
                extendedCode: handleClosed == false || descriptorsClosed == false ||
                    coordinationUnlocked == false
                    ? SQLITE_IOERR
                    : openResult == SQLITE_OK
                    ? SQLITE_MISUSE
                    : openResult
            )
        }
        if configuration.openMode == .readOnlyExisting ||
            configuration.openMode == .readOnlySnapshot {
            do {
                var descriptorStatus = stat()
                var pathStatus = stat()
                let pathIdentityRead: Bool
                if let snapshotDirectoryDescriptor {
                    pathIdentityRead = fstatat(
                        snapshotDirectoryDescriptor,
                        databaseURL.lastPathComponent,
                        &pathStatus,
                        AT_SYMLINK_NOFOLLOW
                    ) == 0
                } else {
                    pathIdentityRead = Darwin.lstat(databaseURL.path, &pathStatus) == 0
                }
                guard let immutableDescriptor, let immutableIdentity,
                      fstat(immutableDescriptor, &descriptorStatus) == 0,
                      pathIdentityRead,
                      UInt64(descriptorStatus.st_dev) == immutableIdentity.device,
                      UInt64(descriptorStatus.st_ino) == immutableIdentity.inode,
                      descriptorStatus.st_dev == pathStatus.st_dev,
                      descriptorStatus.st_ino == pathStatus.st_ino,
                      descriptorStatus.st_nlink == 1,
                      pathStatus.st_nlink == 1 else {
                    throw SQLiteError(operation: .open, extendedCode: SQLITE_BUSY)
                }
                if let snapshotDirectoryDescriptor, let initialNamespaceIdentity {
                    let observed = try Self.captureReadOnlyNamespaceIdentity(
                        directoryDescriptor: snapshotDirectoryDescriptor,
                        databaseName: databaseURL.lastPathComponent,
                        requireSidecarsAbsent: configuration.openMode == .readOnlyExisting
                    )
                    try Self.requirePermittedNamespaceTransition(
                        from: initialNamespaceIdentity,
                        to: observed,
                        allowsSharedMemoryCreation:
                            configuration.openMode == .readOnlySnapshot &&
                            configuration.readOnlySnapshotAuthority?
                                .allowsBoundedSharedMemoryCoordination == true
                    )
                    retainedReadOnlyNamespace = observed
                }
            } catch {
                let handleClosed = sqlite3_close(openedHandle) == SQLITE_OK
                let coordinationUnlocked = snapshotCoordinationDescriptor.map {
                    flock($0, LOCK_UN) == 0
                } ?? true
                let owner = SQLiteDescriptorOwner(
                    descriptors: [
                        immutableDescriptor ?? -1,
                        snapshotDirectoryDescriptor ?? -1,
                        snapshotCoordinationDescriptor ?? -1,
                    ]
                )
                let descriptorsClosed: Bool
                if handleClosed {
                    descriptorsClosed = owner.closeAll()
                } else {
                    descriptorsClosed = false
                    SQLiteFailedResourceRegistry.shared.retain(owner)
                    SQLiteFailedResourceRegistry.shared.retainSQLiteConnection(
                        openedHandle,
                        writableVFSContext: writableVFSContext
                    )
                }
                guard handleClosed, descriptorsClosed, coordinationUnlocked else {
                    throw SQLiteError(operation: .open, extendedCode: SQLITE_IOERR)
                }
                throw error
            }
        }
        handle = openedHandle
        retainedReadOnlyDescriptor = immutableDescriptor
        retainedReadOnlyDirectoryDescriptor = snapshotDirectoryDescriptor
        retainedReadOnlyCoordinationDescriptor = snapshotCoordinationDescriptor
        retainedWritableVFSContext = writableVFSContext
        sqlite3_extended_result_codes(openedHandle, 1)

        do {
            try Self.configure(openedHandle, configuration: configuration)
            try Self.setPublicStatementAuthorizer(
                openedHandle,
                state: authorizerState
            )
        } catch {
            let handleClosed = sqlite3_close(openedHandle) == SQLITE_OK
            if handleClosed { handle = nil }
            if handleClosed, let retainedWritableVFSContext {
                AmbitionsSQLiteSecureVFSDestroyContext(retainedWritableVFSContext)
                self.retainedWritableVFSContext = nil
            } else if handleClosed == false {
                SQLiteFailedResourceRegistry.shared.retainSQLiteConnection(
                    openedHandle,
                    writableVFSContext: retainedWritableVFSContext
                )
                handle = nil
                self.retainedWritableVFSContext = nil
            }
            var descriptorClosed = true
            var directoryClosed = true
            var coordinationClosed = true
            if handleClosed, let descriptor = retainedReadOnlyDescriptor {
                descriptorClosed = Darwin.close(descriptor) == 0
                if descriptorClosed { retainedReadOnlyDescriptor = nil }
            }
            if handleClosed, let descriptor = retainedReadOnlyDirectoryDescriptor {
                directoryClosed = Darwin.close(descriptor) == 0
                if directoryClosed { retainedReadOnlyDirectoryDescriptor = nil }
            }
            if handleClosed, let descriptor = retainedReadOnlyCoordinationDescriptor {
                let unlocked = flock(descriptor, LOCK_UN) == 0
                let closed = Darwin.close(descriptor) == 0
                coordinationClosed = unlocked && closed
                if closed { retainedReadOnlyCoordinationDescriptor = nil }
            }
            if handleClosed == false {
                let owner = SQLiteDescriptorOwner(
                    descriptors: [
                        retainedReadOnlyDescriptor ?? -1,
                        retainedReadOnlyDirectoryDescriptor ?? -1,
                        retainedReadOnlyCoordinationDescriptor ?? -1,
                    ]
                )
                SQLiteFailedResourceRegistry.shared.retain(owner)
                retainedReadOnlyDescriptor = nil
                retainedReadOnlyDirectoryDescriptor = nil
                retainedReadOnlyCoordinationDescriptor = nil
            }
            if descriptorClosed == false || directoryClosed == false ||
                coordinationClosed == false {
                SQLiteFailedResourceRegistry.shared.recordIndeterminateClose(
                    count: [descriptorClosed, directoryClosed, coordinationClosed]
                        .filter { $0 == false }.count
                )
                retainedReadOnlyDescriptor = nil
                retainedReadOnlyDirectoryDescriptor = nil
                retainedReadOnlyCoordinationDescriptor = nil
            }
            guard handleClosed, descriptorClosed, directoryClosed,
                  coordinationClosed else {
                throw SQLiteError(operation: .configure, extendedCode: SQLITE_IOERR)
            }
            throw error
        }
    }

    deinit {
        var handleClosed = true
        if let handle {
            handleClosed = sqlite3_close(handle) == SQLITE_OK
        }
        if let retainedWritableVFSContext {
            if handleClosed {
                AmbitionsSQLiteSecureVFSDestroyContext(retainedWritableVFSContext)
            } else if let handle {
                SQLiteFailedResourceRegistry.shared.retainSQLiteConnection(
                    handle,
                    writableVFSContext: retainedWritableVFSContext
                )
            }
        }
        if handleClosed == false {
            let owner = SQLiteDescriptorOwner(
                descriptors: [
                    retainedReadOnlyDescriptor ?? -1,
                    retainedReadOnlyDirectoryDescriptor ?? -1,
                    retainedReadOnlyCoordinationDescriptor ?? -1,
                ]
            )
            SQLiteFailedResourceRegistry.shared.retain(owner)
        } else {
            if let retainedReadOnlyDescriptor {
                _ = Darwin.close(retainedReadOnlyDescriptor)
            }
            if let retainedReadOnlyDirectoryDescriptor {
                _ = Darwin.close(retainedReadOnlyDirectoryDescriptor)
            }
            if let retainedReadOnlyCoordinationDescriptor {
                _ = flock(retainedReadOnlyCoordinationDescriptor, LOCK_UN)
                _ = Darwin.close(retainedReadOnlyCoordinationDescriptor)
            }
        }
    }

    /// Explicitly closes the owned handle so migration code can prove that a
    /// subsequent verification open is a fresh connection, not a reused one.
    public func close() throws {
        guard terminalError == nil,
              authorizerState.writeAuthorization == nil,
              authorizerState.bootstrapAuthorization == nil else {
            throw misuseError(operation: .close)
        }
        var closeFailed = false
        if configuration.openMode == .readOnlyExisting ||
            configuration.openMode == .readOnlySnapshot {
            do { try revalidateReadOnlySourceNamespace() }
            catch {
                terminalError = SQLiteError(operation: .close, extendedCode: SQLITE_BUSY)
                closeFailed = true
            }
        }
        if let handle {
            guard sqlite3_get_autocommit(handle) != 0 else {
                throw misuseError(operation: .close)
            }
            let result = sqlite3_close(handle)
            if result == SQLITE_OK {
                self.handle = nil
            } else {
                closeFailed = true
            }
        }
        guard self.handle == nil else {
            let error = SQLiteError(operation: .close, extendedCode: SQLITE_IOERR)
            terminalError = error
            throw error
        }
        if let retainedWritableVFSContext {
            AmbitionsSQLiteSecureVFSDestroyContext(retainedWritableVFSContext)
            self.retainedWritableVFSContext = nil
        }
        if self.handle == nil &&
            (configuration.openMode == .readOnlyExisting ||
             configuration.openMode == .readOnlySnapshot) {
            do {
                try revalidateReadOnlySourceNamespace(
                    allowsSharedMemoryRemoval: true
                )
            }
            catch {
                terminalError = SQLiteError(operation: .close, extendedCode: SQLITE_BUSY)
                closeFailed = true
            }
        }
        if let descriptor = retainedReadOnlyDescriptor {
            let closed = Darwin.close(descriptor) == 0
            retainedReadOnlyDescriptor = nil
            if closed == false {
                SQLiteFailedResourceRegistry.shared.recordIndeterminateClose(count: 1)
                closeFailed = true
            }
        }
        if let descriptor = retainedReadOnlyDirectoryDescriptor {
            let closed = Darwin.close(descriptor) == 0
            retainedReadOnlyDirectoryDescriptor = nil
            if closed == false {
                SQLiteFailedResourceRegistry.shared.recordIndeterminateClose(count: 1)
                closeFailed = true
            }
        }
        if let descriptor = retainedReadOnlyCoordinationDescriptor {
            let unlocked = flock(descriptor, LOCK_UN) == 0
            let closed = Darwin.close(descriptor) == 0
            retainedReadOnlyCoordinationDescriptor = nil
            if unlocked == false || closed == false {
                if closed == false {
                    SQLiteFailedResourceRegistry.shared.recordIndeterminateClose(count: 1)
                }
                closeFailed = true
            }
        }
        if closeFailed {
            throw SQLiteError(operation: .close, extendedCode: SQLITE_IOERR)
        }
    }

    /// Revalidates the pinned parent, main file, and observed sidecar namespace.
    /// Verification callers invoke this immediately before accepting evidence;
    /// `close()` repeats it before and after closing SQLite's handle.
    public func revalidateReadOnlySourceNamespace(
        allowsSharedMemoryRemoval: Bool = false
    ) throws {
        guard configuration.openMode == .readOnlyExisting ||
                configuration.openMode == .readOnlySnapshot,
              let directoryDescriptor = retainedReadOnlyDirectoryDescriptor,
              let expected = retainedReadOnlyNamespace else {
            throw misuseError(operation: .open)
        }
        let observed = try Self.captureReadOnlyNamespaceIdentity(
            directoryDescriptor: directoryDescriptor,
            databaseName: databaseURL.lastPathComponent,
            requireSidecarsAbsent: configuration.openMode == .readOnlyExisting
        )
        try Self.requirePermittedNamespaceTransition(
            from: expected,
            to: observed,
            allowsSharedMemoryCreation: false,
            allowsSharedMemoryRemoval: allowsSharedMemoryRemoval
        )
        var directoryStatus = stat()
        var directoryPathStatus = stat()
        guard fstat(directoryDescriptor, &directoryStatus) == 0,
              Darwin.lstat(
                databaseURL.deletingLastPathComponent().path,
                &directoryPathStatus
              ) == 0,
              directoryStatus.st_dev == directoryPathStatus.st_dev,
              directoryStatus.st_ino == directoryPathStatus.st_ino else {
            throw SQLiteError(operation: .open, extendedCode: SQLITE_BUSY)
        }
    }

    @discardableResult
    public func execute(
        _ sql: String,
        bindings: [SQLiteBinding] = []
    ) throws -> SQLiteExecutionResult {
        guard let handle else {
            throw unavailableError(operation: .prepare)
        }
        let statement = try prepare(sql, operation: .prepare)
        defer { sqlite3_finalize(statement) }
        try bind(bindings, to: statement)

        let stepResult = sqlite3_step(statement)
        guard stepResult == SQLITE_DONE else {
            throw Self.databaseError(
                handle: handle,
                operation: .step,
                resultCode: stepResult
            )
        }
        return SQLiteExecutionResult(
            changedRowCount: sqlite3_changes(handle),
            lastInsertedRowID: sqlite3_last_insert_rowid(handle)
        )
    }

    public func query(
        _ sql: String,
        bindings: [SQLiteBinding] = []
    ) throws -> [SQLiteRow] {
        try query(
            sql,
            bindings: bindings,
            operation: .step,
            budget: .default
        )
    }

    public func query(
        _ sql: String,
        bindings: [SQLiteBinding] = [],
        maximumDecodedBytes: Int
    ) throws -> [SQLiteRow] {
        guard maximumDecodedBytes >= 0 else {
            throw SQLiteQueryBudgetExceeded(maximumBytes: maximumDecodedBytes)
        }
        return try query(
            sql,
            bindings: bindings,
            operation: .step,
            budget: try SQLiteQueryBudget(
                maximumDecodedBytes: maximumDecodedBytes,
                maximumRowCount: SQLiteQueryBudget.default.maximumRowCount,
                maximumProgressCallbacks: SQLiteQueryBudget.default.maximumProgressCallbacks,
                progressInstructionInterval: SQLiteQueryBudget.default.progressInstructionInterval
            )
        )
    }

    /// Executes one bounded materializing query. This is the preferred API for
    /// production readers: both decoded payload and VM work are finite, and a
    /// cancellation observed by SQLite interrupts the statement promptly.
    public func query(
        _ sql: String,
        bindings: [SQLiteBinding] = [],
        budget: SQLiteQueryBudget
    ) throws -> [SQLiteRow] {
        try query(sql, bindings: bindings, operation: .step, budget: budget)
    }

    /// Runs a transaction without a suspension point or actor reentrancy.
    ///
    /// The isolated synchronous closure can call database methods directly but
    /// cannot `await`. Public statements always deny transaction-control SQL;
    /// only this wrapper temporarily authorizes its own control statements.
    /// Body and commit failures trigger rollback before the original error is
    /// rethrown. An unresolved rollback closes and poisons the connection and
    /// throws `SQLiteTransactionRollbackError`, so durability is never
    /// overstated.
    public func transaction<Result: Sendable>(
        _ mode: SQLiteTransactionMode = .immediate,
        precommitValidation: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Void = { _ in },
        _ operation: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Result
    ) throws -> Result {
        try performTransaction(
            mode,
            writeAuthorization: nil,
            bootstrapAuthorization: nil,
            schemaMigrationAuthorization: nil,
            invariantCapture: nil,
            validateInvariant: nil,
            precommitValidation: precommitValidation,
            operation
        )
    }

    /// Runs a transaction whose writes are constrained by SQLite's authorizer
    /// to the supplied table capability. This is stronger than checking SQL at
    /// a call site: writes issued by triggers and dynamically prepared
    /// statements pass through the same deny-by-default boundary.
    public func transaction<Result: Sendable>(
        _ mode: SQLiteTransactionMode = .immediate,
        writeAuthorization: SQLiteWriteAuthorization,
        precommitValidation: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Void = { _ in },
        _ operation: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Result
    ) throws -> Result {
        try performTransaction(
            mode,
            writeAuthorization: writeAuthorization,
            bootstrapAuthorization: nil,
            schemaMigrationAuthorization: nil,
            invariantCapture: nil,
            validateInvariant: nil,
            precommitValidation: precommitValidation,
            operation
        )
    }

    /// Runs a scoped write transaction with an internal before/after invariant
    /// capture. Only the capture closure receives unrestricted read authority;
    /// the operation closure remains constrained to its explicit read/write
    /// capability. Connection-wide operations remain denied throughout.
    public func transaction<Result: Sendable>(
        _ mode: SQLiteTransactionMode = .immediate,
        writeAuthorization: SQLiteWriteAuthorization,
        invariantCapture: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Data,
        validateInvariant: @escaping @Sendable (_ before: Data, _ after: Data) throws -> Void,
        precommitValidation: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Void = { _ in },
        _ operation: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Result
    ) throws -> Result {
        try performTransaction(
            mode,
            writeAuthorization: writeAuthorization,
            bootstrapAuthorization: nil,
            schemaMigrationAuthorization: nil,
            invariantCapture: invariantCapture,
            validateInvariant: validateInvariant,
            precommitValidation: precommitValidation,
            operation
        )
    }

    /// Constructs a fresh schema under an explicit object allow-list. This is
    /// intentionally separate from normal mutation authority; the ordinary
    /// transaction APIs cannot issue DDL.
    public func bootstrapTransaction<Result: Sendable>(
        _ mode: SQLiteTransactionMode = .exclusive,
        authorization: SQLiteBootstrapAuthorization,
        precommitValidation: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Void = { _ in },
        _ operation: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Result
    ) throws -> Result {
        try performTransaction(
            mode,
            writeAuthorization: nil,
            bootstrapAuthorization: authorization,
            schemaMigrationAuthorization: nil,
            invariantCapture: nil,
            validateInvariant: nil,
            precommitValidation: precommitValidation,
            operation
        )
    }

    /// Applies a recognized in-place schema delta under a capability distinct
    /// from both normal writes and fresh-store bootstrap.
    public func schemaMigrationTransaction<Result: Sendable>(
        _ mode: SQLiteTransactionMode = .exclusive,
        authorization: SQLiteSchemaMigrationAuthorization,
        precommitValidation: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Void = { _ in },
        _ operation: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Result
    ) throws -> Result {
        try performTransaction(
            mode,
            writeAuthorization: nil,
            bootstrapAuthorization: nil,
            schemaMigrationAuthorization: authorization,
            invariantCapture: nil,
            validateInvariant: nil,
            precommitValidation: precommitValidation,
            operation
        )
    }

    private func performTransaction<Result: Sendable>(
        _ mode: SQLiteTransactionMode,
        writeAuthorization: SQLiteWriteAuthorization?,
        bootstrapAuthorization: SQLiteBootstrapAuthorization?,
        schemaMigrationAuthorization: SQLiteSchemaMigrationAuthorization?,
        invariantCapture: (@Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Data)?,
        validateInvariant: (@Sendable (_ before: Data, _ after: Data) throws -> Void)?,
        precommitValidation: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Void,
        _ operation: @escaping @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Result
    ) throws -> Result {
        guard let handle, sqlite3_get_autocommit(handle) != 0 else {
            throw misuseError(operation: .transaction)
        }
        guard authorizerState.writeAuthorization == nil,
              authorizerState.bootstrapAuthorization == nil,
              authorizerState.schemaMigrationAuthorization == nil else {
            throw misuseError(operation: .transaction)
        }
        authorizerState.writeAuthorization = writeAuthorization
        authorizerState.bootstrapAuthorization = bootstrapAuthorization
        authorizerState.schemaMigrationAuthorization = schemaMigrationAuthorization
        defer {
            authorizerState.writeAuthorization = nil
            authorizerState.bootstrapAuthorization = nil
            authorizerState.schemaMigrationAuthorization = nil
        }
        do {
            try executeTransactionStatement("BEGIN \(mode.rawValue) TRANSACTION")
        } catch {
            let beginError = error
            if let activeHandle = self.handle,
               sqlite3_get_autocommit(activeHandle) == 0 {
                try rollback(after: .body)
            }
            throw beginError
        }
        guard sqlite3_get_autocommit(handle) == 0 else {
            throw misuseError(operation: .transaction)
        }

        let invariantBefore: Data?
        do {
            authorizerState.allowsInvariantReads = invariantCapture != nil
            invariantBefore = try invariantCapture?(self)
            authorizerState.allowsInvariantReads = false
        } catch {
            authorizerState.allowsInvariantReads = false
            try rollback(after: .body)
            throw error
        }

        let result: Result
        do {
            result = try operation(self)
        } catch {
            let bodyError = error
            try rollback(after: .body)
            throw bodyError
        }

        if let invariantCapture, let validateInvariant, let invariantBefore {
            do {
                authorizerState.allowsInvariantReads = true
                let invariantAfter = try invariantCapture(self)
                authorizerState.allowsInvariantReads = false
                try validateInvariant(invariantBefore, invariantAfter)
            } catch {
                authorizerState.allowsInvariantReads = false
                try rollback(after: .body)
                throw error
            }
        }

        do {
            authorizerState.allowsPrecommitValidationReads = true
            authorizerState.precommitValidationIsReadOnly = true
            try precommitValidation(self)
            authorizerState.precommitValidationIsReadOnly = false
            authorizerState.allowsPrecommitValidationReads = false
        } catch {
            authorizerState.precommitValidationIsReadOnly = false
            authorizerState.allowsPrecommitValidationReads = false
            try rollback(after: .body)
            throw error
        }

        do {
            try executeTransactionStatement("COMMIT TRANSACTION")
            guard sqlite3_get_autocommit(handle) != 0 else {
                throw misuseError(operation: .transaction)
            }
        } catch {
            let commitError = error
            if let activeHandle = self.handle,
               sqlite3_get_autocommit(activeHandle) != 0 {
                throw SQLiteTransactionCommitIndeterminateError(
                    commitFailure: commitError as? SQLiteError
                        ?? misuseError(operation: .transaction)
                )
            }
            if self.handle != nil {
                try rollback(after: .commit)
            }
            throw commitError
        }
        return result
    }

    public func checkpoint(
        _ mode: SQLiteCheckpointMode = .passive
    ) throws -> SQLiteCheckpointResult {
        guard configuration.openMode != .readOnlyExisting,
              configuration.openMode != .readOnlySnapshot,
              authorizerState.writeAuthorization == nil,
              authorizerState.bootstrapAuthorization == nil,
              authorizerState.precommitValidationIsReadOnly == false else {
            throw misuseError(operation: .checkpoint)
        }
        guard let handle else {
            throw unavailableError(operation: .checkpoint)
        }
        var logFrameCount: Int32 = 0
        var checkpointedFrameCount: Int32 = 0
        let result = sqlite3_wal_checkpoint_v2(
            handle,
            "main",
            mode.sqliteValue,
            &logFrameCount,
            &checkpointedFrameCount
        )
        guard result == SQLITE_OK else {
            throw Self.databaseError(
                handle: handle,
                operation: .checkpoint,
                resultCode: result
            )
        }
        return SQLiteCheckpointResult(
            logFrameCount: logFrameCount,
            checkpointedFrameCount: checkpointedFrameCount
        )
    }

    public func backup(
        to destinationURL: URL,
        pagesPerStep: Int32 = 128,
        busyRetryLimit: Int = 50,
        prepareReservedDestination: @Sendable (
            URL,
            SQLiteReservedFileIdentity,
            Int32
        ) throws -> Void = { _, _, _ in }
    ) throws -> SQLiteBackupResult {
        guard authorizerState.writeAuthorization == nil,
              authorizerState.bootstrapAuthorization == nil,
              authorizerState.precommitValidationIsReadOnly == false else {
            throw misuseError(operation: .backup)
        }
        guard let sourceHandle = handle,
              pagesPerStep > 0,
              busyRetryLimit >= 0
        else {
            throw misuseError(operation: .backup)
        }
        if configuration.openMode == .readOnlyExisting ||
            configuration.openMode == .readOnlySnapshot {
            try revalidateReadOnlySourceNamespace()
        }

        let destinationURL = destinationURL.standardizedFileURL
        guard destinationURL != databaseURL else {
            throw misuseError(operation: .backup)
        }
        let destinationDirectory = destinationURL.deletingLastPathComponent()
        let destinationName = destinationURL.lastPathComponent
        guard destinationName.isEmpty == false,
              destinationName != ".", destinationName != "..",
              destinationName.utf8.allSatisfy({ $0 != 0 && $0 != 47 }),
              destinationDirectory.appendingPathComponent(destinationName)
                .standardizedFileURL == destinationURL else {
            throw SQLiteError(operation: .backup, extendedCode: SQLITE_CANTOPEN)
        }
        do {
            try FileManager.default.createDirectory(
                at: destinationDirectory,
                withIntermediateDirectories: true
            )
        } catch {
            throw SQLiteError(
                operation: .backup,
                extendedCode: SQLITE_CANTOPEN
            )
        }
        // Reserve and retain the destination descriptor. SQLite writes through
        // /dev/fd so a pathname swap after reservation cannot redirect private
        // pages into another inode. The parent directory identity is pinned
        // across publication and durability proof.
        let directoryDescriptor = Darwin.open(
            destinationDirectory.path,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        var directoryStatus = stat()
        guard directoryDescriptor >= 0,
              fstat(directoryDescriptor, &directoryStatus) == 0,
              directoryStatus.st_mode & S_IFMT == S_IFDIR else {
            let owner = SQLiteDescriptorOwner(descriptors: [directoryDescriptor])
            let closeFailed = owner.closeAll() == false
            if closeFailed { SQLiteFailedResourceRegistry.shared.retain(owner) }
            throw SQLiteError(
                operation: .backup,
                extendedCode: closeFailed ? SQLITE_IOERR : SQLITE_CANTOPEN
            )
        }
        for suffix in ["-wal", "-shm", "-journal"] {
            var sidecarStatus = stat()
            guard fstatat(
                directoryDescriptor, destinationName + suffix,
                &sidecarStatus, AT_SYMLINK_NOFOLLOW
            ) != 0, errno == ENOENT else {
                let owner = SQLiteDescriptorOwner(descriptors: [directoryDescriptor])
                let closed = owner.closeAll()
                if closed == false { SQLiteFailedResourceRegistry.shared.retain(owner) }
                throw SQLiteError(
                    operation: .backup,
                    extendedCode: closed ? SQLITE_CANTOPEN : SQLITE_IOERR
                )
            }
        }
        let reservedDescriptor = Darwin.openat(
            directoryDescriptor,
            destinationName,
            O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard reservedDescriptor >= 0 else {
            let owner = SQLiteDescriptorOwner(descriptors: [directoryDescriptor])
            let directoryClosed = owner.closeAll()
            if directoryClosed == false {
                SQLiteFailedResourceRegistry.shared.retain(owner)
            }
            throw SQLiteError(
                operation: .backup,
                extendedCode: directoryClosed ? SQLITE_CANTOPEN : SQLITE_IOERR
            )
        }
        var reservedStatus = stat()
        let reservedStatusResult = fstat(reservedDescriptor, &reservedStatus)
        guard reservedStatusResult == 0,
              reservedStatus.st_mode & S_IFMT == S_IFREG,
              reservedStatus.st_nlink == 1 else {
            if reservedStatusResult == 0 {
                var observed = stat()
                if fstatat(
                    directoryDescriptor, destinationName, &observed,
                    AT_SYMLINK_NOFOLLOW
                ) == 0,
                   observed.st_dev == reservedStatus.st_dev,
                   observed.st_ino == reservedStatus.st_ino,
                   observed.st_nlink == 1 {
                    _ = Darwin.unlinkat(directoryDescriptor, destinationName, 0)
                }
            }
            let owner = SQLiteDescriptorOwner(
                descriptors: [reservedDescriptor, directoryDescriptor]
            )
            if owner.closeAll() == false {
                SQLiteFailedResourceRegistry.shared.retain(owner)
            }
            throw SQLiteError(operation: .backup, extendedCode: SQLITE_IOERR)
        }
        var reservedDescriptorOpen = true
        var directoryDescriptorOpen = true

        func closeReservedDescriptorOnce() -> Bool {
            guard reservedDescriptorOpen else { return true }
            let result = Darwin.close(reservedDescriptor)
            if result == 0 { reservedDescriptorOpen = false }
            return result == 0
        }

        func closeDirectoryDescriptorOnce() -> Bool {
            guard directoryDescriptorOpen else { return true }
            let result = Darwin.close(directoryDescriptor)
            if result == 0 { directoryDescriptorOpen = false }
            return result == 0
        }

        func closeOwnedDescriptors() -> Bool {
            let reservedClosed = closeReservedDescriptorOnce()
            let directoryClosed = closeDirectoryDescriptorOnce()
            if reservedClosed == false || directoryClosed == false {
                SQLiteFailedResourceRegistry.shared.recordIndeterminateClose(
                    count: [reservedClosed, directoryClosed]
                        .filter { $0 == false }.count
                )
                reservedDescriptorOpen = false
                directoryDescriptorOpen = false
            }
            return reservedClosed && directoryClosed
        }

        func reservedIdentityStillOwned() -> Bool {
            var descriptorStatus = stat()
            var pathStatus = stat()
            return fstat(reservedDescriptor, &descriptorStatus) == 0 &&
                fstatat(
                    directoryDescriptor, destinationName, &pathStatus,
                    AT_SYMLINK_NOFOLLOW
                ) == 0 &&
                descriptorStatus.st_dev == reservedStatus.st_dev &&
                descriptorStatus.st_ino == reservedStatus.st_ino &&
                pathStatus.st_dev == reservedStatus.st_dev &&
                pathStatus.st_ino == reservedStatus.st_ino &&
                descriptorStatus.st_nlink == 1 && pathStatus.st_nlink == 1
        }

        func destinationSidecarsAreAbsent() -> Bool {
            for suffix in ["-wal", "-shm", "-journal"] {
                var status = stat()
                if fstatat(
                    directoryDescriptor, destinationName + suffix,
                    &status, AT_SYMLINK_NOFOLLOW
                ) == 0 || errno != ENOENT {
                    return false
                }
            }
            return true
        }

        func destinationParentPathStillPinned() -> Bool {
            let reopened = Darwin.open(
                destinationDirectory.path,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            )
            guard reopened >= 0 else { return false }
            var reopenedStatus = stat()
            var pathStatus = stat()
            let matches = fstat(reopened, &reopenedStatus) == 0 &&
                Darwin.lstat(destinationDirectory.path, &pathStatus) == 0 &&
                reopenedStatus.st_mode & S_IFMT == S_IFDIR &&
                pathStatus.st_mode & S_IFMT == S_IFDIR &&
                reopenedStatus.st_dev == directoryStatus.st_dev &&
                reopenedStatus.st_ino == directoryStatus.st_ino &&
                pathStatus.st_dev == directoryStatus.st_dev &&
                pathStatus.st_ino == directoryStatus.st_ino
            let owner = SQLiteDescriptorOwner(descriptors: [reopened])
            let closed = owner.closeAll()
            if closed == false {
                SQLiteFailedResourceRegistry.shared.retain(owner)
            }
            return matches && closed
        }
        do {
            // The caller may establish platform file-protection metadata after
            // exclusive pathname reservation but before SQLite writes page 1.
            try prepareReservedDestination(
                destinationURL,
                SQLiteReservedFileIdentity(
                    device: UInt64(reservedStatus.st_dev),
                    inode: UInt64(reservedStatus.st_ino)
                ),
                reservedDescriptor
            )
            guard reservedIdentityStillOwned() else {
                throw SQLiteError(operation: .backup, extendedCode: SQLITE_IOERR)
            }
        } catch {
            quarantineReservedDestinationIfOwned()
            guard closeOwnedDescriptors() else {
                throw SQLiteError(operation: .backup, extendedCode: SQLITE_IOERR)
            }
            throw error
        }

        func quarantineReservedDestinationIfOwned() {
            var observed = stat()
            guard fstatat(
                    directoryDescriptor, destinationName, &observed,
                    AT_SYMLINK_NOFOLLOW
                  ) == 0,
                  observed.st_dev == reservedStatus.st_dev,
                  observed.st_ino == reservedStatus.st_ino,
                  observed.st_nlink == 1 else { return }
            let failedName =
                ".failed-backup-\(UInt64(reservedStatus.st_dev))-\(UInt64(reservedStatus.st_ino))"
            guard Darwin.renameatx_np(
                directoryDescriptor, destinationName,
                directoryDescriptor, failedName,
                UInt32(RENAME_EXCL)
            ) == 0 else { return }
            // Sidecars are not moved: they are not opened, pinned, or proven
            // to belong to this backup attempt. Their presence is ambiguous
            // evidence and causes the operation to fail closed.
            if directoryDescriptorOpen {
                _ = Darwin.fsync(directoryDescriptor)
            }
        }

        guard AmbitionsSQLiteSecureVFSInstall() == SQLITE_OK,
              let backupVFSContext = AmbitionsSQLiteSecureVFSCreateContext(
                  directoryDescriptor,
                  destinationName
              ),
              let backupVirtualPath = AmbitionsSQLiteSecureVFSDatabasePath(
                  backupVFSContext
              ) else {
            quarantineReservedDestinationIfOwned()
            _ = closeOwnedDescriptors()
            throw SQLiteError(operation: .backup, extendedCode: SQLITE_CANTOPEN)
        }
        // The VFS context owns a duplicate of the pinned directory descriptor.
        // It is released only after SQLite confirms a synchronous close. A
        // refused close retains both resources process-lifetime, because the
        // VFS may still be called by SQLite.
        var backupVFSContextRetainedAfterCloseFailure = false
        defer {
            if backupVFSContextRetainedAfterCloseFailure == false {
                AmbitionsSQLiteSecureVFSDestroyContext(backupVFSContext)
            }
        }

        var destinationHandle: OpaquePointer?
        func retainDestinationAfterFailedClose(_ handle: OpaquePointer, _ result: Int32) {
            guard result != SQLITE_OK else { return }
            SQLiteFailedResourceRegistry.shared.retainSQLiteConnection(
                handle,
                writableVFSContext: backupVFSContext
            )
            backupVFSContextRetainedAfterCloseFailure = true
        }
        let openResult = sqlite3_open_v2(
            String(cString: backupVirtualPath),
            &destinationHandle,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX,
            AmbitionsSQLiteSecureVFSName()
        )
        guard openResult == SQLITE_OK, let destinationHandle else {
            var destinationClosed = true
            if let destinationHandle {
                let closeResult = sqlite3_close(destinationHandle)
                destinationClosed = closeResult == SQLITE_OK
                retainDestinationAfterFailedClose(destinationHandle, closeResult)
            }
            guard destinationClosed else {
                _ = closeOwnedDescriptors()
                throw SQLiteError(operation: .backup, extendedCode: SQLITE_IOERR)
            }
            quarantineReservedDestinationIfOwned()
            let ownersClosed = closeOwnedDescriptors()
            throw SQLiteError(
                operation: .backup,
                extendedCode: destinationClosed == false || ownersClosed == false
                    ? SQLITE_IOERR
                    : openResult == SQLITE_OK
                    ? SQLITE_MISUSE
                    : openResult
            )
        }
        sqlite3_extended_result_codes(destinationHandle, 1)
        guard sqlite3_exec(
            destinationHandle,
            "PRAGMA journal_mode=OFF; PRAGMA synchronous=OFF;",
            nil,
            nil,
            nil
        ) == SQLITE_OK else {
            let error = Self.databaseError(
                handle: destinationHandle,
                operation: .backup,
                resultCode: sqlite3_errcode(destinationHandle)
            )
            let closeResult = sqlite3_close(destinationHandle)
            let destinationClosed = closeResult == SQLITE_OK
            retainDestinationAfterFailedClose(destinationHandle, closeResult)
            guard destinationClosed else {
                _ = closeOwnedDescriptors()
                throw SQLiteError(operation: .backup, extendedCode: SQLITE_IOERR)
            }
            quarantineReservedDestinationIfOwned()
            let ownersClosed = closeOwnedDescriptors()
            if destinationClosed == false || ownersClosed == false {
                throw SQLiteError(operation: .backup, extendedCode: SQLITE_IOERR)
            }
            throw error
        }

        guard let backup = sqlite3_backup_init(
            destinationHandle,
            "main",
            sourceHandle,
            "main"
        ) else {
            let error = Self.databaseError(
                handle: destinationHandle,
                operation: .backup,
                resultCode: sqlite3_errcode(destinationHandle),
                fallbackCode: SQLITE_ERROR
            )
            let closeResult = sqlite3_close(destinationHandle)
            let destinationClosed = closeResult == SQLITE_OK
            retainDestinationAfterFailedClose(destinationHandle, closeResult)
            guard destinationClosed else {
                _ = closeOwnedDescriptors()
                throw SQLiteError(operation: .backup, extendedCode: SQLITE_IOERR)
            }
            quarantineReservedDestinationIfOwned()
            let ownersClosed = closeOwnedDescriptors()
            if destinationClosed == false || ownersClosed == false {
                throw SQLiteError(operation: .backup, extendedCode: SQLITE_IOERR)
            }
            throw error
        }

        var retriesRemaining = busyRetryLimit
        var stepResult: Int32
        repeat {
            if Task.isCancelled {
                stepResult = SQLITE_INTERRUPT
                break
            }
            stepResult = sqlite3_backup_step(backup, pagesPerStep)
            if stepResult == SQLITE_BUSY || stepResult == SQLITE_LOCKED {
                guard retriesRemaining > 0 else { break }
                retriesRemaining -= 1
                sqlite3_sleep(10)
            }
        } while stepResult == SQLITE_OK
            || stepResult == SQLITE_BUSY
            || stepResult == SQLITE_LOCKED

        let pageCount = sqlite3_backup_pagecount(backup)
        let remainingPageCount = sqlite3_backup_remaining(backup)
        let finishResult = sqlite3_backup_finish(backup)
        let closeResult = sqlite3_close(destinationHandle)
        retainDestinationAfterFailedClose(destinationHandle, closeResult)
        guard closeResult == SQLITE_OK else {
            _ = closeOwnedDescriptors()
            throw SQLiteError(operation: .backup, extendedCode: SQLITE_IOERR)
        }
        guard stepResult == SQLITE_DONE,
              remainingPageCount == 0,
              finishResult == SQLITE_OK else {
            let result = stepResult == SQLITE_DONE ? finishResult : stepResult
            quarantineReservedDestinationIfOwned()
            guard closeOwnedDescriptors() else {
                throw SQLiteError(operation: .backup, extendedCode: SQLITE_IOERR)
            }
            if Task.isCancelled { throw CancellationError() }
            throw SQLiteError(
                operation: .backup,
                extendedCode: result == SQLITE_OK ? closeResult : result
            )
        }
        var completedStatus = stat()
        var completedPathStatus = stat()
        var completedDirectoryStatus = stat()
        guard fstat(reservedDescriptor, &completedStatus) == 0,
              fstatat(
                directoryDescriptor, destinationName, &completedPathStatus,
                AT_SYMLINK_NOFOLLOW
              ) == 0,
              fstat(directoryDescriptor, &completedDirectoryStatus) == 0,
              completedStatus.st_dev == reservedStatus.st_dev,
              completedStatus.st_ino == reservedStatus.st_ino,
              completedPathStatus.st_dev == reservedStatus.st_dev,
              completedPathStatus.st_ino == reservedStatus.st_ino,
              completedStatus.st_nlink == 1,
              completedPathStatus.st_nlink == 1,
              completedDirectoryStatus.st_dev == directoryStatus.st_dev,
              completedDirectoryStatus.st_ino == directoryStatus.st_ino,
              destinationSidecarsAreAbsent(),
              Darwin.fsync(reservedDescriptor) == 0,
              Darwin.fsync(directoryDescriptor) == 0,
              destinationParentPathStillPinned() else {
            quarantineReservedDestinationIfOwned()
            _ = closeOwnedDescriptors()
            throw SQLiteError(operation: .backup, extendedCode: SQLITE_IOERR)
        }
        guard closeOwnedDescriptors() else {
            quarantineReservedDestinationIfOwned()
            throw SQLiteError(operation: .backup, extendedCode: SQLITE_IOERR)
        }
        if configuration.openMode == .readOnlyExisting ||
            configuration.openMode == .readOnlySnapshot {
            try revalidateReadOnlySourceNamespace()
        }
        return SQLiteBackupResult(
            pageCount: pageCount,
            remainingPageCount: remainingPageCount
        )
    }

    public func integrityCheck(
        budget: SQLiteQueryBudget = .diagnostics
    ) throws -> SQLiteIntegrityResult {
        guard authorizerState.bootstrapAuthorization == nil,
              authorizerState.writeAuthorization == nil ||
                authorizerState.precommitValidationIsReadOnly else {
            throw misuseError(operation: .integrityCheck)
        }
        let rows = try query(
            "PRAGMA integrity_check",
            bindings: [],
            operation: .integrityCheck,
            budget: budget
        )
        let messages = rows.compactMap { row -> String? in
            guard case let .text(message) = row.values.first else { return nil }
            return message
        }
        guard messages.count == rows.count, !messages.isEmpty else {
            throw misuseError(operation: .integrityCheck)
        }
        return SQLiteIntegrityResult(messages: messages)
    }

    public func foreignKeyCheck(
        budget: SQLiteQueryBudget = .diagnostics
    ) throws -> [SQLiteForeignKeyViolation] {
        guard authorizerState.bootstrapAuthorization == nil,
              authorizerState.writeAuthorization == nil ||
                authorizerState.precommitValidationIsReadOnly else {
            throw misuseError(operation: .foreignKeyCheck)
        }
        let rows = try query(
            "PRAGMA foreign_key_check",
            bindings: [],
            operation: .foreignKeyCheck,
            budget: budget
        )
        return try rows.map { row in
            guard row.values.count == 4,
                  case let .text(table) = row.values[0],
                  case let .text(parentTable) = row.values[2],
                  case let .integer(constraintIndex) = row.values[3]
            else {
                throw misuseError(operation: .foreignKeyCheck)
            }
            let rowID: Int64?
            switch row.values[1] {
            case let .integer(value):
                rowID = value
            case .null:
                rowID = nil
            default:
                throw misuseError(operation: .foreignKeyCheck)
            }
            return SQLiteForeignKeyViolation(
                table: table,
                rowID: rowID,
                parentTable: parentTable,
                constraintIndex: constraintIndex
            )
        }
    }
}

private extension SQLiteDatabase {
    static func configure(
        _ handle: OpaquePointer,
        configuration: SQLiteConfiguration
    ) throws {
        let busyTimeoutResult = sqlite3_busy_timeout(
            handle,
            configuration.busyTimeoutMilliseconds
        )
        guard busyTimeoutResult == SQLITE_OK else {
            throw Self.databaseError(
                handle: handle,
                operation: .configure,
                resultCode: busyTimeoutResult
            )
        }
        try executeRaw("PRAGMA foreign_keys=ON", handle: handle)
        if configuration.openMode == .readOnlyExisting ||
            configuration.openMode == .readOnlySnapshot {
            try executeRaw("PRAGMA query_only=ON", handle: handle)
        } else {
            try executeRaw(
                "PRAGMA journal_mode=\(configuration.journalMode.rawValue)",
                handle: handle
            )
            try executeRaw(
                "PRAGMA synchronous=\(configuration.synchronousPolicy.rawValue)",
                handle: handle
            )
        }
        if let maximumValueBytes = configuration.maximumValueBytes {
            _ = sqlite3_limit(handle, SQLITE_LIMIT_LENGTH, maximumValueBytes)
            guard sqlite3_limit(handle, SQLITE_LIMIT_LENGTH, -1) == maximumValueBytes else {
                throw SQLiteError(
                    operation: .configure,
                    extendedCode: SQLITE_MISUSE
                )
            }
        }
    }

    static func captureReadOnlyNamespaceIdentity(
        directoryDescriptor: Int32,
        databaseName: String,
        requireSidecarsAbsent: Bool
    ) throws -> SQLiteReadOnlyNamespaceIdentity {
        var directoryStatus = stat()
        var databaseStatus = stat()
        guard fstat(directoryDescriptor, &directoryStatus) == 0,
              fstatat(
                directoryDescriptor, databaseName, &databaseStatus,
                AT_SYMLINK_NOFOLLOW
              ) == 0,
              directoryStatus.st_mode & S_IFMT == S_IFDIR,
              databaseStatus.st_mode & S_IFMT == S_IFREG,
              databaseStatus.st_nlink == 1 else {
            throw SQLiteError(operation: .open, extendedCode: SQLITE_BUSY)
        }
        var sidecars: [String: SQLiteOptionalFileIdentity] = [:]
        for suffix in ["-wal", "-shm", "-journal"] {
            var status = stat()
            if fstatat(
                directoryDescriptor, databaseName + suffix, &status,
                AT_SYMLINK_NOFOLLOW
            ) == 0 {
                guard requireSidecarsAbsent == false,
                      status.st_mode & S_IFMT == S_IFREG,
                      status.st_nlink == 1,
                      status.st_size >= 0 else {
                    throw SQLiteError(operation: .open, extendedCode: SQLITE_BUSY)
                }
                sidecars[suffix] = .present(
                    device: UInt64(status.st_dev),
                    inode: UInt64(status.st_ino),
                    byteCount: Int64(status.st_size)
                )
            } else {
                guard errno == ENOENT else {
                    throw SQLiteError(operation: .open, extendedCode: SQLITE_BUSY)
                }
                sidecars[suffix] = .absent
            }
        }
        return SQLiteReadOnlyNamespaceIdentity(
            directoryDevice: UInt64(directoryStatus.st_dev),
            directoryInode: UInt64(directoryStatus.st_ino),
            databaseDevice: UInt64(databaseStatus.st_dev),
            databaseInode: UInt64(databaseStatus.st_ino),
            databaseByteCount: Int64(databaseStatus.st_size),
            sidecars: sidecars
        )
    }

    static func requirePermittedNamespaceTransition(
        from expected: SQLiteReadOnlyNamespaceIdentity,
        to observed: SQLiteReadOnlyNamespaceIdentity,
        allowsSharedMemoryCreation: Bool,
        allowsSharedMemoryRemoval: Bool = false
    ) throws {
        guard expected.directoryDevice == observed.directoryDevice,
              expected.directoryInode == observed.directoryInode,
              expected.databaseDevice == observed.databaseDevice,
              expected.databaseInode == observed.databaseInode,
              expected.databaseByteCount == observed.databaseByteCount else {
            throw SQLiteError(operation: .open, extendedCode: SQLITE_BUSY)
        }
        for suffix in ["-wal", "-shm", "-journal"] {
            let prior = expected.sidecars[suffix] ?? .absent
            let current = observed.sidecars[suffix] ?? .absent
            if prior == current { continue }
            if suffix == "-shm",
               case let .present(priorDevice, priorInode, _) = prior,
               case let .present(currentDevice, currentInode, _) = current,
               priorDevice == currentDevice, priorInode == currentInode {
                // SQLite's read-only WAL path may update coordination bytes in
                // the already-bound SHM inode. Identity replacement is never
                // accepted, and main/WAL/journal bytes remain exact.
                continue
            }
            if suffix == "-shm", allowsSharedMemoryRemoval,
               case .present = prior, current == .absent {
                continue
            }
            guard suffix == "-shm", allowsSharedMemoryCreation,
                  prior == .absent,
                  case .present = current else {
                throw SQLiteError(operation: .open, extendedCode: SQLITE_BUSY)
            }
        }
    }

    static func executeRaw(
        _ sql: String,
        handle: OpaquePointer
    ) throws {
        let result = sqlite3_exec(handle, sql, nil, nil, nil)
        guard result == SQLITE_OK else {
            throw Self.databaseError(
                handle: handle,
                operation: .configure,
                resultCode: result
            )
        }
    }

    func prepare(
        _ sql: String,
        operation: SQLiteOperation
    ) throws -> OpaquePointer {
        guard let handle else {
            throw unavailableError(operation: operation)
        }
        var statement: OpaquePointer?
        let result = sqlite3_prepare_v2(handle, sql, -1, &statement, nil)
        guard result == SQLITE_OK else {
            throw Self.databaseError(
                handle: handle,
                operation: operation,
                resultCode: result
            )
        }
        guard let statement else {
            throw misuseError(operation: operation)
        }
        return statement
    }

    func bind(
        _ bindings: [SQLiteBinding],
        to statement: OpaquePointer
    ) throws {
        guard let handle else {
            throw unavailableError(operation: .bind)
        }
        guard Int(sqlite3_bind_parameter_count(statement)) == bindings.count else {
            throw misuseError(operation: .bind)
        }

        for (offset, binding) in bindings.enumerated() {
            let index = Int32(offset + 1)
            let result: Int32
            switch binding {
            case .null:
                result = sqlite3_bind_null(statement, index)
            case let .integer(value):
                result = sqlite3_bind_int64(statement, index, value)
            case let .real(value):
                result = sqlite3_bind_double(statement, index, value)
            case let .text(value):
                let utf8 = value.utf8CString
                result = utf8.withUnsafeBufferPointer { buffer in
                    sqlite3_bind_text64(
                        statement,
                        index,
                        buffer.baseAddress,
                        UInt64(buffer.count - 1),
                        sqliteTransient,
                        UInt8(SQLITE_UTF8)
                    )
                }
            case let .blob(value) where value.isEmpty:
                result = sqlite3_bind_zeroblob(statement, index, 0)
            case let .blob(value):
                result = value.withUnsafeBytes { bytes in
                    sqlite3_bind_blob64(
                        statement,
                        index,
                        bytes.baseAddress,
                        UInt64(value.count),
                        sqliteTransient
                    )
                }
            }
            guard result == SQLITE_OK else {
                throw Self.databaseError(
                    handle: handle,
                    operation: .bind,
                    resultCode: result
                )
            }
        }
    }

    func query(
        _ sql: String,
        bindings: [SQLiteBinding],
        operation: SQLiteOperation,
        budget: SQLiteQueryBudget
    ) throws -> [SQLiteRow] {
        guard let handle else {
            throw unavailableError(operation: operation)
        }
        let statement = try prepare(sql, operation: operation)
        defer { sqlite3_finalize(statement) }
        try bind(bindings, to: statement)

        let progressState = SQLiteQueryProgressState(
            maximumCallbacks: budget.maximumProgressCallbacks
        )
        sqlite3_progress_handler(
            handle,
            budget.progressInstructionInterval,
            sqliteQueryProgressHandler,
            Unmanaged.passUnretained(progressState).toOpaque()
        )
        defer { sqlite3_progress_handler(handle, 0, nil, nil) }

        var rows: [SQLiteRow] = []
        var decodedBytes = 0
        while true {
            if Task.isCancelled {
                progressState.interrupt(for: .cancelled)
                throw SQLiteQueryBudgetExceeded(
                    limit: .cancelled,
                    maximumBytes: budget.maximumDecodedBytes,
                    maximumRowCount: budget.maximumRowCount,
                    maximumProgressCallbacks: budget.maximumProgressCallbacks
                )
            }
            let stepResult = sqlite3_step(statement)
            switch stepResult {
            case SQLITE_ROW:
                guard rows.count < budget.maximumRowCount else {
                    throw SQLiteQueryBudgetExceeded(
                        limit: .rowCount,
                        maximumBytes: budget.maximumDecodedBytes,
                        maximumRowCount: budget.maximumRowCount,
                        maximumProgressCallbacks: budget.maximumProgressCallbacks
                    )
                }
                let rowBytes = decodedByteCount(of: statement)
                let (next, overflow) = decodedBytes.addingReportingOverflow(rowBytes)
                guard overflow == false, next <= budget.maximumDecodedBytes else {
                    throw SQLiteQueryBudgetExceeded(
                        limit: .decodedBytes,
                        maximumBytes: budget.maximumDecodedBytes,
                        maximumRowCount: budget.maximumRowCount,
                        maximumProgressCallbacks: budget.maximumProgressCallbacks
                    )
                }
                decodedBytes = next
                rows.append(try readRow(statement))
            case SQLITE_DONE:
                return rows
            case SQLITE_INTERRUPT:
                guard let limit = progressState.interruptionLimit else {
                    throw Self.databaseError(
                        handle: handle,
                        operation: operation,
                        resultCode: stepResult
                    )
                }
                throw SQLiteQueryBudgetExceeded(
                    limit: limit,
                    maximumBytes: budget.maximumDecodedBytes,
                    maximumRowCount: budget.maximumRowCount,
                    maximumProgressCallbacks: budget.maximumProgressCallbacks
                )
            default:
                throw Self.databaseError(
                    handle: handle,
                    operation: operation,
                    resultCode: stepResult
                )
            }
        }
    }

    func decodedByteCount(of statement: OpaquePointer) -> Int {
        var total = 0
        for index in 0..<sqlite3_column_count(statement) {
            let bytes: Int
            switch sqlite3_column_type(statement, index) {
            case SQLITE_NULL:
                bytes = 0
            case SQLITE_INTEGER, SQLITE_FLOAT:
                bytes = MemoryLayout<Int64>.size
            default:
                bytes = Int(sqlite3_column_bytes(statement, index))
            }
            let (next, overflow) = total.addingReportingOverflow(bytes)
            if overflow { return Int.max }
            total = next
        }
        return total
    }

    func readRow(_ statement: OpaquePointer) throws -> SQLiteRow {
        let count = sqlite3_column_count(statement)
        var names: [String] = []
        var values: [SQLiteValue] = []
        names.reserveCapacity(Int(count))
        values.reserveCapacity(Int(count))

        for index in 0..<count {
            guard let columnName = sqlite3_column_name(statement, index),
                  let decodedColumnName = String(validatingCString: columnName)
            else {
                throw decodingError(extendedCode: SQLITE_CORRUPT)
            }
            names.append(decodedColumnName)
            switch sqlite3_column_type(statement, index) {
            case SQLITE_INTEGER:
                values.append(.integer(sqlite3_column_int64(statement, index)))
            case SQLITE_FLOAT:
                values.append(.real(sqlite3_column_double(statement, index)))
            case SQLITE_TEXT:
                guard let text = sqlite3_column_text(statement, index) else {
                    throw decodingError(extendedCode: SQLITE_CORRUPT)
                }
                let byteCount = Int(sqlite3_column_bytes(statement, index))
                let buffer = UnsafeBufferPointer(
                    start: text,
                    count: byteCount
                )
                guard let value = String(bytes: buffer, encoding: .utf8) else {
                    throw decodingError(extendedCode: SQLITE_MISMATCH)
                }
                values.append(.text(value))
            case SQLITE_BLOB:
                let count = Int(sqlite3_column_bytes(statement, index))
                if count == 0 {
                    values.append(.blob(Data()))
                } else if let bytes = sqlite3_column_blob(statement, index) {
                    values.append(.blob(Data(bytes: bytes, count: count)))
                } else {
                    throw decodingError(extendedCode: SQLITE_CORRUPT)
                }
            case SQLITE_NULL:
                values.append(.null)
            default:
                throw decodingError(extendedCode: SQLITE_CORRUPT)
            }
        }
        return SQLiteRow(columnNames: names, values: values)
    }

    func decodingError(extendedCode: Int32) -> SQLiteError {
        SQLiteError(operation: .decode, extendedCode: extendedCode)
    }

    func executeTransactionStatement(_ sql: String) throws {
        guard let handle else {
            throw unavailableError(operation: .transaction)
        }
        precondition(!authorizerState.allowsInternalTransactionControl)
        authorizerState.allowsInternalTransactionControl = true
        defer { authorizerState.allowsInternalTransactionControl = false }

        var errorMessage: UnsafeMutablePointer<CChar>?
        let result = sqlite3_exec(handle, sql, nil, nil, &errorMessage)
        if let errorMessage {
            sqlite3_free(errorMessage)
        }
        guard result == SQLITE_OK else {
            throw Self.databaseError(
                handle: handle,
                operation: .transaction,
                resultCode: result
            )
        }
    }

    static func setPublicStatementAuthorizer(
        _ handle: OpaquePointer,
        state: SQLiteAuthorizerState
    ) throws {
        let result = sqlite3_set_authorizer(
            handle,
            sqlitePublicStatementAuthorizer,
            Unmanaged.passUnretained(state).toOpaque()
        )
        guard result == SQLITE_OK else {
            throw Self.databaseError(
                handle: handle,
                operation: .configure,
                resultCode: result
            )
        }
    }

    func rollback(after phase: SQLiteTransactionFailurePhase) throws {
        guard let handle else {
            throw SQLiteTransactionRollbackError(
                precedingFailure: phase,
                rollbackFailure: unavailableError(operation: .transaction)
            )
        }
        guard sqlite3_get_autocommit(handle) == 0 else {
            return
        }
        do {
            try executeTransactionStatement("ROLLBACK TRANSACTION")
        } catch {
            if let activeHandle = self.handle,
               sqlite3_get_autocommit(activeHandle) != 0 {
                return
            }
            let rollbackError = error as? SQLiteError
                ?? misuseError(operation: .transaction)
            let closeFailure = poisonConnectionAfterUnresolvedRollback(rollbackError)
            throw SQLiteTransactionRollbackError(
                precedingFailure: phase,
                rollbackFailure: rollbackError,
                closeFailure: closeFailure
            )
        }
        guard let activeHandle = self.handle,
              sqlite3_get_autocommit(activeHandle) != 0
        else {
            let rollbackError = misuseError(operation: .transaction)
            let closeFailure = poisonConnectionAfterUnresolvedRollback(rollbackError)
            throw SQLiteTransactionRollbackError(
                precedingFailure: phase,
                rollbackFailure: rollbackError,
                closeFailure: closeFailure
            )
        }
    }

    func unavailableError(operation: SQLiteOperation) -> SQLiteError {
        terminalError ?? SQLiteError(
            operation: operation,
            extendedCode: SQLITE_MISUSE
        )
    }

    func misuseError(operation: SQLiteOperation) -> SQLiteError {
        terminalError ?? SQLiteError(
            operation: operation,
            extendedCode: SQLITE_MISUSE
        )
    }

    static func databaseError(
        handle: OpaquePointer,
        operation: SQLiteOperation,
        resultCode: Int32,
        fallbackCode: Int32 = SQLITE_MISUSE
    ) -> SQLiteError {
        let observedExtendedCode = sqlite3_extended_errcode(handle)
        let immediateCode = resultCode == SQLITE_OK ? fallbackCode : resultCode
        let extendedCode: Int32
        if observedExtendedCode != SQLITE_OK,
           observedExtendedCode & 0xFF == immediateCode & 0xFF {
            extendedCode = observedExtendedCode
        } else {
            extendedCode = immediateCode == SQLITE_OK
                ? SQLITE_MISUSE
                : immediateCode
        }
        return SQLiteError(
            operation: operation,
            extendedCode: extendedCode
        )
    }
}

extension SQLiteDatabase {
    func poisonConnectionAfterUnresolvedRollback(
        _ rollbackError: SQLiteError
    ) -> SQLiteError? {
        guard terminalError == nil else { return terminalError }
        terminalError = SQLiteError(
            operation: .connection,
            extendedCode: rollbackError.extendedCode
        )
        if let handle {
            let closeResult = sqlite3_close(handle)
            if closeResult == SQLITE_OK {
                self.handle = nil
                return nil
            }
            // Do not discard a handle whose terminal close result is unknown.
            // Keeping it actor-owned and terminal prevents both reuse and an
            // overclaim that SQLite released its underlying resources.
            let closeFailure = SQLiteError(
                operation: .close,
                extendedCode: closeResult
            )
            terminalError = SQLiteError(
                operation: .connection,
                extendedCode: closeFailure.extendedCode
            )
            return closeFailure
        }
        return nil
    }
}

private extension SQLiteCheckpointMode {
    var sqliteValue: Int32 {
        switch self {
        case .passive:
            SQLITE_CHECKPOINT_PASSIVE
        case .full:
            SQLITE_CHECKPOINT_FULL
        case .restart:
            SQLITE_CHECKPOINT_RESTART
        case .truncate:
            SQLITE_CHECKPOINT_TRUNCATE
        }
    }
}

/// Synchronously consulted only while SQLite is executing on its actor-owned
/// connection. The callback cannot suspend or escape the SQLite call.
private final class SQLiteAuthorizerState {
    let connectionIsReadOnly: Bool
    var allowsInternalTransactionControl = false
    var writeAuthorization: SQLiteWriteAuthorization?
    var bootstrapAuthorization: SQLiteBootstrapAuthorization?
    var schemaMigrationAuthorization: SQLiteSchemaMigrationAuthorization?
    var allowsInvariantReads = false
    var allowsPrecommitValidationReads = false
    var precommitValidationIsReadOnly = false

    init(connectionIsReadOnly: Bool) {
        self.connectionIsReadOnly = connectionIsReadOnly
    }
}

/// Owned by a single synchronous statement execution. SQLite invokes this
/// callback on the same actor-owned connection, so no cross-thread mutation is
/// permitted or required.
private final class SQLiteQueryProgressState {
    let maximumCallbacks: Int
    var callbackCount = 0
    var interruptionLimit: SQLiteQueryBudgetLimit?

    init(maximumCallbacks: Int) {
        self.maximumCallbacks = maximumCallbacks
    }

    func interrupt(for limit: SQLiteQueryBudgetLimit) {
        interruptionLimit = limit
    }
}

private func sqliteQueryProgressHandler(
    _ context: UnsafeMutableRawPointer?
) -> Int32 {
    guard let context else { return 1 }
    let state = Unmanaged<SQLiteQueryProgressState>
        .fromOpaque(context)
        .takeUnretainedValue()
    if Task.isCancelled {
        state.interrupt(for: .cancelled)
        return 1
    }
    if state.callbackCount >= state.maximumCallbacks {
        state.interrupt(for: .virtualMachineWork)
        return 1
    }
    state.callbackCount += 1
    return 0
}

private func sqlitePublicStatementAuthorizer(
    _ context: UnsafeMutableRawPointer?,
    _ actionCode: Int32,
    _ firstDetail: UnsafePointer<CChar>?,
    _ secondDetail: UnsafePointer<CChar>?,
    _ databaseName: UnsafePointer<CChar>?,
    _ triggerName: UnsafePointer<CChar>?
) -> Int32 {
    _ = triggerName
    guard let context else { return SQLITE_DENY }
    let state = Unmanaged<SQLiteAuthorizerState>
        .fromOpaque(context)
        .takeUnretainedValue()
    switch actionCode {
    case SQLITE_TRANSACTION, SQLITE_SAVEPOINT:
        return state.allowsInternalTransactionControl ? SQLITE_OK : SQLITE_DENY
    case SQLITE_INSERT, SQLITE_UPDATE, SQLITE_DELETE:
        guard state.connectionIsReadOnly == false,
              state.precommitValidationIsReadOnly == false,
              databaseName.map({ String(cString: $0) }) == "main",
              let firstDetail else {
            return SQLITE_DENY
        }
        let table = String(cString: firstDetail).lowercased()
        if let authorization = state.writeAuthorization {
            // AUTOINCREMENT updates SQLite's internal sequence catalog for an
            // already-authorized table. It is not caller-selectable domain
            // authority and cannot be named by a public capability.
            if table == "sqlite_sequence" { return SQLITE_OK }
            return authorization.allowedTables.contains(table) ? SQLITE_OK : SQLITE_DENY
        }
        if let authorization = state.bootstrapAuthorization {
            // SQLite represents DDL bookkeeping as writes to its internal
            // catalog. Those writes are reachable only while the separate
            // bootstrap capability is active; ordinary mutation authority can
            // never name either catalog table.
            if table == "sqlite_master" || table == "sqlite_schema" ||
                table == "sqlite_sequence" {
                return SQLITE_OK
            }
            return authorization.allowedSchemaObjects.contains(table) ? SQLITE_OK : SQLITE_DENY
        }
        if let authorization = state.schemaMigrationAuthorization {
            if table == "sqlite_master" || table == "sqlite_schema" ||
                table == "sqlite_sequence" {
                return SQLITE_OK
            }
            return authorization.allowedTables.contains(table) ? SQLITE_OK : SQLITE_DENY
        }
        return SQLITE_DENY
    case SQLITE_READ:
        // SQLite emits a nil database name for some engine-supplied rowid and
        // schema reads. Attached databases still name themselves explicitly;
        // attachment is denied independently, so nil is not an authority
        // escape across a database boundary.
        if let databaseName, String(cString: databaseName) != "main" {
            return SQLITE_DENY
        }
        if state.allowsInvariantReads || state.allowsPrecommitValidationReads ||
            state.bootstrapAuthorization != nil {
            return SQLITE_OK
        }
        if let authorization = state.schemaMigrationAuthorization {
            guard let firstDetail else { return SQLITE_DENY }
            let table = String(cString: firstDetail).lowercased()
            return authorization.allowedReadTables.contains(table) ? SQLITE_OK : SQLITE_DENY
        }
        guard let authorization = state.writeAuthorization else { return SQLITE_OK }
        guard let firstDetail else { return SQLITE_DENY }
        let table = String(cString: firstDetail).lowercased()
        // SQLite may reload a changed schema while compiling an otherwise
        // table-scoped mutation. Catalog reads do not broaden row authority;
        // they are necessary for the engine to validate the caller's already
        // constrained statement against the current schema.
        if table == "sqlite_master" || table == "sqlite_schema" ||
            table == "sqlite_sequence" {
            return SQLITE_OK
        }
        return authorization.allowedReadTables.contains(table) ? SQLITE_OK : SQLITE_DENY
    case SQLITE_PRAGMA:
        guard let firstDetail else { return SQLITE_DENY }
        let pragma = String(cString: firstDetail).lowercased()
        if let secondDetail {
            if state.connectionIsReadOnly == false,
               state.precommitValidationIsReadOnly == false,
               (state.bootstrapAuthorization != nil || state.schemaMigrationAuthorization != nil),
               pragma == "user_version" {
                return SQLITE_OK
            }
            let argument = String(cString: secondDetail).lowercased()
            guard argument.isEmpty == false,
                  argument.utf8.allSatisfy({ byte in
                      (byte >= 48 && byte <= 57) ||
                          (byte >= 97 && byte <= 122) || byte == 95
                  }),
                  [
                      "foreign_key_check", "foreign_key_list", "index_xinfo",
                      "table_info", "table_xinfo",
                  ].contains(pragma) else {
                return SQLITE_DENY
            }
            if state.allowsInvariantReads || state.allowsPrecommitValidationReads ||
                state.bootstrapAuthorization != nil {
                return SQLITE_OK
            }
            if let authorization = state.schemaMigrationAuthorization {
                guard pragma != "index_xinfo",
                      authorization.allowedReadTables.contains(argument) else {
                    return SQLITE_DENY
                }
                return SQLITE_OK
            }
            if let authorization = state.writeAuthorization {
                guard pragma != "index_xinfo",
                      authorization.allowedReadTables.contains(argument) else {
                    return SQLITE_DENY
                }
            }
            return SQLITE_OK
        }
        let safeReadPragmas: Set<String> = [
            "busy_timeout", "foreign_key_check", "foreign_key_list",
            "foreign_keys", "index_xinfo", "integrity_check", "journal_mode",
            "query_only", "schema_version", "synchronous", "table_info", "table_xinfo",
            "user_version",
        ]
        if state.writeAuthorization != nil,
           state.allowsInvariantReads == false,
           state.allowsPrecommitValidationReads == false,
           (pragma == "integrity_check" || pragma == "foreign_key_check") {
            return SQLITE_DENY
        }
        return safeReadPragmas.contains(pragma) ? SQLITE_OK : SQLITE_DENY
    case SQLITE_ATTACH, SQLITE_DETACH:
        return SQLITE_DENY
    case SQLITE_CREATE_TEMP_INDEX, SQLITE_CREATE_TEMP_TABLE,
         SQLITE_CREATE_TEMP_TRIGGER, SQLITE_CREATE_TEMP_VIEW,
         SQLITE_DROP_TEMP_INDEX, SQLITE_DROP_TEMP_TABLE,
         SQLITE_DROP_TEMP_TRIGGER, SQLITE_DROP_TEMP_VIEW:
        return SQLITE_DENY
    case SQLITE_CREATE_INDEX, SQLITE_CREATE_TABLE,
         SQLITE_CREATE_TRIGGER, SQLITE_CREATE_VIEW,
         SQLITE_CREATE_VTABLE:
        guard state.connectionIsReadOnly == false,
              state.precommitValidationIsReadOnly == false,
              let firstDetail else {
            return SQLITE_DENY
        }
        let primary = String(cString: firstDetail).lowercased()
        let secondary = secondDetail.map { String(cString: $0).lowercased() }
        let allowedSchemaObjects = state.bootstrapAuthorization?.allowedSchemaObjects ??
            state.schemaMigrationAuthorization?.allowedSchemaObjects
        let isImplicitIndex = actionCode == SQLITE_CREATE_INDEX &&
            primary.hasPrefix("sqlite_autoindex_")
        let isImplicitSequenceCatalog = actionCode == SQLITE_CREATE_TABLE &&
            primary == "sqlite_sequence"
        guard let allowedSchemaObjects,
              (allowedSchemaObjects.contains(primary) || isImplicitIndex ||
               isImplicitSequenceCatalog),
              secondary.map({ allowedSchemaObjects.contains($0) }) ?? true
        else {
            return SQLITE_DENY
        }
        return SQLITE_OK
    case SQLITE_ALTER_TABLE, SQLITE_ANALYZE, SQLITE_REINDEX,
         SQLITE_DROP_INDEX, SQLITE_DROP_TABLE,
         SQLITE_DROP_TRIGGER, SQLITE_DROP_VIEW,
         SQLITE_DROP_VTABLE:
        guard state.connectionIsReadOnly == false,
              state.precommitValidationIsReadOnly == false,
              let authorization = state.schemaMigrationAuthorization,
              let firstDetail else { return SQLITE_DENY }
        let primary = String(cString: firstDetail).lowercased()
        let secondary = secondDetail.map { String(cString: $0).lowercased() }
        guard authorization.allowedSchemaObjects.contains(primary),
              secondary.map({ authorization.allowedSchemaObjects.contains($0) }) ?? true
        else { return SQLITE_DENY }
        return SQLITE_OK
    case SQLITE_SELECT, SQLITE_RECURSIVE:
        return SQLITE_OK
    case SQLITE_FUNCTION:
        guard let secondDetail else { return SQLITE_DENY }
        let functionName = String(cString: secondDetail).lowercased()
        return functionName == "load_extension" ? SQLITE_DENY : SQLITE_OK
    default:
        return SQLITE_DENY
    }
}

private let sqliteTransient = unsafeBitCast(
    -1,
    to: sqlite3_destructor_type.self
)

private enum SQLiteOptionalFileIdentity: Sendable, Equatable {
    case absent
    case present(device: UInt64, inode: UInt64, byteCount: Int64)
}

private struct SQLiteReadOnlyNamespaceIdentity: Sendable, Equatable {
    let directoryDevice: UInt64
    let directoryInode: UInt64
    let databaseDevice: UInt64
    let databaseInode: UInt64
    let databaseByteCount: Int64
    let sidecars: [String: SQLiteOptionalFileIdentity]
}

/// Owns descriptors until each receives exactly one close attempt. After an
/// indeterminate failure it retains only failure metadata and never retries the
/// numeric descriptor, which the OS may already have reused.
private final class SQLiteDescriptorOwner: @unchecked Sendable {
    private let lock = NSLock()
    private var descriptors: [Int32]
    private var indeterminateCloseCount = 0

    init(descriptors: [Int32]) {
        self.descriptors = descriptors.filter { $0 >= 0 }
    }

    func closeAll() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let owned = descriptors
        descriptors.removeAll(keepingCapacity: false)
        for descriptor in owned {
            if Darwin.close(descriptor) != 0 {
                // A failed POSIX close leaves descriptor ownership unknown.
                // Never retry the numeric descriptor: it may already have
                // been reused by another thread.
                indeterminateCloseCount += 1
            }
        }
        return indeterminateCloseCount == 0
    }

    deinit {
        _ = closeAll()
    }
}

/// `NSLock` is the synchronization boundary for process-lifetime failure
/// metadata. A failed close may already have released and allowed reuse of the
/// numeric descriptor; the registry never retries or claims control of it.
private final class SQLiteFailedResourceRegistry: @unchecked Sendable {
    static let shared = SQLiteFailedResourceRegistry()
    private let lock = NSLock()
    private var owners: [SQLiteDescriptorOwner] = []
    private var retainedConnections: [SQLiteFailedConnectionOwner] = []
    private var indeterminateCloseCount = 0

    func retain(_ owner: SQLiteDescriptorOwner) {
        lock.lock()
        owners.append(owner)
        lock.unlock()
    }

    /// `sqlite3_close` returned a failure, which means SQLite retains the
    /// connection and may still call its VFS. Keep the matching context alive
    /// until process exit rather than treating deferred-close semantics as a
    /// completed close and freeing descriptor-root authority underneath it.
    func retainSQLiteConnection(
        _ handle: OpaquePointer,
        writableVFSContext: OpaquePointer?
    ) {
        lock.lock()
        retainedConnections.append(
            SQLiteFailedConnectionOwner(
                handle: handle,
                writableVFSContext: writableVFSContext
            )
        )
        lock.unlock()
    }

    func recordIndeterminateClose(count: Int) {
        guard count > 0 else { return }
        lock.lock()
        indeterminateCloseCount += count
        lock.unlock()
    }
}

/// Process-lifetime retention is intentional: `sqlite3_close` refused to
/// close, so neither the connection nor its VFS context has a safe local
/// destruction point. The registry never retries an indeterminate close.
private final class SQLiteFailedConnectionOwner: @unchecked Sendable {
    let handle: OpaquePointer
    let writableVFSContext: OpaquePointer?

    init(handle: OpaquePointer, writableVFSContext: OpaquePointer?) {
        self.handle = handle
        self.writableVFSContext = writableVFSContext
    }
}
