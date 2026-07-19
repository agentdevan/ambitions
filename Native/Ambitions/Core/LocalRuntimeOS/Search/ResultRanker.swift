import Foundation

let resultRankerSchemaVersion = "search_result_ranker.native.v1"

struct ResultRanker: Sendable {
    func rank(
        _ results: [FindActInspectResult],
        query: SearchQuery,
        familyPriority: [LocalSearchObjectFamily: Int] = [:]
    ) -> [FindActInspectResult] {
        let queryTerms = Self.tokens(query.normalizedText)
        let ranked = results.map { result in
            let ranked = score(
                result,
                queryTerms: queryTerms,
                origin: query.origin,
                familyPriority: familyPriority
            )
            return result.ranked(
                score: ranked.score,
                signals: ranked.signals + ["ranker-schema-\(resultRankerSchemaVersion)"],
                matchedTerms: ranked.matchedTerms
            )
        }

        return Array(ranked.sorted { lhs, rhs in
            if lhs.rankScore != rhs.rankScore { return lhs.rankScore > rhs.rankScore }
            if lhs.updatedAt != rhs.updatedAt { return lhs.updatedAt > rhs.updatedAt }
            if lhs.family.rawValue != rhs.family.rawValue { return lhs.family.rawValue < rhs.family.rawValue }
            return lhs.title < rhs.title
        }.prefix(query.limit))
    }

    private func score(
        _ result: FindActInspectResult,
        queryTerms: [String],
        origin: AmbitionsSurface?,
        familyPriority: [LocalSearchObjectFamily: Int]
    ) -> (score: Int, signals: [String], matchedTerms: [String]) {
        var score = result.baseScore
        var signals: [String] = ["base-score-\(result.baseScore)"]
        let title = LocalSearchIndex.normalized([result.title])
        let body = LocalSearchIndex.normalized([result.body, result.provenance.sourceSummary])
        var matchedTerms: [String] = []

        if queryTerms.isEmpty {
            score += 5
            signals.append("empty-query-recency-path")
        } else {
            for term in queryTerms {
                if title == term {
                    score += 50
                    signals.append("title-exact")
                    matchedTerms.append(term)
                } else if title.hasPrefix(term) {
                    score += 35
                    signals.append("title-prefix")
                    matchedTerms.append(term)
                } else if title.contains(term) {
                    score += 25
                    signals.append("title-contains")
                    matchedTerms.append(term)
                } else if body.contains(term) {
                    score += 12
                    signals.append("body-contains")
                    matchedTerms.append(term)
                }
            }
        }

        if let origin, surfaceMatches(origin, result: result) {
            score += 18
            signals.append("origin-\(origin.rawValue)")
        }

        if let priority = familyPriority[result.family] {
            score += max(0, 100 - priority)
            signals.append("family-priority-\(priority)")
        }

        if result.privacy == .standard {
            score += 3
            signals.append("standard-privacy")
        }

        return (max(0, score), Array(Set(signals)).sorted(), Array(Set(matchedTerms)).sorted())
    }

    private func surfaceMatches(_ surface: AmbitionsSurface, result: FindActInspectResult) -> Bool {
        switch (surface, result.family) {
        case (.today, .step), (.today, .capture), (.goals, .goal), (.time, .timeWindow), (.you, .setting),
             (.you, .proof), (.you, .receipt):
            return true
        default:
            return false
        }
    }

    static func tokens(_ normalizedText: String) -> [String] {
        normalizedText
            .split(separator: " ")
            .map(String.init)
            .filter { $0.isEmpty == false }
    }
}
