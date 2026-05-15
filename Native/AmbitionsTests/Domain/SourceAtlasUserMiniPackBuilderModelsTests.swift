import XCTest
@testable import Ambitions

final class SourceAtlasUserMiniPackBuilderModelsTests: XCTestCase {
    private let builder = SourceAtlasUserMiniPackBuilder()

    func testConfirmedUserClaimsBuildALocalPrivateMiniPack() {
        let result = builder.build(Self.request(
            claims: [
                Self.claim(id: "claim-1", sourceState: .locallyProven),
                Self.claim(id: "claim-2", sourceState: .unknown)
            ]
        ))

        XCTAssertEqual(result.pack.manifest.kind, .userMiniPack)
        XCTAssertFalse(result.pack.manifest.productionUse)
        XCTAssertTrue(result.pack.runtimeBoundary.isValueModelOnly)
        XCTAssertEqual(result.container.kind, .userMiniPack)
        XCTAssertEqual(result.container.provenanceState, .userMiniPack)
        XCTAssertEqual(result.container.sourceKind, .userProvided)
        XCTAssertTrue(result.container.requiresReview)
        XCTAssertFalse(result.container.canSupportOfficialCurrentClaim)
        XCTAssertTrue(result.pack.isValidForRuntimeUse)
        XCTAssertEqual(result.sourceState, .locallyProven)
        XCTAssertEqual(result.freshnessState, .unknown)
        XCTAssertEqual(result.correctionEligibility, .reviewRequired)
        XCTAssertEqual(result.rejectionEligibility, .reviewRequired)
        XCTAssertEqual(result.deletionEligibility, .reviewRequired)
    }

    func testExplicitStateEligibilityRemainsVisibleForBlockedAndLocalOnlyClaims() {
        let result = builder.build(Self.request(
            claims: [
                Self.claim(id: "claim-unknown", sourceState: .unknown),
                Self.claim(id: "claim-source-needed", sourceState: .sourceNeeded),
                Self.claim(id: "claim-stale", sourceState: .stale),
                Self.claim(id: "claim-contradicted", sourceState: .contradicted),
                Self.claim(id: "claim-revoked", sourceState: .revoked),
                Self.claim(id: "claim-local", sourceState: .locallyProven)
            ]
        ))

        let byID = Dictionary(uniqueKeysWithValues: result.claimStates.map { ($0.id, $0) })

        XCTAssertEqual(byID["claim-unknown"]?.sourceState, .unknown)
        XCTAssertEqual(byID["claim-unknown"]?.freshnessState, .unknown)
        XCTAssertEqual(byID["claim-unknown"]?.correctionEligibility, .reviewRequired)
        XCTAssertEqual(byID["claim-source-needed"]?.sourceState, .sourceNeeded)
        XCTAssertEqual(byID["claim-source-needed"]?.freshnessState, .needsReview)
        XCTAssertEqual(byID["claim-source-needed"]?.deletionEligibility, .reviewRequired)
        XCTAssertEqual(byID["claim-stale"]?.sourceState, .stale)
        XCTAssertEqual(byID["claim-stale"]?.freshnessState, .stale)
        XCTAssertEqual(byID["claim-stale"]?.rejectionEligibility, .blocked)
        XCTAssertEqual(byID["claim-contradicted"]?.sourceState, .contradicted)
        XCTAssertEqual(byID["claim-contradicted"]?.freshnessState, .disputed)
        XCTAssertEqual(byID["claim-contradicted"]?.correctionEligibility, .blocked)
        XCTAssertEqual(byID["claim-revoked"]?.sourceState, .revoked)
        XCTAssertEqual(byID["claim-revoked"]?.freshnessState, .revoked)
        XCTAssertEqual(byID["claim-revoked"]?.deletionEligibility, .blocked)
        XCTAssertEqual(byID["claim-local"]?.sourceState, .locallyProven)
        XCTAssertEqual(byID["claim-local"]?.freshnessState, .current)
        XCTAssertEqual(byID["claim-local"]?.correctionEligibility, .eligible)
    }

    func testLocallyProvenClaimsStayLocalOnlyAndDoNotBecomeOfficialCurrent() {
        let result = builder.build(Self.request(
            claims: [
                Self.claim(id: "claim-local", sourceState: .locallyProven)
            ]
        ))

        XCTAssertEqual(result.claimStates.first?.claim.state, .verifiedByLocalProof)
        XCTAssertFalse(result.claimStates.first?.claim.canDriveCurrentRecommendation ?? true)
        XCTAssertFalse(result.container.canSupportOfficialCurrentClaim)
        XCTAssertTrue(result.isLocalOnly)
        XCTAssertTrue(result.requiresReview)
    }

    func testEncodedOutputAvoidsConfidenceModelAndReleaseLanguage() throws {
        let result = builder.build(Self.request(
            claims: [
                Self.claim(id: "claim-encoded", sourceState: .sourceNeeded)
            ]
        ))

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(result)
        let encoded = String(decoding: data, as: UTF8.self).lowercased()

        XCTAssertFalse(encoded.contains("confidence"))
        XCTAssertFalse(encoded.contains("model"))
        XCTAssertFalse(encoded.contains("release"))
    }
}

private extension SourceAtlasUserMiniPackBuilderModelsTests {
    static func request(claims: [SourceAtlasUserMiniPackClaimInput]) -> SourceAtlasUserMiniPackBuildRequest {
        SourceAtlasUserMiniPackBuildRequest(
            id: "user-mini-pack",
            title: "User Mini Pack",
            domainID: "source-atlas",
            claims: claims,
            createdAt: "2026-05-15T04:22:13Z",
            updatedAt: "2026-05-15T04:22:13Z"
        )
    }

    static func claim(
        id: String,
        sourceState: SourceAtlasRequirementSourceState
    ) -> SourceAtlasUserMiniPackClaimInput {
        SourceAtlasUserMiniPackClaimInput(
            id: id,
            text: "Claim \(id)",
            sourceState: sourceState,
            riskClass: .hobby
        )
    }
}
