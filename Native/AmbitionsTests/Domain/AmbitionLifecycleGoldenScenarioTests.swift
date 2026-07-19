import XCTest
@testable import Ambitions

final class AmbitionLifecycleGoldenScenarioTests: XCTestCase {
    func testGoalToLifeDirectionLoopCarriesTheAmbitionLifecycleChain() {
        let scenario = makeGoldenScenario()
        let store = AmbitionGraphProjectionStore(snapshots: [scenario.snapshot])

        let loop = store.crossSurfaceLoop(
            for: scenario.snapshot,
            generatedAt: "2026-05-13T02:22:20Z",
            id: "mri08-ambition-lifecycle-loop",
            projectionIDPrefix: "mri08"
        )

        XCTAssertTrue(loop.localProjectionOnly)
        XCTAssertTrue(loop.connectsEveryCanonicalSurface)
        XCTAssertTrue(loop.carriesGoalToLifeDirectionContext)
        XCTAssertEqual(loop.coveredSurfaces, [.today, .goals, .capture, .time, .you])
        XCTAssertEqual(scenario.snapshot.ambition.lifeAreaID, scenario.lifeAreaID)
        XCTAssertEqual(loop.identityDirectionIDs, [scenario.identityDirection.id])
        XCTAssertEqual(loop.outcomeIDs, [scenario.outcome.id])
        XCTAssertEqual(loop.commitmentIDs, [scenario.blockedCommitment.id, scenario.promiseCommitment.id])
        XCTAssertEqual(loop.stepIDs, [scenario.step.id, scenario.reentryStep.id])
        XCTAssertEqual(loop.closureEventIDs, [scenario.closure.id])
        XCTAssertEqual(loop.proofIDs, [scenario.proof.id])
        XCTAssertEqual(loop.recoveryThreadIDs, [scenario.recovery.id])
        XCTAssertEqual(loop.recommendationTraceIDs, [scenario.recommendationTrace.id])
        XCTAssertEqual(scenario.reflection.proofID, scenario.proof.id)
        XCTAssertEqual(scenario.reflection.closureEventID, scenario.closure.id)
        XCTAssertEqual(scenario.adaptation.triggerProofID, scenario.proof.id)
        XCTAssertEqual(scenario.adaptation.sourceThreadID, "thread-health")
        XCTAssertEqual(scenario.adaptation.resultingCommitmentID, scenario.blockedCommitment.id)
    }

    func testBlockedCommitmentCreatesNonShamingRecoveryAndPreservesValidProof() {
        let scenario = makeGoldenScenario()
        let transition = AmbitionClosureState.blocked.transition(hasProof: true)

        XCTAssertEqual(transition.nextCommitmentStatus, .blocked)
        XCTAssertTrue(transition.preservesProof)
        XCTAssertTrue(transition.shouldCreateRecoveryThread)
        XCTAssertTrue(transition.allowsReentry)
        XCTAssertEqual(scenario.recovery.status, .active)
        XCTAssertEqual(scenario.recovery.priorProofRefs, [scenario.proof.id])
        XCTAssertEqual(scenario.recovery.preservedProofRefs, [scenario.proof.id])
        XCTAssertEqual(scenario.recovery.lastHonestPoint?.commitmentID, scenario.promiseCommitment.id)
        XCTAssertEqual(scenario.recovery.lastHonestPoint?.closureEventID, scenario.closure.id)
        XCTAssertEqual(scenario.recovery.reentryStep?.stepID, scenario.reentryStep.id)
        XCTAssertTrue(scenario.recovery.hasReentryStep)
        XCTAssertTrue(scenario.recovery.isReceiptReady)

        assertDoesNotContainForbiddenLanguage([
            scenario.closure.closureState.displayLabel,
            scenario.closure.reason ?? "",
            scenario.closure.followUpPlan ?? "",
            scenario.recovery.trigger,
            scenario.recovery.whatChanged ?? "",
            scenario.recovery.reentryStep?.title ?? "",
            scenario.recovery.reentryStep?.reason ?? ""
        ])
    }

