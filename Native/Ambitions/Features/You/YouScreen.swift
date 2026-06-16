import AmbitionsDesignSystem
import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct YouScreen: View {
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.appPlatformCapability) private var appPlatformCapability
    @Environment(\.appUserSystemCapability) private var appUserSystemCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: YouViewModel
    @State private var activeDetail: YouRootDetail?
    private let showsNavigationChrome: Bool

    @MainActor
    init(viewModel: YouViewModel? = nil, showsNavigationChrome: Bool = true) {
        _viewModel = State(initialValue: viewModel ?? YouViewModel())
        _activeDetail = State(initialValue: Self.screenshotProofDetail(from: ProcessInfo.processInfo.arguments))
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
                    PersonalSystemCenterRootView(
                        profileProjection: profileProjection,
                        onOpenDetail: { activeDetail = $0 }
                    )
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("you.scroll")
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: theme.spacing.xxxl + theme.spacing.xxl)
                .accessibilityHidden(true)
        }
        .background {
            LivingSurfaceBackground(context: .you, state: .calm, intensity: 0.68)
                .ignoresSafeArea()
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
        .sheet(item: $activeDetail) { detail in
            YouRootDetailSheet(
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
            await viewModel.load(using: featureFactory.youService)
            syncAppearanceFromLoadedDashboard()
        }
    }

    private func refresh() async {
        await viewModel.refresh(using: featureFactory.youService)
        syncAppearanceFromLoadedDashboard()
    }

    private func savePreferences() {
        Task {
            await viewModel.save(using: featureFactory.youService)
            syncAppearanceFromLoadedDashboard()
        }
    }

    private func requestNotificationAuthorization() {
        Task {
            let granted = await platform.notificationService.requestAuthorizationOptIn()
            if granted {
                await platform.notificationService.refreshSchedule(now: .now)
            }
            await refresh()
        }
    }

    private func notificationPermissionState(for dashboard: YouDashboard) -> DegradedStatePresentation? {
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

    private static func screenshotProofDetail(from arguments: [String]) -> YouRootDetail? {
        guard launchArgumentValue(for: "AmbitionsScreenshotMode", fromArguments: arguments)?
            .caseInsensitiveCompare("yes") == .orderedSame,
            let rawDetail = launchArgumentValue(for: "AmbitionsYouDetail", fromArguments: arguments)
        else {
            return nil
        }

        return [
            "privacy-automation": .automationTrust,
            "personal-system": .personalRuntime,
            "receipts-history": .receiptsHistory
        ][rawDetail.lowercased()]
    }

    private static func launchArgumentValue(for key: String, fromArguments arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: "-\(key)"), arguments.indices.contains(index + 1) else {
            return nil
        }
        let argumentValue = arguments[index + 1]
        return argumentValue.isEmpty ? nil : argumentValue
    }

    private func syncAppearanceFromLoadedDashboard() {
        guard let profileProjection = viewModel.loadedDashboard else { return }
        userSystem.applyAppearancePreference(
            profileProjection.preferences.appearancePreference,
            profileProjection.preferences.accentFamily
        )
    }

    private var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }

    private var platform: AppPlatformCapability {
        guard let appPlatformCapability else {
            preconditionFailure("App platform capability must be injected.")
        }
        return appPlatformCapability
    }

    private var userSystem: AppUserSystemCapability {
        guard let appUserSystemCapability else {
            preconditionFailure("App user system capability must be injected.")
        }
        return appUserSystemCapability
    }
}

