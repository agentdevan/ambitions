import AmbitionsDesignSystem
import SwiftUI

struct StageDockRail: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let theme: AmbitionTheme
    let selectedTab: AmbitionsSurface
    let onSelect: (AmbitionsSurface) -> Void
    private let chromeState = StageChromeContract.launchDefault

    var body: some View {
        destinationRail
            .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? theme.spacing.xs : theme.spacing.sm)
            .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? theme.spacing.xxs : theme.spacing.xs)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? theme.spacing.xxs : theme.spacing.xs)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Root surfaces")
            .accessibilityIdentifier("shell.stage-os.invisible-rail")
    }

    private var destinationRail: some View {
        destinationRow
    }

    private var destinationRow: some View {
        HStack(spacing: dynamicTypeSize.isAccessibilitySize ? theme.spacing.xs : theme.spacing.sm) {
            ForEach(chromeState.destinations) { destination in
                destinationButton(destination)
            }
        }
    }

    private func destinationButton(_ destination: StageDockDestination) -> some View {
        let isSelected = destination.surface == selectedTab
        let accessibilityCompact = dynamicTypeSize.isAccessibilitySize
        let iconTypography = theme.typography.body
        let iconFont: Font = accessibilityCompact
            ? .system(size: 30, weight: .medium)
            : iconTypography.weight(.medium)

        return Button {
            if destination.surface != selectedTab {
                AppShellSensoryFeedbackPolicy.emit(.surfaceSelection, reduceMotionEnabled: reduceMotion)
            }
            onSelect(destination.surface)
        } label: {
            Image(systemName: destination.systemImage)
                .font(iconFont)
                .symbolRenderingMode(.hierarchical)
            .foregroundStyle(isSelected ? theme.shell.activeTabForeground : theme.shell.inactiveTabForeground.opacity(0.86))
            .frame(
                width: accessibilityCompact ? 58 : 52,
                height: accessibilityCompact ? 50 : 44
            )
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(theme.shell.controlBackground.opacity(0.92))
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
    private struct StageDockRailPreviewHost: View {
        @State private var selectedTab: AmbitionsSurface = .today
        let theme: AmbitionTheme

        var body: some View {
            ZStack(alignment: .bottom) {
                theme.shell.canvasGradient
                    .ignoresSafeArea()

                VStack(spacing: theme.spacing.md) {
                    Spacer()

                    StageDockRail(
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
            .preferredColorScheme(theme.mode == .dark ? .dark : .light)
        }
    }

    #Preview("Stage Dock Rail") {
        StageDockRailPreviewHost(theme: .dark)
    }

    #Preview("Stage Dock Rail Light") {
        StageDockRailPreviewHost(theme: .light)
    }

    #Preview("Stage Dock Rail Large Type") {
        StageDockRailPreviewHost(theme: .dark)
            .environment(\.dynamicTypeSize, .accessibility2)
    }
#endif
