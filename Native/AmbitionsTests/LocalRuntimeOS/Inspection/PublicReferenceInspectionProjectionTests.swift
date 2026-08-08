import XCTest
@testable import Ambitions

final class PublicReferenceInspectionProjectionTests: XCTestCase {
    func testProjectionShowsPublicAuthorityFreshnessLimitsConflictsAndSourceUpdateTrigger() async throws {
        let verified = try PublicReferenceRepositoryTests.verifiedArtifact(hash: "inspection")
        let repository = PublicReferenceRepository(
            provider: InspectionVerifiedArtifactProvider(artifact: verified)
        )
        _ = await repository.refresh()
        let claimID = try XCTUnwrap(verified.publicReferencePackArtifact()?.claims.first?.id)
        let service = PublicReferenceQueryService(repository: repository)
        let result = try await service.inspect(PublicReferenceInspectionQuery(
            artifactID: "onet-30.3",
            claimID: claimID,
            observedSourceRevision: "old"
        ))
        let projection = PublicReferenceInspectionProjection.make(from: result)

        XCTAssertTrue(projection.isReadOnly)
        XCTAssertEqual(
            projection.selectedClaim?.authority,
            "onet — O*NET is authoritative for this descriptive occupation claim."
        )
        XCTAssertEqual(projection.selectedClaim?.freshness, "current")
        XCTAssertEqual(projection.selectedClaim?.conflicts, "No recorded conflicts.")
        XCTAssertEqual(projection.selectedClaim?.supersession, "No recorded supersession.")
        XCTAssertTrue(projection.selectedClaim?.limits.contains("Rights: approved with attribution") == true)
        XCTAssertEqual(projection.semanticUse, "Complete for approved descriptive claims")
        XCTAssertEqual(projection.recommendationReadiness, "Not approved for recommendation use")
        XCTAssertEqual(projection.selectedClaim?.sourceNativeIdentity, "15-1252.00 · occupation.task · onet.database")
        XCTAssertTrue(projection.selectedClaim?.accessibilityValue.contains("Limits Authority lane: description") == true)
        XCTAssertTrue(projection.selectedClaim?.accessibilityValue.contains("Conflicts No recorded conflicts.") == true)
        XCTAssertTrue(projection.selectedClaim?.accessibilityValue.contains("Supersession No recorded supersession.") == true)
        XCTAssertTrue(projection.selectedClaim?.accessibilityValue.contains("Attribution O*NET 30.3, CC BY 4.0") == true)
        XCTAssertEqual(projection.recheckTrigger.title, "Review update")
        XCTAssertEqual(projection.claims.map(\.title), ["Task"])
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
            verificationEvidence: verificationEvidence(), claims: [task, identity]
        )
    }

    private static func verificationEvidence() -> SourceAtlasPublicReferenceArtifactVerificationEvidence {
        SourceAtlasPublicReferenceArtifactVerificationEvidence(
            artifactID: "onet-30.3",
            manifestVersionID: "30.3",
            manifestSHA256: String(repeating: "b", count: 64),
            packSHA256: String(repeating: "a", count: 64),
            packSource: .bundled,
            checkedAt: Date(timeIntervalSince1970: 1_780_000_000),
            sourceNativeSubjectID: "15-1252.00",
            predicateIDs: ["occupation.identity", "occupation.task"],
            sourceIDs: ["record"],
            signatureResult: SignatureVerificationResult(signature: "test", issues: [])
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

private struct InspectionVerifiedArtifactProvider: PublicReferenceVerifiedPackProviding {
    let artifact: SourceAtlasPublicReferenceVerifiedArtifact

    func verifiedSourceAtlasArtifact(
        matching pointer: PublicReferenceVerifiedReleasePointer?
    ) async -> SourceAtlasPublicReferenceVerifiedArtifact? {
        guard pointer == nil || (
            pointer?.artifactID == artifact.evidence.artifactID &&
                pointer?.manifestVersionID == artifact.evidence.manifestVersionID &&
                pointer?.manifestSHA256 == artifact.evidence.manifestSHA256 &&
                pointer?.packSHA256 == artifact.evidence.packSHA256
        ) else { return nil }
        return artifact
    }
}
