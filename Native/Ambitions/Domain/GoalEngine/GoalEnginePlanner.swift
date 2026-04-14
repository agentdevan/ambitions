import Foundation

protocol GoalPlanning: Sendable {
    func plan(input: GoalPlannerInput, options: GoalPlannerOptions) -> GoalPlannerResult
}

private struct PlannerSectionDraft {
    let title: String
    let summary: String
    let kind: PlanSectionKind
    let steps: [PlannerStepDraft]
}

private struct PlannerStepDraft {
    let title: String
    let summary: String?
    let type: StepType
    let timingType: TimingType
    let actionability: StepActionability
    var successSignals: [String] = []
    var isOptional: Bool = false
    var isRepeatable: Bool = false
    var repeatEveryDays: Int? = nil
    var dependencyStepIDs: [String] = []
    var dueAt: String? = nil
    var targetBy: String? = nil
    var suggestedNextAt: String? = nil
    var owner: GoalActor? = nil
}

struct GoalPlanner: GoalPlanning {
    func plan(input: GoalPlannerInput, options: GoalPlannerOptions = .init()) -> GoalPlannerResult {
        let now = options.now ?? "2026-04-14T12:00:00Z"
        let goalID = options.goalID ?? makeGoalID(from: input.draft.title)
        let readiness = input.classification?.readiness ?? input.clarification?.readiness ?? .readyForPlanning
        let missingFields = input.classification?.missingFields ?? input.clarification?.missingFields ?? []

        if readiness == .needsClarification {
            let blockers = missingFields
                .filter(\.blocksPlanning)
                .map { field in
                    GoalPlanningBlocker(
                        code: field.field.rawValue,
                        reason: field.reason,
                        suggestedQuestion: input.clarification?.questions.first(where: { $0.field == field.field })?.prompt
                    )
                }
            return .blocked(draft: input.draft, blockers: blockers, clarification: input.clarification)
        }

        let assumptions = readiness == .canPlanWithDefaults ? missingFields.map(makeAssumption) : []
        let strategyID: IntakePlanningStrategyID = assumptions.isEmpty
            ? (input.classification?.planningStrategyID.value ?? .lightweightTracking)
            : .lightweightTracking

        let sections = sectionDrafts(for: strategyID, draft: input.draft, now: now).enumerated().map { index, section in
            buildSection(from: section, goalID: goalID, draft: input.draft, orderIndex: index, now: now)
        }

        let emptyLint = PlanLintResult(goalID: goalID, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: [])
        var plan = GoalPlan(
            id: "\(goalID)-plan",
            goalID: goalID,
            version: goalEnginePlanVersion,
            generatedAt: now,
            summary: assumptions.isEmpty ? "Plan for \(input.draft.title)." : "Starter plan built with explicit assumptions so the next move is safe without pretending the goal is fully defined.",
            strategy: planStrategy(for: strategyID, draft: input.draft),
            sections: sections,
            assumptions: assumptions,
            lint: emptyLint
        )

        let lint = GoalContractValidator.lint(plan: plan)
        plan = GoalPlan(id: plan.id, goalID: plan.goalID, version: plan.version, generatedAt: plan.generatedAt, summary: plan.summary, strategy: plan.strategy, sections: plan.sections, assumptions: plan.assumptions, lint: lint)

        if assumptions.isEmpty {
            return .plan(draft: input.draft, plan: plan, lint: lint)
        }
        return .starterPlan(draft: input.draft, plan: plan, lint: lint, assumptions: assumptions)
    }

