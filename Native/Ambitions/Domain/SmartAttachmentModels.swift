import Foundation

let smartAttachmentSchemaVersion = "smart_attachment.native.v2"

enum CaptureActivityClassification: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case exercise
    case communication
    case learning
    case work
    case proof
    case blocker
    case recovery
    case outing
    case unknown

    var userFacingLabel: String {
        switch self {
        case .exercise: "Exercise"
        case .communication: "Communication"
        case .learning: "Learning"
        case .work: "Work"
        case .proof: "Proof"
        case .blocker: "Blocker"
        case .recovery: "Recovery"
        case .outing: "Outing"
        case .unknown: "Unknown"
        }
    }
}

enum CaptureGoalDomainHint: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fitness
    case health
    case work
    case learning
    case music
    case relationships
    case outdoors
    case logistics
    case recovery
    case proof
    case general

    var userFacingLabel: String {
        switch self {
        case .fitness: "Fitness"
        case .health: "Health"
        case .work: "Work"
        case .learning: "Learning"
        case .music: "Music"
        case .relationships: "Relationships"
        case .outdoors: "Outdoors"
        case .logistics: "Logistics"
        case .recovery: "Recovery"
        case .proof: "Proof"
        case .general: "General"
        }
    }
}

enum CaptureSemanticUncertaintyFlag: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case timeRequiresAMPM = "time_requires_am_pm"
    case relativeDateOnly = "relative_date_only"
    case recurrenceDetected = "recurrence_detected"
    case locationAmbiguous = "location_ambiguous"
    case personUnconfirmed = "person_unconfirmed"
    case objectPartial = "object_partial"
    case contextualOnly = "contextual_only"
}

enum CaptureTimeAmbiguity: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case amPm
    case date
    case duration
    case recurrence
    case location
    case other
}

enum CaptureTimeConfidenceBand: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case high
    case medium
    case low
    case needsClarification = "needs_clarification"
}

struct CaptureTimeInterpretation: Codable, Sendable, Equatable, Hashable {
    let originalExpression: String
    let interpretedStart: DateComponents?
    let interpretedEnd: DateComponents?
    let timezone: String
    let ambiguity: CaptureTimeAmbiguity
    let requiresUserConfirmation: Bool
    let confidenceBand: CaptureTimeConfidenceBand
    let explanation: String
}

struct CaptureSemanticExtraction: Codable, Sendable, Equatable, Hashable {
    let rawText: String
    let normalizedText: String
    let activity: CaptureActivityClassification
    let actionVerb: String?
    let object: String?
    let dateTimeExpression: String?
    let interpretedDateTime: CaptureTimeInterpretation?
    let durationEstimate: String?
    let locationHint: String?
    let peopleHint: [String]
    let recurrenceHint: String?
    let equipmentHint: String?
    let facilityHint: String?
    let goalDomainHints: [CaptureGoalDomainHint]
    let proofSignal: Bool
    let blockerSignal: Bool
    let recoverySignal: Bool
    let uncertaintyFlags: [CaptureSemanticUncertaintyFlag]
    let needsClarification: Bool

    var semanticClarificationQuestion: String? {
        guard let interpretedDateTime else { return nil }
        guard interpretedDateTime.requiresUserConfirmation else { return nil }
        switch interpretedDateTime.ambiguity {
        case .amPm:
            let value = Self.clarificationTimeValue(from: interpretedDateTime.originalExpression)
            return "Do you mean \(value) AM or \(value) PM?"
        case .date:
            return "Which date did you mean?"
        case .duration:
            return "How long should this be?"
        case .recurrence:
            return "How often should this repeat?"
        case .location:
            return "Which location did you mean?"
        case .other:
            return interpretedDateTime.explanation
        case .none:
            return nil
        }
    }

