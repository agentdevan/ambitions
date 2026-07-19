import Foundation

enum ScheduleInstallDecisionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case previewOnly = "preview_only"
    case commit
    case cancel
}

enum ScheduleInstallIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case elasticityBlocked = "elasticity_blocked"
    case missingElasticityTrace = "missing_elasticity_trace"
    case missingElasticityReceipt = "missing_elasticity_receipt"
    case missingSelectedVariant = "missing_selected_variant"
    case missingSchedulePreview = "missing_schedule_preview"
    case missingSelectedWindow = "missing_selected_window"
    case invalidTimeWindow = "invalid_time_window"
    case missingCommitDecision = "missing_commit_decision"
    case installNotCommitted = "install_not_committed"
    case missingDecisionReceipt = "missing_decision_receipt"
    case missingRollbackTrace = "missing_rollback_trace"
    case missingProtectedTimeProof = "missing_protected_time_proof"
    case protectedTimeConflict = "protected_time_conflict"
    case missingSourceRecord = "missing_source_record"
    case missingReceipt = "missing_receipt"
    case missingReplayTrace = "missing_replay_trace"
    case missingInspectionRoute = "missing_inspection_route"
    case silentTimeMutation = "silent_time_mutation"
    case nonLocalRuntimeBoundary = "non_local_runtime_boundary"
    case irreversibleInstall = "irreversible_install"
    case opaqueInstall = "opaque_install"
}

struct ScheduleInstallTimeWindow: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let label: String
    let startAt: String
    let endAt: String
    let durationMinutes: Int
    let isProtectedTime: Bool
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?

    init(
        id: String,
        label: String,
        startAt: String,
        endAt: String,
        durationMinutes: Int,
        isProtectedTime: Bool,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?
    ) {
        self.id = Self.normalizedID(id)
        self.label = label.trimmingCharacters(in: .whitespacesAndNewlines)
        self.startAt = startAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.endAt = endAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.durationMinutes = max(0, durationMinutes)
        self.isProtectedTime = isProtectedTime
        self.sourceRecordIDs = Self.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = Self.normalizedIDs(receiptIDs)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = Self.normalizedOptional(whatAmbitionsKnowsRoute)
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            label.isEmpty == false &&
            startAt.isEmpty == false &&
            endAt.isEmpty == false &&
            durationMinutes > 0 &&
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

struct ScheduleInstallDecision: Codable, Sendable, Equatable, Hashable {
    let kind: ScheduleInstallDecisionKind
    let selectedWindowID: String?
    let userApproved: Bool
    let decisionReceiptID: String?
    let decidedAt: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let localOnly: Bool
    let silentlyMutatesTime: Bool

    init(
        kind: ScheduleInstallDecisionKind,
        selectedWindowID: String?,
        userApproved: Bool,
        decisionReceiptID: String?,
        decidedAt: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?,
        localOnly: Bool = true,
        silentlyMutatesTime: Bool = false
    ) {
        self.kind = kind
        self.selectedWindowID = Self.normalizedOptional(selectedWindowID)
        self.userApproved = userApproved
        self.decisionReceiptID = Self.normalizedOptional(decisionReceiptID)
        self.decidedAt = decidedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = Self.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = Self.normalizedIDs(receiptIDs)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = Self.normalizedOptional(whatAmbitionsKnowsRoute)
        self.localOnly = localOnly
        self.silentlyMutatesTime = silentlyMutatesTime
    }

    var isInspectable: Bool {
        sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            decisionReceiptID != nil &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            decidedAt.isEmpty == false &&
            localOnly &&
            silentlyMutatesTime == false
    }

    var isExplicitCommit: Bool {
        kind == .commit && userApproved && selectedWindowID != nil && decisionReceiptID != nil
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

struct ScheduleInstallRollbackPlan: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let previousScheduleSnapshotID: String
    let rollbackReceiptID: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let localOnly: Bool
    let reversible: Bool

    init(
        id: String,
        previousScheduleSnapshotID: String,
        rollbackReceiptID: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?,
        localOnly: Bool = true,
        reversible: Bool = true
    ) {
        self.id = Self.normalizedID(id)
        self.previousScheduleSnapshotID = previousScheduleSnapshotID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rollbackReceiptID = rollbackReceiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = Self.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = Self.normalizedIDs(receiptIDs)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = Self.normalizedOptional(whatAmbitionsKnowsRoute)
        self.localOnly = localOnly
        self.reversible = reversible
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            previousScheduleSnapshotID.isEmpty == false &&
            rollbackReceiptID.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            localOnly &&
            reversible
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

struct ScheduleInstallProtectedTimeProof: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let protectedWindowIDs: [String]
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?

    init(
        id: String,
        protectedWindowIDs: [String],
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?
    ) {
        self.id = Self.normalizedID(id)
        self.protectedWindowIDs = Self.normalizedIDs(protectedWindowIDs)
        self.sourceRecordIDs = Self.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = Self.normalizedIDs(receiptIDs)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = Self.normalizedOptional(whatAmbitionsKnowsRoute)
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
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

struct ScheduleInstallPreview: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let selectedVariantID: String
    let selectedWindowID: String?
    let candidateWindows: [ScheduleInstallTimeWindow]
    let protectedWindowIDs: [String]
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let whatAmbitionsKnowsRoutes: [String]
}

struct ScheduleInstallReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let previewID: String
    let selectedVariantID: String
    let selectedWindowID: String
    let decisionReceiptID: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String
    let rollbackTraceID: String
    let createdAt: String
    let reversible: Bool
    let localOnly: Bool
}

struct ScheduleInstallRollbackTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let previewID: String
    let installReceiptID: String
    let previousScheduleSnapshotID: String
    let rollbackReceiptID: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String
    let reversible: Bool
    let localOnly: Bool
}

struct ScheduleInstallTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let previewID: String?
    let installReceiptID: String?
    let rollbackTraceID: String?
    let issueIDs: [String]
    let replayTraceIDs: [String]
    let fingerprint: String
    let localOnly: Bool
}

struct ScheduleInstallInput: Sendable, Equatable {
    let elasticityRecord: StepElasticityRecord
    let selectedVariantID: String?
    let candidateWindows: [ScheduleInstallTimeWindow]
    let decision: ScheduleInstallDecision?
    let rollbackPlan: ScheduleInstallRollbackPlan?
    let protectedTimeProof: ScheduleInstallProtectedTimeProof?
    let evaluatedAt: String
    let localOnly: Bool

    init(
        elasticityRecord: StepElasticityRecord,
        selectedVariantID: String?,
        candidateWindows: [ScheduleInstallTimeWindow],
        decision: ScheduleInstallDecision?,
        rollbackPlan: ScheduleInstallRollbackPlan?,
        protectedTimeProof: ScheduleInstallProtectedTimeProof?,
        evaluatedAt: String,
        localOnly: Bool = true
    ) {
        self.elasticityRecord = elasticityRecord
        self.selectedVariantID = selectedVariantID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.candidateWindows = candidateWindows
        self.decision = decision
        self.rollbackPlan = rollbackPlan
        self.protectedTimeProof = protectedTimeProof
        self.evaluatedAt = evaluatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localOnly = localOnly
    }
}
