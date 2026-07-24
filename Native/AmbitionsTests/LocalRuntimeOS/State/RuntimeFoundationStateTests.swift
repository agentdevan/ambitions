@testable import Ambitions
import Foundation
import XCTest

final class RuntimeFoundationStateTests: XCTestCase {
    func testEveryRuntimeIdentityNormalizesAndRejectsInvalidInput() throws {
        try assertIdentityBehavior(RuntimeCommandID.self)
        try assertIdentityBehavior(RuntimeAggregateID.self)
        try assertIdentityBehavior(RuntimeEventID.self)
        try assertIdentityBehavior(RuntimeReceiptID.self)
        try assertIdentityBehavior(RuntimeProjectionCursorID.self)
        try assertIdentityBehavior(RuntimeExternalOperationID.self)
        try assertIdentityBehavior(RuntimeMigrationID.self)
        try assertIdentityBehavior(RuntimeStoreGenerationID.self)
        try assertIdentityBehavior(RuntimeBlobID.self)
        try assertIdentityBehavior(RuntimeDomainObjectID.self)
    }

    func testEveryRuntimeIdentityCodableRoundTripsAndRejectsInvalidDecode() throws {
        try assertIdentityCoding(RuntimeCommandID.self)
        try assertIdentityCoding(RuntimeAggregateID.self)
        try assertIdentityCoding(RuntimeEventID.self)
        try assertIdentityCoding(RuntimeReceiptID.self)
        try assertIdentityCoding(RuntimeProjectionCursorID.self)
        try assertIdentityCoding(RuntimeExternalOperationID.self)
        try assertIdentityCoding(RuntimeMigrationID.self)
        try assertIdentityCoding(RuntimeStoreGenerationID.self)
        try assertIdentityCoding(RuntimeBlobID.self)
        try assertIdentityCoding(RuntimeDomainObjectID.self)
    }

    func testEveryRuntimeIdentityUsesCanonicalUnicodeStorageEqualityHashAndOrdering() throws {
        try assertIdentityUnicodeBehavior(RuntimeCommandID.self)
        try assertIdentityUnicodeBehavior(RuntimeAggregateID.self)
        try assertIdentityUnicodeBehavior(RuntimeEventID.self)
        try assertIdentityUnicodeBehavior(RuntimeReceiptID.self)
        try assertIdentityUnicodeBehavior(RuntimeProjectionCursorID.self)
        try assertIdentityUnicodeBehavior(RuntimeExternalOperationID.self)
        try assertIdentityUnicodeBehavior(RuntimeMigrationID.self)
        try assertIdentityUnicodeBehavior(RuntimeStoreGenerationID.self)
        try assertIdentityUnicodeBehavior(RuntimeBlobID.self)
        try assertIdentityUnicodeBehavior(RuntimeDomainObjectID.self)
    }

    func testExpectedRevisionCodingAndEqualityPreserveOnlyAbsentOrExact() throws {
        let values: [RuntimeExpectedRevision] = [.absent, .exact(0), .exact(42), .exact(UInt64.max)]

        for value in values {
            let data = try JSONEncoder().encode(value)
            XCTAssertEqual(try JSONDecoder().decode(RuntimeExpectedRevision.self, from: data), value)
        }

        XCTAssertNotEqual(RuntimeExpectedRevision.absent, .exact(0))
        XCTAssertNotEqual(RuntimeExpectedRevision.exact(41), .exact(42))
    }

    func testExpectedRevisionDecodeRejectsContradictoryMissingAndUnexpectedFields() {
        for malformedJSON in [
            #"{"kind":"absent","revision":0}"#,
            #"{"kind":"absent","revision":null}"#,
            #"{"kind":"exact"}"#,
            #"{"kind":"exact","revision":null}"#,
            #"{"kind":"exact","revision":4,"unexpected":true}"#,
        ] {
            XCTAssertThrowsError(
                try JSONDecoder().decode(RuntimeExpectedRevision.self, from: Data(malformedJSON.utf8)),
                "Unexpectedly decoded malformed payload: \(malformedJSON)"
            )
        }
    }

