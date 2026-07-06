import AmbitionsDesignSystem
import SwiftUI

struct LifePathThreadSurface: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: LifePathThreadState

    var body: some View {
        GoalDetailSectionSurface(title: state.title, subtitle: state.subtitle) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                if dynamicTypeSize.isAccessibilitySize {
                    accessibleThread
                } else {
                    visualThread
                }

                if state.proofBeads.isEmpty == false {
                    proofBeads
                }

                if state.riskPinches.isEmpty == false {
                    riskPinches
                }

                if state.alternateRouteFolds.isEmpty == false {
                    alternateRouteFold
                }

                sourceFold
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
        .accessibilityIdentifier("goal-detail.life-path-thread")
    }

    var visualThread: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(state.nodes.enumerated()), id: \.element.id) { index, node in
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(spacing: theme.spacing.xs) {
                        nodeMarker(node)

                        if index < state.nodes.count - 1 {
                            Capsule(style: .continuous)
                                .fill(theme.stateStyle(for: node.state).stroke)
                                .frame(width: 3, height: 42)
                                .accessibilityHidden(true)
                        }
                    }

                    nodeBody(node)
                        .padding(.bottom, index < state.nodes.count - 1 ? theme.spacing.sm : 0)
                }
            }
        }
    }

    var accessibleThread: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(state.nodes) { node in
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    nodeMarker(node)
                    nodeBody(node)
                }
            }
        }
    }

    func nodeMarker(_ node: LifePathThreadNode) -> some View {
        let style = theme.stateStyle(for: node.state)

        return ZStack {
            Circle()
                .fill(style.fill)
                .frame(width: 42, height: 42)
                .overlay(Circle().stroke(style.stroke, lineWidth: 1))

            Image(systemName: node.symbolName)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(style.accent)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottomTrailing) {
            Text("\(node.order)")
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textPrimary)
                .frame(width: 20, height: 20)
                .background(Circle().fill(theme.colors.surfaceOverlay))
                .overlay(Circle().stroke(style.stroke, lineWidth: 1))
        }
    }

    func nodeBody(_ node: LifePathThreadNode) -> some View {
        let style = theme.stateStyle(for: node.state)

        return VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Text(node.roleLabel)
                    .font(theme.typography.micro)
                    .foregroundStyle(style.accent)

                Text(node.statusLabel)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)

                Spacer(minLength: theme.spacing.xs)

                TagPill(node.stepCountLabel, state: node.state)
            }

            Text(node.title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(node.summary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Label(node.markerLabel, systemImage: node.symbolName)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(style.stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Order \(node.order). \(node.roleLabel). \(node.title). \(node.nonColorMeaning)")
    }

    var proofBeads: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            SectionHeader(title: "Proof beads", subtitle: "Evidence attaches to the thread without becoming the path itself.")
            ForEach(state.proofBeads) { bead in
                markerPill(title: bead.title, summary: bead.summary, symbolName: "checkmark.seal", state: bead.state)
            }
        }
    }

    var riskPinches: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            SectionHeader(title: "Risk pinch", subtitle: "Friction is marked by role and copy, not color alone.")
            ForEach(state.riskPinches) { pinch in
                markerPill(title: pinch.title, summary: pinch.summary, symbolName: "exclamationmark.triangle", state: pinch.state)
            }
        }
    }

    var alternateRouteFold: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            SectionHeader(title: "AlternateRouteFold", subtitle: "Branches stay folded until the user reviews tradeoffs.")
            ForEach(state.alternateRouteFolds) { fold in
                markerPill(title: fold.title, summary: "\(fold.summary) \(fold.reviewLabel)", symbolName: "arrow.triangle.branch", state: fold.state)
            }
        }
    }

    var sourceFold: some View {
        let source = state.sourceFold

        return ProductObjectFrame(state: source.state) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Label(source.title, systemImage: "doc.text.magnifyingglass")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)

                Text(source.summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)

                Text(source.breadcrumbLabels.joined(separator: " > "))
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .lineLimit(2)

                Text(source.privacyLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }

    func markerPill(title: String, summary: String, symbolName: String, state: AmbitionVisualState) -> some View {
        let style = theme.stateStyle(for: state)

        return HStack(alignment: .top, spacing: theme.spacing.xs) {
            Image(systemName: symbolName)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(style.accent)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.xs)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(style.fill))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(style.stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(summary)")
    }
}

struct GoalDetailNextMovementSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let movement: GoalDetailNextMovement

    var body: some View {
        GoalDetailSectionSurface(title: "What matters next", subtitle: "One step first, before the rest of the path.") {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(movement.title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(movement.summary)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    Spacer()
                    TagPill(movement.timingLabel, state: movement.state)
                }

                Text(movement.rationale)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityIdentifier("goal-detail.next-movement")
    }
}

struct GoalDetailTrajectorySurface: View {
    @Environment(\.ambitionTheme) private var theme

    let trajectory: GoalDetailTrajectoryState

    var body: some View {
        GoalDetailSectionSurface(title: "Current phase and momentum", subtitle: "Phase truth stays strategic instead of reading like admin.") {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(trajectory.phaseTitle)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(trajectory.phaseSummary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    trajectoryLine(title: "Milestone", detail: trajectory.milestoneSummary)
                    trajectoryLine(title: "Momentum", detail: trajectory.momentumSummary)
                    trajectoryLine(title: "Timeline", detail: trajectory.timelineSummary)
                }
            }
        }
    }

    @ViewBuilder
    func trajectoryLine(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
            Text(detail)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}

struct GoalDetailRecentMovementSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let movement: GoalDetailRecentMovementState

    var body: some View {
        GoalDetailSectionSurface(title: movement.title, subtitle: movement.summary) {
            if movement.items.isEmpty {
                Text("No recent movement is visible yet.")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(movement.items) { item in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            TagPill(item.categoryLabel, state: item.state)
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(item.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(item.subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                Text(item.timestamp)
                                    .font(theme.typography.micro)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("goal-detail.recent-movement")
    }
}

struct GoalActionGrid: View {
    @Environment(\.ambitionTheme) private var theme

    let actions: [GoalDetailActionState]
    let handler: (GoalDetailActionKind) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: theme.spacing.xs)], spacing: theme.spacing.xs) {
            ForEach(actions) { action in
                Button {
                    handler(action.kind)
                } label: {
                    Label(action.title, systemImage: action.systemImage)
                        .font(theme.typography.caption)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .padding(.vertical, theme.spacing.xs)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: action.state))
            }
        }
    }
}
