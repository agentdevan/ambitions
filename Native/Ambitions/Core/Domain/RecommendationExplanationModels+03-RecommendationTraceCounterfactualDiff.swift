import Foundation

struct RecommendationTraceCounterfactualDiff: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let selectedNodeID: String
    let alternativeNodeID: String
    let selectedLabel: String
    let alternativeLabel: String
    let deltaLabel: String
    let sourceIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let runtimeSnapshotReferenceIDs: [String]
    let localFitLabels: [String]
    let policyHook: RecommendationTracePolicyHook

    init(
        id: String,
        selectedNodeID: String,
        alternativeNodeID: String,
        selectedLabel: String,
        alternativeLabel: String,
        deltaLabel: String,
        sourceIDs: [String] = [],
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = [],
        runtimeSnapshotReferenceIDs: [String] = [],
        localFitLabels: [String] = [],
        policyHook: RecommendationTracePolicyHook = .localOnly()
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedNodeID = selectedNodeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.alternativeNodeID = alternativeNodeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedLabel = selectedLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.alternativeLabel = alternativeLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.deltaLabel = deltaLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceIDs = Self.orderedUnique(sourceIDs)
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.replayTraceIDs = Self.orderedUnique(replayTraceIDs)
        self.runtimeSnapshotReferenceIDs = Self.orderedUnique(runtimeSnapshotReferenceIDs)
        self.localFitLabels = Self.orderedUnique(localFitLabels)
        self.policyHook = policyHook
    }

    var isExportSafe: Bool {
        policyHook.isExportSafe
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct RecommendationTraceReasonGraph: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let recommendationID: String
    let selectedNodeID: String
    let sourceIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let runtimeSnapshotReferenceIDs: [String]
    let localFitLabels: [String]
    let nodes: [RecommendationTraceReasonGraphNode]
    let edges: [RecommendationTraceReasonGraphEdge]
    let counterfactualDiffs: [RecommendationTraceCounterfactualDiff]
    let policyHook: RecommendationTracePolicyHook
    let schemaVersion: String

    init(
        id: String,
        recommendationID: String,
        selectedNodeID: String,
        sourceIDs: [String] = [],
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = [],
        runtimeSnapshotReferenceIDs: [String] = [],
        localFitLabels: [String] = [],
        nodes: [RecommendationTraceReasonGraphNode],
        edges: [RecommendationTraceReasonGraphEdge],
        counterfactualDiffs: [RecommendationTraceCounterfactualDiff] = [],
        policyHook: RecommendationTracePolicyHook = .localOnly(),
        schemaVersion: String = recommendationTraceReasonGraphSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.recommendationID = recommendationID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedNodeID = selectedNodeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceIDs = Self.orderedUnique(sourceIDs)
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.replayTraceIDs = Self.orderedUnique(replayTraceIDs)
        self.runtimeSnapshotReferenceIDs = Self.orderedUnique(runtimeSnapshotReferenceIDs)
        self.localFitLabels = Self.orderedUnique(localFitLabels)
        self.nodes = nodes.sorted { $0.id < $1.id }
        self.edges = edges.sorted { $0.id < $1.id }
        self.counterfactualDiffs = counterfactualDiffs.sorted { $0.id < $1.id }
        self.policyHook = policyHook
        self.schemaVersion = schemaVersion
    }

    var isExportSafe: Bool {
        policyHook.isExportSafe &&
            nodes.allSatisfy(\.isExportSafe) &&
            edges.allSatisfy(\.isExportSafe) &&
            counterfactualDiffs.allSatisfy(\.isExportSafe)
    }

    var visibleCopy: [String] {
        [
            id,
            recommendationID,
            policyHook.summary
        ] + nodes.flatMap { [$0.kind.rawValue, $0.label] } + edges.flatMap { [$0.label] } + counterfactualDiffs.flatMap { [$0.selectedLabel, $0.alternativeLabel, $0.deltaLabel] }
    }

    var hasVisibleCopyGuardrailViolation: Bool {
        let blockedPhrases = [
            "ai ",
            "assistant",
            "confidence",
            "best " + "next " + "move",
            "next " + "best " + "move",
            "dash" + "board"
        ]
        return visibleCopy.contains { text in
            let lowercased = text.lowercased()
            return blockedPhrases.contains { lowercased.contains($0) } ||
                text.contains("%")
        }
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
