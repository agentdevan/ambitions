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
    @State private var activeDetail: ProfileRootDetail?
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
                    ProfileSettingsRootView(
                        dashboard: dashboard,
                        onOpenDetail: { activeDetail = $0 }
                    )
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .background {
            LivingSurfaceBackground(context: .you, state: .calm, intensity: 0.68)
                .ignoresSafeArea()
        }
        .navigationTitle(showsNavigationChrome ? "You" : "")
        .refreshable {
            await refresh()
        }
        .accessibilityIdentifier("profile.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .sheet(item: $activeDetail) { detail in
            ProfileRootDetailSheet(
                detail: detail,
                dashboard: viewModel.loadedDashboard,
                appearancePreference: $viewModel.appearancePreference,
                accentFamily: $viewModel.accentFamily,
                preferredTab: $viewModel.preferredTab,
                reviewCadenceDays: $viewModel.reviewCadenceDays,
                isSaving: viewModel.isSaving,
                hasUnsavedChanges: viewModel.hasUnsavedChanges,
                onSavePreferences: savePreferences,
                onEnableNotifications: requestNotificationAuthorization,
                notificationPermissionState: viewModel.loadedDashboard.flatMap(notificationPermissionState),
                onOpenSystemSettings: openSystemSettingsIfAvailable
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
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

private struct ProfileRootDetailSheet: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    let detail: ProfileRootDetail
    let dashboard: ProfileDashboard?
    @Binding var appearancePreference: AppAppearancePreference
    @Binding var accentFamily: AmbitionAccentFamily
    @Binding var preferredTab: AppTab
    @Binding var reviewCadenceDays: Int
    let isSaving: Bool
    let hasUnsavedChanges: Bool
    let onSavePreferences: () -> Void
    let onEnableNotifications: () -> Void
    let notificationPermissionState: DegradedStatePresentation?
    let onOpenSystemSettings: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                    if let dashboard {
                        detailContent(for: dashboard)
                    } else {
                        AsyncStateCard(.loading(lines: 6))
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.md)
            }
            .scrollIndicators(.hidden)
            .navigationTitle(detail.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func detailContent(for dashboard: ProfileDashboard) -> some View {
        switch detail {
        case .profile:
            ProfileDefaultsCard(
                section: dashboard.defaultsSection,
                preferredTab: $preferredTab,
                reviewCadenceDays: $reviewCadenceDays
            )
            ProfileSectionCard(eyebrow: "About you", section: dashboard.accountSection, accessibilityIdentifier: "profile.account-card")
        case .personalization:
            ProfileConstitutionCard(constitution: dashboard.constitution)
        case .appearance:
            ProfileAppearanceStudioCard(
                studio: dashboard.appearanceStudio,
                appearancePreference: $appearancePreference,
                accentFamily: $accentFamily,
                isSaving: isSaving,
                hasUnsavedChanges: hasUnsavedChanges,
                onSave: onSavePreferences
            )
        case .whatAmbitionsKnows:
            ProfileMemoryControlsCard(memoryControls: dashboard.memoryControls)
            ProfileContextVaultCard(contextVault: dashboard.contextVault)
        case .trustCenter:
            ProfileTrustCenterCard(
                trustCenter: dashboard.trustCenter,
                notificationActionTitle: dashboard.notificationAuthorization.actionTitle,
                onEnableNotifications: onEnableNotifications
            )
            ProfileAutomationBoundaryCard(boundary: dashboard.automationBoundary)
        case .receiptsHistory:
            ProfileCrossSurfaceProofReviewCard(state: dashboard.crossSurfaceProofReview)
            ProfileTrustHistoryCenterCard(history: dashboard.trustHistoryCenter)
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
        case .corrections:
            ProfileSectionCard(
                eyebrow: "Corrections",
                section: ProfileSectionGroup(
                    title: dashboard.assumptionCorrections.title,
                    subtitle: dashboard.assumptionCorrections.subtitle,
                    items: dashboard.assumptionCorrections.items,
                    footer: dashboard.assumptionCorrections.footer
                ),
                accessibilityIdentifier: "profile.corrections-card"
            )
        case .reviews:
            ProfileReviewsCard(reviews: dashboard.reviews)
        case .proof:
            ProfileSectionCard(
                eyebrow: "Proof",
                section: ProfileSectionGroup(
                    title: "Proof",
                    subtitle: "Progress evidence stays local and feeds reviews.",
                    items: dashboard.reviews.projection.progressLines.map {
                        SettingsItem(id: "proof-\($0.id)", title: $0.title, subtitle: $0.detail, icon: "checkmark.seal", valueLabel: $0.sourceLabel)
                    },
                    footer: "Proof remains reviewable before it is reused."
                ),
                accessibilityIdentifier: "profile.proof-card"
            )
        case .archive:
            ProfileSectionCard(eyebrow: "Archive", section: dashboard.accountSection, accessibilityIdentifier: "profile.archive-card")
        case .scheduleAvailability:
            ProfileAvailabilityCenterCard(center: dashboard.availabilityCenter)
            if let section = dashboard.planningDefaultsCenter.section(id: "schedule-availability") {
                ProfilePlanningDefaultsSectionCard(section: section, accessibilityIdentifier: "profile.schedule-availability-card")
            }
        case .planBehavior:
            if let section = dashboard.planningDefaultsCenter.section(id: "planning-defaults") {
                ProfilePlanningDefaultsSectionCard(section: section, accessibilityIdentifier: "profile.plan-behavior-card")
            }
        case .automationTrust:
            if let section = dashboard.planningDefaultsCenter.section(id: "automation-trust") {
                ProfilePlanningDefaultsSectionCard(section: section, accessibilityIdentifier: "profile.automation-trust-card")
            }
        case .vacationAwayTime:
            if let section = dashboard.planningDefaultsCenter.section(id: "vacation-away-time") {
                ProfilePlanningDefaultsSectionCard(section: section, accessibilityIdentifier: "profile.vacation-away-card")
            }
        case .durations:
            ProfileSectionCard(
                eyebrow: "Planning Behavior",
                section: ProfileSectionGroup(
                    title: "Durations",
                    subtitle: "Guessed durations are never presented as fact.",
                    items: DurationSource.allCases.map {
                        SettingsItem(id: "duration-\($0.rawValue)", title: durationTitle(for: $0), subtitle: durationSubtitle(for: $0), icon: "timer", valueLabel: nil)
                    },
                    footer: "Examples: 30 min planned, Suggested: 15-20 min, Usually 10-30 min, Duration not set."
                ),
                accessibilityIdentifier: "profile.durations-card"
            )
        case .notifications:
            if let notificationPermissionState {
                DegradedStateCard(
                    state: notificationPermissionState,
                    primaryAccessibilityIdentifier: "profile.notification-permission.primary",
                    secondaryAccessibilityIdentifier: "profile.notification-permission.secondary",
                    onPrimaryAction: onEnableNotifications,
                    onSecondaryAction: onOpenSystemSettings
                )
            }
            ProfileSectionCard(eyebrow: "Notifications", section: dashboard.integrationsSection, accessibilityIdentifier: "profile.notifications-card")
        case .integrations, .widgets, .exportImport:
            ProfileSectionCard(eyebrow: "System configuration", section: dashboard.integrationsSection, accessibilityIdentifier: "profile.integrations-card")
        case .accessibility:
            ProfileSectionCard(
                eyebrow: "Accessibility",
                section: ProfileSectionGroup(
                    title: "Accessibility",
                    subtitle: "Claims stay locked until manual verification is recorded.",
                    items: dashboard.trustCenter.items.filter { $0.title.localizedCaseInsensitiveContains("Accessibility") },
                    footer: "This is an internal evidence status, not a public accessibility claim."
                ),
                accessibilityIdentifier: "profile.accessibility-card"
            )
        case .support:
            ProfileSectionCard(eyebrow: "Help", section: dashboard.accountSection, accessibilityIdentifier: "profile.support-card")
        case .about:
            ProfileSectionCard(eyebrow: "About", section: dashboard.accountSection, accessibilityIdentifier: "profile.about-card")
        }
    }

    private func vacationAvailabilitySubtitle(for behavior: VacationAvailabilityBehavior) -> String {
        switch behavior {
        case .unavailable: "Ambitions keeps this time out of planning unless you mark part of it open."
        case .protected: "Ambitions preserves the time and stays light."
        case .flexible: "Ambitions may suggest light use after you confirm it."
        case .open: "Ambitions may treat selected time as usable for planning."
        }
    }

    private func durationTitle(for source: DurationSource) -> String {
        switch source {
        case .userSet: "User-set"
        case .userAccepted: "Accepted suggestion"
        case .suggested: "Suggested"
        case .historical: "Historical range"
        case .unset: "Unset"
        case .actual: "Actual"
        }
    }

    private func durationSubtitle(for source: DurationSource) -> String {
        switch source {
        case .userSet: "Shown as planned because you set it."
        case .userAccepted: "Shown as planned after you accept it."
        case .suggested: "Always labeled as suggested."
        case .historical: "Always labeled as usually."
        case .unset: "Shown as Duration not set."
        case .actual: "Shown only after completion evidence exists."
        }
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
            hint: "Categories for You."
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

                ContextRecallCard(
                    title: "What Ambitions remembers",
                    summary: memoryControls.recoverySummary,
                    sourceLabel: "Source: local receipts, corrections, reviews, and explicit profile context",
                    confidenceLabel: primaryRecallState == .current ? "Confidence: reviewable" : "Confidence: needs review",
                    state: primaryRecallState,
                    context: .memory,
                    controls: memoryControls.items.prefix(3).map(\.title)
                )
                .accessibilityIdentifier("profile.context-recall-card")

                MemoryConstellation(
                    title: "Visible memory states",
                    subtitle: "A bounded map of current, stale, sensitive, corrected, and empty states. It is not a hidden inference graph.",
                    nodes: constellationNodes
                )
                .accessibilityIdentifier("profile.memory-constellation")

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(memoryControls.items) { item in
                        ProfileSettingRow(item: item)
                    }
                }

                ProfilePersonalizationConsentPanel(consent: memoryControls.consent)

                if memoryControls.privateModeControls.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Private mode",
                            title: "Sensitive areas",
                            subtitle: "Private context stays summarized, approval-gated, or blocked until a safe owner proves more."
                        )

                        ForEach(memoryControls.privateModeControls) { control in
                            ProfilePrivateModeControlRow(control: control)
                        }
                    }
                    .accessibilityIdentifier("profile.private-mode-controls")
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

                if memoryControls.narrativeMemories.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Narrative memory",
                            title: "Reviewable stories",
                            subtitle: "Only explicit local evidence, receipts, corrections, reviews, or confirmations can shape these."
                        )

                        ForEach(memoryControls.narrativeMemories) { memory in
                            ProfileNarrativeMemoryRow(memory: memory)
                        }
                    }
                    .accessibilityIdentifier("profile.narrative-memory-section")
                }

                if memoryControls.conservativePatterns.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Pattern review",
                            title: "Conservative signals",
                            subtitle: "Patterns stay reviewable and never become automatic certainty."
                        )

                        ForEach(memoryControls.conservativePatterns) { pattern in
                            ProfileMemoryPatternRow(pattern: pattern)
                        }
                    }
                    .accessibilityIdentifier("profile.memory-pattern-section")
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

    private var primaryRecallState: ContextRecallState {
        let freshness = memoryControls.groups.flatMap(\.items).map(\.freshness)

        if freshness.contains(.mayNeedReview) {
            return .stale
        }

        if memoryControls.narrativeMemories.contains(where: { $0.sensitiveStatusLabel.localizedCaseInsensitiveContains("sensitive") }) {
            return .sensitive
        }

        if memoryControls.conservativePatterns.contains(where: { $0.reviewLabel.localizedCaseInsensitiveContains("correct") }) {
            return .corrected
        }

        return freshness.isEmpty ? .noResult : .current
    }

    private var constellationNodes: [MemoryConstellationNode] {
        let memoryNodes = memoryControls.groups
            .flatMap(\.items)
            .prefix(3)
            .map { item in
                MemoryConstellationNode(
                    id: item.id,
                    title: item.title,
                    detail: item.sourceLabel,
                    state: item.freshness.contextRecallState
                )
            }

        let narrativeNodes = memoryControls.narrativeMemories
            .prefix(1)
            .map { memory in
                MemoryConstellationNode(
                    id: memory.id,
                    title: memory.title,
                    detail: memory.sensitiveStatusLabel,
                    state: memory.sensitiveStatusLabel.localizedCaseInsensitiveContains("sensitive") ? .sensitive : memory.freshness.contextRecallState
                )
            }

        let nodes = Array(memoryNodes + narrativeNodes)

        if nodes.isEmpty {
            return [
                MemoryConstellationNode(
                    id: "memory-no-result",
                    title: "No hidden memory",
                    detail: "Nothing inferred",
                    state: .noResult
                )
            ]
        }

        return nodes
    }
}

