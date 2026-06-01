import Foundation

let correctionFoldSchemaVersion = "correction_fold.native.v1"

enum CorrectionFoldTarget: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case captureRoute = "capture_route"
    case sourceClaim = "source_claim"
    case recommendation
    case timeFitDecision = "time_fit_decision"
    case learningInput = "learning_input"
}

enum CorrectionFoldCaptureRouteValue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case proof
    case source
    case constraint
    case commitment
    case reflection
    case heldItem = "held_item"
    case growIntoGoal = "grow_into_goal"
    case needsAPlace = "needs_a_place"
    case readyToPlace = "ready_to_place"
}

enum CorrectionFoldSourceClaimValue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case stale
    case wrongSource = "wrong_source"
    case sourceNeeded = "source_needed"
    case contradicted
    case revoked
    case reviewNeeded = "review_needed"

    var blocksRecommendationUse: Bool {
        self != .current
    }
}

enum CorrectionFoldRecommendationValue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case stillUseful = "still_useful"
    case rejectedWrongGoal = "rejected_wrong_goal"
    case rejectedWrongReason = "rejected_wrong_reason"
    case rejectedWrongTime = "rejected_wrong_time"
    case rejectedWrongContext = "rejected_wrong_context"
    case rejectedTooLarge = "rejected_too_large"
    case rejectedWrongCapacity = "rejected_wrong_capacity"
    case rejectedUnavailable = "rejected_unavailable"
    case rejectedAlreadyDone = "rejected_already_done"
    case rejectedWrongSource = "rejected_wrong_source"
    case rejectedLowEnergyContext = "rejected_low_energy_context"
    case confirmedStillCounts = "confirmed_still_counts"
    case markedBlocked = "marked_blocked"
    case markedWaiting = "marked_waiting"
    case needsRecovery = "needs_recovery"

    var isRejection: Bool {
        self != .stillUseful
    }

    var localLearningAdjustment: CorrectionFoldRecommendationLearningAdjustment {
        switch self {
        case .stillUseful:
            return .noAdjustment
        case .rejectedWrongGoal:
            return .downrankWrongGoal
        case .rejectedWrongReason:
            return .requireReasonReview
        case .rejectedWrongTime:
            return .downrankWrongTime
        case .rejectedWrongContext:
            return .downrankWrongContext
        case .rejectedTooLarge:
            return .downrankTooLarge
        case .rejectedWrongCapacity:
            return .downrankWrongCapacity
        case .rejectedUnavailable:
            return .deferUnavailable
        case .rejectedAlreadyDone:
            return .suppressCompleted
        case .rejectedWrongSource:
            return .requireSourceReview
        case .rejectedLowEnergyContext:
            return .downrankLowEnergyContext
        case .confirmedStillCounts:
            return .suppressCompleted
        case .markedBlocked:
            return .deferBlocked
        case .markedWaiting:
            return .deferWaiting
        case .needsRecovery:
            return .downrankRecoveryNeeded
        }
    }
}

enum CorrectionFoldRecommendationLearningAdjustment: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noAdjustment = "no_adjustment"
    case suppressExactRecommendation = "suppress_exact_recommendation"
    case downrankWrongGoal = "downrank_wrong_goal"
    case requireReasonReview = "require_reason_review"
    case downrankWrongTime = "downrank_wrong_time"
    case downrankWrongContext = "downrank_wrong_context"
    case downrankTooLarge = "downrank_too_large"
    case downrankWrongCapacity = "downrank_wrong_capacity"
    case deferUnavailable = "defer_unavailable"
    case suppressCompleted = "suppress_completed"
    case requireSourceReview = "require_source_review"
    case downrankLowEnergyContext = "downrank_low_energy_context"
    case deferBlocked = "defer_blocked"
    case deferWaiting = "defer_waiting"
    case downrankRecoveryNeeded = "downrank_recovery_needed"

    var baseRankAdjustment: Int {
        switch self {
        case .noAdjustment:
            return 0
        case .suppressExactRecommendation, .suppressCompleted:
            return -100
        case .requireReasonReview, .requireSourceReview:
            return -75
        case .deferUnavailable, .deferBlocked, .deferWaiting:
            return -60
        case .downrankTooLarge:
            return -40
        case .downrankWrongGoal, .downrankWrongTime, .downrankWrongContext, .downrankWrongCapacity, .downrankLowEnergyContext, .downrankRecoveryNeeded:
            return -30
        }
    }

    var suppressesEligibleRecommendation: Bool {
        switch self {
        case .suppressExactRecommendation, .suppressCompleted:
            return true
        case .noAdjustment, .downrankWrongGoal, .requireReasonReview, .downrankWrongTime, .downrankWrongContext, .downrankTooLarge, .downrankWrongCapacity, .deferUnavailable, .requireSourceReview, .downrankLowEnergyContext, .deferBlocked, .deferWaiting, .downrankRecoveryNeeded:
            return false
        }
    }
}

