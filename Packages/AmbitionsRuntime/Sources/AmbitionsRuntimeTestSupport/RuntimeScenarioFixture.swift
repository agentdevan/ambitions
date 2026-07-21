import CryptoKit
import Foundation
import AmbitionsRuntimeCore
import AmbitionsRuntimeSQLite

public struct RuntimeScenarioClock: Codable, Sendable, Equatable {
    public let now: Date

    public init(now: Date) {
        self.now = now
    }
}

public struct RuntimeScenarioInitialState: Codable, Sendable, Equatable {
    public let aggregate: RuntimeAggregateReference
    public let revision: Int64
    public let value: Data

    public init(
        aggregate: RuntimeAggregateReference,
        revision: Int64,
        value: Data
    ) {
        self.aggregate = aggregate
        self.revision = revision
        self.value = value
    }
}

public struct RuntimeScenarioFault: Codable, Sendable, Equatable {
    public let commandIndex: Int
    public let point: RuntimeStoreFailurePoint

    public init(commandIndex: Int, point: RuntimeStoreFailurePoint) {
        self.commandIndex = commandIndex
        self.point = point
    }
}

public struct RuntimeScenarioExpectations: Codable, Sendable, Equatable {
    public let zeroPartialAuthorityBeforeCommit: Bool
    public let exactOnceRecoveryAfterCommit: Bool
    public let replayMatchesCanonicalState: Bool

    public init(
        zeroPartialAuthorityBeforeCommit: Bool = true,
        exactOnceRecoveryAfterCommit: Bool = true,
        replayMatchesCanonicalState: Bool = true
    ) {
        self.zeroPartialAuthorityBeforeCommit = zeroPartialAuthorityBeforeCommit
        self.exactOnceRecoveryAfterCommit = exactOnceRecoveryAfterCommit
        self.replayMatchesCanonicalState = replayMatchesCanonicalState
    }
}

public struct RuntimeScenarioScale: Codable, Sendable, Equatable {
    public let commandCount: Int
    public let aggregateCount: Int
    public let payloadBytes: Int

    public init(
        commandCount: Int,
        aggregateCount: Int,
        payloadBytes: Int
    ) {
        self.commandCount = commandCount
        self.aggregateCount = aggregateCount
        self.payloadBytes = payloadBytes
    }
}

public struct RuntimeScenarioFixture: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let id: String
    public let seed: UInt64
    public let clock: RuntimeScenarioClock
    public let calendarIdentifier: String
    public let localeIdentifier: String
    public let timeZoneIdentifier: String
    public let privacyClass: RuntimePrivacyClass
    public let origin: RuntimeCommandOrigin
    public let initialState: [RuntimeScenarioInitialState]
    public let commandHistory: [RuntimeCommandEnvelope]
    public let faultSchedule: [RuntimeScenarioFault]
    public let expectations: RuntimeScenarioExpectations
    public let scale: RuntimeScenarioScale

    public init(
        schemaVersion: Int = 1,
        id: String,
        seed: UInt64,
        clock: RuntimeScenarioClock,
        calendarIdentifier: String,
        localeIdentifier: String,
        timeZoneIdentifier: String,
        privacyClass: RuntimePrivacyClass,
        origin: RuntimeCommandOrigin,
        initialState: [RuntimeScenarioInitialState],
        commandHistory: [RuntimeCommandEnvelope],
        faultSchedule: [RuntimeScenarioFault],
        expectations: RuntimeScenarioExpectations,
        scale: RuntimeScenarioScale
    ) {
        self.schemaVersion = schemaVersion
        self.id = id
        self.seed = seed
        self.clock = clock
        self.calendarIdentifier = calendarIdentifier
        self.localeIdentifier = localeIdentifier
        self.timeZoneIdentifier = timeZoneIdentifier
        self.privacyClass = privacyClass
        self.origin = origin
        self.initialState = initialState
        self.commandHistory = commandHistory
        self.faultSchedule = faultSchedule
        self.expectations = expectations
        self.scale = scale
    }

    public static func generated(
        id: String,
        seed: UInt64,
        commandCount: Int,
        faultSchedule: [RuntimeScenarioFault] = []
    ) -> Self {
        var generator = RuntimeScenarioGenerator(seed: seed)
        let clock = RuntimeScenarioClock(
            now: Date(timeIntervalSince1970: TimeInterval(seed))
        )
        let history = (0..<commandCount).map { index in
            let aggregateIndex = Int(generator.next() % 4)
            let payload = withUnsafeBytes(of: generator.next().littleEndian) {
                Data($0)
            }
            return RuntimeCommandEnvelope(
                command: RuntimeCommand(
                    id: "command.\(index).\(generator.next())",
                    kind: "scenario.mutate",
                    aggregate: RuntimeAggregateReference(
                        kind: "scenario",
                        id: "aggregate.\(aggregateIndex)"
                    ),
                    payload: payload
                ),
                context: RuntimeExecutionContext(
                    idempotencyKey: "\(id).\(index)",
                    expectedRevision: nil,
                    issuedAt: clock.now.addingTimeInterval(TimeInterval(index)),
                    origin: .app,
                    privacyClass: .private
                )
            )
        }
        return RuntimeScenarioFixture(
            id: id,
            seed: seed,
            clock: clock,
            calendarIdentifier: "gregorian",
            localeIdentifier: "en_US_POSIX",
            timeZoneIdentifier: "UTC",
            privacyClass: .private,
            origin: .app,
            initialState: [],
            commandHistory: history,
            faultSchedule: faultSchedule,
            expectations: RuntimeScenarioExpectations(),
            scale: RuntimeScenarioScale(
                commandCount: history.count,
                aggregateCount: Set(history.map(\.command.aggregate)).count,
                payloadBytes: history.reduce(0) { $0 + $1.command.payload.count }
            )
        )
    }

    public func serializedData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public func digest() throws -> String {
        SHA256.hash(data: try serializedData())
            .map { String(format: "%02x", $0) }
            .joined()
    }

    fileprivate func replacingHistory(
        _ history: [RuntimeCommandEnvelope]
    ) -> RuntimeScenarioFixture {
        RuntimeScenarioFixture(
            schemaVersion: schemaVersion,
            id: id,
            seed: seed,
            clock: clock,
            calendarIdentifier: calendarIdentifier,
            localeIdentifier: localeIdentifier,
            timeZoneIdentifier: timeZoneIdentifier,
            privacyClass: privacyClass,
            origin: origin,
            initialState: initialState,
            commandHistory: history,
            faultSchedule: faultSchedule.filter { $0.commandIndex < history.count },
            expectations: expectations,
            scale: RuntimeScenarioScale(
                commandCount: history.count,
                aggregateCount: Set(history.map(\.command.aggregate)).count,
                payloadBytes: history.reduce(0) { $0 + $1.command.payload.count }
            )
        )
    }
}

