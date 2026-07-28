import CryptoKit
import Foundation
import Security

struct RuntimeAttachmentWrappingKey: Sendable {
    let id: RuntimeBlobKeyID
    let version: Int
    let key: SymmetricKey
}

protocol RuntimeAttachmentKeyCustody: Sendable {
    func currentWrappingKey() async throws -> RuntimeAttachmentWrappingKey
    func wrappingKey(id: RuntimeBlobKeyID, version: Int) async throws -> RuntimeAttachmentWrappingKey
    func contentAddressKey() async throws -> SymmetricKey
    func makeDataEncryptionKey() async throws -> SymmetricKey
    func wrap(_ key: SymmetricKey, for blobID: RuntimeBlobID) async throws -> RuntimeBlobKeyEnvelope
    func unwrap(_ envelope: RuntimeBlobKeyEnvelope) async throws -> SymmetricKey
    func prepareWrappingKeyRotation(
        replacing source: RuntimeAttachmentWrappingKey
    ) async throws -> RuntimeAttachmentWrappingKey
    func activatePreparedWrappingKey(
        _ target: RuntimeAttachmentWrappingKey,
        replacing source: RuntimeAttachmentWrappingKey
    ) async throws
    func rewrap(
        _ envelope: RuntimeBlobKeyEnvelope,
        using target: RuntimeAttachmentWrappingKey
    ) async throws -> RuntimeBlobKeyEnvelope
    var supportsIrreversibleKeyRetirement: Bool { get async }
}

extension RuntimeAttachmentKeyCustody {
    func prepareWrappingKeyRotation(
        replacing _: RuntimeAttachmentWrappingKey
    ) async throws -> RuntimeAttachmentWrappingKey {
        throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
    }

    func activatePreparedWrappingKey(
        _: RuntimeAttachmentWrappingKey,
        replacing _: RuntimeAttachmentWrappingKey
    ) async throws {
        throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
    }

    func rewrap(
        _ envelope: RuntimeBlobKeyEnvelope,
        using target: RuntimeAttachmentWrappingKey
    ) async throws -> RuntimeBlobKeyEnvelope {
        let plaintextKey = try await unwrap(envelope)
        return try await seal(plaintextKey, for: envelope.blobID, using: target)
    }

    var supportsIrreversibleKeyRetirement: Bool { get async { false } }

    private func seal(
        _ key: SymmetricKey,
        for blobID: RuntimeBlobID,
        using wrapping: RuntimeAttachmentWrappingKey
    ) throws -> RuntimeBlobKeyEnvelope {
        let sealed = try AES.GCM.seal(
            key.withUnsafeBytes { Data($0) }, using: wrapping.key,
            authenticating: Data("ambitions.attachment.keywrap.v1\u{0}\(blobID.rawValue)".utf8)
        )
        guard let combined = sealed.combined else {
            throw RuntimeCanonicalAttachmentError.keyEnvelopeInvalid
        }
        let unsigned = RuntimeBlobKeyEnvelope(
            version: runtimeCanonicalAttachmentModelVersion, blobID: blobID,
            wrappingKeyID: wrapping.id, wrappingKeyVersion: wrapping.version,
            algorithm: "AES.GCM.keywrap.v1", nonce: Data(sealed.nonce),
            wrappedDataEncryptionKey: combined,
            envelopeDigest: String(repeating: "0", count: 64)
        )
        return RuntimeBlobKeyEnvelope(
            version: unsigned.version, blobID: unsigned.blobID,
            wrappingKeyID: unsigned.wrappingKeyID,
            wrappingKeyVersion: unsigned.wrappingKeyVersion,
            algorithm: unsigned.algorithm, nonce: unsigned.nonce,
            wrappedDataEncryptionKey: unsigned.wrappedDataEncryptionKey,
            envelopeDigest: try RuntimeAttachmentCodec.digest(
                unsigned, maximumBytes: RuntimeAttachmentLimits.maximumEnvelopeBytes
            )
        )
    }
}