private struct YouRootDetailSheet: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    let detail: YouRootDetail
    let dashboard: YouDashboard?
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
            .navigationTitle("")
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
    private func detailContent(for profileProjection: YouDashboard) -> some View {
        switch detail {
        case .sessionDefaults:
            YouConstitutionSurface(constitution: profileProjection.constitution)
        case .personalization:
            YouConstitutionSurface(constitution: profileProjection.constitution)
        case .personalRuntime:
            YouPersonalRuntimeStatusControlGroup(profileProjection: profileProjection)
            YouMemoryControlsSurface(memoryControls: profileProjection.memoryControls)
            YouLifeContextSurface(lifeContext: profileProjection.lifeContext)
            YouSourceAtlasKnowledgeSurface(sourceAtlasKnowledge: profileProjection.sourceAtlasKnowledge)
            YouPersonalVaultSurface(personalVault: profileProjection.personalVault)
            YouEverythingSearchSurface(search: profileProjection.everythingSearch)
        case .appearance:
            YouAppearanceStudioSurface(
                studio: profileProjection.appearanceStudio,
                appearancePreference: $appearancePreference,
                accentFamily: $accentFamily,
                isSaving: isSaving,
                hasUnsavedChanges: hasUnsavedChanges,
                onSave: onSavePreferences
            )
        case .whatAmbitionsKnows:
            YouLifeContextSurface(lifeContext: profileProjection.lifeContext)
            YouSourceAtlasKnowledgeSurface(sourceAtlasKnowledge: profileProjection.sourceAtlasKnowledge)
            YouEverythingSearchSurface(search: profileProjection.everythingSearch)
            YouMemoryControlsSurface(memoryControls: profileProjection.memoryControls)
            YouPersonalVaultSurface(personalVault: profileProjection.personalVault)
            YouContextVaultSurface(contextVault: profileProjection.contextVault)
        case .trustCenter:
            YouTrustCenterSurface(
                trustCenter: profileProjection.trustCenter,
                notificationActionTitle: profileProjection.notificationAuthorization.actionTitle,
                onEnableNotifications: onEnableNotifications
            )
            YouPersonalVaultSurface(personalVault: profileProjection.personalVault)
            YouAutomationBoundarySurface(boundary: profileProjection.automationBoundary)
        case .receiptsHistory:
            YouCrossSurfaceProofReviewSurface(state: profileProjection.crossSurfaceProofReview)
            YouTrustHistoryCenterSurface(history: profileProjection.trustHistoryCenter)
            YouControlGroup(
                eyebrow: "Receipts",
                section: YouSectionGroup(
                    title: profileProjection.receiptAudit.title,
                    subtitle: profileProjection.receiptAudit.subtitle,
                    items: profileProjection.receiptAudit.items,
                    footer: profileProjection.receiptAudit.footer
                ),
                accessibilityIdentifier: "you.receipts-control-group"
            )
        case .corrections:
            YouControlGroup(
                eyebrow: "Corrections",
                section: YouSectionGroup(
                    title: profileProjection.assumptionCorrections.title,
                    subtitle: profileProjection.assumptionCorrections.subtitle,
                    items: profileProjection.assumptionCorrections.items,
                    footer: profileProjection.assumptionCorrections.footer
                ),
                accessibilityIdentifier: "you.corrections-control-group"
            )
        case .reviews:
            YouReviewsSurface(reviews: profileProjection.reviews)
        case .proof:
            YouControlGroup(
                eyebrow: "History",
                section: YouSectionGroup(
                    title: "History",
                    subtitle: "Progress evidence stays local and feeds reviews.",
                    items: profileProjection.reviews.projection.progressLines.map {
                        SettingsItem(id: "proof-\($0.id)", title: $0.title, subtitle: $0.detail, icon: "checkmark.seal", valueLabel: $0.sourceLabel)
                    },
                    footer: "Proof remains reviewable before it is reused."
                ),
                accessibilityIdentifier: "you.proof-control-group"
            )
        case .archive:
            YouControlGroup(eyebrow: "Archive", section: profileProjection.accountSection, accessibilityIdentifier: "you.archive-control-group")
        case .scheduleAvailability:
            YouAvailabilityCenterSurface(center: profileProjection.availabilityCenter)
            if let section = profileProjection.planningDefaultsCenter.section(id: "schedule-availability") {
                YouPlanningDefaultsSectionSurface(section: section, accessibilityIdentifier: "you.schedule-availability-card")
            }
        case .planBehavior:
            if let section = profileProjection.planningDefaultsCenter.section(id: "planning-defaults") {
                YouPlanningDefaultsSectionSurface(section: section, accessibilityIdentifier: "you.plan-behavior-card")
            }
        case .automationTrust:
            if let section = profileProjection.planningDefaultsCenter.section(id: "automation-trust") {
                YouPlanningDefaultsSectionSurface(section: section, accessibilityIdentifier: "you.automation-trust-card")
            }
        case .vacationAwayTime:
            if let section = profileProjection.planningDefaultsCenter.section(id: "vacation-away-time") {
                YouPlanningDefaultsSectionSurface(section: section, accessibilityIdentifier: "you.vacation-away-card")
            }
        case .durations:
            YouControlGroup(
                eyebrow: "Planning Behavior",
                section: YouSectionGroup(
                    title: "Durations",
                    subtitle: "Guessed durations are never presented as fact.",
                    items: DurationSource.allCases.map {
                        SettingsItem(id: "duration-\($0.rawValue)", title: durationTitle(for: $0), subtitle: durationSubtitle(for: $0), icon: "timer", valueLabel: nil)
                    },
                    footer: "Examples: 30 min planned, Suggested: 15-20 min, Usually 10-30 min, Duration not set."
                ),
                accessibilityIdentifier: "you.durations-control-group"
            )
        case .notifications:
            if let notificationPermissionState {
                DegradedStateSurface(
                    state: notificationPermissionState,
                    primaryAccessibilityIdentifier: "you.notification-permission.primary",
                    secondaryAccessibilityIdentifier: "you.notification-permission.secondary",
                    onPrimaryAction: onEnableNotifications,
                    onSecondaryAction: onOpenSystemSettings
                )
            }
            YouControlGroup(eyebrow: "Notifications", section: profileProjection.integrationsSection, accessibilityIdentifier: "you.notifications-control-group")
        case .capturePreferences:
            YouControlGroup(eyebrow: "Capture Preferences", section: profileProjection.integrationsSection, accessibilityIdentifier: "you.capture-preferences-control-group")
        case .sourceSettings:
            YouControlGroup(
                eyebrow: "Source Settings",
                section: YouSectionGroup(
                    title: profileProjection.assumptionCorrections.title,
                    subtitle: profileProjection.assumptionCorrections.subtitle,
                    items: profileProjection.assumptionCorrections.items,
                    footer: profileProjection.assumptionCorrections.footer
                ),
                accessibilityIdentifier: "you.source-settings-control-group"
            )
        case .localDataControls, .integrations, .widgets, .exportImport:
            if detail == .localDataControls {
                YouLocalDataControlsControlGroup(profileProjection: profileProjection)
                YouPersonalVaultSurface(personalVault: profileProjection.personalVault)
                YouMemoryControlsSurface(memoryControls: profileProjection.memoryControls)
                YouControlGroup(eyebrow: "Permission edges", section: profileProjection.integrationsSection, accessibilityIdentifier: "you.local-data-permissions-control-group")
            } else {
                YouControlGroup(eyebrow: "System configuration", section: profileProjection.integrationsSection, accessibilityIdentifier: "you.integrations-control-group")
            }
        case .accessibility:
            YouControlGroup(
                eyebrow: "Accessibility",
                section: YouSectionGroup(
                    title: "Accessibility",
                    subtitle: "Claims stay locked until manual verification is recorded.",
                    items: profileProjection.trustCenter.items.filter { $0.title.localizedCaseInsensitiveContains("Accessibility") },
                    footer: "This is an internal evidence status, not a public accessibility claim."
                ),
                accessibilityIdentifier: "you.accessibility-control-group"
            )
        case .support:
            YouControlGroup(eyebrow: "Help", section: profileProjection.accountSection, accessibilityIdentifier: "you.support-control-group")
        case .about:
            YouControlGroup(eyebrow: "About", section: profileProjection.accountSection, accessibilityIdentifier: "you.about-control-group")
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

private struct YouPersonalRuntimeStatusControlGroup: View {
    let profileProjection: YouDashboard

    var body: some View {
        YouControlGroup(
            eyebrow: "Personal system",
            section: YouSectionGroup(
                title: "Personal system",
                subtitle: "Inspectable local inputs, controls, and receipts for what Ambitions can use today.",
                items: [
                    SettingsItem(
                        id: "you-personal-on-device",
                        title: "Personal context",
                        subtitle: "Life context, memory controls, and personal settings are available from this profile.",
                        icon: "internaldrive",
                        valueLabel: "On device"
                    ),
                    SettingsItem(
                        id: "you-personal-runtime-controls",
                        title: "Edit, reset, disable, delete, export controls",
                        subtitle: "\(profileProjection.memoryControls.localLearningControls.count) local learning controls and \(profileProjection.personalVault.sections.flatMap(\.rows).count) vault rows expose user-owned control labels without silently mutating data.",
                        icon: "slider.horizontal.3",
                        valueLabel: "user-owned"
                    ),
                    SettingsItem(
                        id: "you-personal-runtime-receipts",
                        title: "Receipt behavior",
                        subtitle: "Review history explains what changed, when it changed, and what stayed protected.",
                        icon: "doc.text.magnifyingglass",
                        valueLabel: profileProjection.receiptAudit.items.isEmpty ? "Pending" : "Example"
                    ),
                    SettingsItem(
                        id: "you-personal-runtime-pending",
                        title: "No hidden automation",
                        subtitle: "Broader learning, deletion, sync, export, and import stay unavailable until their controls are ready.",
                        icon: "hand.raised",
                        valueLabel: "Pending"
                    )
                ],
                footer: "This drill-down is inspection and control posture only. It is not a hosted account, cloud planning layer, marketing audit page, or release/privacy approval claim."
            ),
            accessibilityIdentifier: "you.personal-runtime-status-control-group"
        )
    }
}

private struct YouLocalDataControlsControlGroup: View {
    let profileProjection: YouDashboard

    var body: some View {
        YouControlGroup(
            eyebrow: "Privacy",
            section: YouSectionGroup(
                title: "Privacy / Local Data Controls",
                subtitle: "Local-data controls for what Ambitions stores, shows, and can change on this device.",
                items: [
                    SettingsItem(
                        id: "you-local-data-state",
                        title: "Local app state",
                        subtitle: "Display preferences, default landing tab, review cadence, local evidence, captures, and recent event ledger counts come from the current on-device You projection path.",
                        icon: "internaldrive",
                        valueLabel: "On device"
                    ),
                    SettingsItem(
                        id: "you-local-data-vault",
                        title: "Personal vault rows",
                        subtitle: "\(profileProjection.personalVault.sections.flatMap(\.rows).count) local signal and permission rows show source, storage, export, reset, delete, provenance, privacy, and permission labels.",
                        icon: "lock.shield",
                        valueLabel: profileProjection.personalVault.sections.flatMap(\.rows).isEmpty ? "Pending" : "On device"
                    ),
                    SettingsItem(
                        id: "you-local-data-receipts",
                        title: "Policy receipt examples",
                        subtitle: "Examples show how review history will appear when enough local activity exists.",
                        icon: "doc.text.magnifyingglass",
                        valueLabel: "Example"
                    ),
                    SettingsItem(
                        id: "you-local-data-no-account",
                        title: "No hosted account",
                        subtitle: "This build does not introduce a hosted personal-data account, telemetry loop, external planning dependency, or cloud classification requirement.",
                        icon: "person.crop.circle.badge.xmark",
                        valueLabel: "On device"
                    ),
                    SettingsItem(
                        id: "you-local-data-export-sync",
                        title: "Export/import drill pending",
                        subtitle: "Portable export/import, sync continuity, privacy/legal approval, and disaster recovery proof remain future-owned and unclaimed here.",
                        icon: "externaldrive.badge.exclamationmark",
                        valueLabel: "Pending"
                    )
                ],
                footer: "These controls make status inspectable. They do not delete data, claim verified privacy compliance, enable sync, or perform destructive actions from this sheet."
            ),
            accessibilityIdentifier: "you.local-data-controls-control-group"
        )
    }
}

private struct YouConstitutionSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let constitution: YouConstitutionState

    var body: some View {
        ObjectStageSurface {
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
                        YouRuleRow(rule: rule)
                    }
                }

                Text(constitution.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.constitution-card")
        .ambitionPanelAccessibility()
    }
}

private struct YouMemoryControlsSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let memoryControls: YouMemoryControlState

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Memory",
                    title: memoryControls.title,
                    subtitle: memoryControls.subtitle
                )

                if memoryControls.memoryLensItems.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Search",
                            title: "Source-grounded recall",
                            subtitle: "Each visible memory names source age, why it is remembered, privacy posture, and review controls."
                        )

                        ForEach(memoryControls.memoryLensItems) { item in
                            YouMemoryLensItemRow(item: item)
                        }
                    }
                    .accessibilityIdentifier("you.memory-lens-visual-layer")
                }

                ContextRecallSurface(
                    title: "What Ambitions remembers",
                    summary: memoryControls.recoverySummary,
                    sourceLabel: "Source: local receipts, corrections, reviews, and explicit profile context",
                    confidenceLabel: primaryRecallState == .current ? "Review state: current" : "Review state: needs review",
                    state: primaryRecallState,
                    context: .memory,
                    controls: memoryControls.items.prefix(3).map(\.title)
                )
                .accessibilityIdentifier("you.context-recall-surface")

                if memoryControls.runtimeInspectionItems.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Runtime inspection",
                            title: "Learned, used, ignored, changed",
                            subtitle: "A local readout of what shaped memory, what stayed held back, and what changed."
                        )

                        ForEach(memoryControls.runtimeInspectionItems) { item in
                            YouRuntimeInspectionItemRow(item: item)
                        }
                    }
                    .accessibilityIdentifier("you.runtime-inspection-section")
                }

                if memoryControls.localLearningControls.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Local learning controls",
                            title: "Reset, disable, delete, export",
                            subtitle: "Controls stay source-tied, local-only, confirmation-aware, and receipt-aware."
                        )

                        ForEach(memoryControls.localLearningControls) { control in
                            YouLocalLearningControlRow(control: control)
                        }
                    }
                    .accessibilityIdentifier("you.local-learning-controls-section")
                }

                MemoryConstellation(
                    title: "Visible memory states",
                    subtitle: "A bounded map of current, stale, sensitive, corrected, and empty states. It is not a hidden inference graph.",
                    nodes: constellationNodes
                )
                .accessibilityIdentifier("you.memory-constellation")

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(memoryControls.items) { item in
                        YouSettingRow(item: item)
                    }
                }

                YouPersonalizationConsentPanel(consent: memoryControls.consent)

                if memoryControls.privateModeControls.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Private mode",
                            title: "Sensitive areas",
                            subtitle: "Private context stays summarized, approval-gated, or blocked until a safe owner proves more."
                        )

                        ForEach(memoryControls.privateModeControls) { control in
                            YouPrivateModeControlRow(control: control)
                        }
                    }
                    .accessibilityIdentifier("you.private-mode-controls")
                }

                ForEach(memoryControls.groups) { group in
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "What this uses",
                            title: group.title,
                            subtitle: group.subtitle
                        )

                        ForEach(group.items) { item in
                            YouMemoryItemRow(item: item)
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
                            YouNarrativeMemoryRow(memory: memory)
                        }
                    }
                    .accessibilityIdentifier("you.narrative-memory-section")
                }

                if memoryControls.conservativePatterns.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Pattern review",
                            title: "Conservative signals",
                            subtitle: "Patterns stay reviewable and never become automatic certainty."
                        )

                        ForEach(memoryControls.conservativePatterns) { pattern in
                            YouMemoryPatternRow(pattern: pattern)
                        }
                    }
                    .accessibilityIdentifier("you.memory-pattern-section")
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
        .accessibilityIdentifier("you.memory-controls-card")
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