private extension ProfileMemoryFreshness {
    var contextRecallState: ContextRecallState {
        switch self {
        case .current:
            return .current
        case .mayNeedReview:
            return .stale
        case .basedOnOlderContext:
            return .corrected
        }
    }
}

private struct ProfilePersonalizationConsentPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let consent: ProfilePersonalizationConsentState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(
                eyebrow: "Consent",
                title: consent.title,
                subtitle: consent.summary
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.xs) {
                    TagPill(consent.sourceLabel, icon: "internaldrive", state: .default)
                    TagPill(consent.sensitiveMemoryLabel, icon: "hand.raised", state: .warning)
                    TagPill(consent.hiddenMemoryLabel, icon: "eye.slash", state: .selected)
                    TagPill(consent.controlLabel, icon: "person.crop.circle", state: .success)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("profile.personalization-consent")
        .accessibilityLabel("\(consent.title). \(consent.summary). \(consent.controlLabel).")
    }
}

private struct ProfilePrivateModeControlRow: View {
    @Environment(\.ambitionTheme) private var theme

    let control: ProfilePrivateModeControl

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text(control.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)

                Spacer(minLength: theme.spacing.sm)

                TagPill(control.statusLabel, state: control.state)
            }

            Text(control.summary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: theme.spacing.xs) {
                TagPill(control.privacyLabel, icon: "lock.shield", state: .default)
                TagPill(control.controlLabel, icon: "hand.tap", state: control.state)
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(control.title)
        .accessibilityValue("\(control.statusLabel). \(control.privacyLabel). \(control.controlLabel). \(control.summary)")
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

private struct ProfileNarrativeMemoryRow: View {
    @Environment(\.ambitionTheme) private var theme

    let memory: ProfileNarrativeMemory

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "text.book.closed")
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(memory.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(memory.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(memory.usedFor)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                TagPill(memory.freshness.label, state: memory.freshness.visualState)
                TagPill(memory.sourceLabel, state: .default)
                TagPill(memory.sensitiveStatusLabel, state: .default)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(memory.actions) { action in
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
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
            label: memory.accessibilityLabel,
            value: memory.accessibilityValue,
            hint: memory.accessibilityHint
        )
    }
}

private struct ProfileMemoryPatternRow: View {
    @Environment(\.ambitionTheme) private var theme

    let pattern: ProfileMemoryPattern

    var body: some View {
        WidgetCard(state: pattern.state) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(pattern.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Spacer()
                    TagPill(pattern.reviewLabel, state: pattern.state)
                }
                Text(pattern.summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(pattern.sourceLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
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

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(title: "Review rhythms", subtitle: "Weekly, monthly, and recovery reviews stay under You, Plan, and Goal context.")
                    ForEach(projection.cadences) { cadence in
                        ProfileReviewCadenceRow(cadence: cadence)
                    }
                }
                .accessibilityIdentifier("profile.review-cadences-section")

                if projection.progressLines.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(title: "Progress receipt", subtitle: "A plain record of what changed, what has proof, and what should carry forward.")
                        ForEach(projection.progressLines) { line in
                            ProfileProgressReceiptLineRow(line: line)
                        }
                    }
                    .accessibilityIdentifier("profile.progress-receipt-section")
                }

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

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(title: "Planning handoff", subtitle: "Review can suggest where to go next, but it does not change the plan silently.")
                    ForEach(projection.planningHandoffs) { handoff in
                        ProfilePlanningHandoffRow(handoff: handoff)
                    }
                }
                .accessibilityIdentifier("profile.review-planning-handoff-section")

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

private struct ProfileReviewCadenceRow: View {
    @Environment(\.ambitionTheme) private var theme

    let cadence: ReviewCadenceSummary

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: cadenceIcon)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentPrimary)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(cadence.contextLabel)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.accentWarm)
                Text(cadence.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(cadence.detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: theme.spacing.sm)
            TagPill(cadence.statusLabel, state: cadence.state)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(cadence.title)
        .accessibilityValue("\(cadence.contextLabel). \(cadence.statusLabel).")
        .accessibilityHint(cadence.detail)
    }

    private var cadenceIcon: String {
        switch cadence.cadence {
        case .weekly:
            return "calendar"
        case .monthly:
            return "calendar.badge.clock"
        case .recovery:
            return "lifepreserver"
        }
    }
}

