import Foundation
import XCTest
@testable import Ambitions

final class AmbitionGraphModelsTests: XCTestCase {
    func testAmbitionGraphSnapshotCapturesHierarchyAndTraceability() {
        let ambitionID = "ambition-1"
        let commitmentID = "commitment-1"
        let threadID = "thread-1"
        let proofID = "proof-1"
        let constraintID = "constraint-1"
        let recoveryID = "recovery-1"
        let traceID = "trace-1"
        let ambiguityReflectionID = "reflection-1"
        let adaptationID = "adaptation-1"

        let ambition = Ambition(
            id: ambitionID,
            title: "Build a personal operating system",
            identityStatement: "Move from scattered effort to proof-backed continuity.",
            lifeAreaID: "life-identity",
            desiredOutcome: "Sustained weekly progress with less reset.",
            desiredProofDescription: "Evidence of closed and reviewed commitments.",
            activeGoalThreadID: threadID,
            activeCommitmentID: commitmentID,
            knownConstraintIDs: [constraintID],
            recoveryPolicy: "Use smallest credible continuation by default.",
            createdAt: "2026-01-01T08:00:00Z",
            updatedAt: "2026-01-01T08:00:00Z"
        )

        let thread = GoalThread(
            id: threadID,
            ambitionID: ambitionID,
            name: "Life direction thread",
            goalIDs: ["goal-1"],
            isActive: true,
            createdAt: "2026-01-01T08:00:00Z",
            updatedAt: "2026-01-01T08:00:00Z"
        )

        let commitment = Commitment(
            id: commitmentID,
            ambitionID: ambitionID,
            goalThreadID: threadID,
            stepID: "step-1",
            promisedFor: "2026-01-02",
            expectedEffort: "20 min",
            minimumProofDescription: "Show a short completion note with evidence.",
            fitReason: "Fits today with protected time.",
            recoveryPolicy: "Restart with one smaller commitment.",
            status: .stillCounts,
            createdAt: "2026-01-01T09:00:00Z",
            updatedAt: "2026-01-01T09:00:00Z"
        )

        let identityDirection = IdentityDirection(
            id: "identity-direction-1",
            ambitionID: ambitionID,
            title: "Steadily present",
            statement: "Show up consistently in high-leverage routines.",
            priority: .primary,
            createdAt: "2026-01-01T08:30:00Z",
            updatedAt: "2026-01-01T08:30:00Z"
        )

        let outcome = Outcome(
            id: "outcome-1",
            ambitionID: ambitionID,
            identityDirectionID: "identity-direction-1",
            goalThreadID: threadID,
            title: "Weekly continuity proof",
            detail: "Complete one continuity anchor each week.",
            targetAt: "2026-01-07T00:00:00Z",
            kind: .capacity,
            isPrimary: true,
            metric: "frequency: 4/4 weeks",
            createdAt: "2026-01-01T08:45:00Z",
            updatedAt: "2026-01-01T08:45:00Z"
        )

        let step = AmbitionGraphStep(
            id: "step-1",
            ambitionID: ambitionID,
            goalThreadID: threadID,
            outcomeID: "outcome-1",
            name: "Open capture",
            description: "Record a short proof intent at beginning of day.",
            targetOrder: 1,
            expectedEffortMinutes: 10,
            isMilestone: true,
            createdAt: "2026-01-01T08:50:00Z",
            updatedAt: "2026-01-01T08:50:00Z"
        )

        let proof = Proof(
            id: proofID,
            ambitionID: ambitionID,
            goalThreadID: threadID,
            commitmentID: commitmentID,
            closureEventID: "closure-1",
            proofType: .text,
            artifactReference: nil,
            text: "Saved a proof reflection note.",
            source: "Today capture",
            createdAt: "2026-01-01T09:30:00Z"
        )

        let closureEvent = ClosureEvent(
            id: "closure-1",
            ambitionID: ambitionID,
            goalThreadID: threadID,
            ambitionGraphStepID: "step-1",
            commitmentID: commitmentID,
            proofID: proofID,
            closureState: .stillCounts,
            reason: "Moved from a broader weekly plan to a smaller continuation.",
            followUpPlan: "Hold continuity check next session.",
            createdAt: "2026-01-01T10:00:00Z"
        )

        let constraint = Constraint(
            id: constraintID,
            ambitionID: ambitionID,
            label: "Focused block window",
            patternDescription: "Two-hour meeting window on Fridays.",
            patternType: .environment,
            evidenceCount: 2,
            lastObservedAt: "2026-01-01T10:00:00Z",
            userConfirmed: true,
            mitigation: "Shift to a protected 30-minute slot.",
            createdAt: "2026-01-01T10:00:00Z",
            updatedAt: "2026-01-01T10:00:00Z"
        )

        let recovery = RecoveryThread(
            id: recoveryID,
            ambitionID: ambitionID,
            trigger: "Blocked by recurring meeting",
            priorProofRefs: [proofID],
            whatChanged: "Reduce ambition from 60 to 20 minutes",
            newSmallestCommitment: "Commitment-1-mini",
            status: .active,
            receiptID: "receipt-1",
            createdAt: "2026-01-01T10:15:00Z",
            updatedAt: "2026-01-01T10:15:00Z"
        )

        let trace = RecommendationTrace(
            id: traceID,
            recommendedObjectID: commitmentID,
            sourceRefs: ["source-1", "source-2"],
            reasonCodes: ["proof_gap", "time_fit", "constraint_overlap"],
            uncertainty: 0.19,
            userAction: .wrongRecommendation,
            createdAt: "2026-01-01T10:30:00Z",
            sourceLabels: ["Reality Meridian", "Local proof signal"]
        )

        let reflection = Reflection(
            id: ambiguityReflectionID,
            ambitionID: ambitionID,
            proofID: proofID,
            closureEventID: "closure-1",
            text: "Reduced scope and kept momentum through Still Counts.",
            learnedSignal: "Smaller commitments improve continuity.",
            createdAt: "2026-01-01T10:45:00Z"
        )

        let adaptation = AdaptationPivot(
            id: adaptationID,
            ambitionID: ambitionID,
            triggerProofID: proofID,
            sourceThreadID: threadID,
            proposedChange: "Move to a 20-minute minimum viable commitment.",
            resultingCommitmentID: commitmentID,
            createdAt: "2026-01-01T11:00:00Z",
            updatedAt: "2026-01-01T11:00:00Z"
        )

        let snapshot = AmbitionGraphSnapshot(
            id: "snapshot-1",
            ambition: ambition,
            commitments: [commitment],
            proofs: [proof],
            constraints: [constraint],
            recoveryThreads: [recovery],
            recommendationTraces: [trace],
            identityDirections: [identityDirection],
            outcomes: [outcome],
            steps: [step],
            closureEvents: [closureEvent]
        )

        XCTAssertEqual(snapshot.ambition.id, ambitionID)
        XCTAssertEqual(snapshot.commitments.map(\.id), [commitmentID])
        XCTAssertEqual(snapshot.proofs.first?.proofType, .text)
        XCTAssertEqual(snapshot.constraints.first?.patternType, .environment)
        XCTAssertTrue(snapshot.recoveryThreads.first?.isRecoverable ?? false)
        XCTAssertEqual(snapshot.identityDirections.map(\.priority), [.primary])
        XCTAssertEqual(snapshot.outcomes.map(\.kind), [.capacity])
        XCTAssertEqual(snapshot.steps.map(\.targetOrder), [1])
        XCTAssertEqual(snapshot.closureEvents.map(\.closureState), [.stillCounts])
        XCTAssertEqual(recovery.status, .active)
        XCTAssertEqual(reflection.learnedSignal, "Smaller commitments improve continuity.")
        XCTAssertTrue(adaptation.proposedChange.contains("20-minute"))
        XCTAssertEqual(thread.goalIDs, ["goal-1"])
    }

