#if canImport(SwiftUI)
import SwiftUI

extension DesignSystemPreviewGallery {
    func panelDensityMatrixTile(
        configuration: AmbitionPanelDisplayConfiguration
    ) -> some View {
        let required = AmbitionTheme.dark.panelDisplayDecision(
            for: .todayPlan,
            configuration: configuration
        )
        let optional = AmbitionTheme.dark.panelDisplayDecision(
            for: .optional,
            configuration: configuration
        )

        return WidgetCard {
            VStack(alignment: .leading, spacing: required.metrics.verticalSpacing) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(configuration.density.title)
                            .font(theme.typography.sectionTitle)
                        Text(configuration.size.title)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }

                    Spacer()

                    AmbitionChip(
                        required.visibility.previewTitle,
                        role: .state,
                        semanticState: .trust
                    )
                }

                Text("Required information stays visible.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if required.showsSupportingDetail {
                    Text("Looks doable.")
                        .font(theme.typography.caption.weight(.semibold))
                }

                if optional.visibility == .hidden {
                    Text("Extra detail hidden.")
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    Text(optional.visibility == .full ? "More detail shown." : "Extra detail summarized.")
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Button("Make today doable") {}
                    .buttonStyle(AmbitionButtonStyle(tier: .compact, state: .selected))
                    .frame(minHeight: required.metrics.minimumTapTarget)
            }
            .padding(required.metrics.panelPadding)
            .ambitionPanelDisplayConfiguration(configuration)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(configuration.density.title), \(configuration.size.title)")
            .accessibilityValue("Required information stays visible. \(optional.visibility.previewAccessibilityText)")
        }
    }
}
#endif
