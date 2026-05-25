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
            createdAt: String,
            updatedAt: String,
            deletedAt: String? = nil
        ) {
            self.id = Self.normalizedRequired(id)
            self.kind = kind
            self.title = Self.normalizedRequired(title)
            self.summary = Self.normalizedRequired(summary)
            self.body = Self.normalizedOptional(body)
            self.sourceRecords = Self.normalizedSourceRecords(sourceRecords)
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.reflection = reflection
            self.templateID = Self.normalizedOptional(templateID)
            self.collectionIDs = Self.normalizedIDs(collectionIDs)
            self.resourceIDs = Self.normalizedIDs(resourceIDs)
            self.createdAt = Self.normalizedRequired(createdAt)
            self.updatedAt = Self.normalizedRequired(updatedAt)
            self.deletedAt = Self.normalizedOptional(deletedAt)
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
            self.id = Self.normalizedRequired(id)
            self.title = Self.normalizedRequired(title)
            self.summary = Self.normalizedRequired(summary)
            self.templateID = Self.normalizedOptional(templateID)
            self.entryIDs = Self.normalizedIDs(entryIDs)
            self.sourceRecords = Self.normalizedSourceRecords(sourceRecords)
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.reflection = reflection
            self.createdAt = Self.normalizedRequired(createdAt)
            self.updatedAt = Self.normalizedRequired(updatedAt)
            self.deletedAt = Self.normalizedOptional(deletedAt)
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
            self.id = Self.normalizedRequired(id)
            self.title = Self.normalizedRequired(title)
            self.summary = Self.normalizedRequired(summary)
            self.entryKind = entryKind
            self.fieldKeys = Self.normalizedIDs(fieldKeys)
            self.sourceRecords = Self.normalizedSourceRecords(sourceRecords)
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.reflection = reflection
            self.createdAt = Self.normalizedRequired(createdAt)
            self.updatedAt = Self.normalizedRequired(updatedAt)
            self.deletedAt = Self.normalizedOptional(deletedAt)
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
            self.id = Self.normalizedRequired(id)
            self.title = Self.normalizedRequired(title)
            self.summary = Self.normalizedRequired(summary)
            self.contextEntryID = Self.normalizedRequired(contextEntryID)
            self.sourceRecords = Self.normalizedSourceRecords(sourceRecords)
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.reflection = reflection
            self.createdAt = Self.normalizedRequired(createdAt)
            self.updatedAt = Self.normalizedRequired(updatedAt)
            self.deletedAt = Self.normalizedOptional(deletedAt)
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
            self.id = Self.normalizedRequired(id)
            self.reference = reference
            self.sourceRecord = sourceRecord
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.createdAt = Self.normalizedRequired(createdAt)
            self.updatedAt = Self.normalizedRequired(updatedAt)
            self.deletedAt = Self.normalizedOptional(deletedAt)
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
            self.id = Self.normalizedRequired(id)
            self.kind = kind
            self.label = Self.normalizedRequired(label)
            self.summary = Self.normalizedRequired(summary)
            self.sourceRecord = sourceRecord
            self.resourceIDs = Self.normalizedIDs(resourceIDs)
            self.createdAt = Self.normalizedRequired(createdAt)
            self.updatedAt = Self.normalizedRequired(updatedAt)
            self.deletedAt = Self.normalizedOptional(deletedAt)
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
            createdAt: String,
            updatedAt: String,
            deletedAt: String? = nil
        ) {
            self.id = Self.normalizedRequired(id)
            self.surfaceTitle = Self.normalizedRequired(surfaceTitle)
            self.inspectionSummary = Self.normalizedRequired(inspectionSummary)
            self.sourceRecords = Self.normalizedSourceRecords(sourceRecords)
            self.receipt = receipt
            self.replayTrace = replayTrace
            self.contextEntries = Self.normalized(contextEntries)
            self.collections = Self.normalized(collections)
            self.templates = Self.normalized(templates)
            self.decisions = Self.normalized(decisions)
            self.resources = Self.normalized(resources)
            self.personPlaceContexts = Self.normalized(personPlaceContexts)
            self.reflections = Self.normalized(reflections)
            self.createdAt = Self.normalizedRequired(createdAt)
            self.updatedAt = Self.normalizedRequired(updatedAt)
            self.deletedAt = Self.normalizedOptional(deletedAt)
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
                createdAt: createdAt,
                updatedAt: timestamp,
                deletedAt: nil
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

    static func normalized<T: Identifiable & Equatable>(_ values: [T]) -> [T] where T.ID == String {
        Array(values).sorted { lhs, rhs in
            if lhs.id != rhs.id {
                return lhs.id < rhs.id
            }
            return String(describing: lhs) < String(describing: rhs)
        }
    }
}
