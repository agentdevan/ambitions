import Foundation

let captureRuntimeReceiptSchemaVersion = "capture_runtime_receipt.native.v1"
let captureRuntimeReplaySchemaVersion = "capture_runtime_replay.native.v1"

enum CaptureRuntimeReceiptKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case captureExtracted = "capture_extracted"
    case captureNeedsClarification = "capture_needs_clarification"
    case captureMatchedGoal = "capture_matched_goal"
    case captureWeakMatchRejected = "capture_weak_match_rejected"
    case captureSavedAsFutureContext = "capture_saved_as_future_context"
    case captureProposedForTime = "capture_proposed_for_time"
    case captureAddedToTime = "capture_added_to_time"
    case captureAttachedToGoal = "capture_attached_to_goal"
    case captureSavedAsProof = "capture_saved_as_proof"
    case captureRuntimeUsePaused = "capture_runtime_use_paused"
    case captureCorrectionApplied = "capture_correction_applied"
    case captureReplayGenerated = "capture_replay_generated"
}

enum CaptureRuntimeCorrectionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case wrongActivity = "wrong_activity"
    case wrongTime = "wrong_time"
    case wrongGoal = "wrong_goal"
    case doNotUseForPlanning = "do_not_use_for_planning"
    case saveOnlyAsNote = "save_only_as_note"
    case attachToDifferentGoal = "attach_to_different_goal"
    case deleteContext = "delete_context"
}

struct CaptureRuntimeCorrectionInput: Codable, Sendable, Equatable, Hashable {
    let kind: CaptureRuntimeCorrectionKind
    let activityLabel: String?
    let timeLabel: String?
    let goalID: String?
    let note: String?

    init(
        kind: CaptureRuntimeCorrectionKind,
        activityLabel: String? = nil,
        timeLabel: String? = nil,
        goalID: String? = nil,
        note: String? = nil
    ) {
        self.kind = kind
        self.activityLabel = Self.normalizedOptional(activityLabel)
        self.timeLabel = Self.normalizedOptional(timeLabel)
        self.goalID = Self.normalizedOptional(goalID)
        self.note = Self.normalizedOptional(note)
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }
}

enum CaptureRuntimeUseStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case active
    case paused
    case noteOnly = "note_only"
    case blocked
    case deleted
}

