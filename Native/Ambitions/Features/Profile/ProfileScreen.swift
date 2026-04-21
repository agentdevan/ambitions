import AmbitionsDesignSystem
import SwiftUI

struct ProfileScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: ProfileViewModel
    private let showsNavigationChrome: Bool

    @MainActor
    init(viewModel: ProfileViewModel? = nil, showsNavigationChrome: Bool = true) {
        _viewModel = State(initialValue: viewModel ?? ProfileViewModel())
        self.showsNavigationChrome = showsNavigationChrome
    }

    var body: some View {
        FeatureScaffoldView(
            eyebrow: "Profile",
            title: "Profile",
            subtitle: "Keep identity and on-device preferences clear inside the native shell."
        ) {
            switch viewModel.state {
            case .loading:
                LoadingSkeletonCard(lineCount: 7)
                    .transition(.ambitionPanel)
            case let .failed(message):
                EmptyStateCard(
                    title: "Profile is unavailable",
                    message: message,
                    icon: "person.crop.circle.badge.exclamationmark",
                    actionTitle: "Retry",
                    actionAccessibilityIdentifier: "profile.retry-button"
                ) {
                    Task { await refresh() }
                }
                .transition(.ambitionPanel)
            case let .loaded(dashboard):
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    AppCard {
                        SectionHeader(
                            title: dashboard.title,
                            subtitle: "Profile keeps the app's defaults, personalization, and conservative trust posture easy to understand."
                        ) {
                            TagPill(dashboard.badges.first ?? "Ready", state: .selected)
                        }
                    }
                    .transition(.ambitionPanel)

                    ProfilePlanningSummaryCard(summary: dashboard.planningSummary)

                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            SectionHeader(
                                title: dashboard.preferencesSection.title,
                                subtitle: dashboard.preferencesSection.subtitle
                            )

                            Picker("Default tab", selection: $viewModel.preferredTab) {
                                ForEach(AppTab.allCases) { tab in
                                    Text(tab.title).tag(tab)
                                }
                            }
                            .pickerStyle(.segmented)
                            .accessibilityIdentifier("profile.default-tab-picker")

                            Picker("Appearance", selection: $viewModel.appearancePreference) {
                                ForEach(AppAppearancePreference.allCases, id: \.self) { preference in
                                    Text(preference.title).tag(preference)
                                }
                            }
                            .pickerStyle(.segmented)
                            .accessibilityIdentifier("profile.appearance-picker")

                            Picker("Review cadence", selection: $viewModel.reviewCadenceDays) {
                                Text("Daily").tag(1)
                                Text("Every 3 days").tag(3)
                                Text("Weekly").tag(7)
                            }
                            .pickerStyle(.segmented)

                            Button("Save preferences") {
                                Task { await savePreferences() }
                            }
                            .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                            .accessibilityIdentifier("profile.save-preferences-button")

                            if let actionTitle = dashboard.notificationAuthorization.actionTitle {
                                Button(actionTitle) {
                                    Task { await requestNotificationAuthorization() }
                                }
                                .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                                .accessibilityIdentifier("profile.enable-notifications-button")
                            }
                        }
                    }
                    .accessibilityIdentifier("profile.personalization-card")

                    ProfileTrustSectionCard(section: dashboard.trustSection)
                }
            }
        }
        .navigationTitle(showsNavigationChrome ? "Profile" : "")
        .refreshable {
            await refresh()
        }
        .accessibilityIdentifier("profile.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            await viewModel.load(using: container.profileService)
            syncAppearanceFromLoadedDashboard()
        }
    }

    private func refresh() async {
        await viewModel.refresh(using: container.profileService)
        syncAppearanceFromLoadedDashboard()
    }

    private func savePreferences() async {
        await viewModel.save(using: container.profileService)
        syncAppearanceFromLoadedDashboard()
    }

    private func requestNotificationAuthorization() async {
        let granted = await container.notificationService.requestAuthorizationOptIn()
        if granted {
            await container.notificationService.refreshSchedule(now: .now)
        }
        await refresh()
    }

    private func syncAppearanceFromLoadedDashboard() {
        guard let dashboard = viewModel.loadedDashboard else { return }
        container.appearancePreference = dashboard.preferences.appearancePreference
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

private struct ProfilePlanningSummaryCard: View {
    @Environment(\.ambitionTheme) private var theme

    let summary: ProfilePlanningSummary

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: summary.title, subtitle: summary.subtitle)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(summary.items) { item in
                        ProfileSettingRow(item: item)
                    }
                }
            }
        }
        .accessibilityIdentifier("profile.planning-summary-card")
    }
}

private struct ProfileTrustSectionCard: View {
    @Environment(\.ambitionTheme) private var theme

    let section: ProfileSectionGroup

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: section.title, subtitle: section.subtitle)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(section.items) { item in
                        ProfileSettingRow(item: item)
                    }
                }

                if let footer = section.footer {
                    Text(footer)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, theme.spacing.xs)
                }
            }
        }
        .accessibilityIdentifier("profile.trust-card")
    }
}

private struct ProfileSettingRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: SettingsItem

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: item.icon)
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentPrimary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(item.title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: theme.spacing.sm)
            if let valueLabel = item.valueLabel {
                TagPill(valueLabel, state: .default)
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility()
    }
}

#if DEBUG
#Preview("Profile Light") {
    NavigationStack {
        ProfileScreen(viewModel: ProfileViewModel(state: .loaded(PreviewFixtures.default.profileDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

#Preview("Profile Dark") {
    NavigationStack {
        ProfileScreen(viewModel: ProfileViewModel(state: .loaded(PreviewFixtures.default.profileDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}
#endif