public enum RuntimeScenarioShrinker {
    public static func minimize(
        _ fixture: RuntimeScenarioFixture,
        preservesFailure: (RuntimeScenarioFixture) -> Bool
    ) -> RuntimeScenarioFixture {
        guard preservesFailure(fixture) else { return fixture }
        var candidate = fixture
        var chunkSize = max(1, candidate.commandHistory.count / 2)

        while !candidate.commandHistory.isEmpty {
            var removed = false
            var lowerBound = 0
            while lowerBound < candidate.commandHistory.count {
                let upperBound = min(
                    candidate.commandHistory.count,
                    lowerBound + chunkSize
                )
                var history = candidate.commandHistory
                history.removeSubrange(lowerBound..<upperBound)
                let proposal = candidate.replacingHistory(history)
                if preservesFailure(proposal) {
                    candidate = proposal
                    removed = true
                    break
                }
                lowerBound = upperBound
            }
            if !removed {
                if chunkSize == 1 { break }
                chunkSize = max(1, chunkSize / 2)
            } else {
                chunkSize = max(1, candidate.commandHistory.count / 2)
            }
        }

        for index in candidate.commandHistory.indices {
            let envelope = candidate.commandHistory[index]
            let simplified = RuntimeCommandEnvelope(
                schemaVersion: envelope.schemaVersion,
                command: RuntimeCommand(
                    id: envelope.command.id,
                    kind: envelope.command.kind,
                    aggregate: envelope.command.aggregate,
                    payload: Data()
                ),
                context: envelope.context
            )
            var history = candidate.commandHistory
            history[index] = simplified
            let proposal = candidate.replacingHistory(history)
            if preservesFailure(proposal) {
                candidate = proposal
            }
        }
        return candidate
    }
}

public struct RuntimeScenarioReproduction: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let fixtureDigest: String
    public let seed: UInt64
    public let minimizedHistory: [RuntimeCommandEnvelope]
    public let failurePoint: RuntimeStoreFailurePoint
    public let toolVersions: [String: String]
    public let eventChecksum: String
    public let stateChecksum: String
    public let projectionChecksum: String
    public let receiptIDs: [String]

    public init(
        schemaVersion: Int = 1,
        fixture: RuntimeScenarioFixture,
        minimizedFixture: RuntimeScenarioFixture,
        failurePoint: RuntimeStoreFailurePoint,
        toolVersions: [String: String],
        eventChecksum: String,
        stateChecksum: String,
        projectionChecksum: String,
        receiptIDs: [String]
    ) throws {
        self.schemaVersion = schemaVersion
        fixtureDigest = try fixture.digest()
        seed = fixture.seed
        minimizedHistory = minimizedFixture.commandHistory
        self.failurePoint = failurePoint
        self.toolVersions = toolVersions
        self.eventChecksum = eventChecksum
        self.stateChecksum = stateChecksum
        self.projectionChecksum = projectionChecksum
        self.receiptIDs = receiptIDs
    }

    public func serializedData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }
}

private struct RuntimeScenarioGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x9E37_79B9_7F4A_7C15 : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state
    }
}
