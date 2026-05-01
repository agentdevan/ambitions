import AmbitionsDesignSystem
import Foundation

enum MemoryLensResultKind: String, Sendable, Equatable {
    case goal
    case week
    case capture
    case recentChange
    case whyNow
    case teaching
    case learning
    case handoff

    var title: String {
        switch self {
        case .goal: "Goal"
        case .week: "Week"
        case .capture: "Capture"
        case .recentChange: "Recent change"
        case .whyNow: "Why now"
        case .teaching: "Correction"
        case .learning: "Learning"
        case .handoff: "Handoff"
        }
    }

    var systemImage: String {
        switch self {
        case .goal: "target"
        case .week: "calendar"
        case .capture: "tray.full"
        case .recentChange: "clock.arrow.circlepath"
        case .whyNow: "questionmark.circle"
        case .teaching: "sparkles.rectangle.stack"
        case .learning: "lightbulb"
        case .handoff: "arrow.triangle.2.circlepath"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .goal: .selected
        case .week: .default
        case .capture: .default
        case .recentChange: .warning
        case .whyNow: .selected
        case .teaching: .success
        case .learning: .success
        case .handoff: .default
        }
    }
}

enum MemoryLensRecallFacet: String, Sendable, Equatable, CaseIterable {
    case whatChanged
    case whyNow
    case recentCorrection
    case recentLearning
    case handoff
    case open

    var title: String {
        switch self {
        case .whatChanged: "What changed"
        case .whyNow: "Why now"
        case .recentCorrection: "Recent correction"
        case .recentLearning: "Recent learning"
        case .handoff: "Handoff"
        case .open: "Open"
        }
    }
}