private struct YouLifeContextSurface: View {
    @Environment(\.ambitionTheme) private var theme
    @State private var expandedSectionIDs: Set<String> = ["life-context-basics", "life-context-schedule-availability"]

    let lifeContext: YouLifeContextState

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Life Context",
                    title: lifeContext.title,
                    subtitle: lifeContext.subtitle
                )
                .accessibilityIdentifier("you.life-context-card")

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text(lifeContext.intro)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Button {
                            expandAllSections()
                        } label: {
                            Label("Catch me up", systemImage: "arrow.down.right.and.arrow.up.left")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(AmbitionButtonStyle(tier: .hero, state: .selected))
                        .accessibilityIdentifier("you.life-context.catch-up-button")

                        Button {
                            focusReviewNeededSection()
                        } label: {
                            Label("Review what Ambitions knows", systemImage: "checkmark.shield")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: .default))
                        .accessibilityIdentifier("you.life-context.review-button")
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    ForEach(lifeContext.sections) { section in
                        YouLifeContextSectionDisclosure(
                            section: section,
                            isExpanded: expansionBinding(for: section.id)
                        )
                    }
                }

                Text(lifeContext.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .ambitionPanelAccessibility(
            label: lifeContext.title,
            value: "\(lifeContext.sections.count) sections, \(lifeContext.sections.flatMap(\.factRows).count) facts, \(lifeContext.sections.flatMap(\.factRows).filter { $0.runtimeUseState == .needsReview }.count) need review.",
            hint: "Review local life context before Ambitions uses it to fit steps to real life."
        )
    }

    private func expansionBinding(for sectionID: String) -> Binding<Bool> {
        Binding(
            get: { expandedSectionIDs.contains(sectionID) },
            set: { isExpanded in
                if isExpanded {
                    expandedSectionIDs.insert(sectionID)
                } else {
                    expandedSectionIDs.remove(sectionID)
                }
            }
        )
    }

    private func expandAllSections() {
        expandedSectionIDs = Set(lifeContext.sections.map(\.id))
    }

    private func focusReviewNeededSection() {
        expandedSectionIDs = ["life-context-review-needed"]
    }
}

