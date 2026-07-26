import AmbitionsRuntimeCore
import Foundation

enum RuntimeSemanticAggregateKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case capture
    case goal
    case step
    case schedule
    case reminder
    case profile
    case history
    case repair
    case importDeletion = "import_deletion"
    case externalOperation = "external_operation"
}

struct RuntimeSemanticAggregate: Codable, Sendable, Equatable, Hashable {
    let kind: RuntimeSemanticAggregateKind
    let id: RuntimeAggregateID
}

enum RuntimeAggregateLifecycle: String, Codable, Sendable, Equatable, Hashable {
    case active
    case tombstoned
}

enum RuntimeCanonicalTombstoneReason: String, Codable, Sendable, Equatable, Hashable {
    case archived
    case reminderDeleted = "reminder_deleted"
    case objectDeleted = "object_deleted"
    case memoryForgotten = "memory_forgotten"
    case compensatedCreation = "compensated_creation"
}

enum RuntimeCanonicalTombstoneRetentionDisposition: String, Codable, Sendable, Equatable, Hashable {
    case retainedUntilDownstreamPolicy = "retained_until_downstream_policy"
}

enum RuntimeCanonicalTombstoneRecoveryDisposition: String, Codable, Sendable, Equatable, Hashable {
    case explicitTypedRestorationRequired = "explicit_typed_restoration_required"
}

struct RuntimeCanonicalTombstoneAuthority: Codable, Sendable, Equatable, Hashable {
    let reason: RuntimeCanonicalTombstoneReason
    let predecessorDigest: String
    let retentionDisposition: RuntimeCanonicalTombstoneRetentionDisposition
    let recoveryDisposition: RuntimeCanonicalTombstoneRecoveryDisposition
}

struct RuntimeSemanticAggregateTransition: Codable, Sendable, Equatable, Hashable {
    let aggregate: RuntimeSemanticAggregate
    let priorRevision: UInt64?
    let resultingRevision: UInt64
    let lifecycle: RuntimeAggregateLifecycle
    let transition: RuntimeObjectTransitionKind
    let canonicalStateBytes: Data
    let canonicalStateDigest: String
    let privacy: EventLedgerPrivacyClassification?
    let localOnly: Bool?
    let tombstone: RuntimeCanonicalTombstoneAuthority?

    init(
        aggregate: RuntimeSemanticAggregate,
        priorRevision: UInt64?,
        resultingRevision: UInt64,
        lifecycle: RuntimeAggregateLifecycle,
        transition: RuntimeObjectTransitionKind,
        canonicalStateBytes: Data,
        canonicalStateDigest: String,
        privacy: EventLedgerPrivacyClassification = .standard,
        localOnly: Bool = true,
        tombstone: RuntimeCanonicalTombstoneAuthority?
    ) {
        self.aggregate = aggregate
        self.priorRevision = priorRevision
        self.resultingRevision = resultingRevision
        self.lifecycle = lifecycle
        self.transition = transition
        self.canonicalStateBytes = canonicalStateBytes
        self.canonicalStateDigest = canonicalStateDigest
        self.privacy = privacy
        self.localOnly = localOnly
        self.tombstone = tombstone
    }
}

struct RuntimeCorrelationID: RuntimeIdentityValue {
    static let identityKind = RuntimeIdentityKind.domainObject
    let rawValue: String

    init?(rawValue: String) {
        guard let normalized = RuntimeDomainObjectID(rawValue: rawValue) else { return nil }
        self.rawValue = normalized.rawValue
    }
}

