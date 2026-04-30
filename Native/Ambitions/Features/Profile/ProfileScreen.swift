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

private enum ProfileRootDetail: String, Identifiable {
    case profile
    case personalization
    case appearance
    case whatAmbitionsKnows
    case trustCenter
    case receiptsHistory
    case corrections
    case reviews
    case proof
    case archive
    case scheduleAvailability
    case planBehavior
    case automationTrust
    case vacationAwayTime
    case durations
    case notifications
    case integrations
    case widgets
    case exportImport
    case accessibility
    case support
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .profile: "Profile"
        case .personalization: "Personalization"
        case .appearance: "Appearance"
        case .whatAmbitionsKnows: "What Ambitions Knows"
        case .trustCenter: "Trust Center"
        case .receiptsHistory: "Receipts & History"
        case .corrections: "Corrections"
        case .reviews: "Reviews"
        case .proof: "Proof"
        case .archive: "Archive / Completed"
        case .scheduleAvailability: "Schedule & Availability"
        case .planBehavior: "Plan Behavior"
        case .automationTrust: "Automation & Trust"
        case .vacationAwayTime: "Vacation / Away Time"
        case .durations: "Durations"
        case .notifications: "Notifications"
        case .integrations: "Integrations"
        case .widgets: "Widgets / Live Activities / Shortcuts"
        case .exportImport: "Export / Import"
        case .accessibility: "Accessibility"
        case .support: "Help / Support"
        case .about: "About"
        }
    }
}

private struct ProfileSettingsRootView: View {
    @Environment(\.ambitionTheme) private var theme

    let dashboard: ProfileDashboard
    let onOpenDetail: (ProfileRootDetail) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("You")
                    .font(theme.typography.heroDisplay)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)

                Text("Your settings, memory, and trust controls.")
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .accessibilityIdentifier("you.root-title")

            ProfileCompactSystemCard(dashboard: dashboard)

            GroupedNavigationList {
                ForEach(dashboard.systemCenter.sections) { section in
                    GroupedNavigationSection(title: section.title, footer: section.footer) {
                        ForEach(section.items) { item in
                            GroupedDisclosureNavigationRow(
                                title: item.title,
                                subtitle: item.subtitle,
                                systemImage: item.icon,
                                badge: GroupedNavigationBadge(item.statusLabel, state: item.semanticState),
                                accessibilityIdentifier: "you.row.\(item.id)",
                                accessibilityLabel: item.title,
                                accessibilityValue: item.statusLabel,
                                accessibilityHint: item.accessibilityHint
                            ) {
                                onOpenDetail(detail(for: item))
                            }
                        }
                    }
                }
            }
            .accessibilityIdentifier("you.grouped-navigation-root")
        }
        .accessibilityIdentifier("you.root")
    }

    private func detail(for item: ProfileSystemCenterItem) -> ProfileRootDetail {
        switch item.id {
        case "profile": .profile
        case "personalization": .personalization
        case "appearance": .appearance
        case "what-ambitions-knows": .whatAmbitionsKnows
        case "trust-center": .trustCenter
        case "receipts-history": .receiptsHistory
        case "corrections": .corrections
        case "reviews": .reviews
        case "proof": .proof
        case "archive-completed": .archive
        case "schedule-availability": .scheduleAvailability
        case "plan-behavior": .planBehavior
        case "automation-trust": .automationTrust
        case "vacation-away-time": .vacationAwayTime
        case "durations": .durations
        case "notifications": .notifications
        case "integrations": .integrations
        case "widgets-live-activities-shortcuts": .widgets
        case "export-import": .exportImport
        case "accessibility": .accessibility
        case "help-support": .support
        case "about": .about
        default: .profile
        }
    }
}

private struct ProfileCompactSystemCard: View {
    @Environment(\.ambitionTheme) private var theme

    let dashboard: ProfileDashboard