private struct ProfileProgressReceiptLineRow: View {
    @Environment(\.ambitionTheme) private var theme

    let line: LifeOSReceiptProgressLine

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(line.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(line.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: theme.spacing.sm)
                TagPill(line.sourceLabel, state: line.state)
            }

            TagPill(line.privacyLabel, icon: "lock.shield", state: .default)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(line.title)
        .accessibilityValue("\(line.sourceLabel). \(line.privacyLabel).")
        .accessibilityHint(line.detail)
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

private struct ProfilePlanningHandoffRow: View {
    @Environment(\.ambitionTheme) private var theme

    let handoff: ReviewPlanningHandoff

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "arrowshape.turn.up.right")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(handoff.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(handoff.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: theme.spacing.sm)
                TagPill(handoff.destinationLabel, state: handoff.state)
            }

            TagPill(handoff.safetyLabel, icon: "hand.raised", state: handoff.state)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(handoff.title)
        .accessibilityValue("\(handoff.destinationLabel). \(handoff.safetyLabel).")
        .accessibilityHint(handoff.detail)
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

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(
                        eyebrow: "Data map",
                        title: "What this surface can explain",
                        subtitle: "A compact inventory of local context, permissions, receipts, and future-owned edges."
                    )

                    ForEach(trustCenter.dataMap) { item in
                        ProfileTrustDataMapRow(item: item)
                    }
                }
                .accessibilityIdentifier("profile.trust-data-map")

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

                TrustReceiptStack(
                    title: "Recent trust receipts",
                    subtitle: "Privacy-safe summaries of what changed, why, and whether correction or undo is available.",
                    items: trustReceiptStackItems
                )

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

    private var trustReceiptStackItems: [TrustReceiptStackItem] {
        trustCenter.receiptSummaries.map { receipt in
            TrustReceiptStackItem(
                id: receipt.id,
                title: receipt.title,
                summary: receipt.summary,
                sourceLabel: receipt.sourceDomain.trustReceiptSourceLabel,
                freshnessLabel: receipt.safetyState.trustReceiptFreshnessLabel,
                undoLabel: receipt.undoAvailability.trustReceiptUndoLabel,
                correctionLabel: receipt.correctionAvailability.trustReceiptCorrectionLabel,
                nextActionLabel: receipt.nextActionTitle,
                state: receipt.trustReceiptVisualState
            )
        }
    }
}