private struct YouLifeContextSectionDisclosure: View {
    @Environment(\.ambitionTheme) private var theme

    let section: YouLifeContextSection
    @Binding var isExpanded: Bool

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                Button {
                    isExpanded.toggle()
                } label: {
                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(section.title)
                                .font(theme.typography.section)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(section.subtitle)
                                .font(theme.typography.body)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: theme.spacing.sm)

                        TagPill("\(section.factRows.count)", icon: "list.bullet", state: section.factRows.isEmpty ? .default : .selected)

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(theme.colors.textSecondary)
                            .accessibilityHidden(true)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("you.life-context.section.\(section.id)")
                .accessibilityLabel(section.title)
                .accessibilityValue("\(section.factRows.count) facts. \(isExpanded ? "Expanded" : "Collapsed")")
                .accessibilityHint(section.subtitle)

                if isExpanded {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(section.factRows) { factRow in
                            YouLifeContextFactRowView(factRow: factRow)
                        }
                    }
                }
            }
        }
        .ambitionPanelAccessibility()
    }
}

private struct YouLifeContextFactRowView: View {
    @Environment(\.ambitionTheme) private var theme

    let factRow: YouLifeContextFactRow

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: iconName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentWarm)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(factRow.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(factRow.detail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
                TagPill(factRow.freshness.label, state: factRow.freshness.visualState)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        TagPill(factRow.sourceLabel, icon: "doc.text.magnifyingglass", state: .default)
                        TagPill(factRow.activityLabel, icon: "play.circle", state: factRow.activityLabel.localizedCaseInsensitiveContains("active") ? .success : .warning)
                        TagPill(factRow.lastAffectedLabel, icon: "clock", state: factRow.freshness.visualState)
                        TagPill("Runtime use \(factRow.runtimeUseState.label)", icon: "hand.raised", state: factRow.runtimeUseState.visualState)
                        TagPill(factRow.runtimePermissionLabel, icon: "lock.shield", state: factRow.runtimeUseState == .used ? .success : .warning)
                        TagPill(factRow.whereUsed, icon: "tray.full", state: factRow.runtimeUseState.visualState)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    YouLifeContextFactActionButton(
                        title: factRow.editLabel,
                        systemImage: "pencil",
                        state: .default,
                        identifier: "you.life-context.fact.\(factRow.id).edit",
                        hint: factRow.editPath
                    )
                    YouLifeContextFactActionButton(
                        title: factRow.pauseLabel,
                        systemImage: "pause.circle",
                        state: .warning,
                        identifier: "you.life-context.fact.\(factRow.id).pause",
                        hint: factRow.pausePath
                    )
                    YouLifeContextFactActionButton(
                        title: factRow.deleteLabel,
                        systemImage: "trash.slash",
                        state: .warning,
                        identifier: "you.life-context.fact.\(factRow.id).delete",
                        hint: factRow.deletePath
                    )
                    YouLifeContextFactActionButton(
                        title: factRow.reviewLabel,
                        systemImage: "checkmark.shield",
                        state: .selected,
                        identifier: "you.life-context.fact.\(factRow.id).review",
                        hint: factRow.reviewPath
                    )
                    YouLifeContextFactActionButton(
                        title: factRow.confirmLabel,
                        systemImage: "checkmark.circle",
                        state: .success,
                        identifier: "you.life-context.fact.\(factRow.id).confirm",
                        hint: factRow.confirmPath
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility()
    }

    private var iconName: String {
        switch factRow.captureRouteContext {
        case .needsPlace:
            return "location"
        case .needsReview:
            return "checkmark.shield"
        }
    }
}

private struct YouLifeContextFactActionButton: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let systemImage: String
    let state: AmbitionVisualState
    let identifier: String
    let hint: String

    var body: some View {
        Button {
            NotificationCenter.default.post(
                name: Notification.Name("AmbitionsYouPlaceholderActionSelected"),
                object: nil
            )
        } label: {
            Label(title, systemImage: systemImage)
                .font(theme.typography.caption.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(AmbitionButtonStyle(tier: .tertiary, state: state))
        .accessibilityIdentifier(identifier)
        .accessibilityHint(hint)
    }
}

private struct YouRuntimeInspectionItemRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: YouRuntimeInspectionItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: iconName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                TagPill(item.kind.label, state: item.state)
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 220), spacing: theme.spacing.xs, alignment: .leading)],
                alignment: .leading,
                spacing: theme.spacing.xs
            ) {
                TagPill(item.sourceLabel, icon: "doc.text.magnifyingglass", state: .default)
                TagPill(item.controlLabel, icon: "hand.tap", state: item.state)
                TagPill(item.privacyLabel, icon: "lock.shield", state: .default)
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

    private var iconName: String {
        switch item.kind {
        case .learned:
            return "checkmark.seal"
        case .used:
            return "doc.text.magnifyingglass"
        case .ignored:
            return "xmark.seal"
        case .changed:
            return "arrow.triangle.2.circlepath"
        }
    }
}

private struct YouLocalLearningControlRow: View {
    @Environment(\.ambitionTheme) private var theme

