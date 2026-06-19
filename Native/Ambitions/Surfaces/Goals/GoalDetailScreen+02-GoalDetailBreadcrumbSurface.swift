import AmbitionsDesignSystem
import SwiftUI

struct GoalDetailBreadcrumbSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailBreadcrumbState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(
                    title: state.title,
                    subtitle: state.fallbackUsed ? "Relationship data is thin, so this falls back to the current goal." : "Where this goal sits in the larger system."
                )
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(Array(state.labels.enumerated()), id: \.offset) { index, label in
                            HStack(spacing: theme.spacing.xs) {
                                Text(label)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(index == state.labels.count - 1 ? theme.colors.textPrimary : theme.colors.textSecondary)
                                    .padding(.horizontal, theme.spacing.sm)
                                    .padding(.vertical, theme.spacing.xs)
                                    .background(RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous).fill(theme.colors.surfaceOverlay))
                                if index < state.labels.count - 1 {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                        .foregroundStyle(theme.colors.textTertiary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(state.labels.joined(separator: ", "))
        .accessibilityIdentifier("goal-detail.breadcrumb")
        .ambitionPanelAccessibility()
    }
}

struct GoalDetailTimelineSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailTimelineState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(state.items) { item in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(theme.stateStyle(for: item.state).accent)
                                    .frame(width: 10, height: 10)
                                Rectangle()
                                    .fill(theme.colors.strokeSubtle)
                                    .frame(width: 1, height: 34)
                            }
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                HStack(spacing: theme.spacing.xs) {
                                    Text(item.kind.title)
                                        .font(theme.typography.micro)
                                        .foregroundStyle(theme.colors.textTertiary)
                                    if item.isFuture {
                                        TagPill("Possible next", state: .default)
                                    }
                                }
                                Text(item.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(item.summary)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("goal-detail.timeline")
        .ambitionPanelAccessibility()
    }
}

