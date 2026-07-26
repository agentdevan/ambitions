import SwiftUI

extension TodayFlagshipCalibrationContent {
    var settlementAccessibilityIdentity: String {
        "\(interfaceCopy.settlementTitle). \(primaryStep.title)"
    }
}

struct TodayVitalitySettlementView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @AccessibilityFocusState private var isSettledTruthFocused: Bool

    let content: TodayFlagshipCalibrationContent
    let acceptedTruth: String
    let shouldFocusTruth: Bool
    let onOpenHistory: () -> Void
    let onReturnToToday: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                settlementHeading
                resolvedField

                Rectangle()
                    .fill(palette.separator)
                    .frame(height: palette.separatorStrokeWidth)
                    .accessibilityHidden(true)

                history
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            returnAction
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.labelPrimary)
        .onAppear {
            isSettledTruthFocused = shouldFocusTruth
        }
        .onChange(of: shouldFocusTruth) { _, shouldFocus in
            guard shouldFocus else { return }
            isSettledTruthFocused = true
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("r13-settlement-field")
    }

    private var settlementHeading: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(content.interfaceCopy.settledStateAccessibilityTitle)
                .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                .foregroundStyle(palette.settledState)

            Text(content.interfaceCopy.settlementTitle)
                .font(TodayVitalityTypographyRole.objectIdentity.font)
                .foregroundStyle(palette.labelPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(content.settlementAccessibilityIdentity)
        .accessibilityIdentifier("r13-settlement-heading")
    }

    private var resolvedField: some View {
        HStack(alignment: .top, spacing: 8) {
            resolvedRail

            VStack(alignment: .leading, spacing: 18) {
                settledTruth
                parentPursuit
                localEvidence
            }
            .padding(.top, 7)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("r13-settlement-resolved-node")
    }

    private var resolvedRail: some View {
        VStack(spacing: 0) {
            TodayVitalityNode(kind: .settled, palette: palette)

            Rectangle()
                .fill(palette.settledState)
                .frame(width: palette.separatorStrokeWidth)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 44)
        .accessibilityHidden(true)
    }

    private var settledTruth: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(settlementTime)
                .font(TodayVitalityTypographyRole.metadata.font.monospacedDigit().weight(.semibold))
                .foregroundStyle(palette.settledState)
                .accessibilityIdentifier("r13-settlement-time")

            Text(acceptedTruth)
                .font(TodayVitalityTypographyRole.stateTruth.font)
                .foregroundStyle(palette.labelPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(content.interfaceCopy.settledStateAccessibilityTitle)
        .accessibilityValue(acceptedTruth)
        .accessibilityFocused($isSettledTruthFocused)
        .accessibilityIdentifier("tfcs-settled-truth")
    }

    private var parentPursuit: some View {
        Label {
            Text("\(settlementPrefix) \(parentPursuitTitle)")
        } icon: {
            Image(systemName: "house")
                .foregroundStyle(palette.ambitionsAccentMuted)
                .accessibilityHidden(true)
        }
        .font(TodayVitalityTypographyRole.relationship.font)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(content.interfaceCopy.settlementRelationshipPrefix) "
                + content.primaryStep.parentPursuitTitle
        )
        .accessibilityIdentifier("tfcs-settlement-parent-pursuit")
    }

    private var settlementPrefix: Text {
        Text(content.interfaceCopy.settlementRelationshipPrefix)
            .foregroundStyle(palette.labelSecondary)
    }

    private var parentPursuitTitle: Text {
        Text(content.primaryStep.parentPursuitTitle)
            .foregroundStyle(palette.ambitionsAccentMuted)
    }

    private var localEvidence: some View {
        Label(content.receipt.recordedLabel, systemImage: "clock.arrow.circlepath")
            .font(TodayVitalityTypographyRole.relationship.font)
            .foregroundStyle(palette.labelSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("tfcs-recorded-acknowledgment")
    }

    private var history: some View {
        Button(action: onOpenHistory) {
            HStack(spacing: 10) {
                Text(content.interfaceCopy.viewHistoryTitle)
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .font(TodayVitalityTypographyRole.action.font)
        .foregroundStyle(palette.labelPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityHint("Open local history")
        .accessibilityInputLabels([content.interfaceCopy.viewHistoryTitle])
        .accessibilityIdentifier("tfcs-view-history")
    }

    private var returnAction: some View {
        Button(action: onReturnToToday) {
            ZStack {
                Text(content.interfaceCopy.returnTodayTitle)
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
        .accessibilityLabel(content.interfaceCopy.returnTodayTitle)
        .accessibilityHint(content.interfaceCopy.returnTodayHint)
        .accessibilityInputLabels([content.interfaceCopy.returnTodayTitle])
        .accessibilityIdentifier("tfcs-return-to-today")
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

    private var settlementTime: String {
        content.primaryStep.temporalContext.fullDayTimeLabel
            ?? content.primaryStep.temporalContext.exactTime
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
