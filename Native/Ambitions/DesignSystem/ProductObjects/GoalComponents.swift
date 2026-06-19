import AmbitionsDesignSystem
import SwiftUI

struct GoalMissionControlLanes: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    let overview: GoalsOverview
    let onPrimaryAction: (GoalsAtlasPrimaryAction) -> Void

    var primaryGoal: GoalsAtlasSurfaceState? {
        overview.bands
            .first(where: { $0.kind == .activeDirection })?
            .cards
            .first ?? overview.bands.flatMap(\.cards).first
    }

    var pressureGoal: GoalsAtlasSurfaceState? {
        overview.bands
            .first(where: { $0.kind == .pressure })?
            .cards
            .first
    }

    var lanes: [GoalMissionControlLaneState] {
        let proof = primaryGoal?.proofSummary
        let blocker = pressureGoal
        let next = primaryGoal?.nextVisibleStep
        let momentum = primaryGoal?.momentumIntegrity

        return [
            GoalMissionControlLaneState(
                id: "history",
                title: "History",
                value: (proof?.count ?? 0) > 0 ? "\(proof?.count ?? 0) saved" : "Not yet",
                detail: proof?.latestTitle ?? proof?.detail ?? "Proof will appear after progress is saved.",
                symbolName: "checkmark.seal",
                state: (proof?.count ?? 0) > 0 ? .proof : .calm,
                level: min(1, max(0.18, Double(proof?.count ?? 0) / 4.0)),
                showsProofPulse: (proof?.count ?? 0) > 0
            ),
            GoalMissionControlLaneState(
                id: "blockers",
                title: "Blockers",
                value: blocker == nil ? "Clear" : blocker?.renderState.title ?? "Needs attention",
                detail: blocker?.nextStepHint ?? "No true blocker is leading the atlas right now.",
                symbolName: "exclamationmark.triangle",
                state: blocker == nil ? .calm : .pressured,
                level: blocker == nil ? 0.18 : pressureLevel(for: blocker)
            ),
            GoalMissionControlLaneState(
                id: "next-step",
                title: "Next Step",
                value: next?.isAvailable == false ? "Needs review" : "Ready",
                detail: next?.title ?? primaryGoal?.nextStepHint ?? overview.heroPrimaryAction.title,
                symbolName: "scope",
                state: next?.isAvailable == false ? .stale : .active,
                level: next?.isAvailable == false ? 0.38 : 0.74
            ),
            GoalMissionControlLaneState(
                id: "momentum",
                title: "Momentum",
                value: momentum?.title ?? primaryGoal?.progressLabel ?? "Quiet",
                detail: momentum?.detail ?? overview.hero.pressureSummary,
                symbolName: "waveform.path.ecg",
                state: momentum?.visualState == .success ? .proof : .active,
                level: max(0.24, primaryGoal?.progressValue ?? 0.28)
            ),
        ]
    }

    var body: some View {
        AdaptiveModuleChrome(
            title: "Your Direction",
            subtitle: "Life areas stay equal-weight while Thread Focus keeps one real thread connected to Today.",
            context: .goals,
            state: pressureGoal == nil ? .active : .pressured,
            evidence: "Photo-matched DAV06 reference inspected"
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                heroHeader

                MissionControlLaneGrid(
                    items: lanes.map(MissionControlLaneItem.init(atlasLane:)),
                    density: .expanded,
                    animatedReveal: true,
                    hasAppeared: hasAppeared
                )

                GoalsHeroPrimaryActionButton(
                    action: overview.heroPrimaryAction,
                    accessibilityIdentifier: "goals.hero-card",
                    handler: onPrimaryAction
                )
            }
        }
        .overlay(alignment: .topTrailing) {
            PressureGlow(
                level: pressureGoal == nil ? 0.28 : pressureLevel(for: pressureGoal),
                context: .goals,
                label: "Goal direction pressure"
            )
            .frame(width: 150)
            .padding(theme.spacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("goals.mission-control-lanes")
        .onAppear {
            hasAppeared = true
        }
    }

    var heroHeader: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Text("Feeds Today")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.accentWarm)

                Text(primaryGoal?.renderState.title ?? "Ready")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.stateStyle(for: primaryGoal?.renderState.visualState ?? .default).accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxxs)
                    .background(
                        Capsule(style: .continuous)
                            .fill(theme.stateStyle(for: primaryGoal?.renderState.visualState ?? .default).fill)
                    )
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(theme.stateStyle(for: primaryGoal?.renderState.visualState ?? .default).stroke, lineWidth: 1)
                    }
            }

            Text(primaryGoal?.title ?? overview.hero.title)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)

            Text(overview.hero.dominantTruth)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(overview.constellationAtlasCompactInspectionSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("goals.constellation-atlas.inspection-summary")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel([
            "Goals. Your Direction",
            primaryGoal?.title ?? overview.hero.title,
            primaryGoal?.renderState.title ?? "Ready",
            overview.hero.dominantTruth,
            overview.constellationAtlasCompactInspectionSummary
        ].joined(separator: ". "))
    }

    func pressureLevel(for goal: GoalsAtlasSurfaceState?) -> Double {
        guard let goal else { return 0.18 }

        switch goal.posture {
        case .atRisk:
            return 0.74
        case .crowded:
            return 0.66
        case .stalled:
            return 0.54
        case .active:
            return 0.42
        case .lowerPriority, .achieved:
            return 0.28
        }
    }
}