struct GoalPathBuilderSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalPathBuilderState

    var body: some View {
        GoalDetailSectionSurface(title: state.title, subtitle: state.subtitle) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                breadcrumb
                todayConnection
                phases

                if state.forks.isEmpty == false {
                    forks
                    tradeoffReview
                }

                if state.proofRequirements.isEmpty == false {
                    proofRequirements
                }

                roadmapList
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
        .accessibilityIdentifier("goal-detail.path-builder")
    }

    var breadcrumb: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(Array(state.breadcrumbLabels.enumerated()), id: \.offset) { index, label in
                Text(label)
                    .font(theme.typography.micro)
                    .foregroundStyle(index == state.breadcrumbLabels.count - 1 ? theme.colors.textPrimary : theme.colors.textTertiary)
                if index < state.breadcrumbLabels.count - 1 {
                    Image(systemName: "chevron.right")
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .accessibilityHidden(true)
    }

    var todayConnection: some View {
        AppCard(state: .selected) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Label("Today connection", systemImage: "scope")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(state.todayConnectionTitle)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(state.todayConnectionSummary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                Text(state.planConnectionSummary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
    }

    var phases: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(title: "Path shape", subtitle: "Phases stay connected to proof and the next step.")
            ForEach(state.phases) { phase in
                WidgetCard(state: phase.state) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(phase.title)
                                .font(theme.typography.section)
                                .foregroundStyle(theme.colors.textPrimary)
                            Spacer()
                            TagPill(phase.statusLabel, state: phase.state)
                        }
                        Text(phase.summary)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                        Label(phase.dependencySummary, systemImage: "point.3.connected.trianglepath.dotted")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        Label(phase.proofSummary, systemImage: "checkmark.seal")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                }
            }
        }
    }

    var forks: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(title: "Route options", subtitle: "Indicators only; compare before changing the path.")
            ForEach(state.forks) { fork in
                WidgetCard(state: fork.state) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(fork.title)
                                .font(theme.typography.section)
                                .foregroundStyle(theme.colors.textPrimary)
                            Spacer()
                            TagPill(fork.freshnessLabel, state: fork.state)
                        }
                        Text(fork.summary)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                        Text(fork.basisSummary)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        Text(fork.decisionPrompt)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
            }
        }
    }

    var tradeoffReview: some View {
        let review = state.tradeoffReview

        return VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(title: review.title, subtitle: review.subtitle)
            ForEach(review.lanes) { lane in
                WidgetCard(state: lane.state) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        HStack(alignment: .firstTextBaseline) {
                            Label(lane.title, systemImage: "arrow.triangle.branch")
                                .font(theme.typography.section)
                                .foregroundStyle(theme.colors.textPrimary)
                            Spacer()
                            TagPill("Review first", state: lane.state)
                        }
                        Text(lane.summary)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                        Label(lane.effortLabel, systemImage: "wrench.and.screwdriver")
                        Label(lane.timeLabel, systemImage: "clock")
                        Label(lane.energyLabel, systemImage: "battery.75percent")
                        Label(lane.recoveryLabel, systemImage: "arrow.uturn.backward")
                        Label(lane.reviewRequirementLabel, systemImage: "hand.raised")
                    }
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(review.title)
        .accessibilityValue(review.accessibilitySummary)
        .accessibilityHint("Review route tradeoffs before choosing, editing, or parking a path.")
        .accessibilityIdentifier("goal-detail.tradeoff-review")
    }

    var proofRequirements: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(title: "Proof checks", subtitle: "Evidence keeps the path shape honest.")
            ForEach(state.proofRequirements) { proof in
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Image(systemName: "checkmark.seal")
                        .foregroundStyle(theme.colors.accentPrimary)
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        HStack {
                            Text(proof.title)
                                .font(theme.typography.bodyEmphasized)
                                .foregroundStyle(theme.colors.textPrimary)
                            Spacer()
                            TagPill(proof.handoffLabel, state: proof.state)
                        }
                        Text(proof.summary)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
                .padding(theme.spacing.sm)
                .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
            }
        }
    }

    var roadmapList: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            SectionHeader(title: state.roadmapListTitle, subtitle: state.roadmapListSummary)
            ForEach(state.phases) { phase in
                Label("\(phase.title): \(phase.statusLabel)", systemImage: "list.bullet")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
            Text(state.decisionReceiptSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
        }
    }
}

struct GoalDetailAssumptionsSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let assumptions: [GoalDetailAssumptionState]

    var body: some View {
        GoalDetailSectionSurface(title: "Assumptions", subtitle: "Correctable reads Ambitions is using for this goal.") {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                ForEach(assumptions) { assumption in
                    AppCard(state: assumption.state) {
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                Text(assumption.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Spacer()
                                TagPill(assumption.status, state: assumption.state)
                            }
                            Text(assumption.whyItMatters)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                            if let correctionLabel = assumption.correctionLabel {
                                Text(correctionLabel)
                                    .font(theme.typography.micro)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("goal-detail.assumptions")
    }
}

struct GoalDetailReviewTrailSurface: View {
    let state: GoalDetailReviewTrailState

    var body: some View {
        ProofRelationshipTracePrimitiveStage(
            role: .relationship,
            title: state.title,
            subtitle: state.subtitle,
            accessibilityIdentifier: "goal-detail.review-trail"
        ) {
            ForEach(state.items) { item in
                ProofRelationshipTracePrimitiveLine(
                    role: .relationship,
                    title: item.title,
                    subtitle: "\(item.kind.title): \(item.summary) \(item.reviewLabel). \(item.reversibilityLabel)",
                    statusLabel: item.sourceLabel,
                    systemImage: item.kind.symbolName,
                    visualState: item.state,
                    accessibilityIdentifier: "goal-detail.review-trail.\(item.id)"
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.title)
        .accessibilityValue(state.accessibilitySummary)
    }
}
