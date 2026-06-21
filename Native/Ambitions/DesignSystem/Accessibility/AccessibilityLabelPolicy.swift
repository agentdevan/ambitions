import Foundation

struct AccessibilityLabelPolicy: Equatable, Sendable {
    let label: String
    let value: String
    let hint: String
    let focusPolicy: VoiceOverFocusPolicy
    let dynamicTypePolicy: DynamicTypePolicy
    let reduceMotionPolicy: ReduceMotionPolicy
    let reduceTransparencyPolicy: ReduceTransparencyPolicy
    let contrastPolicy: ContrastPolicy

    var announcement: String {
        [label, value].filter { $0.isEmpty == false }.joined(separator: ". ")
    }

    var isCanonSafe: Bool {
        let text = [label, value, hint, announcement].joined(separator: " ").lowercased()
        return ["dashboard", "chatbot", "ai", "score", "streak"].allSatisfy { text.contains($0) == false }
    }

    static func rootComposer(
        label: String,
        value: String,
        hint: String
    ) -> AccessibilityLabelPolicy {
        AccessibilityLabelPolicy(
            label: label,
            value: value,
            hint: hint,
            focusPolicy: .composer,
            dynamicTypePolicy: .surfaceDefault,
            reduceMotionPolicy: .calmStage,
            reduceTransparencyPolicy: .legibleSurface,
            contrastPolicy: .rootSurface
        )
    }

    static func primaryObject(
        label: String,
        value: String,
        hint: String
    ) -> AccessibilityLabelPolicy {
        AccessibilityLabelPolicy(
            label: label,
            value: value,
            hint: hint,
            focusPolicy: .primaryObject,
            dynamicTypePolicy: .primaryObject,
            reduceMotionPolicy: .objectMorph,
            reduceTransparencyPolicy: .legibleSurface,
            contrastPolicy: .primaryObject
        )
    }
}
