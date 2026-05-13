import XCTest
@testable import Ambitions

final class ExternalSurfaceControlContractsTests: XCTestCase {
    func testSystemControlSetContainsOnlyHighestValueControls() {
        XCTAssertEqual(
            Set(ExternalSurfaceControlContract.systemControlSet.map(\.id)),
            Set(ExternalSurfaceControlID.allCases)
        )
        XCTAssertEqual(ExternalSurfaceControlContract.systemControlSet.count, 5)
    }

    func testSystemControlsKeepSensitiveDetailsOutOfSystemSurfaces() {
        for contract in ExternalSurfaceControlContract.systemControlSet {
            XCTAssertFalse(contract.privacySummary.isEmpty)
            XCTAssertFalse(contract.privacySummary.localizedCaseInsensitiveContains("AI"))
            XCTAssertFalse(contract.privacySummary.localizedCaseInsensitiveContains("confidence"))
            XCTAssertTrue(contract.isSafeForSystemControlSurface)
        }
    }

    func testStartNowAndCaptureOpenSafeFallbackDestinations() throws {
        let startNow = ExternalSurfaceControlContract.contract(for: .startNow)
        let capture = ExternalSurfaceControlContract.contract(for: .capture)

        XCTAssertEqual(startNow.title, "Start now")
        XCTAssertEqual(startNow.executionMode, .opensAppOnly)
        XCTAssertEqual(startNow.deepLinkURL(origin: .appIntent)?.absoluteString, "ambitions://tab/today?origin=app_intent")

        XCTAssertEqual(capture.title, "Capture")
        XCTAssertEqual(capture.executionMode, .opensAppOnly)
        XCTAssertEqual(capture.deepLinkURL(origin: .appIntent)?.absoluteString, "ambitions://captures/inbox?origin=app_intent")
    }

    func testMutationCapableControlsRequireInAppConfirmationAndReceipts() {
        let stillCounts = ExternalSurfaceControlContract.contract(for: .stillCounts)
        let addProof = ExternalSurfaceControlContract.contract(for: .addProof)

        XCTAssertEqual(stillCounts.executionMode, .requiresInAppConfirmation)
        XCTAssertTrue(stillCounts.producesReceipt)
        XCTAssertTrue(stillCounts.requiresGoalID)
        XCTAssertTrue(stillCounts.requiresStepID)

        XCTAssertEqual(addProof.executionMode, .requiresInAppConfirmation)
        XCTAssertTrue(addProof.producesReceipt)
        XCTAssertTrue(addProof.requiresGoalID)
        XCTAssertFalse(addProof.requiresStepID)
    }

    func testCurrentStepControlRequiresStepReferenceButDoesNotMutate() {
        let openCurrentStep = ExternalSurfaceControlContract.contract(for: .openCurrentStep)

        XCTAssertEqual(openCurrentStep.executionMode, .opensAppOnly)
        XCTAssertFalse(openCurrentStep.producesReceipt)
        XCTAssertTrue(openCurrentStep.requiresGoalID)
        XCTAssertTrue(openCurrentStep.requiresStepID)
        XCTAssertEqual(openCurrentStep.availability, .requiresCurrentStep)
    }

    func testControlPayloadsUseCanonicalExternalSurfaceActionSchema() {
        let reference = ExternalSurfaceActionReference(goalID: "goal-1", stepID: "step-1")
        let payload = ExternalSurfaceControlContract.contract(for: .stillCounts).commandPayload(reference: reference)

        XCTAssertEqual(payload[ExternalSurfaceActionPayload.Key.action], ExternalSurfaceActionName.complete.rawValue)
        XCTAssertEqual(payload[ExternalSurfaceActionPayload.Key.surface], ExternalSurfacePayloadSurface.goalDetail.rawValue)
        XCTAssertEqual(payload[ExternalSurfaceActionPayload.Key.goalID], "goal-1")
        XCTAssertEqual(payload[ExternalSurfaceActionPayload.Key.stepID], "step-1")
    }

    func testAppIntentControlEnumMapsOneToOneToContracts() {
        XCTAssertEqual(
            Set(AmbitionsSystemControlShortcut.allCases.map(\.contractID)),
            Set(ExternalSurfaceControlID.allCases)
        )

        for shortcut in AmbitionsSystemControlShortcut.allCases {
            XCTAssertEqual(shortcut.contract.id, shortcut.contractID)
        }
    }
}
