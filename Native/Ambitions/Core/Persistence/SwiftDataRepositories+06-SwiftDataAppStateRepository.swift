import Foundation
import SwiftData

struct SwiftDataAppStateRepository: AppStateRepository {
    let store: AmbitionsPersistenceStore

    func loadState() async throws -> AppStateSnapshot {
        try await store.read { context in
            guard let record = try context.fetch(FetchDescriptor<AppStateRecord>()).first else {
                return .default
            }
            return try RepositoryMapping.appState(from: record)
        }
    }

    func saveState(_ state: AppStateSnapshot) async throws {
        try await store.write { context in
            if let record = try context.fetch(FetchDescriptor<AppStateRecord>()).first(where: { $0.id == state.id }) {
                record.preferredTabRaw = state.preferredTab.rawValue
                record.userDisplayName = state.userDisplayName
                record.appearancePreferenceRaw = state.appearancePreference.rawValue
                record.hasCompletedBootstrap = state.hasCompletedBootstrap
                record.lastBootstrapSourceRaw = state.lastBootstrapSource?.rawValue
                record.lastBootstrapAt = state.lastBootstrapAt
                record.lastSeedVersion = state.lastSeedVersion
                record.lastSeededAt = state.lastSeededAt
                record.lastOpenedGoalID = state.lastOpenedGoalID
                record.snapshotData = try PersistenceCoding.encode(state)
            } else {
                context.insert(try RepositoryMapping.appStateRecord(from: state))
            }
        }
    }
}
