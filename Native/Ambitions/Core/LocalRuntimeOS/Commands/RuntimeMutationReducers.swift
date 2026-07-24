import Foundation

enum RuntimePreparationFeature: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case capture
    case goalStep = "goal_step"
    case scheduleReminder = "schedule_reminder"
    case profile
    case historyRepair = "history_repair"
    case importDeletion = "import_deletion"
    case externalOperation = "external_operation"
}

struct RuntimeFeatureHandlerAvailability: Sendable, Equatable {
    let features: Set<RuntimePreparationFeature>

    static let all = RuntimeFeatureHandlerAvailability(features: Set(RuntimePreparationFeature.allCases))

    func contains(_ feature: RuntimePreparationFeature) -> Bool { features.contains(feature) }
}

struct RuntimeFeatureReducerInput: Sendable, Equatable {
    let command: AmbitionsCommand
    let commandID: RuntimeCommandID
    let snapshot: RuntimePreparationSnapshot
    let context: RuntimePreparationContext
}

protocol RuntimeFeatureMutationReducing: Sendable {
    func reduce(_ input: RuntimeFeatureReducerInput) -> RuntimeReducerDecision
}

struct CaptureMutationReducer: RuntimeFeatureMutationReducing {
    func reduce(_ input: RuntimeFeatureReducerInput) -> RuntimeReducerDecision {
        RuntimePureMutationDecisionBuilder.reduce(input, feature: .capture)
    }
}

struct GoalStepMutationReducer: RuntimeFeatureMutationReducing {
    func reduce(_ input: RuntimeFeatureReducerInput) -> RuntimeReducerDecision {
        RuntimePureMutationDecisionBuilder.reduce(input, feature: .goalStep)
    }
}

struct ScheduleReminderMutationReducer: RuntimeFeatureMutationReducing {
    func reduce(_ input: RuntimeFeatureReducerInput) -> RuntimeReducerDecision {
        RuntimePureMutationDecisionBuilder.reduce(input, feature: .scheduleReminder)
    }
}

struct ProfileMutationReducer: RuntimeFeatureMutationReducing {
    func reduce(_ input: RuntimeFeatureReducerInput) -> RuntimeReducerDecision {
        RuntimePureMutationDecisionBuilder.reduce(input, feature: .profile)
    }
}

struct HistoryRepairMutationReducer: RuntimeFeatureMutationReducing {
    func reduce(_ input: RuntimeFeatureReducerInput) -> RuntimeReducerDecision {
        RuntimePureMutationDecisionBuilder.reduce(input, feature: .historyRepair)
    }
}

struct ImportDeletionMutationReducer: RuntimeFeatureMutationReducing {
    func reduce(_ input: RuntimeFeatureReducerInput) -> RuntimeReducerDecision {
        RuntimePureMutationDecisionBuilder.reduce(input, feature: .importDeletion)
    }
}

struct ExternalOperationMutationReducer: RuntimeFeatureMutationReducing {
    func reduce(_ input: RuntimeFeatureReducerInput) -> RuntimeReducerDecision {
        RuntimePureMutationDecisionBuilder.reduce(input, feature: .externalOperation)
    }
}

struct RuntimeFeatureMutationRouter: Sendable {
    let availability: RuntimeFeatureHandlerAvailability

    init(availability: RuntimeFeatureHandlerAvailability = .all) {
        self.availability = availability
    }

    func feature(for payload: RuntimeCommandPayload) -> RuntimePreparationFeature {
        switch payload {
        case .capture: .capture
        case .goal, .step: .goalStep
        case .schedule, .reminder: .scheduleReminder
        case .profile: .profile
        case .history, .repair: .historyRepair
        case .importDeletion: .importDeletion
        case .externalOperation: .externalOperation
        }
    }

    func reduce(_ input: RuntimeFeatureReducerInput) -> RuntimeReducerDecision? {
        let feature = feature(for: input.command.typedPayload)
        guard availability.contains(feature) else { return nil }
        switch feature {
        case .capture: return CaptureMutationReducer().reduce(input)
        case .goalStep: return GoalStepMutationReducer().reduce(input)
        case .scheduleReminder: return ScheduleReminderMutationReducer().reduce(input)
        case .profile: return ProfileMutationReducer().reduce(input)
        case .historyRepair: return HistoryRepairMutationReducer().reduce(input)
        case .importDeletion: return ImportDeletionMutationReducer().reduce(input)
        case .externalOperation: return ExternalOperationMutationReducer().reduce(input)
        }
    }
}

