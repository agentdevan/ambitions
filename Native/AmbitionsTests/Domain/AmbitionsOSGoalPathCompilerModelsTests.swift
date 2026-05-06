import XCTest
@testable import Ambitions

final class AmbitionsOSGoalPathCompilerModelsTests: XCTestCase {
    private let validator = AmbitionsOSGoalPathCompilerValidator()

    func testReviewReadyCandidateRoundTripsWithoutActivating() throws {
        let candidate = compiledCandidate(
            goalClass: .projectGoal,
            stages: [stage(requirementIDs: ["requirement-1"])],
            requirements: [requirement(id: "requirement-1", kind: .hardRequirement)]
        )

        let data = try JSONEncoder().encode(candidate)
        let decoded = try JSONDecoder().decode(AmbitionsOSGoalPathCompiledCandidate.self, from: data)

        XCTAssertEqual(decoded, candidate)
        XCTAssertEqual(validator.validate(decoded), [])
        XCTAssertEqual(decoded.reviewProjection, .reviewReady)
        XCTAssertFalse(decoded.autoActivates)
    }

    func testInvalidSchemaAndMalformedGraphPartsAreRejected() {
        let candidate = compiledCandidate(
            id: "",
            title: "",
            startingPositionSnapshotID: nil,
            stages: [
                stage(id: "", title: "", orderIndex: -1, requirementIDs: [], schemaVersion: "old.schema")
            ],
            requirements: [
                requirement(id: "", title: "", kind: .hardRequirement, schemaVersion: "old.schema")
            ],
            schemaVersion: "old.schema"
        )

        let issues = validator.validate(candidate)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedCandidate))
        XCTAssertTrue(issues.contains(.malformedStage))
        XCTAssertTrue(issues.contains(.malformedRequirement))
        XCTAssertTrue(issues.contains(.missingStartingPosition))
    }

    func testRegulatedGoalRequirementUsesSourceNeededFallbackInsteadOfOfficialClaim() {
        let candidate = compiledCandidate(
            goalClass: .regulatedGoal,
            requirements: [
                requirement(
                    id: "licensure",
                    kind: .hardRequirement,
                    sourceState: .sourceNeeded,
                    freshnessState: .unknown
                ),
                requirement(id: "source-fallback", kind: .sourceNeeded)
            ]
        )

        let issues = validator.validate(candidate)

        XCTAssertEqual(candidate.reviewProjection, .needsSourceReview)
        XCTAssertTrue(issues.contains(.sourceReviewRequired))
        XCTAssertFalse(issues.contains(.officialRequirementOverclaim))
    }

    func testAutoActivationOfficialRequirementAndRuntimeMutationAreBlocked() {
        let candidate = compiledCandidate(
            requirements: [requirement(id: "requirement-1", kind: .hardRequirement)],
            activationReview: .reviewReady,
            autoActivates: true,
            claimsOfficialRequirements: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: false,
                performsNetworkFetches: false,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        let issues = validator.validate(candidate)

        XCTAssertEqual(candidate.reviewProjection, .blocked)
        XCTAssertTrue(issues.contains(.autoActivationRisk))
        XCTAssertTrue(issues.contains(.officialRequirementOverclaim))
        XCTAssertTrue(issues.contains(.runtimeMutationBehavior))
    }

    func testProfessionalBoundaryRequiresSourceBackedReviewedRequirements() {
        let candidate = compiledCandidate(
            goalClass: .regulatedGoal,
            requirements: [
                requirement(
                    id: "medical-boundary",
                    kind: .hardRequirement,
                    sourceState: .userStated,
                    reviewState: .needsSourceReview
                )
            ],
            professionalBoundaryApplies: true
        )

        let issues = validator.validate(candidate)

        XCTAssertEqual(candidate.reviewProjection, .needsSourceReview)
        XCTAssertTrue(issues.contains(.professionalBoundaryReviewRequired))
        XCTAssertTrue(issues.contains(.sourceReviewRequired))
    }

    func testProofNeededAndSensitiveExternalProjectionRequireReview() {
        let candidate = compiledCandidate(
            requirements: [
                requirement(id: "proof-needed", kind: .proofNeeded, proofReceiptIDs: []),
                requirement(id: "private-source", kind: .softRequirement, privacyClass: .sensitive)
            ],
            externalProjectionRequested: true
        )

        let issues = validator.validate(candidate)

        XCTAssertEqual(candidate.reviewProjection, .needsUserReview)
        XCTAssertTrue(issues.contains(.proofReviewRequired))
        XCTAssertTrue(issues.contains(.externalProjectionRisk))
    }
}

private extension AmbitionsOSGoalPathCompilerModelsTests {
    func compiledCandidate(
        id: String = "compiled-path",
        title: String = "Conservative first path",
        goalClass: AmbitionsOSGoalPathClass = .projectGoal,
        startingPositionSnapshotID: String? = "starting-position",
        stages: [AmbitionsOSGoalPathStageContract]? = nil,
        requirements: [AmbitionsOSGoalPathRequirementSlot],
        activationReview: AmbitionsOSGoalPathActivationReview = .draft,
        autoActivates: Bool = false,
        claimsOfficialRequirements: Bool = false,
        professionalBoundaryApplies: Bool = false,
        externalProjectionRequested: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSGoalPathCompilerSchemaVersion
    ) -> AmbitionsOSGoalPathCompiledCandidate {
        AmbitionsOSGoalPathCompiledCandidate(
            id: id,
            title: title,
            goalClass: goalClass,
            startingPositionSnapshotID: startingPositionSnapshotID,
            stages: stages ?? [stage(requirementIDs: requirements.map(\.id))],
            requirements: requirements,
            activationReview: activationReview,
            autoActivates: autoActivates,
            claimsOfficialRequirements: claimsOfficialRequirements,
            professionalBoundaryApplies: professionalBoundaryApplies,
            externalProjectionRequested: externalProjectionRequested,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func stage(
        id: String = "stage-1",
        title: String = "Start safely",
        orderIndex: Int = 0,
        requirementIDs: [String],
        proofNeededIDs: [String] = [],
        schemaVersion: String = ambitionsOSGoalPathCompilerSchemaVersion
    ) -> AmbitionsOSGoalPathStageContract {
        AmbitionsOSGoalPathStageContract(
            id: id,
            title: title,
            orderIndex: orderIndex,
            requirementIDs: requirementIDs,
            proofNeededIDs: proofNeededIDs,
            schemaVersion: schemaVersion
        )
    }

    func requirement(
        id: String,
        title: String = "Requirement needs review",
        kind: AmbitionsOSGoalPathRequirementKind,
        blocking: Bool = true,
        sourceState: HumanProgressSourceState = .sourceBacked,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sourceClaimIDs: [String] = ["claim-1"],
        proofReceiptIDs: [String] = ["receipt-1"],
        schemaVersion: String = ambitionsOSGoalPathCompilerSchemaVersion
    ) -> AmbitionsOSGoalPathRequirementSlot {
        AmbitionsOSGoalPathRequirementSlot(
            id: id,
            title: title,
            kind: kind,
            blocking: blocking,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            sourceClaimIDs: sourceClaimIDs,
            proofReceiptIDs: proofReceiptIDs,
            schemaVersion: schemaVersion
        )
    }
}
