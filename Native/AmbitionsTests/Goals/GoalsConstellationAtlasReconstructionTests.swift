import XCTest
@testable import Ambitions

final class GoalsConstellationAtlasReconstructionTests: XCTestCase {
    func testGoalsObjectStageContractOwnsConstellationAtlas() {
        let contract = GoalsObjectStagePrimitiveContract.current
        XCTAssertEqual(contract.ownerSurface, "Goals")
        XCTAssertEqual(contract.stageName, "Constellation Atlas")
        XCTAssertTrue(contract.avoidsGenericGoalRootOutput)
        XCTAssertTrue(contract.firstViewportStructure.contains("life-area"))
        XCTAssertTrue(contract.firstViewportStructure.contains("Today"))
    }

    func testGoalsContractKeepsInspectionProgressive() {
        let contract = GoalsObjectStagePrimitiveContract.current
        XCTAssertTrue(contract.firstViewportStructure.contains("progressive trust inspection"))
        XCTAssertTrue(contract.sourceTrustLineOrder.contains("Today link"))
    }
}
