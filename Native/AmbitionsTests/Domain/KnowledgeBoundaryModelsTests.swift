import XCTest
@testable import Ambitions

final class KnowledgeBoundaryModelsTests: XCTestCase {
    func testClaimRequiresSourceAndFreshnessMetadata() {
        let claim = sampleClaim()

        XCTAssertEqual(claim.source.id, "source-1")
        XCTAssertEqual(claim.freshness.state, .fresh)
        XCTAssertEqual(claim.confidence, .medium)
    }

    func testProvenanceDistinguishesOfficialInferredAndUserProvidedClaims() {
        let official = KnowledgeSourceRecord(
            id: "official",
            providerID: "provider-1",
            entityTitle: "IRS Filing Deadline",
            publisher: "IRS",
            locator: "https://example.com/official",
            provenanceKind: .official,
            isOfficial: true
        )
        let inferred = KnowledgeSourceRecord(
            id: "inferred",
            providerID: "provider-1",
            entityTitle: "Estimated Processing Time",
            publisher: "Ambitions inference",
            locator: nil,
            provenanceKind: .inferred,
            isOfficial: false
        )
        let userProvided = KnowledgeSourceRecord(
            id: "user",
            providerID: "provider-1",
            entityTitle: "User note",
            publisher: "User",
            locator: nil,
            provenanceKind: .userProvided,
            isOfficial: false
        )

        XCTAssertEqual(official.provenanceKind, .official)
        XCTAssertEqual(inferred.provenanceKind, .inferred)
        XCTAssertEqual(userProvided.provenanceKind, .userProvided)
        XCTAssertTrue(official.isOfficial)
        XCTAssertFalse(inferred.isOfficial)
        XCTAssertFalse(userProvided.isOfficial)
    }

    func testFreshnessMetadataCanRepresentFreshStaleExpiredAndUnknownStates() {
        XCTAssertEqual(
            KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-19T12:00:00Z",
                publishedAt: "2026-04-19T10:00:00Z",
                staleAfter: "2026-04-20T12:00:00Z",
                expiresAt: "2026-04-21T12:00:00Z",
                state: .fresh
            ).state,
            .fresh
        )
        XCTAssertEqual(
            KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-18T12:00:00Z",
                publishedAt: nil,
                staleAfter: "2026-04-19T12:00:00Z",
                expiresAt: nil,
                state: .stale
            ).state,
            .stale
        )
        XCTAssertEqual(
            KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-10T12:00:00Z",
                publishedAt: nil,
                staleAfter: "2026-04-11T12:00:00Z",
                expiresAt: "2026-04-12T12:00:00Z",
                state: .expired
            ).state,
            .expired
        )
        XCTAssertEqual(
            KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-19T12:00:00Z",
                publishedAt: nil,
                staleAfter: nil,
                expiresAt: nil,
                state: .unknown
            ).state,
            .unknown
        )
    }

    func testClaimSetPreservesConflictingUnresolvedState() {
        let set = KnowledgeClaimSet(
            claims: [
                sampleClaim(id: "claim-1", summary: "Processing time is 4 weeks"),
                sampleClaim(
                    id: "claim-2",
                    summary: "Processing time is 6 weeks",
                    uncertaintyFlags: [.conflicting]
                )
            ],
            conflictState: .conflictingUnresolved,
            degradationSummary: "Sources disagree and the conflict is intentionally unresolved."
        )

        XCTAssertEqual(set.claims.count, 2)
        XCTAssertEqual(set.conflictState, .conflictingUnresolved)
        XCTAssertEqual(set.claims[1].uncertaintyFlags, [.conflicting])
    }

    func testKnowledgeBoundaryTypesRoundTripThroughCodable() throws {
        let set = KnowledgeClaimSet(
            claims: [
                sampleClaim(
                    trustLevel: .low,
                    confidence: .low,
                    uncertaintyFlags: [.lowConfidence, .stale, .providerUnavailable]
                )
            ],
            conflictState: .none,
            degradationSummary: "Provider is unavailable, so this claim remains low-confidence."
        )

        let encoded = try JSONEncoder().encode(set)
        let decoded = try JSONDecoder().decode(KnowledgeClaimSet.self, from: encoded)

        XCTAssertEqual(decoded, set)
    }
}

private extension KnowledgeBoundaryModelsTests {
    func sampleClaim(
        id: String = "claim-1",
        summary: String = "Applications open in early May.",
        trustLevel: KnowledgeTrustLevel = .medium,
        confidence: RecommendationConfidence = .medium,
        uncertaintyFlags: Set<KnowledgeUncertaintyFlag> = [.inferred]
    ) -> KnowledgeClaim {
        KnowledgeClaim(
            id: id,
            providerID: "provider-1",
            subject: "application_window",
            payload: KnowledgeClaimPayload(
                summary: summary,
                detail: "The exact date still needs confirmation."
            ),
            source: KnowledgeSourceRecord(
                id: "source-1",
                providerID: "provider-1",
                entityTitle: "Admissions calendar",
                publisher: "Program office",
                locator: "https://example.com/calendar",
                provenanceKind: .providerReported,
                isOfficial: false
            ),
            freshness: KnowledgeFreshnessMetadata(
                retrievedAt: "2026-04-19T12:00:00Z",
                publishedAt: "2026-04-18T12:00:00Z",
                staleAfter: "2026-04-26T12:00:00Z",
                expiresAt: "2026-05-03T12:00:00Z",
                state: .fresh
            ),
            trustLevel: trustLevel,
            confidence: confidence,
            uncertaintyFlags: uncertaintyFlags,
            explanation: KnowledgeExplanationMetadata(
                summary: "The provider found a likely source, but it is not yet official.",
                supportingSourceIDs: ["source-1"],
                notes: ["Treat this as provisional until an official source confirms it."]
            )
        )
    }
}