    let control: YouLocalLearningControl

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: iconName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentWarm)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(control.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(control.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                TagPill(control.availabilityLabel, state: control.state)
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 220), spacing: theme.spacing.xs, alignment: .leading)],
                alignment: .leading,
                spacing: theme.spacing.xs
            ) {
                TagPill(control.sourceLabel, icon: "doc.text.magnifyingglass", state: .default)
                TagPill(control.receiptLabel, icon: "checkmark.seal", state: control.state)
                TagPill(control.boundaryLabel, icon: "lock.shield", state: .default)
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: control.accessibilityLabel,
            value: control.accessibilityValue,
            hint: control.accessibilityHint
        )
    }

    private var iconName: String {
        switch control.id {
        case "local-learning-reset":
            return "arrow.counterclockwise.circle"
        case "local-learning-disable":
            return "pause.circle"
        case "local-learning-delete":
            return "trash.slash"
        case "local-learning-export":
            return "square.and.arrow.up"
        default:
            return "slider.horizontal.3"
        }
    }
}

private struct YouEverythingSearchSurface: View {
    @Environment(\.ambitionTheme) private var theme
    @State private var searchQuery = ""

    let search: YouEverythingSearchState

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Search",
                    title: search.title,
                    subtitle: search.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    TextField(search.queryPrompt, text: $searchQuery, axis: .vertical)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(1...3)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("you.everything-search.query")
                        .accessibilityLabel(search.queryPrompt)
                        .accessibilityHint("Filters local objects already stored on this device.")

                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        Image(systemName: "scope")
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(theme.colors.accentWarm)
                            .frame(width: 24)
                        Text(search.summary(for: searchQuery))
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text(search.performanceBudgetSummary)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if search.filters.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Filters",
                            title: "Local object types",
                            subtitle: "Counts reflect what is already loaded locally."
                        )

                        ForEach(search.filters) { item in
                            YouSettingRow(item: item)
                        }
                    }
                }

                let results = Array(search.filteredItems(matching: searchQuery).prefix(12))
                if results.isEmpty {
                    Text("No local objects match this search yet.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Matches",
                            title: "Inspectable local objects",
                            subtitle: search.hitPerformanceBudget ? "The view is capped to keep search responsive." : "The view stays limited to local objects only."
                        )

                        ForEach(results) { item in
                            YouEverythingSearchResultRow(item: item)
                        }
                    }
                }

                Text(search.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.everything-search-card")
        .ambitionPanelAccessibility(
            label: search.title,
            value: search.summary(for: searchQuery),
            hint: "Search stays local and inspectable."
        )
    }
}

private struct YouEverythingSearchResultRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: YouEverythingSearchItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: item.kind.systemImage)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
            }

            HStack(spacing: theme.spacing.xs) {
                TagPill(item.kind.title, state: .default)
                TagPill(item.sourceLabel, state: .default)
                TagPill(item.freshness.label, state: item.freshness.visualState)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(item.primaryActions) { action in
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

private struct YouMemoryLensItemRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: YouMemoryLensItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "scope")
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(item.whyRemembered)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
            }

            HStack(spacing: theme.spacing.xs) {
                TagPill(item.sourceLabel, icon: "doc.text.magnifyingglass", state: .default)
                TagPill(item.sourceAgeLabel, icon: "clock", state: item.state)
                TagPill(item.privacyShutterLabel, icon: "eye.slash", state: .default)
            }

            HStack(spacing: theme.spacing.xs) {
                TagPill(item.reviewLabel, icon: "checkmark.seal", state: item.state)
                TagPill(item.correctionLabel, icon: "pencil", state: .default)
                TagPill(item.rejectionLabel, icon: "xmark.seal", state: item.state == .success ? .default : .warning)
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

private extension YouMemoryFreshness {
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

private struct YouPersonalizationConsentPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let consent: YouPersonalizationConsentState

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
        .accessibilityIdentifier("you.personalization-consent")
        .accessibilityLabel("\(consent.title). \(consent.summary). \(consent.controlLabel).")
    }
}

private struct YouPrivateModeControlRow: View {
    @Environment(\.ambitionTheme) private var theme

    let control: YouPrivateModeControl

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

private struct YouSourceAtlasKnowledgeSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let sourceAtlasKnowledge: YouSourceAtlasKnowledgeState

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Source Atlas",
                    title: sourceAtlasKnowledge.title,
                    subtitle: sourceAtlasKnowledge.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    ForEach(sourceAtlasKnowledge.sections) { section in
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            SectionHeader(title: section.title, subtitle: section.subtitle)

                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(section.rows) { row in
                                    YouSourceAtlasKnowledgeRowView(row: row)
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
                }

                Text(sourceAtlasKnowledge.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.source-atlas-knowledge-card")
        .ambitionPanelAccessibility(
            label: sourceAtlasKnowledge.title,
            value: "\(sourceAtlasKnowledge.sections.count) source sections",
            hint: "Inspect what Ambitions used for goal knowledge and how to review it."
        )
    }
}

private struct YouSourceAtlasKnowledgeRowView: View {
    @Environment(\.ambitionTheme) private var theme

    let row: YouSourceAtlasKnowledgeRow

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: row.icon)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(row.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(row.usedWhat)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(row.whyUsed)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                TagPill(row.runtimeUseState.label, state: row.runtimeUseState.visualState)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.xs) {
                    TagPill(row.sourceName, state: row.state)
                    TagPill(row.sourceStateLabel, state: row.state)
                    TagPill(row.freshnessStateLabel, state: row.state)
                    TagPill(row.riskStateLabel, state: row.state)
                    TagPill(row.reviewNeedLabel, state: row.reviewNeedLabel == "Needs Review" ? .warning : .success)
                }
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text("Correction: \(row.correctionPath)")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Review: \(row.reviewPath)")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: row.accessibilityLabel,
            value: row.accessibilityValue,
            hint: row.accessibilityHint
        )
    }
}

private struct YouMemoryItemRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: YouMemoryItem

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

private struct YouNarrativeMemoryRow: View {
    @Environment(\.ambitionTheme) private var theme

    let memory: YouNarrativeMemory

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

private struct YouMemoryPatternRow: View {
    @Environment(\.ambitionTheme) private var theme

    let pattern: YouMemoryPattern

