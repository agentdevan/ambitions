import Foundation

private let supportTonePatterns: [String] = [
    #"\bmake (him|her|them)\b"#,
    #"\bforce\b"#,
    #"\bcompliance\b"#,
    #"\bensure they\b"#,
]

private let sessionBreakerPatterns: [String] = [
    #"\band\b"#,
    #"\bthen\b"#,
    #"\bentire\b"#,
    #"\bfull\b"#,
    #"\bcomplete all\b"#,
]

struct GoalEnginePlanLinter {
    private let rewriter = GoalEngineStepRewriter()

    func lint(plan: GoalPlan, goal: GoalDraft) -> PlanLintResult {
        let contractLint = GoalContractValidator.lint(plan: plan)
        let semanticIssues = plan.sections.flatMap { section in
            section.steps.flatMap { step in
                lint(step: step, sectionID: section.id, goal: goal)
            }
        }
        let issues = contractLint.issues + semanticIssues

        return PlanLintResult(
            goalID: plan.goalID,
            planVersion: plan.version,
            isValid: !issues.contains(where: { $0.severity == .error }),
            issueCount: issues.count,
            issues: issues
        )
    }

    private func lint(step: Step, sectionID: String, goal: GoalDraft) -> [PlanLintIssue] {
        var issues: [PlanLintIssue] = []

        if rewriter.isVague(step: step) {
            issues.append(
                makeIssue(
                    code: .vagueStep,
                    severity: .error,
                    step: step,
                    fieldPath: ["steps", step.id, "title"],
                    message: "Planner steps must avoid vague verbs and define an exact action.",
                    suggestedFix: "Replace broad verbs with one visible, session-sized action.",
                    sectionID: sectionID
                )
            )
        }

        if looksOversized(step: step) {
            issues.append(
                makeIssue(
                    code: .oversizedStep,
                    severity: .warning,
                    step: step,
                    fieldPath: ["steps", step.id],
                    message: "This step looks too large for a single working session.",
                    suggestedFix: "Split it into one concrete session step plus a separate follow-up step.",
                    sectionID: sectionID
                )
            )
        }

        if step.evidenceRequired && step.actionability.evidenceOfCompletion.isEmpty {
            issues.append(
                makeIssue(
                    code: .missingStepEvidence,
                    severity: .error,
                    step: step,
                    fieldPath: ["steps", step.id, "actionability", "evidenceOfCompletion"],
                    message: "Actionable steps must say what evidence will show the work is done.",
                    suggestedFix: "Add one or two concrete artifacts, logs, or observations that prove completion.",
                    sectionID: sectionID
                )
            )
        }

        if hasTimingPressureMismatch(step: step, goal: goal) {
            issues.append(
                makeIssue(
                    code: .inappropriateTimingPressure,
                    severity: .warning,
                    step: step,
                    fieldPath: ["steps", step.id, "timing"],
                    message: "This step applies more timing pressure than the goal mode safely supports.",
                    suggestedFix: "Use suggested_next, repeat_within_window, or log_when_done unless the goal explicitly needs a deadline.",
                    sectionID: sectionID
                )
            )
        }

        if goal.mode == .delegatedSupport && hasWrongSupportTone(step: step) {
            issues.append(
                makeIssue(
                    code: .wrongSupportTone,
                    severity: .error,
                    step: step,
                    fieldPath: ["steps", step.id, "title"],
                    message: "Delegated-support plans must use non-punitive, non-controlling language.",
                    suggestedFix: "Rewrite the step as support, observation, or invitation instead of control.",
                    sectionID: sectionID
                )
            )
        }

        if notSessionCompletable(step: step) {
            issues.append(
                makeIssue(
                    code: .notSessionCompletable,
                    severity: .warning,
                    step: step,
                    fieldPath: ["steps", step.id, "actionability", "completionDefinition"],
                    message: "Each step should be meaningfully completable in one session.",
                    suggestedFix: "Define a smaller stopping point that can be completed and evidenced today.",
                    sectionID: sectionID
                )
            )
        }

        return issues
    }

    private func makeIssue(
        code: PlanLintIssueCode,
        severity: PlanLintSeverity,
        step: Step,
        fieldPath: [String],
        message: String,
        suggestedFix: String,
        sectionID: String
    ) -> PlanLintIssue {
        PlanLintIssue(
            code: code,
            severity: severity,
            fieldPath: fieldPath,
            message: message,
            sectionID: sectionID,
            stepID: step.id,
            suggestedFix: suggestedFix
        )
    }

    private func looksOversized(step: Step) -> Bool {
        let combined = [step.title, step.actionability.action, step.actionability.completionDefinition].joined(separator: " ")
        let wordCount = combined.split(whereSeparator: \.isWhitespace).count
        return wordCount > 40 || sessionBreakerPatterns.contains { pattern in
            combined.range(of: pattern, options: .regularExpression) != nil
        }
    }

    private func hasWrongSupportTone(step: Step) -> Bool {
        let combined = [step.title, step.summary ?? "", step.actionability.action].joined(separator: " ")
        return supportTonePatterns.contains { pattern in
            combined.range(of: pattern, options: .regularExpression) != nil
        }
    }

    private func hasTimingPressureMismatch(step: Step, goal: GoalDraft) -> Bool {
        if [.learning, .exploration, .maintenance, .recovery, .delegatedSupport].contains(goal.mode) {
            return step.timing.timingType == .dueAt
        }

        if goal.timing.tempo == .untimed {
            return step.timing.timingType == .dueAt || step.timing.timingType == .targetBy
        }

        return false
    }

    private func notSessionCompletable(step: Step) -> Bool {
        looksOversized(step: step)
            || step.actionability.completionDefinition.range(of: #"\bweeks?\b|\bmonths?\b"#, options: .regularExpression) != nil
    }
}
