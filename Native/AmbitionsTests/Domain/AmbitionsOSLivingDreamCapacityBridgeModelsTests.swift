import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamCapacityBridgeModelsTests: XCTestCase {
    private let validator = AmbitionsOSLivingDreamCapacityBridgeValidator()

    func testReadyBridgeConnectsPathPortfolioToCommitmentTimeWithoutActivation() throws {
        let bridge = makeBridge()

        let data = try JSONEncoder().encode(bridge)
        let decoded = try JSONDecoder().decode(AmbitionsOSLivingDreamCapacityBridge.self, from: data)
        let evaluation = validator.evaluate(bridge: decoded)

        XCTAssertEqual(evaluation.issues, [])
        XCTAssertEqual(evaluation.readiness, .readyForTodayBridge)
        XCTAssertEqual(evaluation.capacityFit, .fits)
        XCTAssertEqual(evaluation.commitmentIDsByCandidateID["primary-path"], ["primary-step"])
        XCTAssertEqual(evaluation.requestedMinutes, 45)
        XCTAssertEqual(evaluation.availableMinutes, 90)
    }

    func testOverCapacityFantasyScheduleIsBlocked() {
        let bridge = makeBridge(
            commitmentProjection: commitmentProjection(
                commitments: [
                    commitment(id: "primary-step", durationMinutes: 80),
                    commitment(id: "proof-step", kind: .reviewWindow, durationMinutes: 45)
                ],
                capacityWindows: [capacityWindow(availableMinutes: 60)]
            )
        )

        let issues = validator.validate(bridge: bridge)

        XCTAssertTrue(issues.contains(.overCapacityFantasySchedule))
        XCTAssertEqual(validator.evaluate(bridge: bridge).readiness, .blocked)
    }

    func testPathPortfolioReadinessGatesCapacityBridge() {
        let bridge = makeBridge(
            pathPortfolio: pathPortfolio(candidates: [
                pathCandidate(id: "primary-path", kind: .primary)
            ])
        )

        let issues = validator.validate(bridge: bridge)

        XCTAssertTrue(issues.contains(.pathPortfolioNotReady))
        XCTAssertEqual(validator.evaluate(bridge: bridge).readiness, .needsPathReview)
    }

    func testSourceProtectedPrivacyAndRecoveryIssuesRequireReview() {
        let bridge = makeBridge(
            commitmentProjection: commitmentProjection(
                commitments: [
                    commitment(
                        id: "primary-step",
                        kind: .deadline,
                        durationMinutes: 75,
                        sourceState: .sourceNeeded,
                        freshnessState: .staleCritical,
                        reviewState: .needsSourceReview,
                        privacyClass: .sensitive
                    )
                ],
                capacityWindows: [
                    capacityWindow(availableMinutes: 90),
                    capacityWindow(availableMinutes: 15, protected: true)
                ]
            ),
            pathBridges: [
                pathBridge(commitmentIDs: ["primary-step"])
            ]
        )

        let issues = validator.validate(bridge: bridge)

        XCTAssertTrue(issues.contains(.sourceReviewRequired))
        XCTAssertTrue(issues.contains(.staleDeadlineSource))
        XCTAssertTrue(issues.contains(.protectedTimeViolation))
        XCTAssertTrue(issues.contains(.privateProjectionRisk))
        XCTAssertEqual(validator.evaluate(bridge: bridge).readiness, .needsSourceReview)

        let tightBridge = makeBridge(
            commitmentProjection: commitmentProjection(
                commitments: [
                    commitment(id: "primary-step", durationMinutes: 75)
                ],
                capacityWindows: [capacityWindow(availableMinutes: 90)]
            ),
            pathBridges: [
                pathBridge(
                    commitmentIDs: ["primary-step"],
                    recoveryCommitmentIDs: [],
                    minimumCapacityBufferMinutes: 0
                )
            ]
        )

        XCTAssertTrue(validator.validate(bridge: tightBridge).contains(.recoveryBufferMissing))
    }

    func testSilentReschedulePlatformCalendarMutationServerAndRuntimeBlockBridge() {
        let bridge = makeBridge(
            commitmentProjection: commitmentProjection(
                commitments: [
                    commitment(
                        id: "primary-step",
                        kind: .appointment,
                        durationMinutes: 30,
                        flexibility: .fixed,
                        requiresUserReviewBeforeMove: false
                    )
                ],
                capacityWindows: [capacityWindow(availableMinutes: 90)],
                runtimeBoundary: SourceAtlasRuntimeBoundary(
                    storesUserData: true,
                    performsNetworkFetches: false,
                    mutatesPlans: false,
                    writesPersistence: true
                ),
                performsPlatformCalendarWork: true,
                writesScheduleAutomatically: true
            ),
            pathBridges: [
                pathBridge(
                    commitmentIDs: ["primary-step"],
                    allowsActivation: true,
                    mutatesCommitments: true,
                    writesScheduleAutomatically: true,
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

        XCTAssertTrue(issues.contains(.silentRescheduleRisk))
        XCTAssertTrue(issues.contains(.platformCalendarImplementation))
        XCTAssertTrue(issues.contains(.activationForbidden))
        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.userDataServerBoundaryBroken))
        XCTAssertTrue(issues.contains(.runtimeBoundaryBroken))
        XCTAssertEqual(validator.evaluate(bridge: bridge).readiness, .blocked)
    }

    func testMalformedUnknownCandidateAndUnsupportedSchemaAreReported() {
        let bridge = makeBridge(
            id: "",
            pathBridges: [
                pathBridge(
                    id: "",
                    candidateID: "unknown-path",
                    commitmentIDs: ["missing"],
                    minimumCapacityBufferMinutes: -1,
                    schemaVersion: "old"
                )
            ],
            schemaVersion: "old"
        )

        let issues = validator.validate(bridge: bridge)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedBridge))
        XCTAssertTrue(issues.contains(.unknownCandidateID))
        XCTAssertTrue(issues.contains(.missingCommitmentForCandidate))
    }
}

