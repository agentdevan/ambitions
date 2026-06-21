import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsSpacing {
    let theme: AmbitionTheme

    var compact: CGFloat { theme.spacing.xs }
    var standard: CGFloat { theme.spacing.sm }
    var objectGap: CGFloat { theme.spacing.md }
    var sectionGap: CGFloat { theme.spacing.lg }
    var primaryObjectPadding: CGFloat { theme.spacing.md }
    var minimumTapTarget: CGFloat { theme.panel.minimumTapTarget }

    func actionWidth(dynamicTypeIsAccessibilitySize: Bool) -> CGFloat? {
        dynamicTypeIsAccessibilitySize ? nil : 220
    }
}
