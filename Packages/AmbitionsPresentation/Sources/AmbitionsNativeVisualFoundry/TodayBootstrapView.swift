import SwiftUI

enum TodayBootstrapNavigationCommand: String, Equatable, Identifiable {
    case today
    case goals
    case time
    case you
    case search
    case capture

    static let roots: [Self] = [.today, .goals, .time, .you]
    static let globalActions: [Self] = [.search, .capture]

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .time: "Time"
        case .you: "You"
        case .search: "Search"
        case .capture: "Capture"
        }
    }

    var symbolName: String {
        switch self {
        case .today: "sun.max"
        case .goals: "target"
        case .time: "clock"
        case .you: "person.crop.circle"
        case .search: "magnifyingglass"
        case .capture: "plus"
        }
    }

    var isSelectedRoot: Bool {
        self == .today
    }
}

public struct TodayBootstrapView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var sectionSpacing = 24.0

    private let content: TodayBootstrapContent
    private let onOpenStep: () -> Void
    private let onOpenDock: () -> Void

    public init(
        content: TodayBootstrapContent,
        onOpenStep: @escaping () -> Void,
        onOpenDock: @escaping () -> Void
    ) {
        self.content = content
        self.onOpenStep = onOpenStep
        self.onOpenDock = onOpenDock
    }

    public var body: some View {
        ZStack(alignment: .trailing) {
            palette.semanticPlane
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: sectionSpacing) {
                    crown
                    if usesAdaptiveNavigation {
                        adaptiveNavigationPassage
                    }
                    startHere
                    timeline
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.leading, 24)
                .padding(.trailing, usesAdaptiveNavigation ? 24 : 68)
                .padding(.top, 12)
                .padding(.bottom, 44)
            }
            .scrollIndicators(.hidden)

            if !usesAdaptiveNavigation {
                peekDock
                    .padding(.trailing, 2)
            }
        }
        .foregroundStyle(palette.primaryInk)
        .tint(palette.actionAccent)
        .accessibilityIdentifier("today-bootstrap-root")
    }

    private var crown: some View {
        Group {
            if usesAdaptiveNavigation {
                VStack(alignment: .leading, spacing: 4) {
                    crownTitle
                    crownRelationship
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    crownTitle
                    crownRelationship
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("today-bootstrap-crown")
    }

    private var crownTitle: some View {
        Text(content.crownTitle)
            .font(.title3.weight(.semibold))
            .accessibilityAddTraits(.isHeader)
    }

    private var crownRelationship: some View {
        Text(content.dateRelationship)
            .font(.caption)
            .foregroundStyle(palette.secondaryInk)
    }

    private var startHere: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(content.startHereEyebrow)
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.articulationAccent)

            Text(content.startHereTitle)
                .font(.title2.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 10) {
                Text(content.currentTruth)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                Text(content.materialConsequence)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onOpenStep) {
                    Text(content.primaryActionTitle)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(palette.actionInk)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 6))
                .controlSize(.small)
                .frame(minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
                .accessibilityIdentifier("today-bootstrap-open-step")
            }
            .padding(.leading, 12)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(palette.localArticulation)
                    .frame(width: 2)
                    .padding(.vertical, 6)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityIdentifier("today-bootstrap-start-here")
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text(content.timelineTitle)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            ForEach(content.timelineEntries) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.body.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)

                    if usesAdaptiveNavigation {
                        VStack(alignment: .leading, spacing: 2) {
                            timelineTime(entry.timeLabel)
                            timelineRelationship(entry.relationship)
                        }
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            timelineTime(entry.timeLabel)
                            Text(entry.relationship)
                                .font(.subheadline)
                                .foregroundStyle(palette.secondaryInk)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(.top, 4)
        .accessibilityIdentifier("today-bootstrap-timeline")
    }

    private func timelineTime(_ value: String) -> some View {
        Text(value)
            .font(.caption.monospacedDigit().weight(.semibold))
            .foregroundStyle(palette.tertiaryInk)
    }

    private func timelineRelationship(_ value: String) -> some View {
        Text(value)
            .font(.subheadline)
            .foregroundStyle(palette.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var adaptiveNavigationPassage: some View {
        VStack(alignment: .leading, spacing: 12) {
            adaptiveNavigationGroup(
                title: "Roots",
                commands: TodayBootstrapNavigationCommand.roots
            )

            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
                .accessibilityHidden(true)

            adaptiveNavigationGroup(
                title: "Global actions",
                commands: TodayBootstrapNavigationCommand.globalActions
            )
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.opaqueChrome)
        }
        .accessibilityIdentifier("today-bootstrap-adaptive-navigation")
    }

    private func adaptiveNavigationGroup(
        title: String,
        commands: [TodayBootstrapNavigationCommand]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.secondaryInk)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(commands) { command in
                    adaptiveNavigationCommand(command)
                }
            }
        }
    }

    private func adaptiveNavigationCommand(
        _ command: TodayBootstrapNavigationCommand
    ) -> some View {
        Button(action: onOpenDock) {
            HStack(spacing: 8) {
                Image(systemName: command.symbolName)
                    .frame(width: 22)

                Text(command.title)
                    .fontWeight(command.isSelectedRoot ? .semibold : .regular)

                Spacer(minLength: 0)
            }
            .font(.body)
            .lineLimit(1)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .padding(.horizontal, 10)
            .background {
                if command.isSelectedRoot {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(palette.selectedChrome)
                }
            }
            .overlay(alignment: .trailing) {
                if command.isSelectedRoot {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .padding(.trailing, 8)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(command.title)
        .accessibilityValue(command.isSelectedRoot ? "Selected root" : "")
        .accessibilityAddTraits(command.isSelectedRoot ? .isSelected : [])
        .accessibilityIdentifier(
            "today-bootstrap-navigation-\(command.rawValue)"
        )
    }

    private var peekDock: some View {
        Button(action: onOpenDock) {
            ZStack(alignment: .trailing) {
                Color.clear
                dockChrome
                    .offset(x: 8)
            }
            .frame(width: 44, height: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open global navigation")
        .accessibilityHint("Shows Today, Goals, Time, You, Search, and Capture")
        .accessibilityIdentifier("today-bootstrap-peek-dock")
    }

    @ViewBuilder
    private var dockChrome: some View {
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        ZStack {
            if reduceTransparency {
                shape
                    .fill(palette.opaqueChrome)
                    .overlay { shape.stroke(palette.divider, lineWidth: 1) }
            } else if #available(iOS 26.0, macOS 26.0, *) {
                Color.clear
                    .frame(width: 24, height: 40)
                    .glassEffect(
                        .regular
                            .tint(palette.opaqueChrome.opacity(0.36))
                            .interactive(),
                        in: shape
                    )
                    .overlay { shape.stroke(palette.divider, lineWidth: 1) }
            } else {
                shape
                    .fill(palette.opaqueChrome)
                    .overlay { shape.stroke(palette.divider, lineWidth: 1) }
            }

            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(palette.secondaryInk)
                .accessibilityHidden(true)
        }
        .frame(width: 24, height: 40)
    }

    private var usesAdaptiveNavigation: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var palette: TodayBootstrapPalette {
        TodayBootstrapPalette(colorScheme: colorScheme)
    }
}

private struct TodayBootstrapPalette {
    let colorScheme: ColorScheme

    var semanticPlane: Color {
        colorScheme == .dark
            ? Color(red: 0.075, green: 0.078, blue: 0.086)
            : Color(red: 0.945, green: 0.937, blue: 0.910)
    }

    var primaryInk: Color {
        colorScheme == .dark
            ? Color(red: 0.94, green: 0.93, blue: 0.90)
            : Color(red: 0.12, green: 0.12, blue: 0.13)
    }

    var secondaryInk: Color {
        colorScheme == .dark
            ? Color(red: 0.72, green: 0.71, blue: 0.69)
            : Color(red: 0.31, green: 0.30, blue: 0.29)
    }

    var tertiaryInk: Color {
        colorScheme == .dark
            ? Color(red: 0.57, green: 0.56, blue: 0.54)
            : Color(red: 0.43, green: 0.42, blue: 0.40)
    }

    var actionAccent: Color {
        colorScheme == .dark
            ? Color(red: 0.38, green: 0.36, blue: 0.60)
            : Color(red: 0.30, green: 0.27, blue: 0.55)
    }

    var articulationAccent: Color {
        colorScheme == .dark
            ? Color(red: 0.68, green: 0.66, blue: 0.90)
            : Color(red: 0.35, green: 0.30, blue: 0.60)
    }

    var actionInk: Color {
        .white
    }

    var localArticulation: Color {
        primaryInk.opacity(colorScheme == .dark ? 0.20 : 0.14)
    }

    var divider: Color {
        primaryInk.opacity(colorScheme == .dark ? 0.22 : 0.16)
    }

    var opaqueChrome: Color {
        colorScheme == .dark
            ? Color(red: 0.15, green: 0.15, blue: 0.17)
            : Color(red: 0.89, green: 0.88, blue: 0.85)
    }

    var selectedChrome: Color {
        colorScheme == .dark
            ? Color(red: 0.25, green: 0.24, blue: 0.30)
            : Color(red: 0.83, green: 0.82, blue: 0.79)
    }
}
