import AmbitionsNativeVisualFoundry
import SwiftUI

@main
struct AmbitionsNativeFoundryHostApp: App {
    var body: some Scene {
        WindowGroup {
            TodayBootstrapHostRoot(variant: .fromProcessArguments)
        }
    }
}

private struct TodayBootstrapHostRoot: View {
    let variant: FoundryVariant

    var body: some View {
        TodayBootstrapView(
            content: TodayBootstrapFixture.preparingForBaby,
            onOpenStep: {},
            onOpenDock: {}
        )
        .preferredColorScheme(variant.colorScheme)
        .dynamicTypeSize(variant.dynamicTypeSize)
    }
}

private enum FoundryVariant: String {
    case typicalLight = "typical-light"
    case typicalDark = "typical-dark"
    case accessibilityDark = "accessibility-dark"

    static var fromProcessArguments: FoundryVariant {
        let arguments = ProcessInfo.processInfo.arguments
        guard
            let flagIndex = arguments.firstIndex(of: "-FoundryVariant"),
            arguments.indices.contains(flagIndex + 1),
            let variant = FoundryVariant(rawValue: arguments[flagIndex + 1])
        else {
            return .typicalLight
        }
        return variant
    }

    var colorScheme: ColorScheme {
        self == .typicalLight ? .light : .dark
    }

    var dynamicTypeSize: DynamicTypeSize {
        self == .accessibilityDark ? .accessibility1 : .large
    }
}