    func testPivotProofTransferSeparatesPreservedReviewRequiredAndNonTransferableProof() {
        let sourceStep = object(.step, "step-current", parent: "thread-health", label: "Current path step", sourceDomain: .goals)
        let pivotStep = object(.step, "step-pivot", parent: "thread-health", label: "Pivot path step", sourceDomain: .goals)

        let preserved = proofReference(
            id: "proof-preserved",
            attachedObject: sourceStep,
            profile: ProofCapitalProfile(
                sourceKind: .actionReceipt,
                sourceState: .sourceBacked,
                freshnessState: .current,
                contradictionState: .none,
                evidence: .init(
                    anchorObjectIDs: [pivotStep.stableKey],
                    proofReferenceIDs: ["proof-input-preserved"],
                    sourceReceiptIDs: ["receipt-preserved"]
                )
            )
        )
        let reviewRequired = proofReference(
            id: "proof-review-required",
            attachedObject: sourceStep,
            profile: ProofCapitalProfile(
                sourceKind: .manual,
                sourceState: .userConfirmed,
                freshnessState: .stale,
                contradictionState: .none,
                evidence: .init(
                    anchorObjectIDs: [pivotStep.stableKey],
                    sourceReceiptIDs: ["receipt-review"]
                )
            )
        )
        let nonTransferable = proofReference(
            id: "proof-non-transferable",
            attachedObject: sourceStep,
            profile: ProofCapitalProfile(
                sourceKind: .correction,
                sourceState: .sourceBacked,
                freshnessState: .current,
                contradictionState: .confirmed,
                evidence: .init(
                    anchorObjectIDs: [pivotStep.stableKey],
                    proofReferenceIDs: ["proof-input-blocked"]
                )
            )
        )

        let report = ProofResourceGraphProjection(
            proofReferences: [preserved, reviewRequired, nonTransferable]
        ).evaluatePivotPreservation(from: sourceStep, to: pivotStep)

        XCTAssertEqual(report.preservedProofIDs, ["proof-preserved"])
        XCTAssertEqual(report.reviewRequiredProofIDs, ["proof-review-required"])
        XCTAssertEqual(report.nonTransferableProofIDs, ["proof-non-transferable"])
        XCTAssertEqual(report.transferRecords.first(where: { $0.proofID == "proof-preserved" })?.outcome, .preserved)
        XCTAssertEqual(report.transferRecords.first(where: { $0.proofID == "proof-review-required" })?.issues, [.staleNeedsReview])
        XCTAssertEqual(report.transferRecords.first(where: { $0.proofID == "proof-non-transferable" })?.issues, [.contradictionConfirmed])
    }

    func testReflectionAdaptationCanInformRecommendationsOnlyWhenLocalVisibleReceiptedAndNonMutating() {
        let validator = AmbitionsOSAdaptationValidator()
        let valid = reflectionRecord()

        XCTAssertTrue(valid.canInformFutureRecommendations)
        XCTAssertEqual(validator.validate(valid), [])
        XCTAssertTrue(valid.localOnly)
        XCTAssertTrue(valid.userVisible)
        XCTAssertTrue(valid.deterministic)
        XCTAssertFalse(valid.requiresModelToApply)
        XCTAssertFalse(valid.mutatesAutomatically)
        XCTAssertTrue(valid.runtimeBoundary.isValueModelOnly)
        XCTAssertFalse(valid.receiptIDs.isEmpty)
        XCTAssertFalse(valid.controlActions.isEmpty)
        assertDoesNotContainForbiddenLanguage(valid.surfaceLanguageSamples)

        let hiddenMutation = reflectionRecord(
            id: "reflection-hidden-mutation",
            localOnly: false,
            deterministic: false,
            requiresModelToApply: true,
            mutatesAutomatically: true,
            receiptIDs: [],
            controlActions: [],
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            ),
            surfaceLanguageSamples: ["Assistant says this is guaranteed fit."]
        )
        let issues = validator.validate(hiddenMutation)

        XCTAssertFalse(hiddenMutation.canInformFutureRecommendations)
        XCTAssertTrue(issues.contains(.hiddenReflection))
        XCTAssertTrue(issues.contains(.reflectionMissingReceipt))
        XCTAssertTrue(issues.contains(.missingControlAction))
        XCTAssertTrue(issues.contains(.modelRequiredPath))
        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
        XCTAssertTrue(issues.contains(.forbiddenLanguage))
    }

    func testCrossSurfaceLoopRemainsLocalOnlyAndKeepsCanonicalSurfaces() {
        let scenario = makeGoldenScenario()
        let store = AmbitionGraphProjectionStore(snapshots: [scenario.snapshot])

        let projections = store.projections(
            for: scenario.snapshot,
            generatedAt: "2026-05-13T02:22:20Z",
            idPrefix: "mri08"
        )

        XCTAssertEqual(projections.map(\.surface), [.today, .goals, .capture, .time, .you])
        XCTAssertEqual(AmbitionGraphProjectionSurface.allCases.map(\.rawValue), ["today", "goals", "capture", "time", "you"])
        XCTAssertFalse(AmbitionGraphProjectionSurface.allCases.map(\.rawValue).contains("plan"))
        XCTAssertFalse(AmbitionGraphProjectionSurface.allCases.map(\.rawValue).contains("tasks"))
        XCTAssertEqual(projections.count, 5)
        XCTAssertTrue(projections.allSatisfy(\.localProjectionOnly))
        XCTAssertTrue(projections.allSatisfy { $0.privacyClasses.contains(.privateUserText) })

        let allSourceText = projections.flatMap(\.sourceFields) + scenario.recommendationTrace.reasonCodes
        assertDoesNotContainForbiddenLanguage(allSourceText)
        assertDoesNotContainHostedDependencyClaim(allSourceText)
    }
}

