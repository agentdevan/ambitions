import AmbitionsDesignSystem
import SwiftUI

// Mutation/accessibility/proof contract: protected-placement actions either approve a local Time placement mutation with visible review state or keep the existing Step placement without fabricating proof.
struct ProtectedPlacementReviewCard: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let review: ProtectedPlacementReviewState
    let onPriorityChange: (PlacementPriority) -> Void
    let onApprove: () -> Void
    let onKeep: () -> Void

    var body: some View {
        let reviewStyle = theme.stateStyle(for: .warning)

        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(reviewStyle.fill.opacity(reduceTransparency ? 0.34 : 0.20))
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(reviewStyle.accent)
                }
                .frame(width: 40, height: 40)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text("Review Step placement")
                        .font(theme.typography.section.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text("This touches this week. Time will keep the current placement unless you approve the move.")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                reviewRow(title: "Step", value: review.stepTitle, identifier: "protected-placement-review.step")
                reviewRow(title: "Stays now", value: review.currentPlacementLabel, identifier: "protected-placement-review.current-placement")
                reviewRow(title: "Move to", value: review.proposedPlacementLabel, identifier: "protected-placement-review.proposed-placement")
                reviewRow(title: "Protection", value: review.decision.userImpactSummary, identifier: "protected-placement-review.protection")
                priorityControl
                reviewRow(title: "Receipt", value: "Approving saves a local receipt. Keep as is makes no placement change.", identifier: "protected-placement-review.receipt")
                reviewRow(title: "Private", value: "No sign-in or cloud handoff is needed.", identifier: "protected-placement-review.privacy")
            }

            Text(review.priorityDecision.reviewNote)
                .font(theme.typography.bodySecondary)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("protected-placement-review.priority-note")

            HStack(spacing: theme.spacing.sm) {
                Button(action: onKeep) {
                    Label("Keep as is", systemImage: "arrow.uturn.backward")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("protected-placement-review.keep-as-is")
                .accessibilityHint("Leaves the Step where it is.")

                Button(action: onApprove) {
                    Label("Move it", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("protected-placement-review.move-it")
                .accessibilityHint("Applies this change now.")
            }
            .font(theme.typography.bodyEmphasized)
        }
        .padding(theme.spacing.md)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(reduceTransparency ? 0.98 : 0.86))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(reviewStyle.stroke.opacity(0.62), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Review Step placement")
        .accessibilityValue(review.accessibilityValue)
        .accessibilityHint("Choose Move it to approve, or Keep as is to leave the Step where it is.")
        .accessibilityIdentifier("protected-placement-review")
    }

    private var priorityControl: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text("Priority")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
            Picker(
                "Priority",
                selection: Binding(
                    get: { review.priorityDecision.priority },
                    set: { onPriorityChange($0) }
                )
            ) {
                ForEach(PlacementPriority.allCases, id: \.self) { priority in
                    Text(priority.userFacingLabel)
                        .tag(priority)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("protected-placement-review.priority")
            .accessibilityLabel("Priority")
            .accessibilityValue(review.priorityDecision.priority.userFacingLabel)
            .accessibilityHint("Choose Low, Normal, or High.")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func reviewRow(title: String, value: String, identifier: String) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .frame(width: 72, alignment: .leading)
            Text(value)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, theme.spacing.xxs)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        .accessibilityIdentifier(identifier)
    }
}
