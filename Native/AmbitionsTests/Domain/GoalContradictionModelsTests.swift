import XCTest
@testable import Ambitions

final class GoalContradictionModelsTests: XCTestCase {
    func testGoalContradictionReportRoundTripsThroughCodable() throws {
        let report = sampleReport()

        let encoded = try JSONEncoder().encode(report)
        let decoded = try JSONDecoder().decode(GoalContradictionReport.self, from: encoded)

        XCTAssertEqual(decoded, report)
    }

    func testEmptyReportHasNoRecords() {
        let report = GoalContradictionReport.empty()

        XCTAssertEqual(report.schemaVersion, goalContradictionSchemaVersion)
        XCTAssertTrue(report.records.isEmpty)
    }

    func testArtifactRefsAreStructuralAndHashable() {
        let first = GoalContradictionArtifactRef(
            kind: .planStep,
            id: "step-1",
            candidateID: "candidate-1",
            stageID: "stage-1"
        )
        let second = GoalContradictionArtifactRef(
            kind: .planStep,
            id: "step-1",
            candidateID: "candidate-1",
            stageID: "stage-1"
        )
        let third = GoalContradictionArtifactRef(
            kind: .planStep,
            id: "step-2",
            candidateID: "candidate-1",
            stageID: "stage-1"
        )

        XCTAssertEqual(first, second)
        XCTAssertNotEqual(first, third)
        XCTAssertEqual(Set<GoalContradictionArtifactRef>([first, second, third]).count, 2)
    }

    func testDeduplicationKeyIsStableForEquivalentRecords() {
        let original = sampleRecord(
            artifactRefs: [
                GoalContradictionArtifactRef(kind: .planStep, id: "step-1", candidateID: "candidate-1", stageID: "stage-1"),
                GoalContradictionArtifactRef(kind: .feedbackEvent, id: "feedback-1", candidateID: nil, stageID: nil)
            ]
        )
        let shuffled = sampleRecord(
            artifactRefs: [
                GoalContradictionArtifactRef(kind: .feedbackEvent, id: "feedback-1", candidateID: nil, stageID: nil),
                GoalContradictionArtifactRef(kind: .planStep, id: "step-1", candidateID: "candidate-1", stageID: "stage-1")
            ]
        )

        XCTAssertEqual(original.deduplicationKey, shuffled.deduplicationKey)
    }
}

private extension GoalContradictionModelsTests {
    func sampleReport() -> GoalContradictionReport {
        GoalContradictionReport(
            schemaVersion: goalContradictionSchemaVersion,
            records: [
                sampleRecord(
                    artifactRefs: [
                        GoalContradictionArtifactRef(kind: .inputContradiction, id: "timing-conflict", candidateID: nil, stageID: nil),
                        GoalContradictionArtifactRef(kind: .understandingConstraint, id: "constraint-time_horizon", candidateID: nil, stageID: nil)
                    ]
                )
            ]
        )
    }

    func sampleRecord(
        artifactRefs: [GoalContradictionArtifactRef]
    ) -> GoalContradictionRecord {
        GoalContradictionRecord(
            id: "contradiction-1",
            code: .inputTimingConflict,
            category: .goalInput,
            severity: .blocking,
            confidence: .high,
            summary: "Timing preferences conflict with deadline phrasing.",
            candidateID: nil,
            stageID: nil,
            artifactRefs: artifactRefs
        )
    }
}
