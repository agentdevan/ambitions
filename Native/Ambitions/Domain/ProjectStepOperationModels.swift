import Foundation

let projectStepOperationSchemaVersion = "project_step_operation.native.v1"
let projectStepBulkDownstreamContractSchemaVersion = "project_step_bulk_downstream_contract.native.v1"
let projectStepClosureProofReplaySchemaVersion = "project_step_closure_proof_replay.native.v1"

enum ProjectStepOperationKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case move
    case shorten
    case hold
    case markNotNeededToday = "mark_not_needed_today"
    case markNeedsRecovery = "mark_needs_recovery"
    case keepDeadline = "keep_deadline"
    case adjustTimeline = "adjust_timeline"
    case schedule
    case unschedule
    case markWaiting = "mark_waiting"
    case markBlocked = "mark_blocked"
    case attachProof = "attach_proof"
    case bulkDownstreamContract = "bulk_downstream_contract"
    case receipt

    var displayName: String {
        switch self {
        case .move:
            return "Move step"
        case .shorten:
            return "Shorten step"
        case .hold:
            return "Hold step"
        case .markNotNeededToday:
            return "Mark not needed today"
        case .markNeedsRecovery:
            return "Mark needs recovery"
        case .keepDeadline:
            return "Keep deadline"
        case .adjustTimeline:
            return "Adjust timeline"
        case .schedule:
            return "Schedule step"
        case .unschedule:
            return "Unschedule step"
        case .markWaiting:
            return "Mark waiting"
        case .markBlocked:
            return "Mark blocked"
        case .attachProof:
            return "Attach proof"
        case .bulkDownstreamContract:
            return "Bulk downstream contract"
        case .receipt:
            return "Receipt"
        }
    }

    var receiptTitle: String {
        switch self {
        case .move:
            return "Step moved"
        case .shorten:
            return "Step shortened"
        case .hold:
            return "Step held"
        case .markNotNeededToday:
            return "Step marked not needed today"
        case .markNeedsRecovery:
            return "Step marked needs recovery"
        case .keepDeadline:
            return "Deadline kept"
        case .adjustTimeline:
            return "Timeline adjusted"
        case .schedule:
            return "Step scheduled"
        case .unschedule:
            return "Step unscheduled"
        case .markWaiting:
            return "Step marked waiting"
        case .markBlocked:
            return "Step marked blocked"
        case .attachProof:
            return "Proof attached"
        case .bulkDownstreamContract:
            return "Bulk contract recorded"
        case .receipt:
            return "Receipt recorded"
        }
    }
}

