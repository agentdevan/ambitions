import AmbitionsDesignSystem
import SwiftUI

struct AppMeridianDestinationRail: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let theme: AmbitionTheme
    let selectedTab: AppTab
    let onSelect: (AppTab) -> Void
    private let chromeState = AppMeridianShellChromeState.launchDefault

    var body: some View {
        destinationRail
            .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? theme.spacing.xxs : theme.spacing.xs)
            .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 8 : 10)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(railMaterial)
            .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? theme.spacing.xxs : theme.spacing.xs)
    }

    private var destinationRail: some View {
        destinationRow
    }

    private var destinationRow: some View {
        HStack(spacing: dynamicTypeSize.isAccessibilitySize ? 0 : theme.spacing.xxs) {
            ForEach(chromeState.destinations) { destination in
                destinationButton(destination)
            }
        }
    }

    private var railMaterial: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(AmbitionsIOS26SemanticTokens.LiquidGlass.darkDockCore.opacity(theme.mode == .dark ? 0.72 : 0.58))
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(AmbitionsIOS26SemanticTokens.LiquidGlass.darkDockBase.opacity(theme.mode == .dark ? 0.38 : 0.24))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(AmbitionsIOS26SemanticTokens.Separator.darkNonOpaque.opacity(0.42), lineWidth: 1)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(theme.colors.textPrimary.opacity(theme.mode == .dark ? 0.035 : 0.06), lineWidth: 1)
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            }
            .shadow(
                color: theme.depth.resting.color.opacity(theme.mode == .dark ? 0.28 : 0.18),
                radius: theme.depth.resting.radius,
                x: theme.depth.resting.x,
                y: theme.depth.resting.y
            )
    }

    private func destinationButton(_ destination: AppMeridianDestination) -> some View {
        let isSelected = destination.tab == selectedTab
        let accessibilityCompact = dynamicTypeSize.isAccessibilitySize
        let iconSize: CGFloat = accessibilityCompact ? (isSelected ? 14 : 13) : (isSelected ? 18 : 17)
        let iconFrame = CGSize(
            width: accessibilityCompact ? 24 : 30,
            height: accessibilityCompact ? 22 : 26
        )
        let labelSize: CGFloat = accessibilityCompact ? 10.5 : 12

        return Button {
            onSelect(destination.tab)
        } label: {
            VStack(spacing: accessibilityCompact ? 3 : 5) {
                ZStack {
                    if isSelected {
                        Capsule(style: .continuous)
                            .fill(theme.shell.activeTabForeground.opacity(theme.mode == .dark ? 0.78 : 0.64))
                            .frame(width: accessibilityCompact ? 14 : 18, height: 2)
                            .offset(y: accessibilityCompact ? 15 : 18)
                            .accessibilityHidden(true)
                    }

                    Image(systemName: destination.systemImage)
                        .font(.system(size: iconSize, weight: isSelected ? .semibold : .medium, design: .rounded))
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(width: iconFrame.width, height: iconFrame.height)

                Text(destination.title)
                    .font(.system(size: labelSize, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(accessibilityCompact ? 0.64 : 0.86)
            }
            .foregroundStyle(isSelected ? theme.shell.activeTabForeground : theme.shell.inactiveTabForeground.opacity(0.86))
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: accessibilityCompact ? 50 : 58
            )
            .padding(.horizontal, accessibilityCompact ? 0 : theme.spacing.xxxs)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: accessibilityCompact ? 18 : 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.070 : 0.055),
                                    theme.colors.accentPrimary.opacity(theme.mode == .dark ? 0.045 : 0.035),
                                    theme.colors.canvasElevated.opacity(0.025)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: accessibilityCompact ? 18 : 24, style: .continuous)
                        .stroke(theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.14 : 0.10), lineWidth: 1)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: accessibilityCompact ? 18 : 24, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(destination.title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Opens \(destination.title).")
        .accessibilityIdentifier(destination.accessibilityIdentifier)
    }
}

#if DEBUG
private struct AppMeridianDestinationRailPreviewHost: View {
    @State private var selectedTab: AppTab = .today
    private let theme = AmbitionTheme.dark

    var body: some View {
        ZStack(alignment: .bottom) {
            theme.shell.canvasGradient
                .ignoresSafeArea()

            VStack(spacing: theme.spacing.md) {
                Spacer()

                AppMeridianDestinationRail(
                    theme: theme,
                    selectedTab: selectedTab
                ) { tab in
                    selectedTab = tab
                }
                .padding(.bottom, theme.spacing.md)
            }
        }
        .frame(width: 393, height: 240)
        .background(theme.shell.canvasGradient)
        .ambitionTheme(theme)
        .preferredColorScheme(.dark)
    }
}

#Preview("App Meridian Shell") {
    AppMeridianDestinationRailPreviewHost()
}

#Preview("App Meridian Shell — Large Type") {
    AppMeridianDestinationRailPreviewHost()
        .environment(\.dynamicTypeSize, .accessibility2)
}
#endif
