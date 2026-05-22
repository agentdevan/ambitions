import XCTest
@testable import Ambitions

final class GoalIntentCompilerModelsTests: XCTestCase {
    func testClearIntentCompilesDeterministicallyToPlanAndStepCandidates() throws {
        let intent = sampleIntent()
        let input = samplePath(
            posture: .stronger,
            safeForStarterPlanning: true,
            ambiguityActive: false,
            alternateInterpretationsActive: false,
            missingContextFields: []
        )
            .makeGoalIntentDayCompilerInput(intent: intent)

        let planStep = PlanStep(
            id: "plan-step-1",
            title: "Frame the work",
            summary: "Write the smallest visible first pass.",
            pace: .untimed,
            evidenceHint: "The smallest visible first pass is written."
        )
        let step = Step(
            id: "step-1",
            sectionID: "today",
            title: "Do the first visible pass",
            summary: "Complete the smallest visible version.",
            type: .actionUnit,
            state: .planned,
            owner: .localOwner,
            timing: GoalTiming(
                tempo: .targetWindow,
                timingType: .targetBy,
                startsOn: nil,
                dueAt: "2026-05-22T18:13:20Z",
                targetBy: nil,
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: nil,
                repeatEveryDays: nil,
                progressReviewCadenceDays: 7
            ),
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["The first visible pass is complete."],
            actionability: StepActionability(
                action: "Do the first visible pass",
                completionDefinition: "The smallest visible version is complete.",
                evidenceOfCompletion: ["The smallest visible version is complete."],
                fallbackMicroStep: "Write the smallest visible first pass.",
                contextRequirements: ["Keep it local."]
            )
        )

        let compiledSteps = [planStep.compiledStep, step.compiledStep]
        let output = input.makeOutput(compiledSteps: compiledSteps, compiledAt: "2026-05-22T18:13:20Z")

        XCTAssertEqual(output.status, .clear)
        XCTAssertTrue(output.localOnly)
        XCTAssertEqual(output.compiledSteps.map(\.id), ["plan-step-1", "step-1"])
        XCTAssertEqual(output.planSteps.map(\.id), ["plan-step-1", "step-1"])
        XCTAssertEqual(output.makeSteps(sectionID: "today").map(\.id), ["plan-step-1", "step-1"])
        XCTAssertEqual(output.receipts.map(\.compiledStepID), ["plan-step-1", "step-1"])
        XCTAssertEqual(output.planSteps.first, planStep)
        XCTAssertEqual(output.planSteps.first?.evidenceHint, "The smallest visible first pass is written.")
        XCTAssertEqual(output.makeSteps(sectionID: "today")[1].actionability.completionDefinition, "The smallest visible version is complete.")
    }

    func testAmbiguousIntentPreservesAssumptionsAndClarificationPrompts() throws {
        let intent = sampleIntent()
        let path = samplePath(
            posture: .provisional,
            safeForStarterPlanning: true,
            ambiguityActive: true,
            alternateInterpretationsActive: true,
            missingContextFields: [.goalShape],
            blockingReasons: [],
            assumptions: [
                GoalCompiledPathAssumption(
                    id: "assumption-1",
                    summary: "Use the conservative first pass.",
                    rationale: "Ambiguity should stay visible.",
                    confidence: .medium,
                    source: .derivedContract,
                    relatedField: .goalShape,
                    safeForCompilation: true
                )
            ]
        )
        let input = path.makeGoalIntentDayCompilerInput(intent: intent)
        let compiledSteps = path.makeCompiledSteps(intentID: intent.id)
        let output = input.makeOutput(compiledSteps: compiledSteps, compiledAt: "2026-05-22T18:13:20Z")

        XCTAssertEqual(output.status, .ambiguous)
        XCTAssertTrue(output.compiledSteps.first?.isExecutable == true)
        XCTAssertEqual(output.assumptions.map(\.id), ["assumption-1"])
        XCTAssertEqual(output.clarification.status, .ambiguous)
        XCTAssertEqual(output.clarification.questions.map(\.targetField), [.goalShape])
        XCTAssertFalse(output.clarification.questions.first?.blocking ?? true)
        XCTAssertEqual(output.receipts.first?.status, .ambiguous)
        XCTAssertTrue(output.receipts.first?.reason.contains("Deterministic local-first compilation.") == true)
    }

