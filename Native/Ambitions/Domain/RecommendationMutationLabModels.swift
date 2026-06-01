import Foundation

let recommendationMutationLabSchemaVersion = "recommendation_mutation_lab.native.v1"

enum RecommendationMutationLabStabilityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case stable
    case needsReview = "needs_review"
    case unstable
}

enum RecommendationMutationLabInstabilityReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingExplanationDelta = "missing_explanation_delta"
    case nonDeterministicOutput = "non_deterministic_output"
    case notBoundedByMutationContext = "not_bounded_by_mutation_context"
    case missingReasonGraph = "missing_reason_graph"
    case missingCounterfactualDiff = "missing_counterfactual_diff"
    case missingInspectionSeams = "missing_inspection_seams"
    case missingReplayTrace = "missing_replay_trace"
}

struct RecommendationMutationLabInspectionSeam: Codable, Sendable, Equatable, Hashable {
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let sourceRecordLabel: String
    let replayTraceLabel: String
    let inspectionSurfaceTitle: String
    let controlVisibility: String
    let youInspectionLabel: String

    init(
        sourceRecordID: String,
        receiptID: String,
        replayTraceID: String,
        sourceRecordLabel: String,
        replayTraceLabel: String,
        inspectionSurfaceTitle: String = "What Ambitions knows",
        controlVisibility: String = "You / What Ambitions knows can inspect the local trace.",
        youInspectionLabel: String = "You / What Ambitions knows"
    ) {
        self.sourceRecordID = sourceRecordID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.receiptID = receiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.replayTraceID = replayTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordLabel = sourceRecordLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.replayTraceLabel = replayTraceLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.inspectionSurfaceTitle = inspectionSurfaceTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        self.controlVisibility = controlVisibility.trimmingCharacters(in: .whitespacesAndNewlines)
        self.youInspectionLabel = youInspectionLabel.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var visibleCopy: [String] {
        [
            sourceRecordID,
            receiptID,
            replayTraceID,
            sourceRecordLabel,
            replayTraceLabel,
            inspectionSurfaceTitle,
            controlVisibility,
            youInspectionLabel
        ]
    }

    var hasRequiredSeams: Bool {
        sourceRecordID.isEmpty == false &&
            receiptID.isEmpty == false &&
            replayTraceID.isEmpty == false &&
            sourceRecordLabel.isEmpty == false &&
            replayTraceLabel.isEmpty == false &&
            inspectionSurfaceTitle.isEmpty == false &&
            controlVisibility.isEmpty == false &&
            youInspectionLabel.isEmpty == false
    }
}

struct RecommendationMutationLabVariant: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let mutationID: String
    let contextSummary: String
    let contextDeltaSummary: String?
    let recommendationTrace: RecommendationTrace
    let reasonGraph: RecommendationTraceReasonGraph?
    let recommendationCounterfactualDiff: RecommendationTraceCounterfactualDiff?
    let planningCounterfactualDiff: PlanningRuleCounterfactualDiff?
    let replayTrace: ReplayableDecisionTrace?
    let inspectionSeam: RecommendationMutationLabInspectionSeam
    let contextBoundaryIDs: [String]
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let runtimeSnapshotReferenceIDs: [String]
    let localFitLabels: [String]
    let schemaVersion: String

