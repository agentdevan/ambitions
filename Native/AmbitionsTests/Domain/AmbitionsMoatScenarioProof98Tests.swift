import CryptoKit
import Foundation
import XCTest
@testable import Ambitions

final class AmbitionsMoatScenarioProof98Tests: XCTestCase {
    func testSameIntentDifferentLocalContextsProduceDifferentStartHereProofAndReplayStable() throws {
        let exporter = MoatScenarioProofExporter()
        let intent = MoatScenarioIntent(
            id: "intent.health-consistency",
            text: "Improve health consistency while maintaining work and relationship commitments."
        )
        let proofDirectory = exporter.proofDirectoryURL()
        let contextA = try buildContext(
            identifier: "context-a",
            intent: intent,
            scenario: .contextA
        )
        let contextAReplay = try buildContext(
            identifier: "context-a",
            intent: intent,
            scenario: .contextA
        )
        let contextB = try buildContext(
            identifier: "context-b",
            intent: intent,
            scenario: .contextB
        )
        let contextBReplay = try buildContext(
            identifier: "context-b",
            intent: intent,
            scenario: .contextB
        )

        let diffSummary = MoatScenarioDiffSummary(
            sameIntent: contextA.intent.id == contextB.intent.id && contextA.intent.text == contextB.intent.text,
            differentContext: contextA.localContext != contextB.localContext,
            differentRecommendation: contextA.meridian.primaryActionTitle != contextB.meridian.primaryActionTitle ||
                contextA.meridian.heroTitle != contextB.meridian.heroTitle,
            protectedTimeRespected: contextB.reality.availability.protectedWindowCount > 0 &&
                contextB.reality.availability.openWindowCount == 0 &&
                contextB.startHereRecommendation.kind == .recovery,
            localOnlyBoundaryPassed: contextA.localOnlyBoundary.isLocalOnly &&
                contextB.localOnlyBoundary.isLocalOnly &&
                contextA.reality.localOnly &&
                contextB.reality.localOnly &&
                contextA.startHereRecommendation.runtimeBoundary.isValueModelOnly &&
                contextB.startHereRecommendation.runtimeBoundary.isValueModelOnly,
            receiptPresent: contextA.startHereRecommendation.proofTrustReceipts.isEmpty == false &&
                contextB.startHereRecommendation.proofTrustReceipts.isEmpty == false,
            freshnessPresent: contextA.sourceClaim.freshnessState == .current &&
                contextB.sourceClaim.freshnessState == .current,
            closureEvidencePresent: contextA.proofTrustReceipt.closureOutcome != nil &&
                contextB.proofTrustReceipt.closureOutcome != nil,
            replayStable: contextA.replayHash == contextAReplay.replayHash &&
                contextB.replayHash == contextBReplay.replayHash &&
                contextA.replayHash == contextAReplay.replayHash &&
                contextB.replayHash == contextBReplay.replayHash
        )

        let replayOutput = MoatScenarioReplayOutput(
            contextA: MoatScenarioReplayPair(
                firstRun: MoatScenarioReplayRun(
                    hash: contextA.replayHash,
                    heroKind: contextA.meridian.heroKind,
                    result: contextA.meridian.primaryActionTitle
                ),
                replayRun: MoatScenarioReplayRun(
                    hash: contextAReplay.replayHash,
                    heroKind: contextAReplay.meridian.heroKind,
                    result: contextAReplay.meridian.primaryActionTitle
                ),
                stable: contextA.replayHash == contextAReplay.replayHash
            ),
            contextB: MoatScenarioReplayPair(
                firstRun: MoatScenarioReplayRun(
                    hash: contextB.replayHash,
                    heroKind: contextB.meridian.heroKind,
                    result: contextB.meridian.primaryActionTitle
                ),
                replayRun: MoatScenarioReplayRun(
                    hash: contextBReplay.replayHash,
                    heroKind: contextBReplay.meridian.heroKind,
                    result: contextBReplay.meridian.primaryActionTitle
                ),
                stable: contextB.replayHash == contextBReplay.replayHash
            ),
            stable: contextA.replayHash == contextAReplay.replayHash && contextB.replayHash == contextBReplay.replayHash
        )
        let explanationDiff = MoatScenarioExplanationDiffArtifact(
            sameIntentID: intent.id,
            contextAWhyNow: contextA.startHereRecommendation.whyNow,
            contextBWhyNow: contextB.startHereRecommendation.whyNow,
            contextAProtects: contextA.startHereRecommendation.protects,
            contextBProtects: contextB.startHereRecommendation.protects,
            contextASourceRecordIDs: contextA.sourceClaim.sourceIDs,
            contextBSourceRecordIDs: contextB.sourceClaim.sourceIDs,
            contextAReceiptIDs: contextA.proofTrustReceipt.actionReceiptIDs,
            contextBReceiptIDs: contextB.proofTrustReceipt.actionReceiptIDs,
            contextAReplayTraceID: "ReplayTrace.moat-scenario.\(intent.id).context-a",
            contextBReplayTraceID: "ReplayTrace.moat-scenario.\(intent.id).context-b",
            contextAReplayHash: contextA.replayHash,
            contextBReplayHash: contextB.replayHash,
            contextACapacityMinutes: contextA.localContext.capacityMinutes,
            contextBCapacityMinutes: contextB.localContext.capacityMinutes,
            protectedTimeDifference: contextA.localContext.protectedRecoveryWindowMinutes != contextB.localContext.protectedRecoveryWindowMinutes,
            recoveryStateDifference: contextA.localContext.recoveryState != contextB.localContext.recoveryState,
            explanationDifferencePresent: contextA.startHereRecommendation.whyNow != contextB.startHereRecommendation.whyNow &&
                contextA.startHereRecommendation.protects != contextB.startHereRecommendation.protects,
            receiptContinuityPresent: contextA.proofTrustReceipt.actionReceiptIDs.isEmpty == false &&
                contextB.proofTrustReceipt.actionReceiptIDs.isEmpty == false,
            replayContinuityPresent: contextA.replayHash == contextAReplay.replayHash &&
                contextB.replayHash == contextBReplay.replayHash
        )

        try exporter.write(
            README: moatsREADME(
                command: exporter.xcodebuildCommand,
                result: diffSummary.replayStable ? "GREEN" : "YELLOW"
            ),
            contextA: contextA,
            contextB: contextB,
            diffSummary: diffSummary,
            privacyBoundaryLog: exporter.privacyBoundaryLog(
                boundary: contextA.localOnlyBoundary,
                runtimeBoundary: contextA.runtimeBoundary
            ),
            replayOutput: replayOutput,
            explanationDiff: explanationDiff
        )

        XCTAssertEqual(contextA.intent.id, intent.id)
        XCTAssertEqual(contextB.intent.id, intent.id)
        XCTAssertEqual(contextA.intent.text, contextB.intent.text)
        XCTAssertNotEqual(contextA.localContext, contextB.localContext)
        XCTAssertNotEqual(contextA.meridian.primaryActionTitle, contextB.meridian.primaryActionTitle)
        XCTAssertGreaterThan(contextA.reality.availability.openWindowCount, 0)
        XCTAssertEqual(contextB.reality.availability.openWindowCount, 0)
        XCTAssertGreaterThan(contextB.reality.availability.protectedWindowCount, 0)
        XCTAssertEqual(contextA.nowState.localOnly, true)
        XCTAssertEqual(contextB.nowState.localOnly, true)
        XCTAssertEqual(PrivateLifeRuntimeBoundary.localOnly.isLocalOnly, true)
        XCTAssertTrue(contextA.startHereRecommendation.isWellFormed)
        XCTAssertTrue(contextB.startHereRecommendation.isWellFormed)
        XCTAssertEqual(AmbitionsOSStartHereRecommendationValidator().validate(contextA.startHereRecommendation), [])
        XCTAssertEqual(AmbitionsOSStartHereRecommendationValidator().validate(contextB.startHereRecommendation), [])
        XCTAssertTrue(contextA.proofTrustReceipt.canCloseProofTrustGate)
        XCTAssertTrue(contextB.proofTrustReceipt.canCloseProofTrustGate)
        XCTAssertEqual(contextA.startHereTrace.recommendationID, contextA.startHereRecommendation.id)
        XCTAssertEqual(contextB.startHereTrace.recommendationID, contextB.startHereRecommendation.id)
        XCTAssertFalse(contextA.startHereTrace.reason.summary.isEmpty)
        XCTAssertFalse(contextB.startHereTrace.reason.summary.isEmpty)
        XCTAssertTrue(diffSummary.sameIntent)
        XCTAssertTrue(diffSummary.differentContext)
        XCTAssertTrue(diffSummary.differentRecommendation)
        XCTAssertTrue(diffSummary.protectedTimeRespected)
        XCTAssertTrue(diffSummary.localOnlyBoundaryPassed)
        XCTAssertTrue(diffSummary.receiptPresent)
        XCTAssertTrue(diffSummary.freshnessPresent)
        XCTAssertTrue(diffSummary.closureEvidencePresent)
        XCTAssertTrue(diffSummary.replayStable)
        XCTAssertTrue(replayOutput.stable)
        XCTAssertNotEqual(contextA.localContext.capacityMinutes, contextB.localContext.capacityMinutes)
        XCTAssertNotEqual(contextA.localContext.recoveryState, contextB.localContext.recoveryState)
        XCTAssertNotEqual(contextA.proofTrustReceipt.actionReceiptIDs, contextB.proofTrustReceipt.actionReceiptIDs)
        XCTAssertNotEqual(contextA.sourceClaim.sourceIDs, contextB.sourceClaim.sourceIDs)
        XCTAssertEqual(explanationDiff.contextAReplayTraceID, "ReplayTrace.moat-scenario.intent.health-consistency.context-a")
        XCTAssertEqual(explanationDiff.contextBReplayTraceID, "ReplayTrace.moat-scenario.intent.health-consistency.context-b")
        XCTAssertTrue(explanationDiff.explanationDifferencePresent)
        XCTAssertTrue(explanationDiff.receiptContinuityPresent)
        XCTAssertTrue(explanationDiff.replayContinuityPresent)

        XCTAssertTrue(FileManager.default.fileExists(atPath: proofDirectory.appendingPathComponent("README.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: proofDirectory.appendingPathComponent("same-intent-context-a.json").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: proofDirectory.appendingPathComponent("same-intent-context-b.json").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: proofDirectory.appendingPathComponent("diff-summary.json").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: proofDirectory.appendingPathComponent("privacy-boundary.log").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: proofDirectory.appendingPathComponent("replay-output.json").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: proofDirectory.appendingPathComponent("explanation-diff.json").path))
    }
}

fileprivate enum ScenarioKind {
    case contextA
    case contextB
}

fileprivate struct ScenarioRun {
    let intent: MoatScenarioIntent
    let localContext: MoatScenarioLocalContext
    let reality: RealitySnapshot
    let goal: Goal
    let goalBelievability: GoalBelievabilityAssessment
    let believabilityExplanation: RecommendationExplanation
    let resilience: ExecutionResilienceAssessment
    let recoveryExplanation: RecommendationExplanation
    let nowState: CanonicalNowState
    let meridian: MoatScenarioMeridianExport
    let execution: MoatScenarioExecutionExport
    let sourceClaim: AmbitionsOSSourceTruthClaim
    let proofTrustReceipt: AmbitionsOSProofTrustReceipt
    let startHereRecommendation: AmbitionsOSStartHereRecommendation
    let startHereTrace: RecommendationTrace
    let localOnlyBoundary: PrivateLifeRuntimeBoundary
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let replayHash: String
}

private extension AmbitionsMoatScenarioProof98Tests {
    func buildContext(identifier: String, intent: MoatScenarioIntent, scenario: ScenarioKind) throws -> ScenarioRun {
        let now = Date(timeIntervalSince1970: 1_778_000_000)
        let goal = makeGoal(
            id: "goal-health-consistency",
            title: intent.text,
            stepID: "step-health-evening-walk",
            stepTitle: scenario == .contextA ? "Take a 20-minute evening walk" : "Take a 5-minute recovery-aware reset",
            dueAt: DomainTimestamp.string(from: now.addingTimeInterval(5 * 24 * 3_600)),
            domain: .health
        )

        let calendarContext: CalendarDerivedContext? = {
            switch scenario {
            case .contextA:
                return CalendarDerivedContext(
                    permissionState: .readWrite,
                    observedRangeStart: now,
                    observedRangeEnd: now.addingTimeInterval(3 * 3_600),
                    derivedBusyWindowCount: 0,
                    userInitiatedTimeAction: "Use the fresh open window",
                    explanation: "Fresh schedule data is readable locally."
                )
            case .contextB:
                return CalendarDerivedContext(
                    permissionState: .denied,
                    observedRangeStart: now,
                    observedRangeEnd: now.addingTimeInterval(3 * 3_600),
                    derivedBusyWindowCount: 0,
                    userInitiatedTimeAction: "Protect the recovery block",
                    explanation: "Schedule access is constrained, so protected recovery time stays visible."
                )
            }
        }()

        let reality = try makeReality(
            now: now,
            scenario: scenario,
            calendarContext: calendarContext,
            goal: goal
        )

        let eventLedgerEntry = makeEventLedgerEntry(
            context: scenario,
            now: now,
            goalID: goal.id
        )

        let believability = GoalBelievabilityProjector().assess(
            GoalBelievabilityInput(
                subjectKind: .goalNextAction,
                goal: goal,
                step: goal.plan?.sections.first?.steps.first,
                generatedAt: now,
                activeContextLens: .recovery,
                realitySnapshot: reality,
                eventLedgerEntries: [eventLedgerEntry],
                effortMinutes: scenario == .contextA ? 20 : 15,
                consequence: .high,
                importance: .high,
                recoveryState: scenario == .contextA ? .stable : .needsRecovery
            )
        )
        let believabilityExplanation = GoalBelievabilityProjector().makeExplanation(
            for: believability,
            type: scenario == .contextA ? .whyBelievable : .whyNotBelievable
        )

        let nowState = CanonicalNowStateProjector().project(
            input: NowStateProjectionInput(
                now: now,
                activeContextLens: .recovery,
                lensSource: .schedule,
                goals: [goal],
                progressEvidence: [],
                feedbackEvents: [],
                eventLedgerEntries: [eventLedgerEntry],
                recommendationExplanations: [believabilityExplanation]
            )
        )

        let resilienceProjector = ExecutionResilienceProjector()
        let resilience = resilienceProjector.assess(
            ExecutionResilienceProjectionInput(
                generatedAt: now,
                activeContextLens: .recovery,
                believabilityAssessments: [believability],
                realitySnapshot: reality,
                nowState: nowState,
                eventLedgerEntries: [eventLedgerEntry],
                timeID: "time.health-consistency"
            )
        )
        let recoveryExplanation = resilienceProjector.makeExplanation(
            for: resilience,
            option: resilience.recommendedRecoveryOption,
            type: scenario == .contextA ? .whyNow : .whyRecovered
        )

        let legacyHero = makeLegacyHero(
            goal: goal,
            step: goal.plan?.sections.first?.steps.first,
            scenario: scenario,
            recoveryExplanation: recoveryExplanation
        )
        let legacySupport = makeLegacySupport(
            scenario: scenario,
            now: now,
            reality: reality
        )
        let executionProjector = TodayExecutionProjector()
        let execution = executionProjector.project(
            TodayExecutionProjectionInput(
                mode: .active,
                legacyHero: legacyHero,
                legacySupport: legacySupport,
                nowState: nowState,
                realitySnapshot: reality,
                believabilityAssessments: [believability],
                resilienceAssessment: resilience,
                explanations: [believabilityExplanation, recoveryExplanation],
                captures: [],
                oneStepGoalsProjection: OneStepGoalProjector().projection(
                    from: OneStepGoalProjector.Input(
                        oneStepGoals: [],
                        goals: [goal],
                        includeArchived: false,
                        maxOneStepGoalsPerArea: 3
                    )
                )
            )
        )

        let sourceQueryResult = makeSourceQueryResult(context: scenario, intent: intent, now: now)
        let sourceClaim = AmbitionsOSStartHereRecommendation.sourceClaim(
            from: sourceQueryResult,
            text: scenario == .contextA
                ? "Fresh local schedule data and a successful evening closure support this step."
                : "Protected recovery time and the constrained schedule keep the smaller step honest."
        )
        let proofTrustReceipt = makeProofTrustReceipt(
            context: scenario,
            now: now,
            sourceClaim: sourceClaim,
            sourceQueryResult: sourceQueryResult,
            eventLedgerEntry: eventLedgerEntry,
            goal: goal
        )
        let controlRequest = AmbitionsOSControlPlaneWorkRequest(
            id: "work.health-consistency.\(identifier)",
            title: intent.text,
            surface: .today,
            requestedAt: DomainTimestamp.string(from: now)
        )
        let startHereRecommendation = makeStartHereRecommendation(
            context: scenario,
            now: now,
            goal: goal,
            sourceClaim: sourceClaim,
            proofTrustReceipt: proofTrustReceipt,
            controlClassification: AmbitionsOSControlPlaneClassifier().classify(controlRequest),
            resilience: resilience,
            believability: believability,
            execution: execution
        )
        let trace = RecommendationTrace(startHere: startHereRecommendation, explanation: recoveryExplanation)
        let localOnlyBoundary = PrivateLifeRuntimeBoundary.localOnly
        let runtimeBoundary = SourceAtlasRuntimeBoundary.valueModelOnly
        let replayHash = try stableReplayHash(
            intent: intent,
            localContext: makeLocalContext(scenario: scenario),
            reality: reality,
            believability: believability,
            resilience: resilience,
            meridian: execution.dayRail.heroStep,
            sourceClaim: sourceClaim,
            proofTrustReceipt: proofTrustReceipt,
            startHereRecommendation: startHereRecommendation,
            localOnlyBoundary: localOnlyBoundary
        )

        return ScenarioRun(
            intent: intent,
            localContext: makeLocalContext(scenario: scenario),
            reality: reality,
            goal: goal,
            goalBelievability: believability,
            believabilityExplanation: believabilityExplanation,
            resilience: resilience,
            recoveryExplanation: recoveryExplanation,
            nowState: nowState,
            meridian: MoatScenarioMeridianExport.from(execution: execution),
            execution: MoatScenarioExecutionExport.from(execution: execution),
            sourceClaim: sourceClaim,
            proofTrustReceipt: proofTrustReceipt,
            startHereRecommendation: startHereRecommendation,
            startHereTrace: trace,
            localOnlyBoundary: localOnlyBoundary,
            runtimeBoundary: runtimeBoundary,
            replayHash: replayHash
        )
    }

    func makeReality(
        now: Date,
        scenario: ScenarioKind,
        calendarContext: CalendarDerivedContext?,
        goal: Goal
    ) throws -> RealitySnapshot {
        let horizon = DateInterval(start: now, end: now.addingTimeInterval(3 * 3_600))
        let protectedWindows: [RealityWindow]
        let freeTimeWindows: [RealityWindow]
        let blockedWindows: [RealityWindow]
        let calendarBusyWindows: [RealityWindow]

        switch scenario {
        case .contextA:
            protectedWindows = []
            freeTimeWindows = [
                RealityWindow(
                    id: "window.a.free",
                    kind: .freeTime,
                    source: .userDefined,
                    start: now.addingTimeInterval(30 * 60),
                    end: now.addingTimeInterval(90 * 60),
                    title: "Evening open window",
                    contextLens: .recovery,
                    isFlexible: true,
                    relatedGoalID: goal.id
                )
            ]
            blockedWindows = []
            calendarBusyWindows = []
        case .contextB:
            protectedWindows = [
                RealityWindow(
                    id: "window.b.protected",
                    kind: .protected,
                    source: .userDefined,
                    start: now,
                    end: now.addingTimeInterval(3 * 3_600),
                    title: "Protected recovery block",
                    contextLens: .recovery,
                    isProtected: true,
                    relatedGoalID: goal.id
                )
            ]
            freeTimeWindows = []
            blockedWindows = []
            calendarBusyWindows = []
        }

        return RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: horizon,
                activeContextLens: .recovery,
                freeTimeWindows: freeTimeWindows,
                protectedWindows: protectedWindows,
                blockedWindows: blockedWindows,
                calendarBusyWindows: calendarBusyWindows,
                calendarContext: calendarContext,
                deadlineHints: [now.addingTimeInterval(5 * 24 * 3_600)],
                minimumWindowMinutes: 15
            )
        )
    }

    func makeEventLedgerEntry(
        context: ScenarioKind,
        now: Date,
        goalID: String
    ) -> EventLedgerEntry {
        switch context {
        case .contextA:
            return EventLedgerEntry(
                id: "ledger.health.a",
                kind: .actionCompleted,
                occurredAt: DomainTimestamp.string(from: now.addingTimeInterval(-2 * 3_600)),
                source: .today,
                goalID: goalID,
                title: "Short evening step completed",
                summary: "A short evening walk counted as proof and stayed local.",
                tone: .positive,
                trust: EventLedgerTrustMetadata(confidence: 0.9, isUserConfirmed: true),
                metadata: [
                    "closure": "successful",
                    "step": "short_evening_step"
                ],
                payload: [
                    "kind": "completed",
                    "source": "local"
                ]
            )
        case .contextB:
            return EventLedgerEntry(
                id: "ledger.health.b",
                kind: .actionSkipped,
                occurredAt: DomainTimestamp.string(from: now.addingTimeInterval(-2 * 3_600)),
                source: .today,
                goalID: goalID,
                title: "Longer health step blocked",
                summary: "Protected recovery time blocked the longer evening step.",
                tone: .caution,
                trust: EventLedgerTrustMetadata(confidence: 0.8, requiresReview: true),
                metadata: [
                    "closure": "needs_recovery",
                    "step": "blocked_by_protected_time"
                ],
                payload: [
                    "kind": "skipped",
                    "source": "local"
                ]
            )
        }
    }

    func makeLegacyHero(
        goal: Goal,
        step: Step?,
        scenario: ScenarioKind,
        recoveryExplanation: RecommendationExplanation
    ) -> TodayHeroState {
        let action = TodayInlineAction(
            kind: scenario == .contextA ? .startStepSession : .openTime,
            title: scenario == .contextA ? "Start now" : "Open Time",
            systemImage: scenario == .contextA ? "play.fill" : "calendar",
            state: .selected,
            target: TodayActionTarget(goalID: goal.id, stepID: step?.id)
        )
        let truth = TodayHeroTruthState(
            greeting: "Good evening",
            dominantText: scenario == .contextA ? "The open window fits the step." : "Protect recovery first.",
            supportingText: scenario == .contextA
                ? "Fresh schedule data keeps the health step reachable."
                : "The schedule is constrained, so keep the recovery block intact.",
            nowTitle: step?.title ?? goal.title,
            nowSubtitle: scenario == .contextA
                ? "A 20-minute evening walk fits the current window."
                : "The smaller reset keeps the day honest.",
            nextTitle: nil,
            nextSubtitle: nil,
            posture: scenario == .contextA ? .stable : .recovering,
            contextPills: [
                TodayPillState(id: "health", title: "Health", icon: "heart", state: .selected),
                TodayPillState(id: "work", title: "Work", icon: "briefcase", state: .default),
                TodayPillState(id: "relationships", title: "Relationships", icon: "person.2", state: .default)
            ],
            trustWhisper: TodayTrustWhisperState(
                title: scenario == .contextA ? "Fresh and local" : "Recovery stays protected",
                detail: scenario == .contextA
                    ? "The step comes from local schedule reality."
                    : "The smaller step does not overwrite protected recovery time.",
                state: .selected
            ),
            shellSummary: nil
        )
        return TodayHeroState(
            truth: truth,
            primaryAction: TodayPrimaryActionState(
                title: scenario == .contextA ? "Start now" : "Open Time",
                subtitle: scenario == .contextA
                    ? "Use the open window for the health step."
                    : "Keep recovery intact and choose a smaller step.",
                action: action,
                supportingActions: [TodayInlineAction(
                    kind: .askWhyThisMatters,
                    title: "Why this?",
                    systemImage: "questionmark.circle",
                    state: .default,
                    target: TodayActionTarget(goalID: goal.id, stepID: step?.id)
                )]
            ),
            reentry: TodayReentryState(
                eyebrow: "Today",
                title: scenario == .contextA ? "Stay with the walk" : "Stay with recovery",
                detail: scenario == .contextA
                    ? "The recommendation stays in the open window."
                    : "The recommendation moves smaller so recovery remains protected.",
                state: .selected
            )
        )
    }

    func makeSourceQueryResult(
        context: ScenarioKind,
        intent: MoatScenarioIntent,
        now: Date
    ) -> SourceAtlasQueryResult {
        SourceAtlasQueryResult(
            id: "source.health.\(context == .contextA ? "a" : "b")",
            packID: "pack.health.local",
            domainID: "health",
            goalIntent: intent.id,
            claimID: "claim.health.consistency",
            requirementID: "requirement.health.consistency",
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            riskClass: .healthMedical,
            reviewState: .approved,
            provenanceSourceIDs: [
                "source.health.local",
                "source.schedule.\(context == .contextA ? "fresh" : "constrained")"
            ],
            proofEntryIDs: [
                "proof.health.\(context == .contextA ? "a" : "b")"
            ],
            fallbackReason: nil,
            sourceNeededDetail: nil
        )
    }

    func makeProofTrustReceipt(
        context: ScenarioKind,
        now: Date,
        sourceClaim: AmbitionsOSSourceTruthClaim,
        sourceQueryResult: SourceAtlasQueryResult,
        eventLedgerEntry: EventLedgerEntry,
        goal: Goal
    ) -> AmbitionsOSProofTrustReceipt {
        AmbitionsOSProofTrustReceipt(
            id: "proof-trust.health.\(context == .contextA ? "a" : "b")",
            kind: .closure,
            surface: .today,
            occurredAt: DomainTimestamp.string(from: now),
            affectedObjectIDs: [goal.id],
            actionReceiptIDs: ["receipt.action.health.\(context == .contextA ? "a" : "b")"],
            proofReferenceIDs: ["proof.health.\(context == .contextA ? "a" : "b")"],
            sourceClaimIDs: [sourceClaim.id],
            sourcePackIDs: [sourceQueryResult.packID],
            changedFactSummaries: context == .contextA
                ? ["A short evening step remained countable as proof."]
                : ["Protected recovery time required a smaller recovery-aware step."],
            closureOutcome: context == .contextA ? .stillCounts : .needsRecovery,
            sourceState: .userConfirmed,
            freshnessState: .current,
            reviewState: .ready,
            privacyClass: .privateLife,
            reversible: true,
            professionalBoundaryReviewRequired: false
        )
    }

    func makeStartHereRecommendation(
        context: ScenarioKind,
        now: Date,
        goal: Goal,
        sourceClaim: AmbitionsOSSourceTruthClaim,
        proofTrustReceipt: AmbitionsOSProofTrustReceipt,
        controlClassification: AmbitionsOSControlPlaneClassification,
        resilience: ExecutionResilienceAssessment,
        believability: GoalBelievabilityAssessment,
        execution: TodayExecutionViewState
    ) -> AmbitionsOSStartHereRecommendation {
        let stepTitle = execution.dayRail.heroStep?.title ?? execution.hero.title
        return AmbitionsOSStartHereRecommendation(
            id: "start-here.health.\(context == .contextA ? "a" : "b")",
            title: context == .contextA
                ? "Take the open health step"
                : "Protect recovery and shrink the step",
            kind: context == .contextA ? .startHere : .recovery,
            surface: .today,
            recommendedObjectID: goal.id,
            sourceLabel: context == .contextA
                ? "Fresh local schedule and successful closure"
                : "Constrained schedule and protected recovery",
            sourceClaims: [sourceClaim],
            proofTrustReceipts: [proofTrustReceipt],
            controlClassification: controlClassification,
            fitState: context == .contextA ? .fits : .reviewable,
            whyNow: context == .contextA
                ? [
                    "Fresh schedule data shows an open window that fits the health step.",
                    "A successful previous evening closure keeps the proof trail current."
                ]
                : [
                    "Protected recovery time is already visible, so the smaller step comes first.",
                    "The schedule is constrained, so the longer step waits."
                ],
            advances: context == .contextA
                ? [
                    "Keeps the health thread moving without crowding work or relationships."
                ]
                : [
                    "Keeps momentum alive without overwriting recovery."
                ],
            protects: context == .contextA
                ? [
                    "Uses the open window locally."
                ]
                : [
                    "Respects the protected recovery block.",
                    "Avoids pushing the larger step into constrained time."
                ],
            assumptions: context == .contextA
                ? [
                    "The 20-minute walk still fits the available open window."
                ]
                : [
                    "A smaller recovery-aware step is safer than forcing the original plan."
                ],
            notChosen: context == .contextA
                ? [
                    "A bigger workout would waste the open window."
                ]
                : [
                    "The longer walk waits until protected time clears."
                ],
            controlActions: context == .contextA
                ? [.adjust, .open, .start]
                : [.adjust, .makeSmaller, .open, .notNow],
            privacyClass: .privateLife,
            runtimeBoundary: .valueModelOnly,
            surfaceLanguageSamples: [
                "Start here with \(stepTitle)",
                "Start now"
            ]
        )
    }

    func stableReplayHash(
        intent: MoatScenarioIntent,
        localContext: MoatScenarioLocalContext,
        reality: RealitySnapshot,
        believability: GoalBelievabilityAssessment,
        resilience: ExecutionResilienceAssessment,
        meridian: DayRailHeroStepState?,
        sourceClaim: AmbitionsOSSourceTruthClaim,
        proofTrustReceipt: AmbitionsOSProofTrustReceipt,
        startHereRecommendation: AmbitionsOSStartHereRecommendation,
        localOnlyBoundary: PrivateLifeRuntimeBoundary
    ) throws -> String {
        let fingerprint = MoatScenarioReplayFingerprint(
            intentID: intent.id,
            intentText: intent.text,
            localContextSummary: localContext.summary,
            protectedWindowCount: reality.availability.protectedWindowCount,
            openWindowCount: reality.availability.openWindowCount,
            recommendedAction: meridian?.primaryAction.title ?? startHereRecommendation.title,
            heroKind: meridian?.primaryAction.kind.rawValue ?? startHereRecommendation.kind.rawValue,
            sourceFreshness: sourceClaim.freshnessState.rawValue,
            closureOutcome: proofTrustReceipt.closureOutcome?.rawValue ?? "none",
            recoveryState: resilience.status.rawValue,
            believabilityStatus: believability.status.rawValue,
            localOnly: localOnlyBoundary.isLocalOnly
        )
        let data = try MoatScenarioProofExporter.encoder.encode(fingerprint)
        return Self.sha256Hex(for: data)
    }

    func makeLocalContext(scenario: ScenarioKind) -> MoatScenarioLocalContext {
        switch scenario {
        case .contextA:
            return MoatScenarioLocalContext(
                summary: "Standard work block, moderate free time, fresh schedule data, and a successful previous evening closure.",
                workWindowMinutes: 60,
                capacityMinutes: 45,
                protectedRecoveryWindowMinutes: 0,
                scheduleSource: "Fresh local Time data",
                priorClosureHistory: "Successful short evening steps",
                recoveryState: "stable",
                protectedTimeSource: "none",
                calendarAccess: "read_write"
            )
        case .contextB:
            return MoatScenarioLocalContext(
                summary: "Protected recovery block, tighter capacity, constrained schedule access, and a missed or blocked recent health step.",
                workWindowMinutes: 0,
                capacityMinutes: 5,
                protectedRecoveryWindowMinutes: 180,
                scheduleSource: "Constrained local Time data",
                priorClosureHistory: "Recent missed or blocked health step",
                recoveryState: "needs_recovery",
                protectedTimeSource: "local protected recovery block",
                calendarAccess: "denied"
            )
        }
    }

    func moatsREADME(command: String, result: String) -> String {
        [
            "# AMB-FE-BE-MOAT-SCENARIO-PROOF-98",
            "",
            "Result: \(result)",
            "",
            "Scenario summary",
            "- Same health-consistency intent, two local contexts, two different Start Here / Reality Meridian recommendations.",
            "- Context A keeps the open window visible and recommends the health step.",
            "- Context B keeps protected recovery time intact and recommends a smaller recovery-aware step.",
            "- `explanation-diff.json` records schedule, capacity, protected time, recovery, source, receipt, and replay differences.",
            "",
            "Exact command run",
            "",
            "```bash",
            command,
            "```",
            "",
            "Evidence index",
            "- `same-intent-context-a.json`",
            "- `same-intent-context-b.json`",
            "- `diff-summary.json`",
            "- `explanation-diff.json`",
            "- `replay-output.json`",
            "- `privacy-boundary.log`",
            "- `test-output.log`",
            "",
            "Limitations",
            "- `swift test` is not the primary proof lane for the iOS target; the focused Xcode test is the executable proof path.",
            "- The proof pack stays local and inspectable; it does not claim device, App Store, or hosted release proof."
        ].joined(separator: "\n")
    }

    func makeLegacySupport(
        scenario: ScenarioKind,
        now: Date,
        reality: RealitySnapshot
    ) -> TodaySupportLayerState {
        let pressure = TodayDayPressureState(
            title: scenario == .contextA ? "Open" : "Protected",
            detail: scenario == .contextA
                ? "Fresh capacity is visible."
                : "Protected time is the dominant constraint.",
            label: scenario == .contextA ? "Open" : "Protected",
            state: scenario == .contextA ? .selected : .warning
        )
        let timeAperture = TodayTimeApertureState(
            title: "Time aperture",
            subtitle: scenario == .contextA
                ? "A fresh evening window is available."
                : "The schedule is constrained around recovery.",
            pressure: pressure,
            windows: [],
            emptyMessage: nil,
            bestUseTitle: scenario == .contextA ? "Use the open window" : "Keep the recovery block intact",
            bestUseDetail: scenario == .contextA
                ? "A short health step fits."
                : "Choose a smaller next step after recovery.",
            bestUseAction: nil,
            trustWhisper: TodayTrustWhisperState(
                title: scenario == .contextA ? "Fresh schedule data" : "Constrained schedule data",
                detail: scenario == .contextA
                    ? "The schedule remains open enough for one useful step."
                    : "The schedule cannot expand into protected time.",
                state: .selected
            )
        )
        let fixedCommitments = TodayFixedCommitmentsState(
            title: "Fixed commitments",
            summary: "Work and relationship commitments stay visible.",
            items: [],
            emptyMessage: "No fixed commitments are pinning this hour."
        )
        let flexibleRoom = TodayFlexibleRoomState(
            title: "Flexible room",
            summary: scenario == .contextA ? "There is room for one health step." : "Room is too tight for the larger step.",
            items: [],
            emptyMessage: "Nothing flexible needs attention."
        )
        let momentum = TodayMomentumStripState(
            title: "Momentum",
            summary: scenario == .contextA ? "Fresh enough to continue." : "Recovery should lead.",
            metrics: [],
            note: scenario == .contextA ? "Keep the open window calm." : "Do not crowd the recovery block.",
            celebrationLine: nil
        )
        return TodaySupportLayerState(
            timeAperture: timeAperture,
            recoveryBloom: nil,
            stepSession: nil,
            fixedCommitments: fixedCommitments,
            flexibleRoom: flexibleRoom,
            momentum: momentum,
            quickCaptureAction: TodayInlineAction(
                kind: .quickLog,
                title: "Capture something",
                systemImage: "tray.and.arrow.down",
                state: .default,
                target: TodayActionTarget()
            ),
            quickCaptureTitle: "Capture something",
            quickCaptureDetail: "Keep intake local and inspectable.",
            timeAction: TodayInlineAction(
                kind: .openTime,
                title: "Open Time",
                systemImage: "calendar",
                state: .default,
                target: TodayActionTarget()
            ),
            reflectionPrompt: nil,
            reflectionHighlights: []
        )
    }

    func makeGoal(
        id: String,
        title: String,
        stepID: String,
        stepTitle: String,
        dueAt: String,
        domain: LifeDomainKey
    ) -> Goal {
        let actor = GoalActor.localOwner
        let timing = GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: nil,
            dueAt: dueAt,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let step = Step(
            id: stepID,
            sectionID: "section-\(id)",
            title: stepTitle,
            summary: nil,
            type: .actionUnit,
            state: .planned,
            owner: actor,
            timing: timing,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["Done"],
            actionability: StepActionability(
                action: "Start \(stepTitle)",
                completionDefinition: "Done",
                evidenceOfCompletion: ["Done"],
                fallbackMicroStep: "Start small",
                contextRequirements: []
            )
        )
        let strategy = PlanningStrategy(
            strategyKind: .sequential,
            allowParallelSteps: false,
            maxActiveSteps: 1,
            preferredSectionOrder: [.activeSteps],
            defaultStepType: .actionUnit,
            autoGenerateReviewSection: false,
            preferShortSteps: true,
            revisitCadenceDays: 7
        )
        let progress = ProgressStrategy(
            metricKind: .stepCompletion,
            rollupMethod: .ratio,
            targetStepCount: 1,
            targetEvidenceCount: nil,
            targetMinutes: nil,
            supportsUntimedProgress: true,
            countsChildGoals: false,
            countsSupportGoals: false
        )
        let section = PlanSection(
            id: "section-\(id)",
            goalID: id,
            title: "Active",
            summary: nil,
            kind: .activeSteps,
            orderIndex: 0,
            steps: [step]
        )
        let plan = GoalPlan(
            id: "plan-\(id)",
            goalID: id,
            version: goalEnginePlanVersion,
            generatedAt: DomainTimestamp.string(from: Date(timeIntervalSince1970: 1_778_000_000)),
            summary: nil,
            strategy: strategy,
            sections: [section],
            assumptions: [],
            lint: PlanLintResult(goalID: id, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: [])
        )
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: DomainTimestamp.string(from: Date(timeIntervalSince1970: 1_778_000_000)),
            updatedAt: DomainTimestamp.string(from: Date(timeIntervalSince1970: 1_778_000_000)),
            state: .active,
            title: title,
            summary: nil,
            mode: .project,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: strategy,
            progressStrategy: progress,
            plan: plan,
            lifeGraph: LifeGraphContext(domains: [LifeDomainAssignment(domain: domain)])
        )
    }

