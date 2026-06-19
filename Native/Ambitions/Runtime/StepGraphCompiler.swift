import Foundation

enum StepGraphNodeKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case installedStep = "installed_step"
    case reserveStep = "reserve_step"
    case proof
    case review
    case dependency
}

enum StepGraphEdgeKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case stageOrdering = "stage_ordering"
    case dependencyRequirement = "dependency_requirement"
    case proofContinuity = "proof_continuity"
    case reviewClosure = "review_closure"
}

enum StepGraphCompilerIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case pathSelectionBlocked = "path_selection_blocked"
    case explicitSelectionRequired = "explicit_selection_required"
    case selectedPathMissing = "selected_path_missing"
    case selectedCompiledCandidateMissing = "selected_compiled_candidate_missing"
    case compiledCandidateBlocked = "compiled_candidate_blocked"
    case missingInstalledStep = "missing_installed_step"
    case missingProofNode = "missing_proof_node"
    case missingReviewNode = "missing_review_node"
    case unresolvedDependency = "unresolved_dependency"
    case dependencyCycle = "dependency_cycle"
    case missingSourceRecord = "missing_source_record"
    case missingReceipt = "missing_receipt"
    case missingReplayTrace = "missing_replay_trace"
    case missingInspectionRoute = "missing_inspection_route"
    case opaqueGraph = "opaque_graph"
    case hiddenMutationRisk = "hidden_mutation_risk"
}

struct StepGraphCompilerNode: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: StepGraphNodeKind
    let title: String
    let summary: String
    let pathID: String
    let candidateID: String
    let stageID: String?
    let dependencyID: String?
    let orderIndex: Int
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?

    var isInspectable: Bool {
        sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil
    }
}

struct StepGraphCompilerEdge: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: StepGraphEdgeKind
    let fromNodeID: String
    let toNodeID: String
    let summary: String
}

struct StepGraphCompilerSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let selectedPathID: String
    let selectedCompiledCandidateID: String
    let nodeIDs: [String]
    let edgeIDs: [String]
    let dependencyNodeIDs: [String]
    let proofNodeIDs: [String]
    let reviewNodeIDs: [String]
    let fingerprint: String
    let localOnly: Bool
}

struct StepGraphCompilerReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let selectedPathID: String
    let selectedCompiledCandidateID: String
    let snapshotID: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String
    let compiledAt: String
    let localOnly: Bool
}

struct StepGraphCompilerTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let selectedPathID: String?
    let selectedCompiledCandidateID: String?
    let graphSnapshotID: String?
    let transitionIDs: [String]
    let issueIDs: [String]
    let replayTraceID: String?
    let localOnly: Bool
}

struct StepGraphCompilerInput: Sendable, Equatable {
    let goalReferenceID: String
    let latticeRecord: MultiPathLatticeRecord
    let compiledPath: GoalCompiledPath
    let selectedCompiledCandidateID: String?
    let graphReceiptID: String?
    let compiledAt: String?

    init(
        goalReferenceID: String,
        latticeRecord: MultiPathLatticeRecord,
        compiledPath: GoalCompiledPath,
        selectedCompiledCandidateID: String? = nil,
        graphReceiptID: String?,
        compiledAt: String?
    ) {
        self.goalReferenceID = Self.normalizedID(goalReferenceID)
        self.latticeRecord = latticeRecord
        self.compiledPath = compiledPath
        self.selectedCompiledCandidateID = Self.normalizedOptional(selectedCompiledCandidateID)
        self.graphReceiptID = Self.normalizedOptional(graphReceiptID)
        self.compiledAt = Self.normalizedOptional(compiledAt)
    }

    static func normalizedID(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }
}

struct StepGraphCompilerRecord: Sendable, Equatable {
    let id: String
    let goalReferenceID: String
    let selectedPathID: String?
    let selectedCompiledCandidateID: String?
    let nodes: [StepGraphCompilerNode]
    let edges: [StepGraphCompilerEdge]
    let snapshot: StepGraphCompilerSnapshot?
    let receipt: StepGraphCompilerReceipt?
    let trace: StepGraphCompilerTrace
    let issues: [StepGraphCompilerIssue]

    var canDriveGraphCompilerSegment: Bool {
        issues.isEmpty && snapshot != nil && receipt != nil && nodes.allSatisfy(\.isInspectable)
    }

    var runtimeCoreSegment: RuntimeCoreChainSegment {
        RuntimeCoreChainSegment(
            kind: .graphCompiler,
            state: canDriveGraphCompilerSegment ? .ready : .blocked,
            sourceRecordIDs: receipt?.sourceRecordIDs ?? [],
            receiptIDs: receipt?.receiptIDs ?? [],
            replayTraceID: receipt?.replayTraceID,
            whatAmbitionsKnowsRoute: receipt?.whatAmbitionsKnowsRoute,
            isReversible: true,
            canDriveVisibleExecution: canDriveGraphCompilerSegment,
            blocksDownstream: canDriveGraphCompilerSegment == false
        )
    }
}
