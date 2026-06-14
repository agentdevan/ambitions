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

struct StepElasticityEngine: Sendable, Equatable {
    func evaluate(_ input: StepElasticityEngineInput) -> StepElasticityRecord {
        var issues: Set<StepElasticityIssue> = baselineIssues(for: input)
        if input.graphRecord.canDriveGraphCompilerSegment == false {
            return makeRecord(input: input, variants: [], receipts: [], issues: issues)
        }

        let variants = makeVariants(input: input)
        issues.formUnion(variantIssues(variants))
        issues.formUnion(copyIssues(for: variants))
        if input.partialProgressProof?.isInspectable != true {
            issues.insert(.recoveryContinuityMissing)
        }

        let sortedIssues = sortedIssues(issues)
        let receipts = sortedIssues.isEmpty ? variants.map { makeReceipt(for: $0, input: input) } : []
        return makeRecord(input: input, variants: variants, receipts: receipts, issues: issues)
    }

    private func baselineIssues(for input: StepElasticityEngineInput) -> Set<StepElasticityIssue> {
        var issues: Set<StepElasticityIssue> = []
        if input.graphRecord.canDriveGraphCompilerSegment == false {
            issues.insert(.graphCompilerBlocked)
        }
        if input.graphRecord.snapshot == nil {
            issues.insert(.missingGraphSnapshot)
        }
        if input.graphRecord.receipt == nil {
            issues.insert(.missingGraphReceipt)
        }
        if input.graphRecord.nodes.contains(where: { $0.kind == .installedStep }) == false {
            issues.insert(.missingInstalledNode)
        }
        if input.graphRecord.nodes.contains(where: { $0.kind == .reserveStep }) == false {
            issues.insert(.missingReserveNode)
        }
        if input.graphRecord.nodes.contains(where: { $0.kind == .proof }) == false {
            issues.insert(.missingProofNode)
        }
        if input.partialProgressProof?.isInspectable != true {
            issues.insert(.missingPartialProgressProof)
        }
        if let partialProgressProof = input.partialProgressProof {
            if partialProgressProof.sourceRecordIDs.isEmpty {
                issues.insert(.missingSourceRecord)
            }
            if partialProgressProof.receiptIDs.isEmpty {
                issues.insert(.missingReceipt)
            }
            if partialProgressProof.replayTraceID == nil {
                issues.insert(.missingReplayTrace)
            }
            if partialProgressProof.whatAmbitionsKnowsRoute == nil {
                issues.insert(.missingInspectionRoute)
            }
        }
        if input.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        if input.silentlyMutatesPlan {
            issues.insert(.hiddenMutationRisk)
        }
        return issues
    }

