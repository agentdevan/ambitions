import Foundation

struct PrivateLifeRuntime: Sendable {
    let boundary: PrivateLifeRuntimeBoundary
    let projectionPipeline: RuntimeProjectionPipeline
    let validator: RuntimeValidator

    init(
        boundary: PrivateLifeRuntimeBoundary = .localOnly,
        projectionPipeline: RuntimeProjectionPipeline = RuntimeProjectionPipeline(),
        validator: RuntimeValidator = RuntimeValidator()
    ) {
        self.boundary = boundary
        self.projectionPipeline = projectionPipeline
        self.validator = validator
    }

    func snapshot(
        input: NowStateProjectionInput,
        proofs: [Proof] = []
    ) -> RuntimeSnapshot {
        projectionPipeline.project(input: input, proofs: proofs, boundary: boundary)
    }

    func validate(_ command: AmbitionsCommand) -> RuntimeValidationReport {
        validator.validate(command, boundary: boundary)
    }

    func mutation(
        for command: AmbitionsCommand,
        beforeSnapshot: String,
        afterSnapshot: String,
        targetSurface: StageMutationTargetSurface,
        timeMutation: TimeMutation? = nil
    ) -> RuntimeMutation? {
        RuntimeMutation(
            command: command,
            validation: validate(command),
            beforeSnapshot: beforeSnapshot,
            afterSnapshot: afterSnapshot,
            targetSurface: targetSurface,
            timeMutation: timeMutation
        )
    }
}
