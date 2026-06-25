import AmbitionsDesignSystem
import SwiftUI

struct ProtectedPlacementReviewCard: View {
    @Environment(\.ambitionTheme) private var theme

    let review: ProtectedPlacementReviewState
    let onApprove: () -> Void
    let onKeep: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("Review change")
                    .font(theme.typography.titleCompact.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("This moves a Step inside the next seven days. Ambitions will not move it without approval.")
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                reviewRow(title: "Step", value: review.stepTitle, identifier: "protected-placement-review.step")
                reviewRow(title: "Current placement", value: review.currentPlacementLabel, identifier: "protected-placement-review.current-placement")
                reviewRow(title: "Proposed placement", value: review.proposedPlacementLabel, identifier: "protected-placement-review.proposed-placement")
                reviewRow(title: "This changes this week", value: review.reasonLabel, identifier: "protected-placement-review.reason")
            }

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
                .fill(theme.colors.surfaceOverlay.opacity(0.94))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(theme.colors.strokeSubtle.opacity(0.72), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Review change")
        .accessibilityValue(review.accessibilityValue)
        .accessibilityHint("Choose Move it to approve, or Keep as is to leave the Step where it is.")
        .accessibilityIdentifier("protected-placement-review")
    }

    private func reviewRow(title: String, value: String, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
            Text(value)
                .font(theme.typography.bodySecondary)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        .accessibilityIdentifier(identifier)
    }
}
