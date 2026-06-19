import AmbitionsDesignSystem
import SwiftUI

struct CaptureContinuityLine: View {
    @Environment(\.ambitionTheme) private var theme

    let capture: Capture
    let activeGoalOptions: [CaptureGoalOption]
    let mutationProofContract: CaptureComposerMutationProofContract
    let onRouteToTime: (Capture) -> Void
    let onCreateGoal: (Capture) -> Void
    let onSaveToNeedsPlace: (Capture) -> Void
    let onAttachToGoal: (Capture, CaptureGoalOption) -> Void
    let onMarkDeliverableSeed: (Capture) -> Void
    let onMarkWaiting: (Capture) -> Void
    let onMarkOptionalSomeday: (Capture) -> Void
    let onArchive: (Capture) -> Void

    var body: some View {
        CaptureStageGroup(state: livingState, accessibilityIdentifier: "capture.stage-line.\(capture.id)") {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                Text(capture.rawText)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(metadataText)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("capture.metadata.\(capture.id)")

                if let assumption = capture.assumptionSummary {
                    CaptureTrustSeam(reason: assumption, source: capture.sourceType?.title ?? "Local capture")
                }

                CapturePlacementReviewView(
                    review: capture.placementReviewState,
                    correction: capture.correctionReviewState
                )

                if canPromoteCaptureToGoal {
                    CaptureGoalSeedIncubatorView(state: capture.goalSeedIncubatorState)
                }

                CaptureActionPipeline(
                    capture: capture,
                    activeGoalOptions: activeGoalOptions,
                    canPromoteCaptureToGoal: canPromoteCaptureToGoal,
                    mutationProofContract: mutationProofContract,
                    onRouteToTime: onRouteToTime,
                    onCreateGoal: onCreateGoal,
                    onSaveToNeedsPlace: onSaveToNeedsPlace,
                    onAttachToGoal: onAttachToGoal,
                    onMarkDeliverableSeed: onMarkDeliverableSeed,
                    onMarkWaiting: onMarkWaiting,
                    onMarkOptionalSomeday: onMarkOptionalSomeday,
                    onArchive: onArchive
                )
            }
        }
        .accessibilityHint(mutationProofContract.submitHint)
    }

    private var metadataText: String {
        var parts = [capture.kind.title, capture.route.title, capture.triageStatus.title]
        if let sourceType = capture.sourceType {
            parts.append(sourceType.title)
        }
        if let deadlineText = capture.deadlineText {
            parts.append("Deadline \(deadlineText)")
        }
        if let contextLensHint = capture.contextLensHint {
            parts.append(contextLensHint.captureDisplayTitle)
        }
        if let revisitAfter = capture.revisitAfter {
            parts.append("Revisit after \(revisitAfter)")
        }
        parts.append(capture.updatedAt)
        return parts.joined(separator: " • ")
    }

    private var livingState: LivingVisualState {
        switch capture.status {
        case .waiting, .optionalSomeday:
            return .stale
        case .archived:
            return .empty
        case .goalBound, .scheduled:
            return .proof
        case .needsTriage, .seed, .actionable, .delegated:
            return .active
        }
    }

    private var canPromoteCaptureToGoal: Bool {
        switch capture.status {
        case .needsTriage, .seed, .actionable:
            return true
        case .goalBound, .scheduled, .delegated, .archived:
            return false
        case .waiting, .optionalSomeday:
            return false
        }
    }
}

private struct CapturePlacementReviewView: View {
    @Environment(\.ambitionTheme) private var theme

    let review: CapturePlacementReviewState
    let correction: CaptureCorrectionReviewState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Divider()

            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Label(review.title, systemImage: "tray.and.arrow.down")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer()
                TagPill(review.placementStateTitle, state: review.state)
            }

            Label(review.destinationLabel, systemImage: "arrow.triangle.branch")
            Label(review.consequenceLabel, systemImage: "checkmark.seal")
            Label(review.privacyLabel, systemImage: "lock.shield")
            Label(review.confirmationLabel, systemImage: "hand.raised")
            Label(review.archiveLabel, systemImage: "archivebox")

            Label(correction.title, systemImage: "arrow.uturn.backward")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
            Label(correction.routeCorrectionLabel, systemImage: "arrow.triangle.branch")
            Label(correction.notGoalLabel, systemImage: "target")
            Label(correction.notNowLabel, systemImage: "moon")
            Label(correction.receiptLabel, systemImage: "doc.text.magnifyingglass")
            Label(correction.learningBoundaryLabel, systemImage: "hand.raised")
        }
        .font(theme.typography.caption)
        .foregroundStyle(theme.colors.textSecondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(review.title)
        .accessibilityValue([review.accessibilityValue, correction.accessibilityValue].joined(separator: ". "))
        .accessibilityIdentifier("capture.placement-review.\(review.id)")
    }
}