    init(
        id: String,
        mutationID: String,
        contextSummary: String,
        contextDeltaSummary: String? = nil,
        recommendationTrace: RecommendationTrace,
        reasonGraph: RecommendationTraceReasonGraph? = nil,
        recommendationCounterfactualDiff: RecommendationTraceCounterfactualDiff? = nil,
        planningCounterfactualDiff: PlanningRuleCounterfactualDiff? = nil,
        replayTrace: ReplayableDecisionTrace? = nil,
        inspectionSeam: RecommendationMutationLabInspectionSeam,
        contextBoundaryIDs: [String] = [],
        sourceRecordIDs: [String] = [],
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = [],
        runtimeSnapshotReferenceIDs: [String] = [],
        localFitLabels: [String] = [],
        schemaVersion: String = recommendationMutationLabSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.mutationID = mutationID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.contextSummary = contextSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.contextDeltaSummary = Self.trimmedOrNil(contextDeltaSummary)
        self.recommendationTrace = recommendationTrace
        self.reasonGraph = reasonGraph
        self.recommendationCounterfactualDiff = recommendationCounterfactualDiff
        self.planningCounterfactualDiff = planningCounterfactualDiff
        self.replayTrace = replayTrace
        self.inspectionSeam = inspectionSeam
        self.contextBoundaryIDs = Self.orderedUnique(contextBoundaryIDs)
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.replayTraceIDs = Self.orderedUnique(replayTraceIDs)
        self.runtimeSnapshotReferenceIDs = Self.orderedUnique(runtimeSnapshotReferenceIDs)
        self.localFitLabels = Self.orderedUnique(localFitLabels)
        self.schemaVersion = schemaVersion
    }

    var recommendationID: String {
        recommendationTrace.recommendationID
    }

    var selectedTraceID: String {
        recommendationTrace.id
    }

    var outputFingerprint: String {
        [
            recommendationTrace.id,
            reasonGraph?.id ?? "",
            recommendationCounterfactualDiff?.id ?? "",
            planningCounterfactualDiff?.id ?? "",
            replayTrace?.id ?? "",
            inspectionSeam.sourceRecordID,
            inspectionSeam.receiptID,
            inspectionSeam.replayTraceID
        ]
        .joined(separator: "|")
    }

    var hasInspectionSeams: Bool {
        inspectionSeam.hasRequiredSeams
    }

    var hasReasonGraph: Bool {
        reasonGraph != nil
    }

    var hasCounterfactualEvidence: Bool {
        recommendationCounterfactualDiff != nil || planningCounterfactualDiff != nil
    }

    var isBoundedByMutationContext: Bool {
        contextBoundaryIDs.isEmpty == false
    }

    var visibleCopy: [String] {
        [
            id,
            mutationID,
            contextSummary,
            contextDeltaSummary ?? "",
            recommendationID,
            selectedTraceID
        ] + inspectionSeam.visibleCopy
    }

    var hasVisibleCopyGuardrailViolation: Bool {
        visibleCopy.contains { text in
            let lowercased = text.lowercased()
            return lowercased.contains("ai ") ||
                lowercased.contains("assistant") ||
                lowercased.contains("confidence") ||
                lowercased.contains("best " + "next " + "move") ||
                lowercased.contains("next " + "best " + "move") ||
                lowercased.contains("dash" + "board") ||
                text.contains("%")
        }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        )
        .sorted()
    }

    private static func trimmedOrNil(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), value.isEmpty == false else {
            return nil
        }
        return value
    }
}

