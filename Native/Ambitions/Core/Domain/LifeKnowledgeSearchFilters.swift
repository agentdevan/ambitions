import Foundation

extension LifeKnowledgeOperationModels {

    struct SearchFilters: Codable, Sendable, Equatable, Hashable {
        let itemKinds: [SearchItemKind]
        let lifeAreaIDs: [String]
        let goalThreadIDs: [String]
        let sourceRecordIDs: [String]
        let proofOnly: Bool
        let sensitivity: SearchSensitivity?
        let reviewState: SearchReviewState?
        let dateFilter: SearchDateFilter?

        init(
            itemKinds: [SearchItemKind] = [],
            lifeAreaIDs: [String] = [],
            goalThreadIDs: [String] = [],
            sourceRecordIDs: [String] = [],
            proofOnly: Bool = false,
            sensitivity: SearchSensitivity? = nil,
            reviewState: SearchReviewState? = nil,
            dateFilter: SearchDateFilter? = nil
        ) {
            self.itemKinds = itemKinds.sorted { $0.rawValue < $1.rawValue }
            self.lifeAreaIDs = LifeKnowledgeOperationModels.normalizedIDs(lifeAreaIDs)
            self.goalThreadIDs = LifeKnowledgeOperationModels.normalizedIDs(goalThreadIDs)
            self.sourceRecordIDs = LifeKnowledgeOperationModels.normalizedIDs(sourceRecordIDs)
            self.proofOnly = proofOnly
            self.sensitivity = sensitivity
            self.reviewState = reviewState
            self.dateFilter = dateFilter
        }

        var isEmpty: Bool {
            itemKinds.isEmpty &&
                lifeAreaIDs.isEmpty &&
                goalThreadIDs.isEmpty &&
                sourceRecordIDs.isEmpty &&
                proofOnly == false &&
                sensitivity == nil &&
                reviewState == nil &&
                dateFilter?.isEmpty != false
        }
    }


    struct SearchQuery: Codable, Sendable, Equatable, Hashable {
        let searchText: String?
        let filters: SearchFilters
        let performanceBudget: SearchPerformanceBudget

        init(
            searchText: String? = nil,
            filters: SearchFilters = .init(),
            performanceBudget: SearchPerformanceBudget = .init()
        ) {
            self.searchText = LifeKnowledgeOperationModels.normalizedOptional(searchText)
            self.filters = filters
            self.performanceBudget = performanceBudget
        }
    }


    struct SearchResultItem: Codable, Sendable, Equatable, Identifiable, Hashable {
        let id: String
        let kind: SearchItemKind
        let title: String
        let summary: String
        let sourceRecordIDs: [String]
        let lifeAreaIDs: [String]
        let goalThreadIDs: [String]
        let proofIDs: [String]
        let sensitivity: SearchSensitivity
        let reviewState: SearchReviewState
        let createdAt: String
        let updatedAt: String
        let rankingValue: Int
        let matchedTerms: [String]

        var hasProof: Bool {
            proofIDs.isEmpty == false
        }
    }


    struct SearchResult: Codable, Sendable, Equatable {
        let query: SearchQuery
        let items: [SearchResultItem]
        let scannedCandidateCount: Int
        let matchedCandidateCount: Int
        let returnedItemCount: Int
        let hitPerformanceBudget: Bool
        let performanceBudgetSummary: String
    }
}
