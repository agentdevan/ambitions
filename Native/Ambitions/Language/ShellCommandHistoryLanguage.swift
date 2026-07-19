extension ShellCommandPresentationContext {
    var historySubtitle: String {
        switch self {
        case .neutral: "Opened from Add something."
        case .quickCapture: "Saved without leaving the global quick action surface."
        case .createGoal: "Started from the goal setup path."
        case .recall: "Opened what Ambitions knows without showing raw history."
        case .recovery: "Returned to a calmer recovery posture."
        case .focus: "Returned to the current step session posture."
        case .time: "Opened the week-shaping context."
        }
    }
}
