import AmbitionsDesignSystem
import SwiftUI

struct GoalDetailProofRailSurface: View {
    let state: GoalDetailProofRailState

    var body: some View {
        ProofSpine(
            title: state.title,
            subtitle: state.subtitle,
            beads: state.spineBeads,
            emptyTitle: state.emptyTitle,
            emptyMessage: state.emptyMessage
        )
        .accessibilityIdentifier("goal-detail.proof-rail")
    }
}

struct GoalDetailReceiptsSurface: View {
    let state: GoalDetailReceiptsState

    var body: some View {
        ProofRelationshipTracePrimitiveStage(
            role: .receipt,
            title: state.title,
            subtitle: state.subtitle,
            accessibilityIdentifier: "goal-detail.receipts"
        ) {
            if state.items.isEmpty {
                ProofRelationshipTracePrimitiveLine(
                    role: .receipt,
                    title: state.emptyTitle,
                    subtitle: state.emptyMessage,
                    systemImage: "doc.text.magnifyingglass",
                    accessibilityIdentifier: "goal-detail.receipts.empty"
                )
            } else {
                ForEach(state.items) { item in
                    ProofRelationshipTracePrimitiveLine(
                        role: .receipt,
                        title: item.title,
                        subtitle: item.summary,
                        statusLabel: item.timestamp,
                        systemImage: "doc.text.magnifyingglass",
                        visualState: item.state,
                        accessibilityIdentifier: "goal-detail.receipts.\(item.id)"
                    )
                }
            }
        }
    }
}

struct GoalAlternatePathDecisionSpine: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalAlternatePathDecisionSpineState

    var body: some View {
        GoalDetailSectionSurface(title: state.title, subtitle: state.subtitle) {
            if state.branches.isEmpty {
                EmptyStateCard(title: state.emptyTitle, message: state.emptyMessage, icon: "arrow.triangle.branch")
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    decisionBoundary
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(Array(state.branches.enumerated()), id: \.element.id) { index, branch in
                            branchFold(branch, isLast: index == state.branches.count - 1)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.title)
        .accessibilityValue(state.accessibilitySummary)
        .accessibilityHint("Review alternate paths and decisions before changing this goal.")
        .accessibilityIdentifier("goal-detail.decisions")
    }

    var decisionBoundary: some View {
        Label(state.boundaryLabel, systemImage: "hand.raised")
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textSecondary)
            .padding(.vertical, theme.spacing.xs)
            .padding(.horizontal, theme.spacing.sm)
            .background(
                Capsule()
                    .fill(theme.colors.surfaceSecondary.opacity(0.72))
            )
    }

    func branchFold(
        _ branch: GoalAlternatePathDecisionBranchState,
        isLast: Bool
    ) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            VStack(spacing: theme.spacing.xs) {
                Image(systemName: branch.kind.symbolName)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.stateStyle(for: branch.state).accent)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(theme.stateStyle(for: branch.state).fill.opacity(0.72))
                    )
                if isLast == false {
                    Rectangle()
                        .fill(theme.colors.strokeSubtle)
                        .frame(width: 1)
                        .frame(minHeight: 44)
                }
            }
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                    Text(branch.kind.title)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                    Spacer(minLength: theme.spacing.sm)
                    TagPill(branch.freshnessLabel, state: branch.state)
                }
                Text(branch.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(branch.summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Label(branch.basisLabel, systemImage: "point.3.connected.trianglepath.dotted")
                    Label(branch.reviewLabel, systemImage: "eye")
                    Label(branch.consequenceLabel, systemImage: "arrow.left.and.right")
                    Label(branch.mutationBoundaryLabel, systemImage: "lock")
                }
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
            }
            .padding(.bottom, isLast ? 0 : theme.spacing.xs)
        }
        .accessibilityElement(children: .combine)
    }
}

