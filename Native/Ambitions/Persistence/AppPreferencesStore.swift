import Foundation

protocol AppPreferencesStore: Sendable {
    func loadPreferences() async throws -> AppPreferences
    func savePreferences(_ preferences: AppPreferences) async throws
}

struct InMemoryAppPreferencesStore: AppPreferencesStore {
    private let preferences: AppPreferences

    init(preferences: AppPreferences) {
        self.preferences = preferences
    }

    func loadPreferences() async throws -> AppPreferences {
        preferences
    }

    func savePreferences(_ preferences: AppPreferences) async throws {
        _ = preferences
    }
}

struct RepositoryBackedAppPreferencesStore: AppPreferencesStore {
    let appStateRepository: any AppStateRepository

    func loadPreferences() async throws -> AppPreferences {
        try await appStateRepository.loadState().preferences
    }

    func savePreferences(_ preferences: AppPreferences) async throws {
        var state = try await appStateRepository.loadState()
        state.preferredTab = preferences.preferredTab.canonicalTopLevelTab
        state.userDisplayName = preferences.userDisplayName
        state.appearancePreference = preferences.appearancePreference
        try await appStateRepository.saveState(state)
    }
}
