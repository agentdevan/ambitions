#if canImport(SwiftUI)
import SwiftUI

public enum RootDestinationIdentity: String, CaseIterable, Hashable, Identifiable, Sendable {
    case today
    case goals
    case time
    case motion
    case you

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .time: "Time"
        case .motion: "Motion"
        case .you: "You"
        }
    }

    public var primaryObject: String {
        switch self {
        case .today: "Reality Meridian"
        case .goals: "Direction Atlas"
        case .time: "LifeShape Field"
        case .motion: "Motion Current"
        case .you: "Personal system"
        }
    }

    public var systemImage: String {
        switch self {
        case .today: "sun.max"
        case .goals: "target"
        case .time: "clock.badge"
        case .motion: "point.topleft.down.curvedto.point.bottomright.up"
        case .you: "person.crop.circle"
        }
    }

    public var accessibilitySummary: String {
        "\(title). \(primaryObject)."
    }
}

public enum BottomNavigationContract {
    public static let requiredDestinations: [RootDestinationIdentity] = [.today, .goals, .time, .motion, .you]
    public static let requiredTitles: [String] = requiredDestinations.map(\.title)
    public static let requiredTitleSequence = "Today / Goals / Time / Motion / You"

    public static func isValidTitleSequence(_ titles: [String]) -> Bool {
        titles == requiredTitles
    }

    public static func isValidDestinationSequence(_ destinations: [RootDestinationIdentity]) -> Bool {
        destinations == requiredDestinations
    }
}