private struct ProfileTrustDataMapRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: ProfileTrustDataMapItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text(item.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)

                Spacer(minLength: theme.spacing.sm)

                Text(item.statusLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xxxs)
                    .background(Capsule().fill(theme.colors.surfaceOverlay))
            }

            Text(item.dataTypes)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(item.sourceLabel) · \(item.controlLabel) · \(item.privacyLabel)")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityValue("\(item.statusLabel). \(item.dataTypes). \(item.sourceLabel). \(item.controlLabel). \(item.privacyLabel).")
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
        case .moved: "Rescheduled"
        case .attached: "Attached"
        case .detached: "Detached"
        case .exportedPrepared: "Export prepared"
        case .draftedPrepared: "Draft prepared"
        case .completed: "Completed"
        case .failedSafely: "Safely blocked"
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

private extension ActionReceiptDisplaySummary {
    var trustReceiptVisualState: TrustReceiptVisualState {
        if safetyState == .safeFailure || safetyState == .externalUnavailable || safetyState == .confirmationRequired {
            return .blocked
        }

        if correctionAvailability.isAvailable {
            return .correction
        }

        if undoAvailability.isAvailable {
            return .undo
        }

        switch resultState {
        case .completed, .created, .changed, .attached, .scheduled:
            return .proofSaved
        case .failedSafely, .needsConfirmation:
            return .blocked
        case .undoAvailable:
            return .undo
        case .correctionAvailable:
            return .correction
        case .undoUnavailable, .noOp, .moved, .detached, .exportedPrepared, .draftedPrepared:
            return .staleSource
        }
    }
}

