import AmbitionsDesignSystem
import AmbitionsWidgetUI
import SwiftUI

struct ProfileScreen: View {
    @Environment(\.appContainer) private var container
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var state: AsyncViewState<ProfileDashboard> = .loading
    @State private var preferredTab: AppTab = .today
    @State private var reviewCadenceDays: Int = 7

    var body: some View {
        FeatureScaffoldView(
            eyebrow: "Profile",
            title: "Profile",
            subtitle: "Keep identity and on-device preferences clear inside the native shell."
        ) {
            switch state {
            case .loading:
                LoadingSkeletonCard(lineCount: 7)
                    .transition(.ambitionPanel)
            case let .failed(message):
                EmptyStateCard(
                    title: "Profile is unavailable",
                    message: message,
                    icon: "person.crop.circle.badge.exclamationmark",
                    actionTitle: "Retry"
                ) {
                    Task { await load() }
                }
                .transition(.ambitionPanel)
            case let .loaded(dashboard):
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    AppCard {
                        SectionHeader(
                            title: dashboard.title,
                            subtitle: dashboard.subtitle
                        ) {
                            TagPill(dashboard.badges.first ?? "Ready", state: .selected)
                        }
                    }
                    .transition(.ambitionPanel)

                    WidgetFeed(items: [
                        WidgetFeedItem(id: "profile-summary", priority: .hero, variant: .expanded) {
                            ProfileSummaryWidget(viewModel: summaryViewModel(dashboard))
                        },
                        WidgetFeedItem(id: "profile-settings", priority: .high, variant: .expanded) {
                            SettingsGroupWidget(viewModel: settingsViewModel(dashboard))
                        }
                    ])

                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            SectionHeader(
                                title: "Persisted preferences",
                                subtitle: "These controls write directly into the local app state used by the native shell."
                            )

                            Picker("Default tab", selection: $preferredTab) {
                                ForEach(AppTab.allCases) { tab in
                                    Text(tab.title).tag(tab)
                                }
                            }
                            .pickerStyle(.segmented)

                            Picker("Review cadence", selection: $reviewCadenceDays) {
                                Text("Daily").tag(1)
                                Text("Every 3 days").tag(3)
                                Text("Weekly").tag(7)
                            }
                            .pickerStyle(.segmented)

                            Button("Save preferences") {
                                Task { await savePreferences() }
                            }
                            .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                        }
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .refreshable {
            await load()
        }
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: stateKey)
        .task {
            guard case .loading = state else { return }
            await load()
        }
    }

    private func load() async {
        do {
            let dashboard = try await container.profileService.loadProfileDashboard()
            syncEditor(with: dashboard)
            state = .loaded(dashboard)
        } catch {
            state = .failed("Unable to load Profile: \(error.localizedDescription)")
        }
    }

    private func savePreferences() async {
        do {
            let dashboard = try await container.profileService.saveProfilePreferences(
                ProfilePreferencesUpdate(
                    preferredTab: preferredTab,
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
        reviewCadenceDays = dashboard.preferences.reviewCadenceDays
    }

    private func summaryViewModel(_ dashboard: ProfileDashboard) -> ProfileSummaryWidgetViewModel {
        ProfileSummaryWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .profileSummary, instanceID: "primary"),
                    priority: .hero,
                    variant: .expanded,
                    chrome: .appCard,
                    supportedActions: []
                ),
                state: .ready(
                    ProfileSummaryContent(
                        title: dashboard.title,
                        subtitle: dashboard.subtitle,
                        initials: dashboard.initials,
                        badges: dashboard.badges,
                        stats: dashboard.stats.map {
                            WidgetStat(
                                id: $0.id,
                                title: $0.title,
                                value: $0.value,
                                detail: $0.detail,
                                icon: $0.icon
                            )
                        },
                        actions: []
                    )
                )
            )
        )
    }

    private func settingsViewModel(_ dashboard: ProfileDashboard) -> SettingsGroupWidgetViewModel {
        SettingsGroupWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .settingsGroup, instanceID: "primary"),
                    priority: .high,
                    variant: .expanded,
                    chrome: .appCard,
                    supportedActions: []
                ),
                state: .ready(
                    SettingsGroupContent(
                        title: dashboard.settingsTitle,
                        subtitle: dashboard.settingsSubtitle,
                        items: dashboard.settings.map {
                            WidgetSettingItem(
                                id: $0.id,
                                title: $0.title,
                                subtitle: $0.subtitle,
                                icon: $0.icon,
                                valueLabel: $0.valueLabel
                            )
                        },
                        footer: dashboard.settingsFooter
                    )
                )
            )
        )
    }

    private var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(dashboard):
            return "loaded:\(dashboard.stats.count):\(dashboard.settings.count)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }
}

#Preview("Profile") {
    NavigationStack {
        ProfileScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
