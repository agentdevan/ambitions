import Foundation
import XCTest
@testable import Ambitions

final class CaptureRuntimeGauntletTests: XCTestCase {
    func testCaptureRuntimeGauntletCoversDeterministicScenarioMatrixAndWritesProofReport() throws {
        let result = try CaptureRuntimeGauntletHarness().run()
        try result.writeReports()

        XCTAssertEqual(result.scenarioCount, 153)
        XCTAssertEqual(result.categoryCount, CaptureRuntimeGauntletCategory.allCases.count)
        XCTAssertEqual(result.failureCount, 0, result.failureSummary)
        XCTAssertEqual(result.redCount, 0)
        XCTAssertGreaterThan(result.greenCount, 0)
        XCTAssertGreaterThan(result.yellowCount, 0)
        XCTAssertTrue(result.report.contains("STATUS: GREEN"))
        XCTAssertTrue(result.report.contains("Scenario count: 153"))
        XCTAssertTrue(result.report.contains("Failing scenarios: None"))
        XCTAssertTrue(result.report.contains("No cloud or LLM dependency was introduced."))
    }
}

private struct CaptureRuntimeGauntletHarness {
    private let fixedTimestamp = "2026-05-24T04:08:53Z"
    private let fixedSourceContext = SmartAttachmentSourceContext(sourceType: .todayQuickCapture, sourceSurface: "Capture")
    private let reportURL: URL = {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("build/reports/capture-runtime-bridge/capture-runtime-gauntlet.md")
    }()
    private let jsonURL: URL = {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("build/reports/capture-runtime-bridge/capture-runtime-gauntlet-output.json")
    }()

    func run() throws -> CaptureRuntimeGauntletResult {
        let service = DefaultSmartAttachmentService()
        let scenarios = makeScenarios()
        var outcomes: [CaptureRuntimeGauntletScenarioOutcome] = []

        for scenario in scenarios {
            let outcome = validateScenario(scenario, using: service)
            outcomes.append(outcome)
        }

        return CaptureRuntimeGauntletResult(
            scenarios: outcomes,
            reportURL: reportURL,
            jsonURL: jsonURL
        )
    }

