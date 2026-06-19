import Foundation

extension LifeKnowledgeOperationModels {
    static let schemaVersion = "life_knowledge_operation_models.native.v1"

    static let surfaceTitle = "Search Ambitions"

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

        static func deterministicID(
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
            "You / \(LifeKnowledgeOperationModels.surfaceTitle) can inspect this source, receipt, and reason."
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
}
