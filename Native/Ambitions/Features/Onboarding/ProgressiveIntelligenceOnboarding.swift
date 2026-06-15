import AmbitionsDesignSystem
import SwiftUI

struct OnboardingRouteDecision: Sendable, Equatable {
    let choice: OnboardingEntryChoice
    let selectedTab: AppTab
    let overlayIntent: ShellCommandIntent?
    let overlaySource: ShellCommandEntrySource?
    let presentationContext: ShellCommandPresentationContext
}

protocol OnboardingServicing: Sendable {
    func complete(choice: OnboardingEntryChoice, now: Date) async throws -> OnboardingRouteDecision
}

struct RepositoryBackedOnboardingService: OnboardingServicing {
    let appStateRepository: any AppStateRepository

    func complete(choice: OnboardingEntryChoice, now: Date) async throws -> OnboardingRouteDecision {
        var state = try await appStateRepository.loadState()
        state.hasCompletedOnboarding = true
        state.onboardingVersion = 1
        state.onboardingCompletedAt = ISO8601DateFormatter().string(from: now)
        state.onboardingEntryChoice = choice
        try await appStateRepository.saveState(state)
        return Self.routeDecision(for: choice)
    }

    static func routeDecision(for choice: OnboardingEntryChoice) -> OnboardingRouteDecision {
        switch choice {
        case .createFirstGoal:
            return OnboardingRouteDecision(
                choice: choice,
                selectedTab: .goals,
                overlayIntent: .newGoal,
                overlaySource: .shellCompose,
                presentationContext: .createGoal
            )
        case .captureFirst:
            return OnboardingRouteDecision(
                choice: choice,
                selectedTab: .today,
                overlayIntent: .quickCapture,
                overlaySource: .shellCompose,
                presentationContext: .quickCapture
            )
        case .enterToday:
            return OnboardingRouteDecision(
                choice: choice,
                selectedTab: .today,
                overlayIntent: nil,
                overlaySource: nil,
                presentationContext: .neutral
            )
        }
    }
}

struct ProgressiveIntelligenceOnboardingView: View {
    @Environment(\.ambitionTheme) private var theme

    let onComplete: (OnboardingEntryChoice) -> Void

