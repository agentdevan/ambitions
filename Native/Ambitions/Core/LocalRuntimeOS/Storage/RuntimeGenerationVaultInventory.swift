import CryptoKit
import Darwin
import Foundation
import AmbitionsRuntimeSQLite

struct RuntimeGenerationVaultInventory: Sendable, Equatable {
    let blobSetDigest: String
    let manifestSetDigest: String
    let keyIdentityDigest: String
    let encryptionScheme: String
    let wrappingKeyID: RuntimeBlobKeyID
    let wrappingKeyVersion: Int
    let rootIdentity: RuntimeStoreFileIdentity
    let fileCount: Int
}

struct RuntimeGenerationVaultBlobArtifact: Codable, Sendable, Equatable, Hashable {
    let blobID: String
    let manifestDigest: String
    let opaqueRelativeDirectory: String
    let payloadArtifact: RuntimeGenerationArtifact
    let manifestArtifact: RuntimeGenerationArtifact
    let finalizationArtifact: RuntimeGenerationArtifact?
    let envelopeDigest: String
    let wrappingKeyID: String
    let wrappingKeyVersion: Int
    let artifactDigest: String
    let backupPayloadArtifact: RuntimeGenerationArtifact?
    let backupManifestArtifact: RuntimeGenerationArtifact?
    let backupFinalizationArtifact: RuntimeGenerationArtifact?
}

struct RuntimeGenerationVerifiedVaultSnapshot: Sendable, Equatable {
    let blobSetDigest: String
    let manifestSetDigest: String
    let keyIdentityDigest: String
    let artifacts: [RuntimeGenerationVaultBlobArtifact]
}

struct RuntimeGenerationVaultRestoreRequest: Sendable, Equatable {
    let snapshot: RuntimeGenerationVerifiedVaultSnapshot
    let backupDirectoryURL: URL
    let vaultRootURL: URL
    let quarantineRootURL: URL
    let quarantineToken: String
}

struct RuntimeGenerationVaultRestoreDeltaEntry: Codable, Sendable, Equatable {
    let relativePath: String
    let existedBeforeRestore: Bool
}

struct RuntimeGenerationVaultRestoreDeltaJournal: Codable, Sendable, Equatable {
    let formatVersion: Int
    let candidateGenerationID: RuntimeStoreGenerationID
    let candidateSelectorFileSHA256: String
    let token: String
    let files: [RuntimeGenerationVaultRestoreDeltaEntry]
    let directories: [RuntimeGenerationVaultRestoreDeltaEntry]
    let journalDigest: String
}

/// Verifies exactly the immutable vault artifacts referenced by a consolidated
/// database snapshot. It authenticates each ciphertext through the production
/// vault reader, matches manifest/finalization bytes to DB digests, and rejects
/// missing, malformed, or extra owned directories.
enum RuntimeGenerationVaultGraphVerifier {
    static func reconcileRestoreDeltaJournals(
        locations: RuntimeStoreLocations,
        fileManager: FileManager = .default
    ) throws {
        guard fileManager.fileExists(atPath: locations.controlURL.path) else { return }
        let activeSelectorDigest = try RuntimeStoreManifestDescriptorReader
            .readIfPresent(at: locations.activeManifestURL)
            .map { LocalRuntimeStorageChecksum.sha256Hex(for: $0) }
        let entries = try fileManager.contentsOfDirectory(
            at: locations.controlURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ).filter {
            $0.lastPathComponent.hasPrefix("vault-restore-delta-") &&
                $0.pathExtension == "json"
        }.sorted { $0.lastPathComponent < $1.lastPathComponent }
        for entry in entries {
            guard let bytes = try RuntimeStoreManifestDescriptorReader.readIfPresent(
                at: entry
            ) else { continue }
            let journal = try RuntimeGenerationControlCodec.decode(
                RuntimeGenerationVaultRestoreDeltaJournal.self, from: bytes
            )
            try validateRestoreDeltaJournal(journal)
            if activeSelectorDigest == journal.candidateSelectorFileSHA256 {
                try fileManager.removeItem(at: entry)
            } else {
                try quarantineCreatedRestoreDelta(
                    journal,
                    vaultRootURL: locations.attachmentVaultURL,
                    quarantineRootURL: locations.quarantineURL,
                    fileManager: fileManager
                )
                let evidenceDirectory = locations.quarantineURL.appendingPathComponent(
                    "restore-delta-\(journal.token)", isDirectory: true
                )
                let evidenceURL = evidenceDirectory.appendingPathComponent(
                    "Delta.json", isDirectory: false
                )
                if fileManager.fileExists(atPath: evidenceURL.path) {
                    guard try RuntimeStoreManifestDescriptorReader.readIfPresent(
                        at: evidenceURL
                    ) == bytes else {
                        throw LocalRuntimeStorageError.canonicalActivationStateUnknown
                    }
                    try fileManager.removeItem(at: entry)
                } else {
                    guard Darwin.rename(entry.path, evidenceURL.path) == 0 else {
                        throw LocalRuntimeStorageError.canonicalActivationStateUnknown
                    }
                }
                try RuntimeStoreFileDurability.synchronizeDirectory(at: evidenceDirectory)
            }
            try RuntimeStoreFileDurability.synchronizeDirectory(at: locations.controlURL)
        }
    }
    static let pageSize = 128
    static let maximumBlobCount = 100_000

