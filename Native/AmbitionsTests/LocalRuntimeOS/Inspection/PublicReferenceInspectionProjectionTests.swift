import XCTest
@testable import Ambitions

final class PublicReferenceInspectionProjectionTests: XCTestCase {
    func testProjectionShowsPublicAuthorityFreshnessLimitsConflictsAndSourceUpdateTrigger() async throws {
        let repository = PublicReferenceRepository()
        _ = await repository.migrateAdditively(bundled: Self.artifact())
        let service = PublicReferenceQueryService(repository: repository)
        let result = try await service.inspect(PublicReferenceInspectionQuery(artifactID: "onet-30.3", claimID: PublicReferenceClaimID("task"), observedSourceRevision: "old"))
        let projection = PublicReferenceInspectionProjection.make(from: result)

        XCTAssertTrue(projection.isReadOnly)
        XCTAssertEqual(projection.selectedClaim?.authority, "onet — O*NET descriptive authority.")
        XCTAssertEqual(projection.selectedClaim?.freshness, "current")
        XCTAssertEqual(projection.selectedClaim?.conflicts, "conflict-1")
        XCTAssertEqual(projection.selectedClaim?.supersession, "superseded-by-1")
        XCTAssertTrue(projection.selectedClaim?.limits.contains("Rights: approved with attribution") == true)
        XCTAssertEqual(projection.recheckTrigger.title, "Review update")
        XCTAssertEqual(projection.claims.map(\.title), ["Identity", "Task"])
    }

    func testQueryRejectsUnapprovedArtifactAndNeverFetches() async {
        let service = PublicReferenceQueryService(repository: PublicReferenceRepository())
        do {
            _ = try await service.inspect(PublicReferenceInspectionQuery(artifactID: "other"))
            XCTFail("Expected unsupported artifact")
        } catch let error as PublicReferenceInspectionQueryError {
            XCTAssertEqual(error, .unsupportedArtifact("other"))
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    private static func artifact() -> PublicReferencePackArtifact {
        let identity = claim(id: "identity", predicate: "occupation.identity", hash: "identity")
        let task = claim(id: "task", predicate: "occupation.task", hash: "task", conflicts: [PublicReferenceClaimID("conflict-1")], supersededBy: [PublicReferenceClaimID("superseded-by-1")])
        return PublicReferencePackArtifact(
            id: "onet-30.3",
            request: SourceAtlasPublicPackRequest(
                packID: "onet-30.3", manifestVersionID: "30.3",
                declaredSHA256: String(repeating: "a", count: 64)
            ),
            release: PublicReferenceRelease(id: "30.3"), publisherID: "onet",
            jurisdiction: PublicReferenceJurisdiction(code: "US", label: "United States"),
            signatureVerified: true, claims: [task, identity]
        )
    }

    private static func claim(id: String, predicate: String, hash: String, conflicts: [PublicReferenceClaimID] = [], supersededBy: [PublicReferenceClaimID] = []) -> PublicReferenceClaimEnvelope {
        PublicReferenceClaimEnvelope(
            id: PublicReferenceClaimID(id), sourceNativeSubjectID: "15-1252.00",
            predicateID: predicate, value: PublicReferenceClaimValue(text: "Public \(predicate) claim."),
            sourceRecordID: "record",
            authority: PublicReferenceAuthority(
                publisherID: "onet", lane: .description, statement: "O*NET descriptive authority."
            ),
            jurisdiction: PublicReferenceJurisdiction(code: "US", label: "United States"),
            release: PublicReferenceRelease(id: "30.3"),
            retrievedAt: "2026-08-06T00:00:00Z", checkedAt: "2026-08-06T00:00:00Z",
            deliveryState: .bundled, semanticReviewState: .complete, freshnessState: .current,
            rightsState: .approvedWithAttribution, requiredAttribution: "O*NET 30.3",
            riskState: "descriptive", conflictIDs: conflicts, supersededByIDs: supersededBy,
            contentHash: hash
        )
    }
}
