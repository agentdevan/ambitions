import XCTest
@testable import Ambitions

final class ConflictPolicyModelsTests: XCTestCase {
    func testEqualValuesDoNotCreateConflict() {
        let decision = LocalConflictPolicyEngine().decide(
            ConflictPolicyCandidate(
                entityKind: "goal",
                localRevision: 2,
                incomingRevision: 2,
                localUpdatedAt: "2026-05-12T10:00:00Z",
                incomingUpdatedAt: "2026-05-12T10:00:00Z",
                valuesAreEqual: true
            )
        )

        XCTAssertEqual(decision.signal, .noConflict)
        XCTAssertEqual(decision.localMarker, "2")
        XCTAssertEqual(decision.incomingMarker, "2")
    }

    func testRevisionOrderingWinsBeforeTimestamps() {
        let decision = LocalConflictPolicyEngine().decide(
            ConflictPolicyCandidate(
                entityKind: "goal",
                localRevision: 3,
                incomingRevision: 2,
                localUpdatedAt: "2026-05-12T09:00:00Z",
                incomingUpdatedAt: "2026-05-12T10:00:00Z",
                valuesAreEqual: false
            )
        )

        XCTAssertEqual(decision.signal, .keepLocal)
        XCTAssertEqual(decision.localMarker, "3")
        XCTAssertEqual(decision.incomingMarker, "2")
    }

    func testNewerIncomingTimestampCanBeAcceptedWhenRevisionsAreAbsent() {
        let decision = LocalConflictPolicyEngine().decide(
            ConflictPolicyCandidate(
                entityKind: "capture",
                localUpdatedAt: "2026-05-12T09:00:00Z",
                incomingUpdatedAt: "2026-05-12T10:00:00Z",
                valuesAreEqual: false
            )
        )

        XCTAssertEqual(decision.signal, .acceptIncoming)
        XCTAssertEqual(decision.localMarker, "2026-05-12T09:00:00Z")
        XCTAssertEqual(decision.incomingMarker, "2026-05-12T10:00:00Z")
    }

    func testUnsafeAutomaticMergeRequiresUserDecision() {
        let decision = LocalConflictPolicyEngine().decide(
            ConflictPolicyCandidate(
                entityKind: "app_state",
                localUpdatedAt: "local-marker",
                incomingUpdatedAt: "incoming-marker",
                valuesAreEqual: false,
                safeAutomaticMergeAllowed: false
            )
        )

        XCTAssertEqual(decision.signal, .requiresUserDecision)
        XCTAssertEqual(decision.localMarker, "local-marker")
        XCTAssertEqual(decision.incomingMarker, "incoming-marker")
    }
}
