import XCTest
@testable import Ambitions

final class AmbitionGraphProjectionStoreTests: XCTestCase {
    func testCrossSurfaceLoopCarriesGoalToLifeDirectionContext() {
        let snapshot = makeSnapshot()
        let store = AmbitionGraphProjectionStore(snapshots: [snapshot])

        guard let loop = store.crossSurfaceLoop(
            for: snapshot.id,
            generatedAt: "2026-05-13T01:52:18Z",
            id: "mri07-goal-to-life-direction-loop",
            projectionIDPrefix: "mri07"
        ) else {
            return XCTFail("Cross-surface loop should exist")
        }

        XCTAssertTrue(loop.localProjectionOnly)
        XCTAssertTrue(loop.connectsEveryCanonicalSurface)
        XCTAssertTrue(loop.carriesGoalToLifeDirectionContext)
        XCTAssertEqual(loop.coveredSurfaces, [.today, .goals, .capture, .time, .you])
        XCTAssertEqual(
            loop.surfaceProjectionIDs,
            ["mri07-capture", "mri07-goals", "mri07-time", "mri07-today", "mri07-you"]
        )
        XCTAssertEqual(loop.identityDirectionIDs, ["identity-direction-1"])
        XCTAssertEqual(loop.outcomeIDs, ["outcome-capture", "outcome-primary"])
        XCTAssertEqual(
            loop.commitmentIDs,
            ["commitment-capture", "commitment-complete", "commitment-goal", "commitment-promised", "commitment-today"]
        )
        XCTAssertEqual(loop.stepIDs, ["step-capture", "step-complete", "step-goal", "step-time", "step-today"])
        XCTAssertEqual(loop.closureEventIDs, ["closure-today"])
        XCTAssertEqual(loop.proofIDs, ["proof-capture", "proof-goal", "proof-today"])
        XCTAssertEqual(loop.recoveryThreadIDs, ["recovery-active"])
        XCTAssertEqual(loop.recommendationTraceIDs, ["trace-capture", "trace-goals"])
        XCTAssertEqual(
            loop.privacyClasses,
            [.privateConstraint, .privateProof, .privateUserText, .systemOwned]
        )
        XCTAssertEqual(
            loop.sourceFields,
            ["capture app", "goals-source", "source-label", "source-ref"]
        )
    }

    func testProjectionFiltersSurfaceOutputsForAmbitionGraphContext() {
        let snapshot = makeSnapshot()
        let store = AmbitionGraphProjectionStore(snapshots: [snapshot])

        guard let todayProjection = store.projection(
            for: .today,
            snapshotID: snapshot.id,
            generatedAt: "2026-05-12T08:00:00Z",
            id: "today-projection"
        ) else {
            return XCTFail("Today projection should exist")
        }

        guard let goalsProjection = store.projection(
            for: .goals,
            snapshotID: snapshot.id,
            generatedAt: "2026-05-12T08:01:00Z",
            id: "goals-projection"
        ) else {
            return XCTFail("Goals projection should exist")
        }

        guard let captureProjection = store.projection(
            for: .capture,
            snapshotID: snapshot.id,
            generatedAt: "2026-05-12T08:02:00Z",
            id: "capture-projection"
        ) else {
            return XCTFail("Capture projection should exist")
        }

        guard let timeProjection = store.projection(
            for: .time,
            snapshotID: snapshot.id,
            generatedAt: "2026-05-12T08:03:00Z",
            id: "time-projection"
        ) else {
            return XCTFail("Time projection should exist")
        }

        guard let youProjection = store.projection(
            for: .you,
            snapshotID: snapshot.id,
            generatedAt: "2026-05-12T08:04:00Z",
            id: "you-projection"
        ) else {
            return XCTFail("You projection should exist")
        }

        XCTAssertEqual(todayProjection.commitmentIDs, ["commitment-capture", "commitment-promised", "commitment-today"])
        XCTAssertEqual(todayProjection.proofIDs, ["proof-today"])
        XCTAssertEqual(todayProjection.stepIDs, ["step-time", "step-today"])
        XCTAssertEqual(goalsProjection.stepIDs, ["step-goal", "step-time", "step-today"])
        XCTAssertEqual(captureProjection.commitmentIDs, ["commitment-capture"])
        XCTAssertEqual(captureProjection.proofIDs, ["proof-capture"])
        XCTAssertEqual(timeProjection.commitmentIDs, ["commitment-promised", "commitment-today"])
        XCTAssertEqual(timeProjection.stepIDs, ["step-time", "step-today"])
        XCTAssertEqual(youProjection.commitmentIDs, ["commitment-capture", "commitment-complete", "commitment-promised", "commitment-today"])
    }

