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
        let target = AmbitionsCommandTarget(goalID: goalID, timeID: timeID, stepID: stepID)
        let content = AmbitionsCommandPayload(
            title: placementCandidate?.title ?? action.title,
            notes: placementCandidate?.accessibilitySummary ?? selectedMark?.accessibilitySummary ?? targetBucket.accessibilitySummary
        )
        let placement = TimePlacementCommandIntent(
            start: Self.isoString(from: targetBucket.start),
            end: Self.isoString(from: targetBucket.end),
            approvedDurationMinutes: action == .placeStep ? placementCandidate?.durationMinutes ?? 15 : nil,
            contextLens: nil,
            relatedGoalID: goalID.flatMap(RuntimeCommandObjectID.init(rawValue:)),
            relatedCaptureID: nil,
            candidateID: placementCandidate?.id.flatMap(RuntimeCommandObjectID.init(rawValue:)),
            candidateKind: placementCandidate?.kind,
            sourceLabel: placementCandidate?.sourceLabel,
            trigger: protectedPlacementTrigger(for: actor),
            explicitUserApproval: explicitProtectedPlacementApproval
        )
        let typedAction: ScheduleCommand.Action = switch action {
        case .placeStep: .placeStep(placement)
        case .protectWindow: .protectWindow(placement)
        case .notUsable, .needsMoreTime, .keepClear, .makeTodayLighter, .addBuffer:
            .correctWindow(TimeCorrectionCommandIntent(
                action: action.timeMutationKind,
                start: placement.start,
                end: placement.end
            ))
        }
        let command = AmbitionsCommand(
            id: "command.time.\(action.rawValue).\(Self.idComponent(timeID)).\(Self.idComponent(createdAt))",
            source: .time,
            typedPayload: .schedule(ScheduleCommand(
                action: typedAction,
                target: target,
                content: RuntimeCommandContent(content)
            )),
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
