import Foundation
import XCTest
@testable import AmbitionsRuntimeCore

final class RuntimeContractTests: XCTestCase {
    func testCommandAndExecutionContextRoundTripWithoutLosingIdentity() throws {
        let command = RuntimeCommand(
            id: "command.capture.001",
            kind: "capture.commit",
            aggregate: RuntimeAggregateReference(
                kind: "capture",
                id: "capture.001"
            ),
            payload: Data(#"{"text":"Call Sam"}"#.utf8)
        )
        let context = RuntimeExecutionContext(
            idempotencyKey: "capture.001.commit",
            expectedRevision: 3,
            issuedAt: Date(timeIntervalSince1970: 1_800_000_000),
            origin: .app,
            privacyClass: .private
        )

        let encoded = try JSONEncoder().encode(
            RuntimeCommandEnvelope(command: command, context: context)
        )
        let decoded = try JSONDecoder().decode(
            RuntimeCommandEnvelope.self,
            from: encoded
        )

        XCTAssertEqual(decoded.command, command)
        XCTAssertEqual(decoded.context, context)
        XCTAssertEqual(decoded.schemaVersion, 1)
    }

    func testTransitionValidationRequiresOneAtomicCanonicalStory() throws {
        let aggregate = RuntimeAggregateReference(
            kind: "capture",
            id: "capture.001"
        )
        let event = RuntimeEvent(
            id: "event.capture.001",
            kind: "capture.committed",
            aggregate: aggregate,
            aggregateRevision: 4,
            payload: Data()
        )
        let stateChange = RuntimeStateChange(
            aggregate: aggregate,
            expectedRevision: 3,
            newRevision: 4,
            value: Data()
        )
        let projection = RuntimeProjectionChange(
            projection: "today",
            cursor: "cursor.today.004",
            payload: Data()
        )
        let inverse = RuntimeCommand(
            id: "command.capture.undo.001",
            kind: "capture.undo",
            aggregate: aggregate,
            payload: Data()
        )
        let receipt = RuntimeReceipt(
            id: "receipt.capture.001",
            commandID: "command.capture.001",
            canonicalRevision: 4,
            eventIDs: [event.id],
            projectionCursors: [projection.projection: projection.cursor],
            externalEffectIDs: [],
            semanticUndoEligible: true
        )
        let transition = RuntimeTransition(
            commandID: "command.capture.001",
            stateChanges: [stateChange],
            events: [event],
            projectionChanges: [projection],
            receipt: receipt,
            compensation: .inverseCommand(inverse),
            externalEffects: []
        )

        XCTAssertNoThrow(try transition.validate())

        let mismatched = RuntimeTransition(
            commandID: transition.commandID,
            stateChanges: transition.stateChanges,
            events: transition.events,
            projectionChanges: transition.projectionChanges,
            receipt: RuntimeReceipt(
                id: receipt.id,
                commandID: receipt.commandID,
                canonicalRevision: receipt.canonicalRevision,
                eventIDs: [],
                projectionCursors: receipt.projectionCursors,
                externalEffectIDs: receipt.externalEffectIDs,
                semanticUndoEligible: receipt.semanticUndoEligible
            ),
            compensation: transition.compensation,
            externalEffects: transition.externalEffects
        )
        XCTAssertThrowsError(try mismatched.validate()) { error in
            XCTAssertEqual(
                error as? RuntimeInvariantViolation,
                .receiptEventIdentityMismatch
            )
        }
    }

    func testOutcomeDistinguishesCommitProjectionConflictAndExternalEffectStates() {
        let commit = RuntimeCommitResult(
            receiptID: "receipt.001",
            canonicalRevision: 4,
            projectionCursors: ["today": "cursor.004"],
            semanticUndoEligible: true
        )
        let outcomes: [RuntimeOutcome] = [
            .committed(commit),
            .committedNeedsProjectionCatchUp(
                commit,
                pendingProjections: ["search"]
            ),
            .rejected(
                RuntimeRejection(code: "invalid", recovery: "Edit the draft")
            ),
            .conflicted(
                RuntimeConflict(expectedRevision: 3, actualRevision: 4)
            ),
            .externalEffectPending(commit, effectIDs: ["effect.001"]),
            .externalEffectReconciled(commit, effectIDs: ["effect.001"]),
            .externalEffectFailed(
                commit,
                failures: [
                    RuntimeExternalEffectFailure(
                        effectID: "effect.001",
                        code: "calendar_denied",
                        recovery: "Review Calendar access"
                    )
                ]
            )
        ]

        XCTAssertEqual(outcomes.count, 7)
        XCTAssertEqual(Set(outcomes.map(\.state)), Set(RuntimeOutcomeState.allCases))
    }
}