    var body: some View {
        AppCard {
            HStack(alignment: .center, spacing: theme.spacing.sm) {
                Circle()
                    .fill(theme.shell.activeTabBackground)
                    .overlay(
                        Text("A")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.shell.activeTabForeground)
                    )
                    .frame(width: 42, height: 42)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(dashboard.hero.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(1)
                    Text(dashboard.hero.dominantTruth)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                Spacer(minLength: theme.spacing.xs)

                Text(dashboard.preferences.appearancePreference.title)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxxs)
                    .background(Capsule().fill(theme.colors.surfaceOverlay))
                    .overlay(Capsule().stroke(theme.colors.strokeSubtle, lineWidth: 1))
            }
            .padding(theme.spacing.sm)
        }
        .accessibilityIdentifier("you.compact-profile-card")
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
            ProfileSectionCard(
                eyebrow: "Planning Behavior",
                section: ProfileSectionGroup(
                    title: "Schedule & Availability",
                    subtitle: "Ambitions uses this to avoid treating busy time as free time.",
                    items: [
                        SettingsItem(id: "schedule-work", title: "Work schedule", subtitle: "Multiple windows, irregular blocks, and low-control work are supported by the v2 model.", icon: "briefcase", valueLabel: "Local"),
                        SettingsItem(id: "schedule-school", title: "School schedule", subtitle: "School blocks and transition buffers are hard context before open time is calculated.", icon: "graduationcap", valueLabel: "Local"),
                        SettingsItem(id: "schedule-protected", title: "Protected time", subtitle: "Family, household, pet care, sleep, and recovery anchors stay out of free time.", icon: "shield", valueLabel: "Protected"),
                        SettingsItem(id: "schedule-buffers", title: "Commute / transition buffers", subtitle: "Buffers count as real protected time.", icon: "arrow.left.arrow.right", valueLabel: "Hard context")
                    ],
                    footer: "Setup remains optional and non-blocking."
                ),
                accessibilityIdentifier: "profile.schedule-availability-card"
            )
        case .planBehavior:
            ProfileSectionCard(
                eyebrow: "Planning Behavior",
                section: ProfileSectionGroup(
                    title: "Plan Behavior",
                    subtitle: "Control how Ambitions treats open windows and recovery prompts.",
                    items: [
                        SettingsItem(id: "plan-open-time", title: "Open time behavior", subtitle: "Open time is not automatically filled.", icon: "rectangle.dashed", valueLabel: AvailabilityState.doNotFill.displayLabel),
                        SettingsItem(id: "plan-protected-free", title: "Protected free time", subtitle: "Some open windows should stay quiet.", icon: "lock", valueLabel: AvailabilityState.protectedFreeTime.displayLabel),
                        SettingsItem(id: "plan-reflow", title: "Reflow permission", subtitle: "Meaningful day changes ask first and save receipts.", icon: "arrow.triangle.2.circlepath", valueLabel: "Ask first"),
                        SettingsItem(id: "plan-rigidity", title: "Default rigidity", subtitle: "Flexible and optional items can shift only inside trusted rules.", icon: "pin", valueLabel: RigidityLevel.flexible.displayLabel)
                    ],
                    footer: "Hard context, protected blocks, and user-owned boundaries win before recommendations."
                ),
                accessibilityIdentifier: "profile.plan-behavior-card"
            )
        case .automationTrust:
            ProfileSectionCard(
                eyebrow: "Planning Behavior",
                section: ProfileSectionGroup(
                    title: "Automation & Trust",
                    subtitle: "Choose how much Ambitions may change without asking.",
                    items: AutomationLevel.allCases.map {
                        SettingsItem(id: "automation-\($0.rawValue)", title: $0.displayLabel, subtitle: $0.explanation, icon: $0 == .guided ? "checkmark.shield" : "hand.raised", valueLabel: $0 == AutomationLevel.defaultLevel ? "Default" : nil)
                    },
                    footer: "Guided is the default: Ambitions proposes and asks before changing meaningful parts of the day."
                ),
                accessibilityIdentifier: "profile.automation-trust-card"
            )
        case .vacationAwayTime:
            ProfileSectionCard(
                eyebrow: "Planning Behavior",
                section: ProfileSectionGroup(
                    title: "Vacation / Away Time",
                    subtitle: "Vacation is not free time by default.",
                    items: VacationAvailabilityBehavior.allCases.map {
                        SettingsItem(id: "vacation-\($0.rawValue)", title: $0.displayLabel, subtitle: vacationAvailabilitySubtitle(for: $0), icon: "airplane.departure", valueLabel: $0 == VacationAvailabilityBehavior.defaultBehavior ? "Default" : nil)
                    },
                    footer: "A new vacation can make its selected behavior the future default."
                ),
                accessibilityIdentifier: "profile.vacation-away-card"
            )
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
        case .moved: "Rescheduled"
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