    func proofDirectoryURL() -> URL {
        repoRootURL()
            .appendingPathComponent("docs")
            .appendingPathComponent("proof")
            .appendingPathComponent("amb-fe-be")
            .appendingPathComponent("moat-scenario-proof-98")
    }

    func repoRootURL() -> URL {
        let fileURL = URL(fileURLWithPath: #filePath)
        return fileURL
            .deletingLastPathComponent() // Domain
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // Native/AmbitionsTests
            .deletingLastPathComponent() // Native
    }

    func stableReplayHash(for fingerprint: MoatScenarioReplayFingerprint) throws -> String {
        let data = try MoatScenarioProofExporter.encoder.encode(fingerprint)
        return Self.sha256Hex(for: data)
    }

    static func sha256Hex(for data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

private struct MoatScenarioIntent: Codable, Sendable, Equatable, Hashable {
    let id: String
    let text: String
}

private struct MoatScenarioLocalContext: Codable, Sendable, Equatable, Hashable {
    let summary: String
    let workWindowMinutes: Int
    let capacityMinutes: Int
    let protectedRecoveryWindowMinutes: Int
    let scheduleSource: String
    let priorClosureHistory: String
    let recoveryState: String
    let protectedTimeSource: String
    let calendarAccess: String
}

private struct MoatScenarioMeridianExport: Codable, Sendable, Equatable, Hashable {
    let heroKind: String
    let heroTitle: String
    let heroSubtitle: String
    let primaryActionTitle: String
    let primaryActionKind: String
    let receiptTitle: String?
    let receiptSourceLabel: String?
    let receiptFreshness: String?
    let becauseLine: String?
    let timeFitTitle: String?
    let timeFitSummary: String?
    let sourceQualityLabel: String?

    static func from(execution: TodayExecutionViewState) -> MoatScenarioMeridianExport {
        let hero = execution.dayRail.heroStep
        return MoatScenarioMeridianExport(
            heroKind: execution.hero.kind.rawValue,
            heroTitle: execution.hero.title,
            heroSubtitle: execution.hero.subtitle,
            primaryActionTitle: hero?.primaryAction.title ?? execution.hero.primaryAction.title,
            primaryActionKind: hero?.primaryAction.kind.rawValue ?? execution.hero.primaryAction.kind.rawValue,
            receiptTitle: hero?.receiptItem.title,
            receiptSourceLabel: hero?.receiptItem.sourceLabel,
            receiptFreshness: hero?.receiptItem.freshness.rawValue,
            becauseLine: hero?.becauseLine,
            timeFitTitle: hero?.timeFitProof.title,
            timeFitSummary: hero?.timeFitProof.summary,
            sourceQualityLabel: hero?.sourceQualityLabel
        )
    }
}

private struct MoatScenarioExecutionExport: Codable, Sendable, Equatable, Hashable {
    let heroKind: String
    let heroTitle: String
    let heroSubtitle: String
    let recommendedStepTitle: String
    let recommendedStepSubtitle: String
    let dayState: String
    let dayStateSummary: String
    let protectedMustDo: MoatScenarioPanelExport
    let recommendedStep: MoatScenarioPanelExport
    let notToday: MoatScenarioPanelExport
    let recoveryFallback: MoatScenarioPanelExport
    let whyThisMatters: MoatScenarioPanelExport
    let actionClosureEntry: MoatScenarioPanelExport
    let todayTimeLayer: MoatScenarioTimeLayerExport

    static func from(execution: TodayExecutionViewState) -> MoatScenarioExecutionExport {
        MoatScenarioExecutionExport(
            heroKind: execution.hero.kind.rawValue,
            heroTitle: execution.hero.title,
            heroSubtitle: execution.hero.subtitle,
            recommendedStepTitle: execution.recommendedStep.title,
            recommendedStepSubtitle: execution.recommendedStep.subtitle,
            dayState: execution.dayState.rawValue,
            dayStateSummary: execution.dayStateSummary,
            protectedMustDo: MoatScenarioPanelExport.from(execution.protectedMustDo),
            recommendedStep: MoatScenarioPanelExport.from(execution.recommendedStep),
            notToday: MoatScenarioPanelExport.from(execution.notToday),
            recoveryFallback: MoatScenarioPanelExport.from(execution.recoveryFallback),
            whyThisMatters: MoatScenarioPanelExport.from(execution.whyThisMatters),
            actionClosureEntry: MoatScenarioPanelExport.from(execution.actionClosureEntry),
            todayTimeLayer: MoatScenarioTimeLayerExport.from(execution.todayTimeLayer)
        )
    }
}

private struct MoatScenarioPanelExport: Codable, Sendable, Equatable, Hashable {
    let title: String
    let subtitle: String
    let value: String
    let semanticState: String

    static func from(_ panel: TodayContractEntryState) -> MoatScenarioPanelExport {
        MoatScenarioPanelExport(
            title: panel.title,
            subtitle: panel.subtitle,
            value: panel.value,
            semanticState: String(describing: panel.semanticState)
        )
    }
}

private struct MoatScenarioTimeLayerExport: Codable, Sendable, Equatable, Hashable {
    let title: String
    let subtitle: String
    let compactTimelineLabel: String
    let openWindowLabel: String
    let calendarSourceLabel: String

    static func from(_ layer: TodayTimeLayerState) -> MoatScenarioTimeLayerExport {
        MoatScenarioTimeLayerExport(
            title: layer.title,
            subtitle: layer.subtitle,
            compactTimelineLabel: layer.compactTimelineLabel,
            openWindowLabel: layer.openWindowLabel,
            calendarSourceLabel: layer.calendarSourceLabel
        )
    }
}

private struct MoatScenarioDiffSummary: Codable, Sendable, Equatable, Hashable {
    let sameIntent: Bool
    let differentContext: Bool
    let differentRecommendation: Bool
    let protectedTimeRespected: Bool
    let localOnlyBoundaryPassed: Bool
    let receiptPresent: Bool
    let freshnessPresent: Bool
    let closureEvidencePresent: Bool
    let replayStable: Bool
}

private struct MoatScenarioReplayRun: Codable, Sendable, Equatable, Hashable {
    let hash: String
    let heroKind: String
    let result: String
}

private struct MoatScenarioReplayPair: Codable, Sendable, Equatable, Hashable {
    let firstRun: MoatScenarioReplayRun
    let replayRun: MoatScenarioReplayRun
    let stable: Bool
}

private struct MoatScenarioReplayOutput: Codable, Sendable, Equatable, Hashable {
    let contextA: MoatScenarioReplayPair
    let contextB: MoatScenarioReplayPair
    let stable: Bool
}

private struct MoatScenarioExplanationDiffArtifact: Codable, Sendable, Equatable, Hashable {
    let sameIntentID: String
    let contextAWhyNow: [String]
    let contextBWhyNow: [String]
    let contextAProtects: [String]
    let contextBProtects: [String]
    let contextASourceRecordIDs: [String]
    let contextBSourceRecordIDs: [String]
    let contextAReceiptIDs: [String]
    let contextBReceiptIDs: [String]
    let contextAReplayTraceID: String
    let contextBReplayTraceID: String
    let contextAReplayHash: String
    let contextBReplayHash: String
    let contextACapacityMinutes: Int
    let contextBCapacityMinutes: Int
    let protectedTimeDifference: Bool
    let recoveryStateDifference: Bool
    let explanationDifferencePresent: Bool
    let receiptContinuityPresent: Bool
    let replayContinuityPresent: Bool
}

private struct MoatScenarioReplayFingerprint: Codable, Sendable, Equatable, Hashable {
    let intentID: String
    let intentText: String
    let localContextSummary: String
    let protectedWindowCount: Int
    let openWindowCount: Int
    let recommendedAction: String
    let heroKind: String
    let sourceFreshness: String
    let closureOutcome: String
    let recoveryState: String
    let believabilityStatus: String
    let localOnly: Bool
}

private struct MoatScenarioProofExporter {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    let command = "xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AmbitionsMoatScenarioProof98Tests test CODE_SIGNING_ALLOWED=NO | tee docs/proof/amb-fe-be/moat-scenario-proof-98/test-output.log"

    var xcodebuildCommand: String {
        command
    }

    func proofDirectoryURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("docs")
            .appendingPathComponent("proof")
            .appendingPathComponent("amb-fe-be")
            .appendingPathComponent("moat-scenario-proof-98")
    }

    func write(
        README: String,
        contextA: ScenarioRun,
        contextB: ScenarioRun,
        diffSummary: MoatScenarioDiffSummary,
        privacyBoundaryLog: String,
        replayOutput: MoatScenarioReplayOutput,
        explanationDiff: MoatScenarioExplanationDiffArtifact
    ) throws {
        let directory = proofDirectoryURL()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        guard let readmeData = README.data(using: .utf8) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try readmeData.write(to: directory.appendingPathComponent("README.md"), options: .atomic)
        try writeJSON(contextA.exported(), to: directory.appendingPathComponent("same-intent-context-a.json"))
        try writeJSON(contextB.exported(), to: directory.appendingPathComponent("same-intent-context-b.json"))
        try writeJSON(diffSummary, to: directory.appendingPathComponent("diff-summary.json"))
        try writeJSON(explanationDiff, to: directory.appendingPathComponent("explanation-diff.json"))
        guard let privacyData = privacyBoundaryLog.data(using: .utf8) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try privacyData.write(to: directory.appendingPathComponent("privacy-boundary.log"), options: .atomic)
        try writeJSON(replayOutput, to: directory.appendingPathComponent("replay-output.json"))
    }

    func privacyBoundaryLog(
        boundary: PrivateLifeRuntimeBoundary,
        runtimeBoundary: SourceAtlasRuntimeBoundary
    ) -> String {
        [
            "PrivateLifeRuntimeBoundary.localOnly.isLocalOnly = \(boundary.isLocalOnly)",
            "usesSwiftDataPersistence = \(boundary.usesSwiftDataPersistence)",
            "usesRepositoryBackedMemory = \(boundary.usesRepositoryBackedMemory)",
            "syncBackendKind = \(boundary.syncBackendKind.rawValue)",
            "hasHostedBackend = \(boundary.hasHostedBackend)",
            "hasRemoteIntelligenceBackend = \(boundary.hasRemoteIntelligenceBackend)",
            "hasExternalCloudLLMDependency = \(boundary.hasExternalCloudLLMDependency)",
            "allowsExternalSideEffectsInsideUnitOfWorkBoundaries = \(boundary.allowsExternalSideEffectsInsideUnitOfWorkBoundaries)",
            "Runtime boundary is value model only = \(runtimeBoundary.isValueModelOnly)",
            "No network, cloud LLM, backend, analytics, or hosted dependency is required for this proof."
        ].joined(separator: "\n")
    }

    private func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let data = try Self.encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }
}

private extension ScenarioRun {
    func exported() -> MoatScenarioContextExport {
        MoatScenarioContextExport(
            contextID: localContext.summary,
            intent: intent,
            localContext: localContext,
            realitySummary: String(describing: reality),
            goalTitle: goal.title,
            goalPlanSummary: String(describing: goal.plan),
            goalBelievabilitySummary: String(describing: goalBelievability),
            believabilityExplanationSummary: String(describing: believabilityExplanation),
            resilienceSummary: String(describing: resilience),
            recoveryExplanationSummary: String(describing: recoveryExplanation),
            nowStateSummary: String(describing: nowState),
            meridian: meridian,
            execution: execution,
            sourceClaimSummary: String(describing: sourceClaim),
            proofTrustReceiptSummary: String(describing: proofTrustReceipt),
            startHereRecommendationSummary: String(describing: startHereRecommendation),
            startHereTraceSummary: String(describing: startHereTrace),
            localOnlyBoundaryIsLocalOnly: localOnlyBoundary.isLocalOnly,
            runtimeBoundarySummary: String(describing: runtimeBoundary),
            replayHash: replayHash
        )
    }
}

private struct MoatScenarioContextExport: Codable, Sendable, Equatable, Hashable {
    let contextID: String
    let intent: MoatScenarioIntent
    let localContext: MoatScenarioLocalContext
    let realitySummary: String
    let goalTitle: String
    let goalPlanSummary: String
    let goalBelievabilitySummary: String
    let believabilityExplanationSummary: String
    let resilienceSummary: String
    let recoveryExplanationSummary: String
    let nowStateSummary: String
    let meridian: MoatScenarioMeridianExport
    let execution: MoatScenarioExecutionExport
    let sourceClaimSummary: String
    let proofTrustReceiptSummary: String
    let startHereRecommendationSummary: String
    let startHereTraceSummary: String
    let localOnlyBoundaryIsLocalOnly: Bool
    let runtimeBoundarySummary: String
    let replayHash: String
}
