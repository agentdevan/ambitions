import SwiftUI

public struct TodayBootstrapView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .body) private var sectionSpacing = 28.0

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
                    startHere
                    timeline
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 44)
            }
            .scrollIndicators(.hidden)

            peekDock
                .padding(.trailing, 8)
        }
        .foregroundStyle(palette.primaryInk)
        .tint(palette.actionAccent)
        .accessibilityIdentifier("today-bootstrap-root")
    }

    private var crown: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(content.crownTitle)
                .font(.largeTitle.weight(.semibold))
                .accessibilityAddTraits(.isHeader)

            Text(content.dateRelationship)
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)

            Text(content.fixtureLabel)
                .font(.footnote)
                .foregroundStyle(palette.tertiaryInk)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("today-bootstrap-crown")
    }

    private var startHere: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(content.startHereEyebrow)
                .font(.headline)
                .foregroundStyle(palette.actionAccent)

            Text(content.startHereTitle)
                .font(.title.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(content.currentTruth)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            Text(content.materialConsequence)
                .font(.body.weight(.medium))
                .foregroundStyle(palette.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onOpenStep) {
                Text(content.primaryActionTitle)
                    .foregroundStyle(.white)
            }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("today-bootstrap-open-step")
        }
        .padding(.leading, 18)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(palette.actionAccent)
                .frame(width: 3)
                .accessibilityHidden(true)
        }
        .accessibilityIdentifier("today-bootstrap-start-here")
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(content.timelineTitle)
                .font(.title3.weight(.semibold))
                .padding(.bottom, 12)
                .accessibilityAddTraits(.isHeader)

            ForEach(content.timelineEntries) { entry in
                Divider()
                    .overlay(palette.divider)

                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text(entry.timeLabel)
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(palette.secondaryInk)
                        .frame(width: 76, alignment: .leading)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(entry.title)
                            .font(.body.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)

                        Text(entry.relationship)
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 14)
                .accessibilityElement(children: .combine)
            }
        }
        .accessibilityIdentifier("today-bootstrap-timeline")
    }

    private var peekDock: some View {
        Button(action: onOpenDock) {
            Image(systemName: "chevron.left")
                .font(.headline.weight(.semibold))
                .frame(width: 44, height: 72)
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .background { dockChrome }
        .accessibilityLabel("Open navigation")
        .accessibilityHint("Shows the Crowned Edge Dock")
        .accessibilityIdentifier("today-bootstrap-peek-dock")
    }

    @ViewBuilder
    private var dockChrome: some View {
        let shape = Capsule()
        if reduceTransparency {
            shape
                .fill(palette.opaqueChrome)
                .overlay { shape.stroke(palette.divider, lineWidth: 1) }
        } else if #available(iOS 26.0, macOS 26.0, *) {
            Color.clear
                .glassEffect(
                    .regular.tint(palette.actionAccent.opacity(0.10)),
                    in: shape
                )
                .overlay { shape.stroke(palette.divider, lineWidth: 1) }
        } else {
            shape
                .fill(palette.opaqueChrome)
                .overlay { shape.stroke(palette.divider, lineWidth: 1) }
        }
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
