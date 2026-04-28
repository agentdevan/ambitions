import XCTest
@testable import Ambitions

final class SmartAttachmentServiceTests: XCTestCase {
    func testHighConfidenceProofAttachesToMatchingLocalGoal() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "Finished first mix proof for Music Goal"),
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-music",
                    label: "Music Goal",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .task, .proofItem]
                )
            ],
            maxCandidateCount: 5
        )

        XCTAssertEqual(result.resultState, .attached)
        XCTAssertEqual(result.confidence, .high)
        XCTAssertEqual(result.selectedCandidate?.target.routeType, .proofItem)
        XCTAssertEqual(result.selectedCandidate?.target.destinationID, "goal-music")
        XCTAssertEqual(result.receiptLine, "Attached as Proof · Music Goal")
        XCTAssertEqual(result.actions, [.change, .keepStandalone])
    }

    func testMediumConfidenceTaskSavesStandaloneWithSuggestion() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "Find NASA contacts on LinkedIn later"),
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-astronaut",
                    label: "NASA contacts",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .task, .proofItem],
                    placementLabel: "Become an Astronaut"
                )
            ],
            maxCandidateCount: 5
        )

        XCTAssertEqual(result.resultState, .savedStandalone)
        XCTAssertEqual(result.confidence, .medium)
        XCTAssertEqual(result.selectedCandidate?.target.routeType, .task)
        XCTAssertEqual(result.suggestedCandidate?.target.destinationID, "goal-astronaut")
        XCTAssertEqual(result.receiptLine, "Saved as Task · Today")
        XCTAssertTrue(result.actions.contains(.change))
        XCTAssertTrue(result.actions.contains(.keepStandalone))
        XCTAssertTrue(result.actions.contains(.attach))
    }

    func testLowConfidenceAsksCompactClarificationAndSavesNeedsPlace() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "NASA"),
            candidates: [],
            maxCandidateCount: 5
        )

        XCTAssertEqual(result.resultState, .needsClarification)
        XCTAssertEqual(result.confidence, .needsClarification)
        XCTAssertEqual(result.selectedCandidate?.target.destinationKind, .needsPlace)
        XCTAssertEqual(result.receiptLine, "Saved to Needs a Place")
        XCTAssertEqual(result.clarification?.question, "What should this become?")
        XCTAssertEqual(result.clarification?.choices.map(\.actionLabel), [.task, .goal, .idea])
        XCTAssertEqual(result.clarification?.choices.count, 3)
    }

    func testFailureUsesNeedsPlaceAndRetryCopyMetadata() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "   "),
            candidates: [],
            maxCandidateCount: 5
        )

        XCTAssertEqual(result.resultState, .failedSafely)
        XCTAssertEqual(result.confidence, .unavailableFailed)
        XCTAssertEqual(result.receiptLine, "Saved to Needs a Place")
        XCTAssertEqual(result.failureReason, "Empty capture text")
        XCTAssertTrue(result.actions.contains(.retry))
        XCTAssertTrue(result.actions.contains(.copy))
    }

    func testCandidateRankingIsDeterministicAndLimitable() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "finish launch proof"),
            candidates: [
                SmartAttachmentDestinationCandidate(id: "goal-b", label: "Launch proof", destinationKind: .existingGoal, supportedRouteTypes: [.proofItem]),
                SmartAttachmentDestinationCandidate(id: "goal-a", label: "Launch proof", destinationKind: .existingGoal, supportedRouteTypes: [.proofItem]),
                SmartAttachmentDestinationCandidate(id: "goal-c", label: "Launch", destinationKind: .existingGoal, supportedRouteTypes: [.proofItem])
            ],
            maxCandidateCount: 1
        )

        XCTAssertEqual(result.selectedCandidate?.target.destinationID, "goal-a")
        XCTAssertEqual(result.selectedCandidate?.score, 14)
    }

    func testServiceDoesNotRequireNetworkAccountCalendarOrExternalCandidates() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "Schedule proposal tomorrow"),
            candidates: [],
            maxCandidateCount: 5
        )

        XCTAssertEqual(result.resultState, .savedStandalone)
        XCTAssertEqual(result.confidence, .high)
        XCTAssertEqual(result.receiptLine, "Saved as Plan · This Week")
        XCTAssertEqual(result.captureRoute, .planSeed)
        XCTAssertEqual(result.captureAssumptionSummary, "Saved as a Plan item without scheduling or calendar changes.")
    }
}
