import Foundation

enum RuntimePreparationFeature: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case capture
    case goalStep = "goal_step"
    case scheduleReminder = "schedule_reminder"
    case profile
    case historyRepair = "history_repair"
    case importDeletion = "import_deletion"
    case externalOperation = "external_operation"
    case attachment
    case compensation
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

struct AttachmentMutationReducer: RuntimeFeatureMutationReducing {
    func reduce(_ input: RuntimeFeatureReducerInput) -> RuntimeReducerDecision {
        guard case let .attachment(command) = input.command.typedPayload,
              input.command.localOnly,
              command.content == RuntimeCommandContent(),
              command.intent.privacy == input.command.privacy,
              (try? RuntimeAttachmentCodec.validate(command.intent)) != nil else {
            return RuntimePureMutationDecisionBuilder.unsupported(input, feature: .attachment)
        }
        if command.intent.action != .linkStaged,
           case .absent = input.command.expectedRevision {
            return RuntimePureMutationDecisionBuilder.unsupported(input, feature: .attachment)
        }
        return RuntimePureMutationDecisionBuilder.reduce(input, feature: .attachment)
    }
}

struct CompensationMutationReducer: RuntimeFeatureMutationReducing {
    func reduce(_ input: RuntimeFeatureReducerInput) -> RuntimeReducerDecision {
        guard case let .compensation(command) = input.command.typedPayload else {
            return RuntimePureMutationDecisionBuilder.unsupported(input, feature: .compensation)
        }
        guard Task.isCancelled == false else {
            return blocked(input, command: command, reason: .cancelled)
        }
        guard command.targets.isEmpty == false,
              command.targets.count <= RuntimeCompensationLimits.maximumTargets,
              command.targets == command.targets.sorted(),
              Set(command.targets.map {
                  "\($0.aggregate.kind.rawValue)\u{0}\($0.aggregate.id.rawValue)"
              }).count == command.targets.count else {
            return RuntimePureMutationDecisionBuilder.unsupported(input, feature: .compensation)
        }
        var readObjects: [RuntimeReadDependency] = []
        readObjects.reserveCapacity(command.targets.count)
        for target in command.targets {
            guard Task.isCancelled == false else {
                return blocked(input, command: command, reason: .cancelled)
            }
            guard let objectID = RuntimeDomainObjectID(rawValue: target.aggregate.id.rawValue) else {
                return RuntimePureMutationDecisionBuilder.unsupported(input, feature: .compensation)
            }
            let reference = RuntimePreparationAggregateReference(
                family: target.aggregate.kind,
                objectID: objectID
            )
            guard let observed = input.snapshot.aggregateRevisions[reference] else { continue }
            readObjects.append(RuntimeReadDependency(
                aggregate: reference,
                expectedRevision: .exact(target.requiredCurrentRevision),
                observedRevision: observed
            ))
        }
        readObjects.sort { $0.aggregate < $1.aggregate }
        let complete = readObjects.count == command.targets.count && zip(readObjects, command.targets).allSatisfy {
            $0.aggregate.family == $1.aggregate.kind &&
                $0.aggregate.objectID.rawValue == $1.aggregate.id.rawValue &&
                $0.observedRevision == .exact($1.requiredCurrentRevision)
        }
        let readSet = RuntimeMutationReadSet(
            objects: readObjects, cursors: input.snapshot.cursors, privacy: input.snapshot.privacy
        )
        guard complete else {
            return RuntimeReducerDecision(
                family: RuntimePreparationFeature.compensation.rawValue,
                action: input.command.typedPayload.diagnosticCase,
                disposition: .blocked, readSet: readSet,
                writeSet: RuntimeMutationWriteSet(
                    transitions: [], events: [], projectionInvalidations: [],
                    receiptIntentID: nil, compensation: nil, externalEffect: .none
                ),
                confirmationScope: nil, reason: .revisionMismatch,
                recovery: .inspect(.revisionMismatch, target: command.target)
            )
        }
        var transitions: [RuntimeObjectTransitionIntent] = []
        transitions.reserveCapacity(command.targets.count)
        for target in command.targets {
            guard Task.isCancelled == false else {
                return blocked(input, command: command, reason: .cancelled)
            }
            guard let objectID = RuntimeDomainObjectID(rawValue: target.aggregate.id.rawValue) else {
                return RuntimePureMutationDecisionBuilder.unsupported(input, feature: .compensation)
            }
            transitions.append(RuntimeObjectTransitionIntent(
                aggregate: RuntimePreparationAggregateReference(
                    family: target.aggregate.kind,
                    objectID: objectID
                ),
                expectedRevision: .exact(target.requiredCurrentRevision),
                transition: target.inverseTransition
            ))
        }
        guard transitions.count == command.targets.count,
              command.targets.allSatisfy({ $0.inverseTransition == command.action.transition }) else {
            return RuntimePureMutationDecisionBuilder.unsupported(input, feature: .compensation)
        }
        let event = RuntimeSemanticEventIntent(
            id: input.context.eventID, kind: .compensationApplied,
            commandID: input.commandID, target: command.target,
            occurredAt: DomainTimestamp.string(from: input.context.issuedAt),
            privacy: input.command.privacy
        )
        let typeID = RuntimeSemanticEventClassifier.classify(input.command.typedPayload)
        let invalidations: [RuntimeCanonicalProjectionID]
        if case let .mutating(id) = typeID {
            invalidations = RuntimeCanonicalProjectionRegistry.projectionIDs(for: id)
        } else {
            invalidations = []
        }
        let evidence = RuntimeIrreversibilityEvidence(
            version: 1, permanence: .semantic, reason: .compensationOfCompensation,
            commandFamily: "compensation", commandAction: input.command.typedPayload.diagnosticCase
        )
        return RuntimeReducerDecision(
            family: RuntimePreparationFeature.compensation.rawValue,
            action: input.command.typedPayload.diagnosticCase,
            disposition: .apply, readSet: readSet,
            writeSet: RuntimeMutationWriteSet(
                transitions: transitions, events: [event], projectionInvalidations: invalidations,
                receiptIntentID: input.context.receiptID,
                compensation: .noncompensable(evidence), externalEffect: .none
            ),
            confirmationScope: command.requiresConfirmation ? .semanticCompensation : nil, reason: nil,
            recovery: RuntimeRecovery(kind: .none, reason: .preparedMutation, target: command.target, redactedDetail: nil)
        )
    }

