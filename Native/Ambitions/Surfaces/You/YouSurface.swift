import AmbitionsDesignSystem
import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct YouSurface: View {
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.appPlatformCapability) private var appPlatformCapability
    @Environment(\.appUserSystemCapability) private var appUserSystemCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: YouViewModel
    @State private var pendingScreenshotDetail: YouRootDetail?
    let showsNavigationChrome: Bool

    @MainActor
    init(viewModel: YouViewModel? = nil, showsNavigationChrome: Bool = true) {
        _viewModel = State(initialValue: viewModel ?? YouViewModel())
        _pendingScreenshotDetail = State(initialValue: Self.screenshotProofDetail(from: ProcessInfo.processInfo.arguments))
        self.showsNavigationChrome = showsNavigationChrome
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    DegradedStateSurface(state: DegradedStateOrchestrator.objectLoading(.personalSystemCenter))
                        .transition(.ambitionPanel)
                case let .failed(message):
                    DegradedStateSurface(
                        state: DegradedStateOrchestrator.objectUnavailable(.personalSystemCenter),
                        primaryAccessibilityIdentifier: "you.retry-button",
                        onPrimaryAction: {
                            _ = message
                            Task { await refresh() }
                        }
                    )
                    .transition(.ambitionPanel)
                case let .loaded(profileProjection):
                    YouObjectView(
                        profileProjection: profileProjection,
                        onOpenDetail: openDetail
                    )
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("you.scroll")
        .stageOwnedSafeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: theme.spacing.xxxl + theme.spacing.xxl)
                .accessibilityHidden(true)
        }
        .background {
            LivingSurfaceBackground(context: .you, state: .calm, intensity: 0.68)
                .stageOwnedIgnoresSafeArea()
        }
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [
                    theme.colors.surfacePrimary.opacity(0.0),
                    theme.colors.surfacePrimary.opacity(0.74),
                    theme.colors.surfacePrimary
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: theme.spacing.xxxl + theme.spacing.xxl)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
        .navigationTitle(showsNavigationChrome ? "You" : "")
        .refreshable {
            await refresh()
        }
        .accessibilityIdentifier("you.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            await viewModel.load(using: featureFactory.youService)
            syncAppearanceFromLoadedDashboard()
            openPendingScreenshotDetailIfNeeded()
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

    func openDetail(_ detail: YouRootDetail) {
        announce(YouInteractions.accessibilityAnnouncement(for: .openDetail(detail)))
        shell.navigation.openYouRoute(detail.routeTarget)
    }

    func openPendingScreenshotDetailIfNeeded() {
        guard let detail = pendingScreenshotDetail else { return }
        pendingScreenshotDetail = nil
        openDetail(detail)
    }

    func announce(_ message: String) {
        #if canImport(UIKit)
        UIAccessibility.post(notification: .announcement, argument: message)
        #else
        _ = message
        #endif
    }

    static func screenshotProofDetail(from arguments: [String]) -> YouRootDetail? {
        guard launchArgumentValue(for: "AmbitionsScreenshotMode", fromArguments: arguments)?
            .caseInsensitiveCompare("yes") == .orderedSame,
            let rawDetail = launchArgumentValue(for: "AmbitionsYouDetail", fromArguments: arguments)
        else {
            return nil
        }

        return [
            "trust-automation": .automationTrust,
            "privacy-automation": .automationTrust,
            "personal-runtime": .personalRuntime,
            "personal-system": .personalRuntime,
            "receipts-history": .receiptsHistory
        ][rawDetail.lowercased()]
    }

    static func launchArgumentValue(for key: String, fromArguments arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: "-\(key)"), arguments.indices.contains(index + 1) else {
            return nil
        }
        let argumentValue = arguments[index + 1]
        return argumentValue.isEmpty ? nil : argumentValue
    }

    func syncAppearanceFromLoadedDashboard() {
        guard let profileProjection = viewModel.loadedDashboard else { return }
        userSystem.applyAppearancePreference(
            profileProjection.preferences.appearancePreference,
            profileProjection.preferences.accentFamily
        )
    }

    var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }

    var shell: AppShellCapability {
        guard let appShellCapability else {
            preconditionFailure("App shell capability must be injected.")
        }
        return appShellCapability
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
