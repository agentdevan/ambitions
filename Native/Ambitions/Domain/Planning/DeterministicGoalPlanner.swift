import Foundation

struct DeterministicGoalPlanSeed: Sendable, Equatable {
    let blueprint: GoalBlueprint
    let steps: [PlanStep]
}

struct DeterministicGoalPlanner {
    func plan(for rawTitle: String, preferredMode: GoalMode? = nil) -> DeterministicGoalPlanSeed {
        let title = normalizeTitle(rawTitle)
        let lower = title.lowercased()
        let mode = preferredMode ?? inferredMode(for: lower)
        let pace = inferredPace(for: lower)
        let lifeGraph = inferredLifeGraph(for: lower)
        let blueprint = GoalBlueprint(
            title: title,
            summary: nil,
            mode: mode,
            relationshipKind: .independent,
            actor: .localOwner,
            parentGoalID: nil,
            tags: tags(for: mode, pace: pace),
            pace: pace,
            targetDate: inferredTargetDate(for: lower),
            repeatEveryDays: pace == .ongoing ? 7 : nil,
            source: .manual,
            lifeGraph: lifeGraph
        )

        return DeterministicGoalPlanSeed(
            blueprint: blueprint,
            steps: stepTemplates(for: title, mode: mode, pace: pace)
        )
    }
}

private extension DeterministicGoalPlanner {
    func normalizeTitle(_ rawTitle: String) -> String {
        let collapsed = rawTitle
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")

        guard collapsed.isEmpty == false else { return "New goal" }
        let trimmedPeriod = collapsed.hasSuffix(".") ? String(collapsed.dropLast()) : collapsed
        return trimmedPeriod.prefix(1).uppercased() + trimmedPeriod.dropFirst()
    }

    func inferredMode(for lower: String) -> GoalMode {
        if containsAny(in: lower, matches: ["learn", "practice", "study", "train"]) {
            return .learning
        }
        if containsAny(in: lower, matches: ["research", "explore", "figure out", "investigate"]) {
            return .exploration
        }
        if containsAny(in: lower, matches: ["keep ", "maintain", "clean", "review weekly"]) {
            return .maintenance
        }
        return .project
    }

    func inferredPace(for lower: String) -> PlanningPace {
        if lower.range(of: #"\b\d{4}-\d{2}-\d{2}\b"#, options: .regularExpression) != nil ||
            containsAny(in: lower, matches: ["deadline", "due "]) {
            return .deadline
        }
        if containsAny(in: lower, matches: ["this week", "this month", "soon", "first version"]) {
            return .targeted
        }
        if containsAny(in: lower, matches: ["every ", "weekly", "daily", "keep ", "maintain"]) {
            return .ongoing
        }
        return .untimed
    }

    func inferredTargetDate(for lower: String) -> String? {
        guard let match = lower.range(of: #"\b\d{4}-\d{2}-\d{2}\b"#, options: .regularExpression) else {
            return nil
        }
        return String(lower[match])
    }

    func tags(for mode: GoalMode, pace: PlanningPace) -> [String] {
        [mode.rawValue, "deterministic_plan", pace.rawValue]
    }

    func inferredLifeGraph(for lower: String) -> LifeGraphContext? {
        if containsAny(in: lower, matches: ["astronaut", "career", "job", "promotion", "business", "company", "freelance"]) {
            return LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .career)],
                roles: [],
                path: LifePathDescriptor(kind: .careerTrack, title: "Career path"),
                milestones: []
            )
        }
        if containsAny(in: lower, matches: ["degree", "school", "course", "certification", "study program"]) {
            return LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .education)],
                roles: [],
                path: LifePathDescriptor(kind: .educationTrack, title: "Education path"),
                milestones: []
            )
        }
        if containsAny(in: lower, matches: ["workout", "exercise", "health", "fitness", "sleep", "recovery"]) {
            return LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .health)],
                roles: [],
                path: nil,
                milestones: []
            )
        }
        return nil
    }

    func stepTemplates(for title: String, mode: GoalMode, pace: PlanningPace) -> [PlanStep] {
        switch mode {
        case .learning:
            return [
                PlanStep(id: "step-1", title: "Pick source", summary: "Choose one source for \(title.lowercased()).", type: .learningCheckpoint, pace: .untimed, evidenceHint: "One source is selected."),
                PlanStep(id: "step-2", title: "Set practice block", summary: "Reserve one short session to practice.", type: .learningCheckpoint, pace: pace == .deadline ? .targeted : .untimed, targetDate: inferredTargetDate(for: title.lowercased()), evidenceHint: "A short practice block is on the calendar or list."),
                PlanStep(id: "step-3", title: "Do first pass", summary: "Complete one focused practice pass.", type: .learningCheckpoint, pace: .untimed, evidenceHint: "The first practice pass is done.")
            ]
        case .exploration:
            return [
                PlanStep(id: "step-1", title: "Write question", summary: "Write the concrete question this goal needs to answer.", type: .explorationExperiment, pace: .untimed, evidenceHint: "The question is written in one sentence."),
                PlanStep(id: "step-2", title: "Gather examples", summary: "Collect a small set of real examples.", type: .explorationExperiment, pace: .untimed, evidenceHint: "At least three examples are captured."),
                PlanStep(id: "step-3", title: "Note conclusion", summary: "Write the first decision or conclusion.", type: .reflectionPrompt, pace: .untimed, evidenceHint: "A first conclusion is written down.")
            ]
        case .maintenance, .habit:
            return [
                PlanStep(id: "step-1", title: "Define minimum", summary: "Set the smallest version that still counts.", type: .recurringRoutine, pace: .untimed, evidenceHint: "The minimum version is written down."),
                PlanStep(id: "step-2", title: "Choose cadence", summary: "Pick a realistic weekly rhythm.", type: .recurringRoutine, pace: .ongoing, repeatEveryDays: 7, evidenceHint: "A cadence is chosen."),
                PlanStep(id: "step-3", title: "Log first run", summary: "Complete one clean first run.", type: .recurringRoutine, pace: .ongoing, repeatEveryDays: 7, evidenceHint: "The first run is logged.")
            ]
        case .achievement, .project, .recovery, .delegatedSupport:
            return [
                PlanStep(id: "step-1", title: "Define scope", summary: "Write what this goal includes and excludes.", type: .actionUnit, pace: .untimed, evidenceHint: "Scope is written in a few lines."),
                PlanStep(id: "step-2", title: "List constraints", summary: "Capture the main constraint, dependency, or limit.", type: .actionUnit, pace: .untimed, evidenceHint: "The main constraint is written down."),
                PlanStep(id: "step-3", title: "Do first pass", summary: "Complete the smallest concrete first pass.", type: .actionUnit, pace: pace == .deadline ? .targeted : .untimed, targetDate: inferredTargetDate(for: title.lowercased()), evidenceHint: "A first pass is completed.")
            ]
        }
    }

    func containsAny(in lower: String, matches: [String]) -> Bool {
        matches.contains { lower.contains($0) }
    }
}
