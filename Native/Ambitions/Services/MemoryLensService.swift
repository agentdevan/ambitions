import AmbitionsDesignSystem
import Foundation

enum MemoryLensResultKind: String, Sendable, Equatable {
    case goal
    case week
    case capture
    case recentChange
    case teaching

    var title: String {
        switch self {
        case .goal: "Goal"
        case .week: "Week"
        case .capture: "Capture"
        case .recentChange: "Recent change"
        case .teaching: "Correction"
        }
    }

    var systemImage: String {
        switch self {
        case .goal: "target"
        case .week: "calendar"
        case .capture: "tray.full"
        case .recentChange: "clock.arrow.circlepath"
        case .teaching: "sparkles.rectangle.stack"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .goal: .selected
        case .week: .default
        case .capture: .default
        case .recentChange: .warning
        case .teaching: .success
        }
    }
}

struct MemoryLensResult: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let queryText: String
    let timestamp: String
    let kind: MemoryLensResultKind
    let destination: ShellCommandDestination

    var state: AmbitionVisualState { kind.visualState }
    var badgeTitle: String { kind.title }
    var systemImage: String { kind.systemImage }
}

struct DefaultMemoryLensService: MemoryLensServicing {
    private let repositories: AppRepositories

    init(repositories: AppRepositories) {
        self.repositories = repositories
    }

    func search(query: String, seedIntent: ShellCommandIntent?) async -> [MemoryLensResult] {
        async let goals = repositories.goals.listGoals()
        async let captures = repositories.captures.listCaptures()
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let teaching = repositories.teaching.listSignals(goalID: nil)

        do {
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let goalResults = makeGoalResults(try await goals)
            let captureResults = makeCaptureResults(try await captures)
            let feedbackResults = makeFeedbackResults(try await feedback)
            let teachingResults = makeTeachingResults(try await teaching)
            let weekResult = makeWeekResult()

            let prioritized = prioritizationOrder(seedIntent: seedIntent)
            let ordered = ([weekResult] + goalResults + captureResults + feedbackResults + teachingResults)
                .filter { result in
                    guard trimmedQuery.isEmpty == false else { return true }
                    return result.queryText.localizedCaseInsensitiveContains(trimmedQuery)
                }
                .sorted { lhs, rhs in
                    let lhsPriority = prioritized[lhs.kind] ?? 99
                    let rhsPriority = prioritized[rhs.kind] ?? 99
                    if lhsPriority == rhsPriority {
                        return lhs.timestamp > rhs.timestamp
                    }
                    return lhsPriority < rhsPriority
                }

            return Array(ordered.prefix(12))
        } catch {
            return []
        }
    }
}

private extension DefaultMemoryLensService {
    func prioritizationOrder(seedIntent: ShellCommandIntent?) -> [MemoryLensResultKind: Int] {
        switch seedIntent {
        case .openGoal:
            return [.goal: 0, .week: 1, .capture: 2, .recentChange: 3, .teaching: 4]
        case .openCapture:
            return [.capture: 0, .week: 1, .goal: 2, .recentChange: 3, .teaching: 4]
        case .openWeek:
            return [.week: 0, .goal: 1, .capture: 2, .recentChange: 3, .teaching: 4]
        default:
            return [.recentChange: 0, .goal: 1, .capture: 2, .teaching: 3, .week: 4]
        }
    }

    func makeWeekResult() -> MemoryLensResult {
        MemoryLensResult(
            id: "memory-week",
            title: "This week",
            subtitle: "Open Plan as the canonical shaping surface.",
            queryText: "week plan shaping open week current week",
            timestamp: "9999-12-31T23:59:59Z",
            kind: .week,
            destination: .tab(.plan)
        )
    }

    func makeGoalResults(_ goals: [Goal]) -> [MemoryLensResult] {
        goals.map { goal in
            MemoryLensResult(
                id: "goal-\(goal.id)",
                title: goal.title,
                subtitle: goal.summary ?? goal.mode.displayTitle,
                queryText: ([goal.title, goal.summary, goal.mode.displayTitle] + goal.tags).compactMap { $0 }.joined(separator: " "),
                timestamp: goal.updatedAt,
                kind: .goal,
                destination: .goal(goal.id)
            )
        }
    }

    func makeCaptureResults(_ captures: [Capture]) -> [MemoryLensResult] {
        captures.map { capture in
            let destination: ShellCommandDestination = capture.linkedGoalID.map { .goal($0) } ?? .planRoute(.capturesInbox)
            return MemoryLensResult(
                id: "capture-\(capture.id)",
                title: capture.rawText,
                subtitle: capture.triage?.destination?.title ?? capture.status.title,
                queryText: [capture.rawText, capture.triage?.destination?.title, capture.status.title].compactMap { $0 }.joined(separator: " "),
                timestamp: capture.updatedAt,
                kind: .capture,
                destination: destination
            )
        }
    }

    func makeFeedbackResults(_ feedback: [GoalFeedbackEvent]) -> [MemoryLensResult] {
        feedback.map { event in
            let title: String
            switch event {
            case .completed:
                title = "Completion captured"
            case .skipped:
                title = "Skip recorded"
            case .delayed:
                title = "Delay recorded"
            case .edited:
                title = "Plan edited"
            case .confused:
                title = "Clarify next step"
            case .tooBig:
                title = "Step marked too big"
            case .tooEasy:
                title = "Step marked too easy"
            case .notRelevant:
                title = "Relevance changed"
            case .askedForSmallerVersion:
                title = "Asked for a smaller version"
            case .askedWhyThisMatters:
                title = "Asked why this matters"
            }

            return MemoryLensResult(
                id: "feedback-\(event.base.id)",
                title: title,
                subtitle: event.base.note ?? "Recent plan and execution change.",
                queryText: [title, event.base.note].compactMap { $0 }.joined(separator: " "),
                timestamp: event.base.occurredAt,
                kind: .recentChange,
                destination: .tab(.insights)
            )
        }
    }

    func makeTeachingResults(_ signals: [GoalTeachingSignal]) -> [MemoryLensResult] {
        signals.map { signal in
            let title = signal.userNote?.isEmpty == false ? signal.userNote! : signal.kind.rawValue.replacingOccurrences(of: "_", with: " ")
            let subtitle = signal.anchor.normalizedIdentity
            return MemoryLensResult(
                id: "teaching-\(signal.id)",
                title: title.capitalized,
                subtitle: subtitle,
                queryText: [title, subtitle, signal.kind.rawValue].joined(separator: " "),
                timestamp: signal.updatedAt,
                kind: .teaching,
                destination: .goal(signal.goalID)
            )
        }
    }
}
