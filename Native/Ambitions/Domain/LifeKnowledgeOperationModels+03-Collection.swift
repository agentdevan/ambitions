import Foundation

extension LifeKnowledgeOperationModels {

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
}
