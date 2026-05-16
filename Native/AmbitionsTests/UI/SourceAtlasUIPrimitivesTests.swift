import XCTest
import SwiftUI
@testable import Ambitions

final class SourceAtlasUIPrimitivesTests: XCTestCase {
    func testSourceBadge() {
        let badge = SourceBadge(state: .official)
        // Basic check that it initializes with the correct state
        XCTAssertEqual(badge.state, .official)
    }
    
    func testFreshnessBadge() {
        let badge = FreshnessBadge(state: .current)
        XCTAssertEqual(badge.state, .current)
    }
    
    func testPackUpdateReceipt() {
        let receipt = PackUpdateReceipt(packID: "test-pack")
        XCTAssertEqual(receipt.packID, "test-pack")
    }
    
    func testSkillSliceIndicator() {
        let indicator = SkillSliceIndicator(sliceName: "test-slice")
        XCTAssertEqual(indicator.sliceName, "test-slice")
    }
}
