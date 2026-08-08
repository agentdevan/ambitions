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
    case recheckFailed(PublicReferenceRepositoryRefreshResult)
}

struct PublicReferenceInspectionQueryResult: Sendable, Equatable {
    let snapshot: PublicReferenceRepositorySnapshot
    let selectedClaim: PublicReferenceClaimEnvelope?
    let unavailableRequestedClaimID: PublicReferenceClaimID?
    let sourceChangedSinceObservation: Bool

    init(
        snapshot: PublicReferenceRepositorySnapshot,
        selectedClaim: PublicReferenceClaimEnvelope?,
        unavailableRequestedClaimID: PublicReferenceClaimID? = nil,
        sourceChangedSinceObservation: Bool
    ) {
        self.snapshot = snapshot
        self.selectedClaim = selectedClaim
        self.unavailableRequestedClaimID = unavailableRequestedClaimID
        self.sourceChangedSinceObservation = sourceChangedSinceObservation
    }
}

actor PublicReferenceQueryService {
    private let repository: PublicReferenceRepository

    init(repository: PublicReferenceRepository) {
        self.repository = repository
    }

    func currentVerifiedPointer() async -> PublicReferenceVerifiedReleasePointer? {
        await repository.currentVerifiedPointer()
    }

    func inspect(_ query: PublicReferenceInspectionQuery) async throws -> PublicReferenceInspectionQueryResult {
        guard query.artifactID == PublicReferencePackAdapter.approvedArtifactID else {
            throw PublicReferenceInspectionQueryError.unsupportedArtifact(query.artifactID)
        }
        guard let snapshot = await repository.offlineSnapshot(), snapshot.release.artifactID == query.artifactID else {
            throw PublicReferenceInspectionQueryError.unavailable
        }
        return result(snapshot: snapshot, query: query)
    }

    func inspectCurrent(
        matchingExactPointer pointer: PublicReferenceVerifiedReleasePointer,
        claimID: PublicReferenceClaimID?
    ) async throws -> PublicReferenceInspectionQueryResult {
        guard pointer.artifactID == PublicReferencePackAdapter.approvedArtifactID else {
            throw PublicReferenceInspectionQueryError.unsupportedArtifact(pointer.artifactID)
        }
        guard let snapshot = await repository.currentSnapshot(matchingExactPointer: pointer) else {
            throw PublicReferenceInspectionQueryError.recheckFailed(.superseded)
        }
        return result(snapshot: snapshot, query: PublicReferenceInspectionQuery(
            artifactID: pointer.artifactID,
            claimID: claimID
        ))
    }

    private func result(
        snapshot: PublicReferenceRepositorySnapshot,
        query: PublicReferenceInspectionQuery
    ) -> PublicReferenceInspectionQueryResult {
        let selectedClaim = query.claimID.flatMap { requested in
            snapshot.release.claims.first(where: { $0.id == requested })
        }
        return PublicReferenceInspectionQueryResult(
            snapshot: snapshot,
            selectedClaim: selectedClaim,
            unavailableRequestedClaimID: query.claimID.flatMap { selectedClaim == nil ? $0 : nil },
            sourceChangedSinceObservation: query.observedSourceRevision.map { $0 != snapshot.release.sourceRevision } ?? false
        )
    }

    func checkUpdate(artifactID: String, since observedSourceRevision: String) async throws -> PublicReferenceUpdateCheck {
        let refreshResult = await repository.refresh()
        switch refreshResult {
        case .promoted, .rolledBack:
            break
        case .cancelled, .unavailable, .quarantined, .superseded, .persistenceFailed:
            throw PublicReferenceInspectionQueryError.recheckFailed(refreshResult)
        }
        let result = try await inspect(PublicReferenceInspectionQuery(
            artifactID: artifactID,
            observedSourceRevision: observedSourceRevision
        ))
        guard result.sourceChangedSinceObservation else { return .current }
        guard let pointer = await repository.currentVerifiedPointer(),
              pointer.artifactID == artifactID,
              pointer.sourceRevision == result.snapshot.release.sourceRevision
        else { throw PublicReferenceInspectionQueryError.recheckFailed(.superseded) }
        return .updateAvailable(PublicReferenceUpdateToken(pointer: pointer))
    }
}
