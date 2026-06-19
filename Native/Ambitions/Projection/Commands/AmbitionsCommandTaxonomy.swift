import Foundation

enum AmbitionsCommandKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case openDestination = "open_destination"
    case quickCapture = "quick_capture"
    case createGoal = "create_goal"
    case updateGoal = "update_goal"
    case attachToGoal = "attach_to_goal"
    case createTimeItem = "create_time_item"
    case scheduleItem = "schedule_item"
    case startStepSession = "start_focus"
    case completeAction = "complete_action"
    case delayAction = "delay_action"
    case splitAction = "split_action"
    case recoverAction = "recover_action"
    case markWaiting = "mark_waiting"
    case archiveItem = "archive_item"
    case prepareExport = "prepare_export"
    case performExport = "perform_export"
    case deleteObject = "delete_object"
    case forgetMemory = "forget_memory"
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
    case time
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
    case time
    case you
    case reviews
    case goalDetail = "goal_detail"
    case captureInbox = "capture_composer"
    case memoryLens = "memory_lens"
    case commandSheet = "command_sheet"
    case weeklyReview = "weekly_review"
}

struct AmbitionsCommandRelations: Codable, Sendable, Equatable, Hashable {
    let goalIDs: [String]
    let captureIDs: [String]
    let timeIDs: [String]
    let reviewIDs: [String]
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]

    init(
        goalIDs: [String] = [],
        captureIDs: [String] = [],
        timeIDs: [String] = [],
        reviewIDs: [String] = [],
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = []
    ) {
        self.goalIDs = Self.normalized(goalIDs)
        self.captureIDs = Self.normalized(captureIDs)
        self.timeIDs = Self.normalized(timeIDs)
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
    let timeID: String?
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
        timeID: String? = nil,
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
        self.timeID = Self.nonEmpty(timeID)
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
