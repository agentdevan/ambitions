import Foundation

struct TodayActionClosureOutcomeState: Identifiable, Equatable {
    let closureState: ClosureState
    let title: String
    let meaning: String
    let receiptPreview: String
    let createsProof: Bool
    let isPrimary: Bool

    var id: String { closureState.rawValue }
}

struct TodayActionClosureSheetState: Identifiable, Equatable {
    let id: String
    let objectTitle: String
    let originalContext: String
    let prompt: String
    let privacyLabel: String
    let outcomes: [TodayActionClosureOutcomeState]
    let receiptPreviewTitle: String
    let confirmTitle: String
    let target: TodayActionTarget

    static func step(
        title: String,
        context: String,
        target: TodayActionTarget,
        privacyLabel: String = "Stored on this device"
    ) -> TodayActionClosureSheetState {
        TodayActionClosureSheetState(
            id: "today.action-closure.\(target.goalID ?? target.draftID ?? "today").\(target.stepID ?? "step")",
            objectTitle: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Today step" : title,
            originalContext: context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "From Today" : context,
            prompt: "What happened with this step?",
            privacyLabel: privacyLabel,
            outcomes: Self.defaultOutcomes,
            receiptPreviewTitle: "Receipt preview",
            confirmTitle: "Save closure",
            target: target
        )
    }

    var primaryOutcomes: [TodayActionClosureOutcomeState] {
        outcomes.filter(\.isPrimary)
    }

    var moreOutcomes: [TodayActionClosureOutcomeState] {
        outcomes.filter { $0.isPrimary == false }
    }

    var visibleCopy: String {
        ([
            objectTitle,
            originalContext,
            prompt,
            privacyLabel,
            receiptPreviewTitle,
            confirmTitle,
        ] + outcomes.flatMap { [$0.title, $0.meaning, $0.receiptPreview] }).joined(separator: " ")
    }

    private static let defaultOutcomes: [TodayActionClosureOutcomeState] = [
        TodayActionClosureOutcomeState(
            closureState: .completed,
            title: "Completed",
            meaning: "Finished as intended.",
            receiptPreview: "Completed · receipt saved",
            createsProof: true,
            isPrimary: true
        ),
        TodayActionClosureOutcomeState(
            closureState: .stillCounts,
            title: "Still Counts",
            meaning: "Meaningful progress happened differently.",
            receiptPreview: "Still Counts · saved as proof",
            createsProof: true,
            isPrimary: true
        ),
        TodayActionClosureOutcomeState(
            closureState: .moved,
            title: "Rescheduled",
            meaning: "Still matters, moved to another time.",
            receiptPreview: "Rescheduled · receipt saved",
            createsProof: false,
            isPrimary: true
        ),
        TodayActionClosureOutcomeState(
            closureState: .notNeeded,
            title: "Not needed",
            meaning: "Intentionally removed.",
            receiptPreview: "Not needed · receipt saved",
            createsProof: false,
            isPrimary: true
        ),
        TodayActionClosureOutcomeState(
            closureState: .blocked,
            title: "Blocked",
            meaning: "Cannot progress because something is in the way.",
            receiptPreview: "Blocked · recovery suggested",
            createsProof: false,
            isPrimary: false
        ),
        TodayActionClosureOutcomeState(
            closureState: .waiting,
            title: "Waiting",
            meaning: "Dependent on a person, time, info, place, or tool.",
            receiptPreview: "Waiting · dependency noted",
            createsProof: false,
            isPrimary: false
        ),
        TodayActionClosureOutcomeState(
            closureState: .needsRecovery,
            title: "Needs recovery",
            meaning: "The plan or day needs repair.",
            receiptPreview: "Needs recovery · review suggested",
            createsProof: false,
            isPrimary: false
        ),
        TodayActionClosureOutcomeState(
            closureState: .needsReview,
            title: "Needs review",
            meaning: "You are not sure yet.",
            receiptPreview: "Needs review · decision saved",
            createsProof: false,
            isPrimary: false
        ),
        TodayActionClosureOutcomeState(
            closureState: .awaitingClosure,
            title: "Review later",
            meaning: "Decide after one more look.",
            receiptPreview: "Review later · reminder kept visible",
            createsProof: false,
            isPrimary: false
        ),
    ]
}
