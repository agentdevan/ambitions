import XCTest
@testable import Ambitions

final class LivingPlanMergeLedgerTests: XCTestCase {
    func testRecordMergeManualRequiresConfirmation() {
        var ledger = LivingPlanMergeLedger()
        
        let receipt = ledger.recordMerge(resolution: .manualMerge, affectedGoalIDs: ["goal-1"])
        
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
        XCTAssertEqual(ledger.entries.count, 1)
        XCTAssertEqual(ledger.entries.first?.resolution, .manualMerge)
    }
    
    func testRecordMergeAutoDoesNotRequireConfirmation() {
        var ledger = LivingPlanMergeLedger()
        
        let receipt = ledger.recordMerge(resolution: .takeRemote, affectedGoalIDs: ["goal-1"])
        
        XCTAssertEqual(receipt.resultState, .completed)
        XCTAssertEqual(receipt.safetyState, .normal)
        XCTAssertEqual(ledger.entries.count, 1)
        XCTAssertEqual(ledger.entries.first?.resolution, .takeRemote)
    }
}
