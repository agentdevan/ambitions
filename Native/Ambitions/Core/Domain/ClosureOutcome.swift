import Foundation

struct ClosureOutcome: Codable, Sendable, Equatable, Hashable, Identifiable {
    enum OptionGroup: String, Codable, Sendable, Equatable, Hashable {
        case defaultOption = "default"
        case advanced
    }

    let closureState: ClosureState
    let title: String
    let meaning: String
    let receiptPreview: String
    let createsProof: Bool
    let optionGroup: OptionGroup

    var id: String { closureState.rawValue }
    var isPrimary: Bool { optionGroup == .defaultOption }

    static let defaultOptions: [ClosureOutcome] = [
        ClosureOutcome(closureState: .completed, title: "Done", meaning: "Finished as intended.", receiptPreview: "Done · receipt saved", createsProof: true, optionGroup: .defaultOption),
        ClosureOutcome(closureState: .stillCounts, title: "Still counts", meaning: "Meaningful progress happened differently.", receiptPreview: "Still counts · saved as proof", createsProof: true, optionGroup: .defaultOption),
        ClosureOutcome(closureState: .moved, title: "Move it", meaning: "Still matters, moved to another time.", receiptPreview: "Move it · receipt saved", createsProof: false, optionGroup: .defaultOption),
        ClosureOutcome(closureState: .blocked, title: "Blocked", meaning: "Cannot progress because something is in the way.", receiptPreview: "Blocked · recovery suggested", createsProof: false, optionGroup: .defaultOption),
        ClosureOutcome(closureState: .notNeeded, title: "Not needed", meaning: "Intentionally removed.", receiptPreview: "Not needed · receipt saved", createsProof: false, optionGroup: .defaultOption)
    ]

    static let advancedOptions: [ClosureOutcome] = [
        ClosureOutcome(closureState: .waiting, title: "Waiting", meaning: "Dependent on a person, time, info, place, or tool.", receiptPreview: "Waiting · dependency noted", createsProof: false, optionGroup: .advanced),
        ClosureOutcome(closureState: .needsRecovery, title: "Needs recovery", meaning: "The plan or day needs repair.", receiptPreview: "Needs recovery · review suggested", createsProof: false, optionGroup: .advanced),
        ClosureOutcome(closureState: .needsReview, title: "Needs review", meaning: "You are not sure yet.", receiptPreview: "Needs review · decision saved", createsProof: false, optionGroup: .advanced),
        ClosureOutcome(closureState: .awaitingClosure, title: "Review later", meaning: "Decide after one more look.", receiptPreview: "Review later · reminder kept visible", createsProof: false, optionGroup: .advanced),
        ClosureOutcome(closureState: .skippedIntentionally, title: "Undo", meaning: "Reverse the latest local closure decision when it was not the right outcome.", receiptPreview: "Undo · local receipt review", createsProof: false, optionGroup: .advanced)
    ]

    static let allOptions: [ClosureOutcome] = defaultOptions + advancedOptions

    var proofEventKind: ProofEvent.Kind? {
        createsProof ? .closure : nil
    }

    var osClosureOutcome: AmbitionsOSClosureOutcome? {
        AmbitionsOSClosureOutcome(rawValue: closureState.rawValue)
    }
}