enum RuntimeSemanticEventTypeID: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case captureCreated = "ambitions.capture.created"
    case captureCommitmentRouted = "ambitions.capture.commitment_routed"
    case captureAttachedToGoal = "ambitions.capture.attached_to_goal"
    case captureMarkedWaiting = "ambitions.capture.marked_waiting"
    case captureArchived = "ambitions.capture.archived"
    case goalCreated = "ambitions.goal.created"
    case goalUpdated = "ambitions.goal.updated"
    case goalPrioritySet = "ambitions.goal.priority_set"
    case goalUrgencySet = "ambitions.goal.urgency_set"
    case goalDeadlineSet = "ambitions.goal.deadline_set"
    case goalContextLensSet = "ambitions.goal.context_lens_set"
    case goalContextLensCleared = "ambitions.goal.context_lens_cleared"
    case goalDeliverableAdded = "ambitions.goal.deliverable_added"
    case goalDeliverableRemoved = "ambitions.goal.deliverable_removed"
    case goalScopeItemAdded = "ambitions.goal.scope_item_added"
    case goalScopeItemRemoved = "ambitions.goal.scope_item_removed"
    case stepSessionStarted = "ambitions.step.session_started"
    case stepCompleted = "ambitions.step.completed"
    case stepDelayed = "ambitions.step.delayed"
    case stepSplit = "ambitions.step.split"
    case stepRecovered = "ambitions.step.recovered"
    case stepTodayActionApplied = "ambitions.step.today_action_applied"
    case scheduleItemCreated = "ambitions.schedule.item_created"
    case scheduleItemScheduled = "ambitions.schedule.item_scheduled"
    case scheduleStepPlaced = "ambitions.schedule.step_placed"
    case scheduleWindowProtected = "ambitions.schedule.window_protected"
    case scheduleWindowCorrected = "ambitions.schedule.window_corrected"
    case scheduleMutationUndone = "ambitions.schedule.mutation_undone"
    case scheduleRitualApplied = "ambitions.schedule.ritual_applied"
    case scheduleCalendarWriteCommitted = "ambitions.schedule.calendar_write_committed"
    case reminderCreated = "ambitions.reminder.created"
    case reminderUpdated = "ambitions.reminder.updated"
    case reminderDeleted = "ambitions.reminder.deleted"
    case profilePreferencesUpdated = "ambitions.profile.preferences_updated"
    case historyRecommendationDismissed = "ambitions.history.recommendation_dismissed"
    case historyTodayReceiptRecorded = "ambitions.history.today_receipt_recorded"
    case repairRecovered = "ambitions.repair.recovered"
    case objectDeleted = "ambitions.object.deleted"
    case memoryForgotten = "ambitions.memory.forgotten"
    case externalReminderRequested = "ambitions.external.reminder_requested"
    case externalCalendarEventRequested = "ambitions.external.calendar_event_requested"
    case captureCreatedCompensated = "ambitions.compensation.capture_created"
    case goalCreatedCompensated = "ambitions.compensation.goal_created"
    case scheduleCreatedCompensated = "ambitions.compensation.schedule_created"
    case reminderCreatedCompensated = "ambitions.compensation.reminder_created"

    var latestPayloadVersion: Int { 3 }
    var supportedPayloadVersions: Set<Int> {
        if Self.compensationTypeIDs.contains(self) { return [3] }
        return self == .captureCreated ? [0, 1, 2, 3] : [1, 2, 3]
    }

    private static let compensationTypeIDs: Set<Self> = [
        .captureCreatedCompensated, .goalCreatedCompensated,
        .scheduleCreatedCompensated, .reminderCreatedCompensated,
    ]

    var isCreation: Bool {
        switch self {
        case .captureCreated, .goalCreated, .scheduleItemCreated, .reminderCreated: true
        default: false
        }
    }

    var aggregateKind: RuntimeSemanticAggregateKind {
        switch self {
        case .captureCreated, .captureCommitmentRouted, .captureAttachedToGoal,
             .captureMarkedWaiting, .captureArchived, .captureCreatedCompensated: .capture
        case .goalCreated, .goalUpdated, .goalPrioritySet, .goalUrgencySet,
             .goalDeadlineSet, .goalContextLensSet, .goalContextLensCleared,
             .goalDeliverableAdded, .goalDeliverableRemoved, .goalScopeItemAdded,
             .goalScopeItemRemoved, .goalCreatedCompensated: .goal
        case .stepSessionStarted, .stepCompleted, .stepDelayed, .stepSplit,
             .stepRecovered, .stepTodayActionApplied: .step
        case .scheduleItemCreated, .scheduleItemScheduled, .scheduleStepPlaced,
             .scheduleWindowProtected, .scheduleWindowCorrected,
             .scheduleMutationUndone, .scheduleRitualApplied,
             .scheduleCalendarWriteCommitted, .scheduleCreatedCompensated: .schedule
        case .reminderCreated, .reminderUpdated, .reminderDeleted,
             .reminderCreatedCompensated: .reminder
        case .profilePreferencesUpdated: .profile
        case .historyRecommendationDismissed, .historyTodayReceiptRecorded: .history
        case .repairRecovered: .repair
        case .objectDeleted, .memoryForgotten: .importDeletion
        case .externalReminderRequested, .externalCalendarEventRequested: .externalOperation
        }
    }

    var legalAggregateTransition: RuntimeObjectTransitionKind {
        switch self {
        case .captureCreated, .goalCreated, .scheduleItemCreated, .reminderCreated:
            .create
        case .captureAttachedToGoal:
            .attach
        case .captureArchived, .reminderDeleted, .objectDeleted, .memoryForgotten,
             .captureCreatedCompensated, .goalCreatedCompensated,
             .scheduleCreatedCompensated, .reminderCreatedCompensated:
            .tombstone
        case .captureCommitmentRouted, .captureMarkedWaiting,
             .goalUpdated, .goalPrioritySet, .goalUrgencySet, .goalDeadlineSet,
             .goalContextLensSet, .goalContextLensCleared, .goalDeliverableAdded,
             .goalDeliverableRemoved, .goalScopeItemAdded, .goalScopeItemRemoved,
             .stepSessionStarted, .stepCompleted, .stepDelayed, .stepSplit,
             .stepRecovered, .stepTodayActionApplied, .scheduleItemScheduled,
             .scheduleStepPlaced, .scheduleWindowProtected, .scheduleWindowCorrected,
             .scheduleMutationUndone, .scheduleRitualApplied,
             .scheduleCalendarWriteCommitted, .reminderUpdated,
             .profilePreferencesUpdated, .historyRecommendationDismissed,
             .historyTodayReceiptRecorded, .repairRecovered,
             .externalReminderRequested, .externalCalendarEventRequested:
            .update
        }
    }

    var legalAggregateLifecycle: RuntimeAggregateLifecycle {
        legalAggregateTransition == .tombstone ? .tombstoned : .active
    }
}

struct RuntimeSemanticMutation: Codable, Sendable, Equatable, Hashable {
    let semanticType: RuntimeSemanticEventTypeID
    let aggregateID: RuntimeAggregateID
    let priorRevision: UInt64?
    let resultingRevision: UInt64
    let changedObjectIDs: [RuntimeDomainObjectID]
    let privacy: EventLedgerPrivacyClassification?
    let localOnly: Bool?
    let primaryAggregate: RuntimeSemanticAggregate?
    let aggregateTransitions: [RuntimeSemanticAggregateTransition]

    enum CodingKeys: String, CodingKey {
        case semanticType = "semantic_type"
        case aggregateID = "aggregate_id"
        case priorRevision = "prior_revision"
        case resultingRevision = "resulting_revision"
        case changedObjectIDs = "changed_object_ids"
        case privacy
        case localOnly = "local_only"
        case primaryAggregate = "primary_aggregate"
        case aggregateTransitions = "aggregate_transitions"
    }

    init(
        semanticType: RuntimeSemanticEventTypeID,
        aggregateID: RuntimeAggregateID,
        priorRevision: UInt64?,
        resultingRevision: UInt64,
        changedObjectIDs: [RuntimeDomainObjectID],
        privacy: EventLedgerPrivacyClassification = .standard,
        localOnly: Bool = true,
        primaryAggregate: RuntimeSemanticAggregate? = nil,
        aggregateTransitions: [RuntimeSemanticAggregateTransition] = []
    ) throws {
        self.semanticType = semanticType
        self.aggregateID = aggregateID
        self.priorRevision = priorRevision
        self.resultingRevision = resultingRevision
        self.changedObjectIDs = Self.canonicalIDs(changedObjectIDs)
        self.privacy = privacy
        self.localOnly = localOnly
        self.aggregateTransitions = aggregateTransitions.sorted {
            ($0.aggregate.kind.rawValue, $0.aggregate.id.rawValue) <
                ($1.aggregate.kind.rawValue, $1.aggregate.id.rawValue)
        }
        self.primaryAggregate = primaryAggregate
        try validate(expectedType: semanticType)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        semanticType = try values.decode(RuntimeSemanticEventTypeID.self, forKey: .semanticType)
        aggregateID = try values.decode(RuntimeAggregateID.self, forKey: .aggregateID)
        priorRevision = try values.decodeIfPresent(UInt64.self, forKey: .priorRevision)
        resultingRevision = try values.decode(UInt64.self, forKey: .resultingRevision)
        changedObjectIDs = try values.decode([RuntimeDomainObjectID].self, forKey: .changedObjectIDs)
        privacy = try values.decodeIfPresent(EventLedgerPrivacyClassification.self, forKey: .privacy)
        localOnly = try values.decodeIfPresent(Bool.self, forKey: .localOnly)
        primaryAggregate = try values.decodeIfPresent(RuntimeSemanticAggregate.self, forKey: .primaryAggregate)
        aggregateTransitions = try values.decodeIfPresent(
            [RuntimeSemanticAggregateTransition].self,
            forKey: .aggregateTransitions
        ) ?? []
        try validate(expectedType: semanticType)
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(semanticType, forKey: .semanticType)
        try values.encode(aggregateID, forKey: .aggregateID)
        try values.encodeIfPresent(priorRevision, forKey: .priorRevision)
        try values.encode(resultingRevision, forKey: .resultingRevision)
        try values.encode(changedObjectIDs, forKey: .changedObjectIDs)
        try values.encodeIfPresent(privacy, forKey: .privacy)
        try values.encodeIfPresent(localOnly, forKey: .localOnly)
        if aggregateTransitions.isEmpty == false {
            try values.encode(primaryAggregate, forKey: .primaryAggregate)
            try values.encode(aggregateTransitions, forKey: .aggregateTransitions)
        }
    }

