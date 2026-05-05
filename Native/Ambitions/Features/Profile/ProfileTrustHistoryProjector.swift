import AmbitionsDesignSystem
import Foundation

struct ProfileTrustHistoryProjector {
    struct Input: Sendable, Equatable {
        let receipts: [ActionReceiptDisplaySummary]
        let recentEvents: [EventLedgerEntry]
        let proofCount: Int
        let sourceReviewCount: Int
        let automationReviewCount: Int
        let permissionSummary: String
    }

    func project(_ input: Input) -> ProfileTrustHistoryCenterState {
        var items = input.receipts.map { receipt in
            ProfileTrustHistoryItem(
                id: "trust-history-receipt-\(receipt.id)",
                category: .receipts,
                title: receipt.title,
                summary: receipt.summary,
                sourceLabel: receipt.sourceDomain.trustHistorySourceLabel,
                reviewLabel: receipt.nextActionTitle ?? "Review where shown",
                privacyLabel: "Summary only",
                reversibilityLabel: receipt.undoAvailability.trustHistoryUndoLabel,
                state: receipt.trustHistoryVisualState
            )
        }

        items.append(proofItem(proofCount: input.proofCount))
        items.append(contentsOf: input.recentEvents.map(changeItem))
        items.append(sourceReviewItem(sourceReviewCount: input.sourceReviewCount))
        items.append(privacyItem)
        items.append(automationItem(automationReviewCount: input.automationReviewCount))

        return ProfileTrustHistoryCenterState(
            title: "Trust History",
            subtitle: "Receipts, proof, source review, changes, privacy, and automation boundaries in one local review center.",
            items: items,
            footer: "\(input.permissionSummary) This is a review surface, not a feed; raw logs and private detail stay behind owning surfaces."
        )
    }

    private func proofItem(proofCount: Int) -> ProfileTrustHistoryItem {
        ProfileTrustHistoryItem(
            id: "trust-history-proof",
            category: .proof,
            title: proofCount == 0 ? "No local proof yet" : "Local proof available",
            summary: proofCount == 0
                ? "Proof will appear here after an owning surface saves local evidence."
                : "\(proofCount) proof records can explain progress without turning proof into performance copy.",
            sourceLabel: "Source: Proof",
            reviewLabel: proofCount == 0 ? "Nothing to review yet" : "Review in owning surfaces",
            privacyLabel: "Detail hidden in compact views",
            reversibilityLabel: "Correction where supported",
            state: proofCount == 0 ? .default : .success
        )
    }

    private func changeItem(_ event: EventLedgerEntry) -> ProfileTrustHistoryItem {
        ProfileTrustHistoryItem(
            id: "trust-history-change-\(event.id)",
            category: .changes,
            title: event.title,
            summary: event.summary ?? "A local change was recorded for review context.",
            sourceLabel: event.source.trustHistorySourceLabel,
            reviewLabel: event.trust.requiresReview ? "Review source" : "Local record",
            privacyLabel: event.privacy.trustHistoryPrivacyLabel,
            reversibilityLabel: event.kind.trustHistoryReversibilityLabel,
            state: event.tone.trustHistoryVisualState
        )
    }

    private func sourceReviewItem(sourceReviewCount: Int) -> ProfileTrustHistoryItem {
        ProfileTrustHistoryItem(
            id: "trust-history-source-review",
            category: .sourceReview,
            title: sourceReviewCount == 0 ? "Source review is quiet" : "Source review available",
            summary: sourceReviewCount == 0
                ? "No local correction or review boundary currently needs attention."
                : "\(sourceReviewCount) local correction or review boundaries can explain why future suggestions change.",
            sourceLabel: "Source: Local records",
            reviewLabel: sourceReviewCount == 0 ? "No review needed" : "Review source",
            privacyLabel: "Review boundary only",
            reversibilityLabel: "User correction stays available where supported",
            state: sourceReviewCount == 0 ? .default : .warning
        )
    }

