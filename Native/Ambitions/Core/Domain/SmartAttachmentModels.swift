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

    static func clarificationTimeValue(from expression: String) -> String {
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
        case .task: "Step"
        case .goal: "Goal"
        case .idea: "Idea"
        case .proofItem: "Proof"
        case .waitingItem: "Waiting"
        case .plan: "Time proposal"
        case .contextualNote: "Thought"
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
