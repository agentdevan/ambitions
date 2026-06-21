import Foundation

enum SurfaceGestureMap {
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

    static func validationIssues() -> [String] {
        StageMutationTargetSurface.allCases.flatMap { surface in
            DirectManipulationPolicy.validate(primaryGrammar(for: surface))
        }
    }
}
