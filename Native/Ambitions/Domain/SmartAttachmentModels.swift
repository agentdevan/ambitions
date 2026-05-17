import Foundation

let smartAttachmentSchemaVersion = "smart_attachment.native.v1"

enum SmartAttachmentRouteType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case task
    case goal
    case idea
    case proofItem = "proof_item"
    case waitingItem = "waiting_item"
    case plan
    case contextualNote = "contextual_note"
    case reminder
    case ritual
    case archive
    case decision

    var isLaunchCoreRoute: Bool {
        switch self {
        case .task, .goal, .idea, .proofItem, .waitingItem, .plan:
            return true
        case .contextualNote, .reminder, .ritual, .archive, .decision:
            return false
        }
    }

    var userFacingLabel: String {
        switch self {
        case .task: "Task"
        case .goal: "Goal"
        case .idea: "Idea"
        case .proofItem: "Proof"
        case .waitingItem: "Waiting"
        case .plan: "Plan"
        case .contextualNote: "Contextual Note"
        case .reminder: "Reminder"
        case .ritual: "Ritual"
        case .archive: "Archive"
        case .decision: "Decision"
        }
    }

    var captureKind: CaptureKind {
        switch self {
        case .task:
            return .oneTimeCommitment
        case .goal:
            return .goalSeed
        case .idea, .contextualNote:
            return .raw
        case .proofItem:
            return .goalSupportingTask
        case .waitingItem:
            return .waitingItem
        case .plan:
            return .oneTimeCommitment
        case .reminder:
            return .deadlineTask
        case .ritual:
            return .optionalSomeday
        case .archive:
            return .archiveItem
        case .decision:
            return .deliverableSeed
        }
    }

    var captureRoute: CaptureRoute {
        switch self {
        case .task, .plan, .reminder:
            return .timeSeed
        case .goal:
            return .goalSeed
        case .idea, .contextualNote:
            return .captureInbox
        case .proofItem:
            return .goalAttachment
        case .waitingItem:
            return .waiting
        case .ritual:
            return .optionalSomeday
        case .archive:
            return .archive
        case .decision:
            return .deliverableSeed
        }
    }
}

enum SmartAttachmentDestinationKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case needsPlace = "needs_place"
    case lifeArea = "life_area"
    case ambitionNorthStar = "ambition_north_star"
    case path
    case milestone
    case step
    case existingGoal = "existing_goal"
    case existingPlan = "existing_plan"
    case existingProofItem = "existing_proof_item"
    case existingWaitingItem = "existing_waiting_item"
    case standalone

    var userFacingLabel: String {
        switch self {
        case .needsPlace: "Needs a Place"
        case .lifeArea: "Life Area"
        case .ambitionNorthStar: "Ambition"
        case .path: "Path"
        case .milestone: "Milestone"
        case .step: "Step"
        case .existingGoal: "Goal"
        case .existingPlan: "Plan"
        case .existingProofItem: "Proof"
        case .existingWaitingItem: "Waiting"
        case .standalone: "Standalone"
        }
    }
}

enum SmartAttachmentConfidenceBand: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case high
    case medium
    case low
    case needsClarification = "needs_clarification"
    case unavailableFailed = "unavailable_failed"

    var userFacingLabel: String {
        switch self {
        case .high: "High"
        case .medium: "Medium"
        case .low: "Low"
        case .needsClarification: "Needs Clarification"
        case .unavailableFailed: "Unavailable"
        }
    }
}

