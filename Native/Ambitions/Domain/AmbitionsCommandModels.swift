import Foundation

let ambitionsCommandSchemaVersion = "ambitions_command.native.v1"

enum AmbitionsCommandKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case openDestination = "open_destination"
    case quickCapture = "quick_capture"
    case createGoal = "create_goal"
    case updateGoal = "update_goal"
    case attachToGoal = "attach_to_goal"
    case createPlanItem = "create_plan_item"
    case scheduleItem = "schedule_item"
    case startFocus = "start_focus"
    case completeAction = "complete_action"
    case delayAction = "delay_action"
    case splitAction = "split_action"
    case recoverAction = "recover_action"
    case markWaiting = "mark_waiting"
    case archiveItem = "archive_item"
    case setPriority = "set_priority"
    case setUrgency = "set_urgency"
    case setDeadline = "set_deadline"
    case setContextLens = "set_context_lens"
    case clearContextLensOverride = "clear_context_lens_override"
    case routeCommitment = "route_commitment"
    case addDeliverable = "add_deliverable"
    case removeDeliverable = "remove_deliverable"
    case addGoalScopeItem = "add_goal_scope_item"
    case removeGoalScopeItem = "remove_goal_scope_item"
    case askWhy = "ask_why"
    case dismissRecommendation = "dismiss_recommendation"
}

enum AmbitionsCommandSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case today
    case goals
    case capture
    case plan
    case you
    case reviews
    case goalDetail = "goal_detail"
    case widget
    case liveActivity = "live_activity"
    case appIntent = "app_intent"
    case notification
    case deepLink = "deep_link"
    case system
}

enum AmbitionsCommandActor: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case user
    case system
    case externalSurface = "external_surface"
}

enum AmbitionsCommandDestination: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case today
    case goals
    case capture
    case plan
    case you
    case reviews
    case goalDetail = "goal_detail"
    case capturesInbox = "captures_inbox"
    case memoryLens = "memory_lens"
    case commandSheet = "command_sheet"
    case weeklyReview = "weekly_review"
}