    func testAmbitionGraphSnapshotDecodesLegacyPayloadWithNewGraphFieldsAsDefaults() throws {
        let payload = """
        {
          "id": "snapshot-legacy",
          "ambition": {
            "id": "ambition-legacy",
            "title": "Legacy ambition contract",
            "identityStatement": "Ground continuity through daily proof.",
            "lifeAreaID": "life-legacy",
            "desiredOutcome": "Maintain continuity.",
            "desiredProofDescription": "One proof each day.",
            "activeGoalThreadID": "thread-legacy",
            "activeCommitmentID": "commitment-legacy",
            "knownConstraintIDs": [],
            "privacyClass": "private_user_text",
            "createdAt": "2026-01-01T00:00:00Z",
            "updatedAt": "2026-01-01T00:00:00Z"
          },
          "commitments": [],
          "proofs": [],
          "constraints": [],
          "recoveryThreads": [],
          "recommendationTraces": []
        }
        """

        let snapshot = try JSONDecoder().decode(AmbitionGraphSnapshot.self, from: Data(payload.utf8))

        XCTAssertEqual(snapshot.id, "snapshot-legacy")
        XCTAssertEqual(snapshot.ambition.id, "ambition-legacy")
        XCTAssertTrue(snapshot.identityDirections.isEmpty)
        XCTAssertTrue(snapshot.outcomes.isEmpty)
        XCTAssertTrue(snapshot.steps.isEmpty)
        XCTAssertTrue(snapshot.closureEvents.isEmpty)
        XCTAssertEqual(snapshot.schemaVersion, ambitionGraphSchemaVersion)
    }

