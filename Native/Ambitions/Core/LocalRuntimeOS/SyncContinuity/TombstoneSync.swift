import Foundation

struct TombstoneSyncDecision: Codable, Sendable, Equatable, Hashable {
    let id: String
    let shouldPropagate: Bool
    let shouldQuarantine: Bool
    let localStoreRemainsAuthoritative: Bool
    let reasons: [String]
}

struct TombstoneSync: Sendable, Equatable {
    func makeEnvelope(
        for tombstone: EntityRevisionTombstone,
        localRevision: Int,
        updatedAt: String
    ) throws -> CloudKitContinuityPortableRecordEnvelope {
        try CloudKitContinuityPortableRecordCodec.encode(
            tombstone,
            family: .tombstone,
            recordName: tombstone.id,
            schemaVersion: tombstone.schemaVersion,
            localRevision: localRevision,
            createdAt: tombstone.recordedAt,
            updatedAt: updatedAt,
            sourceRecordID: tombstone.sourceRecordID,
            receiptID: tombstone.receiptID,
            replayTraceID: tombstone.replayTraceID,
            reviewState: tombstone.localOnly ? .needsReview : .tombstoned,
            tombstone: CloudKitContinuityTombstoneMetadata(
                entityKind: tombstone.entityKind.rawValue,
                entityID: tombstone.entityID,
                reason: tombstone.reason.rawValue,
                recordedAt: tombstone.recordedAt,
                localOnly: tombstone.localOnly
            ),
            payloadClass: .tombstoneMetadata
        )
    }

    func evaluate(_ envelope: CloudKitContinuityPortableRecordEnvelope) -> TombstoneSyncDecision {
        guard let tombstone = envelope.tombstone else {
            return TombstoneSyncDecision(
                id: "tombstone_sync.\(envelope.id)",
                shouldPropagate: false,
                shouldQuarantine: true,
                localStoreRemainsAuthoritative: true,
                reasons: ["missing_tombstone_metadata"]
            )
        }

        if tombstone.localOnly {
            return TombstoneSyncDecision(
                id: "tombstone_sync.\(envelope.id)",
                shouldPropagate: false,
                shouldQuarantine: false,
                localStoreRemainsAuthoritative: true,
                reasons: ["local_only_tombstone"]
            )
        }

        if envelope.payloadClass != .tombstoneMetadata || envelope.reviewState == .conflict {
            return TombstoneSyncDecision(
                id: "tombstone_sync.\(envelope.id)",
                shouldPropagate: false,
                shouldQuarantine: true,
                localStoreRemainsAuthoritative: true,
                reasons: ["unsafe_tombstone_envelope"]
            )
        }

        return TombstoneSyncDecision(
            id: "tombstone_sync.\(envelope.id)",
            shouldPropagate: true,
            shouldQuarantine: false,
            localStoreRemainsAuthoritative: true,
            reasons: ["tombstone_metadata_safe"]
        )
    }
}
