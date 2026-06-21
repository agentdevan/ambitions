import AmbitionsDesignSystem
import SwiftUI

struct CaptureDepthDisclosureStage<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    @Binding var isExpanded: Bool
    let content: Content

    init(
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        _isExpanded = isExpanded
        self.content = content()
    }

    var body: some View {
        CaptureStageGroup(state: .calm, accessibilityIdentifier: "capture.depth-disclosure") {
            DisclosureGroup(isExpanded: $isExpanded) {
                content
                    .padding(.top, theme.spacing.md)
            } label: {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Capture depth")
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text("Open placed items, receipts, and parked capture only after the composer has taken input.")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}
