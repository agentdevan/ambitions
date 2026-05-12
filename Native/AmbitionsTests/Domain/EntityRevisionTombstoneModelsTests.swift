import XCTest
@testable import Ambitions

final class EntityRevisionTombstoneModelsTests: XCTestCase {
    func testDefaultEntityRevisionTombstoneIsWellFormed() {
        let tombstone = EntityRevisionTombstone(
            entityKind: .goal,
            entityID: "goal-1",
            revisionMarker: "revision-v1",
            reason: .deleted,
            recordedAt: "2026-05-12T12:00:00Z"
        )

        XCTAssertTrue(tombstone.isWellFormed)
        XCTAssertEqual(tombstone.schemaVersion, entityRevisionTombstoneSchemaVersion)
        XCTAssertEqual(tombstone.localOnly, true)
        XCTAssertEqual(
            tombstone.id,
            "entity_revision_tombstone.goal.goal-1:revision-v1"
        )
    }

    func testMalformedTombstonesAreNotWellFormed() {
        let malformedID = EntityRevisionTombstone(
            id: " ",
            entityKind: .goal,
            entityID: "",
            revisionMarker: "",
            reason: .unknown,
            recordedAt: "",
            schemaVersion: "wrong.version"
        )

        XCTAssertFalse(malformedID.isWellFormed)
    }

    func testMakeIDSanitizesWhitespaceForEntityAndRevisionIdentifiers() {
        let generated = EntityRevisionTombstone.makeID(
            entityKind: .goalDraft,
            entityID: "goal draft 1",
            revisionMarker: "rev 1"
        )

        XCTAssertEqual(generated, "entity_revision_tombstone.goal_draft.goal_draft_1:rev_1")
    }
}
