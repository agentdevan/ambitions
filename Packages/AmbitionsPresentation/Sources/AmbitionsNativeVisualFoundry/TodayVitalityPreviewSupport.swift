import SwiftUI

#if DEBUG
struct TodayVitalityGrammarPreview: View {
    var forcedContrast: ColorSchemeContrast?
    var forceDifferentiateWithoutColor = false
    var forceReduceTransparency = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var palette: TodayVitalityPalette {
        TodayVitalityPalette(
            colorScheme: colorScheme,
            contrast: forcedContrast ?? contrast,
            differentiateWithoutColor: forceDifferentiateWithoutColor
                || differentiateWithoutColor,
            reduceTransparency: forceReduceTransparency || reduceTransparency
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                typeSpecimen
                reliefSpecimen
                nodeSpecimen
                actionSpecimen
                chromeSpecimen
            }
            .padding(24)
        }
        .background(palette.canvas)
    }

    private var typeSpecimen: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Make the nursery ready for the crib")
                .font(TodayVitalityTypographyRole.objectIdentity.font)
                .foregroundStyle(palette.labelPrimary)
            Text("The corner is cleared and the paint sample is chosen.")
                .font(TodayVitalityTypographyRole.stateTruth.font)
                .foregroundStyle(palette.labelPrimary)
            Text("Welcome our baby home")
                .font(TodayVitalityTypographyRole.relationship.font)
                .foregroundStyle(palette.labelSecondary)
            Text("Available now · before 2:00 PM handoff")
                .font(TodayVitalityTypographyRole.metadata.font)
                .foregroundStyle(palette.labelTertiary)
        }
        .accessibilityElement(children: .contain)
    }

    private var reliefSpecimen: some View {
        TodayVitalityOpenRelief(palette: palette) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Right now")
                    .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.ambitionsAccentMuted)
                Text("Present truth stays open and matte.")
                    .font(TodayVitalityTypographyRole.stateTruth.font)
                    .foregroundStyle(palette.labelPrimary)
                Text("Relief is local to meaning, without a floating content card.")
                    .font(TodayVitalityTypographyRole.relationship.font)
                    .foregroundStyle(palette.labelSecondary)
            }
        }
    }

    private var nodeSpecimen: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Continuity nodes")
                .font(TodayVitalityTypographyRole.relationship.font.weight(.semibold))
                .foregroundStyle(palette.labelPrimary)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 128), alignment: .leading)],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(TodayVitalityNodeKind.allCases, id: \.self) { kind in
                    HStack(spacing: 6) {
                        TodayVitalityNode(kind: kind, palette: palette)
                        Text(kind.nonColorShapeLabel)
                            .font(TodayVitalityTypographyRole.metadata.font)
                            .foregroundStyle(palette.labelSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    private var actionSpecimen: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Action roles")
                .font(TodayVitalityTypographyRole.relationship.font.weight(.semibold))
                .foregroundStyle(palette.labelPrimary)

            ForEach(TodayVitalityActionRole.allCases, id: \.self) { role in
                Button(role.purposeLabel) {}
                    .buttonStyle(
                        TodayVitalityActionStyle(
                            role: role,
                            palette: palette,
                            isSelected: role == .outcomeSelection
                        )
                    )
            }
        }
    }

    private var chromeSpecimen: some View {
        TodayVitalityFunctionalChrome(palette: palette) {
            Label("Functional chrome", systemImage: "circle.grid.2x2")
                .font(TodayVitalityTypographyRole.action.font)
                .foregroundStyle(palette.labelPrimary)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 52)
                .padding(.horizontal, 16)
        }
        .accessibilityLabel("Functional chrome preview")
    }
}

#Preview("R13 Grammar — Light") {
    TodayVitalityGrammarPreview()
        .preferredColorScheme(.light)
}

#Preview("R13 Grammar — Dark") {
    TodayVitalityGrammarPreview()
        .preferredColorScheme(.dark)
}

#Preview("R13 Grammar — Increased Contrast") {
    TodayVitalityGrammarPreview(forcedContrast: .increased)
        .preferredColorScheme(.dark)
}

#Preview("R13 Grammar — Differentiate Without Color") {
    TodayVitalityGrammarPreview(forceDifferentiateWithoutColor: true)
        .preferredColorScheme(.dark)
}

#Preview("R13 Grammar — Dynamic Type") {
    TodayVitalityGrammarPreview()
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}
#endif
