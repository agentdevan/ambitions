import Foundation

struct TodayRootActionAvailability: Equatable, Sendable {
    let shapeTime: TodayInlineAction?
    let protectWindow: TodayInlineAction?
    let recordOutcome: TodayInlineAction?

    static let none = TodayRootActionAvailability(shapeTime: nil, protectWindow: nil, recordOutcome: nil)
}

enum TodayRootActionGate {
    static func actions(for heroStep: DayRailHeroStepState?) -> TodayRootActionAvailability {
        guard let heroStep,
              heroStep.primaryAction.target.stepID != nil || heroStep.primaryAction.target.goalID != nil else {
            return .none
        }

        let target = heroStep.primaryAction.target
        let shapeTime = TodayInlineAction(
            kind: .openTime,
            title: "Shape Time",
            systemImage: "calendar.badge.clock",
            state: .default,
            target: target
        )
        let protectWindow = TodayInlineAction(
            kind: .protectLater,
            title: "Protect this window",
            systemImage: "shield",
            state: .default,
            target: target
        )
        let recordOutcome = isClosureEligible(heroStep.primaryAction)
            ? TodayInlineAction(
                kind: .closeActionClosure,
                title: "Record outcome",
                systemImage: "checkmark.seal",
                state: .default,
                target: target
            )
            : nil

        return TodayRootActionAvailability(
            shapeTime: shapeTime,
            protectWindow: protectWindow,
            recordOutcome: recordOutcome
        )
    }

    static func isClosureEligible(_ action: TodayInlineAction) -> Bool {
        action.kind == .complete || action.kind == .closeActionClosure
    }
}
