import XCTest
@testable import Ambitions

final class OneStepGoalModelsTests: XCTestCase {
    func testOneStepGoalPreservesTaskStepSemanticsWithoutGoalPressure() {
        let task = OneStepGoal(
            id: OneStepGoalID(rawValue: " call-dentist "),
            title: "Call the dentist",
            note: "Ask about the appointment window",
            lifeAreaID: LifeAreaID(domain: .health),
            status: .today,
            timing: OneStepGoalTimingMetadata(dueLabel: "Today", reminderLabel: "This afternoon"),
            source: .capture,
            sourceCaptureID: "capture-1"
        )

        XCTAssertEqual(task.id.rawValue, "call-dentist")
        XCTAssertEqual(task.status.displayName, "Today")
        XCTAssertEqual(task.lifeAreaID, LifeAreaID(domain: .health))
        XCTAssertEqual(task.objectReference.kind, .oneStepGoal)
        XCTAssertNil(task.relationshipHooks.stepReferences.first)
        XCTAssertEqual(task.relationshipHooks.captureReferences.map(\.id), ["capture-1"])
        XCTAssertTrue(task.canBePromotedToGoal)
        XCTAssertTrue(task.canAttachToGoal)
    }

    func testRelationshipHooksCoverFutureConsumersWithoutCreatingObjects() {
        let task = OneStepGoal(
            id: OneStepGoalID(rawValue: "portfolio-email"),
            title: "Email the portfolio link",
            lifeAreaID: LifeAreaID(domain: .career),
            linkedGoalIDs: ["goal-1", "goal-1"],
            northStarIDs: [NorthStarID(rawValue: "career-star"), NorthStarID(rawValue: "career-star")],
            proofReferenceIDs: ["proof-1"],
            receiptReferenceIDs: ["receipt-1"],
            decisionReferenceIDs: ["decision-1"],
            reviewReferenceIDs: ["review-1"]
        )

        XCTAssertEqual(task.relationshipHooks.lifeAreaReference?.kind, .lifeArea)
        XCTAssertEqual(task.relationshipHooks.linkedGoalReferences.map(\.id), ["goal-1"])
        XCTAssertEqual(task.relationshipHooks.northStarReferences.map(\.id), ["career-star"])
        XCTAssertEqual(task.relationshipHooks.proofReferences.map(\.kind), [.proof])
        XCTAssertEqual(task.relationshipHooks.decisionReferences.map(\.kind), [.decision])
        XCTAssertEqual(task.relationshipHooks.receiptReferences.map(\.kind), [.receipt])
        XCTAssertEqual(task.relationshipHooks.reviewReferences.map(\.kind), [.review])
    }

    func testConversionContractsReturnReceiptCompatibleMetadataWithoutCreatingGoal() {
        let task = OneStepGoal(
            id: OneStepGoalID(rawValue: "outline-talk"),
            title: "Outline the talk",
            linkedGoalIDs: ["goal-1"]
        )

        let promotion = task.conversionReceiptMetadata(for: .promoteToGoal, targetGoalID: "goal-new")
        let attachment = task.conversionReceiptMetadata(for: .attachToGoal, targetGoalID: "goal-1")
        let demotion = task.conversionReceiptMetadata(for: .demoteFromGoal, targetGoalID: "goal-heavy")

        XCTAssertEqual(promotion.resultState, .needsConfirmation)
        XCTAssertEqual(promotion.changedFactKind, .promotedTaskToGoal)
        XCTAssertEqual(promotion.affectedObjects.map(\.kind), [.oneStepGoal, .goal])
        XCTAssertTrue(promotion.receiptSummary.contains("No Goal is created automatically"))
        XCTAssertEqual(attachment.changedFactKind, .attachedTaskToGoal)
        XCTAssertEqual(demotion.changedFactKind, .demotedGoalToTask)
        XCTAssertTrue(demotion.requiresConfirmation)
    }

    func testRedactedSummaryKeepsStructureAndHidesSensitiveDetails() {
        let task = OneStepGoal(
            id: OneStepGoalID(rawValue: "private-task"),
            title: "Sensitive call",
            note: "Private details",
            lifeAreaID: LifeAreaID(domain: .relationships),
            status: .reviewLater,
            linkedGoalIDs: ["goal-private"],
            proofReferenceIDs: ["proof-private"],
            receiptReferenceIDs: ["receipt-private"],
            reviewReferenceIDs: ["review-private"],
            isSensitive: true
        )

        let summary = OneStepGoalSummary(oneStepGoal: task, linkedActiveGoalCount: 1, privacyLevel: .redacted)

        XCTAssertEqual(summary.title, "Private item")
        XCTAssertEqual(summary.note, "Detail hidden")
        XCTAssertEqual(summary.status, .reviewLater)
        XCTAssertEqual(summary.objectReference.kind, .oneStepGoal)
        XCTAssertEqual(summary.accessibility.label, "Private item")
        XCTAssertTrue(summary.accessibility.hint.contains("standalone One-Step Goal"))
    }
}
