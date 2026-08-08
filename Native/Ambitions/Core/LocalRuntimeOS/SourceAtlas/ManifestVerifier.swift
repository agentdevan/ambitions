import Foundation

enum ManifestVerificationIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case versionMismatch = "version_mismatch"
    case missingPackEntry = "missing_pack_entry"
    case manifestHashMismatch = "manifest_hash_mismatch"
    case staleManifest = "stale_manifest"
    case signatureInvalid = "signature_invalid"
}

struct ManifestVerificationResult: Codable, Sendable, Equatable, Hashable {
    let manifestVersionID: String
    let packID: String
    let issues: [ManifestVerificationIssue]
    let signatureResult: SignatureVerificationResult?

    var isVerified: Bool {
        issues.isEmpty && (signatureResult?.isVerified ?? true)
    }
}

struct ManifestVerifier: Sendable, Equatable, Hashable {
    private let signatureVerifier: SignatureVerifier

    init(signatureVerifier: SignatureVerifier = SignatureVerifier()) {
        self.signatureVerifier = signatureVerifier
    }

    static func signingPayload(
        for manifest: SourceAtlasFreshnessManifest
    ) throws -> Data {
        let payload = SigningManifest(
            schemaVersion: manifest.schemaVersion,
            versionID: manifest.versionID,
            publishedAt: manifest.publishedAt,
            packIndex: manifest.packIndex.map {
                SigningPackEntry(
                    packID: $0.packID,
                    currentSHA256: $0.currentSHA256,
                    rollbackPointers: $0.rollbackPointers,
                    changedClaimIDs: $0.changedClaimIDs,
                    claimStateBuckets: $0.claimStateBuckets
                )
            },
            globalClaimStateBuckets: manifest.globalClaimStateBuckets
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(payload)
    }

    func verify(
        manifest: SourceAtlasFreshnessManifest,
        packID: String,
        expectedVersionID: String,
        manifestData: Data? = nil,
        expectedManifestSHA256: String? = nil,
        checkedAt: Date,
        maximumAgeDays: Int = 30,
        ed25519PublicKey: Data? = nil
    ) -> ManifestVerificationResult {
        let trimmedPackID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        var issues: Set<ManifestVerificationIssue> = []

        if manifest.schemaVersion != 1 {
            issues.insert(.unsupportedSchema)
        }
        if manifest.versionID != expectedVersionID.trimmingCharacters(in: .whitespacesAndNewlines) {
            issues.insert(.versionMismatch)
        }
        guard let entry = manifest.packIndex.first(where: { $0.packID == trimmedPackID }) else {
            issues.insert(.missingPackEntry)
            return ManifestVerificationResult(
                manifestVersionID: manifest.versionID,
                packID: trimmedPackID,
                issues: ManifestVerificationIssue.allCases.filter { issues.contains($0) },
                signatureResult: nil
            )
        }
        if let manifestData, let expectedManifestSHA256,
           SourceAtlasStore.sha256Hex(for: manifestData) != expectedManifestSHA256.lowercased() {
            issues.insert(.manifestHashMismatch)
        }
        if manifest.publishedAt.addingTimeInterval(TimeInterval(maximumAgeDays * 24 * 60 * 60)) < checkedAt {
            issues.insert(.staleManifest)
        }

        let usesCanonicalManifestSignature = entry.currentSignature.hasPrefix("ed25519:") && manifestData != nil
        let signedData = usesCanonicalManifestSignature
            ? ((try? Self.signingPayload(for: manifest)) ?? Data())
            : Data(entry.currentSHA256.utf8)
        let signatureResult = signatureVerifier.verify(
            signature: entry.currentSignature,
            signedData: signedData,
            expectedSHA256: usesCanonicalManifestSignature ? nil : expectedManifestSHA256,
            ed25519PublicKey: ed25519PublicKey
        )
        if signatureResult.isVerified == false {
            issues.insert(.signatureInvalid)
        }

        return ManifestVerificationResult(
            manifestVersionID: manifest.versionID,
            packID: trimmedPackID,
            issues: ManifestVerificationIssue.allCases.filter { issues.contains($0) },
            signatureResult: signatureResult
        )
    }
}

private struct SigningManifest: Encodable {
    let schemaVersion: Int
    let versionID: String
    let publishedAt: Date
    let packIndex: [SigningPackEntry]
    let globalClaimStateBuckets: [SourceAtlasFreshnessBrokerClaimStateBucket]
}

private struct SigningPackEntry: Encodable {
    let packID: String
    let currentSHA256: String
    let rollbackPointers: [String: String]
    let changedClaimIDs: [String]
    let claimStateBuckets: [SourceAtlasFreshnessBrokerClaimStateBucket]
}