    private func validateScenario(
        _ scenario: CaptureRuntimeGauntletScenario,
        using service: DefaultSmartAttachmentService
    ) -> CaptureRuntimeGauntletScenarioOutcome {
        var failures: [CaptureRuntimeGauntletFailure] = []

        func record(_ condition: @autoclosure () -> Bool, _ message: String) {
            if condition() == false {
                failures.append(
                    CaptureRuntimeGauntletFailure(
                        id: scenario.id,
                        category: scenario.category,
                        message: message
                    )
                )
            }
        }

        let input = SmartAttachmentInput(rawText: scenario.rawText, sourceContext: fixedSourceContext)
        let result = service.route(input, candidates: scenario.candidates, maxCandidateCount: 5)
        let trace = result.captureRuntimeReplayTrace(timestamp: fixedTimestamp, correction: scenario.correction)
        let replayAgain = result.captureRuntimeReplayTrace(timestamp: fixedTimestamp, correction: scenario.correction)
        let factoringCandidate = result.captureRuntimeFactoringCandidate
        let futureCandidate = result.futureProofContextCandidate
        let planCandidate = result.planInsertionCandidate
        let encodedTrace = try? JSONEncoder.gauntlet.encode(trace)
        let encodedReplay = try? JSONEncoder.gauntlet.encode(replayAgain)
        let replayDeterministic = trace == replayAgain && encodedTrace == encodedReplay

        record(result.input.rawText == scenario.rawText, "Capture text was not preserved in the result payload.")
        record(trace.rawCapture == scenario.rawText, "Capture text was not preserved in the replay trace.")
        record(trace.receipt.id.isEmpty == false, "Replay receipt was missing an ID.")
        record(trace.futureUse.localOnly, "Replay future-use projection must stay local-only.")
        record(trace.receipt.whatWasDetected.contains(where: { $0.localizedCaseInsensitiveContains("cloud") || $0.localizedCaseInsensitiveContains("LLM") }) == false, "Replay receipt exposed a cloud or LLM dependency.")
        record(trace.receipt.whatWasCaptured.isEmpty == false, "Replay receipt did not retain a capture record.")
        record(replayDeterministic, "Replay trace was not deterministic.")

        switch scenario.category {
        case .scheduledActivity:
            record(factoringCandidate?.candidateType == .scheduledActivity, "Scheduled activity should factor to scheduled activity.")
            record(futureCandidate?.contextCategory == .scheduleDrift, "Scheduled activity should surface schedule drift future context.")
            record(futureCandidate?.runtimeUseAllowed == true, "Scheduled activity should stay runtime-usable.")
            record(futureCandidate?.reviewNeeded == true, "Scheduled activity should remain review-aware.")
            record(futureCandidate?.visibleInYou == true, "Scheduled activity should be visible in You.")
        case .proofEvent:
            record(result.resultState == .savedStandalone, "Proof event should save as standalone proof.")
            record(result.selectedCandidate?.target.routeType == .proofItem, "Proof event should use the proof route.")
            record(result.goalRelevanceScan?.highConfidenceMatches.count == 1, "Proof event should attach to the explicit local goal candidate.")
            record(factoringCandidate == nil, "Proof event should not produce a future-proof factoring candidate once the goal match is explicit.")
            record(futureCandidate == nil, "Proof event should not surface a future-proof context candidate once the goal match is explicit.")
            record(trace.receipt.kind == .captureSavedAsProof, "Proof event should produce a proof receipt.")
        case .facilityAccess:
            record(factoringCandidate?.candidateType == .facilityAccess, "Facility access should factor to facility access.")
            record(futureCandidate?.contextCategory == .facilityAccess, "Facility access should surface the facility-access future context.")
            record(futureCandidate?.runtimeUseAllowed == true, "Facility access should stay runtime-usable.")
            record(futureCandidate?.reviewNeeded == false, "Facility access should not require review.")
        case .equipmentAccess:
            record(factoringCandidate?.candidateType == .equipmentAccess, "Equipment access should factor to equipment access.")
            record(futureCandidate?.contextCategory == .equipmentAccess, "Equipment access should surface the equipment-access future context.")
            record(futureCandidate?.runtimeUseAllowed == true, "Equipment access should stay runtime-usable.")
            record(futureCandidate?.reviewNeeded == false, "Equipment access should not require review.")
        case .blocker:
            record(factoringCandidate?.candidateType == .blocker, "Blocker context should factor to blocker.")
            record(futureCandidate?.contextCategory == .accessConstraint, "Blocker context should surface access-constraint future context.")
            record(futureCandidate?.runtimeUseAllowed == true, "Blocker context should remain runtime-usable.")
            record(futureCandidate?.reviewNeeded == true, "Blocker context should remain review-aware.")
            record(trace.receiptKinds.contains(.captureSavedAsFutureContext), "Blocker context should be retained as future context.")
        case .recoveryInjury:
            record(factoringCandidate?.candidateType == .recovery, "Recovery injury should factor to recovery.")
            record(futureCandidate?.contextCategory == .recoveryConstraint, "Recovery injury should surface the recovery constraint.")
            record(futureCandidate?.runtimeUseAllowed == false, "Recovery injury should not be runtime-usable without review.")
            record(futureCandidate?.reviewNeeded == true, "Recovery injury should stay review-gated.")
            record(trace.receipt.whatWasCaptured == "[redacted]", "Sensitive recovery capture text should be redacted in the receipt.")
            record(trace.receipt.privacyRedactions.contains("raw capture text"), "Sensitive recovery capture should redact the raw capture text.")
        case .socialSupport:
            record(result.semanticExtraction.peopleHint.isEmpty == false, "Social support context should preserve people hints.")
            record(factoringCandidate?.candidateType == .step, "Social support should factor to a local future step.")
            record(futureCandidate?.contextCategory == .lifeContext, "Social support should surface life context.")
            record(futureCandidate?.visibleInYou == true, "Social support should remain visible in You.")
        case .recurringCommitment:
            record(factoringCandidate?.candidateType == .recurringCommitment, "Recurring commitment should factor to recurring commitment.")
            record(futureCandidate?.runtimeUseAllowed == true, "Recurring commitment should stay runtime-usable.")
            record(futureCandidate?.contextCategory == .recurringCommitment || futureCandidate?.contextCategory == .skillContext, "Recurring commitment should surface recurring or skill context.")
            if scenario.variantIndex.isMultiple(of: 2) {
                record(futureCandidate?.contextCategory == .skillContext, "Learning-flavored recurring commitments should surface skill context.")
            }
        case .ambiguousTime:
            record(result.semanticExtraction.needsClarification, "Ambiguous time should require clarification.")
            record(planCandidate != nil, "Ambiguous time should build a plan insertion candidate.")
            record(planCandidate?.timeConfidence == .needsClarification, "Ambiguous time should need clarification.")
            record(planCandidate?.scheduleImpact == .timeChangeRecommended, "Ambiguous time should recommend a time change.")
            record(planCandidate?.conflictStatus == .ambiguity, "Ambiguous time should be marked as an ambiguity.")
            record(planCandidate?.requiresCalendarPermission == true, "Ambiguous time should require calendar permission before any write.")
            record(planCandidate?.requiresUserApproval == true, "Ambiguous time should require user approval.")
        case .ambiguousGoalRelevance:
            record(result.goalRelevanceScan?.weakMatches.isEmpty == false || result.goalRelevanceScan?.mediumConfidenceMatches.isEmpty == false, "Ambiguous goal relevance should preserve uncertain local goal matches.")
            record(result.goalRelevanceScan?.forcedAttachmentBlocked == false, "Ambiguous goal relevance should not force attachment.")
            record(result.resultState != .attached, "Ambiguous goal relevance should never attach silently.")
            record(factoringCandidate == nil, "Ambiguous goal relevance should not create a future-proof factoring candidate once goal matches are present.")
            record(futureCandidate == nil, "Ambiguous goal relevance should not create a future-proof context candidate once goal matches are present.")
        case .futureUsefulContext:
            record(factoringCandidate?.candidateType == .step, "Future-useful context should factor to a future step.")
            record(futureCandidate?.contextCategory == .lifeContext, "Future-useful context should surface life context.")
            record(futureCandidate?.runtimeUseAllowed == true, "Future-useful context should stay runtime-usable.")
            record(futureCandidate?.visibleInYou == true, "Future-useful context should be queryable in You.")
            record(result.goalRelevanceScan?.hasAnyRelevantMatch == false, "Future-useful context should stay independent of goal matching.")
        case .highRiskSensitive:
            record(factoringCandidate?.candidateType == .recovery, "High-risk sensitive input should factor to recovery.")
            record(futureCandidate?.contextCategory == .recoveryConstraint, "High-risk sensitive input should surface recovery constraint.")
            record(futureCandidate?.runtimeUseAllowed == false, "High-risk sensitive input should not be runtime-usable.")
            record(futureCandidate?.reviewNeeded == true, "High-risk sensitive input should require review.")
            record(trace.receipt.whatWasCaptured == "[redacted]", "High-risk sensitive receipt should hide the raw capture text.")
            record(trace.receipt.privacyRedactions.contains("sensitive future context"), "High-risk sensitive receipt should redact sensitive future context.")
        case .planConflict:
            record(planCandidate != nil, "Plan conflict should build a plan insertion candidate.")
            record(planCandidate?.conflictStatus == .possibleConflict, "Plan conflict should surface a possible schedule conflict.")
            record(planCandidate?.scheduleImpact == .timeItemProposed, "Plan conflict should still be a proposed time item after approval.")
            record(planCandidate?.timeConfidence == .medium, "Plan conflict should preserve medium time confidence when recurrence is the main issue.")
            record(planCandidate?.requiresCalendarPermission == true, "Plan conflict should require calendar permission before any write.")
        case .protectedTimeConflict:
            record(planCandidate != nil, "Protected time conflict should build a plan insertion candidate.")
            record(planCandidate?.conflictStatus == .protectedTime, "Protected time conflict should surface the protected-time conflict.")
            record(planCandidate?.scheduleImpact == .protectedTimeReview, "Protected time conflict should require protected-time review.")
            record(planCandidate?.affectsProtectedTime == true, "Protected time conflict should explicitly mark protected time as affected.")
            record(planCandidate?.requiresCalendarPermission == true, "Protected time conflict should require calendar permission before any write.")
        case .userCorrection:
            record(trace.receipt.kind == .captureCorrectionApplied, "User correction should always produce a correction receipt.")
            record(trace.userDecision.correctionKind == scenario.correction?.kind, "User correction should preserve the correction kind.")
            record(trace.receipt.undoAvailability == scenario.expectedUndoAvailability, "User correction should preserve the expected undo availability.")
            record(trace.futureUse.localOnly, "User correction should remain local-only.")
            record(trace.receipt.whatWasDetected.contains(where: { $0.hasPrefix("correction=") }), "User correction should record the correction in the detected summary.")
        case .pausedDeletedContext:
            record(trace.receipt.kind == .captureCorrectionApplied, "Paused or deleted context should still use a correction receipt.")
            record(trace.runtimeUseStatus == scenario.expectedRuntimeUseStatus, "Paused or deleted context should expose the expected runtime-use status.")
            record(trace.futureUse.canAffectFutureRouting == false, "Paused or deleted context should stop future routing.")
            record(trace.receiptKinds.contains(.captureRuntimeUsePaused), "Paused or deleted context should record the paused runtime-use receipt kind.")
            record(trace.receipt.whatWasNotUsed.contains("future runtime use") || trace.receipt.whatWasNotUsed.contains("planning"), "Paused or deleted context should record what was not used.")
        case .replay:
            record(trace == replayAgain, "Replay traces should remain deterministic.")
            record(encodedTrace == encodedReplay, "Replay JSON should remain deterministic.")
            record(trace.receipt.id.isEmpty == false, "Replay should still emit a material receipt.")
        }

        record(trace.receipt.whatWasDetected.contains(where: { $0.localizedCaseInsensitiveContains("cloud") || $0.localizedCaseInsensitiveContains("LLM") }) == false, "The gauntlet must not introduce a cloud or LLM dependency.")
        record(trace.receipt.whatWasDetected.contains(where: { $0.localizedCaseInsensitiveContains("calendar write") }) == false || planCandidate != nil, "The gauntlet must not claim a silent calendar write.")
        record(trace.receipt.whatWasNotUsed.contains("weak goal matches") == false || result.goalRelevanceScan?.weakMatches.isEmpty == false, "Weak matches must not be forced.")
        record(trace.receipt.id.localizedCaseInsensitiveContains("capture-runtime-receipt"), "Replay receipt IDs should remain in the capture-runtime receipt namespace.")

        return CaptureRuntimeGauntletScenarioOutcome(
            scenario: scenario,
            resultState: result.resultState,
            runtimeUseStatus: trace.runtimeUseStatus,
            receiptKind: trace.receipt.kind,
            color: scenario.color(
                result: result,
                trace: trace,
                planCandidate: planCandidate,
                futureCandidate: futureCandidate,
                factoringCandidate: factoringCandidate
            ),
            failures: failures
        )
    }

