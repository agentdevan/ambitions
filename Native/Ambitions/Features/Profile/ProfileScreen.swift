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
                        .error(title: "You is unavailable", message: message, icon: "person.crop.circle.badge.exclamationmark", actionTitle: "Retry"),
                        actionAccessibilityIdentifier: "profile.retry-button"
                    ) {
                        Task { await refresh() }
                    }
                    .transition(.ambitionPanel)
                case let .loaded(dashboard):
                    ProfileHeroCard(hero: dashboard.hero)

                    ProfileSystemCenterCard(systemCenter: dashboard.systemCenter)

                    ProfileControlRoomCard(controlRoom: dashboard.controlRoom)

                    ProfileTrustCenterCard(
                        trustCenter: dashboard.trustCenter,
                        notificationActionTitle: dashboard.notificationAuthorization.actionTitle,
                        onEnableNotifications: requestNotificationAuthorization
                    )

                    ProfileConstitutionCard(constitution: dashboard.constitution)

                    ProfileMemoryControlsCard(memoryControls: dashboard.memoryControls)

                    ProfileSectionCard(
                        eyebrow: "Correction",
                        section: ProfileSectionGroup(
                            title: dashboard.assumptionCorrections.title,
                            subtitle: dashboard.assumptionCorrections.subtitle,
                            items: dashboard.assumptionCorrections.items,
                            footer: dashboard.assumptionCorrections.footer
                        ),
                        accessibilityIdentifier: "profile.corrections-card"
                    )

                    ProfileAutomationBoundaryCard(boundary: dashboard.automationBoundary)

                    ProfileSectionCard(
                        eyebrow: "Receipts",
                        section: ProfileSectionGroup(
                            title: dashboard.receiptAudit.title,
                            subtitle: dashboard.receiptAudit.subtitle,
                            items: dashboard.receiptAudit.items,
                            footer: dashboard.receiptAudit.footer
                        ),
                        accessibilityIdentifier: "profile.receipts-card"
                    )

                    ProfileReviewsCard(reviews: dashboard.reviews)

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
        .navigationTitle(showsNavigationChrome ? "You" : "")
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
                    Text("You / Trust")
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

                LazyVGrid(columns: [GridItem(.flexible())], spacing: theme.spacing.sm) {
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

private struct ProfileControlRoomCard: View {
    @Environment(\.ambitionTheme) private var theme

    let controlRoom: ProfileControlRoomState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Trust map",
                    title: controlRoom.title,
                    subtitle: controlRoom.subtitle
                )

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: theme.spacing.sm) {
                    ForEach(controlRoom.entries) { entry in
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            HStack(alignment: .top, spacing: theme.spacing.xs) {
                                Image(systemName: entry.icon)
                                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                                    .foregroundStyle(theme.colors.accentPrimary)
                                    .frame(width: 24)
                                Spacer()
                                TagPill(entry.statusLabel, state: entry.state)
                            }

                            Text(entry.title)
                                .font(theme.typography.section)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(entry.subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
                        .padding(theme.spacing.sm)
                        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
                    }
                }

                Text(controlRoom.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("profile.control-room-card")
        .ambitionPanelAccessibility()
    }
}

private struct ProfileSystemCenterCard: View {
    @Environment(\.ambitionTheme) private var theme

    let systemCenter: ProfileSystemCenterState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "You",
                    title: systemCenter.title,
                    subtitle: systemCenter.subtitle
                )

                GroupedNavigationList {
                    ForEach(systemCenter.sections) { section in
                        GroupedNavigationSection(title: section.title, footer: section.footer) {
                            ForEach(section.items) { item in
                                GroupedNavigationRow(
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    systemImage: item.icon,
                                    badge: GroupedNavigationBadge(item.statusLabel, state: item.semanticState),
                                    accessibilityLabel: item.title,
                                    accessibilityValue: item.statusLabel,
                                    accessibilityHint: item.accessibilityHint,
                                    action: {}
                                )
                            }
                        }
                    }
                }

                Text(systemCenter.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("profile.system-center-card")
        .ambitionPanelAccessibility(
            label: systemCenter.title,
            value: "\(systemCenter.sections.flatMap(\.items).count) grouped areas",
            hint: "Personal System Center categories for You."
        )
    }
}

private struct ProfileConstitutionCard: View {
    @Environment(\.ambitionTheme) private var theme

    let constitution: ProfileConstitutionState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Constitution",
                    title: constitution.title,
                    subtitle: constitution.subtitle
                )

                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.colors.accentPrimary)
                    Text(constitution.postureSummary)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(theme.spacing.md)
                .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(constitution.rules) { rule in
                        ProfileRuleRow(rule: rule)
                    }
                }

                Text(constitution.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("profile.constitution-card")
        .ambitionPanelAccessibility()
    }
}