struct MemoryLensResult: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let explanation: String
    let queryText: String
    let timestamp: String
    let kind: MemoryLensResultKind
    let facet: MemoryLensRecallFacet
    let actionTitle: String
    let destination: ShellCommandDestination

    var state: AmbitionVisualState { kind.visualState }
    var badgeTitle: String { kind.title }
    var systemImage: String { kind.systemImage }
    var facetTitle: String { facet.title }
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
            let resolvedGoals = try await goals
            let resolvedCaptures = try await captures
            let resolvedFeedback = try await feedback
            let resolvedTeaching = try await teaching
            let goalResults = makeGoalResults(resolvedGoals)
            let captureResults = makeCaptureResults(resolvedCaptures)
            let feedbackResults = makeFeedbackResults(resolvedFeedback, goals: resolvedGoals)
            let whyNowResults = makeWhyNowResults(resolvedGoals, feedback: resolvedFeedback)
            let teachingResults = makeTeachingResults(resolvedTeaching, goals: resolvedGoals)
            let learningResults = makeLearningResults(resolvedGoals, feedback: resolvedFeedback, teaching: resolvedTeaching)
            let handoffResults = makeHandoffResults()
            let weekResult = makeWeekResult()

            let prioritized = prioritizationOrder(seedIntent: seedIntent)
            var combined: [MemoryLensResult] = [weekResult]
            combined.append(contentsOf: handoffResults)
            combined.append(contentsOf: whyNowResults)
            combined.append(contentsOf: learningResults)
            combined.append(contentsOf: feedbackResults)
            combined.append(contentsOf: goalResults)
            combined.append(contentsOf: captureResults)
            combined.append(contentsOf: teachingResults)
            let filtered = combined.filter { result in
                guard trimmedQuery.isEmpty == false else { return true }
                return result.queryText.localizedCaseInsensitiveContains(trimmedQuery)
            }
            let ordered = filtered.sorted { lhs, rhs in
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
            return [.goal: 0, .whyNow: 1, .recentChange: 2, .teaching: 3, .learning: 4, .week: 5, .capture: 6, .handoff: 7]
        case .openCapture:
            return [.capture: 0, .week: 1, .goal: 2, .recentChange: 3, .whyNow: 4, .teaching: 5, .learning: 6, .handoff: 7]
        case .openWeek:
            return [.week: 0, .recentChange: 1, .whyNow: 2, .capture: 3, .goal: 4, .teaching: 5, .learning: 6, .handoff: 7]
        default:
            return [.whyNow: 0, .recentChange: 1, .learning: 2, .teaching: 3, .handoff: 4, .goal: 5, .capture: 6, .week: 7]
        }
    }

    func makeWeekResult() -> MemoryLensResult {
        MemoryLensResult(
            id: "memory-week",
            title: "This week is the shaping surface",
            subtitle: "Open Plan when the question is how the week holds together.",
            explanation: "What Ambitions knows keeps week recall calm by returning to the owning Plan surface instead of building a second planning history.",
            queryText: "week plan shaping open week current week what changed why now",
            timestamp: "9999-12-31T23:59:59Z",
            kind: .week,
            facet: .open,
            actionTitle: "Open Plan",
            destination: .tab(.plan)
        )
    }

    func makeGoalResults(_ goals: [Goal]) -> [MemoryLensResult] {
        goals.map { goal in
            MemoryLensResult(
                id: "goal-\(goal.id)",
                title: goal.title,
                subtitle: goal.summary ?? goal.mode.displayTitle,
                explanation: "Open the canonical Goal Detail view with its strategy, trust, correction, and memory layers intact.",
                queryText: ([goal.title, goal.summary, goal.mode.displayTitle] + goal.tags).compactMap { $0 }.joined(separator: " "),
                timestamp: goal.updatedAt,
                kind: .goal,
                facet: .open,
                actionTitle: "Open goal",
                destination: .goal(goal.id)
            )
        }
    }

    func makeCaptureResults(_ captures: [Capture]) -> [MemoryLensResult] {
        captures.map { capture in
            let destination: ShellCommandDestination = capture.linkedGoalID.map { .goal($0) } ?? .planRoute(.captureInbox)
            return MemoryLensResult(
                id: "capture-\(capture.id)",
                title: capture.rawText,
                subtitle: capture.triage?.destination?.title ?? capture.status.title,
                explanation: capture.linkedGoalID == nil
                    ? "This thought still belongs in Capture before it becomes work."
                    : "This capture already carries goal context, so recall can return to the linked goal.",
                queryText: [capture.rawText, capture.triage?.destination?.title, capture.status.title].compactMap { $0 }.joined(separator: " "),
                timestamp: capture.updatedAt,
                kind: .capture,
                facet: .open,
                actionTitle: capture.linkedGoalID == nil ? "Open Capture" : "Open goal",
                destination: destination
            )
        }
    }

    func makeFeedbackResults(_ feedback: [GoalFeedbackEvent], goals: [Goal]) -> [MemoryLensResult] {
        feedback.map { event in
            let title: String
            let explanation: String
            switch event {
            case .completed:
                title = "Completion captured"
                explanation = "The plan now has proof of movement, so current recommendations can lean on real evidence instead of intent alone."
            case .skipped:
                title = "Skip recorded"
                explanation = "Ambitions treats the skip as useful context for reshaping, not as a failure."
            case .delayed:
                title = "Delay recorded"
                explanation = "Timing changed, so the safest next step may be gentler or later."
            case .edited:
                title = "Plan edited"
                explanation = "A step or plan phrase changed, so recall returns to the current plan shape rather than the old wording."
            case .confused:
                title = "Clarify next step"
                explanation = "Confusion is a signal to make the next step clearer before adding more work."
            case .tooBig:
                title = "Step marked too big"
                explanation = "The app should now prefer a smaller version when this path appears again."
            case .tooEasy:
                title = "Step marked too easy"
                explanation = "The plan learned that this step may need more meaningful signal."
            case .notRelevant:
                title = "Relevance changed"
                explanation = "The path needs a relevance check before Ambitions keeps recommending the same move."
            case .askedForSmallerVersion:
                title = "Asked for a smaller version"
                explanation = "Recovery context is preserved so future recall can start from a believable next step."
            case .askedWhyThisMatters:
                title = "Asked why this matters"
                explanation = "Why-now context should stay close to the goal instead of becoming a detached audit item."
            }
            let goalID = goalID(for: event, goals: goals)

            return MemoryLensResult(
                id: "feedback-\(event.base.id)",
                title: title,
                subtitle: event.base.note ?? "Recent plan and execution change.",
                explanation: explanation,
                queryText: [title, event.base.note, goalTitle(goalID: goalID, goals: goals), "what changed recent change"].compactMap { $0 }.joined(separator: " "),
                timestamp: event.base.occurredAt,
                kind: .recentChange,
                facet: .whatChanged,
                actionTitle: goalID == nil ? "Open history" : "Open goal",
                destination: goalID.map { .goal($0) } ?? .insightsRoute(.history)
            )
        }
    }

    func makeWhyNowResults(_ goals: [Goal], feedback: [GoalFeedbackEvent]) -> [MemoryLensResult] {
        var results: [MemoryLensResult] = []
        for goal in goals {
            guard let step = goal.plan?.sections
                .sorted(by: { $0.orderIndex < $1.orderIndex })
                .flatMap(\.steps)
                .first(where: { $0.state != .completed && $0.state != .cancelled }) else {
                continue
            }
            let recentGoalFeedback = feedback.filter { event in
                goal.plan?.sections.flatMap(\.steps).contains(where: { $0.id == event.base.stepID }) == true
            }
            let pressure = pressurePhrase(for: goal, step: step, recentFeedback: recentGoalFeedback)
            results.append(MemoryLensResult(
                id: "why-now-\(goal.id)-\(step.id)",
                title: "Why now: \(goal.title)",
                subtitle: pressure,
                explanation: "This recall points to the current useful step and the reason it deserves attention, without exposing raw planning logs.",
                queryText: [goal.title, step.title, pressure, "why now current next step"].joined(separator: " "),
                timestamp: goal.updatedAt,
                kind: .whyNow,
                facet: .whyNow,
                actionTitle: "Open goal",
                destination: .goal(goal.id)
            ))
        }
        return results
    }

    func makeTeachingResults(_ signals: [GoalTeachingSignal], goals: [Goal]) -> [MemoryLensResult] {
        signals.map { signal in
            let title = signal.userNote?.isEmpty == false ? signal.userNote! : signal.kind.rawValue.replacingOccurrences(of: "_", with: " ")
            let subtitle = correctionSubtitle(for: signal)
            return MemoryLensResult(
                id: "teaching-\(signal.id)",
                title: title.capitalized,
                subtitle: subtitle,
                explanation: "This correction is treated as useful truth for this goal, not as a judgment about past behavior.",
                queryText: [title, subtitle, signal.kind.rawValue, goalTitle(goalID: signal.goalID, goals: goals), "recent correction teaching"].compactMap { $0 }.joined(separator: " "),
                timestamp: signal.updatedAt,
                kind: .teaching,
                facet: .recentCorrection,
                actionTitle: "Open goal",
                destination: .goal(signal.goalID)
            )
        }
    }

    func makeLearningResults(
        _ goals: [Goal],
        feedback: [GoalFeedbackEvent],
        teaching: [GoalTeachingSignal]
    ) -> [MemoryLensResult] {
        let goalIDsWithFeedback = Set(feedback.compactMap { goalID(for: $0, goals: goals) })
        let goalIDsWithTeaching = Set(teaching.map(\.goalID))
        return goals
            .filter { goalIDsWithFeedback.contains($0.id) || goalIDsWithTeaching.contains($0.id) }
            .map { goal in
                let correctionCount = teaching.filter { $0.goalID == goal.id }.count
                let feedbackCount = feedback.filter { goalID(for: $0, goals: goals) == goal.id }.count
                let subtitle = correctionCount > 0
                    ? "\(correctionCount) correction\(correctionCount == 1 ? "" : "s") are shaping this path."
                    : "\(feedbackCount) recent signal\(feedbackCount == 1 ? "" : "s") are shaping this path."
                return MemoryLensResult(
                    id: "learning-\(goal.id)",
                    title: "What Ambitions is learning: \(goal.title)",
                    subtitle: subtitle,
                    explanation: "Learning recall summarizes the useful pattern in consumer language, then returns to the owning goal for detail.",
                    queryText: [goal.title, subtitle, "recent learning what learned correction feedback"].joined(separator: " "),
                    timestamp: goal.updatedAt,
                    kind: .learning,
                    facet: .recentLearning,
                    actionTitle: "Open goal",
                    destination: .goal(goal.id)
                )
            }
    }

    func makeHandoffResults() -> [MemoryLensResult] {
        [
            MemoryLensResult(
                id: "handoff-context",
                title: "External entries return to owning surfaces",
                subtitle: "Widgets, notifications, shortcuts, and shares keep their origin while landing in canonical app routes.",
                explanation: "Use this when you want to understand where an external prompt will take you. The app preserves source context without adding breadcrumb clutter.",
                queryText: "handoff return entry widget notification live activity app intent shortcut share extension origin external",
                timestamp: "9999-12-31T23:59:58Z",
                kind: .handoff,
                facet: .handoff,
                actionTitle: "Open Today",
                destination: .tab(.today)
            )
        ]
    }

    func goalID(for event: GoalFeedbackEvent, goals: [Goal]) -> String? {
        let stepID = event.base.stepID
        guard stepID.isEmpty == false else { return nil }
        return goals.first { goal in
            goal.plan?.sections.flatMap(\.steps).contains(where: { $0.id == stepID }) == true
        }?.id
    }

    func goalTitle(goalID: String?, goals: [Goal]) -> String? {
        guard let goalID else { return nil }
        return goals.first(where: { $0.id == goalID })?.title
    }

    func pressurePhrase(for goal: Goal, step: Step, recentFeedback: [GoalFeedbackEvent]) -> String {
        if recentFeedback.contains(where: { if case .askedForSmallerVersion = $0 { return true }; return false }) {
            return "A smaller version is now the calmest next step."
        }
        if recentFeedback.contains(where: { if case .delayed = $0 { return true }; return false }) {
            return "Timing changed recently, so this step needs a believable return."
        }
        if step.timing.dueAt != nil || step.timing.targetBy != nil || goal.timing.dueAt != nil || goal.timing.targetBy != nil {
            return "Time pressure is visible, but the next step stays bounded."
        }
        return "This is the next readable move from the current local plan."
    }

    func correctionSubtitle(for signal: GoalTeachingSignal) -> String {
        switch signal.kind {
        case .interpretationCorrection:
            return "Goal interpretation was clarified."
        case .goalSubjectCorrection:
            return "Goal subject was clarified."
        case .classificationCorrection:
            return "Goal classification was clarified."
        case .requirementRelevanceCorrection:
            return "Requirement relevance was clarified."
        case .contradictionDispositionCorrection:
            return "A contradiction was clarified."
        case .energyFitCorrection:
            return "Energy fit was clarified."
        }
    }
}