struct AmbitionsCommandRelations: Codable, Sendable, Equatable, Hashable {
    let goalIDs: [String]
    let captureIDs: [String]
    let planIDs: [String]
    let reviewIDs: [String]
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]

    init(
        goalIDs: [String] = [],
        captureIDs: [String] = [],
        planIDs: [String] = [],
        reviewIDs: [String] = [],
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = []
    ) {
        self.goalIDs = Self.normalized(goalIDs)
        self.captureIDs = Self.normalized(captureIDs)
        self.planIDs = Self.normalized(planIDs)
        self.reviewIDs = Self.normalized(reviewIDs)
        self.eventLedgerEntryIDs = Self.normalized(eventLedgerEntryIDs)
        self.recommendationExplanationIDs = Self.normalized(recommendationExplanationIDs)
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsCommandTarget: Codable, Sendable, Equatable, Hashable {
    let goalID: String?
    let captureID: String?
    let planID: String?
    let reviewID: String?
    let stepID: String?
    let deliverableID: String?
    let scopeItemID: String?
    let recommendationID: String?
    let explanationID: String?
    let destination: AmbitionsCommandDestination?

    init(
        goalID: String? = nil,
        captureID: String? = nil,
        planID: String? = nil,
        reviewID: String? = nil,
        stepID: String? = nil,
        deliverableID: String? = nil,
        scopeItemID: String? = nil,
        recommendationID: String? = nil,
        explanationID: String? = nil,
        destination: AmbitionsCommandDestination? = nil
    ) {
        self.goalID = Self.nonEmpty(goalID)
        self.captureID = Self.nonEmpty(captureID)
        self.planID = Self.nonEmpty(planID)
        self.reviewID = Self.nonEmpty(reviewID)
        self.stepID = Self.nonEmpty(stepID)
        self.deliverableID = Self.nonEmpty(deliverableID)
        self.scopeItemID = Self.nonEmpty(scopeItemID)
        self.recommendationID = Self.nonEmpty(recommendationID)
        self.explanationID = Self.nonEmpty(explanationID)
        self.destination = destination
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value, value.isEmpty == false else { return nil }
        return value
    }
}

struct AmbitionsCommandPriorityHints: Codable, Sendable, Equatable, Hashable {
    let importance: NowPressureLevel?
    let urgency: NowPressureLevel?
    let deadline: NowPressureLevel?
    let consequence: NowPressureLevel?
    let effort: NowPressureLevel?
    let contextFit: NowPressureLevel?
    let goalRelationship: NowPressureLevel?
    let userPreference: NowPressureLevel?
    let capacityHint: NowPressureLevel?
    let recoveryState: NowRecoveryState?

    init(
        importance: NowPressureLevel? = nil,
        urgency: NowPressureLevel? = nil,
        deadline: NowPressureLevel? = nil,
        consequence: NowPressureLevel? = nil,
        effort: NowPressureLevel? = nil,
        contextFit: NowPressureLevel? = nil,
        goalRelationship: NowPressureLevel? = nil,
        userPreference: NowPressureLevel? = nil,
        capacityHint: NowPressureLevel? = nil,
        recoveryState: NowRecoveryState? = nil
    ) {
        self.importance = importance
        self.urgency = urgency
        self.deadline = deadline
        self.consequence = consequence
        self.effort = effort
        self.contextFit = contextFit
        self.goalRelationship = goalRelationship
        self.userPreference = userPreference
        self.capacityHint = capacityHint
        self.recoveryState = recoveryState
    }

    var hasAnySignal: Bool {
        importance != nil || urgency != nil || deadline != nil || consequence != nil || effort != nil ||
            contextFit != nil || goalRelationship != nil || userPreference != nil || capacityHint != nil ||
            recoveryState != nil
    }
}

struct AmbitionsCommandPayload: Codable, Sendable, Equatable, Hashable {
    let rawText: String?
    let title: String?
    let notes: String?
    let dueText: String?
    let deadlineText: String?
    let contextLens: NowContextLens?
    let commitmentKind: NowCommitmentKind?
    let priorityHints: AmbitionsCommandPriorityHints
    let goalRelationship: NowGoalPressureKind?
    let destinationRoute: String?
    let explanationID: String?
    let metadata: [String: String]

    init(
        rawText: String? = nil,
        title: String? = nil,
        notes: String? = nil,
        dueText: String? = nil,
        deadlineText: String? = nil,
        contextLens: NowContextLens? = nil,
        commitmentKind: NowCommitmentKind? = nil,
        priorityHints: AmbitionsCommandPriorityHints = AmbitionsCommandPriorityHints(),
        goalRelationship: NowGoalPressureKind? = nil,
        destinationRoute: String? = nil,
        explanationID: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.rawText = Self.trimmed(rawText)
        self.title = Self.trimmed(title)
        self.notes = Self.trimmed(notes)
        self.dueText = Self.trimmed(dueText)
        self.deadlineText = Self.trimmed(deadlineText)
        self.contextLens = contextLens
        self.commitmentKind = commitmentKind
        self.priorityHints = priorityHints
        self.goalRelationship = goalRelationship
        self.destinationRoute = Self.trimmed(destinationRoute)
        self.explanationID = Self.trimmed(explanationID)
        self.metadata = metadata.filter { $0.key.isEmpty == false && $0.value.isEmpty == false }
    }

    var primaryText: String? {
        rawText ?? title
    }

    private static func trimmed(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

enum AmbitionsCommandValidationState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case valid
    case invalid
    case needsConfirmation = "needs_confirmation"
    case needsMissingTarget = "needs_missing_target"
    case unsupportedInThisBuild = "unsupported_in_this_build"
    case blockedByMissingFoundation = "blocked_by_missing_foundation"
}

enum AmbitionsCommandExecutionStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case pending
    case succeeded
    case failed
    case noOp = "no_op"
    case queued
    case requiresConfirmation = "requires_confirmation"
    case unsupported
    case blocked
}

struct AmbitionsCommandExecutionResult: Codable, Sendable, Equatable, Hashable {
    let status: AmbitionsCommandExecutionStatus
    let summary: String
    let route: AmbitionsCommandDestination?
    let target: AmbitionsCommandTarget?
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let metadata: [String: String]

    init(
        status: AmbitionsCommandExecutionStatus,
        summary: String,
        route: AmbitionsCommandDestination? = nil,
        target: AmbitionsCommandTarget? = nil,
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = [],
        metadata: [String: String] = [:]
    ) {
        self.status = status
        self.summary = summary
        self.route = route
        self.target = target
        self.eventLedgerEntryIDs = Array(Set(eventLedgerEntryIDs.filter { $0.isEmpty == false })).sorted()
        self.recommendationExplanationIDs = Array(Set(recommendationExplanationIDs.filter { $0.isEmpty == false })).sorted()
        self.metadata = metadata.filter { $0.key.isEmpty == false && $0.value.isEmpty == false }
    }
}

struct AmbitionsCommand: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: AmbitionsCommandKind
    let source: AmbitionsCommandSource
    let target: AmbitionsCommandTarget
    let payload: AmbitionsCommandPayload
    let validationState: AmbitionsCommandValidationState
    let executionStatus: AmbitionsCommandExecutionStatus
    let result: AmbitionsCommandExecutionResult?
    let createdAt: String
    let requestedAt: String
    let actor: AmbitionsCommandActor
    let sourceSurface: String?
    let relations: AmbitionsCommandRelations
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let schemaVersion: String

    init(
        id: String,
        kind: AmbitionsCommandKind,
        source: AmbitionsCommandSource,
        target: AmbitionsCommandTarget = AmbitionsCommandTarget(),
        payload: AmbitionsCommandPayload = AmbitionsCommandPayload(),
        validationState: AmbitionsCommandValidationState = .valid,
        executionStatus: AmbitionsCommandExecutionStatus = .pending,
        result: AmbitionsCommandExecutionResult? = nil,
        createdAt: String,
        requestedAt: String? = nil,
        actor: AmbitionsCommandActor = .user,
        sourceSurface: String? = nil,
        relations: AmbitionsCommandRelations = AmbitionsCommandRelations(),
        localOnly: Bool = true,
        privacy: EventLedgerPrivacyClassification = .standard,
        schemaVersion: String = ambitionsCommandSchemaVersion
    ) {
        self.id = id
        self.kind = kind
        self.source = source
        self.target = target
        self.payload = payload
        self.validationState = validationState
        self.executionStatus = executionStatus
        self.result = result
        self.createdAt = createdAt
        self.requestedAt = requestedAt ?? createdAt
        self.actor = actor
        self.sourceSurface = sourceSurface
        self.relations = relations
        self.localOnly = localOnly
        self.privacy = privacy
        self.schemaVersion = schemaVersion
    }

    func validated(as state: AmbitionsCommandValidationState) -> AmbitionsCommand {
        AmbitionsCommand(
            id: id,
            kind: kind,
            source: source,
            target: target,
            payload: payload,
            validationState: state,
            executionStatus: executionStatus,
            result: result,
            createdAt: createdAt,
            requestedAt: requestedAt,
            actor: actor,
            sourceSurface: sourceSurface,
            relations: relations,
            localOnly: localOnly,
            privacy: privacy,
            schemaVersion: schemaVersion
        )
    }
}

