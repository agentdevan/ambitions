import Foundation

let projectStepOperationSchemaVersion = "project_step_operation.native.v1"
let projectStepBulkDownstreamContractSchemaVersion = "project_step_bulk_downstream_contract.native.v1"
let projectStepClosureProofReplaySchemaVersion = "project_step_closure_proof_replay.native.v1"
let stepReallocationEventSchemaVersion = "step_reallocation_event.native.v1"

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

struct StepReallocationTimeContext: Codable, Sendable, Equatable, Hashable {
    let scheduledBlockLabel: String
    let timeWindowLabel: String
    let protectedTimeLabel: String
    let scheduleImpactSummary: String
    let isProtectedTimeVisible: Bool

    init(
        scheduledBlockLabel: String,
        timeWindowLabel: String,
        protectedTimeLabel: String,
        scheduleImpactSummary: String,
        isProtectedTimeVisible: Bool
    ) {
        self.scheduledBlockLabel = Self.normalizedRequired(scheduledBlockLabel)
        self.timeWindowLabel = Self.normalizedRequired(timeWindowLabel)
        self.protectedTimeLabel = Self.normalizedRequired(protectedTimeLabel)
        self.scheduleImpactSummary = Self.normalizedRequired(scheduleImpactSummary)
        self.isProtectedTimeVisible = isProtectedTimeVisible
    }