    func validate(expectedType: RuntimeSemanticEventTypeID) throws {
        for transition in aggregateTransitions {
            let decoded: RuntimeCanonicalAggregateState
            do {
                decoded = try RuntimeCanonicalAggregateStateCodec().decode(transition.canonicalStateBytes)
            } catch {
                throw RuntimeSemanticEventCodecError.invalidPayload
            }
            guard transition.canonicalStateDigest == LocalRuntimeStorageChecksum.sha256Hex(
                for: transition.canonicalStateBytes
            ),
            decoded.aggregate == transition.aggregate,
            decoded.revision == transition.resultingRevision,
            decoded.lifecycle == transition.lifecycle,
            decoded.transition == transition.transition,
            decoded.changedObjectIDs == changedObjectIDs else {
                throw RuntimeSemanticEventCodecError.invalidPayload
            }
        }
        let hasValidProgression: Bool
        let primary = primaryAggregate.flatMap { primary in
            aggregateTransitions.first { $0.aggregate == primary }
        }
        if primary?.transition == .create || (aggregateTransitions.isEmpty && expectedType.isCreation) {
            hasValidProgression = priorRevision == nil && resultingRevision == 0
        } else if let priorRevision {
            hasValidProgression = priorRevision < UInt64.max && resultingRevision == priorRevision + 1
        } else {
            hasValidProgression = false
        }
        guard semanticType == expectedType,
              hasValidProgression,
              changedObjectIDs == Self.canonicalIDs(changedObjectIDs),
              aggregateTransitions.isEmpty == (primaryAggregate == nil),
              aggregateTransitions == aggregateTransitions.sorted(by: {
                  ($0.aggregate.kind.rawValue, $0.aggregate.id.rawValue) <
                      ($1.aggregate.kind.rawValue, $1.aggregate.id.rawValue)
              }),
              Set(aggregateTransitions.map(\.aggregate)).count == aggregateTransitions.count,
              aggregateTransitions.allSatisfy({ transition in
                  let transitionProgression = transition.transition == .create
                      ? transition.priorRevision == nil && transition.resultingRevision == 0
                      : transition.priorRevision.map {
                          $0 < UInt64.max && transition.resultingRevision == $0 + 1
                      } ?? false
                  return transitionProgression &&
                      transition.canonicalStateBytes.isEmpty == false &&
                      transition.privacy == privacy &&
                      transition.localOnly == localOnly &&
                      RuntimeStoreManifestCodec.isSHA256Hex(transition.canonicalStateDigest) &&
                      transition.canonicalStateDigest == transition.canonicalStateDigest.lowercased() &&
                      (transition.lifecycle == .tombstoned) == (transition.transition == .tombstone) &&
                      (transition.lifecycle == .tombstoned) == (transition.tombstone != nil) &&
                      (transition.tombstone.map({ authority in
                          RuntimeStoreManifestCodec.isSHA256Hex(authority.predecessorDigest) &&
                              authority.predecessorDigest == authority.predecessorDigest.lowercased()
                      }) ?? true)
              }),
              aggregateTransitions.isEmpty || (
                  primaryAggregate?.kind == expectedType.aggregateKind &&
                      primaryAggregate?.id == aggregateID &&
                      primary?.priorRevision == priorRevision &&
                      primary?.resultingRevision == resultingRevision &&
                      primary?.transition == expectedType.legalAggregateTransition &&
                      primary?.lifecycle == expectedType.legalAggregateLifecycle
              ) else {
            throw RuntimeSemanticEventCodecError.invalidPayload
        }
    }

    private static func canonicalIDs(_ values: [RuntimeDomainObjectID]) -> [RuntimeDomainObjectID] {
        Array(Set(values)).sorted()
    }
}

protocol RuntimeSemanticFamilyMutationPayload: Codable, Sendable, Equatable {
    var mutation: RuntimeSemanticMutation { get }
    func validate() throws
}

struct RuntimeCaptureMutationFacts: Codable, Sendable, Equatable {
    let action: CaptureCommand.Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
    let sourceType: CaptureSourceType?
    let entryPoint: CaptureCommand.EntryPoint?
    let route: CaptureRoute?
    let flagshipRoute: CaptureCommand.FlagshipRoute?
    let placementID: FlagshipPlacementID?
    let draftID: FlagshipDraftID?
    init(_ command: CaptureCommand) {
        action = command.action; target = command.target; content = command.content
        sourceType = command.sourceType; entryPoint = command.entryPoint; route = command.route
        flagshipRoute = command.flagshipRoute; placementID = command.placementID; draftID = command.draftID
    }
}

struct RuntimeGoalMutationFacts: Codable, Sendable, Equatable {
    let action: GoalCommand.Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
    init(_ command: GoalCommand) { action = command.action; target = command.target; content = command.content }
}

struct RuntimeStepMutationFacts: Codable, Sendable, Equatable {
    let action: StepCommand.Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
    init(_ command: StepCommand) { action = command.action; target = command.target; content = command.content }
}

struct RuntimeScheduleMutationFacts: Codable, Sendable, Equatable {
    let action: ScheduleCommand.Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
    init(_ command: ScheduleCommand) { action = command.action; target = command.target; content = command.content }
}