struct AmbitionsCommandValidator: Sendable {
    func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        switch command.kind {
        case .quickCapture:
            return command.payload.primaryText == nil ? .invalid : .valid
        case .openDestination:
            return command.target.destination == nil ? .needsMissingTarget : .valid
        case .createGoal:
            return command.payload.primaryText == nil ? .needsConfirmation : .valid
        case .updateGoal:
            return command.target.goalID == nil ? .needsMissingTarget : .valid
        case .attachToGoal:
            return command.target.goalID == nil || command.target.captureID == nil ? .needsMissingTarget : .valid
        case .createPlanItem:
            return command.payload.primaryText == nil ? .needsConfirmation : .valid
        case .scheduleItem:
            if command.payload.metadata["calendarWriteIntent"] == "true",
               command.payload.metadata["userConfirmed"] != "true" {
                return .needsConfirmation
            }
            return command.target.captureID == nil && command.target.planID == nil && command.payload.primaryText == nil ? .needsMissingTarget : .valid
        case .startFocus, .completeAction, .delayAction, .splitAction:
            return command.target.goalID == nil || command.target.stepID == nil ? .needsMissingTarget : .valid
        case .recoverAction:
            return command.target.goalID == nil && command.target.captureID == nil && command.target.planID == nil ? .needsMissingTarget : .valid
        case .markWaiting, .archiveItem:
            return command.target.captureID == nil && command.target.goalID == nil && command.target.planID == nil ? .needsMissingTarget : .valid
        case .setPriority:
            return command.payload.priorityHints.hasAnySignal == false ? .invalid : targetBacked(command)
        case .setUrgency:
            return command.payload.priorityHints.urgency == nil ? .invalid : targetBacked(command)
        case .setDeadline:
            return command.payload.deadlineText == nil && command.payload.priorityHints.deadline == nil ? .invalid : targetBacked(command)
        case .setContextLens:
            return command.payload.contextLens == nil ? .invalid : .valid
        case .clearContextLensOverride:
            return .valid
        case .routeCommitment:
            return command.payload.primaryText == nil && command.target.captureID == nil ? .invalid : .valid
        case .addDeliverable:
            return command.target.goalID == nil || command.payload.title == nil ? .needsMissingTarget : .valid
        case .removeDeliverable:
            return command.target.goalID == nil || command.target.deliverableID == nil ? .needsMissingTarget : .valid
        case .addGoalScopeItem:
            return command.target.goalID == nil || command.payload.title == nil ? .needsMissingTarget : .valid
        case .removeGoalScopeItem:
            return command.target.goalID == nil || command.target.scopeItemID == nil ? .needsMissingTarget : .valid
        case .askWhy:
            return command.target.explanationID == nil && command.target.destination == nil ? .needsMissingTarget : .valid
        case .dismissRecommendation:
            return command.target.recommendationID == nil && command.target.explanationID == nil ? .needsMissingTarget : .valid
        }
    }

    private func targetBacked(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        command.target.goalID == nil && command.target.captureID == nil && command.target.planID == nil
            ? .needsMissingTarget
            : .valid
    }
}

