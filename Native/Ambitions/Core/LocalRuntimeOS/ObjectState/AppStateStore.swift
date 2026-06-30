import Foundation

struct SwiftDataAppStateStore: AppStateStore {
    typealias StoredObject = AppStateSnapshot

    let repository: any AppStateRepository

    init(repository: any AppStateRepository) {
        self.repository = repository
    }

    init(store: AmbitionsPersistenceStore) {
        self.init(repository: SwiftDataAppStateRepository(store: store))
    }

    var family: ObjectStateFamily {
        .appState
    }

    func loadState() async throws -> AppStateSnapshot {
        try await repository.loadState()
    }

    func save(
        _ object: AppStateSnapshot,
        context: RuntimeObjectStateMutationContext
    ) async throws -> ObjectStateWriteReceipt {
        try context.validated(for: .appState)
        let identity = try ObjectStateIdentity(family: .appState, rawID: object.id)
        let receipt = try ObjectStateWriteReceipt(identity: identity, mutationKind: .replace, context: context)
        try await repository.saveState(object)
        return receipt
    }
}
