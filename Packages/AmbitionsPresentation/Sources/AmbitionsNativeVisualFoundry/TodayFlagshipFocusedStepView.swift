import SwiftUI

struct TodayFlagshipFocusedStepView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @AccessibilityFocusState private var accessibilityFocus: TodayFlagshipFocusAnchor?

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState

    var body: some View {
        Group {
            if state.phase == .focusedCurrent {
                TodayOpenContinuityFocusedObject(
                    content: content,
                    acceptedTruth: state.acceptedTruth,
                    palette: palette,
                    shouldFocusIdentity: state.focusAnchor == .focusedIdentity,
                    isOutcomeEnabled: true,
                    onSelectStillCounts: {
                        _ = state.selectStillCounts()
                    }
                )
            } else {
                legacyStateScroll
            }
        }
        .background(palette.semanticPlane.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .navigationTitle(state.phase == .settled ? content.interfaceCopy.settlementTitle : "")
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
                if state.phase == .settled {
                    identity
                    settlement
                } else {
                    VStack(alignment: .leading, spacing: 25) {
                        identity

                        if state.phase == .interrupted || state.phase == .recoveryReview {
                            interruptionSeam
                        } else if state.phase == .recoveredContinuation {
                            recoveredSeam
                        }

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

    private var interruptionSeam: some View {
        TodayFlagshipObjectField(role: .interrupted, palette: palette) {
            VStack(alignment: .leading, spacing: 12) {
                TodayFlagshipLandmarkLabel(
                    title: content.recovery.interruptionTitle,
                    symbol: "pause.circle.fill",
                    tint: palette.interruptionAccent
                )

                Text(content.recovery.interruptionDetail)
                    .font(.body.weight(.medium))

                TodayFlagshipStateField(
                    label: "Last saved progress",
                    symbol: "externaldrive.badge.checkmark",
                    truth: content.recovery.lastSavedProgress,
                    role: .interrupted,
                    palette: palette
                )

                Button(content.interfaceCopy.recoveryEntryTitle) {
                    _ = state.openRecoveryReview()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .frame(minHeight: 44, alignment: .leading)
                // AMBitionsAllowWeakPattern(reason: "SwiftUI interaction state prevents a duplicate recovery presentation")
                .disabled(state.phase == .recoveryReview)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityFocused($accessibilityFocus, equals: .interruption)
        .accessibilityIdentifier("tfcs-interruption-seam")
    }

    private var recoveredSeam: some View {
        TodayFlagshipObjectField(role: .current, palette: palette) {
            VStack(alignment: .leading, spacing: 6) {
                TodayFlagshipLandmarkLabel(
                    title: content.interfaceCopy.recoveryTitle,
                    symbol: "arrow.clockwise",
                    tint: palette.articulationAccent
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
        TodayFlagshipObjectField(role: .settled, palette: palette) {
            VStack(alignment: .leading, spacing: 18) {
                TodayFlagshipLandmarkLabel(
                    title: content.interfaceCopy.settlementTitle,
                    symbol: "checkmark.seal.fill",
                    tint: palette.settledAccent
                )

                TodayFlagshipStateField(
                    label: content.interfaceCopy.rightNowTitle,
                    symbol: "checkmark.seal.fill",
                    truth: state.acceptedTruth,
                    role: .settled,
                    palette: palette
                )
                .accessibilityFocused($accessibilityFocus, equals: .settledTruth)
                .accessibilityIdentifier("tfcs-settled-truth")

                TodayFlagshipRelationshipRow(
                    symbol: "scope",
                    title: "Added to",
                    value: content.primaryStep.parentPursuitTitle,
                    palette: palette,
                    emphasized: true
                )

                TodayFlagshipEvidenceRow(
                    symbol: "checkmark.seal",
                    title: content.receipt.recordedLabel,
                    detail: "Available in this Step’s history",
                    palette: palette
                )
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
                    Label(content.interfaceCopy.returnTodayTitle, systemImage: "arrow.uturn.backward")
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
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-settlement-field")
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
