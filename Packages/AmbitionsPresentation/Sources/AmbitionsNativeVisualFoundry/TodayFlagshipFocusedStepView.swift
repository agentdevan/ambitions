import SwiftUI

struct TodayFlagshipFocusedStepView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @AccessibilityFocusState private var accessibilityFocus: TodayFlagshipFocusAnchor?

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState

    var body: some View {
        Group {
            if state.phase == .focusedCurrent || state.phase == .recoveredContinuation {
                TodayOpenContinuityFocusedObject(
                    content: content,
                    acceptedTruth: state.acceptedTruth,
                    palette: palette,
                    shouldFocusIdentity: state.focusAnchor == .focusedIdentity,
                    recoveredProgress: state.phase == .recoveredContinuation
                        ? state.lastSavedProgress
                        : nil,
                    shouldFocusRecoveredProgress: state.focusAnchor == .recoveredProgress,
                    isOutcomeEnabled: true,
                    onSelectStillCounts: {
                        _ = state.selectStillCounts()
                    }
                )
            } else if state.phase == .settled {
                TodayOpenContinuitySettlementView(
                    content: content,
                    acceptedTruth: state.acceptedTruth,
                    palette: palette,
                    shouldFocusTruth: state.focusAnchor == .settledTruth,
                    historyDisclosure: historyDisclosure,
                    onReturnToToday: {
                        _ = state.returnToToday()
                    }
                )
            } else {
                legacyStateScroll
            }
        }
        .background(palette.semanticPlane.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .navigationTitle("")
        .todayFlagshipInlineNavigationTitle()
        .todayFlagshipBackButtonHidden(state.phase == .settled)
        .onAppear {
            accessibilityFocus = state.focusAnchor
        }
        .onChange(of: state.phase) { _, _ in
            accessibilityFocus = state.focusAnchor
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-focused-step")
    }

    private var legacyStateScroll: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                if state.phase == .interrupted || state.phase == .recoveryReview {
                    TodayOpenContinuityInterruptedField(
                        content: content,
                        acceptedTruth: state.acceptedTruth,
                        palette: palette,
                        showsRecoveryAction: true,
                        onOpenRecovery: {
                            _ = state.openRecoveryReview()
                        }
                    )
                    .accessibilityFocused($accessibilityFocus, equals: .interruption)
                    .accessibilityIdentifier("tfcs-interruption-seam")
                } else {
                    VStack(alignment: .leading, spacing: 25) {
                    identity

                    currentStep
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(
                        "\(content.primaryStep.title), "
                            + "\(content.primaryStep.parentPursuitTitle)"
                    )
                    .accessibilityIdentifier("tfcs-focused-object-field")
                }
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 50)
        }
        .scrollIndicators(.hidden)
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 7) {
            TodayFlagshipLandmarkLabel(
                title: content.interfaceCopy.stepTitle,
                symbol: "circle.dashed.inset.filled",
                tint: palette.articulationAccent
            )

            Text(content.primaryStep.title)
                .font(.title.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            TodayFlagshipRelationshipRow(
                symbol: "scope",
                title: "Part of",
                value: content.primaryStep.parentPursuitTitle,
                palette: palette,
                emphasized: true
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityFocused($accessibilityFocus, equals: .focusedIdentity)
        .accessibilityIdentifier("tfcs-step-identity")
    }

    private var currentStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            TodayFlagshipObjectField(role: .current, palette: palette) {
                VStack(alignment: .leading, spacing: 16) {
                    TodayFlagshipStateField(
                        label: content.interfaceCopy.rightNowTitle,
                        symbol: "checkmark.seal",
                        truth: state.acceptedTruth,
                        role: .current,
                        palette: palette
                    )
                    .accessibilityIdentifier("tfcs-current-truth")

                    VStack(alignment: .leading, spacing: 14) {
                        TodayFlagshipRelationshipRow(
                            symbol: "sparkles",
                            title: content.interfaceCopy.whyItFitsTitle,
                            value: content.primaryStep.whyItFitsNow,
                            palette: palette
                        )

                        TodayFlagshipRelationshipRow(
                            symbol: "shield",
                            title: content.interfaceCopy.consequenceTitle,
                            value: content.primaryStep.materialConsequence,
                            palette: palette
                        )

                        temporalContext
                    }
                }
            }

            availableOutcomes
        }
    }

    private var temporalContext: some View {
        TodayFlagshipRelationshipRow(
            symbol: "clock",
            title: content.primaryStep.temporalContext.relationship,
            value: content.primaryStep.temporalContext.exactTime,
            palette: palette,
            emphasized: true
        )
    }

    private var availableOutcomes: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 14) {
                outcomePrompt
                Spacer(minLength: 8)
                stillCountsButton
            }

            VStack(alignment: .leading, spacing: 12) {
                outcomePrompt
                stillCountsButton
            }
        }
        .padding(.vertical, 4)
    }

    private var outcomePrompt: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Progress can be real before the whole Step is done.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(palette.primaryInk)
            Text("Choose the outcome that fits now.")
                .font(.caption)
                .foregroundStyle(palette.tertiaryInk)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var stillCountsButton: some View {
            Button {
                _ = state.selectStillCounts()
            } label: {
                Label(
                    content.primaryStep.stillCountsProposal.outcomeTitle,
                    systemImage: "checkmark.circle"
                )
                    .font(.body.weight(.semibold))
                    .foregroundStyle(palette.actionInk)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 8))
            .controlSize(.large)
            .frame(minHeight: 44, alignment: .leading)
            // AMBitionsAllowWeakPattern(reason: "SwiftUI interaction state prevents mutation during object recovery")
            .disabled(state.phase == .interrupted || state.phase == .recoveryReview)
            .accessibilityHint("Reviews meaningful progress before anything changes")
            .accessibilityIdentifier("tfcs-select-still-counts")
    }

    private var historyDisclosure: Binding<Bool> {
        Binding(
            get: { state.isHistoryExpanded },
            set: { isExpanded in
                if isExpanded {
                    _ = state.openHistory()
                } else {
                    _ = state.closeHistory()
                }
            }
        )
    }

    private var palette: TodayFlagshipPalette {
        TodayFlagshipPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast
        )
    }
}
