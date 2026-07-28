@testable import Ambitions
import Foundation
import XCTest

final class RuntimeFoundationBoundaryTests: XCTestCase {
    func testRuntimeErrorSummariesNeverExposePrivateSentinelsOrFilePaths() throws {
        let privateSentinel = "PRIVATE_SENTINEL_/Users/person/Library/private.sqlite"
        let objectID = try RuntimeDomainObjectID(validating: privateSentinel)
        let commandID = try RuntimeCommandID(validating: privateSentinel)
        let migrationID = try RuntimeMigrationID(validating: privateSentinel)
        let cursorID = try RuntimeProjectionCursorID(validating: privateSentinel)
        let operationID = try RuntimeExternalOperationID(validating: privateSentinel)
        let receiptID = try RuntimeReceiptID(validating: privateSentinel)
        let errors: [RuntimeFoundationError] = [
            .invalidIdentity(.blob),
            .invalidSchema,
            .unsupportedSchema,
            .validation,
            .authorization,
            .revisionConflict(expected: .exact(4), actual: 5),
            .duplicate(objectID),
            .idempotencyCollision(commandID),
            .persistence,
            .corruption,
            .migration(migrationID),
            .projection(cursorID),
            .externalOperation(operationID),
            .cancellationBeforeCommit,
            .cancellationAfterCommit(receiptID),
            .privacyDenial,
            .unsupportedCapability,
        ]

        for error in errors {
            XCTAssertFalse(error.userFacingSummary.contains("PRIVATE_SENTINEL"))
            XCTAssertFalse(error.userFacingSummary.contains("/Users/"))
            XCTAssertFalse(error.userFacingSummary.contains("private.sqlite"))
        }
    }

    func testDeterministicClockUUIDAndRandomClientsRepeatIdenticalSequences() throws {
        let now = Date(timeIntervalSince1970: 1_783_006_200)
        let environmentA = try XCTUnwrap(RuntimeEnvironment.deterministic(now: now, seed: 84))
        let environmentB = try XCTUnwrap(RuntimeEnvironment.deterministic(now: now, seed: 84))

        XCTAssertEqual(environmentA.clock.now, environmentB.clock.now)
        XCTAssertEqual(environmentA.clock.now, now)
        XCTAssertEqual(environmentA.timeZone.timeZone.identifier, environmentB.timeZone.timeZone.identifier)
        XCTAssertEqual(environmentA.locale.locale.identifier, environmentB.locale.locale.identifier)
        XCTAssertEqual(environmentA.calendar.calendar.timeZone, environmentB.calendar.calendar.timeZone)

        var uuidA = environmentA.uuid
        var uuidB = environmentB.uuid
        var randomA = environmentA.random
        var randomB = environmentB.random
        var uuidSequenceA: [UUID] = []
        var uuidSequenceB: [UUID] = []
        var randomSequenceA: [UInt64] = []
        var randomSequenceB: [UInt64] = []

        for _ in 0..<8 {
            uuidSequenceA.append(uuidA.nextUUID())
            uuidSequenceB.append(uuidB.nextUUID())
            randomSequenceA.append(randomA.nextUInt64())
            randomSequenceB.append(randomB.nextUInt64())
        }

        XCTAssertEqual(uuidSequenceA, uuidSequenceB)
        XCTAssertEqual(randomSequenceA, randomSequenceB)
        XCTAssertEqual(Set(uuidSequenceA).count, uuidSequenceA.count)
    }

    func testLiveEnvironmentProvidesStructurallyValidValueClients() {
        var environmentA = RuntimeEnvironment.live

        XCTAssertFalse(environmentA.timeZone.timeZone.identifier.isEmpty)
        XCTAssertFalse(environmentA.locale.locale.identifier.isEmpty)
        let uuidBytes = environmentA.uuid.nextUUID().uuid
        XCTAssertEqual(uuidBytes.6 & 0xF0, 0x40)
        XCTAssertEqual(uuidBytes.8 & 0xC0, 0x80)
    }
}
