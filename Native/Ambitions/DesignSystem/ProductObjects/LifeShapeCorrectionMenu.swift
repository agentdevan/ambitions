import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeCorrectionMenu: View {
    @Environment(\.ambitionTheme) private var theme

    let layer: LifeShapeLayer
    let onNotUsable: () -> Void
    let onNeedsMoreTime: () -> Void
    let onKeepClear: () -> Void

    var body: some View {
        Menu {
            Button("Not usable", systemImage: "xmark.circle", action: onNotUsable)
            Button("Needs more time", systemImage: "clock.arrow.circlepath", action: onNeedsMoreTime)
            Button("Keep this clear", systemImage: "lock.shield", action: onKeepClear)
        } label: {
            Label(labelTitle, systemImage: "slider.horizontal.3")
                .font(theme.typography.body.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.76)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier("time.life-shape-field.correction-menu")
    }

    private var labelTitle: String {
        switch layer {
        case .open:
            "Correct window"
        case .protected:
            "Update boundary"
        case .pressure:
            "Update pressure"
        case .buffer:
            "Update buffer"
        }
    }
}
