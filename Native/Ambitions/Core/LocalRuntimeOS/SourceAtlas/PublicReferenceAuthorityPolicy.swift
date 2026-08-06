import Foundation

enum PublicReferenceAuthorityFailureReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsafePublicRequest = "unsafe_public_request"
    case malformedClaim = "malformed_claim"
    case schemaMismatch = "schema_mismatch"
    case signatureInvalid = "signature_invalid"
    case unsupportedJurisdiction = "unsupported_jurisdiction"
    case unsupportedAuthorityLane = "unsupported_authority_lane"
    case rightsBlocked = "rights_blocked"
    case freshnessBlocked = "freshness_blocked"
    case conflictPresent = "conflict_present"
    case unavailable = "unavailable"
}

/// A certificate is a public artifact contract, never evidence about a user.
struct PublicReferenceAuthorityCertificate: Codable, Sendable, Equatable, Hashable {
    let artifactID: String
    let schemaVersion: String
    let signatureVerified: Bool
    let permittedJurisdictionCodes: Set<String>
    let permittedAuthorityLanes: Set<PublicReferenceAuthorityLane>

    init(
        artifactID: String,
        schemaVersion: String = publicReferenceKnowledgeSchemaVersion,
        signatureVerified: Bool,
        permittedJurisdictionCodes: Set<String>,
        permittedAuthorityLanes: Set<PublicReferenceAuthorityLane>
    ) {
        self.artifactID = artifactID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.schemaVersion = schemaVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.signatureVerified = signatureVerified
        self.permittedJurisdictionCodes = Set(permittedJurisdictionCodes.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() })
        self.permittedAuthorityLanes = permittedAuthorityLanes
    }
}

struct PublicReferenceAuthorityValidationInput: Sendable, Equatable, Hashable {
    let request: SourceAtlasPublicPackRequest
    let claim: PublicReferenceClaimEnvelope
    let certificate: PublicReferenceAuthorityCertificate
}

struct PublicReferenceAuthorityDecision: Codable, Sendable, Equatable, Hashable {
    let claimID: PublicReferenceClaimID
    let availability: PublicReferenceClaimAvailability
    let failureReasons: [PublicReferenceAuthorityFailureReason]

    var isAccepted: Bool {
        failureReasons.isEmpty
    }
}

/// A deterministic, fail-closed semantic gate after structural pack validation.
struct PublicReferenceAuthorityPolicy: Sendable, Equatable, Hashable {
    let freshnessEngine: FreshnessEngine

    init(freshnessEngine: FreshnessEngine = FreshnessEngine()) {
        self.freshnessEngine = freshnessEngine
    }

    func evaluate(_ input: PublicReferenceAuthorityValidationInput) -> PublicReferenceAuthorityDecision {
        var reasons: Set<PublicReferenceAuthorityFailureReason> = []
        if SourceAtlasPublicPackRequestValidator().validate(input.request).isEmpty == false {
            reasons.insert(.unsafePublicRequest)
        }
        if input.claim.isWellFormed == false {
            reasons.insert(.malformedClaim)
        }
        if input.claim.schemaVersion != publicReferenceKnowledgeSchemaVersion ||
            input.certificate.schemaVersion != publicReferenceKnowledgeSchemaVersion {
            reasons.insert(.schemaMismatch)
        }
        if input.certificate.signatureVerified == false {
            reasons.insert(.signatureInvalid)
        }
        if input.certificate.artifactID != input.request.packID ||
            input.certificate.permittedJurisdictionCodes.contains(input.claim.jurisdiction.code.uppercased()) == false {
            reasons.insert(.unsupportedJurisdiction)
        }
        if input.certificate.permittedAuthorityLanes.contains(input.claim.authority.lane) == false {
            reasons.insert(.unsupportedAuthorityLane)
        }
        if input.claim.rightsState == .reviewRequired || input.claim.rightsState == .withdrawn {
            reasons.insert(.rightsBlocked)
        }
        if input.claim.conflictIDs.isEmpty == false || input.claim.semanticReviewState == .disputed {
            reasons.insert(.conflictPresent)
        }
        if freshnessEngine.publicReferenceVerdict(for: input.claim).blocksCurrentUse {
            reasons.insert(.freshnessBlocked)
        }
        if input.claim.availability == .unavailable {
            reasons.insert(.unavailable)
        }

        return PublicReferenceAuthorityDecision(
            claimID: input.claim.id,
            availability: input.claim.availability,
            failureReasons: PublicReferenceAuthorityFailureReason.allCases.filter { reasons.contains($0) }
        )
    }
}