    var isWellFormed: Bool {
        scheduledBlockLabel.isEmpty == false &&
            timeWindowLabel.isEmpty == false &&
            protectedTimeLabel.isEmpty == false &&
            scheduleImpactSummary.isEmpty == false
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
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

    private static func normalizedRequired(_ value: String) -> String {
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

    private static func normalizedRequired(_ value: String) -> String {
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

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct StepReallocationApprovedDecision: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceRecord: SourceRecord
    let receipt: Receipt
    let replayTrace: ReplayTrace
    let timeContext: StepReallocationTimeContext
    let momentumContext: StepReallocationMomentumContext
    let pressureImpact: StepReallocationPressureImpact
    let proofImpact: StepReallocationProofImpact
    let approvedAt: String
    let approvalSummary: String
    let isApproved: Bool

    init(
        id: String,
        sourceRecord: SourceRecord,
        receipt: Receipt,
        replayTrace: ReplayTrace,
        timeContext: StepReallocationTimeContext,
        momentumContext: StepReallocationMomentumContext,
        pressureImpact: StepReallocationPressureImpact,
        proofImpact: StepReallocationProofImpact,
        approvedAt: String,
        approvalSummary: String,
        isApproved: Bool
    ) {
        self.id = Self.normalizedRequired(id)
        self.sourceRecord = sourceRecord
        self.receipt = receipt
        self.replayTrace = replayTrace
        self.timeContext = timeContext
        self.momentumContext = momentumContext
        self.pressureImpact = pressureImpact
        self.proofImpact = proofImpact
        self.approvedAt = Self.normalizedRequired(approvedAt)
        self.approvalSummary = Self.normalizedRequired(approvalSummary)
        self.isApproved = isApproved
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            Self.isWellFormed(sourceRecord: sourceRecord) &&
            receipt.isWellFormed &&
            replayTrace.isLocalOnly &&
            replayTrace.isReplayable &&
            timeContext.isWellFormed &&
            momentumContext.isWellFormed &&
            pressureImpact.isWellFormed &&
            proofImpact.isWellFormed &&
            approvedAt.isEmpty == false &&
            approvalSummary.isEmpty == false
    }

    func emitStepReallocationEvent() -> StepReallocationEvent? {
        guard isApproved, isWellFormed else {
            return nil
        }

        return StepReallocationEvent(
            id: "step-reallocation.event.\(id)",
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            timeContext: timeContext,
            momentumContext: momentumContext,
            pressureImpact: pressureImpact,
            proofImpact: proofImpact
        )
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

struct StepReallocationEvent: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceRecord: SourceRecord
    let receipt: Receipt
    let replayTrace: ReplayTrace
    let timeContext: StepReallocationTimeContext
    let momentumContext: StepReallocationMomentumContext
    let pressureImpact: StepReallocationPressureImpact
    let proofImpact: StepReallocationProofImpact
    let schemaVersion: String

    init(
        id: String,
        sourceRecord: SourceRecord,
        receipt: Receipt,
        replayTrace: ReplayTrace,
        timeContext: StepReallocationTimeContext,
        momentumContext: StepReallocationMomentumContext,
        pressureImpact: StepReallocationPressureImpact,
        proofImpact: StepReallocationProofImpact,
        schemaVersion: String = stepReallocationEventSchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.sourceRecord = sourceRecord
        self.receipt = receipt
        self.replayTrace = replayTrace
        self.timeContext = timeContext
        self.momentumContext = momentumContext
        self.pressureImpact = pressureImpact
        self.proofImpact = proofImpact
        self.schemaVersion = Self.normalizedRequired(schemaVersion)
    }

    var sourceRecordLabel: String {
        sourceRecord.entityTitle
    }

    var sourceAdapterUseSummary: String {
        "Step reallocation stays local and inspectable through source adapters."
    }

    var inspectionSurfaceTitle: String {
        "What Ambitions knows"
    }

    var inspectionSummary: String {
        "You / What Ambitions knows can inspect this Step Reallocation source adapter, SourceRecord, Receipt, and ReplayTrace IDs."
    }

    var isInspectableBoundary: Bool {
        inspectionSurfaceTitle == "What Ambitions knows" && replayTrace.isLocalOnly
    }

    var isWellFormed: Bool {
        Self.isWellFormed(sourceRecord: sourceRecord) &&
            receipt.isWellFormed &&
            replayTrace.isLocalOnly &&
            replayTrace.isReplayable &&
            timeContext.isWellFormed &&
            momentumContext.isWellFormed &&
            pressureImpact.isWellFormed &&
            proofImpact.isWellFormed &&
            schemaVersion == stepReallocationEventSchemaVersion
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

struct StepReallocationRuntimeInput: Sendable {
    let event: StepReallocationEvent
    let traceContext: PrivateLifeRuntimeKernelTraceContext
    let decisionKey: String
    let goalText: String?
    let recommendationTrace: RecommendationTrace
    let inspectionSurfaceTitle: String

    var sourceRecord: SourceRecord {
        event.sourceRecord
    }

    var receipt: Receipt {
        event.receipt
    }

    var replayTrace: ReplayTrace {
        event.replayTrace
    }

    var sourceAdapterUseSummary: String {
        event.sourceAdapterUseSummary
    }

    var inspectionSummary: String {
        "You / What Ambitions knows can inspect this Step Reallocation source adapter, SourceRecord, Receipt, and ReplayTrace IDs."
    }

    var isInspectableBoundary: Bool {
        inspectionSurfaceTitle == "What Ambitions knows" && replayTrace.isLocalOnly
    }

    var runtimeInput: PrivateLifeRuntimeKernelDecisionInput {
        PrivateLifeRuntimeKernelDecisionInput(
            traceContext: traceContext,
            decisionKey: decisionKey,
            goalText: goalText,
            recommendationTrace: recommendationTrace
        )
    }
}

struct StepReallocationSourceAdapter: Sendable, Equatable, Hashable {
    let inspectionSurfaceTitle: String

    init(inspectionSurfaceTitle: String = "What Ambitions knows") {
        self.inspectionSurfaceTitle = inspectionSurfaceTitle
    }

    func makeRuntimeInput(
        from event: StepReallocationEvent,
        runtimeContext: RuntimeContextSnapshot,
        goalText: String? = nil
    ) -> StepReallocationRuntimeInput {
        let traceContext = PrivateLifeRuntimeKernelTraceContext(
            runtimeContext: runtimeContext,
            goalText: goalText ?? event.momentumContext.destinationStepTitle
        )
        return StepReallocationRuntimeInput(
            event: event,
            traceContext: traceContext,
            decisionKey: decisionKey(for: event),
            goalText: goalText ?? event.momentumContext.destinationStepTitle,
            recommendationTrace: recommendationTrace(for: event),
            inspectionSurfaceTitle: inspectionSurfaceTitle
        )
    }

    private func decisionKey(for event: StepReallocationEvent) -> String {
        "step.reallocation.\(event.id)"
    }

    private func recommendationTrace(for event: StepReallocationEvent) -> RecommendationTrace {
        RecommendationTrace(
            id: "trace.step-reallocation.\(event.id)",
            recommendationID: "recommendation.step-reallocation.\(event.id)",
            source: RecommendationTraceSource(
                citedSourceIDs: [
                    event.sourceRecord.id,
                    event.receipt.id,
                    event.replayTrace.id,
                    event.replayTrace.decisionID
                ],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .goalState, .contextLens, .recovery],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.step-reallocation.\(event.id)",
                summary: [
                    event.timeContext.scheduleImpactSummary,
                    event.momentumContext.momentumSummary,
                    event.pressureImpact.pressureSummary
                ]
                .joined(separator: " "),
                evidenceCategoryIDs: [
                    RecommendationExplanationEvidenceCategory.sourceTruth.rawValue,
                    RecommendationExplanationEvidenceCategory.goalState.rawValue,
                    RecommendationExplanationEvidenceCategory.contextLens.rawValue,
                    RecommendationExplanationEvidenceCategory.recovery.rawValue
                ]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: [
                    event.timeContext.timeWindowLabel,
                    event.momentumContext.momentumSummary,
                    event.pressureImpact.reviewSummary,
                    event.proofImpact.proofSummary
                ],
                summaries: [
                    event.timeContext.scheduleImpactSummary,
                    event.pressureImpact.pressureSummary,
                    event.proofImpact.proofSummary
                ]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: [
                    RecommendationExplanationCorrectionActionKind.changeDeadline.rawValue,
                    RecommendationExplanationCorrectionActionKind.changeRoute.rawValue,
                    RecommendationExplanationCorrectionActionKind.explainMore.rawValue
                ],
                controlActionIDs: [
                    "open_step",
                    "start_now"
                ],
                correctableFieldKeys: [
                    "sourceRecord",
                    "receipt",
                    "replayTrace",
                    "timeContext",
                    "momentumContext",
                    "pressureImpact",
                    "proofImpact"
                ],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(
                receiptIDs: [event.receipt.id],
                actionReceiptIDs: [event.receipt.id],
                proofReferenceIDs: event.proofImpact.proofReferenceIDs
            )
        )
    }
}
