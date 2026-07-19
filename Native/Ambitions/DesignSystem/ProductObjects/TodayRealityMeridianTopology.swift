import AmbitionsDesignSystem
import SwiftUI

struct MeridianTopologyStrip: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: AmbitionsDayRailViewState
    let semanticState: AmbitionSemanticState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(state.continuity.title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(state.continuity.summary)
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: dynamicTypeSize.isAccessibilitySize ? 144 : 118), spacing: theme.spacing.xs, alignment: .leading),
                ],
                alignment: .leading,
                spacing: theme.spacing.xs
            ) {
                MeridianTopologyBadge(
                    title: "Start here",
                    detail: state.heroStep?.title ?? "User choice stays available.",
                    state: state.heroStep == nil ? .trust : .focus
                )

                MeridianTopologyBadge(
                    title: "Now",
                    detail: topologyValue(for: .now),
                    state: topologyState(for: .now)
                )
                .accessibilityIdentifier("TodayRealityRailNowSection")

                MeridianTopologyBadge(
                    title: "Next",
                    detail: topologyValue(for: .next),
                    state: topologyState(for: .next)
                )
                .accessibilityIdentifier("TodayRealityRailNextSection")

                MeridianTopologyBadge(
                    title: "Later",
                    detail: topologyValue(for: .later),
                    state: topologyState(for: .later)
                )
                .accessibilityIdentifier("TodayRealityRailLaterSection")

                MeridianTopologyBadge(
                    title: "Source",
                    detail: state.privacyProjection.sourceLabel,
                    state: state.privacyProjection.isSensitiveProjection ? .protected : .trust
                )

                MeridianTopologyBadge(
                    title: "Freshness",
                    detail: state.heroStep?.receiptItem.freshness.label ?? "Freshness stays visible",
                    state: freshnessSemanticState
                )

                MeridianTopologyBadge(
                    title: "Closure",
                    detail: state.closureSlot.subtitle,
                    state: .review
                )

                MeridianTopologyBadge(
                    title: "Proof",
                    detail: state.proofSlot.subtitle,
                    state: .trust
                )

                MeridianTopologyBadge(
                    title: "Pressure",
                    detail: state.continuity.pressureLabel,
                    state: semanticState
                )
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Reality Meridian topology")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("TodayRealityRailTopologyStrip")
    }

    var freshnessSemanticState: AmbitionSemanticState {
        switch state.heroStep?.receiptItem.freshness {
        case .some(.fresh), .some(.localOnly):
            .trust
        case .some(.partial):
            .waiting
        case .some(.stale), .some(.offline), .some(.denied), .some(.blocked), .some(.unavailable):
            .caution
        case nil:
            .trust
        }
    }

    var accessibilityValue: String {
        [
            "Start here \(state.heroStep?.title ?? "User choice stays available.")",
            "Now \(topologyValue(for: .now))",
            "Next \(topologyValue(for: .next))",
            "Later \(topologyValue(for: .later))",
            "Source \(state.privacyProjection.sourceLabel)",
            "Freshness \(state.heroStep?.receiptItem.freshness.label ?? "Freshness stays visible")",
            "Closure \(state.closureSlot.subtitle)",
            "Proof \(state.proofSlot.subtitle)",
            "Pressure \(state.continuity.pressureLabel)",
        ].joined(separator: ". ")
    }

    func topologyValue(for slot: DayRailRowSlot) -> String {
        let rows = state.rows.filter { $0.slot == slot }
        switch slot {
        case .now:
            return state.heroStep == nil && rows.isEmpty ? "Open" : "\(rows.count + (state.heroStep == nil ? 0 : 1)) connected"
        case .next, .later:
            return rows.isEmpty ? "Open" : "\(rows.count) connected"
        }
    }

    func topologyState(for slot: DayRailRowSlot) -> AmbitionSemanticState {
        switch (slot, state.mode) {
        case (.now, .overloaded):
            .caution
        case (.now, .recovery):
            .recovery
        case (.now, .protected):
            .protected
        case (.now, _):
            semanticState
        case (.next, _):
            .waiting
        case (.later, _):
            .neutral
        }
    }
}

struct MeridianTopologyBadge: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let detail: String
    let state: AmbitionSemanticState

    var body: some View {
        let style = theme.semanticStyle(for: state)

        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.micro)
                .foregroundStyle(style.accent)
                .lineLimit(1)
            Text(detail)
                .font(theme.typography.caption)
                .foregroundStyle(style.foreground)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .fill(style.fill.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .stroke(style.stroke.opacity(0.72), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(detail)
    }
}