    static func prepareRestoreDeltaJournal(
        snapshot: RuntimeGenerationVerifiedVaultSnapshot,
        candidateGenerationID: RuntimeStoreGenerationID,
        candidateSelectorFileSHA256: String,
        token: String,
        vaultRootURL: URL,
        journalURL: URL,
        fileManager: FileManager = .default
    ) throws -> RuntimeGenerationVaultRestoreDeltaJournal {
        try RuntimeStorePathValidation.requireSafeComponent(token)
        let filePaths = Set(snapshot.artifacts.flatMap { artifact in
            [artifact.payloadArtifact.relativePath,
             artifact.manifestArtifact.relativePath] +
                (artifact.finalizationArtifact.map { [$0.relativePath] } ?? [])
        }).sorted()
        var directoryPaths = Set<String>()
        for artifact in snapshot.artifacts {
            var components: [String] = []
            for component in artifact.opaqueRelativeDirectory.split(separator: "/") {
                components.append(String(component))
                directoryPaths.insert(components.joined(separator: "/"))
            }
        }
        let files = try filePaths.map { relativePath in
            let url = vaultRootURL.appendingPathComponent(relativePath)
            try RuntimeStorePathValidation.requireContained(url, in: vaultRootURL)
            return RuntimeGenerationVaultRestoreDeltaEntry(
                relativePath: relativePath,
                existedBeforeRestore: fileManager.fileExists(atPath: url.path)
            )
        }
        let directories = try directoryPaths.sorted().map { relativePath in
            let url = vaultRootURL.appendingPathComponent(relativePath, isDirectory: true)
            try RuntimeStorePathValidation.requireContained(url, in: vaultRootURL)
            return RuntimeGenerationVaultRestoreDeltaEntry(
                relativePath: relativePath,
                existedBeforeRestore: fileManager.fileExists(atPath: url.path)
            )
        }
        let material = ([
            "runtime-vault-restore-delta-v1",
            candidateGenerationID.rawValue,
            candidateSelectorFileSHA256,
            token,
        ] + files.flatMap { [$0.relativePath, $0.existedBeforeRestore ? "1" : "0"] } +
            directories.flatMap { [$0.relativePath, $0.existedBeforeRestore ? "1" : "0"] })
            .joined(separator: "\n")
        let journal = RuntimeGenerationVaultRestoreDeltaJournal(
            formatVersion: 1,
            candidateGenerationID: candidateGenerationID,
            candidateSelectorFileSHA256: candidateSelectorFileSHA256,
            token: token,
            files: files,
            directories: directories,
            journalDigest: LocalRuntimeStorageChecksum.sha256Hex(for: material)
        )
        let bytes = try RuntimeGenerationControlCodec.encode(journal)
        try bytes.write(to: journalURL, options: [.withoutOverwriting])
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: journalURL,
            artifact: "vault_restore_delta_journal"
        )
        try RuntimeStoreFileDurability.synchronizeFile(at: journalURL)
        try RuntimeStoreFileDurability.synchronizeDirectory(
            at: journalURL.deletingLastPathComponent()
        )
        return journal
    }

    static func quarantineCreatedRestoreDelta(
        _ journal: RuntimeGenerationVaultRestoreDeltaJournal,
        vaultRootURL: URL,
        quarantineRootURL: URL,
        fileManager: FileManager = .default
    ) throws {
        try validateRestoreDeltaJournal(journal)
        let quarantineDirectory = quarantineRootURL.appendingPathComponent(
            "restore-delta-\(journal.token)", isDirectory: true
        )
        if fileManager.fileExists(atPath: quarantineRootURL.path) == false {
            try fileManager.createDirectory(
                at: quarantineRootURL, withIntermediateDirectories: false
            )
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: quarantineRootURL,
                artifact: "restore_delta_quarantine_root"
            )
        }
        if fileManager.fileExists(atPath: quarantineDirectory.path) == false {
            try fileManager.createDirectory(
                at: quarantineDirectory, withIntermediateDirectories: false
            )
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: quarantineDirectory,
                artifact: "restore_delta_quarantine"
            )
        }
        for (index, entry) in journal.files.enumerated()
            where entry.existedBeforeRestore == false {
            let source = vaultRootURL.appendingPathComponent(entry.relativePath)
            let destination = quarantineDirectory.appendingPathComponent(
                "created-file-\(index)", isDirectory: false
            )
            if fileManager.fileExists(atPath: source.path) {
                guard fileManager.fileExists(atPath: destination.path) == false,
                      Darwin.rename(source.path, destination.path) == 0 else {
                    throw LocalRuntimeStorageError.canonicalActivationStateUnknown
                }
            }
        }
        for entry in journal.directories.reversed()
            where entry.existedBeforeRestore == false {
            let directory = vaultRootURL.appendingPathComponent(
                entry.relativePath, isDirectory: true
            )
            guard fileManager.fileExists(atPath: directory.path) else { continue }
            let contents = try fileManager.contentsOfDirectory(atPath: directory.path)
            if contents.isEmpty {
                try fileManager.removeItem(at: directory)
            }
        }
        try RuntimeStoreFileDurability.synchronizeDirectory(at: quarantineDirectory)
        try RuntimeStoreFileDurability.synchronizeDirectory(at: quarantineRootURL)
        try RuntimeStoreFileDurability.synchronizeDirectory(at: vaultRootURL)
    }

    static func validateRestoreDeltaJournal(
        _ journal: RuntimeGenerationVaultRestoreDeltaJournal
    ) throws {
        try RuntimeStorePathValidation.requireSafeComponent(journal.token)
        guard journal.formatVersion == 1,
              journal.files == journal.files.sorted(by: { $0.relativePath < $1.relativePath }),
              journal.directories == journal.directories.sorted(by: {
                $0.relativePath < $1.relativePath
              }),
              Set(journal.files.map(\.relativePath)).count == journal.files.count,
              Set(journal.directories.map(\.relativePath)).count == journal.directories.count else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
        let material = ([
            "runtime-vault-restore-delta-v1",
            journal.candidateGenerationID.rawValue,
            journal.candidateSelectorFileSHA256,
            journal.token,
        ] + journal.files.flatMap {
            [$0.relativePath, $0.existedBeforeRestore ? "1" : "0"]
        } + journal.directories.flatMap {
            [$0.relativePath, $0.existedBeforeRestore ? "1" : "0"]
        }).joined(separator: "\n")
        guard LocalRuntimeStorageChecksum.sha256Hex(for: material) ==
                journal.journalDigest else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
    }

    static func verify(
        database: SQLiteDatabase,
        vault: RuntimeAttachmentVault,
        vaultRootURL: URL,
        keyCustody: any RuntimeAttachmentKeyCustody
    ) async throws -> RuntimeGenerationVerifiedVaultSnapshot {
        var artifacts: [RuntimeGenerationVaultBlobArtifact] = []
        artifacts.reserveCapacity(min(1_024, maximumBlobCount))
        var cursor: String?
        while true {
            try Task.checkCancellation()
            let rows = try await database.query(
                """
                SELECT b.blob_id, b.manifest_digest, b.opaque_relative_directory,
                       k.envelope_digest, k.wrapping_key_id, k.wrapping_key_version,
                       (SELECT MIN(v.revision_id) FROM runtime_attachment_revisions AS v
                        WHERE v.blob_id = b.blob_id) AS revision_id,
                       (SELECT i.marker_digest FROM runtime_blob_finalization_intents AS i
                        WHERE i.blob_id = b.blob_id) AS marker_digest
                FROM runtime_blob_records AS b
                JOIN runtime_blob_key_envelopes AS k ON k.blob_id = b.blob_id
                WHERE (? IS NULL OR b.blob_id > ?)
                ORDER BY b.blob_id
                LIMIT ?
                """,
                bindings: [cursor.map(SQLiteBinding.text) ?? .null,
                           cursor.map(SQLiteBinding.text) ?? .null,
                           .integer(Int64(pageSize))],
                maximumDecodedBytes: RuntimeGenerationDatabaseAuthority.pageByteBudget
            )
            for row in rows {
                guard artifacts.count < maximumBlobCount,
                      case let .text(blobID)? = row.value(named: "blob_id"),
                      case let .text(manifestDigest)? = row.value(named: "manifest_digest"),
                      case let .text(relativeDirectory)? = row.value(named: "opaque_relative_directory"),
                      case let .text(envelopeDigest)? = row.value(named: "envelope_digest"),
                      case let .text(wrappingKeyID)? = row.value(named: "wrapping_key_id"),
                      case let .integer(wrappingKeyVersion)? = row.value(named: "wrapping_key_version"),
                      case let .text(revisionID)? = row.value(named: "revision_id"),
                      let typedRevisionID = RuntimeAttachmentRevisionID(rawValue: revisionID),
                      RuntimeAttachmentCodec.validOpaqueDirectory(relativeDirectory) else {
                    throw RuntimeGenerationControlError.verificationRejected
                }
                let graph = try await database.transaction(.deferred) { database in
                    try CanonicalRuntimeAttachmentStore.load(
                        revisionID: typedRevisionID,
                        database: database
                    )
                }
                guard let graph,
                      graph.manifest.blobID.rawValue == blobID,
                      graph.revision.manifestDigest == manifestDigest,
                      graph.manifest.opaqueRelativeDirectory == relativeDirectory,
                      graph.envelope.envelopeDigest == envelopeDigest,
                      graph.envelope.wrappingKeyID.rawValue == wrappingKeyID,
                      graph.envelope.wrappingKeyVersion == wrappingKeyVersion else {
                    throw RuntimeGenerationControlError.verificationRejected
                }
                try await vault.verifyAuthenticatedBlob(graph)
                let payloadArtifact = try RuntimeGenerationDatabaseAuthority.artifact(
                    at: vaultRootURL.appendingPathComponent(relativeDirectory)
                        .appendingPathComponent("payload.aead"),
                    relativePath: "\(relativeDirectory)/payload.aead"
                )
                let manifestArtifact = try RuntimeGenerationDatabaseAuthority.artifact(
                    at: vaultRootURL.appendingPathComponent(relativeDirectory)
                        .appendingPathComponent("manifest.json"),
                    relativePath: "\(relativeDirectory)/manifest.json"
                )
                guard manifestArtifact.sha256 == manifestDigest else {
                    throw RuntimeGenerationControlError.verificationRejected
                }
                let markerDigest: String? = switch row.value(named: "marker_digest") {
                case .null?, nil: nil
                case let .text(value)?: value
                default: throw RuntimeGenerationControlError.verificationRejected
                }
                let finalizationArtifact: RuntimeGenerationArtifact?
                if let markerDigest {
                    let artifact = try RuntimeGenerationDatabaseAuthority.artifact(
                        at: vaultRootURL.appendingPathComponent(relativeDirectory)
                            .appendingPathComponent("finalized.json"),
                        relativePath: "\(relativeDirectory)/finalized.json"
                    )
                    guard artifact.sha256 == markerDigest else {
                        throw RuntimeGenerationControlError.verificationRejected
                    }
                    finalizationArtifact = artifact.semantic
                } else {
                    let markerURL = vaultRootURL.appendingPathComponent(relativeDirectory)
                        .appendingPathComponent("finalized.json")
                    guard FileManager.default.fileExists(atPath: markerURL.path) == false else {
                        throw RuntimeGenerationControlError.verificationRejected
                    }
                    finalizationArtifact = nil
                }
                let artifactDigest = LocalRuntimeStorageChecksum.sha256Hex(for: [
                    blobID, manifestDigest, relativeDirectory,
                    payloadArtifact.sha256, manifestArtifact.sha256,
                    finalizationArtifact?.sha256 ?? "", envelopeDigest,
                    wrappingKeyID, String(wrappingKeyVersion),
                ].joined(separator: "\n"))
                artifacts.append(RuntimeGenerationVaultBlobArtifact(
                    blobID: blobID,
                    manifestDigest: manifestDigest,
                    opaqueRelativeDirectory: relativeDirectory,
                    payloadArtifact: payloadArtifact.semantic,
                    manifestArtifact: manifestArtifact.semantic,
                    finalizationArtifact: finalizationArtifact,
                    envelopeDigest: envelopeDigest,
                    wrappingKeyID: wrappingKeyID,
                    wrappingKeyVersion: Int(wrappingKeyVersion),
                    artifactDigest: artifactDigest,
                    backupPayloadArtifact: nil,
                    backupManifestArtifact: nil,
                    backupFinalizationArtifact: nil
                ))
            }
            guard rows.count == pageSize,
                  let last = artifacts.last else { break }
            cursor = last.blobID
        }

        var observedDirectories = Set<String>()
        var filesystemCursor: String?
        repeat {
            let page = try await vault.ownedManifestDirectories(
                limit: RuntimeAttachmentLimits.maximumPageSize,
                afterCursorKey: filesystemCursor
            )
            for entry in page.entries {
                switch entry {
                case let .owned(_, url):
                    let inspection = try await vault.inspectOwnedManifestDirectory(url)
                    guard inspection.manifestDigest ==
                            artifacts.first(where: {
                                $0.opaqueRelativeDirectory ==
                                    inspection.manifest.opaqueRelativeDirectory
                            })?.manifestDigest,
                          observedDirectories.insert(
                              inspection.manifest.opaqueRelativeDirectory
                          ).inserted else {
                        throw RuntimeGenerationControlError.verificationRejected
                    }
                case .malformed:
                    throw RuntimeGenerationControlError.verificationRejected
                }
            }
            filesystemCursor = page.nextCursorKey
            if page.exhausted { break }
            guard filesystemCursor != nil else {
                throw RuntimeGenerationControlError.verificationRejected
            }
        } while true
        guard observedDirectories == Set(artifacts.map(\.opaqueRelativeDirectory)) else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        let blobSetDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: (["runtime-generation-vault-blobs-v1"] +
                artifacts.map(\.artifactDigest)).joined(separator: "\n")
        )
        let manifestSetDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: (["runtime-generation-vault-manifests-v1"] + artifacts.flatMap {
                [$0.blobID, $0.manifestDigest, $0.opaqueRelativeDirectory]
            }).joined(separator: "\n")
        )
        let keyPairs = Set(artifacts.map {
            "\($0.wrappingKeyID)\n\($0.wrappingKeyVersion)"
        })
        var keyProofs: [String] = []
        if keyPairs.isEmpty {
            let current = try await keyCustody.currentWrappingKey()
            keyProofs.append(try keyIdentityProof(current))
        } else {
            for pair in keyPairs.sorted() {
                let parts = pair.split(separator: "\n", omittingEmptySubsequences: false)
                guard parts.count == 2,
                      let version = Int(parts[1]),
                      let id = RuntimeBlobKeyID(rawValue: String(parts[0])) else {
                    throw RuntimeGenerationControlError.verificationRejected
                }
                let wrappingKey = try await keyCustody.wrappingKey(
                    id: id,
                    version: version
                )
                keyProofs.append(try keyIdentityProof(wrappingKey))
            }
        }
        let keyIdentityDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: (["runtime-generation-vault-keys-v2"] + keyProofs.sorted())
                .joined(separator: "\n")
        )
        return RuntimeGenerationVerifiedVaultSnapshot(
            blobSetDigest: blobSetDigest,
            manifestSetDigest: manifestSetDigest,
            keyIdentityDigest: keyIdentityDigest,
            artifacts: artifacts
        )
    }

    private static func keyIdentityProof(
        _ wrappingKey: RuntimeAttachmentWrappingKey
    ) throws -> String {
        let challenge = Data("ambitions.runtime.generation.key-identity.v2".utf8)
        let proof = HMAC<SHA256>.authenticationCode(
            for: challenge,
            using: wrappingKey.key
        )
        return LocalRuntimeStorageChecksum.sha256Hex(
            for: "\(wrappingKey.id.rawValue)\n\(wrappingKey.version)\n\(Data(proof).base64EncodedString())"
        )
    }

    static func copyToProtectedBackup(
        _ snapshot: RuntimeGenerationVerifiedVaultSnapshot,
        sourceRootURL: URL,
        backupRootURL: URL,
        fileManager: FileManager = .default
    ) throws -> RuntimeGenerationVerifiedVaultSnapshot {
        guard fileManager.fileExists(atPath: backupRootURL.path) == false else {
            throw RuntimeGenerationControlError.recordConflict(
                kind: "vault_backup",
                id: backupRootURL.lastPathComponent
            )
        }
        try fileManager.createDirectory(
            at: backupRootURL,
            withIntermediateDirectories: false
        )
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: backupRootURL,
            artifact: "generation_backup_vault_root"
        )
        do {
            var copied: [RuntimeGenerationVaultBlobArtifact] = []
            copied.reserveCapacity(snapshot.artifacts.count)
            for artifact in snapshot.artifacts {
                try Task.checkCancellation()
                let destinationDirectory = backupRootURL.appendingPathComponent(
                    artifact.opaqueRelativeDirectory,
                    isDirectory: true
                )
                try createProtectedDirectoryChain(
                    relativeDirectory: artifact.opaqueRelativeDirectory,
                    rootURL: backupRootURL,
                    fileManager: fileManager
                )
                let backupPayload = try copyVerifiedArtifact(
                    artifact.payloadArtifact,
                    sourceRootURL: sourceRootURL,
                    destinationRootURL: backupRootURL,
                    destinationRelativePath: "\(artifact.opaqueRelativeDirectory)/payload.aead",
                    destinationArtifactRelativePath:
                        "Vault/\(artifact.opaqueRelativeDirectory)/payload.aead"
                )
                let backupManifest = try copyVerifiedArtifact(
                    artifact.manifestArtifact,
                    sourceRootURL: sourceRootURL,
                    destinationRootURL: backupRootURL,
                    destinationRelativePath: "\(artifact.opaqueRelativeDirectory)/manifest.json",
                    destinationArtifactRelativePath:
                        "Vault/\(artifact.opaqueRelativeDirectory)/manifest.json"
                )
                let backupFinalization = try artifact.finalizationArtifact.map {
                    try copyVerifiedArtifact(
                        $0,
                        sourceRootURL: sourceRootURL,
                        destinationRootURL: backupRootURL,
                        destinationRelativePath: "\(artifact.opaqueRelativeDirectory)/finalized.json",
                        destinationArtifactRelativePath:
                            "Vault/\(artifact.opaqueRelativeDirectory)/finalized.json"
                    )
                }
                try RuntimeStoreFileDurability.synchronizeDirectory(at: destinationDirectory)
                copied.append(RuntimeGenerationVaultBlobArtifact(
                    blobID: artifact.blobID,
                    manifestDigest: artifact.manifestDigest,
                    opaqueRelativeDirectory: artifact.opaqueRelativeDirectory,
                    payloadArtifact: artifact.payloadArtifact,
                    manifestArtifact: artifact.manifestArtifact,
                    finalizationArtifact: artifact.finalizationArtifact,
                    envelopeDigest: artifact.envelopeDigest,
                    wrappingKeyID: artifact.wrappingKeyID,
                    wrappingKeyVersion: artifact.wrappingKeyVersion,
                    artifactDigest: artifact.artifactDigest,
                    backupPayloadArtifact: backupPayload,
                    backupManifestArtifact: backupManifest,
                    backupFinalizationArtifact: backupFinalization
                ))
            }
            try RuntimeStoreFileDurability.synchronizeDirectory(at: backupRootURL)
            try RuntimeStoreFileDurability.synchronizeDirectory(
                at: backupRootURL.deletingLastPathComponent()
            )
            return RuntimeGenerationVerifiedVaultSnapshot(
                blobSetDigest: snapshot.blobSetDigest,
                manifestSetDigest: snapshot.manifestSetDigest,
                keyIdentityDigest: snapshot.keyIdentityDigest,
                artifacts: copied
            )
        } catch {
            let operationError = error
            var status = stat()
            guard lstat(backupRootURL.path, &status) == 0,
                  status.st_mode & S_IFMT == S_IFDIR else {
                throw RuntimeGenerationControlError.verificationRejected
            }
            let failedURL = backupRootURL.deletingLastPathComponent()
                .appendingPathComponent(
                    ".failed-vault-\(UInt64(status.st_dev))-\(UInt64(status.st_ino))",
                    isDirectory: true
                )
            guard Darwin.rename(backupRootURL.path, failedURL.path) == 0 else {
                throw RuntimeGenerationControlError.verificationRejected
            }
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: failedURL,
                artifact: "failed_generation_backup_vault"
            )
            try RuntimeStoreFileDurability.synchronizeDirectory(
                at: backupRootURL.deletingLastPathComponent()
            )
            throw operationError
        }
    }

    static func restoreMissingArtifacts(
        _ snapshot: RuntimeGenerationVerifiedVaultSnapshot,
        backupDirectoryURL: URL,
        vaultRootURL: URL,
        fileManager: FileManager = .default
    ) throws {
        for artifact in snapshot.artifacts {
            try createProtectedDirectoryChain(
                relativeDirectory: artifact.opaqueRelativeDirectory,
                rootURL: vaultRootURL,
                fileManager: fileManager
            )
            guard let backupPayload = artifact.backupPayloadArtifact,
                  let backupManifest = artifact.backupManifestArtifact else {
                throw RuntimeGenerationControlError.restoreSourceUnverified
            }
            try restoreOne(
                backupPayload,
                expectedLiveArtifact: artifact.payloadArtifact,
                backupDirectoryURL: backupDirectoryURL,
                vaultRootURL: vaultRootURL
            )
            try restoreOne(
                backupManifest,
                expectedLiveArtifact: artifact.manifestArtifact,
                backupDirectoryURL: backupDirectoryURL,
                vaultRootURL: vaultRootURL
            )
            if let expectedLive = artifact.finalizationArtifact {
                guard let backup = artifact.backupFinalizationArtifact else {
                    throw RuntimeGenerationControlError.restoreSourceUnverified
                }
                try restoreOne(
                    backup,
                    expectedLiveArtifact: expectedLive,
                    backupDirectoryURL: backupDirectoryURL,
                    vaultRootURL: vaultRootURL
                )
            }
            try RuntimeStoreFileDurability.synchronizeDirectory(
                at: vaultRootURL.appendingPathComponent(
                    artifact.opaqueRelativeDirectory,
                    isDirectory: true
                )
            )
        }
        try RuntimeStoreFileDurability.synchronizeDirectory(at: vaultRootURL)
    }

    static func verifyProtectedBackup(
        _ snapshot: RuntimeGenerationVerifiedVaultSnapshot,
        backupDirectoryURL: URL,
        keyCustody: any RuntimeAttachmentKeyCustody
    ) async throws {
        let pin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            backupDirectoryURL,
            createFinalComponentIfMissing: false
        )
        try pin.revalidate()
        let ordered = snapshot.artifacts.sorted { $0.blobID < $1.blobID }
        guard ordered == snapshot.artifacts,
              Set(ordered.map(\.blobID)).count == ordered.count else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
        for artifact in ordered {
            try Task.checkCancellation()
            guard let payload = artifact.backupPayloadArtifact,
                  let manifest = artifact.backupManifestArtifact else {
                throw RuntimeGenerationControlError.restoreSourceUnverified
            }
            let backupArtifacts = [payload, manifest] +
                (artifact.backupFinalizationArtifact.map { [$0] } ?? [])
            for expected in backupArtifacts {
                let observed = try RuntimeGenerationDatabaseAuthority.artifact(
                    at: backupDirectoryURL.appendingPathComponent(expected.relativePath),
                    relativePath: expected.relativePath
                )
                guard observed == expected else {
                    throw RuntimeGenerationControlError.restoreSourceUnverified
                }
            }
        }
        let blobSetDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: (["runtime-generation-vault-blobs-v1"] +
                ordered.map(\.artifactDigest)).joined(separator: "\n")
        )
        let manifestSetDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: (["runtime-generation-vault-manifests-v1"] + ordered.flatMap {
                [$0.blobID, $0.manifestDigest, $0.opaqueRelativeDirectory]
            }).joined(separator: "\n")
        )
        let keyPairs = Set(ordered.map {
            "\($0.wrappingKeyID)\n\($0.wrappingKeyVersion)"
        })
        var keyProofs: [String] = []
        if keyPairs.isEmpty {
            keyProofs.append(try keyIdentityProof(
                try await keyCustody.currentWrappingKey()
            ))
        } else {
            for pair in keyPairs.sorted() {
                let parts = pair.split(separator: "\n", omittingEmptySubsequences: false)
                guard parts.count == 2,
                      let version = Int(parts[1]),
                      let keyID = RuntimeBlobKeyID(rawValue: String(parts[0])) else {
                    throw RuntimeGenerationControlError.restoreSourceUnverified
                }
                keyProofs.append(try keyIdentityProof(
                    try await keyCustody.wrappingKey(id: keyID, version: version)
                ))
            }
        }
        let keyIdentityDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: (["runtime-generation-vault-keys-v2"] + keyProofs.sorted())
                .joined(separator: "\n")
        )
        try pin.revalidate()
        guard blobSetDigest == snapshot.blobSetDigest,
              manifestSetDigest == snapshot.manifestSetDigest,
              keyIdentityDigest == snapshot.keyIdentityDigest else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
    }

    private static func restoreOne(
        _ backupArtifact: RuntimeGenerationArtifact,
        expectedLiveArtifact: RuntimeGenerationArtifact,
        backupDirectoryURL: URL,
        vaultRootURL: URL,
        fileManager: FileManager = .default
    ) throws {
        let liveURL = vaultRootURL.appendingPathComponent(
            expectedLiveArtifact.relativePath
        )
        if fileManager.fileExists(atPath: liveURL.path) {
            let observed = try RuntimeGenerationDatabaseAuthority.artifact(
                at: liveURL,
                relativePath: expectedLiveArtifact.relativePath
            )
            guard observed.sha256 == expectedLiveArtifact.sha256,
                  observed.byteCount == expectedLiveArtifact.byteCount else {
                throw RuntimeGenerationControlError.restoreSourceUnverified
            }
            return
        }
        let restored = try copyVerifiedArtifact(
            backupArtifact,
            sourceRootURL: backupDirectoryURL,
            destinationRootURL: vaultRootURL,
            destinationRelativePath: expectedLiveArtifact.relativePath,
            destinationArtifactRelativePath: expectedLiveArtifact.relativePath
        )
        guard restored.sha256 == expectedLiveArtifact.sha256,
              restored.byteCount == expectedLiveArtifact.byteCount else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
    }

    private static func createProtectedDirectoryChain(
        relativeDirectory: String,
        rootURL: URL,
        fileManager: FileManager
    ) throws {
        guard RuntimeAttachmentCodec.validOpaqueDirectory(relativeDirectory) else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        var current = rootURL
        for component in relativeDirectory.split(separator: "/").map(String.init) {
            try RuntimeStorePathValidation.requireSafeComponent(component)
            let next = current.appendingPathComponent(component, isDirectory: true)
            if fileManager.fileExists(atPath: next.path) == false {
                try fileManager.createDirectory(
                    at: next,
                    withIntermediateDirectories: false
                )
                try RuntimeStoreFileDurability.applyCompleteProtection(
                    at: next,
                    artifact: "generation_backup_vault_directory"
                )
                try RuntimeStoreFileDurability.synchronizeDirectory(at: current)
            } else {
                try RuntimeStoreFileDurability.requireDirectory(
                    at: next,
                    artifact: "generation_backup_vault_directory"
                )
            }
            current = next
        }
    }

    private static func copyVerifiedArtifact(
        _ sourceArtifact: RuntimeGenerationArtifact,
        sourceRootURL: URL,
        destinationRootURL: URL,
        destinationRelativePath: String,
        destinationArtifactRelativePath: String
    ) throws -> RuntimeGenerationArtifact {
        let sourceURL = sourceRootURL.appendingPathComponent(sourceArtifact.relativePath)
        let observedSource = try RuntimeGenerationDatabaseAuthority.artifact(
            at: sourceURL,
            relativePath: sourceArtifact.relativePath
        )
        guard observedSource.semantic == sourceArtifact else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        let source = Darwin.open(sourceURL.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard source >= 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "open_vault_backup_source"
            )
        }
        defer { _ = Darwin.close(source) }
        var sourceStatus = stat()
        guard fstat(source, &sourceStatus) == 0,
              sourceStatus.st_mode & S_IFMT == S_IFREG,
              sourceStatus.st_nlink == 1,
              sourceStatus.st_size == sourceArtifact.byteCount,
              observedSource.fileIdentity == RuntimeStoreFileIdentity(
                  device: UInt64(sourceStatus.st_dev),
                  inode: UInt64(sourceStatus.st_ino)
              ) else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        let destinationURL = destinationRootURL.appendingPathComponent(
            destinationRelativePath
        )
        let destination = Darwin.open(
            destinationURL.path,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard destination >= 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "reserve_vault_backup_destination"
            )
        }
        var destinationOpen = true
        defer { if destinationOpen { _ = Darwin.close(destination) } }
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: destinationURL,
            artifact: "generation_backup_vault_file_reserved"
        )
        var buffer = [UInt8](repeating: 0, count: 128 * 1_024)
        while true {
            try Task.checkCancellation()
            let count = buffer.withUnsafeMutableBytes {
                Darwin.read(source, $0.baseAddress, $0.count)
            }
            if count < 0, errno == EINTR { continue }
            guard count >= 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "read_vault_backup_source"
                )
            }
            if count == 0 { break }
            var offset = 0
            while offset < count {
                let written = buffer.withUnsafeBytes {
                    Darwin.write(
                        destination,
                        $0.baseAddress?.advanced(by: offset),
                        count - offset
                    )
                }
                if written < 0, errno == EINTR { continue }
                guard written > 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "write_vault_backup_destination"
                    )
                }
                offset += written
            }
        }
        let syncResult = Darwin.fsync(destination)
        let closeResult = Darwin.close(destination)
        destinationOpen = false
        guard syncResult == 0, closeResult == 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "sync_vault_backup_destination"
            )
        }
        var finalSourceStatus = stat()
        guard fstat(source, &finalSourceStatus) == 0,
              finalSourceStatus.st_dev == sourceStatus.st_dev,
              finalSourceStatus.st_ino == sourceStatus.st_ino,
              finalSourceStatus.st_size == sourceStatus.st_size,
              finalSourceStatus.st_nlink == 1 else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        let backupArtifact = try RuntimeGenerationDatabaseAuthority.artifact(
            at: destinationURL,
            relativePath: destinationArtifactRelativePath
        )
        guard backupArtifact.sha256 == sourceArtifact.sha256,
              backupArtifact.byteCount == sourceArtifact.byteCount else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        return backupArtifact.semantic
    }
}