    private func blocked(
        _ input: RuntimeFeatureReducerInput,
        command: RuntimeCompensationCommand,
        reason: RuntimeRecoveryReason
    ) -> RuntimeReducerDecision {
        RuntimeReducerDecision(
            family: RuntimePreparationFeature.compensation.rawValue,
            action: input.command.typedPayload.diagnosticCase,
            disposition: .blocked,
            readSet: RuntimeMutationReadSet(
                objects: [], cursors: input.snapshot.cursors, privacy: input.snapshot.privacy
            ),
            writeSet: RuntimeMutationWriteSet(
                transitions: [], events: [], projectionInvalidations: [],
                receiptIntentID: nil, compensation: nil, externalEffect: .none
            ),
            confirmationScope: nil,
            reason: reason,
            recovery: .inspect(reason, target: command.target)
        )
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
        case .attachment: .attachment
        case .compensation: .compensation
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
        case .attachment: return AttachmentMutationReducer().reduce(input)
        case .compensation: return CompensationMutationReducer().reduce(input)
        }
    }
}

private enum RuntimePureMutationDecisionBuilder {
    static func unsupported(
        _ input: RuntimeFeatureReducerInput,
        feature: RuntimePreparationFeature
    ) -> RuntimeReducerDecision {
        RuntimeReducerDecision(
            family: feature.rawValue, action: input.command.typedPayload.diagnosticCase,
            disposition: .unsupported,
            readSet: RuntimeMutationReadSet(objects: [], cursors: [], privacy: input.command.privacy),
            writeSet: RuntimeMutationWriteSet(
                transitions: [], events: [], projectionInvalidations: [],
                receiptIntentID: nil, compensation: nil, externalEffect: .none
            ),
            confirmationScope: nil, reason: .unsupportedInput,
            recovery: .inspect(.unsupportedInput, target: input.command.target)
        )
    }

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
        let compensation = disposition == .apply
            ? RuntimeCompensationIntentFactory.disposition(for: command, context: input.context)
            : nil
        let recovery: RuntimeRecovery = switch disposition {
        case .apply:
            switch compensation {
            case .typedPlan?:
                RuntimeRecovery(
                    kind: effect == .none ? .undo : .rollback,
                    reason: .preparedMutation,
                    target: command.target,
                    redactedDetail: nil
                )
            case .noncompensable?, nil:
                RuntimeRecovery(
                    kind: .none,
                    reason: .preparedMutation,
                    target: command.target,
                    redactedDetail: nil
                )
            }
        case .unchanged: .none(.noMutation, target: command.target)
        case .blocked: .inspect(.invalidSemanticInput, target: command.target)
        case .unsupported: .inspect(.unsupportedInput, target: command.target)
        }
        let writeSet = RuntimeMutationWriteSet(
            transitions: transitions,
            events: events,
            projectionInvalidations: disposition == .apply ? projectionInvalidations(for: command) : [],
            receiptIntentID: disposition == .apply ? input.context.receiptID : nil,
            compensation: compensation,
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
        case let .schedule(schedule) where schedule.action == .undo:
            return .unsupported
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
        case .compensation: return .semanticCompensation
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
        case let .attachment(value):
            if value.intent.action == .linkStaged,
               case .absent = command.expectedRevision { return .create }
            return .update
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
        case .attachment: .attachmentChanged
        case .compensation: .compensationApplied
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
        case let .attachment(value): value.target
        case let .compensation(value): value.target
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
        case let .attachment(value): value.intent.attachmentID.rawValue
        case let .compensation(value): value.action.primaryObjectID.rawValue
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
        if case let .compensation(value) = self {
            guard Task.isCancelled == false,
                  value.targets.isEmpty == false,
                  value.targets.count <= RuntimeCompensationLimits.maximumTargets else {
                return []
            }
            return value.targets.compactMap { target in
                guard let objectID = RuntimeDomainObjectID(rawValue: target.aggregate.id.rawValue) else { return nil }
                return RuntimePreparationAggregateReference(family: target.aggregate.kind, objectID: objectID)
            }.sorted()
        }
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
        case let .attachment(value): value.target
        case let .compensation(value): value.target
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
        if case let .attachment(value) = self {
            add(value.intent.attachmentID.rawValue, .attachment)
            if let related = value.intent.target {
                add(related.id.rawValue, related.kind)
            }
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
        case let .attachment(value): value.intent.attachmentID.rawValue
        case let .compensation(value): value.action.primaryObjectID.rawValue
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
        case .attachment: .attachment
        case let .compensation(value): value.action.aggregateKind
        }
    }
}

