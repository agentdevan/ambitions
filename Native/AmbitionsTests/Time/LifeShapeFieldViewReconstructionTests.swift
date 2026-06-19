import XCTest
@testable import Ambitions

final class LifeShapeFieldViewReconstructionTests: XCTestCase {
    func testTimeObjectStageContractOwnsLifeShapeField() {
        let contract = TimeObjectStagePrimitiveContract.current
        XCTAssertEqual(contract.ownerSurface, "Time")
        XCTAssertEqual(contract.productObject, "LifeShape Field")
        XCTAssertTrue(contract.firstViewportAvoidsCalendarCardStackGeometry)
    }

    func testTimeObjectStageContractNamesCapacityPressureAndProtectedReality() {
        let structure = TimeObjectStagePrimitiveContract.current.firstViewportStructure
        XCTAssertTrue(structure.contains("capacity contours"))
        XCTAssertTrue(structure.contains("pressure texture"))
        XCTAssertTrue(structure.contains("protected windows"))
        XCTAssertTrue(structure.contains("fixed points"))
        XCTAssertTrue(structure.contains("horizons"))
        XCTAssertTrue(structure.contains("confirmation-first shaping actions"))
    }

    func testTimeObjectStageContractRejectsCalendarCloneGeometry() {
        let replaced = Set(TimeObjectStagePrimitiveContract.current.replacesFirstViewportStructures)
        XCTAssertTrue(replaced.contains("calendar clone"))
        XCTAssertTrue(replaced.contains("agenda clone"))
        XCTAssertTrue(replaced.contains("free/busy grid"))
        XCTAssertTrue(replaced.contains("metric-row stack"))
    }
}
