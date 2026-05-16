import AmbitionsDesignSystem
import Foundation
import Observation

@MainActor
@Observable
final class YouViewModel {
    var state: AsyncViewState<ProfileDashboard>
    var preferredTab: AppTab
    var appearancePreference: AppAppearancePreference
    var accentFamily: AmbitionAccentFamily
    var reviewCadenceDays: Int
    var isSaving = false

    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(dashboard):
            return "loaded:\(dashboard.hero.stats.count):\(dashboard.trustCenter.items.count):\(dashboard.controlRoom.entries.count):\(dashboard.memoryControls.items.count):\(dashboard.contextVault.items.count):\(dashboard.integrationsSection.items.count)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    var loadedDashboard: ProfileDashboard? {
        guard case let .loaded(dashboard) = state else { return nil }
        return dashboard
    }

    init(state: AsyncViewState<ProfileDashboard> = .loading) {
        self.state = state
        preferredTab = .today
        appearancePreference = .system
        accentFamily = .sage
        reviewCadenceDays = 7
    }

    var hasUnsavedChanges: Bool {
        guard let dashboard = loadedDashboard else { return false }
        return preferredTab != dashboard.preferences.preferredTab ||
            appearancePreference != dashboard.preferences.appearancePreference ||
            accentFamily != dashboard.preferences.accentFamily ||
            reviewCadenceDays != dashboard.preferences.reviewCadenceDays
    }

    func load(using service: any ProfileServicing) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service)
    }

    func refresh(using service: any ProfileServicing) async {
        do {
            let dashboard = try await service.loadProfileDashboard()
            syncEditor(with: dashboard)
            state = .loaded(dashboard)
        } catch {
            state = .failed("Unable to load You: \(error.localizedDescription)")
        }
    }

    func save(using service: any ProfileServicing) async {
        guard hasUnsavedChanges else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            let dashboard = try await service.saveProfilePreferences(
                ProfilePreferencesUpdate(
                    preferredTab: preferredTab,
                    appearancePreference: appearancePreference,
                    accentFamily: accentFamily,
                    reviewCadenceDays: reviewCadenceDays,
                    localOnlyModeEnabled: true
                )
            )
            syncEditor(with: dashboard)
            state = .loaded(dashboard)
        } catch {
            state = .failed("Unable to save You: \(error.localizedDescription)")
        }
    }

    private func syncEditor(with dashboard: ProfileDashboard) {
        preferredTab = dashboard.preferences.preferredTab
        appearancePreference = dashboard.preferences.appearancePreference
        accentFamily = dashboard.preferences.accentFamily
        reviewCadenceDays = dashboard.preferences.reviewCadenceDays
    }
}
