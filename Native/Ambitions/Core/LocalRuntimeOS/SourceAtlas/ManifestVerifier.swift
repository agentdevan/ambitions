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

        let signatureResult = signatureVerifier.verify(
            signature: entry.currentSignature,
            signedData: manifestData ?? Data(entry.currentSHA256.utf8),
            expectedSHA256: expectedManifestSHA256,
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
