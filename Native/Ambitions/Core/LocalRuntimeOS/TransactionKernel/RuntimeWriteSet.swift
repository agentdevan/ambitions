import Foundation

let runtimeWriteSetSchemaVersion = "runtime_write_set.native.v1"

struct RuntimeWriteSet: Sendable, Codable, Equatable, Hashable, Identifiable {
    let id: String
    let commandID: String
    let event: RuntimeEvent
    let affectedObjectIDs: [String]
    let objectFamilies: [ObjectStateFamily]
    let projectionIDs: [ProjectionID]
    let stageMutationID: String
    let motionEventID: String
    let proofArtifactID: String
    let receiptID: String
    let replayTraceID: String
    let afterSnapshotID: String
    let afterSnapshotSummary: String
    let localOnly: Bool
    let checksum: String
    let schemaVersion: String

    init(
        command: AmbitionsCommand,
        mutation: RuntimeMutation,
        projectionIDs: [ProjectionID],
        occurredAt: String,
        schemaVersion: String = runtimeWriteSetSchemaVersion
    ) {
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: mutation.stageMutation.visibleUserFacingChange,
            target: command.target,
            eventLedgerEntryIDs: command.relations.eventLedgerEntryIDs,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "runtimeMutationID": mutation.id,
                "stageMutationID": mutation.stageMutation.runtimeMutationID,
                "proofArtifactID": mutation.stageMutation.proofArtifact.artifactID,
                "receiptID": mutation.stageMutation.receipt.receiptID,
                "motionEventID": mutation.stageMutation.motionEvent,
                "visibleChange": mutation.stageMutation.visibleUserFacingChange,
            ]
        )
        self.id = "runtime.write-set.\(command.id)"
        self.commandID = command.id
        self.event = RuntimeEvent.commandExecution(
            command: command.validated(as: mutation.validation.validationState),
            result: result,
            recordedAt: occurredAt,
            commandRecordID: "command.execution.\(command.id)"
        )
        self.affectedObjectIDs = RuntimeTransactionObjectFacts.affectedObjectIDs(command: command, mutation: mutation)
        self.objectFamilies = RuntimeTransactionObjectFacts.families(command: command, mutation: mutation)
        self.projectionIDs = Array(Set(projectionIDs)).sorted { $0.rawValue < $1.rawValue }
        self.stageMutationID = mutation.stageMutation.runtimeMutationID
        self.motionEventID = mutation.stageMutation.motionEvent
        self.proofArtifactID = mutation.stageMutation.proofArtifact.artifactID
        self.receiptID = mutation.stageMutation.receipt.receiptID
        self.replayTraceID = "runtime.replay.\(command.id)"
        self.afterSnapshotID = mutation.stageMutation.afterSnapshot.id
        self.afterSnapshotSummary = mutation.stageMutation.afterSnapshot.summary
        self.localOnly = command.localOnly && mutation.validation.privacyBoundary.localOnly && event.localOnly
        self.schemaVersion = schemaVersion
        self.checksum = RuntimeTransactionDigest.digest([
            id,
            commandID,
            event.kind.rawValue,
            event.occurredAt,
            affectedObjectIDs.joined(separator: ","),
            objectFamilies.map(\.rawValue).joined(separator: ","),
            self.projectionIDs.map(\.rawValue).joined(separator: ","),
            stageMutationID,
            motionEventID,
            proofArtifactID,
            receiptID,
            replayTraceID,
            afterSnapshotID,
            afterSnapshotSummary,
            String(localOnly),
            schemaVersion,
        ])
    }

    var isComplete: Bool {
        commandID.isEmpty == false &&
            affectedObjectIDs.isEmpty == false &&
            projectionIDs.isEmpty == false &&
            stageMutationID.isEmpty == false &&
            proofArtifactID.isEmpty == false &&
            receiptID.isEmpty == false &&
            replayTraceID.isEmpty == false &&
            afterSnapshotID.isEmpty == false &&
            afterSnapshotSummary.isEmpty == false &&
            localOnly
    }
}
