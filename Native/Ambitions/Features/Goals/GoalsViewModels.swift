import Foundation
import Observation

@MainActor
@Observable
final class GoalsViewModel {
    var state: AsyncViewState<GoalsOverview>
    var selectedFilter: GoalsFilter
    var selectedSort: GoalsSortOption

    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(overview):
            return "loaded:\(overview.items.count):\(selectedFilter.rawValue):\(selectedSort.rawValue)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    init(
        state: AsyncViewState<GoalsOverview> = .loading,
        selectedFilter: GoalsFilter = .active,
        selectedSort: GoalsSortOption = .relevance
    ) {
        self.state = state
        self.selectedFilter = selectedFilter
        self.selectedSort = selectedSort
    }

    func load(using service: any GoalsServicing) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service)
    }

    func refresh(using service: any GoalsServicing) async {
        do {
            state = .loaded(try await service.loadOverview())
        } catch {
            state = .failed("Unable to load Goals: \(error.localizedDescription)")
        }
    }

    var visibleItems: [GoalListItem] {
        guard case let .loaded(overview) = state else { return [] }

        return overview.items
            .filter { item in
                switch selectedFilter {
                case .active:
                    return item.renderState == .active || item.renderState == .starter || item.renderState == .clarification || item.renderState == .blocked
                case .onHold:
                    return item.renderState == .onHold
                case .achieved:
                    return item.renderState == .achieved
                }
            }
            .sorted(by: sortDescriptor)
    }

    var filterCounts: [GoalsFilter: Int] {
        guard case let .loaded(overview) = state else { return [:] }
        return Dictionary(uniqueKeysWithValues: overview.filterSummaries.map { ($0.filter, $0.count) })
    }

    private var sortDescriptor: (GoalListItem, GoalListItem) -> Bool {
        switch selectedSort {
        case .relevance:
            return { lhs, rhs in
                lhs.relevanceScore == rhs.relevanceScore ? lhs.updatedAt > rhs.updatedAt : lhs.relevanceScore > rhs.relevanceScore
            }
        case .momentum:
            return { lhs, rhs in
                lhs.momentumScore == rhs.momentumScore ? lhs.progressValue > rhs.progressValue : lhs.momentumScore > rhs.momentumScore
            }
        case .urgency:
            return { lhs, rhs in
                lhs.urgencyScore == rhs.urgencyScore ? lhs.relevanceScore > rhs.relevanceScore : lhs.urgencyScore > rhs.urgencyScore
            }
        case .manualPriority:
            return { lhs, rhs in
                lhs.manualPriorityRank == rhs.manualPriorityRank ? lhs.relevanceScore > rhs.relevanceScore : lhs.manualPriorityRank < rhs.manualPriorityRank
            }
        }
    }
}

@MainActor
@Observable
final class GoalDetailViewModel {
    let target: GoalRouteTarget
    var state: AsyncViewState<GoalDetailPresentation>
    var inlineMessage: GoalDetailInlineMessage?
    var lens: GoalDetailLens
    var clarificationAnswers: [String: String]

    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(detail):
            return "loaded:\(detail.target.id):\(lens.rawValue)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    init(
        target: GoalRouteTarget,
        state: AsyncViewState<GoalDetailPresentation> = .loading,
        inlineMessage: GoalDetailInlineMessage? = nil,
        lens: GoalDetailLens = .tasks,
        clarificationAnswers: [String: String] = [:]
    ) {
        self.target = target
        self.state = state
        self.inlineMessage = inlineMessage
        self.lens = lens
        self.clarificationAnswers = clarificationAnswers
    }

    func load(using service: any GoalsServicing) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service)
    }

    func refresh(using service: any GoalsServicing) async {
        do {
            let detail = try await service.loadDetail(target: target)
            state = .loaded(detail)
            if clarificationAnswers.isEmpty {
                clarificationAnswers = Dictionary(uniqueKeysWithValues: detail.clarification?.questions.map { ($0.id, $0.existingAnswer ?? "") } ?? [])
            }
            if hasLoaded == false || inlineMessage == nil {
                lens = detail.defaultLens
            }
        } catch {
            state = .failed("Unable to load Goal Detail: \(error.localizedDescription)")
        }
    }

    func perform(_ action: GoalDetailActionKind, using service: any GoalsServicing, now: Date = .now) async {
        if action == .showPath {
            lens = lens == .tasks ? .path : .tasks
            return
        }

        let stepID: String? = {
            guard case let .loaded(detail) = state else { return nil }
            return detail.primaryStepID
        }()

        do {
            let response = try await service.performAction(
                GoalDetailActionRequest(target: target, kind: action, stepID: stepID),
                now: now
            )
            inlineMessage = response.message
            await refresh(using: service)
        } catch {
            inlineMessage = GoalDetailInlineMessage(
                title: "Action failed",
                body: error.localizedDescription,
                state: .warning
            )
        }
    }

    func saveClarificationAnswer(
        _ question: GoalClarificationQuestionState,
        using service: any GoalsServicing,
        now: Date = .now
    ) async {
        let answer = clarificationAnswers[question.id, default: ""]
        do {
            let response = try await service.submitClarificationAnswer(
                GoalClarificationAnswerRequest(
                    target: target,
                    questionID: question.id,
                    field: question.field,
                    answer: answer
                ),
                now: now
            )
            inlineMessage = response.message
            await refresh(using: service)
        } catch {
            inlineMessage = GoalDetailInlineMessage(
                title: "Clarification failed",
                body: error.localizedDescription,
                state: .warning
            )
        }
    }
}
