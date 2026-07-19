import CoreGraphics
import Foundation

enum SurfaceGestureMap {
    static let edgeBackSwipeGrammar = GestureGrammar(
        gesture: .drag,
        semanticAction: "Back",
        requiresVisibleControl: true,
        accessibilityAlternative: "Back button"
    )

    static let todayCommandCapableKinds: Set<TodayActionKind> = [
        .complete,
        .defer,
        .reschedule,
        .split,
        .askForHelp,
        .askWhyThisMatters,
        .quickLog,
    ]

    static func primaryGrammar(for surface: StageMutationTargetSurface) -> GestureGrammar {
        switch surface {
        case .today:
            return GestureGrammar(
                gesture: .tap,
                semanticAction: UserFacingLanguage.Action.startHere,
                requiresVisibleControl: true,
                accessibilityAlternative: KeyboardPolicy.primaryShortcut(for: .today).accessibilityLabel
            )
        case .goals:
            return GestureGrammar(
                gesture: .tap,
                semanticAction: ProductCopy.Goals.openGoal,
                requiresVisibleControl: true,
                accessibilityAlternative: KeyboardPolicy.primaryShortcut(for: .goals).accessibilityLabel
            )
        case .time:
            return GestureGrammar(
                gesture: .tap,
                semanticAction: ProductCopy.Time.shapeWeek,
                requiresVisibleControl: true,
                accessibilityAlternative: KeyboardPolicy.primaryShortcut(for: .time).accessibilityLabel
            )
        case .you:
            return GestureGrammar(
                gesture: .tap,
                semanticAction: ProductCopy.You.profile,
                requiresVisibleControl: true,
                accessibilityAlternative: KeyboardPolicy.primaryShortcut(for: .you).accessibilityLabel
            )
        }
    }

    static func edgeBackSwipeStartWidth(screenWidth: CGFloat) -> CGFloat {
        min(max(screenWidth * 0.16, 36), 64)
    }

    static func isEdgeBackSwipe(
        startDistanceFromLeadingEdge: CGFloat,
        horizontalTranslation: CGFloat,
        verticalTranslation: CGFloat,
        screenWidth: CGFloat
    ) -> Bool {
        let startWidth = edgeBackSwipeStartWidth(screenWidth: screenWidth)
        let horizontalDistance = max(0, horizontalTranslation)
        let verticalDistance = abs(verticalTranslation)
        return startDistanceFromLeadingEdge <= startWidth &&
            horizontalDistance >= 72 &&
            horizontalDistance > verticalDistance * 1.45
    }

    static func validationIssues() -> [String] {
        let rootIssues = StageMutationTargetSurface.allCases.flatMap { surface in
            DirectManipulationPolicy.validate(primaryGrammar(for: surface))
        }
        return rootIssues + DirectManipulationPolicy.validate(edgeBackSwipeGrammar)
    }
}
