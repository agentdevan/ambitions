import SwiftUI

struct TodayFlagshipAdaptiveNavigationPassage: View {
    let palette: TodayFlagshipPalette
    let onCommand: (TodayFlagshipNavigationCommand) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            navigationGroup(
                title: "Roots",
                commands: TodayFlagshipNavigationCommand.roots
            )

            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
                .accessibilityHidden(true)

            navigationGroup(
                title: "Global actions",
                commands: TodayFlagshipNavigationCommand.globalActions
            )
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.opaqueChrome)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-adaptive-navigation-passage")
    }

    private func navigationGroup(
        title: String,
        commands: [TodayFlagshipNavigationCommand]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TodayFlagshipSectionLabel(title, palette: palette)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 8)
                ],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(commands) { command in
                    navigationButton(command)
                }
            }
        }
    }

    private func navigationButton(
        _ command: TodayFlagshipNavigationCommand
    ) -> some View {
        Button {
            onCommand(command)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: command.symbolName)
                    .frame(width: 22)
                    .accessibilityHidden(true)

                Text(command.title)
                    .fontWeight(command.isSelectedRoot ? .semibold : .regular)

                Spacer(minLength: 0)

                if command.isSelectedRoot {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .accessibilityHidden(true)
                }
            }
            .font(.body)
            .lineLimit(2)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .padding(.horizontal, 10)
            .background {
                if command.isSelectedRoot {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(palette.selectedChrome)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(command.title)
        .accessibilityValue(command.isSelectedRoot ? "Selected root" : "")
        .accessibilityAddTraits(command.isSelectedRoot ? .isSelected : [])
        .accessibilityIdentifier("tfcs-navigation-\(command.rawValue)")
    }
}

struct TodayFlagshipDock: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @Binding var isExpanded: Bool
    let palette: TodayFlagshipPalette
    let onCommand: (TodayFlagshipNavigationCommand) -> Void

    var body: some View {
        Group {
            if isExpanded {
                expandedDock
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                peekDock
                    .transition(.opacity)
            }
        }
    }

    private var peekDock: some View {
        Button {
            isExpanded = true
        } label: {
            ZStack(alignment: .trailing) {
                Color.clear
                dockMaterial(
                    shape: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
                .frame(width: 25, height: 42)
                .offset(x: 8)

                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(palette.secondaryInk)
                    .offset(x: 1)
                    .accessibilityHidden(true)
            }
            .frame(width: 44, height: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open global navigation")
        .accessibilityHint("Shows Today, Goals, Time, You, Search, and Capture")
        .accessibilityIdentifier("tfcs-dock-peek")
    }

    private var expandedDock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Navigate")
                    .font(.headline)
                Spacer()
                Button {
                    isExpanded = false
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close global navigation")
            }

            dockGroup(
                label: "Roots",
                commands: TodayFlagshipNavigationCommand.roots
            )

            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
                .accessibilityHidden(true)

            dockGroup(
                label: "Global",
                commands: TodayFlagshipNavigationCommand.globalActions
            )
        }
        .padding(12)
        .frame(width: 300)
        .background {
            dockMaterial(
                shape: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-dock-expanded")
    }

    private func dockGroup(
        label: String,
        commands: [TodayFlagshipNavigationCommand]
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
                .accessibilityAddTraits(.isHeader)

            ForEach(commands) { command in
                Button {
                    onCommand(command)
                    if command == .today {
                        isExpanded = false
                    }
                } label: {
                    HStack(spacing: 9) {
                        Image(systemName: command.symbolName)
                            .frame(width: 20)
                            .accessibilityHidden(true)
                        Text(command.title)
                        Spacer(minLength: 0)
                        if command.isSelectedRoot {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .accessibilityHidden(true)
                        }
                    }
                    .font(.body.weight(command.isSelectedRoot ? .semibold : .regular))
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .padding(.horizontal, 8)
                    .background {
                        if command.isSelectedRoot {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(palette.selectedChrome)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(command.title)
                .accessibilityValue(command.isSelectedRoot ? "Selected root" : "")
                .accessibilityAddTraits(command.isSelectedRoot ? .isSelected : [])
                .accessibilityIdentifier("tfcs-dock-\(command.rawValue)")
            }
        }
    }

    @ViewBuilder
    private func dockMaterial<S: InsettableShape>(shape: S) -> some View {
        if reduceTransparency {
            shape
                .fill(palette.opaqueChrome)
                .overlay { shape.stroke(palette.divider, lineWidth: 1) }
        } else if #available(iOS 26.0, macOS 26.0, *) {
            shape
                .fill(palette.opaqueChrome.opacity(0.90))
                .glassEffect(
                    .regular
                        .tint(palette.opaqueChrome.opacity(0.48))
                        .interactive(),
                    in: shape
                )
                .overlay { shape.stroke(palette.divider, lineWidth: 1) }
        } else {
            shape
                .fill(palette.opaqueChrome)
                .overlay { shape.stroke(palette.divider, lineWidth: 1) }
        }
    }
}
