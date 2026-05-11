import Foundation

enum CaptureSourceType: String, Codable, Sendable, Equatable, CaseIterable {
    case todayQuickCapture = "today_quick_capture"
    case notification = "notification"
    case shareExtensionText = "share_extension_text"
    case shareExtensionURL = "share_extension_url"
    case appIntent = "app_intent"

    var title: String {
        switch self {
        case .todayQuickCapture:
            return "Today quick capture"
        case .notification:
            return "Notification"
        case .shareExtensionText:
            return "Share extension text"
        case .shareExtensionURL:
            return "Share extension URL"
        case .appIntent:
            return "App Intent"
        }
    }
}

enum CaptureStatus: String, Codable, Sendable, Equatable, CaseIterable {
    case needsTriage = "needs_triage"
    case seed
    case actionable
    case goalBound = "goal_bound"
    case scheduled
    case delegated
    case waiting
    case optionalSomeday = "optional_someday"
    case archived

    var title: String {
        switch self {
        case .needsTriage:
            return "Needs triage"
        case .seed:
            return "Seed"
        case .actionable:
            return "Actionable"
        case .goalBound:
            return "Goal-bound"
        case .scheduled:
            return "Scheduled"
        case .delegated:
            return "Delegated"
        case .waiting:
            return "Waiting"
        case .optionalSomeday:
            return "Optional / Someday"
        case .archived:
            return "Archived"
        }
    }

    func canTransition(to next: CaptureStatus) -> Bool {
        guard self != next else { return true }

        switch self {
        case .needsTriage:
            return next == .seed || next == .actionable || next == .goalBound || next == .scheduled || next == .delegated || next == .waiting || next == .optionalSomeday || next == .archived
        case .seed:
            return next == .actionable || next == .goalBound || next == .scheduled || next == .waiting || next == .optionalSomeday || next == .archived
        case .actionable:
            return next == .needsTriage || next == .seed || next == .goalBound || next == .scheduled || next == .delegated || next == .waiting || next == .optionalSomeday || next == .archived
        case .goalBound, .scheduled, .delegated, .waiting, .optionalSomeday:
            return next == .needsTriage || next == .seed || next == .actionable || next == .goalBound || next == .scheduled || next == .delegated || next == .waiting || next == .optionalSomeday || next == .archived
        case .archived:
            return false
        }
    }
}

enum CaptureTriageDestination: String, Codable, Sendable, Equatable, CaseIterable {
    case needsTriage = "needs_triage"
    case planSeed = "plan_seed"
    case doSoon = "do_soon"
    case turnIntoGoal = "turn_into_goal"
    case attachToGoal = "attach_to_goal"
    case saveAsSeed = "save_as_seed"
    case waiting
    case optionalSomeday = "optional_someday"
    case deliverableSeed = "deliverable_seed"
    case archive

    var title: String {
        switch self {
        case .needsTriage:
            return "Needs triage"
        case .planSeed:
            return "Plan idea"
        case .doSoon:
            return "Do soon"
        case .turnIntoGoal:
            return "Turn into goal"
        case .attachToGoal:
            return "Attach to goal"
        case .saveAsSeed:
            return "Save as seed"
        case .waiting:
            return "Waiting"
        case .optionalSomeday:
            return "Optional / Someday"
        case .deliverableSeed:
            return "Deliverable seed"
        case .archive:
            return "Archive"
        }
    }
}

enum CaptureKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case raw
    case oneTimeCommitment = "one_time_commitment"
    case deadlineTask = "deadline_task"
    case goalSeed = "goal_seed"
    case goalSupportingTask = "goal_supporting_task"
    case deliverableSeed = "deliverable_seed"
    case waitingItem = "waiting_item"
    case optionalSomeday = "optional_someday"
    case archiveItem = "archive_item"

    var title: String {
        switch self {
        case .raw: "Raw capture"
        case .oneTimeCommitment: "One-time commitment"
        case .deadlineTask: "Deadline task"
        case .goalSeed: "Goal seed"
        case .goalSupportingTask: "Goal-supporting task"
        case .deliverableSeed: "Deliverable seed"
        case .waitingItem: "Waiting item"
        case .optionalSomeday: "Optional / Someday"
        case .archiveItem: "Archive item"
        }
    }
}

enum CaptureTriageStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case needsTriage = "needs_triage"
    case assumedRoute = "assumed_route"
    case userCorrected = "user_corrected"
    case routed
    case waiting
    case archived

    var title: String {
        switch self {
        case .needsTriage: "Needs triage"
        case .assumedRoute: "Assumed route"
        case .userCorrected: "User corrected"
        case .routed: "Routed"
        case .waiting: "Waiting"
        case .archived: "Archived"
        }
    }
}

