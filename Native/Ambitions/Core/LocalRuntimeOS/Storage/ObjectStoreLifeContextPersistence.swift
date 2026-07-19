import Foundation
import SwiftData

private enum LifeContextPersistenceMapping {
    static func record(from bundle: LifeContextBundle) throws -> LifeContextBundleRecord {
        LifeContextBundleRecord(
            id: bundle.id,
            schemaVersion: lifeContextBundleRecordSchemaVersion,
            createdAt: bundle.createdAt,
            updatedAt: bundle.updatedAt,
            deletedAt: bundle.deletedAt,
            snapshotData: try PersistenceCoding.encode(bundle)
        )
    }

    static func apply(_ bundle: LifeContextBundle, to record: LifeContextBundleRecord) throws {
        record.schemaVersion = lifeContextBundleRecordSchemaVersion
        record.createdAt = bundle.createdAt
        record.updatedAt = bundle.updatedAt
        record.deletedAt = bundle.deletedAt
        record.snapshotData = try PersistenceCoding.encode(bundle)
    }

    static func bundle(from record: LifeContextBundleRecord) throws -> LifeContextBundle {
        if let snapshot = try? PersistenceCoding.decode(LifeContextBundle.self, from: record.snapshotData) {
            return snapshot
        }

        throw PersistenceError.invalidStoredValue("LifeContextBundleRecord snapshots must decode into LifeContextBundle.")
    }
}

let lifeContextBundleRecordSchemaVersion = "life_context_bundle_record.swiftdata.v1"

struct SwiftDataLifeContextRepository: LifeContextRepository {
    let store: AmbitionsPersistenceStore

    func listBundles() async throws -> [LifeContextBundle] {
        try await store.read { context in
            let records = try context.fetch(FetchDescriptor<LifeContextBundleRecord>())
            return try records
                .filter { $0.deletedAt == nil }
                .sorted {
                    if $0.updatedAt != $1.updatedAt {
                        return $0.updatedAt > $1.updatedAt
                    }
                    return $0.id > $1.id
                }
                .map { try LifeContextPersistenceMapping.bundle(from: $0) }
        }
    }

    func bundle(id: String) async throws -> LifeContextBundle? {
        try await store.read { context in
            guard let record = try context.fetch(FetchDescriptor<LifeContextBundleRecord>())
                .first(where: { $0.id == id && $0.deletedAt == nil }) else {
                return nil
            }
            return try LifeContextPersistenceMapping.bundle(from: record)
        }
    }

    func saveBundles(_ bundles: [LifeContextBundle]) async throws {
        try await store.write { context in
            let existing = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<LifeContextBundleRecord>()).map { ($0.id, $0) })
            for bundle in bundles {
                if let record = existing[bundle.id] {
                    try LifeContextPersistenceMapping.apply(bundle, to: record)
                } else {
                    context.insert(try LifeContextPersistenceMapping.record(from: bundle))
                }
            }
        }
    }

    func deleteBundle(id: String, at timestamp: String) async throws {
        try await store.write { context in
            guard let record = try context.fetch(FetchDescriptor<LifeContextBundleRecord>()).first(where: { $0.id == id }) else {
                return
            }

            if let snapshot = try? LifeContextPersistenceMapping.bundle(from: record) {
                let deleted = snapshot.markedDeleted(at: timestamp)
                try LifeContextPersistenceMapping.apply(deleted, to: record)
            } else {
                record.deletedAt = timestamp
                record.updatedAt = timestamp
            }
        }
    }

    func projectRuntime(for bundleID: String, asOf now: Date) async throws -> LifeContextRuntimeProjection? {
        guard let bundle = try await bundle(id: bundleID) else {
            return nil
        }
        return bundle.projection(asOf: now)
    }
}