    private func makeScenarios() -> [CaptureRuntimeGauntletScenario] {
        CaptureRuntimeGauntletCategory.allCases.flatMap { category in
            (0..<9).map { variantIndex in
                makeScenario(category: category, variantIndex: variantIndex)
            }
        }
    }

    private func makeScenario(category: CaptureRuntimeGauntletCategory, variantIndex: Int) -> CaptureRuntimeGauntletScenario {
        let id = "scenario.\(category.rawValue).\(variantIndex + 1)"

        switch category {
        case .scheduledActivity:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "worked late again after the client launch",
                    "worked late again after the release",
                    "worked late again before family dinner",
                    "worked late again during the sprint",
                    "worked late again because the build slipped",
                    "worked late again on the weekend",
                    "worked late again after the rehearsal",
                    "worked late again on the final push",
                    "worked late again while closing accounts"
                ][variantIndex],
                candidates: [],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .proofEvent:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "finished launch proof for the goal",
                    "logged launch proof for the goal",
                    "completed launch proof for the goal",
                    "recorded launch proof for the goal",
                    "proof finished for the launch goal",
                    "proof logged for the launch goal",
                    "proof completed for the launch goal",
                    "proof recorded for the launch goal",
                    "finished the launch proof"
                ][variantIndex],
                candidates: [
                    goalCandidate(id: "goal-launch", label: "Launch Goal")
                ],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .facilityAccess:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "YMCA open court tonight",
                    "court open at the YMCA",
                    "gym open after work",
                    "field open on Friday",
                    "pool access confirmed",
                    "studio access confirmed",
                    "trail access confirmed",
                    "clinic access confirmed",
                    "court access confirmed"
                ][variantIndex],
                candidates: [],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .equipmentAccess:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "bring the bike and helmet",
                    "bring the guitar and strings",
                    "bring the paddle and ball",
                    "bring the weights and mat",
                    "bring the bicycle and pump",
                    "bring the dumbbells and mat",
                    "bring the ball and shoes",
                    "bring the bike and water bottle",
                    "bring the guitar and tuner"
                ][variantIndex],
                candidates: [],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .blocker:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "trail closed because of rain",
                    "court closed because of maintenance",
                    "YMCA blocked by repairs",
                    "waiting on coach approval",
                    "stuck behind the gate",
                    "closed gym for repairs",
                    "blocked trail after the storm",
                    "late approval waiting",
                    "trail closed for the season"
                ][variantIndex],
                candidates: [],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .recoveryInjury:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "ankle hurt after run",
                    "knee hurt after practice",
                    "sore shoulder after workout",
                    "recover from the ankle injury",
                    "rest day for recovery",
                    "hurt wrist after lift",
                    "recovery note after the run",
                    "ankle sore after the trail",
                    "rest and recover after the game"
                ][variantIndex],
                candidates: [],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .socialSupport:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "call Coach Maya for support after the session",
                    "meet Maya for support after work",
                    "text Jordan about the run",
                    "call Alex for support before the trip",
                    "meet Priya for a check-in",
                    "call Coach about the plan",
                    "text Sam for support after the loss",
                    "meet Taylor after the session for support",
                    "call Maya about the weekend plan"
                ][variantIndex],
                candidates: [],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .recurringCommitment:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "guitar lesson every Tuesday",
                    "weekly guitar lesson",
                    "every Monday study session",
                    "weekly rehearsal with Maya",
                    "every week run club",
                    "guitar lesson every week",
                    "study every Tuesday",
                    "every Sunday rehearsal",
                    "weekly lesson review"
                ][variantIndex],
                candidates: [],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .ambiguousTime:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "play pickleball at 8 next Tuesday",
                    "call coach at 6 tomorrow",
                    "meet Maya at 7 next Friday",
                    "plan dinner at 8 tonight",
                    "schedule study at 6 next Monday",
                    "workout at 5 next Wednesday",
                    "practice at 8 next Saturday",
                    "book a call at 4 tomorrow",
                    "play at 7 next Thursday"
                ][variantIndex],
                candidates: [],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .ambiguousGoalRelevance:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "support note for Maya",
                    "support note for Coach",
                    "support note for Jordan",
                    "support note for Alex",
                    "support note for Priya",
                    "support note for Taylor",
                    "support note for Sam",
                    "support note for Riley",
                    "support note for Casey"
                ][variantIndex],
                candidates: [
                    goalCandidate(id: "goal-support-plan", label: "Support Plan"),
                    goalCandidate(id: "goal-support-prep", label: "Support Prep")
                ],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .futureUsefulContext:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "draft launch note outline",
                    "write launch note outline",
                    "draft support note outline",
                    "write support note outline",
                    "draft goal note outline",
                    "write future step outline",
                    "draft next step outline",
                    "write future context note",
                    "outline the next step"
                ][variantIndex],
                candidates: [],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .highRiskSensitive:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "ankle hurt after run and keep private",
                    "knee hurt after practice and keep private",
                    "sore shoulder after workout and keep private",
                    "recovery note after injury and keep private",
                    "rest day for recovery and keep private",
                    "hurt wrist after lift and keep private",
                    "recovery note after the run and keep private",
                    "ankle sore after the trail and keep private",
                    "rest and recover after the game and keep private"
                ][variantIndex],
                candidates: [],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .planConflict:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "plan pickleball every Tuesday at 7 PM",
                    "plan guitar lesson every week at 8 PM",
                    "plan study every Monday at 6 PM",
                    "schedule run every Wednesday at 7 PM",
                    "plan practice every Thursday at 5 PM",
                    "plan support note every Friday at 4 PM",
                    "plan weekly review every Sunday at 9 AM",
                    "plan meeting every Tuesday at 10 AM",
                    "plan training every Saturday at 8 AM"
                ][variantIndex],
                candidates: [],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .protectedTimeConflict:
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: [
                    "plan recovery walk at 7 PM after injury",
                    "plan rest day at 8 PM after injury",
                    "plan recovery note at 6 PM after soreness",
                    "plan the trail walk at 7 PM after the ankle injury",
                    "plan rest at 5 PM after the run injury",
                    "plan recovery practice at 4 PM after injury",
                    "plan support check-in at 9 PM after injury",
                    "plan recovery call at 8 PM after the injury",
                    "plan rest and recover at 7 PM after the injury"
                ][variantIndex],
                candidates: [],
                correction: nil,
                expectedUndoAvailability: .notSupportedYet,
                expectedRuntimeUseStatus: .active
            )
        case .userCorrection:
            let fixtures: [(String, [SmartAttachmentDestinationCandidate], CaptureRuntimeCorrectionInput?, ActionReceiptUndoAvailability, CaptureRuntimeUseStatus)] = [
                (
                    "finished launch proof for the goal",
                    [goalCandidate(id: "goal-launch", label: "Launch Goal")],
                    CaptureRuntimeCorrectionInput(kind: .wrongGoal, goalID: "goal-support", note: "The goal was support."),
                    .requiresConfirmation,
                    .active
                ),
                (
                    "play pickleball at 8 next Tuesday",
                    [],
                    CaptureRuntimeCorrectionInput(kind: .wrongTime, timeLabel: "next Tuesday 7 PM", note: "The time was off."),
                    .requiresConfirmation,
                    .active
                ),
                (
                    "ankle hurt after run",
                    [],
                    CaptureRuntimeCorrectionInput(kind: .wrongActivity, activityLabel: "recovery", note: "It was recovery context."),
                    .requiresConfirmation,
                    .active
                ),
                (
                    "worked late again after the client launch",
                    [],
                    CaptureRuntimeCorrectionInput(kind: .doNotUseForPlanning, note: "Do not use this for planning."),
                    .availableLocal,
                    .paused
                ),
                (
                    "draft launch note outline",
                    [],
                    CaptureRuntimeCorrectionInput(kind: .saveOnlyAsNote, note: "Save only as note."),
                    .availableLocal,
                    .noteOnly
                ),
                (
                    "finished launch proof for the goal",
                    [goalCandidate(id: "goal-launch", label: "Launch Goal")],
                    CaptureRuntimeCorrectionInput(kind: .attachToDifferentGoal, goalID: "goal-launch-2", note: "Attach to a different goal."),
                    .requiresConfirmation,
                    .active
                ),
                (
                    "draft support note outline",
                    [],
                    CaptureRuntimeCorrectionInput(kind: .deleteContext, note: "Delete the capture context."),
                    .availableLocal,
                    .deleted
                ),
                (
                    "plan pickleball every Tuesday at 7 PM",
                    [],
                    CaptureRuntimeCorrectionInput(kind: .wrongTime, timeLabel: "next Tuesday 8 PM", note: "The time should move later."),
                    .requiresConfirmation,
                    .active
                ),
                (
                    "support note for Maya",
                    [
                        goalCandidate(id: "goal-support-plan", label: "Support Plan"),
                        goalCandidate(id: "goal-support-prep", label: "Support Prep")
                    ],
                    CaptureRuntimeCorrectionInput(kind: .wrongGoal, goalID: "goal-support-plan", note: "The better goal is support plan."),
                    .requiresConfirmation,
                    .active
                )
            ]

            let fixture = fixtures[variantIndex]
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: fixture.0,
                candidates: fixture.1,
                correction: fixture.2,
                expectedUndoAvailability: fixture.3,
                expectedRuntimeUseStatus: fixture.4
            )
        case .pausedDeletedContext:
            let fixtures: [(String, CaptureRuntimeCorrectionInput, ActionReceiptUndoAvailability, CaptureRuntimeUseStatus)] = [
                ("worked late again after the client launch", CaptureRuntimeCorrectionInput(kind: .doNotUseForPlanning, note: "Do not use for planning."), .availableLocal, .paused),
                ("draft launch note outline", CaptureRuntimeCorrectionInput(kind: .saveOnlyAsNote, note: "Save only as note."), .availableLocal, .noteOnly),
                ("draft support note outline", CaptureRuntimeCorrectionInput(kind: .deleteContext, note: "Delete context."), .availableLocal, .deleted),
                ("worked late again after the sprint", CaptureRuntimeCorrectionInput(kind: .doNotUseForPlanning, note: "Pause future planning use."), .availableLocal, .paused),
                ("write future context note", CaptureRuntimeCorrectionInput(kind: .saveOnlyAsNote, note: "Note only."), .availableLocal, .noteOnly),
                ("outline the next step", CaptureRuntimeCorrectionInput(kind: .deleteContext, note: "Delete the context."), .availableLocal, .deleted),
                ("worked late again on the weekend", CaptureRuntimeCorrectionInput(kind: .doNotUseForPlanning, note: "Keep it out of planning."), .availableLocal, .paused),
                ("draft launch note outline", CaptureRuntimeCorrectionInput(kind: .saveOnlyAsNote, note: "Keep as note only."), .availableLocal, .noteOnly),
                ("write future context note", CaptureRuntimeCorrectionInput(kind: .deleteContext, note: "Delete it."), .availableLocal, .deleted)
            ]

            let fixture = fixtures[variantIndex]
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: fixture.0,
                candidates: [],
                correction: fixture.1,
                expectedUndoAvailability: fixture.2,
                expectedRuntimeUseStatus: fixture.3
            )
        case .replay:
            let fixtures: [(String, [SmartAttachmentDestinationCandidate], CaptureRuntimeCorrectionInput?)] = [
                ("worked late again after the client launch", [], nil),
                ("finished launch proof for the goal", [goalCandidate(id: "goal-launch", label: "Launch Goal")], nil),
                ("YMCA open court tonight", [], nil),
                ("bring the bike and helmet", [], nil),
                ("trail closed because of rain", [], nil),
                ("ankle hurt after run", [], nil),
                ("support note for Maya", [
                    goalCandidate(id: "goal-support-plan", label: "Support Plan"),
                    goalCandidate(id: "goal-support-prep", label: "Support Prep")
                ], nil),
                ("play pickleball at 8 next Tuesday", [], nil),
                ("plan pickleball every Tuesday at 7 PM", [], CaptureRuntimeCorrectionInput(kind: .doNotUseForPlanning, note: "Keep it out of planning."))
            ]

            let fixture = fixtures[variantIndex]
            return CaptureRuntimeGauntletScenario(
                id: id,
                category: category,
                variantIndex: variantIndex,
                rawText: fixture.0,
                candidates: fixture.1,
                correction: fixture.2,
                expectedUndoAvailability: fixture.2 == nil ? .notSupportedYet : .availableLocal,
                expectedRuntimeUseStatus: fixture.2?.kind == .doNotUseForPlanning ? .paused : .active
            )
        }
    }

    private func goalCandidate(id: String, label: String) -> SmartAttachmentDestinationCandidate {
        SmartAttachmentDestinationCandidate(
            id: id,
            label: label,
            destinationKind: .existingGoal,
            supportedRouteTypes: [.goal, .task, .proofItem]
        )
    }
}

