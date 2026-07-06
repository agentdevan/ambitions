import AmbitionsDesignSystem
import SwiftUI

struct NorthStarRailItem: View {
    @Environment(\.ambitionTheme) private var theme

    let item: GoalsNorthStarRailItemState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.xs) {
                Image(systemName: "north.star")
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.stateStyle(for: item.state).accent)
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.lifeAreaLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            Text(item.subtitle)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(3)

            HStack(spacing: theme.spacing.xs) {
                TagPill(item.postureLabel, state: item.state)
                TagPill(item.readinessLabel, state: item.canBeShaped ? .selected : .default)
            }

            Text(item.canBeShaped ? item.shapeIntoGoalLabel : item.suggestedNextAction)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.stateStyle(for: item.state).stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(item.accessibilityValue)
        .accessibilityHint(item.accessibilityHint)
    }
}

struct GoalsOneStepGoalsPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsOneStepGoalsPanelState
    let onPromote: (GoalsOneStepGoalPanelItemState) -> Void

    var body: some View {
        ProductObjectFrame {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                if state.items.isEmpty {
                    EmptyStateCard(
                        title: state.emptyTitle,
                        message: state.emptyMessage,
                        icon: "checkmark.circle"
                    )
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.items) { item in
                            OneStepGoalPanelRow(item: item, onPromote: onPromote)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
        .accessibilityIdentifier("goals.one-step-goals-panel")
        .ambitionPanelAccessibility()
    }
}

struct OneStepGoalPanelRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: GoalsOneStepGoalPanelItemState
    let onPromote: (GoalsOneStepGoalPanelItemState) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: theme.spacing.xxxs) {
                    TagPill(item.statusLabel, state: item.state)
                    Text(item.areaLabel)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            HStack(alignment: .center, spacing: theme.spacing.xs) {
                if let timingLabel = item.timingLabel {
                    TagPill(timingLabel, icon: "calendar", state: item.state)
                }
                TagPill(item.suggestedNextAction, state: item.state)
                Spacer(minLength: theme.spacing.xs)
                if item.canPromoteToGoal {
                    Button {
                        onPromote(item)
                    } label: {
                        Label(item.promoteLabel, systemImage: "arrow.up.right.circle")
                            .font(theme.typography.caption)
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                    .accessibilityHint("Opens goal creation. No Goal is created automatically.")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.stateStyle(for: item.state).stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(item.accessibilityValue)
        .accessibilityHint(item.accessibilityHint)
    }
}

struct GoalsAtlasBandSection: View {
    @Environment(\.ambitionTheme) private var theme

    let band: GoalsAtlasBand

    var body: some View {
        ProductObjectFrame {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: band.title, subtitle: band.subtitle)

                if band.cards.isEmpty {
                    EmptyStateCard(
                        title: "Nothing to surface here yet",
                        message: band.subtitle,
                        icon: "scope"
                    )
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(band.cards) { card in
                            NavigationLink(value: card.target) {
                                GoalsAtlasSurfaceView(card: card)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("goals.surface.open.\(card.target.goalID ?? card.target.draftID ?? card.id)")
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("goals.band.\(band.kind.rawValue)")
        .ambitionPanelAccessibility()
    }
}

struct GoalsAtlasSurfaceView: View {
    @Environment(\.ambitionTheme) private var theme

    let card: GoalsAtlasSurfaceState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack(spacing: theme.spacing.xs) {
                        TagPill(card.lifecycleState.title, icon: card.lifecycleState.icon, state: card.lifecycleState.visualState)
                        TagPill(card.weather.title, icon: card.weather.icon, state: card.weather.visualState)
                    }

                    Text(card.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)

                    Text(card.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                VStack(alignment: .trailing, spacing: theme.spacing.xxxs) {
                    Text(card.modeLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(card.timingLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text("Next visible step")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(card.nextVisibleStep.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                if card.nextVisibleStep.detail.isEmpty == false {
                    Text(card.nextVisibleStep.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacing.sm)
            .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceSecondary.opacity(0.7)))

            HStack(alignment: .top, spacing: theme.spacing.sm) {
                signalColumn(title: "History", headline: card.proofSummary.title, body: card.proofSummary.detail, state: card.proofSummary.visualState)
                signalColumn(title: "Weather", headline: card.weather.title, body: card.weatherSummary, state: card.weather.visualState)
            }

            signalColumn(title: "Momentum", headline: card.momentumIntegrity.title, body: card.momentumIntegrity.detail, state: card.momentumIntegrity.visualState)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                if let supportLabel = card.supportLabel {
                    Text(supportLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }

                if let shellSummary = card.shellSummary {
                    GoalShellSummaryCompactView(summary: shellSummary)
                        .padding(.top, theme.spacing.xxxs)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityIdentifier("goals.surface.\(card.id)")
        .accessibilityLabel("\(card.title). State \(card.lifecycleState.title). Weather \(card.weather.title), \(card.weatherSummary). Next visible step, \(card.nextVisibleStep.title). Proof, \(card.proofSummary.title). Momentum, \(card.momentumIntegrity.title).")
        .ambitionPanelAccessibility()
    }

    @ViewBuilder
    func signalColumn(title: String, headline: String, body: String, state: AmbitionVisualState) -> some View {
        let style = theme.stateStyle(for: state)
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
            Text(headline)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
            Text(body)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(style.fill))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(style.stroke, lineWidth: 1))
    }
}

struct GoalsLowerPriorityDisclosureSection: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsLowerPriorityState
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        ProductObjectFrame {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle) {
                    Button(isExpanded ? "Hide" : state.disclosureTitle, action: onToggle)
                        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                        .accessibilityIdentifier("goals.lower-priority.toggle")
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.cards) { card in
                            NavigationLink(value: card.target) {
                                GoalsAtlasSurfaceView(card: card)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .transition(.ambitionPanel)
                }
            }
        }
        .accessibilityIdentifier("goals.band.lower-priority")
        .ambitionPanelAccessibility()
    }
}
