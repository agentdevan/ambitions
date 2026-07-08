import AmbitionsDesignSystem
import SwiftUI

enum GoalsLifeAreaTitle {
    static func title(for id: String) -> String {
        switch id {
        case "work": "Work"
        case "body": "Body"
        case "home": "Home"
        case "people": "People"
        case "self": "Self"
        case "future": "Future"
        default: id.split(separator: "-").map { $0.capitalized }.joined(separator: " ")
        }
    }
}

struct AreaDetailScreen: View {
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let lifeAreaID: String
    @State private var viewModel = GoalsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    DegradedStateSurface(state: DegradedStateOrchestrator.objectLoading(.missionControlTimeSpine))
                case .failed:
                    DegradedStateSurface(
                        state: DegradedStateOrchestrator.objectUnavailable(.missionControlTimeSpine),
                        primaryAccessibilityIdentifier: "goals.area-detail.retry-button",
                        onPrimaryAction: {
                            Task { await viewModel.refresh(using: featureFactory.goalsService) }
                        }
                    )
                case let .loaded(overview):
                    if let region = GoalsLifeAreaAtlasRegion.region(id: lifeAreaID, in: overview) {
                        AreaDetailLoadedView(
                            region: region,
                            onOpenGoal: openGoal,
                            onCapture: openCapture
                        )
                    } else {
                        AreaDetailUnavailableView(lifeAreaID: lifeAreaID)
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .accessibilityIdentifier("goals.area-detail.screen")
        .scrollIndicators(.hidden)
        .background {
            LivingSurfaceBackground(context: .goals, state: .active, intensity: 0.72)
                .stageOwnedIgnoresSafeArea()
        }
        .refreshable {
            await viewModel.refresh(using: featureFactory.goalsService)
        }
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            await viewModel.load(using: featureFactory.goalsService)
        }
    }

    private func openGoal(_ target: GoalRouteTarget) {
        shell.navigation.openGoalDetail(target)
    }

    private func openCapture(_ kind: CaptureTypedRouteKind) {
        shell.navigation.presentTypedCaptureComposer(
            kind: kind,
            source: .goalsCreate,
            lifeAreaID: lifeAreaID
        )
    }

    private var shell: AppShellCapability {
        guard let appShellCapability else {
            preconditionFailure("App shell capability must be injected.")
        }
        return appShellCapability
    }

    private var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }
}

private struct AreaDetailLoadedView: View {
    @Environment(\.ambitionTheme) private var theme

    let region: GoalsLifeAreaAtlasRegion
    let onOpenGoal: (GoalRouteTarget) -> Void
    let onCapture: (CaptureTypedRouteKind) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            header
            creationRow
            goalsSection
            looseObjectsSection
            historySection
            settingsSection
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(region.accessibilityLabel)
        .accessibilityValue(region.accessibilityValue)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .center, spacing: theme.spacing.md) {
                Image(systemName: region.symbolName)
                    .font(.system(size: theme.icon.mediumSize, weight: .semibold))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(theme.colors.accentPrimary.opacity(0.14)))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(region.title)
                        .font(theme.typography.title)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(region.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityIdentifier("goals.area-detail.header")
    }

    private var creationRow: some View {
        HStack(spacing: theme.spacing.sm) {
            areaAction("Goal", symbol: "target", kind: .goalSeed)
            areaAction("Step", symbol: "smallcircle.filled.circle", kind: .stepSeed)
            areaAction("Thought", symbol: "sparkle", kind: .noteThought)
            areaAction("Proof", symbol: "seal", kind: .proof)
        }
        .accessibilityIdentifier("goals.area-detail.capture-actions")
    }

    private func areaAction(_ title: String, symbol: String, kind: CaptureTypedRouteKind) -> some View {
        Button {
            onCapture(kind)
        } label: {
            Label(title, systemImage: symbol)
                .font(theme.typography.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity, minHeight: theme.panel.minimumTapTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
        .accessibilityIdentifier("goals.area-detail.capture.\(kind.rawValue)")
    }

    @ViewBuilder
    private var goalsSection: some View {
        AreaDetailSection(title: "Goals", subtitle: region.activeGoalCount > 0 ? "Active threads in this area." : "No active goals here yet.") {
            if region.goalReferences.isEmpty {
                quietLine("Add a goal when this area has direction that should keep history.")
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(region.goalReferences) { reference in
                        Button {
                            onOpenGoal(GoalRouteTarget(goalID: reference.id))
                        } label: {
                            HStack(spacing: theme.spacing.sm) {
                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                    Text(reference.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(reference.subtitle)
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }
                            .padding(theme.spacing.md)
                            .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("goals.area-detail.goal.\(reference.id)")
                    }
                }
            }
        }
    }

    private var looseObjectsSection: some View {
        AreaDetailSection(title: "Loose steps and thoughts", subtitle: "Items can stay here until they belong to a goal.") {
            if region.looseStepCount == 0 && region.thoughtCount == 0 {
                quietLine("Nothing loose in this area.")
            } else {
                HStack(spacing: theme.spacing.sm) {
                    if region.looseStepCount > 0 {
                        TagPill("\(region.looseStepCount) steps", state: .default)
                    }
                    if region.thoughtCount > 0 {
                        TagPill("\(region.thoughtCount) thoughts", state: .default)
                    }
                }
            }
        }
    }

    private var historySection: some View {
        AreaDetailSection(title: "History", subtitle: "Accomplished goals and receipts stay inspectable.") {
            if region.proofCount == 0 && region.receiptCount == 0 {
                quietLine("History appears after progress is saved.")
            } else {
                HStack(spacing: theme.spacing.sm) {
                    if region.proofCount > 0 {
                        TagPill("\(region.proofCount) proof", state: .selected)
                    }
                    if region.receiptCount > 0 {
                        TagPill("\(region.receiptCount) receipts", state: .success)
                    }
                }
            }
        }
    }

    private var settingsSection: some View {
        AreaDetailSection(title: "Area settings", subtitle: "Rename, icon, reorder, and hide are staged for the local area model.") {
            quietLine("Customization is staged in the area model; no unsupported mutation is shown as saved.")
        }
    }

    private func quietLine(_ text: String) -> some View {
        Text(text)
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct AreaDetailUnavailableView: View {
    @Environment(\.ambitionTheme) private var theme

    let lifeAreaID: String

    var body: some View {
        AreaDetailSection(title: GoalsLifeAreaTitle.title(for: lifeAreaID), subtitle: "This area could not load.") {
            Text("Return to Goals and open the area again.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}

private struct AreaDetailSection<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            content
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfacePrimary.opacity(0.72))
        )
    }
}
