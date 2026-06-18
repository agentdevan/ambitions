import XCTest
@testable import Ambitions

@MainActor
final class StageMotionRoutingTests: XCTestCase {
    func testMotionCurrentActionNotificationPayloadRoundTripsThroughCanonicalPayload() {
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
            let notification = Notification(
                name: MotionCurrentAction.notificationName,
                object: nil,
                userInfo: action.toNotificationPayload()
            )
            XCTAssertEqual(notification.ambitionsMotionCurrentAction, action)
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

    func testStageOwnerRoutesProofReceiptAndThreadReentryThroughMemoryLensOverlay() {
        let owner = StageOwner()

        assertMemoryLensOverlay(
            owner.route(for: .inspectProof("proof"), source: "test"),
            expectedQuery: "proof:proof"
        )
        assertMemoryLensOverlay(
            owner.route(for: .openReceipt("receipt"), source: "test"),
            expectedQuery: "receipt:receipt"
        )
        assertMemoryLensOverlay(
            owner.route(for: .openThread("thread"), source: "test"),
            expectedQuery: "thread:thread"
        )
    }

    func testStageOwnerRecordsProjectionAndReduceMotionState() {
        let owner = StageOwner(reduceMotionEnabled: true)
        _ = owner.route(for: .openTime, source: "stage-test")

        XCTAssertEqual(owner.lastMotionProjection?.action, .openTime)
        XCTAssertEqual(owner.lastMotionProjection?.sourceSurface, "stage-test")
        XCTAssertEqual(owner.lastMotionProjection?.reduceMotion, true)
        XCTAssertEqual(owner.lastMotionProjection?.displayStyle, .calm)
    }

    private func assertMemoryLensOverlay(_ route: StageMotionRoute, expectedQuery: String) {
        switch route {
        case let .presentOverlay(overlay):
            XCTAssertEqual(overlay.kind, .memoryLens)
            XCTAssertEqual(overlay.query, expectedQuery)
        default:
            XCTFail("Expected presentOverlay memory lens route")
        }
    }
}
