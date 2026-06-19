import Foundation

extension LifeKnowledgeOperationModels {

    struct Store: Codable, Sendable, Equatable, Identifiable {
        let id: String
        let surfaceTitle: String
        let inspectionSummary: String
        let sourceRecords: [SourceRecord]
        let receipt: Receipt?
        let replayTrace: ReplayTrace?
        let contextEntries: [ContextEntry]
        let collections: [Collection]
        let templates: [Template]
        let decisions: [Decision]
        let resources: [Resource]
        let personPlaceContexts: [PersonPlaceContext]
        let reflections: [Reflection]
        let relationEdges: [RelationEdge]
        let createdAt: String
        let updatedAt: String
        let deletedAt: String?

        init(
            id: String,
            surfaceTitle: String = LifeKnowledgeOperationModels.surfaceTitle,
            inspectionSummary: String,
            sourceRecords: [SourceRecord] = [],
            receipt: Receipt? = nil,
            replayTrace: ReplayTrace? = nil,
            contextEntries: [ContextEntry] = [],
            collections: [Collection] = [],
            templates: [Template] = [],
            decisions: [Decision] = [],
            resources: [Resource] = [],
            personPlaceContexts: [PersonPlaceContext] = [],
            reflections: [Reflection] = [],
            relationEdges: [RelationEdge] = [],
            createdAt: String,
            updatedAt: String,
            deletedAt: String? = nil
        ) {
            self.id = LifeKnowledgeOperationModels.normalizedRequired(id)
            self.surfaceTitle = LifeKnowledgeOperationModels.normalizedRequired(surfaceTitle)
            self.inspectionSummary = LifeKnowledgeOperationModels.normalizedRequired(inspectionSummary)
            self.sourceRecords = LifeKnowledgeOperationModels.normalizedSourceRecords(sourceRecords)
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.contextEntries = LifeKnowledgeOperationModels.normalized(contextEntries)
            self.collections = LifeKnowledgeOperationModels.normalized(collections)
            self.templates = LifeKnowledgeOperationModels.normalized(templates)
            self.decisions = LifeKnowledgeOperationModels.normalized(decisions)
            self.resources = LifeKnowledgeOperationModels.normalized(resources)
            self.personPlaceContexts = LifeKnowledgeOperationModels.normalized(personPlaceContexts)
            self.reflections = LifeKnowledgeOperationModels.normalized(reflections)
            self.relationEdges = LifeKnowledgeOperationModels.normalizedRelationEdges(relationEdges)
            self.createdAt = LifeKnowledgeOperationModels.normalizedRequired(createdAt)
            self.updatedAt = LifeKnowledgeOperationModels.normalizedRequired(updatedAt)
            self.deletedAt = LifeKnowledgeOperationModels.normalizedOptional(deletedAt)
        }

        var inspectionLabel: String {
            surfaceTitle
        }

        var isDeleted: Bool {
            deletedAt != nil
        }

        var canDelete: Bool {
            isDeleted == false
        }

        var exportSnapshot: ExportSnapshot {
            ExportSnapshot(
                id: id,
                surfaceTitle: surfaceTitle,
                inspectionSummary: inspectionSummary,
                sourceRecordIDs: sourceRecords.map(\.id),
                receiptID: receipt?.id,
                replayTraceID: replayTrace?.id,
                contextEntryIDs: contextEntries.map(\.id),
                collectionIDs: collections.map(\.id),
                templateIDs: templates.map(\.id),
                decisionIDs: decisions.map(\.id),
                resourceIDs: resources.map(\.id),
                personPlaceContextIDs: personPlaceContexts.map(\.id),
                reflectionIDs: reflections.map(\.id),
                relationEdgeIDs: relationEdges.map(\.id),
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt
            )
        }

        func markedDeleted(at timestamp: String) -> Store {
            Store(
                id: id,
                surfaceTitle: surfaceTitle,
                inspectionSummary: inspectionSummary,
                sourceRecords: sourceRecords,
                receipt: receipt,
                replayTrace: replayTrace,
                contextEntries: contextEntries,
                collections: collections,
                templates: templates,
                decisions: decisions,
                resources: resources,
                personPlaceContexts: personPlaceContexts,
                reflections: reflections,
                relationEdges: relationEdges,
                createdAt: createdAt,
                updatedAt: timestamp,
                deletedAt: timestamp
            )
        }

        func reset(at timestamp: String) -> Store {
            Store(
                id: id,
                surfaceTitle: surfaceTitle,
                inspectionSummary: inspectionSummary,
                sourceRecords: [],
                receipt: nil,
                replayTrace: nil,
                contextEntries: [],
                collections: [],
                templates: [],
                decisions: [],
                resources: [],
                personPlaceContexts: [],
                reflections: [],
                relationEdges: [],
                createdAt: createdAt,
                updatedAt: timestamp,
                deletedAt: nil
            )
        }

