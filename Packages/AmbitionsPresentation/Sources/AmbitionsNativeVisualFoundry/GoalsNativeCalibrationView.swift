import SwiftUI

public struct GoalsNativeCalibrationView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let content: GoalsNativeCalibrationContent
    @Binding private var state: GoalsNativeCalibrationJourneyState

    public init(
        content: GoalsNativeCalibrationContent,
        state: Binding<GoalsNativeCalibrationJourneyState>
    ) {
        self.content = content
        _state = state
    }

    public var body: some View {
        NavigationStack(path: navigationPath) {
            GoalsNativeCalibrationRootView(
                content: content,
                state: $state,
                palette: palette,
                usesAdaptiveNavigation: dynamicTypeSize.isAccessibilitySize
            )
        }
        .tint(palette.accent)
        .accessibilityIdentifier("gnc-journey-root")
    }

    private var navigationPath: Binding<[GoalsNativeCalibrationRoute]> {
        Binding(
            get: { state.navigationPath },
            set: { state.reconcileNavigationPath($0) }
        )
    }

    private var palette: GoalsNativeCalibrationPalette {
        GoalsNativeCalibrationPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast
        )
    }
}