    private func makeVariants(input: StepElasticityEngineInput) -> [StepElasticityVariant] {
        let nodes = input.graphRecord.nodes.sorted { lhs, rhs in
            if lhs.orderIndex == rhs.orderIndex {
                return lhs.id < rhs.id
            }
            return lhs.orderIndex < rhs.orderIndex
        }
        let installedNode = nodes.first { $0.kind == .installedStep }
        let reserveNode = nodes.first { $0.kind == .reserveStep }
        let proofNode = nodes.first { $0.kind == .proof }
        let partialProof = input.partialProgressProof

        let shrinkMinutes = max(1, min(max(1, input.availableMinutes), max(1, input.originalDurationMinutes / 2)))
        let graphReceiptIDs = input.graphRecord.receipt?.receiptIDs ?? []
        let graphReplayTraceID = input.graphRecord.receipt?.replayTraceID
        let graphRoute = input.graphRecord.receipt?.whatAmbitionsKnowsRoute

        return [
            makeVariant(
                kind: .shrink,
                node: installedNode,
                replacementNode: nil,
                durationMinutes: shrinkMinutes,
                sourceRecordIDs: installedNode?.sourceRecordIDs ?? [],
                receiptIDs: graphReceiptIDs,
                replayTraceID: graphReplayTraceID,
                inspectionRoute: graphRoute,
                partialProof: nil,
                copy: input.copyOverrides[.shrink] ?? StepElasticityActionCopy(
                    title: "Shrink",
                    summary: "Use a smaller version that still preserves proof.",
                    reason: "Current capacity is smaller than the original step."
                ),
                input: input
            ),
            makeVariant(
                kind: .replace,
                node: installedNode,
                replacementNode: reserveNode,
                durationMinutes: nil,
                sourceRecordIDs: normalizedIDs((installedNode?.sourceRecordIDs ?? []) + (reserveNode?.sourceRecordIDs ?? [])),
                receiptIDs: graphReceiptIDs,
                replayTraceID: graphReplayTraceID,
                inspectionRoute: graphRoute,
                partialProof: nil,
                copy: input.copyOverrides[.replace] ?? StepElasticityActionCopy(
                    title: "Replace",
                    summary: "Use a reserve step that keeps the selected path inspectable.",
                    reason: "The current step no longer fits the moment."
                ),
                input: input
            ),
            makeVariant(
                kind: .keepMomentum,
                node: proofNode,
                replacementNode: nil,
                durationMinutes: nil,
                sourceRecordIDs: proofNode?.sourceRecordIDs ?? [],
                receiptIDs: graphReceiptIDs,
                replayTraceID: graphReplayTraceID,
                inspectionRoute: graphRoute,
                partialProof: nil,
                copy: input.copyOverrides[.keepMomentum] ?? StepElasticityActionCopy(
                    title: "Keep momentum",
                    summary: "Do the proof-preserving part that keeps movement visible.",
                    reason: "The proof node can carry the path forward without pretending the full step fits."
                ),
                input: input
            ),
            makeVariant(
                kind: .stillCounts,
                node: installedNode,
                replacementNode: nil,
                durationMinutes: nil,
                sourceRecordIDs: normalizedIDs((installedNode?.sourceRecordIDs ?? []) + (partialProof?.sourceRecordIDs ?? [])),
                receiptIDs: normalizedIDs(graphReceiptIDs + (partialProof?.receiptIDs ?? [])),
                replayTraceID: partialProof?.replayTraceID ?? graphReplayTraceID,
                inspectionRoute: partialProof?.whatAmbitionsKnowsRoute ?? graphRoute,
                partialProof: partialProof,
                copy: input.copyOverrides[.stillCounts] ?? StepElasticityActionCopy(
                    title: "Still Counts",
                    summary: "Save the progress that happened and keep recovery calm.",
                    reason: "Partial progress has proof and can adjust the next step."
                ),
                input: input
            )
        ].compactMap { $0 }.sorted { $0.kind.orderIndex < $1.kind.orderIndex }
    }

    private func makeVariant(
        kind: StepElasticityActionKind,
        node: StepGraphCompilerNode?,
        replacementNode: StepGraphCompilerNode?,
        durationMinutes: Int?,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        inspectionRoute: String?,
        partialProof: StepElasticityPartialProgressProof?,
        copy: StepElasticityActionCopy,
        input: StepElasticityEngineInput
    ) -> StepElasticityVariant? {
        guard let node else {
            return nil
        }
        let variantID = stableIdentifier(
            prefix: "step-elasticity.variant",
            components: [
                input.goalReferenceID,
                input.graphRecord.snapshot?.id ?? "missing-graph",
                kind.rawValue,
                node.id,
                replacementNode?.id ?? "same-node",
                partialProof?.id ?? "no-partial-proof"
            ]
        )
        return StepElasticityVariant(
            id: variantID,
            kind: kind,
            title: copy.title,
            summary: copy.summary,
            reason: copy.reason,
            sourceNodeID: node.id,
            replacementNodeID: replacementNode?.id,
            durationMinutes: durationMinutes,
            sourceRecordIDs: normalizedIDs(sourceRecordIDs),
            receiptIDs: normalizedIDs(receiptIDs),
            replayTraceID: replayTraceID,
            whatAmbitionsKnowsRoute: inspectionRoute,
            preservesProof: true,
            preservesPartialProgress: kind == .stillCounts,
            recoverySafe: kind == .stillCounts || kind == .shrink,
            requiresUserApproval: true,
            silentlyMutatesPlan: input.silentlyMutatesPlan,
            localOnly: input.localOnly
        )
    }