    private var privacyItem: ProfileTrustHistoryItem {
        ProfileTrustHistoryItem(
            id: "trust-history-privacy",
            category: .privacy,
            title: "Privacy labels",
            summary: "You controls compact memory, external-surface summaries, source-tied correction, and destructive-action boundaries.",
            sourceLabel: "Source: You",
            reviewLabel: "Review controls",
            privacyLabel: "Private details stay summarized",
            reversibilityLabel: "No destructive action from this center",
            state: .selected
        )
    }

    private func automationItem(automationReviewCount: Int) -> ProfileTrustHistoryItem {
        ProfileTrustHistoryItem(
            id: "trust-history-automation",
            category: .automation,
            title: "Automation history posture",
            summary: "Calendar writes, broad reflow, and destructive memory actions remain confirmation-gated or blocked.",
            sourceLabel: "Source: Automation policy",
            reviewLabel: "\(automationReviewCount) guarded boundaries",
            privacyLabel: "Permission posture only",
            reversibilityLabel: "Requires confirmation where risky",
            state: .warning
        )
    }
}

private extension ActionReceiptDisplaySummary {
    var trustHistoryVisualState: AmbitionVisualState {
        if safetyState == .safeFailure || safetyState == .externalUnavailable || safetyState == .confirmationRequired {
            return .warning
        }
        if correctionAvailability.isAvailable || undoAvailability.isAvailable {
            return .success
        }
        return .default
    }
}

private extension ActionReceiptSourceDomain {
    var trustHistorySourceLabel: String {
        switch self {
        case .today: "Source: Today"
        case .goals: "Source: Goals"
        case .capture: "Source: Capture"
        case .plan: "Source: Plan"
        case .you: "Source: You"
        case .reviews: "Source: Reviews"
        case .goalDetail: "Source: Goal Detail"
        case .commandPipeline: "Source: Command"
        case .eventLedger: "Source: Event Ledger"
        case .proof: "Source: Proof"
        case .resource: "Source: Resource"
        case .commitment: "Source: Commitment"
        case .calendar: "Source: Calendar boundary"
        case .exportImport: "Source: Export / import boundary"
        case .externalSurface: "Source: External surface"
        case .system: "Source: System"
        }
    }
}

private extension ActionReceiptUndoAvailability {
    var trustHistoryUndoLabel: String {
        switch self {
        case .availableLocal: "Undo available locally"
        case .requiresConfirmation: "Undo requires confirmation"
        case .unavailable: "Undo unavailable"
        case .unsafe: "Undo blocked as unsafe"
        case .notSupportedYet: "Undo not supported yet"
        }
    }
}

private extension EventLedgerSource {
    var trustHistorySourceLabel: String {
        switch self {
        case .today: "Source: Today"
        case .goals: "Source: Goals"
        case .capture: "Source: Capture"
        case .plan: "Source: Plan"
        case .you: "Source: You"
        case .memoryLens: "Source: Memory"
        case .goalEngine: "Source: Goals"
        case .planner: "Source: Plan"
        case .recovery: "Source: Recovery"
        case .recommendation: "Source: Recommendation"
        case .accessibilityNutrition: "Source: Accessibility review"
        case .sync: "Source: Sync boundary"
        case .exportImport: "Source: Export / import boundary"
        case .calendar: "Source: Calendar boundary"
        case .system: "Source: System"
        }
    }
}

private extension EventLedgerPrivacyClassification {
    var trustHistoryPrivacyLabel: String {
        switch self {
        case .standard: "Private by default"
        case .sensitive, .privateUserText: "Private detail hidden"
        case .calendarDerived: "Calendar-derived summary"
        case .syncMetadata: "Sync boundary summary"
        }
    }
}

private extension EventLedgerKind {
    var trustHistoryReversibilityLabel: String {
        "Review in owning surface"
    }
}

private extension EventLedgerTone {
    var trustHistoryVisualState: AmbitionVisualState {
        switch self {
        case .positive: .success
        case .recovering, .caution, .correction: .warning
        case .neutral: .default
        }
    }
}
