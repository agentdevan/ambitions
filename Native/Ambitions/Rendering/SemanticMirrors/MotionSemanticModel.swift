import Foundation

struct MotionSemanticModel: Equatable, Sendable {
    let behaviorName: String
    let crownSummary: String
    let sourceSummary: String
    let proofSummary: String
    let receiptSummary: String
    let reductionSummary: String
    let consequenceMirrors: [MotionConsequenceMirror]

    init(
        projection: MotionCurrentProjection,
        reductionPolicy: StageMotionReductionPolicy
    ) {
        self.behaviorName = UserFacingLanguage.Object.stageMotion
        self.crownSummary = projection.crown.summary
        self.sourceSummary = projection.field.source
        self.proofSummary = projection.field.proof
        self.receiptSummary = projection.field.receipt
        self.reductionSummary = reductionPolicy.rhythmSpacingDescription
        self.consequenceMirrors = MotionConsequenceMirror.current(
            projection: projection,
            reductionPolicy: reductionPolicy
        )
    }

    var provesBehaviorNotDestination: Bool {
        behaviorName == UserFacingLanguage.Object.stageMotion &&
            sourceSummary.isEmpty == false &&
            proofSummary.isEmpty == false &&
            receiptSummary.isEmpty == false &&
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

enum MotionConsequenceKind: String, CaseIterable, Sendable {
    case completion
    case blockage
    case proof
    case recovery
    case reEntry
    case undo
    case protectedBoundary
}

struct MotionConsequenceMirror: Equatable, Sendable {
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
                proofRelationship: projection.field.proof,
                accessibilityPhrase: "Completion keeps saved proof visible.",
                reduceMotionEquivalent: reductionPolicy.motionQuery(label: "completion", action: .openThread(projection.field.control))
            ),
            MotionConsequenceMirror(
                kind: .blockage,
                label: "Blocked",
                visibleMutation: "Blocked or waiting work stays held instead of being silently moved.",
                proofRelationship: "Source and receipt explain why the thread is held.",
                accessibilityPhrase: "Blocked state stays visible with source and receipt context.",
                reduceMotionEquivalent: "Static blocked marker"
            ),
            MotionConsequenceMirror(
                kind: .proof,
                label: "Proof",
                visibleMutation: "Proof, source, and receipt remain inspectable before change.",
                proofRelationship: projection.field.receipt,
                accessibilityPhrase: "Proof route can be inspected from the current stage.",
                reduceMotionEquivalent: reductionPolicy.proofThreadTextureDescription
            ),
            MotionConsequenceMirror(
                kind: .recovery,
                label: "Recovery",
                visibleMutation: "Recovery creates a lighter return path that still counts.",
                proofRelationship: "Recovery keeps minimum proof and reason visible.",
                accessibilityPhrase: "Recovery state names the lighter path and preserved proof.",
                reduceMotionEquivalent: "Static recovery marker"
            ),
            MotionConsequenceMirror(
                kind: .reEntry,
                label: "Re-entry",
                visibleMutation: "A paused thread keeps one visible return point.",
                proofRelationship: projection.field.source,
                accessibilityPhrase: "Re-entry names the return point and owner.",
                reduceMotionEquivalent: "Static re-entry marker"
            ),
            MotionConsequenceMirror(
                kind: .undo,
                label: "Undo",
                visibleMutation: "Undo remains explicit when a stage mutation can be reversed.",
                proofRelationship: "Undo preserves the prior receipt path.",
                accessibilityPhrase: "Undo state is announced only when reversal is supported.",
                reduceMotionEquivalent: "Static undo marker"
            ),
            MotionConsequenceMirror(
                kind: .protectedBoundary,
                label: "Protected",
                visibleMutation: "Protected boundaries prevent silent widening across surfaces.",
                proofRelationship: "Consent and source context stay attached to the protected edge.",
                accessibilityPhrase: "Protected boundary names consent before cross-surface change.",
                reduceMotionEquivalent: "Static protected-boundary marker"
            )
        ]
    }
}
