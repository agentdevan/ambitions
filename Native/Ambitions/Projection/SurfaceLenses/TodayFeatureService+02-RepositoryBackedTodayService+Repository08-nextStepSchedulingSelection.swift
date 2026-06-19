import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTodayService {
    func nextStepSchedulingSelection(goal: Goal, step: Step) -> NextStepSchedulingSelection {
        NextStepSchedulingSelection(
            goalID: goal.id,
            goalTitle: goal.title,
            stepID: step.id,
            stepTitle: step.title,
            stepSummary: step.summary ?? step.actionability.fallbackMicroStep,
            suggestedDate: parseDate(step.timing.suggestedNextAt ?? step.timing.targetBy ?? step.timing.dueAt ?? "")
        )
    }

    func shiftedTiming(for timing: GoalTiming, now: Date, adjustment: GoalTimingAdjustment) -> GoalTiming {
        let shiftedDate: Date
        switch adjustment {
        case .laterToday:
            shiftedDate = clock.calendar.date(byAdding: .hour, value: 3, to: now) ?? now
        case .laterThisWeek:
            shiftedDate = clock.calendar.date(byAdding: .day, value: 2, to: now) ?? now
        case .someday:
            shiftedDate = clock.calendar.date(byAdding: .day, value: 14, to: now) ?? now
        case .removeDeadline:
            shiftedDate = now
        }

        let shiftedValue = adjustment == .removeDeadline ? nil : Self.iso.string(from: shiftedDate)
        return GoalTiming(
            tempo: adjustment == .removeDeadline ? .untimed : timing.tempo,
            timingType: adjustment == .removeDeadline ? .logWhenDone : .suggestedNext,
            startsOn: timing.startsOn,
            dueAt: adjustment == .removeDeadline ? nil : timing.dueAt,
            targetBy: adjustment == .removeDeadline ? nil : timing.targetBy,
            windowStart: timing.windowStart,
            windowEnd: timing.windowEnd,
            suggestedNextAt: shiftedValue,
            repeatEveryDays: timing.repeatEveryDays,
            progressReviewCadenceDays: timing.progressReviewCadenceDays
        )
    }

    func smallerSummary(from recommendation: GoalReplanRecommendation, step: Step) -> String? {
        switch recommendation {
        case let .shrinkStep(_, _, _, _, smallerVersion, fallbackMicroStep):
            return "\(smallerVersion) Start with: \(fallbackMicroStep)"
        case let .suggestMicroStep(_, _, _, _, microStep):
            return microStep
        case let .reviseStep(_, _, _, _, rewriteHints, _, _):
            return rewriteHints.first ?? step.actionability.fallbackMicroStep
        case let .suggestAlternatePath(_, _, _, _, alternatePath, _):
            return alternatePath
        case .noChange, .relaxTiming, .requestReclarification, .adjustPlanTone:
            return nil
        }
    }

    func update(goal: Goal, stepID: String, now: Date, transform: (Step) -> Step) -> Goal {
        let updatedSections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id,
                goalID: section.goalID,
                title: section.title,
                summary: section.summary,
                kind: section.kind,
                orderIndex: section.orderIndex,
                steps: section.steps.map { $0.id == stepID ? transform($0) : $0 }
            )
        }

        let updatedPlan = goal.plan.map { plan in
            GoalPlan(
                id: plan.id,
                goalID: plan.goalID,
                version: plan.version,
                generatedAt: plan.generatedAt,
                summary: plan.summary,
                strategy: plan.strategy,
                sections: updatedSections ?? plan.sections,
                assumptions: plan.assumptions,
                lint: plan.lint
            )
        }

        return Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision + 1,
            createdAt: goal.createdAt,
            updatedAt: Self.iso.string(from: now),
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: goal.relationshipKind,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: updatedPlan,
            lifeGraph: goal.lifeGraph
        )
    }

    func incompleteDependencyCount(in goal: Goal, for step: Step) -> Int {
        let completedStepIDs = Set(goal.plan?.sections.flatMap(\.steps).filter { $0.state == .completed }.map(\.id) ?? [])
        return step.dependencyStepIDs.filter { completedStepIDs.contains($0) == false }.count
    }

    static var iso: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }

    static var isoFallback: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }

    func parseDate(_ value: String) -> Date? {
        Self.iso.date(from: value) ?? Self.isoFallback.date(from: value) ?? Self.dateOnly.date(from: value)
    }

    static var dateOnly: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    static var shortTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }

    func calendarEventMessageBody(for title: String, report: CalendarConflictReport?) -> String {
        guard let report else {
            return "\"\(title)\" was added to Calendar."
        }
        if report.hasConflicts {
            let count = report.conflicts.count
            if let nearby = report.nearbyAvailableWindow {
                return "\"\(title)\" was added to Calendar. It overlaps \(count) event\(count == 1 ? "" : "s"). A clearer opening starts around \(Self.shortTime.string(from: nearby.start))."
            }
            return "\"\(title)\" was added to Calendar. It overlaps \(count) event\(count == 1 ? "" : "s")."
        }
        if report.pressure == .high {
            return "\"\(title)\" was added to Calendar. The day looks tight around that block."
        }
        return "\"\(title)\" was added to Calendar."
    }
}