    func testProjectionIDsAreDeduplicatedAndOrdered() {
        let snapshot = makeSnapshot()
        let store = AmbitionGraphProjectionStore(snapshots: [snapshot])

        guard let captureProjection = store.projection(
            for: .capture,
            snapshotID: snapshot.id,
            generatedAt: "2026-05-12T08:00:00Z",
            id: "capture-projection"
        ) else {
            return XCTFail("Capture projection should exist")
        }

        let duplicateProof = snapshot.proofs + [
            Proof(
                id: "proof-capture",
                ambitionID: snapshot.ambition.id,
                goalThreadID: "thread-capture",
                proofType: .photo,
                source: "capture app",
                createdAt: "2026-05-12T08:00:00Z"
            )
        ]
        let duplicateClosure = AmbitionGraphSnapshot(
            id: snapshot.id,
            ambition: snapshot.ambition,
            commitments: snapshot.commitments,
            proofs: duplicateProof,
            constraints: snapshot.constraints,
            recoveryThreads: snapshot.recoveryThreads,
            recommendationTraces: snapshot.recommendationTraces,
            identityDirections: snapshot.identityDirections,
            outcomes: snapshot.outcomes,
            steps: snapshot.steps,
            closureEvents: snapshot.closureEvents
        )
        let dedupeStore = AmbitionGraphProjectionStore(snapshots: [duplicateClosure])
        guard let dedupedCapture = dedupeStore.projection(
            for: .capture,
            snapshotID: duplicateClosure.id,
            generatedAt: "2026-05-12T08:00:00Z",
            id: "capture-projection"
        ) else {
            return XCTFail("Capture projection should exist")
        }

        XCTAssertEqual(dedupedCapture.proofIDs, ["proof-capture"])
        XCTAssertEqual(dedupedCapture.sourceObjectIDs, ["ambition-graphql", "commitment-capture", "constraint-capture", "proof-capture"])
        XCTAssertEqual(dedupedCapture.proofIDs, captureProjection.proofIDs)
    }

    func testPrivacyAndSourceFieldsTrackInProjectionContract() {
        let snapshot = makeSnapshot()
        let store = AmbitionGraphProjectionStore(snapshots: [snapshot])
        guard let youProjection = store.projection(
            for: .you,
            snapshotID: snapshot.id,
            generatedAt: "2026-05-12T08:00:00Z",
            id: "you-projection"
        ) else {
            return XCTFail("You projection should exist")
        }

        XCTAssertTrue(youProjection.localProjectionOnly)
        XCTAssertTrue(youProjection.hasPrivateContent)
        XCTAssertEqual(
            youProjection.privacyClasses.sorted(by: { $0.rawValue < $1.rawValue }),
            [AmbitionPrivacyClass.privateConstraint, .privateProof, .privateUserText]
        )
        XCTAssertEqual(
            youProjection.sourceFields,
            ["capture app", "goals-source", "source-label", "source-ref"]
        )
    }

    func testNoForbiddenUserFacingTermsArePresentInSurfaceNames() {
        let forbidden = [
            "task",
            "tasks",
            "productivity app",
            "card",
            "dashboard",
            "ai",
            "shame",
            "streak"
        ]
        for term in forbidden {
            let includesTerm = AmbitionGraphProjectionSurface.allCases.contains {
                $0.rawValue.localizedCaseInsensitiveContains(term)
            }
            XCTAssertFalse(includesTerm, "Forbidden term should not appear in surface names: \(term)")
        }
    }
}

