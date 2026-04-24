import AmbitionsDesignSystem
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    AsyncStateCard(.loading(lines: 12))
                        .transition(.ambitionPanel)
                case let .failed(message):
                    AsyncStateCard(
                        .error(title: "Profile is unavailable", message: message, icon: "person.crop.circle.badge.exclamationmark", actionTitle: "Retry"),
                        actionAccessibilityIdentifier: "profile.retry-button"
                    ) {
                        Task { await refresh() }
                    }
                    .transition(.ambitionPanel)
                case let .loaded(dashboard):
                    ProfileHeroCard(hero: dashboard.hero)

                    ProfileAppearanceStudioCard(
                        studio: dashboard.appearanceStudio,
                        appearancePreference: $viewModel.appearancePreference,
                        accentFamily: $viewModel.accentFamily,
                        isSaving: viewModel.isSaving,
                        hasUnsavedChanges: viewModel.hasUnsavedChanges,
                        onSave: savePreferences
                    )

                    ProfileDefaultsCard(
                        section: dashboard.defaultsSection,
                        preferredTab: $viewModel.preferredTab,
                        reviewCadenceDays: $viewModel.reviewCadenceDays
                    )

                    ProfileTrustCenterCard(
                        trustCenter: dashboard.trustCenter,
                        notificationActionTitle: dashboard.notificationAuthorization.actionTitle,
                        onEnableNotifications: requestNotificationAuthorization
                    )

                    if let permissionState = notificationPermissionState(for: dashboard) {
                        DegradedStateCard(
                            state: permissionState,
                            primaryAccessibilityIdentifier: "profile.notification-permission.primary",
                            secondaryAccessibilityIdentifier: "profile.notification-permission.secondary",
                            onPrimaryAction: {
                                if dashboard.notificationAuthorization.canRequestAuthorization {
                                    requestNotificationAuthorization()
                                }
                            },
                            onSecondaryAction: {
                                openSystemSettingsIfAvailable()
                            }
                        )
                        .transition(.ambitionPanel)
                    }

                    ProfileContextVaultCard(contextVault: dashboard.contextVault)

                    ProfileSectionCard(
                        eyebrow: "System configuration",
                        section: dashboard.integrationsSection,
                        accessibilityIdentifier: "profile.integrations-card"
                    )

                    ProfileSectionCard(
                        eyebrow: "Person-level",
                        section: dashboard.accountSection,
                        accessibilityIdentifier: "profile.account-card"
                    )
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
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

    private func savePreferences() {
        Task {
            await viewModel.save(using: container.profileService)
            syncAppearanceFromLoadedDashboard()
        }
    }

    private func requestNotificationAuthorization() {
        Task {
            let granted = await container.notificationService.requestAuthorizationOptIn()
            if granted {
                await container.notificationService.refreshSchedule(now: .now)
            }
            await refresh()
        }
    }

    private func notificationPermissionState(for dashboard: ProfileDashboard) -> DegradedStatePresentation? {
        if dashboard.notificationAuthorization.statusLabel == "Denied" {
            return DegradedStateOrchestrator.permissionDeniedNotifications()
        }
        if dashboard.notificationAuthorization.canRequestAuthorization {
            return DegradedStateOrchestrator.permissionNeededNotifications()
        }
        return nil
    }

    private func openSystemSettingsIfAvailable() {
        #if canImport(UIKit)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        #endif
    }

    private func syncAppearanceFromLoadedDashboard() {
        guard let dashboard = viewModel.loadedDashboard else { return }
        container.appearancePreference = dashboard.preferences.appearancePreference
        container.accentFamily = dashboard.preferences.accentFamily
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

private struct ProfileHeroCard: View {
    @Environment(\.ambitionTheme) private var theme

    let hero: ProfileHeroState

    var body: some View {
        HeroCard(state: hero.status) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text("Profile / Trust")
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(hero.title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(hero.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(hero.dominantTruth)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(hero.supportingTruth)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(hero.pills) { pill in
                            TagPill(pill.title, icon: pill.icon, state: pill.state)
                        }
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: theme.spacing.sm) {
                    ForEach(hero.stats) { metric in
                        ProfileMetricTile(metric: metric)
                    }
                }

                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(hero.trustWhisper)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityIdentifier("profile.hero-card")
        .ambitionPanelAccessibility()
    }
}

private struct ProfileMetricTile: View {
    @Environment(\.ambitionTheme) private var theme

    let metric: MetricSummary

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Label(metric.title, systemImage: metric.icon)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            Text(metric.value)
                .font(theme.typography.numeric)
                .foregroundStyle(theme.colors.textPrimary)
            if let detail = metric.detail {
                Text(detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}

private struct ProfileAppearanceStudioCard: View {
    @Environment(\.ambitionTheme) private var theme

    let studio: ProfileAppearanceStudioState
    @Binding var appearancePreference: AppAppearancePreference
    @Binding var accentFamily: AmbitionAccentFamily
    let isSaving: Bool
    let hasUnsavedChanges: Bool
    let onSave: () -> Void

    private let previewColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Appearance",
                    title: studio.title,
                    subtitle: studio.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text(studio.previewSummary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)

                    Picker("Appearance", selection: $appearancePreference) {
                        ForEach(studio.modeOptions) { option in
                            Text(option.title).tag(option.preference)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("profile.appearance-picker")

                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        ForEach(studio.modeOptions) { option in
                            ProfileSelectableRow(
                                title: option.title,
                                subtitle: option.subtitle,
                                state: appearancePreference == option.preference ? .selected : .default
                            ) {
                                appearancePreference = option.preference
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    HStack {
                        Text("Accent family")
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Spacer()
                        TagPill(accentFamily.title, icon: "paintpalette", state: .selected)
                    }

                    Picker("Accent family", selection: $accentFamily) {
                        ForEach(studio.accentOptions) { option in
                            Text(option.title).tag(option.family)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("profile.accent-family-picker")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: theme.spacing.sm) {
                        ForEach(studio.accentOptions) { option in
                            ProfileAccentTile(
                                option: option,
                                isSelected: accentFamily == option.family
                            ) {
                                accentFamily = option.family
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(
                        title: "Live preview",
                        subtitle: "See the selected appearance against Ambitions hierarchy before you commit it."
                    )

                    LazyVGrid(columns: previewColumns, spacing: theme.spacing.sm) {
                        ForEach(studio.previewSwatches) { swatch in
                            ProfilePreviewSwatchCard(
                                swatch: swatch,
                                appearancePreference: appearancePreference,
                                accentFamily: accentFamily
                            )
                        }
                    }
                }

                Text(studio.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onSave) {
                    HStack(spacing: theme.spacing.sm) {
                        Image(systemName: hasUnsavedChanges ? "checkmark.circle" : "checkmark.circle.fill")
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(hasUnsavedChanges ? (isSaving ? "Saving…" : "Save appearance and defaults") : "No unsaved changes")
                                .font(theme.typography.bodyEmphasized)
                            Text("Persist the curated setup for future launches.")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(AmbitionButtonStyle(tier: .hero, state: hasUnsavedChanges ? .selected : .default))
                .disabled(hasUnsavedChanges == false || isSaving)
                .accessibilityIdentifier("profile.save-preferences-button")
            }
        }
        .accessibilityIdentifier("profile.appearance-studio-card")
    }
}

private struct ProfileSelectableRow: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    let state: AmbitionVisualState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Circle()
                    .fill(state == .selected ? theme.colors.accentPrimary : theme.colors.surfaceOverlay)
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                if state == .selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(theme.colors.accentPrimary)
                }
            }
            .padding(theme.spacing.sm)
            .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
            .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct ProfileAccentTile: View {
    @Environment(\.ambitionTheme) private var theme

    let option: ProfileAccentOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let previewTheme = AmbitionTheme.theme(for: .dark, accentFamily: option.family)

        Button(action: action) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(previewTheme.surfaces.heroGradient)
                    .frame(height: 58)
                    .overlay(alignment: .bottomLeading) {
                        HStack(spacing: 6) {
                            Circle().fill(previewTheme.colors.accentPrimary).frame(width: 10, height: 10)
                            Circle().fill(previewTheme.colors.accentWarm).frame(width: 10, height: 10)
                            Circle().fill(previewTheme.colors.textPrimary.opacity(0.8)).frame(width: 10, height: 10)
                        }
                        .padding(10)
                    }

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack {
                        Text(option.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(theme.colors.accentPrimary)
                        }
                    }
                    Text(option.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(theme.spacing.sm)
            .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
            .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(isSelected ? theme.colors.accentPrimary.opacity(0.7) : theme.colors.strokeSubtle, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct ProfilePreviewSwatchCard: View {
    let swatch: ProfilePreviewSwatch
    let appearancePreference: AppAppearancePreference
    let accentFamily: AmbitionAccentFamily

    var body: some View {
        let selectedTheme = appearancePreference.resolveTheme(systemColorScheme: .dark, accentFamily: accentFamily)

        VStack(alignment: .leading, spacing: selectedTheme.spacing.xs) {
            Text(swatch.eyebrow)
                .font(selectedTheme.typography.micro)
                .foregroundStyle(selectedTheme.colors.accentWarm)
            Text(swatch.title)
                .font(selectedTheme.typography.bodyEmphasized)
                .foregroundStyle(selectedTheme.colors.textPrimary)
            Text(swatch.subtitle)
                .font(selectedTheme.typography.caption)
                .foregroundStyle(selectedTheme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            RoundedRectangle(cornerRadius: selectedTheme.radius.sm, style: .continuous)
                .fill(selectedTheme.colors.accentPrimary.opacity(0.8))
                .frame(height: 6)

            TagPill(
                appearancePreference.title,
                icon: "circle.lefthalf.filled",
                state: swatch.state
            )
        }
        .padding(selectedTheme.spacing.sm)
        .frame(maxWidth: .infinity, minHeight: 158, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: selectedTheme.radius.lg, style: .continuous)
                .fill(selectedTheme.surfaces.heroGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: selectedTheme.radius.lg, style: .continuous)
                .stroke(selectedTheme.colors.strokeSubtle, lineWidth: 1)
        )
    }
}

private struct ProfileTrustCenterCard: View {
    @Environment(\.ambitionTheme) private var theme

    let trustCenter: ProfileTrustCenterState
    let notificationActionTitle: String?
    let onEnableNotifications: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Trust",
                    title: trustCenter.title,
                    subtitle: trustCenter.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text(trustCenter.pulse.title)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(trustCenter.pulse.subtitle)
                        .font(theme.typography.titleCompact)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(trustCenter.pulse.detail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .padding(theme.spacing.md)
                .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(trustCenter.items) { item in
                        ProfileSettingRow(item: item)
                    }
                }

                if let notificationActionTitle {
                    Button(notificationActionTitle, action: onEnableNotifications)
                        .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: .default))
                        .accessibilityIdentifier("profile.enable-notifications-button")
                }

                Text(trustCenter.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("profile.trust-center-card")
    }
}

private struct ProfileContextVaultCard: View {
    @Environment(\.ambitionTheme) private var theme

    let contextVault: ProfileContextVaultState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Optional context",
                    title: contextVault.title,
                    subtitle: contextVault.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(contextVault.items) { item in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Image(systemName: item.icon)
                                .foregroundStyle(theme.colors.accentPrimary)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(item.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(item.subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                Text(item.detail)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }
                            Spacer()
                        }
                        .padding(theme.spacing.sm)
                        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(
                        title: "Signal policy",
                        subtitle: "Keep optional context understandable before later compliance work deepens the control layer."
                    )

                    ForEach(contextVault.policyItems) { item in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            TagPill(item.title, state: item.state)
                            Text(item.detail)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                    }
                }

                Text(contextVault.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("profile.context-vault-card")
    }
}

private struct ProfileDefaultsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let section: ProfileSectionGroup
    @Binding var preferredTab: AppTab
    @Binding var reviewCadenceDays: Int

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Defaults",
                    title: section.title,
                    subtitle: section.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(section.items) { item in
                        ProfileSettingRow(item: item)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                        Text("Default tab")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        Picker("Default tab", selection: $preferredTab) {
                            ForEach(AppTab.allCases) { tab in
                                Text(tab.title).tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("profile.default-tab-picker")
                    }
                    .accessibilityIdentifier("profile.default-tab-section")

                    VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                        Text("Review cadence")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        Picker("Review cadence", selection: $reviewCadenceDays) {
                            Text("Daily").tag(1)
                            Text("Every 3 days").tag(3)
                            Text("Weekly").tag(7)
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("profile.review-cadence-picker")
                    }
                    .accessibilityIdentifier("profile.review-cadence-section")
                }
            }
        }
        .accessibilityIdentifier("profile.defaults-card")
    }
}

private struct ProfileSectionCard: View {
    @Environment(\.ambitionTheme) private var theme

    let eyebrow: String
    let section: ProfileSectionGroup
    let accessibilityIdentifier: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(eyebrow: eyebrow, title: section.title, subtitle: section.subtitle)

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
                }
            }
        }
        .accessibilityIdentifier(accessibilityIdentifier)
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
