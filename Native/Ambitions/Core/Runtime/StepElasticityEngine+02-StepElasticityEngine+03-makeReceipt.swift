import Foundation

extension StepElasticityEngine {

    func makeReceipt(
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


    func makeRecord(
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


    func makeTrace(
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


    func copyValidation(for variants: [StepElasticityVariant]) -> StepElasticityCopyValidation {
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


    func sortedIssues(_ issues: Set<StepElasticityIssue>) -> [StepElasticityIssue] {
        issues.sorted { $0.rawValue < $1.rawValue }
    }


    func stableIdentifier(prefix: String, components: [String]) -> String {
        ([prefix] + components.map { normalizedToken($0) })
            .filter { $0.isEmpty == false }
            .joined(separator: ".")
    }


    func normalizedToken(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
    }


    func normalizedCopy(_ value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }


    func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }


    static let shamePhrases: Set<String> = [
        "not enough",
        "no excuses",
        "not enough",
        "lazy",
        "should have",
        "disappointed in yourself"
    ]

    static let falseCompletionPhrases: Set<String> = [
        "mark complete",
        "counts as done",
        "done anyway",
        "finished anyway",
        "pretend finished",
        "as if finished"
    ]
}
