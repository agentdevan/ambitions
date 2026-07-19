import Foundation

let ambitionsOSProofTrustSchemaVersion = "ambitionsos_proof_trust.native.v1"

enum AmbitionsOSProofTrustReceiptKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case closure
    case proof
    case trustReview = "trust_review"
    case sourceChange = "source_change"
    case mutation
    case professionalBoundary = "professional_boundary"
    case correction
}

enum AmbitionsOSClosureOutcome: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case completed
    case stillCounts = "still_counts"
    case moved
    case skippedIntentionally = "skipped_intentionally"
    case notNeeded = "not_needed"
    case blocked
    case waiting
    case needsRecovery = "needs_recovery"
    case needsReview = "needs_review"
}

enum AmbitionsOSProofTrustIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case malformedReceipt = "malformed_receipt"
    case missingProofOrActionReceipt = "missing_proof_or_action_receipt"
    case sourceReviewRequired = "source_review_required"
    case staleHighRiskSource = "stale_high_risk_source"
    case professionalBoundaryReviewRequired = "professional_boundary_review_required"
    case silentMutationRisk = "silent_mutation_risk"
    case punitiveClosureLanguage = "punitive_closure_language"
    case privateExternalProjectionRisk = "private_external_projection_risk"
}

struct AmbitionsOSProofTrustReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: AmbitionsOSProofTrustReceiptKind
    let surface: AmbitionsOSControlPlaneSurface
    let occurredAt: String
    let affectedObjectIDs: [String]
    let actionReceiptIDs: [String]
    let proofReferenceIDs: [String]
    let sourceClaimIDs: [String]
    let sourcePackIDs: [String]
    let changedFactSummaries: [String]
    let closureOutcome: AmbitionsOSClosureOutcome?
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let reversible: Bool
    let professionalBoundaryReviewRequired: Bool
    let schemaVersion: String

    init(
        id: String,
        kind: AmbitionsOSProofTrustReceiptKind,
        surface: AmbitionsOSControlPlaneSurface,
        occurredAt: String,
        affectedObjectIDs: [String],
        actionReceiptIDs: [String] = [],
        proofReferenceIDs: [String] = [],
        sourceClaimIDs: [String] = [],
        sourcePackIDs: [String] = [],
        changedFactSummaries: [String] = [],
        closureOutcome: AmbitionsOSClosureOutcome? = nil,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        reversible: Bool = true,
        professionalBoundaryReviewRequired: Bool = false,
        schemaVersion: String = ambitionsOSProofTrustSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.surface = surface
        self.occurredAt = occurredAt
        self.affectedObjectIDs = Self.orderedUnique(affectedObjectIDs)
        self.actionReceiptIDs = Self.orderedUnique(actionReceiptIDs)
        self.proofReferenceIDs = Self.orderedUnique(proofReferenceIDs)
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.sourcePackIDs = Self.orderedUnique(sourcePackIDs)
        self.changedFactSummaries = Self.orderedUnique(changedFactSummaries)
        self.closureOutcome = closureOutcome
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.reversible = reversible
        self.professionalBoundaryReviewRequired = professionalBoundaryReviewRequired
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            occurredAt.isEmpty == false &&
            affectedObjectIDs.isEmpty == false &&
            schemaVersion == ambitionsOSProofTrustSchemaVersion
    }

    var hasTrustEvidence: Bool {
        actionReceiptIDs.isEmpty == false || proofReferenceIDs.isEmpty == false
    }

    var canCloseProofTrustGate: Bool {
        isWellFormed &&
            hasTrustEvidence &&
            sourceState.canDriveSourceSensitiveRecommendation &&
            freshnessState.blocksHighRiskUse == false &&
            reviewState.blocksAutomaticMutation == false &&
            professionalBoundaryReviewRequired == false &&
            privacyClass != .deletePending
    }

    var isExternalProjectionSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSClosurePromptContract: Codable, Sendable, Equatable, Hashable {
    let promptID: String
    let unresolvedStateLabel: String
    let availableOutcomes: [AmbitionsOSClosureOutcome]
    let receiptRequired: Bool

    init(
        promptID: String,
        unresolvedStateLabel: String = "Needs a quick check",
        availableOutcomes: [AmbitionsOSClosureOutcome] = AmbitionsOSClosureOutcome.allCases,
        receiptRequired: Bool = true
    ) {
        self.promptID = promptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.unresolvedStateLabel = unresolvedStateLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.availableOutcomes = Array(Set(availableOutcomes)).sorted { $0.rawValue < $1.rawValue }
        self.receiptRequired = receiptRequired
    }

    var usesNonPunitiveLanguage: Bool {
        let normalized = unresolvedStateLabel.lowercased()
        return Self.forbiddenUnresolvedLabels.allSatisfy { normalized.contains($0) == false }
    }

    private static let forbiddenUnresolvedLabels = [
        "failed",
        "missed",
        "overdue",
        "behind",
        "neglected",
        "incomplete"
    ]
}

struct AmbitionsOSProofTrustValidator: Sendable, Equatable, Hashable {
    func validate(
        receipt: AmbitionsOSProofTrustReceipt,
        closurePrompt: AmbitionsOSClosurePromptContract? = nil
    ) -> [AmbitionsOSProofTrustIssue] {
        var issues: Set<AmbitionsOSProofTrustIssue> = []

        if receipt.isWellFormed == false {
            issues.insert(.malformedReceipt)
        }
        if receipt.hasTrustEvidence == false {
            issues.insert(.missingProofOrActionReceipt)
        }
        if receipt.sourceState.canDriveSourceSensitiveRecommendation == false ||
            receipt.reviewState.blocksAutomaticMutation {
            issues.insert(.sourceReviewRequired)
        }
        if receipt.freshnessState.blocksHighRiskUse {
            issues.insert(.staleHighRiskSource)
        }
        if receipt.professionalBoundaryReviewRequired {
            issues.insert(.professionalBoundaryReviewRequired)
        }
        if receipt.kind == .mutation && receipt.reversible == false && receipt.reviewState != .ready {
            issues.insert(.silentMutationRisk)
        }
        if receipt.privacyClass == .sensitive && receipt.isExternalProjectionSafe == false {
            issues.insert(.privateExternalProjectionRisk)
        }
        if closurePrompt?.usesNonPunitiveLanguage == false {
            issues.insert(.punitiveClosureLanguage)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }
}
