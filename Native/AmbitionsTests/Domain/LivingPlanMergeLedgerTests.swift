import XCTest
@testable import Ambitions

final class LivingPlanMergeLedgerTests: XCTestCase {
    func testReceiptPinning() {
        var ledger = LivingPlanAuditLedger()
        let receiptID = "r1"
        let note = "Verified by source"
        
        let receipt = ledger.pinReceipt(receiptID: receiptID, note: note)
        
        XCTAssertEqual(ledger.entries.count, 1)
        XCTAssertEqual(ledger.entries[0].kind, .receiptPin)
        XCTAssertEqual(ledger.entries[0].receiptID, receiptID)
        XCTAssertTrue(receipt.summary.contains(note))
    }
}
