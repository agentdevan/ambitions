import XCTest
@testable import Ambitions

final class ProgressEvidenceKindCodingTests: XCTestCase {
    func testRitualEvidenceKindEncodesCanonicalStorageValues() throws {
        let evidence = ProgressEvidence(
            id: "evidence-ritual",
            goalID: "goal-ritual",
            stepID: "step-ritual",
            evidenceKind: .ritualCompletion,
            source: .manual,
            capturedAt: "2026-04-20T09:00:00Z",
            progressDelta: 1,
            confidenceDelta: 0.1,
            minutesInvested: 10,
            note: nil
        )

        let data = try PersistenceCoding.encode(evidence)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        let decoded = try PersistenceCoding.decode(ProgressEvidence.self, from: data)

        XCTAssertTrue(json.contains("ritual_completion"))
        XCTAssertFalse(json.contains("habit_completion"))
        XCTAssertEqual(decoded, evidence)
    }

    func testLegacyHabitEvidenceStorageDecodesAsRitualAndReencodesCanonically() throws {
        let legacyJSON = """
        {
          "id": "evidence-legacy",
          "goalID": "goal-legacy",
          "stepID": "step-legacy",
          "evidenceKind": "habit_minimum_version",
          "source": "manual",
          "capturedAt": "2026-04-20T09:00:00Z",
          "progressDelta": 0.2,
          "confidenceDelta": 0.1,
          "minutesInvested": 5,
          "note": null
        }
        """

        let decoded = try PersistenceCoding.decode(ProgressEvidence.self, from: Data(legacyJSON.utf8))
        let reencoded = try PersistenceCoding.encode(decoded)
        let reencodedJSON = try XCTUnwrap(String(data: reencoded, encoding: .utf8))

        XCTAssertEqual(decoded.evidenceKind, .ritualMinimumVersion)
        XCTAssertTrue(reencodedJSON.contains("ritual_minimum_version"))
        XCTAssertFalse(reencodedJSON.contains("habit_minimum_version"))
    }
}