    private func makeGoalID(from title: String) -> String {
        let slug = title
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9]+"#, with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return "goal-\(slug.isEmpty ? "draft" : slug)"
    }

    private func makeAssumption(from missing: MissingField) -> PlanAssumption {
        switch missing.field {
        case .supportScope:
            return PlanAssumption(id: "assumption-support-scope", summary: "Assume light support rather than taking over execution.", rationale: "This preserves agency for the real executor.", confidence: .medium, relatedField: .supportScope)
        case .successDefinition:
            return PlanAssumption(id: "assumption-success-definition", summary: "Assume the first useful version should stay small and demonstrable.", rationale: "Starter planning needs a concrete win signal even when the finish line is broad.", confidence: .medium, relatedField: .successDefinition)
        case .timeHorizon:
            return PlanAssumption(id: "assumption-time-horizon", summary: "Keep timing light until the user chooses a horizon.", rationale: "The engine should not invent urgency the user did not ask for.", confidence: .medium, relatedField: .timeHorizon)
        case .goalShape:
            return PlanAssumption(id: "assumption-goal-shape", summary: "Assume stabilization and consistency come before expansion.", rationale: "Broad recovery goals are safer when sequenced around stability first.", confidence: .medium, relatedField: .goalShape)
        case .goalSubject:
            return PlanAssumption(id: "assumption-goal-subject", summary: "The goal subject remains unresolved.", rationale: missing.reason, confidence: .low, relatedField: .goalSubject)
        case .executorIdentity:
            return PlanAssumption(id: "assumption-executor-identity", summary: "The real executor is not yet known.", rationale: missing.reason, confidence: .low, relatedField: .executorIdentity)
        }
    }

    private func buildSection(from definition: PlannerSectionDraft, goalID: String, draft: GoalDraft, orderIndex: Int, now: String) -> PlanSection {
        let sectionID = "\(goalID)-section-\(definition.kind.rawValue)-\(orderIndex + 1)"
        let steps = definition.steps.enumerated().map { index, step in
            buildStep(from: step, sectionID: sectionID, draft: draft, index: index, now: now)
        }
        return PlanSection(id: sectionID, goalID: goalID, title: definition.title, summary: definition.summary, kind: definition.kind, orderIndex: orderIndex, steps: steps)
    }

    private func buildStep(from definition: PlannerStepDraft, sectionID: String, draft: GoalDraft, index: Int, now: String) -> Step {
        let owner = definition.owner ?? draft.actor
        return Step(
            id: "\(sectionID)-step-\(index + 1)",
            sectionID: sectionID,
            title: definition.title,
            summary: definition.summary,
            type: definition.type,
            state: .planned,
            owner: owner,
            timing: resolveTiming(definition: definition, draft: draft, now: now),
            dependencyStepIDs: definition.dependencyStepIDs,
            isOptional: definition.isOptional,
            isRepeatable: definition.isRepeatable,
            evidenceRequired: true,
            successSignals: definition.successSignals.isEmpty ? [definition.actionability.completionDefinition] : definition.successSignals,
            actionability: definition.actionability
        )
    }

    private func resolveTiming(definition: PlannerStepDraft, draft: GoalDraft, now: String) -> GoalTiming {
        switch definition.timingType {
        case .dueAt:
            return GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: definition.dueAt ?? draft.timing.dueAt, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: draft.timing.progressReviewCadenceDays)
        case .targetBy:
            return GoalTiming(tempo: .targetWindow, timingType: .targetBy, startsOn: nil, dueAt: nil, targetBy: definition.targetBy ?? draft.timing.targetBy ?? draft.timing.windowEnd, windowStart: draft.timing.windowStart, windowEnd: draft.timing.windowEnd, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: draft.timing.progressReviewCadenceDays)
        case .repeatWithinWindow:
            return GoalTiming(tempo: .ongoing, timingType: .repeatWithinWindow, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: definition.repeatEveryDays ?? draft.timing.repeatEveryDays ?? 7, progressReviewCadenceDays: draft.timing.progressReviewCadenceDays)
        case .logWhenDone:
            return GoalTiming(tempo: .untimed, timingType: .logWhenDone, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: draft.timing.progressReviewCadenceDays)
        case .suggestedNext:
            return GoalTiming(tempo: draft.timing.tempo == .ongoing ? .ongoing : .untimed, timingType: .suggestedNext, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: definition.suggestedNextAt ?? draft.timing.suggestedNextAt ?? now, repeatEveryDays: draft.timing.repeatEveryDays, progressReviewCadenceDays: draft.timing.progressReviewCadenceDays)
        }
    }

    private func planStrategy(for strategyID: IntakePlanningStrategyID, draft: GoalDraft) -> PlanningStrategy {
        switch strategyID {
        case .guidedSupport:
            return PlanningStrategy(strategyKind: .supportive, allowParallelSteps: true, maxActiveSteps: 3, preferredSectionOrder: [.supportingWork, .activeSteps, .review], defaultStepType: .supportAction, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .learningPath:
            return PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: true, maxActiveSteps: 4, preferredSectionOrder: [.overview, .activeSteps, .resources, .review], defaultStepType: .learningCheckpoint, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .discoveryMap:
            return PlanningStrategy(strategyKind: .exploratory, allowParallelSteps: true, maxActiveSteps: 4, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .explorationExperiment, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 5)
        case .routineBuilder:
            return PlanningStrategy(strategyKind: .cadence, allowParallelSteps: true, maxActiveSteps: 3, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .recurringRoutine, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .stabilizationPath:
            return PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: false, maxActiveSteps: 2, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .observationPrompt, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 4)
        case .lightweightTracking:
            return PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: true, maxActiveSteps: 2, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .actionUnit, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .milestonePlan:
            return draft.planningStrategy
        }
    }

    private func sectionDrafts(for strategyID: IntakePlanningStrategyID, draft: GoalDraft, now: String) -> [PlannerSectionDraft] {
        switch strategyID {
        case .guidedSupport:
            return guidedSupportSections(now: now)
        case .learningPath:
            return learningPathSections(subject: draft.summary ?? draft.title, now: now)
        case .discoveryMap:
            return discoveryMapSections(subject: draft.summary ?? draft.title, now: now)
        case .routineBuilder:
            return routineSections(subject: draft.summary ?? draft.title, repeatEveryDays: draft.timing.repeatEveryDays ?? 7)
        case .stabilizationPath:
            return stabilizationSections(subject: draft.summary ?? draft.title, now: now)
        case .lightweightTracking:
            return starterSections(subject: draft.summary ?? draft.title, now: now)
        case .milestonePlan:
            return milestoneSections(subject: draft.summary ?? draft.title, draft: draft, now: now)
        }
    }

    private func milestoneSections(subject: String, draft: GoalDraft, now: String) -> [PlannerSectionDraft] {
        [
            PlannerSectionDraft(title: "Milestones", summary: "Checkpoint definitions keep delivery work concrete without forcing giant steps.", kind: .overview, steps: [
                PlannerStepDraft(title: "Define the first visible milestone", summary: "Name the first milestone in a way that lets you tell whether it is reached.", type: .actionUnit, timingType: draft.timing.tempo == .deadlineBased ? .targetBy : .suggestedNext, actionability: actionability(action: "Write one sentence that defines the first visible milestone for \(subject.lowercased()).", completion: "You have a milestone sentence and a short checklist for what makes it count.", evidence: ["A saved note names the milestone and its signs."], micro: "Write the milestone name only, then add one sign."), targetBy: draft.timing.targetBy ?? draft.timing.windowEnd, suggestedNextAt: now),
                PlannerStepDraft(title: "Check what ready-to-finish will look like", summary: "This prevents late-stage thrash by defining the finish standard early.", type: .actionUnit, timingType: .logWhenDone, actionability: actionability(action: "List the three signs that would make the goal feel ready to finish rather than merely started.", completion: "Three finish signs are written in concrete language.", evidence: ["A short finish-sign list exists and can be reviewed later."], micro: "Write one finish sign and leave the rest for the next session."))
            ]),
            PlannerSectionDraft(title: "Next Steps", summary: "These are the session-sized actions that move the work immediately.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Complete one session-sized build slice", summary: "Advance the work with one bounded unit rather than a vague push.", type: .actionUnit, timingType: .suggestedNext, actionability: actionability(action: "Complete one bounded slice of the active workstream for \(subject.lowercased()).", completion: "One visible slice is finished and can be shown or described in a sentence.", evidence: ["A changed artifact, checklist mark, or progress note shows the slice is done."], micro: "Set up the file, tool, or materials needed for the slice."), suggestedNextAt: now),
                PlannerStepDraft(title: "Capture the next handoff or follow-up", summary: "Closing the loop prevents progress from getting lost between sessions.", type: .reflectionPrompt, timingType: .logWhenDone, actionability: actionability(action: "After the build slice, write the exact next thing that should happen next.", completion: "There is one explicit follow-up action written in plain language.", evidence: ["A follow-up note exists next to the completed slice."], micro: "Write a single next-action sentence."))
            ])
        ]
    }

    private func learningPathSections(subject: String, now: String) -> [PlannerSectionDraft] {
        [
            PlannerSectionDraft(title: "Skill Map", summary: "Break the learning goal into a small map before trying to master all of it.", kind: .overview, steps: [
                PlannerStepDraft(title: "Name the first sub-skill to practice", summary: "This keeps the first learning loop concrete.", type: .learningCheckpoint, timingType: .suggestedNext, actionability: actionability(action: "Pick the first sub-skill that would most increase confidence in \(subject.lowercased()).", completion: "One sub-skill is named in plain language.", evidence: ["A note names the sub-skill and why it comes first."], micro: "Write the sub-skill name only."), suggestedNextAt: now)
            ]),
            PlannerSectionDraft(title: "Practice Loop", summary: "The first loop should create signal, not pressure.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Run one focused practice session", summary: "Use one bounded session to get real evidence of understanding.", type: .learningCheckpoint, timingType: .suggestedNext, actionability: actionability(action: "Complete one short practice session focused on the chosen sub-skill.", completion: "One bounded practice session is finished and produces something reviewable.", evidence: ["A note, recording, worked example, or explanation exists."], micro: "Set a timer for one short practice block and start."), suggestedNextAt: now),
                PlannerStepDraft(title: "Review what still feels shaky", summary: "Checkpoint language should emphasize evidence rather than judgment.", type: .reflectionPrompt, timingType: .logWhenDone, actionability: actionability(action: "After practice, write the part that still feels unclear and the next question it creates.", completion: "One confusion point and one follow-up question are captured.", evidence: ["A checkpoint note records the confusion point and next question."], micro: "Write only the unclear part."))
            ])
        ]
    }

    private func discoveryMapSections(subject: String, now: String) -> [PlannerSectionDraft] {
        [
            PlannerSectionDraft(title: "Key Questions", summary: "Exploration stays honest when the questions are explicit before the experiments start.", kind: .overview, steps: [
                PlannerStepDraft(title: "Write the top questions that need evidence", summary: "Pick the questions that should guide the first experiments.", type: .reflectionPrompt, timingType: .logWhenDone, actionability: actionability(action: "List the two or three questions you need answered before narrowing \(subject.lowercased()).", completion: "A short question list exists and each question is answerable through observation or experiment.", evidence: ["A question list exists and the highest-priority question is marked."], micro: "Write the highest-priority question only."))
            ]),
            PlannerSectionDraft(title: "Experiments", summary: "Experiments should be small enough to learn from without pretending certainty is already earned.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Run one low-cost experiment", summary: "Choose one question and generate evidence within one session.", type: .explorationExperiment, timingType: .suggestedNext, actionability: actionability(action: "Choose one question and run a low-cost experiment that produces evidence within one session.", completion: "One experiment is completed and tied to a specific question.", evidence: ["A short experiment log names the question, action, and result."], micro: "Define the experiment and what result would count as signal."), suggestedNextAt: now),
                PlannerStepDraft(title: "Record what the experiment changed", summary: "Reflections should change confidence without forcing certainty too early.", type: .observationPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write what became more likely, less likely, or still uncertain after the experiment.", completion: "A reflection note updates confidence without pretending the answer is final.", evidence: ["A confidence note records what changed and what remains open."], micro: "Write one sentence about what became more or less likely."))
            ])
        ]
    }

    private func routineSections(subject: String, repeatEveryDays: Int) -> [PlannerSectionDraft] {
        [
            PlannerSectionDraft(title: "Routine", summary: "The main routine should be repeatable without needing ideal conditions.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Run the standard version once", summary: nil, type: .recurringRoutine, timingType: .repeatWithinWindow, actionability: actionability(action: "Complete the standard version of \(subject.lowercased()) once.", completion: "The routine is completed in full one time.", evidence: ["A log entry notes that the standard version was completed."], micro: "Do the first two minutes of the routine and log the minimum version."), isRepeatable: true, repeatEveryDays: repeatEveryDays)
            ]),
            PlannerSectionDraft(title: "Recovery Logic", summary: "Recovery matters more than perfection because streaks break.", kind: .review, steps: [
                PlannerStepDraft(title: "Decide how to restart after a miss", summary: nil, type: .reflectionPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write the reset rule for the next day after the routine is missed.", completion: "There is one clear reset rule that says how the routine resumes without punishment.", evidence: ["A recovery note exists and uses non-judgmental language."], micro: "Write the first sentence of the reset rule only."))
            ])
        ]
    }

    private func stabilizationSections(subject: String, now: String) -> [PlannerSectionDraft] {
        [
            PlannerSectionDraft(title: "Stabilization First", summary: "Recovery plans should stabilize the system before they ask for growth.", kind: .overview, steps: [
                PlannerStepDraft(title: "Name the baseline that needs protecting", summary: nil, type: .observationPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write the baseline condition that would mean \(subject.lowercased()) is getting more stable.", completion: "One stabilization sign is named in plain, observable language.", evidence: ["A note names the stabilization sign and why it matters."], micro: "Write the stabilization sign only."))
            ]),
            PlannerSectionDraft(title: "Low-Friction Actions", summary: "Choose the smallest reliable action before anything ambitious gets added.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Complete one stabilizing action", summary: nil, type: .actionUnit, timingType: .suggestedNext, actionability: actionability(action: "Complete the smallest action that would help the next day feel steadier or less chaotic.", completion: "One stabilizing action is finished without adding extra stretch work.", evidence: ["A note or artifact shows the action happened."], micro: "Do the first two minutes of the stabilizing action only."), suggestedNextAt: now),
                PlannerStepDraft(title: "Log the response after the action", summary: nil, type: .observationPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write whether the action made the situation feel steadier, unchanged, or harder.", completion: "A short observation records the immediate response to the action.", evidence: ["A response log exists in one or two sentences."], micro: "Choose one word for the response and add detail later."))
            ])
        ]
    }

    private func guidedSupportSections(now: String) -> [PlannerSectionDraft] {
        [
            PlannerSectionDraft(title: "Support Actions", summary: "Support plans help progress without taking ownership away from the executor.", kind: .supportingWork, steps: [
                PlannerStepDraft(title: "Offer one concrete support action", summary: nil, type: .supportAction, timingType: .suggestedNext, actionability: actionability(action: "Offer one specific support action that could help without taking over the work.", completion: "One support offer is prepared or completed and it leaves the executor with agency.", evidence: ["A message, material, or setup note shows what support was offered."], micro: "Write the support offer before sending or doing it."), suggestedNextAt: now)
            ]),
            PlannerSectionDraft(title: "Observation Prompts", summary: "Observation prompts gather signal without punishment or pressure.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Ask an open observation question", summary: nil, type: .observationPrompt, timingType: .suggestedNext, actionability: actionability(action: "Ask what feels clear, what feels stuck, and what kind of help would be welcome next.", completion: "At least one open question is asked without directing or judging the response.", evidence: ["A short note records the question or the answer that came back."], micro: "Ask only what feels stuck."), suggestedNextAt: now)
            ]),
            PlannerSectionDraft(title: "Milestone Signs", summary: "Milestone signs let support plans notice progress without micromanaging it.", kind: .review, steps: [
                PlannerStepDraft(title: "Define the next progress sign to watch for", summary: nil, type: .reflectionPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write the next sign that would show progress, even if the full goal is still far away.", completion: "One milestone sign is named in observational language.", evidence: ["A milestone-sign note exists and avoids control language."], micro: "Write the milestone sign as a fragment if needed."))
            ])
        ]
    }

    private func starterSections(subject: String, now: String) -> [PlannerSectionDraft] {
        [
            PlannerSectionDraft(title: "Starter Focus", summary: "When confidence is limited, the engine should produce a safe starter plan instead of pretending certainty.", kind: .overview, steps: [
                PlannerStepDraft(title: "State the current best guess", summary: nil, type: .reflectionPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write the current best guess about what would move \(subject.lowercased()) forward next.", completion: "One best-guess next move is written without claiming it is the final plan.", evidence: ["A note records the current best guess."], micro: "Write the first half of the guess sentence."))
            ]),
            PlannerSectionDraft(title: "Smallest Next Move", summary: "Starter plans should only ask for the smallest move that can create signal.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Take one low-risk next step", summary: nil, type: .actionUnit, timingType: .suggestedNext, actionability: actionability(action: "Complete one low-risk next step that can be finished quickly and teaches you something useful.", completion: "One bounded next step is completed and its result is visible.", evidence: ["A note or artifact shows what was tried and what happened."], micro: "Set up the step or gather the one thing needed to begin it."), suggestedNextAt: now)
            ]),
            PlannerSectionDraft(title: "What To Log", summary: "Logging matters because starter plans are designed to learn what should happen next.", kind: .review, steps: [
                PlannerStepDraft(title: "Log whether the next move helped", summary: nil, type: .observationPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write whether the low-risk next step clarified direction, exposed friction, or should be repeated.", completion: "A short reflection records what the next move taught you.", evidence: ["A reflection note exists with one clear takeaway."], micro: "Write only the takeaway sentence."))
            ])
        ]
    }

    private func actionability(action: String, completion: String, evidence: [String], micro: String) -> StepActionability {
        StepActionability(action: action, completionDefinition: completion, evidenceOfCompletion: evidence, fallbackMicroStep: micro, contextRequirements: [])
    }
}
