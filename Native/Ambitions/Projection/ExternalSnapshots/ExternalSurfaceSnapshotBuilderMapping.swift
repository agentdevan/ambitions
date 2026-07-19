import Foundation

extension ExternalSurfaceSnapshotBuilder {
    func mapGoalMode(_ mode: GoalMode) -> ExternalSurfaceGoalMode {
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

    func mapStepState(_ state: StepLifecycleState) -> ExternalSurfaceStepState {
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

    func mapRitualKind(_ kind: RitualKind) -> ExternalSurfaceRitualKind {
        switch kind {
        case .morningSetup:
            return .morningSetup
        case .middayReset:
            return .middayReset
        case .eveningClose:
            return .eveningClose
        case .weeklyReset:
            return .weeklyReset
        }
    }

    func mapRitualProgress(_ state: RitualProgressState) -> ExternalSurfaceRitualProgressState {
        switch state {
        case .unavailable:
            return .unavailable
        case .ready:
            return .ready
        case .needsReset:
            return .needsReset
        case .complete:
            return .complete
        }
    }

    func templateKey(for kind: RitualKind) -> String {
        switch kind {
        case .morningSetup:
            return "ritual_morning_setup"
        case .middayReset:
            return "ritual_midday_reset"
        case .eveningClose:
            return "ritual_evening_close"
        case .weeklyReset:
            return "ritual_weekly_reset"
        }
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return Self.iso.date(from: value) ?? Self.isoFallback.date(from: value)
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
}
