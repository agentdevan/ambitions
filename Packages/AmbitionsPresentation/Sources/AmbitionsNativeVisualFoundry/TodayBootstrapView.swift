import SwiftUI

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
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(palette.actionAccent)
                    .frame(width: 20, height: 2)
                    .accessibilityHidden(true)

                Text(content.startHereEyebrow)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.actionAccent)
            }

            Text(content.startHereTitle)
                .font(.title2.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(content.currentTruth)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            Text(content.materialConsequence)
                .font(.callout.weight(.medium))
                .foregroundStyle(palette.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onOpenStep) {
                Text(content.primaryActionTitle)
                    .foregroundStyle(.white)
                    .frame(
                        maxWidth: usesAdaptiveNavigation ? .infinity : nil
                    )
            }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 10))
                .controlSize(.regular)
                .accessibilityIdentifier("today-bootstrap-open-step")
        }
        .accessibilityIdentifier("today-bootstrap-start-here")
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(content.timelineTitle)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            ForEach(content.timelineEntries) { entry in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(palette.tertiaryInk)
                        .frame(width: 5, height: 5)
                        .padding(.top, 7)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(entry.title)
                            .font(.body.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)

                        Text(entry.relationship)
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(entry.timeLabel)
                            .font(.caption.monospacedDigit().weight(.medium))
                            .foregroundStyle(palette.tertiaryInk)
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
        .accessibilityIdentifier("today-bootstrap-timeline")
    }

    private var adaptiveNavigationPassage: some View {
        Button(action: onOpenDock) {
            Text("Open navigation")
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 10))
        .controlSize(.large)
        .accessibilityHint("Shows the Crowned Edge Dock")
        .accessibilityIdentifier("today-bootstrap-adaptive-navigation")
    }

    private var peekDock: some View {
        Button(action: onOpenDock) {
            ZStack {
                Color.clear
                dockChrome
            }
            .frame(width: 44, height: 88)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open navigation")
        .accessibilityHint("Shows the Crowned Edge Dock")
        .accessibilityIdentifier("today-bootstrap-peek-dock")
    }

    @ViewBuilder
    private var dockChrome: some View {
        let shape = RoundedRectangle(cornerRadius: 7, style: .continuous)
        if reduceTransparency {
            shape
                .fill(palette.opaqueChrome)
                .overlay { shape.stroke(palette.divider, lineWidth: 1) }
                .frame(width: 14, height: 72)
        } else if #available(iOS 26.0, macOS 26.0, *) {
            Color.clear
                .frame(width: 14, height: 72)
                .glassEffect(
                    .regular.interactive(),
                    in: shape
                )
                .overlay { shape.stroke(palette.divider, lineWidth: 1) }
        } else {
            shape
                .fill(palette.opaqueChrome)
                .overlay { shape.stroke(palette.divider, lineWidth: 1) }
                .frame(width: 14, height: 72)
        }
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
            ? Color(red: 0.69, green: 0.67, blue: 0.98)
            : Color(red: 0.31, green: 0.27, blue: 0.72)
    }

    var divider: Color {
        primaryInk.opacity(colorScheme == .dark ? 0.22 : 0.16)
    }

    var opaqueChrome: Color {
        colorScheme == .dark
            ? Color(red: 0.15, green: 0.15, blue: 0.17)
            : Color(red: 0.89, green: 0.88, blue: 0.85)
    }
}