enum SmartAttachmentResultState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case savedStandalone = "saved_standalone"
    case attached
    case savedToNeedsPlace = "saved_to_needs_place"
    case needsClarification = "needs_clarification"
    case failedSafely = "failed_safely"
}

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

    private static func normalizedOptional(_ value: String?) -> String? {
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

    fileprivate var orderingKey: String {
        [
            routeType.rawValue,
            destinationKind.rawValue,
            destinationLabel?.lowercased() ?? "",
            destinationID ?? "",
            placementLabel?.lowercased() ?? "",
            id
        ].joined(separator: ":")
    }

    private var lifeGraphKind: LifeGraphObjectKind {
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

    private var lifeGraphSourceDomain: LifeGraphSourceDomain {
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

    fileprivate static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    fileprivate static func normalizedOptional(_ value: String?) -> String? {
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

struct SmartAttachmentResult: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let input: SmartAttachmentInput
    let resultState: SmartAttachmentResultState
    let confidence: SmartAttachmentConfidenceBand
    let selectedCandidate: SmartAttachmentCandidate?
    let suggestedCandidate: SmartAttachmentCandidate?
    let clarification: SmartAttachmentClarification?
    let receiptLine: String
    let explanation: String?
    let actions: [SmartAttachmentActionLabel]
    let privacyLevel: ActionReceiptPrivacyLevel
    let failureReason: String?
    let schemaVersion: String

    init(
        id: String,
        input: SmartAttachmentInput,
        resultState: SmartAttachmentResultState,
        confidence: SmartAttachmentConfidenceBand,
        selectedCandidate: SmartAttachmentCandidate? = nil,
        suggestedCandidate: SmartAttachmentCandidate? = nil,
        clarification: SmartAttachmentClarification? = nil,
        receiptLine: String,
        explanation: String? = nil,
        actions: [SmartAttachmentActionLabel],
        privacyLevel: ActionReceiptPrivacyLevel = .privateItem,
        failureReason: String? = nil,
        schemaVersion: String = smartAttachmentSchemaVersion
    ) {
        self.id = SmartAttachmentRouteTarget.normalizedRequired(id)
        self.input = input
        self.resultState = resultState
        self.confidence = confidence
        self.selectedCandidate = selectedCandidate
        self.suggestedCandidate = suggestedCandidate
        self.clarification = clarification
        self.receiptLine = SmartAttachmentRouteTarget.normalizedRequired(receiptLine)
        self.explanation = SmartAttachmentRouteTarget.normalizedOptional(explanation)
        self.actions = Array(Set(actions)).sorted { $0.rawValue < $1.rawValue }
        self.privacyLevel = privacyLevel
        self.failureReason = SmartAttachmentRouteTarget.normalizedOptional(failureReason)
        self.schemaVersion = schemaVersion
    }

    var captureKind: CaptureKind {
        selectedCandidate?.target.routeType.captureKind ?? .raw
    }

    var captureRoute: CaptureRoute {
        selectedCandidate?.target.routeType.captureRoute ?? .captureInbox
    }

    var triageStatus: CaptureTriageStatus {
        switch confidence {
        case .high, .medium:
            return .assumedRoute
        case .low, .needsClarification, .unavailableFailed:
            return .needsTriage
        }
    }

    var savesToNeedsPlace: Bool {
        resultState == .savedToNeedsPlace || selectedCandidate?.target.isNeedsPlace == true
    }

    var captureAssumptionSummary: String {
        if savesToNeedsPlace {
            return "Saved to Needs a Place because the route was not safe to infer."
        }
        if let explanation {
            return explanation
        }
        return "Smart Attachment chose a conservative local route."
    }

    func receiptProjection(detail: SmartAttachmentPrivacyProjection) -> SmartAttachmentReceiptProjection {
        let shouldRedact = detail == .redacted || privacyLevel.requiresRedactionByDefault
        let redactedTitle = privacyLevel == .unavailable ? "Detail hidden" : "Private item"
        let title = shouldRedact ? redactedTitle : receiptLine
        let summary = shouldRedact ? redactedTitle : (explanation ?? receiptLine)
        let accessibilityValue = shouldRedact ? "Detail hidden" : "\(confidence.userFacingLabel). \(receiptLine)"

        return SmartAttachmentReceiptProjection(
            title: title,
            summary: summary,
            accessibilityLabel: "Smart Attachment result",
            accessibilityValue: accessibilityValue,
            accessibilityHint: actions.isEmpty ? nil : actions.map(\.title).joined(separator: ", "),
            actionTitles: actions.map(\.title),
            privacyLevel: shouldRedact ? .redacted : privacyLevel,
            isRedacted: shouldRedact
        )
    }

    func actionReceipt(captureID: String, occurredAt: String) -> ActionReceipt {
        let captureObject = LifeGraphObjectReference(
            kind: .capture,
            id: captureID,
            label: input.rawText,
            sourceDomain: .capture
        )
        let targetObject = selectedCandidate?.target.objectReference
        let affectedObjects = [captureObject, targetObject].compactMap { $0 }
        let resultState: ActionReceiptResultState
        switch self.resultState {
        case .attached:
            resultState = .attached
        case .savedStandalone, .savedToNeedsPlace:
            resultState = .created
        case .needsClarification:
            resultState = .needsConfirmation
        case .failedSafely:
            resultState = .failedSafely
        }
        let factKind: ActionReceiptChangedFactKind = self.resultState == .attached ? .attachedCaptureToGoal : .createdCapture
        let safeFailure = self.resultState == .failedSafely
            ? ActionReceiptSafeFailure(
                whatFailed: "Smart Attachment",
                whyFailed: failureReason,
                unchangedFacts: ["No calendar, sync, account, cloud, external service, or unsupported app data was changed."],
                nextSafeAction: ActionReceiptNextAction(kind: .dismiss, title: "Keep")
            )
            : nil

        return ActionReceipt(
            id: "receipt.smart-attachment.\(id)",
            resultState: resultState,
            title: receiptLine,
            summary: explanation ?? receiptLine,
            sourceDomain: .capture,
            occurredAt: occurredAt,
            affectedObjects: affectedObjects,
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact.smart-attachment.\(id)",
                    kind: factKind,
                    object: captureObject,
                    summary: receiptLine
                )
            ],
            why: ActionReceiptWhyExplanation(body: explanation),
            nextAction: ActionReceiptNextAction(kind: .correctAssumption, title: "Change", destination: .captureInbox, target: captureObject),
            correctionAvailability: .availableWithReason,
            undoAvailability: .notSupportedYet,
            safetyState: self.resultState == .failedSafely ? .safeFailure : .normal,
            safeFailure: safeFailure,
            sourceObject: captureObject
        )
    }
}

extension SmartAttachmentResult {
    var reclassificationProjection: SmartAttachmentReclassificationProjection {
        let actionTitles = reclassificationActionTitles
        let undoSummary = "Undo is not applied automatically; use Change before saving or reclassify after placement."
        let correctionAvailability: ActionReceiptCorrectionAvailability = actionTitles.isEmpty ? .unavailable : .availableWithReason
        let rollbackSummary = savesToNeedsPlace
            ? "Rollback keeps the capture in Needs a Place with the original text preserved."
            : "Rollback returns the capture to Needs a Place and preserves the original text and receipt."

        return SmartAttachmentReclassificationProjection(
            receiptTitle: receiptLine,
            undoAvailability: .notSupportedYet,
            undoSummary: undoSummary,
            correctionAvailability: correctionAvailability,
            reclassificationActions: actionTitles,
            rollbackSummary: rollbackSummary,
            accessibilitySummary: "\(receiptLine). Undo not supported yet. \(correctionAvailability.isAvailable ? "Correction available." : "No correction action available.")"
        )
    }

    var reviewBundle: SmartAttachmentReviewBundle {
        let cluster = SmartAttachmentCaptureCluster(
            id: "cluster.\(id)",
            title: clusterTitle,
            summary: clusterSummary,
            evidenceLabels: suggestedCandidate?.evidenceLabels ?? selectedCandidate?.evidenceLabels ?? [],
            itemCount: 1
        )
        let signals = openLoopSignals
        let actionTitles = actions.map(\.title)

        return SmartAttachmentReviewBundle(
            id: "review-bundle.\(id)",
            title: reviewBundleTitle,
            summary: reviewBundleSummary(openLoopCount: signals.count),
            clusters: [cluster],
            openLoopSignals: signals,
            actionTitles: actionTitles,
            accessibilitySummary: accessibilityReviewSummary(openLoopCount: signals.count, actionTitles: actionTitles)
        )
    }

    private var reclassificationActionTitles: [String] {
        guard resultState != .failedSafely else { return [] }
        return actions.filter { action in
            switch action {
            case .change, .task, .goal, .idea, .proof, .waiting, .plan, .attach, .keepStandalone:
                return true
            case .retry, .copy:
                return false
            }
        }
        .map(\.title)
    }

    private var reviewBundleTitle: String {
        if savesToNeedsPlace || resultState == .needsClarification {
            return "Needs a Place review"
        }
        if suggestedCandidate != nil {
            return "Route review"
        }
        return "Placed capture review"
    }

    private var clusterTitle: String {
        if savesToNeedsPlace || resultState == .needsClarification {
            return "Unplaced capture"
        }
        if selectedCandidate?.target.routeType == .proofItem {
            return "Proof candidate"
        }
        return selectedCandidate?.target.routeType.userFacingLabel ?? "Capture"
    }

    private var clusterSummary: String {
        if savesToNeedsPlace || resultState == .needsClarification {
            return "Held safely until the user chooses where it belongs."
        }
        if let destination = selectedCandidate?.target.displaySegments.joined(separator: " · "), destination.isEmpty == false {
            return "Locally grouped by \(destination)."
        }
        return "Locally grouped by conservative capture route."
    }

    private var openLoopSignals: [SmartAttachmentOpenLoopSignal] {
        var signals = [SmartAttachmentOpenLoopSignal]()
        if savesToNeedsPlace || resultState == .needsClarification {
            signals.append(
                SmartAttachmentOpenLoopSignal(
                    id: "open-loop.\(id).route-choice",
                    title: "Route needs a choice",
                    reason: clarification?.question ?? "The route was not safe to infer.",
                    requiresUserChoice: true
                )
            )
        }
        if let suggestedCandidate {
            signals.append(
                SmartAttachmentOpenLoopSignal(
                    id: "open-loop.\(id).suggested-attachment",
                    title: "Suggested attachment available",
                    reason: "Local wording also matched \(suggestedCandidate.target.destinationLabel ?? "an existing item").",
                    requiresUserChoice: true
                )
            )
        }
        if resultState == .failedSafely {
            signals.append(
                SmartAttachmentOpenLoopSignal(
                    id: "open-loop.\(id).safe-failure",
                    title: "Capture kept safely",
                    reason: failureReason ?? "No route was applied.",
                    requiresUserChoice: false
                )
            )
        }
        return signals
    }

    private func reviewBundleSummary(openLoopCount: Int) -> String {
        if openLoopCount == 0 {
            return "No open review loop is required before saving this local route."
        }
        return "\(openLoopCount) open review loop\(openLoopCount == 1 ? "" : "s") kept explicit before placement."
    }

    private func accessibilityReviewSummary(openLoopCount: Int, actionTitles: [String]) -> String {
        let actions = actionTitles.isEmpty ? "No actions" : actionTitles.joined(separator: ", ")
        return "\(reviewBundleTitle). \(openLoopCount) open loop\(openLoopCount == 1 ? "" : "s"). Actions: \(actions)."
    }
}