    func testTruthFactsRetainTypedOwnerRevisionProvenanceAndTransitionQualifiers() throws {
        let aggregateID = try RuntimeAggregateID(validating: "aggregate.plan")
        let objectID = try RuntimeDomainObjectID(validating: "step.local.1")
        let receiptID = try RuntimeReceiptID(validating: "receipt.local.1")
        let observedAt = Date(timeIntervalSince1970: 1_783_006_200)
        let fact = RuntimeTruthFact(
            state: .accepted,
            owner: .aggregate(aggregateID),
            subject: .domainObject(objectID),
            revision: 27,
            observedAt: observedAt,
            provenance: .receipt(receiptID),
            permittedTransitions: [.historical, .conflict, .historical, .undoAvailable]
        )

        XCTAssertEqual(fact.owner, .aggregate(aggregateID))
        XCTAssertEqual(fact.subject, .domainObject(objectID))
        XCTAssertEqual(fact.revision, 27)
        XCTAssertEqual(fact.observedAt, observedAt)
        XCTAssertEqual(fact.provenance, .receipt(receiptID))
        XCTAssertEqual(fact.permittedTransitions, [.historical, .conflict, .undoAvailable])
        XCTAssertTrue(fact.permitsTransition(to: .conflict))
        XCTAssertFalse(fact.permitsTransition(to: .saving))
        XCTAssertEqual(RuntimeTruthState.allCases.count, 18)

        let roundTrip = try JSONDecoder().decode(
            RuntimeTruthFact.self,
            from: JSONEncoder().encode(fact)
        )
        XCTAssertEqual(roundTrip, fact)
    }

    func testTruthFactDecodeCanonicalizesAdversarialTransitionOrderAndDuplicates() throws {
        let payload = AdversarialTruthFactPayload(
            state: .current,
            owner: .runtime,
            subject: .domainObject(try RuntimeDomainObjectID(validating: "object.truth")),
            revision: 3,
            observedAt: Date(timeIntervalSince1970: 1_783_006_200),
            provenance: .event(try RuntimeEventID(validating: "event.truth")),
            permittedTransitions: [.undoAvailable, .pending, .pending, .historical, .undoAvailable]
        )

        let decoded = try JSONDecoder().decode(
            RuntimeTruthFact.self,
            from: JSONEncoder().encode(payload)
        )

        XCTAssertEqual(decoded.permittedTransitions, [.historical, .pending, .undoAvailable])
    }

    func testStableOrderingUsesExplicitIdentityRevisionAndEventTieBreaks() throws {
        let objectA = try RuntimeDomainObjectID(validating: "object.a")
        let objectB = try RuntimeDomainObjectID(validating: "object.b")
        let eventA = try RuntimeEventID(validating: "event.a")
        let eventB = try RuntimeEventID(validating: "event.b")
        let unorderedIdentities = [
            try RuntimeCommandID(validating: "command.z"),
            try RuntimeCommandID(validating: "command.a"),
            try RuntimeCommandID(validating: "command.m"),
        ]

        XCTAssertEqual(
            RuntimeStableOrdering.identities(unorderedIdentities).map(\.rawValue),
            ["command.a", "command.m", "command.z"]
        )

        let records = [
            RevisionedFixture(label: "object-b", key: .init(objectID: objectB, revision: 1, eventID: eventA)),
            RevisionedFixture(label: "revision-2", key: .init(objectID: objectA, revision: 2, eventID: eventA)),
            RevisionedFixture(label: "event-b", key: .init(objectID: objectA, revision: 1, eventID: eventB)),
            RevisionedFixture(label: "event-a", key: .init(objectID: objectA, revision: 1, eventID: eventA)),
            RevisionedFixture(label: "equal-key-first", key: .init(objectID: objectA, revision: 1, eventID: eventA)),
            RevisionedFixture(label: "equal-key-second", key: .init(objectID: objectA, revision: 1, eventID: eventA)),
        ]

        XCTAssertEqual(
            RuntimeStableOrdering.revisioned(records, key: \.key).map(\.label),
            ["event-a", "equal-key-first", "equal-key-second", "event-b", "revision-2", "object-b"]
        )
    }

