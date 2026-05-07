import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamPackRegistryModelsTests: XCTestCase {
    func testReviewedPackCompilesToNonActivatingPackSet() throws {
        let input = validInput()
        let registry = AmbitionsOSLivingDreamPackRegistry(inputs: [input])
        let compiled = try AmbitionsOSLivingDreamPackCompiler().compile(registry: registry)

        XCTAssertTrue(input.validationIssues.isEmpty)
        XCTAssertTrue(registry.validationIssues.isEmpty)
        XCTAssertEqual(registry.compilerReadyInputs.map(\.manifest.id), ["ldi.pack.training"])
        XCTAssertEqual(compiled.packIDs, ["ldi.pack.training"])
        XCTAssertEqual(compiled.claimIDs, ["claim-training-age"])
        XCTAssertFalse(compiled.activatesPlans)
        XCTAssertFalse(compiled.mutatesCommitments)
    }

    func testGeneratedOrDraftPackCannotEnterCompiler() {
        let generated = validInput(
            manifest: manifest(
                qualityState: .generated,
                reviewState: .ready
            )
        )
        let draft = validInput(
            manifest: manifest(
                id: "ldi.pack.draft",
                qualityState: .draft,
                reviewState: .needsSourceReview
            )
        )

        XCTAssertTrue(generated.validationIssues.contains(.generatedPackWithoutReviewProof))
        XCTAssertTrue(draft.validationIssues.contains(.generatedPackWithoutReviewProof))
        XCTAssertFalse(generated.canEnterCompiler)
        XCTAssertFalse(draft.canEnterCompiler)
    }

    func testSupplyChainProofAndNoExecutableLogicAreRequired() {
        let input = validInput(
            supplyChainProof: AmbitionsOSLivingDreamPackSupplyChainProof(
                checksum: "",
                provenance: "",
                signedManifestID: "",
                rollbackVersion: "",
                safeImportValidation: false,
                containsExecutableLogic: true
            )
        )

        XCTAssertTrue(input.validationIssues.contains(.missingSupplyChainProof))
        XCTAssertTrue(input.validationIssues.contains(.executableLogic))
    }

    func testUnsafeStaleConflictAndOfficialOverclaimAreBlocked() {
        let unsafe = validInput(
            manifest: manifest(
                qualityState: .unsafeToUse,
                reviewState: .ready
            )
        )
        let stale = validInput(
            manifest: manifest(
                id: "ldi.pack.stale",
                qualityState: .stale,
                reviewState: .ready,
                lifecycleState: .stale
            )
        )
        let overclaim = validInput(
            manifest: manifest(
                id: "ldi.pack.official",
                claimsOfficialSourcePack: true
            )
        )

        XCTAssertTrue(unsafe.validationIssues.contains(.unsafePackUsable))
        XCTAssertTrue(stale.validationIssues.contains(.staleOrConflictPackUsable))
        XCTAssertTrue(overclaim.validationIssues.contains(.officialPackOverclaim))
    }

    func testRegulatedPackRequiresReviewAndNoUserDataServerRuntime() {
        let input = validInput(
            manifest: manifest(
                taxonomy: .regulated,
                reviewState: .needsSourceReview,
                usesUserDataServer: true,
                allowsActivation: true
            ),
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        XCTAssertTrue(input.validationIssues.contains(.unreviewedRegulatedPack))
        XCTAssertTrue(input.validationIssues.contains(.userDataServerBoundaryBroken))
        XCTAssertTrue(input.validationIssues.contains(.forbiddenActivation))
        XCTAssertTrue(input.validationIssues.contains(.runtimeBoundaryBroken))
    }

    func testCompilerRejectsInvalidClaimGraphAndDuplicateRegistryInputs() {
        let invalidGraph = AmbitionsOSLivingDreamSourceClaimGraph(
            claims: [claim(sourceRefIDs: ["missing-source"])],
            sourceRefs: [sourceRef()]
        )
        let input = validInput(sourceClaimGraph: invalidGraph)
        let registry = AmbitionsOSLivingDreamPackRegistry(inputs: [input, input])

        XCTAssertTrue(input.validationIssues.contains(.missingSourceClaimGraph))
        XCTAssertTrue(registry.validationIssues.contains(.invalidCompilerInput))
        XCTAssertThrowsError(try AmbitionsOSLivingDreamPackCompiler().compile(registry: registry)) { error in
            XCTAssertTrue(
                (error as? AmbitionsOSLivingDreamPackRegistryValidator.ValidationError)?
                    .issues
                    .contains(.missingSourceClaimGraph) == true
            )
        }
    }
}

private extension AmbitionsOSLivingDreamPackRegistryModelsTests {
    func validInput(
        manifest: AmbitionsOSLivingDreamPackManifest? = nil,
        supplyChainProof: AmbitionsOSLivingDreamPackSupplyChainProof? = nil,
        sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph? = nil,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly
    ) -> AmbitionsOSLivingDreamPackCompilerInput {
        AmbitionsOSLivingDreamPackCompilerInput(
            id: "compiler-input.training",
            manifest: manifest ?? self.manifest(),
            supplyChainProof: supplyChainProof ?? Self.proof(),
            sourceClaimGraph: sourceClaimGraph ?? validClaimGraph(),
            runtimeBoundary: runtimeBoundary
        )
    }

    func validClaimGraph() -> AmbitionsOSLivingDreamSourceClaimGraph {
        AmbitionsOSLivingDreamSourceClaimGraph(
            claims: [claim()],
            sourceRefs: [sourceRef()]
        )
    }

    func manifest(
        id: String = "ldi.pack.training",
        taxonomy: AmbitionsOSLivingDreamPackTaxonomy = .domain,
        qualityState: AmbitionsOSLivingDreamPackQualityState = .reviewed,
        reviewState: HumanProgressReviewState = .ready,
        lifecycleState: AmbitionsOSLivingDreamPackLifecycleState = .active,
        claimsOfficialSourcePack: Bool = false,
        usesUserDataServer: Bool = false,
        allowsActivation: Bool = false
    ) -> AmbitionsOSLivingDreamPackManifest {
        AmbitionsOSLivingDreamPackManifest(
            id: id,
            title: "Training Pack",
            taxonomy: taxonomy,
            version: "1.0.0",
            sourceAtlasPackID: "source-atlas.training",
            sourceClaimGraphID: "claim-graph.training",
            sourceClaimIDs: ["claim-training-age"],
            qualityState: qualityState,
            reviewState: reviewState,
            lifecycleState: lifecycleState,
            claimsOfficialSourcePack: claimsOfficialSourcePack,
            allowsActivation: allowsActivation,
            usesUserDataServer: usesUserDataServer
        )
    }

    static func proof() -> AmbitionsOSLivingDreamPackSupplyChainProof {
        AmbitionsOSLivingDreamPackSupplyChainProof(
            checksum: "sha256-example",
            provenance: "local-fixture",
            signedManifestID: "manifest.training.v1",
            rollbackVersion: "0.9.0"
        )
    }

    func sourceRef() -> AmbitionsOSLivingDreamSourceClaimReference {
        AmbitionsOSLivingDreamSourceClaimReference(
            id: "source-official",
            title: "Reviewed official source",
            kind: .official,
            locator: "https://example.invalid/source",
            retrievedAt: "2026-05-07T16:10:00Z",
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
            lastVerified: "2026-05-07T16:10:00Z",
            effectiveDate: "2026-05-01",
            professionalBoundary: true,
            claimQualityState: .officialSourceBacked,
            riskClass: .careerContext,
            reviewState: .ready
        )
    }
}
