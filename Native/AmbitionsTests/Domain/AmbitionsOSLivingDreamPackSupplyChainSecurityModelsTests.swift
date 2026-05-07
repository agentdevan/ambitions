import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamPackSupplyChainSecurityModelsTests: XCTestCase {
    func testTrustedEnvelopeProducesNonMutatingReceipt() {
        let envelope = validEnvelope()
        let receipt = AmbitionsOSLivingDreamPackSupplyChainValidator().receipt(for: envelope)

        XCTAssertTrue(envelope.validationIssues.isEmpty)
        XCTAssertTrue(envelope.isTrustedForRegistry)
        XCTAssertTrue(receipt.accepted)
        XCTAssertTrue(receipt.issues.isEmpty)
        XCTAssertFalse(receipt.activatesPlans)
        XCTAssertFalse(receipt.mutatesCommitments)
        XCTAssertFalse(receipt.usesUserDataServer)
    }

    func testChecksumMismatchAndUnsignedManifestAreBlocked() {
        let envelope = validEnvelope(
            checksumProof: AmbitionsOSLivingDreamPackChecksumProof(
                expectedChecksum: "sha256:expected",
                observedChecksum: "sha256:observed"
            ),
            signatureProof: AmbitionsOSLivingDreamPackSignatureProof(
                signedManifestID: "",
                signerID: "",
                signatureVersion: "",
                verifiedLocally: false
            )
        )

        XCTAssertTrue(envelope.validationIssues.contains(.checksumMismatch))
        XCTAssertTrue(envelope.validationIssues.contains(.signatureMissing))
        XCTAssertTrue(envelope.validationIssues.contains(.signatureUnverified))
        XCTAssertFalse(envelope.isTrustedForRegistry)
    }

    func testRollbackMustBeReversibleAndCommitmentSafe() {
        let envelope = validEnvelope(
            rollbackProof: AmbitionsOSLivingDreamPackRollbackProof(
                currentVersion: "1.0.0",
                rollbackVersion: "1.0.0",
                preservesPreviousManifest: false,
                reversibleWithoutNetwork: false,
                mutatesUserCommitments: true
            )
        )

        XCTAssertTrue(envelope.validationIssues.contains(.rollbackMissing))
        XCTAssertTrue(envelope.validationIssues.contains(.rollbackNotReversible))
    }

    func testImportCorruptionTamperAndDiffIntegrityAreRequired() {
        let envelope = validEnvelope(
            safeImportValidation: false,
            corruptionHandling: false,
            tamperDetection: false,
            packDiffIntegrity: false,
            packManifestIntegrity: false
        )

        XCTAssertTrue(envelope.validationIssues.contains(.safeImportValidationMissing))
        XCTAssertTrue(envelope.validationIssues.contains(.corruptionHandlingMissing))
        XCTAssertTrue(envelope.validationIssues.contains(.tamperDetectionMissing))
        XCTAssertTrue(envelope.validationIssues.contains(.packDiffIntegrityMissing))
        XCTAssertTrue(envelope.validationIssues.contains(.packManifestIntegrityMissing))
    }

    func testExecutableLogicAndRuntimeBoundariesAreBlocked() {
        let envelope = validEnvelope(
            compilerInput: validInput(
                manifest: manifest(usesUserDataServer: true, allowsActivation: true),
                runtimeBoundary: SourceAtlasRuntimeBoundary(
                    storesUserData: true,
                    performsNetworkFetches: true,
                    mutatesPlans: true,
                    writesPersistence: true
                )
            ),
            containsExecutableLogic: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        XCTAssertTrue(envelope.validationIssues.contains(.executableLogicPresent))
        XCTAssertTrue(envelope.validationIssues.contains(.runtimeBoundaryBroken))
        XCTAssertTrue(envelope.validationIssues.contains(.userDataServerBoundaryBroken))
        XCTAssertTrue(envelope.validationIssues.contains(.activationOrMutationForbidden))
    }

    func testInvalidSourceClaimGraphBlocksTrustedUse() {
        let invalidGraph = AmbitionsOSLivingDreamSourceClaimGraph(
            claims: [claim(sourceRefIDs: ["missing-source"])],
            sourceRefs: [sourceRef()]
        )
        let envelope = validEnvelope(
            compilerInput: validInput(sourceClaimGraph: invalidGraph)
        )

        XCTAssertTrue(envelope.validationIssues.contains(.sourceClaimGraphNotReady))
        XCTAssertFalse(envelope.isTrustedForRegistry)
    }
}

private extension AmbitionsOSLivingDreamPackSupplyChainSecurityModelsTests {
    func validEnvelope(
        compilerInput: AmbitionsOSLivingDreamPackCompilerInput? = nil,
        checksumProof: AmbitionsOSLivingDreamPackChecksumProof = AmbitionsOSLivingDreamPackChecksumProof(
            expectedChecksum: "sha256:training",
            observedChecksum: "sha256:training"
        ),
        signatureProof: AmbitionsOSLivingDreamPackSignatureProof = AmbitionsOSLivingDreamPackSignatureProof(
            signedManifestID: "manifest.training.v1",
            signerID: "local-reviewer",
            signatureVersion: "1",
            verifiedLocally: true
        ),
        rollbackProof: AmbitionsOSLivingDreamPackRollbackProof = AmbitionsOSLivingDreamPackRollbackProof(
            currentVersion: "1.0.0",
            rollbackVersion: "0.9.0",
            preservesPreviousManifest: true,
            reversibleWithoutNetwork: true
        ),
        safeImportValidation: Bool = true,
        corruptionHandling: Bool = true,
        tamperDetection: Bool = true,
        packDiffIntegrity: Bool = true,
        packManifestIntegrity: Bool = true,
        containsExecutableLogic: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly
    ) -> AmbitionsOSLivingDreamPackSupplyChainEnvelope {
        AmbitionsOSLivingDreamPackSupplyChainEnvelope(
            id: "ldi.pack.training",
            compilerInput: compilerInput ?? validInput(),
            checksumProof: checksumProof,
            signatureProof: signatureProof,
            rollbackProof: rollbackProof,
            provenance: "local-fixture",
            safeImportValidation: safeImportValidation,
            corruptionHandling: corruptionHandling,
            tamperDetection: tamperDetection,
            packDiffIntegrity: packDiffIntegrity,
            packManifestIntegrity: packManifestIntegrity,
            containsExecutableLogic: containsExecutableLogic,
            runtimeBoundary: runtimeBoundary
        )
    }

    func validInput(
        manifest: AmbitionsOSLivingDreamPackManifest? = nil,
        supplyChainProof: AmbitionsOSLivingDreamPackSupplyChainProof? = nil,
        sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph? = nil,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly
    ) -> AmbitionsOSLivingDreamPackCompilerInput {
        AmbitionsOSLivingDreamPackCompilerInput(
            id: "compiler-input.training",
            manifest: manifest ?? self.manifest(),
            supplyChainProof: supplyChainProof ?? proof(),
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

    func proof() -> AmbitionsOSLivingDreamPackSupplyChainProof {
        AmbitionsOSLivingDreamPackSupplyChainProof(
            checksum: "sha256:training",
            provenance: "local-fixture",
            signedManifestID: "manifest.training.v1",
            rollbackVersion: "0.9.0"
        )
    }

    func manifest(
        usesUserDataServer: Bool = false,
        allowsActivation: Bool = false
    ) -> AmbitionsOSLivingDreamPackManifest {
        AmbitionsOSLivingDreamPackManifest(
            id: "ldi.pack.training",
            title: "Training Pack",
            taxonomy: .domain,
            version: "1.0.0",
            sourceAtlasPackID: "source-atlas.training",
            sourceClaimGraphID: "claim-graph.training",
            sourceClaimIDs: ["claim-training-age"],
            qualityState: .reviewed,
            reviewState: .ready,
            allowsActivation: allowsActivation,
            usesUserDataServer: usesUserDataServer
        )
    }

    func sourceRef() -> AmbitionsOSLivingDreamSourceClaimReference {
        AmbitionsOSLivingDreamSourceClaimReference(
            id: "source-official",
            title: "Reviewed official source",
            kind: .official,
            locator: "https://example.invalid/source",
            retrievedAt: "2026-05-07T16:30:00Z",
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
            lastVerified: "2026-05-07T16:30:00Z",
            effectiveDate: "2026-05-01",
            professionalBoundary: true,
            claimQualityState: .officialSourceBacked,
            riskClass: .careerContext,
            reviewState: .ready
        )
    }
}