    private func variantIssues(_ variants: [StepElasticityVariant]) -> Set<StepElasticityIssue> {
        var issues: Set<StepElasticityIssue> = []
        let kinds = Set(variants.map(\.kind))
        if kinds.contains(.shrink) == false {
            issues.insert(.missingShrinkVariant)
        }
        if kinds.contains(.replace) == false {
            issues.insert(.missingReplaceVariant)
        }
        if kinds.contains(.keepMomentum) == false {
            issues.insert(.missingKeepMomentumVariant)
        }
        if kinds.contains(.stillCounts) == false {
            issues.insert(.missingStillCountsVariant)
        }
        for variant in variants {
            if variant.sourceRecordIDs.isEmpty {
                issues.insert(.missingSourceRecord)
            }
            if variant.receiptIDs.isEmpty {
                issues.insert(.missingReceipt)
            }
            if variant.replayTraceID == nil {
                issues.insert(.missingReplayTrace)
            }
            if variant.whatAmbitionsKnowsRoute == nil {
                issues.insert(.missingInspectionRoute)
            }
            if variant.isInspectable == false {
                issues.insert(.opaqueAction)
            }
            if variant.localOnly == false {
                issues.insert(.nonLocalRuntimeBoundary)
            }
            if variant.silentlyMutatesPlan {
                issues.insert(.hiddenMutationRisk)
            }
        }
        return issues
    }

    private func copyIssues(for variants: [StepElasticityVariant]) -> Set<StepElasticityIssue> {
        let validation = copyValidation(for: variants)
        var issues: Set<StepElasticityIssue> = []
        if validation.shameLanguageDetected {
            issues.insert(.shameLanguage)
        }
        if validation.falseCompletionLanguageDetected {
            issues.insert(.falseCompletionLanguage)
        }
        return issues
    }

    private func makeReceipt(
        for variant: StepElasticityVariant,
        input: StepElasticityEngineInput
    ) -> StepElasticityActionReceipt {
        let receiptID = stableIdentifier(
            prefix: "step-elasticity.receipt",
            components: [
                input.goalReferenceID,
                input.graphRecord.snapshot?.id ?? "missing-graph",
                variant.kind.rawValue,
                variant.id
            ]
        )
        return StepElasticityActionReceipt(
            id: receiptID,
            actionKind: variant.kind,
            variantID: variant.id,
            actionTaken: variant.title,
            affectedNodeID: variant.sourceNodeID,
            sourceRecordIDs: variant.sourceRecordIDs,
            receiptIDs: normalizedIDs(variant.receiptIDs + [receiptID]),
            replayTraceID: variant.replayTraceID ?? input.graphRecord.receipt?.replayTraceID ?? "missing-ReplayTrace",
            whatAmbitionsKnowsRoute: variant.whatAmbitionsKnowsRoute ?? "you://what-ambitions-knows/elasticity/\(input.goalReferenceID)",
            partialProgressProofID: variant.kind == .stillCounts ? input.partialProgressProof?.id : nil,
            createdAt: input.evaluatedAt,
            reversible: true,
            localOnly: true
        )
    }

