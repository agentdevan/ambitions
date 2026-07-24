import SwiftUI

#if os(iOS)
import UIKit
#endif

struct TodayFlagshipReviewView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AccessibilityFocusState private var accessibilityFocus: TodayFlagshipFocusAnchor?
    @State private var reviewFeedbackTrigger = false
    @State private var commitFeedbackTrigger = false

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState
    let onCommitProposal: @MainActor () async -> Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    identity

                    TodayOpenContinuityTruthComparison(
                        currentLabel: content.interfaceCopy.rightNowTitle,
                        currentTruth: state.acceptedTruth,
                        proposedLabel: content.primaryStep.stillCountsProposal.outcomeTitle,
                        proposedTruth: state.proposedTruth
                            ?? content.primaryStep.stillCountsProposal.proposedTruth,
                        palette: palette,
                        isSaving: state.isCommitInFlight
                    )
                    .accessibilityIdentifier("tfcs-review-comparison")
                    .accessibilityFocused($accessibilityFocus, equals: .reviewCurrentTruth)

                    consequence
                    relationshipSummary
                    details
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
                TodayOpenContinuityCommitBar(
                    cancelTitle: content.interfaceCopy.cancelTitle,
                    commitTitle: content.primaryStep.stillCountsProposal.commitActionTitle,
                    savingTitle: content.interfaceCopy.savingTitle,
                    savingBody: content.interfaceCopy.savingBody,
                    cancelHint: content.interfaceCopy.cancelReviewHint,
                    commitHint: content.interfaceCopy.commitProgressHint,
                    palette: palette,
                    isSaving: state.isCommitInFlight,
                    onCancel: cancelReview,
                    onCommit: commitProposal
                )
            }
            .navigationTitle(content.interfaceCopy.reviewTitle)
            .todayFlagshipInlineNavigationTitle()
        }
        .interactiveDismissDisabled(state.isCommitInFlight)
        .onAppear {
            accessibilityFocus = state.focusAnchor
            reviewFeedbackTrigger.toggle()
        }
        .onChange(of: state.phase) { _, _ in
            accessibilityFocus = state.focusAnchor
        }
        .sensoryFeedback(.selection, trigger: reviewFeedbackTrigger)
        .sensoryFeedback(
            .impact(weight: .light, intensity: 0.75),
            trigger: commitFeedbackTrigger
        )
        .accessibilityIdentifier("tfcs-consequential-review")
    }

    private var identity: some View {
        HStack(alignment: .top, spacing: 12) {
            TodayOpenContinuitySpine(
                kind: .current,
                palette: palette.openContinuity,
                extendsBefore: false,
                extendsAfter: true
            )
            .frame(width: 22)
            .frame(minHeight: 70)

            VStack(alignment: .leading, spacing: 5) {
                Text(content.primaryStep.title)
                    .font(TodayOpenContinuityTypographyRole.objectIdentity.font)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                Text(content.primaryStep.parentPursuitTitle)
                    .font(TodayOpenContinuityTypographyRole.relationship.font)
                    .foregroundStyle(palette.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("tfcs-step-identity")
    }

    private var consequence: some View {
        reviewFact(
            symbol: "arrow.trianglehead.branch",
            title: content.interfaceCopy.reviewChangeTitle,
            value: content.primaryStep.stillCountsProposal.exactConsequence,
            emphasized: true
        )
        .accessibilityIdentifier("tfcs-review-consequence")
    }

    private var relationshipSummary: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 14) {
                    relationship
                    historyTrust
                }
            } else {
                HStack(alignment: .top, spacing: 18) {
                    relationship
                        .frame(maxWidth: .infinity, alignment: .leading)
                    historyTrust
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var relationship: some View {
        reviewFact(
            symbol: "scope",
            title: content.interfaceCopy.reviewRelationshipTitle,
            value: content.primaryStep.stillCountsProposal.affectedLineage,
            emphasized: false
        )
        .accessibilityIdentifier("tfcs-review-relationship")
    }

    private var historyTrust: some View {
        reviewFact(
            symbol: "lock",
            title: content.interfaceCopy.historyTrustCue,
            value: nil,
            emphasized: false
        )
        .accessibilityIdentifier("tfcs-review-trust-cue")
    }

    private var details: some View {
        DisclosureGroup(content.interfaceCopy.detailsTitle) {
            VStack(alignment: .leading, spacing: 9) {
                Text(content.primaryStep.stillCountsProposal.proofRequirement)
                if content.primaryStep.stillCountsProposal.createsReceipt {
                    Text(content.interfaceCopy.receiptAvailableDetail)
                }
                if content.primaryStep.stillCountsProposal.appearsInHistory {
                    Text(content.interfaceCopy.savedHistoryDetail)
                }
            }
            .font(TodayOpenContinuityTypographyRole.metadata.font)
            .foregroundStyle(palette.secondaryInk)
            .padding(.top, 6)
            .accessibilityIdentifier("tfcs-review-detail-content")
        }
        .font(TodayOpenContinuityTypographyRole.relationship.font.weight(.medium))
        .frame(minHeight: 44)
        .accessibilityIdentifier("tfcs-review-details")
    }

    private func reviewFact(
        symbol: String,
        title: String,
        value: String?,
        emphasized: Bool
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(emphasized ? palette.articulationAccent : palette.tertiaryInk)
                .frame(width: 18)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(TodayOpenContinuityTypographyRole.metadata.font.weight(.semibold))
                    .foregroundStyle(palette.tertiaryInk)
                if let value {
                    Text(value)
                        .font(
                            TodayOpenContinuityTypographyRole.relationship.font.weight(
                                emphasized ? .semibold : .regular
                            )
                        )
                        .foregroundStyle(palette.primaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func cancelReview() {
        _ = state.cancelReview()
    }

    private func commitProposal() {
        guard state.beginCommit() else { return }
        commitFeedbackTrigger.toggle()
        announceSaving()

        Task { @MainActor in
            guard await onCommitProposal() else { return }
            _ = state.settle()
        }
    }

    @MainActor
    private func announceSaving() {
        #if os(iOS)
        UIAccessibility.post(
            notification: .announcement,
            argument: content.interfaceCopy.savingAnnouncement
        )
        #endif
    }

    private var palette: TodayFlagshipPalette {
        TodayFlagshipPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast
        )
    }
}
