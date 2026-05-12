import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamRequirementGraphModelsTests: XCTestCase {
    func testSatisfiedRequirementGraphCanRecommendWithoutActivating() {
        let graph = validGraph()
        let evaluation = AmbitionsOSLivingDreamRequirementGraphValidator().evaluate(graph: graph)

        XCTAssertTrue(graph.validationIssues.isEmpty)
        XCTAssertTrue(evaluation.canRecommendConsequentialNextStep)
        XCTAssertEqual(evaluation.readyRequirementIDs, ["requirement.training.age", "requirement.training.proof"])
        XCTAssertTrue(evaluation.blockerRequirementIDs.isEmpty)
        XCTAssertFalse(evaluation.activatesPlans)
        XCTAssertFalse(evaluation.mutatesCommitments)
    }

    func testHardRequirementsBlockWhenMissing() {
        let graph = validGraph(
            requirements: [
                requirement(
                    id: "requirement.training.age",
                    kind: .hard,
                    state: .missing
                )
            ]
        )
        let evaluation = AmbitionsOSLivingDreamRequirementGraphValidator().evaluate(graph: graph)

        XCTAssertTrue(graph.validationIssues.contains(.hardRequirementUnsatisfied))
        XCTAssertEqual(evaluation.blockerRequirementIDs, ["requirement.training.age"])
        XCTAssertFalse(evaluation.canRecommendConsequentialNextStep)
    }

    func testBlockersDependenciesAndMissingProofAreReported() {
        let blocker = requirement(
            id: "requirement.training.blocker",
            kind: .blocker,
            state: .blocked
        )
        let proof = requirement(
            id: "requirement.training.proof",
            kind: .proofNeeded,
            state: .needsProof,
            dependencies: [
                AmbitionsOSLivingDreamRequirementEdge(
                    kind: .hard,
                    targetRequirementID: "requirement.training.blocker",
                    sourceState: .officialCurrent,
                    freshnessState: .current,
                    riskState: .low,
                    reviewState: .approved
                )
            ],
            proofIDs: []
        )
        let graph = validGraph(requirements: [blocker, proof])

        XCTAssertTrue(graph.validationIssues.contains(.blockerOpen))
        XCTAssertTrue(graph.validationIssues.contains(.dependencyUnsatisfied))
        XCTAssertTrue(graph.validationIssues.contains(.proofMissing))
    }

    func testMissingClaimAndInvalidClaimGraphAreBlocked() {
        let invalidGraph = AmbitionsOSLivingDreamSourceClaimGraph(
            claims: [claim(sourceRefIDs: ["missing-source"])],
            sourceRefs: [sourceRef()]
        )
        let graph = validGraph(
            requirements: [
                requirement(sourceClaimIDs: ["claim-missing"])
            ],
            sourceClaimGraph: invalidGraph
        )

        XCTAssertTrue(graph.validationIssues.contains(.missingSourceClaim))
        XCTAssertTrue(graph.validationIssues.contains(.sourceClaimGraphNotReady))
    }

    func testUntrustedPackSecurityBlocksRequirementGraphUse() {
        let untrustedEnvelope = validEnvelope(
            checksumProof: AmbitionsOSLivingDreamPackChecksumProof(
                expectedChecksum: "sha256:expected",
                observedChecksum: "sha256:observed"
            )
        )
        let graph = validGraph(packSecurityEnvelope: untrustedEnvelope)

        XCTAssertTrue(graph.validationIssues.contains(.packSecurityNotTrusted))
    }

    func testRuntimeActivationUserDataAndProfessionalReviewAreBlocked() {
        let graph = validGraph(
            requirements: [
                requirement(
                    professionalBoundary: true,
                    reviewState: .needsSourceReview
                )
            ],
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            ),
            allowsActivation: true,
            usesUserDataServer: true
        )

        XCTAssertTrue(graph.validationIssues.contains(.professionalBoundaryNeedsReview))
        XCTAssertTrue(graph.validationIssues.contains(.runtimeBoundaryBroken))
        XCTAssertTrue(graph.validationIssues.contains(.activationForbidden))
        XCTAssertTrue(graph.validationIssues.contains(.userDataServerBoundaryBroken))
    }

    func testTypedEdgesCaptureSourceFreshnessRiskAndReviewState() {
        let graph = validGraph(
            requirements: [
                requirement(
                    id: "requirement.training.precheck",
                    kind: .prerequisite,
                    state: .satisfied,
                    dependencies: [
                        AmbitionsOSLivingDreamRequirementEdge(
                            kind: .dependency,
                            targetRequirementID: "requirement.training.age",
                            sourceState: .revoked,
                            freshnessState: .stale,
                            riskState: .high,
                            reviewState: .required
                        )
                    ]
                ),
                requirement(
                    id: "requirement.training.age",
                    kind: .hard,
                    state: .satisfied
                )
            ]
        )

        XCTAssertTrue(graph.validationIssues.contains(.dependencyUnsatisfied))
    }
}

