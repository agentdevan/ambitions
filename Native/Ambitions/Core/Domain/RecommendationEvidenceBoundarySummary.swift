import Foundation

struct RecommendationEvidenceBoundarySummary: Sendable, Equatable, Hashable {
    let evidenceLabel: String
    let inferenceBoundaryLabel: String
    let userControlLabel: String
    let privacyLabel: String
    let citedSourceIDs: [String]
    let isEvidenceLight: Bool
    let hasCorrectableInference: Bool
    let requiresSensitiveReview: Bool
}

enum RecommendationEvidenceStrength: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case evidenceLight = "evidence_light"
    case localEvidence = "local_evidence"
    case citedLocalRecords = "cited_local_records"
    case reviewRequired = "review_required"
}

enum RecommendationTraceFitState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fits
    case reviewable
    case sourceNeeded = "source_needed"
    case proofNeeded = "proof_needed"
    case blocked
}

enum RecommendationTraceReceiptBehaviorState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case receiptAvailable = "receipt_available"
    case receiptRequired = "receipt_required"
    case receiptMissing = "receipt_missing"
    case notApplicable = "not_applicable"
}

struct RecommendationTraceSource: Codable, Sendable, Equatable, Hashable {
    let citedSourceIDs: [String]
    let sourceAtlasBlockReasons: [String]
    let localEvidenceCategories: [RecommendationExplanationEvidenceCategory]
    let canSupportRecommendation: Bool

    init(
        citedSourceIDs: [String],
        sourceAtlasBlockReasons: [String],
        localEvidenceCategories: [RecommendationExplanationEvidenceCategory],
        canSupportRecommendation: Bool
    ) {
        self.citedSourceIDs = Self.orderedUnique(citedSourceIDs)
        self.sourceAtlasBlockReasons = Self.orderedUnique(sourceAtlasBlockReasons)
        self.localEvidenceCategories = Self.orderedUnique(localEvidenceCategories)
        self.canSupportRecommendation = canSupportRecommendation
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    static func orderedUnique(_ values: [RecommendationExplanationEvidenceCategory]) -> [RecommendationExplanationEvidenceCategory] {
        Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }
}

struct RecommendationTraceReason: Codable, Sendable, Equatable, Hashable {
    let explanationID: String
    let summary: String
    let evidenceCategoryIDs: [String]

