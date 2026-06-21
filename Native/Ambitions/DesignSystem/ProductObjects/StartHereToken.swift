import AmbitionsDesignSystem
import SwiftUI

struct StartHereToken: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String

    init(title: String = "Start here") {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(AmbitionsTypography(theme: theme).caption)
            .foregroundStyle(AmbitionsColor(theme: theme).tertiaryText)
            .accessibilityIdentifier("product.start-here-token")
    }
}
