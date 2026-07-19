import AmbitionsDesignSystem
import SwiftUI

struct LifeAreaAtlasListRow: View {
    @Environment(\.ambitionTheme) private var theme

    let region: GoalsLifeAreaAtlasRegion
    let isSelected: Bool
    let isProofHighlighted: Bool
    let onOpen: () -> Void
    let onCreate: () -> Void

    var body: some View {
        Button(action: region.hasActivity ? onOpen : onCreate) {
            let style = theme.stateStyle(for: rowState, accent: rowTint)
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: region.symbolName)
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .foregroundStyle(rowTint)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(style.fill))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        Text(region.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        if isSelected {
                            Text("Selected area")
                                .font(theme.typography.micro.weight(.semibold))
                                .foregroundStyle(rowTint)
                                .accessibilityIdentifier("goals.life-area.\(region.id).selected-marker")
                        }
                        if isProofHighlighted {
                            Text("Proof visible")
                                .font(theme.typography.micro.weight(.semibold))
                                .foregroundStyle(rowTint)
                                .accessibilityIdentifier("goals.life-area.\(region.id).proof-marker")
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)

                    Text(region.primaryCountLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(region.hasActivity || isSelected || isProofHighlighted ? rowTint : theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let proofHistoryLabel = region.proofHistoryLabel, isProofHighlighted {
                        Text(proofHistoryLabel)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: theme.spacing.xs)
            }
            .padding(.vertical, theme.spacing.sm)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(rowTint.opacity(isSelected || isProofHighlighted ? 0.78 : 0.28))
                    .frame(width: isSelected || isProofHighlighted ? 3 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("goals.life-area.\(region.id)")
        .accessibilityLabel(region.accessibilityLabel)
        .accessibilityValue(region.accessibilityValue)
        .accessibilityHint(region.accessibilityHint)
    }

    var rowState: AmbitionVisualState {
        if isProofHighlighted {
            return .success
        }
        if isSelected || region.state == .selected {
            return .selected
        }
        return .default
    }

    var rowTint: Color {
        if isProofHighlighted {
            return theme.colors.success
        }
        if region.hasActivity || isSelected {
            return region.atlasTint(theme)
        }
        return theme.colors.textTertiary
    }
}

struct LifeAreaAtlasNode: View {
    @Environment(\.ambitionTheme) private var theme

    let region: GoalsLifeAreaAtlasRegion
    let isSelected: Bool
    let isProofHighlighted: Bool
    let onOpen: () -> Void
    let onCreate: () -> Void

    var body: some View {
        Button(action: region.hasActivity ? onOpen : onCreate) {
            let style = theme.stateStyle(for: nodeState, accent: nodeTint)
            VStack(alignment: .center, spacing: theme.spacing.xs) {
                ZStack {
                    Circle()
                        .fill(nodeTint.opacity(region.hasActivity ? 0.26 : 0.12))
                        .overlay {
                            Circle()
                                .stroke(style.accent.opacity(nodeIsHighlighted ? 0.82 : 0.20), lineWidth: nodeIsHighlighted ? 2 : 1)
                        }
                    Image(systemName: region.symbolName)
                        .font(.system(size: theme.icon.smallSize, weight: .semibold))
                        .foregroundStyle(region.hasActivity || nodeIsHighlighted ? nodeTint : theme.colors.textSecondary)
                }
                .frame(width: 36, height: 36)
                .overlay(alignment: .bottomTrailing) {
                    if isSelected {
                        nodeBadge(
                            systemImage: "scope",
                            accessibilityLabel: "Selected area",
                            accessibilityIdentifier: "goals.life-area.\(region.id).selected-marker"
                        )
                    } else if isProofHighlighted {
                        nodeBadge(
                            systemImage: "checkmark.seal",
                            accessibilityLabel: "Proof visible",
                            accessibilityIdentifier: "goals.life-area.\(region.id).proof-marker"
                        )
                    }
                }
                .accessibilityHidden(true)

                Text(region.title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text(region.primaryCountLabel)
                    .font(theme.typography.micro)
                    .foregroundStyle(region.hasActivity || nodeIsHighlighted ? nodeTint : theme.colors.textTertiary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.78)

                if region.hasActivity {
                    ActivityMarks(region: region, proofHighlighted: isProofHighlighted)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
        .accessibilityIdentifier("goals.life-area.\(region.id)")
        .accessibilityLabel(region.accessibilityLabel)
        .accessibilityValue(region.accessibilityValue)
        .accessibilityHint(region.accessibilityHint)
    }

    var nodeIsHighlighted: Bool {
        isSelected || isProofHighlighted
    }

    var nodeState: AmbitionVisualState {
        if isProofHighlighted {
            return .success
        }
        if isSelected || region.state == .selected {
            return .selected
        }
        return region.state
    }

    var nodeTint: Color {
        if isProofHighlighted {
            return theme.colors.success
        }
        if region.hasActivity {
            return region.atlasTint(theme)
        }
        return theme.colors.textTertiary
    }

    func nodeBadge(
        systemImage: String,
        accessibilityLabel: String,
        accessibilityIdentifier: String
    ) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(theme.colors.textPrimary)
            .frame(width: 15, height: 15)
            .background(Circle().fill(nodeTint.opacity(0.92)))
            .overlay(
                Circle()
                    .stroke(theme.colors.surfaceOverlay.opacity(0.86), lineWidth: 1)
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}

private struct ActivityMarks: View {
    @Environment(\.ambitionTheme) private var theme

    let region: GoalsLifeAreaAtlasRegion
    let proofHighlighted: Bool

    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            mark(count: region.activeGoalCount, symbol: "target", label: "goals")
            mark(count: region.looseStepCount, symbol: "smallcircle.filled.circle", label: "steps")
            mark(count: region.thoughtCount, symbol: "sparkle", label: "thoughts")
            mark(
                count: region.proofCount + region.receiptCount,
                symbol: "seal",
                label: "history",
                emphasized: proofHighlighted
            )
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func mark(count: Int, symbol: String, label: String, emphasized: Bool = false) -> some View {
        if count > 0 {
            Image(systemName: symbol)
                .font(theme.typography.micro)
                .foregroundStyle(emphasized ? theme.colors.success : theme.colors.textSecondary)
                .accessibilityLabel("\(count) \(label)")
        }
    }
}

struct AtlasCurrentStepObject: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let action: GoalsAtlasPrimaryAction
    let isProofHighlighted: Bool
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            let style = theme.stateStyle(for: isProofHighlighted ? .success : action.state)
            VStack(alignment: .center, spacing: theme.spacing.xs) {
                Image(systemName: action.systemImage)
                    .font(.system(size: theme.icon.largeSize, weight: .semibold))
                    .foregroundStyle(style.accent)
                    .accessibilityHidden(true)

                Text("Start here")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                    .textCase(.uppercase)
                    .lineLimit(1)

                Text(displayTitle)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Text(action.subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
            }
            .padding(theme.spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(style.fill.opacity(action.state == .warning ? 0.62 : 0.50))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(style.stroke.opacity(action.state == .warning ? 0.86 : 0.62), lineWidth: action.state == .warning ? 1.25 : 1)
            )
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
        .accessibilityIdentifier("goals.current-step.open")
        .accessibilityLabel(action.title)
        .accessibilityHint(action.subtitle)
    }

    var displayTitle: String {
        if action.title.hasPrefix("Recover ") {
            return action.title.replacingOccurrences(of: "Recover ", with: "Recover\n")
        }
        if dynamicTypeSize >= .xxxLarge, action.title.hasPrefix("Refine ") {
            return action.title.replacingOccurrences(of: "Refine ", with: "Refine\n")
        }
        if dynamicTypeSize >= .xxxLarge, action.title.hasPrefix("Open ") {
            return action.title.replacingOccurrences(of: "Open ", with: "Open\n")
        }
        return action.title
    }
}
