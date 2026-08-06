import Foundation

let publicReferencePackAdapterSchemaVersion = "public_reference_pack_adapter.native.v1"

enum PublicReferencePackAdapterFailure: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedArtifact = "unsupported_artifact"
    case unsupportedRelease = "unsupported_release"
    case unsupportedPublisher = "unsupported_publisher"
    case unsupportedJurisdiction = "unsupported_jurisdiction"
    case unsupportedSubject = "unsupported_subject"
    case unsupportedPredicate = "unsupported_predicate"
    case invalidClaim = "invalid_claim"
}

struct PublicReferencePackArtifact: Codable, Sendable, Equatable, Hashable {
    let id: String
    let request: SourceAtlasPublicPackRequest
    let release: PublicReferenceRelease
    let publisherID: String
    let jurisdiction: PublicReferenceJurisdiction
    let signatureVerified: Bool
    let claims: [PublicReferenceClaimEnvelope]

    init(
        id: String,
        request: SourceAtlasPublicPackRequest,
        release: PublicReferenceRelease,
        publisherID: String,
        jurisdiction: PublicReferenceJurisdiction,
        signatureVerified: Bool,
        claims: [PublicReferenceClaimEnvelope]
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.request = request
        self.release = release
        self.publisherID = publisherID.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.jurisdiction = jurisdiction
        self.signatureVerified = signatureVerified
        self.claims = claims.sorted { $0.id.rawValue < $1.id.rawValue }
    }
}

struct PublicReferencePackQuarantine: Codable, Sendable, Equatable, Hashable {
    let artifactID: String
    let claimID: PublicReferenceClaimID?
    let failures: [PublicReferencePackAdapterFailure]
}

struct PublicReferenceVerifiedRelease: Codable, Sendable, Equatable, Hashable {
    let artifactID: String
    let release: PublicReferenceRelease
    let claims: [PublicReferenceClaimEnvelope]
    let sourceRevision: String
}

struct PublicReferencePackAdapterResult: Codable, Sendable, Equatable, Hashable {
    let release: PublicReferenceVerifiedRelease?
    let quarantines: [PublicReferencePackQuarantine]

    var isVerified: Bool { release != nil && quarantines.isEmpty }
}

/// A release-pinned adapter for the one approved O*NET corpus. It rejects the
/// whole artifact when any visible claim leaves the allowlist.
struct PublicReferencePackAdapter: Sendable, Equatable, Hashable {
    static let approvedArtifactID = "onet-30.3"
    static let approvedReleaseID = "30.3"
    static let approvedPublisherID = "onet"
    static let approvedJurisdictionCode = "US"
    static let approvedSubjectID = "15-1252.00"
    static let approvedPredicateIDs: Set<String> = [
        "occupation.identity",
        "occupation.task",
        "occupation.skill",
        "occupation.knowledge",
        "occupation.work_activity",
        "occupation.work_context",
        "occupation.education",
        "occupation.experience"
    ]

    let authorityPolicy: PublicReferenceAuthorityPolicy

    init(authorityPolicy: PublicReferenceAuthorityPolicy = PublicReferenceAuthorityPolicy()) {
        self.authorityPolicy = authorityPolicy
    }

    func adapt(_ artifact: PublicReferencePackArtifact) -> PublicReferencePackAdapterResult {
        var quarantines: [PublicReferencePackQuarantine] = []
        let artifactFailures = failures(for: artifact)
        if artifactFailures.isEmpty == false {
            quarantines.append(PublicReferencePackQuarantine(artifactID: artifact.id, claimID: nil, failures: artifactFailures))
        }

        let certificate = PublicReferenceAuthorityCertificate(
            artifactID: artifact.id,
            signatureVerified: artifact.signatureVerified,
            permittedJurisdictionCodes: [Self.approvedJurisdictionCode],
            permittedAuthorityLanes: [.classification, .description, .typicalPreparation]
        )
        for claim in artifact.claims {
            var failures = failures(for: claim)
            let decision = authorityPolicy.evaluate(PublicReferenceAuthorityValidationInput(
                request: artifact.request,
                claim: claim,
                certificate: certificate
            ))
            if decision.isAccepted == false {
                failures.append(.invalidClaim)
            }
            if failures.isEmpty == false {
                quarantines.append(PublicReferencePackQuarantine(
                    artifactID: artifact.id,
                    claimID: claim.id,
                    failures: Array(Set(failures)).sorted { $0.rawValue < $1.rawValue }
                ))
            }
        }

        guard quarantines.isEmpty, artifact.claims.isEmpty == false else {
            return PublicReferencePackAdapterResult(release: nil, quarantines: quarantines)
        }
        return PublicReferencePackAdapterResult(
            release: PublicReferenceVerifiedRelease(
                artifactID: artifact.id,
                release: artifact.release,
                claims: artifact.claims,
                sourceRevision: "\(artifact.release.id)|\(artifact.claims.map(\.contentHash).joined(separator: ","))"
            ),
            quarantines: []
        )
    }
}

private extension PublicReferencePackAdapter {
    func failures(for artifact: PublicReferencePackArtifact) -> [PublicReferencePackAdapterFailure] {
        var failures: [PublicReferencePackAdapterFailure] = []
        if artifact.id != Self.approvedArtifactID || artifact.request.packID != Self.approvedArtifactID {
            failures.append(.unsupportedArtifact)
        }
        if artifact.release.id != Self.approvedReleaseID || artifact.request.manifestVersionID != Self.approvedReleaseID {
            failures.append(.unsupportedRelease)
        }
        if artifact.publisherID != Self.approvedPublisherID {
            failures.append(.unsupportedPublisher)
        }
        if artifact.jurisdiction.code.uppercased() != Self.approvedJurisdictionCode {
            failures.append(.unsupportedJurisdiction)
        }
        return failures
    }

    func failures(for claim: PublicReferenceClaimEnvelope) -> [PublicReferencePackAdapterFailure] {
        var failures: [PublicReferencePackAdapterFailure] = []
        if claim.authority.publisherID.lowercased() != Self.approvedPublisherID {
            failures.append(.unsupportedPublisher)
        }
        if claim.release.id != Self.approvedReleaseID {
            failures.append(.unsupportedRelease)
        }
        if claim.jurisdiction.code.uppercased() != Self.approvedJurisdictionCode {
            failures.append(.unsupportedJurisdiction)
        }
        if claim.sourceNativeSubjectID != Self.approvedSubjectID {
            failures.append(.unsupportedSubject)
        }
        if Self.approvedPredicateIDs.contains(claim.predicateID) == false {
            failures.append(.unsupportedPredicate)
        }
        return failures
    }
}
