import Foundation

enum GoalOrchestrationResult: Sendable, Equatable {
    case clarificationRequired(GoalClarificationRequiredResult)
    case planned(GoalPlannedResult)
    case starterPlanned(GoalStarterPlannedResult)
    case blocked(GoalBlockedResult)

    var kind: GoalOrchestrationResultKind {
        switch self {
        case .clarificationRequired:
            return .clarificationRequired
        case .planned:
            return .planned
        case .starterPlanned:
            return .starterPlanned
        case .blocked:
            return .blocked
        }
    }

    var draft: GoalDraft {
        switch self {
        case let .clarificationRequired(result):
            return result.draft
        case let .planned(result):
            return result.draft
        case let .starterPlanned(result):
            return result.draft
        case let .blocked(result):
            return result.draft
        }
    }

    var metadata: GoalOrchestrationMetadata {
        switch self {
        case let .clarificationRequired(result):
            return result.metadata
        case let .planned(result):
            return result.metadata
        case let .starterPlanned(result):
            return result.metadata
        case let .blocked(result):
            return result.metadata
        }
    }
}

enum GoalContractValidator {
    static func lint(draft: GoalDraft) -> PlanLintResult {
        var issues: [PlanLintIssue] = []

        if draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(PlanLintIssue(code: .missingTitle, severity: .error, fieldPath: ["title"], message: "Goal title is required."))
        }

        issues.append(contentsOf: lintTiming(draft.timing, fieldPath: ["timing"]))

        return PlanLintResult(goalID: nil, planVersion: 0, isValid: !issues.contains(where: { $0.severity == .error }), issueCount: issues.count, issues: issues)
    }

    static func lint(plan: GoalPlan) -> PlanLintResult {
        var issues: [PlanLintIssue] = []
        var sectionIDs = Set<String>()
        var stepIDs = Set<String>()
        var validStepIDs = Set<String>()

        if plan.sections.isEmpty {
            issues.append(PlanLintIssue(code: .missingPlanSections, severity: .error, fieldPath: ["sections"], message: "Goal plans require at least one section."))
        }

        for section in plan.sections {
            if !sectionIDs.insert(section.id).inserted {
                issues.append(
                    PlanLintIssue(
                        code: .duplicateSectionID,
                        severity: .error,
                        fieldPath: ["sections", section.id],
                        message: "Section identifiers must be unique.",
                        sectionID: section.id
                    )
                )
            }

            for step in section.steps where step.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(PlanLintIssue(code: .missingStepTitle, severity: .error, fieldPath: ["sections", section.id, "steps", step.id, "title"], message: "Step title is required.", sectionID: section.id, stepID: step.id))
            }
            for step in section.steps {
                if !stepIDs.insert(step.id).inserted {
                    issues.append(
                        PlanLintIssue(
                            code: .duplicateStepID,
                            severity: .error,
                            fieldPath: ["sections", section.id, "steps", step.id],
                            message: "Step identifiers must be unique.",
                            sectionID: section.id,
                            stepID: step.id
                        )
                    )
                }
                validStepIDs.insert(step.id)
                issues.append(contentsOf: lintTiming(step.timing, fieldPath: ["sections", section.id, "steps", step.id, "timing"]))
            }
        }

        for section in plan.sections {
            for step in section.steps {
                for dependencyStepID in step.dependencyStepIDs where !validStepIDs.contains(dependencyStepID) {
                    issues.append(
                        PlanLintIssue(
                            code: .invalidDependency,
                            severity: .error,
                            fieldPath: ["sections", section.id, "steps", step.id, "dependencyStepIDs"],
                            message: "Step dependencies must reference a valid step identifier.",
                            sectionID: section.id,
                            stepID: step.id
                        )
                    )
                }
            }
        }

        return PlanLintResult(goalID: plan.goalID, planVersion: plan.version, isValid: !issues.contains(where: { $0.severity == .error }), issueCount: issues.count, issues: issues)
    }

    static func lintTiming(_ timing: GoalTiming, fieldPath: [String]) -> [PlanLintIssue] {
        switch timing.tempo {
        case .deadlineBased:
            return timing.dueAt == nil ? [PlanLintIssue(code: .invalidTiming, severity: .error, fieldPath: fieldPath, message: "Deadline-based goals require dueAt.")] : []
        case .targetWindow:
            return timing.targetBy == nil && (timing.windowStart == nil || timing.windowEnd == nil)
                ? [PlanLintIssue(code: .invalidTiming, severity: .error, fieldPath: fieldPath, message: "Target-window goals require targetBy or both windowStart and windowEnd.")]
                : []
        case .ongoing:
            return timing.timingType == .repeatWithinWindow && timing.repeatEveryDays == nil
                ? [PlanLintIssue(code: .invalidTiming, severity: .error, fieldPath: fieldPath, message: "Ongoing repeat timing requires repeatEveryDays.")]
                : []
        case .untimed:
            return (timing.dueAt != nil || timing.targetBy != nil || timing.windowStart != nil || timing.windowEnd != nil)
                ? [PlanLintIssue(code: .invalidTiming, severity: .error, fieldPath: fieldPath, message: "Untimed goals cannot carry deadline or target-window dates.")]
                : []
        }
    }
}

extension GoalOrchestrationResult {
    var adaptivePlanResult: GoalAdaptivePlanResult? {
        switch self {
        case let .planned(result):
            return .planned(result)
        case let .starterPlanned(result):
            return .starterPlanned(result)
        case .clarificationRequired, .blocked:
            return nil
        }
    }
}