    init(
        explanationID: String,
        summary: String,
        evidenceCategoryIDs: [String]
    ) {
        self.explanationID = explanationID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.summary = summary
        self.evidenceCategoryIDs = Self.orderedUnique(evidenceCategoryIDs)
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct RecommendationTraceFit: Codable, Sendable, Equatable, Hashable {
    let state: RecommendationTraceFitState
    let blockReasons: [String]
    let canDriveRecommendation: Bool

    init(
        state: RecommendationTraceFitState,
        blockReasons: [String],
        canDriveRecommendation: Bool
    ) {
        self.state = state
        self.blockReasons = Self.orderedUnique(blockReasons)
        self.canDriveRecommendation = canDriveRecommendation
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct RecommendationTraceUncertainty: Codable, Sendable, Equatable, Hashable {
    let uncertaintyIDs: [String]
    let summaries: [String]

    init(
        uncertaintyIDs: [String],
        summaries: [String]
    ) {
        self.uncertaintyIDs = Self.orderedUnique(uncertaintyIDs)
        self.summaries = Self.orderedUnique(summaries)
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct RecommendationTraceControl: Codable, Sendable, Equatable, Hashable {
    let correctionActionIDs: [String]
    let controlActionIDs: [String]
    let correctableFieldKeys: [String]
    let hasRequiredControl: Bool

    init(
        correctionActionIDs: [String],
        controlActionIDs: [String],
        correctableFieldKeys: [String],
        hasRequiredControl: Bool
    ) {
        self.correctionActionIDs = Self.orderedUnique(correctionActionIDs)
        self.controlActionIDs = Self.orderedUnique(controlActionIDs)
        self.correctableFieldKeys = Self.orderedUnique(correctableFieldKeys)
        self.hasRequiredControl = hasRequiredControl
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct RecommendationTraceReceiptBehavior: Codable, Sendable, Equatable, Hashable {
    let state: RecommendationTraceReceiptBehaviorState
    let receiptIDs: [String]
    let actionReceiptIDs: [String]
    let proofReferenceIDs: [String]
    let requiresReceiptBeforeBehaviorChange: Bool

    var satisfiesTraceContract: Bool {
        switch state {
        case .receiptAvailable:
            return receiptIDs.isEmpty == false ||
                actionReceiptIDs.isEmpty == false ||
                proofReferenceIDs.isEmpty == false
        case .receiptRequired:
            return requiresReceiptBeforeBehaviorChange
        case .notApplicable:
            return requiresReceiptBeforeBehaviorChange == false
        case .receiptMissing:
            return false
        }
    }

    static func available(
        receiptIDs: [String] = [],
        actionReceiptIDs: [String] = [],
        proofReferenceIDs: [String] = []
    ) -> RecommendationTraceReceiptBehavior {
        RecommendationTraceReceiptBehavior(
            state: .receiptAvailable,
            receiptIDs: orderedUnique(receiptIDs),
            actionReceiptIDs: orderedUnique(actionReceiptIDs),
            proofReferenceIDs: orderedUnique(proofReferenceIDs),
            requiresReceiptBeforeBehaviorChange: false
        )
    }

    static func required() -> RecommendationTraceReceiptBehavior {
        RecommendationTraceReceiptBehavior(
            state: .receiptRequired,
            receiptIDs: [],
            actionReceiptIDs: [],
            proofReferenceIDs: [],
            requiresReceiptBeforeBehaviorChange: true
        )
    }

    static func missing() -> RecommendationTraceReceiptBehavior {
        RecommendationTraceReceiptBehavior(
            state: .receiptMissing,
            receiptIDs: [],
            actionReceiptIDs: [],
            proofReferenceIDs: [],
            requiresReceiptBeforeBehaviorChange: true
        )
    }

    static func notApplicable() -> RecommendationTraceReceiptBehavior {
        RecommendationTraceReceiptBehavior(
            state: .notApplicable,
            receiptIDs: [],
            actionReceiptIDs: [],
            proofReferenceIDs: [],
            requiresReceiptBeforeBehaviorChange: false
        )
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

enum RecommendationTraceReasonGraphNodeKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case source
    case reason
    case fit
    case uncertainty
    case control
    case receipt
    case runtimeSnapshot = "runtime_snapshot"
    case localFit = "local_fit"
}

struct RecommendationTracePolicyHook: Codable, Sendable, Equatable, Hashable {
    let privacyClass: AFEPStoragePrivacyClass
    let exportPolicy: AFEPExportPolicy
    let redactionClass: RuntimeSnapshotFieldRedactionClass
    let summary: String

    init(
        privacyClass: AFEPStoragePrivacyClass,
        exportPolicy: AFEPExportPolicy,
        redactionClass: RuntimeSnapshotFieldRedactionClass,
        summary: String
    ) {
        self.privacyClass = privacyClass
        self.exportPolicy = exportPolicy
        self.redactionClass = redactionClass
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func localOnly(summary: String = "Local-only redacted export") -> RecommendationTracePolicyHook {
        RecommendationTracePolicyHook(
            privacyClass: .localOnly,
            exportPolicy: .redacted,
            redactionClass: .localOnly,
            summary: summary
        )
    }

    var isExportSafe: Bool {
        exportPolicy.isExportSafe && redactionClass != .redacted
    }
}

struct RecommendationTraceReasonGraphNode: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: RecommendationTraceReasonGraphNodeKind
    let label: String
    let sourceIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let runtimeSnapshotReferenceIDs: [String]
    let localFitLabels: [String]
    let policyHook: RecommendationTracePolicyHook

    init(
        id: String,
        kind: RecommendationTraceReasonGraphNodeKind,
        label: String,
        sourceIDs: [String] = [],
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = [],
        runtimeSnapshotReferenceIDs: [String] = [],
        localFitLabels: [String] = [],
        policyHook: RecommendationTracePolicyHook = .localOnly()
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.label = label.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceIDs = Self.orderedUnique(sourceIDs)
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.replayTraceIDs = Self.orderedUnique(replayTraceIDs)
        self.runtimeSnapshotReferenceIDs = Self.orderedUnique(runtimeSnapshotReferenceIDs)
        self.localFitLabels = Self.orderedUnique(localFitLabels)
        self.policyHook = policyHook
    }

    var isExportSafe: Bool {
        policyHook.isExportSafe
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct RecommendationTraceReasonGraphEdge: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let fromNodeID: String
    let toNodeID: String
    let label: String
    let sourceIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let runtimeSnapshotReferenceIDs: [String]
    let localFitLabels: [String]
    let policyHook: RecommendationTracePolicyHook

    init(
        id: String,
        fromNodeID: String,
        toNodeID: String,
        label: String,
        sourceIDs: [String] = [],
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = [],
        runtimeSnapshotReferenceIDs: [String] = [],
        localFitLabels: [String] = [],
        policyHook: RecommendationTracePolicyHook = .localOnly()
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fromNodeID = fromNodeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.toNodeID = toNodeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.label = label.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceIDs = Self.orderedUnique(sourceIDs)
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.replayTraceIDs = Self.orderedUnique(replayTraceIDs)
        self.runtimeSnapshotReferenceIDs = Self.orderedUnique(runtimeSnapshotReferenceIDs)
        self.localFitLabels = Self.orderedUnique(localFitLabels)
        self.policyHook = policyHook
    }

    var isExportSafe: Bool {
        policyHook.isExportSafe
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
