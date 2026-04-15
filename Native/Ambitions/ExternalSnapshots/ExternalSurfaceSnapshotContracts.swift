import Foundation

struct ExternalSurfaceSnapshot: Codable, Sendable, Equatable {
    static let schemaVersion = "external_surface_snapshot.v1"

    let schemaVersion: String
    let generatedAt: String
    let nextAction: ExternalSurfaceNextAction?

    init(
        schemaVersion: String = ExternalSurfaceSnapshot.schemaVersion,
        generatedAt: String,
        nextAction: ExternalSurfaceNextAction?
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.nextAction = nextAction
    }
}

struct ExternalSurfaceNextAction: Codable, Sendable, Equatable {
    let goalID: String
    let stepID: String
    let display: ExternalSurfaceDisplayMetadata
}

struct ExternalSurfaceDisplayMetadata: Codable, Sendable, Equatable {
    let templateKey: String
    let goalMode: ExternalSurfaceGoalMode
    let stepState: ExternalSurfaceStepState
    let urgency: ExternalSurfaceUrgency
    let timing: ExternalSurfaceTiming
}

enum ExternalSurfaceGoalMode: String, Codable, Sendable {
    case achievement
    case project
    case habit
    case learning
    case exploration
    case maintenance
    case recovery
    case delegatedSupport = "delegated_support"
}

enum ExternalSurfaceStepState: String, Codable, Sendable {
    case planned
    case active
    case completed
    case blocked
    case cancelled
}

enum ExternalSurfaceUrgency: String, Codable, Sendable {
    case overdue
    case soon
    case normal
    case anytime
}

enum ExternalSurfaceTiming: String, Codable, Sendable {
    case deadline
    case window
    case cadence
    case untimed
}

struct ExternalSurfaceSnapshotBuilder: Sendable {
    func makeSnapshot(goals: [Goal], now: Date) -> ExternalSurfaceSnapshot {
        let nextAction = nextAction(from: goals, now: now)
        return ExternalSurfaceSnapshot(
            generatedAt: Self.iso.string(from: now),
            nextAction: nextAction
        )
    }

    private func nextAction(from goals: [Goal], now: Date) -> ExternalSurfaceNextAction? {
        let candidates = goals
            .filter { $0.state == .active || $0.state == .paused }
            .flatMap { goal in
                (goal.plan?.sections.flatMap(\.steps) ?? [])
                    .filter { $0.state != .completed && $0.state != .cancelled }
                    .map { (goal, $0) }
            }

        guard let chosen = candidates.min(by: { lhs, rhs in
            let lhsKey = timingSortKey(for: lhs.1.timing)
            let rhsKey = timingSortKey(for: rhs.1.timing)
            if lhsKey != rhsKey { return lhsKey < rhsKey }
            if lhs.0.id != rhs.0.id { return lhs.0.id < rhs.0.id }
            return lhs.1.id < rhs.1.id
        }) else {
            return nil
        }

        let goal = chosen.0
        let step = chosen.1
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

    private func timingSortKey(for timing: GoalTiming) -> String {
        timing.dueAt ?? timing.targetBy ?? timing.windowEnd ?? timing.suggestedNextAt ?? "9999-12-31T23:59:59Z"
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