struct RecommendationMutationLabComparison: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let baselineVariantID: String
    let mutatedVariantID: String
    let baselineRecommendationID: String
    let mutatedRecommendationID: String
    let baselineTraceID: String
    let mutatedTraceID: String
    let stabilityState: RecommendationMutationLabStabilityState
    let instabilityReasonIDs: [RecommendationMutationLabInstabilityReason]
    let summary: String
    let explanationDeltaSummary: String?
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let sourceRecordLabel: String
    let replayTraceLabel: String
    let inspectionSurfaceTitle: String
    let controlVisibility: String
    let youInspectionLabel: String
    let schemaVersion: String

    init(
        baseline baselineVariant: RecommendationMutationLabVariant,
        mutated mutatedVariant: RecommendationMutationLabVariant,
        schemaVersion: String = recommendationMutationLabSchemaVersion
    ) {
        baselineVariantID = baselineVariant.id
        mutatedVariantID = mutatedVariant.id
        baselineRecommendationID = baselineVariant.recommendationID
        mutatedRecommendationID = mutatedVariant.recommendationID
        baselineTraceID = baselineVariant.selectedTraceID
        mutatedTraceID = mutatedVariant.selectedTraceID
        sourceRecordID = mutatedVariant.inspectionSeam.sourceRecordID
        receiptID = mutatedVariant.inspectionSeam.receiptID
        replayTraceID = mutatedVariant.inspectionSeam.replayTraceID
        sourceRecordLabel = mutatedVariant.inspectionSeam.sourceRecordLabel
        replayTraceLabel = mutatedVariant.inspectionSeam.replayTraceLabel
        inspectionSurfaceTitle = mutatedVariant.inspectionSeam.inspectionSurfaceTitle
        controlVisibility = mutatedVariant.inspectionSeam.controlVisibility
        youInspectionLabel = mutatedVariant.inspectionSeam.youInspectionLabel
        explanationDeltaSummary = mutatedVariant.contextDeltaSummary
        let reasons = Self.instabilityReasons(
            baseline: baselineVariant,
            mutated: mutatedVariant
        )
        instabilityReasonIDs = reasons
        if reasons.contains(.missingExplanationDelta) ||
            reasons.contains(.nonDeterministicOutput) ||
            reasons.contains(.notBoundedByMutationContext) {
            stabilityState = .unstable
        } else if reasons.isEmpty {
            stabilityState = .stable
        } else {
            stabilityState = .needsReview
        }
        summary = Self.summary(
            baseline: baselineVariant,
            mutated: mutatedVariant,
            stabilityState: stabilityState
        )
        self.schemaVersion = schemaVersion
        id = "recommendation-mutation-comparison.\(baselineVariant.id).\(mutatedVariant.id)"
    }

    var isStable: Bool {
        stabilityState == .stable
    }

    var isUnstable: Bool {
        stabilityState == .unstable
    }

    var hasRequiredInspectionSeams: Bool {
        sourceRecordID.isEmpty == false &&
            receiptID.isEmpty == false &&
            replayTraceID.isEmpty == false &&
            sourceRecordLabel.isEmpty == false &&
            replayTraceLabel.isEmpty == false &&
            inspectionSurfaceTitle.isEmpty == false &&
            controlVisibility.isEmpty == false &&
            youInspectionLabel.isEmpty == false
    }

    var visibleCopy: [String] {
        [
            id,
            baselineRecommendationID,
            mutatedRecommendationID,
            baselineTraceID,
            mutatedTraceID,
            summary,
            explanationDeltaSummary ?? "",
            sourceRecordLabel,
            replayTraceLabel,
            inspectionSurfaceTitle,
            controlVisibility,
            youInspectionLabel
        ]
    }

    var hasVisibleCopyGuardrailViolation: Bool {
        visibleCopy.contains { text in
            let lowercased = text.lowercased()
            return lowercased.contains("ai ") ||
                lowercased.contains("assistant") ||
                lowercased.contains("confidence") ||
                lowercased.contains("best " + "next " + "move") ||
                lowercased.contains("next " + "best " + "move") ||
                lowercased.contains("dash" + "board") ||
                text.contains("%")
        }
    }

    private static func instabilityReasons(
        baseline: RecommendationMutationLabVariant,
        mutated: RecommendationMutationLabVariant
    ) -> [RecommendationMutationLabInstabilityReason] {
        var reasons: [RecommendationMutationLabInstabilityReason] = []

        if mutated.hasInspectionSeams == false || baseline.hasInspectionSeams == false {
            reasons.append(.missingInspectionSeams)
        }
        if mutated.hasReasonGraph == false || baseline.hasReasonGraph == false {
            reasons.append(.missingReasonGraph)
        }
        if mutated.hasCounterfactualEvidence == false || baseline.hasCounterfactualEvidence == false {
            reasons.append(.missingCounterfactualDiff)
        }
        if mutated.replayTrace == nil || baseline.replayTrace == nil {
            reasons.append(.missingReplayTrace)
        }
        if sameMutationInput(baseline, mutated) && baseline.outputFingerprint != mutated.outputFingerprint {
            reasons.append(.nonDeterministicOutput)
        }
        if baseline.recommendationID != mutated.recommendationID && mutated.isBoundedByMutationContext == false {
            reasons.append(.notBoundedByMutationContext)
        }
        if baseline.recommendationTrace.reason != mutated.recommendationTrace.reason &&
            (mutated.contextDeltaSummary?.isEmpty ?? true) {
            reasons.append(.missingExplanationDelta)
        } else if baseline.recommendationID != mutated.recommendationID &&
            (mutated.contextDeltaSummary?.isEmpty ?? true) {
            reasons.append(.missingExplanationDelta)
        }

        return Array(Set(reasons)).sorted { $0.rawValue < $1.rawValue }
    }

    private static func sameMutationInput(
        _ baseline: RecommendationMutationLabVariant,
        _ mutated: RecommendationMutationLabVariant
    ) -> Bool {
        baseline.mutationID == mutated.mutationID &&
            baseline.contextSummary == mutated.contextSummary &&
            baseline.contextDeltaSummary == mutated.contextDeltaSummary &&
            baseline.contextBoundaryIDs == mutated.contextBoundaryIDs &&
            baseline.sourceRecordIDs == mutated.sourceRecordIDs &&
            baseline.receiptIDs == mutated.receiptIDs &&
            baseline.replayTraceIDs == mutated.replayTraceIDs &&
            baseline.runtimeSnapshotReferenceIDs == mutated.runtimeSnapshotReferenceIDs &&
            baseline.localFitLabels == mutated.localFitLabels
    }

    private static func summary(
        baseline: RecommendationMutationLabVariant,
        mutated: RecommendationMutationLabVariant,
        stabilityState: RecommendationMutationLabStabilityState
    ) -> String {
        let changeLabel = baseline.recommendationID == mutated.recommendationID ? "stays" : "changes"
        return "Baseline \(baseline.recommendationID) \(changeLabel) \(mutated.recommendationID) with \(stabilityState.rawValue) local inspection."
    }
}