private extension AmbitionsOSLivingDreamCapacityBridgeModelsTests {
    func makeBridge(
        id: String = "capacity-bridge",
        pathPortfolio: AmbitionsOSLivingDreamPathPortfolio? = nil,
        commitmentProjection: AmbitionsOSCommitmentTimeProjection? = nil,
        pathBridges: [AmbitionsOSLivingDreamPathCapacityBridge]? = nil,
        allowsActivation: Bool = false,
        mutatesCommitments: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamCapacityBridgeSchemaVersion
    ) -> AmbitionsOSLivingDreamCapacityBridge {
        AmbitionsOSLivingDreamCapacityBridge(
            id: id,
            pathPortfolio: pathPortfolio ?? self.pathPortfolio(),
            commitmentProjection: commitmentProjection ?? self.commitmentProjection(),
            pathBridges: pathBridges ?? [pathBridge()],
            allowsActivation: allowsActivation,
            mutatesCommitments: mutatesCommitments,
            usesUserDataServer: usesUserDataServer,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func pathBridge(
        id: String = "primary-bridge",
        candidateID: String = "primary-path",
        commitmentIDs: [String] = ["primary-step"],
        proofCommitmentIDs: [String] = ["proof-step"],
        reviewCommitmentIDs: [String] = ["review-step"],
        recoveryCommitmentIDs: [String] = ["recovery-step"],
        minimumCapacityBufferMinutes: Int = 15,
        allowsActivation: Bool = false,
        mutatesCommitments: Bool = false,
        writesScheduleAutomatically: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamCapacityBridgeSchemaVersion
    ) -> AmbitionsOSLivingDreamPathCapacityBridge {
        AmbitionsOSLivingDreamPathCapacityBridge(
            id: id,
            candidateID: candidateID,
            commitmentIDs: commitmentIDs,
            proofCommitmentIDs: proofCommitmentIDs,
            reviewCommitmentIDs: reviewCommitmentIDs,
            recoveryCommitmentIDs: recoveryCommitmentIDs,
            minimumCapacityBufferMinutes: minimumCapacityBufferMinutes,
            allowsActivation: allowsActivation,
            mutatesCommitments: mutatesCommitments,
            writesScheduleAutomatically: writesScheduleAutomatically,
            usesUserDataServer: usesUserDataServer,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func commitmentProjection(
        commitments: [AmbitionsOSCommitmentTimeItem]? = nil,
        capacityWindows: [AmbitionsOSCapacityWindow]? = nil,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        performsPlatformCalendarWork: Bool = false,
        writesScheduleAutomatically: Bool = false
    ) -> AmbitionsOSCommitmentTimeProjection {
        AmbitionsOSCommitmentTimeProjection(
            commitments: commitments ?? [
                commitment(id: "primary-step", durationMinutes: 30),
                commitment(id: "proof-step", kind: .reviewWindow, durationMinutes: 5),
                commitment(id: "review-step", kind: .reviewWindow, durationMinutes: 5),
                commitment(id: "recovery-step", kind: .recovery, durationMinutes: 5)
            ],
            capacityWindows: capacityWindows ?? [capacityWindow(availableMinutes: 90)],
            runtimeBoundary: runtimeBoundary,
            performsPlatformCalendarWork: performsPlatformCalendarWork,
            writesScheduleAutomatically: writesScheduleAutomatically
        )
    }

    func commitment(
        id: String,
        kind: AmbitionsOSCommitmentTimeKind = .step,
        durationMinutes: Int,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        flexibility: AmbitionsOSCommitmentFlexibility = .movableSameDay,
        requiresUserReviewBeforeMove: Bool = true
    ) -> AmbitionsOSCommitmentTimeItem {
        AmbitionsOSCommitmentTimeItem(
            id: id,
            title: "Review capacity fit",
            kind: kind,
            durationMinutes: durationMinutes,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            flexibility: flexibility,
            requiresUserReviewBeforeMove: requiresUserReviewBeforeMove
        )
    }

    func capacityWindow(
        availableMinutes: Int,
        protected: Bool = false
    ) -> AmbitionsOSCapacityWindow {
        AmbitionsOSCapacityWindow(
            id: protected ? "protected-window" : "open-window",
            title: protected ? "Protected time" : "Open capacity",
            availableMinutes: availableMinutes,
            protected: protected
        )
    }

    func pathPortfolio(
        candidates: [AmbitionsOSLivingDreamPathCandidate]? = nil
    ) -> AmbitionsOSLivingDreamPathPortfolio {
        AmbitionsOSLivingDreamPathPortfolio(
            id: "path-portfolio",
            intakeEvaluation: readyIntakeEvaluation(),
            sourceClaimGraph: sourceClaimGraph(),
            northStarOutcome: safeNorthStarOutcome(),
            candidates: candidates ?? [
                pathCandidate(id: "primary-path", kind: .primary),
                pathCandidate(id: "conservative-path", kind: .conservative, riskPosture: .low),
                pathCandidate(id: "fallback-path", kind: .fallback, riskPosture: .measured)
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

    func readyIntakeEvaluation() -> AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation {
        AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation(
            packetID: "intake",
            requiredQuestionIDs: ["availability"],
            answeredQuestionIDs: ["availability"],
            blockedQuestionIDs: [],
            issues: [],
            storesUserData: false,
            mutatesCommitments: false,
            projectsExternally: false
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
                    locator: "local-fixture://ldi12/source-ready",
                    retrievedAt: "2026-05-07",
                    reviewState: .ready
                )
            ]
        )
    }

    func safeNorthStarOutcome() -> AmbitionsOSLivingDreamNorthStarOutcome {
        AmbitionsOSLivingDreamNorthStarOutcome(
            id: "north-star",
            requestID: "north-star-request",
            literalHandling: .meaningOnly,
            meaningStatement: "Build a safe, source-backed life direction.",
            dimensions: [.impact],
            safeAlternativeSeeds: ["small proof step"],
            blockedLiteralSummary: "No literal guarantee."
        )
    }
}