    var body: some View {
        ObjectStageGlance(state: pattern.state) {
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

private struct YouAutomationBoundarySurface: View {
    @Environment(\.ambitionTheme) private var theme

    let boundary: YouAutomationBoundaryState

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Boundaries",
                    title: boundary.title,
                    subtitle: boundary.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(boundary.rules) { rule in
                        YouRuleRow(rule: rule)
                    }
                }

                Text(boundary.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.automation-boundary-card")
        .ambitionPanelAccessibility()
    }
}

private struct YouReviewsSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let reviews: YouReviewsState

    var body: some View {
        let projection = reviews.projection

        ObjectStageSurface {
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

                YouReviewCluster(
                    title: projection.recovery.title,
                    subtitle: projection.recovery.subtitle,
                    emptyTitle: projection.recovery.emptyStateTitle,
                    emptyDetail: projection.recovery.emptyStateDetail,
                    items: Array((projection.recovery.whatRecovered + projection.recovery.whatWasProtected + projection.recovery.needsReview).prefix(4))
                )

                YouReviewCluster(
                    title: projection.lifeOSReceipt.title,
                    subtitle: projection.lifeOSReceipt.subtitle,
                    emptyTitle: projection.lifeOSReceipt.emptyStateTitle,
                    emptyDetail: projection.lifeOSReceipt.emptyStateDetail,
                    items: Array((projection.lifeOSReceipt.receiptHighlights + projection.lifeOSReceipt.meaningfulEvents).prefix(4))
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(title: "Review rhythms", subtitle: "Weekly, monthly, and recovery reviews stay under You, Time, and Goal context.")
                    ForEach(projection.cadences) { cadence in
                        YouReviewCadenceRow(cadence: cadence)
                    }
                }
                .accessibilityIdentifier("you.review-cadences-section")

                if projection.progressLines.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(title: "Progress receipt", subtitle: "A plain record of what changed, what has proof, and what should carry forward.")
                        ForEach(projection.progressLines) { line in
                            YouProgressReceiptLineRow(line: line)
                        }
                    }
                    .accessibilityIdentifier("you.progress-receipt-section")
                }

                if projection.proofHighlights.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(title: "Proof highlights", subtitle: "Recent evidence that can make the next review more grounded.")
                        ForEach(projection.proofHighlights) { proof in
                            YouReviewProofRow(proof: proof)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(title: "Carry forward", subtitle: "The smallest useful thing to keep visible after this review.")
                    ForEach(projection.carryForward) { item in
                        YouCarryForwardRow(item: item)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(title: "Planning handoff", subtitle: "Review can suggest where to go next, but it does not change the plan silently.")
                    ForEach(projection.planningHandoffs) { handoff in
                        YouPlanningHandoffRow(handoff: handoff)
                    }
                }
                .accessibilityIdentifier("you.review-planning-handoff-section")

                if projection.correctionPrompts.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(title: "Corrections", subtitle: "Existing correction paths stay user-directed.")
                        ForEach(projection.correctionPrompts.prefix(2)) { prompt in
                            YouCorrectionPromptRow(prompt: prompt)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(title: "Unavailable here", subtitle: "Trust notes for what this review does not claim.")
                    ForEach(projection.unavailableNotes.prefix(3)) { note in
                        YouReviewSignalRow(item: note)
                    }
                }

                Text(reviews.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.reviews-card")
        .ambitionPanelAccessibility()
    }
}

private struct YouReviewCluster: View {
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
                    YouReviewSignalRow(item: item)
                }
            }
        }
    }
}

private struct YouReviewCadenceRow: View {
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

private struct YouProgressReceiptLineRow: View {
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

private struct YouReviewSignalRow: View {
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

private struct YouReviewProofRow: View {
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

private struct YouCarryForwardRow: View {
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

private struct YouPlanningHandoffRow: View {
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

private struct YouCorrectionPromptRow: View {
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

private struct YouRuleRow: View {
    @Environment(\.ambitionTheme) private var theme

    let rule: YouConstitutionRule

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

private struct YouMetricTile: View {
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

private struct YouAppearanceStudioSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let studio: YouAppearanceStudioState
    @Binding var appearancePreference: AppAppearancePreference
    @Binding var accentFamily: AmbitionAccentFamily
    let isSaving: Bool
    let hasUnsavedChanges: Bool
    let onSave: () -> Void

