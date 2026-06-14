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

    private static func normalizedID(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    private static func normalizedOptional(_ value: String?) -> String? {
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

    private static func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    private static func normalizedOptional(_ value: String?) -> String? {
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

    private static func normalizedID(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    private static func normalizedOptional(_ value: String?) -> String? {
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

    private static func normalizedID(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    private static func normalizedOptional(_ value: String?) -> String? {
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

struct ScheduleInstallRecord: Sendable, Equatable {
    let id: String
    let goalReferenceID: String
    let preview: ScheduleInstallPreview?
    let installReceipt: ScheduleInstallReceipt?
    let rollbackTrace: ScheduleInstallRollbackTrace?
    let trace: ScheduleInstallTrace
    let issues: [ScheduleInstallIssue]

    var canDriveScheduleInstallSegment: Bool {
        issues.isEmpty &&
            preview != nil &&
            installReceipt != nil &&
            rollbackTrace != nil
    }

    var runtimeCoreSegment: RuntimeCoreChainSegment {
        RuntimeCoreChainSegment(
            kind: .scheduleInstall,
            state: canDriveScheduleInstallSegment ? .ready : .blocked,
            sourceRecordIDs: normalizedIDs((installReceipt?.sourceRecordIDs ?? []) + (rollbackTrace?.sourceRecordIDs ?? [])),
            receiptIDs: normalizedIDs((installReceipt?.receiptIDs ?? []) + (rollbackTrace?.receiptIDs ?? [])),
            replayTraceID: canDriveScheduleInstallSegment ? trace.id : nil,
            whatAmbitionsKnowsRoute: canDriveScheduleInstallSegment ? "you://what-ambitions-knows/schedule-install/\(goalReferenceID)" : nil,
            isReversible: rollbackTrace?.reversible == true,
            canDriveVisibleExecution: canDriveScheduleInstallSegment,
            blocksDownstream: canDriveScheduleInstallSegment == false
        )
    }
}

struct ScheduleInstallKernel: Sendable, Equatable {
    func evaluate(_ input: ScheduleInstallInput) -> ScheduleInstallRecord {
        var issues = baselineIssues(for: input)
        let selectedVariant = selectedVariant(for: input)
        let preview = makePreview(input: input, selectedVariant: selectedVariant)
        issues.formUnion(previewIssues(preview, input: input))

        let selectedWindow = selectedWindow(for: preview, decision: input.decision)
        issues.formUnion(windowIssues(selectedWindow, protectedTimeProof: input.protectedTimeProof))
        issues.formUnion(decisionIssues(input.decision))
        issues.formUnion(rollbackIssues(input.rollbackPlan, decision: input.decision))

        let sortedIssues = sortedIssues(issues)
        let rollbackTrace = sortedIssues.isEmpty ? makeRollbackTrace(input: input, preview: preview) : nil
        let installReceipt = sortedIssues.isEmpty ? makeReceipt(input: input, preview: preview, selectedWindow: selectedWindow, rollbackTrace: rollbackTrace) : nil
        return makeRecord(input: input, preview: preview, installReceipt: installReceipt, rollbackTrace: rollbackTrace, issues: issues)
    }

    private func baselineIssues(for input: ScheduleInstallInput) -> Set<ScheduleInstallIssue> {
        var issues: Set<ScheduleInstallIssue> = []
        if input.elasticityRecord.canDriveElasticitySegment == false {
            issues.insert(.elasticityBlocked)
        }
        if input.elasticityRecord.trace.replayTraceIDs.isEmpty {
            issues.insert(.missingElasticityTrace)
        }
        if input.elasticityRecord.receipts.isEmpty {
            issues.insert(.missingElasticityReceipt)
        }
        if selectedVariant(for: input) == nil {
            issues.insert(.missingSelectedVariant)
        }
        if input.candidateWindows.isEmpty {
            issues.insert(.missingSchedulePreview)
        }
        if input.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        return issues
    }

    private func makePreview(
        input: ScheduleInstallInput,
        selectedVariant: StepElasticityVariant?
    ) -> ScheduleInstallPreview? {
        guard input.elasticityRecord.canDriveElasticitySegment, let selectedVariant else {
            return nil
        }
        let windows = input.candidateWindows.sorted { lhs, rhs in
            if lhs.startAt == rhs.startAt {
                return lhs.id < rhs.id
            }
            return lhs.startAt < rhs.startAt
        }
        guard windows.isEmpty == false else {
            return nil
        }
        let sourceRecordIDs = normalizedIDs(
            selectedVariant.sourceRecordIDs +
                input.elasticityRecord.receipts.flatMap(\.sourceRecordIDs) +
                windows.flatMap(\.sourceRecordIDs) +
                (input.protectedTimeProof?.sourceRecordIDs ?? [])
        )
        let receiptIDs = normalizedIDs(
            selectedVariant.receiptIDs +
                input.elasticityRecord.receipts.flatMap(\.receiptIDs) +
                windows.flatMap(\.receiptIDs) +
                (input.protectedTimeProof?.receiptIDs ?? [])
        )
        let replayTraceIDs = normalizedIDs(
            input.elasticityRecord.trace.replayTraceIDs +
                windows.compactMap(\.replayTraceID) +
                [input.protectedTimeProof?.replayTraceID].compactMap { $0 }
        )
        let routes = normalizedIDs(
            windows.compactMap(\.whatAmbitionsKnowsRoute) +
                [input.protectedTimeProof?.whatAmbitionsKnowsRoute, selectedVariant.whatAmbitionsKnowsRoute].compactMap { $0 }
        )
        return ScheduleInstallPreview(
            id: stableIdentifier(
                prefix: "schedule-install.preview",
                components: [
                    input.elasticityRecord.goalReferenceID,
                    selectedVariant.id,
                    windows.map(\.id).joined(separator: ",")
                ]
            ),
            selectedVariantID: selectedVariant.id,
            selectedWindowID: input.decision?.selectedWindowID,
            candidateWindows: windows,
            protectedWindowIDs: windows.filter(\.isProtectedTime).map(\.id).sorted(),
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            whatAmbitionsKnowsRoutes: routes
        )
    }

    private func selectedVariant(for input: ScheduleInstallInput) -> StepElasticityVariant? {
        guard let selectedVariantID = input.selectedVariantID, selectedVariantID.isEmpty == false else {
            return nil
        }
        return input.elasticityRecord.variants.first { $0.id == selectedVariantID }
    }

    private func selectedWindow(
        for preview: ScheduleInstallPreview?,
        decision: ScheduleInstallDecision?
    ) -> ScheduleInstallTimeWindow? {
        guard let selectedWindowID = decision?.selectedWindowID else {
            return nil
        }
        return preview?.candidateWindows.first { $0.id == selectedWindowID }
    }

    private func previewIssues(_ preview: ScheduleInstallPreview?, input: ScheduleInstallInput) -> Set<ScheduleInstallIssue> {
        guard let preview else {
            return [.missingSchedulePreview]
        }
        var issues: Set<ScheduleInstallIssue> = []
        if preview.sourceRecordIDs.isEmpty {
            issues.insert(.missingSourceRecord)
        }
        if preview.receiptIDs.isEmpty {
            issues.insert(.missingReceipt)
        }
        if preview.replayTraceIDs.isEmpty {
            issues.insert(.missingReplayTrace)
        }
        if preview.whatAmbitionsKnowsRoutes.isEmpty {
            issues.insert(.missingInspectionRoute)
        }
        if preview.protectedWindowIDs.isEmpty == false && input.protectedTimeProof?.isInspectable != true {
            issues.insert(.missingProtectedTimeProof)
        }
        for window in preview.candidateWindows where window.isInspectable == false {
            issues.insert(.invalidTimeWindow)
            if window.sourceRecordIDs.isEmpty {
                issues.insert(.missingSourceRecord)
            }
            if window.receiptIDs.isEmpty {
                issues.insert(.missingReceipt)
            }
            if window.replayTraceID == nil {
                issues.insert(.missingReplayTrace)
            }
            if window.whatAmbitionsKnowsRoute == nil {
                issues.insert(.missingInspectionRoute)
            }
        }
        return issues
    }

    private func windowIssues(
        _ window: ScheduleInstallTimeWindow?,
        protectedTimeProof: ScheduleInstallProtectedTimeProof?
    ) -> Set<ScheduleInstallIssue> {
        guard let window else {
            return [.missingSelectedWindow]
        }
        var issues: Set<ScheduleInstallIssue> = []
        if window.isInspectable == false {
            issues.insert(.invalidTimeWindow)
        }
        if window.isProtectedTime {
            issues.insert(.protectedTimeConflict)
            if protectedTimeProof?.isInspectable != true {
                issues.insert(.missingProtectedTimeProof)
            }
        }
        return issues
    }

    private func decisionIssues(_ decision: ScheduleInstallDecision?) -> Set<ScheduleInstallIssue> {
        guard let decision else {
            return [.missingCommitDecision]
        }
        var issues: Set<ScheduleInstallIssue> = []
        if decision.kind != .commit || decision.userApproved == false {
            issues.insert(.installNotCommitted)
        }
        if decision.decisionReceiptID == nil {
            issues.insert(.missingDecisionReceipt)
        }
        if decision.isInspectable == false {
            if decision.sourceRecordIDs.isEmpty {
                issues.insert(.missingSourceRecord)
            }
            if decision.receiptIDs.isEmpty || decision.decisionReceiptID == nil {
                issues.insert(.missingReceipt)
            }
            if decision.replayTraceID == nil {
                issues.insert(.missingReplayTrace)
            }
            if decision.whatAmbitionsKnowsRoute == nil {
                issues.insert(.missingInspectionRoute)
            }
            issues.insert(.opaqueInstall)
        }
        if decision.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        if decision.silentlyMutatesTime {
            issues.insert(.silentTimeMutation)
        }
        return issues
    }

    private func rollbackIssues(
        _ rollbackPlan: ScheduleInstallRollbackPlan?,
        decision: ScheduleInstallDecision?
    ) -> Set<ScheduleInstallIssue> {
        guard decision?.kind == .commit else {
            return []
        }
        guard let rollbackPlan else {
            return [.missingRollbackTrace]
        }
        var issues: Set<ScheduleInstallIssue> = []
        if rollbackPlan.isInspectable == false {
            issues.insert(.missingRollbackTrace)
            if rollbackPlan.sourceRecordIDs.isEmpty {
                issues.insert(.missingSourceRecord)
            }
            if rollbackPlan.receiptIDs.isEmpty || rollbackPlan.rollbackReceiptID.isEmpty {
                issues.insert(.missingReceipt)
            }
            if rollbackPlan.replayTraceID == nil {
                issues.insert(.missingReplayTrace)
            }
            if rollbackPlan.whatAmbitionsKnowsRoute == nil {
                issues.insert(.missingInspectionRoute)
            }
            if rollbackPlan.reversible == false {
                issues.insert(.irreversibleInstall)
            }
        }
        if rollbackPlan.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        return issues
    }

    private func makeReceipt(
        input: ScheduleInstallInput,
        preview: ScheduleInstallPreview?,
        selectedWindow: ScheduleInstallTimeWindow?,
        rollbackTrace: ScheduleInstallRollbackTrace?
    ) -> ScheduleInstallReceipt? {
        guard
            let preview,
            let decision = input.decision,
            let selectedWindow,
            let decisionReceiptID = decision.decisionReceiptID,
            let rollbackTrace
        else {
            return nil
        }
        let receiptID = stableIdentifier(
            prefix: "schedule-install.receipt",
            components: [
                input.elasticityRecord.goalReferenceID,
                preview.id,
                selectedWindow.id,
                decisionReceiptID
            ]
        )
        let sourceRecordIDs = normalizedIDs(preview.sourceRecordIDs + selectedWindow.sourceRecordIDs + decision.sourceRecordIDs + rollbackTrace.sourceRecordIDs)
        let receiptIDs = normalizedIDs(preview.receiptIDs + selectedWindow.receiptIDs + decision.receiptIDs + [decisionReceiptID, receiptID])
        return ScheduleInstallReceipt(
            id: receiptID,
            previewID: preview.id,
            selectedVariantID: preview.selectedVariantID,
            selectedWindowID: selectedWindow.id,
            decisionReceiptID: decisionReceiptID,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceID: decision.replayTraceID ?? selectedWindow.replayTraceID ?? rollbackTrace.replayTraceID,
            whatAmbitionsKnowsRoute: decision.whatAmbitionsKnowsRoute ?? selectedWindow.whatAmbitionsKnowsRoute ?? rollbackTrace.whatAmbitionsKnowsRoute,
            rollbackTraceID: rollbackTrace.id,
            createdAt: input.evaluatedAt,
            reversible: true,
            localOnly: true
        )
    }

    private func makeRollbackTrace(
        input: ScheduleInstallInput,
        preview: ScheduleInstallPreview?
    ) -> ScheduleInstallRollbackTrace? {
        guard let preview, let rollbackPlan = input.rollbackPlan else {
            return nil
        }
        let installReceiptID = stableIdentifier(
            prefix: "schedule-install.receipt",
            components: [
                input.elasticityRecord.goalReferenceID,
                preview.id,
                input.decision?.selectedWindowID ?? "missing-window",
                input.decision?.decisionReceiptID ?? "missing-decision-receipt"
            ]
        )
        return ScheduleInstallRollbackTrace(
            id: stableIdentifier(
                prefix: "schedule-install.rollback",
                components: [
                    preview.id,
                    rollbackPlan.id,
                    rollbackPlan.previousScheduleSnapshotID
                ]
            ),
            previewID: preview.id,
            installReceiptID: installReceiptID,
            previousScheduleSnapshotID: rollbackPlan.previousScheduleSnapshotID,
            rollbackReceiptID: rollbackPlan.rollbackReceiptID,
            sourceRecordIDs: rollbackPlan.sourceRecordIDs,
            receiptIDs: normalizedIDs(rollbackPlan.receiptIDs + [rollbackPlan.rollbackReceiptID]),
            replayTraceID: rollbackPlan.replayTraceID ?? "missing-ReplayTrace",
            whatAmbitionsKnowsRoute: rollbackPlan.whatAmbitionsKnowsRoute ?? "you://what-ambitions-knows/schedule-install/\(input.elasticityRecord.goalReferenceID)",
            reversible: rollbackPlan.reversible,
            localOnly: rollbackPlan.localOnly
        )
    }

    private func makeRecord(
        input: ScheduleInstallInput,
        preview: ScheduleInstallPreview?,
        installReceipt: ScheduleInstallReceipt?,
        rollbackTrace: ScheduleInstallRollbackTrace?,
        issues: Set<ScheduleInstallIssue>
    ) -> ScheduleInstallRecord {
        let sortedIssues = sortedIssues(issues)
        let trace = makeTrace(input: input, preview: preview, installReceipt: installReceipt, rollbackTrace: rollbackTrace, issues: sortedIssues)
        return ScheduleInstallRecord(
            id: stableIdentifier(
                prefix: "schedule-install.record",
                components: [
                    input.elasticityRecord.goalReferenceID,
                    preview?.id ?? "missing-preview",
                    installReceipt?.id ?? "missing-install-receipt",
                    rollbackTrace?.id ?? "missing-rollback",
                    sortedIssues.map(\.rawValue).joined(separator: ",")
                ]
            ),
            goalReferenceID: input.elasticityRecord.goalReferenceID,
            preview: preview,
            installReceipt: installReceipt,
            rollbackTrace: rollbackTrace,
            trace: trace,
            issues: sortedIssues
        )
    }

    private func makeTrace(
        input: ScheduleInstallInput,
        preview: ScheduleInstallPreview?,
        installReceipt: ScheduleInstallReceipt?,
        rollbackTrace: ScheduleInstallRollbackTrace?,
        issues: [ScheduleInstallIssue]
    ) -> ScheduleInstallTrace {
        let issueIDs = issues.map(\.rawValue)
        let replayTraceIDs = normalizedIDs(
            (preview?.replayTraceIDs ?? []) +
                [installReceipt?.replayTraceID, rollbackTrace?.replayTraceID].compactMap { $0 }
        )
        let fingerprint = stableIdentifier(
            prefix: "schedule-install.fingerprint",
            components: [
                preview?.id ?? "missing-preview",
                installReceipt?.id ?? "missing-install-receipt",
                rollbackTrace?.id ?? "missing-rollback",
                replayTraceIDs.joined(separator: ","),
                issueIDs.joined(separator: ",")
            ]
        )
        return ScheduleInstallTrace(
            id: stableIdentifier(
                prefix: "schedule-install.trace",
                components: [
                    input.elasticityRecord.goalReferenceID,
                    fingerprint
                ]
            ),
            goalReferenceID: input.elasticityRecord.goalReferenceID,
            previewID: preview?.id,
            installReceiptID: installReceipt?.id,
            rollbackTraceID: rollbackTrace?.id,
            issueIDs: issueIDs,
            replayTraceIDs: replayTraceIDs,
            fingerprint: fingerprint,
            localOnly: input.localOnly
        )
    }

    private func sortedIssues(_ issues: Set<ScheduleInstallIssue>) -> [ScheduleInstallIssue] {
        issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func stableIdentifier(prefix: String, components: [String]) -> String {
        ([prefix] + components.map { normalizedToken($0) })
            .filter { $0.isEmpty == false }
            .joined(separator: ".")
    }

    private func normalizedToken(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
    }

    private func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

private extension ScheduleInstallRecord {
    func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