private extension AmbitionLifecycleGoldenScenarioTests {
    struct GoldenScenario {
        let lifeAreaID: String
        let identityDirection: IdentityDirection
        let outcome: Outcome
        let promiseCommitment: Commitment
        let blockedCommitment: Commitment
        let step: AmbitionGraphStep
        let reentryStep: AmbitionGraphStep
        let closure: ClosureEvent
        let proof: Proof
        let reflection: Reflection
        let adaptation: AdaptationPivot
        let recovery: RecoveryThread
        let recommendationTrace: AmbitionGraphRecommendationTrace
        let snapshot: AmbitionGraphSnapshot
    }

    func makeGoldenScenario() -> GoldenScenario {
        let ambitionID = "ambition-health-continuity"
        let lifeAreaID = "life-area-health"
        let identity = IdentityDirection(
            id: "identity-direction-stable-health",
            ambitionID: ambitionID,
            title: "Steady health direction",
            statement: "Keep health commitments realistic and proof-backed.",
            priority: .primary,
            createdAt: "2026-05-13T02:00:00Z",
            updatedAt: "2026-05-13T02:00:00Z"
        )
        let outcome = Outcome(
            id: "outcome-morning-recovery",
            ambitionID: ambitionID,
            identityDirectionID: identity.id,
            goalThreadID: "thread-health",
            title: "Morning recovery routine fits real capacity",
            kind: .behavior,
            isPrimary: true,
            createdAt: "2026-05-13T02:01:00Z",
            updatedAt: "2026-05-13T02:01:00Z"
        )
        let ambition = Ambition(
            id: ambitionID,
            title: "Build a durable health rhythm",
            identityStatement: "I keep promises by matching them to reality.",
            lifeAreaID: lifeAreaID,
            desiredOutcome: outcome.title,
            desiredProofDescription: "A checked-in routine with a preserved proof trail.",
            activeGoalThreadID: "thread-health",
            activeCommitmentID: "commitment-blocked",
            knownConstraintIDs: ["constraint-energy"],
            recoveryPolicy: "Recover from the last honest point and keep valid proof.",
            privacyClass: .privateUserText,
            createdAt: "2026-05-13T02:02:00Z",
            updatedAt: "2026-05-13T02:02:00Z"
        )
        let step = AmbitionGraphStep(
            id: "step-first-check-in",
            ambitionID: ambitionID,
            goalThreadID: "thread-health",
            outcomeID: outcome.id,
            name: "Complete the first check-in",
            targetOrder: 1,
            expectedEffortMinutes: 20,
            createdAt: "2026-05-13T02:03:00Z",
            updatedAt: "2026-05-13T02:03:00Z"
        )
        let reentryStep = AmbitionGraphStep(
            id: "step-small-reentry",
            ambitionID: ambitionID,
            goalThreadID: "thread-health",
            outcomeID: outcome.id,
            name: "Restart with a five minute version",
            targetOrder: 2,
            expectedEffortMinutes: 5,
            createdAt: "2026-05-13T02:04:00Z",
            updatedAt: "2026-05-13T02:04:00Z"
        )
        let promiseCommitment = Commitment(
            id: "commitment-promised",
            ambitionID: ambitionID,
            goalThreadID: "thread-health",
            stepID: step.id,
            promisedFor: "2026-05-13T13:00:00Z",
            expectedEffort: "20m",
            minimumProofDescription: "Manual check-in note.",
            fitReason: "Morning capacity usually fits this step.",
            recoveryPolicy: "Shorten before abandoning.",
            status: .promised,
            createdAt: "2026-05-13T02:05:00Z",
            updatedAt: "2026-05-13T02:05:00Z"
        )
        let blockedCommitment = Commitment(
            id: "commitment-blocked",
            ambitionID: ambitionID,
            goalThreadID: "thread-health",
            stepID: reentryStep.id,
            promisedFor: "2026-05-13T15:00:00Z",
            expectedEffort: "5m",
            minimumProofDescription: "Preserve the check-in proof and restart small.",
            fitReason: "A smaller re-entry fits after interruption.",
            recoveryPolicy: "Use Still Counts or Needs Recovery language.",
            status: .blocked,
            createdAt: "2026-05-13T02:06:00Z",
            updatedAt: "2026-05-13T02:06:00Z"
        )
        let proof = Proof(
            id: "proof-check-in",
            ambitionID: ambitionID,
            goalThreadID: "thread-health",
            commitmentID: promiseCommitment.id,
            closureEventID: "closure-blocked",
            proofType: .text,
            text: "Started the check-in and recorded the useful part.",
            source: "local closure receipt",
            privacyClass: .privateProof,
            userConfirmed: true,
            transferPolicy: "Preserve valid proof through recovery and pivot review.",
            createdAt: "2026-05-13T02:07:00Z"
        )
        let closure = ClosureEvent(
            id: "closure-blocked",
            ambitionID: ambitionID,
            goalThreadID: "thread-health",
            ambitionGraphStepID: step.id,
            commitmentID: promiseCommitment.id,
            proofID: proof.id,
            closureState: .blocked,
            reason: "Reality changed before the full step could finish.",
            followUpPlan: "Keep the useful proof and offer a smaller re-entry.",
            createdAt: "2026-05-13T02:08:00Z"
        )
        let recovery = RecoveryThread(
            id: "recovery-health-reentry",
            ambitionID: ambitionID,
            trigger: "Reality changed during the commitment.",
            priorProofRefs: [proof.id],
            lastHonestPoint: RecoveryLastHonestPoint(
                commitmentID: promiseCommitment.id,
                closureEventID: closure.id,
                stepID: step.id,
                summary: "The first useful check-in was started and recorded.",
                capturedAt: "2026-05-13T02:09:00Z"
            ),
            reentryStep: RecoveryReentryStep(
                id: "reentry-small-version",
                commitmentID: blockedCommitment.id,
                stepID: reentryStep.id,
                title: "Restart with the five minute version",
                reason: "Preserves continuity while reducing effort.",
                estimatedEffortMinutes: 5
            ),
            receiptBehavior: .preserveExistingReceipt,
            whatChanged: "The next commitment became smaller and reviewable.",
            newSmallestCommitment: "Five minute check-in",
            status: .active,
            receiptID: "receipt-recovery",
            createdAt: "2026-05-13T02:10:00Z",
            updatedAt: "2026-05-13T02:10:00Z"
        )
        let reflection = Reflection(
            id: "reflection-recovery-fit",
            ambitionID: ambitionID,
            proofID: proof.id,
            closureEventID: closure.id,
            text: "Small re-entry preserved the useful part.",
            learnedSignal: "After interruption, offer a shorter recovery step.",
            createdAt: "2026-05-13T02:11:00Z"
        )
        let adaptation = AdaptationPivot(
            id: "adaptation-shorter-reentry",
            ambitionID: ambitionID,
            triggerProofID: proof.id,
            sourceThreadID: "thread-health",
            proposedChange: "Use shorter recovery commitments after similar interruptions.",
            resultingCommitmentID: blockedCommitment.id,
            createdAt: "2026-05-13T02:12:00Z",
            updatedAt: "2026-05-13T02:12:00Z"
        )
        let recommendationTrace = AmbitionGraphRecommendationTrace(
            id: "trace-reentry",
            recommendedObjectID: blockedCommitment.id,
            sourceRefs: [proof.id, reflection.id],
            reasonCodes: ["proof-preserved", "recovery-fit", "user-controlled"],
            uncertainty: 0.25,
            userAction: .openStep,
            createdAt: "2026-05-13T02:13:00Z",
            isAiCopySuppressed: true,
            sourceLabels: ["local proof", "visible reflection"]
        )
        let constraint = Constraint(
            id: "constraint-energy",
            ambitionID: ambitionID,
            label: "Energy changed",
            patternDescription: "Morning capacity changed after interruption.",
            patternType: .energyDemand,
            evidenceCount: 1,
            lastObservedAt: "2026-05-13T02:14:00Z",
            userConfirmed: true,
            mitigation: "Prefer a smaller re-entry step.",
            privacyClass: .privateConstraint,
            createdAt: "2026-05-13T02:14:00Z",
            updatedAt: "2026-05-13T02:14:00Z"
        )
        let snapshot = AmbitionGraphSnapshot(
            id: "snapshot-mri08-lifecycle",
            ambition: ambition,
            commitments: [promiseCommitment, blockedCommitment],
            proofs: [proof],
            constraints: [constraint],
            recoveryThreads: [recovery],
            recommendationTraces: [recommendationTrace],
            identityDirections: [identity],
            outcomes: [outcome],
            steps: [step, reentryStep],
            closureEvents: [closure]
        )

        return GoldenScenario(
            lifeAreaID: lifeAreaID,
            identityDirection: identity,
            outcome: outcome,
            promiseCommitment: promiseCommitment,
            blockedCommitment: blockedCommitment,
            step: step,
            reentryStep: reentryStep,
            closure: closure,
            proof: proof,
            reflection: reflection,
            adaptation: adaptation,
            recovery: recovery,
            recommendationTrace: recommendationTrace,
            snapshot: snapshot
        )
    }

