import Darwin
import Foundation

enum RuntimeGenerationActivationLockMode: Sendable, Equatable {
    case shared
    case exclusive

    fileprivate var flockOperation: Int32 {
        switch self {
        case .shared: Int32(LOCK_SH | LOCK_NB)
        case .exclusive: Int32(LOCK_EX | LOCK_NB)
        }
    }
}

/// An unforgeable, process-local proof that the canonical activation lock is
/// held on the exact pinned runtime root. The descriptor is never exposed.
/// `NSLock` protects only this object's small synchronous lifecycle state.
final class RuntimeGenerationActivationLockScope: @unchecked Sendable {
    private enum State {
        case held(Int32)
        case closeIndeterminate
        case closed
    }

    let mode: RuntimeGenerationActivationLockMode
    private let rootAuthority: any RuntimeStoreRootAuthorityProviding
    private let lockURL: URL
    private let identity: RuntimeStoreFileIdentity
    private let stateLock = NSLock()
    private var state: State

    private init(
        descriptor: Int32,
        mode: RuntimeGenerationActivationLockMode,
        rootAuthority: any RuntimeStoreRootAuthorityProviding,
        lockURL: URL,
        identity: RuntimeStoreFileIdentity
    ) {
        self.mode = mode
        self.rootAuthority = rootAuthority
        self.lockURL = lockURL
        self.identity = identity
        state = .held(descriptor)
    }

    static func acquire(
        rootAuthority: any RuntimeStoreRootAuthorityProviding,
        locations: RuntimeStoreLocations,
        mode: RuntimeGenerationActivationLockMode,
        createIfMissing: Bool
    ) throws -> RuntimeGenerationActivationLockScope {
        try rootAuthority.revalidatePinnedRoot()
        let lockURL = locations.rootURL.appendingPathComponent(
            ".activation.lock", isDirectory: false
        )
        try RuntimeStorePathValidation.requireContained(lockURL, in: locations.rootURL)
        let flags = O_RDWR | O_NOFOLLOW | O_CLOEXEC |
            (createIfMissing ? O_CREAT : 0)
        let descriptor = Darwin.open(lockURL.path, flags, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalActivationLockFailed
        }
        var lockAcquired = false
        do {
            guard Darwin.flock(descriptor, mode.flockOperation) == 0 else {
                throw LocalRuntimeStorageError.canonicalActivationLockFailed
            }
            lockAcquired = true
            var descriptorStatus = stat()
            var pathStatus = stat()
            guard fstat(descriptor, &descriptorStatus) == 0,
                  Darwin.lstat(lockURL.path, &pathStatus) == 0,
                  descriptorStatus.st_mode & S_IFMT == S_IFREG,
                  descriptorStatus.st_nlink == 1,
                  descriptorStatus.st_dev == pathStatus.st_dev,
                  descriptorStatus.st_ino == pathStatus.st_ino else {
                throw LocalRuntimeStorageError.canonicalActivationLockFailed
            }
            if createIfMissing {
                try RuntimeStoreFileDurability.applyCompleteProtection(
                    toOpenFileDescriptor: descriptor,
                    artifact: "activation_lock"
                )
                guard Darwin.fsync(descriptor) == 0 else {
                    throw LocalRuntimeStorageError.canonicalActivationLockFailed
                }
                var protectedDescriptorStatus = stat()
                var protectedPathStatus = stat()
                guard fstat(descriptor, &protectedDescriptorStatus) == 0,
                      Darwin.lstat(lockURL.path, &protectedPathStatus) == 0,
                      protectedDescriptorStatus.st_dev == descriptorStatus.st_dev,
                      protectedDescriptorStatus.st_ino == descriptorStatus.st_ino,
                      protectedPathStatus.st_dev == descriptorStatus.st_dev,
                      protectedPathStatus.st_ino == descriptorStatus.st_ino else {
                    throw LocalRuntimeStorageError.canonicalActivationLockFailed
                }
                try RuntimeStoreFileDurability.synchronizeDirectory(at: locations.rootURL)
            }
            try rootAuthority.revalidatePinnedRoot()
            return RuntimeGenerationActivationLockScope(
                descriptor: descriptor,
                mode: mode,
                rootAuthority: rootAuthority,
                lockURL: lockURL,
                identity: RuntimeStoreFileIdentity(
                    device: UInt64(descriptorStatus.st_dev),
                    inode: UInt64(descriptorStatus.st_ino)
                )
            )
        } catch {
            let unlocked = lockAcquired == false || Darwin.flock(descriptor, LOCK_UN) == 0
            let closed = Darwin.close(descriptor) == 0
            if closed == false {
                RuntimeGenerationLockFailureRegistry.shared.recordIndeterminateClose()
            }
            guard unlocked, closed else {
                throw LocalRuntimeStorageError.canonicalActivationLockFailed
            }
            throw error
        }
    }

    func revalidate(requiredMode: RuntimeGenerationActivationLockMode) throws {
        stateLock.lock()
        defer { stateLock.unlock() }
        guard mode == requiredMode, case let .held(descriptor) = state else {
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
        try rootAuthority.revalidatePinnedRoot()
        var descriptorStatus = stat()
        var pathStatus = stat()
        guard fstat(descriptor, &descriptorStatus) == 0,
              Darwin.lstat(lockURL.path, &pathStatus) == 0,
              descriptorStatus.st_mode & S_IFMT == S_IFREG,
              descriptorStatus.st_nlink == 1,
              RuntimeStoreFileIdentity(
                device: UInt64(descriptorStatus.st_dev),
                inode: UInt64(descriptorStatus.st_ino)
              ) == identity,
              RuntimeStoreFileIdentity(
                device: UInt64(pathStatus.st_dev),
                inode: UInt64(pathStatus.st_ino)
              ) == identity else {
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
    }

    func close() throws {
        stateLock.lock()
        defer { stateLock.unlock() }
        switch state {
        case .closed:
            return
        case .closeIndeterminate:
            throw LocalRuntimeStorageError.canonicalActivationLockFailed
        case let .held(descriptor):
            let unlockResult = Darwin.flock(descriptor, LOCK_UN)
            let closeResult = Darwin.close(descriptor)
            state = closeResult == 0 ? .closed : .closeIndeterminate
            if closeResult != 0 {
                RuntimeGenerationLockFailureRegistry.shared.recordIndeterminateClose()
            }
            guard unlockResult == 0, closeResult == 0 else {
                // Never retry an indeterminate numeric descriptor.
                throw LocalRuntimeStorageError.canonicalActivationLockFailed
            }
        }
    }

    deinit {
        stateLock.lock()
        if case let .held(descriptor) = state {
            _ = Darwin.flock(descriptor, LOCK_UN)
            let closed = Darwin.close(descriptor) == 0
            if closed == false {
                RuntimeGenerationLockFailureRegistry.shared.recordIndeterminateClose()
            }
            state = closed ? .closed : .closeIndeterminate
        }
        stateLock.unlock()
    }
}

/// Retains only a privacy-safe count; an indeterminate numeric descriptor is
/// never retried because the OS may already have reused it.
private final class RuntimeGenerationLockFailureRegistry: @unchecked Sendable {
    static let shared = RuntimeGenerationLockFailureRegistry()
    private let lock = NSLock()
    private var indeterminateCloseCount = 0

    func recordIndeterminateClose() {
        lock.lock()
        indeterminateCloseCount += 1
        lock.unlock()
    }
}