        func relationEdges(from sourceContextEntryID: String) -> [RelationEdge] {
            relationEdges.filter { $0.sourceContextEntryID == sourceContextEntryID && $0.isDeleted == false }
        }

        func backlinks(to target: RelationTargetReference) -> RelationBacklink {
            let matches = relationEdges.filter {
                $0.target.stableKey == target.stableKey && $0.isDeleted == false
            }
            return RelationBacklink(
                target: target,
                edgeIDs: matches.map(\.id),
                strongEdgeIDs: matches.filter { $0.reviewState == .ready }.map(\.id),
                weakEdgeIDs: matches.filter(\.isWeak).map(\.id),
                reviewRequiredEdgeIDs: matches.filter(\.requiresReview).map(\.id)
            )
        }
    }


    struct ExportSnapshot: Codable, Sendable, Equatable, Hashable {
        let id: String
        let surfaceTitle: String
        let inspectionSummary: String
        let sourceRecordIDs: [String]
        let receiptID: String?
        let replayTraceID: String?
        let contextEntryIDs: [String]
        let collectionIDs: [String]
        let templateIDs: [String]
        let decisionIDs: [String]
        let resourceIDs: [String]
        let personPlaceContextIDs: [String]
        let reflectionIDs: [String]
        let relationEdgeIDs: [String]
        let isDeleted: Bool
        let createdAt: String
        let updatedAt: String
        let deletedAt: String?
    }


    struct InspectionBoundary: Codable, Sendable, Equatable, Hashable {
        let surfaceTitle: String
        let sourceKnowledgeLabel: String
        let allowsRawActivityLog: Bool

        var inspectionLabel: String {
            surfaceTitle
        }

        var blocksRawActivityLogCopy: Bool {
            allowsRawActivityLog == false
        }

        var isInspectableBoundary: Bool {
            surfaceTitle == LifeKnowledgeOperationModels.surfaceTitle && allowsRawActivityLog == false
        }
    }


    enum SearchItemKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
        case contextEntry
        case collection
        case template
        case reflection
        case decision
        case resource
        case personContext = "person_context"
        case placeContext = "place_context"
        case relationEdge = "relation_edge"

        var displayName: String {
            switch self {
            case .contextEntry:
                return "Context Entry"
            case .collection:
                return "Collection"
            case .template:
                return "Template"
            case .reflection:
                return "Reflection"
            case .decision:
                return "Decision"
            case .resource:
                return "Resource"
            case .personContext:
                return "Person Context"
            case .placeContext:
                return "Place Context"
            case .relationEdge:
                return "Relation Edge"
            }
        }
    }


    enum SearchSensitivity: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
        case open
        case sensitive
        case reviewRequired = "review_required"

        var displayName: String {
            switch self {
            case .open:
                return "Open"
            case .sensitive:
                return "Sensitive"
            case .reviewRequired:
                return "Review Required"
            }
        }
    }


    enum SearchReviewState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
        case ready
        case weak
        case needsReview = "needs_review"

        var displayName: String {
            switch self {
            case .ready:
                return "Ready"
            case .weak:
                return "Weak"
            case .needsReview:
                return "Needs Review"
            }
        }
    }


    struct SearchDateFilter: Codable, Sendable, Equatable, Hashable {
        let createdAfter: String?
        let createdBefore: String?
        let updatedAfter: String?
        let updatedBefore: String?

        init(
            createdAfter: String? = nil,
            createdBefore: String? = nil,
            updatedAfter: String? = nil,
            updatedBefore: String? = nil
        ) {
            self.createdAfter = LifeKnowledgeOperationModels.normalizedOptional(createdAfter)
            self.createdBefore = LifeKnowledgeOperationModels.normalizedOptional(createdBefore)
            self.updatedAfter = LifeKnowledgeOperationModels.normalizedOptional(updatedAfter)
            self.updatedBefore = LifeKnowledgeOperationModels.normalizedOptional(updatedBefore)
        }

        var isEmpty: Bool {
            createdAfter == nil && createdBefore == nil && updatedAfter == nil && updatedBefore == nil
        }
    }


    struct SearchPerformanceBudget: Codable, Sendable, Equatable, Hashable {
        let maximumCandidates: Int
        let maximumResults: Int
        let maximumTextTokens: Int

        init(
            maximumCandidates: Int = 64,
            maximumResults: Int = 24,
            maximumTextTokens: Int = 12
        ) {
            self.maximumCandidates = max(1, maximumCandidates)
            self.maximumResults = max(1, maximumResults)
            self.maximumTextTokens = max(1, maximumTextTokens)
        }
    }
}
