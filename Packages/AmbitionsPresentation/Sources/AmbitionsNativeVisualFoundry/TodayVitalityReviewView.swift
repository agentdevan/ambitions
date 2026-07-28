import SwiftUI

struct TodayVitalityReviewView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AccessibilityFocusState private var accessibilityFocus: TodayFlagshipFocusAnchor?

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState
    let onOpenConsequenceDetails: () -> Void
    let onCancel: () -> Void
    let onCommit: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    reviewIdentity

                    if state.phase == .failedSettlement {
                        failurePosture
                    }

                    comparisonField

                    consequenceSummary

                    if state.isCommitInFlight {
                        savingTrustCue
                    } else {
                        details
                    }

                    if usesFlowingActions {
                        actionRegion
                            .padding(.top, 4)
                            .padding(.bottom, 24)
                    }
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 16)
                .accessibilityElement(children: .contain)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if usesFlowingActions == false {
                    actionRegion
                }
            }
            .background(palette.canvas.ignoresSafeArea())
            .foregroundStyle(palette.labelPrimary)
            .toolbar {
                reviewDismissalToolbarItem
            }
            .navigationTitle("")
            .todayFlagshipInlineNavigationTitle()
        }
        .onAppear {
            accessibilityFocus = state.focusAnchor
        }
        .onChange(of: state.phase) { _, _ in
            accessibilityFocus = state.focusAnchor
        }
        .accessibilityIdentifier("tfcs-consequential-review")
    }

    private var reviewIdentity: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(screenTitle)
                .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                .foregroundStyle(
                    state.isCommitInFlight
                        ? palette.ambitionsAccentMuted
                        : palette.labelSecondary
                )

            Text(content.primaryStep.title)
                .font(TodayVitalityTypographyRole.objectIdentity.font)
                .foregroundStyle(palette.labelPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("tfcs-review-step-identity")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(screenTitle). \(content.primaryStep.title)")
        .accessibilityIdentifier("tfcs-step-identity")
    }

    @ToolbarContentBuilder
    private var reviewDismissalToolbarItem: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .topBarLeading) {
            reviewDismissalAction
        }
        #else
        ToolbarItem(placement: .navigation) {
            reviewDismissalAction
        }
        #endif
    }

    private var reviewDismissalAction: some View {
        Button(action: onCancel) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.backward")
                    .accessibilityHidden(true)
                Text(content.interfaceCopy.stepTitle)
            }
        }
        .environment(\.isEnabled, !state.isCommitInFlight)
        .accessibilityLabel(content.interfaceCopy.stepTitle)
        .accessibilityHint(content.interfaceCopy.cancelReviewHint)
        .accessibilityInputLabels([content.interfaceCopy.stepTitle])
        .accessibilityIdentifier("r13-review-step-dismissal")
    }

    private var comparisonField: some View {
        TodayVitalityReviewComparison {
            truthRegion(
                kind: .current,
                label: content.interfaceCopy.rightNowTitle,
                truth: state.acceptedTruth,
                identifier: "tfcs-review-current-truth"
            )
            .accessibilityFocused($accessibilityFocus, equals: .reviewCurrentTruth)

            transitionSeam

            truthRegion(
                kind: .proposed,
                label: content.primaryStep.stillCountsProposal.outcomeTitle,
                truth: state.proposedTruth
                    ?? content.primaryStep.stillCountsProposal.proposedTruth,
                identifier: "tfcs-proposed-truth"
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-review-comparison")
    }

    private func truthRegion(
        kind: TodayVitalityNodeKind,
        label: String,
        truth: String,
        identifier: String
    ) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if kind == .current {
                TodayVitalityNode(kind: .current, palette: palette)
            } else {
                TodayVitalityNode(kind: .proposed, palette: palette)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(label)
                    .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(
                        kind == .proposed
                            ? palette.ambitionsAccentMuted
                            : palette.labelSecondary
                    )

                Text(truth)
                    .font(TodayVitalityTypographyRole.stateTruth.font)
                    .foregroundStyle(palette.labelPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 8)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(truth)
        .accessibilityIdentifier(identifier)
    }

    private var transitionSeam: some View {
        HStack(spacing: 8) {
            ZStack {
                Rectangle()
                    .fill(palette.separator)
                    .frame(
                        width: palette.separatorStrokeWidth,
                        height: state.isCommitInFlight ? 44 : 34
                    )

                if state.isCommitInFlight {
                    TodayVitalityNode(kind: .saving, palette: palette)
                } else {
                    Circle()
                        .fill(palette.canvas)
                        .frame(width: 7, height: 7)
                        .overlay {
                            Circle()
                                .stroke(
                                    palette.labelSecondary,
                                    lineWidth: palette.separatorStrokeWidth
                                )
                        }
                }
            }
            .frame(width: 44, height: state.isCommitInFlight ? 44 : 34)

            Spacer(minLength: 0)
        }
        .frame(height: state.isCommitInFlight ? 44 : 34)
        .accessibilityElement(children: .ignore)
        .accessibilityHidden(true)
        .accessibilityIdentifier("tfcs-review-transition-seam")
        .accessibilityIdentifier(
            state.isCommitInFlight
                ? "tfcs-saving-transaction-seam"
                : "tfcs-review-transition-seam"
        )
    }

    private var consequenceSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(content.interfaceCopy.reviewChangeTitle)
                .font(TodayVitalityTypographyRole.metadata.font.weight(.semibold))
                .foregroundStyle(palette.ambitionsAccentMuted)

            Text(content.primaryStep.stillCountsProposal.exactConsequence)
                .font(TodayVitalityTypographyRole.relationship.font)
                .foregroundStyle(palette.labelPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("tfcs-review-consequence")

            Label {
                Text(
                    "\(content.interfaceCopy.reviewRelationshipTitle): "
                        + content.primaryStep.stillCountsProposal.affectedLineage
                )
            } icon: {
                Image(systemName: "house")
                    .accessibilityHidden(true)
            }
            .font(TodayVitalityTypographyRole.metadata.font)
            .foregroundStyle(palette.labelSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("tfcs-review-relationship")

            Label {
                Text(content.interfaceCopy.historyTrustCue)
            } icon: {
                Image(systemName: "lock")
                    .accessibilityHidden(true)
            }
            .font(TodayVitalityTypographyRole.metadata.font)
            .foregroundStyle(palette.labelSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("tfcs-review-trust-cue")
        }
    }

    private var details: some View {
        Button(action: onOpenConsequenceDetails) {
            HStack(spacing: 10) {
                Text(content.interfaceCopy.detailsTitle)
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .font(TodayVitalityTypographyRole.relationship.font.weight(.medium))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(palette.separator)
                .frame(height: palette.separatorStrokeWidth)
                .accessibilityHidden(true)
        }
        .accessibilityHint("Open consequence details")
        .accessibilityInputLabels([content.interfaceCopy.detailsTitle])
        .accessibilityIdentifier("tfcs-review-details")
    }

    private var savingTrustCue: some View {
        Label {
            Text(content.interfaceCopy.savingBody)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "lock")
                .accessibilityHidden(true)
        }
        .font(TodayVitalityTypographyRole.metadata.font)
        .foregroundStyle(palette.labelSecondary)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("r13-saving-trust-cue")
    }

    @ViewBuilder
    private var actionRegion: some View {
        if state.isCommitInFlight {
            savingAction
        } else if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: 10) {
                cancelAction
                commitAction
            }
            .modifier(TodayVitalityReviewActionBackground(palette: palette))
        } else {
            HStack(spacing: 12) {
                cancelAction
                    .frame(maxWidth: 132)
                commitAction
            }
            .modifier(TodayVitalityReviewActionBackground(palette: palette))
        }
    }

    private var cancelAction: some View {
        Button(action: onCancel) {
            Text(cancelTitle)
                .multilineTextAlignment(.center)
                .frame(minHeight: 48)
        }
        .buttonStyle(
            TodayVitalityActionStyle(role: .secondary, palette: palette)
        )
        .accessibilityHint(content.interfaceCopy.cancelReviewHint)
        .accessibilityInputLabels([cancelTitle])
        .accessibilityIdentifier("tfcs-cancel-review")
    }

    private var commitAction: some View {
        Button(action: onCommit) {
            Text(commitTitle)
                .multilineTextAlignment(.center)
                .frame(minHeight: 48)
        }
        .buttonStyle(
            TodayVitalityActionStyle(role: .commitment, palette: palette)
        )
        .accessibilityHint(content.interfaceCopy.commitProgressHint)
        .accessibilityInputLabels([commitTitle])
        .accessibilityIdentifier("tfcs-commit-still-counts")
    }

    private var savingAction: some View {
        HStack(spacing: 12) {
            TodayVitalityNode(kind: .saving, palette: palette)

            Text(content.interfaceCopy.savingTitle)
                .font(TodayVitalityTypographyRole.action.font)

            Spacer(minLength: 8)

            ProgressView()
                .controlSize(.small)
                .accessibilityHidden(true)
        }
        .foregroundStyle(palette.actionInk)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 48)
        .padding(.horizontal, 16)
        .background(
            palette.ambitionsAccent.opacity(0.72),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .opacity(0.78)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(content.interfaceCopy.savingTitle)
        .accessibilityFocused($accessibilityFocus, equals: .saving)
        .accessibilityIdentifier("tfcs-saving-posture")
        .modifier(TodayVitalityReviewActionBackground(palette: palette))
    }

    private var failurePosture: some View {
        HStack(alignment: .top, spacing: 10) {
            TodayVitalityNode(kind: .interrupted, palette: palette)

            VStack(alignment: .leading, spacing: 4) {
                Text(content.supporting.commitFailure.title)
                    .font(TodayVitalityTypographyRole.relationship.font.weight(.semibold))
                Text(content.supporting.commitFailure.body)
                    .font(TodayVitalityTypographyRole.metadata.font)
                    .foregroundStyle(palette.labelSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityFocused($accessibilityFocus, equals: .failedSettlement)
        .accessibilityIdentifier("tfcs-failed-settlement")
    }

    private var screenTitle: String {
        state.isCommitInFlight
            ? content.interfaceCopy.savingTitle
            : content.interfaceCopy.reviewTitle
    }

    private var cancelTitle: String {
        state.phase == .failedSettlement
            ? content.supporting.commitFailure.dismissTitle
            : content.interfaceCopy.cancelTitle
    }

    private var commitTitle: String {
        state.phase == .failedSettlement
            ? content.supporting.commitFailure.retryTitle
            : content.primaryStep.stillCountsProposal.commitActionTitle
    }

    private var usesFlowingActions: Bool {
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

private struct TodayVitalityReviewActionBackground: ViewModifier {
    let palette: TodayVitalityPalette

    func body(content: Content) -> some View {
        content
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
}

private struct TodayVitalityReviewComparison<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
    }
}