private struct ProfileMemoryControlsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let memoryControls: ProfileMemoryControlState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Memory",
                    title: memoryControls.title,
                    subtitle: memoryControls.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(memoryControls.items) { item in
                        ProfileSettingRow(item: item)
                    }
                }

                ForEach(memoryControls.groups) { group in
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "What this uses",
                            title: group.title,
                            subtitle: group.subtitle
                        )

                        ForEach(group.items) { item in
                            ProfileMemoryItemRow(item: item)
                        }

                        if let footer = group.footer {
                            Text(footer)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textTertiary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                Text(memoryControls.recoverySummary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(memoryControls.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("profile.memory-controls-card")
        .ambitionPanelAccessibility(
            label: memoryControls.title,
            value: "Local memory groups, freshness labels, and safe correction controls.",
            hint: "Review what Ambitions stores and how it can be corrected."
        )
    }
}

private struct ProfileMemoryItemRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: ProfileMemoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.detail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(item.usedFor)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
            }

            HStack(spacing: theme.spacing.xs) {
                TagPill(item.freshness.label, state: item.freshness.visualState)
                TagPill(item.sourceLabel, state: .default)
                TagPill(item.privacyLabel, state: .default)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(item.actions) { action in
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        TagPill(action.title, state: action.state)
                        Text(action.statusLabel)
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textSecondary)
                        Text(action.detail)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: item.accessibilityLabel,
            value: item.accessibilityValue,
            hint: item.accessibilityHint
        )
    }
}

private struct ProfileAutomationBoundaryCard: View {
    @Environment(\.ambitionTheme) private var theme

    let boundary: ProfileAutomationBoundaryState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Boundaries",
                    title: boundary.title,
                    subtitle: boundary.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(boundary.rules) { rule in
                        ProfileRuleRow(rule: rule)
                    }
                }

                Text(boundary.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("profile.automation-boundary-card")
        .ambitionPanelAccessibility()
    }
}

private struct ProfileReviewsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let reviews: ProfileReviewsState

    var body: some View {
        let projection = reviews.projection

        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Reviews",
                    title: reviews.title,
                    subtitle: reviews.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        Image(systemName: "rectangle.stack.badge.play")
                            .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(theme.colors.accentPrimary)
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(projection.period.timeframeLabel)
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.accentWarm)
                            Text(projection.period.title)
                                .font(theme.typography.titleCompact)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(projection.period.dominantTruth)
                                .font(theme.typography.body)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        TagPill(projection.lifeOSReceipt.statusLabel, state: projection.period.state)
                    }
                    .padding(theme.spacing.md)
                    .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                    .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))

                    Text(projection.period.trustWhisper)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ProfileReviewCluster(
                    title: projection.recovery.title,
                    subtitle: projection.recovery.subtitle,
                    emptyTitle: projection.recovery.emptyStateTitle,
                    emptyDetail: projection.recovery.emptyStateDetail,
                    items: Array((projection.recovery.whatRecovered + projection.recovery.whatWasProtected + projection.recovery.needsReview).prefix(4))
                )

                ProfileReviewCluster(
                    title: projection.lifeOSReceipt.title,
                    subtitle: projection.lifeOSReceipt.subtitle,
                    emptyTitle: projection.lifeOSReceipt.emptyStateTitle,
                    emptyDetail: projection.lifeOSReceipt.emptyStateDetail,
                    items: Array((projection.lifeOSReceipt.receiptHighlights + projection.lifeOSReceipt.meaningfulEvents).prefix(4))
                )

                if projection.proofHighlights.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(title: "Proof highlights", subtitle: "Recent evidence that can make the next review more grounded.")
                        ForEach(projection.proofHighlights) { proof in
                            ProfileReviewProofRow(proof: proof)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(title: "Carry forward", subtitle: "The smallest useful thing to keep visible after this review.")
                    ForEach(projection.carryForward) { item in
                        ProfileCarryForwardRow(item: item)
                    }
                }

                if projection.correctionPrompts.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(title: "Corrections", subtitle: "Existing correction paths stay user-directed.")
                        ForEach(projection.correctionPrompts.prefix(2)) { prompt in
                            ProfileCorrectionPromptRow(prompt: prompt)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(title: "Unavailable here", subtitle: "Trust notes for what this review does not claim.")
                    ForEach(projection.unavailableNotes.prefix(3)) { note in
                        ProfileReviewSignalRow(item: note)
                    }
                }

                Text(reviews.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("profile.reviews-card")
        .ambitionPanelAccessibility()
    }
}

private struct ProfileReviewCluster: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    let emptyTitle: String
    let emptyDetail: String
    let items: [ReviewSignalItem]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(title: title, subtitle: subtitle)

            if items.isEmpty {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    TagPill("Available after more activity", icon: "clock", state: .default)
                    Text(emptyTitle)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(emptyDetail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(theme.spacing.md)
                .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
            } else {
                ForEach(items) { item in
                    ProfileReviewSignalRow(item: item)
                }
            }
        }
    }
}