extension AmbitionsCommand {
    static func fromNowAction(
        _ action: NowAction,
        source: AmbitionsCommandSource = .today,
        id: String = DomainIdentifier.prefixed("command"),
        createdAt: String
    ) -> AmbitionsCommand {
        let kind: AmbitionsCommandKind
        let destination: AmbitionsCommandDestination?
        switch action.kind {
        case .none:
            kind = .openDestination
            destination = .today
        case .focus:
            kind = .startFocus
            destination = nil
        case .completeAction:
            kind = .completeAction
            destination = nil
        case .openGoal:
            kind = .openDestination
            destination = .goalDetail
        case .openPlan, .schedule:
            kind = .openDestination
            destination = .plan
        case .capture:
            kind = .openDestination
            destination = .capture
        case .recover:
            kind = .recoverAction
            destination = nil
        case .review:
            kind = .openDestination
            destination = .reviews
        case .wait:
            kind = .markWaiting
            destination = nil
        case .routeCommitment:
            kind = .routeCommitment
            destination = nil
        case .explain:
            kind = .askWhy
            destination = nil
        }

        let command = AmbitionsCommand(
            id: id,
            kind: kind,
            source: source,
            target: AmbitionsCommandTarget(
                goalID: action.reference?.goalID,
                captureID: action.reference?.captureID,
                planID: action.reference?.planID,
                reviewID: action.reference?.reviewID,
                stepID: action.reference?.stepID,
                explanationID: action.explanationID,
                destination: destination
            ),
            payload: AmbitionsCommandPayload(
                title: action.title,
                notes: action.subtitle,
                contextLens: action.contextLens,
                commitmentKind: action.commitmentKind,
                explanationID: action.explanationID
            ),
            createdAt: createdAt,
            relations: AmbitionsCommandRelations(
                goalIDs: [action.reference?.goalID].compactMap { $0 },
                captureIDs: [action.reference?.captureID].compactMap { $0 },
                planIDs: [action.reference?.planID].compactMap { $0 },
                reviewIDs: [action.reference?.reviewID].compactMap { $0 },
                eventLedgerEntryIDs: action.eventLedgerEntryIDs,
                recommendationExplanationIDs: [action.explanationID].compactMap { $0 }
            )
        )
        return command.validated(as: AmbitionsCommandValidator().validate(command))
    }
}