private extension GoalThread {
    func momentumReflowUpdated(
        isActive: Bool? = nil,
        updatedAt: String
    ) -> GoalThread {
        GoalThread(
            id: id,
            ambitionID: ambitionID,
            lifeAreaID: lifeAreaID,
            name: name,
            goalIDs: goalIDs,
            isActive: isActive ?? self.isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

private extension Commitment {
    func momentumReflowUpdated(
        status: AmbitionCommitmentStatus? = nil,
        updatedAt: String
    ) -> Commitment {
        Commitment(
            id: id,
            ambitionID: ambitionID,
            goalThreadID: goalThreadID,
            stepID: stepID,
            promisedFor: promisedFor,
            expectedEffort: expectedEffort,
            minimumProofDescription: minimumProofDescription,
            fitReason: fitReason,
            recoveryPolicy: recoveryPolicy,
            status: status ?? self.status,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

private extension Step {
    func momentumReflowUpdated(
        state: StepLifecycleState? = nil
    ) -> Step {
        Step(
            id: id,
            sectionID: sectionID,
            title: title,
            summary: summary,
            type: type,
            state: state ?? self.state,
            owner: owner,
            timing: timing,
            dependencyStepIDs: dependencyStepIDs,
            isOptional: isOptional,
            isRepeatable: isRepeatable,
            evidenceRequired: evidenceRequired,
            successSignals: successSignals,
            actionability: actionability
        )
    }
}

struct ProjectStepBulkDownstreamContract: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let inspectionSurfaceTitle: String
    let sourceRecord: SourceRecord
    let receipt: Receipt
    let replayTrace: ReplayTrace
    let operationKinds: [ProjectStepOperationKind]
    let operationReceipts: [Receipt]
    let downstreamContractIDs: [String]
    let proofReferenceIDs: [String]
    let schemaVersion: String

    init(
        id: String,
        title: String,
        summary: String,
        inspectionSurfaceTitle: String = "What Ambitions knows",
        sourceRecord: SourceRecord,
        receipt: Receipt,
        replayTrace: ReplayTrace,
        operationKinds: [ProjectStepOperationKind],
        operationReceipts: [Receipt],
        downstreamContractIDs: [String] = [],
        proofReferenceIDs: [String] = [],
        schemaVersion: String = projectStepBulkDownstreamContractSchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.title = Self.normalizedRequired(title)
        self.summary = Self.normalizedRequired(summary)
        self.inspectionSurfaceTitle = Self.normalizedRequired(inspectionSurfaceTitle)
        self.sourceRecord = sourceRecord
        self.receipt = receipt
        self.replayTrace = replayTrace
        self.operationKinds = operationKinds
        self.operationReceipts = operationReceipts
        self.downstreamContractIDs = Self.orderedUnique(downstreamContractIDs)
        self.proofReferenceIDs = Self.orderedUnique(proofReferenceIDs)
        self.schemaVersion = Self.normalizedRequired(schemaVersion)
    }

    var bulkOperationCount: Int {
        operationReceipts.count
    }

    var isBulk: Bool {
        bulkOperationCount > 1
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

    var inspectionLabel: String {
        inspectionSurfaceTitle
    }

    var isInspectableBoundary: Bool {
        inspectionSurfaceTitle == "What Ambitions knows" && replayTrace.isLocalOnly
    }

    var operationReceiptTitles: [String] {
        operationReceipts.map(\.title)
    }

    var isWellFormed: Bool {
        Self.isWellFormed(sourceRecord: sourceRecord) &&
            receipt.isWellFormed &&
            replayTrace.isLocalOnly &&
            replayTrace.isReplayable &&
            inspectionSurfaceTitle == "What Ambitions knows" &&
            title.isEmpty == false &&
            summary.isEmpty == false &&
            schemaVersion == projectStepBulkDownstreamContractSchemaVersion &&
            operationKinds.count == operationReceipts.count &&
            operationKinds.isEmpty == false &&
            operationReceipts.allSatisfy(\.isWellFormed) &&
            operationKinds.count == Self.orderedUnique(operationKinds).count &&
            operationReceipts.count == Self.orderedUnique(operationReceipts.map(\.id)).count &&
            proofReferenceIDs.isEmpty == false
    }

    private static func isWellFormed(sourceRecord: SourceRecord) -> Bool {
        sourceRecord.id.isEmpty == false &&
            sourceRecord.providerID.isEmpty == false &&
            sourceRecord.entityTitle.isEmpty == false &&
            (sourceRecord.locator?.isEmpty == false || sourceRecord.locator == nil)
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
            .sorted()
    }

    private static func orderedUnique<T: Hashable>(_ values: [T]) -> [T] {
        var seen = Set<T>()
        return values.filter { seen.insert($0).inserted }
    }
}

enum ProjectStepDisposition: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case move
    case shorten
    case hold
    case markNotNeededToday = "mark_not_needed_today"
    case markNeedsRecovery = "mark_needs_recovery"
    case keepDeadline = "keep_deadline"
    case adjustTimeline = "adjust_timeline"

    var displayName: String {
        switch self {
        case .move:
            return "Move"
        case .shorten:
            return "Shorten"
        case .hold:
            return "Hold"
        case .markNotNeededToday:
            return "Mark not needed today"
        case .markNeedsRecovery:
            return "Mark needs recovery"
        case .keepDeadline:
            return "Keep deadline"
        case .adjustTimeline:
            return "Adjust timeline"
        }
    }

    var receiptTitle: String {
        switch self {
        case .move:
            return "Step moved"
        case .shorten:
            return "Step shortened"
        case .hold:
            return "Step held"
        case .markNotNeededToday:
            return "Step marked not needed today"
        case .markNeedsRecovery:
            return "Step marked needs recovery"
        case .keepDeadline:
            return "Deadline kept"
        case .adjustTimeline:
            return "Timeline adjusted"
        }
    }
}

enum ProjectStepGoalThreadState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case active
    case reflowed
    case continued
    case held
    case waiting
    case needsRecovery = "needs_recovery"
    case notNeededToday = "not_needed_today"
    case deadlineKept = "deadline_kept"
    case timelineAdjusted = "timeline_adjusted"

    var displayName: String {
        switch self {
        case .active:
            return "Active"
        case .reflowed:
            return "Reflowed"
        case .continued:
            return "Continued"
        case .held:
            return "Held"
        case .waiting:
            return "Waiting"
        case .needsRecovery:
            return "Needs recovery"
        case .notNeededToday:
            return "Not needed today"
        case .deadlineKept:
            return "Deadline kept"
        case .timelineAdjusted:
            return "Timeline adjusted"
        }
    }
}

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

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
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

    private static func normalizedRequired(_ value: String) -> String {
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

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
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

    private static func normalizedRequired(_ value: String) -> String {
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
        inspectionSurfaceTitle: String = "What Ambitions knows",
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
        inspectionSurfaceTitle == "What Ambitions knows" && replayTrace.isLocalOnly
    }

    var isWellFormed: Bool {
        Self.isWellFormed(sourceRecord: sourceRecord) &&
            receipt.isWellFormed &&
            replayTrace.isLocalOnly &&
            replayTrace.isReplayable &&
            inspectionSurfaceTitle == "What Ambitions knows" &&
            originalStep.remainsCoherent &&
            continuationContext.isWellFormed &&
            sourceGoalThreadUpdate.isWellFormed &&
            destinationGoalThreadUpdate.isWellFormed &&
            proofOpportunity.isWellFormed &&
            schemaVersion == projectStepClosureProofReplaySchemaVersion
    }

    private static func isWellFormed(sourceRecord: SourceRecord) -> Bool {
        sourceRecord.id.isEmpty == false &&
            sourceRecord.providerID.isEmpty == false &&
            sourceRecord.entityTitle.isEmpty == false &&
            (sourceRecord.locator?.isEmpty == false || sourceRecord.locator == nil)
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