    func proofReference(
        id: String,
        attachedObject: LifeGraphObjectReference,
        profile: ProofCapitalProfile
    ) -> ProofReference {
        ProofReference(
            id: id,
            kind: .completedAction,
            title: id,
            attachedObject: attachedObject,
            occurredAt: "2026-05-13T02:15:00Z",
            strength: .supporting,
            sourceDomain: .proof,
            capitalProfile: profile
        )
    }

    func reflectionRecord(
        id: String = "reflection-recovery-learning",
        localOnly: Bool = true,
        userVisible: Bool = true,
        deterministic: Bool = true,
        deterministicFallbackAvailable: Bool = true,
        requiresModelToApply: Bool = false,
        mutatesAutomatically: Bool = false,
        receiptIDs: [String] = ["receipt-reflection"],
        controlActions: [String] = ["disable", "reset", "review"],
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = ["You can review, reset, or disable this local learning."]
    ) -> AmbitionsOSReflectionAdaptationRecord {
        AmbitionsOSReflectionAdaptationRecord(
            id: id,
            sourceObjectID: "recovery-health-reentry",
            surface: .you,
            kind: .recoveryLearning,
            intent: .futureRecommendationInput,
            summary: "Shorter re-entry helped after the commitment was blocked.",
            recommendationInfluenceSummary: "Prefer smaller re-entry steps after similar recovery signals.",
            dimensions: [.capacity, .recovery],
            userVisible: userVisible,
            localOnly: localOnly,
            deterministic: deterministic,
            deterministicFallbackAvailable: deterministicFallbackAvailable,
            requiresModelToApply: requiresModelToApply,
            mutatesAutomatically: mutatesAutomatically,
            receiptIDs: receiptIDs,
            controlActions: controlActions,
            privacyClass: .privateLife,
            reviewState: .ready,
            runtimeBoundary: runtimeBoundary,
            surfaceLanguageSamples: surfaceLanguageSamples
        )
    }