actor KeychainRuntimeAttachmentKeyCustody: RuntimeAttachmentKeyCustody {
    private static let activeWrappingVersionAccount = "attachment-wrapping-key.active-version"
    private static let wrappingAccountPrefix = "attachment-wrapping-key.v"
    private static let addressAccount = "attachment-content-address-key.v1"
    private static let wrappingKeyIDPrefix = "ambitions.attachment.wrapping.main.v"
    private let service: String

    /// This custody is intentionally locked to the calling application's default
    /// Keychain access group. Production callers cannot redirect it into a shared
    /// extension group, and every item is device-only and non-synchronizable.
    init(service: String = "com.ambitions.runtime.attachments") {
        self.service = service
    }

    func currentWrappingKey() async throws -> RuntimeAttachmentWrappingKey {
        let version = try loadOrCreateActiveWrappingVersion()
        guard let id = wrappingKeyID(version: version) else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return RuntimeAttachmentWrappingKey(
            id: id,
            version: version,
            key: try loadOrCreate(account: wrappingAccount(version: version))
        )
    }

    func wrappingKey(id: RuntimeBlobKeyID, version: Int) async throws -> RuntimeAttachmentWrappingKey {
        guard version > 0, id == wrappingKeyID(version: version),
              let data = try load(account: wrappingAccount(version: version)), data.count == 32 else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return RuntimeAttachmentWrappingKey(id: id, version: version, key: SymmetricKey(data: data))
    }

    func contentAddressKey() async throws -> SymmetricKey {
        try loadOrCreate(account: Self.addressAccount)
    }

    func makeDataEncryptionKey() async throws -> SymmetricKey {
        try Task.checkCancellation()
        return SymmetricKey(size: .bits256)
    }

    func wrap(_ key: SymmetricKey, for blobID: RuntimeBlobID) async throws -> RuntimeBlobKeyEnvelope {
        try Task.checkCancellation()
        let wrapping = try await currentWrappingKey()
        return try makeEnvelope(key, for: blobID, using: wrapping)
    }

    private func makeEnvelope(
        _ key: SymmetricKey,
        for blobID: RuntimeBlobID,
        using wrapping: RuntimeAttachmentWrappingKey
    ) throws -> RuntimeBlobKeyEnvelope {
        let sealed = try AES.GCM.seal(
            key.withUnsafeBytes { Data($0) },
            using: wrapping.key,
            authenticating: Data("ambitions.attachment.keywrap.v1\u{0}\(blobID.rawValue)".utf8)
        )
        guard let combined = sealed.combined else {
            throw RuntimeCanonicalAttachmentError.keyEnvelopeInvalid
        }
        let unsigned = RuntimeBlobKeyEnvelope(
            version: runtimeCanonicalAttachmentModelVersion,
            blobID: blobID,
            wrappingKeyID: wrapping.id,
            wrappingKeyVersion: wrapping.version,
            algorithm: "AES.GCM.keywrap.v1",
            nonce: Data(sealed.nonce),
            wrappedDataEncryptionKey: combined,
            envelopeDigest: String(repeating: "0", count: 64)
        )
        let digest = try RuntimeAttachmentCodec.digest(
            unsigned, maximumBytes: RuntimeAttachmentLimits.maximumEnvelopeBytes
        )
        return RuntimeBlobKeyEnvelope(
            version: unsigned.version, blobID: unsigned.blobID,
            wrappingKeyID: unsigned.wrappingKeyID, wrappingKeyVersion: unsigned.wrappingKeyVersion,
            algorithm: unsigned.algorithm, nonce: unsigned.nonce,
            wrappedDataEncryptionKey: unsigned.wrappedDataEncryptionKey, envelopeDigest: digest
        )
    }

    func unwrap(_ envelope: RuntimeBlobKeyEnvelope) async throws -> SymmetricKey {
        try Task.checkCancellation()
        try RuntimeAttachmentCodec.validate(envelope)
        let wrapping = try await wrappingKey(
            id: envelope.wrappingKeyID, version: envelope.wrappingKeyVersion
        )
        do {
            let sealed = try AES.GCM.SealedBox(combined: envelope.wrappedDataEncryptionKey)
            guard Data(sealed.nonce) == envelope.nonce else {
                throw RuntimeCanonicalAttachmentError.keyEnvelopeInvalid
            }
            let raw = try AES.GCM.open(
                sealed,
                using: wrapping.key,
                authenticating: Data("ambitions.attachment.keywrap.v1\u{0}\(envelope.blobID.rawValue)".utf8)
            )
            guard raw.count == 32 else { throw RuntimeCanonicalAttachmentError.keyEnvelopeInvalid }
            return SymmetricKey(data: raw)
        } catch let error as RuntimeCanonicalAttachmentError {
            throw error
        } catch {
            throw RuntimeCanonicalAttachmentError.keyEnvelopeInvalid
        }
    }

    func prepareWrappingKeyRotation(
        replacing source: RuntimeAttachmentWrappingKey
    ) async throws -> RuntimeAttachmentWrappingKey {
        try Task.checkCancellation()
        let current = try await currentWrappingKey()
        guard current.id == source.id, current.version == source.version,
              source.version < Int.max else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        let nextVersion = source.version + 1
        let key = try loadOrCreate(account: wrappingAccount(version: nextVersion))
        guard let id = wrappingKeyID(version: nextVersion) else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return RuntimeAttachmentWrappingKey(id: id, version: nextVersion, key: key)
    }

    func activatePreparedWrappingKey(
        _ target: RuntimeAttachmentWrappingKey,
        replacing source: RuntimeAttachmentWrappingKey
    ) async throws {
        try Task.checkCancellation()
        let active = try await currentWrappingKey()
        guard target.id == wrappingKeyID(version: target.version),
              let prepared = try load(account: wrappingAccount(version: target.version)),
              prepared.count == 32,
              Self.constantTimeEquals(
                  prepared, target.key.withUnsafeBytes { Data($0) }
              ) else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        if active.id == target.id, active.version == target.version { return }
        guard active.id == source.id, active.version == source.version,
              target.version == source.version + 1,
              target.id == wrappingKeyID(version: target.version) else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        try storeActiveWrappingVersion(target.version)
    }

    func rewrap(
        _ envelope: RuntimeBlobKeyEnvelope,
        using target: RuntimeAttachmentWrappingKey
    ) async throws -> RuntimeBlobKeyEnvelope {
        try Task.checkCancellation()
        let stored = try await wrappingKey(id: target.id, version: target.version)
        guard Self.constantTimeEquals(
            stored.key.withUnsafeBytes { Data($0) },
            target.key.withUnsafeBytes { Data($0) }
        ) else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        let plaintextKey = try await unwrap(envelope)
        return try makeEnvelope(plaintextKey, for: envelope.blobID, using: stored)
    }

    private func loadOrCreate(account: String) throws -> SymmetricKey {
        if let data = try load(account: account) {
            guard data.count == 32 else { throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable }
            return SymmetricKey(data: data)
        }
        let key = SymmetricKey(size: .bits256)
        let data = key.withUnsafeBytes { Data($0) }
        var query = baseQuery(account: account)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem, let raced = try load(account: account), raced.count == 32 {
            return SymmetricKey(data: raced)
        }
        guard status == errSecSuccess else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return key
    }

    private func load(account: String) throws -> Data? {
        var query = baseQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return data
    }

    private func loadOrCreateActiveWrappingVersion() throws -> Int {
        if let bytes = try load(account: Self.activeWrappingVersionAccount) {
            return try decodeWrappingVersion(bytes)
        }
        let initial = Data("1".utf8)
        var query = baseQuery(account: Self.activeWrappingVersionAccount)
        query[kSecValueData as String] = initial
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem,
           let raced = try load(account: Self.activeWrappingVersionAccount) {
            return try decodeWrappingVersion(raced)
        }
        guard status == errSecSuccess else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return 1
    }

    private func storeActiveWrappingVersion(_ version: Int) throws {
        guard version > 0 else { throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable }
        let query = baseQuery(account: Self.activeWrappingVersionAccount)
        let attributes = [kSecValueData as String: Data(String(version).utf8)]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
    }

    private func decodeWrappingVersion(_ bytes: Data) throws -> Int {
        guard bytes.isEmpty == false, bytes.count <= 20,
              let raw = String(data: bytes, encoding: .utf8),
              raw.allSatisfy(\.isNumber), let version = Int(raw), version > 0 else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return version
    }

    private func wrappingAccount(version: Int) -> String {
        Self.wrappingAccountPrefix + String(version)
    }

    private func wrappingKeyID(version: Int) -> RuntimeBlobKeyID? {
        RuntimeBlobKeyID(rawValue: Self.wrappingKeyIDPrefix + String(version))
    }

    private func baseQuery(account: String) -> [String: Any] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any,
        ]
        return query
    }

    private static func constantTimeEquals(_ lhs: Data, _ rhs: Data) -> Bool {
        guard lhs.count == rhs.count else { return false }
        var difference: UInt8 = 0
        for index in lhs.indices {
            difference |= lhs[index] ^ rhs[index]
        }
        return difference == 0
    }
}