    private func assertIdentityBehavior<Identity: RuntimeIdentityValue>(_: Identity.Type) throws {
        XCTAssertEqual(try Identity(validating: "  runtime.id  ").rawValue, "runtime.id")
        XCTAssertEqual(try Identity(validating: "\u{00A0}runtime.id\u{00A0}").rawValue, "runtime.id")
        XCTAssertNil(Identity(rawValue: ""))
        XCTAssertNil(Identity(rawValue: " \n\t "))
        XCTAssertNil(Identity(rawValue: "\nruntime.id"))
        XCTAssertNil(Identity(rawValue: "runtime.id\n"))
        XCTAssertNil(Identity(rawValue: "\truntime.id"))
        XCTAssertNil(Identity(rawValue: "runtime.id\t"))
        XCTAssertNil(Identity(rawValue: "runtime\u{0000}id"))
        XCTAssertThrowsError(try Identity(validating: "runtime\u{0007}id")) { error in
            XCTAssertEqual(error as? RuntimeFoundationError, .invalidIdentity(Identity.identityKind))
        }
    }

    private func assertIdentityCoding<Identity: RuntimeIdentityValue>(_: Identity.Type) throws {
        let identity = try Identity(validating: "  runtime.id  ")
        let encoded = try JSONEncoder().encode(identity)

        XCTAssertEqual(try JSONDecoder().decode(Identity.self, from: encoded), identity)
        XCTAssertThrowsError(
            try JSONDecoder().decode(Identity.self, from: Data(#""runtime\u0000id""#.utf8))
        ) { error in
            XCTAssertTrue(error is DecodingError)
        }
        for edgeControlJSON in [
            #""\nruntime.id""#,
            #""runtime.id\n""#,
            #""\truntime.id""#,
            #""runtime.id\t""#,
        ] {
            XCTAssertThrowsError(
                try JSONDecoder().decode(Identity.self, from: Data(edgeControlJSON.utf8))
            ) { error in
                XCTAssertTrue(error is DecodingError)
            }
        }
    }

    private func assertIdentityUnicodeBehavior<Identity: RuntimeIdentityValue>(_: Identity.Type) throws {
        let composed = try Identity(validating: "caf\u{00E9}")
        let decomposed = try Identity(validating: "cafe\u{0301}")
        let orderedBeforeAccent = try Identity(validating: "caff")

        XCTAssertEqual(composed.rawValue, "caf\u{00E9}")
        XCTAssertEqual(decomposed.rawValue, composed.rawValue)
        XCTAssertEqual(composed, decomposed)
        XCTAssertEqual(Set([composed, decomposed]).count, 1)
        XCTAssertEqual(try JSONEncoder().encode(composed), try JSONEncoder().encode(decomposed))
        XCTAssertEqual(
            RuntimeStableOrdering.identities([composed, orderedBeforeAccent, decomposed]).map(\.rawValue),
            ["caff", "caf\u{00E9}", "caf\u{00E9}"]
        )
        let decomposedJSON = Data(#""cafe\u0301""#.utf8)
        XCTAssertEqual(try JSONDecoder().decode(Identity.self, from: decomposedJSON), composed)
    }
}

private struct RevisionedFixture {
    let label: String
    let key: RuntimeRevisionedOrderKey
}

private struct AdversarialTruthFactPayload: Encodable {
    let state: RuntimeTruthState
    let owner: RuntimeTruthOwner
    let subject: RuntimeTruthSubject
    let revision: UInt64
    let observedAt: Date
    let provenance: RuntimeTruthProvenance
    let permittedTransitions: [RuntimeTruthState]
}
