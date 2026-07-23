import SwiftUI

#Preview("Today Bootstrap — Typical Light") {
    TodayBootstrapView(
        content: TodayBootstrapFixture.preparingForBaby,
        onOpenStep: {},
        onOpenDock: {}
    )
    .preferredColorScheme(.light)
}

#Preview("Today Bootstrap — Typical Dark") {
    TodayBootstrapView(
        content: TodayBootstrapFixture.preparingForBaby,
        onOpenStep: {},
        onOpenDock: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Today Bootstrap — Accessibility Dynamic Type Dark") {
    TodayBootstrapView(
        content: TodayBootstrapFixture.preparingForBaby,
        onOpenStep: {},
        onOpenDock: {}
    )
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility1)
}