private enum RuntimePureMutationDecisionBuilder {
    static func reduce(
        _ input: RuntimeFeatureReducerInput,
        feature: RuntimePreparationFeature
    ) -> RuntimeReducerDecision {
        let command = input.command
        let targetIDs = command.target.runtimePreparationObjectIDs
        let readObjects = targetIDs.map { objectID in
            RuntimeReadDependency(
                objectID: objectID,
                expectedRevision: command.expectedRevision,
                observedRevision: input.snapshot.objectRevisions[objectID] ?? input.snapshot.observedRevision
            )
        }
        let readSet = RuntimeMutationReadSet(
            objects: readObjects,
            cursors: input.snapshot.cursors,
            privacy: input.snapshot.privacy
        )
        let disposition = disposition(for: command)
        let confirmationScope = confirmationScope(for: command)
        let effect = externalEffect(for: command, context: input.context)
        let transitionIDs = transitionObjectIDs(for: command, targetIDs: targetIDs, proposed: input.context.proposedObjectID)
        let transitionKind = transitionKind(for: command)
        let transitions: [RuntimeObjectTransitionIntent] = disposition == .apply
            ? transitionIDs.map {
                RuntimeObjectTransitionIntent(
                    objectID: $0,
                    expectedRevision: command.expectedRevision,
                    transition: transitionKind,
                    family: feature.rawValue
                )
            }
            : []
        let eventKind = semanticEventKind(for: command)
        let events: [RuntimeSemanticEventIntent] = disposition == .apply
            ? [RuntimeSemanticEventIntent(
                id: input.context.eventID,
                kind: eventKind,
                commandID: input.commandID,
                target: command.target,
                occurredAt: DomainTimestamp.string(from: input.context.issuedAt),
                privacy: command.privacy
            )]
            : []
        let reason: RuntimeRecoveryReason? = switch disposition {
        case .apply: nil
        case .unchanged: .noMutation
        case .blocked: .invalidSemanticInput
        case .unsupported: .unsupportedInput
        }
        let recovery: RuntimeRecovery = switch disposition {
        case .apply:
            RuntimeRecovery(
                kind: effect == .none ? .undo : .rollback,
                reason: .preparedMutation,
                target: command.target,
                redactedDetail: nil
            )
        case .unchanged: .none(.noMutation, target: command.target)
        case .blocked: .inspect(.invalidSemanticInput, target: command.target)
        case .unsupported: .inspect(.unsupportedInput, target: command.target)
        }
        let writeSet = RuntimeMutationWriteSet(
            transitions: transitions,
            events: events,
            projectionInvalidations: disposition == .apply ? projectionInvalidations(for: command, feature: feature) : [],
            receiptIntentID: disposition == .apply ? input.context.receiptID : nil,
            rollbackIntentID: disposition == .apply ? input.context.rollbackPlanID : nil,
            externalEffect: disposition == .apply ? effect : .none
        )
        return RuntimeReducerDecision(
            family: feature.rawValue,
            action: command.typedPayload.diagnosticCase,
            disposition: disposition,
            readSet: readSet,
            writeSet: writeSet,
            confirmationScope: confirmationScope,
            reason: reason,
            recovery: recovery
        )
    }

    private static func disposition(for command: AmbitionsCommand) -> RuntimeReducerDisposition {
        switch command.typedPayload {
        case let .history(history):
            switch history.action {
            case .openDestination, .askWhy: return .unchanged
            case .dismissRecommendation, .todayReceipt: return .apply
            }
        case let .repair(repair):
            return repair.action == .openDestination ? .unchanged : .apply
        default:
            return .apply
        }
    }

