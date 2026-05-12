import XCTest
@testable import Ambitions

final class CaptureRouteCommandMappingTests: XCTestCase {
    func testCommandDestinationRouteCoversProofAndConstraintRoutes() {
        XCTAssertEqual(CaptureRoute.commandDestinationRoute(CaptureRoute.proofItem.rawValue), .proofItem)
        XCTAssertEqual(CaptureRoute.commandDestinationRoute(CaptureRoute.constraintItem.rawValue), .constraintItem)
    }

    func testCommandDestinationRoutePreservesKnownLegacyAliasesAndSafeFallback() {
        XCTAssertEqual(CaptureRoute.commandDestinationRoute("plan"), .planSeed)
        XCTAssertEqual(CaptureRoute.commandDestinationRoute("goal"), .goalSeed)
        XCTAssertEqual(CaptureRoute.commandDestinationRoute(CaptureRoute.goalAttachment.rawValue), .goalAttachment)
        XCTAssertEqual(CaptureRoute.commandDestinationRoute(CaptureRoute.deliverableSeed.rawValue), .deliverableSeed)
        XCTAssertEqual(CaptureRoute.commandDestinationRoute(CaptureRoute.captureInbox.rawValue), .captureInbox)
        XCTAssertEqual(CaptureRoute.commandDestinationRoute("unknown-route"), .captureInbox)
        XCTAssertNil(CaptureRoute.commandDestinationRoute("  "))
        XCTAssertNil(CaptureRoute.commandDestinationRoute(nil))
    }
}
