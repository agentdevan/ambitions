import XCTest
@testable import Ambitions

final class LivingPlanRecompilerTests: XCTestCase {
    func testPreviewRecompileEnforcesMutationPermission() {
        let recompiler = LivingPlanRecompiler()
        
        let preview = recompiler.previewRecompile(
            for: "goal-123",
            rawTitle: "Learn Swift",
            currentSteps: [],
            sourceUpdates: ["source-update-1"]
        )
        
        XCTAssertEqual(preview.affectedGoalID, "goal-123")
        XCTAssertFalse(preview.isSafeToApply)
        XCTAssertTrue(preview.mutationPermissionRequired)
        
        let receipt = preview.receiptPreview
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
        XCTAssertEqual(receipt.undoAvailability, .requiresConfirmation)
        
        let fact = receipt.changedFacts.first
        XCTAssertEqual(fact?.kind, .needsConfirmation)
        
        // Assert it does not silently mutate
        XCTAssertFalse(preview.proposedSteps.isEmpty)
    }
}
