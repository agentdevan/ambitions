import Foundation

enum RecommendationTrustSeamSectionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case ready
    case reviewNeeded = "review_needed"
    case blocked
    case missing
    case notApplicable = "not_applicable"
}

enum RecommendationTrustSeamSectionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case source
    case reason
    case fit
    case uncertainty
    case controls
    case receiptBehavior = "receipt_behavior"
}

struct RecommendationTrustSeamSection: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: RecommendationTrustSeamSectionKind
    let title: String
    let summary: String
    let state: RecommendationTrustSeamSectionState
    let referenceIDs: [String]
}

struct RecommendationTrustSeamState: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let traceID: String
    let recommendationID: String
    let sections: [RecommendationTrustSeamSection]
    let canProceed: Bool
    let needsReview: Bool
    let localOnlyLabel: String

    init(trace: RecommendationTrace) {
        let sections = [
            Self.sourceSection(trace.source),
            Self.reasonSection(trace.reason),
            Self.fitSection(trace.fit),
            Self.uncertaintySection(trace.uncertainty),
            Self.controlsSection(trace.control),
            Self.receiptSection(trace.receiptBehavior)
        ]
        self.id = "trust-seam.\(trace.id)"
        self.traceID = trace.id
        self.recommendationID = trace.recommendationID
        self.sections = sections
        self.canProceed = trace.canDriveRecommendationBehavior
        self.needsReview = trace.canDriveRecommendationBehavior == false ||
            sections.contains { $0.state != .ready && $0.state != .notApplicable }
        self.localOnlyLabel = "Local-only"
    }

    var sectionKinds: [RecommendationTrustSeamSectionKind] {
        sections.map(\.kind)
    }

    var visibleCopy: [String] {
        sections.flatMap { [$0.title, $0.summary] } + [localOnlyLabel]
    }

    var hasVisibleCopyGuardrailViolation: Bool {
        let blockedPhrases = [
            "ai ",
            "assistant",
            "confidence",
            "best " + "next " + "move",
            "next " + "best " + "move",
            "dash" + "board"
        ]
        return visibleCopy.contains { text in
            let lowercased = text.lowercased()
            return blockedPhrases.contains { lowercased.contains($0) } ||
                text.contains("%")
        }
    }

    func section(_ kind: RecommendationTrustSeamSectionKind) -> RecommendationTrustSeamSection? {
        sections.first { $0.kind == kind }
    }

    static func sourceSection(_ source: RecommendationTraceSource) -> RecommendationTrustSeamSection {
        let references = orderedUnique(source.citedSourceIDs + source.localEvidenceCategories.map(\.rawValue))
        let state: RecommendationTrustSeamSectionState
        let summary: String
        if source.canSupportRecommendation && source.localEvidenceCategories.isEmpty == false {
            state = .ready
            summary = source.citedSourceIDs.isEmpty ? "Uses local source context." : "Cites local source context."
        } else if source.sourceAtlasBlockReasons.isEmpty == false {
            state = .blocked
            summary = "Needs source review before this can guide behavior."
        } else {
            state = .missing
            summary = "Needs local source context before this can guide behavior."
        }

        return RecommendationTrustSeamSection(
            id: "trust-seam.source",
            kind: .source,
            title: "Source",
            summary: summary,
            state: state,
            referenceIDs: references
        )
    }

    static func reasonSection(_ reason: RecommendationTraceReason) -> RecommendationTrustSeamSection {
        let hasReason = reason.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        return RecommendationTrustSeamSection(
            id: "trust-seam.reason",
            kind: .reason,
            title: "Reason",
            summary: hasReason ? reason.summary : "Needs a stated reason.",
            state: hasReason ? .ready : .missing,
            referenceIDs: orderedUnique([reason.explanationID] + reason.evidenceCategoryIDs)
        )
    }

    static func fitSection(_ fit: RecommendationTraceFit) -> RecommendationTrustSeamSection {
        let state: RecommendationTrustSeamSectionState
        let summary: String
        switch fit.state {
        case .fits:
            state = fit.canDriveRecommendation ? .ready : .reviewNeeded
            summary = fit.canDriveRecommendation ? "Fits the current recommendation context." : "Fit needs review before behavior changes."
        case .reviewable:
            state = .reviewNeeded
            summary = "Needs review before behavior changes."
        case .sourceNeeded:
            state = .missing
            summary = "Needs source review before behavior changes."
        case .proofNeeded:
            state = .missing
            summary = "Needs proof before behavior changes."
        case .blocked:
            state = .blocked
            summary = "Blocked until the recommendation context changes."
        }

        return RecommendationTrustSeamSection(
            id: "trust-seam.fit",
            kind: .fit,
            title: "Fit",
            summary: summary,
            state: state,
            referenceIDs: orderedUnique(fit.blockReasons)
        )
    }

    static func uncertaintySection(_ uncertainty: RecommendationTraceUncertainty) -> RecommendationTrustSeamSection {
        let references = orderedUnique(uncertainty.uncertaintyIDs)
        return RecommendationTrustSeamSection(
            id: "trust-seam.uncertainty",
            kind: .uncertainty,
            title: "Uncertainty",
            summary: uncertainty.summaries.isEmpty ? "No stated uncertainty." : uncertainty.summaries.joined(separator: " "),
            state: uncertainty.summaries.isEmpty ? .notApplicable : .reviewNeeded,
            referenceIDs: references
        )
    }

    static func controlsSection(_ control: RecommendationTraceControl) -> RecommendationTrustSeamSection {
        let references = orderedUnique(control.correctionActionIDs + control.controlActionIDs + control.correctableFieldKeys)
        return RecommendationTrustSeamSection(
            id: "trust-seam.controls",
            kind: .controls,
            title: "Controls",
            summary: control.hasRequiredControl ? "Correction or review control is available." : "Needs a correction or review control.",
            state: control.hasRequiredControl ? .ready : .missing,
            referenceIDs: references
        )
    }

    static func receiptSection(_ receiptBehavior: RecommendationTraceReceiptBehavior) -> RecommendationTrustSeamSection {
        let references = orderedUnique(receiptBehavior.receiptIDs + receiptBehavior.actionReceiptIDs + receiptBehavior.proofReferenceIDs)
        let state: RecommendationTrustSeamSectionState
        let summary: String
        switch receiptBehavior.state {
        case .receiptAvailable:
            state = receiptBehavior.satisfiesTraceContract ? .ready : .missing
            summary = receiptBehavior.satisfiesTraceContract ? "Receipt or proof reference is available." : "Needs a receipt or proof reference."
        case .receiptRequired:
            state = .reviewNeeded
            summary = "Behavior change must create a receipt."
        case .receiptMissing:
            state = .missing
            summary = "Needs a receipt before behavior changes."
        case .notApplicable:
            state = .notApplicable
            summary = "No receipt is needed for this review."
        }

        return RecommendationTrustSeamSection(
            id: "trust-seam.receipt",
            kind: .receiptBehavior,
            title: "Receipt",
            summary: summary,
            state: state,
            referenceIDs: references
        )
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

extension RecommendationTraceFitState {
    var canDriveRecommendation: Bool {
        switch self {
        case .fits:
            return true
        case .reviewable, .sourceNeeded, .proofNeeded, .blocked:
            return false
        }
    }
}

extension CorrectionFoldRecommendationLearningInfluence {
    var personalRuntimeInspectableSummary: String {
        "\(explanation) \(sourceRecordInspectionLabel) \(replayTraceInspectionLabel) Reset, disable, or delete from You > Search Ambitions."
    }

    var personalRuntimeInspectionRoute: String {
        "you://personal-runtime/\(recommendationID)/inspect"
    }

    var personalRuntimeResetRoute: String {
        "you://personal-runtime/\(recommendationID)/reset"
    }

    var personalRuntimeDisableRoute: String {
        "you://personal-runtime/\(recommendationID)/disable"
    }

    var personalRuntimeDeleteRoute: String {
        "you://personal-runtime/\(recommendationID)/delete"
    }

    var personalRuntimeClearRoute: String {
        personalRuntimeDeleteRoute
    }

    var personalRuntimeInspectionLabel: String {
        localOnly ? "Local and source-tied" : "Review required"
    }
}

struct RecommendationEvidenceModel: Codable, Sendable, Equatable, Hashable {
    let explanationID: String
    let source: RecommendationExplanationSource
    let categories: [RecommendationExplanationEvidenceCategory]
    let categoryCounts: [RecommendationExplanationEvidenceCategory: Int]
    let citedSourceIDs: [String]
    let eventLedgerEntryIDs: [String]
    let assumptionIDs: [String]
    let uncertaintyIDs: [String]
    let correctableFieldKeys: [String]
    let strength: RecommendationEvidenceStrength
    let usesCalendarDerivedEvidence: Bool
    let usesContextLensEvidence: Bool
    let usesPriorityRealityEvidence: Bool
    let usesDeadlineEvidence: Bool
    let usesGoalScopeEvidence: Bool
    let usesSourceAtlasEvidence: Bool
    let sourceAtlasBlockReasons: [String]
    let requiresSensitiveReview: Bool
    let canDriveRecommendation: Bool
    let schemaVersion: String

    init(explanation: RecommendationExplanation) {
        let boundary = explanation.evidenceBoundarySummary
        let categoryCounts = Dictionary(grouping: explanation.evidence, by: \.category)
            .mapValues(\.count)
        let eventLedgerEntryIDs = Array(
            Set(explanation.relations.eventLedgerEntryIDs + explanation.evidence.compactMap(\.eventLedgerEntryID))
        ).sorted()
        let correctableFieldKeys = Array(
            Set(explanation.userCorrectableFields + explanation.correctionActions.compactMap(\.targetFieldKey))
        ).filter { $0.isEmpty == false }.sorted()
        let hasReviewableInference = explanation.assumptions.isEmpty == false || explanation.uncertainty.isEmpty == false
        let sourceAtlasBlockReasons = Array(
            Set(explanation.evidence.compactMap { $0.metadata["sourceAtlasRecommendationBlockReason"] })
        ).sorted()

        self.explanationID = explanation.id
        self.source = explanation.source
        self.categories = categoryCounts.keys.sorted { $0.rawValue < $1.rawValue }
        self.categoryCounts = categoryCounts
        self.citedSourceIDs = boundary.citedSourceIDs
        self.eventLedgerEntryIDs = eventLedgerEntryIDs
        self.assumptionIDs = explanation.assumptions.map(\.id).sorted()
        self.uncertaintyIDs = explanation.uncertainty.map(\.id).sorted()
        self.correctableFieldKeys = correctableFieldKeys
        self.usesCalendarDerivedEvidence = explanation.containsCalendarDerivedEvidence
        self.usesContextLensEvidence = explanation.containsContextLensEvidence
        self.usesPriorityRealityEvidence = explanation.containsPriorityRealityEvidence
        self.usesDeadlineEvidence = explanation.containsDeadlineEvidence
        self.usesGoalScopeEvidence = explanation.containsGoalScopeOrDeliverableEvidence
        self.usesSourceAtlasEvidence = explanation.containsSourceTruthEvidence
        self.sourceAtlasBlockReasons = sourceAtlasBlockReasons
        self.requiresSensitiveReview = boundary.requiresSensitiveReview
        self.canDriveRecommendation = boundary.isEvidenceLight == false &&
            explanation.localOnly &&
            boundary.requiresSensitiveReview == false &&
            sourceAtlasBlockReasons.isEmpty &&
            (hasReviewableInference == false || boundary.hasCorrectableInference)
        self.schemaVersion = recommendationExplanationSchemaVersion

        if boundary.requiresSensitiveReview {
            self.strength = .reviewRequired
        } else if eventLedgerEntryIDs.isEmpty == false || explanation.referencesEventLedger {
            self.strength = .citedLocalRecords
        } else if boundary.isEvidenceLight {
            self.strength = .evidenceLight
        } else {
            self.strength = .localEvidence
        }
    }
}
