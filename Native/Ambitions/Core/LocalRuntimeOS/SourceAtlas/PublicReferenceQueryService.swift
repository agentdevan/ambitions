import Foundation

/// A bounded, public-only selector. It carries no Goal, Capability, Proof,
/// schedule, or free-text context and never initiates a refresh.
struct PublicReferenceInspectionQuery: Codable, Sendable, Equatable, Hashable {
    let artifactID: String
    let claimID: PublicReferenceClaimID?
    let observedSourceRevision: String?

    init(artifactID: String, claimID: PublicReferenceClaimID? = nil, observedSourceRevision: String? = nil) {
        self.artifactID = artifactID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.claimID = claimID
        self.observedSourceRevision = observedSourceRevision?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum PublicReferenceInspectionQueryError: Error, Sendable, Equatable {
    case unsupportedArtifact(String)
    case unavailable
    case missingClaim(PublicReferenceClaimID)
}

struct PublicReferenceInspectionQueryResult: Sendable, Equatable {
    let snapshot: PublicReferenceRepositorySnapshot
    let selectedClaim: PublicReferenceClaimEnvelope?
    let sourceChangedSinceObservation: Bool
}

actor PublicReferenceQueryService {
    private let repository: PublicReferenceRepository

    init(repository: PublicReferenceRepository) {
        self.repository = repository
    }

    func inspect(_ query: PublicReferenceInspectionQuery) async throws -> PublicReferenceInspectionQueryResult {
        guard query.artifactID == PublicReferencePackAdapter.approvedArtifactID else {
            throw PublicReferenceInspectionQueryError.unsupportedArtifact(query.artifactID)
        }
        guard let snapshot = await repository.offlineSnapshot(), snapshot.release.artifactID == query.artifactID else {
            throw PublicReferenceInspectionQueryError.unavailable
        }
        let selectedClaim = query.claimID.flatMap { requested in
            snapshot.release.claims.first(where: { $0.id == requested })
        }
        if let requested = query.claimID, selectedClaim == nil {
            throw PublicReferenceInspectionQueryError.missingClaim(requested)
        }
        return PublicReferenceInspectionQueryResult(
            snapshot: snapshot,
            selectedClaim: selectedClaim,
            sourceChangedSinceObservation: query.observedSourceRevision.map { $0 != snapshot.release.sourceRevision } ?? false
        )
    }
}