    private static func clarificationTimeValue(from expression: String) -> String {
        guard let hour = Self.parsedHour(from: expression.lowercased()) else {
            return expression
                .replacingOccurrences(of: #"(?i)^at\s+"#, with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return String(hour)
    }

    static func extract(
        from input: SmartAttachmentInput,
        routeType: SmartAttachmentRouteType?,
        selectedCandidate: SmartAttachmentCandidate?,
        clarification: SmartAttachmentClarification?
    ) -> CaptureSemanticExtraction {
        let rawText = input.rawText
        let normalizedText = Self.normalizedText(from: rawText)
        let activity = Self.activityClassification(for: normalizedText, routeType: routeType, selectedCandidate: selectedCandidate)
        let actionVerb = Self.actionVerb(in: normalizedText)
        let dateTimeExpression = Self.dateTimeExpression(in: rawText)
        let timeInterpretation = Self.timeInterpretation(for: rawText, dateTimeExpression: dateTimeExpression)
        let proofSignal = Self.containsAny(normalizedText, ["finished", "completed", "recorded", "logged", "ran", "ran ", "did", "proof"])
        let blockerSignal = Self.containsAny(normalizedText, ["blocked", "closed", "late", "waiting", "stuck", "cancelled", "canceled"])
        let recoverySignal = Self.containsAny(normalizedText, ["hurt", "injury", "sore", "recover", "recovery", "rest"])
        let recurrenceHint = Self.recurrenceHint(in: rawText)
        let locationHint = Self.locationHint(in: rawText)
        let equipmentHint = Self.equipmentHint(in: rawText)
        let facilityHint = Self.facilityHint(in: rawText)
        let peopleHint = Self.peopleHint(in: rawText)
        let object = Self.objectPhrase(
            in: rawText,
            actionVerb: actionVerb,
            dateTimeExpression: dateTimeExpression
        )
        let durationEstimate = Self.durationEstimate(in: rawText)
        let goalDomainHints = Self.goalDomainHints(
            activity: activity,
            proofSignal: proofSignal,
            blockerSignal: blockerSignal,
            recoverySignal: recoverySignal,
            rawText: normalizedText
        )
        let uncertaintyFlags = Self.uncertaintyFlags(
            timeInterpretation: timeInterpretation,
            recurrenceHint: recurrenceHint,
            locationHint: locationHint,
            peopleHint: peopleHint,
            object: object
        )

        return CaptureSemanticExtraction(
            rawText: rawText,
            normalizedText: normalizedText,
            activity: activity,
            actionVerb: actionVerb,
            object: object,
            dateTimeExpression: dateTimeExpression,
            interpretedDateTime: timeInterpretation,
            durationEstimate: durationEstimate,
            locationHint: locationHint,
            peopleHint: peopleHint,
            recurrenceHint: recurrenceHint,
            equipmentHint: equipmentHint,
            facilityHint: facilityHint,
            goalDomainHints: goalDomainHints,
            proofSignal: proofSignal,
            blockerSignal: blockerSignal,
            recoverySignal: recoverySignal,
            uncertaintyFlags: uncertaintyFlags,
            needsClarification: timeInterpretation?.requiresUserConfirmation == true
        )
    }
}

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
    let semanticExtraction: CaptureSemanticExtraction
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
        semanticExtraction: CaptureSemanticExtraction? = nil,
        receiptLine: String,
        explanation: String? = nil,
        actions: [SmartAttachmentActionLabel],
        privacyLevel: ActionReceiptPrivacyLevel = .privateItem,
        failureReason: String? = nil,
        schemaVersion: String = smartAttachmentSchemaVersion
    ) {
        self.id = SmartAttachmentRouteTarget.normalizedRequired(id)
        self.input = input
        self.semanticExtraction = semanticExtraction ?? CaptureSemanticExtraction.extract(
            from: input,
            routeType: selectedCandidate?.target.routeType,
            selectedCandidate: selectedCandidate,
            clarification: clarification
        )
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

    var semanticClarificationQuestion: String? {
        semanticExtraction.semanticClarificationQuestion
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

private extension CaptureSemanticExtraction {
    static func normalizedText(from rawText: String) -> String {
        rawText
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func activityClassification(
        for normalizedText: String,
        routeType: SmartAttachmentRouteType?,
        selectedCandidate: SmartAttachmentCandidate?
    ) -> CaptureActivityClassification {
        if containsAny(normalizedText, ["finished", "completed", "logged", "proof"]) {
            return .proof
        }
        if containsAny(normalizedText, ["closed", "blocked", "waiting", "stuck", "late"]) {
            return .blocker
        }
        if containsAny(normalizedText, ["hurt", "sore", "recover", "recovery", "rest", "practice"]) {
            return .recovery
        }
        if containsAny(normalizedText, ["lesson", "study", "learn", "guitar", "music"]) {
            return .learning
        }
        if containsAny(normalizedText, ["call", "email", "text", "meet", "met", "coach"]) {
            return .communication
        }
        if containsAny(normalizedText, ["ymca", "open court", "court"]) {
            return .outing
        }
        if containsAny(normalizedText, ["run", "ran", "walk", "bike", "pickleball", "workout", "practice", "court", "trail"]) {
            return .exercise
        }
        if containsAny(normalizedText, ["worked", "work", "send", "draft", "write"]) {
            return .work
        }
        if containsAny(normalizedText, ["trip", "travel", "visit", "ymca"]) {
            return .outing
        }
        if routeType == .goal || selectedCandidate?.target.routeType == .goal {
            return .work
        }
        return .unknown
    }

    static func actionVerb(in normalizedText: String) -> String? {
        let verbs = [
            "finished", "completed", "logged", "call", "email", "meet", "met", "play",
            "ran", "run", "worked", "work", "hurt", "study", "learn", "practice"
        ]
        return firstMatchingWord(in: normalizedText, words: verbs)
    }

    static func dateTimeExpression(in rawText: String) -> String? {
        let patterns = [
            #"(?i)\bat\s+\d{1,2}(?:\s?(?:am|pm))?(?:\s+(?:next\s+)?(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday))?"#,
            #"(?i)\bnext\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b"#,
            #"(?i)\bevery\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b"#,
            #"(?i)\b(?:today|tomorrow|tonight|friday|monday|tuesday|wednesday|thursday|saturday|sunday)\b"#
        ]
        return firstMatchingSubstring(in: rawText, patterns: patterns)
    }

    static func timeInterpretation(for rawText: String, dateTimeExpression: String?) -> CaptureTimeInterpretation? {
        guard let dateTimeExpression else { return nil }
        let lowercased = dateTimeExpression.lowercased()
        let timezone = TimeZone.current.identifier

        if lowercased.contains("every ") {
            return CaptureTimeInterpretation(
                originalExpression: dateTimeExpression,
                interpretedStart: nil,
                interpretedEnd: nil,
                timezone: timezone,
                ambiguity: .recurrence,
                requiresUserConfirmation: false,
                confidenceBand: .medium,
                explanation: "The capture names a recurrence without a specific clock time."
            )
        }

        if let hour = parsedHour(from: lowercased) {
            let explicitMeridiem = lowercased.contains("am") || lowercased.contains("pm")
            let clarifiedHour = normalizedHour(hour, isPM: lowercased.contains("pm"))
            var components = DateComponents()
            components.hour = clarifiedHour
            components.minute = 0
            return CaptureTimeInterpretation(
                originalExpression: dateTimeExpression,
                interpretedStart: components,
                interpretedEnd: nil,
                timezone: timezone,
                ambiguity: explicitMeridiem ? .none : .amPm,
                requiresUserConfirmation: explicitMeridiem == false,
                confidenceBand: explicitMeridiem ? .high : .needsClarification,
                explanation: explicitMeridiem
                    ? "The capture includes an explicit clock time."
                    : "The capture includes a clock time without AM or PM."
            )
        }

        if containsAny(lowercased, ["today", "tomorrow", "tonight", "friday", "monday", "tuesday", "wednesday", "thursday", "saturday", "sunday"]) {
            return CaptureTimeInterpretation(
                originalExpression: dateTimeExpression,
                interpretedStart: nil,
                interpretedEnd: nil,
                timezone: timezone,
                ambiguity: .date,
                requiresUserConfirmation: false,
                confidenceBand: .medium,
                explanation: "The capture names a relative day without a clock time."
            )
        }

        return CaptureTimeInterpretation(
            originalExpression: dateTimeExpression,
            interpretedStart: nil,
            interpretedEnd: nil,
            timezone: timezone,
            ambiguity: .other,
            requiresUserConfirmation: false,
            confidenceBand: .low,
            explanation: "The capture mentions time language that stays local until the user confirms it."
        )
    }

    static func recurrenceHint(in rawText: String) -> String? {
        firstMatchingSubstring(
            in: rawText,
            patterns: [
                #"(?i)\bevery\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b"#,
                #"(?i)\bevery\s+(?:week|day|month|year)\b"#
            ]
        )
    }

    static func locationHint(in rawText: String) -> String? {
        if let facility = facilityHint(in: rawText) {
            return facility
        }
        if let match = firstMatchingSubstring(
            in: rawText,
            patterns: [
                #"(?i)\b(?:at|in|on|near)\s+[A-Z][A-Za-z0-9&'\- ]+"#,
                #"(?i)\b(?:court|trail|studio|gym|park|office|home)\b"#
            ]
        ) {
            return match.replacingOccurrences(of: #"(?i)^(?:at|in|on|near)\s+"#, with: "", options: .regularExpression)
        }
        return nil
    }

    static func equipmentHint(in rawText: String) -> String? {
        firstMatchingSubstring(
            in: rawText,
            patterns: [
                #"(?i)\b(guitar|bike|bicycle|ball|paddle|weights|dumbbells|mat)\b"#
            ]
        )
    }

    static func facilityHint(in rawText: String) -> String? {
        firstMatchingSubstring(
            in: rawText,
            patterns: [
                #"(?i)\bymca\b"#,
                #"(?i)\b(?:court|trail|gym|studio|clinic|field|pool)\b"#
            ]
        )
    }

    static func peopleHint(in rawText: String) -> [String] {
        var hints = [String]()
        if let directRole = firstMatchingSubstring(in: rawText, patterns: [#"(?i)\bcall\s+coach\b"#]) {
            hints.append(directRole.replacingOccurrences(of: #"(?i)^call\s+"#, with: "", options: .regularExpression))
        }
        let names = matches(in: rawText, pattern: #"\b[A-Z][a-z]+\b"#)
            .filter { !commonTimeWords.contains($0.lowercased()) }
            .filter { $0 != "YMCA" }
        hints.append(contentsOf: names)
        return Array(NSOrderedSet(array: hints)).compactMap { $0 as? String }
    }

    static func objectPhrase(
        in rawText: String,
        actionVerb: String?,
        dateTimeExpression: String?
    ) -> String? {
        let lowercased = rawText.lowercased()
        if lowercased.contains("met ") && lowercased.contains(" for ") {
            if let forRange = rawText.range(of: #"(?i)\bfor\s+(.+)$"#, options: .regularExpression) {
                let value = String(rawText[forRange]).replacingOccurrences(of: #"(?i)^for\s+"#, with: "", options: .regularExpression)
                return cleaned(value)
            }
        }
        guard let actionVerb else {
            if let blockerObject = firstMatchingSubstring(
                in: rawText,
                patterns: [
                    #"(?i)^(.*?)(?:\s+closed\b|\s+open\b|\s+hurt\b)$"#
                ]
            ) {
                return cleaned(blockerObject.replacingOccurrences(of: #"(?i)\s+(?:closed|open|hurt)$"#, with: "", options: .regularExpression))
            }
            if let dateTimeExpression,
               let range = rawText.range(of: dateTimeExpression, options: [.caseInsensitive]) {
                let withoutDate = rawText.replacingCharacters(in: range, with: "")
                return cleaned(withoutDate)
            }
            return cleaned(rawText)
        }

        guard let verbRange = lowercased.range(of: actionVerb.lowercased()) else {
            return cleaned(rawText)
        }

        let before = String(rawText[..<verbRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        let after = String(rawText[verbRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        if actionVerb == "hurt", before.isEmpty == false {
            return cleaned(before)
        }
        if actionVerb == "call", after.isEmpty == false {
            return cleaned(after.replacingOccurrences(of: #"(?i)\b(?:today|tomorrow|tonight|friday|monday|tuesday|wednesday|thursday|saturday|sunday|next\s+\w+)\b.*$"#, with: "", options: .regularExpression))
        }
        if after.isEmpty == false {
            let clipped = after.replacingOccurrences(
                of: #"(?i)\s+(?:at|on|in|near|by|today|tomorrow|tonight|every|next\s+\w+)\b.*$"#,
                with: "",
                options: .regularExpression
            )
            if let cleanedAfter = cleaned(clipped) {
                return cleanedAfter
            }
        }
        if before.isEmpty == false {
            return cleaned(before)
        }
        return cleaned(after)
    }

    static func durationEstimate(in rawText: String) -> String? {
        firstMatchingSubstring(
            in: rawText,
            patterns: [
                #"(?i)\b\d+\s*(?:miles?|minutes?|mins?|hours?|hrs?)\b"#
            ]
        )
    }

    static func goalDomainHints(
        activity: CaptureActivityClassification,
        proofSignal: Bool,
        blockerSignal: Bool,
        recoverySignal: Bool,
        rawText: String
    ) -> [CaptureGoalDomainHint] {
        var hints = [CaptureGoalDomainHint]()
        switch activity {
        case .exercise:
            hints.append(contentsOf: [.fitness, .health])
        case .communication:
            hints.append(.relationships)
        case .learning:
            hints.append(contentsOf: [.learning, .music])
        case .work:
            hints.append(.work)
        case .proof:
            hints.append(.proof)
        case .blocker:
            hints.append(contentsOf: [.health, .recovery])
        case .recovery:
            hints.append(contentsOf: [.health, .recovery])
        case .outing:
            hints.append(contentsOf: [.outdoors, .fitness])
        case .unknown:
            break
        }
        if proofSignal {
            hints.append(.proof)
        }
        if blockerSignal || recoverySignal {
            hints.append(contentsOf: [.health, .recovery])
        }
        if rawText.contains("met ") || rawText.contains("call ") || rawText.contains("study") || rawText.contains("coach") {
            hints.append(.relationships)
        }
        if rawText.contains("study") {
            hints.append(.learning)
        }
        return Array(NSOrderedSet(array: hints)).compactMap { $0 as? CaptureGoalDomainHint }
    }

    static func uncertaintyFlags(
        timeInterpretation: CaptureTimeInterpretation?,
        recurrenceHint: String?,
        locationHint: String?,
        peopleHint: [String],
        object: String?
    ) -> [CaptureSemanticUncertaintyFlag] {
        var flags = [CaptureSemanticUncertaintyFlag]()
        if timeInterpretation?.ambiguity == .amPm {
            flags.append(.timeRequiresAMPM)
        }
        if timeInterpretation?.ambiguity == .date {
            flags.append(.relativeDateOnly)
        }
        if recurrenceHint != nil {
            flags.append(.recurrenceDetected)
        }
        if locationHint != nil {
            flags.append(.locationAmbiguous)
        }
        if peopleHint.isEmpty == false {
            flags.append(.personUnconfirmed)
        }
        if object == nil || object?.isEmpty == true {
            flags.append(.objectPartial)
        }
        if flags.isEmpty {
            flags.append(.contextualOnly)
        }
        return Array(NSOrderedSet(array: flags)).compactMap { $0 as? CaptureSemanticUncertaintyFlag }
    }

    static func containsAny(_ text: String, _ terms: [String]) -> Bool {
        terms.contains { containsWord(text, $0) }
    }

    static func containsWord(_ text: String, _ word: String) -> Bool {
        text.range(of: #"(?<![a-z0-9])"# + NSRegularExpression.escapedPattern(for: word.lowercased()) + #"(?=[^a-z0-9]|$)"#, options: .regularExpression) != nil
    }

    static func firstMatchingWord(in text: String, words: [String]) -> String? {
        words.first { containsWord(text, $0) }
    }

    static func firstMatchingSubstring(in text: String, patterns: [String]) -> String? {
        for pattern in patterns {
            if let match = firstMatch(in: text, pattern: pattern) {
                return match
            }
        }
        return nil
    }

    static func firstMatch(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range),
              let matchRange = Range(match.range, in: text) else {
            return nil
        }
        return String(text[matchRange]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func matches(in text: String, pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, options: [], range: range).compactMap { match in
            guard let matchRange = Range(match.range, in: text) else { return nil }
            return String(text[matchRange])
        }
    }

    static func parsedHour(from text: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: #"(?i)\bat\s+(\d{1,2})(?:\s?(?:am|pm))?"#) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range),
              match.numberOfRanges > 1,
              let captureRange = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return Int(String(text[captureRange]))
    }

    static func normalizedHour(_ hour: Int, isPM: Bool) -> Int {
        let boundedHour = max(0, min(hour, 23))
        guard boundedHour <= 12 else { return boundedHour }
        if isPM, boundedHour < 12 {
            return boundedHour + 12
        }
        if isPM == false, boundedHour == 12 {
            return 0
        }
        return boundedHour
    }

    static func cleaned(_ value: String) -> String? {
        let trimmed = value
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static var commonTimeWords: Set<String> {
        ["am", "pm", "today", "tomorrow", "tonight", "friday", "monday", "tuesday", "wednesday", "thursday", "saturday", "sunday", "next", "every"]
    }
}