    private let previewColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ObjectStageSurface {
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
                    .accessibilityIdentifier("you.appearance-picker")

                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        ForEach(studio.modeOptions) { option in
                            YouSelectableRow(
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
                    .accessibilityIdentifier("you.accent-family-picker")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: theme.spacing.sm) {
                        ForEach(studio.accentOptions) { option in
                            YouAccentTile(
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
                        subtitle: "See the selected appearance against real Ambitions surfaces before you commit it."
                    )

                    LazyVGrid(columns: previewColumns, spacing: theme.spacing.sm) {
                        ForEach(studio.previewSwatches) { swatch in
                            YouPreviewSwatchSurface(
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
                .accessibilityIdentifier("you.save-preferences-button")
            }
        }
        .accessibilityIdentifier("you.appearance-studio-card")
    }
}

private struct YouSelectableRow: View {
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

private struct YouAccentTile: View {
    @Environment(\.ambitionTheme) private var theme

    let option: YouAccentOption
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

private struct YouPreviewSwatchSurface: View {
    let swatch: YouPreviewSwatch
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

            YouObjectPreviewMiniature(kind: swatch.objectKind, previewTheme: selectedTheme)

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
        .ambitionPanelAccessibility(
            label: swatch.accessibilityLabel,
            value: "\(appearancePreference.title) mode, \(accentFamily.title) accent.",
            hint: "Shows how the selected appearance applies to this Ambitions object preview."
        )
    }
}

private struct YouObjectPreviewMiniature: View {
    let kind: YouAppearanceObjectPreviewKind
    let previewTheme: AmbitionTheme

    var body: some View {
        switch kind {
        case .startHere:
            VStack(alignment: .leading, spacing: 6) {
                Capsule().fill(previewTheme.colors.accentWarm.opacity(0.9)).frame(width: 52, height: 5)
                RoundedRectangle(cornerRadius: previewTheme.radius.sm, style: .continuous)
                    .fill(previewTheme.colors.accentPrimary.opacity(0.82))
                    .frame(height: 22)
                HStack(spacing: 5) {
                    Capsule().fill(previewTheme.colors.textSecondary.opacity(0.35)).frame(height: 5)
                    Capsule().fill(previewTheme.colors.textSecondary.opacity(0.22)).frame(width: 36, height: 5)
                }
            }
            .accessibilityHidden(true)

        case .realityRail:
            HStack(alignment: .center, spacing: 8) {
                VStack(spacing: 5) {
                    Circle().fill(previewTheme.colors.accentPrimary).frame(width: 7, height: 7)
                    Rectangle().fill(previewTheme.colors.strokeSubtle).frame(width: 2, height: 20)
                    Circle().fill(previewTheme.colors.accentWarm.opacity(0.85)).frame(width: 7, height: 7)
                    Rectangle().fill(previewTheme.colors.strokeSubtle).frame(width: 2, height: 20)
                    Circle().fill(previewTheme.colors.textTertiary.opacity(0.8)).frame(width: 7, height: 7)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Capsule().fill(previewTheme.colors.accentPrimary.opacity(0.75)).frame(height: 8)
                    Capsule().fill(previewTheme.colors.surfaceOverlay.opacity(0.9)).frame(height: 8)
                    Capsule().fill(previewTheme.colors.surfaceOverlay.opacity(0.65)).frame(height: 8)
                }
            }
            .accessibilityHidden(true)

        case .lifeShape:
            HStack(alignment: .bottom, spacing: 5) {
                RoundedRectangle(cornerRadius: 3).fill(previewTheme.colors.surfaceOverlay).frame(width: 12, height: 22)
                RoundedRectangle(cornerRadius: 3).fill(previewTheme.colors.accentPrimary.opacity(0.7)).frame(width: 12, height: 38)
                RoundedRectangle(cornerRadius: 3).fill(previewTheme.colors.accentWarm.opacity(0.82)).frame(width: 12, height: 28)
                RoundedRectangle(cornerRadius: 3).fill(previewTheme.colors.surfaceOverlay).frame(width: 12, height: 46)
                RoundedRectangle(cornerRadius: 3).fill(previewTheme.colors.accentPrimary.opacity(0.45)).frame(width: 12, height: 32)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityHidden(true)

        case .receiptDrawer:
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(previewTheme.colors.accentPrimary)
                    Capsule().fill(previewTheme.colors.textSecondary.opacity(0.35)).frame(height: 6)
                }
                HStack(spacing: 5) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(previewTheme.colors.accentWarm)
                    Capsule().fill(previewTheme.colors.surfaceOverlay.opacity(0.9)).frame(height: 6)
                }
                RoundedRectangle(cornerRadius: previewTheme.radius.sm, style: .continuous)
                    .fill(previewTheme.colors.strokeSubtle.opacity(0.7))
                    .frame(height: 1)
            }
            .accessibilityHidden(true)
        }
    }
}

private struct YouTrustCenterSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let trustCenter: YouTrustCenterState
    let notificationActionTitle: String?
    let onEnableNotifications: () -> Void

    var body: some View {
        ObjectStageSurface {
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
                        YouSettingRow(item: item)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(
                        eyebrow: "Data map",
                        title: "What this surface can explain",
                        subtitle: "A compact inventory of local context, permissions, receipts, and future-owned edges."
                    )

                    ForEach(trustCenter.dataMap) { item in
                        YouTrustDataMapRow(item: item)
                    }
                }
                .accessibilityIdentifier("you.trust-data-map")

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

                WhyThisAffordance(
                    summary: "Receipts explain what changed, why it changed, and when review, correction, or undo is available.",
                    evidence: "The surface stays local, inspectable, and explicit about context freshness instead of implying hosted intelligence.",
                    onOpen: {}
                )

                ReceiptDrawer(
                    title: "Receipt drawer",
                    subtitle: "Receipt drawer keeps context freshness, privacy, correction, undo, and review paths visible.",
                    sections: trustReceiptDrawerSections,
                    onReview: { _ in },
                    onUndo: { _ in }
                )

                ProofSpine(
                    title: "Proof trail",
                    subtitle: "Proof stays attached to context freshness, privacy, correction, and review state.",
                    beads: trustProofTrailBeads
                )

                TrustReceiptStack(
                    title: "Recent trust receipts",
                    subtitle: "Privacy-safe summaries of what changed, why, and whether correction or undo is available.",
                    items: trustReceiptStackItems
                )

                if let notificationActionTitle {
                    Button(notificationActionTitle, action: onEnableNotifications)
                        .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: .default))
                        .accessibilityIdentifier("you.enable-notifications-button")
                }

                Text(trustCenter.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.trust-center-card")
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

    private var trustReceiptDrawerSections: [ReceiptDrawerSection] {
        let receipts = trustCenter.receiptSummaries
        guard receipts.isEmpty == false else { return [] }

        return [
            ReceiptDrawerSection(
                id: "recent-receipts",
                title: "Recent receipts",
                subtitle: "What changed, why, and what remains reviewable or reversible.",
                items: receipts.prefix(3).map(\.trustReceiptLayerItem)
            ),
            ReceiptDrawerSection(
                id: "recovery-receipts",
                title: "Recovery and review",
                subtitle: "Local-only, blocked, and confirmation-gated paths stay visible.",
                items: receipts.suffix(max(0, receipts.count - 3)).map(\.trustReceiptLayerItem)
            )
        ]
    }

    private var trustProofTrailBeads: [ProofBead] {
        trustCenter.receiptSummaries.prefix(5).map(\.proofTrailBead)
    }
}

private struct YouTrustDataMapRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: YouTrustDataMapItem

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

private struct YouTrustReceiptRow: View {
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
        case .time: "Source: Time"
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
        case .externalUnavailable: "Freshness: external needs context"
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

private extension ActionReceiptDisplaySummary {
    var trustReceiptLayerItem: TrustReceiptLayerItem {
        TrustReceiptLayerItem(
            id: id,
            kind: trustReceiptKind,
            title: title,
            summary: summary,
            sourceLabel: sourceDomain.trustReceiptSourceLabel,
            freshness: safetyState.trustReceiptFreshnessState,
            privacyLabel: safetyState.trustReceiptPrivacyLabel,
            whyLabel: trustReceiptWhyLabel,
            changeLabel: trustReceiptChangeLabel,
            undoLabel: undoAvailability.trustReceiptUndoLabel,
            correctionLabel: correctionAvailability.trustReceiptCorrectionLabel,
            reviewLabel: trustReceiptReviewLabel
        )
    }

    var proofTrailBead: ProofBead {
        ProofBead(
            id: id,
            title: title,
            summary: summary,
            sourceLabel: sourceDomain.trustReceiptSourceLabel,
            freshness: safetyState.trustReceiptFreshnessState,
            privacyLabel: safetyState.trustReceiptPrivacyLabel,
            timestampLabel: occurredAt,
            correctionLabel: correctionAvailability.trustReceiptCorrectionLabel,
            staleReviewLabel: trustReceiptStaleReviewLabel
        )
    }

    var trustReceiptKind: TrustReceiptLayerKind {
        switch (safetyState, resultState) {
        case (.safeFailure, _), (.externalUnavailable, _):
            return .blockedSafely
        case (.confirmationRequired, _):
            return .needsReview
        case (_, .undoAvailable):
            return .undone
        case (_, .correctionAvailable):
            return .sourceChange
        case (_, .moved):
            return .moved
        case (_, .changed), (_, .created), (_, .scheduled), (_, .attached), (_, .completed):
            return .proofSaved
        case (_, .failedSafely), (_, .needsConfirmation):
            return .blockedSafely
        case (_, .noOp), (_, .undoUnavailable), (_, .detached), (_, .exportedPrepared), (_, .draftedPrepared):
            return .staleSource
        }
    }

    var trustReceiptWhyLabel: String {
        nextActionTitle ?? "User review keeps the next change visible and inspectable."
    }

    var trustReceiptChangeLabel: String {
        switch resultState {
        case .created: "A new local receipt was recorded."
        case .changed: "The local record changed with a receipt."
        case .scheduled: "A scheduled change was recorded locally."
        case .moved: "The item moved with a receipt."
        case .attached: "The item was attached with a receipt."
        case .detached: "The item was detached with a receipt."
        case .exportedPrepared: "Export was prepared locally."
        case .draftedPrepared: "Draft preparation was recorded."
        case .completed: "The completed step remains visible as proof."
        case .failedSafely: "The change stayed blocked safely."
        case .needsConfirmation: "The change waits for confirmation."
        case .noOp: "No hidden change happened."
        case .undoAvailable: "Undo remains available locally."
        case .undoUnavailable: "Undo is not available for this receipt."
        case .correctionAvailable: "Correction remains available locally."
        }
    }

    var trustReceiptReviewLabel: String {
        switch safetyState {
        case .normal: "Review receipt"
        case .degraded: "Review context"
        case .safeFailure: "Review blocked change"
        case .externalUnavailable: "Review local-only receipt"
        case .confirmationRequired: "Review before confirming"
        }
    }

    var trustReceiptStaleReviewLabel: String? {
        switch safetyState {
        case .normal:
            return nil
        case .degraded:
            return "Review before broader use."
        case .safeFailure:
            return "Blocked safely until the source is reviewed."
        case .externalUnavailable:
            return "Source is unavailable, so the receipt stays local."
        case .confirmationRequired:
            return "Wait for confirmation before broader use."
        }
    }
}

private extension ActionReceiptSafetyState {
    var trustReceiptFreshnessState: SourceFreshnessState {
        switch self {
        case .normal: .fresh
        case .degraded: .partial
        case .safeFailure: .blocked
        case .externalUnavailable: .offline
        case .confirmationRequired: .stale
        }
    }

    var trustReceiptPrivacyLabel: String {
        switch self {
        case .normal: "Private by default"
        case .degraded: "Private summary"
        case .safeFailure: "Protected receipt"
        case .externalUnavailable: "Local only"
        case .confirmationRequired: "Private until confirmed"
        }
    }
}

private struct YouContextVaultSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let contextVault: YouContextVaultState

    var body: some View {
        ObjectStageSurface {
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
        .accessibilityIdentifier("you.context-vault-card")
    }
}

private struct YouPersonalVaultSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let personalVault: YouPersonalVaultState

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Privacy",
                    title: personalVault.title,
                    subtitle: personalVault.subtitle
                )

                ForEach(personalVault.sections) { section in
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: section.id.localizedCaseInsensitiveContains("permission") ? "Permissions Center" : "Sensitive Local Signals",
                            title: section.title,
                            subtitle: section.subtitle
                        )

                        ForEach(section.rows) { row in
                            YouPersonalVaultRowView(row: row)
                        }
                    }
                }

