import Foundation

let runtimeGenerationActiveSelectorVersion = 2

/// Minimal active-store selector. It contains no user data and names all three
/// digest domains so a resolver cannot confuse semantic authority with file
/// bytes or selector bytes.
struct RuntimeGenerationActiveSelector: Codable, Sendable, Equatable {
    let formatVersion: Int
    let generationID: RuntimeStoreGenerationID
    let schemaVersion: Int
    let relativeDatabasePath: String
    let authorityManifestDigest: String
    let authorityManifestFileSHA256: String
    let verificationID: String
    let activationIntentID: String
    let priorGenerationID: RuntimeStoreGenerationID?
    let priorAuthorityManifestDigest: String?
    /// Candidate preparation time. The actual selector commit time exists only
    /// in the durable activation-consumption record.
    let preparedAtMilliseconds: Int64

    enum CodingKeys: String, CodingKey, CaseIterable {
        case formatVersion = "format_version"
        case generationID = "generation_id"
        case schemaVersion = "schema_version"
        case relativeDatabasePath = "relative_database_path"
        case authorityManifestDigest = "authority_manifest_digest"
        case authorityManifestFileSHA256 = "authority_manifest_file_sha256"
        case verificationID = "verification_id"
        case activationIntentID = "activation_intent_id"
        case priorGenerationID = "prior_generation_id"
        case priorAuthorityManifestDigest = "prior_authority_manifest_digest"
        case preparedAtMilliseconds = "prepared_at_ms"
    }

    func validate() throws {
        guard formatVersion <= runtimeGenerationActiveSelectorVersion else {
            throw RuntimeGenerationControlError.futureVersion(
                maximumSupported: runtimeGenerationActiveSelectorVersion,
                actual: formatVersion
            )
        }
        guard formatVersion == runtimeGenerationActiveSelectorVersion else {
            throw RuntimeGenerationControlError.unsupportedVersion(
                expected: runtimeGenerationActiveSelectorVersion,
                actual: formatVersion
            )
        }
        guard schemaVersion == runtimeCanonicalAttachmentSchemaVersion,
              preparedAtMilliseconds >= 0,
              (priorGenerationID == nil) == (priorAuthorityManifestDigest == nil)
        else { throw RuntimeGenerationControlError.malformed(field: "active_selector") }
        try RuntimeStorePathValidation.requireSafeComponent(generationID.pathComponent)
        try RuntimeGenerationControlValidation.requireRelativePath(relativeDatabasePath)
        for (value, field) in [
            (authorityManifestDigest, "selector_authority_manifest_digest"),
            (authorityManifestFileSHA256, "selector_authority_manifest_file_sha256"),
        ] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        for (value, field) in [
            (verificationID, "selector_verification_id"),
            (activationIntentID, "selector_activation_intent_id"),
        ] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        if let priorAuthorityManifestDigest {
            try RuntimeGenerationControlValidation.requireDigest(
                priorAuthorityManifestDigest,
                field: "selector_prior_authority_manifest_digest"
            )
        }
    }
}

enum RuntimeGenerationActiveSelectorCodec {
    static func encode(_ selector: RuntimeGenerationActiveSelector) throws -> Data {
        try selector.validate()
        return try RuntimeGenerationControlCodec.encode(selector)
    }

    static func decode(_ data: Data) throws -> RuntimeGenerationActiveSelector {
        let selector = try RuntimeGenerationControlCodec.decode(
            RuntimeGenerationActiveSelector.self,
            from: data
        )
        try selector.validate()
        return selector
    }
}