private extension AmbitionsOSLivingDreamRequirementGraphModelsTests {
    func validGraph(
        requirements: [AmbitionsOSLivingDreamRequirementNode]? = nil,
        sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph? = nil,
        packSecurityEnvelope: AmbitionsOSLivingDreamPackSupplyChainEnvelope? = nil,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        allowsActivation: Bool = false,
        usesUserDataServer: Bool = false
    ) -> AmbitionsOSLivingDreamRequirementGraph {
        let claimGraph = sourceClaimGraph ?? validClaimGraph()
        return AmbitionsOSLivingDreamRequirementGraph(
            id: "requirement-graph.training",
            requirements: requirements ?? [
                requirement(id: "requirement.training.age", kind: .hard),
                requirement(
                    id: "requirement.training.proof",
                    kind: .proofNeeded,
                    proofIDs: ["proof.training"]
                )
            ],
            sourceClaimGraph: claimGraph,
            packSecurityEnvelope: packSecurityEnvelope ?? validEnvelope(sourceClaimGraph: claimGraph),
            runtimeBoundary: runtimeBoundary,
            allowsActivation: allowsActivation,
            usesUserDataServer: usesUserDataServer
        )
    }

    func requirement(
        id: String = "requirement.training.age",
        kind: AmbitionsOSLivingDreamRequirementKind = .hard,
        state: AmbitionsOSLivingDreamRequirementState = .satisfied,
        sourceClaimIDs: [String] = ["claim-training-age"],
        dependencies: [AmbitionsOSLivingDreamRequirementEdge] = [],
        proofIDs: [String] = [],
        professionalBoundary: Bool = false,
        reviewState: HumanProgressReviewState = .ready
    ) -> AmbitionsOSLivingDreamRequirementNode {
        AmbitionsOSLivingDreamRequirementNode(
            id: id,
            title: "Training requirement",
            kind: kind,
            state: state,
            sourceClaimIDs: sourceClaimIDs,
            dependencies: dependencies,
            proofIDs: proofIDs,
            professionalBoundary: professionalBoundary,
            reviewState: reviewState
        )
    }

    func validEnvelope(
        sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph? = nil,
        checksumProof: AmbitionsOSLivingDreamPackChecksumProof = AmbitionsOSLivingDreamPackChecksumProof(
            expectedChecksum: "sha256:training",
            observedChecksum: "sha256:training"
        )
    ) -> AmbitionsOSLivingDreamPackSupplyChainEnvelope {
        AmbitionsOSLivingDreamPackSupplyChainEnvelope(
            id: "ldi.pack.training",
            compilerInput: validInput(sourceClaimGraph: sourceClaimGraph),
            checksumProof: checksumProof,
            signatureProof: AmbitionsOSLivingDreamPackSignatureProof(
                signedManifestID: "manifest.training.v1",
                signerID: "local-reviewer",
                signatureVersion: "1",
                verifiedLocally: true
            ),
            rollbackProof: AmbitionsOSLivingDreamPackRollbackProof(
                currentVersion: "1.0.0",
                rollbackVersion: "0.9.0",
                preservesPreviousManifest: true,
                reversibleWithoutNetwork: true
            ),
            provenance: "local-fixture",
            safeImportValidation: true,
            corruptionHandling: true,
            tamperDetection: true,
            packDiffIntegrity: true,
            packManifestIntegrity: true,
            containsExecutableLogic: false
        )
    }

    func validInput(
        sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph? = nil
    ) -> AmbitionsOSLivingDreamPackCompilerInput {
        AmbitionsOSLivingDreamPackCompilerInput(
            id: "compiler-input.training",
            manifest: manifest(),
            supplyChainProof: AmbitionsOSLivingDreamPackSupplyChainProof(
                checksum: "sha256:training",
                provenance: "local-fixture",
                signedManifestID: "manifest.training.v1",
                rollbackVersion: "0.9.0"
            ),
            sourceClaimGraph: sourceClaimGraph ?? validClaimGraph(),
            runtimeBoundary: .valueModelOnly
        )
    }

    func manifest() -> AmbitionsOSLivingDreamPackManifest {
        AmbitionsOSLivingDreamPackManifest(
            id: "ldi.pack.training",
            title: "Training Pack",
            taxonomy: .domain,
            version: "1.0.0",
            sourceAtlasPackID: "source-atlas.training",
            sourceClaimGraphID: "claim-graph.training",
            sourceClaimIDs: ["claim-training-age"],
            qualityState: .reviewed,
            reviewState: .ready
        )
    }

    func validClaimGraph() -> AmbitionsOSLivingDreamSourceClaimGraph {
        AmbitionsOSLivingDreamSourceClaimGraph(
            claims: [claim()],
            sourceRefs: [sourceRef()]
        )
    }

    func sourceRef() -> AmbitionsOSLivingDreamSourceClaimReference {
        AmbitionsOSLivingDreamSourceClaimReference(
            id: "source-official",
            title: "Reviewed official source",
            kind: .official,
            locator: "https://example.invalid/source",
            retrievedAt: "2026-05-07T16:50:00Z",
            approvedForOfficialClaims: true,
            reviewState: .ready
        )
    }

    func claim(sourceRefIDs: [String] = ["source-official"]) -> AmbitionsOSLivingDreamSourceClaim {
        AmbitionsOSLivingDreamSourceClaim(
            id: "claim-training-age",
            claimType: .eligibility,
            value: "The reviewed source says this eligibility requirement applies in the named jurisdiction.",
            jurisdiction: "US-EXAMPLE",
            authorityLevel: .official,
            sourceRefIDs: sourceRefIDs,
            sourceState: .sourceBacked,
            freshnessPolicy: AmbitionsOSLivingDreamFreshnessPolicy(reviewIntervalDays: 30),
            freshnessState: .current,
            lastVerified: "2026-05-07T16:50:00Z",
            effectiveDate: "2026-05-01",
            professionalBoundary: true,
            claimQualityState: .officialSourceBacked,
            riskClass: .careerContext,
            reviewState: .ready
        )
    }
}
