import XCTest
@testable import Ambitions

final class AppDrivingProofModeRouterTests: XCTestCase {
    func testSameIntentDifferentLocalContextsProduceDifferentInspectableOutputs() {
        let router = AppDrivingProofModeRouter()

        let outputs = router.routePair(
            intent: AppDrivingProofModeRouter.certificationExamIntent,
            first: AppDrivingProofModeRouter.protectedTimeHeavyContext,
            second: AppDrivingProofModeRouter.openDeepWorkContext
        )

        XCTAssertEqual(outputs.count, 2)
        XCTAssertEqual(Set(outputs.map(\.intent)), Set([AppDrivingProofModeRouter.certificationExamIntent]))
        XCTAssertNotEqual(outputs[0].contextID, outputs[1].contextID)
        XCTAssertNotEqual(outputs[0].recommendedStep, outputs[1].recommendedStep)
        XCTAssertNotEqual(outputs[0].plannedMinutes, outputs[1].plannedMinutes)
        XCTAssertNotEqual(outputs[0].whyNow, outputs[1].whyNow)
        XCTAssertTrue(outputs[0].recommendedStep.localizedCaseInsensitiveContains("Still Counts"))
        XCTAssertTrue(outputs[1].recommendedStep.localizedCaseInsensitiveContains("focused exam practice"))
        XCTAssertTrue(outputs[0].timeFit.contains("Fits"))
        XCTAssertTrue(outputs[1].timeFit.contains("Fits"))
        XCTAssertTrue(outputs[0].receiptID.hasPrefix("proof-receipt-"))
        XCTAssertTrue(outputs[0].replayID.hasPrefix("proof-replay-"))
    }

    func testProofModeRouterIsDeterministicForSameIntentAndContext() {
        let router = AppDrivingProofModeRouter()

        let first = router.route(
            intent: AppDrivingProofModeRouter.certificationExamIntent,
            context: AppDrivingProofModeRouter.protectedTimeHeavyContext
        )
        let second = router.route(
            intent: AppDrivingProofModeRouter.certificationExamIntent,
            context: AppDrivingProofModeRouter.protectedTimeHeavyContext
        )

        XCTAssertEqual(first, second)
    }

    func testProofModeRouterKeepsNonClaimBoundariesVisible() {
        let output = AppDrivingProofModeRouter().route(
            intent: AppDrivingProofModeRouter.certificationExamIntent,
            context: AppDrivingProofModeRouter.openDeepWorkContext
        )

        XCTAssertTrue(output.claimsNotMade.contains("No production user data was mutated."))
        XCTAssertTrue(output.claimsNotMade.contains("No cloud AI or hosted inference was used."))
        XCTAssertTrue(output.claimsNotMade.contains("No release readiness claim is made."))
        XCTAssertFalse(output.claimsNotMade.isEmpty)
    }
}
