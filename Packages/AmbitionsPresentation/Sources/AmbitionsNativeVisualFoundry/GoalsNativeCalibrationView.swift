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
            .navigationTitle("Goals")
            .navigationDestination(for: GoalsNativeCalibrationRoute.self) { route in
                destination(for: route)
            }
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

    @ViewBuilder
    private func destination(for route: GoalsNativeCalibrationRoute) -> some View {
        switch route {
        case let .lifeArea(id):
            GoalsNativeCalibrationLifeAreaView(
                content: content,
                lifeAreaID: id,
                palette: palette
            )
        case let .focusedGoal(id) where id == content.primaryGoal.id:
            GoalsNativeCalibrationFocusedGoalView(
                content: content,
                state: $state,
                palette: palette
            )
        case let .relationship(primaryGoalID, relatedGoalID)
            where primaryGoalID == content.relationship.primaryGoalID
                && relatedGoalID == content.relationship.relatedGoalID:
            GoalsNativeCalibrationRelationshipView(
                content: content,
                palette: palette
            )
        case let .goalPath(id) where id == content.goalPath.id:
            GoalsNativeCalibrationPathView(
                content: content,
                state: $state,
                palette: palette
            )
        default:
            EmptyView()
        }
    }
}

extension View {
    @ViewBuilder
    func goalsNativeCalibrationDepthNavigation(title: String) -> some View {
        #if os(iOS)
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
        #else
        navigationTitle(title)
        #endif
    }
}
