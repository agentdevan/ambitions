import Foundation

enum GoalsInteractionIntent: Sendable, Equatable {
    case createGoal
    case openGoal
    case recoverGoal
    case refineStrategy
}

enum GoalsInteractions {
    static func intent(for action: GoalsAtlasPrimaryAction) -> GoalsInteractionIntent {
        switch action.kind {
        case .createGoal:
            .createGoal
        case .openGoal:
            .openGoal
        case .recoverGoal:
            .recoverGoal
        case .refineStrategy:
            .refineStrategy
        }
    }

    static func accessibilityAnnouncement(for intent: GoalsInteractionIntent) -> String {
        switch intent {
        case .createGoal:
            "Goal creation opened."
        case .openGoal:
            "Goal detail opened."
        case .recoverGoal:
            "Goal recovery opened."
        case .refineStrategy:
            "Strategy review opened."
        }
    }
}