struct CorrectionFoldRecommendationLearningInfluence: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let correctionRecordID: String
    let recommendationID: String
    let rejectionReason: CorrectionFoldRecommendationValue
    let adjustment: CorrectionFoldRecommendationLearningAdjustment
    let similarRecommendationSignalKeys: [String]
    let explanation: String
    let receiptID: String
    let localOnly: Bool
    let resetDeleteCompatible: Bool
    let permitsSilentMutation: Bool
    let schemaVersion: String

    init?(
        correction: CorrectionFoldRecord,
        similarRecommendationSignalKeys: [String] = [],
        schemaVersion: String = correctionFoldSchemaVersion
    ) {
        guard correction.target == .recommendation,
              correction.allowsFutureLearning,
              correction.effect == .suppressRecommendation,
              let reason = correction.correctedRecommendation,
              reason.isRejection
        else {
            return nil
        }

        self.id = "learning.\(correction.id)"
        self.correctionRecordID = correction.id
        self.recommendationID = correction.sourceObjectID
        self.rejectionReason = reason
        self.adjustment = reason.localLearningAdjustment
        self.similarRecommendationSignalKeys = Self.orderedUnique(similarRecommendationSignalKeys)
        self.explanation = Self.explanation(for: reason)
        self.receiptID = correction.receipt.id
        self.localOnly = correction.receipt.localOnly
        self.resetDeleteCompatible = true
        self.permitsSilentMutation = false
        self.schemaVersion = schemaVersion
    }

    var isInspectableAndControllable: Bool {
        correctionRecordID.isEmpty == false &&
            recommendationID.isEmpty == false &&
            explanation.isEmpty == false &&
            receiptID.isEmpty == false &&
            localOnly &&
            resetDeleteCompatible &&
            permitsSilentMutation == false &&
            schemaVersion == correctionFoldSchemaVersion
    }

    var sourceRecordInspectionLabel: String {
        "SourceRecord remains tied to the local correction receipt \(receiptID)."
    }

    var replayTraceInspectionLabel: String {
        "ReplayTrace stays local and replayable before this correction changes future ranking."
    }

    func rankAdjustment(
        for candidateRecommendationID: String,
        candidateSignalKeys: [String] = []
    ) -> Int {
        if candidateRecommendationID == recommendationID {
            return CorrectionFoldRecommendationLearningAdjustment.suppressExactRecommendation.baseRankAdjustment
        }

        let candidateSignals = Set(Self.orderedUnique(candidateSignalKeys))
        let rejectedSignals = Set(similarRecommendationSignalKeys)
        if candidateSignals.isEmpty == false && rejectedSignals.isDisjoint(with: candidateSignals) == false {
            return adjustment.baseRankAdjustment
        }

        return 0
    }

    func suppresses(
        candidateRecommendationID: String,
        candidateSignalKeys: [String] = []
    ) -> Bool {
        rankAdjustment(for: candidateRecommendationID, candidateSignalKeys: candidateSignalKeys) <=
            CorrectionFoldRecommendationLearningAdjustment.suppressExactRecommendation.baseRankAdjustment ||
            (adjustment.suppressesEligibleRecommendation &&
                rankAdjustment(for: candidateRecommendationID, candidateSignalKeys: candidateSignalKeys) < 0)
    }

    private static func explanation(for reason: CorrectionFoldRecommendationValue) -> String {
        switch reason {
        case .stillUseful:
            return "No rejection learning is applied."
        case .rejectedWrongGoal:
            return "Similar recommendations should be lower until the goal fit is reviewed."
        case .rejectedWrongReason:
            return "Similar recommendations should wait for reason review before they guide behavior."
        case .rejectedWrongTime:
            return "Similar recommendations should be lower when the time fit looks the same."
        case .rejectedWrongContext:
            return "Similar recommendations should be lower when the context looks the same."
        case .rejectedTooLarge:
            return "Similar recommendations should be smaller before they rise again."
        case .rejectedWrongCapacity:
            return "Similar recommendations should be lower when capacity looks the same."
        case .rejectedUnavailable:
            return "Similar recommendations should wait while the needed source, person, place, or material is unavailable."
        case .rejectedAlreadyDone:
            return "The rejected recommendation should stay suppressed as already handled."
        case .rejectedWrongSource:
            return "Similar recommendations should wait for source review before they guide behavior."
        case .rejectedLowEnergyContext:
            return "Similar recommendations should be lower when the energy or context fit looks the same."
        case .confirmedStillCounts:
            return "The recommendation should be treated as already meaningfully handled because the user said Still Counts."
        case .markedBlocked:
            return "Similar recommendations should wait until the blocker changes."
        case .markedWaiting:
            return "Similar recommendations should stay out of urgent execution while this is waiting."
        case .needsRecovery:
            return "Similar recommendations should be lighter until recovery is handled."
        }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

enum CorrectionFoldTimeFitValue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fitsNow = "fits_now"
    case tooLargeForOpenTime = "too_large_for_open_time"
    case protectedTimeConflict = "protected_time_conflict"
    case wrongEnergy = "wrong_energy"
    case needsReflow = "needs_reflow"
    case deferUntilLater = "defer_until_later"

    var requiresFitReview: Bool {
        self != .fitsNow
    }
}

