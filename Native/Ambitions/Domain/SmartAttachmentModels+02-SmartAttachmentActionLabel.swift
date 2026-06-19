import Foundation

enum SmartAttachmentActionLabel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case change
    case keepStandalone = "keep_standalone"
    case attach
    case task
    case goal
    case idea
    case proof
    case waiting
    case plan
    case retry
    case copy

    var title: String {
        switch self {
        case .change: "Change"
        case .keepStandalone: "Keep Standalone"
        case .attach: "Attach"
        case .task: "Task"
        case .goal: "Goal"
        case .idea: "Idea"
        case .proof: "Proof"
        case .waiting: "Waiting"
        case .plan: "Plan"
        case .retry: "Retry"
        case .copy: "Copy"
        }
    }
}

enum SmartAttachmentPrivacyProjection: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fullDetail = "full_detail"
    case redacted
}

struct SmartAttachmentSourceContext: Codable, Sendable, Equatable, Hashable {
    let sourceType: CaptureSourceType?
    let sourceSurface: String?
    let commandID: String?

    init(sourceType: CaptureSourceType? = nil, sourceSurface: String? = nil, commandID: String? = nil) {
        self.sourceType = sourceType
        self.sourceSurface = Self.normalizedOptional(sourceSurface)
        self.commandID = Self.normalizedOptional(commandID)
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }
}

struct SmartAttachmentInput: Codable, Sendable, Equatable, Hashable {
    let rawText: String
    let sourceContext: SmartAttachmentSourceContext?

    init(rawText: String, sourceContext: SmartAttachmentSourceContext? = nil) {
        self.rawText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceContext = sourceContext
    }
}

struct SmartAttachmentRouteTarget: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let routeType: SmartAttachmentRouteType
    let destinationKind: SmartAttachmentDestinationKind
    let destinationID: String?
    let destinationLabel: String?
    let placementLabel: String?

    init(
        id: String,
        routeType: SmartAttachmentRouteType,
        destinationKind: SmartAttachmentDestinationKind,
        destinationID: String? = nil,
        destinationLabel: String? = nil,
        placementLabel: String? = nil
    ) {
        self.id = Self.normalizedRequired(id)
        self.routeType = routeType
        self.destinationKind = destinationKind
        self.destinationID = Self.normalizedOptional(destinationID)
        self.destinationLabel = Self.normalizedOptional(destinationLabel)
        self.placementLabel = Self.normalizedOptional(placementLabel)
    }

    var isNeedsPlace: Bool {
        destinationKind == .needsPlace
    }

    var displaySegments: [String] {
        if isNeedsPlace {
            return ["Needs a Place"]
        }

        if routeType == .proofItem {
            return [
                routeType.userFacingLabel,
                destinationLabel
            ].compactMap { value in
                guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
                      trimmed.isEmpty == false else {
                    return nil
                }
                return trimmed
            }
        }

        return [
            routeType.userFacingLabel,
            destinationLabel,
            placementLabel
        ].compactMap { value in
            guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
                  trimmed.isEmpty == false else {
                return nil
            }
            return trimmed
        }
    }

    var objectReference: LifeGraphObjectReference? {
        guard let destinationID else { return nil }
        return LifeGraphObjectReference(
            kind: lifeGraphKind,
            id: destinationID,
            label: destinationLabel,
            sourceDomain: lifeGraphSourceDomain
        )
    }

    var orderingKey: String {
        [
            routeType.rawValue,
            destinationKind.rawValue,
            destinationLabel?.lowercased() ?? "",
            destinationID ?? "",
            placementLabel?.lowercased() ?? "",
            id
        ].joined(separator: ":")
    }

    var lifeGraphKind: LifeGraphObjectKind {
        switch destinationKind {
        case .existingGoal:
            return .goal
        case .existingProofItem:
            return .proof
        case .existingWaitingItem:
            return .waitingItem
        case .existingPlan, .step:
            return .action
        case .milestone:
            return .milestone
        case .needsPlace, .lifeArea, .ambitionNorthStar, .path, .standalone:
            return .capture
        }
    }

    var lifeGraphSourceDomain: LifeGraphSourceDomain {
        switch destinationKind {
        case .existingGoal, .lifeArea, .ambitionNorthStar, .path, .milestone:
            return .goals
        case .existingPlan, .step:
            return .time
        case .existingProofItem:
            return .proof
        case .existingWaitingItem:
            return .commitment
        case .needsPlace, .standalone:
            return .capture
        }
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }
}

struct SmartAttachmentDestinationCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let label: String
    let destinationKind: SmartAttachmentDestinationKind
    let supportedRouteTypes: [SmartAttachmentRouteType]
    let placementLabel: String?
    let localOnly: Bool

    init(
        id: String,
        label: String,
        destinationKind: SmartAttachmentDestinationKind,
        supportedRouteTypes: [SmartAttachmentRouteType],
        placementLabel: String? = nil,
        localOnly: Bool = true
    ) {
        self.id = SmartAttachmentRouteTarget.normalizedRequired(id)
        self.label = SmartAttachmentRouteTarget.normalizedRequired(label)
        self.destinationKind = destinationKind
        self.supportedRouteTypes = Array(Set(supportedRouteTypes)).sorted { $0.rawValue < $1.rawValue }
        self.placementLabel = SmartAttachmentRouteTarget.normalizedOptional(placementLabel)
        self.localOnly = localOnly
    }

    var isUsable: Bool {
        id.isEmpty == false && label.isEmpty == false && supportedRouteTypes.isEmpty == false && localOnly
    }
}

