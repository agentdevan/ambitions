import Foundation

let appGroupSnapshotWriterInventorySchemaVersion = "app_group_snapshot_writer_inventory.native.v1"

enum AppGroupSnapshotWriterFamily: String, Codable, Sendable, Equatable, CaseIterable {
    case nextStepExternalSurface = "next_step_external_surface"
}

struct AppGroupSnapshotWriterDescriptor: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let family: AppGroupSnapshotWriterFamily
    let writerTypeName: String
    let writerSourcePath: String
    let storeTypeName: String
    let storeSourcePath: String
    let appGroupIdentifier: String
    let appGroupRelativeDirectory: String
    let recordID: String
    let recordFileName: String
    let snapshotKind: String
    let recordSchemaVersion: String
    let payloadSchemaVersion: String
    let sourceProjectionIDs: [String]
    let projectionOnly: Bool
    let rawRuntimeRepositoryReadAllowed: Bool
    let containsPrivateRuntimeDataAllowed: Bool
    let allowedPrivacyClassRawValues: [String]
    let blockedPrivacyClassRawValues: [String]
    let redactionGate: String
    let checksumRequired: Bool
    let fileProtectionPolicy: String
    let staleAwareFields: [String]
    let readerTypeNames: [String]
    let nonSnapshotAppGroupAccessors: [String]
}

struct AppGroupSnapshotWriterInventory: Codable, Sendable, Equatable {
    let schemaVersion: String
    let writers: [AppGroupSnapshotWriterDescriptor]

    static let current = AppGroupSnapshotWriterInventory(
        schemaVersion: appGroupSnapshotWriterInventorySchemaVersion,
        writers: [
            AppGroupSnapshotWriterDescriptor(
                id: "writer.external_surface_snapshot.next_step_widget",
                family: .nextStepExternalSurface,
                writerTypeName: "ExternalSurfaceSnapshotWriter",
                writerSourcePath: "Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift",
                storeTypeName: "AppGroupSnapshotStore",
                storeSourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore.swift",
                appGroupIdentifier: "group.com.ambitions.shared",
                appGroupRelativeDirectory: "ExternalSnapshots",
                recordID: "external-surface-current",
                recordFileName: "external-surface-current.snapshot.json",
                snapshotKind: "widget_projection_external_surface",
                recordSchemaVersion: "app_group_snapshot_store.native.v1",
                payloadSchemaVersion: "external_surface_snapshot.v1",
                sourceProjectionIDs: ["widget", "privacy"],
                projectionOnly: true,
                rawRuntimeRepositoryReadAllowed: false,
                containsPrivateRuntimeDataAllowed: false,
                allowedPrivacyClassRawValues: [
                    "calendar_derived",
                    "standard",
                    "sync_metadata"
                ],
                blockedPrivacyClassRawValues: [
                    "private_user_text",
                    "sensitive"
                ],
                redactionGate: "PrivacyExternalBoundaryGate.evaluateExternalSnapshot",
                checksumRequired: true,
                fileProtectionPolicy: "complete_until_first_user_authentication",
                staleAwareFields: [
                    "continuity.lease.status",
                    "continuity.lease.generatedAt",
                    "continuity.lease.staleActionLabel",
                    "continuity.syncHealth.state",
                    "continuity.lifecycle.sourceState"
                ],
                readerTypeNames: [
                    "ExtensionExternalSurfaceSnapshotReader",
                    "FileExternalSurfaceSnapshotReader",
                    "FileRuntimeExternalSurfaceSnapshotReader"
                ],
                nonSnapshotAppGroupAccessors: [
                    "SharedExternalCreationStore",
                    "ObjectStoreSwiftDataLegacyMigration"
                ]
            )
        ]
    )

    func writer(for family: AppGroupSnapshotWriterFamily) -> AppGroupSnapshotWriterDescriptor? {
        writers.first { $0.family == family }
    }
}