enum CaptureRoute: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case captureInbox = "capture_inbox"
    case planSeed = "plan_seed"
    case goalSeed = "goal_seed"
    case goalAttachment = "goal_attachment"
    case deliverableSeed = "deliverable_seed"
    case proofItem = "proof_item"
    case constraintItem = "constraint_item"
    case waiting
    case optionalSomeday = "optional_someday"
    case archive

    var title: String {
        switch self {
        case .captureInbox: "Capture"
        case .planSeed: "Plan idea"
        case .goalSeed: "Goal seed"
        case .goalAttachment: "Attach to goal"
        case .deliverableSeed: "Deliverable seed"
        case .proofItem: "Proof"
        case .constraintItem: "Constraint"
        case .waiting: "Waiting"
        case .optionalSomeday: "Optional / Someday"
        case .archive: "Archive"
        }
    }

    var triageDestination: CaptureTriageDestination {
        switch self {
        case .captureInbox: .needsTriage
        case .planSeed: .planSeed
        case .goalSeed: .turnIntoGoal
        case .goalAttachment: .attachToGoal
        case .deliverableSeed: .deliverableSeed
        case .proofItem, .constraintItem: .deliverableSeed
        case .waiting: .waiting
        case .optionalSomeday: .optionalSomeday
        case .archive: .archive
        }
    }
}

enum CaptureDeadlineKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case soft
    case hard
    case flexible
}

enum CaptureCorrectionAction: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case changeRoute = "change_route"
    case changeDeadline = "change_deadline"
    case attachToGoal = "attach_to_goal"
    case markWaiting = "mark_waiting"
    case markOptionalSomeday = "mark_optional_someday"
    case archive
}

struct CapturePriorityHints: Codable, Sendable, Equatable, Hashable {
    let importance: NowPressureLevel?
    let urgency: NowPressureLevel?
    let consequence: NowPressureLevel?
    let deadline: NowPressureLevel?
    let effort: NowPressureLevel?
    let contextFit: NowPressureLevel?
    let optionalSomeday: Bool
    let passive: Bool
    let goalSupporting: Bool

    init(
        importance: NowPressureLevel? = nil,
        urgency: NowPressureLevel? = nil,
        consequence: NowPressureLevel? = nil,
        deadline: NowPressureLevel? = nil,
        effort: NowPressureLevel? = nil,
        contextFit: NowPressureLevel? = nil,
        optionalSomeday: Bool = false,
        passive: Bool = false,
        goalSupporting: Bool = false
    ) {
        self.importance = importance
        self.urgency = urgency
        self.consequence = consequence
        self.deadline = deadline
        self.effort = effort
        self.contextFit = contextFit
        self.optionalSomeday = optionalSomeday
        self.passive = passive
        self.goalSupporting = goalSupporting
    }
}

struct CaptureGoalRelationship: Codable, Sendable, Equatable, Hashable {
    let goalID: String?
    let relationshipKind: NowGoalPressureKind?
    let note: String?

    init(goalID: String? = nil, relationshipKind: NowGoalPressureKind? = nil, note: String? = nil) {
        self.goalID = goalID
        self.relationshipKind = relationshipKind
        self.note = note
    }
}

struct CaptureWaitingMetadata: Codable, Sendable, Equatable, Hashable {
    let blockedBy: String?
    let waitingOn: String?
    let followUpText: String?

    init(blockedBy: String? = nil, waitingOn: String? = nil, followUpText: String? = nil) {
        self.blockedBy = blockedBy
        self.waitingOn = waitingOn
        self.followUpText = followUpText
    }
}

struct CaptureTriageMetadata: Codable, Sendable, Equatable {
    let destination: CaptureTriageDestination?
    let hint: String?

    init(destination: CaptureTriageDestination? = nil, hint: String? = nil) {
        self.destination = destination
        self.hint = hint
    }
}

