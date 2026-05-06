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

    func testF09CaptureHandoffPreservesCaptureIDThroughPreviewAndSubmit() async {
        let expectedPreview = CreateGoalPreviewState(
            normalizedTitle: "Launch community workshop",
            summary: "A capture can become a goal after confirmation.",
            modeLabel: GoalMode.project.displayTitle,
            resultKind: .starterPlanned,
            renderState: .starter,
            selectedPace: .balanced,
            paceOptions: [],
            feasibility: nil,
            deadlineGuidance: nil,
            pathStages: [],
            milestonePreview: [],
            clarification: nil,
            blocked: nil,
            trust: StrategyComposerTrustState(
                title: "Trust framing",
                lines: ["This remains confirmation-based."],
                badgeTitle: "Local first",
                state: .default
            ),
            planningEvaluation: nil
        )
        let expectedResponse = CreateGoalResponse(
            target: GoalRouteTarget(goalID: "goal-grown", draftID: "draft-grown"),
            blueprint: GoalBlueprint(title: "Launch community workshop", mode: .project)
        )
        let service = RecordingGoalsService(response: expectedResponse, preview: expectedPreview)
        let viewModel = CreateGoalViewModel(
            title: "  Launch community workshop  ",
            selectedMode: .project,
            entrySource: .capturesScreen,
            captureID: "capture-workshop"
        )

        let handoff = try! XCTUnwrap(viewModel.captureGoalHandoff)
        XCTAssertEqual(handoff.title, "Grow into Goal")
        XCTAssertEqual(handoff.sourceLabel, "Launch community workshop")
        XCTAssertEqual(handoff.confirmationLabel, "Requires your confirmation")

        await viewModel.refreshPreview(using: service, now: fixedNow)
        _ = await viewModel.submit(using: service, now: fixedNow)

        let previewRequest = await service.recordedPreviewRequest
        let createRequest = await service.recordedCreateRequest
        XCTAssertEqual(previewRequest?.captureID, "capture-workshop")
        XCTAssertEqual(createRequest?.captureID, "capture-workshop")
        XCTAssertEqual(createRequest?.entrySource, .capturesScreen)
    }

    func testPD11GoalSeedReviewKeepsPromotionExplicitAndEditable() {
        let preview = CreateGoalPreviewState(
            normalizedTitle: "Launch community workshop",
            summary: "A capture can become a goal after confirmation.",
            modeLabel: GoalMode.project.displayTitle,
            resultKind: .starterPlanned,
            renderState: .starter,
            selectedPace: .balanced,
            paceOptions: [],
            feasibility: nil,
            deadlineGuidance: nil,
            pathStages: [
                GoalPathStage(
                    id: "start",
                    title: "Starting phase",
                    summary: "Begin with a small invitation list.",
                    stepCountLabel: "1 step",
                    position: .current,
                    statusLabel: GoalPathStagePosition.current.title,
                    highlight: "Draft the first invitation",
                    state: .selected
                )
            ],
            milestonePreview: [
                GoalDetailStepItem(
                    id: "first-step",
                    title: "Draft the first invitation",
                    summary: "Make the workshop concrete without locking the whole path.",
                    timingLabel: "Flexible",
                    statusLabel: "Next",
                    state: .selected
                )
            ],
            clarification: nil,
            blocked: nil,
            trust: StrategyComposerTrustState(
                title: "Trust framing",
                lines: ["This remains confirmation-based."],
                badgeTitle: "Capture-led",
                state: .selected
            ),
            planningEvaluation: nil
        )

        let review = preview.goalSeedReviewState

        XCTAssertEqual(review.title, "Goal Seed Incubator")
        XCTAssertTrue(review.whyGoalLabel.localizedCaseInsensitiveContains("might be a goal"))
        XCTAssertTrue(review.startingPositionLabel.localizedCaseInsensitiveContains("Starting phase"))
        XCTAssertTrue(review.firstMilestoneLabel.localizedCaseInsensitiveContains("workshop concrete"))
        XCTAssertTrue(review.firstStepLabel.localizedCaseInsensitiveContains("Draft the first invitation"))
        XCTAssertTrue(review.proofSourceSeedLabel.localizedCaseInsensitiveContains("review before saving"))
        XCTAssertTrue(review.confirmationLabel.localizedCaseInsensitiveContains("only when you choose Create Goal"))
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains("automatically"))
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains("AI confidence"))
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains("classified as"))
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
