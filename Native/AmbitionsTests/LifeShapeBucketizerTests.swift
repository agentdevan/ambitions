import XCTest
@testable import Ambitions

final class LifeShapeBucketizerTests: XCTestCase {
    func testEngineProjectionIsDeterministicForFrozenScenario() throws {
        let engine = LifeShapeEngine()

        let first = try engine.project(LifeShapeStressScenarios.calendarDeniedManualInput)
        let second = try engine.project(LifeShapeStressScenarios.calendarDeniedManualInput)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.selectedLayer, .open)
        XCTAssertEqual(Set(first.todayBuckets.map(\.layer)), Set([.open, .protected]))
        XCTAssertTrue(first.semanticSummary.contains("open window"))
    }

    func testEmptyScenarioDoesNotFabricateCapacityBuckets() throws {
        let projection = try LifeShapeEngine().project(LifeShapeStressScenarios.emptyManualInput)

        XCTAssertTrue(projection.todayBuckets.isEmpty)
        XCTAssertTrue(projection.semanticSummary.contains("no open capacity is claimed"))
        XCTAssertNil(projection.nowBucketID)
    }

    func testDenseDayUsesStrongOpenReadingsAndDoesNotExposePressureOrBuffer() throws {
        let projection = try LifeShapeEngine().project(LifeShapeStressScenarios.denseDayInput)
        let layers = Set(projection.todayBuckets.map(\.layer))
        let openBuckets = projection.todayBuckets.filter { $0.layer == .open }

        XCTAssertFalse(layers.contains(.pressure))
        XCTAssertFalse(layers.contains(.buffer))
        XCTAssertLessThanOrEqual(openBuckets.count, 3)
        XCTAssertTrue(openBuckets.allSatisfy { $0.reading.kind == .open })
        XCTAssertTrue(projection.todayBuckets.contains { $0.layer == .protected })
    }

    func testCalendarDeniedOpenBucketsCarryFallbackAndAccessibility() throws {
        let projection = try LifeShapeEngine().project(LifeShapeStressScenarios.calendarDeniedManualInput)
        let openBuckets = projection.todayBuckets.filter { $0.layer == .open }

        XCTAssertFalse(openBuckets.isEmpty)
        XCTAssertTrue(openBuckets.allSatisfy { $0.derivation.fallbackState?.kind == .calendarUnavailable })
        XCTAssertTrue(projection.todayBuckets.allSatisfy { $0.accessibilitySummary.isEmpty == false })
        XCTAssertTrue(projection.todayBuckets.allSatisfy { $0.derivation.isCompleteForVisibleMark })
    }
}
