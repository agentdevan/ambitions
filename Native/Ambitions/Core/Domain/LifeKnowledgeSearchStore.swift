import Foundation

extension LifeKnowledgeOperationModels.Store {
    func search(query: LifeKnowledgeOperationModels.SearchQuery = .init()) -> LifeKnowledgeOperationModels.SearchResult {
        let documents = searchDocuments()
        let orderedDocuments = documents.sorted { lhs, rhs in
            if lhs.updatedAt != rhs.updatedAt {
                return lhs.updatedAt > rhs.updatedAt
            }
            if lhs.kind.rawValue != rhs.kind.rawValue {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            if lhs.title != rhs.title {
                return lhs.title < rhs.title
            }
            return lhs.id < rhs.id
        }

        let candidateDocuments = Array(orderedDocuments.prefix(query.performanceBudget.maximumCandidates))
        let matchingDocuments = candidateDocuments.filter { $0.matches(query: query) }
        let rankedResults = matchingDocuments
            .map { $0.resultItem(query: query) }
            .sorted { lhs, rhs in
                if lhs.rankingValue != rhs.rankingValue {
                    return lhs.rankingValue > rhs.rankingValue
                }
                if lhs.updatedAt != rhs.updatedAt {
                    return lhs.updatedAt > rhs.updatedAt
                }
                if lhs.title != rhs.title {
                    return lhs.title < rhs.title
                }
                return lhs.id < rhs.id
            }

        let limitedResults = Array(rankedResults.prefix(query.performanceBudget.maximumResults))
        let budgetReached = documents.count > query.performanceBudget.maximumCandidates ||
            matchingDocuments.count > query.performanceBudget.maximumResults
        let budgetSummary = "Scanned \(candidateDocuments.count) of \(documents.count) candidate items; matched \(matchingDocuments.count); returned \(limitedResults.count) within a \(query.performanceBudget.maximumCandidates)-candidate / \(query.performanceBudget.maximumResults)-result budget."

        return LifeKnowledgeOperationModels.SearchResult(
            query: query,
            items: limitedResults,
            scannedCandidateCount: candidateDocuments.count,
            matchedCandidateCount: matchingDocuments.count,
            returnedItemCount: limitedResults.count,
            hitPerformanceBudget: budgetReached,
            performanceBudgetSummary: budgetSummary
        )
    }

    func searchDocuments() -> [LifeKnowledgeSearchDocument] {
        var documents: [LifeKnowledgeSearchDocument] = []

        documents.append(contentsOf: contextEntries.filter { $0.isDeleted == false }.map { contextEntry in
            searchDocument(
                id: contextEntry.id,
                kind: .contextEntry,
                title: contextEntry.title,
                summary: contextEntry.summary,
                body: contextEntry.body,
                sourceRecords: contextEntry.sourceRecords,
                receipt: contextEntry.receipt,
                replayTrace: contextEntry.replayTrace,
                proofIDs: contextEntry.reflection.map { $0.proofID }.compactMap { $0 },
                linkedContextEntryIDs: [contextEntry.id],
                createdAt: contextEntry.createdAt,
                updatedAt: contextEntry.updatedAt,
                extraSearchTerms: [
                    contextEntry.templateID ?? "",
                    contextEntry.collectionIDs.joined(separator: " "),
                    contextEntry.resourceIDs.joined(separator: " "),
                    contextEntry.relationEdgeIDs.joined(separator: " ")
                ]
            )
        })

        documents.append(contentsOf: collections.filter { $0.isDeleted == false }.map { collection in
            searchDocument(
                id: collection.id,
                kind: .collection,
                title: collection.title,
                summary: collection.summary,
                sourceRecords: collection.sourceRecords,
                receipt: collection.receipt,
                replayTrace: collection.replayTrace,
                linkedContextEntryIDs: collection.entryIDs,
                createdAt: collection.createdAt,
                updatedAt: collection.updatedAt,
                extraSearchTerms: [
                    collection.templateID ?? "",
                    collection.entryIDs.joined(separator: " ")
                ]
            )
        })

        documents.append(contentsOf: templates.filter { $0.isDeleted == false }.map { template in
            searchDocument(
                id: template.id,
                kind: .template,
                title: template.title,
                summary: template.summary,
                sourceRecords: template.sourceRecords,
                receipt: template.receipt,
                replayTrace: template.replayTrace,
                linkedContextEntryIDs: contextEntries.filter { $0.templateID == template.id && $0.isDeleted == false }.map(\.id),
                createdAt: template.createdAt,
                updatedAt: template.updatedAt,
                extraSearchTerms: template.fieldKeys
            )
        })

        documents.append(contentsOf: decisions.filter { $0.isDeleted == false }.map { decision in
            searchDocument(
                id: decision.id,
                kind: .decision,
                title: decision.title,
                summary: decision.summary,
                sourceRecords: decision.sourceRecords,
                receipt: decision.receipt,
                replayTrace: decision.replayTrace,
                linkedContextEntryIDs: [decision.contextEntryID],
                createdAt: decision.createdAt,
                updatedAt: decision.updatedAt,
                extraSearchTerms: [decision.contextEntryID]
            )
        })

        documents.append(contentsOf: resources.filter { $0.isDeleted == false }.map { resource in
            searchDocument(
                id: resource.id,
                kind: .resource,
                title: resource.reference.title,
                summary: resource.reference.summary ?? resource.reference.locator ?? "",
                sourceRecords: resource.sourceRecord.map { [$0] } ?? [],
                receipt: resource.receipt,
                replayTrace: resource.replayTrace,
                linkedContextEntryIDs: contextEntries.filter { $0.isDeleted == false && $0.resourceIDs.contains(resource.id) }.map(\.id),
                createdAt: resource.createdAt,
                updatedAt: resource.updatedAt,
                extraSearchTerms: [
                    resource.reference.kind.rawValue,
                    resource.reference.locator ?? ""
                ]
            )
        })

        documents.append(contentsOf: personPlaceContexts.filter { $0.isDeleted == false }.map { personPlace in
            searchDocument(
                id: personPlace.id,
                kind: personPlace.kind == .person ? .personContext : .placeContext,
                title: personPlace.label,
                summary: personPlace.summary,
                sourceRecords: personPlace.sourceRecord.map { [$0] } ?? [],
                linkedContextEntryIDs: contextEntries.filter {
                    $0.isDeleted == false && $0.resourceIDs.contains(where: personPlace.resourceIDs.contains)
                }.map(\.id),
                sensitivityOverride: personPlace.sourceRecord == nil ? .reviewRequired : nil,
                reviewStateOverride: personPlace.sourceRecord == nil ? .needsReview : nil,
                createdAt: personPlace.createdAt,
                updatedAt: personPlace.updatedAt,
                extraSearchTerms: personPlace.resourceIDs
            )
        })

        documents.append(contentsOf: reflections.filter { $0.isDeleted == false }.map { reflection in
            searchDocument(
                id: reflection.id,
                kind: .reflection,
                title: reflection.text,
                summary: reflection.learnedSignal,
                proofIDs: reflection.proofID.map { [$0] } ?? [],
                linkedContextEntryIDs: contextEntries.filter { $0.isDeleted == false && $0.reflection?.id == reflection.id }.map(\.id),
                createdAt: reflection.createdAt,
                updatedAt: reflection.createdAt,
                extraSearchTerms: [reflection.ambitionID, reflection.closureEventID ?? ""]
            )
        })

        documents.append(contentsOf: relationEdges.filter { $0.isDeleted == false }.map { edge in
            searchDocument(
                id: edge.id,
                kind: .relationEdge,
                title: edge.target.label,
                summary: edge.relationSummary,
                sourceRecords: edge.sourceRecords,
                receipt: edge.receipt,
                replayTrace: edge.replayTrace,
                proofIDs: edge.target.kind == .proof ? [edge.target.id] : [],
                linkedContextEntryIDs: [],
                lifeAreaIDs: edge.target.kind == .lifeArea ? [edge.target.id] : [],
                goalThreadIDs: edge.target.kind == .goalThread ? [edge.target.id] : [],
                reviewStateOverride: searchReviewState(for: edge.reviewState),
                createdAt: edge.createdAt,
                updatedAt: edge.updatedAt,
                extraSearchTerms: [
                    edge.relationshipKind.rawValue,
                    edge.target.kind.displayName
                ]
            )
        })

        return documents
    }

    func searchDocument(
        id: String,
        kind: LifeKnowledgeOperationModels.SearchItemKind,
        title: String,
        summary: String,
        body: String? = nil,
        sourceRecords: [SourceRecord] = [],
        receipt: Receipt? = nil,
        replayTrace: ReplayTrace? = nil,
        proofIDs: [String] = [],
        linkedContextEntryIDs: [String] = [],
        lifeAreaIDs: [String] = [],
        goalThreadIDs: [String] = [],
        sensitivityOverride: LifeKnowledgeOperationModels.SearchSensitivity? = nil,
        reviewStateOverride: LifeKnowledgeOperationModels.SearchReviewState? = nil,
        createdAt: String,
        updatedAt: String,
        extraSearchTerms: [String] = []
    ) -> LifeKnowledgeSearchDocument {
        let linkedContextEntries = linkedContextEntryIDs.compactMap { contextEntryID in
            contextEntries.first(where: { $0.id == contextEntryID && $0.isDeleted == false })
        }
        let linkedRelationEdges = linkedContextEntryIDs.flatMap { relationEdges(from: $0) }
        let allSourceRecords = LifeKnowledgeOperationModels.normalizedSourceRecords(
            sourceRecords + linkedContextEntries.flatMap(\.sourceRecords)
        )
        let allProofIDs = LifeKnowledgeOperationModels.normalizedIDs(
            proofIDs +
                (receipt?.proofReferenceIDs ?? []) +
                (replayTrace?.decisionReceipt?.proofReferenceIDs ?? []) +
                linkedContextEntries.compactMap { $0.reflection?.proofID }
        )
        let resolvedLifeAreaIDs = LifeKnowledgeOperationModels.normalizedIDs(
            lifeAreaIDs +
                linkedRelationEdges.filter { $0.target.kind == .lifeArea }.map { $0.target.id }
        )
        let resolvedGoalThreadIDs = LifeKnowledgeOperationModels.normalizedIDs(
            goalThreadIDs +
                linkedRelationEdges.filter { $0.target.kind == .goalThread }.map { $0.target.id }
        )
        let hasDirectEvidence = sourceRecords.isEmpty == false || receipt != nil || replayTrace != nil || proofIDs.isEmpty == false
        let reviewEdges = hasDirectEvidence ? [] : linkedRelationEdges
        let reviewState = reviewStateOverride ?? derivedSearchReviewState(
            sourceRecords: allSourceRecords,
            relationEdges: reviewEdges,
            proofIDs: allProofIDs
        )
        let sensitivity = sensitivityOverride ?? derivedSearchSensitivity(
            sourceRecords: allSourceRecords,
            relationEdges: reviewEdges,
            proofIDs: allProofIDs,
            reviewState: reviewState
        )
        let searchableText = LifeKnowledgeOperationModels.normalizedKey(
            [
                title,
                summary,
                body ?? "",
                allSourceRecords.map(\.entityTitle).joined(separator: " "),
                allSourceRecords.compactMap(\.publisher).joined(separator: " "),
                allSourceRecords.compactMap(\.locator).joined(separator: " "),
                linkedContextEntries.map(\.title).joined(separator: " "),
                linkedContextEntries.map(\.summary).joined(separator: " "),
                extraSearchTerms.joined(separator: " ")
            ]
            .joined(separator: " ")
        )

        return LifeKnowledgeSearchDocument(
            id: id,
            kind: kind,
            title: title,
            summary: summary,
            sourceRecordIDs: allSourceRecords.map(\.id),
            lifeAreaIDs: resolvedLifeAreaIDs,
            goalThreadIDs: resolvedGoalThreadIDs,
            proofIDs: allProofIDs,
            sensitivity: sensitivity,
            reviewState: reviewState,
            createdAt: createdAt,
            updatedAt: updatedAt,
            searchText: searchableText
        )
    }

    func derivedSearchReviewState(
        sourceRecords: [SourceRecord],
        relationEdges: [LifeKnowledgeOperationModels.RelationEdge],
        proofIDs: [String]
    ) -> LifeKnowledgeOperationModels.SearchReviewState {
        if relationEdges.contains(where: { $0.reviewState == .needsReview }) {
            return .needsReview
        }
        if relationEdges.contains(where: { $0.reviewState == .weak }) {
            return .weak
        }
        if sourceRecords.isEmpty && proofIDs.isEmpty {
            return .needsReview
        }
        if sourceRecords.contains(where: { $0.provenanceKind == .userProvided || $0.provenanceKind == .inferred }) {
            return .weak
        }
        return .ready
    }

    func derivedSearchSensitivity(
        sourceRecords: [SourceRecord],
        relationEdges: [LifeKnowledgeOperationModels.RelationEdge],
        proofIDs: [String],
        reviewState: LifeKnowledgeOperationModels.SearchReviewState
    ) -> LifeKnowledgeOperationModels.SearchSensitivity {
        if reviewState == .needsReview {
            return .reviewRequired
        }
        if sourceRecords.contains(where: { $0.provenanceKind == .userProvided || $0.provenanceKind == .inferred }) {
            return .sensitive
        }
        if relationEdges.contains(where: { $0.reviewState != .ready }) || proofIDs.isEmpty {
            return .reviewRequired
        }
        return .open
    }

    func searchReviewState(for reviewState: LifeKnowledgeOperationModels.RelationEdgeReviewState) -> LifeKnowledgeOperationModels.SearchReviewState {
        switch reviewState {
        case .ready:
            return .ready
        case .weak:
            return .weak
        case .needsReview:
            return .needsReview
        }
    }
}
