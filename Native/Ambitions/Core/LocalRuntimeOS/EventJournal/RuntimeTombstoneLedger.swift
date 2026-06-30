import Foundation

enum RuntimeTombstoneObjectFamily: String, Codable, Equatable, Hashable, CaseIterable {
    case goalThread = "goal_thread"
    case lifeArea = "life_area"
    case step
    case capture
    case timeBlock = "time_block"
    case closure
    case proof
    case receipt
    case userSystem = "user_system"
    case appState = "app_state"
    case projection
}

struct RuntimeTombstoneEventPayload: Codable, Equatable, Hashable {
    let tombstoneID: String
    let objectFamily: RuntimeTombstoneObjectFamily
    let objectID: String
    let lineageID: String?
    let reason: String
    let supersededByObjectID: String?

    init(
        tombstoneID: String,
        objectFamily: RuntimeTombstoneObjectFamily,
        objectID: String,
        lineageID: String? = nil,
        reason: String,
        supersededByObjectID: String? = nil
    ) {
        self.tombstoneID = tombstoneID
        self.objectFamily = objectFamily
        self.objectID = objectID
        self.lineageID = lineageID?.isEmpty == false ? lineageID : nil
        self.reason = reason
        self.supersededByObjectID = supersededByObjectID?.isEmpty == false ? supersededByObjectID : nil
    }
}

struct RuntimeTombstoneLedger {
    let store: any RuntimeEventStore

    @discardableResult
    func append(
        _ payload: RuntimeTombstoneEventPayload,
        commandID: String?,
        actor: AmbitionsCommandActor,
        source: AmbitionsCommandSource,
        privacy: EventLedgerPrivacyClassification,
        occurredAt: String
    ) async throws -> RuntimeEventEnvelope {
        try await store.append(
            RuntimeEvent(
                commandID: commandID,
                actor: actor,
                source: source,
                privacy: privacy,
                occurredAt: occurredAt,
                payload: .tombstoneRecorded(payload),
                metadata: [
                    "objectFamily": payload.objectFamily.rawValue,
                    "objectID": payload.objectID,
                ]
            )
        )
    }
}
