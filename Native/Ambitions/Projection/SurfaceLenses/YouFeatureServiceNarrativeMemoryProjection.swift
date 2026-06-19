import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeNarrativeMemories(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> [YouNarrativeMemory] {
        var memories: [YouNarrativeMemory] = []

        if correctionCount > 0 {
            memories.append(
                YouNarrativeMemory(
                    id: "narrative-memory-corrections",
                    title: "You corrected how Ambitions reads something",
                    summary: "\(correctionCount) manual correction\(correctionCount == 1 ? "" : "s") can change future explanation language where the original artifact still exists.",
                    sourceLabel: "Manual corrections",
                    freshness: .current,
                    usedFor: "Used for Why Changed, recommendation wording, and future review prompts that cite the correction.",
                    sensitiveStatusLabel: "No sensitive inference",
                    actions: [
                        memoryAction(id: "narrative-correct", title: "Correct", statusLabel: "Use owning surface", detail: "Goal Detail, Capture, and explanation controls remain the supported correction paths.", state: .success),
                        memoryAction(id: "narrative-reject", title: "Reject reuse", statusLabel: "Review first", detail: "Rejection is not durable memory behavior here; it is a safe review boundary until receipts and delete coverage exist.", state: .warning),
                        memoryAction(id: "narrative-delete", title: "Delete", statusLabel: "Needs confirmation", detail: "Deletion is not claimed until safe review, confirmation, and undo coverage exist.", state: .warning),
                        memoryAction(id: "narrative-pause", title: "Pause use", statusLabel: "Review later", detail: "Pause is shown as a review need until a safe preference exists.", state: .warning)
                    ],
                    accessibilityLabel: "Narrative memory from corrections",
                    accessibilityValue: "Current. Manual corrections. Sensitive categories are not inferred.",
                    accessibilityHint: "Shows what this narrative memory uses and which correction, delete, and pause controls are safe or blocked."
                )
            )
        }

        if proofFeedbackCount > 0 {
            memories.append(
                YouNarrativeMemory(
                    id: "narrative-memory-proof",
                    title: "Recent proof can ground progress",
                    summary: "\(proofFeedbackCount) proof or feedback record\(proofFeedbackCount == 1 ? "" : "s") can make review language less intention-only.",
                    sourceLabel: "Proof and feedback",
                    freshness: .current,
                    usedFor: "Used for progress receipts, reviews, and deciding what still needs proof.",
                    sensitiveStatusLabel: "Private detail hidden",
                    actions: [
                        memoryAction(id: "narrative-proof-update", title: "Update this", statusLabel: "Use owning surface", detail: "Proof and feedback stay editable from Goal Detail, Capture, or Review context.", state: .default),
                        memoryAction(id: "narrative-proof-pause", title: "Pause use", statusLabel: "Review later", detail: "Pause is represented as a review need here until a safe preference exists.", state: .warning)
                    ],
                    accessibilityLabel: "Narrative memory from proof and feedback",
                    accessibilityValue: "Current. Private detail hidden in compact views.",
                    accessibilityHint: "Shows how proof and feedback can shape narrative memory without exposing sensitive detail."
                )
            )
        }

        if eventCount > 0 {
            memories.append(
                YouNarrativeMemory(
                    id: "narrative-memory-events",
                    title: "Recent actions can explain what changed",
                    summary: "\(eventCount) recent local event\(eventCount == 1 ? "" : "s") can support calm change explanations and recovery summaries.",
                    sourceLabel: "Event Ledger",
                    freshness: .current,
                    usedFor: "Used for Why Changed, recovery review, and receipt context.",
                    sensitiveStatusLabel: "Private by default",
                    actions: [
                        memoryAction(id: "narrative-events-inspect", title: "Inspect", statusLabel: "Available", detail: "Review happens through receipts, reviews, and owning surfaces.", state: .success),
                        memoryAction(id: "narrative-events-delete", title: "Delete", statusLabel: "Not exposed", detail: "Raw destructive deletion waits for a safe confirmation and undo boundary.", state: .warning)
                    ],
                    accessibilityLabel: "Narrative memory from recent actions",
                    accessibilityValue: "Current. Event Ledger. Private by default.",
                    accessibilityHint: "Shows how recent local actions can explain what changed and why deletion is not exposed here."
                )
            )
        }

        if memories.isEmpty {
            memories.append(
                YouNarrativeMemory(
                    id: "narrative-memory-empty",
                    title: "No narrative memory yet",
                    summary: openCaptures > 0 ? "Open captures may become reviewable memory after you place or archive them." : "Ambitions should stay evidence-light until local records, receipts, corrections, or reviews exist.",
                    sourceLabel: "Local records",
                    freshness: .basedOnOlderContext,
                    usedFor: "Used as a reminder not to pretend the app knows more than it does.",
                    sensitiveStatusLabel: "No sensitive inference",
                    actions: [
                        memoryAction(id: "narrative-empty-review", title: "Review", statusLabel: "Available later", detail: "Narrative memory appears only after explicit local evidence exists.", state: .default)
                    ],
                    accessibilityLabel: "No narrative memory yet",
                    accessibilityValue: "Based on Older Context. No sensitive category inferred.",
                    accessibilityHint: "Shows that Ambitions has no narrative memory to use yet."
                )
            )
        }

        return Array(memories.prefix(3))
    }

    func makeConservativeMemoryPatterns(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> [YouMemoryPattern] {
        var patterns: [YouMemoryPattern] = []

        if correctionCount > 0 {
            patterns.append(
                YouMemoryPattern(
                    id: "memory-pattern-corrections",
                    title: "Correction-shaped learning",
                    summary: "Only user-confirmed correction signals are treated as learning here.",
                    sourceLabel: "\(correctionCount) manual",
                    reviewLabel: "Review before reuse",
                    state: .success
                )
            )
        }

        if openCaptures > 0 {
            patterns.append(
                YouMemoryPattern(
                    id: "memory-pattern-open-captures",
                    title: "Loose items need a place",
                    summary: "Open captures may need routing before Ambitions should use them as context.",
                    sourceLabel: "\(openCaptures) open",
                    reviewLabel: "May Need Review",
                    state: .warning
                )
            )
        }

        if proofFeedbackCount + eventCount > 0 {
            patterns.append(
                YouMemoryPattern(
                    id: "memory-pattern-local-evidence",
                    title: "Local evidence exists",
                    summary: "Receipts, proof, feedback, or events can ground review language without becoming an automatic recommendation.",
                    sourceLabel: "\(proofFeedbackCount + eventCount) records",
                    reviewLabel: "Current",
                    state: .default
                )
            )
        }

        if patterns.isEmpty {
            patterns.append(
                YouMemoryPattern(
                    id: "memory-pattern-none",
                    title: "No pattern detected",
                    summary: "Ambitions should not invent a pattern when local evidence is thin.",
                    sourceLabel: "No evidence",
                    reviewLabel: "Based on Older Context",
                    state: .default
                )
            )
        }

        return Array(patterns.prefix(3))
    }

    func memoryAction(
        id: String,
        title: String,
        statusLabel: String,
        detail: String,
        state: AmbitionVisualState
    ) -> YouMemoryAction {
        YouMemoryAction(
            id: id,
            title: title,
            statusLabel: statusLabel,
            detail: detail,
            state: state
        )
    }

}
