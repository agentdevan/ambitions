import SwiftUI

struct TodayFlagshipAdaptiveNavigationPassage: View {
    let copy: TodayFlagshipInterfaceCopy
    let commands: [TodayFlagshipNavigationCommand]
    let palette: TodayFlagshipPalette
    let onCommand: (TodayFlagshipNavigationCommand) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            navigationGroup(
                title: copy.rootsGroupTitle,
                commands: rootCommands,
                headingIdentifier: "tfcs-adaptive-roots-heading",
                identifier: "tfcs-adaptive-roots-group"
            )

            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
                .accessibilityHidden(true)

            navigationGroup(
                title: copy.globalActionsGroupTitle,
                commands: globalActionCommands,
                headingIdentifier: "tfcs-adaptive-global-actions-heading",
                identifier: "tfcs-adaptive-global-actions-group"
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
        commands: [TodayFlagshipNavigationCommand],
        headingIdentifier: String,
        identifier: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier(headingIdentifier)

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
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(identifier)
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

                Text(copy.navigationTitle(for: command))
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
        .accessibilityLabel(copy.navigationTitle(for: command))
        .accessibilityValue(command.isSelectedRoot ? copy.selectedRootValue : String())
        .accessibilityAddTraits(command.isSelectedRoot ? .isSelected : [])
        .accessibilityIdentifier("tfcs-navigation-\(command.rawValue)")
    }

    private var rootCommands: [TodayFlagshipNavigationCommand] {
        commands.filter(TodayFlagshipNavigationCommand.roots.contains)
    }

    private var globalActionCommands: [TodayFlagshipNavigationCommand] {
        commands.filter(TodayFlagshipNavigationCommand.globalActions.contains)
    }
}

struct TodayFlagshipDock: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var commandSelectionFeedback = 0

    let copy: TodayFlagshipInterfaceCopy
    let commands: [TodayFlagshipNavigationCommand]
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
        .sensoryFeedback(.selection, trigger: commandSelectionFeedback)
    }

    private var peekDock: some View {
        Button {
            isExpanded = true
        } label: {
            ZStack(alignment: .trailing) {
                dockMaterial(
                    shape: UnevenRoundedRectangle(
                        topLeadingRadius: 9,
                        bottomLeadingRadius: 9,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 0,
                        style: .continuous
                    )
                )
                .frame(width: 14, height: 52)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(palette.articulationAccent)
                        .frame(width: 2, height: 30)
                        .accessibilityHidden(true)
                }

                VStack(spacing: 5) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 11, weight: .semibold))

                    Capsule(style: .continuous)
                        .fill(palette.secondaryInk)
                        .frame(width: 5, height: 2)
                }
                .foregroundStyle(palette.secondaryInk)
                .frame(width: 14, height: 52)
                .accessibilityHidden(true)
            }
            .frame(width: 44, height: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(TodayFlagshipDockPeekButtonStyle())
        .accessibilityLabel(copy.openNavigationLabel)
        .accessibilityHint(copy.navigationCommandsHint)
        .accessibilityIdentifier("tfcs-dock-shell-peek")
    }

    private var expandedDock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                Button {
                    isExpanded = false
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(copy.closeNavigationLabel)
                .accessibilityHint(copy.closeNavigationHint)
            }

            dockGroup(
                label: copy.rootsGroupTitle,
                commands: rootCommands,
                identifier: "tfcs-dock-roots-group"
            )

            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
                .accessibilityHidden(true)

            dockGroup(
                label: copy.globalActionsGroupTitle,
                commands: globalActionCommands,
                identifier: "tfcs-dock-global-actions-group"
            )
        }
        .padding(12)
        .frame(width: 300)
        .background {
            dockMaterial(
                shape: UnevenRoundedRectangle(
                    topLeadingRadius: 18,
                    bottomLeadingRadius: 18,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0,
                    style: .continuous
                )
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-dock-expanded")
    }

    private func dockGroup(
        label: String,
        commands: [TodayFlagshipNavigationCommand],
        identifier: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
                .accessibilityAddTraits(.isHeader)

            ForEach(commands) { command in
                Button {
                    commandSelectionFeedback += 1
                    onCommand(command)
                    if command == .today {
                        isExpanded = false
                    }
                } label: {
                    HStack(spacing: 9) {
                        Image(systemName: command.symbolName)
                            .frame(width: 20)
                            .accessibilityHidden(true)
                        Text(copy.navigationTitle(for: command))
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
                .accessibilityLabel(copy.navigationTitle(for: command))
                .accessibilityValue(command.isSelectedRoot ? copy.selectedRootValue : String())
                .accessibilityAddTraits(command.isSelectedRoot ? .isSelected : [])
                .accessibilityIdentifier("tfcs-dock-\(command.rawValue)")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(identifier)
    }

    private var rootCommands: [TodayFlagshipNavigationCommand] {
        commands.filter(TodayFlagshipNavigationCommand.roots.contains)
    }

    private var globalActionCommands: [TodayFlagshipNavigationCommand] {
        commands.filter(TodayFlagshipNavigationCommand.globalActions.contains)
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

private struct TodayFlagshipDockPeekButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(reduceMotion ? 1 : configuration.isPressed ? 0.97 : 1)
    }
}
