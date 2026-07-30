import SwiftUI

public enum GoalsNativeCalibrationDepthEntryMode: Equatable, Sendable {
    case active
    case recovery
    case closure
}

public struct GoalsNativeCalibrationView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let content: GoalsNativeCalibrationContent
    private let depthEntryMode: GoalsNativeCalibrationDepthEntryMode
    @Binding private var state: GoalsNativeCalibrationJourneyState

    public init(
        content: GoalsNativeCalibrationContent,
        state: Binding<GoalsNativeCalibrationJourneyState>,
        depthEntryMode: GoalsNativeCalibrationDepthEntryMode = .active
    ) {
        self.content = content
        self.depthEntryMode = depthEntryMode
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
                palette: palette,
                depthEntryMode: depthEntryMode
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
        case let .pathEvidence(pathID, nodeID)
            where pathID == content.goalPath.id
                && content.goalPath.node(id: nodeID) != nil:
            GoalsNativeCalibrationPathEvidenceView(
                content: content,
                nodeID: nodeID,
                palette: palette
            )
        case let .recovery(id) where id == content.recovery.id:
            GoalsNativeCalibrationRecoveryView(
                content: content,
                palette: palette,
                reviewCurrentPath: { _ = state.openRecoveryPath() },
                inspectPossibleNext: { _ = state.inspectPossibleNext() },
                keepUnresolved: { _ = state.keepRecoveryUnresolved() }
            )
        case let .closure(id) where id == content.closure.id:
            GoalsNativeCalibrationClosureView(
                content: content,
                palette: palette,
                viewHistory: { _ = state.openClosureHistory() },
                returnToGoal: { state.reconcileNavigationPath(focusedGoalPath) }
            )
        case let .closureHistory(id) where id == content.closure.id:
            GoalsNativeCalibrationClosureHistoryView(
                content: content,
                palette: palette
            )
        default:
            EmptyView()
        }
    }

    private var focusedGoalPath: [GoalsNativeCalibrationRoute] {
        [
            .lifeArea(id: content.primaryGoal.lifeAreaID),
            .focusedGoal(id: content.primaryGoal.id)
        ]
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
