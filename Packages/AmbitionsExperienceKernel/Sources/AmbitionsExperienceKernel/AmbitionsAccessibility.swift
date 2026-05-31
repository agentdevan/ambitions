import Foundation

public enum AmbitionsAccessibility {
    public static func startHereSummary(title: String, whyNow: String, fit: AmbitionsStepFit, receiptCount: Int) -> String {
        "Start here. \(title). \(fitLabel(fit)). \(whyNow). \(receiptCount) proof receipts."
    }

    public static func meridianSummary(nodes: [MeridianNode], field: AmbitionsVisualFieldState) -> String {
        let current = nodes.first(where: { $0.isCurrent })?.title ?? "No current step"
        return "Reality Meridian. Current: \(current). \(fitLabel(field.fit))."
    }

    public static func receiptSummary(_ receipts: [AmbitionsProofReceipt]) -> String {
        receipts.isEmpty ? "No proof receipts shown" : "\(receipts.count) proof receipts shown"
    }

    public static func closureSummary(state: AmbitionsActionClosureState, title: String) -> String {
        "Closure: \(title). State: \(state.rawValue)."
    }

    public static func fitLabel(_ fit: AmbitionsStepFit) -> String {
        switch fit {
        case .fitsNow: return "Fits now"
        case .tightFit: return "Tight fit"
        case .needsBuffer: return "Needs buffer"
        case .protectedTime: return "Protected time"
        case .recoveryFirst: return "Recovery first"
        }
    }
}
