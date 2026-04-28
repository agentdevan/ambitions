import XCTest
@testable import Ambitions

final class SmartAttachmentModelsTests: XCTestCase {
    func testLaunchCoreRoutesAndFutureCompatibleRoutesAreRepresented() {
        XCTAssertEqual(
            Set(SmartAttachmentRouteType.allCases.filter(\.isLaunchCoreRoute)),
            [.task, .goal, .idea, .proofItem, .waitingItem, .plan]
        )
        XCTAssertFalse(SmartAttachmentRouteType.contextualNote.isLaunchCoreRoute)
        XCTAssertFalse(SmartAttachmentRouteType.reminder.isLaunchCoreRoute)
        XCTAssertFalse(SmartAttachmentRouteType.ritual.isLaunchCoreRoute)
        XCTAssertFalse(SmartAttachmentRouteType.archive.isLaunchCoreRoute)
        XCTAssertFalse(SmartAttachmentRouteType.decision.isLaunchCoreRoute)
    }

    func testCanonicalLabelsAvoidFakePrecisionAndAIWording() {
        XCTAssertEqual(SmartAttachmentConfidenceBand.high.userFacingLabel, "High")
        XCTAssertEqual(SmartAttachmentConfidenceBand.medium.userFacingLabel, "Medium")
        XCTAssertEqual(SmartAttachmentConfidenceBand.low.userFacingLabel, "Low")
        XCTAssertEqual(SmartAttachmentConfidenceBand.needsClarification.userFacingLabel, "Needs Clarification")
        XCTAssertEqual(SmartAttachmentConfidenceBand.unavailableFailed.userFacingLabel, "Unavailable")

        let labels = SmartAttachmentConfidenceBand.allCases.map(\.userFacingLabel).joined(separator: " ")
        XCTAssertFalse(labels.contains("%"))
        let disallowedTerms = ["AI Confidence", "AI Explanation", "Model Reasoning", "Fix AI"]
        XCTAssertTrue(disallowedTerms.allSatisfy { labels.localizedCaseInsensitiveContains($0) == false })
    }

    func testReceiptProjectionRedactsPrivateDetailsAndKeepsAccessibilityShape() {
        let result = SmartAttachmentResult(
            id: "smart-attachment-1",
            input: SmartAttachmentInput(rawText: "Finish bridge mix"),
            resultState: .savedStandalone,
            confidence: .medium,
            selectedCandidate: SmartAttachmentCandidate(
                id: "candidate-task",
                target: SmartAttachmentRouteTarget(
                    id: "target-task",
                    routeType: .task,
                    destinationKind: .standalone,
                    placementLabel: "Today"
                ),
                score: 1,
                evidenceLabels: ["Standalone"]
            ),
            receiptLine: "Saved as Task · Today",
            explanation: "Saved as a standalone Task because no existing local destination was reliable enough.",
            actions: [.change],
            privacyLevel: .privateItem
        )

        let full = result.receiptProjection(detail: .fullDetail)
        let redacted = result.receiptProjection(detail: .redacted)

        XCTAssertEqual(full.title, "Private item")
        XCTAssertEqual(full.summary, "Private item")
        XCTAssertTrue(full.isRedacted)
        XCTAssertEqual(full.accessibilityLabel, "Smart Attachment result")
        XCTAssertEqual(full.accessibilityHint, "Change")
        XCTAssertEqual(redacted.title, "Private item")
        XCTAssertEqual(redacted.privacyLevel, .redacted)
    }

    func testSmartAttachmentMapsToD05ActionReceiptContract() {
        let result = SmartAttachmentResult(
            id: "smart-attachment-proof",
            input: SmartAttachmentInput(rawText: "Finished first song proof"),
            resultState: .attached,
            confidence: .high,
            selectedCandidate: SmartAttachmentCandidate(
                id: "candidate-proof",
                target: SmartAttachmentRouteTarget(
                    id: "target-proof",
                    routeType: .proofItem,
                    destinationKind: .existingGoal,
                    destinationID: "goal-music",
                    destinationLabel: "Music Goal"
                ),
                score: 11,
                evidenceLabels: ["music"]
            ),
            receiptLine: "Attached as Proof · Music Goal",
            explanation: "Attached as Proof because the capture reads like evidence for a matching local goal.",
            actions: [.change, .keepStandalone],
            privacyLevel: .privateItem
        )

        let receipt = result.actionReceipt(captureID: "capture-proof", occurredAt: "2026-04-28T12:00:00Z")
        let search = ActionReceiptProjection(receipts: [receipt]).searchReceipts(
            ActionReceiptSearchQuery(relatedCaptureID: "capture-proof", projectionDetail: .redacted),
            privacyByReceiptID: [receipt.id: .sensitive]
        )

        XCTAssertTrue(receipt.isWellFormed)
        XCTAssertEqual(receipt.resultState, .attached)
        XCTAssertEqual(receipt.title, "Attached as Proof · Music Goal")
        XCTAssertEqual(receipt.changedFacts.map(\.kind), [.attachedCaptureToGoal])
        XCTAssertEqual(receipt.correctionAvailability, .availableWithReason)
        XCTAssertEqual(receipt.nextAction?.title, "Change")
        XCTAssertEqual(search.results.first?.title, "Private item")
        XCTAssertEqual(search.results.first?.changedFactSummaries, ["Detail hidden"])
    }

    func testFailureReceiptPreservesInputWithoutExternalMutationClaim() {
        let result = SmartAttachmentResult(
            id: "smart-attachment-failed",
            input: SmartAttachmentInput(rawText: ""),
            resultState: .failedSafely,
            confidence: .unavailableFailed,
            receiptLine: "Saved to Needs a Place",
            explanation: "The capture text was preserved, but no route could be inferred from an empty input.",
            actions: [.change, .retry, .copy],
            privacyLevel: .unavailable,
            failureReason: "Empty capture text"
        )

        let receipt = result.actionReceipt(captureID: "capture-empty", occurredAt: "2026-04-28T12:00:00Z")

        XCTAssertTrue(receipt.isWellFormed)
        XCTAssertEqual(receipt.resultState, .failedSafely)
        XCTAssertEqual(receipt.safetyState, .safeFailure)
        XCTAssertEqual(receipt.safeFailure?.unchangedFacts, ["No calendar, sync, account, cloud, external service, or unsupported app data was changed."])
    }
}
