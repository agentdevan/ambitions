import XCTest
@testable import Ambitions

final class SourceAtlasUIPrimitivesTests: XCTestCase {
    func testSourceBadge() {
        let badge = SourceBadge(sourceState: "official")
        XCTAssertEqual(badge.sourceState, "official")
    }
    
    func testFreshnessBadge() {
        let badge = FreshnessBadge(freshness: "stale")
        XCTAssertEqual(badge.freshness, "stale")
    }
}
