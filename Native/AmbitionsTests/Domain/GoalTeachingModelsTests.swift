import XCTest
@testable import Ambitions

final class GoalTeachingModelsTests: XCTestCase {
    func testSignalRoundTripsThroughCodable() throws {
        let signal = GoalTeachingSignal(
            id: "teaching-1",
            goalID: "goal-1",
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            source: .explicitManualCorrection,
            kind: .classificationCorrection,
            disposition: .active,
            anchor: GoalTeachingStableAnchor(
                artifactKind: .classificationField,
                canonicalField: .mode,
                candidateID: nil,
                stageID: nil,
                stepID: nil,
                targetFingerprint: "mode",
                contradictionCode: nil,
                contradictionArtifactRefs: []
            ),
            payload: .classification(
                GoalTeachingClassificationCorrection(
                    field: .mode,
                    correctedValue: .mode(.learning)
                )
            ),
            applicationKey: "goal-1::classification",
            userNote: "This is a learning goal."
        )

        let data = try PersistenceCoding.encode(signal)
        let decoded = try PersistenceCoding.decode(GoalTeachingSignal.self, from: data)

        XCTAssertEqual(decoded, signal)
    }

    func testContradictionAnchorNormalizationIgnoresArtifactRefOrdering() {
        let first = GoalTeachingStableAnchor.contradiction(
            code: .requiredResourceMissingSupport,
            candidateID: "candidate-1",
            stageID: "stage-1",
            artifactRefs: [
                GoalTeachingContradictionArtifactRef(kind: .resource, id: "resource-b"),
                GoalTeachingContradictionArtifactRef(kind: .knowledgeClaim, id: "claim-a")
            ]
        )
        let second = GoalTeachingStableAnchor.contradiction(
            code: .requiredResourceMissingSupport,
            candidateID: "candidate-1",
            stageID: "stage-1",
            artifactRefs: [
                GoalTeachingContradictionArtifactRef(kind: .knowledgeClaim, id: "claim-a"),
                GoalTeachingContradictionArtifactRef(kind: .resource, id: "resource-b")
            ]
        )

        XCTAssertEqual(first.targetFingerprint, second.targetFingerprint)
    }

    func testApplicationKeyIncludesNormalizedTargetValue() {
        let anchor = GoalTeachingStableAnchor(
            artifactKind: .goalSubjectField,
            canonicalField: .goalSubject,
            candidateID: nil,
            stageID: nil,
            stepID: nil,
            targetFingerprint: "goal_subject",
            contradictionCode: nil,
            contradictionArtifactRefs: []
        )

        let first = GoalTeachingSignal.makeApplicationKey(
            goalID: "goal-1",
            kind: .goalSubjectCorrection,
            anchor: anchor,
            normalizedTargetValue: "become an astronaut"
        )
        let second = GoalTeachingSignal.makeApplicationKey(
            goalID: "goal-1",
            kind: .goalSubjectCorrection,
            anchor: anchor,
            normalizedTargetValue: "launch a startup"
        )

        XCTAssertNotEqual(first, second)
    }
}
