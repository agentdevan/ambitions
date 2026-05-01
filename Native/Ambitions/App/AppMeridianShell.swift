import AmbitionsDesignSystem
import SwiftUI

struct AppMeridianDestinationRail: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let theme: AmbitionTheme
    let selectedTab: AppTab
    let onSelect: (AppTab) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.xxs) {
                ForEach(AppMeridianDestination.all) { destination in
                    destinationButton(destination)
                }
            }
            .padding(.horizontal, theme.spacing.xs)
            .padding(.vertical, theme.spacing.xxs)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .background(
            Capsule(style: .continuous)
                .fill(theme.colors.canvasElevated.opacity(theme.mode == .dark ? 0.94 : 0.98))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(theme.shell.divider.opacity(0.68), lineWidth: 1)
                )
                .shadow(
                    color: theme.depth.resting.color,
                    radius: theme.depth.resting.radius,
                    x: theme.depth.resting.x,
                    y: theme.depth.resting.y
                )
        )
        .padding(.horizontal, theme.spacing.sm)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Meridian destinations")
        .accessibilityIdentifier("shell.meridian.destination-rail")
    }

    private func destinationButton(_ destination: AppMeridianDestination) -> some View {
        let isSelected = destination.tab == selectedTab

        return Button {
            onSelect(destination.tab)
        } label: {
            VStack(spacing: theme.spacing.xxxs) {
                Image(systemName: destination.systemImage)
                    .font(.system(.body, design: .rounded).weight(isSelected ? .semibold : .regular))
                    .frame(height: 18)

                Text(destination.title)
                    .font(theme.typography.micro)
                    .lineLimit(1)
                    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.72 : 0.84)
            }
            .foregroundStyle(isSelected ? theme.shell.activeTabForeground : theme.shell.inactiveTabForeground)
            .frame(minWidth: dynamicTypeSize.isAccessibilitySize ? 88 : 62, minHeight: 50)
            .padding(.horizontal, theme.spacing.xxxs)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? theme.shell.activeTabBackground.opacity(0.92) : .clear)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(isSelected ? theme.shell.activeTabForeground.opacity(0.55) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(destination.title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Opens \(destination.title).")
        .accessibilityIdentifier(destination.accessibilityIdentifier)
    }
}
