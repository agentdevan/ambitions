import XCTest
@testable import Ambitions

final class PublicReferenceKnowledgeModelsTests: XCTestCase {
    func testAuthoritativeClaimPreservesRequiredPublicSourceBinding() throws {
        let claim = Self.claim()

        XCTAssertTrue(claim.isWellFormed)
        XCTAssertEqual(claim.availability, .authoritative)
        XCTAssertEqual(claim.authority.lane, .description)
        XCTAssertEqual(claim.jurisdiction.code, "US")

        let data = try JSONEncoder().encode(claim)
        XCTAssertEqual(try JSONDecoder().decode(PublicReferenceClaimEnvelope.self, from: data), claim)
    }

    func testOrthogonalStatesExpressContextualLastKnownGoodConflictAndUnavailable() {
        XCTAssertEqual(Self.claim(freshnessState: .aging).availability, .contextual)
        XCTAssertEqual(Self.claim(deliveryState: .lastKnownGood).availability, .lastKnownGood)
        XCTAssertEqual(Self.claim(conflictIDs: [PublicReferenceClaimID("claim-conflict")]).availability, .conflicting)
        XCTAssertEqual(Self.claim(rightsState: .reviewRequired).availability, .unavailable)
        XCTAssertEqual(Self.claim(freshnessState: .staleBlocked).availability, .unavailable)
    }

    func testCrosswalkCarriesTwoSourceNativeIdentitiesWithoutMergingThem() {
        let crosswalk = PublicReferenceCrosswalkClaim(
            id: "crosswalk-1",
            publisherID: "publisher-1",
            relationshipKind: "maps_to",
            sourceNativeID: "source-occupation",
            sourceReleaseID: "30.3",
            targetNativeID: "target-occupation",
            targetReleaseID: "v2",
            reviewState: .complete,
            limitations: "Contextual mapping only.",
            rightsState: .approvedWithAttribution,
            freshnessState: .current
        )

        XCTAssertNotEqual(crosswalk.sourceNativeID, crosswalk.targetNativeID)
        XCTAssertEqual(crosswalk.reviewState, .complete)
    }

    private static func claim(
        deliveryState: PublicReferenceDeliveryState = .bundled,
        freshnessState: PublicReferenceFreshnessState = .current,
        rightsState: PublicReferenceRightsState = .approvedWithAttribution,
        conflictIDs: [PublicReferenceClaimID] = []
    ) -> PublicReferenceClaimEnvelope {
        PublicReferenceClaimEnvelope(
            id: PublicReferenceClaimID("claim-software-developers"),
            sourceNativeSubjectID: "15-1252.00",
            predicateID: "occupation.description",
            value: PublicReferenceClaimValue(text: "Research, design, and develop computer software."),
            sourceRecordID: "onet-30.3-15-1252.00",
            authority: PublicReferenceAuthority(publisherID: "onet", lane: .description, statement: "O*NET owns this descriptive occupation claim."),
            jurisdiction: PublicReferenceJurisdiction(code: "US", label: "United States"),
            release: PublicReferenceRelease(id: "30.3"),
            retrievedAt: "2026-08-05T00:00:00Z",
            checkedAt: "2026-08-05T00:00:00Z",
            deliveryState: deliveryState,
            semanticReviewState: .complete,
            freshnessState: freshnessState,
            rightsState: rightsState,
            requiredAttribution: "O*NET 30.3, CC BY 4.0",
            riskState: "descriptive",
            conflictIDs: conflictIDs,
            contentHash: "abc123"
        )
    }
}
