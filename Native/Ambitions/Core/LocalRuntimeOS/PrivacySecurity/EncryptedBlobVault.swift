import CryptoKit
import Foundation

let encryptedBlobVaultSchemaVersion = "encrypted_blob_vault.native.v1"

struct EncryptedBlobVaultRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let objectID: String
    let privacyClass: RuntimePrivacyClass
    let blobRecord: BlobStoreFileSystemRecord
    let plaintextSHA256: String
    let encryptedSHA256: String
    let keyID: String
    let algorithm: String
    let schemaVersion: String
}

struct EncryptedBlobVaultWrite: Codable, Sendable, Equatable, Hashable {
    let record: EncryptedBlobVaultRecord
    let receipt: PrivacySecurityReceipt
}

actor EncryptedBlobVault {
    private let blobStore: BlobStoreFileSystem
    private let fileProtectionPolicy: FileProtectionPolicy

    init(
        blobStore: BlobStoreFileSystem,
        fileProtectionPolicy: FileProtectionPolicy = FileProtectionPolicy()
    ) {
        self.blobStore = blobStore
        self.fileProtectionPolicy = fileProtectionPolicy
    }

    static func defaultLiveVault() -> EncryptedBlobVault {
        EncryptedBlobVault(blobStore: .defaultLiveStore())
    }

    func sealAndWrite(
        id: String,
        object: PrivacyClassifiedObject,
        plaintext: Data,
        contentType: String,
        key: SymmetricKey,
        keyID: String,
        createdAt: String
    ) async throws -> EncryptedBlobVaultWrite {
        guard plaintext.isEmpty == false else {
            throw LocalRuntimeStorageError.emptyPayload(id: id)
        }
        let fileProtection = fileProtectionPolicy.decision(for: object)
        let sealedBox = try AES.GCM.seal(plaintext, using: key)
        guard let encrypted = sealedBox.combined else {
            throw LocalRuntimeStorageError.emptyPayload(id: id)
        }
        let blobRecord = try await blobStore.write(
            id: id,
            data: encrypted,
            contentType: contentType,
            protectionClass: fileProtection.protectionLevel.blobStoreProtectionClass,
            createdAt: createdAt
        )
        let record = EncryptedBlobVaultRecord(
            id: "encrypted_blob_vault.\(blobRecord.id)",
            objectID: object.id,
            privacyClass: object.privacyClass,
            blobRecord: blobRecord,
            plaintextSHA256: LocalRuntimeStorageChecksum.sha256Hex(for: plaintext),
            encryptedSHA256: LocalRuntimeStorageChecksum.sha256Hex(for: encrypted),
            keyID: keyID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "local-user-key" : keyID.trimmingCharacters(in: .whitespacesAndNewlines),
            algorithm: "AES.GCM",
            schemaVersion: encryptedBlobVaultSchemaVersion
        )

        return EncryptedBlobVaultWrite(
            record: record,
            receipt: PrivacySecurityReceipt(
                id: "privacy_receipt.encrypted_vault.\(blobRecord.id)",
                action: .encryptedVault,
                objectID: object.id,
                surface: .encryptedVault,
                permitted: true,
                redactionApplied: false,
                localOnlyInspectionPath: "You / Privacy / Encrypted vault / \(object.id)",
                issueCodes: [],
                summary: "Encrypted blob vault wrote \(object.privacyClass.rawValue) data with \(fileProtection.protectionLevel.rawValue) protection."
            )
        )
    }

    func open(
        _ record: EncryptedBlobVaultRecord,
        key: SymmetricKey
    ) async throws -> Data {
        guard record.schemaVersion == encryptedBlobVaultSchemaVersion else {
            throw LocalRuntimeStorageError.unsupportedSchema(expected: encryptedBlobVaultSchemaVersion, actual: record.schemaVersion)
        }
        let encrypted = try await blobStore.read(id: record.blobRecord.id)
        guard LocalRuntimeStorageChecksum.sha256Hex(for: encrypted) == record.encryptedSHA256 else {
            throw LocalRuntimeStorageError.checksumMismatch(id: record.id)
        }
        let sealedBox = try AES.GCM.SealedBox(combined: encrypted)
        let plaintext = try AES.GCM.open(sealedBox, using: key)
        guard LocalRuntimeStorageChecksum.sha256Hex(for: plaintext) == record.plaintextSHA256 else {
            throw LocalRuntimeStorageError.checksumMismatch(id: record.id)
        }
        return plaintext
    }
}
