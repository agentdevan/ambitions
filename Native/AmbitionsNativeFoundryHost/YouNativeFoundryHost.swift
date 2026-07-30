import AmbitionsNativeVisualFoundry
import SwiftUI

enum YouNativeFoundryVariant: String {
    case root = "ync-d07-root-dark"
    case appearanceDepth = "ync-d07-appearance-depth-dark"
    case accessibilityRoot = "ync-d07-root-accessibility-dark"

    static var fromProcessArguments: YouNativeFoundryVariant? {
        let arguments = ProcessInfo.processInfo.arguments
        for flag in ["-FoundryVariant", "-FoundryJourney"] {
            guard
                let flagIndex = arguments.firstIndex(of: flag),
                arguments.indices.contains(flagIndex + 1),
                let variant = YouNativeFoundryVariant(rawValue: arguments[flagIndex + 1])
            else {
                continue
            }
            return variant
        }
        return nil
    }

    var dynamicTypeSize: DynamicTypeSize {
        self == .accessibilityRoot ? .accessibility2 : .large
    }
}

struct YouNativeFoundryHost: View {
    private let fixture = YouNativeCalibrationFixture.flagship
    @State private var state: YouNativeCalibrationJourneyState

    let variant: YouNativeFoundryVariant

    init(variant: YouNativeFoundryVariant) {
        self.variant = variant
        var initialState = YouNativeCalibrationJourneyState()
        if variant == .appearanceDepth {
            _ = initialState.openAppearance()
        }
        _state = State(initialValue: initialState)
    }

    var body: some View {
        YouNativeCalibrationView(
            fixture: fixture,
            state: $state
        )
        .preferredColorScheme(.dark)
        .dynamicTypeSize(variant.dynamicTypeSize)
        .environment(\.locale, Locale(identifier: "en_US"))
        .environment(\.layoutDirection, LayoutDirection.leftToRight)
    }
}
