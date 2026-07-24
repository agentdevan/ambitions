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
        let targetReferences = command.runtimePreparationAggregateReferences
        let hasCompleteSnapshot = targetReferences.allSatisfy {
            input.snapshot.aggregateRevisions[$0] != nil
        }
        let readObjects = targetReferences.compactMap { reference -> RuntimeReadDependency? in
            guard let observed = input.snapshot.aggregateRevisions[reference] else { return nil }
            let expected = reference == command.runtimePrimaryPreparationReference
                ? command.expectedRevision
                : observed
            return RuntimeReadDependency(
                aggregate: reference,
                expectedRevision: expected,
                observedRevision: observed
            )
        }
        let readSet = RuntimeMutationReadSet(
            objects: readObjects,
            cursors: input.snapshot.cursors,
            privacy: input.snapshot.privacy
        )
        let disposition = hasCompleteSnapshot ? disposition(for: command) : .blocked
        let confirmationScope = confirmationScope(for: command)
        let effect = externalEffect(for: command, context: input.context)
        // Target references are read dependencies. A command writes only its
        // semantic primary aggregate until a feature reducer explicitly owns
        // an additional aggregate transition.
        var transitionReferences = explicitWriteReferences(for: command)
        if isCreate(command), let proposed = input.context.proposedObjectID {
            let proposedReference = RuntimePreparationAggregateReference(
                family: command.typedPayload.semanticAggregateKind,
                objectID: proposed
            )
            if transitionReferences.contains(proposedReference) == false {
                transitionReferences.append(proposedReference)
            }
        }
        let transitionKind = transitionKind(for: command)
        let transitions: [RuntimeObjectTransitionIntent] = disposition == .apply
            ? transitionReferences.compactMap { reference in
                let expected: RuntimeExpectedRevision
                if let dependency = readObjects.first(where: { $0.aggregate == reference }) {
                    expected = dependency.expectedRevision
                } else if isCreate(command), reference.family == command.typedPayload.semanticAggregateKind,
                          reference.objectID == input.context.proposedObjectID {
                    expected = .absent
                } else {
                    return nil
                }
                return RuntimeObjectTransitionIntent(
                    aggregate: reference,
                    expectedRevision: expected,
                    transition: transitionKind
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
            projectionInvalidations: disposition == .apply ? projectionInvalidations(for: command) : [],
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

    private static func explicitWriteReferences(
        for command: AmbitionsCommand
    ) -> [RuntimePreparationAggregateReference] {
        guard let primary = command.runtimePrimaryPreparationReference else { return [] }
        // Every currently typed action mutates exactly its semantic owner.
        // Related IDs in AmbitionsCommandTarget remain optimistic read
        // dependencies; T17/T20 feature reducers must add explicit secondary
        // writes when their domain contracts require them.
        return [primary]
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

    private static func projectionInvalidations(for command: AmbitionsCommand) -> [RuntimeCanonicalProjectionID] {
        switch RuntimeSemanticEventClassifier.classify(command.typedPayload) {
        case let .mutating(typeID):
            RuntimeCanonicalProjectionRegistry.projectionIDs(for: typeID)
        case .nonMutating:
            []
        }
    }
}

extension AmbitionsCommand {
    var runtimePrimaryPreparationReference: RuntimePreparationAggregateReference? {
        typedPayload.runtimePrimaryPreparationReference
    }

    var runtimePreparationAggregateReferences: [RuntimePreparationAggregateReference] {
        typedPayload.runtimePreparationAggregateReferences
    }
}

extension RuntimeCommandPayload {
    var runtimePrimaryPreparationReference: RuntimePreparationAggregateReference? {
        let references = runtimePreparationAggregateReferences
        let target: AmbitionsCommandTarget = switch self {
        case let .capture(value): value.target
        case let .goal(value): value.target
        case let .step(value): value.target
        case let .schedule(value): value.target
        case let .reminder(value): value.target
        case let .profile(value): value.target
        case let .history(value): value.target
        case let .repair(value): value.target
        case let .importDeletion(value): value.target
        case let .externalOperation(value): value.target
        }
        let raw: String? = switch self {
        case .capture: target.captureID
        case .goal: target.goalID
        case .step: target.stepID
        case .schedule: target.timeID
        case .reminder: target.timeID ?? target.goalID
        case .profile: "profile.local"
        case .history: target.reviewID ?? target.recommendationID
        case .repair: target.recommendationID ?? target.goalID
        case .importDeletion:
            references.first?.objectID.rawValue
        case let .externalOperation(value): value.operationID.rawValue
        }
        guard let raw, let objectID = RuntimeDomainObjectID(rawValue: raw) else { return nil }
        let semantic = RuntimePreparationAggregateReference(
            family: semanticAggregateKind,
            objectID: objectID
        )
        if references.contains(semantic) { return semantic }
        return semantic
    }

    var runtimePreparationAggregateReferences: [RuntimePreparationAggregateReference] {
        let target: AmbitionsCommandTarget = switch self {
        case let .capture(value): value.target
        case let .goal(value): value.target
        case let .step(value): value.target
        case let .schedule(value): value.target
        case let .reminder(value): value.target
        case let .profile(value): value.target
        case let .history(value): value.target
        case let .repair(value): value.target
        case let .importDeletion(value): value.target
        case let .externalOperation(value): value.target
        }
        var values: [RuntimePreparationAggregateReference] = []
        func add(_ raw: String?, _ family: RuntimeSemanticAggregateKind) {
            guard let raw, let objectID = RuntimeDomainObjectID(rawValue: raw) else { return }
            values.append(RuntimePreparationAggregateReference(family: family, objectID: objectID))
        }
        add(target.captureID, .capture)
        add(target.goalID, .goal)
        add(target.stepID, .step)
        add(target.deliverableID, .goal)
        add(target.scopeItemID, .goal)
        add(target.reviewID, .history)
        add(target.recommendationID, semanticAggregateKind)
        add(target.explanationID, .history)
        switch self {
        case .reminder: add(target.timeID, .reminder)
        default: add(target.timeID, .schedule)
        }
        let semanticRaw: String? = switch self {
        case .capture: target.captureID
        case .goal: target.goalID
        case .step: target.stepID
        case .schedule: target.timeID
        case .reminder: target.timeID ?? target.goalID
        case .profile: "profile.local"
        case .history: target.reviewID ?? target.recommendationID
        case .repair: target.recommendationID ?? target.goalID
        case .importDeletion: values.first?.objectID.rawValue
        case let .externalOperation(value): value.operationID.rawValue
        }
        add(semanticRaw, semanticAggregateKind)
        return Array(Set(values)).sorted()
    }
}

private extension RuntimeCommandPayload {
    var semanticAggregateKind: RuntimeSemanticAggregateKind {
        switch self {
        case .capture: .capture
        case .goal: .goal
        case .step: .step
        case .schedule: .schedule
        case .reminder: .reminder
        case .profile: .profile
        case .history: .history
        case .repair: .repair
        case .importDeletion: .importDeletion
        case .externalOperation: .externalOperation
        }
    }
}
