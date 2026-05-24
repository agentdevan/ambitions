import Foundation

enum CaptureRuntimeFactoringCandidateType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case step
    case scheduledActivity = "scheduled_activity"
    case proof
    case lifeContext = "life_context"
    case historicalContext = "historical_context"
    case facilityAccess = "facility_access"
    case equipmentAccess = "equipment_access"
    case blocker
    case opportunity
    case recovery
    case recurringCommitment = "recurring_commitment"
    case goalSeed = "goal_seed"
    case decideLater = "decide_later"

    var displayTitle: String {
        switch self {
        case .step:
            return "Step"
        case .scheduledActivity:
            return "Scheduled activity"
        case .proof:
            return "Proof"
        case .lifeContext:
            return "Life context"
        case .historicalContext:
            return "Historical context"
        case .facilityAccess:
            return "Facility access"
        case .equipmentAccess:
            return "Equipment access"
        case .blocker:
            return "Blocker"
        case .opportunity:
            return "Opportunity"
        case .recovery:
            return "Recovery"
        case .recurringCommitment:
            return "Recurring commitment"
        case .goalSeed:
            return "Goal seed"
        case .decideLater:
            return "Decide later"
        }
    }
}

enum FutureProofContextCategory: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case activityHistory = "activity_history"
    case facilityAccess = "facility_access"
    case equipmentAccess = "equipment_access"
    case accessConstraint = "access_constraint"
    case scheduleDrift = "schedule_drift"
    case recurringCommitment = "recurring_commitment"
    case recoveryConstraint = "recovery_constraint"
    case skillContext = "skill_context"
    case lifeContext = "life_context"
    case historicalContext = "historical_context"
    case goalSeed = "goal_seed"
    case opportunity
    case decideLater = "decide_later"

    var displayTitle: String {
        switch self {
        case .activityHistory:
            return "Activity history"
        case .facilityAccess:
            return "Facility access"
        case .equipmentAccess:
            return "Equipment access"
        case .accessConstraint:
            return "Access constraint"
        case .scheduleDrift:
            return "Schedule drift"
        case .recurringCommitment:
            return "Recurring commitment"
        case .recoveryConstraint:
            return "Recovery constraint"
        case .skillContext:
            return "Skill context"
        case .lifeContext:
            return "Life context"
        case .historicalContext:
            return "Historical context"
        case .goalSeed:
            return "Goal seed"
        case .opportunity:
            return "Opportunity"
        case .decideLater:
            return "Decide later"
        }
    }
}

struct CaptureRuntimeFactoringCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let captureID: String
    let candidateType: CaptureRuntimeFactoringCandidateType
    let suggestedDestination: String
    let runtimeUseAllowed: Bool
    let requiresApproval: Bool
    let sourceFreshness: LifeContextFreshness
    let sensitivity: HistoricalContextFactSensitivity
    let reason: String
    let rejectedReason: String?

    var id: String {
        "\(captureID).\(candidateType.rawValue)"
    }
}

struct FutureProofContextCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let captureID: String
    let contextCategory: FutureProofContextCategory
    let potentialFutureUses: [String]
    let sourceLabel: String
    let freshness: LifeContextFreshness
    let reviewNeeded: Bool
    let runtimeUseAllowed: Bool
    let visibleInYou: Bool
    let deletionSupported: Bool

    var id: String {
        "\(captureID).\(contextCategory.rawValue)"
    }
}

extension SmartAttachmentResult {
    var captureRuntimeFactoringCandidate: CaptureRuntimeFactoringCandidate? {
        FutureProofContextClassifier.captureRuntimeFactoringCandidate(from: self)
    }

    var futureProofContextCandidate: FutureProofContextCandidate? {
        FutureProofContextClassifier.futureProofContextCandidate(from: self)
    }
}