private struct ProfileReviewSignalRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: ReviewSignalItem

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: item.icon)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentPrimary)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(item.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(item.detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: theme.spacing.sm)
            TagPill(item.valueLabel, state: item.state)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}

private struct ProfileReviewProofRow: View {
    @Environment(\.ambitionTheme) private var theme

    let proof: ReviewProofHighlight

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentPrimary)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(proof.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(proof.detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            TagPill(proof.valueLabel, state: proof.state)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}

private struct ProfileCarryForwardRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: ReviewCarryForwardItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            TagPill(item.actionLabel, icon: "arrow.forward", state: item.state)
            Text(item.title)
                .font(theme.typography.section)
                .foregroundStyle(theme.colors.textPrimary)
            Text(item.detail)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}

private struct ProfileCorrectionPromptRow: View {
    @Environment(\.ambitionTheme) private var theme

    let prompt: ReviewCorrectionPrompt

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "checkmark.bubble")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentPrimary)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(prompt.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(prompt.detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            TagPill(prompt.actionLabel, state: prompt.state)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}

private struct ProfileRuleRow: View {
    @Environment(\.ambitionTheme) private var theme

    let rule: ProfileConstitutionRule

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            TagPill(rule.statusLabel, state: rule.state)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(rule.title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(rule.detail)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
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

                GroupedNavigationList {
                    ForEach(trustCenter.sections) { section in
                        GroupedNavigationSection(title: section.title, footer: section.footer) {
                            ForEach(section.routes) { route in
                                GroupedNavigationRow(
                                    title: route.title,
                                    subtitle: route.subtitle,
                                    systemImage: route.icon,
                                    badge: GroupedNavigationBadge(route.statusLabel, state: route.semanticState),
                                    accessibilityLabel: route.title,
                                    accessibilityValue: route.statusLabel,
                                    accessibilityHint: route.accessibilityHint,
                                    action: {}
                                )
                            }
                        }
                    }
                }

                if trustCenter.receiptSummaries.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Receipts",
                            title: "Recent trust receipts",
                            subtitle: "Privacy-safe summaries of what changed, why, and whether correction or undo is available."
                        )

                        ForEach(trustCenter.receiptSummaries) { receipt in
                            ProfileTrustReceiptRow(receipt: receipt)
                        }
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

private struct ProfileTrustReceiptRow: View {
    @Environment(\.ambitionTheme) private var theme

    let receipt: ActionReceiptDisplaySummary

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: iconName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(receipt.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(receipt.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let nextActionTitle = receipt.nextActionTitle {
                        Text(nextActionTitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: theme.spacing.sm)
            }

            HStack(spacing: theme.spacing.xs) {
                TagPill(resultLabel, state: resultState)
                TagPill(undoLabel, state: undoState)
                TagPill(correctionLabel, state: correctionState)
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: receipt.title,
            value: "\(resultLabel). \(undoLabel). \(correctionLabel).",
            hint: "Receipt summary. Sensitive detail is not expanded here."
        )
    }

    private var iconName: String {
        switch receipt.safetyState {
        case .safeFailure, .externalUnavailable, .confirmationRequired:
            return "exclamationmark.shield"
        case .normal, .degraded:
            return "doc.text.magnifyingglass"
        }
    }

    private var resultLabel: String {
        switch receipt.resultState {
        case .created: "Created"
        case .changed: "Changed"
        case .scheduled: "Scheduled"
        case .moved: "Moved"
        case .attached: "Attached"
        case .detached: "Detached"
        case .exportedPrepared: "Export prepared"
        case .draftedPrepared: "Draft prepared"
        case .completed: "Completed"
        case .failedSafely: "Safe failure"
        case .needsConfirmation: "Needs confirmation"
        case .noOp: "No change"
        case .undoAvailable: "Undo available"
        case .undoUnavailable: "Undo unavailable"
        case .correctionAvailable: "Correction available"
        }
    }

    private var resultState: AmbitionVisualState {
        switch receipt.safetyState {
        case .safeFailure, .externalUnavailable, .confirmationRequired:
            return .warning
        case .normal, .degraded:
            return .default
        }
    }

    private var undoLabel: String {
        receipt.undoAvailability.isAvailable ? "Undo available" : "Undo not available"
    }

    private var undoState: AmbitionVisualState {
        receipt.undoAvailability.isAvailable ? .success : .default
    }

    private var correctionLabel: String {
        receipt.correctionAvailability.isAvailable ? "Correction available" : "Correction unavailable"
    }

    private var correctionState: AmbitionVisualState {
        receipt.correctionAvailability.isAvailable ? .success : .default
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
#Preview("You Light") {
    NavigationStack {
        ProfileScreen(viewModel: ProfileViewModel(state: .loaded(PreviewFixtures.default.profileDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

#Preview("You Dark") {
    NavigationStack {
        ProfileScreen(viewModel: ProfileViewModel(state: .loaded(PreviewFixtures.default.profileDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}
#endif
