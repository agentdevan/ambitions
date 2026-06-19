import XCTest
@testable import Ambitions

final class ProgressStrategyCodingTests: XCTestCase {
    func testRitualRhythmStrategyEncodesCanonicalStorageValues() throws {
        let strategy = ProgressStrategy(
            metricKind: .ritualRhythm,
            rollupMethod: .rhythmLength,
            targetStepCount: nil,
            targetEvidenceCount: 5,
            targetMinutes: nil,
            supportsUntimedProgress: true,
            countsChildGoals: false,
            countsSupportGoals: false
        )

        let data = try PersistenceCoding.encode(strategy)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        let decoded = try PersistenceCoding.decode(ProgressStrategy.self, from: data)

        XCTAssertTrue(json.contains("ritual_rhythm"))
        XCTAssertTrue(json.contains("rhythm_length"))
        XCTAssertFalse(json.contains("streak"))
        XCTAssertEqual(decoded, strategy)
    }

    func testLegacyStreakStorageDecodesAsRitualRhythmAndReencodesCanonically() throws {
        let legacyJSON = """
        {
          "metricKind": "streak",
          "rollupMethod": "streak_length",
          "targetStepCount": null,
          "targetEvidenceCount": 5,
          "targetMinutes": null,
          "supportsUntimedProgress": true,
          "countsChildGoals": false,
          "countsSupportGoals": false
        }
        """

        let decoded = try PersistenceCoding.decode(ProgressStrategy.self, from: Data(legacyJSON.utf8))
        let reencoded = try PersistenceCoding.encode(decoded)
        let reencodedJSON = try XCTUnwrap(String(data: reencoded, encoding: .utf8))

        XCTAssertEqual(decoded.metricKind, .ritualRhythm)
        XCTAssertEqual(decoded.rollupMethod, .rhythmLength)
        XCTAssertTrue(reencodedJSON.contains("ritual_rhythm"))
        XCTAssertTrue(reencodedJSON.contains("rhythm_length"))
        XCTAssertFalse(reencodedJSON.contains("streak"))
    }
}