struct Capture: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let rawText: String
    let sourceType: CaptureSourceType?
    let status: CaptureStatus
    let linkedGoalID: String?
    let triage: CaptureTriageMetadata?
    let revisitAfter: String?
    let kind: CaptureKind
    let route: CaptureRoute
    let triageStatus: CaptureTriageStatus
    let commitmentKind: NowCommitmentKind?
    let deadlineText: String?
    let deadlineKind: CaptureDeadlineKind
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints
    let goalRelationship: CaptureGoalRelationship?
    let deliverableHint: String?
    let scopeItemHint: String?
    let waitingMetadata: CaptureWaitingMetadata?
    let assumptionSummary: String?
    let correctionActions: [CaptureCorrectionAction]
    let recommendationExplanationIDs: [String]
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification

    init(
        id: String,
        createdAt: String,
        updatedAt: String,
        rawText: String,
        sourceType: CaptureSourceType?,
        status: CaptureStatus,
        linkedGoalID: String?,
        triage: CaptureTriageMetadata? = nil,
        revisitAfter: String? = nil,
        kind: CaptureKind = .raw,
        route: CaptureRoute = .captureInbox,
        triageStatus: CaptureTriageStatus = .needsTriage,
        commitmentKind: NowCommitmentKind? = nil,
        deadlineText: String? = nil,
        deadlineKind: CaptureDeadlineKind = .none,
        contextLensHint: NowContextLens? = nil,
        priorityHints: CapturePriorityHints = CapturePriorityHints(),
        goalRelationship: CaptureGoalRelationship? = nil,
        deliverableHint: String? = nil,
        scopeItemHint: String? = nil,
        waitingMetadata: CaptureWaitingMetadata? = nil,
        assumptionSummary: String? = nil,
        correctionActions: [CaptureCorrectionAction] = [.changeRoute, .changeDeadline, .attachToGoal, .markWaiting, .markOptionalSomeday, .archive],
        recommendationExplanationIDs: [String] = [],
        localOnly: Bool = true,
        privacy: EventLedgerPrivacyClassification = .privateUserText
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.rawText = rawText
        self.sourceType = sourceType
        self.status = status
        self.linkedGoalID = linkedGoalID
        self.triage = triage
        self.revisitAfter = revisitAfter
        self.kind = kind
        self.route = route
        self.triageStatus = triageStatus
        self.commitmentKind = commitmentKind
        self.deadlineText = deadlineText
        self.deadlineKind = deadlineKind
        self.contextLensHint = contextLensHint
        self.priorityHints = priorityHints
        self.goalRelationship = goalRelationship
        self.deliverableHint = deliverableHint
        self.scopeItemHint = scopeItemHint
        self.waitingMetadata = waitingMetadata
        self.assumptionSummary = assumptionSummary
        self.correctionActions = Array(Set(correctionActions)).sorted { $0.rawValue < $1.rawValue }
        self.recommendationExplanationIDs = Array(Set(recommendationExplanationIDs.filter { $0.isEmpty == false })).sorted()
        self.localOnly = localOnly
        self.privacy = privacy
    }
}