struct RuntimeReminderMutationFacts: Codable, Sendable, Equatable {
    let action: ReminderCommand.Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
    init(_ command: ReminderCommand) { action = command.action; target = command.target; content = command.content }
}

struct RuntimeProfileMutationFacts: Codable, Sendable, Equatable {
    let action: ProfileCommand.Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
    let preferences: ProfilePreferencesCommandValues?
    init(_ command: ProfileCommand) {
        action = command.action; target = command.target; content = command.content; preferences = command.preferences
    }
}

struct RuntimeHistoryMutationFacts: Codable, Sendable, Equatable {
    let action: HistoryCommand.Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
    init(_ command: HistoryCommand) { action = command.action; target = command.target; content = command.content }
}

struct RuntimeRepairMutationFacts: Codable, Sendable, Equatable {
    let action: RepairCommand.Action
    let recommendation: RecoveryRecommendationCommand
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
    init(_ command: RepairCommand) {
        action = command.action; recommendation = command.recommendation
        target = command.target; content = command.content
    }
}

struct RuntimeImportDeletionMutationFacts: Codable, Sendable, Equatable {
    let action: ImportDeletionCommand.Action
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
    init(_ command: ImportDeletionCommand) { action = command.action; target = command.target; content = command.content }
}

struct RuntimeExternalOperationMutationFacts: Codable, Sendable, Equatable {
    let operationID: RuntimeExternalOperationID
    let kind: RuntimeExternalEffectKind
    let target: AmbitionsCommandTarget
    let title: String
    init(_ command: ExternalOperationCommand) {
        operationID = command.operationID; kind = command.kind; target = command.target; title = command.title
    }
}

struct RuntimeCompensationMutationFacts: Codable, Sendable, Equatable {
    let sourceReceiptID: RuntimeReceiptID
    let planID: RuntimeRollbackPlanID
    let planDigest: String
    let sourceLineage: RuntimeAuthorityLineageReference
    let action: RuntimeSemanticCompensationAction
    let targets: [RuntimeCompensationTargetExpectation]
    let requiresConfirmation: Bool
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent

    init(_ command: RuntimeCompensationCommand) {
        sourceReceiptID = command.sourceReceiptID
        planID = command.planID
        planDigest = command.planDigest
        sourceLineage = command.sourceLineage
        action = command.action
        targets = command.targets
        requiresConfirmation = command.requiresConfirmation
        target = command.target
        content = command.content
    }

    var command: RuntimeCompensationCommand {
        RuntimeCompensationCommand(
            sourceReceiptID: sourceReceiptID, planID: planID,
            planDigest: planDigest, sourceLineage: sourceLineage,
            action: action, targets: targets,
            requiresConfirmation: requiresConfirmation,
            target: target, content: content
        )
    }
}

struct RuntimeCaptureMutationPayload: RuntimeSemanticFamilyMutationPayload {
    let mutation: RuntimeSemanticMutation
    let facts: RuntimeCaptureMutationFacts

    init(mutation: RuntimeSemanticMutation, facts: CaptureCommand) throws {
        self.mutation = mutation
        self.facts = RuntimeCaptureMutationFacts(facts)
        try validate()
    }

    func validate() throws {
        let expected: RuntimeSemanticEventTypeID = switch facts.action {
        case .quickCapture: .captureCreated
        case .routeCommitment: .captureCommitmentRouted
        case .attachToGoal: .captureAttachedToGoal
        case .markWaiting: .captureMarkedWaiting
        case .archive: .captureArchived
        }
        try mutation.validate(expectedType: expected)
    }
}

struct RuntimeGoalMutationPayload: RuntimeSemanticFamilyMutationPayload {
    let mutation: RuntimeSemanticMutation
    let facts: RuntimeGoalMutationFacts
    init(mutation: RuntimeSemanticMutation, facts: GoalCommand) throws {
        self.mutation = mutation; self.facts = RuntimeGoalMutationFacts(facts); try validate()
    }
    func validate() throws {
        let expected: RuntimeSemanticEventTypeID = switch facts.action {
        case .create: .goalCreated
        case .update: .goalUpdated
        case .setPriority: .goalPrioritySet
        case .setUrgency: .goalUrgencySet
        case .setDeadline: .goalDeadlineSet
        case .setContextLens: .goalContextLensSet
        case .clearContextLens: .goalContextLensCleared
        case .addDeliverable: .goalDeliverableAdded
        case .removeDeliverable: .goalDeliverableRemoved
        case .addScopeItem: .goalScopeItemAdded
        case .removeScopeItem: .goalScopeItemRemoved
        }
        try mutation.validate(expectedType: expected)
    }
}

struct RuntimeStepMutationPayload: RuntimeSemanticFamilyMutationPayload {
    let mutation: RuntimeSemanticMutation
    let facts: RuntimeStepMutationFacts
    init(mutation: RuntimeSemanticMutation, facts: StepCommand) throws {
        self.mutation = mutation; self.facts = RuntimeStepMutationFacts(facts); try validate()
    }
    func validate() throws {
        let expected: RuntimeSemanticEventTypeID = switch facts.action {
        case .startSession: .stepSessionStarted
        case .complete: .stepCompleted
        case .delay: .stepDelayed
        case .split: .stepSplit
        case .recover: .stepRecovered
        case .todayGoalStep: .stepTodayActionApplied
        }
        try mutation.validate(expectedType: expected)
    }
}

struct RuntimeScheduleMutationPayload: RuntimeSemanticFamilyMutationPayload {
    let mutation: RuntimeSemanticMutation
    let facts: RuntimeScheduleMutationFacts
    init(mutation: RuntimeSemanticMutation, facts: ScheduleCommand) throws {
        self.mutation = mutation; self.facts = RuntimeScheduleMutationFacts(facts); try validate()
    }
    func validate() throws {
        let expected: RuntimeSemanticEventTypeID = switch facts.action {
        case .createItem: .scheduleItemCreated
        case .schedule: .scheduleItemScheduled
        case .placeStep: .scheduleStepPlaced
        case .protectWindow: .scheduleWindowProtected
        case .correctWindow: .scheduleWindowCorrected
        case .undo: .scheduleMutationUndone
        case .ritual: .scheduleRitualApplied
        case .calendarWrite: .scheduleCalendarWriteCommitted
        }
        try mutation.validate(expectedType: expected)
    }
}

