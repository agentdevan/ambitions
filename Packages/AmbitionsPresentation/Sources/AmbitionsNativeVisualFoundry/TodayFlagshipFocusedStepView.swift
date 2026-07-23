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
        .navigationTitle(state.phase == .settled ? "Recorded" : "Start Here")
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
                "Step",
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
                label: "Current · Accepted",
                symbol: "checkmark.seal",
                truth: state.acceptedTruth,
                supportingText: "This remains authoritative until a reviewed outcome settles.",
                isProposed: false,
                palette: palette
            )
            .accessibilityIdentifier("tfcs-current-truth")

            semanticRelationship(
                label: "Why it fits now",
                text: content.primaryStep.whyItFitsNow
            )

            semanticRelationship(
                label: "What this protects",
                text: content.primaryStep.materialConsequence
            )

            temporalContext
            availableOutcomes
            proofPosture
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
            TodayFlagshipSectionLabel("Time relationship", palette: palette)

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(content.primaryStep.temporalContext.exactTime)
                    .font(.headline.monospacedDigit())
                Text(content.primaryStep.temporalContext.relationship)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("Exact chronology remains \(content.primaryStep.temporalContext.owner)-owned.")
                .font(.caption)
                .foregroundStyle(palette.tertiaryInk)
        }
        .accessibilityElement(children: .combine)
    }

    private var availableOutcomes: some View {
        VStack(alignment: .leading, spacing: 12) {
            TodayFlagshipSectionLabel("Available outcomes", palette: palette)

            Button {
                _ = state.selectStillCounts()
            } label: {
                Label("Still counts", systemImage: "checkmark.circle")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(palette.actionInk)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 8))
            .controlSize(.large)
            .frame(minHeight: 44, alignment: .leading)
            .disabled(state.phase == .interrupted || state.phase == .recoveryReview)
            .accessibilityHint("Reviews meaningful progress before anything changes")
            .accessibilityIdentifier("tfcs-select-still-counts")

            Text("Done · Move it · Waiting · Blocked · Not needed")
                .font(.footnote)
                .foregroundStyle(palette.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var proofPosture: some View {
        TodayFlagshipLocalSeam(palette: palette) {
            VStack(alignment: .leading, spacing: 6) {
                TodayFlagshipSectionLabel(
                    "Proof posture",
                    symbol: "lock.shield",
                    palette: palette
                )
                Text("No new Proof or Receipt exists before an outcome settles.")
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
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

            Button("Review recovery choices") {
                _ = state.openRecoveryReview()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .frame(minHeight: 44, alignment: .leading)
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
                    "Saved progress restored",
                    symbol: "arrow.clockwise",
                    palette: palette
                )
                Text(content.recovery.lastSavedProgress)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Accepted truth is unchanged.")
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
                label: "New · Accepted",
                symbol: "checkmark.seal.fill",
                truth: state.acceptedTruth,
                supportingText: content.primaryStep.stillCountsProposal.exactConsequence,
                isProposed: false,
                palette: palette
            )
            .accessibilityFocused($accessibilityFocus, equals: .settledTruth)
            .accessibilityIdentifier("tfcs-settled-truth")

            TodayFlagshipLocalSeam(palette: palette) {
                VStack(alignment: .leading, spacing: 8) {
                    Label(content.receipt.recordedLabel, systemImage: "doc.badge.checkmark")
                        .font(.subheadline.weight(.semibold))
                    Text(content.receipt.proofLabel)
                        .font(.footnote)
                        .foregroundStyle(palette.secondaryInk)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("tfcs-recorded-acknowledgment")

            DisclosureGroup("Receipt and History") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(content.receipt.receiptSummary)
                    Text(content.receipt.historySummary)
                    Text("Receipt ID: \(content.receipt.id)")
                        .font(.caption.monospaced())
                        .foregroundStyle(palette.tertiaryInk)
                }
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
                .padding(.top, 8)
            }
            .font(.body.weight(.medium))
            .accessibilityIdentifier("tfcs-receipt-history-disclosure")

            Button {
                _ = state.returnToToday()
            } label: {
                Text("Return to Today")
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

    private var palette: TodayFlagshipPalette {
        TodayFlagshipPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast
        )
    }
}
