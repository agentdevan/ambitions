import Foundation

struct ClosureOutcome: Codable, Sendable, Equatable, Hashable, Identifiable {
    enum OptionGroup: String, Codable, Sendable, Equatable, Hashable {
        case defaultOption = "default"
        case advanced
    }

    enum ProofClassification: String, Codable, Sendable, Equatable, Hashable {
        case createsClosureProofEvent = "creates_closure_proof_event"
        case receiptOnlyMutationProof = "receipt_only_mutation_proof"
    }

    enum ReceiptClassification: String, Codable, Sendable, Equatable, Hashable {
        case savesLocalReceipt = "saves_local_receipt"
        case reviewOnlyLocalReceipt = "review_only_local_receipt"
    }

    enum UndoClassification: String, Codable, Sendable, Equatable, Hashable {
        case availableFromLocalReceipt = "available_from_local_receipt"
        case reviewFromLocalReceipt = "review_from_local_receipt"

        var isAvailable: Bool {
            self == .availableFromLocalReceipt
        }
    }

    struct MutationClassification: Codable, Sendable, Equatable, Hashable {
        let proof: ProofClassification
        let receipt: ReceiptClassification
        let undo: UndoClassification
        let localOnly: Bool

        var requiresSavedReceipt: Bool {
            receipt == .savesLocalReceipt
        }
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
        ClosureOutcome(closureState: .waiting, title: "Waiting", meaning: "Dependent on a person, time, info, place, or tool.", receiptPreview: "Waiting · dependency noted", createsProof: false, optionGroup: .defaultOption),
        ClosureOutcome(closureState: .blocked, title: "Blocked", meaning: "Cannot progress because something is in the way.", receiptPreview: "Blocked · recovery suggested", createsProof: false, optionGroup: .defaultOption),
        ClosureOutcome(closureState: .notNeeded, title: "Not needed", meaning: "Intentionally removed.", receiptPreview: "Not needed · receipt saved", createsProof: false, optionGroup: .defaultOption)
    ]

    static let advancedOptions: [ClosureOutcome] = [
        ClosureOutcome(closureState: .needsRecovery, title: "Needs recovery", meaning: "The plan or day needs repair.", receiptPreview: "Needs recovery · review suggested", createsProof: false, optionGroup: .advanced),
        ClosureOutcome(closureState: .needsReview, title: "Needs review", meaning: "You are not sure yet.", receiptPreview: "Needs review · decision saved", createsProof: false, optionGroup: .advanced),
        ClosureOutcome(closureState: .awaitingClosure, title: "Review later", meaning: "Decide after one more look.", receiptPreview: "Review later · reminder kept visible", createsProof: false, optionGroup: .advanced),
        ClosureOutcome(closureState: .skippedIntentionally, title: "Undo", meaning: "Reverse the latest local closure decision when it was not the right outcome.", receiptPreview: "Undo · local receipt review", createsProof: false, optionGroup: .advanced)
    ]

    static let allOptions: [ClosureOutcome] = defaultOptions + advancedOptions

    static func option(for closureState: ClosureState) -> ClosureOutcome? {
        allOptions.first { $0.closureState == closureState }
    }

    var proofEventKind: ProofEvent.Kind? {
        createsProof ? .closure : nil
    }

    var mutationClassification: MutationClassification {
        MutationClassification(
            proof: createsProof ? .createsClosureProofEvent : .receiptOnlyMutationProof,
            receipt: optionGroup == .defaultOption ? .savesLocalReceipt : .reviewOnlyLocalReceipt,
            undo: closureState.undoAvailability.isAvailable ? .availableFromLocalReceipt : .reviewFromLocalReceipt,
            localOnly: true
        )
    }

    var osClosureOutcome: AmbitionsOSClosureOutcome? {
        AmbitionsOSClosureOutcome(rawValue: closureState.rawValue)
    }
}
