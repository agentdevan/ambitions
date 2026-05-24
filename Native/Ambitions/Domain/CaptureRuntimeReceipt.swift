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

    private static func normalizedOptional(_ value: String?) -> String? {
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

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    private static func normalized(_ values: [String]) -> [String] {
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

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedOptional(_ value: String?) -> String? {
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

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    private static func normalized(_ values: [String]) -> [String] {
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
        self.whereItWent = Self.normalizedRequired(whereItWent)
        self.whatItMayAffect = Self.normalized(whatItMayAffect)
        self.whatWasNotUsed = Self.normalized(whatWasNotUsed)
        self.whyApprovalWasNeeded = Self.normalizedOptional(whyApprovalWasNeeded)
        self.timestamp = Self.normalizedRequired(timestamp)
        self.privacyRedactions = Self.normalized(privacyRedactions)
        self.undoAvailability = undoAvailability
        self.schemaVersion = schemaVersion
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    private static func normalized(_ values: [String]) -> [String] {
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
        self.futureUse = futureUse
        self.receiptKinds = Self.normalizedReceiptKinds(receiptKinds)
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedReceiptKinds(_ kinds: [CaptureRuntimeReceiptKind]) -> [CaptureRuntimeReceiptKind] {
        Array(
            Set(kinds)
        ).sorted { $0.recognitionOrder < $1.recognitionOrder }
    }
}

extension SmartAttachmentResult {
    func captureRuntimeReceipt(
        timestamp: String,
        correction: CaptureRuntimeCorrectionInput? = nil
    ) -> CaptureRuntimeReceipt {
        captureRuntimeReplayTrace(timestamp: timestamp, correction: correction).receipt
    }

    func captureRuntimeReplayTrace(
        timestamp: String,
        correction: CaptureRuntimeCorrectionInput? = nil
    ) -> CaptureRuntimeReplayTrace {
        let futureProof = futureProofContextCandidate
        let runtimeFactoring = captureRuntimeFactoringCandidate
        let proposedDestinations = captureRuntimeProposedDestinations(correction: correction)
        let userDecision = CaptureRuntimeUserDecision(
            selectedRouteType: selectedCandidate?.target.routeType,
            selectedDestinationID: selectedCandidate?.target.destinationID,
            selectedDestinationLabel: selectedCandidate?.target.destinationLabel,
            decisionSummary: captureRuntimeDecisionSummary(correction: correction),
            correctionKind: correction?.kind,
            correctionNote: correction?.note
        )
        let futureUse = captureRuntimeFutureUse(
            futureProof: futureProof,
            runtimeFactoring: runtimeFactoring,
            hasSelectedCandidate: selectedCandidate != nil,
            correction: correction
        )
        let receiptKinds = captureRuntimeReceiptKinds(
            futureUse: futureUse,
            correction: correction
        )
        let receipt = captureRuntimeReceipt(
            timestamp: timestamp,
            correction: correction,
            futureUse: futureUse,
            receiptKinds: receiptKinds
        )

        return CaptureRuntimeReplayTrace(
            id: "capture-runtime-replay.\(id).\(receipt.kind.rawValue)",
            rawCapture: input.rawText,
            extraction: semanticExtraction,
            ambiguity: clarification,
            relevanceScan: goalRelevanceScan,
            proposedDestinations: proposedDestinations,
            userDecision: userDecision,
            runtimeUseStatus: captureRuntimeUseStatus(correction: correction, futureUse: futureUse),
            receipt: receipt,
            futureUse: futureUse,
            receiptKinds: receiptKinds
        )
    }
}

private extension SmartAttachmentResult {
    func captureRuntimeReceipt(
        timestamp: String,
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse,
        receiptKinds: [CaptureRuntimeReceiptKind]
    ) -> CaptureRuntimeReceipt {
        let privacyRedactions = captureRuntimePrivacyRedactions(correction: correction, futureUse: futureUse)
        let capturedText = captureRuntimeCapturedText(redactions: privacyRedactions)
        let detected = captureRuntimeDetectedSummary(
            correction: correction,
            futureUse: futureUse,
            receiptKinds: receiptKinds
        )
        let whereItWent = captureRuntimeWhereItWent(correction: correction, futureUse: futureUse)
        let whatItMayAffect = captureRuntimeWhatItMayAffect(futureUse: futureUse, correction: correction)
        let whatWasNotUsed = captureRuntimeWhatWasNotUsed(correction: correction, futureUse: futureUse)
        let approvalNeeded = captureRuntimeApprovalNeeded(correction: correction, futureUse: futureUse)

        return CaptureRuntimeReceipt(
            id: "capture-runtime-receipt.\(id).\(timestamp).\(receiptKind(for: correction, futureUse: futureUse).rawValue)",
            kind: receiptKind(for: correction, futureUse: futureUse),
            whatWasCaptured: capturedText,
            whatWasDetected: detected,
            whereItWent: whereItWent,
            whatItMayAffect: whatItMayAffect,
            whatWasNotUsed: whatWasNotUsed,
            whyApprovalWasNeeded: approvalNeeded,
            timestamp: timestamp,
            privacyRedactions: privacyRedactions,
            undoAvailability: undoAvailability(for: correction)
        )
    }

    func captureRuntimeReceiptKinds(
        futureUse: CaptureRuntimeFutureUse,
        correction: CaptureRuntimeCorrectionInput?
    ) -> [CaptureRuntimeReceiptKind] {
        var kinds = [CaptureRuntimeReceiptKind.captureExtracted]
        if clarification != nil {
            kinds.append(.captureNeedsClarification)
        }
        if goalRelevanceScan?.highConfidenceMatches.isEmpty == false || selectedCandidate?.target.destinationKind == .existingGoal {
            kinds.append(.captureMatchedGoal)
        }
        if let scan = goalRelevanceScan, scan.weakMatches.isEmpty == false, scan.highConfidenceMatches.isEmpty, scan.mediumConfidenceMatches.isEmpty {
            kinds.append(.captureWeakMatchRejected)
        }
        if futureUse.canAffectFutureRouting {
            kinds.append(.captureSavedAsFutureContext)
        }
        if let routeType = selectedCandidate?.target.routeType, routeType.captureRoute == .timeSeed {
            kinds.append(.captureProposedForTime)
        }
        if selectedCandidate?.target.destinationKind == .existingPlan {
            kinds.append(.captureAddedToTime)
        }
        if selectedCandidate?.target.destinationKind == .existingGoal && selectedCandidate?.target.routeType == .proofItem {
            kinds.append(.captureAttachedToGoal)
        }
        if selectedCandidate?.target.routeType == .proofItem {
            kinds.append(.captureSavedAsProof)
        }
        if futureUse.canAffectFutureRouting == false || correction?.kind == .doNotUseForPlanning || correction?.kind == .saveOnlyAsNote || correction?.kind == .deleteContext {
            kinds.append(.captureRuntimeUsePaused)
        }
        if correction != nil {
            kinds.append(.captureCorrectionApplied)
        }
        kinds.append(.captureReplayGenerated)
        return Array(Set(kinds)).sorted { lhs, rhs in
            lhs.recognitionOrder < rhs.recognitionOrder
        }
    }

    func captureRuntimeProposedDestinations(
        correction: CaptureRuntimeCorrectionInput?
    ) -> [CaptureRuntimeProposedDestination] {
        var proposals = [CaptureRuntimeProposedDestination]()
        if let selectedCandidate {
            proposals.append(
                CaptureRuntimeProposedDestination(
                    id: "proposal.\(id).selected.\(selectedCandidate.id)",
                    title: selectedCandidate.target.destinationLabel ?? selectedCandidate.target.routeType.userFacingLabel,
                    routeType: selectedCandidate.target.routeType.rawValue,
                    destinationKind: selectedCandidate.target.destinationKind.rawValue,
                    score: selectedCandidate.score,
                    evidenceLabels: selectedCandidate.evidenceLabels,
                    needsApproval: goalRelevanceScan?.forcedAttachmentBlocked == true,
                    wasSelected: true,
                    notes: selectedCandidate.target.displaySegments
                )
            )
        }
        if let suggestedCandidate, suggestedCandidate.id != selectedCandidate?.id {
            proposals.append(
                CaptureRuntimeProposedDestination(
                    id: "proposal.\(id).suggested.\(suggestedCandidate.id)",
                    title: suggestedCandidate.target.destinationLabel ?? suggestedCandidate.target.routeType.userFacingLabel,
                    routeType: suggestedCandidate.target.routeType.rawValue,
                    destinationKind: suggestedCandidate.target.destinationKind.rawValue,
                    score: suggestedCandidate.score,
                    evidenceLabels: suggestedCandidate.evidenceLabels,
                    needsApproval: goalRelevanceScan?.forcedAttachmentBlocked == true,
                    wasSelected: false,
                    notes: suggestedCandidate.target.displaySegments
                )
            )
        }
        if let correction,
           let goalID = correction.goalID,
           correction.kind == .wrongGoal || correction.kind == .attachToDifferentGoal {
            proposals.append(
                CaptureRuntimeProposedDestination(
                    id: "proposal.\(id).correction.goal.\(goalID)",
                    title: correction.note ?? "Different goal",
                    routeType: SmartAttachmentRouteType.goal.rawValue,
                    destinationKind: SmartAttachmentDestinationKind.existingGoal.rawValue,
                    score: nil,
                    evidenceLabels: [],
                    needsApproval: true,
                    wasSelected: false,
                    notes: ["Future routing corrected to a different goal."]
                )
            )
        }
        return Array(
            Dictionary(grouping: proposals, by: \.id).compactMap { $0.value.first }
        ).sorted { lhs, rhs in
            lhs.id < rhs.id
        }
    }

    func captureRuntimeFutureUse(
        futureProof: FutureProofContextCandidate?,
        runtimeFactoring: CaptureRuntimeFactoringCandidate?,
        hasSelectedCandidate: Bool,
        correction: CaptureRuntimeCorrectionInput?
    ) -> CaptureRuntimeFutureUse {
        var notes = [String]()
        var canAffectFutureRouting = hasSelectedCandidate || futureProof != nil || runtimeFactoring != nil
        var preferredGoalID: String?
        var preferredTimeLabel: String?
        var preferredActivityLabel: String?

        if let futureProof {
            notes.append(contentsOf: futureProof.potentialFutureUses)
            canAffectFutureRouting = canAffectFutureRouting || futureProof.runtimeUseAllowed
        }
        if let runtimeFactoring {
            notes.append(runtimeFactoring.reason)
            canAffectFutureRouting = canAffectFutureRouting || runtimeFactoring.runtimeUseAllowed
        }

        guard let correction else {
            return CaptureRuntimeFutureUse(
                canAffectFutureRouting: canAffectFutureRouting,
                preferredGoalID: preferredGoalID,
                preferredTimeLabel: preferredTimeLabel,
                preferredActivityLabel: preferredActivityLabel,
                routingNotes: notes,
                localOnly: true
            )
        }

        notes.append(correction.kind.userFacingSummary)
        switch correction.kind {
        case .wrongActivity:
            preferredActivityLabel = correction.activityLabel ?? correction.note
            canAffectFutureRouting = true
            notes.append("Future routing should prefer the corrected activity.")
        case .wrongTime:
            preferredTimeLabel = correction.timeLabel ?? correction.note
            canAffectFutureRouting = true
            notes.append("Future routing should prefer the corrected time.")
        case .wrongGoal, .attachToDifferentGoal:
            preferredGoalID = correction.goalID
            canAffectFutureRouting = true
            notes.append("Future routing should prefer the corrected goal.")
        case .doNotUseForPlanning:
            canAffectFutureRouting = false
            notes.append("Do not use this capture for planning.")
        case .saveOnlyAsNote:
            canAffectFutureRouting = false
            notes.append("Save only as note.")
        case .deleteContext:
            canAffectFutureRouting = false
            notes.append("Delete context and stop future use.")
        }

        return CaptureRuntimeFutureUse(
            canAffectFutureRouting: canAffectFutureRouting,
            preferredGoalID: preferredGoalID,
            preferredTimeLabel: preferredTimeLabel,
            preferredActivityLabel: preferredActivityLabel,
            routingNotes: notes,
            localOnly: true
        )
    }

    func captureRuntimeUseStatus(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> CaptureRuntimeUseStatus {
        switch correction?.kind {
        case .deleteContext:
            return .deleted
        case .saveOnlyAsNote:
            return .noteOnly
        case .doNotUseForPlanning:
            return .paused
        case .wrongActivity, .wrongTime, .wrongGoal, .attachToDifferentGoal:
            return .active
        case nil:
            break
        }

        if resultState == .needsClarification {
            return .blocked
        }
        if futureUse.canAffectFutureRouting == false {
            return .paused
        }
        return .active
    }

    func captureRuntimeReceiptKind(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> CaptureRuntimeReceiptKind {
        if correction != nil {
            return .captureCorrectionApplied
        }
        if captureRuntimeUseStatus(correction: correction, futureUse: futureUse) == .paused {
            return .captureRuntimeUsePaused
        }
        if resultState == .needsClarification {
            return .captureNeedsClarification
        }
        if selectedCandidate?.target.routeType == .proofItem {
            return .captureSavedAsProof
        }
        if selectedCandidate?.target.destinationKind == .existingGoal && goalRelevanceScan?.forcedAttachmentBlocked == true {
            return .captureAttachedToGoal
        }
        if selectedCandidate?.target.routeType.captureRoute == .timeSeed {
            return .captureProposedForTime
        }
        if futureUse.canAffectFutureRouting {
            return .captureSavedAsFutureContext
        }
        return .captureReplayGenerated
    }

    func captureRuntimeCapturedText(redactions: [String]) -> String {
        guard redactions.contains("raw capture text") == false else {
            return "[redacted]"
        }
        return input.rawText
    }

    func captureRuntimeDetectedSummary(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse,
        receiptKinds: [CaptureRuntimeReceiptKind]
    ) -> [String] {
        var detected = [String]()
        detected.append("activity=\(semanticExtraction.activity.userFacingLabel)")
        if let object = semanticExtraction.object, object.isEmpty == false {
            detected.append("object=\(object)")
        }
        if let expression = semanticExtraction.dateTimeExpression, expression.isEmpty == false {
            detected.append("time=\(expression)")
        }
        if semanticExtraction.goalDomainHints.isEmpty == false {
            detected.append("goal-hints=\(semanticExtraction.goalDomainHints.map(\.userFacingLabel).joined(separator: ", "))")
        }
        if goalRelevanceScan?.hasAnyRelevantMatch == true {
            detected.append("goal-relevance=match")
        }
        if clarification != nil {
            detected.append("ambiguity=needs-clarification")
        }
        if futureUse.canAffectFutureRouting {
            detected.append("future-use=allowed")
        } else {
            detected.append("future-use=paused")
        }
        if correction != nil {
            detected.append("correction=\(correction?.kind.rawValue ?? "")")
        }
        detected.append("receipt-kind=\(receiptKinds.last?.rawValue ?? receiptRuntimeFallbackKind.rawValue)")
        return Array(Set(detected)).sorted()
    }

    func captureRuntimeWhereItWent(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> String {
        if let correction {
            switch correction.kind {
            case .wrongActivity:
                return "Corrected activity"
            case .wrongTime:
                return "Corrected time"
            case .wrongGoal, .attachToDifferentGoal:
                return "Corrected goal"
            case .doNotUseForPlanning:
                return "Planning paused"
            case .saveOnlyAsNote:
                return "Note only"
            case .deleteContext:
                return "Context deleted"
            }
        }

        if selectedCandidate?.target.routeType == .proofItem {
            return "Proof"
        }
        if selectedCandidate?.target.destinationKind == .existingGoal {
            return "Goal"
        }
        if selectedCandidate?.target.routeType.captureRoute == .timeSeed {
            return "Time"
        }
        if futureUse.canAffectFutureRouting {
            return "Future context"
        }
        return "Needs a Place"
    }

    func captureRuntimeWhatItMayAffect(
        futureUse: CaptureRuntimeFutureUse,
        correction: CaptureRuntimeCorrectionInput?
    ) -> [String] {
        var values = [String]()
        if futureUse.canAffectFutureRouting {
            values.append("future routing")
        }
        if futureUse.preferredGoalID != nil {
            values.append("goal routing")
        }
        if futureUse.preferredTimeLabel != nil {
            values.append("time routing")
        }
        if futureUse.preferredActivityLabel != nil {
            values.append("activity routing")
        }
        if correction?.kind == .doNotUseForPlanning || correction?.kind == .saveOnlyAsNote {
            values.append("planning")
        }
        if correction?.kind == .deleteContext {
            values.append("future use")
        }
        return Array(Set(values)).sorted()
    }

    func captureRuntimeWhatWasNotUsed(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> [String] {
        var values = [String]()
        if clarification != nil {
            values.append("unclear route")
        }
        if goalRelevanceScan?.weakMatches.isEmpty == false {
            values.append("weak goal matches")
        }
        if correction?.kind == .wrongActivity {
            values.append("original activity guess")
        }
        if correction?.kind == .wrongTime {
            values.append("original time guess")
        }
        if correction?.kind == .wrongGoal || correction?.kind == .attachToDifferentGoal {
            values.append("original goal guess")
        }
        if correction?.kind == .doNotUseForPlanning || correction?.kind == .saveOnlyAsNote {
            values.append("planning")
        }
        if correction?.kind == .deleteContext || futureUse.canAffectFutureRouting == false {
            values.append("future runtime use")
        }
        return Array(Set(values)).sorted()
    }

    func captureRuntimePrivacyRedactions(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> [String] {
        var values = [String]()
        if privacyLevel.requiresRedactionByDefault {
            values.append("raw capture text")
        }
        if futureProofContextCandidate?.runtimeUseAllowed == false {
            values.append("sensitive future context")
        }
        if futureProofContextCandidate?.sourceLabel.isEmpty == false {
            values.append("source label")
        }
        if goalRelevanceScan?.forcedAttachmentBlocked == true {
            values.append("goal attachment details")
        }
        if correction?.kind == .attachToDifferentGoal || correction?.kind == .wrongGoal {
            values.append("goal correction note")
        }
        if futureUse.canAffectFutureRouting == false {
            values.append("future routing note")
        }
        return Array(Set(values)).sorted()
    }

    func captureRuntimeApprovalNeeded(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> String? {
        if let scan = goalRelevanceScan, scan.forcedAttachmentBlocked {
            return scan.explanation
        }
        if futureProofContextCandidate?.runtimeUseAllowed == false {
            return "Sensitive context stays review-gated before runtime use."
        }
        if correction?.kind == .attachToDifferentGoal {
            return "Attaching to a different goal must stay user-confirmed."
        }
        if correction?.kind == .doNotUseForPlanning {
            return "Planning use is paused by the user."
        }
        if futureUse.canAffectFutureRouting == false {
            return "Future runtime use is paused."
        }
        return nil
    }

    func undoAvailability(for correction: CaptureRuntimeCorrectionInput?) -> ActionReceiptUndoAvailability {
        guard correction != nil else {
            return .notSupportedYet
        }
        switch correction?.kind {
        case .deleteContext, .doNotUseForPlanning, .saveOnlyAsNote:
            return .availableLocal
        case .wrongActivity, .wrongTime, .wrongGoal, .attachToDifferentGoal:
            return .requiresConfirmation
        case nil:
            return .notSupportedYet
        }
    }

    func receiptKind(
        for correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> CaptureRuntimeReceiptKind {
        if correction != nil {
            return .captureCorrectionApplied
        }
        if captureRuntimeUseStatus(correction: correction, futureUse: futureUse) == .paused {
            return .captureRuntimeUsePaused
        }
        if resultState == .needsClarification {
            return .captureNeedsClarification
        }
        if selectedCandidate?.target.routeType == .proofItem {
            return .captureSavedAsProof
        }
        if selectedCandidate?.target.destinationKind == .existingGoal && goalRelevanceScan?.forcedAttachmentBlocked == true {
            return .captureAttachedToGoal
        }
        if selectedCandidate?.target.routeType.captureRoute == .timeSeed {
            return .captureProposedForTime
        }
        if futureUse.canAffectFutureRouting {
            return .captureSavedAsFutureContext
        }
        return .captureReplayGenerated
    }

    func captureRuntimeDecisionSummary(
        correction: CaptureRuntimeCorrectionInput?
    ) -> String {
        if let correction {
            switch correction.kind {
            case .wrongActivity:
                return "Corrected activity"
            case .wrongTime:
                return "Corrected time"
            case .wrongGoal, .attachToDifferentGoal:
                return "Corrected goal"
            case .doNotUseForPlanning:
                return "Do not use for planning"
            case .saveOnlyAsNote:
                return "Save only as note"
            case .deleteContext:
                return "Delete context"
            }
        }

        if let selectedCandidate {
            return captureRuntimeReceiptLine(for: selectedCandidate.target, state: resultState)
        }
        return receiptLine
    }

    var receiptRuntimeFallbackKind: CaptureRuntimeReceiptKind {
        .captureReplayGenerated
    }

    func captureRuntimeReceiptLine(for target: SmartAttachmentRouteTarget, state: SmartAttachmentResultState) -> String {
        if state == .attached, target.routeType == .proofItem {
            return "Attached as Proof · \(target.destinationLabel ?? "Goal")"
        }
        if target.isNeedsPlace {
            return "Saved to Needs a Place"
        }
        return "Saved as \(target.displaySegments.joined(separator: " · "))"
    }
}

private extension CaptureRuntimeReceiptKind {
    var recognitionOrder: Int {
        switch self {
        case .captureExtracted:
            return 0
        case .captureNeedsClarification:
            return 1
        case .captureMatchedGoal:
            return 2
        case .captureWeakMatchRejected:
            return 3
        case .captureSavedAsFutureContext:
            return 4
        case .captureProposedForTime:
            return 5
        case .captureAddedToTime:
            return 6
        case .captureAttachedToGoal:
            return 7
        case .captureSavedAsProof:
            return 8
        case .captureRuntimeUsePaused:
            return 9
        case .captureCorrectionApplied:
            return 10
        case .captureReplayGenerated:
            return 11
        }
    }
}

private extension CaptureRuntimeCorrectionKind {
    var userFacingSummary: String {
        switch self {
        case .wrongActivity:
            return "Wrong activity"
        case .wrongTime:
            return "Wrong time"
        case .wrongGoal:
            return "Wrong goal"
        case .doNotUseForPlanning:
            return "Do not use for planning"
        case .saveOnlyAsNote:
            return "Save only as note"
        case .attachToDifferentGoal:
            return "Attach to different goal"
        case .deleteContext:
            return "Delete context"
        }
    }
}
