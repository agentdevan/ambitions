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
            recommendationTraces: [trace]
        )

        XCTAssertEqual(snapshot.ambition.id, ambitionID)
        XCTAssertEqual(snapshot.commitments.map(\.id), [commitmentID])
        XCTAssertEqual(snapshot.proofs.first?.proofType, .text)
        XCTAssertEqual(snapshot.constraints.first?.patternType, .environment)
        XCTAssertTrue(snapshot.recoveryThreads.first?.isRecoverable ?? false)
        XCTAssertEqual(recovery.status, .active)
        XCTAssertEqual(reflection.learnedSignal, "Smaller commitments improve continuity.")
        XCTAssertTrue(adaptation.proposedChange.contains("20-minute"))
        XCTAssertEqual(thread.goalIDs, ["goal-1"])
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
