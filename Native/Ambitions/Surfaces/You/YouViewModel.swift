import AmbitionsDesignSystem
import Foundation
import Observation

@MainActor
@Observable
final class YouViewModel {
    enum PublicReferenceRecheckOutcome: Sendable, Equatable {
        case current
        case updateAvailable(PublicReferenceUpdateToken)
        case stale
        case failed
    }

    var state: AsyncViewState<YouDashboard>
    var preferredTab: AmbitionsSurface
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
            let counts = [
                dashboard.hero.stats.count,
                dashboard.trustCenter.items.count,
                dashboard.controlRoom.entries.count,
                dashboard.memoryControls.items.count,
                dashboard.contextVault.items.count,
                dashboard.integrationsSection.items.count
            ]
            return "loaded:\(counts.map(String.init).joined(separator: ":"))"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    var loadedDashboard: YouDashboard? {
        guard case let .loaded(dashboard) = state else { return nil }
        return dashboard
    }

    init(state: AsyncViewState<YouDashboard> = .loading) {
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

    func load(using service: any YouServicing) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service)
    }

    func refresh(using service: any YouServicing) async {
        do {
            let dashboard = try await service.loadYouDashboard()
            syncEditor(with: dashboard)
            state = .loaded(dashboard)
        } catch {
            state = .failed("Unable to load You: \(error.localizedDescription)")
        }
    }

    func recheckPublicReference(
        using service: any YouServicing,
        observedSourceRevision: String,
        updateToken: PublicReferenceUpdateToken?,
        selectedClaimID: PublicReferenceClaimID?
    ) async -> PublicReferenceRecheckOutcome {
        do {
            guard let updateToken else {
                switch try await service.checkPublicReferenceUpdate(since: observedSourceRevision) {
                case .current:
                    return .current
                case let .updateAvailable(token):
                    return .updateAvailable(token)
                }
            }
            switch try await service.acceptPublicReferenceUpdate(
                updateToken,
                selectedClaimID: selectedClaimID
            ) {
            case let .accepted(dashboard):
                syncEditor(with: dashboard)
                state = .loaded(dashboard)
                return .current
            case .stale:
                return .stale
            }
        } catch {
            return .failed
        }
    }

    func commitPreferences(
        using preferencesCommands: any YouPreferencesCommanding
    ) async {
        guard hasUnsavedChanges else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            let dashboard = try await preferencesCommands.saveYouPreferences(
                YouPreferencesUpdate(
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

    private func syncEditor(with dashboard: YouDashboard) {
        preferredTab = dashboard.preferences.preferredTab
        appearancePreference = dashboard.preferences.appearancePreference
        accentFamily = dashboard.preferences.accentFamily
        reviewCadenceDays = dashboard.preferences.reviewCadenceDays
    }
}