    private func makeRecord(
        input: StepElasticityEngineInput,
        variants: [StepElasticityVariant],
        receipts: [StepElasticityActionReceipt],
        issues: Set<StepElasticityIssue>
    ) -> StepElasticityRecord {
        let sortedIssues = sortedIssues(issues)
        let validation = copyValidation(for: variants)
        let trace = makeTrace(input: input, variants: variants, receipts: receipts, issues: sortedIssues)
        return StepElasticityRecord(
            id: stableIdentifier(
                prefix: "step-elasticity.record",
                components: [
                    input.goalReferenceID,
                    input.graphRecord.snapshot?.id ?? "missing-graph",
                    variants.map(\.id).joined(separator: ","),
                    sortedIssues.map(\.rawValue).joined(separator: ",")
                ]
            ),
            goalReferenceID: input.goalReferenceID,
            graphSnapshotID: input.graphRecord.snapshot?.id,
            variants: variants,
            receipts: receipts,
            copyValidation: validation,
            trace: trace,
            issues: sortedIssues
        )
    }

    private func makeTrace(
        input: StepElasticityEngineInput,
        variants: [StepElasticityVariant],
        receipts: [StepElasticityActionReceipt],
        issues: [StepElasticityIssue]
    ) -> StepElasticityActionTrace {
        let variantIDs = variants.map(\.id).sorted()
        let receiptIDs = receipts.map(\.id).sorted()
        let replayTraceIDs = normalizedIDs(variants.compactMap(\.replayTraceID) + receipts.map(\.replayTraceID))
        let issueIDs = issues.map(\.rawValue)
        let fingerprint = stableIdentifier(
            prefix: "step-elasticity.fingerprint",
            components: variantIDs + receiptIDs + replayTraceIDs + issueIDs
        )
        return StepElasticityActionTrace(
            id: stableIdentifier(
                prefix: "step-elasticity.trace",
                components: [
                    input.goalReferenceID,
                    input.graphRecord.snapshot?.id ?? "missing-graph",
                    fingerprint
                ]
            ),
            goalReferenceID: input.goalReferenceID,
            graphSnapshotID: input.graphRecord.snapshot?.id,
            variantIDs: variantIDs,
            receiptIDs: receiptIDs,
            issueIDs: issueIDs,
            replayTraceIDs: replayTraceIDs,
            fingerprint: fingerprint,
            localOnly: true
        )
    }

    private func copyValidation(for variants: [StepElasticityVariant]) -> StepElasticityCopyValidation {
        var blockedTerms: Set<String> = []
        for variant in variants {
            let normalizedCopy = normalizedCopy([variant.title, variant.summary, variant.reason].joined(separator: " "))
            for term in Self.shamePhrases where normalizedCopy.contains(term) {
                blockedTerms.insert(term)
            }
            for term in Self.falseCompletionPhrases where normalizedCopy.contains(term) {
                blockedTerms.insert(term)
            }
        }
        let shameDetected = blockedTerms.contains(where: { Self.shamePhrases.contains($0) })
        let falseCompletionDetected = blockedTerms.contains(where: { Self.falseCompletionPhrases.contains($0) })
        return StepElasticityCopyValidation(
            inspectedVariantIDs: variants.map(\.id).sorted(),
            shameLanguageDetected: shameDetected,
            falseCompletionLanguageDetected: falseCompletionDetected,
            blockedTerms: Array(blockedTerms).sorted(),
            localOnly: true
        )
    }

    private func sortedIssues(_ issues: Set<StepElasticityIssue>) -> [StepElasticityIssue] {
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

    private func normalizedCopy(_ value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    private static let shamePhrases: Set<String> = [
        "not enough",
        "no excuses",
        "not enough",
        "lazy",
        "should have",
        "disappointed in yourself"
    ]

    private static let falseCompletionPhrases: Set<String> = [
        "mark complete",
        "counts as done",
        "done anyway",
        "finished anyway",
        "pretend finished",
        "as if finished"
    ]
}

private extension StepElasticityEngineInput {
    var goalReferenceID: String {
        graphRecord.goalReferenceID
    }
}

private extension StepElasticityRecord {
    func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
