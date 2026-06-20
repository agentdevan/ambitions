import Foundation

enum StepElasticityActionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case shrink
    case replace
    case keepMomentum = "keep_momentum"
    case stillCounts = "still_counts"

    var orderIndex: Int {
        switch self {
        case .shrink:
            return 0
        case .replace:
            return 1
        case .keepMomentum:
            return 2
        case .stillCounts:
            return 3
        }
    }
}

enum StepElasticityIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case graphCompilerBlocked = "graph_compiler_blocked"
    case missingGraphSnapshot = "missing_graph_snapshot"
    case missingGraphReceipt = "missing_graph_receipt"
    case missingInstalledNode = "missing_installed_node"
    case missingReserveNode = "missing_reserve_node"
    case missingProofNode = "missing_proof_node"
    case missingPartialProgressProof = "missing_partial_progress_proof"
    case missingSourceRecord = "missing_source_record"
    case missingReceipt = "missing_receipt"
    case missingReplayTrace = "missing_replay_trace"
    case missingInspectionRoute = "missing_inspection_route"
    case missingShrinkVariant = "missing_shrink_variant"
    case missingReplaceVariant = "missing_replace_variant"
    case missingKeepMomentumVariant = "missing_keep_momentum_variant"
    case missingStillCountsVariant = "missing_still_counts_variant"
    case shameLanguage = "shame_language"
    case falseCompletionLanguage = "false_completion_language"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case nonLocalRuntimeBoundary = "non_local_runtime_boundary"
    case recoveryContinuityMissing = "recovery_continuity_missing"
    case opaqueAction = "opaque_action"
}

struct StepElasticityPartialProgressProof: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let summary: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let occurredAt: String

    init(
        id: String,
        summary: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?,
        occurredAt: String
    ) {
        self.id = Self.normalizedID(id)
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = Self.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = Self.normalizedIDs(receiptIDs)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = Self.normalizedOptional(whatAmbitionsKnowsRoute)
        self.occurredAt = occurredAt.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            summary.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil
    }

    static func normalizedID(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }
}

struct StepElasticityActionCopy: Codable, Sendable, Equatable, Hashable {
    let title: String
    let summary: String
    let reason: String

    init(title: String, summary: String, reason: String) {
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var combined: String {
        [title, summary, reason].joined(separator: " ")
    }
}

struct StepElasticityVariant: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: StepElasticityActionKind
    let title: String
    let summary: String
    let reason: String
    let sourceNodeID: String
    let replacementNodeID: String?
    let durationMinutes: Int?
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let preservesProof: Bool
    let preservesPartialProgress: Bool
    let recoverySafe: Bool
    let requiresUserApproval: Bool
    let silentlyMutatesPlan: Bool
    let localOnly: Bool

    var isInspectable: Bool {
        title.isEmpty == false &&
            summary.isEmpty == false &&
            reason.isEmpty == false &&
            sourceNodeID.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            preservesProof &&
            localOnly &&
            silentlyMutatesPlan == false
    }
}

struct StepElasticityActionReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let actionKind: StepElasticityActionKind
    let variantID: String
    let actionTaken: String
    let affectedNodeID: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String
    let partialProgressProofID: String?
    let createdAt: String
    let reversible: Bool
    let localOnly: Bool
}

struct StepElasticityCopyValidation: Codable, Sendable, Equatable, Hashable {
    let inspectedVariantIDs: [String]
    let shameLanguageDetected: Bool
    let falseCompletionLanguageDetected: Bool
    let blockedTerms: [String]
    let localOnly: Bool
}

struct StepElasticityActionTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let graphSnapshotID: String?
    let variantIDs: [String]
    let receiptIDs: [String]
    let issueIDs: [String]
    let replayTraceIDs: [String]
    let fingerprint: String
    let localOnly: Bool
}

struct StepElasticityEngineInput: Sendable, Equatable {
    let graphRecord: StepGraphCompilerRecord
    let partialProgressProof: StepElasticityPartialProgressProof?
    let originalDurationMinutes: Int
    let availableMinutes: Int
    let copyOverrides: [StepElasticityActionKind: StepElasticityActionCopy]
    let evaluatedAt: String
    let localOnly: Bool
    let silentlyMutatesPlan: Bool

    init(
        graphRecord: StepGraphCompilerRecord,
        partialProgressProof: StepElasticityPartialProgressProof?,
        originalDurationMinutes: Int,
        availableMinutes: Int,
        copyOverrides: [StepElasticityActionKind: StepElasticityActionCopy] = [:],
        evaluatedAt: String,
        localOnly: Bool = true,
        silentlyMutatesPlan: Bool = false
    ) {
        self.graphRecord = graphRecord
        self.partialProgressProof = partialProgressProof
        self.originalDurationMinutes = max(0, originalDurationMinutes)
        self.availableMinutes = max(0, availableMinutes)
        self.copyOverrides = copyOverrides
        self.evaluatedAt = evaluatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localOnly = localOnly
        self.silentlyMutatesPlan = silentlyMutatesPlan
    }
}

struct StepElasticityRecord: Sendable, Equatable {
    let id: String
    let goalReferenceID: String
    let graphSnapshotID: String?
    let variants: [StepElasticityVariant]
    let receipts: [StepElasticityActionReceipt]
    let copyValidation: StepElasticityCopyValidation
    let trace: StepElasticityActionTrace
    let issues: [StepElasticityIssue]

    var canDriveElasticitySegment: Bool {
        issues.isEmpty &&
            variants.map(\.kind) == StepElasticityActionKind.allCases.sorted { $0.orderIndex < $1.orderIndex } &&
            receipts.count == variants.count &&
            variants.allSatisfy(\.isInspectable) &&
            copyValidation.shameLanguageDetected == false &&
            copyValidation.falseCompletionLanguageDetected == false
    }

    var runtimeCoreSegment: RuntimeCoreChainSegment {
        RuntimeCoreChainSegment(
            kind: .elasticity,
            state: canDriveElasticitySegment ? .ready : .blocked,
            sourceRecordIDs: normalizedIDs(receipts.flatMap(\.sourceRecordIDs)),
            receiptIDs: normalizedIDs(receipts.flatMap(\.receiptIDs) + receipts.map(\.id)),
            replayTraceID: canDriveElasticitySegment ? trace.id : nil,
            whatAmbitionsKnowsRoute: canDriveElasticitySegment ? "you://what-ambitions-knows/elasticity/\(goalReferenceID)" : nil,
            isReversible: true,
            canDriveVisibleExecution: canDriveElasticitySegment,
            blocksDownstream: canDriveElasticitySegment == false
        )
    }
}
