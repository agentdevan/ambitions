import CryptoKit
import Foundation

struct RuntimeAttachmentSubsystem: Sendable {
    let keyCustody: any RuntimeAttachmentKeyCustody
    let vault: RuntimeAttachmentVault
    let intake: RuntimeAttachmentIntake
    let staging: RuntimeAttachmentStagingCoordinator
    let finalizer: RuntimeAttachmentFinalizer
    let garbageCollector: RuntimeAttachmentGarbageCollector
    let recovery: RuntimeAttachmentRecovery
    let keyRotation: RuntimeAttachmentKeyRotationCoordinator
    let accessAuthority: RuntimeAttachmentAccessAuthority
    let query: RuntimeAttachmentQueryService
    let portableImporter: RuntimeAttachmentPortableImporter

    static func mainApplication(
        store: CanonicalRuntimeStore,
        keyCustody: any RuntimeAttachmentKeyCustody = KeychainRuntimeAttachmentKeyCustody(),
        portableCleanupCustody: any RuntimeAttachmentPortableCleanupJobCustody =
            DeviceLocalRuntimeAttachmentCleanupJobCustody(),
        garbageCollectionOwnerID: String,
        opaqueToken: @escaping @Sendable () -> String = { UUID().uuidString.lowercased() },
        intakeToken: @escaping @Sendable () -> String = { UUID().uuidString.lowercased() },
        portableImportToken: @escaping @Sendable () -> String = {
            UUID().uuidString.lowercased()
        },
        leaseID: @escaping @Sendable () -> RuntimeBlobGCLeaseID = {
            RuntimeBlobGCLeaseID(rawValue: UUID().uuidString.lowercased())!
        },
        tombstoneID: @escaping @Sendable () -> RuntimeBlobTombstoneID = {
            RuntimeBlobTombstoneID(rawValue: UUID().uuidString.lowercased())!
        },
        clock: @escaping @Sendable () -> Date = Date.init
    ) throws -> RuntimeAttachmentSubsystem {
        guard let support = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let root = support.appendingPathComponent("AmbitionsLocalRuntimeOS", isDirectory: true)
        let intakeProofKey = SymmetricKey(size: .bits256)
        let vault = try RuntimeAttachmentVault(
            rootDirectory: root.appendingPathComponent("AttachmentVault", isDirectory: true),
            keyCustody: keyCustody,
            intakeProofKey: intakeProofKey,
            opaqueToken: opaqueToken
        )
        let intake = try RuntimeAttachmentIntake(
            intakeRoot: root.appendingPathComponent("AttachmentIntake", isDirectory: true),
            vault: vault,
            quotaAuthorizer: store,
            intakeProofKey: intakeProofKey,
            intakeToken: intakeToken,
            clock: clock
        )
        let portableImporter = try RuntimeAttachmentPortableImporter(
            cleanupCustody: portableCleanupCustody,
            importRoot: root.appendingPathComponent(
                "AttachmentPortableImport", isDirectory: true
            ),
            importToken: portableImportToken,
            clock: clock
        )
        let staging = RuntimeAttachmentStagingCoordinator(
            store: store, vault: vault, keyCustody: keyCustody, clock: clock
        )
        let finalizer = RuntimeAttachmentFinalizer(store: store, vault: vault)
        let keyRotation = try RuntimeAttachmentKeyRotationCoordinator(
            store: store, custody: keyCustody,
            ownerID: "\(garbageCollectionOwnerID):attachment-key-rotation",
            clock: clock
        )
        let garbageCollector = try RuntimeAttachmentGarbageCollector(
            store: store, vault: vault, ownerID: garbageCollectionOwnerID,
            leaseID: leaseID,
            tombstoneID: tombstoneID,
            clock: clock
        )
        let recovery = RuntimeAttachmentRecovery(
            store: store, vault: vault, intake: intake,
            staging: staging, finalizer: finalizer, keyRotation: keyRotation,
            portableImporter: portableImporter, clock: clock
        )
        let accessAuthority = RuntimeAttachmentAccessAuthority(store: store, clock: clock)
        let query = RuntimeAttachmentQueryService(
            store: store, vault: vault, accessAuthority: accessAuthority, clock: clock
        )
        return RuntimeAttachmentSubsystem(
            keyCustody: keyCustody,
            vault: vault, intake: intake, staging: staging, finalizer: finalizer,
            garbageCollector: garbageCollector, recovery: recovery,
            keyRotation: keyRotation, accessAuthority: accessAuthority, query: query,
            portableImporter: portableImporter
        )
    }

    func mutationClient(
        preparer: any RuntimeMutationPreparing,
        submitter: any RuntimeMutationSubmitting
    ) -> AttachmentRuntimeMutationClient {
        AttachmentRuntimeMutationClient(preparer: preparer, submitter: submitter)
    }

    func portableExporter(
        store: CanonicalRuntimeStore,
        custody: any RuntimeAttachmentPortableExportCustody,
        exportToken: @escaping @Sendable () -> String = { UUID().uuidString.lowercased() },
        clock: @escaping @Sendable () -> Date = Date.init
    ) -> RuntimeAttachmentPortableExporter {
        RuntimeAttachmentPortableExporter(
            store: store, vault: vault, custody: custody,
            accessAuthority: accessAuthority, exportToken: exportToken, clock: clock
        )
    }

    func portableImportCoordinator(
        custody: any RuntimeAttachmentPortableExportCustody
    ) throws -> RuntimeAttachmentPortableImportCoordinator {
        RuntimeAttachmentPortableImportCoordinator(
            importer: portableImporter,
            intake: intake,
            custody: custody
        )
    }

    func keyRotationCoordinator(
        store: CanonicalRuntimeStore,
        ownerID: String,
        clock: @escaping @Sendable () -> Date = Date.init
    ) throws -> RuntimeAttachmentKeyRotationCoordinator {
        try RuntimeAttachmentKeyRotationCoordinator(
            store: store, custody: keyCustody, ownerID: ownerID, clock: clock
        )
    }
}
