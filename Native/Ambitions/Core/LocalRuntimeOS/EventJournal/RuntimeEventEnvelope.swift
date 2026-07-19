import Foundation

let runtimeEventEnvelopeSchemaVersion = "runtime_event_envelope.native.v1"

struct RuntimeEventEnvelope: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let sequence: Int64
    let previousChecksum: String?
    let causalClock: RuntimeCausalClock
    let event: RuntimeEvent
    let checksum: String
    let schemaVersion: String

    init(
        id: String,
        sequence: Int64,
        previousChecksum: String?,
        causalClock: RuntimeCausalClock,
        event: RuntimeEvent,
        checksum: String,
        schemaVersion: String = runtimeEventEnvelopeSchemaVersion
    ) {
        self.id = id
        self.sequence = max(1, sequence)
        self.previousChecksum = previousChecksum?.isEmpty == false ? previousChecksum : nil
        self.causalClock = causalClock
        self.event = event
        self.checksum = checksum
        self.schemaVersion = schemaVersion
    }

    static func make(
        sequence: Int64,
        previousChecksum: String?,
        event: RuntimeEvent,
        deviceID: String = RuntimeLocalDeviceID.current
    ) throws -> RuntimeEventEnvelope {
        let normalizedSequence = max(1, sequence)
        let id = "runtime.event.\(normalizedSequence)"
        let causalClock = RuntimeCausalClock.tick(
            sequence: normalizedSequence,
            occurredAt: event.occurredAt,
            deviceID: deviceID
        )
        let material = RuntimeEventChecksumMaterial(
            id: id,
            sequence: normalizedSequence,
            previousChecksum: previousChecksum,
            causalClock: causalClock,
            event: event,
            schemaVersion: runtimeEventEnvelopeSchemaVersion
        )
        return try RuntimeEventEnvelope(
            id: id,
            sequence: normalizedSequence,
            previousChecksum: previousChecksum,
            causalClock: causalClock,
            event: event,
            checksum: RuntimeEventChecksum.digest(material)
        )
    }

    var cursor: RuntimeEventCursor {
        RuntimeEventCursor(
            sequence: sequence,
            eventID: id,
            checksum: checksum,
            occurredAt: event.occurredAt
        )
    }

    var checksumMaterial: RuntimeEventChecksumMaterial {
        RuntimeEventChecksumMaterial(
            id: id,
            sequence: sequence,
            previousChecksum: previousChecksum,
            causalClock: causalClock,
            event: event,
            schemaVersion: schemaVersion
        )
    }
}