struct GoalDetailRisksSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailRisksState

    var body: some View {
        GoalDetailSectionSurface(title: state.title, subtitle: state.subtitle) {
            if state.items.isEmpty {
                EmptyStateCard(title: state.emptyTitle, message: state.emptyMessage, icon: "checkmark.shield")
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(state.items) { item in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(theme.stateStyle(for: item.state).accent)
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(item.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(item.summary)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("goal-detail.risks")
    }
}

struct GoalDetailArchiveSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalDetailArchiveState

    var body: some View {
        GoalDetailSectionSurface(title: "Archive", subtitle: "What this goal should remember when its active work changes.") {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    Text(state.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Spacer()
                    TagPill(state.statusLabel, state: state.state)
                }
                Text(state.summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                Text(state.learning)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .padding(theme.spacing.sm)
            .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Archive. \(state.title). \(state.summary)")
        .accessibilityIdentifier("goal-detail.archive")
    }
}

struct GoalExplainabilitySection: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalExplainabilityState
    @Binding var isTrustExpanded: Bool
    @Binding var isCorrectionsExpanded: Bool
    let onCorrection: (GoalCorrectionControlState) -> Void

    var body: some View {
        if isTrustExpanded {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                GoalDetailSectionSurface(title: "Why this is on deck", subtitle: "Calm reasoning that stays attached to the strategic read instead of taking over the screen.") {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        Text(state.whyThis.compactSummary)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)

                        ForEach(Array(state.whyThis.lines.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                }
                .accessibilityIdentifier("goal-detail.trust-panel")

                GoalDetailSectionSurface(title: "Trust posture", subtitle: "Confidence, freshness, and contradictions stay legible before the deeper audit.") {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ExplainabilityLabelList(
                            title: humanizedConfidence(state.confidence.understandingConfidence),
                            subtitle: state.confidence.pathConfidence.map(humanizedConfidence),
                            labels: state.confidence.detailLabels
                        )
                        ExplainabilityLabelList(
                            title: state.freshness.postureLabel,
                            subtitle: state.freshness.severityLabel,
                            labels: state.freshness.detailLabels
                        )

                        if state.contradictions.isEmpty == false {
                            Divider()
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                Text("What needs reconciling")
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                ForEach(state.contradictions) { contradiction in
                                    AppCard(state: contradiction.state) {
                                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                            HStack {
                                                Text(contradiction.title)
                                                    .font(theme.typography.bodyEmphasized)
                                                    .foregroundStyle(theme.colors.textPrimary)
                                                Spacer()
                                                TagPill(contradiction.severityLabel, state: contradiction.state)
                                            }
                                            Text(contradiction.summary)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textSecondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                GoalDetailSectionSurface(title: "Source context", subtitle: "Audit stays available here without dominating the first layer.") {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.sourceAudit.rows) { row in
                            AppCard(state: row.state) {
                                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                    Text(row.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(row.subtitle)
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                    ForEach(row.detailLabels, id: \.self) { label in
                                        Text(label)
                                            .font(theme.typography.micro)
                                            .foregroundStyle(theme.colors.textTertiary)
                                    }
                                }
                            }
                        }
                    }
                }
                .accessibilityIdentifier("goal-detail.audit-panel")

                if state.correctionControls.isEmpty == false || state.appliedTeachingBadges.isEmpty == false {
                    GoalDetailSectionSurface(title: "Corrections and teaching", subtitle: "Use these when the app needs clearer truth, not more admin.") {
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            Button(isCorrectionsExpanded ? "Hide correction actions" : "Open correction actions") {
                                isCorrectionsExpanded.toggle()
                            }
                            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                            .accessibilityIdentifier("goal-detail.corrections-toggle")

                            if state.appliedTeachingBadges.isEmpty == false {
                                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                    Text("Already learned")
                                        .font(theme.typography.section)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    ForEach(state.appliedTeachingBadges) { badge in
                                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                                            TagPill(badge.title, state: badge.state)
                                            Text(badge.subtitle)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textSecondary)
                                        }
                                    }
                                }
                            }

                            if isCorrectionsExpanded {
                                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                    ForEach(state.correctionControls) { control in
                                        AppCard(state: control.state) {
                                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                                Text(control.title)
                                                    .font(theme.typography.bodyEmphasized)
                                                    .foregroundStyle(theme.colors.textPrimary)
                                                Text(control.subtitle)
                                                    .font(theme.typography.caption)
                                                    .foregroundStyle(theme.colors.textSecondary)
                                                Button(control.title) {
                                                    onCorrection(control)
                                                }
                                                .buttonStyle(AmbitionPressableButtonStyle(state: control.state))
                                                .padding(.top, theme.spacing.xs)
                                            }
                                        }
                                    }
                                }
                                .accessibilityIdentifier("goal-detail.corrections-panel")
                            }
                        }
                    }
                }
            }
        }
    }

    func humanizedConfidence(_ confidence: RecommendationConfidence) -> String {
        confidence.rawValue
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}
