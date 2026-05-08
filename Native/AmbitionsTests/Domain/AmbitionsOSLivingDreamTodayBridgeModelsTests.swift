import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamTodayBridgeModelsTests: XCTestCase {
    private let validator = AmbitionsOSLivingDreamTodayBridgeValidator()

    func testReadyTodayBridgeRoundTripsWithThreeUsefulStepsAndClosurePrompt() throws {
        let bridge = makeBridge()

        let data = try JSONEncoder().encode(bridge)
        let decoded = try JSONDecoder().decode(AmbitionsOSLivingDreamTodayBridge.self, from: data)
        let evaluation = validator.evaluate(bridge: decoded)

        XCTAssertEqual(evaluation.issues, [])
        XCTAssertEqual(evaluation.readiness, .readyForToday)
        XCTAssertEqual(evaluation.todayStepIDs, ["proof-step", "review-step", "today-step"])
        XCTAssertEqual(evaluation.recommendedStepIDs, ["today-step"])
        XCTAssertEqual(evaluation.closurePromptIDs, ["closure-prompt"])
        XCTAssertEqual(evaluation.proofReceiptIDs, ["proof-1"])
    }

    func testCapacityBridgeMustBeReadyBeforeTodayProjection() {
        let bridge = makeBridge(
            capacityBridge: capacityBridge(
                commitmentProjection: commitmentProjection(
                    commitments: [
                        commitment(id: "primary-step", durationMinutes: 90),
                        commitment(id: "proof-step", kind: .reviewWindow, durationMinutes: 45)
                    ],
                    capacityWindows: [capacityWindow(availableMinutes: 60)]
                )
            )
        )

        let issues = validator.validate(bridge: bridge)

        XCTAssertTrue(issues.contains(.capacityBridgeNotReady))
        XCTAssertEqual(validator.evaluate(bridge: bridge).readiness, .needsCapacityReview)
    }

    func testOneToThreeTodayStepRuleAndRequiredStepKindsAreEnforced() {
        let tooMany = makeBridge(todaySteps: [
            todayStep(id: "one", kind: .recommendedStep),
            todayStep(id: "two", kind: .proofStep),
            todayStep(id: "three", kind: .sourceReview),
            todayStep(id: "four", kind: .closureReview)
        ])
        let missingRecommendedAndProof = makeBridge(todaySteps: [
            todayStep(id: "closure-only", kind: .closureReview, proofReceiptIDs: [])
        ])

        XCTAssertTrue(validator.validate(bridge: tooMany).contains(.tooManyTodaySteps))

        let missingIssues = validator.validate(bridge: missingRecommendedAndProof)
        XCTAssertTrue(missingIssues.contains(.missingRecommendedStep))
        XCTAssertTrue(missingIssues.contains(.missingProofOrReviewStep) == false)
    }

    func testClosurePromptsMustExistAndUseNonPunitiveLanguage() {
        let missingClosure = makeBridge(
            todaySteps: [
                todayStep(closurePromptID: "missing-prompt")
            ],
            closurePrompts: []
        )
        let punitive = makeBridge(
            closurePrompts: [
                AmbitionsOSClosurePromptContract(
                    promptID: "closure-prompt",
                    unresolvedStateLabel: "Failed and overdue"
                )
            ]
        )

        XCTAssertTrue(validator.validate(bridge: missingClosure).contains(.missingClosurePrompt))
        XCTAssertTrue(validator.validate(bridge: punitive).contains(.punitiveClosureLanguage))
        XCTAssertEqual(validator.evaluate(bridge: punitive).readiness, .needsClosureReview)
    }

    func testRecommendationSourceProofControlAndLanguageGatesPropagate() {
        let bridge = makeBridge(
            recommendations: [
                startHere(
                    sourceClaims: [
                        sourceTruthClaim(
                            state: .sourceNeeded,
                            freshnessState: .staleCritical,
                            reviewState: .needsSourceReview
                        )
                    ],
                    proofTrustReceipts: [proofReceipt(actionReceiptIDs: [], proofReferenceIDs: [])],
                    controlActions: [],
                    usesGenericPriorityOnly: true,
                    exposesConfidenceScore: true,
                    claimsGuaranteedOutcome: true,
                    surfaceLanguageSamples: [
                        "AI " + "confidence says this is guaranteed."
                    ]
                )
            ]
        )

        let issues = validator.validate(bridge: bridge)

        XCTAssertTrue(issues.contains(.sourceReviewRequired))
        XCTAssertTrue(issues.contains(.staleSourceReviewRequired))
        XCTAssertTrue(issues.contains(.proofTrustReviewRequired))
        XCTAssertTrue(issues.contains(.missingUserControl))
        XCTAssertTrue(issues.contains(.genericPriorityOnly))
        XCTAssertTrue(issues.contains(.confidenceScoreExposed))
        XCTAssertTrue(issues.contains(.guaranteedOutcomeLanguage))
        XCTAssertTrue(issues.contains(.harmfulRecommendationLanguage))
        XCTAssertEqual(validator.evaluate(bridge: bridge).readiness, .blocked)
    }

    func testRuntimeServerActivationAndMutationAreBlocked() {
        let bridge = makeBridge(
            todaySteps: [
                todayStep(
                    allowsActivation: true,
                    mutatesCommitments: true,
                    usesUserDataServer: true,
                    runtimeBoundary: SourceAtlasRuntimeBoundary(
                        storesUserData: true,
                        performsNetworkFetches: true,
                        mutatesPlans: true,
                        writesPersistence: true
                    )
                )
            ],
            allowsActivation: true,
            mutatesCommitments: true,
            usesUserDataServer: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: false,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        let issues = validator.validate(bridge: bridge)

        XCTAssertTrue(issues.contains(.activationForbidden))
        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.userDataServerBoundaryBroken))
        XCTAssertTrue(issues.contains(.runtimeBoundaryBroken))
        XCTAssertEqual(validator.evaluate(bridge: bridge).readiness, .blocked)
    }

    func testMalformedSchemaAndProofTrustIssuesAreReported() {
        let bridge = makeBridge(
            id: "",
            todaySteps: [
                todayStep(id: "", title: "", estimatedMinutes: 0, schemaVersion: "old")
            ],
            proofReceipts: [
                proofReceipt(
                    actionReceiptIDs: [],
                    proofReferenceIDs: [],
                    sourceState: .sourceNeeded,
                    freshnessState: .staleCritical,
                    reviewState: .needsSourceReview
                )
            ],
            schemaVersion: "old"
        )

        let issues = validator.validate(bridge: bridge)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedBridge))
        XCTAssertTrue(issues.contains(.proofTrustReviewRequired))
        XCTAssertTrue(issues.contains(.sourceReviewRequired))
        XCTAssertTrue(issues.contains(.staleSourceReviewRequired))
    }
}

