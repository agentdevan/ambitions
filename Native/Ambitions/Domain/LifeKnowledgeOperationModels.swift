import Foundation

enum LifeKnowledgeOperationModels {
    static let schemaVersion = "life_knowledge_operation_models.native.v1"
    static let surfaceTitle = "What Ambitions knows"

    enum EntryKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
        case contextEntry = "context_entry"
        case collection
        case template
        case reflection
        case decision
        case resource
        case personContext = "person_context"
        case placeContext = "place_context"
    }

    enum PersonPlaceContextKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
        case person
        case place
    }

    enum RelationTargetKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
        case lifeArea = "life_area"
        case goalThread = "goal_thread"
        case commitment
        case step
        case proof
        case source

        var displayName: String {
            switch self {
            case .lifeArea:
                return "Life Area"
            case .goalThread:
                return "Goal Thread"
            case .commitment:
                return "Commitment"
            case .step:
                return "Step"
            case .proof:
                return "Proof"
            case .source:
                return "Source"
            }
        }

        var objectKind: LifeGraphObjectKind {
            switch self {
            case .lifeArea:
                return .lifeArea
            case .goalThread:
                return .goal
            case .commitment:
                return .commitment
            case .step:
                return .step
            case .proof:
                return .proof
            case .source:
                return .evidence
            }
        }

        var defaultSourceDomain: LifeGraphSourceDomain {
            switch self {
            case .lifeArea, .goalThread:
                return .goals
            case .commitment:
                return .commitment
            case .step:
                return .goalEngine
            case .proof:
                return .proof
            case .source:
                return .you
            }
        }
    }

    struct RelationTargetReference: Codable, Sendable, Equatable, Hashable, Identifiable {
        let kind: RelationTargetKind
        let id: String
        let label: String
        let sourceDomain: LifeGraphSourceDomain?

        init(
            kind: RelationTargetKind,
            id: String,
            label: String,
            sourceDomain: LifeGraphSourceDomain? = nil
        ) {
            self.kind = kind
            self.id = LifeKnowledgeOperationModels.normalizedRequired(id)
            self.label = LifeKnowledgeOperationModels.normalizedRequired(label)
            self.sourceDomain = sourceDomain
        }

        var stableKey: String {
            [
                kind.rawValue,
                id,
                sourceDomain?.rawValue ?? ""
            ].joined(separator: ":")
        }

        var objectReference: LifeGraphObjectReference {
            LifeGraphObjectReference(
                kind: kind.objectKind,
                id: id,
                label: label,
                sourceDomain: sourceDomain ?? kind.defaultSourceDomain
            )
        }
    }

    enum RelationEdgeReviewState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
        case ready
        case weak
        case needsReview = "needs_review"

        var isWeak: Bool {
            self == .weak
        }

        var requiresReview: Bool {
            self != .ready
        }
    }

    struct RelationEdge: Codable, Sendable, Equatable, Identifiable, Hashable {
        let id: String
        let sourceContextEntryID: String
        let target: RelationTargetReference
        let relationshipKind: LifeGraphRelationshipKind
        let reviewState: RelationEdgeReviewState
        let sourceRecords: [SourceRecord]
        let receipt: Receipt?
        let replayTrace: ReplayTrace?
        let createdAt: String
        let updatedAt: String
        let deletedAt: String?

        init(
            id: String? = nil,
            sourceContextEntryID: String,
            target: RelationTargetReference,
            relationshipKind: LifeGraphRelationshipKind,
            reviewState: RelationEdgeReviewState = .ready,
            sourceRecords: [SourceRecord] = [],
            receipt: Receipt? = nil,
            replayTrace: ReplayTrace? = nil,
            createdAt: String,
            updatedAt: String,
            deletedAt: String? = nil
        ) {
            self.sourceContextEntryID = LifeKnowledgeOperationModels.normalizedRequired(sourceContextEntryID)
            self.target = target
            self.relationshipKind = relationshipKind
            self.reviewState = reviewState
            self.sourceRecords = LifeKnowledgeOperationModels.normalizedSourceRecords(sourceRecords)
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.createdAt = LifeKnowledgeOperationModels.normalizedRequired(createdAt)
            self.updatedAt = LifeKnowledgeOperationModels.normalizedRequired(updatedAt)
            self.deletedAt = LifeKnowledgeOperationModels.normalizedOptional(deletedAt)
            self.id = id ?? Self.deterministicID(
                sourceContextEntryID: self.sourceContextEntryID,
                target: target,
                relationshipKind: relationshipKind,
                reviewState: reviewState
            )
        }

        var isDeleted: Bool {
            deletedAt != nil
        }

        var isWeak: Bool {
            reviewState.isWeak
        }

        var requiresReview: Bool {
            reviewState.requiresReview
        }

        var backlinkLabel: String {
            target.label
        }

        var relationSummary: String {
            "\(relationshipKind.rawValue) -> \(target.kind.displayName)"
        }

        private static func deterministicID(
            sourceContextEntryID: String,
            target: RelationTargetReference,
            relationshipKind: LifeGraphRelationshipKind,
            reviewState: RelationEdgeReviewState
        ) -> String {
            "lifeknowledge:\(sourceContextEntryID):\(relationshipKind.rawValue):\(target.stableKey):\(reviewState.rawValue)"
                .lowercased()
                .replacingOccurrences(of: #"[^a-z0-9:_-]+"#, with: "-", options: .regularExpression)
        }
    }

    struct RelationBacklink: Codable, Sendable, Equatable, Hashable {
        let target: RelationTargetReference
        let edgeIDs: [String]
        let strongEdgeIDs: [String]
        let weakEdgeIDs: [String]
        let reviewRequiredEdgeIDs: [String]

        var hasBacklinks: Bool {
            edgeIDs.isEmpty == false
        }
    }

    struct ContextEntry: Codable, Sendable, Equatable, Identifiable, Hashable {
        let id: String
        let kind: EntryKind
        let title: String
        let summary: String
        let body: String?
        let sourceRecords: [SourceRecord]
        let receipt: Receipt?
        let replayTrace: ReplayTrace?
        let reflection: Reflection?
        let templateID: String?
        let collectionIDs: [String]
        let resourceIDs: [String]
        let relationEdgeIDs: [String]
        let createdAt: String
        let updatedAt: String
        let deletedAt: String?

        init(
            id: String,
            kind: EntryKind,
            title: String,
            summary: String,
            body: String? = nil,
            sourceRecords: [SourceRecord] = [],
            receipt: Receipt? = nil,
            replayTrace: ReplayTrace? = nil,
            reflection: Reflection? = nil,
            templateID: String? = nil,
            collectionIDs: [String] = [],
            resourceIDs: [String] = [],
            relationEdgeIDs: [String] = [],
            createdAt: String,
            updatedAt: String,
            deletedAt: String? = nil
        ) {
            self.id = LifeKnowledgeOperationModels.normalizedRequired(id)
            self.kind = kind
            self.title = LifeKnowledgeOperationModels.normalizedRequired(title)
            self.summary = LifeKnowledgeOperationModels.normalizedRequired(summary)
            self.body = LifeKnowledgeOperationModels.normalizedOptional(body)
            self.sourceRecords = LifeKnowledgeOperationModels.normalizedSourceRecords(sourceRecords)
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.reflection = reflection
            self.templateID = LifeKnowledgeOperationModels.normalizedOptional(templateID)
            self.collectionIDs = LifeKnowledgeOperationModels.normalizedIDs(collectionIDs)
            self.resourceIDs = LifeKnowledgeOperationModels.normalizedIDs(resourceIDs)
            self.relationEdgeIDs = LifeKnowledgeOperationModels.normalizedIDs(relationEdgeIDs)
            self.createdAt = LifeKnowledgeOperationModels.normalizedRequired(createdAt)
            self.updatedAt = LifeKnowledgeOperationModels.normalizedRequired(updatedAt)
            self.deletedAt = LifeKnowledgeOperationModels.normalizedOptional(deletedAt)
        }

        var sourceRecordIDs: [String] {
            sourceRecords.map(\.id)
        }

        var receiptID: String? {
            receipt?.id
        }

        var replayTraceID: String? {
            replayTrace?.id
        }

        var isDeleted: Bool {
            deletedAt != nil
        }

        var sourceSurfaceTitle: String {
            LifeKnowledgeOperationModels.surfaceTitle
        }

        var localInspectionSummary: String {
            "You / \(LifeKnowledgeOperationModels.surfaceTitle) can inspect this SourceRecord, Receipt, and ReplayTrace."
        }

        func markedDeleted(at timestamp: String) -> ContextEntry {
            ContextEntry(
                id: id,
                kind: kind,
                title: title,
                summary: summary,
                body: body,
                sourceRecords: sourceRecords,
                receipt: receipt,
                replayTrace: replayTrace,
                reflection: reflection,
                templateID: templateID,
                collectionIDs: collectionIDs,
                resourceIDs: resourceIDs,
                relationEdgeIDs: relationEdgeIDs,
                createdAt: createdAt,
                updatedAt: timestamp,
                deletedAt: timestamp
            )
        }
    }

    struct Collection: Codable, Sendable, Equatable, Identifiable, Hashable {
        let id: String
        let title: String
        let summary: String
        let templateID: String?
        let entryIDs: [String]
        let sourceRecords: [SourceRecord]
        let receipt: Receipt?
        let replayTrace: ReplayTrace?
        let reflection: Reflection?
        let createdAt: String
        let updatedAt: String
        let deletedAt: String?

        init(
            id: String,
            title: String,
            summary: String,
            templateID: String? = nil,
            entryIDs: [String] = [],
            sourceRecords: [SourceRecord] = [],
            receipt: Receipt? = nil,
            replayTrace: ReplayTrace? = nil,
            reflection: Reflection? = nil,
            createdAt: String,
            updatedAt: String,
            deletedAt: String? = nil
        ) {
            self.id = LifeKnowledgeOperationModels.normalizedRequired(id)
            self.title = LifeKnowledgeOperationModels.normalizedRequired(title)
            self.summary = LifeKnowledgeOperationModels.normalizedRequired(summary)
            self.templateID = LifeKnowledgeOperationModels.normalizedOptional(templateID)
            self.entryIDs = LifeKnowledgeOperationModels.normalizedIDs(entryIDs)
            self.sourceRecords = LifeKnowledgeOperationModels.normalizedSourceRecords(sourceRecords)
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.reflection = reflection
            self.createdAt = LifeKnowledgeOperationModels.normalizedRequired(createdAt)
            self.updatedAt = LifeKnowledgeOperationModels.normalizedRequired(updatedAt)
            self.deletedAt = LifeKnowledgeOperationModels.normalizedOptional(deletedAt)
        }

        var isDeleted: Bool {
            deletedAt != nil
        }
    }

    struct Template: Codable, Sendable, Equatable, Identifiable, Hashable {
        let id: String
        let title: String
        let summary: String
        let entryKind: EntryKind
        let fieldKeys: [String]
        let sourceRecords: [SourceRecord]
        let receipt: Receipt?
        let replayTrace: ReplayTrace?
        let reflection: Reflection?
        let createdAt: String
        let updatedAt: String
        let deletedAt: String?

        init(
            id: String,
            title: String,
            summary: String,
            entryKind: EntryKind,
            fieldKeys: [String] = [],
            sourceRecords: [SourceRecord] = [],
            receipt: Receipt? = nil,
            replayTrace: ReplayTrace? = nil,
            reflection: Reflection? = nil,
            createdAt: String,
            updatedAt: String,
            deletedAt: String? = nil
        ) {
            self.id = LifeKnowledgeOperationModels.normalizedRequired(id)
            self.title = LifeKnowledgeOperationModels.normalizedRequired(title)
            self.summary = LifeKnowledgeOperationModels.normalizedRequired(summary)
            self.entryKind = entryKind
            self.fieldKeys = LifeKnowledgeOperationModels.normalizedIDs(fieldKeys)
            self.sourceRecords = LifeKnowledgeOperationModels.normalizedSourceRecords(sourceRecords)
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.reflection = reflection
            self.createdAt = LifeKnowledgeOperationModels.normalizedRequired(createdAt)
            self.updatedAt = LifeKnowledgeOperationModels.normalizedRequired(updatedAt)
            self.deletedAt = LifeKnowledgeOperationModels.normalizedOptional(deletedAt)
        }

        var isDeleted: Bool {
            deletedAt != nil
        }
    }

    struct Decision: Codable, Sendable, Equatable, Identifiable, Hashable {
        let id: String
        let title: String
        let summary: String
        let contextEntryID: String
        let sourceRecords: [SourceRecord]
        let receipt: Receipt?
        let replayTrace: ReplayTrace?
        let reflection: Reflection?
        let createdAt: String
        let updatedAt: String
        let deletedAt: String?

        init(
            id: String,
            title: String,
            summary: String,
            contextEntryID: String,
            sourceRecords: [SourceRecord] = [],
            receipt: Receipt? = nil,
            replayTrace: ReplayTrace? = nil,
            reflection: Reflection? = nil,
            createdAt: String,
            updatedAt: String,
            deletedAt: String? = nil
        ) {
            self.id = LifeKnowledgeOperationModels.normalizedRequired(id)
            self.title = LifeKnowledgeOperationModels.normalizedRequired(title)
            self.summary = LifeKnowledgeOperationModels.normalizedRequired(summary)
            self.contextEntryID = LifeKnowledgeOperationModels.normalizedRequired(contextEntryID)
            self.sourceRecords = LifeKnowledgeOperationModels.normalizedSourceRecords(sourceRecords)
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.reflection = reflection
            self.createdAt = LifeKnowledgeOperationModels.normalizedRequired(createdAt)
            self.updatedAt = LifeKnowledgeOperationModels.normalizedRequired(updatedAt)
            self.deletedAt = LifeKnowledgeOperationModels.normalizedOptional(deletedAt)
        }

        var isDeleted: Bool {
            deletedAt != nil
        }
    }

    struct Resource: Codable, Sendable, Equatable, Identifiable, Hashable {
        let id: String
        let reference: ResourceReference
        let sourceRecord: SourceRecord?
        let receipt: Receipt?
        let replayTrace: ReplayTrace?
        let createdAt: String
        let updatedAt: String
        let deletedAt: String?

        init(
            id: String,
            reference: ResourceReference,
            sourceRecord: SourceRecord? = nil,
            receipt: Receipt? = nil,
            replayTrace: ReplayTrace? = nil,
            createdAt: String,
            updatedAt: String,
            deletedAt: String? = nil
        ) {
            self.id = LifeKnowledgeOperationModels.normalizedRequired(id)
            self.reference = reference
            self.sourceRecord = sourceRecord
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.createdAt = LifeKnowledgeOperationModels.normalizedRequired(createdAt)
            self.updatedAt = LifeKnowledgeOperationModels.normalizedRequired(updatedAt)
            self.deletedAt = LifeKnowledgeOperationModels.normalizedOptional(deletedAt)
        }

        var isDeleted: Bool {
            deletedAt != nil
        }
    }

    struct PersonPlaceContext: Codable, Sendable, Equatable, Identifiable, Hashable {
        let id: String
        let kind: PersonPlaceContextKind
        let label: String
        let summary: String
        let sourceRecord: SourceRecord?
        let resourceIDs: [String]
        let createdAt: String
        let updatedAt: String
        let deletedAt: String?

        init(
            id: String,
            kind: PersonPlaceContextKind,
            label: String,
            summary: String,
            sourceRecord: SourceRecord? = nil,
            resourceIDs: [String] = [],
            createdAt: String,
            updatedAt: String,
            deletedAt: String? = nil
        ) {
            self.id = LifeKnowledgeOperationModels.normalizedRequired(id)
            self.kind = kind
            self.label = LifeKnowledgeOperationModels.normalizedRequired(label)
            self.summary = LifeKnowledgeOperationModels.normalizedRequired(summary)
            self.sourceRecord = sourceRecord
            self.resourceIDs = LifeKnowledgeOperationModels.normalizedIDs(resourceIDs)
            self.createdAt = LifeKnowledgeOperationModels.normalizedRequired(createdAt)
            self.updatedAt = LifeKnowledgeOperationModels.normalizedRequired(updatedAt)
            self.deletedAt = LifeKnowledgeOperationModels.normalizedOptional(deletedAt)
        }

        var isDeleted: Bool {
            deletedAt != nil
        }
    }

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

private extension LifeKnowledgeOperationModels {
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

private struct LifeKnowledgeSearchDocument {
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

    private static func searchTokens(from text: String?, maximumTokens: Int) -> [String] {
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

    private static func matches(dateFilter: LifeKnowledgeOperationModels.SearchDateFilter, createdAt: String, updatedAt: String) -> Bool {
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

    private func searchDocuments() -> [LifeKnowledgeSearchDocument] {
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

    private func searchDocument(
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
        let reviewState = reviewStateOverride ?? derivedSearchReviewState(
            sourceRecords: allSourceRecords,
            relationEdges: linkedRelationEdges,
            proofIDs: allProofIDs
        )
        let sensitivity = sensitivityOverride ?? derivedSearchSensitivity(
            sourceRecords: allSourceRecords,
            relationEdges: linkedRelationEdges,
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

    private func derivedSearchReviewState(
        sourceRecords: [SourceRecord],
        relationEdges: [RelationEdge],
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

    private func derivedSearchSensitivity(
        sourceRecords: [SourceRecord],
        relationEdges: [RelationEdge],
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

    private func searchReviewState(for reviewState: RelationEdge.RelationEdgeReviewState) -> LifeKnowledgeOperationModels.SearchReviewState {
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
