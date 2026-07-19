import CryptoKit
import Foundation

enum SignatureVerificationIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingSignature = "missing_signature"
    case unsupportedSignatureFormat = "unsupported_signature_format"
    case missingPublicKey = "missing_public_key"
    case invalidBase64 = "invalid_base64"
    case signatureMismatch = "signature_mismatch"
}

struct SignatureVerificationResult: Codable, Sendable, Equatable, Hashable {
    let signature: String
    let issues: [SignatureVerificationIssue]

    var isVerified: Bool {
        issues.isEmpty
    }
}

struct SignatureVerifier: Sendable, Equatable, Hashable {
    func verify(
        signature: String,
        signedData: Data,
        expectedSHA256: String? = nil,
        ed25519PublicKey: Data? = nil
    ) -> SignatureVerificationResult {
        let trimmed = signature.trimmingCharacters(in: .whitespacesAndNewlines)
        var issues: Set<SignatureVerificationIssue> = []

        if trimmed.isEmpty {
            issues.insert(.missingSignature)
        } else if trimmed.hasPrefix("sha256:") {
            let declared = String(trimmed.dropFirst("sha256:".count)).lowercased()
            if declared != SourceAtlasStore.sha256Hex(for: signedData) {
                issues.insert(.signatureMismatch)
            }
        } else if trimmed.hasPrefix("publisher-pointer:") {
            let pointerHash = String(trimmed.dropFirst("publisher-pointer:".count)).lowercased()
            if let expectedSHA256, pointerHash != expectedSHA256.lowercased() {
                issues.insert(.signatureMismatch)
            } else if SourceAtlasPublishedCurrentPointerValidator.isSHA256Hex(pointerHash) == false {
                issues.insert(.unsupportedSignatureFormat)
            }
        } else if trimmed.hasPrefix("ed25519:") {
            let encodedSignature = String(trimmed.dropFirst("ed25519:".count))
            guard let ed25519PublicKey else {
                issues.insert(.missingPublicKey)
                return result(signature: trimmed, issues: issues)
            }
            guard let signatureData = Data(base64Encoded: encodedSignature) else {
                issues.insert(.invalidBase64)
                return result(signature: trimmed, issues: issues)
            }
            do {
                let key = try Curve25519.Signing.PublicKey(rawRepresentation: ed25519PublicKey)
                if key.isValidSignature(signatureData, for: signedData) == false {
                    issues.insert(.signatureMismatch)
                }
            } catch {
                issues.insert(.missingPublicKey)
            }
        } else {
            issues.insert(.unsupportedSignatureFormat)
        }

        return result(signature: trimmed, issues: issues)
    }

    private func result(
        signature: String,
        issues: Set<SignatureVerificationIssue>
    ) -> SignatureVerificationResult {
        SignatureVerificationResult(
            signature: signature,
            issues: SignatureVerificationIssue.allCases.filter { issues.contains($0) }
        )
    }
}
