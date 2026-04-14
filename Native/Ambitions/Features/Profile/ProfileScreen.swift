import AmbitionsDesignSystem
import AmbitionsWidgetUI
import SwiftUI

struct ProfileScreen: View {
    @Environment(\.appContainer) private var container
    @State private var state: AsyncViewState<ProfileDashboard> = .loading

    var body: some View {
        FeatureScaffoldView(
            title: "Profile",
            subtitle: "Account, settings, and widget-related configuration will move here as native services come online."
        ) {
            switch state {
            case .loading:
                ProgressView("Loading profile")
                    .frame(maxWidth: .infinity, alignment: .leading)
            case let .failed(message):
                Text(message)
                    .foregroundStyle(.secondary)
            case let .loaded(dashboard):
                WidgetFeed(items: [
                    WidgetFeedItem(id: "profile-summary", priority: .hero, variant: .expanded) {
                        ProfileSummaryWidget(viewModel: summaryViewModel(dashboard), onAction: handleAction)
                    },
                    WidgetFeedItem(id: "profile-settings", priority: .high, variant: .expanded) {
                        SettingsGroupWidget(viewModel: settingsViewModel(dashboard), onAction: handleAction)
                    }
                ])
            }
        }
        .navigationTitle("Profile")
        .task {
            guard case .loading = state else { return }
            await load()
        }
    }

    private func load() async {
        do {
            state = .loaded(try await container.profileService.loadProfileDashboard())
        } catch {
            state = .failed("Unable to load Profile: \(error.localizedDescription)")
        }
    }

    private func handleAction(_ action: WidgetAction) {
        Task {
            await container.actionRouter.handle(action)
        }
    }

    private func summaryViewModel(_ dashboard: ProfileDashboard) -> ProfileSummaryWidgetViewModel {
        ProfileSummaryWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .profileSummary, instanceID: "primary"),
                    priority: .hero,
                    variant: .expanded,
                    chrome: .appCard,
                    supportedActions: [.openDetail]
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
                        actions: [
                            WidgetInlineActionDescriptor(kind: .openDetail, title: "Open account", icon: "person.crop.circle.badge.checkmark")
                        ]
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
                    supportedActions: [.openDetail]
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
}

#Preview("Profile") {
    NavigationStack {
        ProfileScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
