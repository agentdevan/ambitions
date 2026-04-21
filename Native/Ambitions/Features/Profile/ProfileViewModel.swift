import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    var state: AsyncViewState<ProfileDashboard>
    var preferredTab: AppTab
    var appearancePreference: AppAppearancePreference
    var reviewCadenceDays: Int

    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(dashboard):
            return "loaded:\(dashboard.stats.count):\(dashboard.planningSummary.items.count):\(dashboard.preferencesSection.items.count):\(dashboard.trustSection.items.count)"
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
        reviewCadenceDays = 7
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
            state = .failed("Unable to load Profile: \(error.localizedDescription)")
        }
    }

    func save(using service: any ProfileServicing) async {
        do {
            let dashboard = try await service.saveProfilePreferences(
                ProfilePreferencesUpdate(
                    preferredTab: preferredTab,
                    appearancePreference: appearancePreference,
                    reviewCadenceDays: reviewCadenceDays,
                    localOnlyModeEnabled: true
                )
            )
            syncEditor(with: dashboard)
            state = .loaded(dashboard)
        } catch {
            state = .failed("Unable to save Profile: \(error.localizedDescription)")
        }
    }

    private func syncEditor(with dashboard: ProfileDashboard) {
        preferredTab = dashboard.preferences.preferredTab
        appearancePreference = dashboard.preferences.appearancePreference
        reviewCadenceDays = dashboard.preferences.reviewCadenceDays
    }
}
