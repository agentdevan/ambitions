import Foundation

extension RecommendationTrace {

    func reasonGraph(
        runtimeSnapshotReferenceIDs: [String] = [],
        replayTraceIDs: [String] = [],
        localFitLabels: [String] = []
    ) -> RecommendationTraceReasonGraph {
        let policyHook = RecommendationTracePolicyHook(
            privacyClass: source.canSupportRecommendation ? .localOnly : .privateSensitive,
            exportPolicy: .redacted,
            redactionClass: receiptBehavior.state == .receiptAvailable ? .localOnly : .replayRestricted,
            summary: source.canSupportRecommendation
                ? "Local-only redacted export"
                : "Local-only redacted export with source review"
        )
        let sourceNode = RecommendationTraceReasonGraphNode(
            id: "trace.\(id).source",
            kind: .source,
            label: source.canSupportRecommendation ? "Local source support" : "Source review needed",
            sourceIDs: source.citedSourceIDs,
            receiptIDs: receiptBehavior.receiptIDs + receiptBehavior.actionReceiptIDs + receiptBehavior.proofReferenceIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels,
            policyHook: policyHook
        )
        let reasonNode = RecommendationTraceReasonGraphNode(
            id: "trace.\(id).reason",
            kind: .reason,
            label: reason.summary,
            sourceIDs: source.citedSourceIDs,
            receiptIDs: receiptBehavior.receiptIDs + receiptBehavior.actionReceiptIDs + receiptBehavior.proofReferenceIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels,
            policyHook: policyHook
        )
        let fitNode = RecommendationTraceReasonGraphNode(
            id: "trace.\(id).fit",
            kind: .fit,
            label: fit.state.rawValue,
            sourceIDs: source.citedSourceIDs,
            receiptIDs: fit.blockReasons,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels + [fit.state.rawValue],
            policyHook: policyHook
        )
        let uncertaintyNode = RecommendationTraceReasonGraphNode(
            id: "trace.\(id).uncertainty",
            kind: .uncertainty,
            label: uncertainty.summaries.isEmpty ? "No stated uncertainty" : uncertainty.summaries.joined(separator: " "),
            sourceIDs: source.citedSourceIDs,
            receiptIDs: [],
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels,
            policyHook: policyHook
        )
        let controlNode = RecommendationTraceReasonGraphNode(
            id: "trace.\(id).control",
            kind: .control,
            label: control.hasRequiredControl ? "Control available" : "Control needed",
            sourceIDs: source.citedSourceIDs,
            receiptIDs: control.correctionActionIDs + control.controlActionIDs + control.correctableFieldKeys,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels,
            policyHook: policyHook
        )
        let receiptNode = RecommendationTraceReasonGraphNode(
            id: "trace.\(id).receipt",
            kind: .receipt,
            label: receiptBehavior.state.rawValue,
            sourceIDs: source.citedSourceIDs,
            receiptIDs: receiptBehavior.receiptIDs + receiptBehavior.actionReceiptIDs + receiptBehavior.proofReferenceIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels,
            policyHook: policyHook
        )
        let runtimeSnapshotNode = RecommendationTraceReasonGraphNode(
            id: "trace.\(id).runtime_snapshot",
            kind: .runtimeSnapshot,
            label: runtimeSnapshotReferenceIDs.isEmpty ? "Runtime snapshot unavailable" : "Runtime snapshot references are local and inspectable",
            sourceIDs: source.citedSourceIDs,
            receiptIDs: receiptBehavior.receiptIDs + receiptBehavior.actionReceiptIDs + receiptBehavior.proofReferenceIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels,
            policyHook: policyHook
        )
        let localFitNode = RecommendationTraceReasonGraphNode(
            id: "trace.\(id).local_fit",
            kind: .localFit,
            label: localFitLabels.isEmpty ? fit.state.rawValue : localFitLabels.joined(separator: ", "),
            sourceIDs: source.citedSourceIDs,
            receiptIDs: [],
            replayTraceIDs: [],
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels,
            policyHook: policyHook
        )

        let sourceIDs = source.citedSourceIDs
        let receiptIDs = receiptBehavior.receiptIDs + receiptBehavior.actionReceiptIDs + receiptBehavior.proofReferenceIDs
        let edges = [
            RecommendationTraceReasonGraphEdge(
                id: "trace.\(id).edge.source.reason",
                fromNodeID: sourceNode.id,
                toNodeID: reasonNode.id,
                label: "Source supports reason",
                sourceIDs: sourceIDs,
                receiptIDs: receiptIDs,
                runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                localFitLabels: localFitLabels,
                policyHook: policyHook
            ),
            RecommendationTraceReasonGraphEdge(
                id: "trace.\(id).edge.reason.fit",
                fromNodeID: reasonNode.id,
                toNodeID: fitNode.id,
                label: "Reason constrains local fit",
                sourceIDs: sourceIDs,
                receiptIDs: fit.blockReasons,
                runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                localFitLabels: localFitLabels + [fit.state.rawValue],
                policyHook: policyHook
            ),
            RecommendationTraceReasonGraphEdge(
                id: "trace.\(id).edge.reason.uncertainty",
                fromNodeID: reasonNode.id,
                toNodeID: uncertaintyNode.id,
                label: "Reason keeps uncertainty visible",
                sourceIDs: sourceIDs,
                runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                localFitLabels: localFitLabels,
                policyHook: policyHook
            ),
            RecommendationTraceReasonGraphEdge(
                id: "trace.\(id).edge.fit.control",
                fromNodeID: fitNode.id,
                toNodeID: controlNode.id,
                label: "Fit requires control",
                sourceIDs: sourceIDs,
                receiptIDs: control.correctionActionIDs + control.controlActionIDs + control.correctableFieldKeys,
                runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                localFitLabels: localFitLabels,
                policyHook: policyHook
            ),
            RecommendationTraceReasonGraphEdge(
                id: "trace.\(id).edge.control.receipt",
                fromNodeID: controlNode.id,
                toNodeID: receiptNode.id,
                label: "Control stays receipt-aware",
                sourceIDs: sourceIDs,
                receiptIDs: receiptIDs,
                runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                localFitLabels: localFitLabels,
                policyHook: policyHook
            ),
            RecommendationTraceReasonGraphEdge(
                id: "trace.\(id).edge.reason.runtime_snapshot",
                fromNodeID: reasonNode.id,
                toNodeID: runtimeSnapshotNode.id,
                label: "Reason remains runtime snapshot backed",
                sourceIDs: sourceIDs,
                receiptIDs: receiptIDs,
                runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                localFitLabels: localFitLabels,
                policyHook: policyHook
            ),
            RecommendationTraceReasonGraphEdge(
                id: "trace.\(id).edge.reason.local_fit",
                fromNodeID: reasonNode.id,
                toNodeID: localFitNode.id,
                label: "Reason stays locally fit",
                sourceIDs: sourceIDs,
                receiptIDs: receiptIDs,
                runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                localFitLabels: localFitLabels,
                policyHook: policyHook
            )
        ].sorted { $0.id < $1.id }

        let counterfactualDiffs = [
            RecommendationTraceCounterfactualDiff(
                id: "trace.\(id).diff.reason.fit",
                selectedNodeID: reasonNode.id,
                alternativeNodeID: fitNode.id,
                selectedLabel: reasonNode.label,
                alternativeLabel: fitNode.label,
                deltaLabel: "selected_reason_overrides_fit_state",
                sourceIDs: sourceIDs,
                receiptIDs: receiptIDs,
                replayTraceIDs: replayTraceIDs,
                runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                localFitLabels: localFitLabels + [fit.state.rawValue],
                policyHook: policyHook
            ),
            RecommendationTraceCounterfactualDiff(
                id: "trace.\(id).diff.reason.receipt",
                selectedNodeID: reasonNode.id,
                alternativeNodeID: receiptNode.id,
                selectedLabel: reasonNode.label,
                alternativeLabel: receiptNode.label,
                deltaLabel: "selected_reason_overrides_receipt_state",
                sourceIDs: sourceIDs,
                receiptIDs: receiptIDs,
                replayTraceIDs: replayTraceIDs,
                runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                localFitLabels: localFitLabels,
                policyHook: policyHook
            )
        ]

        return RecommendationTraceReasonGraph(
            id: "trace.\(id).reason_graph",
            recommendationID: recommendationID,
            selectedNodeID: reasonNode.id,
            sourceIDs: sourceIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels,
            nodes: [controlNode, fitNode, localFitNode, reasonNode, receiptNode, runtimeSnapshotNode, sourceNode, uncertaintyNode],
            edges: edges,
            counterfactualDiffs: counterfactualDiffs,
            policyHook: policyHook
        )
    }


    var rejectionLearningCandidateSignalKeys: [String] {
        Self.orderedUnique(
            source.localEvidenceCategories.map(\.rawValue) +
                source.sourceAtlasBlockReasons +
                reason.evidenceCategoryIDs +
                fit.blockReasons +
                control.correctableFieldKeys
        )
    }


    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
