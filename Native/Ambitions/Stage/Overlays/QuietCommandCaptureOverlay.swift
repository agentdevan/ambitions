import AmbitionsDesignSystem
import SwiftUI

extension QuietCommandSheetView {
    var captureComposerRedirect: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Capture opens as a full-screen composer.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Button("Open Capture") {
                onDismiss()
                actions.presentGlobalCapture(source: overlay.entrySource)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
            .accessibilityIdentifier("shell.command.action.quick_capture")
        }
    }
}