                Text(personalVault.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.personal-vault-card")
        .ambitionPanelAccessibility(
            label: personalVault.title,
            value: "\(personalVault.sections.count) sections, \(personalVault.sections.flatMap(\.rows).count) rows, \(personalVault.sections.flatMap(\.rows).filter { $0.kind == .permission }.count) permission rows.",
            hint: "Review the local signal rows, permission labels, and export/reset/delete boundaries."
        )
    }
}

private struct YouPersonalVaultRowView: View {
    @Environment(\.ambitionTheme) private var theme

    let row: YouPersonalVaultRow

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: iconName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(row.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(row.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
                TagPill(row.kind.label, state: row.state)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.xs) {
                    TagPill(row.sourceLabel, icon: "doc.text.magnifyingglass", state: .default)
                    TagPill(row.storageLabel, icon: "internaldrive", state: row.state)
                    TagPill(row.exportLabel, icon: "square.and.arrow.up", state: row.state)
                    TagPill(row.resetLabel, icon: "arrow.counterclockwise", state: .default)
                    TagPill(row.deleteLabel, icon: "trash.slash", state: .warning)
                    TagPill(row.provenanceLabel, icon: "text.badge.checkmark", state: .default)
                    TagPill(row.privacyPolicyLabel, icon: "hand.raised", state: .default)
                    TagPill(row.permissionLabel, icon: "lock.shield", state: row.state)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: row.accessibilityLabel,
            value: row.accessibilityValue,
            hint: row.accessibilityHint
        )
    }

    private var iconName: String {
        switch row.kind {
        case .signal:
            return "brain.head.profile"
        case .permission:
            return "lock.shield"
        }
    }
}

private struct YouControlGroup: View {
    @Environment(\.ambitionTheme) private var theme

    let eyebrow: String
    let section: YouSectionGroup
    let accessibilityIdentifier: String

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            SectionHeader(eyebrow: eyebrow, title: section.title, subtitle: section.subtitle)

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                ForEach(section.items) { item in
                    YouSettingRow(item: item)
                }
            }

            if let footer = section.footer {
                Text(footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .padding(.leading, theme.spacing.sm)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(LivingTabContext.you.accent(in: theme).opacity(0.42))
                .frame(width: 2)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.72))
                .frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.42))
                .frame(height: 1)
        }
        .accessibilityIdentifier(accessibilityIdentifier)
        .ambitionPanelAccessibility(
            label: section.title,
            value: "\(section.items.count) controls",
            hint: "Review this You control group."
        )
    }
}

private struct YouSettingRow: View {
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
                if let valueLabel = item.valueLabel {
                    TagPill(valueLabel, state: .default)
                }
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility()
    }
}

#if DEBUG
#Preview("You Minimal State") {
    NavigationStack {
        YouScreen(viewModel: YouViewModel(state: .loaded(PreviewFixtures.default.youDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("You Memory Stale") {
    ScrollView {
        ContextRecallSurface(
            title: "Availability pattern may need review",
            summary: "This recall is old enough that Ambitions should ask before using it to shape planning.",
            sourceLabel: "Source: older local review",
            confidenceLabel: "Review state: needs review",
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
        ContextRecallSurface(
            title: "Rejected assumption",
            summary: "The user rejected this signal, so it remains visible only as correction history.",
            sourceLabel: "Source: correction receipt",
            confidenceLabel: "Review state: not active",
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
        ContextRecallSurface(
            title: "Sensitive context is protected",
            summary: "This context requires explicit review before it appears in planning guidance.",
            sourceLabel: "Source: private profile context",
            confidenceLabel: "Review state: protected",
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
        ContextRecallSurface(
            title: "Planning default corrected",
            summary: "The corrected version is the only active version used for future recall surfaces.",
            sourceLabel: "Source: explicit correction",
            confidenceLabel: "Review state: user-confirmed",
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
        ContextRecallSurface(
            title: "No hidden memory",
            summary: "Ambitions has no recall result for this context and should say so plainly.",
            sourceLabel: "Source: none",
            confidenceLabel: "Review state: no result",
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
                title: "Time change can be undone",
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