public struct RootDestinationIdentityRail: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private let selected: RootDestinationIdentity

    public init(selected: RootDestinationIdentity = .today) {
        self.selected = selected
    }

    public var body: some View {
        let useLiquidGlass = ambitionShouldUseLiquidGlass(
            reduceTransparency: reduceTransparency,
            colorSchemeContrast: colorSchemeContrast
        )

        let rail = HStack(spacing: theme.spacing.xs) {
            ForEach(BottomNavigationContract.requiredDestinations) { destination in
                let isSelected = destination == selected
                let chromeShape = Capsule(style: .continuous)

                VStack(spacing: theme.spacing.xxxs) {
                    Image(systemName: destination.systemImage)
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .accessibilityHidden(true)
                    Text(destination.title)
                        .font(theme.typography.micro)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
                .foregroundStyle(isSelected ? theme.shell.activeTabForeground : theme.shell.inactiveTabForeground)
                .frame(maxWidth: .infinity, minHeight: theme.panel.minimumTapTarget)
                .background {
                    if useLiquidGlass {
                        chromeShape
                            .fill(Color.clear)
                            .glassEffect(theme.shell.glass.controlGlass, in: chromeShape)
                    } else {
                        chromeShape.fill(isSelected ? theme.shell.activeTabBackground : .clear)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(destination.accessibilitySummary)
                .accessibilityValue(isSelected ? "Selected" : "Not selected")
            }
        }

        Group {
            if useLiquidGlass {
                GlassEffectContainer(spacing: theme.shell.glass.containerSpacing) {
                    rail
                }
            } else {
                rail
            }
        }
            .padding(theme.spacing.xxs)
            .background {
                let chromeShape = Capsule(style: .continuous)
                if useLiquidGlass {
                    chromeShape
                        .fill(Color.clear)
                        .glassEffect(theme.shell.glass.bottomBarGlass, in: chromeShape)
                } else {
                    chromeShape.fill(theme.shell.bottomBarMaterial)
                }
            }
            .overlay(Capsule(style: .continuous).stroke(theme.shell.divider, lineWidth: 1))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Bottom navigation")
            .accessibilityValue(BottomNavigationContract.requiredTitleSequence)
    }
}

public struct SegmentedFilterBar<Item: Hashable>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private let items: [Item]
    @Binding private var selection: Item
    private let title: (Item) -> String

    public init(items: [Item], selection: Binding<Item>, title: @escaping (Item) -> String) {
        self.items = items
        self._selection = selection
        self.title = title
    }

    public var body: some View {
        let useLiquidGlass = ambitionShouldUseLiquidGlass(
            reduceTransparency: reduceTransparency,
            colorSchemeContrast: colorSchemeContrast
        )

        let segments = HStack(spacing: theme.spacing.xs) {
            ForEach(items, id: \.self) { item in
                let state: AmbitionVisualState = item == selection ? .selected : .default

                Button {
                    selection = item
                } label: {
                    Text(title(item))
                        .font(theme.typography.caption)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .padding(.vertical, theme.spacing.xs)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: state))
                .accessibilityAddTraits(item == selection ? [.isSelected] : [])
            }
        }
        Group {
            if useLiquidGlass {
                GlassEffectContainer(spacing: theme.shell.glass.containerSpacing) {
                    segments
                }
            } else {
                segments
            }
        }
            .padding(theme.spacing.xxs)
            .background {
                let chromeShape = Capsule(style: .continuous)
                if useLiquidGlass {
                    chromeShape
                        .fill(Color.clear)
                        .glassEffect(theme.shell.glass.bottomBarGlass, in: chromeShape)
                } else {
                    chromeShape.fill(theme.colors.surfaceOverlay)
                }
            }
            .overlay(Capsule(style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
            .animation(theme.motion.animation(reduceMotion: reduceMotion), value: selection)
    }
}

public struct ListChevronRow<Leading: View, Trailing: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String?
    private let leading: Leading
    private let trailing: Trailing
    private let action: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading()
        self.trailing = trailing()
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            AmbitionRowShell(
                title: title,
                subtitle: subtitle,
                leading: { leading },
                trailing: {
                    HStack(spacing: theme.spacing.xs) {
                        trailing
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

public struct BottomNavShell<Item: Hashable>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private let items: [Item]
    @Binding private var selection: Item
    private let title: (Item) -> String
    private let icon: (Item) -> String

    public init(items: [Item], selection: Binding<Item>, title: @escaping (Item) -> String, icon: @escaping (Item) -> String) {
        self.items = items
        self._selection = selection
        self.title = title
        self.icon = icon
    }

    public var body: some View {
        let useLiquidGlass = ambitionShouldUseLiquidGlass(
            reduceTransparency: reduceTransparency,
            colorSchemeContrast: colorSchemeContrast
        )

        let bar = HStack(spacing: theme.spacing.sm) {
            ForEach(items, id: \.self) { item in
                let selected = item == selection

                Button {
                    selection = item
                } label: {
                    VStack(spacing: theme.spacing.xxxs) {
                        Image(systemName: icon(item))
                            .font(.system(size: theme.icon.mediumSize, weight: .semibold))
                        Text(title(item))
                            .font(theme.typography.micro)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
                    .padding(.vertical, theme.spacing.xs)
                    .foregroundStyle(selected ? theme.colors.textPrimary : theme.colors.textSecondary)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .fill(selected ? theme.colors.accentPrimary.opacity(0.18) : .clear)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? [.isSelected] : [])
            }
        }
        Group {
            if useLiquidGlass {
                GlassEffectContainer(spacing: theme.shell.glass.containerSpacing) {
                    bar
                }
            } else {
                bar
            }
        }
            .padding(theme.spacing.xs)
            .background {
                let chromeShape = RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                if useLiquidGlass {
                    chromeShape
                        .fill(Color.clear)
                        .glassEffect(theme.shell.glass.bottomBarGlass, in: chromeShape)
                } else {
                    chromeShape.fill(theme.colors.canvasElevated.opacity(theme.surfaces.backgroundBlurOpacity))
                }
            }
            .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
            .shadow(color: theme.elevation.raised.color, radius: theme.elevation.raised.radius, x: 0, y: theme.elevation.raised.y)
            .animation(theme.motion.animation(reduceMotion: reduceMotion), value: selection)
    }
}

public struct AmbitionPressableButtonStyle: ButtonStyle {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let state: AmbitionVisualState
    private let accent: Color?

    public init(state: AmbitionVisualState = .default, accent: Color? = nil) {
        self.state = state
        self.accent = accent
    }

    public func makeBody(configuration: Configuration) -> some View {
        let effectiveState: AmbitionVisualState = configuration.isPressed ? .pressed : state
        let resolved = theme.stateStyle(for: effectiveState, accent: accent)
        let chromeAccent = accent ?? resolved.accent
        let isPressed = configuration.isPressed && reduceMotion == false
        let shape = Capsule(style: .continuous)

        return configuration.label
            .font(theme.typography.bodyEmphasized)
            .foregroundStyle(resolved.foreground)
            .contentShape(shape)
            .background {
                ZStack {
                    shape.fill(
                        LinearGradient(
                            colors: [
                                chromeAccent.opacity(0.30),
                                resolved.fill.opacity(theme.mode == .dark ? 0.88 : 0.72),
                                theme.shell.controlBackground.opacity(0.58)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    shape.fill(
                        LinearGradient(
                            colors: [Color.white.opacity(isPressed ? 0.10 : 0.30), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
            .overlay {
                shape.stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.36), resolved.stroke.opacity(0.86), chromeAccent.opacity(0.30)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            }
            .overlay(alignment: .bottom) {
                shape.stroke(theme.colors.canvas.opacity(0.42), lineWidth: 1)
            }
            .shadow(color: chromeAccent.opacity(isPressed ? 0.12 : 0.24), radius: isPressed ? 7 : 16, x: 0, y: isPressed ? 3 : 10)
            .shadow(color: Color.black.opacity(theme.mode == .dark ? 0.24 : 0.10), radius: isPressed ? 6 : 14, x: 0, y: isPressed ? 2 : 8)
            .offset(y: isPressed ? 1 : 0)
            .scaleEffect(isPressed ? 0.982 : resolved.scale)
            .opacity(resolved.opacity)
            .animation(theme.motion.settleAnimation(reduceMotion: reduceMotion), value: configuration.isPressed)
    }
}
#endif
