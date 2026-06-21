import Foundation

struct LifeShapeDerivation: Sendable, Hashable {
    let inputRefs: [LifeShapeInputRef]
    let ruleIDs: [LifeShapeRuleID]
    let clockDerivation: String
    let fallbackState: LifeShapeFallback?

    init(
        inputRefs: [LifeShapeInputRef],
        ruleIDs: [LifeShapeRuleID],
        clockDerivation: String,
        fallbackState: LifeShapeFallback? = nil
    ) {
        self.inputRefs = inputRefs
        self.ruleIDs = ruleIDs
        self.clockDerivation = clockDerivation.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fallbackState = fallbackState
    }

    var isCompleteForVisibleMark: Bool {
        inputRefs.isEmpty == false &&
            ruleIDs.isEmpty == false &&
            clockDerivation.isEmpty == false
    }
}
