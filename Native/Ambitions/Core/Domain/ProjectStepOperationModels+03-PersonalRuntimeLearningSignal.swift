import Foundation

struct PersonalRuntimeLearningSignal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let signalType: PersonalRuntimeLearningSignalType
    let confidenceState: PersonalRuntimeLearningSignalConfidenceState
    let sourceRecord: SourceRecord
    let receipt: Receipt
    let replayTrace: ReplayTrace
    let inspectionSurfaceTitle: String
    let sourceAdapterUseSummary: String
    let inspectionSummary: String
    let reviewSummary: String
    let medicalAdviceBoundarySummary: String
    let schemaVersion: String
    let requiresSensitiveReview: Bool
    let deletedAt: String?

    init(
        id: String,
        signalType: PersonalRuntimeLearningSignalType,
        confidenceState: PersonalRuntimeLearningSignalConfidenceState,
        sourceRecord: SourceRecord,
        receipt: Receipt,
        replayTrace: ReplayTrace,
        inspectionSurfaceTitle: String = "Search Ambitions",
        sourceAdapterUseSummary: String,
        inspectionSummary: String,
        reviewSummary: String,
        medicalAdviceBoundarySummary: String,
        requiresSensitiveReview: Bool = false,
        deletedAt: String? = nil,
        schemaVersion: String = personalRuntimeLearningSignalSchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.signalType = signalType
        self.confidenceState = confidenceState
        self.sourceRecord = sourceRecord
        self.receipt = receipt
        self.replayTrace = replayTrace
        self.inspectionSurfaceTitle = Self.normalizedRequired(inspectionSurfaceTitle)
        self.sourceAdapterUseSummary = Self.normalizedRequired(sourceAdapterUseSummary)
        self.inspectionSummary = Self.normalizedRequired(inspectionSummary)
        self.reviewSummary = Self.normalizedRequired(reviewSummary)
        self.medicalAdviceBoundarySummary = Self.normalizedRequired(medicalAdviceBoundarySummary)
        self.schemaVersion = Self.normalizedRequired(schemaVersion)
        self.requiresSensitiveReview = requiresSensitiveReview
        self.deletedAt = Self.normalizedOptional(deletedAt)
    }

    var sourceRecordLabel: String {
        sourceRecord.entityTitle
    }

    var personalRuntimeInspectionLabel: String {
        switch confidenceState {
        case .active:
            return "Local and source-tied"
        case .reviewRequired:
            return "Review required"
        case .disabled:
            return "Disabled"
        case .reset:
            return "Reset"
        case .deleted:
            return "Deleted"
        }
    }

    var personalRuntimeInspectableSummary: String {
        switch confidenceState {
        case .active:
            return "\(inspectionSummary) \(reviewSummary) \(medicalAdviceBoundarySummary)"
        case .reviewRequired:
            return "\(inspectionSummary) \(reviewSummary) \(medicalAdviceBoundarySummary)"
        case .disabled:
            return "\(inspectionSummary) Learning is disabled and excluded from future ranking."
        case .reset:
            return "\(inspectionSummary) Learning is reset and excluded from future ranking."
        case .deleted:
            return "\(inspectionSummary) Learning is deleted or tombstoned and excluded from future ranking."
        }
    }

    var personalRuntimeResetRoute: String {
        "you://personal-runtime/\(signalType.rawValue)/\(id)/reset"
    }

    var personalRuntimeDisableRoute: String {
        "you://personal-runtime/\(signalType.rawValue)/\(id)/disable"
    }

    var personalRuntimeDeleteRoute: String {
        "you://personal-runtime/\(signalType.rawValue)/\(id)/delete"
    }

    var personalRuntimeExportRoute: String {
        "you://personal-runtime/\(signalType.rawValue)/\(id)/export"
    }

    var isExcludedFromFutureRanking: Bool {
        confidenceState.excludesFutureRanking
    }

    var isInspectableAndControllable: Bool {
        isInspectableBoundary &&
            receipt.isWellFormed &&
            replayTrace.isLocalOnly &&
            replayTrace.isReplayable &&
            sourceRecord.id.isEmpty == false &&
            confidenceState != .deleted &&
            deletedAt == nil &&
            schemaVersion == personalRuntimeLearningSignalSchemaVersion
    }

    var isInspectableBoundary: Bool {
        inspectionSurfaceTitle == "Search Ambitions" && replayTrace.isLocalOnly
    }

    var permitsSilentMutation: Bool {
        false
    }

    var exportSelectionSummary: String {
        exportSelection(includingRelatedSource: true).summary
    }

    var deleteSelectionSummary: String {
        deleteSelection(includingRelatedSource: true).summary
    }

    func exportSelection(includingRelatedSource: Bool) -> PersonalRuntimeLearningSignalDataSelection {
        PersonalRuntimeLearningSignalDataSelection(
            kind: .export,
            signalID: id,
            includesRelatedSource: includingRelatedSource,
            summary: includingRelatedSource
                ? "Export includes the momentum_reflow signal, related source, receipt, and replay trace."
                : "Export includes the momentum_reflow signal, receipt, and replay trace without the related source."
        )
    }

    func deleteSelection(includingRelatedSource: Bool) -> PersonalRuntimeLearningSignalDataSelection {
        PersonalRuntimeLearningSignalDataSelection(
            kind: .delete,
            signalID: id,
            includesRelatedSource: includingRelatedSource,
            summary: includingRelatedSource
                ? "Delete tombstones the momentum_reflow signal and related source according to the selected choice."
                : "Delete tombstones the momentum_reflow signal while leaving the related source untouched."
        )
    }

    func disabling(at timestamp: String? = nil) -> PersonalRuntimeLearningSignal {
        updated(confidenceState: .disabled, deletedAt: timestamp)
    }

    func resetting(at timestamp: String? = nil) -> PersonalRuntimeLearningSignal {
        updated(confidenceState: .reset, deletedAt: timestamp)
    }

    func deleting(at timestamp: String? = nil) -> PersonalRuntimeLearningSignal {
        updated(confidenceState: .deleted, deletedAt: timestamp)
    }

    func reviewing() -> PersonalRuntimeLearningSignal {
        updated(confidenceState: .reviewRequired, deletedAt: deletedAt)
    }

    func updated(
        confidenceState: PersonalRuntimeLearningSignalConfidenceState,
        deletedAt: String? = nil
    ) -> PersonalRuntimeLearningSignal {
        PersonalRuntimeLearningSignal(
            id: id,
            signalType: signalType,
            confidenceState: confidenceState,
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            inspectionSurfaceTitle: inspectionSurfaceTitle,
            sourceAdapterUseSummary: sourceAdapterUseSummary,
            inspectionSummary: inspectionSummary,
            reviewSummary: reviewSummary,
            medicalAdviceBoundarySummary: medicalAdviceBoundarySummary,
            requiresSensitiveReview: requiresSensitiveReview,
            deletedAt: deletedAt ?? self.deletedAt,
            schemaVersion: schemaVersion
        )
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            sourceRecord.id.isEmpty == false &&
            sourceRecord.providerID.isEmpty == false &&
            sourceRecord.entityTitle.isEmpty == false &&
            receipt.isWellFormed &&
            replayTrace.isLocalOnly &&
            replayTrace.isReplayable &&
            inspectionSurfaceTitle == "Search Ambitions" &&
            sourceAdapterUseSummary.isEmpty == false &&
            inspectionSummary.isEmpty == false &&
            reviewSummary.isEmpty == false &&
            medicalAdviceBoundarySummary.isEmpty == false &&
            schemaVersion == personalRuntimeLearningSignalSchemaVersion
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

struct StepReallocationMomentumContext: Codable, Sendable, Equatable, Hashable {
    let sourceStepID: String
    let sourceStepTitle: String
    let destinationStepID: String
    let destinationStepTitle: String
    let momentumSummary: String

    init(
        sourceStepID: String,
        sourceStepTitle: String,
        destinationStepID: String,
        destinationStepTitle: String,
        momentumSummary: String
    ) {
        self.sourceStepID = Self.normalizedRequired(sourceStepID)
        self.sourceStepTitle = Self.normalizedRequired(sourceStepTitle)
        self.destinationStepID = Self.normalizedRequired(destinationStepID)
        self.destinationStepTitle = Self.normalizedRequired(destinationStepTitle)
        self.momentumSummary = Self.normalizedRequired(momentumSummary)
    }

    var isWellFormed: Bool {
        sourceStepID.isEmpty == false &&
            sourceStepTitle.isEmpty == false &&
            destinationStepID.isEmpty == false &&
            destinationStepTitle.isEmpty == false &&
            momentumSummary.isEmpty == false
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct StepReallocationPressureImpact: Codable, Sendable, Equatable, Hashable {
    let deadlinePolicyLabel: String
    let pressureSummary: String
    let reviewSummary: String

    init(
        deadlinePolicyLabel: String,
        pressureSummary: String,
        reviewSummary: String
    ) {
        self.deadlinePolicyLabel = Self.normalizedRequired(deadlinePolicyLabel)
        self.pressureSummary = Self.normalizedRequired(pressureSummary)
        self.reviewSummary = Self.normalizedRequired(reviewSummary)
    }

    var isWellFormed: Bool {
        deadlinePolicyLabel.isEmpty == false &&
            pressureSummary.isEmpty == false &&
            reviewSummary.isEmpty == false
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct StepReallocationProofImpact: Codable, Sendable, Equatable, Hashable {
    let proofOpportunityLabel: String
    let proofSummary: String
    let proofReferenceIDs: [String]

    init(
        proofOpportunityLabel: String,
        proofSummary: String,
        proofReferenceIDs: [String]
    ) {
        self.proofOpportunityLabel = Self.normalizedRequired(proofOpportunityLabel)
        self.proofSummary = Self.normalizedRequired(proofSummary)
        self.proofReferenceIDs = Self.orderedUnique(proofReferenceIDs)
    }

    var isWellFormed: Bool {
        proofOpportunityLabel.isEmpty == false &&
            proofSummary.isEmpty == false &&
            proofReferenceIDs.isEmpty == false
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
