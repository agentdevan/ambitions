import Foundation

struct TodayActionClosureOutcomeState: Identifiable, Equatable {
    let closureState: ClosureState
    let title: String
    let meaning: String
    let receiptPreview: String
    let createsProof: Bool
    let isPrimary: Bool

    var id: String { closureState.rawValue }

    var consequenceLabel: String {
        switch closureState {
        case .completed:
            "Records the step as complete and attaches proof."
        case .stillCounts:
            "Saves the real progress as proof without pretending the original ask happened."
        case .moved:
            "Keeps the step alive for planning review."
        case .notNeeded, .skippedIntentionally:
            "Keeps the decision visible without treating it as a problem."
        case .blocked:
            "Keeps the blocker visible so recovery can shrink the ask."
        case .waiting:
            "Keeps the dependency visible without changing the plan silently."
        case .needsRecovery:
            "Marks recovery as available before any plan change."
        case .needsReview, .awaitingClosure:
            "Keeps the step open for one more look."
        case .now, .next, .later:
            "Keeps the timing decision visible for review."
        }
    }

    var recoveryPrompt: String {
        switch closureState {
        case .completed, .stillCounts:
            "Save proof and return to Today."
        case .moved:
            "Open Time only when you want to choose the new time."
        case .notNeeded, .skippedIntentionally:
            "Save the decision so it can be reversed later."
        case .blocked, .needsRecovery:
            "Reduce the ask or move the step before trying again."
        case .waiting:
            "Name what you are waiting on before changing the day."
        case .needsReview, .awaitingClosure:
            "Come back when the next detail is clear."
        case .now, .next, .later:
            "Review timing before changing anything else."
        }
    }
}

struct TodayActionClosureDiamondFacetState: Identifiable, Equatable {
    let id: String
    let title: String
    let summary: String
    let systemImage: String
}

struct TodayActionClosureDiamondState: Equatable {
    let title: String
    let summary: String
    let centerLabel: String
    let noSilentChangeLabel: String
    let facets: [TodayActionClosureDiamondFacetState]

    var visibleCopy: String {
        ([
            title,
            summary,
            centerLabel,
            noSilentChangeLabel
        ] + facets.flatMap { [$0.title, $0.summary] }).joined(separator: " ")
    }

    var accessibilityValue: String {
        facets.map { "\($0.title): \($0.summary)" }.joined(separator: ". ")
    }

    static let todayDefault = TodayActionClosureDiamondState(
        title: "Closure diamond",
        summary: "Choose the honest outcome, then Ambitions shows the consequence before anything changes.",
        centerLabel: "Close the loop",
        noSilentChangeLabel: "No silent changes",
        facets: [
            TodayActionClosureDiamondFacetState(
                id: "diamond.outcome",
                title: "Outcome",
                summary: "What actually happened.",
                systemImage: "checkmark.seal"
            ),
            TodayActionClosureDiamondFacetState(
                id: "diamond.consequence",
                title: "Consequence",
                summary: "What this means for Today.",
                systemImage: "arrow.triangle.branch"
            ),
            TodayActionClosureDiamondFacetState(
                id: "diamond.proof",
                title: "Proof",
                summary: "Evidence only when it is true.",
                systemImage: "doc.text"
            ),
            TodayActionClosureDiamondFacetState(
                id: "diamond.recovery",
                title: "Recovery",
                summary: "A smaller path if reality changed.",
                systemImage: "arrow.triangle.2.circlepath"
            ),
        ]
    )
}

struct TodayActionClosureSheetState: Identifiable, Equatable {
    let id: String
    let objectTitle: String
    let originalContext: String
    let prompt: String
    let privacyLabel: String
    let diamond: TodayActionClosureDiamondState
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
            diamond: .todayDefault,
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
            softPriorStepPrompt,
            recoveryReceiptLabel,
            diamond.visibleCopy,
        ] + outcomes.flatMap {
            [$0.title, $0.meaning, $0.consequenceLabel, $0.recoveryPrompt, $0.receiptPreview]
        }).joined(separator: " ")
    }

    var softPriorStepPrompt: String {
        "If the step changed shape, choose the closest honest outcome."
    }

    var recoveryReceiptLabel: String {
        "Receipt records the consequence you choose; Ambitions does not rearrange the day from this sheet."
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
