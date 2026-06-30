import Foundation

let semanticLocalIndexSchemaVersion = "search_recall_semantic_local_index.native.v1"

struct SemanticLocalMatch: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let result: FindActInspectResult
    let score: Int
    let overlappingTerms: [String]
    let externalModelUsed: Bool
    let localOnly: Bool
    let schemaVersion: String

    init(
        result: FindActInspectResult,
        score: Int,
        overlappingTerms: [String],
        externalModelUsed: Bool = false,
        localOnly: Bool = true,
        schemaVersion: String = semanticLocalIndexSchemaVersion
    ) {
        id = "\(result.id).semantic-local"
        self.result = result
        self.score = max(0, score)
        self.overlappingTerms = Array(Set(overlappingTerms.filter { $0.isEmpty == false })).sorted()
        self.externalModelUsed = externalModelUsed
        self.localOnly = localOnly
        self.schemaVersion = schemaVersion
    }
}

struct SemanticLocalIndex: Sendable, Equatable {
    let results: [FindActInspectResult]

    init(results: [FindActInspectResult]) {
        self.results = results
    }

    func search(_ query: SearchRecallQuery) -> [SemanticLocalMatch] {
        let queryTerms = Set(ResultRanker.tokens(query.normalizedText).map(Self.stem))
        guard queryTerms.isEmpty == false else {
            return []
        }

        return results.compactMap { result in
            guard query.allowedPrivacy.contains(result.privacy),
                  query.allowedFamilies?.contains(result.family) ?? true,
                  query.requiresLocalOnly == false || result.localOnly
            else { return nil }

            let resultTerms = Set(Self.tokens(for: result).map(Self.stem))
            let overlap = queryTerms.intersection(resultTerms).sorted()
            guard overlap.isEmpty == false else { return nil }

            let coverage = Int((Double(overlap.count) / Double(max(queryTerms.count, 1))) * 40.0)
            let score = result.baseScore + coverage + min(20, overlap.count * 4)
            return SemanticLocalMatch(
                result: result.ranked(
                    score: score,
                    signals: ["semantic-local-overlap-\(overlap.count)"],
                    matchedTerms: overlap
                ),
                score: score,
                overlappingTerms: overlap
            )
        }
        .sorted { lhs, rhs in
            if lhs.score != rhs.score { return lhs.score > rhs.score }
            return lhs.result.title < rhs.result.title
        }
    }

    private static func tokens(for result: FindActInspectResult) -> [String] {
        ResultRanker.tokens(
            LocalSearchIndex.normalized([
                result.title,
                result.body,
                result.provenance.sourceSummary,
                result.family.rawValue,
                result.provenance.objectIDs.joined(separator: " ")
            ])
        )
    }

    private static func stem(_ value: String) -> String {
        if value.count > 6, value.hasSuffix("ing") {
            return String(value.dropLast(3))
        }
        if value.count > 5, value.hasSuffix("ed") {
            return String(value.dropLast(2))
        }
        if value.count > 4, value.hasSuffix("s") {
            return String(value.dropLast())
        }
        return value
    }
}
