import XCTest
@testable import Ambitions

@MainActor
final class CreateGoalViewModelTests: XCTestCase {
    func testScheduledPreviewRefreshPublishesClarificationState() async {
        let preview = CreateGoalPreviewState(
            normalizedTitle: "I don't know where to start",
            summary: "One clarification keeps the path honest.",
            modeLabel: GoalMode.project.displayTitle,
            resultKind: .clarificationRequired,
            renderState: .clarification,
            selectedPace: .balanced,
            paceOptions: [],
            feasibility: nil,
            deadlineGuidance: nil,
            pathStages: [],
            milestonePreview: [],
            clarification: GoalClarificationState(
                title: "One clarification keeps the path honest",
                subtitle: "Ambitions needs one concrete detail before shaping the path.",
                questions: []
            ),
            blocked: nil,
            trust: StrategyComposerTrustState(
                title: "Trust framing",
                lines: ["This read is grounded in the current intake and planning signals."],
                badgeTitle: "Local first",
                state: .default
            ),
            planningEvaluation: nil
        )
        let service = RecordingGoalsService(preview: preview)
        let viewModel = CreateGoalViewModel(title: "I don't know where to start")

        viewModel.schedulePreviewRefresh(using: service, now: fixedNow, debounceNanoseconds: 0)
        let loadedPreview = await waitForLoadedPreview(in: viewModel)
        guard let loadedPreview else {
            return XCTFail("Expected preview to load after scheduling refresh.")
        }
        XCTAssertEqual(loadedPreview.resultKind, .clarificationRequired)
        let recordedRequest = await service.recordedPreviewRequest
        XCTAssertEqual(recordedRequest?.title, "I don't know where to start")
    }

    func testSubmitUsesTrimmedTitleAndSelectedMode() async {
        let expectedResponse = CreateGoalResponse(
            target: GoalRouteTarget(goalID: "goal-1", draftID: "draft-1"),
            blueprint: GoalBlueprint(title: "Learn SwiftUI layout", mode: .learning)
        )
        let service = RecordingGoalsService(response: expectedResponse)
        let viewModel = CreateGoalViewModel(
            title: "  Learn SwiftUI layout  ",
            selectedMode: .learning
        )

        let response = await viewModel.submit(using: service, now: fixedNow)

        XCTAssertEqual(response?.target.goalID, "goal-1")
        let recordedRequest = await service.recordedCreateRequest
        let recordedDate = await service.recordedCreateDate

        XCTAssertEqual(recordedRequest?.title, "Learn SwiftUI layout")
        XCTAssertEqual(recordedRequest?.mode, .learning)
        XCTAssertEqual(recordedDate, fixedNow)
        XCTAssertEqual(viewModel.submissionState, .idle)
        XCTAssertFalse(viewModel.isSubmitting)
    }

    func testSubmitMovesIntoFailureStateWhenServiceThrows() async {
        let service = RecordingGoalsService(error: CreateGoalFailure.unavailable)
        let viewModel = CreateGoalViewModel(title: "Ship native create-goal flow")

        let response = await viewModel.submit(using: service, now: fixedNow)

        XCTAssertNil(response)
        guard case let .failed(message) = viewModel.submissionState else {
            return XCTFail("Expected failure state after service error.")
        }
        XCTAssertTrue(message.contains("Unable to create Goal"))
        XCTAssertTrue(message.contains("Create Goal is temporarily unavailable."))
        XCTAssertFalse(viewModel.isSubmitting)
    }

    private var fixedNow: Date {
        Date(timeIntervalSince1970: 1_712_692_800)
    }

    private func waitForLoadedPreview(
        in viewModel: CreateGoalViewModel,
        attempts: Int = 20
    ) async -> CreateGoalPreviewState? {
        for _ in 0..<attempts {
            if case let .loaded(preview) = viewModel.previewState {
                return preview
            }
            try? await Task.sleep(for: .milliseconds(25))
        }
        return nil
    }
}

private enum CreateGoalFailure: LocalizedError {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Create Goal is temporarily unavailable."
        }
    }
}

private actor RecordingGoalsService: GoalsServicing {
    private(set) var recordedCreateRequest: CreateGoalRequest?
    private(set) var recordedCreateDate: Date?
    private(set) var recordedPreviewRequest: CreateGoalPreviewRequest?
    private(set) var recordedPreviewDate: Date?

    let response: CreateGoalResponse?
    let preview: CreateGoalPreviewState?
    let error: Error?

    init(response: CreateGoalResponse? = nil, preview: CreateGoalPreviewState? = nil, error: Error? = nil) {
        self.response = response
        self.preview = preview
        self.error = error
    }

    func loadOverview() async throws -> GoalsOverview {
        fatalError("Not needed for CreateGoalViewModelTests")
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        _ = target
        fatalError("Not needed for CreateGoalViewModelTests")
    }

    func previewCreateGoal(_ request: CreateGoalPreviewRequest, now: Date) async throws -> CreateGoalPreviewState {
        recordedPreviewRequest = request
        recordedPreviewDate = now

        if let error {
            throw error
        }

        guard let preview else {
            fatalError("Expected a preview fixture.")
        }

        return preview
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        recordedCreateRequest = request
        recordedCreateDate = now

        if let error {
            throw error
        }

        guard let response else {
            fatalError("Expected a create-goal response fixture.")
        }

        return response
    }

    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        fatalError("Not needed for CreateGoalViewModelTests")
    }

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        fatalError("Not needed for CreateGoalViewModelTests")
    }
}
