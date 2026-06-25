import AmbitionsDesignSystem

struct StageMotionAccessibilityPlan {
    let label: String
    let value: String
    let hint: String
    let semanticMirror: MotionSemanticModel

    static func current(
        projection: MotionCurrentProjection,
        reductionPolicy: StageMotionReductionPolicy
    ) -> StageMotionAccessibilityPlan {
        let mirror = MotionSemanticModel(projection: projection, reductionPolicy: reductionPolicy)
        return StageMotionAccessibilityPlan(
            label: "\(projection.crown.title). \(projection.crown.summary)",
            value: [
                projection.field.title,
                projection.field.changedObject,
                projection.field.changeState,
                projection.field.returnPoint,
                reductionPolicy.movementTextureDescription,
                mirror.accessibleConsequenceSummary,
            ].joined(separator: ". "),
            hint: "Movement stays attached to the changed object. \(reductionPolicy.rhythmSpacingDescription)",
            semanticMirror: mirror
        )
    }
}

func motionTraceRole(for label: String) -> ProofRelationshipTracePrimitiveRole {
    let value = label.lowercased()
    if value.contains("context") || value.contains("local") {
        return .source
    }
    if value.contains("history") || value.contains("still counts") {
        return .proof
    }
    if value.contains("review") {
        return .receipt
    }
    if value.contains("return") || value.contains("next step") {
        return .replayTrace
    }
    if value.contains("owner") || value.contains("consent") {
        return .inspection
    }
    return .relationship
}

extension MotionLaneItemState {
    var accessibilitySummary: String {
        "\(stateLabel). \(changedObject). \(changeState). \(returnPoint)"
    }
}

extension String {
    var motionSlug: String {
        lowercased()
            .replacingOccurrences(of: " / ", with: "-")
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "?", with: "")
            .replacingOccurrences(of: "/", with: "-")
    }
}
