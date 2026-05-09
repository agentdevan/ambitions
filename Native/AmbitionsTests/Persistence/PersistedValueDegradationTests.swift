import XCTest
@testable import Ambitions

final class PersistedValueDegradationTests: XCTestCase {
    func testKnownRawValueResolvesWithoutDegradation() {
        let result = PersistedValueDegradation.resolve(
            CaptureStatus.self,
            rawValue: CaptureStatus.actionable.rawValue,
            fallback: .needsTriage,
            storedTypeName: "CaptureRecord",
            fieldName: "statusRaw"
        )

        XCTAssertEqual(result.value, .actionable)
        XCTAssertNil(result.degradation)
    }

    func testUnknownRawValueFallsBackWithReviewableDegradationEntry() throws {
        let result = PersistedValueDegradation.resolve(
            GoalLifecycleState.self,
            rawValue: "future-paused-state",
            fallback: .active,
            storedTypeName: "GoalRecord",
            fieldName: "stateRaw"
        )
        let degradation = try XCTUnwrap(result.degradation)

        XCTAssertEqual(result.value, .active)
        XCTAssertEqual(degradation.schemaVersion, persistedValueDegradationSchemaVersion)
        XCTAssertEqual(degradation.storedTypeName, "GoalRecord")
        XCTAssertEqual(degradation.fieldName, "stateRaw")
        XCTAssertEqual(degradation.rawValue, "future-paused-state")
        XCTAssertEqual(degradation.fallbackRawValue, GoalLifecycleState.active.rawValue)
        XCTAssertEqual(degradation.reason, .unknownRawValue)
        XCTAssertEqual(degradation.disposition, .deterministicFallback)
        XCTAssertTrue(degradation.requiresReview)
        XCTAssertTrue(degradation.blocksMigrationClaim)
    }

    func testLegacyAliasResolvesWithoutReviewRequirement() throws {
        let result = PersistedValueDegradation.resolve(
            CaptureStatus.self,
            rawValue: "processed",
            fallback: .actionable,
            storedTypeName: "CaptureRecord",
            fieldName: "statusRaw",
            legacyAliases: ["processed": .goalBound]
        )
        let degradation = try XCTUnwrap(result.degradation)

        XCTAssertEqual(result.value, .goalBound)
        XCTAssertEqual(degradation.reason, .legacyAlias)
        XCTAssertEqual(degradation.fallbackRawValue, CaptureStatus.goalBound.rawValue)
        XCTAssertFalse(degradation.requiresReview)
        XCTAssertTrue(degradation.blocksMigrationClaim)
    }

    func testUnknownOptionalRawValueFallsBackToNil() throws {
        let result = PersistedValueDegradation.resolveOptional(
            CaptureSourceType.self,
            rawValue: "future-widget-source",
            storedTypeName: "CaptureRecord",
            fieldName: "sourceTypeRaw"
        )
        let degradation = try XCTUnwrap(result.degradation)

        XCTAssertNil(result.value)
        XCTAssertEqual(degradation.reason, .unknownRawValue)
        XCTAssertEqual(degradation.disposition, .optionalNilFallback)
        XCTAssertEqual(degradation.rawValue, "future-widget-source")
        XCTAssertNil(degradation.fallbackRawValue)
    }
}
