import SwiftUI

struct TodayVitalityRootCrown: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutDirection) private var layoutDirection
    @ScaledMetric(relativeTo: .body) private var verticalSpacing = 4.0

    let copy: TodayFlagshipInterfaceCopy
    let relationship: String
    let palette: TodayFlagshipPalette
    let scrollProgress: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            HStack(spacing: 7) {
                Image(systemName: "crown.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(palette.secondaryInk)
                    .accessibilityHidden(true)

                Text(copy.ambitionsWordmark)
                    .font(.subheadline.weight(.medium))
                    .accessibilityIdentifier("tfcs-ambitions-wordmark")
            }

            Text(relationship)
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
                .opacity(relationshipOpacity)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(copy.todayAccessibilityHeading)
        .accessibilityValue(crownAccessibilityValue)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("tfcs-today-heading")
    }

    private var relationshipOpacity: Double {
        if dynamicTypeSize.isAccessibilitySize || layoutDirection == .rightToLeft {
            return 1
        }
        return 1 - (0.82 * scrollProgress)
    }

    private var crownAccessibilityValue: String {
        [copy.ambitionsWordmark, relationship].joined(separator: ", ")
    }
}

struct TodayVitalityDockPeekLabel: View {
    let palette: TodayFlagshipPalette

    var body: some View {
        ZStack {
            TodayVitalityDockMaterial(
                palette: palette,
                isInteractive: true,
                shape: edgeShape
            )

            ZStack {
                Circle()
                    .strokeBorder(palette.secondaryInk, lineWidth: 1.5)
                    .frame(width: 20, height: 20)

                Circle()
                    .fill(palette.articulationAccent)
                    .frame(width: 7, height: 7)
            }
            .accessibilityHidden(true)
        }
        .frame(width: 30, height: 52)
        .frame(width: 44, height: 56, alignment: .trailing)
        .contentShape(Rectangle())
    }

    private var edgeShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 13,
            bottomLeadingRadius: 13,
            bottomTrailingRadius: 0,
            topTrailingRadius: 0,
            style: .continuous
        )
    }
}

struct TodayVitalityDockMaterial<Shape: InsettableShape>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let palette: TodayFlagshipPalette
    let isInteractive: Bool
    let shape: Shape

    var body: some View {
        if reduceTransparency {
            opaqueSurface
        } else {
            nativeSurface
        }
    }

    private var opaqueSurface: some View {
        shape
            .fill(palette.opaqueChrome)
            .overlay {
                shape.stroke(palette.divider, lineWidth: 1)
            }
    }

    @ViewBuilder
    private var nativeSurface: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            shape
                .fill(palette.opaqueChrome.opacity(0.88))
                .glassEffect(
                    .regular
                        .tint(palette.opaqueChrome.opacity(0.36))
                        .interactive(isInteractive),
                    in: shape
                )
                .overlay {
                    shape.stroke(palette.divider, lineWidth: 1)
                }
        } else {
            opaqueSurface
        }
        #else
        opaqueSurface
        #endif
    }
}
