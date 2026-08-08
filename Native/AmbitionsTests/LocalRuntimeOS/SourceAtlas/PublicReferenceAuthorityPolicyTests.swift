import XCTest
@testable import Ambitions

final class PublicReferenceAuthorityPolicyTests: XCTestCase {
    func testVerifiedAuthorityCertificateAcceptsCurrentPublicClaim() {
        let decision = PublicReferenceAuthorityPolicy().evaluate(Self.input())

        XCTAssertTrue(decision.isAccepted)
        XCTAssertEqual(decision.availability, .authoritative)
        XCTAssertTrue(decision.failureReasons.isEmpty)
    }

    func testCertificateFailuresAreDeterministicAndFailClosed() {
        let invalidSignature = Self.input(certificate: Self.certificate(signatureVerified: false))
        XCTAssertEqual(
            PublicReferenceAuthorityPolicy().evaluate(invalidSignature).failureReasons,
            [.signatureInvalid]
        )

        let wrongRegion = Self.input(certificate: PublicReferenceAuthorityCertificate(
            artifactID: "onet-30.3",
            signatureVerified: true,
            permittedJurisdictionCodes: ["CA"],
            permittedAuthorityLanes: [.description]
        ))
        XCTAssertEqual(
            PublicReferenceAuthorityPolicy().evaluate(wrongRegion).failureReasons,
            [.unsupportedJurisdiction]
        )
    }

    func testRightsFreshnessAndConflictAreIndependentClosedReasons() {
        XCTAssertEqual(
            PublicReferenceAuthorityPolicy().evaluate(Self.input(claim: Self.claim(rightsState: .reviewRequired))).failureReasons,
            [.rightsBlocked, .unavailable]
        )
        XCTAssertEqual(
            PublicReferenceAuthorityPolicy().evaluate(Self.input(claim: Self.claim(freshnessState: .staleBlocked))).failureReasons,
            [.freshnessBlocked, .unavailable]
        )
        XCTAssertEqual(
            PublicReferenceAuthorityPolicy().evaluate(Self.input(claim: Self.claim(conflictIDs: [PublicReferenceClaimID("claim-conflict")]))).failureReasons,
            [.conflictPresent]
        )
    }

    func testRequestValidatorCombinesStructuralAndAuthorityValidation() {
        let request = SourceAtlasPublicPackRequest(
            packID: "onet-30.3",
            manifestVersionID: "30.3",
            declaredSHA256: String(repeating: "a", count: 64),
            queryItems: ["goal": "private"]
        )
        let input = PublicReferenceAuthorityValidationInput(request: request, claim: Self.claim(), certificate: Self.certificate())

        let decision = SourceAtlasPublicPackRequestValidator().validate(input)

        XCTAssertEqual(decision.failureReasons, [.unsafePublicRequest])
    }

    func testFreshnessEngineNeverPromotesSourceChangedClaim() {
        let verdict = FreshnessEngine().publicReferenceVerdict(for: Self.claim(freshnessState: .sourceChanged))

        XCTAssertEqual(verdict.reason, "source_changed")
        XCTAssertTrue(verdict.blocksCurrentUse)
    }

    private static func input(
        claim: PublicReferenceClaimEnvelope = claim(),
        certificate: PublicReferenceAuthorityCertificate = certificate()
    ) -> PublicReferenceAuthorityValidationInput {
        PublicReferenceAuthorityValidationInput(
            request: SourceAtlasPublicPackRequest(
                packID: "onet-30.3",
                manifestVersionID: "30.3",
                declaredSHA256: String(repeating: "a", count: 64)
            ),
            claim: claim,
            certificate: certificate
        )
    }

    private static func certificate(signatureVerified: Bool = true) -> PublicReferenceAuthorityCertificate {
        PublicReferenceAuthorityCertificate(
            artifactID: "onet-30.3",
            signatureVerified: signatureVerified,
            permittedJurisdictionCodes: ["US"],
            permittedAuthorityLanes: [.description]
        )
    }

    private static func claim(
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
            sourceNativeFieldID: "description-1",
            sourceLocator: "https://www.onetcenter.org/database.html",
            authority: PublicReferenceAuthority(publisherID: "onet", lane: .description, statement: "O*NET owns this descriptive claim."),
            jurisdiction: PublicReferenceJurisdiction(code: "US", label: "United States"),
            release: PublicReferenceRelease(id: "30.3"),
            retrievedAt: "2026-08-06T00:00:00Z",
            checkedAt: "2026-08-06T00:00:00Z",
            deliveryState: .bundled,
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
