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
            .padding(.horizontal, theme.spacing.xs)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(railMaterial)
            .padding(.horizontal, theme.spacing.xs)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(chromeState.title)
            .accessibilityValue(chromeState.accessibilitySummary)
            .accessibilityIdentifier("shell.meridian.destination-rail")
    }

    @ViewBuilder
    private var destinationRail: some View {
        if dynamicTypeSize.isAccessibilitySize {
            ScrollView(.horizontal, showsIndicators: false) {
                destinationRow
                    .padding(.horizontal, theme.spacing.xxs)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        } else {
            destinationRow
        }
    }

    private var destinationRow: some View {
        HStack(spacing: theme.spacing.xxs) {
            ForEach(chromeState.destinations) { destination in
                destinationButton(destination)
            }
        }
    }

    private var railMaterial: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(theme.shell.bottomBarMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(theme.shell.divider.opacity(0.56), lineWidth: 1)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(theme.colors.textPrimary.opacity(theme.mode == .dark ? 0.08 : 0.10), lineWidth: 1)
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            }
            .shadow(
                color: theme.depth.resting.color.opacity(theme.mode == .dark ? 0.82 : 0.36),
                radius: theme.depth.resting.radius,
                x: theme.depth.resting.x,
                y: theme.depth.resting.y
            )
    }

    private func destinationButton(_ destination: AppMeridianDestination) -> some View {
        let isSelected = destination.tab == selectedTab

        return Button {
            onSelect(destination.tab)
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.20 : 0.14))
                            .overlay(
                                Circle()
                                    .stroke(theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.34 : 0.24), lineWidth: 1)
                            )
                    }

                    Image(systemName: destination.systemImage)
                        .font(.system(size: isSelected ? 20 : 19, weight: isSelected ? .semibold : .medium, design: .rounded))
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(width: 32, height: 28)

                Text(destination.title)
                    .font(theme.typography.micro)
                    .lineLimit(1)
                    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.76 : 0.86)
            }
            .foregroundStyle(isSelected ? theme.shell.activeTabForeground : theme.shell.inactiveTabForeground.opacity(0.86))
            .frame(
                minWidth: dynamicTypeSize.isAccessibilitySize ? 92 : 0,
                maxWidth: dynamicTypeSize.isAccessibilitySize ? 104 : .infinity,
                minHeight: 58
            )
            .padding(.horizontal, theme.spacing.xxxs)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.24 : 0.15),
                                    theme.colors.accentPrimary.opacity(theme.mode == .dark ? 0.12 : 0.08),
                                    theme.colors.canvasElevated.opacity(0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(theme.colors.accentWarm.opacity(theme.mode == .dark ? 0.36 : 0.22), lineWidth: 1)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