enum FutureProofContextClassifier {
    static func captureRuntimeFactoringCandidate(from result: SmartAttachmentResult) -> CaptureRuntimeFactoringCandidate? {
        guard result.goalRelevanceScan?.hasAnyRelevantMatch != true else {
            return nil
        }

        let extraction = result.semanticExtraction
        let normalized = extraction.normalizedText
        let sourceLabel = result.input.sourceContext?.sourceType?.title ?? "Capture"

        if extraction.recoverySignal || containsAny(normalized, ["hurt", "injury", "sore", "recover", "recovery", "rest"]) {
            return makePair(
                captureID: result.id,
                candidateType: .recovery,
                contextCategory: .recoveryConstraint,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: false,
                requiresApproval: true,
                sourceFreshness: .mayNeedReview,
                sensitivity: .sensitive,
                reason: "The capture preserves sensitive recovery context that should stay review-gated before runtime use.",
                rejectedReason: "Sensitive recovery context requires approval before runtime use.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "recovery-aware planning",
                    "approval-gated runtime use"
                ],
                reviewNeeded: true
            ).runtimeCandidate
        }

        if containsAny(normalized, ["trail closed", "closed trail", "mountain bike trail closed"]) ||
            (extraction.blockerSignal && containsAny(normalized, ["trail", "court", "ymca"])) {
            return makePair(
                captureID: result.id,
                candidateType: .blocker,
                contextCategory: .accessConstraint,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture records an access constraint that can help future planning avoid the same dead end.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "access constraint review",
                    "future opportunity filtering"
                ],
                reviewNeeded: true
            ).runtimeCandidate
        }

        if extraction.facilityHint != nil,
           containsAny(normalized, ["ymca", "open court", "court", "gym", "field", "trail"]) {
            return makePair(
                captureID: result.id,
                candidateType: .facilityAccess,
                contextCategory: .facilityAccess,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture preserves facility access context for future planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "facility access checks",
                    "go / no-go planning"
                ],
                reviewNeeded: false
            ).runtimeCandidate
        } else if extraction.equipmentHint != nil {
            return makePair(
                captureID: result.id,
                candidateType: .equipmentAccess,
                contextCategory: .equipmentAccess,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture keeps equipment access visible for future planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "equipment planning",
                    "future step feasibility"
                ],
                reviewNeeded: false
            ).runtimeCandidate
        }

        if extraction.recurrenceHint != nil || containsAny(normalized, ["weekly", "every "]) {
            let category: FutureProofContextCategory = extraction.activity == .learning ? .skillContext : .recurringCommitment
            return makePair(
                captureID: result.id,
                candidateType: .recurringCommitment,
                contextCategory: category,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture names a recurring commitment that can stay visible in the local life graph.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "recurring planning",
                    "skill practice context"
                ],
                reviewNeeded: false
            ).runtimeCandidate
        }

        if containsAny(normalized, ["worked late again", "late again", "worked late"]) ||
            (extraction.activity == .work && extraction.blockerSignal && containsAny(normalized, ["late", "over time"])) {
            return makePair(
                captureID: result.id,
                candidateType: .scheduledActivity,
                contextCategory: .scheduleDrift,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture preserves schedule drift and capacity pressure for future planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "capacity-aware planning",
                    "future schedule planning"
                ],
                reviewNeeded: true
            ).runtimeCandidate
        }

        if containsAny(normalized, ["pickleball", "activity history"]) || extraction.activity == .exercise {
            return makePair(
                captureID: result.id,
                candidateType: .historicalContext,
                contextCategory: .activityHistory,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture records an activity history signal that can help future fitness or social planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "future fitness planning",
                    "social context",
                    "activity history"
                ],
                reviewNeeded: false
            ).runtimeCandidate
        }

        if extraction.proofSignal {
            return makePair(
                captureID: result.id,
                candidateType: .proof,
                contextCategory: .historicalContext,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture is proof that can ground future planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "proof review",
                    "future planning references"
                ],
                reviewNeeded: false
            ).runtimeCandidate
        }

        if extraction.actionVerb != nil || extraction.object != nil || extraction.goalDomainHints.isEmpty == false {
            return makePair(
                captureID: result.id,
                candidateType: .step,
                contextCategory: .lifeContext,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture looks like a useful future step or context note.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "future step planning",
                    "runtime fit checks"
                ],
                reviewNeeded: false
            ).runtimeCandidate
        }

        return makePair(
            captureID: result.id,
            candidateType: .decideLater,
            contextCategory: .decideLater,
            suggestedDestination: "Capture",
            runtimeUseAllowed: false,
            requiresApproval: false,
            sourceFreshness: .basedOnOlderContext,
            sensitivity: .normal,
            reason: "The capture is still useful, but it needs a later review before runtime use.",
            rejectedReason: "Not enough signal yet to promote this capture into future runtime use.",
            sourceLabel: sourceLabel,
            potentialFutureUses: [
                "manual review",
                "later classification"
            ],
            reviewNeeded: true
        ).runtimeCandidate
    }

    static func futureProofContextCandidate(from result: SmartAttachmentResult) -> FutureProofContextCandidate? {
        guard result.goalRelevanceScan?.hasAnyRelevantMatch != true else {
            return nil
        }

        let extraction = result.semanticExtraction
        let normalized = extraction.normalizedText
        let sourceLabel = result.input.sourceContext?.sourceType?.title ?? "Capture"

        if extraction.recoverySignal || containsAny(normalized, ["hurt", "injury", "sore", "recover", "recovery", "rest"]) {
            return makePair(
                captureID: result.id,
                candidateType: .recovery,
                contextCategory: .recoveryConstraint,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: false,
                requiresApproval: true,
                sourceFreshness: .mayNeedReview,
                sensitivity: .sensitive,
                reason: "The capture preserves sensitive recovery context that should stay review-gated before runtime use.",
                rejectedReason: "Sensitive recovery context requires approval before runtime use.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "recovery-aware planning",
                    "approval-gated runtime use"
                ],
                reviewNeeded: true
            ).futureProofCandidate
        }

        if containsAny(normalized, ["trail closed", "closed trail", "mountain bike trail closed"]) ||
            (extraction.blockerSignal && containsAny(normalized, ["trail", "court", "ymca"])) {
            return makePair(
                captureID: result.id,
                candidateType: .blocker,
                contextCategory: .accessConstraint,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture records an access constraint that can help future planning avoid the same dead end.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "access constraint review",
                    "future opportunity filtering"
                ],
                reviewNeeded: true
            ).futureProofCandidate
        }

        if extraction.facilityHint != nil,
           containsAny(normalized, ["ymca", "open court", "court", "gym", "field", "trail"]) {
            return makePair(
                captureID: result.id,
                candidateType: .facilityAccess,
                contextCategory: .facilityAccess,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture preserves facility access context for future planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "facility access checks",
                    "go / no-go planning"
                ],
                reviewNeeded: false
            ).futureProofCandidate
        }

        if extraction.equipmentHint != nil {
            return makePair(
                captureID: result.id,
                candidateType: .equipmentAccess,
                contextCategory: .equipmentAccess,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture keeps equipment access visible for future planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "equipment planning",
                    "future step feasibility"
                ],
                reviewNeeded: false
            ).futureProofCandidate
        }

        if extraction.recurrenceHint != nil || containsAny(normalized, ["weekly", "every "]) {
            let category: FutureProofContextCategory = extraction.activity == .learning ? .skillContext : .recurringCommitment
            return makePair(
                captureID: result.id,
                candidateType: .recurringCommitment,
                contextCategory: category,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture names a recurring commitment that can stay visible in the local life graph.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "recurring planning",
                    "skill practice context"
                ],
                reviewNeeded: false
            ).futureProofCandidate
        }

        if containsAny(normalized, ["worked late again", "late again", "worked late"]) ||
            (extraction.activity == .work && extraction.blockerSignal && containsAny(normalized, ["late", "over time"])) {
            return makePair(
                captureID: result.id,
                candidateType: .scheduledActivity,
                contextCategory: .scheduleDrift,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture preserves schedule drift and capacity pressure for future planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "capacity-aware planning",
                    "future schedule planning"
                ],
                reviewNeeded: true
            ).futureProofCandidate
        }

        if containsAny(normalized, ["pickleball", "activity history"]) || extraction.activity == .exercise {
            return makePair(
                captureID: result.id,
                candidateType: .historicalContext,
                contextCategory: .activityHistory,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture records an activity history signal that can help future fitness or social planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "future fitness planning",
                    "social context",
                    "activity history"
                ],
                reviewNeeded: false
            ).futureProofCandidate
        }

        if extraction.proofSignal {
            return makePair(
                captureID: result.id,
                candidateType: .proof,
                contextCategory: .historicalContext,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture is proof that can ground future planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "proof review",
                    "future planning references"
                ],
                reviewNeeded: false
            ).futureProofCandidate
        }

        if extraction.actionVerb != nil || extraction.object != nil || extraction.goalDomainHints.isEmpty == false {
            return makePair(
                captureID: result.id,
                candidateType: .step,
                contextCategory: .lifeContext,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture looks like a useful future step or context note.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "future step planning",
                    "runtime fit checks"
                ],
                reviewNeeded: false
            ).futureProofCandidate
        }

        return makePair(
            captureID: result.id,
            candidateType: .decideLater,
            contextCategory: .decideLater,
            suggestedDestination: "Capture",
            runtimeUseAllowed: false,
            requiresApproval: false,
            sourceFreshness: .basedOnOlderContext,
            sensitivity: .normal,
            reason: "The capture is still useful, but it needs a later review before runtime use.",
            rejectedReason: "Not enough signal yet to promote this capture into future runtime use.",
            sourceLabel: sourceLabel,
            potentialFutureUses: [
                "manual review",
                "later classification"
            ],
            reviewNeeded: true
        ).futureProofCandidate
    }

    private static func makePair(
        captureID: String,
        candidateType: CaptureRuntimeFactoringCandidateType,
        contextCategory: FutureProofContextCategory,
        suggestedDestination: String,
        runtimeUseAllowed: Bool,
        requiresApproval: Bool,
        sourceFreshness: LifeContextFreshness,
        sensitivity: HistoricalContextFactSensitivity,
        reason: String,
        rejectedReason: String? = nil,
        sourceLabel: String,
        potentialFutureUses: [String],
        reviewNeeded: Bool
    ) -> (runtimeCandidate: CaptureRuntimeFactoringCandidate, futureProofCandidate: FutureProofContextCandidate) {
        let runtimeCandidate = CaptureRuntimeFactoringCandidate(
            captureID: captureID,
            candidateType: candidateType,
            suggestedDestination: suggestedDestination,
            runtimeUseAllowed: runtimeUseAllowed,
            requiresApproval: requiresApproval,
            sourceFreshness: sourceFreshness,
            sensitivity: sensitivity,
            reason: reason,
            rejectedReason: rejectedReason
        )
        let futureProofCandidate = FutureProofContextCandidate(
            captureID: captureID,
            contextCategory: contextCategory,
            potentialFutureUses: potentialFutureUses,
            sourceLabel: sourceLabel,
            freshness: sourceFreshness,
            reviewNeeded: reviewNeeded,
            runtimeUseAllowed: runtimeUseAllowed,
            visibleInYou: true,
            deletionSupported: true
        )
        return (runtimeCandidate, futureProofCandidate)
    }

    private static func containsAny(_ text: String, _ values: [String]) -> Bool {
        values.contains { text.contains($0) }
    }
}