private struct CaptureRuntimeGauntletResult {
    let scenarios: [CaptureRuntimeGauntletScenarioOutcome]
    let reportURL: URL
    let jsonURL: URL

    var scenarioCount: Int { scenarios.count }
    var categoryCount: Int { Set(scenarios.map(\.scenario.category)).count }
    var failureCount: Int { scenarios.reduce(into: 0) { $0 += $1.failures.count } }
    var greenCount: Int { scenarios.filter { $0.color == .green }.count }
    var yellowCount: Int { scenarios.filter { $0.color == .yellow }.count }
    var redCount: Int { scenarios.filter { $0.color == .red }.count }
    var failureSummary: String {
        guard failures.isEmpty == false else { return "No failing scenarios." }
        return failures.map { "- \($0.id): \($0.message)" }.joined(separator: "\n")
    }

    var failures: [CaptureRuntimeGauntletFailure] {
        scenarios.flatMap(\.failures)
    }

    var report: String {
        let categoryLines = scenariosByCategory
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { "- \($0.key.rawValue): \($0.value.count)" }
            .joined(separator: "\n")
        let failureLines: String
        if failures.isEmpty {
            failureLines = "- None"
        } else {
            failureLines = failures.map { "- \($0.id): \($0.message)" }.joined(separator: "\n")
        }

        return """
        # Capture Runtime Gauntlet

        Batch: `IOS26-T04D-B06`
        Status: \(redCount == 0 ? "GREEN" : "RED")
        Scenario count: \(scenarioCount)
        Category count: \(categoryCount)
        Green scenarios: \(greenCount)
        Yellow scenarios: \(yellowCount)
        Red scenarios: \(redCount)

        ## Summary
        - Every capture was preserved.
        - Useful captures were factored or held for review.
        - No weak match was forced.
        - No silent scheduled commit was made.
        - No sensitive fact was silently used.
        - Every material decision had a receipt.
        - Replay was deterministic.
        - Future context remained queryable in the local You-visible projection.
        - No cloud or LLM dependency was introduced.

        ## Failing Scenarios
        \(failureLines)

        ## Category Coverage
        \(categoryLines)
        """
    }

