import AmbitionsDesignSystem
import Foundation

extension PreviewTimeScenarios {
    static let seededLifeSuite = TimeLifeSuiteState(
        title: "Shape Time",
        subtitle: "LifeShape Field shows what the week can hold.",
        shapes: [
            TimeLifeSuiteShapeState(kind: .day, title: "Day Shape", question: "What can this day honestly hold?", summary: "Today has tight room and three planned blocks.", facts: ["Tight room", "One open window", "3 planned blocks attached."], sourceLabel: "Based on Time", boundaryLabel: "No silent replanning", visualState: .warning),
            TimeLifeSuiteShapeState(kind: .week, title: "Week Shape", question: "Does the week still fit?", summary: "Two days may need shaping before the week feels believable.", facts: ["2 pressured days visible.", "2 captures need a place.", "7 days included in this week."], sourceLabel: "Based on goals and captures", boundaryLabel: "Suggestions require confirmation", visualState: .warning),
            TimeLifeSuiteShapeState(kind: .life, title: "Life Shape", question: "Is Time still pointed at the life you are building?", summary: "Three active goals shape the current LifeShape Field.", facts: ["3 active goals included.", "Life Shape stays inside Time."], sourceLabel: "Based on active goals", boundaryLabel: "Life view, broader than time slots", visualState: .selected)
        ],
        calendarBoundaryLabel: "Calendar stays optional",
        manualFallbackLabel: "User choice available",
        trustLabel: "No silent calendar changes"
    )

    static let emptyLifeSuite = TimeLifeSuiteState(
        title: "Shape Time",
        subtitle: "LifeShape Field shows what the week can hold.",
        shapes: [
            TimeLifeSuiteShapeState(kind: .day, title: "Day Shape", question: "What can this day honestly hold?", summary: "No day shape is loaded yet.", facts: ["Manual shaping is available.", "Nothing moves without review."], sourceLabel: "Based on Time", boundaryLabel: "No silent replanning", visualState: .default),
            TimeLifeSuiteShapeState(kind: .week, title: "Week Shape", question: "Does the week still fit?", summary: "The week has room until goals, captures, or routines create real constraints.", facts: ["0 pressured days visible.", "0 captures need a place.", "7 days included in this week."], sourceLabel: "Based on goals and captures", boundaryLabel: "Suggestions require confirmation", visualState: .selected),
            TimeLifeSuiteShapeState(kind: .life, title: "Life Shape", question: "Is Time still pointed at the life you are building?", summary: "Life Shape is quiet until active goals give Time something to shape.", facts: ["No active goals shaping life view yet.", "Life Shape stays inside Time."], sourceLabel: "Based on active goals", boundaryLabel: "Life view, broader than time slots", visualState: .default)
        ],
        calendarBoundaryLabel: "Manual planning still works",
        manualFallbackLabel: "User choice available",
        trustLabel: "No silent calendar changes"
    )

    static let seededReflowDecision = TimeReflowDecisionState(
        title: "Reflow decisions",
        subtitle: "Choose one path before anything changes.",
        sourceLabel: "Based on your plan",
        trustLabel: "Changes stay reviewable",
        reasonLabel: "Tuesday is carrying more than this plan can calmly explain.",
        recoveryLabel: "No schedule changes happen from this card.",
        receiptLabel: "Safe local suggestion. No silent rescheduling. No calendar write. Nothing changed yet.",
        options: [
            TimeReflowDecisionOptionState(
                id: "preview-decision-protect",
                kind: .protectTime,
                title: "Protect time",
                detail: "Keep shell regression work defended before changing the rest.",
                impactLabel: "Smallest useful adjustment",
                sourceLabel: "Based on your plan",
                trustLabel: "Changes stay reviewable",
                boundaryLabel: "Safe local suggestion. Undo can be local.",
                visualState: .selected,
                target: GoalRouteTarget(goalID: "preview-goal-1"),
                timeRoute: nil
            ),
            TimeReflowDecisionOptionState(
                id: "preview-decision-smaller",
                kind: .makeSmaller,
                title: "Make smaller",
                detail: "Close only the top regression before moving anything else.",
                impactLabel: "Local suggestion only",
                sourceLabel: "Based on your plan",
                trustLabel: "Changes stay reviewable",
                boundaryLabel: "Safe local suggestion. Undo can be local.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: "preview-goal-1"),
                timeRoute: nil
            ),
            TimeReflowDecisionOptionState(
                id: "preview-decision-review",
                kind: .reviewShape,
                title: "Review plan",
                detail: "Confirm before applying any broad reflow or calendar-impacting change.",
                impactLabel: "Nothing changes until confirmed",
                sourceLabel: "Based on your plan",
                trustLabel: "Changes stay reviewable",
                boundaryLabel: "Broad reflow needs confirmation. Undo not supported yet.",
                visualState: .warning,
                target: nil,
                timeRoute: nil
            )
        ],
        visualState: .warning
    )

    static let emptyReflowDecision = TimeReflowDecisionState(
        title: "Reflow decisions",
        subtitle: "Choose one path before anything changes.",
        sourceLabel: "Based on your plan",
        trustLabel: "Changes stay reviewable",
        reasonLabel: "There is not enough plan pressure to reflow yet.",
        recoveryLabel: "No schedule changes happen from this card.",
        receiptLabel: "Safe local suggestion. No silent rescheduling. No calendar write. Nothing changed yet.",
        options: [
            TimeReflowDecisionOptionState(
                id: "preview-decision-empty",
                kind: .keepTime,
                title: "Keep plan",
                detail: "Leave the plan unchanged until there is enough evidence to adjust it.",
                impactLabel: "No plan mutation",
                sourceLabel: "Based on your plan",
                trustLabel: "Changes stay reviewable",
                boundaryLabel: "Safe local suggestion. Undo can be local.",
                visualState: .default,
                target: nil,
                timeRoute: nil
            )
        ],
        visualState: .default
    )
}
