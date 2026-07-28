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
            }

            Text(relationship)
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
                .opacity(relationshipOpacity)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
        .accessibilityElement(children: .ignore)
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
    let copy: TodayFlagshipInterfaceCopy
    let palette: TodayFlagshipPalette
    let isScrolling: Bool

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                TodayVitalityDockMaterial(
                    palette: palette,
                    isInteractive: true,
                    shape: edgeShape
                )
                .frame(width: isScrolling ? 30 : 44, height: isScrolling ? 44 : 56)
                .accessibilityIdentifier("r14-dock-peek-visible-seam")
            }

            VStack(spacing: 3) {
                Image(systemName: TodayFlagshipNavigationCommand.today.symbolName)
                    .font(.caption.weight(.semibold))

                if isScrolling == false {
                    Text(copy.navigationTitle(for: .today))
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .foregroundStyle(palette.primaryInk)
            .accessibilityHidden(true)
        }
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
