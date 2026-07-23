import SwiftUI

struct TodayFlagshipReviewView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @AccessibilityFocusState private var accessibilityFocus: TodayFlagshipFocusAnchor?

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState
    let onCommitProposal: @MainActor () async -> Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 23) {
                    identity

                    TodayFlagshipTruthBlock(
                        label: "Current · Accepted",
                        symbol: "checkmark.seal",
                        truth: state.acceptedTruth,
                        supportingText: "This remains authoritative while you review.",
                        isProposed: false,
                        palette: palette
                    )
                    .accessibilityFocused($accessibilityFocus, equals: .reviewCurrentTruth)
                    .accessibilityIdentifier("tfcs-review-current-truth")

                    TodayFlagshipTruthBlock(
                        label: "Proposed · Not yet accepted",
                        symbol: "arrow.trianglehead.branch",
                        truth: state.proposedTruth
                            ?? content.primaryStep.stillCountsProposal.proposedTruth,
                        supportingText: "Nothing changes unless you commit below.",
                        isProposed: true,
                        palette: palette
                    )
                    .accessibilityIdentifier("tfcs-proposed-truth")

                    reviewRelationship(
                        label: "Exact consequence",
                        text: content.primaryStep.stillCountsProposal.exactConsequence
                    )
                    reviewRelationship(
                        label: "Affected relationship",
                        text: content.primaryStep.stillCountsProposal.affectedLineage
                    )
                    reviewRelationship(
                        label: "Proof, Receipt, and History",
                        text: content.primaryStep.stillCountsProposal.proofRequirement
                            + " A local Receipt and History record are expected after settlement."
                    )

                    if state.isCommitInFlight {
                        savingPosture
                    } else {
                        commitAction
                    }
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 44)
            }
            .scrollIndicators(.hidden)
            .background(palette.semanticPlane.ignoresSafeArea())
            .foregroundStyle(palette.primaryInk)
            .navigationTitle("Review Still counts")
            .todayFlagshipInlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        _ = state.cancelReview()
                    }
                    .disabled(state.isCommitInFlight)
                    .accessibilityHint("Closes review without changing the Step")
                }
            }
        }
        .interactiveDismissDisabled(state.isCommitInFlight)
        .onAppear {
            accessibilityFocus = state.focusAnchor
        }
        .onChange(of: state.phase) { _, _ in
            accessibilityFocus = state.focusAnchor
        }
        .accessibilityIdentifier("tfcs-consequential-review")
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 7) {
            TodayFlagshipSectionLabel("Exact Step", palette: palette)
            Text(content.primaryStep.title)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Text(content.primaryStep.parentPursuitTitle)
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
        }
        .accessibilityElement(children: .combine)
    }

    private func reviewRelationship(label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            TodayFlagshipSectionLabel(label, palette: palette)
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var commitAction: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                guard state.beginCommit() else { return }
                Task { @MainActor in
                    guard await onCommitProposal() else { return }
                    _ = state.settle()
                }
            } label: {
                Text(content.primaryStep.stillCountsProposal.commitActionTitle)
                    .foregroundStyle(palette.actionInk)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 8))
            .controlSize(.large)
            .frame(minHeight: 44, alignment: .leading)
            .accessibilityHint("Commits the proposed truth and creates local evidence")
            .accessibilityIdentifier("tfcs-commit-still-counts")

            Text("Cancel remains non-mutating.")
                .font(.caption)
                .foregroundStyle(palette.tertiaryInk)
        }
    }

    private var savingPosture: some View {
        TodayFlagshipLocalSeam(palette: palette) {
            HStack(alignment: .top, spacing: 12) {
                ProgressView()
                    .controlSize(.regular)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Recording Still counts")
                        .font(.headline)
                    Text("Current accepted truth stays in place until settlement.")
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Recording Still counts. Current accepted truth stays in place until settlement."
        )
        .accessibilityFocused($accessibilityFocus, equals: .saving)
        .accessibilityIdentifier("tfcs-saving-posture")
    }

    private var palette: TodayFlagshipPalette {
        TodayFlagshipPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast
        )
    }
}
