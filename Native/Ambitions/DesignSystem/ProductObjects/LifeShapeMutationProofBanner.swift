import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeMutationProofBanner: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let mutation: UserVisibleMutation
    let onUndo: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(theme.stateStyle(for: .success).fill.opacity(reduceTransparency ? 0.34 : 0.22))
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.stateStyle(for: .success).accent)
                }
                .frame(width: 38, height: 38)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(mutation.headline)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("time.life-shape-field.mutation-proof.changed")

                    Text(mutation.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.xs)

                if let onUndo {
                    Button(action: onUndo) {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                            .labelStyle(.titleAndIcon)
                            .font(theme.typography.caption.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityIdentifier("time.life-shape-field.undo")
                }
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                proofRow(
                    title: "Source",
                    value: sourceValue,
                    systemImage: "location",
                    identifier: "time.life-shape-field.mutation-proof.source"
                )
                proofRow(
                    title: "Proof",
                    value: proofValue,
                    systemImage: "checkmark.seal",
                    identifier: "time.life-shape-field.mutation-proof.proof"
                )
                proofRow(
                    title: "History",
                    value: historyValue,
                    systemImage: "clock.arrow.circlepath",
                    identifier: "time.life-shape-field.mutation-proof.history"
                )
                proofRow(
                    title: "Private",
                    value: privateValue,
                    systemImage: "lock",
                    identifier: "time.life-shape-field.mutation-proof.privacy"
                )
            }
        }
        .padding(theme.spacing.sm)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(reduceTransparency ? 0.96 : 0.74))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(theme.stateStyle(for: .success).stroke.opacity(0.46), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(mutation.headline)
        .accessibilityValue("\(mutation.detail). \(sourceValue). \(proofValue). \(historyValue). \(privateValue). \(mutation.stageMutation.accessibilityAnnouncement.message)")
        .accessibilityIdentifier("time.life-shape-field.mutation-proof")
    }

    private var sourceValue: String {
        guard let source = mutation.stageMutation.proofArtifact.action?.source else {
            return "Local Time action"
        }
        switch source {
        case .time:
            return "Local Time action"
        case .today:
            return "Local Today action"
        case .goals, .goalDetail:
            return "Local Goals action"
        case .capture:
            return "Local Capture action"
        case .you:
            return "Local settings action"
        default:
            return "Local Ambitions action"
        }
    }

    private var proofValue: String {
        mutation.stageMutation.proofArtifact.state == .available
            ? mutation.stageMutation.proofArtifact.label
            : "Proof not available"
    }

    private var historyValue: String {
        mutation.stageMutation.receipt.inspectionLabel
    }

    private var privateValue: String {
        mutation.stageMutation.proofArtifact.localOnly
            ? "Saved on this iPhone"
            : "Review privacy before sharing"
    }

    private func proofRow(title: String, value: String, systemImage: String, identifier: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(theme.stateStyle(for: .success).accent)
                .frame(width: 18)
                .accessibilityHidden(true)

            Text(title)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: 48, alignment: .leading)

            Text(value)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.74)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        .accessibilityIdentifier(identifier)
    }
}