struct RuntimeReminderMutationPayload: RuntimeSemanticFamilyMutationPayload {
    let mutation: RuntimeSemanticMutation
    let facts: RuntimeReminderMutationFacts
    init(mutation: RuntimeSemanticMutation, facts: ReminderCommand) throws {
        self.mutation = mutation; self.facts = RuntimeReminderMutationFacts(facts); try validate()
    }
    func validate() throws {
        let expected: RuntimeSemanticEventTypeID = switch facts.action {
        case .create: .reminderCreated
        case .update: .reminderUpdated
        case .delete: .reminderDeleted
        }
        try mutation.validate(expectedType: expected)
    }
}

struct RuntimeProfileMutationPayload: RuntimeSemanticFamilyMutationPayload {
    let mutation: RuntimeSemanticMutation
    let facts: RuntimeProfileMutationFacts
    init(mutation: RuntimeSemanticMutation, facts: ProfileCommand) throws {
        self.mutation = mutation; self.facts = RuntimeProfileMutationFacts(facts); try validate()
    }
    func validate() throws {
        guard facts.preferences != nil else { throw RuntimeSemanticEventCodecError.invalidPayload }
        try mutation.validate(expectedType: .profilePreferencesUpdated)
    }
}

struct RuntimeHistoryMutationPayload: RuntimeSemanticFamilyMutationPayload {
    let mutation: RuntimeSemanticMutation
    let facts: RuntimeHistoryMutationFacts
    init(mutation: RuntimeSemanticMutation, facts: HistoryCommand) throws {
        self.mutation = mutation; self.facts = RuntimeHistoryMutationFacts(facts); try validate()
    }
    func validate() throws {
        let expected: RuntimeSemanticEventTypeID
        switch facts.action {
        case .dismissRecommendation: expected = .historyRecommendationDismissed
        case .todayReceipt: expected = .historyTodayReceiptRecorded
        case .openDestination, .askWhy: throw RuntimeSemanticEventCodecError.invalidPayload
        }
        try mutation.validate(expectedType: expected)
    }
}

struct RuntimeRepairMutationPayload: RuntimeSemanticFamilyMutationPayload {
    let mutation: RuntimeSemanticMutation
    let facts: RuntimeRepairMutationFacts
    init(mutation: RuntimeSemanticMutation, facts: RepairCommand) throws {
        self.mutation = mutation; self.facts = RuntimeRepairMutationFacts(facts); try validate()
    }
    func validate() throws {
        guard facts.action == .recover else { throw RuntimeSemanticEventCodecError.invalidPayload }
        try mutation.validate(expectedType: .repairRecovered)
    }
}

struct RuntimeImportDeletionMutationPayload: RuntimeSemanticFamilyMutationPayload {
    let mutation: RuntimeSemanticMutation
    let facts: RuntimeImportDeletionMutationFacts
    init(mutation: RuntimeSemanticMutation, facts: ImportDeletionCommand) throws {
        self.mutation = mutation; self.facts = RuntimeImportDeletionMutationFacts(facts); try validate()
    }
    func validate() throws {
        let expected: RuntimeSemanticEventTypeID
        switch facts.action {
        case .deleteObject: expected = .objectDeleted
        case .forgetMemory: expected = .memoryForgotten
        case .prepareExport, .performExport: throw RuntimeSemanticEventCodecError.invalidPayload
        }
        try mutation.validate(expectedType: expected)
    }
}

struct RuntimeExternalOperationMutationPayload: RuntimeSemanticFamilyMutationPayload {
    let mutation: RuntimeSemanticMutation
    let facts: RuntimeExternalOperationMutationFacts
    init(mutation: RuntimeSemanticMutation, facts: ExternalOperationCommand) throws {
        self.mutation = mutation; self.facts = RuntimeExternalOperationMutationFacts(facts); try validate()
    }
    func validate() throws {
        let expected: RuntimeSemanticEventTypeID = switch facts.kind {
        case .reminder: .externalReminderRequested
        case .calendarEvent: .externalCalendarEventRequested
        }
        try mutation.validate(expectedType: expected)
    }
}

struct RuntimeCompensationMutationPayload: RuntimeSemanticFamilyMutationPayload {
    let mutation: RuntimeSemanticMutation
    let facts: RuntimeCompensationMutationFacts

    init(mutation: RuntimeSemanticMutation, facts: RuntimeCompensationCommand) throws {
        self.mutation = mutation
        self.facts = RuntimeCompensationMutationFacts(facts)
        try validate()
    }

    func validate() throws {
        let expected: RuntimeSemanticEventTypeID = switch facts.action {
        case .discardCreatedCapture: .captureCreatedCompensated
        case .discardCreatedGoal: .goalCreatedCompensated
        case .discardCreatedSchedule: .scheduleCreatedCompensated
        case .discardCreatedReminder: .reminderCreatedCompensated
        }
        try Task.checkCancellation()
        guard facts.targets.isEmpty == false,
              facts.targets.count <= RuntimeCompensationLimits.maximumTargets else {
            throw RuntimeSemanticEventCodecError.invalidPayload
        }
        let targetKeys = facts.targets.map {
            "\($0.aggregate.kind.rawValue)\u{0}\($0.aggregate.id.rawValue)"
        }
        guard facts.targets == facts.targets.sorted(),
              Set(targetKeys).count == targetKeys.count,
              facts.content == RuntimeCommandContent(),
              facts.targets.allSatisfy({ target in
                  target.aggregate.kind == facts.action.aggregateKind &&
                      target.inverseTransition == facts.action.transition &&
                      target.requiredCurrentRevision == target.sourceRevision &&
                      RuntimeStoreManifestCodec.isSHA256Hex(target.sourceStateDigest)
              }) else {
            throw RuntimeSemanticEventCodecError.invalidPayload
        }
        for target in facts.targets {
            try Task.checkCancellation()
            guard target.aggregate.kind == facts.action.aggregateKind,
                  target.inverseTransition == facts.action.transition,
                  target.requiredCurrentRevision == target.sourceRevision,
                  RuntimeStoreManifestCodec.isSHA256Hex(target.sourceStateDigest) else {
                throw RuntimeSemanticEventCodecError.invalidPayload
            }
        }
        try mutation.validate(expectedType: expected)
    }
}

