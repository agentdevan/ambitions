import Foundation
import Observation

@MainActor
@Observable
final class GoalsViewModel {
    var state: AsyncViewState<GoalsOverview>
    var isLowerPriorityExpanded: Bool
    var semanticZoomMode: GoalsSemanticZoomMode

    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(overview):
            let cardCount = overview.bands.reduce(0) { $0 + $1.cards.count } + overview.lowerPriority.cards.count
            return "loaded:\(cardCount):\(overview.lifeAreas.contentAreaCount):\(overview.northStars.totalCount):\(overview.oneStepGoals.openCount):\(isLowerPriorityExpanded):\(semanticZoomMode.rawValue)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    init(
        state: AsyncViewState<GoalsOverview> = .loading,
        isLowerPriorityExpanded: Bool = false,
        semanticZoomMode: GoalsSemanticZoomMode = .map
    ) {
        self.state = state
        self.isLowerPriorityExpanded = isLowerPriorityExpanded
        self.semanticZoomMode = semanticZoomMode
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
}

@MainActor
@Observable
final class GoalDetailViewModel {
    let target: GoalRouteTarget
    var state: AsyncViewState<GoalDetailPresentation>
    var inlineMessage: GoalDetailInlineMessage?
    var lens: GoalDetailLens
    var isTrustExpanded: Bool
    var isCorrectionsExpanded: Bool
    var isMemoryExpanded: Bool
    var clarificationAnswers: [String: String]

    private var hasLoaded = false
    private var pendingOperationIDs: [String: String] = [:]

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(detail):
            return "loaded:\(detail.target.id):\(lens.rawValue):\(isTrustExpanded):\(isCorrectionsExpanded):\(isMemoryExpanded)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    init(
        target: GoalRouteTarget,
        state: AsyncViewState<GoalDetailPresentation> = .loading,
        inlineMessage: GoalDetailInlineMessage? = nil,
        lens: GoalDetailLens = .tasks,
        isTrustExpanded: Bool = false,
        isCorrectionsExpanded: Bool = false,
        isMemoryExpanded: Bool = false,
        clarificationAnswers: [String: String] = [:]
    ) {
        self.target = target
        self.state = state
        self.inlineMessage = inlineMessage
        self.lens = lens
        self.isTrustExpanded = isTrustExpanded
        self.isCorrectionsExpanded = isCorrectionsExpanded
        self.isMemoryExpanded = isMemoryExpanded
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
            let operationKey = "\(action.rawValue).\(stepID ?? "none")"
            let operationID = pendingOperationIDs[operationKey] ?? UUID().uuidString.lowercased()
            pendingOperationIDs[operationKey] = operationID
            let response = try await service.performAction(
                GoalDetailActionRequest(operationID: operationID, target: target, kind: action, stepID: stepID),
                now: now
            )
            pendingOperationIDs.removeValue(forKey: operationKey)
            inlineMessage = response.message
            await refresh(using: service)
        } catch {
            inlineMessage = GoalDetailInlineMessage(
                title: "Action could not finish",
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
                title: "Clarification could not finish",
                body: error.localizedDescription,
                state: .warning
            )
        }
    }

    func submitExplainabilityCorrection(
        _ control: GoalCorrectionControlState,
        using service: any GoalsServicing,
        now: Date = .now
    ) async {
        do {
            let response = try await service.submitExplainabilityCorrection(
                GoalExplainabilityCorrectionRequest(
                    target: target,
                    control: control
                ),
                now: now
            )
            inlineMessage = response.message
            await refresh(using: service)
        } catch {
            inlineMessage = GoalDetailInlineMessage(
                title: "Correction could not finish",
                body: error.localizedDescription,
                state: .warning
            )
        }
    }
}