    func object(
        _ kind: LifeGraphObjectKind,
        _ id: String,
        parent: String? = nil,
        label: String,
        sourceDomain: LifeGraphSourceDomain? = nil
    ) -> LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: kind,
            id: id,
            parentContextID: parent,
            label: label,
            sourceDomain: sourceDomain
        )
    }

    func assertDoesNotContainForbiddenLanguage(
        _ samples: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let forbiddenTerms = [
            "ai confidence",
            "model confidence",
            "confidence percentage",
            "best next move",
            "recommended step",
            "overdue",
            "failed",
            "streak broken",
            "productivity dropped",
            "productivity score",
            "shame",
            "chatbot",
            "chat transcript"
        ]
        let text = samples.joined(separator: " ").lowercased()
        for term in forbiddenTerms {
            XCTAssertFalse(text.contains(term), "Forbidden language found: \(term)", file: file, line: line)
        }
    }

    func assertDoesNotContainHostedDependencyClaim(
        _ samples: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let forbiddenClaims = [
            "hosted backend",
            "cloud llm",
            "server profile",
            "remote model",
            "external model"
        ]
        let text = samples.joined(separator: " ").lowercased()
        for claim in forbiddenClaims {
            XCTAssertFalse(text.contains(claim), "Forbidden dependency claim found: \(claim)", file: file, line: line)
        }
    }
}