struct RecommendationMutationLabReport: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let batchID: String
    let title: String
    let comparisons: [RecommendationMutationLabComparison]
    let summary: String
    let schemaVersion: String

    init(
        id: String,
        batchID: String,
        title: String = "Scenario Mutation Lab",
        comparisons: [RecommendationMutationLabComparison],
        schemaVersion: String = recommendationMutationLabSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.batchID = batchID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.comparisons = comparisons.sorted { $0.id < $1.id }
        self.summary = Self.summary(for: self.comparisons)
        self.schemaVersion = schemaVersion
    }

    var stableComparisonCount: Int {
        comparisons.filter(\.isStable).count
    }

    var needsReviewComparisonCount: Int {
        comparisons.filter { $0.stabilityState == .needsReview }.count
    }

    var unstableComparisonCount: Int {
        comparisons.filter(\.isUnstable).count
    }

    var visibleCopy: [String] {
        [
            id,
            batchID,
            title,
            summary
        ] + comparisons.flatMap { comparison in
            [
                comparison.summary,
                comparison.stabilityState.rawValue,
                comparison.sourceRecordLabel,
                comparison.replayTraceLabel,
                comparison.inspectionSurfaceTitle,
                comparison.controlVisibility,
                comparison.youInspectionLabel
            ]
        }
    }

    var hasVisibleCopyGuardrailViolation: Bool {
        visibleCopy.contains { text in
            let lowercased = text.lowercased()
            return lowercased.contains("ai ") ||
                lowercased.contains("assistant") ||
                lowercased.contains("confidence") ||
                lowercased.contains("best " + "next " + "move") ||
                lowercased.contains("next " + "best " + "move") ||
                lowercased.contains("dash" + "board") ||
                text.contains("%")
        }
    }

    private static func summary(for comparisons: [RecommendationMutationLabComparison]) -> String {
        let stable = comparisons.filter(\.isStable).count
        let unstable = comparisons.filter(\.isUnstable).count
        let review = comparisons.count - stable - unstable
        return "\(stable) stable, \(review) needs review, \(unstable) unstable comparisons"
    }
}
