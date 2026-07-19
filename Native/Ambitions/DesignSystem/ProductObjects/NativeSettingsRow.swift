import AmbitionsDesignSystem
import SwiftUI

struct NativeSettingsRowModel: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let value: String
    let systemImage: String
}

struct NativeSettingsRow: View {
    @Environment(\.ambitionTheme) private var theme

    let model: NativeSettingsRowModel

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
            Image(systemName: model.systemImage)
                .foregroundStyle(theme.semanticColors.trust)
                .accessibilityHidden(true)
            Text(model.title)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textPrimary)
            Spacer(minLength: theme.spacing.sm)
            Text(model.value)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(theme.spacing.sm)
        .background(SurfaceMorphBackdrop(role: .detailObject))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("product.native-settings-row.\(model.id)")
    }
}
