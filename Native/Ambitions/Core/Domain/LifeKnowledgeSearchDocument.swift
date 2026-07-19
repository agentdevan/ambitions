import Foundation

extension LifeKnowledgeOperationModels {
    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    static func normalizedKey(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9]+"#, with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    static func normalizedIDs(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }

    static func normalizedSourceRecords(_ values: [SourceRecord]) -> [SourceRecord] {
        Array(values).sorted { lhs, rhs in
            if lhs.id != rhs.id {
                return lhs.id < rhs.id
            }
            if lhs.entityTitle != rhs.entityTitle {
                return lhs.entityTitle < rhs.entityTitle
            }
            return lhs.providerID < rhs.providerID
        }
    }

    static func normalizedRelationEdges(_ values: [RelationEdge]) -> [RelationEdge] {
        Array(values)
            .filter { $0.isDeleted == false }
            .sorted { lhs, rhs in
                if lhs.sourceContextEntryID != rhs.sourceContextEntryID {
                    return lhs.sourceContextEntryID < rhs.sourceContextEntryID
                }
                if lhs.target.stableKey != rhs.target.stableKey {
                    return lhs.target.stableKey < rhs.target.stableKey
                }
                if lhs.relationshipKind.rawValue != rhs.relationshipKind.rawValue {
                    return lhs.relationshipKind.rawValue < rhs.relationshipKind.rawValue
                }
                if lhs.reviewState.rawValue != rhs.reviewState.rawValue {
                    return lhs.reviewState.rawValue < rhs.reviewState.rawValue
                }
                return lhs.id < rhs.id
            }
    }

    static func normalized<T: Identifiable & Equatable>(_ values: [T]) -> [T] where T.ID == String {
        Array(values).sorted { lhs, rhs in
            if lhs.id != rhs.id {
                return lhs.id < rhs.id
            }
            return String(describing: lhs) < String(describing: rhs)
        }
    }
}

struct LifeKnowledgeSearchDocument {
    let id: String
    let kind: LifeKnowledgeOperationModels.SearchItemKind
    let title: String
    let summary: String
    let sourceRecordIDs: [String]
    let lifeAreaIDs: [String]
    let goalThreadIDs: [String]
    let proofIDs: [String]
    let sensitivity: LifeKnowledgeOperationModels.SearchSensitivity
    let reviewState: LifeKnowledgeOperationModels.SearchReviewState
    let createdAt: String
    let updatedAt: String
    let searchText: String

    func matches(query: LifeKnowledgeOperationModels.SearchQuery) -> Bool {
        if query.filters.itemKinds.isEmpty == false && query.filters.itemKinds.contains(kind) == false {
            return false
        }
        if query.filters.lifeAreaIDs.isEmpty == false && lifeAreaIDs.contains(where: query.filters.lifeAreaIDs.contains) == false {
            return false
        }
        if query.filters.goalThreadIDs.isEmpty == false && goalThreadIDs.contains(where: query.filters.goalThreadIDs.contains) == false {
            return false
        }
        if query.filters.sourceRecordIDs.isEmpty == false && sourceRecordIDs.contains(where: query.filters.sourceRecordIDs.contains) == false {
            return false
        }
        if query.filters.proofOnly && proofIDs.isEmpty {
            return false
        }
        if let sensitivity = query.filters.sensitivity, sensitivity != self.sensitivity {
            return false
        }
        if let reviewState = query.filters.reviewState, reviewState != self.reviewState {
            return false
        }
        if let dateFilter = query.filters.dateFilter, Self.matches(dateFilter: dateFilter, createdAt: createdAt, updatedAt: updatedAt) == false {
            return false
        }

        let searchTokens = Self.searchTokens(from: query.searchText, maximumTokens: query.performanceBudget.maximumTextTokens)
        guard searchTokens.isEmpty == false else {
            return true
        }

        return searchTokens.contains(where: { searchText.contains($0) })
    }

    func resultItem(query: LifeKnowledgeOperationModels.SearchQuery) -> LifeKnowledgeOperationModels.SearchResultItem {
        let searchTokens = Self.searchTokens(from: query.searchText, maximumTokens: query.performanceBudget.maximumTextTokens)
        let matchedTerms = searchTokens.filter { searchText.contains($0) }
        var rankingValue = 10

        if searchTokens.isEmpty {
            rankingValue += 1
        } else {
            rankingValue += matchedTerms.count * 14
            if matchedTerms.contains(where: { title.contains($0) }) {
                rankingValue += 20
            }
            if matchedTerms.contains(where: { summary.contains($0) }) {
                rankingValue += 10
            }
        }

        rankingValue += proofIDs.count * 4
        rankingValue += lifeAreaIDs.count * 3
        rankingValue += goalThreadIDs.count * 3

        switch sensitivity {
        case .open:
            rankingValue += 4
        case .sensitive:
            rankingValue += 2
        case .reviewRequired:
            break
        }

        switch reviewState {
        case .ready:
            rankingValue += 4
        case .weak:
            rankingValue += 1
        case .needsReview:
            break
        }

        return LifeKnowledgeOperationModels.SearchResultItem(
            id: id,
            kind: kind,
            title: title,
            summary: summary,
            sourceRecordIDs: sourceRecordIDs,
            lifeAreaIDs: lifeAreaIDs,
            goalThreadIDs: goalThreadIDs,
            proofIDs: proofIDs,
            sensitivity: sensitivity,
            reviewState: reviewState,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rankingValue: rankingValue,
            matchedTerms: matchedTerms
        )
    }

    static func searchTokens(from text: String?, maximumTokens: Int) -> [String] {
        guard let text else { return [] }
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalized.isEmpty == false else { return [] }
        return LifeKnowledgeOperationModels.normalizedKey(normalized)
            .split(separator: "-")
            .map(String.init)
            .filter { $0.isEmpty == false }
            .prefix(maximumTokens)
            .map { $0 }
    }

    static func matches(dateFilter: LifeKnowledgeOperationModels.SearchDateFilter, createdAt: String, updatedAt: String) -> Bool {
        if let createdAfter = dateFilter.createdAfter, createdAt < createdAfter {
            return false
        }
        if let createdBefore = dateFilter.createdBefore, createdAt > createdBefore {
            return false
        }
        if let updatedAfter = dateFilter.updatedAfter, updatedAt < updatedAfter {
            return false
        }
        if let updatedBefore = dateFilter.updatedBefore, updatedAt > updatedBefore {
            return false
        }
        return true
    }
}
