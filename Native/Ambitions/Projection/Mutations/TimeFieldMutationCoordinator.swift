import Foundation

enum TimeFieldMutationError: Error, Equatable {
    case noVisibleMutationTarget
    case missingEligibleStep
    case runtimeRejected(String)
    case protectedPlacementRequiresApproval(ProtectedStepPlacementDecision)
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
    let placementEngine: PlacementEngine

    init(
        runtime: PrivateLifeRuntime = PrivateLifeRuntime(),
        placementEngine: PlacementEngine = PlacementEngine()
    ) {
        self.runtime = runtime
        self.placementEngine = placementEngine
    }

    func perform(
        _ action: TimeFieldMutationAction,
        in timeState: TimeSurfaceState,
        selectedMark: LifeShapeSemanticMark?,
        now: Date,
        actor: AmbitionsCommandActor = .user,
        explicitProtectedPlacementApproval: Bool = true
    ) throws -> TimeFieldMutationResult {
        let visibleProjection = try LifeShapeProjection.fromVisibleTimeField(
            timeState.lifeSuite.field,
            selectedMark: selectedMark,
            preferredLayer: action.targetLayer,
            placementCandidate: timeState.lifeSuite.field.placementCandidate,
            now: now
        )
        if action == .placeStep, timeState.lifeSuite.field.canPlaceStep == false {
            throw TimeFieldMutationError.missingEligibleStep
        }
        guard let targetBucket = visibleProjection.targetBucket(for: selectedMark, preferredLayer: action.targetLayer) else {
            throw TimeFieldMutationError.noVisibleMutationTarget
        }

        let command = makeCommand(
            action,
            targetBucket: targetBucket,
            selectedMark: selectedMark,
            placementCandidate: timeState.lifeSuite.field.placementCandidate,
            now: now,
            actor: actor,
            explicitProtectedPlacementApproval: explicitProtectedPlacementApproval
        )
        if let decision = placementEngine.evaluate(
            command: command,
            context: CommandExecutionContext(now: now, actor: actor, sourceSurface: "Time")
        ), decision.requiresReviewBeforeMutation {
            throw TimeFieldMutationError.protectedPlacementRequiresApproval(decision.protectedPlacementDecision)
        }
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
        placementCandidate: TimePlacementCandidate?,
        now: Date,
        actor: AmbitionsCommandActor,
        explicitProtectedPlacementApproval: Bool
    ) -> AmbitionsCommand {
        let timeID = targetBucket.id
        let stepID = action == .placeStep ? placementCandidate?.stepID : nil
        let goalID = action == .placeStep
            ? placementCandidate?.goalID
            : selectedMark?.inputRefs.first { $0.kind == .goal }?.id
        let createdAt = Self.isoString(from: now)
        var metadata = action.commandMetadata
        if let placementCandidate, action == .placeStep {
            metadata["placementCandidateID"] = placementCandidate.id
            metadata["placementCandidateKind"] = placementCandidate.kind.rawValue
            metadata["durationMinutes"] = "\(placementCandidate.durationMinutes)"
            metadata["placementSource"] = placementCandidate.sourceLabel
            metadata["startAt"] = Self.isoString(from: targetBucket.start)
            metadata["endAt"] = Self.isoString(from: targetBucket.end)
            metadata["proposedStartAt"] = Self.isoString(from: targetBucket.start)
            metadata["proposedEndAt"] = Self.isoString(from: targetBucket.end)
            metadata["placementTrigger"] = protectedPlacementTrigger(for: actor).rawValue
            metadata["explicitUserApproval"] = explicitProtectedPlacementApproval ? "true" : "false"
        }
        let command = AmbitionsCommand(
            id: "command.time.\(action.rawValue).\(Self.idComponent(timeID)).\(Self.idComponent(createdAt))",
            kind: action.commandKind,
            source: .time,
            target: AmbitionsCommandTarget(
                goalID: goalID,
                timeID: timeID,
                stepID: stepID
            ),
            payload: AmbitionsCommandPayload(
                title: placementCandidate?.title ?? action.title,
                notes: placementCandidate?.accessibilitySummary ?? selectedMark?.accessibilitySummary ?? targetBucket.accessibilitySummary,
                metadata: metadata
            ),
            createdAt: createdAt,
            actor: actor,
            sourceSurface: "Time"
        )
        return command.validated(as: AmbitionsCommandValidator().validate(command))
    }

    private func protectedPlacementTrigger(for actor: AmbitionsCommandActor) -> ProtectedStepPlacementTrigger {
        switch actor {
        case .system:
            .automatic
        case .externalSurface:
            .externalSurface
        case .user:
            .userInitiated
        }
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