    func testRecommendationTraceEnforcesExplainabilityAndNoAiCopyDefaults() {
        let trace = RecommendationTrace(
            id: "trace-1",
            recommendedObjectID: "obj-1",
            sourceRefs: ["source-1", "source-1", "source-2"],
            reasonCodes: ["closure_pressure", "proof_gap", "proof_gap"],
            uncertainty: 1.25,
            userAction: .none,
            createdAt: "2026-01-01T11:15:00Z",
            sourceLabels: ["Source Index", "Proof Index"]
        )

        XCTAssertEqual(trace.sourceRefs, ["source-1", "source-2"])
        XCTAssertEqual(trace.reasonCodes, ["closure_pressure", "proof_gap"])
        XCTAssertEqual(trace.userAction, .none)
        XCTAssertEqual(trace.uncertainty, 1.0)
        XCTAssertTrue(trace.isAiCopySuppressed)
        XCTAssertEqual(
            Set(trace.controlOptions),
            Set([.startNow, .openStep, .shorten, .move, .stillCounts, .notToday, .wrongRecommendation, .forgetPattern])
        )
    }

    func testCommitmentRequiresProofLanguageAndClosureStatesAvoidShameTerms() {
        XCTAssertEqual(AmbitionCommitmentStatus.allCases.map(\.rawValue).sorted(), [
            "completed",
            "held",
            "in_flight",
            "moved",
            "not_needed",
            "open",
            "promised",
            "still_counts",
            "stalled",
            "waiting",
        ].sorted())

        let closureLabels = AmbitionClosureState.allCases.map(\.displayLabel).joined(separator: " ")
        XCTAssertFalse(closureLabels.localizedCaseInsensitiveContains("Overdue"))
        XCTAssertFalse(closureLabels.localizedCaseInsensitiveContains("Failed"))
        XCTAssertEqual(AmbitionClosureState.stillCounts.displayLabel, "Still Counts")
        XCTAssertEqual(AmbitionClosureState.noLongerTrue.isClosureForRecovery, true)
        XCTAssertEqual(AmbitionClosureState.completed.isClosureForRecovery, false)
    }
}
