import Foundation

struct MotionSemanticModel: Equatable {
    let behaviorName: String
    let crownSummary: String
    let changedObjectSummary: String
    let changeStateSummary: String
    let returnPointSummary: String
    let reductionSummary: String
    let consequenceMirrors: [MotionConsequenceMirror]

    init(
        projection: MotionCurrentProjection,
        reductionPolicy: StageMotionReductionPolicy
    ) {
        behaviorName = UserFacingLanguage.Object.stageMotion
        crownSummary = projection.crown.summary
        changedObjectSummary = projection.field.changedObject
        changeStateSummary = projection.field.changeState
        returnPointSummary = projection.field.returnPoint
        reductionSummary = reductionPolicy.rhythmSpacingDescription
        consequenceMirrors = MotionConsequenceMirror.current(
            projection: projection,
            reductionPolicy: reductionPolicy
        )
    }

    var provesBehaviorNotDestination: Bool {
        behaviorName == UserFacingLanguage.Object.stageMotion &&
            changedObjectSummary.isEmpty == false &&
            changeStateSummary.isEmpty == false &&
            returnPointSummary.isEmpty == false &&
            reductionSummary.isEmpty == false &&
            hasRequiredBehaviorConsequences
    }

    var hasRequiredBehaviorConsequences: Bool {
        Set(consequenceMirrors.map(\.kind)) == Set(MotionConsequenceKind.allCases) &&
            consequenceMirrors.allSatisfy(\.hasAccessibleStaticEquivalent)
    }

    var accessibleConsequenceSummary: String {
        consequenceMirrors
            .map(\.accessibilityPhrase)
            .joined(separator: " ")
    }
}

enum MotionConsequenceKind: String, CaseIterable {
    case completion
    case blockage
    case review
    case recovery
    case reEntry
    case undo
    case protectedBoundary
}

struct MotionConsequenceMirror: Equatable {
    let kind: MotionConsequenceKind
    let label: String
    let visibleMutation: String
    let proofRelationship: String
    let accessibilityPhrase: String
    let reduceMotionEquivalent: String

    var hasAccessibleStaticEquivalent: Bool {
        label.isEmpty == false &&
            visibleMutation.isEmpty == false &&
            proofRelationship.isEmpty == false &&
            accessibilityPhrase.isEmpty == false &&
            reduceMotionEquivalent.isEmpty == false
    }

    static func current(
        projection: MotionCurrentProjection,
        reductionPolicy: StageMotionReductionPolicy
    ) -> [MotionConsequenceMirror] {
        [
            MotionConsequenceMirror(
                kind: .completion,
                label: "Completion",
                visibleMutation: "Closed work stays attached to the current stage thread.",
                proofRelationship: projection.field.changeState,
                accessibilityPhrase: "Completion keeps saved history visible.",
                reduceMotionEquivalent: reductionPolicy.motionQuery(label: "completion", action: .returnToThread(projection.field.control))
            ),
            MotionConsequenceMirror(
                kind: .blockage,
                label: "Blocked",
                visibleMutation: "Blocked or waiting work stays held instead of being silently moved.",
                proofRelationship: "Context and history explain why the thread is held.",
                accessibilityPhrase: "Blocked state stays visible with context and history.",
                reduceMotionEquivalent: "Static blocked marker"
            ),
            MotionConsequenceMirror(
                kind: .review,
                label: "Review",
                visibleMutation: "Context, history, and review remain inspectable before change.",
                proofRelationship: projection.field.returnPoint,
                accessibilityPhrase: "Review can be opened from the current object.",
                reduceMotionEquivalent: reductionPolicy.movementTextureDescription
            ),
            MotionConsequenceMirror(
                kind: .recovery,
                label: "Recovery",
                visibleMutation: "Recovery creates a lighter return path that still counts.",
                proofRelationship: "Recovery keeps minimum history and reason visible.",
                accessibilityPhrase: "Recovery state names the lighter path and preserved history.",
                reduceMotionEquivalent: "Static recovery marker"
            ),
            MotionConsequenceMirror(
                kind: .reEntry,
                label: "Re-entry",
                visibleMutation: "A paused thread keeps one visible return point.",
                proofRelationship: projection.field.changedObject,
                accessibilityPhrase: "Re-entry names the return point and owner.",
                reduceMotionEquivalent: "Static re-entry marker"
            ),
            MotionConsequenceMirror(
                kind: .undo,
                label: "Undo",
                visibleMutation: "Undo remains explicit when a stage mutation can be reversed.",
                proofRelationship: "Undo preserves the prior history path.",
                accessibilityPhrase: "Undo state is announced only when reversal is supported.",
                reduceMotionEquivalent: "Static undo marker"
            ),
            MotionConsequenceMirror(
                kind: .protectedBoundary,
                label: "Protected",
                visibleMutation: "Protected boundaries prevent silent widening across surfaces.",
                proofRelationship: "Consent and context stay attached to the protected edge.",
                accessibilityPhrase: "Protected boundary names consent before cross-surface change.",
                reduceMotionEquivalent: "Static protected-boundary marker"
            ),
        ]
    }
}
