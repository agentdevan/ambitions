import Foundation

extension StepElasticityEngine {
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


    func baselineIssues(for input: StepElasticityEngineInput) -> Set<StepElasticityIssue> {
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


    func makeVariants(input: StepElasticityEngineInput) -> [StepElasticityVariant] {
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


    func makeVariant(
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


    func variantIssues(_ variants: [StepElasticityVariant]) -> Set<StepElasticityIssue> {
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


    func copyIssues(for variants: [StepElasticityVariant]) -> Set<StepElasticityIssue> {
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
}