    private static func confirmationScope(for command: AmbitionsCommand) -> RuntimeConfirmationScope? {
        switch command.typedPayload {
        case let .schedule(schedule):
            switch schedule.action {
            case .protectWindow: return .protectedPlacement
            case let .calendarWrite(intent):
                return intent.operationIdentityProvenance == .currentRequired
                    ? .calendarOutbox
                    : .legacyCalendarCompatibility
            default: return nil
            }
        case .reminder: return .reminderOutbox
        case let .importDeletion(value):
            switch value.action {
            case .prepareExport, .performExport: return .export
            case .deleteObject, .forgetMemory: return .destructiveMutation
            }
        case .externalOperation: return .externalOperation
        default: return nil
        }
    }

    private static func externalEffect(
        for command: AmbitionsCommand,
        context: RuntimePreparationContext
    ) -> RuntimeExternalEffectIntent {
        switch command.typedPayload {
        case let .schedule(schedule):
            guard case let .calendarWrite(intent) = schedule.action,
                  intent.operationIdentityProvenance == .currentRequired,
                  let operationID = intent.operationID else { return .none }
            return .outbox(operationID: operationID, kind: .calendarEvent)
        case .reminder:
            return .outbox(operationID: context.externalOperationID, kind: .reminder)
        case let .externalOperation(operation):
            return .outbox(operationID: operation.operationID, kind: operation.kind)
        default:
            return .none
        }
    }

    private static func transitionObjectIDs(
        for command: AmbitionsCommand,
        targetIDs: [RuntimeDomainObjectID],
        proposed: RuntimeDomainObjectID?
    ) -> [RuntimeDomainObjectID] {
        var values = targetIDs
        if isCreate(command), let proposed { values.append(proposed) }
        var seen = Set<RuntimeDomainObjectID>()
        return values.filter { seen.insert($0).inserted }.sorted()
    }

    private static func isCreate(_ command: AmbitionsCommand) -> Bool {
        switch command.typedPayload {
        case let .capture(capture):
            if case .quickCapture = capture.action { return true }
            return false
        case let .goal(goal): return goal.action == .create
        case let .schedule(schedule):
            if case .createItem = schedule.action { return true }
            return false
        case let .reminder(reminder): return reminder.action == .create
        default: return false
        }
    }

    private static func transitionKind(for command: AmbitionsCommand) -> RuntimeObjectTransitionKind {
        switch command.typedPayload {
        case let .capture(capture):
            switch capture.action {
            case .quickCapture: return .create
            case .attachToGoal: return .attach
            case .archive: return .tombstone
            case .routeCommitment, .markWaiting: return .update
            }
        case let .goal(goal): return goal.action == .create ? .create : .update
        case let .schedule(schedule):
            if case .createItem = schedule.action { return .create }
            return .update
        case let .reminder(reminder): return reminder.action == .delete ? .tombstone : (reminder.action == .create ? .create : .update)
        case let .importDeletion(value):
            switch value.action {
            case .deleteObject, .forgetMemory: return .tombstone
            case .prepareExport, .performExport: return .update
            }
        default: return .update
        }
    }

    private static func semanticEventKind(for command: AmbitionsCommand) -> RuntimeSemanticEventIntentKind {
        switch command.typedPayload {
        case .capture: .captureChanged
        case .goal: .goalChanged
        case .step: .stepChanged
        case .schedule: .scheduleChanged
        case .reminder: .reminderChanged
        case .profile: .preferencesChanged
        case .history: .historyChanged
        case .repair: .repairRequested
        case .importDeletion: .importDeletionRequested
        case .externalOperation: .externalOperationProposed
        }
    }

    private static func projectionInvalidations(
        for command: AmbitionsCommand,
        feature: RuntimePreparationFeature
    ) -> [String] {
        var values = ["projection.receipt", "projection.privacy", "projection.search"]
        values.append("projection.\(feature.rawValue)")
        if let destination = command.target.destination { values.append("projection.\(destination.rawValue)") }
        return values
    }
}

extension AmbitionsCommandTarget {
    var runtimePreparationObjectIDs: [RuntimeDomainObjectID] {
        let raw = [
            goalID, captureID, timeID, reviewID, stepID, deliverableID, scopeItemID,
            recommendationID, explanationID,
        ].compactMap { $0 }
        var seen = Set<RuntimeDomainObjectID>()
        return raw.compactMap(RuntimeDomainObjectID.init(rawValue:))
            .filter { seen.insert($0).inserted }
            .sorted()
    }
}
