import Foundation

enum TimeFieldMutationError: Error, Equatable {
    case noVisibleMutationTarget
    case runtimeRejected(String)
}

struct TimeFieldMutationResult: Sendable {
    let previousTimeState: TimeSurfaceState
    let updatedTimeState: TimeSurfaceState
    let command: AmbitionsCommand
    let timeMutation: TimeMutation
    let runtimeMutation: RuntimeMutation

    var visibleMutation: UserVisibleMutation {
        runtimeMutation.userVisibleMutation
    }
}

struct TimeFieldUndoResult: Sendable {
    let restoredTimeState: TimeSurfaceState
    let visibleMutation: UserVisibleMutation
}

struct TimeFieldMutationCoordinator: Sendable {
    let runtime: PrivateLifeRuntime

    init(runtime: PrivateLifeRuntime = PrivateLifeRuntime()) {
        self.runtime = runtime
    }

    func perform(
        _ action: TimeFieldMutationAction,
        in timeState: TimeSurfaceState,
        selectedMark: LifeShapeSemanticMark?,
        now: Date
    ) throws -> TimeFieldMutationResult {
        let visibleProjection = try LifeShapeProjection.fromVisibleTimeField(
            timeState.lifeSuite.field,
            selectedMark: selectedMark,
            preferredLayer: action.targetLayer,
            now: now
        )
        guard let targetBucket = visibleProjection.targetBucket(for: selectedMark, preferredLayer: action.targetLayer) else {
            throw TimeFieldMutationError.noVisibleMutationTarget
        }

        let command = makeCommand(
            action,
            targetBucket: targetBucket,
            selectedMark: selectedMark,
            now: now
        )
        let timeMutation = try TimeMutation.make(command: command, beforeProjection: visibleProjection)
        guard let runtimeMutation = runtime.mutation(
            for: command,
            beforeSnapshot: visibleProjection.semanticSummary,
            afterSnapshot: timeMutation.afterProjection.semanticSummary,
            targetSurface: .time,
            timeMutation: timeMutation
        ) else {
            let validation = runtime.validate(command)
            throw TimeFieldMutationError.runtimeRejected(validation.blockedReasons.joined(separator: ", "))
        }

        let updatedLifeSuite = timeState.lifeSuite.applying(timeMutation: timeMutation, runtimeMutation: runtimeMutation)
        return TimeFieldMutationResult(
            previousTimeState: timeState,
            updatedTimeState: timeState.replacing(lifeSuite: updatedLifeSuite),
            command: command,
            timeMutation: timeMutation,
            runtimeMutation: runtimeMutation
        )
    }

    func undo(_ result: TimeFieldMutationResult, now: Date) -> TimeFieldUndoResult {
        let undoMutation = RuntimeMutation.undoVisibleMutation(
            original: result.runtimeMutation,
            restoredSnapshot: result.timeMutation.beforeProjection.semanticSummary,
            now: now
        )
        return TimeFieldUndoResult(
            restoredTimeState: result.previousTimeState,
            visibleMutation: undoMutation
        )
    }

    private func makeCommand(
        _ action: TimeFieldMutationAction,
        targetBucket: LifeShapeBucket,
        selectedMark: LifeShapeSemanticMark?,
        now: Date
    ) -> AmbitionsCommand {
        let timeID = targetBucket.id
        let stepID = action == .placeStep ? "step.\(Self.idComponent(timeID))" : nil
        let createdAt = Self.isoString(from: now)
        let command = AmbitionsCommand(
            id: "command.time.\(action.rawValue).\(Self.idComponent(timeID)).\(Self.idComponent(createdAt))",
            kind: action.commandKind,
            source: .time,
            target: AmbitionsCommandTarget(
                goalID: selectedMark?.inputRefs.first { $0.kind == .goal }?.id ?? "goal.time-field",
                timeID: timeID,
                stepID: stepID
            ),
            payload: AmbitionsCommandPayload(
                title: action.title,
                notes: selectedMark?.accessibilitySummary ?? targetBucket.accessibilitySummary,
                metadata: action.commandMetadata
            ),
            createdAt: createdAt,
            sourceSurface: "Time"
        )
        return command.validated(as: AmbitionsCommandValidator().validate(command))
    }

    private static func isoString(from date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }

    private static func idComponent(_ value: String) -> String {
        value
            .lowercased()
            .map { character in
                character.isLetter || character.isNumber ? character : "-"
            }
            .reduce(into: "") { partial, character in
                if character == "-", partial.last == "-" { return }
                partial.append(character)
            }
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}
