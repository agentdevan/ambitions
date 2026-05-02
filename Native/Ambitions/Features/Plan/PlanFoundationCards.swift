import AmbitionsDesignSystem
import SwiftUI

struct PlanTreatyCard: View {
    @Environment(\.ambitionTheme) private var theme

    let treaty: PlanTreatyState

    var body: some View {
        AppCard(state: treaty.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: treaty.title, subtitle: treaty.summary)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: theme.spacing.sm), GridItem(.flexible(), spacing: theme.spacing.sm)], spacing: theme.spacing.sm) {
                    PlanTreatyTile(title: "Keep", detail: treaty.protectedWork, icon: "lock.shield", state: .selected)
                    PlanTreatyTile(title: "Flex", detail: treaty.flexibleWork, icon: "arrow.left.and.right", state: .default)
                    PlanTreatyTile(title: "Not today", detail: treaty.notTodayWork, icon: "tray", state: .warning)
                    PlanTreatyTile(title: "Recovery", detail: treaty.recoveryAllowance, icon: "sun.max", state: treaty.visualState)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(treaty.calendarBoundary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(theme.stateStyle(for: treaty.visualState).accent)
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(treaty.primaryActionTitle)
                                .font(theme.typography.bodyEmphasized)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(treaty.primaryActionSubtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textTertiary)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("plan.treaty")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct PlanTreatyTile: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let detail: String
    let icon: String
    let state: AmbitionVisualState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                Text(title)
                    .font(theme.typography.caption)
            }
            .foregroundStyle(theme.stateStyle(for: state).accent)

            Text(detail)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.stateStyle(for: state).stroke.opacity(0.5), lineWidth: 1)
        )
    }
}

struct PlanCapacityEnvelopeCard: View {
    @Environment(\.ambitionTheme) private var theme

    let envelope: PlanCapacityEnvelopeState

    var body: some View {
        AppCard(state: envelope.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: envelope.title, subtitle: envelope.detail)

                HStack(spacing: theme.spacing.xs) {
                    TagPill(envelope.label, icon: "gauge.with.dots.needle.bottom.50percent", state: envelope.visualState)
                    TagPill(envelope.availableCapacity, icon: "calendar", state: envelope.visualState)
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    PlanKeyValueRow(label: "Pressure", value: envelope.pressure, state: envelope.visualState)
                    PlanKeyValueRow(label: "Focus time", value: envelope.protectedFocus, state: .selected)
                    PlanKeyValueRow(label: "Recovery margin", value: envelope.recoveryMargin, state: envelope.visualState)
                }
            }
        }
        .accessibilityIdentifier("plan.capacity-envelope")
        .ambitionPanelAccessibility()
    }
}

struct PlanKeyValueRow: View {
    @Environment(\.ambitionTheme) private var theme

    let label: String
    let value: String
    let state: AmbitionVisualState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Circle()
                .fill(theme.stateStyle(for: state).accent)
                .frame(width: 7, height: 7)
                .padding(.top, 7)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(label)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(value)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
            }
            Spacer()
        }
    }
}

struct PlanGoalLifecycleRailCard: View {
    @Environment(\.ambitionTheme) private var theme

    let rail: PlanGoalLifecycleRailState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: rail.title, subtitle: rail.subtitle)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.sm) {
                        ForEach(rail.segments) { segment in
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                HStack(spacing: theme.spacing.xs) {
                                    Image(systemName: segment.lifecycleState.icon)
                                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                    Text(segment.lifecycleState.title)
                                        .font(theme.typography.caption)
                                }
                                .foregroundStyle(theme.stateStyle(for: segment.lifecycleState.visualState).accent)

                                Text("\(segment.count)")
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(segment.subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                                    .lineLimit(2)
                            }
                            .padding(theme.spacing.md)
                            .frame(width: 128, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                    .fill(theme.colors.surfaceOverlay)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                    .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("plan.goal-lifecycle-rail")
        .ambitionPanelAccessibility()
    }
}

struct PlanTimelineStripCard: View {
    @Environment(\.ambitionTheme) private var theme

    let strip: PlanTimelineStripState
    let onOpenGoal: (GoalRouteTarget) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: strip.title, subtitle: strip.subtitle)

                if strip.items.isEmpty {
                    Text("Goal movement will appear here when this plan has real pressure to carry.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            ForEach(strip.items) { item in
                                Button {
                                    guard let target = item.target else { return }
                                    onOpenGoal(target)
                                } label: {
                                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                        TagPill(item.kind.title, state: item.visualState)
                                        Text(item.title)
                                            .font(theme.typography.bodyEmphasized)
                                            .foregroundStyle(theme.colors.textPrimary)
                                            .lineLimit(2)
                                        Text(item.detail)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textSecondary)
                                            .lineLimit(3)
                                        Text(item.timingLabel)
                                            .font(theme.typography.micro)
                                            .foregroundStyle(theme.colors.textTertiary)
                                        TagPill(item.sourceLabel, state: .default)
                                    }
                                    .padding(theme.spacing.md)
                                    .frame(width: 176, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                            .fill(theme.colors.surfaceOverlay)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                            .stroke(theme.stateStyle(for: item.visualState).stroke.opacity(0.6), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(item.target == nil)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("\(item.title). \(item.detail). \(item.timingLabel). \(item.sourceLabel).")
                            }
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("plan.timeline-strip")
        .ambitionPanelAccessibility()
    }
}