private extension AmbitionsOSLivingDreamTodayBridgeModelsTests {
    func makeBridge(
        id: String = "today-bridge",
        capacityBridge: AmbitionsOSLivingDreamCapacityBridge? = nil,
        todaySteps: [AmbitionsOSLivingDreamTodayStep]? = nil,
        recommendations: [AmbitionsOSStartHereRecommendation]? = nil,
        closurePrompts: [AmbitionsOSClosurePromptContract]? = nil,
        proofReceipts: [AmbitionsOSProofTrustReceipt]? = nil,
        allowsActivation: Bool = false,
        mutatesCommitments: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamTodayBridgeSchemaVersion
    ) -> AmbitionsOSLivingDreamTodayBridge {
        AmbitionsOSLivingDreamTodayBridge(
            id: id,
            capacityBridge: capacityBridge ?? self.capacityBridge(),
            todaySteps: todaySteps ?? [
                todayStep(),
                todayStep(
                    id: "proof-step",
                    commitmentID: "proof-step",
                    kind: .proofStep,
                    proofReceiptIDs: ["proof-1"]
                ),
                todayStep(
                    id: "review-step",
                    commitmentID: "review-step",
                    kind: .closureReview,
                    proofReceiptIDs: ["proof-1"]
                )
            ],
            recommendations: recommendations ?? [startHere()],
            closurePrompts: closurePrompts ?? [closurePrompt()],
            proofReceipts: proofReceipts ?? [proofReceipt()],
            allowsActivation: allowsActivation,
            mutatesCommitments: mutatesCommitments,
            usesUserDataServer: usesUserDataServer,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func todayStep(
        id: String = "today-step",
        candidateID: String = "primary-path",
        commitmentID: String = "primary-step",
        title: String = "Collect one proof point",
        kind: AmbitionsOSLivingDreamTodayStepKind = .recommendedStep,
        estimatedMinutes: Int = 30,
        sourceClaimIDs: [String] = ["claim-1"],
        proofReceiptIDs: [String] = ["proof-1"],
        closurePromptID: String? = "closure-prompt",
        recommendationID: String? = "start-here-1",
        allowsActivation: Bool = false,
        mutatesCommitments: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamTodayBridgeSchemaVersion
    ) -> AmbitionsOSLivingDreamTodayStep {
        AmbitionsOSLivingDreamTodayStep(
            id: id,
            candidateID: candidateID,
            commitmentID: commitmentID,
            title: title,
            kind: kind,
            estimatedMinutes: estimatedMinutes,
            sourceClaimIDs: sourceClaimIDs,
            proofReceiptIDs: proofReceiptIDs,
            closurePromptID: closurePromptID,
            recommendationID: recommendationID,
            allowsActivation: allowsActivation,
            mutatesCommitments: mutatesCommitments,
            usesUserDataServer: usesUserDataServer,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func capacityBridge(
        commitmentProjection: AmbitionsOSCommitmentTimeProjection? = nil
    ) -> AmbitionsOSLivingDreamCapacityBridge {
        AmbitionsOSLivingDreamCapacityBridge(
            id: "capacity-bridge",
            pathPortfolio: pathPortfolio(),
            commitmentProjection: commitmentProjection ?? self.commitmentProjection(),
            pathBridges: [
                AmbitionsOSLivingDreamPathCapacityBridge(
                    id: "primary-bridge",
                    candidateID: "primary-path",
                    commitmentIDs: ["primary-step"],
                    proofCommitmentIDs: ["proof-step"],
                    reviewCommitmentIDs: ["review-step"],
                    recoveryCommitmentIDs: ["recovery-step"],
                    minimumCapacityBufferMinutes: 15
                )
            ]
        )
    }

    func commitmentProjection(
        commitments: [AmbitionsOSCommitmentTimeItem]? = nil,
        capacityWindows: [AmbitionsOSCapacityWindow]? = nil
    ) -> AmbitionsOSCommitmentTimeProjection {
        AmbitionsOSCommitmentTimeProjection(
            commitments: commitments ?? [
                commitment(id: "primary-step", durationMinutes: 30),
                commitment(id: "proof-step", kind: .reviewWindow, durationMinutes: 5),
                commitment(id: "review-step", kind: .reviewWindow, durationMinutes: 5),
                commitment(id: "recovery-step", kind: .recovery, durationMinutes: 5)
            ],
            capacityWindows: capacityWindows ?? [capacityWindow(availableMinutes: 90)]
        )
    }

    func commitment(
        id: String,
        kind: AmbitionsOSCommitmentTimeKind = .step,
        durationMinutes: Int
    ) -> AmbitionsOSCommitmentTimeItem {
        AmbitionsOSCommitmentTimeItem(
            id: id,
            title: "Review the next step",
            kind: kind,
            durationMinutes: durationMinutes,
            flexibility: .movableSameDay
        )
    }

    func capacityWindow(availableMinutes: Int) -> AmbitionsOSCapacityWindow {
        AmbitionsOSCapacityWindow(
            id: "open-window",
            title: "Open capacity",
            availableMinutes: availableMinutes
        )
    }

    func pathPortfolio() -> AmbitionsOSLivingDreamPathPortfolio {
        AmbitionsOSLivingDreamPathPortfolio(
            id: "path-portfolio",
            intakeEvaluation: AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation(
                packetID: "intake",
                requiredQuestionIDs: ["availability"],
                answeredQuestionIDs: ["availability"],
                blockedQuestionIDs: [],
                issues: [],
                storesUserData: false,
                mutatesCommitments: false,
                projectsExternally: false
            ),
            sourceClaimGraph: sourceClaimGraph(),
            northStarOutcome: AmbitionsOSLivingDreamNorthStarOutcome(
                id: "north-star",
                requestID: "north-star-request",
                literalHandling: .meaningOnly,
                meaningStatement: "Build a safe, source-backed life direction.",
                dimensions: [.impact],
                safeAlternativeSeeds: ["small proof step"],
                blockedLiteralSummary: "No literal guarantee."
            ),
            candidates: [
                pathCandidate(id: "primary-path", kind: .primary),
                pathCandidate(id: "conservative-path", kind: .conservative, riskPosture: .low),
                pathCandidate(id: "fallback-path", kind: .fallback)
            ]
        )
    }

    func pathCandidate(
        id: String,
        kind: AmbitionsOSLivingDreamPathKind,
        riskPosture: AmbitionsOSLivingDreamPathRiskPosture = .measured
    ) -> AmbitionsOSLivingDreamPathCandidate {
        AmbitionsOSLivingDreamPathCandidate(
            id: id,
            kind: kind,
            title: "Candidate path",
            summary: "A reviewed local candidate path.",
            handlingLane: .sourceBackedPlan,
            sourceClaimIDs: ["claim-ready"],
            requirementIDs: ["requirement-ready"],
            firstProofStep: "Collect one proof point before committing.",
            riskPosture: riskPosture
        )
    }

    func sourceClaimGraph() -> AmbitionsOSLivingDreamSourceClaimGraph {
        AmbitionsOSLivingDreamSourceClaimGraph(
            claims: [
                AmbitionsOSLivingDreamSourceClaim(
                    id: "claim-ready",
                    claimType: .requirement,
                    value: "One proof point should be collected before commitment.",
                    jurisdiction: "general",
                    authorityLevel: .maintainerCurated,
                    sourceRefIDs: ["source-ready"],
                    sourceState: .sourceBacked,
                    freshnessPolicy: AmbitionsOSLivingDreamFreshnessPolicy(reviewIntervalDays: 90),
                    freshnessState: .current,
                    lastVerified: "2026-05-07",
                    effectiveDate: "2026-05-07",
                    claimQualityState: .reviewed,
                    riskClass: .lowRiskSkill,
                    reviewState: .ready
                )
            ],
            sourceRefs: [
                AmbitionsOSLivingDreamSourceClaimReference(
                    id: "source-ready",
                    title: "Maintainer reviewed local fixture",
                    kind: .maintainerCurated,
                    locator: "local-fixture://ldi13/source-ready",
                    retrievedAt: "2026-05-07",
                    reviewState: .ready
                )
            ]
        )
    }

    func startHere(
        sourceClaims: [AmbitionsOSSourceTruthClaim]? = nil,
        proofTrustReceipts: [AmbitionsOSProofTrustReceipt]? = nil,
        controlActions: [AmbitionsOSStartHereControlAction] = [.start, .open, .adjust],
        usesGenericPriorityOnly: Bool = false,
        exposesConfidenceScore: Bool = false,
        claimsGuaranteedOutcome: Bool = false,
        surfaceLanguageSamples: [String] = ["Start here"]
    ) -> AmbitionsOSStartHereRecommendation {
        AmbitionsOSStartHereRecommendation(
            id: "start-here-1",
            title: "Collect one proof point",
            kind: .startHere,
            surface: .today,
            recommendedObjectID: "primary-step",
            sourceLabel: "Based on your reviewed path",
            sourceClaims: sourceClaims ?? [sourceTruthClaim()],
            proofTrustReceipts: proofTrustReceipts ?? [proofReceipt()],
            controlClassification: AmbitionsOSControlPlaneClassification(
                id: "classification-1",
                requestID: "request-1",
                workClass: .interactive,
                disposition: .allowLocalWork,
                requiredGates: [],
                allowedOutputs: [.recommendation, .reviewRequest],
                rationaleIDs: ["ready_today_bridge"]
            ),
            fitState: .fits,
            whyNow: ["You have a reviewed path and enough open capacity."],
            advances: ["Moves the path with one proof point."],
            protects: ["Keeps closure and recovery visible."],
            assumptions: ["Duration stays reviewable."],
            controlActions: controlActions,
            exposesConfidenceScore: exposesConfidenceScore,
            usesGenericPriorityOnly: usesGenericPriorityOnly,
            claimsGuaranteedOutcome: claimsGuaranteedOutcome,
            surfaceLanguageSamples: surfaceLanguageSamples
        )
    }

    func sourceTruthClaim(
        state: AmbitionsOSSourceTruthClaimState = .officialSourceBacked,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready
    ) -> AmbitionsOSSourceTruthClaim {
        AmbitionsOSSourceTruthClaim(
            id: "claim-1",
            text: "The step is grounded in the user's reviewed path.",
            scopeID: "primary-path",
            state: state,
            sourceQualityState: .official,
            freshnessState: freshnessState,
            riskClass: .careerContext,
            sourceIDs: ["source-1"],
            sourcePackIDs: ["pack-1"],
            reviewState: reviewState,
            lastReviewedAt: "2026-05-07T15:55:00Z"
        )
    }

    func closurePrompt() -> AmbitionsOSClosurePromptContract {
        AmbitionsOSClosurePromptContract(promptID: "closure-prompt")
    }

    func proofReceipt(
        actionReceiptIDs: [String] = ["action-receipt-1"],
        proofReferenceIDs: [String] = ["proof-1"],
        sourceState: HumanProgressSourceState = .sourceBacked,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready
    ) -> AmbitionsOSProofTrustReceipt {
        AmbitionsOSProofTrustReceipt(
            id: "proof-1",
            kind: .proof,
            surface: .today,
            occurredAt: "2026-05-07T15:55:00Z",
            affectedObjectIDs: ["primary-step"],
            actionReceiptIDs: actionReceiptIDs,
            proofReferenceIDs: proofReferenceIDs,
            sourceClaimIDs: ["claim-1"],
            sourcePackIDs: ["pack-1"],
            changedFactSummaries: ["One proof point is ready for review."],
            closureOutcome: .needsReview,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState
        )
    }
}
