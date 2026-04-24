import AmbitionsDesignSystem
import Foundation

struct MetricSummary: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let value: String
    let detail: String?
    let icon: String
}

enum HabitsExperienceMode: Sendable {
    case empty
    case seeded
    case active
    case recovery
}

enum HabitTodayState: String, Sendable {
    case ready
    case completed
    case minimumDone = "minimum_done"
    case partial
    case delayed
    case skipped
    case recovery
    case needsEasierVersion = "needs_easier_version"
    case notRelevant = "not_relevant"
    case supportive

    var title: String {
        switch self {
        case .ready:
            "Ready"
        case .completed:
            "Done today"
        case .minimumDone:
            "Minimum version done"
        case .partial:
            "Partial progress"
        case .delayed:
            "Delayed"
        case .skipped:
            "Skipped"
        case .recovery:
            "Recovery"
        case .needsEasierVersion:
            "Needs easier version"
        case .notRelevant:
            "Plan needs review"
        case .supportive:
            "Supportive rhythm"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .completed, .minimumDone, .partial:
            .success
        case .delayed, .supportive:
            .selected
        case .skipped, .recovery, .needsEasierVersion, .notRelevant:
            .warning
        case .ready:
            .default
        }
    }
}

enum HabitActionKind: String, Sendable {
    case complete
    case skip
    case delay
    case minimumVersion = "minimum_version"
    case quickLog = "quick_log"
    case openDetail = "open_detail"
    case needsEasierVersion = "needs_easier_version"
    case markNotRelevant = "mark_not_relevant"
}

struct HabitActionTarget: Hashable, Sendable {
    let goalID: String
    let stepID: String
    let draftID: String?
}

struct HabitActionState: Identifiable, Sendable {
    var id: String { "\(kind.rawValue)-\(target.goalID)-\(target.stepID)" }

    let kind: HabitActionKind
    let title: String
    let systemImage: String
    let state: AmbitionVisualState
    let target: HabitActionTarget
}

struct HabitActionRequest: Sendable {
    let kind: HabitActionKind
    let target: HabitActionTarget
}

struct HabitInlineMessage: Identifiable, Sendable {
    let id: String
    let title: String
    let body: String
    let state: AmbitionVisualState

    init(id: String = UUID().uuidString, title: String, body: String, state: AmbitionVisualState) {
        self.id = id
        self.title = title
        self.body = body
        self.state = state
    }
}

struct HabitActionResponse: Sendable {
    let message: HabitInlineMessage?
}

struct HabitSummary: Identifiable, Sendable {
    let id: String
    let target: HabitActionTarget
    let title: String
    let subtitle: String
    let cadenceLabel: String
    let streakLabel: String
    let consistencyLabel: String
    let progress: Double
    let progressLabel: String
    let status: HabitTodayState
    let note: String
    let minimumVersionLabel: String?
    let supportLabel: String?
    let actions: [HabitActionState]
}

struct StreakSummary: Sendable {
    let title: String
    let subtitle: String
    let stats: [MetricSummary]
    let recoveryNote: String
}

struct HabitsDashboard: Sendable {
    let mode: HabitsExperienceMode
    let title: String
    let subtitle: String
    let summaryLabel: String
    let summaryDetail: String
    let stats: [MetricSummary]
    let habits: [HabitSummary]
    let recoveryHabits: [HabitSummary]
    let streak: StreakSummary
    let guidanceTitle: String
    let guidanceBody: String
    let emptyTitle: String?
    let emptyMessage: String?
}