private extension AmbitionGraphProjectionStoreTests {
    func makeSnapshot() -> AmbitionGraphSnapshot {
        let ambition = Ambition(
            id: "ambition-graphql",
            title: "Build a durable operating rhythm",
            identityStatement: "Move with continuity and proof.",
            privacyClass: .privateUserText,
            createdAt: "2026-05-12T07:00:00Z",
            updatedAt: "2026-05-12T07:00:00Z"
        )

        let captureCommitment = Commitment(
            id: "commitment-capture",
            ambitionID: "ambition-graphql",
            stepID: "step-capture",
            minimumProofDescription: "Capture and review.",
            fitReason: "Capture confidence check.",
            status: .open,
            createdAt: "2026-05-12T07:00:00Z",
            updatedAt: "2026-05-12T07:00:00Z"
        )

        let goalsCommitment = Commitment(
            id: "commitment-goal",
            ambitionID: "ambition-graphql",
            goalThreadID: "thread-goals",
            status: .open,
            createdAt: "2026-05-12T07:00:00Z",
            updatedAt: "2026-05-12T07:00:00Z"
        )

        let promisedCommitment = Commitment(
            id: "commitment-promised",
            ambitionID: "ambition-graphql",
            goalThreadID: "thread-time",
            stepID: "step-time",
            promisedFor: "2026-05-12T10:00:00Z",
            expectedEffort: "20m",
            status: .promised,
            createdAt: "2026-05-12T07:05:00Z",
            updatedAt: "2026-05-12T07:05:00Z"
        )

        let todayCommitment = Commitment(
            id: "commitment-today",
            ambitionID: "ambition-graphql",
            goalThreadID: "thread-time",
            stepID: "step-today",
            promisedFor: "2026-05-12T11:00:00Z",
            status: .inFlight,
            createdAt: "2026-05-12T07:10:00Z",
            updatedAt: "2026-05-12T07:10:00Z"
        )

        let completeCommitment = Commitment(
            id: "commitment-complete",
            ambitionID: "ambition-graphql",
            stepID: "step-complete",
            status: .completed,
            createdAt: "2026-05-12T07:10:00Z",
            updatedAt: "2026-05-12T07:10:00Z"
        )

        let stepGoal = AmbitionGraphStep(
            id: "step-goal",
            ambitionID: "ambition-graphql",
            goalThreadID: "thread-goals",
            name: "Write one page",
            targetOrder: 1,
            isCompleted: false,
            createdAt: "2026-05-12T07:15:00Z",
            updatedAt: "2026-05-12T07:15:00Z"
        )

        let stepCapture = AmbitionGraphStep(
            id: "step-capture",
            ambitionID: "ambition-graphql",
            goalThreadID: "thread-capture",
            name: "Capture evidence",
            targetOrder: 2,
            expectedEffortMinutes: 3,
            isMilestone: true,
            isCompleted: false,
            createdAt: "2026-05-12T07:16:00Z",
            updatedAt: "2026-05-12T07:16:00Z"
        )

        let stepTime = AmbitionGraphStep(
            id: "step-time",
            ambitionID: "ambition-graphql",
            goalThreadID: "thread-time",
            name: "Do first work block",
            targetOrder: 3,
            expectedEffortMinutes: 30,
            isCompleted: false,
            createdAt: "2026-05-12T07:17:00Z",
            updatedAt: "2026-05-12T07:17:00Z"
        )

        let stepToday = AmbitionGraphStep(
            id: "step-today",
            ambitionID: "ambition-graphql",
            goalThreadID: "thread-time",
            name: "Execute first 20 minutes",
            targetOrder: 4,
            expectedEffortMinutes: 20,
            isCompleted: false,
            createdAt: "2026-05-12T07:18:00Z",
            updatedAt: "2026-05-12T07:18:00Z"
        )

        let stepComplete = AmbitionGraphStep(
            id: "step-complete",
            ambitionID: "ambition-graphql",
            goalThreadID: "thread-time",
            name: "Completed context cleanup",
            targetOrder: 5,
            isCompleted: true,
            createdAt: "2026-05-12T07:19:00Z",
            updatedAt: "2026-05-12T07:19:00Z"
        )

        let captureProof = Proof(
            id: "proof-capture",
            ambitionID: "ambition-graphql",
            commitmentID: "commitment-capture",
            proofType: .photo,
            source: "capture app",
            privacyClass: .privateProof,
            userConfirmed: true,
            createdAt: "2026-05-12T07:20:00Z"
        )

        let todayProof = Proof(
            id: "proof-today",
            ambitionID: "ambition-graphql",
            commitmentID: "commitment-today",
            proofType: .text,
            privacyClass: .privateProof,
            userConfirmed: true,
            createdAt: "2026-05-12T07:21:00Z"
        )

        let goalProof = Proof(
            id: "proof-goal",
            ambitionID: "ambition-graphql",
            goalThreadID: "thread-goals",
            proofType: .artifact,
            privacyClass: .systemOwned,
            createdAt: "2026-05-12T07:22:00Z"
        )

        let constraintCaptured = Constraint(
            id: "constraint-capture",
            ambitionID: "ambition-graphql",
            label: "Capture buffer",
            patternDescription: "Manual review window",
            patternType: .supportNeed,
            userConfirmed: true,
            mitigation: "Capture within local review window.",
            privacyClass: .privateConstraint,
            createdAt: "2026-05-12T07:23:00Z",
            updatedAt: "2026-05-12T07:23:00Z"
        )

        let identityDirection = IdentityDirection(
            id: "identity-direction-1",
            ambitionID: "ambition-graphql",
            title: "Steady execution",
            statement: "Do work in realistic chunks.",
            priority: .primary,
            createdAt: "2026-05-12T07:24:00Z",
            updatedAt: "2026-05-12T07:24:00Z"
        )

        let outcomePrimary = Outcome(
            id: "outcome-primary",
            ambitionID: "ambition-graphql",
            title: "Progress continuity",
            kind: .behavior,
            isPrimary: true,
            createdAt: "2026-05-12T07:25:00Z",
            updatedAt: "2026-05-12T07:25:00Z"
        )

        let outcomeSecondary = Outcome(
            id: "outcome-capture",
            ambitionID: "ambition-graphql",
            goalThreadID: "thread-capture",
            title: "Capture quality",
            kind: .capacity,
            isPrimary: false,
            createdAt: "2026-05-12T07:26:00Z",
            updatedAt: "2026-05-12T07:26:00Z"
        )

        let closure = ClosureEvent(
            id: "closure-today",
            ambitionID: "ambition-graphql",
            goalThreadID: "thread-time",
            ambitionGraphStepID: "step-today",
            commitmentID: "commitment-today",
            closureState: .stillCounts,
            reason: "Small continuation started.",
            followUpPlan: "Continue in 20-minute blocks.",
            createdAt: "2026-05-12T07:27:00Z"
        )

        let recovery = RecoveryThread(
            id: "recovery-active",
            ambitionID: "ambition-graphql",
            trigger: "Capacity dip",
            whatChanged: "Shorten commitment.",
            status: .active,
            createdAt: "2026-05-12T07:28:00Z",
            updatedAt: "2026-05-12T07:28:00Z"
        )

        let captureTrace = AmbitionGraphRecommendationTrace(
            id: "trace-capture",
            recommendedObjectID: "commitment-capture",
            sourceRefs: ["source-ref"],
            reasonCodes: ["capture"],
            userAction: .openStep,
            createdAt: "2026-05-12T07:29:00Z",
            sourceLabels: ["source-label"]
        )

        let goalsTrace = AmbitionGraphRecommendationTrace(
            id: "trace-goals",
            recommendedObjectID: "commitment-goal",
            sourceRefs: ["goals-source"],
            reasonCodes: ["goal"],
            userAction: .startNow,
            createdAt: "2026-05-12T07:30:00Z"
        )

        return AmbitionGraphSnapshot(
            id: "snapshot-mri02",
            ambition: ambition,
            commitments: [
                captureCommitment,
                goalsCommitment,
                promisedCommitment,
                todayCommitment,
                completeCommitment
            ],
            proofs: [captureProof, todayProof, goalProof],
            constraints: [constraintCaptured],
            recoveryThreads: [recovery],
            recommendationTraces: [captureTrace, goalsTrace],
            identityDirections: [identityDirection],
            outcomes: [outcomePrimary, outcomeSecondary],
            steps: [stepGoal, stepCapture, stepTime, stepToday, stepComplete],
            closureEvents: [closure]
        )
    }
}
