import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeMutationProofBanner: View {
    @Environment(\.ambitionTheme) private var theme

    let mutation: UserVisibleMutation
    let onUndo: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentPrimary)
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(mutation.headline)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(mutation.detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Local change saved. Undo is available here.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.xs)

            if let onUndo {
                Button("Undo", action: onUndo)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityIdentifier("time.life-shape-field.undo")
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(theme.colors.accentPrimary)
                .frame(width: 4)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(mutation.headline)
        .accessibilityValue("\(mutation.detail). \(mutation.stageMutation.accessibilityAnnouncement.message)")
        .accessibilityIdentifier("time.life-shape-field.mutation-proof")
    }
}
