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
    private let linter = GoalEnginePlanLinter()
    private let rewriter = GoalEngineStepRewriter()
    private let evaluator = PlanningEvaluator()

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

        let assumptions: [PlanAssumption]
        if let clarificationAnalysis = input.clarificationAnalysis {
            assumptions = clarificationAnalysis.compatibilityPlanAssumptions
        } else {
            assumptions = readiness == .canPlanWithDefaults ? missingFields.map(makeAssumption) : []
        }
        let strategyID = assumptions.isEmpty ? plannerStrategyID(for: input.draft, classification: input.classification) : .lightweightTracking
        let sections = strategySections(for: strategyID, draft: input.draft, now: now).enumerated().map { index, draftSection in
            buildSection(from: draftSection, goalID: goalID, draft: input.draft, orderIndex: index, now: now)
        }
        let rewrittenSections = sections.map { section in
            PlanSection(
                id: section.id,
                goalID: section.goalID,
                title: section.title,
                summary: section.summary,
                kind: section.kind,
                orderIndex: section.orderIndex,
                steps: section.steps.map { rewriter.rewrite(step: $0, goal: input.draft) }
            )
        }

        var plan = GoalPlan(
            id: "\(goalID)-plan",
            goalID: goalID,
            version: goalEnginePlanVersion,
            generatedAt: now,
            summary: assumptions.isEmpty
                ? "Shape \(input.draft.title)."
                : "Starter plan built with explicit assumptions so the next step is safe without pretending the goal is fully defined.",
            strategy: strategyShape(for: strategyID, draft: input.draft),
            sections: rewrittenSections,
            assumptions: assumptions,
            lint: PlanLintResult(goalID: goalID, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: [])
        )

        let lint = linter.lint(plan: plan, goal: input.draft)
        let evaluation = evaluator.evaluate(
            draft: input.draft,
            plan: plan,
            inference: input.classification.map { classification in
                [
                    "mode": classification.mode.metadata,
                    "tempo": classification.tempo.metadata,
                    "relationshipKind": classification.relationshipKind.metadata,
                    "executionOwnership": classification.executionOwnership.metadata,
                    "userRole": classification.userRole.metadata,
                    "strictDeadlinesAppropriate": classification.strictDeadlinesAppropriate.metadata,
                    "planningStrategyID": classification.planningStrategyID.metadata,
                    "progressStrategyID": classification.progressStrategyID.metadata,
                ]
            } ?? [:],
            pathStateSummary: LifeGraphResolver.pathStateSummary(for: input.draft, plan: plan)
        )
        plan = GoalPlan(
            id: plan.id,
            goalID: plan.goalID,
            version: plan.version,
            generatedAt: plan.generatedAt,
            summary: plan.summary,
            strategy: plan.strategy,
            sections: plan.sections,
            assumptions: plan.assumptions,
            lint: lint,
            evaluation: evaluation
        )

        if assumptions.isEmpty {
            return .plan(draft: input.draft, plan: plan, lint: lint)
        }

        return .starterPlan(draft: input.draft, plan: plan, lint: lint, assumptions: assumptions)
    }

    private func plannerStrategyID(for draft: GoalDraft, classification: ClassificationResult?) -> IntakePlanningStrategyID {
        if let tagged = draft.tags.first(where: { IntakePlanningStrategyID(rawValue: $0) != nil }),
           let strategy = IntakePlanningStrategyID(rawValue: tagged) {
            return strategy
        }
        if let classified = classification?.planningStrategyID.value {
            return classified
        }

        switch draft.mode {
        case .habit, .maintenance:
            return .routineBuilder
        case .learning:
            return .learningPath
        case .exploration:
            return .discoveryMap
        case .recovery:
            return .stabilizationPath
        case .delegatedSupport:
            return .guidedSupport
        case .achievement, .project:
            return draft.timing.tempo == .untimed ? .lightweightTracking : .milestonePlan
        }
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
            return PlanAssumption(id: "assumption-support-scope", summary: "Assume a light support role rather than taking over execution.", rationale: "This keeps support plans helpful without stripping agency from the real executor.", confidence: .medium, relatedField: .supportScope)
        case .successDefinition:
            return PlanAssumption(id: "assumption-success-definition", summary: "Assume the first useful version should stay small and demonstrable.", rationale: "Starter planning needs a concrete win signal even when the user has not defined a full finish line.", confidence: .medium, relatedField: .successDefinition)
        case .timeHorizon:
            return PlanAssumption(id: "assumption-time-horizon", summary: "Keep timing light until the user chooses a horizon.", rationale: "The planner should not invent deadline pressure where the user has not asked for it.", confidence: .medium, relatedField: .timeHorizon)
        case .goalShape:
            return PlanAssumption(id: "assumption-goal-shape", summary: "Assume stabilization and consistency come before expansion.", rationale: "Broad recovery and maintenance goals are safer when sequenced around stability first.", confidence: .medium, relatedField: .goalShape)
        case .goalSubject:
            return PlanAssumption(id: "assumption-goal-subject", summary: "The goal subject remains unresolved.", rationale: missing.reason, confidence: .low, relatedField: .goalSubject)
        case .executorIdentity:
            return PlanAssumption(id: "assumption-executor-identity", summary: "The real executor is not yet known.", rationale: missing.reason, confidence: .low, relatedField: .executorIdentity)
        }
    }

    private func strategyShape(for strategyID: IntakePlanningStrategyID, draft: GoalDraft) -> PlanningStrategy {
        let defaultStepType: StepType
        switch strategyID {
        case .learningPath:
            defaultStepType = .learningCheckpoint
        case .discoveryMap:
            defaultStepType = .explorationExperiment
        case .guidedSupport:
            defaultStepType = .supportAction
        case .routineBuilder:
            defaultStepType = .recurringRoutine
        case .stabilizationPath:
            defaultStepType = .observationPrompt
        case .milestonePlan, .lightweightTracking:
            defaultStepType = .actionUnit
        }

        let preferredSectionOrder: [PlanSectionKind] = strategyID == .guidedSupport
            ? [.supportingWork, .activeSteps, .review]
            : [.overview, .activeSteps, .review]

        return PlanningStrategy(
            strategyKind: draft.planningStrategy.strategyKind,
            allowParallelSteps: draft.planningStrategy.allowParallelSteps,
            maxActiveSteps: draft.planningStrategy.maxActiveSteps,
            preferredSectionOrder: preferredSectionOrder,
            defaultStepType: defaultStepType,
            autoGenerateReviewSection: draft.planningStrategy.autoGenerateReviewSection,
            preferShortSteps: strategyID != .milestonePlan,
            revisitCadenceDays: draft.planningStrategy.revisitCadenceDays
        )
    }

    private func strategySections(for strategyID: IntakePlanningStrategyID, draft: GoalDraft, now: String) -> [PlannerSectionDraft] {
        switch strategyID {
        case .milestonePlan:
            return milestonePlanSections(draft: draft, now: now)
        case .routineBuilder:
            return routineBuilderSections(draft: draft, now: now)
        case .learningPath:
            return learningPathSections(draft: draft, now: now)
        case .discoveryMap:
            return discoveryMapSections(draft: draft, now: now)
        case .stabilizationPath:
            return stabilizationPathSections(draft: draft, now: now)
        case .guidedSupport:
            return guidedSupportSections(draft: draft, now: now)
        case .lightweightTracking:
            return lightweightTrackingSections(draft: draft, now: now)
        }
    }

    private func normalizedSubject(for draft: GoalDraft) -> String {
        let subject = draft.summary ?? draft.title
        return subject.hasSuffix(".") ? String(subject.dropLast()) : subject
    }

    private func actionability(action: String, completion: String, evidence: [String], micro: String, contextRequirements: [String] = []) -> StepActionability {
        StepActionability(action: action, completionDefinition: completion, evidenceOfCompletion: evidence, fallbackMicroStep: micro, contextRequirements: contextRequirements)
    }

    private func dueAnchors(for draft: GoalDraft) -> (early: String?, mid: String?, final: String?) {
        if let dueAt = draft.timing.dueAt {
            let dueDate = String(dueAt.prefix(10))
            return (shift(dateOnly: dueDate, by: -21), shift(dateOnly: dueDate, by: -10), dueDate)
        }

        if let target = draft.timing.targetBy ?? draft.timing.windowEnd {
            return (shift(dateOnly: target, by: -14), shift(dateOnly: target, by: -5), target)
        }

        return (nil, nil, nil)
    }

    private func shift(dateOnly: String, by days: Int) -> String? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateOnly),
              let shifted = Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: date) else { return nil }
        return formatter.string(from: shifted)
    }

    private func shift(dateTime: String, by days: Int) -> String? {
        guard let date = ISO8601DateFormatter().date(from: dateTime),
              let shifted = Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: date) else { return nil }
        return ISO8601DateFormatter().string(from: shifted)
    }

    private func milestonePlanSections(draft: GoalDraft, now: String) -> [PlannerSectionDraft] {
        let subject = normalizedSubject(for: draft)
        let anchors = dueAnchors(for: draft)
        return [
            PlannerSectionDraft(title: "Milestones", summary: "Checkpoint definitions keep achievement work concrete without turning every step into a giant project.", kind: .overview, steps: [
                PlannerStepDraft(title: "Define the first visible milestone", summary: "Name the first milestone in a way that lets you tell whether it is reached.", type: .actionUnit, timingType: anchors.early == nil ? .suggestedNext : .targetBy, actionability: actionability(action: "Write one sentence that defines the first visible milestone for \(subject.lowercased()).", completion: "You have a milestone sentence and a short checklist of what must be true for it to count.", evidence: ["A saved checklist or note names the milestone and its signs."], micro: "Write the milestone name only, then add one sign that would prove it is reached."), targetBy: anchors.early),
                PlannerStepDraft(title: "Check what ready to finish will look like", summary: "This prevents late-stage thrash by defining the finish standard before the last sprint.", type: .actionUnit, timingType: anchors.mid == nil ? .suggestedNext : .targetBy, actionability: actionability(action: "List the three signs that would make the goal feel ready to finish rather than merely started.", completion: "Three finish signs are written in concrete language.", evidence: ["A short finish-sign list exists and can be reviewed later."], micro: "Write one finish sign and leave the other two for the next session."), targetBy: anchors.mid),
            ]),
            PlannerSectionDraft(title: "Workstreams", summary: "Keep the work separated into a few streams so next actions stay visible.", kind: .supportingWork, steps: [
                PlannerStepDraft(title: "Name the current workstream", summary: "Choose the one stream that deserves attention before anything else.", type: .actionUnit, timingType: .suggestedNext, actionability: actionability(action: "Pick the single workstream that most directly advances \(subject.lowercased()) right now.", completion: "One active workstream is named and the others are explicitly deferred.", evidence: ["A short list shows the active workstream and what is parked."], micro: "Write the active workstream name only."), suggestedNextAt: now),
                PlannerStepDraft(title: "List blockers for the active workstream", summary: "A small blocker list keeps the next action real instead of optimistic.", type: .actionUnit, timingType: .logWhenDone, actionability: actionability(action: "Write down the one blocker, dependency, or open decision most likely to slow the active workstream.", completion: "At least one blocker is named in specific terms and paired with a next step.", evidence: ["A blocker note pairs the blocker with a response or owner."], micro: "Capture one blocker without solving it yet.")),
            ]),
            PlannerSectionDraft(title: "Next Steps", summary: "These are the session-sized actions that move the chosen workstream immediately.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Complete one session-sized build slice", summary: "Advance the workstream with one bounded unit rather than a vague push.", type: .actionUnit, timingType: .suggestedNext, actionability: actionability(action: "Complete one bounded slice of the active workstream for \(subject.lowercased()).", completion: "One visible slice is finished and can be shown or described in a sentence.", evidence: ["A changed artifact, checklist mark, or progress note shows the slice is done."], micro: "Set up the file, tool, or materials needed for the slice and stop there if time is low.", contextRequirements: ["Only gather materials if they are required to start the slice."]), suggestedNextAt: now),
                PlannerStepDraft(title: "Capture the next handoff or follow-up", summary: "Closing the loop prevents progress from getting lost between sessions.", type: .reflectionPrompt, timingType: .logWhenDone, actionability: actionability(action: "After the build slice, write the exact next thing that should happen before the next session ends.", completion: "There is one explicit follow-up action written in plain language.", evidence: ["A follow-up note exists next to the completed slice."], micro: "Write a single next-action sentence.")),
            ]),
        ]
    }

    private func routineBuilderSections(draft: GoalDraft, now: String) -> [PlannerSectionDraft] {
        let subject = normalizedSubject(for: draft)
        let repeatEveryDays = draft.timing.repeatEveryDays ?? 1
        return [
            PlannerSectionDraft(title: "Cue", summary: "Attach the routine to a cue so it starts without negotiation.", kind: .overview, steps: [
                PlannerStepDraft(title: "Choose the cue that starts the routine", summary: nil, type: .actionUnit, timingType: .suggestedNext, actionability: actionability(action: "Name the existing cue that should trigger \(subject.lowercased()).", completion: "One cue is chosen and written in concrete everyday language.", evidence: ["A note pairs the cue with the routine start."], micro: "Write the cue only."), suggestedNextAt: now)
            ]),
            PlannerSectionDraft(title: "Routine", summary: "The main routine should be repeatable without needing ideal conditions.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Run the standard version once", summary: nil, type: .recurringRoutine, timingType: .repeatWithinWindow, actionability: actionability(action: "Complete the standard version of \(subject.lowercased()) once after the chosen cue.", completion: "The routine is completed in full one time using the chosen cue.", evidence: ["A log entry notes that the standard version was completed."], micro: "Do the first two minutes of the routine and log that the minimum version happened."), isRepeatable: true, repeatEveryDays: repeatEveryDays)
            ]),
            PlannerSectionDraft(title: "Minimum Version", summary: "The minimum version keeps the goal alive on low-energy days.", kind: .supportingWork, steps: [
                PlannerStepDraft(title: "Write the minimum viable version", summary: nil, type: .actionUnit, timingType: .logWhenDone, actionability: actionability(action: "Define the smallest acceptable version that still counts when time or energy is low.", completion: "A single minimum version is written in a way that can be done quickly.", evidence: ["A short fallback script or checklist names the minimum version."], micro: "Write the minimum version as one sentence."))
            ]),
            PlannerSectionDraft(title: "Recovery Logic", summary: "Recovery logic matters more than perfection because rhythms get disrupted.", kind: .review, steps: [
                PlannerStepDraft(title: "Decide how to restart after a miss", summary: nil, type: .reflectionPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write the reset rule for the next day after the routine is missed.", completion: "There is one clear reset rule that says how the routine resumes without punishment.", evidence: ["A recovery note exists and uses non-judgmental language."], micro: "Write the first sentence of the reset rule only."))
            ]),
        ]
    }

    private func learningPathSections(draft: GoalDraft, now: String) -> [PlannerSectionDraft] {
        let subject = normalizedSubject(for: draft)
        return [
            PlannerSectionDraft(title: "Skill Map", summary: "Break the learning goal into a small map so practice follows a visible edge.", kind: .overview, steps: [
                PlannerStepDraft(title: "Name the first sub-skill to practice", summary: "This keeps the first learning loop concrete.", type: .learningCheckpoint, timingType: .suggestedNext, actionability: actionability(action: "Pick the first sub-skill that would most increase confidence in \(subject.lowercased()).", completion: "One sub-skill is named in plain language.", evidence: ["A note names the sub-skill and why it comes first."], micro: "Write the sub-skill name only."), suggestedNextAt: now)
            ]),
            PlannerSectionDraft(title: "Practice Sessions", summary: "Practice loops should create signal, not pressure.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Run one focused practice session", summary: "Use one bounded session to get real evidence of understanding.", type: .learningCheckpoint, timingType: .suggestedNext, actionability: actionability(action: "Complete one short practice session focused on the chosen sub-skill.", completion: "One bounded practice session is finished and produces something reviewable.", evidence: ["A note, recording, worked example, or explanation exists."], micro: "Set a timer for one short practice block and start."), suggestedNextAt: now),
                PlannerStepDraft(title: "Externalize what you learned", summary: "Externalizing understanding makes confusion visible earlier.", type: .learningCheckpoint, timingType: .logWhenDone, actionability: actionability(action: "Write, say, or sketch what you learned in a form that would let someone else inspect your understanding.", completion: "One short explanation or artifact captures what you currently understand.", evidence: ["A recording, note, worked example, or explanation exists."], micro: "Write two sentences that explain the sub-skill in your own words.")),
            ]),
            PlannerSectionDraft(title: "Checkpoints", summary: "Checkpoint language should emphasize evidence of understanding rather than vague effort.", kind: .review, steps: [
                PlannerStepDraft(title: "Review what still feels shaky", summary: "Checkpoint language should emphasize evidence rather than judgment.", type: .reflectionPrompt, timingType: .logWhenDone, actionability: actionability(action: "After practice, write the part that still feels unclear and the next question it creates.", completion: "One confusion point and one follow-up question are captured.", evidence: ["A checkpoint note records the confusion point and next question."], micro: "Write only the unclear part."))
            ]),
        ]
    }

    private func discoveryMapSections(draft: GoalDraft, now: String) -> [PlannerSectionDraft] {
        let subject = normalizedSubject(for: draft)
        return [
            PlannerSectionDraft(title: "Key Questions", summary: "Exploration stays honest when the questions are explicit before the experiments start.", kind: .overview, steps: [
                PlannerStepDraft(title: "Write the top questions that need evidence", summary: nil, type: .reflectionPrompt, timingType: .logWhenDone, actionability: actionability(action: "List the two or three questions you need answered before narrowing \(subject.lowercased()).", completion: "A short question list exists and each question is answerable through observation or experiment.", evidence: ["A question list exists and the highest-priority question is marked."], micro: "Write the highest-priority question only."))
            ]),
            PlannerSectionDraft(title: "Experiments", summary: "Experiments should be small enough to learn from without pretending certainty is already earned.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Run one low-cost experiment", summary: nil, type: .explorationExperiment, timingType: .suggestedNext, actionability: actionability(action: "Choose one question and run a low-cost experiment that produces evidence within one session.", completion: "One experiment is completed and tied to a specific question.", evidence: ["A short experiment log names the question, action, and result."], micro: "Define the experiment and what result would count as signal."), suggestedNextAt: now)
            ]),
            PlannerSectionDraft(title: "Reflections", summary: "Reflections should increase or decrease confidence without forcing certainty too early.", kind: .review, steps: [
                PlannerStepDraft(title: "Record what the experiment changed", summary: nil, type: .observationPrompt, timingType: .logWhenDone, actionability: actionability(action: "After the experiment, write what became more likely, less likely, or still uncertain.", completion: "A reflection note updates confidence without pretending the answer is final.", evidence: ["A confidence note records what changed and what remains open."], micro: "Write one sentence about what became more or less likely."))
            ]),
        ]
    }

    private func stabilizationPathSections(draft: GoalDraft, now: String) -> [PlannerSectionDraft] {
        let subject = normalizedSubject(for: draft)
        return [
            PlannerSectionDraft(title: "Stabilization First", summary: "Recovery plans should stabilize the system before they ask for growth.", kind: .overview, steps: [
                PlannerStepDraft(title: "Name the baseline that needs protecting", summary: nil, type: .observationPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write the baseline condition that would mean \(subject.lowercased()) is getting more stable.", completion: "One stabilization sign is named in plain, observable language.", evidence: ["A note names the stabilization sign and why it matters."], micro: "Write the stabilization sign only."))
            ]),
            PlannerSectionDraft(title: "Low-Friction Actions", summary: "Choose the smallest reliable action before anything ambitious gets added.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Complete one stabilizing action", summary: nil, type: .actionUnit, timingType: .suggestedNext, actionability: actionability(action: "Complete the smallest action that would help the next day feel steadier or less chaotic.", completion: "One stabilizing action is finished without adding extra stretch work.", evidence: ["A note or artifact shows the action happened."], micro: "Do the first two minutes of the stabilizing action only."), suggestedNextAt: now),
                PlannerStepDraft(title: "Log the response after the action", summary: nil, type: .observationPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write whether the action made the situation feel steadier, unchanged, or harder.", completion: "A short observation records the immediate response to the action.", evidence: ["A response log exists in one or two sentences."], micro: "Choose one word for the response and add detail later.")),
            ]),
        ]
    }

    private func guidedSupportSections(draft: GoalDraft, now: String) -> [PlannerSectionDraft] {
        let subject = normalizedSubject(for: draft)
        let supportOwner: GoalActor = draft.actor.ownership == .self
            ? GoalActor(actorID: ExecutionOwnership.observedOnly.rawValue, displayName: "Supported person", ownership: .observedOnly, roleLabel: "Supported person", isPrimary: true)
            : draft.actor

        return [
            PlannerSectionDraft(title: "Support Actions", summary: "Support plans help progress without taking ownership away from the executor.", kind: .supportingWork, steps: [
                PlannerStepDraft(title: "Offer one concrete support action", summary: nil, type: .supportAction, timingType: .suggestedNext, actionability: actionability(action: "Offer one specific support action that could help with \(subject.lowercased()) without taking over the work.", completion: "One support offer is prepared or completed and it leaves the executor with agency.", evidence: ["A message, material, or setup note shows what support was offered."], micro: "Write the support offer before sending or doing it."), suggestedNextAt: now)
            ]),
            PlannerSectionDraft(title: "Observation Prompts", summary: "Observation prompts gather signal without punishment or pressure.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Ask an open observation question", summary: nil, type: .observationPrompt, timingType: .suggestedNext, actionability: actionability(action: "Ask what feels clear, what feels stuck, and what kind of help would be welcome next.", completion: "At least one open question is asked without directing or judging the response.", evidence: ["A short note records the question or the answer that came back."], micro: "Ask only what feels stuck."), suggestedNextAt: shift(dateTime: now, by: 1) ?? now, owner: supportOwner)
            ]),
            PlannerSectionDraft(title: "Milestone Signs", summary: "Milestone signs let support plans notice progress without micromanaging it.", kind: .review, steps: [
                PlannerStepDraft(title: "Define the next progress sign to watch for", summary: nil, type: .reflectionPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write the next sign that would show progress, even if the full goal is still far away.", completion: "One milestone sign is named in observational language.", evidence: ["A milestone-sign note exists and avoids control language."], micro: "Write the milestone sign as a fragment if needed."))
            ]),
        ]
    }

    private func lightweightTrackingSections(draft: GoalDraft, now: String) -> [PlannerSectionDraft] {
        let subject = normalizedSubject(for: draft)
        return [
            PlannerSectionDraft(title: "Starter Focus", summary: "When confidence is limited, the planner should produce a safe starter plan instead of pretending certainty.", kind: .overview, steps: [
                PlannerStepDraft(title: "State the current best guess", summary: nil, type: .reflectionPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write the current best guess about what would move \(subject.lowercased()) forward next.", completion: "One best-guess next step is written without claiming it is the final plan.", evidence: ["A note records the current best guess."], micro: "Write the first half of the guess sentence."))
            ]),
            PlannerSectionDraft(title: "Smallest Next Step", summary: "Starter plans should only ask for the smallest step that can create real signal.", kind: .activeSteps, steps: [
                PlannerStepDraft(title: "Take one low-risk next step", summary: nil, type: .actionUnit, timingType: .suggestedNext, actionability: actionability(action: "Complete one low-risk next step that can be finished quickly and teaches you something useful.", completion: "One bounded next step is completed and its result is visible.", evidence: ["A note or artifact shows what was tried and what happened."], micro: "Set up the step or gather the one thing needed to begin it."), suggestedNextAt: now)
            ]),
            PlannerSectionDraft(title: "What To Log", summary: "Logging matters because starter plans are designed to learn what should happen next.", kind: .review, steps: [
                PlannerStepDraft(title: "Log whether the next step helped", summary: nil, type: .observationPrompt, timingType: .logWhenDone, actionability: actionability(action: "Write whether the low-risk next step clarified direction, exposed friction, or should be repeated.", completion: "A short reflection records what the next step taught you.", evidence: ["A reflection note exists with one clear takeaway."], micro: "Write only the takeaway sentence."))
            ]),
        ]
    }

    private func buildSection(from definition: PlannerSectionDraft, goalID: String, draft: GoalDraft, orderIndex: Int, now: String) -> PlanSection {
        let sectionID = "\(goalID)-section-\(definition.kind.rawValue)-\(orderIndex + 1)"
        let steps = definition.steps.enumerated().map { index, stepDraft in
            buildStep(from: stepDraft, sectionID: sectionID, draft: draft, index: index, now: now)
        }

        return PlanSection(
            id: sectionID,
            goalID: goalID,
            title: definition.title,
            summary: definition.summary,
            kind: definition.kind,
            orderIndex: orderIndex,
            steps: steps
        )
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
            if let dueAt = definition.dueAt ?? draft.timing.dueAt {
                return GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: dueAt, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: draft.timing.progressReviewCadenceDays)
            }
        case .targetBy:
            if let targetBy = definition.targetBy ?? draft.timing.targetBy ?? draft.timing.windowEnd ?? draft.timing.dueAt.map({ String($0.prefix(10)) }) {
                return GoalTiming(tempo: .targetWindow, timingType: .targetBy, startsOn: nil, dueAt: nil, targetBy: targetBy, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: draft.timing.progressReviewCadenceDays)
            }
        case .repeatWithinWindow:
            return GoalTiming(tempo: .ongoing, timingType: .repeatWithinWindow, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: definition.repeatEveryDays ?? draft.timing.repeatEveryDays ?? 7, progressReviewCadenceDays: draft.timing.progressReviewCadenceDays)
        case .logWhenDone:
            return GoalTiming(tempo: .untimed, timingType: .logWhenDone, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: draft.timing.progressReviewCadenceDays)
        case .suggestedNext:
            break
        }

        return GoalTiming(
            tempo: draft.timing.tempo == .ongoing ? .ongoing : .untimed,
            timingType: .suggestedNext,
            startsOn: nil,
            dueAt: nil,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: definition.suggestedNextAt ?? draft.timing.suggestedNextAt ?? now,
            repeatEveryDays: draft.timing.tempo == .ongoing ? (draft.timing.repeatEveryDays ?? definition.repeatEveryDays) : nil,
            progressReviewCadenceDays: draft.timing.progressReviewCadenceDays
        )
    }
}
