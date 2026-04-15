import XCTest
@testable import Ambitions

@MainActor
final class CreateGoalViewModelTests: XCTestCase {
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

    let response: CreateGoalResponse?
    let error: Error?

    init(response: CreateGoalResponse? = nil, error: Error? = nil) {
        self.response = response
        self.error = error
    }

    func loadOverview() async throws -> GoalsOverview {
        fatalError("Not needed for CreateGoalViewModelTests")
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        _ = target
        fatalError("Not needed for CreateGoalViewModelTests")
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