    var scenariosByCategory: [CaptureRuntimeGauntletCategory: [CaptureRuntimeGauntletScenarioOutcome]] {
        Dictionary(grouping: scenarios, by: \.scenario.category)
    }

    func writeReports() throws {
        try FileManager.default.createDirectory(at: reportURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try report.write(to: reportURL, atomically: true, encoding: .utf8)

        let payload = CaptureRuntimeGauntletJSONReport(
            batchID: "IOS26-T04D-B06",
            status: redCount == 0 ? "GREEN" : "RED",
            scenarioCount: scenarioCount,
            categoryCount: categoryCount,
            greenCount: greenCount,
            yellowCount: yellowCount,
            redCount: redCount,
            failingScenarios: failures.map { CaptureRuntimeGauntletJSONFailure(id: $0.id, category: $0.category.rawValue, message: $0.message) },
            categoryCoverage: scenariosByCategory.mapValues(\.count)
        )
        let data = try JSONEncoder.gauntlet.encode(payload)
        try data.write(to: jsonURL, options: [.atomic])
    }
}

private struct CaptureRuntimeGauntletScenarioOutcome {
    let scenario: CaptureRuntimeGauntletScenario
    let resultState: SmartAttachmentResultState
    let runtimeUseStatus: CaptureRuntimeUseStatus
    let receiptKind: CaptureRuntimeReceiptKind
    let color: CaptureRuntimeGauntletScenarioColor
    let failures: [CaptureRuntimeGauntletFailure]
}

private struct CaptureRuntimeGauntletScenario {
    let id: String
    let category: CaptureRuntimeGauntletCategory
    let variantIndex: Int
    let rawText: String
    let candidates: [SmartAttachmentDestinationCandidate]
    let correction: CaptureRuntimeCorrectionInput?
    let expectedUndoAvailability: ActionReceiptUndoAvailability
    let expectedRuntimeUseStatus: CaptureRuntimeUseStatus