extension Capture {
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case rawText
        case sourceType
        case status
        case linkedGoalID
        case triage
        case revisitAfter
        case kind
        case route
        case triageStatus
        case commitmentKind
        case deadlineText
        case deadlineKind
        case contextLensHint
        case priorityHints
        case goalRelationship
        case deliverableHint
        case scopeItemHint
        case waitingMetadata
        case assumptionSummary
        case correctionActions
        case recommendationExplanationIDs
        case localOnly
        case privacy
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        rawText = try container.decode(String.self, forKey: .rawText)
        sourceType = try container.decodeIfPresent(CaptureSourceType.self, forKey: .sourceType)
        status = try container.decode(CaptureStatus.self, forKey: .status)
        linkedGoalID = try container.decodeIfPresent(String.self, forKey: .linkedGoalID)
        triage = try container.decodeIfPresent(CaptureTriageMetadata.self, forKey: .triage)
        revisitAfter = try container.decodeIfPresent(String.self, forKey: .revisitAfter)
        kind = try container.decodeIfPresent(CaptureKind.self, forKey: .kind) ?? Self.defaultKind(for: status)
        route = try container.decodeIfPresent(CaptureRoute.self, forKey: .route) ?? Self.defaultRoute(for: status, triage: triage)
        triageStatus = try container.decodeIfPresent(CaptureTriageStatus.self, forKey: .triageStatus) ?? Self.defaultTriageStatus(for: status)
        commitmentKind = try container.decodeIfPresent(NowCommitmentKind.self, forKey: .commitmentKind)
        deadlineText = try container.decodeIfPresent(String.self, forKey: .deadlineText)
        deadlineKind = try container.decodeIfPresent(CaptureDeadlineKind.self, forKey: .deadlineKind) ?? .none
        contextLensHint = try container.decodeIfPresent(NowContextLens.self, forKey: .contextLensHint)
        priorityHints = try container.decodeIfPresent(CapturePriorityHints.self, forKey: .priorityHints) ?? CapturePriorityHints()
        goalRelationship = try container.decodeIfPresent(CaptureGoalRelationship.self, forKey: .goalRelationship)
        deliverableHint = try container.decodeIfPresent(String.self, forKey: .deliverableHint)
        scopeItemHint = try container.decodeIfPresent(String.self, forKey: .scopeItemHint)
        waitingMetadata = try container.decodeIfPresent(CaptureWaitingMetadata.self, forKey: .waitingMetadata)
        assumptionSummary = try container.decodeIfPresent(String.self, forKey: .assumptionSummary)
        correctionActions = try container.decodeIfPresent([CaptureCorrectionAction].self, forKey: .correctionActions) ?? [.changeRoute, .changeDeadline, .attachToGoal, .markWaiting, .markOptionalSomeday, .archive]
        recommendationExplanationIDs = try container.decodeIfPresent([String].self, forKey: .recommendationExplanationIDs) ?? []
        localOnly = try container.decodeIfPresent(Bool.self, forKey: .localOnly) ?? true
        privacy = try container.decodeIfPresent(EventLedgerPrivacyClassification.self, forKey: .privacy) ?? .privateUserText
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(rawText, forKey: .rawText)
        try container.encodeIfPresent(sourceType, forKey: .sourceType)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(linkedGoalID, forKey: .linkedGoalID)
        try container.encodeIfPresent(triage, forKey: .triage)
        try container.encodeIfPresent(revisitAfter, forKey: .revisitAfter)
        try container.encode(kind, forKey: .kind)
        try container.encode(route, forKey: .route)
        try container.encode(triageStatus, forKey: .triageStatus)
        try container.encodeIfPresent(commitmentKind, forKey: .commitmentKind)
        try container.encodeIfPresent(deadlineText, forKey: .deadlineText)
        try container.encode(deadlineKind, forKey: .deadlineKind)
        try container.encodeIfPresent(contextLensHint, forKey: .contextLensHint)
        try container.encode(priorityHints, forKey: .priorityHints)
        try container.encodeIfPresent(goalRelationship, forKey: .goalRelationship)
        try container.encodeIfPresent(deliverableHint, forKey: .deliverableHint)
        try container.encodeIfPresent(scopeItemHint, forKey: .scopeItemHint)
        try container.encodeIfPresent(waitingMetadata, forKey: .waitingMetadata)
        try container.encodeIfPresent(assumptionSummary, forKey: .assumptionSummary)
        try container.encode(correctionActions, forKey: .correctionActions)
        try container.encode(recommendationExplanationIDs, forKey: .recommendationExplanationIDs)
        try container.encode(localOnly, forKey: .localOnly)
        try container.encode(privacy, forKey: .privacy)
    }

    private static func defaultKind(for status: CaptureStatus) -> CaptureKind {
        switch status {
        case .needsTriage, .actionable: .raw
        case .seed: .goalSeed
        case .goalBound: .goalSupportingTask
        case .scheduled: .oneTimeCommitment
        case .delegated, .waiting: .waitingItem
        case .optionalSomeday: .optionalSomeday
        case .archived: .archiveItem
        }
    }

    private static func defaultRoute(for status: CaptureStatus, triage: CaptureTriageMetadata?) -> CaptureRoute {
        if let destination = triage?.destination {
            switch destination {
            case .needsTriage: return .captureInbox
            case .doSoon, .planSeed: return .planSeed
            case .turnIntoGoal: return .goalSeed
            case .attachToGoal: return .goalAttachment
            case .saveAsSeed: return .captureInbox
            case .waiting: return .waiting
            case .optionalSomeday: return .optionalSomeday
            case .deliverableSeed: return .deliverableSeed
            case .archive: return .archive
            }
        }

        switch status {
        case .needsTriage, .actionable, .seed:
            return .captureInbox
        case .goalBound:
            return .goalAttachment
        case .scheduled:
            return .planSeed
        case .delegated, .waiting:
            return .waiting
        case .optionalSomeday:
            return .optionalSomeday
        case .archived:
            return .archive
        }
    }

    private static func defaultTriageStatus(for status: CaptureStatus) -> CaptureTriageStatus {
        switch status {
        case .needsTriage, .actionable, .seed: .needsTriage
        case .waiting: .waiting
        case .archived: .archived
        case .goalBound, .scheduled, .delegated, .optionalSomeday: .routed
        }
    }
}