private extension ActionReceiptSourceDomain {
    var trustReceiptSourceLabel: String {
        switch self {
        case .today: "Source: Today"
        case .goals: "Source: Goals"
        case .capture: "Source: Capture"
        case .plan: "Source: Plan"
        case .you: "Source: You"
        case .reviews: "Source: Reviews"
        case .goalDetail: "Source: Goal Detail"
        case .commandPipeline: "Source: Command"
        case .eventLedger: "Source: Event Ledger"
        case .proof: "Source: Proof"
        case .resource: "Source: Resource"
        case .commitment: "Source: Commitment"
        case .calendar: "Source: Calendar boundary"
        case .exportImport: "Source: Export / import boundary"
        case .externalSurface: "Source: External surface"
        case .system: "Source: System"
        }
    }
}

private extension ActionReceiptSafetyState {
    var trustReceiptFreshnessLabel: String {
        switch self {
        case .normal: "Freshness: current local receipt"
        case .degraded: "Freshness: degraded source"
        case .safeFailure: "Freshness: blocked safely"
        case .externalUnavailable: "Freshness: external source unavailable"
        case .confirmationRequired: "Freshness: waiting for confirmation"
        }
    }
}

private extension ActionReceiptUndoAvailability {
    var trustReceiptUndoLabel: String {
        switch self {
        case .availableLocal: "Undo available locally"
        case .requiresConfirmation: "Undo requires confirmation"
        case .unavailable: "Undo unavailable"
        case .unsafe: "Undo blocked as unsafe"
        case .notSupportedYet: "Undo not supported yet"
        }
    }
}