enum CorrectionFoldLearningInputValue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case use
    case ignore
    case reset
    case delete
    case disableSignal = "disable_signal"

    var removesLearningUse: Bool {
        switch self {
        case .use:
            return false
        case .ignore, .reset, .delete, .disableSignal:
            return true
        }
    }
}

enum CorrectionFoldEffect: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noChange = "no_change"
    case rerouteCapture = "reroute_capture"
    case markSourceForReview = "mark_source_for_review"
    case suppressRecommendation = "suppress_recommendation"
    case requireTimeFitReview = "require_time_fit_review"
    case removeLearningInput = "remove_learning_input"
}

enum CorrectionFoldReceiptAction: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case corrected
    case ignored
    case reset
    case disabled
}

struct CorrectionFoldReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let target: CorrectionFoldTarget
    let action: CorrectionFoldReceiptAction
    let sourceObjectID: String
    let beforeValue: String
    let afterValue: String
    let reason: String
    let occurredAt: String
    let localOnly: Bool
    let schemaVersion: String

    init(
        id: String,
        target: CorrectionFoldTarget,
        action: CorrectionFoldReceiptAction,
        sourceObjectID: String,
        beforeValue: String,
        afterValue: String,
        reason: String,
        occurredAt: String,
        localOnly: Bool = true,
        schemaVersion: String = correctionFoldSchemaVersion
    ) {
        self.id = Self.trim(id)
        self.target = target
        self.action = action
        self.sourceObjectID = Self.trim(sourceObjectID)
        self.beforeValue = Self.trim(beforeValue)
        self.afterValue = Self.trim(afterValue)
        self.reason = Self.trim(reason)
        self.occurredAt = Self.trim(occurredAt)
        self.localOnly = localOnly
        self.schemaVersion = Self.trim(schemaVersion)
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            sourceObjectID.isEmpty == false &&
            beforeValue.isEmpty == false &&
            afterValue.isEmpty == false &&
            reason.isEmpty == false &&
            occurredAt.isEmpty == false &&
            localOnly &&
            schemaVersion == correctionFoldSchemaVersion
    }

    private static func trim(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct CorrectionFoldRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let target: CorrectionFoldTarget
    let sourceObjectID: String
    let originalValue: String
    let correctedValue: String
    let reason: String
    let occurredAt: String
    let allowsFutureLearning: Bool
    let receipt: CorrectionFoldReceipt
    let schemaVersion: String

    init(
        id: String,
        target: CorrectionFoldTarget,
        sourceObjectID: String,
        originalValue: String,
        correctedValue: String,
        reason: String,
        occurredAt: String,
        allowsFutureLearning: Bool = false,
        schemaVersion: String = correctionFoldSchemaVersion
    ) {
        let normalizedID = Self.trim(id)
        let normalizedOriginal = Self.trim(originalValue)
        let normalizedCorrected = Self.trim(correctedValue)
        let normalizedReason = Self.trim(reason)
        let normalizedOccurredAt = Self.trim(occurredAt)

        self.id = normalizedID
        self.target = target
        self.sourceObjectID = Self.trim(sourceObjectID)
        self.originalValue = normalizedOriginal
        self.correctedValue = normalizedCorrected
        self.reason = normalizedReason
        self.occurredAt = normalizedOccurredAt
        self.allowsFutureLearning = allowsFutureLearning
        self.schemaVersion = Self.trim(schemaVersion)
        self.receipt = CorrectionFoldReceipt(
            id: "receipt.\(normalizedID)",
            target: target,
            action: Self.receiptAction(target: target, correctedValue: normalizedCorrected),
            sourceObjectID: Self.trim(sourceObjectID),
            beforeValue: normalizedOriginal,
            afterValue: normalizedCorrected,
            reason: normalizedReason,
            occurredAt: normalizedOccurredAt
        )
    }

    static func captureRoute(
        id: String,
        captureID: String,
        from original: CorrectionFoldCaptureRouteValue,
        to corrected: CorrectionFoldCaptureRouteValue,
        reason: String,
        occurredAt: String,
        allowsFutureLearning: Bool = false
    ) -> CorrectionFoldRecord {
        CorrectionFoldRecord(
            id: id,
            target: .captureRoute,
            sourceObjectID: captureID,
            originalValue: original.rawValue,
            correctedValue: corrected.rawValue,
            reason: reason,
            occurredAt: occurredAt,
            allowsFutureLearning: allowsFutureLearning
        )
    }

    static func sourceClaim(
        id: String,
        claimID: String,
        from original: CorrectionFoldSourceClaimValue,
        to corrected: CorrectionFoldSourceClaimValue,
        reason: String,
        occurredAt: String
    ) -> CorrectionFoldRecord {
        CorrectionFoldRecord(
            id: id,
            target: .sourceClaim,
            sourceObjectID: claimID,
            originalValue: original.rawValue,
            correctedValue: corrected.rawValue,
            reason: reason,
            occurredAt: occurredAt
        )
    }

    static func recommendation(
        id: String,
        recommendationID: String,
        from original: CorrectionFoldRecommendationValue,
        to corrected: CorrectionFoldRecommendationValue,
        reason: String,
        occurredAt: String,
        allowsFutureLearning: Bool = true
    ) -> CorrectionFoldRecord {
        CorrectionFoldRecord(
            id: id,
            target: .recommendation,
            sourceObjectID: recommendationID,
            originalValue: original.rawValue,
            correctedValue: corrected.rawValue,
            reason: reason,
            occurredAt: occurredAt,
            allowsFutureLearning: allowsFutureLearning
        )
    }

    static func timeFitDecision(
        id: String,
        decisionID: String,
        from original: CorrectionFoldTimeFitValue,
        to corrected: CorrectionFoldTimeFitValue,
        reason: String,
        occurredAt: String
    ) -> CorrectionFoldRecord {
        CorrectionFoldRecord(
            id: id,
            target: .timeFitDecision,
            sourceObjectID: decisionID,
            originalValue: original.rawValue,
            correctedValue: corrected.rawValue,
            reason: reason,
            occurredAt: occurredAt
        )
    }

    static func learningInput(
        id: String,
        learningInputID: String,
        from original: CorrectionFoldLearningInputValue,
        to corrected: CorrectionFoldLearningInputValue,
        reason: String,
        occurredAt: String
    ) -> CorrectionFoldRecord {
        CorrectionFoldRecord(
            id: id,
            target: .learningInput,
            sourceObjectID: learningInputID,
            originalValue: original.rawValue,
            correctedValue: corrected.rawValue,
            reason: reason,
            occurredAt: occurredAt,
            allowsFutureLearning: false
        )
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            sourceObjectID.isEmpty == false &&
            originalValue.isEmpty == false &&
            correctedValue.isEmpty == false &&
            reason.isEmpty == false &&
            occurredAt.isEmpty == false &&
            schemaVersion == correctionFoldSchemaVersion &&
            receipt.isWellFormed
    }

    var effect: CorrectionFoldEffect {
        if originalValue == correctedValue {
            return .noChange
        }

        switch target {
        case .captureRoute:
            return .rerouteCapture
        case .sourceClaim:
            return correctedSourceClaim?.blocksRecommendationUse == true ? .markSourceForReview : .noChange
        case .recommendation:
            return correctedRecommendation?.isRejection == true ? .suppressRecommendation : .noChange
        case .timeFitDecision:
            return correctedTimeFit?.requiresFitReview == true ? .requireTimeFitReview : .noChange
        case .learningInput:
            return correctedLearningInput?.removesLearningUse == true ? .removeLearningInput : .noChange
        }
    }

    var correctedCaptureRoute: CorrectionFoldCaptureRouteValue? {
        CorrectionFoldCaptureRouteValue(rawValue: correctedValue)
    }

    var correctedSourceClaim: CorrectionFoldSourceClaimValue? {
        CorrectionFoldSourceClaimValue(rawValue: correctedValue)
    }

    var correctedRecommendation: CorrectionFoldRecommendationValue? {
        CorrectionFoldRecommendationValue(rawValue: correctedValue)
    }

    var correctedTimeFit: CorrectionFoldTimeFitValue? {
        CorrectionFoldTimeFitValue(rawValue: correctedValue)
    }

    var correctedLearningInput: CorrectionFoldLearningInputValue? {
        CorrectionFoldLearningInputValue(rawValue: correctedValue)
    }

    var requiresUserVisibleReceipt: Bool {
        effect != .noChange
    }

    var permitsSilentMutation: Bool {
        false
    }

    private static func receiptAction(
        target: CorrectionFoldTarget,
        correctedValue: String
    ) -> CorrectionFoldReceiptAction {
        guard target == .learningInput,
              let learningValue = CorrectionFoldLearningInputValue(rawValue: correctedValue)
        else {
            return .corrected
        }

        switch learningValue {
        case .ignore:
            return .ignored
        case .reset, .delete:
            return .reset
        case .disableSignal:
            return .disabled
        case .use:
            return .corrected
        }
    }

    private static func trim(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
