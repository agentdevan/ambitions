import AmbitionsDesignSystem
import Foundation

let reviewsV1SchemaVersion = "reviews_v1.native.v1"

enum ReviewItemKind: String, Sendable, Equatable, Hashable, CaseIterable {
    case event
    case recovery
    case receipt
    case proof
    case correction
    case carryForward = "carry_forward"
    case trustNote = "trust_note"
}

enum ReviewCadenceKind: String, Sendable, Equatable, Hashable, CaseIterable {
    case weekly
    case monthly
    case recovery
}

struct ReviewPeriodSummary: Sendable, Equatable {
    let title: String
    let subtitle: String
    let timeframeLabel: String
    let dominantTruth: String
    let trustWhisper: String
    let state: AmbitionVisualState
}

struct ReviewSignalItem: Identifiable, Sendable, Equatable {
    let id: String
    let kind: ReviewItemKind
    let title: String
    let detail: String
    let valueLabel: String
    let icon: String
    let state: AmbitionVisualState
}

struct ReviewCadenceSummary: Identifiable, Sendable, Equatable {
    let id: String
    let cadence: ReviewCadenceKind
    let title: String
    let detail: String
    let statusLabel: String
    let contextLabel: String
    let state: AmbitionVisualState
}

struct RecoveryReviewSummary: Sendable, Equatable {
    let title: String
    let subtitle: String
    let statusLabel: String
    let whatRecovered: [ReviewSignalItem]
    let whatWasProtected: [ReviewSignalItem]
    let needsReview: [ReviewSignalItem]
    let boundaryNotes: [String]
    let emptyStateTitle: String
    let emptyStateDetail: String
}

struct LifeOSReceiptSummary: Sendable, Equatable {
    let title: String
    let subtitle: String
    let statusLabel: String
    let receiptHighlights: [ReviewSignalItem]
    let meaningfulEvents: [ReviewSignalItem]
    let emptyStateTitle: String
    let emptyStateDetail: String
}

struct LifeOSReceiptProgressLine: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let sourceLabel: String
    let privacyLabel: String
    let state: AmbitionVisualState
}

struct ReviewProofHighlight: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let valueLabel: String
    let state: AmbitionVisualState
}

struct ReviewCorrectionPrompt: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let actionLabel: String
    let state: AmbitionVisualState
}

struct ReviewCarryForwardItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let actionLabel: String
    let state: AmbitionVisualState
}

struct ReviewPlanningHandoff: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let destinationLabel: String
    let safetyLabel: String
    let state: AmbitionVisualState
}

struct ReviewsV1Projection: Sendable, Equatable {
    let id: String
    let generatedAt: String
    let period: ReviewPeriodSummary
    let cadences: [ReviewCadenceSummary]
    let recovery: RecoveryReviewSummary
    let lifeOSReceipt: LifeOSReceiptSummary
    let progressLines: [LifeOSReceiptProgressLine]
    let proofHighlights: [ReviewProofHighlight]
    let correctionPrompts: [ReviewCorrectionPrompt]
    let carryForward: [ReviewCarryForwardItem]
    let planningHandoffs: [ReviewPlanningHandoff]
    let unavailableNotes: [ReviewSignalItem]
    let eventLedgerEntryIDs: [String]
    let receiptIDs: [String]
    let localOnly: Bool
    let schemaVersion: String

    var isEmpty: Bool {
        recovery.whatRecovered.isEmpty &&
            recovery.whatWasProtected.isEmpty &&
            recovery.needsReview.isEmpty &&
            lifeOSReceipt.receiptHighlights.isEmpty &&
            lifeOSReceipt.meaningfulEvents.isEmpty &&
            progressLines.isEmpty &&
            proofHighlights.isEmpty &&
            correctionPrompts.isEmpty
    }
}

struct ReviewsV1ProjectionInput: Sendable, Equatable {
    let generatedAt: String
    let timeframeLabel: String
    let eventLedgerEntries: [EventLedgerEntry]
    let receipts: [ActionReceipt]
    let resilienceAssessments: [ExecutionResilienceAssessment]
    let proofEvidence: [ProgressEvidence]
    let teachingSignals: [GoalTeachingSignal]
    let recommendationExplanations: [RecommendationExplanation]
    let calendarStatusLabel: String?

    init(
        generatedAt: String,
        timeframeLabel: String = "Recent review",
        eventLedgerEntries: [EventLedgerEntry] = [],
        receipts: [ActionReceipt] = [],
        resilienceAssessments: [ExecutionResilienceAssessment] = [],
        proofEvidence: [ProgressEvidence] = [],
        teachingSignals: [GoalTeachingSignal] = [],
        recommendationExplanations: [RecommendationExplanation] = [],
        calendarStatusLabel: String? = nil
    ) {
        self.generatedAt = generatedAt
        self.timeframeLabel = timeframeLabel
        self.eventLedgerEntries = eventLedgerEntries
        self.receipts = receipts
        self.resilienceAssessments = resilienceAssessments
        self.proofEvidence = proofEvidence
        self.teachingSignals = teachingSignals
        self.recommendationExplanations = recommendationExplanations
        self.calendarStatusLabel = calendarStatusLabel
    }
}