/// First-install vault preparation is intentionally separate from independent
/// verification. This slice supports only a provably empty T14 vault; existing
/// files require the typed legacy/import review path and are never silently
/// adopted into an empty canonical database.
enum RuntimeGenerationVaultInventoryReader {
    static func prepareEmpty(
        rootURL: URL,
        keyCustody: any RuntimeAttachmentKeyCustody,
        fileManager: FileManager = .default
    ) async throws -> RuntimeGenerationVaultInventory {
        if fileManager.fileExists(atPath: rootURL.path) == false {
            try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)
        }
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: rootURL,
            artifact: "attachment_vault_root"
        )
        let key = try await keyCustody.currentWrappingKey()
        return try verifyEmpty(
            rootURL: rootURL,
            keyID: key.id,
            keyVersion: key.version,
            keyCustody: keyCustody,
            fileManager: fileManager
        )
    }

    static func verifyEmpty(
        rootURL: URL,
        expected: RuntimeGenerationVaultInventory,
        keyCustody: any RuntimeAttachmentKeyCustody,
        fileManager: FileManager = .default
    ) async throws -> RuntimeGenerationVaultInventory {
        let observed = try await verifyEmpty(
            rootURL: rootURL,
            keyID: expected.wrappingKeyID,
            keyVersion: expected.wrappingKeyVersion,
            keyCustody: keyCustody,
            fileManager: fileManager
        )
        guard observed == expected else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        return observed
    }

    private static func verifyEmpty(
        rootURL: URL,
        keyID: RuntimeBlobKeyID,
        keyVersion: Int,
        keyCustody: any RuntimeAttachmentKeyCustody,
        fileManager: FileManager
    ) async throws -> RuntimeGenerationVaultInventory {
        try RuntimeStoreFileDurability.requireDirectory(
            at: rootURL,
            artifact: "attachment_vault_root"
        )
        try RuntimeStoreFileDurability.requireCompleteProtection(
            at: rootURL,
            artifact: "attachment_vault_root"
        )
        let pin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            rootURL,
            createFinalComponentIfMissing: false
        )
        try pin.revalidate()
        let entries = try fileManager.contentsOfDirectory(
            at: rootURL,
            includingPropertiesForKeys: nil,
            options: []
        )
        guard entries.isEmpty else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        let key = try await keyCustody.wrappingKey(id: keyID, version: keyVersion)
        let challenge = Data("ambitions.runtime.generation.key-identity.v1".utf8)
        let proof = HMAC<SHA256>.authenticationCode(for: challenge, using: key.key)
        let keyIdentity = LocalRuntimeStorageChecksum.sha256Hex(
            for: "\(key.id.rawValue)\n\(key.version)\n\(Data(proof).base64EncodedString())"
        )
        try pin.revalidate()
        let identity = pin.identity
        let rootMaterial = "\(identity.device):\(identity.inode)"
        return RuntimeGenerationVaultInventory(
            blobSetDigest: LocalRuntimeStorageChecksum.sha256Hex(
                for: "attachment-vault-empty-v1\n\(rootMaterial)"
            ),
            manifestSetDigest: LocalRuntimeStorageChecksum.sha256Hex(
                for: "attachment-vault-manifests-empty-v1\n\(rootMaterial)"
            ),
            keyIdentityDigest: keyIdentity,
            encryptionScheme: "sqlite-file-protection-complete+attachment-aes-gcm-v1",
            wrappingKeyID: key.id,
            wrappingKeyVersion: key.version,
            rootIdentity: identity,
            fileCount: 0
        )
    }
}
