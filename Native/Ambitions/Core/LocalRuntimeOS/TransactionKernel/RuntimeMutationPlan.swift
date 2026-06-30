import Foundation

let runtimeMutationPlanSchemaVersion = "runtime_mutation_plan.native.v1"

struct RuntimeMutationPlan: Sendable, Equatable, Identifiable {
    let id: String
    let command: AmbitionsCommand
    let validation: RuntimeValidationReport
    let mutation: RuntimeMutation
    let readSet: RuntimeReadSet
    let writeSet: RuntimeWriteSet
    let expectedProjectionIDs: [ProjectionID]
    let targetSurface: StageMutationTargetSurface
    let plannedAt: String
    let checksum: String
    let schemaVersion: String

    init(
        command: AmbitionsCommand,
        validation: RuntimeValidationReport,
        latestEventCursor: RuntimeEventCursor?,
        projectionCursors: [ProjectionID: ProjectionCursor],
        beforeSnapshot: String,
        afterSnapshot: String,
        targetSurface: StageMutationTargetSurface,
        timeMutation: TimeMutation?,
        plannedAt: String,
        schemaVersion: String = runtimeMutationPlanSchemaVersion
    ) throws {
        guard validation.canMutate else {
            throw RuntimeTransactionError.blockedByValidation(commandID: command.id, reasons: validation.blockedReasons)
        }
        guard let mutation = RuntimeMutation(
            command: command,
            validation: validation,
            beforeSnapshot: beforeSnapshot,
            afterSnapshot: afterSnapshot,
            targetSurface: targetSurface,
            timeMutation: timeMutation
        ) else {
            throw RuntimeTransactionError.mutationProofIncomplete(commandID: command.id)
        }
        guard mutation.hasCompleteActionFlowProof else {
            throw RuntimeTransactionError.mutationProofIncomplete(commandID: command.id)
        }

        let projections = RuntimeTransactionObjectFacts.projections(command: command, mutation: mutation)
        let readSet = RuntimeReadSet(
            command: command,
            validation: validation,
            latestEventCursor: latestEventCursor,
            projectionCursors: projectionCursors,
            beforeSnapshot: mutation.stageMutation.beforeSnapshot,
            mutation: mutation
        )
        let writeSet = RuntimeWriteSet(
            command: command,
            mutation: mutation,
            projectionIDs: projections,
            occurredAt: plannedAt
        )

        self.id = "runtime.mutation-plan.\(command.id)"
        self.command = command
        self.validation = validation
        self.mutation = mutation
        self.readSet = readSet
        self.writeSet = writeSet
        self.expectedProjectionIDs = projections
        self.targetSurface = targetSurface
        self.plannedAt = plannedAt
        self.schemaVersion = schemaVersion
        self.checksum = RuntimeTransactionDigest.digest([
            id,
            command.id,
            command.kind.rawValue,
            validation.validationState.rawValue,
            readSet.checksum,
            writeSet.checksum,
            expectedProjectionIDs.map(\.rawValue).joined(separator: ","),
            targetSurface.rawValue,
            plannedAt,
            schemaVersion,
        ])
    }

    var isCommittable: Bool {
        validation.canMutate &&
            mutation.hasCompleteActionFlowProof &&
            readSet.isComplete &&
            writeSet.isComplete &&
            expectedProjectionIDs.isEmpty == false
    }
}
