import AmbitionsDesignSystem
import SwiftUI

struct AppCanvasView<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            theme.colors.canvas
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    theme.colors.accentSecondary.opacity(0.16),
                    theme.colors.canvas.opacity(0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            content
        }
    }
}
