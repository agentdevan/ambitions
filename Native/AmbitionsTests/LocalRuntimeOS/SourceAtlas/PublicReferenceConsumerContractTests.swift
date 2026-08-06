import XCTest
@testable import Ambitions

final class PublicReferenceConsumerContractTests: XCTestCase {
    func testCareerEducationHobbyAndCredentialConsumersAcceptOnlyTheirVerifiedPublicArtifact() {
        let fixtures = [
            ConsumerFixture(
                consumer: .career,
                domainID: "occupation_foundation",
                artifactID: "source-atlas/v1/domain/occupation_foundation/20260628T000000Z"
            ),
            ConsumerFixture(
                consumer: .education,
                domainID: "education_credentialing",
                artifactID: "source-atlas/v1/domain/education_credentialing/20260628T000000Z"
            ),
            ConsumerFixture(
                consumer: .hobby,
                domainID: "hobbies_recreation",
                artifactID: "source-atlas/v1/domain/hobbies_recreation/20260628T000000Z"
            ),
            ConsumerFixture(
                consumer: .credential,
                domainID: "education_credentialing",
                artifactID: "source-atlas/v1/domain/education_credentialing/20260628T000000Z"
            )
        ]

        for fixture in fixtures {
            let decision = SourceAtlasPublicPlanningConsumerPolicy().evaluate(
                Self.request(
                    consumer: fixture.consumer,
                    domainID: fixture.domainID,
                    artifactID: fixture.artifactID
                )
            )

            XCTAssertTrue(
                decision.canExposeToLocalPlanning,
                "\(fixture.consumer) should accept its verified artifact"
            )
            XCTAssertEqual(decision.acceptedArtifactID, fixture.artifactID)
            XCTAssertEqual(decision.issues, [])
        }
    }

    func testBoundaryAttacksFailClosedWithDeterministicReasons() {
        let valid = Self.request(
            consumer: .career,
            domainID: "occupation_foundation",
            artifactID: "source-atlas/v1/domain/occupation_foundation/20260628T000000Z"
        )
        let attacks: [(SourceAtlasPublicPlanningConsumerRequest, SourceAtlasPublicPlanningConsumerIssue)] = [
            (
                valid.replacing(boundaryFields: ["goal_id": "goal-private-123"]),
                .privateField
            ),
            (
                valid.replacing(artifactIdentityOrigin: .derivedFromPrivateState),
                .derivedArtifactIdentity
            ),
            (
                valid.replacing(openEndedQuery: "find the best career for my private history"),
                .openEndedQuery
            ),
            (
                valid.replacing(sourceID: "unsupported-source"),
                .unsupportedSource
            ),
            (
                valid.replacing(operationOrder: [.fetchAllowlistedArtifact, .validateBoundary, .projectForLocalPlanning]),
                .networkBeforeValidation
            )
        ]

        for (request, expectedIssue) in attacks {
            let decision = SourceAtlasPublicPlanningConsumerPolicy().evaluate(request)

            XCTAssertFalse(decision.canExposeToLocalPlanning)
            XCTAssertNil(decision.acceptedArtifactID)
            XCTAssertTrue(decision.issues.contains(expectedIssue), "Expected \(expectedIssue), got \(decision.issues)")
        }
    }

    func testMismatchedOrOpenEndedArtifactIdentityCannotReachLocalPlanning() {
        let request = Self.request(
            consumer: .hobby,
            domainID: "hobbies_recreation",
            artifactID: "source-atlas/v1/domain/hobbies_recreation/20260628T000000Z"
        )
        .replacing(artifactID: "source-atlas/v1/domain/hobbies_recreation/*?goal=private")

        let decision = SourceAtlasPublicPlanningConsumerPolicy().evaluate(request)

        XCTAssertFalse(decision.canExposeToLocalPlanning)
        XCTAssertEqual(decision.issues, [.artifactMismatch, .unsupportedArtifactID])
    }
}

private extension PublicReferenceConsumerContractTests {
    struct ConsumerFixture {
        let consumer: SourceAtlasPublicPlanningConsumerKind
        let domainID: String
        let artifactID: String
    }

    static func request(
        consumer: SourceAtlasPublicPlanningConsumerKind,
        domainID: String,
        artifactID: String
    ) -> SourceAtlasPublicPlanningConsumerRequest {
        SourceAtlasPublicPlanningConsumerRequest(
            consumer: consumer,
            context: context(domainID: domainID, artifactID: artifactID),
            artifactID: artifactID,
            domainID: domainID,
            sourceID: "source-public-\(domainID)",
            artifactIdentityOrigin: .approvedPublicRegistry,
            openEndedQuery: nil,
            boundaryFields: [
                "artifact_id": artifactID,
                "domain_id": domainID,
                "source_id": "source-public-\(domainID)"
            ],
            operationOrder: [.validateBoundary, .readVerifiedLocalArtifact, .fetchAllowlistedArtifact, .projectForLocalPlanning]
        )
    }

    static func context(domainID: String, artifactID: String) -> SourceAtlasPublicPlanningContext {
        SourceAtlasPublicPlanningContext(
            schemaVersion: sourceAtlasVerifiedPublicPackProviderSchemaVersion,
            id: "context.public.\(domainID)",
            requestDomainID: domainID,
            selectedPackID: artifactID,
            selectedPackDomainID: domainID,
            manifestVersionID: "manifest.public.\(domainID)",
            useMode: .currentReference,
            availability: SourceAtlasPublicPlanningContextAvailability(
                fetchStatus: .accepted,
                selectedStoreSource: .bundled,
                storeSourceState: .officialCurrent,
                fallbackConditions: [],
                canSupportCurrentPublicReferenceUse: true,
                localPlanningBlocked: false,
                isLastKnownGood: false,
                isLocalFallback: false
            ),
            requirements: [],
            proofNeeds: [],
            starterActions: [],
            sourceIDs: ["source-public-\(domainID)"],
            claimIDs: ["claim-public-\(domainID)"],
            caveats: [],
            riskMetadata: [],
            ownership: .publicReferenceOnly
        )
    }
}

private extension SourceAtlasPublicPlanningConsumerRequest {
    func replacing(
        artifactID: String? = nil,
        sourceID: String? = nil,
        artifactIdentityOrigin: SourceAtlasPublicPlanningArtifactIdentityOrigin? = nil,
        openEndedQuery: String?? = nil,
        boundaryFields: [String: String]? = nil,
        operationOrder: [SourceAtlasPublicPlanningConsumerOperation]? = nil
    ) -> SourceAtlasPublicPlanningConsumerRequest {
        SourceAtlasPublicPlanningConsumerRequest(
            consumer: consumer,
            context: context,
            artifactID: artifactID ?? self.artifactID,
            domainID: domainID,
            sourceID: sourceID ?? self.sourceID,
            artifactIdentityOrigin: artifactIdentityOrigin ?? self.artifactIdentityOrigin,
            openEndedQuery: openEndedQuery ?? self.openEndedQuery,
            boundaryFields: boundaryFields ?? self.boundaryFields,
            operationOrder: operationOrder ?? self.operationOrder
        )
    }
}
