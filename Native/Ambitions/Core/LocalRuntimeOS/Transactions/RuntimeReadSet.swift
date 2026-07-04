import Foundation

let runtimeReadSetSchemaVersion = "runtime_read_set.native.v1"

struct RuntimeReadSet: Sendable, Codable, Equatable, Hashable, Identifiable {
    let id: String
    let commandID: String
    let source: AmbitionsCommandSource
    let targetObjectIDs: [String]
    let objectFamilies: [ObjectStateFamily]
    let validationState: AmbitionsCommandValidationState
    let privacyBoundarySatisfied: Bool
    let latestEventCursor: RuntimeEventCursor?
    let projectionCursors: [ProjectionCursor]
    let beforeSnapshotID: String
    let beforeSnapshotSummary: String
    let localOnly: Bool
    let checksum: String
    let schemaVersion: String

    init(
        command: AmbitionsCommand,
        validation: RuntimeValidationReport,
        latestEventCursor: RuntimeEventCursor?,
        projectionCursors: [ProjectionID: ProjectionCursor],
        beforeSnapshot: MutationSnapshotReference,
        mutation: RuntimeMutation? = nil,
        schemaVersion: String = runtimeReadSetSchemaVersion
    ) {
        self.id = "runtime.read-set.\(command.id)"
        self.commandID = command.id
        self.source = command.source
        self.targetObjectIDs = RuntimeTransactionObjectFacts.affectedObjectIDs(command: command, mutation: mutation)
        self.objectFamilies = RuntimeTransactionObjectFacts.families(command: command, mutation: mutation)
        self.validationState = validation.validationState
        self.privacyBoundarySatisfied = validation.privacyBoundary.isSatisfied
        self.latestEventCursor = latestEventCursor
        self.projectionCursors = projectionCursors.values.sorted()
        self.beforeSnapshotID = beforeSnapshot.id
        self.beforeSnapshotSummary = beforeSnapshot.summary
        self.localOnly = command.localOnly && validation.privacyBoundary.localOnly
        self.schemaVersion = schemaVersion
        self.checksum = RuntimeTransactionDigest.digest([
            id,
            commandID,
            source.rawValue,
            targetObjectIDs.joined(separator: ","),
            objectFamilies.map(\.rawValue).joined(separator: ","),
            validationState.rawValue,
            String(privacyBoundarySatisfied),
            latestEventCursor?.eventID ?? "",
            latestEventCursor.map { String($0.sequence) } ?? "",
            self.projectionCursors.map { "\($0.projectionID.rawValue):\($0.sequence):\($0.checksum)" }.joined(separator: ","),
            beforeSnapshotID,
            beforeSnapshotSummary,
            String(localOnly),
            schemaVersion,
        ])
    }

    var isComplete: Bool {
        commandID.isEmpty == false &&
            validationState == .valid &&
            privacyBoundarySatisfied &&
            beforeSnapshotID.isEmpty == false &&
            beforeSnapshotSummary.isEmpty == false &&
            localOnly
    }
}