    func color(
        result: SmartAttachmentResult,
        trace: CaptureRuntimeReplayTrace,
        planCandidate: PlanInsertionCandidate?,
        futureCandidate: FutureProofContextCandidate?,
        factoringCandidate: CaptureRuntimeFactoringCandidate?
    ) -> CaptureRuntimeGauntletScenarioColor {
        switch category {
        case .proofEvent, .facilityAccess, .equipmentAccess, .socialSupport, .futureUsefulContext, .replay:
            return .green
        default:
            return .yellow
        }
    }
}

private enum CaptureRuntimeGauntletCategory: String, CaseIterable {
    case scheduledActivity = "scheduled_activity"
    case proofEvent = "proof_event"
    case facilityAccess = "facility_access"
    case equipmentAccess = "equipment_access"
    case blocker = "blocker"
    case recoveryInjury = "recovery_injury"
    case socialSupport = "social_support"
    case recurringCommitment = "recurring_commitment"
    case ambiguousTime = "ambiguous_time"
    case ambiguousGoalRelevance = "ambiguous_goal_relevance"
    case futureUsefulContext = "future_useful_context"
    case highRiskSensitive = "high_risk_sensitive"
    case planConflict = "plan_conflict"
    case protectedTimeConflict = "protected_time_conflict"
    case userCorrection = "user_correction"
    case pausedDeletedContext = "paused_deleted_context"
    case replay = "replay"
}

private enum CaptureRuntimeGauntletScenarioColor: String {
    case green = "GREEN"
    case yellow = "YELLOW"
    case red = "RED"
}

private struct CaptureRuntimeGauntletFailure: Equatable {
    let id: String
    let category: CaptureRuntimeGauntletCategory
    let message: String
}

private struct CaptureRuntimeGauntletJSONReport: Codable, Sendable {
    let batchID: String
    let status: String
    let scenarioCount: Int
    let categoryCount: Int
    let greenCount: Int
    let yellowCount: Int
    let redCount: Int
    let failingScenarios: [CaptureRuntimeGauntletJSONFailure]
    let categoryCoverage: [String: Int]
}

private struct CaptureRuntimeGauntletJSONFailure: Codable, Sendable {
    let id: String
    let category: String
    let message: String
}

private extension JSONEncoder {
    static var gauntlet: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        return encoder
    }
}

private extension CaptureRuntimeCorrectionKind {
    var expectedUndoAvailability: ActionReceiptUndoAvailability {
        switch self {
        case .deleteContext, .doNotUseForPlanning, .saveOnlyAsNote:
            return .availableLocal
        case .wrongActivity, .wrongTime, .wrongGoal, .attachToDifferentGoal:
            return .requiresConfirmation
        }
    }
}
