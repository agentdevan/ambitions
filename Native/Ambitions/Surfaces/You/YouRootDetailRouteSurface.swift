import AmbitionsDesignSystem
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

struct YouRootDetailRouteSurface: View {
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.appPlatformCapability) private var appPlatformCapability
    @Environment(\.appUserSystemCapability) private var appUserSystemCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: YouViewModel

    let detail: YouRootDetail

    @MainActor
    init(detail: YouRootDetail) {
        _viewModel = State(initialValue: YouViewModel())
        self.detail = detail
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    AsyncStateCard(.loading(lines: 8))
                case let .failed(message):
                    AsyncStateCard(
                        .error(title: "\(detail.title) is unavailable", message: message, icon: "person.crop.circle", actionTitle: "Retry"),
                        actionAccessibilityIdentifier: "you.detail.retry-button"
                    ) {
                        Task { await refresh() }
                    }
                case let .loaded(profileProjection):
                    YouRootDetailContent(
                        detail: detail,
                        profileProjection: profileProjection,
                        appearancePreference: $viewModel.appearancePreference,
                        accentFamily: $viewModel.accentFamily,
                        preferredTab: $viewModel.preferredTab,
                        reviewCadenceDays: $viewModel.reviewCadenceDays,
                        isSaving: viewModel.isSaving,
                        hasUnsavedChanges: viewModel.hasUnsavedChanges,
                        onSavePreferences: savePreferences,
                        onEnableNotifications: requestNotificationAuthorization,
                        notificationPermissionState: notificationPermissionState(for: profileProjection),
                        onOpenSystemSettings: openSystemSettingsIfAvailable
                    )
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await refresh()
        }
        .accessibilityIdentifier("you.screen")
        .accessibilityLabel("\(detail.title). You settings.")
        .accessibilityHint("Review this settings detail.")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            await viewModel.load(using: featureFactory.youService)
            syncAppearanceFromLoadedDashboard()
        }
        .onChange(of: viewModel.appearancePreference) { _, _ in
            applyAppearancePreviewFromEditor()
        }
        .onChange(of: viewModel.accentFamily) { _, _ in
            applyAppearancePreviewFromEditor()
        }
    }

    func refresh() async {
        await viewModel.refresh(using: featureFactory.youService)
        syncAppearanceFromLoadedDashboard()
    }

    func savePreferences() {
        Task {
            await viewModel.save(using: featureFactory.youService)
            syncAppearanceFromLoadedDashboard()
            announce(YouInteractions.accessibilityAnnouncement(for: .savePreferences))
        }
    }

    func applyAppearancePreviewFromEditor() {
        userSystem.applyAppearancePreference(
            viewModel.appearancePreference,
            viewModel.accentFamily
        )
    }

    func requestNotificationAuthorization() {
        Task {
            let granted = await platform.notificationService.requestAuthorizationOptIn()
            announce(YouInteractions.permissionAnnouncement(granted: granted))
            if granted {
                await platform.notificationService.refreshSchedule(now: .now)
            }
            await refresh()
        }
    }

    func notificationPermissionState(for dashboard: YouDashboard) -> DegradedStatePresentation? {
        if dashboard.notificationAuthorization.statusLabel == "Denied" {
            return DegradedStateOrchestrator.permissionDeniedNotifications()
        }
        if dashboard.notificationAuthorization.canRequestAuthorization {
            return DegradedStateOrchestrator.permissionNeededNotifications()
        }
        return nil
    }

    func openSystemSettingsIfAvailable() {
        #if canImport(UIKit)
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            announce(YouInteractions.accessibilityAnnouncement(for: .openSystemSettings))
            UIApplication.shared.open(url)
        #endif
    }

    func syncAppearanceFromLoadedDashboard() {
        guard let profileProjection = viewModel.loadedDashboard else { return }
        userSystem.applyAppearancePreference(
            profileProjection.preferences.appearancePreference,
            profileProjection.preferences.accentFamily
        )
    }

    func announce(_ message: String) {
        #if canImport(UIKit)
            UIAccessibility.post(notification: .announcement, argument: message)
        #else
            _ = message
        #endif
    }

    var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }

    var platform: AppPlatformCapability {
        guard let appPlatformCapability else {
            preconditionFailure("App platform capability must be injected.")
        }
        return appPlatformCapability
    }

    var userSystem: AppUserSystemCapability {
        guard let appUserSystemCapability else {
            preconditionFailure("App user system capability must be injected.")
        }
        return appUserSystemCapability
    }
}
