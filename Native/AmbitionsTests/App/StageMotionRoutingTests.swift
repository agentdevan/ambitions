import XCTest
@testable import Ambitions

@MainActor
final class StageMotionRoutingTests: XCTestCase {
    func testMotionCurrentActionNotificationPayloadRoundTrips() {
        let actions: [MotionCurrentAction] = [
            .openToday,
            .openGoals,
            .openTime,
            .openTrust,
            .inspectProof("proof-visible"),
            .openReceipt("receipt-visible"),
            .openThread("return-to-thread")
        ]

        for action in actions {
            let decoded = MotionCurrentAction.fromNotificationPayload(action.toNotificationPayload(source: "test"))
            XCTAssertEqual(decoded, action)
        }
    }

    func testStageOwnerRoutesMotionActionsToCanonicalSurfaces() {
        let owner = StageOwner()

        switch owner.route(for: .openToday, source: "test") {
        case let .returnToToday(context):
            XCTAssertEqual(context, .standard)
        default:
            XCTFail("openToday should route to Today standard context")
        }

        switch owner.route(for: .openGoals, source: "test") {
        case .openGoals:
            break
        default:
            XCTFail("openGoals should route to Goals")
        }

        switch owner.route(for: .openTime, source: "test") {
        case .openTime:
            break
        default:
            XCTFail("openTime should route to Time")
        }
    }

    func testStageOwnerRoutesProofReceiptAndReentryWithoutMotionRootTab() {
        let owner = StageOwner()

        switch owner.route(for: .inspectProof("proof"), source: "test") {
        case .openTrust:
            break
        default:
            XCTFail("proof inspection should route to Trust/History")
        }

        switch owner.route(for: .openReceipt("receipt"), source: "test") {
        case .openTrust:
            break
        default:
            XCTFail("receipt inspection should route to Trust/History")
        }

        switch owner.route(for: .openThread("thread"), source: "test") {
        case let .returnToToday(context):
            XCTAssertEqual(context, .focus)
        default:
            XCTFail("thread re-entry should route to Today focus context")
        }
    }
}
