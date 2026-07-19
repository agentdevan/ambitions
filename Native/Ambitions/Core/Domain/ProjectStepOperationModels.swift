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

extension GoalThread {
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

extension Commitment {
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

extension Step {
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
        inspectionSurfaceTitle: String = "Search Ambitions",
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
        inspectionSurfaceTitle == "Search Ambitions" && replayTrace.isLocalOnly
    }

    var operationReceiptTitles: [String] {
        operationReceipts.map(\.title)
    }

    var isWellFormed: Bool {
        Self.isWellFormed(sourceRecord: sourceRecord) &&
            receipt.isWellFormed &&
            replayTrace.isLocalOnly &&
            replayTrace.isReplayable &&
            inspectionSurfaceTitle == "Search Ambitions" &&
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

    static func isWellFormed(sourceRecord: SourceRecord) -> Bool {
        sourceRecord.id.isEmpty == false &&
            sourceRecord.providerID.isEmpty == false &&
            sourceRecord.entityTitle.isEmpty == false &&
            (sourceRecord.locator?.isEmpty == false || sourceRecord.locator == nil)
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

    static func orderedUnique<T: Hashable>(_ values: [T]) -> [T] {
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
