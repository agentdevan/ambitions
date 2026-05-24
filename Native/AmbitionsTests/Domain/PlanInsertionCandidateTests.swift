import XCTest
@testable import Ambitions

final class PlanInsertionCandidateTests: XCTestCase {
    func testPlanInsertionCandidatePreservesApprovalOptionsAndSafetyStatuses() {
        let adapter = SmartAttachmentCaptureAdapter()

        let decision = adapter.decision(
            rawText: "play pickleball at 8 next Tuesday",
            sourceType: .todayQuickCapture,
            sourceSurface: "Capture"
        )
        let candidate = decision?.planInsertionCandidate

        XCTAssertEqual(candidate?.captureID, decision?.result.id)
        XCTAssertEqual(candidate?.title, "Play Pickleball")
        XCTAssertEqual(candidate?.proposedStart?.hour, 8)
        XCTAssertEqual(candidate?.proposedEnd?.hour, 9)
        XCTAssertEqual(candidate?.timeConfidence, .needsClarification)
        XCTAssertEqual(candidate?.scheduleImpact, .timeChangeRecommended)
        XCTAssertEqual(candidate?.conflictStatus, .ambiguity)
        XCTAssertFalse(candidate?.affectsProtectedTime ?? true)
        XCTAssertTrue(candidate?.requiresCalendarPermission == true)
        XCTAssertTrue(candidate?.requiresUserApproval == true)
        XCTAssertEqual(candidate?.approvalOptionTitles, [
            "Decide later",
            "Save as context",
            "Attach to goal",
            "Add to Time",
            "Change time",
            "Do not use for planning"
        ])
    }

    func testPlanInsertionReceiptProjectionExplainsApprovalBeforeAnyWrite() {
        let adapter = SmartAttachmentCaptureAdapter()

        let decision = adapter.decision(
            rawText: "play pickleball at 8 next Tuesday",
            sourceType: .todayQuickCapture,
            sourceSurface: "Capture"
        )
        let receipt = decision?.planInsertionReceiptProjection

        XCTAssertEqual(receipt?.title, "Add to Time")
        XCTAssertTrue(receipt?.summary.localizedCaseInsensitiveContains("Play Pickleball") == true)
        XCTAssertTrue(receipt?.summary.localizedCaseInsensitiveContains("Needs clarification") == true)
        XCTAssertTrue(receipt?.accessibilityValue.localizedCaseInsensitiveContains("Conflict status: Time ambiguity") == true)
        XCTAssertTrue(receipt?.accessibilityValue.localizedCaseInsensitiveContains("Calendar permission required before any write.") == true)
        XCTAssertEqual(receipt?.actionTitles, [
            "Decide later",
            "Save as context",
            "Attach to goal",
            "Add to Time",
            "Change time",
            "Do not use for planning"
        ])
    }
}