enum RuntimeCaptureSemanticEvent: Sendable, Equatable {
    case created(RuntimeCaptureMutationPayload)
    case commitmentRouted(RuntimeCaptureMutationPayload)
    case attachedToGoal(RuntimeCaptureMutationPayload)
    case markedWaiting(RuntimeCaptureMutationPayload)
    case archived(RuntimeCaptureMutationPayload)
}
enum RuntimeGoalSemanticEvent: Sendable, Equatable {
    case created(RuntimeGoalMutationPayload)
    case updated(RuntimeGoalMutationPayload)
    case prioritySet(RuntimeGoalMutationPayload)
    case urgencySet(RuntimeGoalMutationPayload)
    case deadlineSet(RuntimeGoalMutationPayload)
    case contextLensSet(RuntimeGoalMutationPayload)
    case contextLensCleared(RuntimeGoalMutationPayload)
    case deliverableAdded(RuntimeGoalMutationPayload)
    case deliverableRemoved(RuntimeGoalMutationPayload)
    case scopeItemAdded(RuntimeGoalMutationPayload)
    case scopeItemRemoved(RuntimeGoalMutationPayload)
}
enum RuntimeStepSemanticEvent: Sendable, Equatable {
    case sessionStarted(RuntimeStepMutationPayload)
    case completed(RuntimeStepMutationPayload)
    case delayed(RuntimeStepMutationPayload)
    case split(RuntimeStepMutationPayload)
    case recovered(RuntimeStepMutationPayload)
    case todayActionApplied(RuntimeStepMutationPayload)
}
enum RuntimeScheduleSemanticEvent: Sendable, Equatable {
    case itemCreated(RuntimeScheduleMutationPayload)
    case itemScheduled(RuntimeScheduleMutationPayload)
    case stepPlaced(RuntimeScheduleMutationPayload)
    case windowProtected(RuntimeScheduleMutationPayload)
    case windowCorrected(RuntimeScheduleMutationPayload)
    case mutationUndone(RuntimeScheduleMutationPayload)
    case ritualApplied(RuntimeScheduleMutationPayload)
    case calendarWriteCommitted(RuntimeScheduleMutationPayload)
}
enum RuntimeReminderSemanticEvent: Sendable, Equatable {
    case created(RuntimeReminderMutationPayload)
    case updated(RuntimeReminderMutationPayload)
    case deleted(RuntimeReminderMutationPayload)
}
enum RuntimeProfileSemanticEvent: Sendable, Equatable { case preferencesUpdated(RuntimeProfileMutationPayload) }
enum RuntimeHistorySemanticEvent: Sendable, Equatable {
    case recommendationDismissed(RuntimeHistoryMutationPayload)
    case todayReceiptRecorded(RuntimeHistoryMutationPayload)
}
enum RuntimeRepairSemanticEvent: Sendable, Equatable { case recovered(RuntimeRepairMutationPayload) }
enum RuntimeImportDeletionSemanticEvent: Sendable, Equatable {
    case objectDeleted(RuntimeImportDeletionMutationPayload)
    case memoryForgotten(RuntimeImportDeletionMutationPayload)
}
enum RuntimeExternalOperationSemanticEvent: Sendable, Equatable {
    case reminderRequested(RuntimeExternalOperationMutationPayload)
    case calendarEventRequested(RuntimeExternalOperationMutationPayload)
}
enum RuntimeCompensationSemanticEvent: Sendable, Equatable {
    case applied(RuntimeCompensationMutationPayload)
}

enum RuntimeSemanticEvent: Sendable, Equatable {
    case capture(RuntimeCaptureSemanticEvent)
    case goal(RuntimeGoalSemanticEvent)
    case step(RuntimeStepSemanticEvent)
    case schedule(RuntimeScheduleSemanticEvent)
    case reminder(RuntimeReminderSemanticEvent)
    case profile(RuntimeProfileSemanticEvent)
    case history(RuntimeHistorySemanticEvent)
    case repair(RuntimeRepairSemanticEvent)
    case importDeletion(RuntimeImportDeletionSemanticEvent)
    case externalOperation(RuntimeExternalOperationSemanticEvent)
    case compensation(RuntimeCompensationSemanticEvent)

    var typeID: RuntimeSemanticEventTypeID {
        switch self {
        case let .capture(value):
            switch value {
            case .created: .captureCreated
            case .commitmentRouted: .captureCommitmentRouted
            case .attachedToGoal: .captureAttachedToGoal
            case .markedWaiting: .captureMarkedWaiting
            case .archived: .captureArchived
            }
        case let .goal(value):
            switch value {
            case .created: .goalCreated
            case .updated: .goalUpdated
            case .prioritySet: .goalPrioritySet
            case .urgencySet: .goalUrgencySet
            case .deadlineSet: .goalDeadlineSet
            case .contextLensSet: .goalContextLensSet
            case .contextLensCleared: .goalContextLensCleared
            case .deliverableAdded: .goalDeliverableAdded
            case .deliverableRemoved: .goalDeliverableRemoved
            case .scopeItemAdded: .goalScopeItemAdded
            case .scopeItemRemoved: .goalScopeItemRemoved
            }
        case let .step(value):
            switch value {
            case .sessionStarted: .stepSessionStarted
            case .completed: .stepCompleted
            case .delayed: .stepDelayed
            case .split: .stepSplit
            case .recovered: .stepRecovered
            case .todayActionApplied: .stepTodayActionApplied
            }
        case let .schedule(value):
            switch value {
            case .itemCreated: .scheduleItemCreated
            case .itemScheduled: .scheduleItemScheduled
            case .stepPlaced: .scheduleStepPlaced
            case .windowProtected: .scheduleWindowProtected
            case .windowCorrected: .scheduleWindowCorrected
            case .mutationUndone: .scheduleMutationUndone
            case .ritualApplied: .scheduleRitualApplied
            case .calendarWriteCommitted: .scheduleCalendarWriteCommitted
            }
        case let .reminder(value):
            switch value {
            case .created: .reminderCreated
            case .updated: .reminderUpdated
            case .deleted: .reminderDeleted
            }
        case .profile: .profilePreferencesUpdated
        case let .history(value):
            switch value {
            case .recommendationDismissed: .historyRecommendationDismissed
            case .todayReceiptRecorded: .historyTodayReceiptRecorded
            }
        case .repair: .repairRecovered
        case let .importDeletion(value):
            switch value {
            case .objectDeleted: .objectDeleted
            case .memoryForgotten: .memoryForgotten
            }
        case let .externalOperation(value):
            switch value {
            case .reminderRequested: .externalReminderRequested
            case .calendarEventRequested: .externalCalendarEventRequested
            }
        case let .compensation(value): value.payload.mutation.semanticType
        }
    }
    var aggregateKind: RuntimeSemanticAggregateKind {
        mutation.primaryAggregate?.kind ?? typeID.aggregateKind
    }