    @State private var page: Page = .orientation
    @State private var selectedChoice: OnboardingEntryChoice = .createFirstGoal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    orientationPage
                        .tag(Page.orientation)
                    startPage
                        .tag(Page.start)
                    trustPage
                        .tag(Page.trust)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                footer
            }
            .background(AppCanvasView { Color.clear })
            .navigationTitle("Welcome")
            .toolbar(.hidden, for: .navigationBar)
        }
        .accessibilityIdentifier("onboarding.screen")
    }

    private var orientationPage: some View {
        return onboardingPage(
            eyebrow: "Ambitions",
            title: ActivationContract.orientationTitle,
            subtitle: ActivationContract.orientationSubtitle,
            rows: []
        ) {
            copySectionCard(
                title: "Primary objects",
                subtitle: "Ambitions organizes life through these five places.",
                rows: ActivationContract.onboardingSurfaceRows
            )

            copySectionCard(
                title: "What is known now",
                subtitle: "The first-run path only needs one real thing and one clear next move.",
                rows: ActivationContract.onboardingKnownNowRows
            )

            copySectionCard(
                title: "Setup boundaries",
                subtitle: "These parts stay optional until you need them.",
                rows: ActivationContract.onboardingBoundaryRows
            )
        }
    }

    private var startPage: some View {
        let goalPromise = ActivationContract.promise(for: .firstMeaningfulGoal)
        let capturePromise = ActivationContract.promise(for: .firstCapturedLifeObject)
        let todayPromise = ActivationContract.promise(for: .firstTodayContract)

        return onboardingPage(
            eyebrow: "Start small",
            title: ActivationContract.startTitle,
            subtitle: ActivationContract.startSubtitle,
            rows: []
        ) {
            choiceRow(
                choice: .createFirstGoal,
                title: goalPromise.primaryActionTitle ?? goalPromise.title,
                subtitle: goalPromise.explanation,
                icon: "target"
            )
            choiceRow(
                choice: .captureFirst,
                title: capturePromise.primaryActionTitle ?? capturePromise.title,
                subtitle: capturePromise.explanation,
                icon: "tray.and.arrow.down"
            )
            choiceRow(
                choice: .enterToday,
                title: todayPromise.primaryActionTitle ?? todayPromise.title,
                subtitle: todayPromise.explanation,
                icon: AppTab.today.systemImage
            )
        }
    }

    private var trustPage: some View {
        let trustMessage = ActivationContract.trustMessage

        return onboardingPage(
            eyebrow: "Trust",
            title: trustMessage.title,
            subtitle: trustMessage.explanation,
            rows: trustMessage.rows
        )
    }

    @ViewBuilder
    private func onboardingPage(
        eyebrow: String,
        title: String,
        subtitle: String,
        rows: [ActivationCopyRow],
        @ViewBuilder extraContent: () -> some View = { EmptyView() }
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                HeroCard(state: .selected) {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        Text(eyebrow)
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.accentWarm)
                        Text(title)
                            .font(theme.typography.hero)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(subtitle)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if rows.isEmpty == false {
                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            ForEach(rows, id: \.title) { row in
                                HStack(alignment: .top, spacing: theme.spacing.sm) {
                                    Image(systemName: row.icon)
                                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                        Text(row.title)
                                            .font(theme.typography.bodyEmphasized)
                                            .foregroundStyle(theme.colors.textPrimary)
                                        Text(row.detail)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(theme.spacing.lg)
                    }
                }

                extraContent()
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.xl)
        }
        .scrollIndicators(.hidden)
    }

    private func copySectionCard(title: String, subtitle: String, rows: [ActivationCopyRow]) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                ForEach(rows, id: \.title) { row in
                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        Image(systemName: row.icon)
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(theme.colors.textSecondary)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(row.title)
                                .font(theme.typography.bodyEmphasized)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(row.detail)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                }
            }
            .padding(theme.spacing.lg)
        }
    }

    private func choiceRow(choice: OnboardingEntryChoice, title: String, subtitle: String, icon: String) -> some View {
        Button {
            selectedChoice = choice
        } label: {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                Spacer()
                Image(systemName: selectedChoice == choice ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(selectedChoice == choice ? theme.colors.success : theme.colors.textTertiary)
            }
            .padding(theme.spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.colors.surfaceOverlay)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(selectedChoice == choice ? theme.colors.strokeStrong : theme.colors.strokeSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("onboarding.choice.\(choice.rawValue)")
    }

    private var footer: some View {
        HStack(spacing: theme.spacing.sm) {
            Button {
                moveBackward()
            } label: {
                Label("Back", systemImage: "chevron.left")
            }
            .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: .default))
            .disabled(page == .orientation)
            .accessibilityIdentifier("onboarding.back-button")

            Spacer()

            Button {
                moveForward()
            } label: {
                Label(page == .trust ? startButtonTitle : "Next", systemImage: page == .trust ? startButtonIcon : "chevron.right")
            }
            .buttonStyle(AmbitionButtonStyle(tier: .hero, state: .selected))
            .accessibilityIdentifier(page == .trust ? "onboarding.start-button" : "onboarding.next-button")
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, theme.spacing.md)
        .background(theme.surfaces.overlayGradient.opacity(theme.surfaces.backgroundBlurOpacity))
    }

    private var startButtonTitle: String {
        switch selectedChoice {
        case .createFirstGoal: "Create first goal"
        case .captureFirst: "Capture first"
        case .enterToday: "Enter Today"
        }
    }

    private var startButtonIcon: String {
        switch selectedChoice {
        case .createFirstGoal: "target"
        case .captureFirst: "tray.and.arrow.down"
        case .enterToday: AppTab.today.systemImage
        }
    }

    private func moveForward() {
        switch page {
        case .orientation:
            page = .start
        case .start:
            page = .trust
        case .trust:
            onComplete(selectedChoice)
        }
    }

    private func moveBackward() {
        switch page {
        case .orientation:
            return
        case .start:
            page = .orientation
        case .trust:
            page = .start
        }
    }
}

private enum Page: Int, Hashable {
    case orientation
    case start
    case trust
}