    func testBlockedIntentEmitsBlockedReasonsAndNoExecutableDailyStep() throws {
        let intent = sampleIntent()
        let path = samplePath(
            posture: .blocked,
            safeForStarterPlanning: false,
            ambiguityActive: true,
            alternateInterpretationsActive: false,
            missingContextFields: [.successDefinition],
            blockingReasons: [
                GoalCompiledPathBlockingReason(
                    id: "block-1",
                    summary: "Clarify what success looks like.",
                    field: .successDefinition
                )
            ]
        )
        let input = path.makeGoalIntentDayCompilerInput(intent: intent)
        let output = input.makeOutput(compiledSteps: path.makeCompiledSteps(intentID: intent.id), compiledAt: "2026-05-22T18:13:20Z")

        XCTAssertEqual(output.status, .blocked)
        XCTAssertTrue(output.compiledSteps.isEmpty)
        XCTAssertEqual(output.blockedReasons.map(\.id), ["block-1"])
        XCTAssertEqual(output.clarification.status, .blocked)
        XCTAssertEqual(output.clarification.missingFields.map(\.field), [.successDefinition])
        XCTAssertEqual(output.receipts.count, 1)
        XCTAssertEqual(output.receipts.first?.compiledStepID, "blocked")
        XCTAssertEqual(output.receipts.first?.status, .blocked)
        XCTAssertTrue(output.receipts.first?.reason.contains("Clarify what success looks like.") == true)
    }

    func testGoalIntentCompilerContractsRoundTripThroughCodable() throws {
        let intent = sampleIntent()
        let path = samplePath(
            posture: .provisional,
            safeForStarterPlanning: true,
            ambiguityActive: true,
            alternateInterpretationsActive: true,
            missingContextFields: [.goalShape]
        )
        let input = path.makeGoalIntentDayCompilerInput(intent: intent)
        let output = input.makeOutput(
            compiledSteps: path.makeCompiledSteps(intentID: intent.id),
            compiledAt: "2026-05-22T18:13:20Z"
        )

        let encodedInput = try JSONEncoder().encode(input)
        let decodedInput = try JSONDecoder().decode(GoalIntentDayCompilerInput.self, from: encodedInput)
        let encodedOutput = try JSONEncoder().encode(output)
        let decodedOutput = try JSONDecoder().decode(GoalIntentDayCompilerOutput.self, from: encodedOutput)

        XCTAssertEqual(decodedInput, input)
        XCTAssertEqual(decodedOutput, output)
    }

    func testCompilerContractsStayLocalOnlyAndDoNotExposeCloudBackendOrRuntimeMutationFields() {
        let intent = sampleIntent()
        let path = samplePath(
            posture: .provisional,
            safeForStarterPlanning: true,
            ambiguityActive: true,
            alternateInterpretationsActive: true,
            missingContextFields: [.goalShape]
        )
        let input = path.makeGoalIntentDayCompilerInput(intent: intent)
        let output = input.makeOutput(compiledSteps: path.makeCompiledSteps(intentID: intent.id), compiledAt: "2026-05-22T18:13:20Z")

        let inputLabels = Mirror(reflecting: input).children.compactMap(\.label)
        let outputLabels = Mirror(reflecting: output).children.compactMap(\.label)
        let forbiddenFragments = ["cloud", "backend", "network", "llm", "persistence", "autoActivation", "planMutation"]

        XCTAssertTrue(input.localOnly)
        XCTAssertTrue(output.localOnly)
        XCTAssertFalse(inputLabels.contains { label in
            forbiddenFragments.contains { label.localizedCaseInsensitiveContains($0) }
        })
        XCTAssertFalse(outputLabels.contains { label in
            forbiddenFragments.contains { label.localizedCaseInsensitiveContains($0) }
        })
    }
}

