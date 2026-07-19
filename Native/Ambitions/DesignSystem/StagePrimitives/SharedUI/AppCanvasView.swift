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
            theme.shell.canvasGradient
                .ignoresSafeArea()

            content
        }
    }
}