struct SmartAttachmentCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let target: SmartAttachmentRouteTarget
    let score: Int
    let evidenceLabels: [String]
    let isSuggestedAttachment: Bool

    init(
        id: String,
        target: SmartAttachmentRouteTarget,
        score: Int,
        evidenceLabels: [String],
        isSuggestedAttachment: Bool = false
    ) {
        self.id = SmartAttachmentRouteTarget.normalizedRequired(id)
        self.target = target
        self.score = score
        self.evidenceLabels = Array(Set(evidenceLabels.map(SmartAttachmentRouteTarget.normalizedRequired).filter { $0.isEmpty == false })).sorted()
        self.isSuggestedAttachment = isSuggestedAttachment
    }

    var orderingKey: String {
        [
            String(format: "%05d", max(0, 10_000 - score)),
            target.orderingKey,
            id
        ].joined(separator: ":")
    }
}

struct SmartAttachmentClarificationChoice: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let actionLabel: SmartAttachmentActionLabel
    let routeType: SmartAttachmentRouteType
    let target: SmartAttachmentRouteTarget?

    init(
        id: String,
        actionLabel: SmartAttachmentActionLabel,
        routeType: SmartAttachmentRouteType,
        target: SmartAttachmentRouteTarget? = nil
    ) {
        self.id = SmartAttachmentRouteTarget.normalizedRequired(id)
        self.actionLabel = actionLabel
        self.routeType = routeType
        self.target = target
    }
}

struct SmartAttachmentClarification: Codable, Sendable, Equatable, Hashable {
    let question: String
    let choices: [SmartAttachmentClarificationChoice]

    init(question: String, choices: [SmartAttachmentClarificationChoice]) {
        self.question = SmartAttachmentRouteTarget.normalizedRequired(question)
        self.choices = Array(choices.prefix(3))
    }
}

struct SmartAttachmentReceiptProjection: Sendable, Equatable {
    let title: String
    let summary: String
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String?
    let actionTitles: [String]
    let privacyLevel: ActionReceiptPrivacyLevel
    let isRedacted: Bool
}

struct SmartAttachmentCaptureCluster: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let evidenceLabels: [String]
    let itemCount: Int

    init(id: String, title: String, summary: String, evidenceLabels: [String] = [], itemCount: Int = 1) {
        self.id = SmartAttachmentRouteTarget.normalizedRequired(id)
        self.title = SmartAttachmentRouteTarget.normalizedRequired(title)
        self.summary = SmartAttachmentRouteTarget.normalizedRequired(summary)
        self.evidenceLabels = Array(Set(evidenceLabels.map(SmartAttachmentRouteTarget.normalizedRequired).filter { $0.isEmpty == false })).sorted()
        self.itemCount = max(1, itemCount)
    }
}

struct SmartAttachmentOpenLoopSignal: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let reason: String
    let requiresUserChoice: Bool

    init(id: String, title: String, reason: String, requiresUserChoice: Bool) {
        self.id = SmartAttachmentRouteTarget.normalizedRequired(id)
        self.title = SmartAttachmentRouteTarget.normalizedRequired(title)
        self.reason = SmartAttachmentRouteTarget.normalizedRequired(reason)
        self.requiresUserChoice = requiresUserChoice
    }
}

struct SmartAttachmentReviewBundle: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let clusters: [SmartAttachmentCaptureCluster]
    let openLoopSignals: [SmartAttachmentOpenLoopSignal]
    let actionTitles: [String]
    let accessibilitySummary: String

    init(
        id: String,
        title: String,
        summary: String,
        clusters: [SmartAttachmentCaptureCluster],
        openLoopSignals: [SmartAttachmentOpenLoopSignal],
        actionTitles: [String],
        accessibilitySummary: String
    ) {
        self.id = SmartAttachmentRouteTarget.normalizedRequired(id)
        self.title = SmartAttachmentRouteTarget.normalizedRequired(title)
        self.summary = SmartAttachmentRouteTarget.normalizedRequired(summary)
        self.clusters = clusters
        self.openLoopSignals = openLoopSignals
        self.actionTitles = actionTitles.map(SmartAttachmentRouteTarget.normalizedRequired).filter { $0.isEmpty == false }
        self.accessibilitySummary = SmartAttachmentRouteTarget.normalizedRequired(accessibilitySummary)
    }
}

struct SmartAttachmentReclassificationProjection: Sendable, Equatable, Hashable {
    let receiptTitle: String
    let undoAvailability: ActionReceiptUndoAvailability
    let undoSummary: String
    let correctionAvailability: ActionReceiptCorrectionAvailability
    let reclassificationActions: [String]
    let rollbackSummary: String
    let accessibilitySummary: String
}
