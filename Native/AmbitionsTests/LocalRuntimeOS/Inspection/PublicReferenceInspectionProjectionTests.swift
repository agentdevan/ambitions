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
        XCTAssertEqual(projection.selectedClaim?.conflicts, "No recorded conflicts.")
        XCTAssertEqual(projection.selectedClaim?.supersession, "superseded-by-1")
        XCTAssertTrue(projection.selectedClaim?.limits.contains("Rights: approved with attribution") == true)
        XCTAssertEqual(projection.semanticUse, "Complete for approved descriptive claims")
        XCTAssertEqual(projection.recommendationReadiness, "Not approved for recommendation use")
        XCTAssertEqual(projection.selectedClaim?.sourceNativeIdentity, "15-1252.00 · occupation.task · record")
        XCTAssertTrue(projection.selectedClaim?.accessibilityValue.contains("Limits Authority lane: description") == true)
        XCTAssertTrue(projection.selectedClaim?.accessibilityValue.contains("Conflicts No recorded conflicts.") == true)
        XCTAssertTrue(projection.selectedClaim?.accessibilityValue.contains("Supersession superseded-by-1") == true)
        XCTAssertTrue(projection.selectedClaim?.accessibilityValue.contains("Attribution O*NET 30.3") == true)
        XCTAssertEqual(projection.recheckTrigger.title, "Review update")
        XCTAssertEqual(projection.claims.map(\.title), ["Identity", "Task"])
    }

    func testProjectionSurfacesConflictMetadataWithoutWeakeningRepositoryAdmission() {
        let artifact = Self.artifact(claimConflicts: [PublicReferenceClaimID("conflict-1")])
        let release = PublicReferenceVerifiedRelease(
            artifactID: artifact.id,
            release: artifact.release,
            claims: artifact.claims,
            sourceRevision: "30.3|inspection-fixture"
        )
        let snapshot = PublicReferenceRepositorySnapshot(
            schemaVersion: publicReferenceRepositorySchemaVersion,
            delivery: .bundled,
            release: release
        )
        let selected = artifact.claims.first { $0.id == PublicReferenceClaimID("task") }
        let result = PublicReferenceInspectionQueryResult(
            snapshot: snapshot,
            selectedClaim: selected,
            sourceChangedSinceObservation: false
        )

        let projection = PublicReferenceInspectionProjection.make(from: result)

        XCTAssertEqual(projection.selectedClaim?.conflicts, "conflict-1")
        XCTAssertTrue(projection.selectedClaim?.accessibilityValue.contains("Conflicts conflict-1") == true)
    }

    func testUnavailableProjectionKeepsLocalPlanningAvailableWithoutInventingSourceFacts() {
        let projection = PublicReferenceInspectionProjection.unavailable

        XCTAssertEqual(projection.availability, .unavailable)
        XCTAssertEqual(projection.title, "Public reference sources")
        XCTAssertEqual(projection.corpusTitle, "No verified public corpus installed")
        XCTAssertEqual(projection.delivery, "Unavailable")
        XCTAssertEqual(projection.semanticUse, "No approved public claims available")
        XCTAssertEqual(projection.recommendationReadiness, "Not approved for recommendation use")
        XCTAssertEqual(projection.claims, [])
        XCTAssertTrue(projection.recheckTrigger.detail.contains("Local planning remains available"))
        XCTAssertTrue(projection.isReadOnly)
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

    private static func artifact(claimConflicts: [PublicReferenceClaimID] = []) -> PublicReferencePackArtifact {
        let identity = claim(id: "identity", predicate: "occupation.identity", hash: "identity")
        let task = claim(
            id: "task",
            predicate: "occupation.task",
            hash: "task",
            conflicts: claimConflicts,
            supersededBy: [PublicReferenceClaimID("superseded-by-1")]
        )
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
