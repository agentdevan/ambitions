import XCTest
@testable import Ambitions

final class PublicReferenceInspectionUITests: XCTestCase {
    func testProjectionExposesAStableReadOnlyAccessibilityIdentifier() {
        let projection = PublicReferenceInspectionProjection(
            id: "public-reference-inspection-onet-30.3-30.3", title: "Public reference details",
            sourceRevision: "30.3|hash", delivery: "bundled", authority: "onet",
            retrieval: "Retrieved now", freshness: "current", selectedClaimID: nil,
            selectedClaim: nil, claims: [],
            recheckTrigger: .init(title: "Check approved source release", detail: "Read only.", isRequired: false),
            isReadOnly: true
        )
        XCTAssertTrue(projection.isReadOnly)
        XCTAssertEqual("trust.public-reference-inspection.\(projection.id)", "trust.public-reference-inspection.public-reference-inspection-onet-30.3-30.3")
    }
}