    var mutation: RuntimeSemanticMutation {
        switch self {
        case let .capture(value): value.payload.mutation
        case let .goal(value): value.payload.mutation
        case let .step(value): value.payload.mutation
        case let .schedule(value): value.payload.mutation
        case let .reminder(value): value.payload.mutation
        case let .profile(value): value.payload.mutation
        case let .history(value): value.payload.mutation
        case let .repair(value): value.payload.mutation
        case let .importDeletion(value): value.payload.mutation
        case let .externalOperation(value): value.payload.mutation
        case let .compensation(value): value.payload.mutation
        }
    }

    func validate() throws {
        guard mutation.semanticType == typeID,
              mutation.aggregateTransitions.isEmpty || mutation.primaryAggregate?.kind == typeID.aggregateKind else {
            throw RuntimeSemanticEventCodecError.typeMismatch
        }
        switch self {
        case let .capture(value): try value.payload.validate()
        case let .goal(value): try value.payload.validate()
        case let .step(value): try value.payload.validate()
        case let .schedule(value): try value.payload.validate()
        case let .reminder(value): try value.payload.validate()
        case let .profile(value): try value.payload.validate()
        case let .history(value): try value.payload.validate()
        case let .repair(value): try value.payload.validate()
        case let .importDeletion(value): try value.payload.validate()
        case let .externalOperation(value): try value.payload.validate()
        case let .compensation(value): try value.payload.validate()
        }
    }

    var commandPayload: RuntimeCommandPayload {
        switch self {
        case let .capture(value):
            let f = value.payload.facts
            return .capture(CaptureCommand(
                action: f.action, target: f.target, content: f.content,
                sourceType: f.sourceType, entryPoint: f.entryPoint, route: f.route,
                flagshipRoute: f.flagshipRoute, placementID: f.placementID, draftID: f.draftID
            ))
        case let .goal(value):
            let f = value.payload.facts
            return .goal(GoalCommand(action: f.action, target: f.target, content: f.content))
        case let .step(value):
            let f = value.payload.facts
            return .step(StepCommand(action: f.action, target: f.target, content: f.content))
        case let .schedule(value):
            let f = value.payload.facts
            return .schedule(ScheduleCommand(action: f.action, target: f.target, content: f.content))
        case let .reminder(value):
            let f = value.payload.facts
            return .reminder(ReminderCommand(action: f.action, target: f.target, content: f.content))
        case let .profile(value):
            let f = value.payload.facts
            return .profile(ProfileCommand(
                action: f.action, target: f.target, content: f.content, preferences: f.preferences
            ))
        case let .history(value):
            let f = value.payload.facts
            return .history(HistoryCommand(action: f.action, target: f.target, content: f.content))
        case let .repair(value):
            let f = value.payload.facts
            return .repair(RepairCommand(
                action: f.action, recommendation: f.recommendation, target: f.target, content: f.content
            ))
        case let .importDeletion(value):
            let f = value.payload.facts
            return .importDeletion(ImportDeletionCommand(action: f.action, target: f.target, content: f.content))
        case let .externalOperation(value):
            let f = value.payload.facts
            return .externalOperation(ExternalOperationCommand(
                operationID: f.operationID, kind: f.kind, target: f.target, title: f.title,
                action: f.effectiveAction, sourceOperationID: f.sourceOperationID,
                sourceProviderReference: f.sourceProviderReference,
                sourceReceiptID: f.sourceReceiptID,
                compensationPlanID: f.compensationPlanID,
                compensationPlanDigest: f.compensationPlanDigest
            ))
        case let .compensation(value):
            return .compensation(value.payload.facts.command)
        }
    }
}

extension RuntimeCaptureSemanticEvent {
    var payload: RuntimeCaptureMutationPayload { switch self { case let .created(v), let .commitmentRouted(v), let .attachedToGoal(v), let .markedWaiting(v), let .archived(v): v } }
}
extension RuntimeGoalSemanticEvent {
    var payload: RuntimeGoalMutationPayload { switch self { case let .created(v), let .updated(v), let .prioritySet(v), let .urgencySet(v), let .deadlineSet(v), let .contextLensSet(v), let .contextLensCleared(v), let .deliverableAdded(v), let .deliverableRemoved(v), let .scopeItemAdded(v), let .scopeItemRemoved(v): v } }
}
extension RuntimeStepSemanticEvent {
    var payload: RuntimeStepMutationPayload { switch self { case let .sessionStarted(v), let .completed(v), let .delayed(v), let .split(v), let .recovered(v), let .todayActionApplied(v): v } }
}
extension RuntimeScheduleSemanticEvent {
    var payload: RuntimeScheduleMutationPayload { switch self { case let .itemCreated(v), let .itemScheduled(v), let .stepPlaced(v), let .windowProtected(v), let .windowCorrected(v), let .mutationUndone(v), let .ritualApplied(v), let .calendarWriteCommitted(v): v } }
}
extension RuntimeReminderSemanticEvent {
    var payload: RuntimeReminderMutationPayload { switch self { case let .created(v), let .updated(v), let .deleted(v): v } }
}
extension RuntimeProfileSemanticEvent { var payload: RuntimeProfileMutationPayload { switch self { case let .preferencesUpdated(v): v } } }
extension RuntimeHistorySemanticEvent { var payload: RuntimeHistoryMutationPayload { switch self { case let .recommendationDismissed(v), let .todayReceiptRecorded(v): v } } }
extension RuntimeRepairSemanticEvent { var payload: RuntimeRepairMutationPayload { switch self { case let .recovered(v): v } } }
extension RuntimeImportDeletionSemanticEvent { var payload: RuntimeImportDeletionMutationPayload { switch self { case let .objectDeleted(v), let .memoryForgotten(v): v } } }
extension RuntimeExternalOperationSemanticEvent { var payload: RuntimeExternalOperationMutationPayload { switch self { case let .reminderRequested(v), let .calendarEventRequested(v): v } } }
extension RuntimeCompensationSemanticEvent { var payload: RuntimeCompensationMutationPayload { switch self { case let .applied(v): v } } }

