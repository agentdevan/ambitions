import Foundation

protocol AppPreferencesStore: Sendable {
    func loadPreferences() async throws -> AppPreferences
}

struct InMemoryAppPreferencesStore: AppPreferencesStore {
    private let preferences: AppPreferences

    init(preferences: AppPreferences) {
        self.preferences = preferences
    }

    func loadPreferences() async throws -> AppPreferences {
        preferences
    }
}
