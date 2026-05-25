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