enum RuntimeSemanticEventRegistry {
    static let allRegisteredTypeIDs = Set(RuntimeSemanticEventTypeID.allCases)
    static let registeredUpcasterVersions: [RuntimeSemanticEventTypeID: Set<Int>] = [
        .captureCreated: [0],
    ]
    static func supports(typeID: RuntimeSemanticEventTypeID, payloadVersion: Int) -> Bool {
        typeID.supportedPayloadVersions.contains(payloadVersion)
    }

    static func requiresUpcast(typeID: RuntimeSemanticEventTypeID, payloadVersion: Int) -> Bool {
        registeredUpcasterVersions[typeID]?.contains(payloadVersion) == true
    }
}

enum RuntimeNonMutatingCommandClassification: String, Codable, Sendable, Equatable, Hashable {
    case navigation
    case inspection
    case exportPreparation = "export_preparation"
    case exportExecution = "export_execution"
}
enum RuntimeCommandSemanticClassification: Sendable, Equatable, Hashable {
    case mutating(RuntimeSemanticEventTypeID)
    case nonMutating(RuntimeNonMutatingCommandClassification)
}

enum RuntimeSemanticEventClassifier {
    static let allMutationTypeIDs = Set(RuntimeSemanticEventTypeID.allCases)
    static let explicitNonMutatingClassifications: Set<RuntimeNonMutatingCommandClassification> = [.navigation, .inspection, .exportPreparation, .exportExecution]

    static func classify(_ command: RuntimeCommandPayload) -> RuntimeCommandSemanticClassification {
        switch command {
        case let .capture(value):
            switch value.action {
            case .quickCapture: .mutating(.captureCreated)
            case .routeCommitment: .mutating(.captureCommitmentRouted)
            case .attachToGoal: .mutating(.captureAttachedToGoal)
            case .markWaiting: .mutating(.captureMarkedWaiting)
            case .archive: .mutating(.captureArchived)
            }
        case let .goal(value):
            switch value.action {
            case .create: .mutating(.goalCreated)
            case .update: .mutating(.goalUpdated)
            case .setPriority: .mutating(.goalPrioritySet)
            case .setUrgency: .mutating(.goalUrgencySet)
            case .setDeadline: .mutating(.goalDeadlineSet)
            case .setContextLens: .mutating(.goalContextLensSet)
            case .clearContextLens: .mutating(.goalContextLensCleared)
            case .addDeliverable: .mutating(.goalDeliverableAdded)
            case .removeDeliverable: .mutating(.goalDeliverableRemoved)
            case .addScopeItem: .mutating(.goalScopeItemAdded)
            case .removeScopeItem: .mutating(.goalScopeItemRemoved)
            }
        case let .step(value):
            switch value.action {
            case .startSession: .mutating(.stepSessionStarted)
            case .complete: .mutating(.stepCompleted)
            case .delay: .mutating(.stepDelayed)
            case .split: .mutating(.stepSplit)
            case .recover: .mutating(.stepRecovered)
            case .todayGoalStep: .mutating(.stepTodayActionApplied)
            }
        case let .schedule(value):
            switch value.action {
            case .createItem: .mutating(.scheduleItemCreated)
            case .schedule: .mutating(.scheduleItemScheduled)
            case .placeStep: .mutating(.scheduleStepPlaced)
            case .protectWindow: .mutating(.scheduleWindowProtected)
            case .correctWindow: .mutating(.scheduleWindowCorrected)
            case .undo: .mutating(.scheduleMutationUndone)
            case .ritual: .mutating(.scheduleRitualApplied)
            case .calendarWrite: .mutating(.scheduleCalendarWriteCommitted)
            }
        case let .reminder(value):
            switch value.action {
            case .create: .mutating(.reminderCreated)
            case .update: .mutating(.reminderUpdated)
            case .delete: .mutating(.reminderDeleted)
            }
        case .profile:
            .mutating(.profilePreferencesUpdated)
        case let .history(value):
            switch value.action {
            case .openDestination: .nonMutating(.navigation)
            case .askWhy: .nonMutating(.inspection)
            case .dismissRecommendation: .mutating(.historyRecommendationDismissed)
            case .todayReceipt: .mutating(.historyTodayReceiptRecorded)
            }
        case let .repair(value):
            switch value.action {
            case .recover: .mutating(.repairRecovered)
            case .openDestination: .nonMutating(.navigation)
            }
        case let .importDeletion(value):
            switch value.action {
            case .prepareExport: .nonMutating(.exportPreparation)
            case .performExport: .nonMutating(.exportExecution)
            case .deleteObject: .mutating(.objectDeleted)
            case .forgetMemory: .mutating(.memoryForgotten)
            }
        case let .externalOperation(value):
            switch value.kind {
            case .reminder: .mutating(.externalReminderRequested)
            case .calendarEvent: .mutating(.externalCalendarEventRequested)
            }
        case let .compensation(value):
            switch value.action {
            case .discardCreatedCapture: .mutating(.captureCreatedCompensated)
            case .discardCreatedGoal: .mutating(.goalCreatedCompensated)
            case .discardCreatedSchedule: .mutating(.scheduleCreatedCompensated)
            case .discardCreatedReminder: .mutating(.reminderCreatedCompensated)
            }
        }
    }
}

struct RuntimeSemanticEventDraft: Sendable, Equatable {
    let eventID: RuntimeEventID
    let commandID: RuntimeCommandID
    let aggregate: RuntimeSemanticAggregate
    let correlationID: RuntimeCorrelationID
    let causationEventID: RuntimeEventID?
    let occurredAt: Date
    let event: RuntimeSemanticEvent
}

struct RuntimeSemanticEventDraftFactory: Sendable {
    private var environment: RuntimeEnvironment
    init(environment: RuntimeEnvironment) { self.environment = environment }
    mutating func make(commandID: RuntimeCommandID, aggregate: RuntimeSemanticAggregate, correlationID: RuntimeCorrelationID, causationEventID: RuntimeEventID? = nil, event: RuntimeSemanticEvent) throws -> RuntimeSemanticEventDraft {
        guard event.aggregateKind == aggregate.kind, event.mutation.aggregateID == aggregate.id else {
            throw RuntimeSemanticEventCodecError.invalidPayload
        }
        return RuntimeSemanticEventDraft(
            eventID: try RuntimeEventID(validating: "event.\(environment.uuid.nextUUID().uuidString.lowercased())"),
            commandID: commandID,
            aggregate: aggregate,
            correlationID: correlationID,
            causationEventID: causationEventID,
            occurredAt: environment.clock.now,
            event: event
        )
    }
}
