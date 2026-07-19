import Foundation

struct ProjectStepGoalThreadUpdate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalThreadID: String
    let goalThreadName: String
    let previousState: ProjectStepGoalThreadState
    let newState: ProjectStepGoalThreadState
    let impactExplanation: String
    let affectedStepIDs: [String]
    let proofReferenceIDs: [String]
    let receiptID: String

    init(
        id: String,
        goalThreadID: String,
        goalThreadName: String,
        previousState: ProjectStepGoalThreadState,
        newState: ProjectStepGoalThreadState,
        impactExplanation: String,
        affectedStepIDs: [String] = [],
        proofReferenceIDs: [String] = [],
        receiptID: String
    ) {
        self.id = Self.normalizedRequired(id)
        self.goalThreadID = Self.normalizedRequired(goalThreadID)
        self.goalThreadName = Self.normalizedRequired(goalThreadName)
        self.previousState = previousState
        self.newState = newState
        self.impactExplanation = Self.normalizedRequired(impactExplanation)
        self.affectedStepIDs = Self.orderedUnique(affectedStepIDs)
        self.proofReferenceIDs = Self.orderedUnique(proofReferenceIDs)
        self.receiptID = Self.normalizedRequired(receiptID)
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            goalThreadID.isEmpty == false &&
            goalThreadName.isEmpty == false &&
            impactExplanation.isEmpty == false &&
            receiptID.isEmpty == false
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
            .sorted()
    }
}

struct ProjectStepContinuationContext: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let priorSessionID: String
    let priorSessionLabel: String
    let destinationStepID: String
    let destinationStepTitle: String
    let linkageSummary: String
    let receiptID: String

    init(
        id: String,
        priorSessionID: String,
        priorSessionLabel: String,
        destinationStepID: String,
        destinationStepTitle: String,
        linkageSummary: String,
        receiptID: String
    ) {
        self.id = Self.normalizedRequired(id)
        self.priorSessionID = Self.normalizedRequired(priorSessionID)
        self.priorSessionLabel = Self.normalizedRequired(priorSessionLabel)
        self.destinationStepID = Self.normalizedRequired(destinationStepID)
        self.destinationStepTitle = Self.normalizedRequired(destinationStepTitle)
        self.linkageSummary = Self.normalizedRequired(linkageSummary)
        self.receiptID = Self.normalizedRequired(receiptID)
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            priorSessionID.isEmpty == false &&
            priorSessionLabel.isEmpty == false &&
            destinationStepID.isEmpty == false &&
            destinationStepTitle.isEmpty == false &&
            linkageSummary.isEmpty == false &&
            receiptID.isEmpty == false
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct ProjectStepProofOpportunity: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalThreadID: String
    let followsStepID: String
    let title: String
    let summary: String
    let proofReferenceIDs: [String]

    init(
        id: String,
        goalThreadID: String,
        followsStepID: String,
        title: String,
        summary: String,
        proofReferenceIDs: [String] = []
    ) {
        self.id = Self.normalizedRequired(id)
        self.goalThreadID = Self.normalizedRequired(goalThreadID)
        self.followsStepID = Self.normalizedRequired(followsStepID)
        self.title = Self.normalizedRequired(title)
        self.summary = Self.normalizedRequired(summary)
        self.proofReferenceIDs = Self.orderedUnique(proofReferenceIDs)
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            goalThreadID.isEmpty == false &&
            followsStepID.isEmpty == false &&
            title.isEmpty == false &&
            summary.isEmpty == false &&
            proofReferenceIDs.isEmpty == false
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
            .sorted()
    }
}

struct ProjectStepDisplacedStepRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let originalDisposition: ProjectStepDisposition
    let coherenceSummary: String
    let isDeleted: Bool
    let isStaleCarried: Bool

    init(
        id: String,
        title: String,
        originalDisposition: ProjectStepDisposition,
        coherenceSummary: String,
        isDeleted: Bool = false,
        isStaleCarried: Bool = false
    ) {
        self.id = Self.normalizedRequired(id)
        self.title = Self.normalizedRequired(title)
        self.originalDisposition = originalDisposition
        self.coherenceSummary = Self.normalizedRequired(coherenceSummary)
        self.isDeleted = isDeleted
        self.isStaleCarried = isStaleCarried
    }

    var remainsCoherent: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            coherenceSummary.isEmpty == false &&
            isDeleted == false &&
            isStaleCarried == false
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct ProjectStepClosureProofReplay: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceRecord: SourceRecord
    let receipt: Receipt
    let replayTrace: ReplayTrace
    let inspectionSurfaceTitle: String
    let originalStep: ProjectStepDisplacedStepRecord
    let continuationContext: ProjectStepContinuationContext
    let sourceGoalThreadUpdate: ProjectStepGoalThreadUpdate
    let destinationGoalThreadUpdate: ProjectStepGoalThreadUpdate
    let proofOpportunity: ProjectStepProofOpportunity
    let schemaVersion: String

    init(
        id: String,
        sourceRecord: SourceRecord,
        receipt: Receipt,
        replayTrace: ReplayTrace,
        inspectionSurfaceTitle: String = "Search Ambitions",
        originalStep: ProjectStepDisplacedStepRecord,
        continuationContext: ProjectStepContinuationContext,
        sourceGoalThreadUpdate: ProjectStepGoalThreadUpdate,
        destinationGoalThreadUpdate: ProjectStepGoalThreadUpdate,
        proofOpportunity: ProjectStepProofOpportunity,
        schemaVersion: String = projectStepClosureProofReplaySchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.sourceRecord = sourceRecord
        self.receipt = receipt
        self.replayTrace = replayTrace
        self.inspectionSurfaceTitle = Self.normalizedRequired(inspectionSurfaceTitle)
        self.originalStep = originalStep
        self.continuationContext = continuationContext
        self.sourceGoalThreadUpdate = sourceGoalThreadUpdate
        self.destinationGoalThreadUpdate = destinationGoalThreadUpdate
        self.proofOpportunity = proofOpportunity
        self.schemaVersion = Self.normalizedRequired(schemaVersion)
    }

    var sourceRecordLabel: String {
        sourceRecord.entityTitle
    }

    var receiptLabel: String {
        receipt.title
    }

    var replayTraceLabel: String {
        replayTrace.decisionReceipt?.replayTraceLabel ?? (replayTrace.isReplayable ? "Replay trace stays local and inspectable" : "Replay trace needs review")
    }

    var originalDispositionLabel: String {
        originalStep.originalDisposition.displayName
    }

    var isInspectableBoundary: Bool {
        inspectionSurfaceTitle == "Search Ambitions" && replayTrace.isLocalOnly
    }

    var isWellFormed: Bool {
        Self.isWellFormed(sourceRecord: sourceRecord) &&
            receipt.isWellFormed &&
            replayTrace.isLocalOnly &&
            replayTrace.isReplayable &&
            inspectionSurfaceTitle == "Search Ambitions" &&
            originalStep.remainsCoherent &&
            continuationContext.isWellFormed &&
            sourceGoalThreadUpdate.isWellFormed &&
            destinationGoalThreadUpdate.isWellFormed &&
            proofOpportunity.isWellFormed &&
            schemaVersion == projectStepClosureProofReplaySchemaVersion
    }

    static func isWellFormed(sourceRecord: SourceRecord) -> Bool {
        sourceRecord.id.isEmpty == false &&
            sourceRecord.providerID.isEmpty == false &&
            sourceRecord.entityTitle.isEmpty == false &&
            (sourceRecord.locator?.isEmpty == false || sourceRecord.locator == nil)
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct StepReallocationTimeContext: Codable, Sendable, Equatable, Hashable {
    let scheduledBlockLabel: String
    let timeWindowLabel: String
    let protectedTimeLabel: String
    let scheduleImpactSummary: String
    let isProtectedTimeVisible: Bool
    let requiresSensitiveReview: Bool

    init(
        scheduledBlockLabel: String,
        timeWindowLabel: String,
        protectedTimeLabel: String,
        scheduleImpactSummary: String,
        isProtectedTimeVisible: Bool,
        requiresSensitiveReview: Bool = false
    ) {
        self.scheduledBlockLabel = Self.normalizedRequired(scheduledBlockLabel)
        self.timeWindowLabel = Self.normalizedRequired(timeWindowLabel)
        self.protectedTimeLabel = Self.normalizedRequired(protectedTimeLabel)
        self.scheduleImpactSummary = Self.normalizedRequired(scheduleImpactSummary)
        self.isProtectedTimeVisible = isProtectedTimeVisible
        self.requiresSensitiveReview = requiresSensitiveReview
    }

    var isWellFormed: Bool {
        scheduledBlockLabel.isEmpty == false &&
            timeWindowLabel.isEmpty == false &&
            protectedTimeLabel.isEmpty == false &&
            scheduleImpactSummary.isEmpty == false
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

let personalRuntimeLearningSignalSchemaVersion = "personal_runtime_learning_signal.native.v1"

enum PersonalRuntimeLearningSignalType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case momentumReflow = "momentum_reflow"
}

enum PersonalRuntimeLearningSignalConfidenceState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case active
    case reviewRequired = "review_required"
    case disabled
    case reset
    case deleted

    var excludesFutureRanking: Bool {
        self != .active
    }
}

enum PersonalRuntimeLearningSignalDataSelectionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case export
    case delete
}

struct PersonalRuntimeLearningSignalDataSelection: Codable, Sendable, Equatable, Hashable {
    let kind: PersonalRuntimeLearningSignalDataSelectionKind
    let signalID: String
    let includesSignal: Bool
    let includesRelatedSource: Bool
    let includesReceipt: Bool
    let includesReplayTrace: Bool
    let summary: String

    init(
        kind: PersonalRuntimeLearningSignalDataSelectionKind,
        signalID: String,
        includesSignal: Bool = true,
        includesRelatedSource: Bool,
        includesReceipt: Bool = true,
        includesReplayTrace: Bool = true,
        summary: String
    ) {
        self.kind = kind
        self.signalID = Self.normalizedRequired(signalID)
        self.includesSignal = includesSignal
        self.includesRelatedSource = includesRelatedSource
        self.includesReceipt = includesReceipt
        self.includesReplayTrace = includesReplayTrace
        self.summary = Self.normalizedRequired(summary)
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
