import AmbitionsDesignSystem
import SwiftUI

struct UserSystemProfileView: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let summary: String
    let controls: [NativeSettingsRowModel]

    var body: some View {
        NativeSettingsGroup(title: title, footer: summary) {
            ForEach(controls) { control in
                NativeSettingsRow(model: control)
            }
        }
        .accessibilityIdentifier("product.user-system-profile")
    }
}
