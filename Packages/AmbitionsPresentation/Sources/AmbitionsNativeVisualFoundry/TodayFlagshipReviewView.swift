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
                TodayFlagshipObjectField(role: .proposed, palette: palette) {
                    VStack(alignment: .leading, spacing: 13) {
                        identity

                        TodayFlagshipStateComparison(
                            currentLabel: content.interfaceCopy.rightNowTitle,
                            currentTruth: state.acceptedTruth,
                            proposedLabel: content.primaryStep.stillCountsProposal.outcomeTitle,
                            proposedTruth: state.proposedTruth
                                ?? content.primaryStep.stillCountsProposal.proposedTruth,
                            palette: palette
                        )
                        .accessibilityFocused($accessibilityFocus, equals: .reviewCurrentTruth)
                        .accessibilityIdentifier("tfcs-review-comparison")

                        TodayFlagshipRelationshipRow(
                            symbol: "arrow.trianglehead.branch",
                            title: content.interfaceCopy.reviewChangeTitle,
                            value: content.primaryStep.stillCountsProposal.exactConsequence,
                            palette: palette,
                            emphasized: true
                        )
                        .accessibilityIdentifier("tfcs-review-consequence")

                        ViewThatFits(in: .horizontal) {
                            HStack(alignment: .top, spacing: 18) {
                                reviewRelationshipRow
                                historyTrustRow
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                reviewRelationshipRow
                                historyTrustRow
                            }
                        }

                        DisclosureGroup(content.interfaceCopy.detailsTitle) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(content.primaryStep.stillCountsProposal.proofRequirement)
                                if content.primaryStep.stillCountsProposal.createsReceipt {
                                    Text("A local receipt will be available after progress is recorded.")
                                }
                                if content.primaryStep.stillCountsProposal.appearsInHistory {
                                    Text("You can review the saved history from this Step.")
                                }
                            }
                            .font(.footnote)
                            .foregroundStyle(palette.secondaryInk)
                            .padding(.top, 6)
                            .accessibilityIdentifier("tfcs-review-detail-content")
                        }
                        .font(.body.weight(.medium))
                        .accessibilityIdentifier("tfcs-review-details")
                    }
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
            .background(palette.semanticPlane.ignoresSafeArea())
            .foregroundStyle(palette.primaryInk)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                reviewActionRegion
            }
            .navigationTitle(content.interfaceCopy.reviewTitle)
            .todayFlagshipInlineNavigationTitle()
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
        VStack(alignment: .leading, spacing: 5) {
            Text(content.primaryStep.title)
                .font(.title2.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
            Text(content.primaryStep.parentPursuitTitle)
                .font(.subheadline)
                .foregroundStyle(palette.secondaryInk)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("tfcs-step-identity")
    }

    private var reviewRelationshipRow: some View {
        TodayFlagshipRelationshipRow(
            symbol: "scope",
            title: content.interfaceCopy.reviewRelationshipTitle,
            value: content.primaryStep.stillCountsProposal.affectedLineage,
            palette: palette
        )
        .accessibilityIdentifier("tfcs-review-relationship")
    }

    private var historyTrustRow: some View {
        TodayFlagshipEvidenceRow(
            symbol: "lock",
            title: content.interfaceCopy.historyTrustCue,
            detail: nil,
            palette: palette
        )
        .accessibilityIdentifier("tfcs-review-trust-cue")
    }

    private var commitAction: some View {
        Button {
            guard state.beginCommit() else { return }
            Task { @MainActor in
                guard await onCommitProposal() else { return }
                _ = state.settle()
            }
        } label: {
            Text(content.primaryStep.stillCountsProposal.commitActionTitle)
                .foregroundStyle(palette.actionInk)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 8))
        .controlSize(.large)
        .frame(minHeight: 44)
        .accessibilityHint("Records the reviewed progress")
        .accessibilityIdentifier("tfcs-commit-still-counts")
    }

    private var savingPosture: some View {
        HStack(alignment: .top, spacing: 12) {
            ProgressView()
                .controlSize(.regular)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(content.interfaceCopy.savingTitle)
                    .font(.headline)
                Text(content.interfaceCopy.savingBody)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(content.interfaceCopy.savingTitle). \(content.interfaceCopy.savingBody)"
        )
        .accessibilityFocused($accessibilityFocus, equals: .saving)
        .accessibilityIdentifier("tfcs-saving-posture")
    }

    private var cancelAction: some View {
        Button {
            _ = state.cancelReview()
        } label: {
            Text(content.interfaceCopy.cancelTitle)
                .frame(minWidth: 72, minHeight: 44)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .accessibilityHint("Closes review without changing the Step")
    }

    private var reviewActionRegion: some View {
        Group {
            if state.isCommitInFlight {
                savingPosture
            } else {
                HStack(spacing: 12) {
                    cancelAction
                    commitAction
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.semanticPlane)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(palette.divider)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
    }

    private var palette: TodayFlagshipPalette {
        TodayFlagshipPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast
        )
    }
}
