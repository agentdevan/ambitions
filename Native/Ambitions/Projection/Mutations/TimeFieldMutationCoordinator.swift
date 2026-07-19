import Foundation

enum TimeFieldMutationError: Error, Equatable {
    case noVisibleMutationTarget
    case missingEligibleStep
    case runtimeRejected(String)
    case protectedPlacementRequiresApproval(ProtectedStepPlacementDecision)
}

struct TimeFieldMutationCoordinator: Sendable {
    static func prepareCommand(
        _ action: TimeFieldMutationAction,
        in timeState: TimeSurfaceState,
        selectedMark: LifeShapeSemanticMark?,
        now: Date,
        actor: AmbitionsCommandActor = .user,
        explicitProtectedPlacementApproval: Bool = true
    ) throws -> AmbitionsCommand {
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
        guard let targetBucket = visibleProjection.targetBucket(
            for: selectedMark,
            preferredLayer: action.targetLayer
        ) else {
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
        if let decision = PlacementEngine().evaluate(
            command: command,
            context: CommandExecutionContext(now: now, actor: actor, sourceSurface: "Time")
        ), decision.requiresReviewBeforeMutation {
            throw TimeFieldMutationError.protectedPlacementRequiresApproval(decision.protectedPlacementDecision)
        }
        return command
    }

    private static func makeCommand(
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
        metadata["startAt"] = Self.isoString(from: targetBucket.start)
        metadata["endAt"] = Self.isoString(from: targetBucket.end)
        if let placementCandidate, action == .placeStep {
            metadata["placementCandidateID"] = placementCandidate.id
            metadata["placementCandidateKind"] = placementCandidate.kind.rawValue
            metadata["durationMinutes"] = "\(placementCandidate.durationMinutes)"
            metadata["placementSource"] = placementCandidate.sourceLabel
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

    private static func protectedPlacementTrigger(for actor: AmbitionsCommandActor) -> ProtectedStepPlacementTrigger {
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
