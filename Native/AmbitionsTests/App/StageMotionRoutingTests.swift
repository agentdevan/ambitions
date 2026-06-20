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
        XCTAssertEqual(owner.lastMotionCoordination?.projection.action, .openTime)
        XCTAssertEqual(owner.lastMotionCoordination?.reductionPolicy.displayStyle, .calm)
        XCTAssertFalse(owner.lastMotionCoordination?.reductionPolicy.allowsAmbientMovement ?? true)
    }

    func testStageMotionCoordinatorOwnsCanonicalRoutingAndPolicy() {
        let coordinator = StageMotionCoordinator(reduceMotionEnabled: false)
        let coordination = coordinator.coordinate(
            action: .inspectProof(nil),
            source: "stage-motion-test"
        )

        XCTAssertEqual(coordination.projection.action, .inspectProof(nil))
        XCTAssertEqual(coordination.projection.sourceSurface, "stage-motion-test")
        XCTAssertEqual(coordination.projection.reduceMotion, false)
        XCTAssertEqual(coordination.projection.displayStyle, .active)
        XCTAssertEqual(coordination.reductionPolicy.displayStyle, .active)
        XCTAssertTrue(coordination.reductionPolicy.allowsAmbientMovement)
        assertMemoryLensOverlay(coordination.route, expectedQuery: "proof continuity")
    }

    func testStageMotionReductionPolicyKeepsReducedMotionSemanticQueriesStatic() {
        let policy = StageMotionReductionPolicy.current(reduceMotionEnabled: true)

        XCTAssertEqual(policy.displayStyle, .calm)
        XCTAssertFalse(policy.allowsAmbientMovement)
        XCTAssertEqual(policy.motionQuery(label: "proof", action: .inspectProof(nil)), "proof")
        XCTAssertEqual(policy.motionQuery(label: "proof", action: .inspectProof("proof-id")), "proof:proof-id")
        XCTAssertTrue(policy.proofThreadTextureDescription.contains("Static proof-thread marks"))
        XCTAssertTrue(policy.rhythmSpacingDescription.contains("static"))
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
