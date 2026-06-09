import AmbitionsDesignSystem
import SwiftUI

struct DayRailSection: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let rows: [DayRailRowState]
    let privacy: DayRailPrivacyProjectionState
    let contextLabel: String
    let onOpenStepDetail: (DayRailStepDetailState) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)

            if rows.isEmpty {
                Text(emptyCopy)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(rows) { row in
                    DayRailRow(row: row, privacy: privacy, contextLabel: contextLabel, onOpenStepDetail: onOpenStepDetail)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }

    private var emptyCopy: String {
        switch title {
        case "Now":
            "Nothing needs you right now."
        case "Next":
            "No next step is being pulled forward."
        default:
            "Later can stay open."
        }
    }
}

struct DayRailRow: View {
    @Environment(\.ambitionTheme) private var theme

    let row: DayRailRowState
    let privacy: DayRailPrivacyProjectionState
    let contextLabel: String
    let onOpenStepDetail: (DayRailStepDetailState) -> Void

    var body: some View {
        Button {
            onOpenStepDetail(row.stepDetail(privacy: privacy, contextLabel: contextLabel))
        } label: {
            HStack(alignment: .top, spacing: theme.spacing.md) {
                DayRailNode(kind: nodeKind, active: row.slot == .now)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        Text(row.slot.title)
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.textTertiary)
                        AmbitionChip(row.duration.label, role: .time, semanticState: .calendarDerived)
                    }

                    Text(row.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(row.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(theme.spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.colors.surfaceSecondary.opacity(0.78))
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(theme.colors.strokeSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue("\(row.duration.label). \(sourceSummary)")
        .accessibilityHint("Opens Step Detail.")
        .accessibilityIdentifier(privacy.isSensitiveProjection ? "TodayRealityRailPrivateItem" : "TodayRealityRailRow")
    }

    private var nodeKind: DayRailNodeKind {
        switch row.slot {
        case .now:
            .active
        case .next:
            .upcoming
        case .later:
            .flexible
        }
    }

    private var sourceSummary: String {
        if privacy.isSensitiveProjection {
            return privacy.sourceLabel
        }
        return row.sourceLabels.map(\.label).prefix(2).joined(separator: " · ")
    }

    private var accessibilityLabel: String {
        privacy.isSensitiveProjection
            ? "\(row.slot.title). Private item. Details stay private on Today."
            : "\(row.slot.title). \(row.title). \(row.subtitle)"
    }
}

struct DayRailEmptySurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: AmbitionsDayRailViewState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            DayRailNode(kind: .empty, active: false)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("Start here")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .accessibilityIdentifier("TodayRealityRailStartHereTitle")
                Text("Nothing needs you right now.")
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Capture something, choose from a goal, or leave today open.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: theme.spacing.sm)
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Start here. Nothing needs you right now.")
        .accessibilityValue(state.contextSummary)
        .accessibilityIdentifier("TodayRealityRailHero")
    }
}

struct DayRailNode: View {
    @Environment(\.ambitionTheme) private var theme

    let kind: DayRailNodeKind
    let active: Bool

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(theme.colors.strokeSubtle)
                .frame(width: 1, height: 10)
                .opacity(active ? 0 : 1)
            node
            Rectangle()
                .fill(theme.colors.strokeSubtle)
                .frame(width: 1, height: 28)
        }
        .frame(width: 26)
    }

    @ViewBuilder
    private var node: some View {
        switch kind {
        case .closure:
            Diamond()
                .fill(theme.semanticAccent(for: .review).opacity(active ? 0.92 : 0.28))
                .frame(width: 14, height: 14)
        case .proof:
            Image(systemName: "doc.text")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(theme.semanticAccent(for: .trust))
                .frame(width: 20, height: 20)
        case .protected, .waiting, .blocked, .empty:
            Circle()
                .stroke(theme.colors.textTertiary.opacity(0.7), lineWidth: 1.4)
                .frame(width: 14, height: 14)
        case .recommended, .active:
            Circle()
                .fill(theme.colors.accentWarm)
                .frame(width: 16, height: 16)
                .shadow(color: theme.colors.accentWarm.opacity(0.24), radius: 8)
        case .upcoming, .flexible:
            Circle()
                .stroke(theme.colors.accentWarm.opacity(kind == .upcoming ? 0.78 : 0.48), lineWidth: 1.6)
                .frame(width: kind == .upcoming ? 14 : 11, height: kind == .upcoming ? 14 : 11)
        }
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