private extension GoalIntentCompilerModelsTests {
    func sampleIntent() -> GoalIntent {
        let draft = GoalBlueprint(title: "Ship the intent compiler").makeDraft()

        return draft.makeGoalIntent(
            id: "intent-1",
            createdAt: "2026-05-22T18:13:20Z",
            sourceSurface: .goals,
            privacyClass: .localOnly,
            sourceState: .draft
        )
    }

    func samplePath(
        posture: GoalPathCompilePosture,
        safeForStarterPlanning: Bool,
        ambiguityActive: Bool,
        alternateInterpretationsActive: Bool,
        missingContextFields: [MissingFieldKey],
        blockingReasons: [GoalCompiledPathBlockingReason] = [],
        assumptions: [GoalCompiledPathAssumption] = []
    ) -> GoalCompiledPath {
        let stages = [
            GoalCompiledPathStage(
                id: "stage-setup",
                title: "Frame the work",
                summary: "Write the smallest visible first pass.",
                orderIndex: 0,
                kind: .setup,
                dependencyIDs: [],
                prerequisiteHints: ["Keep it local."],
                readinessHints: ["The first visible pass can be written now."],
                uncertainBecause: ambiguityActive ? [.activeAmbiguity] : []
            ),
            GoalCompiledPathStage(
                id: "stage-first-proof",
                title: "Produce the first proof",
                summary: "Complete one inspectable step.",
                orderIndex: 1,
                kind: .firstProof,
                dependencyIDs: ["stage-setup"],
                prerequisiteHints: ["The first visible pass is written."],
                readinessHints: ["The step can be checked locally."],
                uncertainBecause: ambiguityActive ? [.missingContext] : []
            )
        ]

        let candidate = GoalCompiledPathCandidate(
            id: "candidate-primary",
            title: "Primary path",
            summary: "Compile the conservative first path.",
            isPrimary: true,
            posture: posture,
            safeForStarterPlanning: safeForStarterPlanning,
            stages: stages,
            dependencies: [],
            branches: [],
            assumptions: assumptions,
            risks: [],
            blockingReasons: blockingReasons,
            confidence: GoalCompiledPathConfidence(
                overall: .medium,
                score: 0.72,
                uncertaintyTags: ambiguityActive ? ["ambiguity_active"] : []
            )
        )

        return GoalCompiledPath(
            schemaVersion: goalPathCompilerSchemaVersion,
            sourceUnderstandingSchemaVersion: goalUnderstandingSchemaVersion,
            overallPosture: posture,
            safeForStarterPlanning: safeForStarterPlanning,
            candidates: [candidate],
            uncertainty: GoalCompiledPathUncertainty(
                ambiguityActive: ambiguityActive,
                missingContextFields: missingContextFields,
                unresolvedQuestionIDs: ambiguityActive ? ["question-1"] : [],
                alternateInterpretationsActive: alternateInterpretationsActive,
                knowledgeContextAttached: false,
                knowledgeContextRequired: false
            ),
            audit: GoalCompiledPathAuditMetadata(
                entries: [
                    GoalCompiledPathAuditEntry(
                        id: "audit-1",
                        kind: .interpretationSelection,
                        sourceInterpretationID: "interp-1",
                        sourceDependencyID: nil,
                        sourceRiskID: nil,
                        sourceAssumptionID: assumptions.first?.id,
                        claimID: nil,
                        sourceRecordID: nil,
                        summary: "Primary interpretation selected."
                    )
                ],
                packEntries: []
            )
        )
    }
}