private extension ActionReceiptCorrectionAvailability {
    var trustReceiptCorrectionLabel: String {
        switch self {
        case .available: "Correction available"
        case .availableWithReason: "Correction available with reason"
        case .unavailable: "Correction unavailable"
        case .notSupportedYet: "Correction not supported yet"
        }
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

#Preview("You System Center Setup Incomplete") {
    NavigationStack {
        ProfileScreen(viewModel: ProfileViewModel(state: .loaded(PreviewFixtures.default.profileDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Trust Privacy Focused") {
    NavigationStack {
        ProfileScreen(viewModel: ProfileViewModel(state: .loaded(PreviewFixtures.default.profileDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You High Dynamic Type") {
    NavigationStack {
        ProfileScreen(viewModel: ProfileViewModel(state: .loaded(PreviewFixtures.default.profileDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("You Reduce Motion") {
    NavigationStack {
        ProfileScreen(viewModel: ProfileViewModel(state: .loaded(PreviewFixtures.default.profileDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Minimal State") {
    NavigationStack {
        ProfileScreen(viewModel: ProfileViewModel(state: .loaded(PreviewFixtures.default.profileDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Memory Stale") {
    ScrollView {
        ContextRecallCard(
            title: "Availability pattern may need review",
            summary: "This recall is old enough that Ambitions should ask before using it to shape planning.",
            sourceLabel: "Source: older local review",
            confidenceLabel: "Confidence: needs review",
            state: .stale,
            controls: ["Review", "Correct", "Ignore"]
        )
        .padding()
    }
    .background(LivingSurfaceBackground(context: .memory, state: .stale).ignoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Memory Rejected") {
    ScrollView {
        ContextRecallCard(
            title: "Rejected assumption",
            summary: "The user rejected this signal, so it remains visible only as correction history.",
            sourceLabel: "Source: correction receipt",
            confidenceLabel: "Confidence: not active",
            state: .rejected,
            controls: ["View receipt"]
        )
        .padding()
    }
    .background(LivingSurfaceBackground(context: .memory, state: .recovery).ignoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Memory Private") {
    ScrollView {
        ContextRecallCard(
            title: "Sensitive context is protected",
            summary: "This context requires explicit review before it appears in planning guidance.",
            sourceLabel: "Source: private profile context",
            confidenceLabel: "Confidence: protected",
            state: .sensitive,
            controls: ["Review privacy", "Keep hidden"]
        )
        .padding()
    }
    .background(LivingSurfaceBackground(context: .memory, state: .sensitive).ignoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Memory Corrected") {
    ScrollView {
        ContextRecallCard(
            title: "Planning default corrected",
            summary: "The corrected version is the only active version used for future recall surfaces.",
            sourceLabel: "Source: explicit correction",
            confidenceLabel: "Confidence: user-confirmed",
            state: .corrected,
            controls: ["View correction"]
        )
        .padding()
    }
    .background(LivingSurfaceBackground(context: .memory, state: .proof).ignoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Memory No Result") {
    ScrollView {
        ContextRecallCard(
            title: "No hidden memory",
            summary: "Ambitions has no recall result for this context and should say so plainly.",
            sourceLabel: "Source: none",
            confidenceLabel: "Confidence: no result",
            state: .noResult,
            controls: []
        )
        .padding()
    }
    .background(LivingSurfaceBackground(context: .memory, state: .empty).ignoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Trust Receipts Empty") {
    ScrollView {
        TrustReceiptStack(items: [])
            .padding()
    }
    .background(LivingSurfaceBackground(context: .trust, state: .empty).ignoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Trust Proof Saved") {
    ScrollView {
        TrustReceiptStack(items: [
            TrustReceiptStackItem(
                id: "preview-proof-saved",
                title: "Proof saved",
                summary: "A completed step produced local proof and a visible receipt.",
                sourceLabel: "Source: Today",
                freshnessLabel: "Freshness: current local receipt",
                undoLabel: "Undo available locally",
                correctionLabel: "Correction available",
                nextActionLabel: "Review proof",
                state: .proofSaved
            )
        ])
        .padding()
    }
    .background(LivingSurfaceBackground(context: .trust, state: .proof).ignoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Trust Correction") {
    ScrollView {
        TrustReceiptStack(items: [
            TrustReceiptStackItem(
                id: "preview-correction",
                title: "Correction recorded",
                summary: "A user correction is visible as the active trust signal.",
                sourceLabel: "Source: You",
                freshnessLabel: "Freshness: current local receipt",
                undoLabel: "Undo unavailable",
                correctionLabel: "Correction available with reason",
                nextActionLabel: "View correction",
                state: .correction
            )
        ])
        .padding()
    }
    .background(LivingSurfaceBackground(context: .trust, state: .proof).ignoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Trust Undo") {
    ScrollView {
        TrustReceiptStack(items: [
            TrustReceiptStackItem(
                id: "preview-undo",
                title: "Plan change can be undone",
                summary: "A local reversible change exposes undo without implying silent automation.",
                sourceLabel: "Source: Plan",
                freshnessLabel: "Freshness: current local receipt",
                undoLabel: "Undo requires confirmation",
                correctionLabel: "Correction unavailable",
                nextActionLabel: "Review in Plan",
                state: .undo
            )
        ])
        .padding()
    }
    .background(LivingSurfaceBackground(context: .trust, state: .active).ignoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Trust Stale Source") {
    ScrollView {
        TrustReceiptStack(items: [
            TrustReceiptStackItem(
                id: "preview-stale-source",
                title: "Source may need review",
                summary: "This receipt stays visible, but its source should not be treated as fresh proof.",
                sourceLabel: "Source: older review",
                freshnessLabel: "Freshness: degraded source",
                undoLabel: "Undo not supported yet",
                correctionLabel: "Correction not supported yet",
                nextActionLabel: nil,
                state: .staleSource
            )
        ])
        .padding()
    }
    .background(LivingSurfaceBackground(context: .trust, state: .stale).ignoresSafeArea())
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}
#endif
