import SwiftUI

struct TodayFlagshipFocusedStepView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @AccessibilityFocusState private var accessibilityFocus: TodayFlagshipFocusAnchor?

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                identity

                if state.phase == .interrupted || state.phase == .recoveryReview {
                    interruptionSeam
                } else if state.phase == .recoveredContinuation {
                    recoveredSeam
                }

                if state.phase == .settled {
                    settlement
                } else {
                    currentStep
                }
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 50)
        }
        .scrollIndicators(.hidden)
        .background(palette.semanticPlane.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .navigationTitle(
            state.phase == .settled
                ? content.interfaceCopy.settlementTitle
                : content.interfaceCopy.startHereTitle
        )
        .todayFlagshipInlineNavigationTitle()
        .todayFlagshipBackButtonHidden(state.phase == .settled)
        .onAppear {
            accessibilityFocus = state.focusAnchor
        }
        .onChange(of: state.phase) { _, _ in
            accessibilityFocus = state.focusAnchor
        }
        .accessibilityIdentifier("tfcs-focused-step")
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 8) {
            TodayFlagshipSectionLabel(
                content.interfaceCopy.stepTitle,
                symbol: "circle.dashed.inset.filled",
                palette: palette
            )

            Text(content.primaryStep.title)
                .font(.title2.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Label(
                content.primaryStep.parentPursuitTitle,
                systemImage: "arrow.up.right"
            )
            .font(.subheadline.weight(.medium))
            .foregroundStyle(palette.secondaryInk)
        }
        .accessibilityElement(children: .combine)
        .accessibilityFocused($accessibilityFocus, equals: .focusedIdentity)
        .accessibilityIdentifier("tfcs-step-identity")
    }

    private var currentStep: some View {
        VStack(alignment: .leading, spacing: 25) {
            TodayFlagshipTruthBlock(
                label: content.interfaceCopy.rightNowTitle,
                symbol: "checkmark.seal",
                truth: state.acceptedTruth,
                supportingText: nil,
                isProposed: false,
                palette: palette
            )
            .accessibilityIdentifier("tfcs-current-truth")

            semanticRelationship(
                label: content.interfaceCopy.whyItFitsTitle,
                text: content.primaryStep.whyItFitsNow
            )

            semanticRelationship(
                label: content.interfaceCopy.consequenceTitle,
                text: content.primaryStep.materialConsequence
            )

            temporalContext
            availableOutcomes
        }
    }

    private func semanticRelationship(label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            TodayFlagshipSectionLabel(label, palette: palette)
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var temporalContext: some View {
        VStack(alignment: .leading, spacing: 7) {
            TodayFlagshipSectionLabel(
                content.primaryStep.temporalContext.relationship,
                palette: palette
            )

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(content.primaryStep.temporalContext.exactTime)
                    .font(.headline.monospacedDigit())
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var availableOutcomes: some View {
        VStack(alignment: .leading, spacing: 0) {
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
    }

    private var interruptionSeam: some View {
        VStack(alignment: .leading, spacing: 10) {
            TodayFlagshipSectionLabel(
                content.recovery.interruptionTitle,
                symbol: "pause.circle",
                palette: palette
            )

            Text(content.recovery.interruptionDetail)
                .font(.body)

            Text(content.recovery.lastSavedProgress)
                .font(.callout.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)

            Button(content.interfaceCopy.recoveryEntryTitle) {
                _ = state.openRecoveryReview()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .frame(minHeight: 44, alignment: .leading)
            // AMBitionsAllowWeakPattern(reason: "SwiftUI interaction state prevents a duplicate recovery presentation")
            .disabled(state.phase == .recoveryReview)
        }
        .padding(14)
        .background(palette.warningPlane)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(palette.localArticulation)
                .frame(width: 3)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .accessibilityFocused($accessibilityFocus, equals: .interruption)
        .accessibilityIdentifier("tfcs-interruption-seam")
    }

    private var recoveredSeam: some View {
        TodayFlagshipLocalSeam(palette: palette) {
            VStack(alignment: .leading, spacing: 6) {
                TodayFlagshipSectionLabel(
                    content.interfaceCopy.recoveryTitle,
                    symbol: "arrow.clockwise",
                    palette: palette
                )
                Text(content.recovery.lastSavedProgress)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                Text(content.interfaceCopy.recoveryBody)
                    .font(.footnote)
                    .foregroundStyle(palette.secondaryInk)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityFocused($accessibilityFocus, equals: .recoveredProgress)
    }

    private var settlement: some View {
        VStack(alignment: .leading, spacing: 22) {
            TodayFlagshipTruthBlock(
                label: content.interfaceCopy.settlementTitle,
                symbol: "checkmark.seal.fill",
                truth: state.acceptedTruth,
                supportingText: nil,
                isProposed: false,
                palette: palette
            )
            .accessibilityFocused($accessibilityFocus, equals: .settledTruth)
            .accessibilityIdentifier("tfcs-settled-truth")

            Text(
                "\(content.interfaceCopy.settlementRelationshipPrefix) "
                    + content.primaryStep.parentPursuitTitle
            )
            .font(.body.weight(.medium))
            .fixedSize(horizontal: false, vertical: true)

            Label(content.receipt.recordedLabel, systemImage: "checkmark.seal")
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("tfcs-recorded-acknowledgment")

            DisclosureGroup(
                content.interfaceCopy.viewHistoryTitle,
                isExpanded: historyDisclosure
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(content.receipt.receiptSummary)
                    Text(content.receipt.historySummary)
                    Text(content.receipt.recordedLabel)
                    Text("Record: \(content.receipt.id)")
                        .font(.caption.monospaced())
                        .foregroundStyle(palette.tertiaryInk)
                }
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
                .padding(.top, 8)
                .accessibilityIdentifier("tfcs-history-detail")
            }
            .font(.body.weight(.medium))
            .accessibilityIdentifier("tfcs-view-history")

            Button {
                _ = state.returnToToday()
            } label: {
                Text(content.interfaceCopy.returnTodayTitle)
                    .foregroundStyle(palette.actionInk)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 8))
            .controlSize(.large)
            .frame(minHeight: 44, alignment: .leading)
            .accessibilityHint("Returns to the settled Step and the next Start Here")
            .accessibilityIdentifier("tfcs-return-to-today")
        }
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
