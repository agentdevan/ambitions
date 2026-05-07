import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamEligibilityDeadlineModelsTests: XCTestCase {
    func testSatisfiedEligibilityAndDeadlineRuntimeCanProceedWithoutActivating() {
        let runtime = validRuntime()
        let evaluation = AmbitionsOSLivingDreamEligibilityDeadlineValidator().evaluate(runtime: runtime)

        XCTAssertTrue(evaluation.issues.isEmpty)
        XCTAssertTrue(evaluation.canProceedToPathPortfolio)
        XCTAssertEqual(evaluation.eligibleConditionIDs, [
            "eligibility.training.age",
            "eligibility.training.deadline",
            "eligibility.training.lead"
        ])
        XCTAssertTrue(evaluation.blockedConditionIDs.isEmpty)
        XCTAssertFalse(evaluation.activatesPlans)
        XCTAssertFalse(evaluation.mutatesCommitments)
    }

    func testAgeDeadlineAndLeadTimeFailuresBlockProgress() {
        let runtime = validRuntime(
            conditions: [
                condition(
                    id: "eligibility.training.age",
                    kind: .minimumAge,
                    minimumAge: 18,
                    observedAge: 16
                ),
                condition(
                    id: "eligibility.training.deadline",
                    kind: .deadline,
                    currentDate: "2026-06-15",
                    deadlineDate: "2026-06-01"
                ),
                condition(
                    id: "eligibility.training.lead",
                    kind: .minimumLeadTime,
                    minimumLeadDays: 14,
                    observedLeadDays: 7
                )
            ]
        )
        let evaluation = AmbitionsOSLivingDreamEligibilityDeadlineValidator().evaluate(runtime: runtime)

        XCTAssertTrue(evaluation.issues.contains(.ageBelowMinimum))
        XCTAssertTrue(evaluation.issues.contains(.deadlinePassed))
        XCTAssertTrue(evaluation.issues.contains(.insufficientLeadTime))
        XCTAssertEqual(evaluation.blockedConditionIDs, [
            "eligibility.training.age",
            "eligibility.training.deadline",
            "eligibility.training.lead"
        ])
        XCTAssertFalse(evaluation.canProceedToPathPortfolio)
    }

    func testApplicationWindowBlocksBeforeAndAfterWindow() {
        let before = validRuntime(
            conditions: [
                condition(
                    id: "eligibility.training.window",
                    kind: .applicationWindow,
                    currentDate: "2026-04-01",
                    windowStartDate: "2026-05-01",
                    windowEndDate: "2026-06-01"
                )
            ]
        )
        let after = validRuntime(
            conditions: [
                condition(
                    id: "eligibility.training.window",
                    kind: .applicationWindow,
                    currentDate: "2026-07-01",
                    windowStartDate: "2026-05-01",
                    windowEndDate: "2026-06-01"
                )
            ]
        )

        XCTAssertTrue(AmbitionsOSLivingDreamEligibilityDeadlineValidator().validate(runtime: before).contains(.beforeWindow))
        XCTAssertTrue(AmbitionsOSLivingDreamEligibilityDeadlineValidator().validate(runtime: after).contains(.afterWindow))
    }

    func testMissingRequirementAndMissingClaimAreReported() {
        let runtime = validRuntime(
            conditions: [
                condition(
                    sourceClaimIDs: ["claim-missing"],
                    requirementIDs: ["requirement.missing"]
                )
            ]
        )

        XCTAssertTrue(runtime.validationIssues.contains(.missingRequirement))
        XCTAssertTrue(runtime.validationIssues.contains(.missingSourceClaim))
    }

    func testStaleConflictedSourceClaimsBlockEligibilityUse() {
        let sourceClaimGraph = validClaimGraph(
            claims: [
                claim(
                    freshnessState: .sourceChanged,
                    sourceConflictState: .confirmed,
                    claimQualityState: .conflict
                )
            ]
        )
        let requirementGraph = validRequirementGraph(sourceClaimGraph: sourceClaimGraph)
        let runtime = validRuntime(requirementGraph: requirementGraph)

        XCTAssertTrue(runtime.validationIssues.contains(.requirementGraphNotReady))
        XCTAssertTrue(runtime.validationIssues.contains(.sourceClaimNotReady))
        XCTAssertTrue(runtime.validationIssues.contains(.staleCriticalSource))
        XCTAssertTrue(runtime.validationIssues.contains(.unresolvedSourceConflict))
    }

    func testRuntimeActivationUserDataAndProfessionalReviewAreBlocked() {
        let runtime = validRuntime(
            conditions: [
                condition(
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

        XCTAssertTrue(runtime.validationIssues.contains(.professionalBoundaryNeedsReview))
        XCTAssertTrue(runtime.validationIssues.contains(.runtimeBoundaryBroken))
        XCTAssertTrue(runtime.validationIssues.contains(.activationForbidden))
        XCTAssertTrue(runtime.validationIssues.contains(.userDataServerBoundaryBroken))
    }
}

private extension AmbitionsOSLivingDreamEligibilityDeadlineRuntime {
    var validationIssues: [AmbitionsOSLivingDreamEligibilityDeadlineIssue] {
        AmbitionsOSLivingDreamEligibilityDeadlineValidator().validate(runtime: self)
    }
}

private extension AmbitionsOSLivingDreamEligibilityDeadlineModelsTests {
    func validRuntime(
        conditions: [AmbitionsOSLivingDreamEligibilityDeadlineCondition]? = nil,
        requirementGraph: AmbitionsOSLivingDreamRequirementGraph? = nil,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        allowsActivation: Bool = false,
        usesUserDataServer: Bool = false
    ) -> AmbitionsOSLivingDreamEligibilityDeadlineRuntime {
        AmbitionsOSLivingDreamEligibilityDeadlineRuntime(
            id: "eligibility-runtime.training",
            conditions: conditions ?? [
                condition(id: "eligibility.training.age", kind: .minimumAge, minimumAge: 18, observedAge: 20),
                condition(id: "eligibility.training.deadline", kind: .deadline, deadlineDate: "2026-06-01"),
                condition(id: "eligibility.training.lead", kind: .minimumLeadTime, minimumLeadDays: 14, observedLeadDays: 30)
            ],
            requirementGraph: requirementGraph ?? validRequirementGraph(),
            runtimeBoundary: runtimeBoundary,
            allowsActivation: allowsActivation,
            usesUserDataServer: usesUserDataServer
        )
    }

    func condition(
        id: String = "eligibility.training.age",
        kind: AmbitionsOSLivingDreamEligibilityDeadlineKind = .minimumAge,
        state: AmbitionsOSLivingDreamEligibilityDeadlineState = .satisfied,
        sourceClaimIDs: [String] = ["claim-training-age"],
        requirementIDs: [String] = ["requirement.training.age"],
        currentDate: String = "2026-05-07",
        windowStartDate: String? = nil,
        windowEndDate: String? = nil,
        deadlineDate: String? = nil,
        minimumAge: Int? = 18,
        maximumAge: Int? = nil,
        observedAge: Int? = 20,
        minimumLeadDays: Int? = nil,
        observedLeadDays: Int? = nil,
        professionalBoundary: Bool = false,
        reviewState: HumanProgressReviewState = .ready
    ) -> AmbitionsOSLivingDreamEligibilityDeadlineCondition {
        AmbitionsOSLivingDreamEligibilityDeadlineCondition(
            id: id,
            title: "Training eligibility",
            kind: kind,
            state: state,
            sourceClaimIDs: sourceClaimIDs,
            requirementIDs: requirementIDs,
            jurisdiction: "US-EXAMPLE",
            currentDate: currentDate,
            windowStartDate: windowStartDate,
            windowEndDate: windowEndDate,
            deadlineDate: deadlineDate,
            minimumAge: minimumAge,
            maximumAge: maximumAge,
            observedAge: observedAge,
            minimumLeadDays: minimumLeadDays,
            observedLeadDays: observedLeadDays,
            professionalBoundary: professionalBoundary,
            reviewState: reviewState
        )
    }

    func validRequirementGraph(
        sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph? = nil
    ) -> AmbitionsOSLivingDreamRequirementGraph {
        let graph = sourceClaimGraph ?? validClaimGraph()
        return AmbitionsOSLivingDreamRequirementGraph(
            id: "requirement-graph.training",
            requirements: [
                AmbitionsOSLivingDreamRequirementNode(
                    id: "requirement.training.age",
                    title: "Training age requirement",
                    kind: .hard,
                    state: .satisfied,
                    sourceClaimIDs: ["claim-training-age"],
                    reviewState: .ready
                )
            ],
            sourceClaimGraph: graph,
            packSecurityEnvelope: validEnvelope(sourceClaimGraph: graph)
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

    func validClaimGraph(
        claims: [AmbitionsOSLivingDreamSourceClaim]? = nil
    ) -> AmbitionsOSLivingDreamSourceClaimGraph {
        AmbitionsOSLivingDreamSourceClaimGraph(
            claims: claims ?? [claim()],
            sourceRefs: [sourceRef()]
        )
    }

    func sourceRef() -> AmbitionsOSLivingDreamSourceClaimReference {
        AmbitionsOSLivingDreamSourceClaimReference(
            id: "source-official",
            title: "Reviewed official source",
            kind: .official,
            locator: "https://example.invalid/source",
            retrievedAt: "2026-05-07T17:50:00Z",
            approvedForOfficialClaims: true,
            reviewState: .ready
        )
    }

    func claim(
        freshnessState: HumanProgressFreshnessState = .current,
        sourceConflictState: AmbitionsOSLivingDreamSourceConflictState = .none,
        claimQualityState: AmbitionsOSLivingDreamClaimQualityState = .officialSourceBacked
    ) -> AmbitionsOSLivingDreamSourceClaim {
        AmbitionsOSLivingDreamSourceClaim(
            id: "claim-training-age",
            claimType: .eligibility,
            value: "The reviewed source says this age requirement applies in the named jurisdiction.",
            jurisdiction: "US-EXAMPLE",
            authorityLevel: .official,
            sourceRefIDs: ["source-official"],
            sourceState: .sourceBacked,
            freshnessPolicy: AmbitionsOSLivingDreamFreshnessPolicy(reviewIntervalDays: 30),
            freshnessState: freshnessState,
            lastVerified: "2026-05-07T17:50:00Z",
            effectiveDate: "2026-05-01",
            professionalBoundary: true,
            sourceConflictState: sourceConflictState,
            claimQualityState: claimQualityState,
            riskClass: .careerContext,
            reviewState: .ready
        )
    }
}
