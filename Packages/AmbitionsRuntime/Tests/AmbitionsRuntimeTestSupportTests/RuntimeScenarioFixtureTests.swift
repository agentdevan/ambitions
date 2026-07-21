import Foundation
import XCTest
import AmbitionsRuntimeCore
import AmbitionsRuntimeSQLite
@testable import AmbitionsRuntimeTestSupport

final class RuntimeScenarioFixtureTests: XCTestCase {
    func testSeededFixturesAreDeterministicAndRoundTripExactly() throws {
        let first = RuntimeScenarioFixture.generated(
            id: "golden.capture",
            seed: 42,
            commandCount: 8
        )
        let second = RuntimeScenarioFixture.generated(
            id: "golden.capture",
            seed: 42,
            commandCount: 8
        )
        let differentSeed = RuntimeScenarioFixture.generated(
            id: "golden.capture",
            seed: 43,
            commandCount: 8
        )

        XCTAssertEqual(first, second)
        XCTAssertEqual(try first.digest(), try second.digest())
        XCTAssertNotEqual(first.commandHistory, differentSeed.commandHistory)

        let encoded = try first.serializedData()
        let decoded = try JSONDecoder().decode(
            RuntimeScenarioFixture.self,
            from: encoded
        )
        XCTAssertEqual(decoded, first)
    }

    func testFixtureCarriesEveryDeterministicExecutionInput() {
        let fixture = RuntimeScenarioFixture.generated(
            id: "failure.before-commit",
            seed: 7,
            commandCount: 3,
            faultSchedule: [
                RuntimeScenarioFault(
                    commandIndex: 1,
                    point: .afterEvents
                )
            ]
        )

        XCTAssertEqual(fixture.schemaVersion, 1)
        XCTAssertEqual(fixture.clock.now, Date(timeIntervalSince1970: 7))
        XCTAssertEqual(fixture.calendarIdentifier, "gregorian")
        XCTAssertEqual(fixture.localeIdentifier, "en_US_POSIX")
        XCTAssertEqual(fixture.timeZoneIdentifier, "UTC")
        XCTAssertEqual(fixture.privacyClass, .private)
        XCTAssertEqual(fixture.origin, .app)
        XCTAssertEqual(fixture.faultSchedule.first?.point, .afterEvents)
        XCTAssertEqual(fixture.scale.commandCount, 3)
        XCTAssertEqual(fixture.expectations.zeroPartialAuthorityBeforeCommit, true)
    }

    func testShrinkerRemovesUnrelatedHistoryAndSimplifiesPayload() {
        let fixture = RuntimeScenarioFixture.generated(
            id: "shrink.failure",
            seed: 99,
            commandCount: 12
        )
        let failingCommandID = fixture.commandHistory[9].command.id

        let minimized = RuntimeScenarioShrinker.minimize(fixture) { candidate in
            candidate.commandHistory.contains {
                $0.command.id == failingCommandID
            }
        }

        XCTAssertEqual(minimized.commandHistory.count, 1)
        XCTAssertEqual(minimized.commandHistory[0].command.id, failingCommandID)
        XCTAssertTrue(minimized.commandHistory[0].command.payload.isEmpty)
        XCTAssertEqual(minimized.scale.commandCount, 1)
    }

    func testReproductionSerializesMinimizedHistoryAndChecksums() throws {
        let fixture = RuntimeScenarioFixture.generated(
            id: "restart.after-commit",
            seed: 101,
            commandCount: 4
        )
        let minimized = RuntimeScenarioShrinker.minimize(fixture) { candidate in
            !candidate.commandHistory.isEmpty
        }
        let reproduction = try RuntimeScenarioReproduction(
            fixture: fixture,
            minimizedFixture: minimized,
            failurePoint: .afterReceipt,
            toolVersions: ["swift": "6.2"],
            eventChecksum: "events-1",
            stateChecksum: "state-1",
            projectionChecksum: "projection-1",
            receiptIDs: ["receipt.command.0"]
        )

        let data = try reproduction.serializedData()
        let decoded = try JSONDecoder().decode(
            RuntimeScenarioReproduction.self,
            from: data
        )

        XCTAssertEqual(decoded, reproduction)
        XCTAssertEqual(decoded.fixtureDigest, try fixture.digest())
        XCTAssertEqual(decoded.seed, 101)
        XCTAssertEqual(decoded.minimizedHistory.count, 1)
        XCTAssertEqual(decoded.failurePoint, .afterReceipt)
        XCTAssertEqual(decoded.eventChecksum, "events-1")
        XCTAssertEqual(decoded.receiptIDs, ["receipt.command.0"])
    }

    func testAfterCommitFailurePointRoundTripsInDeterministicFixtures() throws {
        let fixture = RuntimeScenarioFixture.generated(
            id: "restart.after-commit",
            seed: 102,
            commandCount: 1,
            faultSchedule: [
                RuntimeScenarioFault(commandIndex: 0, point: .afterCommit)
            ]
        )

        let data = try fixture.serializedData()
        let decoded = try JSONDecoder().decode(
            RuntimeScenarioFixture.self,
            from: data
        )

        XCTAssertEqual(decoded.faultSchedule, fixture.faultSchedule)
        XCTAssertEqual(decoded.faultSchedule.first?.point, .afterCommit)
        let serialized = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertTrue(serialized.contains("after_commit"))
    }
}