struct CaptureRuntimeProposedDestination: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let routeType: String?
    let destinationKind: String
    let score: Int?
    let evidenceLabels: [String]
    let needsApproval: Bool
    let wasSelected: Bool
    let notes: [String]

    init(
        id: String,
        title: String,
        routeType: String? = nil,
        destinationKind: String,
        score: Int? = nil,
        evidenceLabels: [String] = [],
        needsApproval: Bool = false,
        wasSelected: Bool = false,
        notes: [String] = []
    ) {
        self.id = Self.normalizedRequired(id)
        self.title = Self.normalizedRequired(title)
        self.routeType = Self.normalizedOptional(routeType)
        self.destinationKind = Self.normalizedRequired(destinationKind)
        self.score = score
        self.evidenceLabels = Self.normalized(evidenceLabels)
        self.needsApproval = needsApproval
        self.wasSelected = wasSelected
        self.notes = Self.normalized(notes)
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

    static func normalized(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct CaptureRuntimeUserDecision: Codable, Sendable, Equatable, Hashable {
    let selectedRouteType: SmartAttachmentRouteType?
    let selectedDestinationID: String?
    let selectedDestinationLabel: String?
    let decisionSummary: String
    let correctionKind: CaptureRuntimeCorrectionKind?
    let correctionNote: String?

    init(
        selectedRouteType: SmartAttachmentRouteType?,
        selectedDestinationID: String?,
        selectedDestinationLabel: String?,
        decisionSummary: String,
        correctionKind: CaptureRuntimeCorrectionKind? = nil,
        correctionNote: String? = nil
    ) {
        self.selectedRouteType = selectedRouteType
        self.selectedDestinationID = Self.normalizedOptional(selectedDestinationID)
        self.selectedDestinationLabel = Self.normalizedOptional(selectedDestinationLabel)
        self.decisionSummary = Self.normalizedRequired(decisionSummary)
        self.correctionKind = correctionKind
        self.correctionNote = Self.normalizedOptional(correctionNote)
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

struct CaptureRuntimeFutureUse: Codable, Sendable, Equatable, Hashable {
    let canAffectFutureRouting: Bool
    let preferredGoalID: String?
    let preferredTimeLabel: String?
    let preferredActivityLabel: String?
    let routingNotes: [String]
    let localOnly: Bool

    init(
        canAffectFutureRouting: Bool,
        preferredGoalID: String? = nil,
        preferredTimeLabel: String? = nil,
        preferredActivityLabel: String? = nil,
        routingNotes: [String] = [],
        localOnly: Bool = true
    ) {
        self.canAffectFutureRouting = canAffectFutureRouting
        self.preferredGoalID = Self.normalizedOptional(preferredGoalID)
        self.preferredTimeLabel = Self.normalizedOptional(preferredTimeLabel)
        self.preferredActivityLabel = Self.normalizedOptional(preferredActivityLabel)
        self.routingNotes = Self.normalized(routingNotes)
        self.localOnly = localOnly
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    static func normalized(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct CaptureRuntimeReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: CaptureRuntimeReceiptKind
    let whatWasCaptured: String
    let whatWasDetected: [String]
    let stagedInputs: [CaptureStagedInputProjection]
    let whereItWent: String
    let whatItMayAffect: [String]
    let whatWasNotUsed: [String]
    let whyApprovalWasNeeded: String?
    let timestamp: String
    let privacyRedactions: [String]
    let undoAvailability: ActionReceiptUndoAvailability
    let schemaVersion: String

    init(
        id: String,
        kind: CaptureRuntimeReceiptKind,
        whatWasCaptured: String,
        whatWasDetected: [String],
        stagedInputs: [CaptureStagedInputProjection] = [],
        whereItWent: String,
        whatItMayAffect: [String],
        whatWasNotUsed: [String],
        whyApprovalWasNeeded: String? = nil,
        timestamp: String,
        privacyRedactions: [String] = [],
        undoAvailability: ActionReceiptUndoAvailability = .notSupportedYet,
        schemaVersion: String = captureRuntimeReceiptSchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.kind = kind
        self.whatWasCaptured = Self.normalizedRequired(whatWasCaptured)
        self.whatWasDetected = Self.normalized(whatWasDetected)
        self.stagedInputs = stagedInputs
        self.whereItWent = Self.normalizedRequired(whereItWent)
        self.whatItMayAffect = Self.normalized(whatItMayAffect)
        self.whatWasNotUsed = Self.normalized(whatWasNotUsed)
        self.whyApprovalWasNeeded = Self.normalizedOptional(whyApprovalWasNeeded)
        self.timestamp = Self.normalizedRequired(timestamp)
        self.privacyRedactions = Self.normalized(privacyRedactions)
        self.undoAvailability = undoAvailability
        self.schemaVersion = schemaVersion
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

    static func normalized(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct CaptureRuntimeReplayTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let schemaVersion: String
    let rawCapture: String
    let extraction: CaptureSemanticExtraction
    let ambiguity: SmartAttachmentClarification?
    let relevanceScan: GoalRelevanceScan?
    let proposedDestinations: [CaptureRuntimeProposedDestination]
    let userDecision: CaptureRuntimeUserDecision
    let runtimeUseStatus: CaptureRuntimeUseStatus
    let receipt: CaptureRuntimeReceipt
    let stagedInputs: [CaptureStagedInputProjection]
    let futureUse: CaptureRuntimeFutureUse
    let receiptKinds: [CaptureRuntimeReceiptKind]

    init(
        id: String,
        rawCapture: String,
        extraction: CaptureSemanticExtraction,
        ambiguity: SmartAttachmentClarification?,
        relevanceScan: GoalRelevanceScan?,
        proposedDestinations: [CaptureRuntimeProposedDestination],
        userDecision: CaptureRuntimeUserDecision,
        runtimeUseStatus: CaptureRuntimeUseStatus,
        receipt: CaptureRuntimeReceipt,
        stagedInputs: [CaptureStagedInputProjection] = [],
        futureUse: CaptureRuntimeFutureUse,
        receiptKinds: [CaptureRuntimeReceiptKind],
        schemaVersion: String = captureRuntimeReplaySchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.schemaVersion = schemaVersion
        self.rawCapture = Self.normalizedRequired(rawCapture)
        self.extraction = extraction
        self.ambiguity = ambiguity
        self.relevanceScan = relevanceScan
        self.proposedDestinations = proposedDestinations
        self.userDecision = userDecision
        self.runtimeUseStatus = runtimeUseStatus
        self.receipt = receipt
        self.stagedInputs = stagedInputs
        self.futureUse = futureUse
        self.receiptKinds = Self.normalizedReceiptKinds(receiptKinds)
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedReceiptKinds(_ kinds: [CaptureRuntimeReceiptKind]) -> [CaptureRuntimeReceiptKind] {
        Array(
            Set(kinds)
        ).sorted { $0.recognitionOrder < $1.recognitionOrder }
    }
}
