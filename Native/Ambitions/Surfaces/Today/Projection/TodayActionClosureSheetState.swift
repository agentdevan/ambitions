import Foundation

struct TodayActionClosureOutcomeState: Identifiable, Equatable, Sendable {
    let closureState: ClosureState
    let title: String
    let meaning: String
    let receiptPreview: String
    let createsProof: Bool
    let isPrimary: Bool

    var id: String { closureState.rawValue }

    init(domainOutcome: ClosureOutcome) {
        closureState = domainOutcome.closureState
        title = domainOutcome.title
        meaning = domainOutcome.meaning
        receiptPreview = domainOutcome.receiptPreview
        createsProof = domainOutcome.createsProof
        isPrimary = domainOutcome.isPrimary
    }

    var consequenceLabel: String {
        switch closureState {
        case .completed:
            "Closes the step and attaches proof."
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

    var undoPreviewLabel: String {
        switch closureState {
        case .completed, .stillCounts:
            "Undo remains available from local receipt history."
        case .moved, .notNeeded, .skippedIntentionally, .blocked, .waiting, .needsRecovery, .needsReview, .awaitingClosure, .now, .next, .later:
            "Review remains available from local receipt history."
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

struct TodayActionClosureDiamondFacetState: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let summary: String
    let systemImage: String
}

struct TodayActionClosureDiamondState: Equatable, Sendable {
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
        title: "What changes",
        summary: "Choose the honest outcome, then Ambitions shows the consequence before saving.",
        centerLabel: "Save outcome",
        noSilentChangeLabel: "Changes stay reviewable",
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

struct TodayActionClosureSheetState: Identifiable, Equatable, Sendable {
    let id: String
    let objectTitle: String
    let startHereReceiptLabel: String
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
        startHereReceiptLabel: String = "Start Here review history",
        privacyLabel: String = "Stored on this device"
    ) -> TodayActionClosureSheetState {
        TodayActionClosureSheetState(
            id: "today.action-closure.\(target.goalID ?? target.draftID ?? "today").\(target.stepID ?? "step")",
            objectTitle: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Today step" : title,
            startHereReceiptLabel: startHereReceiptLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Start Here review history" : startHereReceiptLabel,
            originalContext: context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "From Today" : context,
            prompt: "What changed?",
            privacyLabel: privacyLabel,
            diamond: .todayDefault,
            outcomes: Self.defaultOutcomes,
            receiptPreviewTitle: "After saving",
            confirmTitle: "Save outcome",
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
            startHereReceiptLabel,
            originalContext,
            prompt,
            privacyLabel,
            receiptPreviewTitle,
            confirmTitle,
            softPriorStepPrompt,
            recoveryReceiptLabel,
        ] + outcomes.flatMap {
            [$0.title, $0.meaning, $0.consequenceLabel, $0.recoveryPrompt, $0.receiptPreview, $0.undoPreviewLabel]
        }).joined(separator: " ")
    }

    var softPriorStepPrompt: String {
        "Choose the closest honest outcome. Ambitions shows what changes before saving."
    }

    var recoveryReceiptLabel: String {
        "Saving the outcome updates Today, saves a local receipt when available, and does not rearrange the day silently."
    }

    private static let defaultOutcomes: [TodayActionClosureOutcomeState] =
        ClosureOutcome.allOptions.map(TodayActionClosureOutcomeState.init(domainOutcome:))
}
