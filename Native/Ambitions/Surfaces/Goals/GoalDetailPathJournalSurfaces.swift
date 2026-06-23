import AmbitionsDesignSystem
import SwiftUI

struct GoalDetailProfileSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let detail: GoalDetailPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(alignment: .top, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(detail.headline.title)
                        .font(theme.typography.title)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(detail.headline.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: theme.spacing.sm)
                TagPill(detail.headline.renderState.title, state: detail.headline.renderState.visualState)
            }

            Text(detail.intent)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfacePrimary.opacity(0.74))
        )
        .accessibilityIdentifier("goal-detail.profile")
    }
}

struct GoalDetailPathFieldSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let detail: GoalDetailPresentation
    let onAction: (GoalDetailActionKind) -> Void

    var body: some View {
        GoalDetailSectionSurface(title: "Path", subtitle: pathSubtitle) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: theme.spacing.md) {
                    ForEach(nodes) { node in
                        GoalDetailPathNodeView(node: node)
                    }
                }
                .padding(.vertical, theme.spacing.xs)
            }
            .accessibilityIdentifier("goal-detail.path-field")

            HStack(spacing: theme.spacing.sm) {
                Button {
                    onAction(.showPath)
                } label: {
                    Label("Review path", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .default))

                Text("Move, replace, split, and regenerate stay unavailable until they can preserve history.")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var pathSubtitle: String {
        if detail.primaryStepID == nil {
            return "Choose the next step before the path asks for more."
        }
        return "Past history sits left, the current step stays centered, future path stays right."
    }

    private var nodes: [GoalDetailPathNodeState] {
        if detail.pathStages.isEmpty == false {
            return detail.pathStages.map(GoalDetailPathNodeState.init(stage:))
        }

        if let movement = detail.nextMovement {
            return [
                GoalDetailPathNodeState(id: "history", title: "History", subtitle: detail.progress.label, kind: "Proof", state: .default),
                GoalDetailPathNodeState(id: "current", title: movement.title, subtitle: movement.summary, kind: "Step", state: movement.state),
                GoalDetailPathNodeState(id: "future", title: "Next path", subtitle: "Review before Ambitions changes direction.", kind: "Decision", state: .default)
            ]
        }

        return [
            GoalDetailPathNodeState(id: "choose-next", title: "Choose next step", subtitle: "Capture can add a step, proof, or thought.", kind: "Step", state: .selected)
        ]
    }
}

private struct GoalDetailPathNodeState: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let kind: String
    let state: AmbitionVisualState

    init(id: String, title: String, subtitle: String, kind: String, state: AmbitionVisualState) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.kind = kind
        self.state = state
    }

    init(stage: GoalPathStage) {
        let kind: String = {
            switch stage.position {
            case .completed:
                return "Proof"
            case .current:
                return "Step"
            case .blocked:
                return "Recovery"
            case .upcoming:
                return "Decision"
            }
        }()
        self.init(
            id: stage.id,
            title: stage.title,
            subtitle: stage.summary,
            kind: kind,
            state: stage.state
        )
    }
}

private struct GoalDetailPathNodeView: View {
    @Environment(\.ambitionTheme) private var theme

    let node: GoalDetailPathNodeState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            TagPill(node.kind, state: node.state)
            Text(node.title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
            Text(node.subtitle)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(3)
        }
        .frame(width: 210, alignment: .topLeading)
        .frame(minHeight: 132, alignment: .topLeading)
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(node.kind). \(node.title). \(node.subtitle)")
    }
}

struct GoalDetailJournalSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let detail: GoalDetailPresentation

    var body: some View {
        GoalDetailSectionSurface(title: "Journal", subtitle: "Receipts and corrections stay append-only.") {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                if detail.evidence.isEmpty && detail.history.isEmpty {
                    Text("Journal entries appear after proof, revisions, or saved progress.")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    ForEach(detail.evidence.prefix(3)) { item in
                        journalRow(title: item.title, subtitle: item.subtitle, timestamp: item.timestamp)
                    }
                    ForEach(detail.history.prefix(3)) { item in
                        journalRow(title: item.title, subtitle: item.subtitle, timestamp: item.timestamp)
                    }
                }
            }
        }
        .accessibilityIdentifier("goal-detail.journal")
    }

    private func journalRow(title: String, subtitle: String, timestamp: String) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "seal")
                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                .foregroundStyle(theme.colors.accentPrimary)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                Text(timestamp)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
    }
}