struct GoalMissionControlLaneState: Identifiable, Sendable {
    let id: String
    let title: String
    let value: String
    let detail: String
    let symbolName: String
    let state: LivingVisualState
    let level: Double
    var showsProofPulse: Bool = false
}

struct GoalsHeroSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let overview: GoalsOverview
    let onPrimaryAction: (GoalsAtlasPrimaryAction) -> Void

    var body: some View {
        ObjectStageHero(state: overview.heroPrimaryAction.state) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(overview.hero.eyebrow)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(overview.hero.title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(overview.hero.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(overview.hero.dominantTruth)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(overview.hero.pressureSummary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(overview.hero.contextPills) { pill in
                            TagPill(pill.title, icon: pill.icon, state: pill.state)
                        }
                    }
                }

                if overview.hero.attentionPills.isEmpty == false {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: theme.spacing.xs) {
                            ForEach(overview.hero.attentionPills) { pill in
                                TagPill(pill.title, icon: pill.icon, state: pill.state)
                            }
                        }
                    }
                }

                GoalsHeroPrimaryActionButton(
                    action: overview.heroPrimaryAction,
                    handler: onPrimaryAction
                )
            }
        }
        .accessibilityIdentifier("goals.hero-card")
        .ambitionPanelAccessibility()
    }
}

struct GoalsHeroPrimaryActionButton: View {
    @Environment(\.ambitionTheme) private var theme

    let action: GoalsAtlasPrimaryAction
    var accessibilityIdentifier = "goals.hero.primary-action"
    let handler: (GoalsAtlasPrimaryAction) -> Void

    var body: some View {
        Button {
            handler(action)
        } label: {
            HStack(alignment: .center, spacing: theme.spacing.sm) {
                Image(systemName: action.systemImage)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(action.title)
                        .font(theme.typography.bodyEmphasized)
                    Text(action.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(AmbitionButtonStyle(tier: .hero, state: action.state))
        .accessibilityHint(action.subtitle)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

struct GoalsWeekPressureSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let summary: GoalsWeekPressureSummary

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(summary.title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(summary.subtitle)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    Spacer()
                    TagPill(summary.pill.title, icon: summary.pill.icon, state: summary.pill.state)
                }

                HStack(spacing: theme.spacing.sm) {
                    metricBlock(title: "Alive", value: summary.leadingMetric)
                    metricBlock(title: "Stretch", value: summary.trailingMetric)
                }
            }
        }
        .accessibilityIdentifier("goals.week-pressure")
        .ambitionPanelAccessibility()
    }

    @ViewBuilder
    func metricBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
            Text(value)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
    }
}