private enum RuntimeCompensationIntentFactory {
    static func disposition(
        for command: AmbitionsCommand,
        context: RuntimePreparationContext
    ) -> RuntimeCompensationDispositionIntent {
        guard command.localOnly else {
            return .noncompensable(RuntimeIrreversibilityEvidence(
                version: 1,
                permanence: .currentRuntimeUnsupported,
                reason: .externalEffectConstraint,
                commandFamily: command.typedPayload.diagnosticFamily,
                commandAction: command.typedPayload.diagnosticCase
            ))
        }
        let expiry = context.issuedAt.addingTimeInterval(30 * 24 * 60 * 60)
        func plan(_ action: RuntimeSemanticCompensationAction, confirmation: Bool) -> RuntimeCompensationDispositionIntent {
            .typedPlan(RuntimeCompensationPlanIntent(
                planID: context.rollbackPlanID, action: action,
                policyVersion: runtimeCompensationPolicyVersion,
                expiresAt: expiry, requiresConfirmation: confirmation
            ))
        }
        switch command.typedPayload {
        case let .capture(value):
            switch value.action {
            case .quickCapture:
                if let id = context.proposedObjectID { return plan(.discardCreatedCapture(id), confirmation: true) }
            case .attachToGoal:
                return unsupported(command, reason: .unsupportedSemanticInverse)
            case .archive:
                return unsupported(command, reason: .unsupportedSemanticInverse)
            case .routeCommitment, .markWaiting: break
            }
        case let .goal(value):
            if value.action == .create, let id = context.proposedObjectID {
                return plan(.discardCreatedGoal(id), confirmation: true)
            }
        case let .step(value):
            if case .complete = value.action {
                return unsupported(command, reason: .unsupportedSemanticInverse)
            }
        case let .schedule(value):
            switch value.action {
            case .createItem:
                if let id = context.proposedObjectID { return plan(.discardCreatedSchedule(id), confirmation: true) }
            case .undo:
                return unsupported(command, reason: .legacyProjectionAuthority)
            default: break
            }
        case let .reminder(value):
            switch value.action {
            case .create:
                if let id = context.proposedObjectID { return plan(.discardCreatedReminder(id), confirmation: true) }
            case .delete:
                return unsupported(command, reason: .unsupportedSemanticInverse)
            case .update: break
            }
        case let .importDeletion(value):
            if value.action == .forgetMemory {
                return .noncompensable(RuntimeIrreversibilityEvidence(
                    version: 1, permanence: .semantic, reason: .destructiveErasure,
                    commandFamily: command.typedPayload.diagnosticFamily,
                    commandAction: command.typedPayload.diagnosticCase
                ))
            }
        case .compensation:
            return .noncompensable(RuntimeIrreversibilityEvidence(
                version: 1, permanence: .semantic, reason: .compensationOfCompensation,
                commandFamily: "compensation", commandAction: command.typedPayload.diagnosticCase
            ))
        case .profile, .history, .repair, .externalOperation, .attachment:
            break
        }
        return unsupported(command, reason: .missingPriorSemanticValue)
    }

    private static func unsupported(
        _ command: AmbitionsCommand,
        reason: RuntimeIrreversibilityReason
    ) -> RuntimeCompensationDispositionIntent {
        .noncompensable(RuntimeIrreversibilityEvidence(
            version: 1, permanence: .currentRuntimeUnsupported, reason: reason,
            commandFamily: command.typedPayload.diagnosticFamily,
            commandAction: command.typedPayload.diagnosticCase
        ))
    }
}
