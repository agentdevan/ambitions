import SwiftUI

struct TodayVitalityFocusedStepView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @AccessibilityFocusState private var isIdentityFocused: Bool

    let content: TodayFlagshipCalibrationContent
    let acceptedTruth: String
    let shouldFocusIdentity: Bool
    let onSelectStillCounts: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                identity
                parentPursuit
                presentField
                temporalRelationship

                Rectangle()
                    .fill(palette.separator)
                    .frame(height: palette.separatorStrokeWidth)
                    .accessibilityHidden(true)

                TodayVitalityFocusedOutcome(
                    title: content.primaryStep.stillCountsProposal.outcomeTitle,
                    proposedTruth: content.primaryStep.stillCountsProposal.proposedTruth,
                    palette: palette
                )
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 20)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("tfcs-focused-object-field")
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            reviewAction
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.labelPrimary)
        .onAppear {
            isIdentityFocused = shouldFocusIdentity
        }
        .onChange(of: shouldFocusIdentity) { _, shouldFocus in
            guard shouldFocus else { return }
            isIdentityFocused = true
        }
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(content.interfaceCopy.stepTitle)
                .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                .foregroundStyle(palette.ambitionsAccentMuted)

            Text(content.primaryStep.title)
                .font(TodayVitalityTypographyRole.objectIdentity.font)
                .foregroundStyle(palette.labelPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
        .accessibilityElement(children: .combine)
        .accessibilityFocused($isIdentityFocused)
        .accessibilityIdentifier("tfcs-focused-identity")
    }

    private var parentPursuit: some View {
        Label(content.primaryStep.parentPursuitTitle, systemImage: "house")
            .font(TodayVitalityTypographyRole.relationship.font.weight(.medium))
            .foregroundStyle(palette.ambitionsAccentMuted)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(content.primaryStep.parentPursuitTitle)
            .accessibilityIdentifier("tfcs-focused-parent-pursuit")
    }

    private var presentField: some View {
        HStack(alignment: .top, spacing: 8) {
            TodayVitalityRailNode(
                kind: .current,
                palette: palette,
                extendsAfter: true
            )

            VStack(alignment: .leading, spacing: 12) {
                Text(content.interfaceCopy.rightNowTitle)
                    .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.ambitionsAccentMuted)

                Text(acceptedTruth)
                    .font(TodayVitalityTypographyRole.stateTruth.font)
                    .foregroundStyle(palette.labelPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("tfcs-current-truth")

                Text(content.primaryStep.startHereSummary)
                    .font(TodayVitalityTypographyRole.relationship.font)
                    .foregroundStyle(palette.labelSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("tfcs-focused-protected-consequence")
            }
            .padding(.top, 7)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-focused-current-truth")
    }

    private var temporalRelationship: some View {
        Label {
            Text(
                "\(content.primaryStep.temporalContext.exactTime) · "
                    + content.primaryStep.temporalContext.relationship
            )
            .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "clock")
                .accessibilityHidden(true)
        }
        .font(TodayVitalityTypographyRole.metadata.font.monospacedDigit())
        .foregroundStyle(palette.labelSecondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(content.primaryStep.temporalContext.exactTime) · "
                + content.primaryStep.temporalContext.relationship
        )
        .accessibilityIdentifier("tfcs-focused-temporal-anchor")
    }

    private var reviewAction: some View {
        Button(action: onSelectStillCounts) {
            ZStack {
                Text("Choose Still Counts")
                    .multilineTextAlignment(.center)

                HStack {
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .accessibilityHidden(true)
                }
            }
            .frame(minHeight: 48)
        }
        .buttonStyle(
            TodayVitalityActionStyle(
                role: .continuation,
                palette: palette
            )
        )
        .accessibilityLabel(content.primaryStep.stillCountsProposal.outcomeTitle)
        .accessibilityHint(content.interfaceCopy.reviewStillCountsHint)
        .accessibilityInputLabels([
            content.primaryStep.stillCountsProposal.outcomeTitle,
            "Choose Still Counts"
        ])
        .accessibilityIdentifier("tfcs-select-still-counts")
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background {
            palette.canvas
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(palette.separator)
                        .frame(height: palette.separatorStrokeWidth)
                }
        }
    }

    private var palette: TodayVitalityPalette {
        TodayVitalityPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast,
            differentiateWithoutColor: differentiateWithoutColor,
            reduceTransparency: reduceTransparency
        )
    }
}

private struct TodayVitalityFocusedOutcome: View {
    let title: String
    let proposedTruth: String
    let palette: TodayVitalityPalette

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            TodayVitalityRailNode(
                kind: .proposed,
                palette: palette,
                extendsAfter: false
            )

            VStack(alignment: .leading, spacing: 9) {
                Text(title)
                    .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.ambitionsAccentMuted)

                Text(proposedTruth)
                    .font(TodayVitalityTypographyRole.stateTruth.font)
                    .foregroundStyle(palette.labelPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 7)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(proposedTruth)
        .accessibilityIdentifier("r13-focused-outcome")
    }
}
