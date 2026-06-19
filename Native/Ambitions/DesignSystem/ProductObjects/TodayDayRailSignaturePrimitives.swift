import AmbitionsDesignSystem
import SwiftUI

struct DayRailRhythmStrip: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: AmbitionsDayRailViewState
    let semanticState: AmbitionSemanticState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text("Day rhythm")
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
                .accessibilityHidden(true)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    rhythmItems
                }
            } else {
                HStack(spacing: theme.spacing.xs) {
                    rhythmItems
                }
            }
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.shell.controlBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.shell.divider, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Day rhythm")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("TodayRealityRailRhythmStrip")
    }

    @ViewBuilder
    var rhythmItems: some View {
        ForEach(DayRailRowSlot.allCases, id: \.rawValue) { slot in
            DayRailRhythmItem(
                title: slot.title,
                value: value(for: slot),
                detail: detail(for: slot),
                state: stateForSlot(slot),
                isCurrent: slot == .now
            )
        }
    }

    func value(for slot: DayRailRowSlot) -> String {
        switch slot {
        case .now:
            state.heroStep == nil && rows(for: slot).isEmpty ? "Open" : "\(rows(for: slot).count + (state.heroStep == nil ? 0 : 1))"
        case .next, .later:
            rows(for: slot).isEmpty ? "Open" : "\(rows(for: slot).count)"
        }
    }

    func detail(for slot: DayRailRowSlot) -> String {
        switch slot {
        case .now:
            state.heroStep == nil ? "Nothing urgent" : "Current focus"
        case .next:
            rows(for: slot).isEmpty ? "No pull forward" : "Ready after now"
        case .later:
            rows(for: slot).isEmpty ? "Can stay open" : "Held gently"
        }
    }

    func stateForSlot(_ slot: DayRailRowSlot) -> AmbitionSemanticState {
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

    func rows(for slot: DayRailRowSlot) -> [DayRailRowState] {
        state.rows.filter { $0.slot == slot }
    }

    var accessibilityValue: String {
        DayRailRowSlot.allCases
            .map { "\($0.title): \(detail(for: $0)), \(value(for: $0))" }
            .joined(separator: ". ")
    }
}

struct DayRailRhythmItem: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let value: String
    let detail: String
    let state: AmbitionSemanticState
    let isCurrent: Bool

    var body: some View {
        let style = theme.semanticStyle(for: state)

        HStack(spacing: theme.spacing.xs) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.micro)
                    .foregroundStyle(isCurrent ? style.accent : theme.colors.textTertiary)
                    .lineLimit(1)

                Text(detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.xs)

            Text(value)
                .font(theme.typography.caption)
                .foregroundStyle(style.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, theme.spacing.xs)
                .padding(.vertical, theme.spacing.xxxs)
                .background(Capsule().fill(style.fill))
                .overlay(Capsule().stroke(style.stroke, lineWidth: 1))
        }
        .frame(maxWidth: .infinity, minHeight: theme.panel.minimumTapTarget, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue("\(detail), \(value)")
    }
}
