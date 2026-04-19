import Foundation

struct ExternalSurfaceSnapshotBuilder: Sendable {
    func makeSnapshot(goals: [Goal], captures: [Capture] = [], now: Date) -> ExternalSurfaceSnapshot {
        let nextAction = nextAction(from: goals, now: now)
        return ExternalSurfaceSnapshot(
            generatedAt: Self.iso.string(from: now),
            nextAction: nextAction,
            nowState: nowState(goals: goals, captures: captures, nextAction: nextAction)
        )
    }

    private func nextAction(from goals: [Goal], now: Date) -> ExternalSurfaceNextAction? {
        guard let selection = PlanningNextStepSelector().bestSelection(goals: goals, now: now) else {
            return nil
        }

        let goal = selection.goal
        let step = selection.step
        return ExternalSurfaceNextAction(
            goalID: goal.id,
            stepID: step.id,
            display: ExternalSurfaceDisplayMetadata(
                templateKey: "next_tiny_step",
                goalMode: mapGoalMode(goal.mode),
                stepState: mapStepState(step.state),
                urgency: urgency(for: step.timing, now: now),
                timing: timing(for: step.timing)
            )
        )
    }

    private func nowState(
        goals: [Goal],
        captures: [Capture],
        nextAction: ExternalSurfaceNextAction?
    ) -> ExternalSurfaceNowState {
        let activeGoals = goals.filter { $0.state == .active || $0.state == .paused }
        let blockedSteps = activeGoals.flatMap { goal in
            goal.plan?.sections.flatMap(\.steps) ?? []
        }.filter { $0.state == .blocked }
        let openCaptures = captures.filter { capture in
            capture.status != .archived
        }

        let posture: ExternalSurfaceTodayPosture
        if activeGoals.isEmpty {
            posture = .empty
        } else if blockedSteps.isEmpty == false && nextAction == nil {
            posture = .waiting
        } else {
            posture = .active
        }

        return ExternalSurfaceNowState(
            todayPosture: posture,
            pressureLevel: pressureLevel(activeGoalCount: activeGoals.count, blockedCount: blockedSteps.count),
            bestNextStep: nextAction.map { ExternalSurfaceActionReference(goalID: $0.goalID, stepID: $0.stepID) },
            activeFocus: nil,
            openCaptureUrgency: captureUrgency(openCaptureCount: openCaptures.count),
            blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: blockedSteps.count),
            supportedCommands: supportedCommands(hasNextAction: nextAction != nil)
        )
    }

    private func pressureLevel(activeGoalCount: Int, blockedCount: Int) -> ExternalSurfacePressureLevel {
        if activeGoalCount == 0 { return .open }
        if blockedCount >= 3 || activeGoalCount >= 8 { return .overloaded }
        if blockedCount > 0 || activeGoalCount >= 5 { return .elevated }
        return .steady
    }

    private func captureUrgency(openCaptureCount: Int) -> ExternalSurfaceCaptureUrgency {
        if openCaptureCount == 0 { return .none }
        if openCaptureCount >= 5 { return .elevated }
        return .low
    }

    private func supportedCommands(hasNextAction: Bool) -> [ExternalSurfaceCommandDescriptor] {
        var commands = [
            ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
            ExternalSurfaceCommandDescriptor(kind: .openCapturesInbox, requiresGoalID: false, requiresStepID: false),
        ]

        if hasNextAction {
            commands = [
                ExternalSurfaceCommandDescriptor(kind: .complete, requiresGoalID: true, requiresStepID: true),
                ExternalSurfaceCommandDescriptor(kind: .snooze, requiresGoalID: true, requiresStepID: true),
                ExternalSurfaceCommandDescriptor(kind: .openGoal, requiresGoalID: true, requiresStepID: false),
            ] + commands
        }

        return commands
    }

    private func urgency(for timing: GoalTiming, now: Date) -> ExternalSurfaceUrgency {
        guard let reference = parseDate(timing.dueAt ?? timing.targetBy ?? timing.windowEnd ?? timing.suggestedNextAt) else {
            return timing.tempo == .untimed ? .anytime : .normal
        }

        let delta = reference.timeIntervalSince(now)
        if delta < 0 { return .overdue }
        if delta <= 48 * 60 * 60 { return .soon }
        return .normal
    }

    private func timing(for timing: GoalTiming) -> ExternalSurfaceTiming {
        switch timing.tempo {
        case .deadlineBased:
            return .deadline
        case .targetWindow:
            return .window
        case .ongoing:
            return .cadence
        case .untimed:
            return .untimed
        }
    }

    private func mapGoalMode(_ mode: GoalMode) -> ExternalSurfaceGoalMode {
        switch mode {
        case .achievement:
            return .achievement
        case .project:
            return .project
        case .habit:
            return .habit
        case .learning:
            return .learning
        case .exploration:
            return .exploration
        case .maintenance:
            return .maintenance
        case .recovery:
            return .recovery
        case .delegatedSupport:
            return .delegatedSupport
        }
    }

    private func mapStepState(_ state: StepLifecycleState) -> ExternalSurfaceStepState {
        switch state {
        case .planned:
            return .planned
        case .active:
            return .active
        case .completed:
            return .completed
        case .blocked:
            return .blocked
        case .cancelled:
            return .cancelled
        }
    }

    private func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return Self.iso.date(from: value) ?? Self.isoFallback.date(from: value)
    }

    private static let iso: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFallback: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
