import XCTest
@testable import Ambitions

final class LivingPlanRecompilerTests: XCTestCase {
    func testPreviewRecompileWithSourceClaims() {
        let recompiler = LivingPlanRecompiler()
        
        let staleClaim = SourceAtlasClaim(
            id: "claim-1",
            text: "Requires 100 hours of practice",
            state: .stale,
            freshness: .stale,
            riskClass: .hobby
        )
        
        let preview = recompiler.previewRecompile(
            for: "goal-1",
            rawTitle: "Learn Guitar",
            currentSteps: [],
            sourceClaims: [staleClaim]
        )
        
        XCTAssertEqual(preview.affectedGoalID, "goal-1")
        XCTAssertEqual(preview.claimImpacts["claim-1"], .stale)
        XCTAssertTrue(preview.receiptPreview.summary.contains("Claim 'Requires 100 hours of practice' is now in blocking state (stale)"))
        XCTAssertTrue(preview.mutationPermissionRequired)
    }
}
