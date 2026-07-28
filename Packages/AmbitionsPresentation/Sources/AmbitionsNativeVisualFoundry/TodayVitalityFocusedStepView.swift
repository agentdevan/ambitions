import SwiftUI

struct TodayVitalityFocusedStepView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AccessibilityFocusState private var isIdentityFocused: Bool
    @AccessibilityFocusState private var isRecoveredProgressFocused: Bool

    let content: TodayFlagshipCalibrationContent
    let step: TodayFlagshipStepSnapshot
    let shouldFocusIdentity: Bool
    var recoveredProgress: String?
    var shouldFocusRecoveredProgress: Bool = false
    let showsStillCountsOutcome: Bool
    let showsParentPursuitNavigation: Bool
    let onOpenGoalDetail: () -> Void
    let onSelectStillCounts: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                identity
                parentPursuit
                presentField
                if let recoveredProgress {
                    TodayVitalityRecoveredProgressField(
                        title: content.interfaceCopy.lastSavedProgressTitle,
                        progress: recoveredProgress,
                        palette: palette
                    )
                    .accessibilityFocused($isRecoveredProgressFocused)
                }
                temporalRelationship

                if showsStillCountsOutcome {
                    TodayVitalityOutcomeTransitionSeam(palette: palette)

                    TodayVitalityFocusedOutcome(
                        title: step.stillCountsProposal.outcomeTitle,
                        proposedTruth: step.stillCountsProposal.proposedTruth,
                        palette: palette
                    )

                    if usesFlowingReviewAction {
                        VStack(spacing: 0) {
                            reviewAction
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 36)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("r13-focused-flowing-action")
                    }
                }
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 0)
            .padding(.bottom, 20)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("tfcs-focused-object-field")
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if showsStillCountsOutcome && usesFlowingReviewAction == false {
                anchoredReviewAction
            }
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
        .onAppear {
            isRecoveredProgressFocused = shouldFocusRecoveredProgress
        }
        .onChange(of: shouldFocusRecoveredProgress) { _, shouldFocus in
            guard shouldFocus else { return }
            isRecoveredProgressFocused = true
        }
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(content.interfaceCopy.stepTitle)
                .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                .foregroundStyle(palette.ambitionsAccentMuted)

            Text(step.title)
                .font(TodayVitalityTypographyRole.objectIdentity.font)
                .foregroundStyle(palette.labelPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("tfcs-focused-step-id-\(step.id)")
        }
        .accessibilityElement(children: .combine)
        .accessibilityFocused($isIdentityFocused)
        .accessibilityIdentifier("tfcs-focused-identity")
    }

    private var parentPursuit: some View {
        Group {
            if showsParentPursuitNavigation {
                Button(action: onOpenGoalDetail) {
                    parentPursuitLabel
                }
                .buttonStyle(.plain)
                .accessibilityHint("Open Goal details")
            } else {
                parentPursuitLabel
            }
        }
        .font(TodayVitalityTypographyRole.relationship.font.weight(.medium))
        .foregroundStyle(palette.ambitionsAccentMuted)
        .accessibilityLabel(step.parentPursuitTitle)
        .accessibilityIdentifier("tfcs-focused-parent-pursuit")
    }

    private var parentPursuitLabel: some View {
            HStack(spacing: 9) {
                Image(systemName: "house")
                    .accessibilityHidden(true)
                Text(step.parentPursuitTitle)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                if showsParentPursuitNavigation {
                    Image(systemName: "chevron.forward")
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
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

                Text(step.currentAcceptedTruth)
                    .font(TodayVitalityTypographyRole.stateTruth.font)
                    .foregroundStyle(palette.labelPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("tfcs-current-truth")

                Text(step.materialConsequence)
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
                "\(step.temporalContext.exactTime) · "
                    + step.temporalContext.relationship
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
            "\(step.temporalContext.exactTime) · "
                + step.temporalContext.relationship
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
        .accessibilityLabel(step.stillCountsProposal.outcomeTitle)
        .accessibilityHint(content.interfaceCopy.reviewStillCountsHint)
        .accessibilityInputLabels([
            step.stillCountsProposal.outcomeTitle,
            "Choose Still Counts"
        ])
        .accessibilityIdentifier("tfcs-select-still-counts")
    }

    private var anchoredReviewAction: some View {
        reviewAction
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

    private var usesFlowingReviewAction: Bool {
        dynamicTypeSize.isAccessibilitySize
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

private struct TodayVitalityOutcomeTransitionSeam: View {
    let palette: TodayVitalityPalette

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(palette.separator)
                .frame(width: palette.separatorStrokeWidth, height: 20)
                .padding(.leading, 21)
            Spacer(minLength: 0)
        }
        .frame(height: 20)
        .accessibilityHidden(true)
    }
}
