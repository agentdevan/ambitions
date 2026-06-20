import AmbitionsDesignSystem
import SwiftUI

struct AppMeridianDestinationRail: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let theme: AmbitionTheme
    let selectedTab: AmbitionsSurface
    let onSelect: (AmbitionsSurface) -> Void
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
        Capsule(style: .continuous)
            .fill(AmbitionsIOS26SemanticTokens.LiquidGlass.darkDockCore.opacity(theme.mode == .dark ? 0.72 : 0.58))
            .overlay(
                Capsule(style: .continuous)
                    .fill(AmbitionsIOS26SemanticTokens.LiquidGlass.darkDockBase.opacity(theme.mode == .dark ? 0.38 : 0.24))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(AmbitionsIOS26SemanticTokens.Separator.darkNonOpaque.opacity(0.42), lineWidth: 1)
            )
            .overlay(alignment: .top) {
                Capsule(style: .continuous)
                    .stroke(theme.colors.textPrimary.opacity(theme.mode == .dark ? 0.035 : 0.06), lineWidth: 1)
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            }
    }

    private func destinationButton(_ destination: AppMeridianDestination) -> some View {
        let isSelected = destination.tab == selectedTab
        let accessibilityCompact = dynamicTypeSize.isAccessibilitySize
        let iconFrame = CGSize(
            width: accessibilityCompact ? 24 : 30,
            height: accessibilityCompact ? 22 : 26
        )
        let iconTypography = isSelected ? theme.typography.bodyEmphasized : theme.typography.body
        let labelTypography = accessibilityCompact ? theme.typography.micro : theme.typography.caption

        return Button {
            if destination.tab != selectedTab {
                AppShellSensoryFeedbackPolicy.emit(.surfaceSelection, reduceMotionEnabled: reduceMotion)
            }
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
                        .font(iconTypography.weight(isSelected ? .semibold : .medium))
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(width: iconFrame.width, height: iconFrame.height)

                Text(destination.title)
                    .font(labelTypography.weight(isSelected ? .semibold : .medium))
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
                    Capsule(style: .continuous)
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
                    Capsule(style: .continuous)
                        .stroke(theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.14 : 0.10), lineWidth: 1)
                }
            }
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(destination.title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Opens \(destination.title).")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier(destination.accessibilityIdentifier)
    }
}

#if DEBUG
private struct AppMeridianDestinationRailPreviewHost: View {
    @State private var selectedTab: AmbitionsSurface = .today
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
