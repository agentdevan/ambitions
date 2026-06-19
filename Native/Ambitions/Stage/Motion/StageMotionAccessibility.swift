import AmbitionsDesignSystem

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
    if value.contains("trace") || value.contains("return") || value.contains("next seam") {
        return .replayTrace
    }
    if value.contains("owner") || value.contains("consent") {
        return .inspection
    }
    return .relationship
}

extension MotionLaneItemState {
    var accessibilitySummary: String {
        "\(stateLabel). Source: \(source). Proof: \(proof). Receipt: \(receipt)"
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