private struct CaptureGoalSeedIncubatorView: View {
    @Environment(\.ambitionTheme) private var theme

    let state: CaptureGoalSeedIncubatorState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Divider()

            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Label(state.title, systemImage: "seedling")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer()
                TagPill("Confirm first", state: state.state)
            }

            Label(state.whyGoalLabel, systemImage: "questionmark.circle")
            Label(state.startingPositionProofLabel, systemImage: "location")
            Label(state.firstMilestoneAnchorLabel, systemImage: "flag")
            Label(state.firstStepLabel, systemImage: "arrow.forward.circle")
            Label(state.proofSourceSeedLabel, systemImage: "doc.text.magnifyingglass")
            Label(state.promotionConfirmationLabel, systemImage: "hand.raised")
        }
        .font(theme.typography.caption)
        .foregroundStyle(theme.colors.textSecondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(state.title)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityIdentifier("capture.goal-seed-incubator.\(state.id)")
    }
}

private struct CaptureTrustSeam: View {
    @Environment(\.ambitionTheme) private var theme

    let reason: String
    let source: String

    var body: some View {
        CaptureStageGroup(state: .calm, accessibilityIdentifier: "capture.route-trust") {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                EvidenceLabel(
                    "Why this?",
                    detail: reason,
                    source: source,
                    state: .calm,
                    context: .capture
                )

                Label("Review before saving; route choices stay editable.", systemImage: "hand.raised")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Capture route trust")
        .accessibilityValue("\(reason). Review before saving; route choices stay editable.")
    }
}

private struct CaptureActionPipeline: View {
    @Environment(\.ambitionTheme) private var theme

    let capture: Capture
    let activeGoalOptions: [CaptureGoalOption]
    let canPromoteCaptureToGoal: Bool
    let mutationProofContract: CaptureComposerMutationProofContract
    let onRouteToTime: (Capture) -> Void
    let onCreateGoal: (Capture) -> Void
    let onSaveToNeedsPlace: (Capture) -> Void
    let onAttachToGoal: (Capture, CaptureGoalOption) -> Void
    let onMarkDeliverableSeed: (Capture) -> Void
    let onMarkWaiting: (Capture) -> Void
    let onMarkOptionalSomeday: (Capture) -> Void
    let onArchive: (Capture) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.sm) {
                Button {
                    onRouteToTime(capture)
                } label: {
                    Label("Ready to Place", systemImage: "checkmark.circle")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .scheduled) == false)

                Button {
                    onCreateGoal(capture)
                } label: {
                    Label("Open as Goal", systemImage: "target")
                }
                .buttonStyle(.borderedProminent)
                .disabled(canPromoteCaptureToGoal == false)
                .accessibilityIdentifier("capture.new-goal.\(capture.id)")
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    onSaveToNeedsPlace(capture)
                } label: {
                    Label("Keep for review", systemImage: "tray.full")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .needsTriage) == false)

                Menu("Attach proof") {
                    if activeGoalOptions.isEmpty {
                        Text("No active goals")
                    } else {
                        ForEach(activeGoalOptions) { option in
                            Button(option.title) {
                                onAttachToGoal(capture, option)
                            }
                        }
                    }
                }
                .disabled(capture.status.canTransition(to: .goalBound) == false || activeGoalOptions.isEmpty)
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    onMarkDeliverableSeed(capture)
                } label: {
                    Label("Idea", systemImage: "lightbulb")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .seed) == false)

                Button {
                    onMarkWaiting(capture)
                } label: {
                    Label("Waiting", systemImage: "hourglass")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .waiting) == false)
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    onMarkOptionalSomeday(capture)
                } label: {
                    Label("Review later", systemImage: "moon")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .optionalSomeday) == false)

                Button {
                    onArchive(capture)
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .archived) == false)
            }
        }
        .font(theme.typography.caption)
        .accessibilityHint(mutationProofContract.submitHint)
    }
}

private extension NowContextLens {
    var captureDisplayTitle: String {
        switch self {
        case .work: "Work"
        case .personal: "Personal"
        case .freeTime: "Free Time"
        case .admin: "Admin"
        case .creative: "Creative"
        case .recovery: "Recovery"
        case .deepFocus: "Deep Focus"
        case .all: "All"
        }
    }
}
