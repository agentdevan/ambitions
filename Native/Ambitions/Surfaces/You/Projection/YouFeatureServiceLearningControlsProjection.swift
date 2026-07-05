import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeLocalLearningControls(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> [YouLocalLearningControl] {
        [
            YouLocalLearningControl(
                id: "local-learning-reset",
                title: "Reset learned corrections",
                summary: correctionCount == 0
                    ? "No correction learning is active yet; reset stays available as a review path when local teaching signals exist."
                    : "\(correctionCount) correction signal\(correctionCount == 1 ? "" : "s") can be reset, disabled, or deleted from the owning correction path after confirmation.",
                sourceLabel: "Manual corrections",
                availabilityLabel: correctionCount == 0 ? "Available when present" : "Confirmation required",
                receiptLabel: "Receipt required before future reuse changes",
                boundaryLabel: "Does not erase proof, captures, or raw Event Ledger history; changes stay source-tied and reversible",
                state: correctionCount == 0 ? .default : .warning,
                accessibilityLabel: "Reset learned corrections",
                accessibilityValue: correctionCount == 0 ? "No active correction learning. Local only." : "\(correctionCount) correction signals. Confirmation required.",
                accessibilityHint: "Explains the reset boundary for local correction learning without claiming broad deletion."
            ),
            YouLocalLearningControl(
                id: "local-learning-disable",
                title: "Disable learning from this signal",
                summary: "Learning reuse can be disabled only at the source-tied signal boundary; Ambitions keeps manual planning and correction available.",
                sourceLabel: "Source-tied learning",
                availabilityLabel: "Review first",
                receiptLabel: "Receipt records disabled reuse",
                boundaryLabel: "Local-only; no silent sync or hidden personal-context update",
                state: .warning,
                accessibilityLabel: "Disable learning from this signal",
                accessibilityValue: "Review first. Local-only.",
                accessibilityHint: "Explains that disabling learning is source-tied and confirmation-aware."
            ),
            YouLocalLearningControl(
                id: "local-learning-delete",
                title: "Delete a learning signal",
                summary: "Single-signal deletion remains confirmation-gated and receipt-aware. Broad destructive deletion is not claimed from this surface.",
                sourceLabel: "Correction or learning source",
                availabilityLabel: "Needs confirmation",
                receiptLabel: "Deletion receipt required",
                boundaryLabel: "No broad destructive delete claim",
                state: .warning,
                accessibilityLabel: "Delete a learning signal",
                accessibilityValue: "Needs confirmation. No broad destructive delete claim.",
                accessibilityHint: "Explains that deletion is bounded to a source-tied learning signal and does not claim full memory erasure."
            ),
            YouLocalLearningControl(
                id: "local-learning-export",
                title: "Export learning summary",
                summary: exportSummary(
                    eventCount: eventCount,
                    proofFeedbackCount: proofFeedbackCount,
                    correctionCount: correctionCount,
                    openCaptures: openCaptures
                ),
                sourceLabel: "Local summary",
                availabilityLabel: "Summary only",
                receiptLabel: "Export boundary shown before use",
                boundaryLabel: "No raw private text, sync payload, or external memory",
                state: .success,
                accessibilityLabel: "Export learning summary",
                accessibilityValue: "Summary only. No raw private text or external memory.",
                accessibilityHint: "Explains the export boundary for local learning summaries."
            )
        ]
    }

    func exportSummary(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> String {
        let signalCount = eventCount + proofFeedbackCount + correctionCount + openCaptures
        if signalCount == 0 {
            return "Export can summarize that no local learning signals are active, without creating sync or an external profile."
        }

        return "Export can summarize \(signalCount) local signal\(signalCount == 1 ? "" : "s") by category and boundary, without raw private text or broad account data."
    }

    func makeMemoryLensItems(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> [YouMemoryLensItem] {
        let stagedInputs = CaptureStagedInputProjection.supported(sourceSurface: "Capture")
        return [
            YouMemoryLensItem(
                id: "memory-lens-current-plan",
                title: "Current plan context",
                summary: proofFeedbackCount == 0
                    ? "Search can return to the current plan, but progress proof is still light."
                    : "\(proofFeedbackCount) proof or feedback records can ground plan recall.",
                sourceLabel: "Current plan",
                sourceAgeLabel: proofFeedbackCount == 0 ? "May need review" : "Current",
                whyRemembered: "Why remembered: current goals, proof, and feedback help recall return to Goals or Goal Detail instead of inventing a second history.",
                privacyShutterLabel: "Summary only",
                reviewLabel: "Safe for context recall",
                correctionLabel: "Correct in owning surface",
                rejectionLabel: "No durable memory claim",
                state: proofFeedbackCount == 0 ? .warning : .success,
                accessibilityLabel: "Search current plan context",
                accessibilityValue: proofFeedbackCount == 0 ? "May need review. Summary only." : "Current. Summary only.",
                accessibilityHint: "Shows source age, why remembered, privacy boundary, and correction posture for current plan recall."
            ),
            YouMemoryLensItem(
                id: "memory-lens-corrections",
                title: "Correction memory",
                summary: correctionCount == 0
                    ? "No active correction memory is available yet."
                    : "\(correctionCount) user-confirmed corrections can shape future explanation language.",
                sourceLabel: "Manual corrections",
                sourceAgeLabel: correctionCount == 0 ? "Based on older context" : "Current",
                whyRemembered: "Why remembered: user corrections can prevent repeated bad assumptions, but reuse stays reviewable.",
                privacyShutterLabel: "No sensitive inference",
                reviewLabel: "Review before durable memory",
                correctionLabel: "Correct or reject reuse",
                rejectionLabel: "Deletion waits for receipt proof",
                state: correctionCount == 0 ? .default : .warning,
                accessibilityLabel: "Search correction memory",
                accessibilityValue: correctionCount == 0 ? "Based on older context. No sensitive inference." : "Current. Review before durable memory.",
                accessibilityHint: "Shows correction, rejection, and deletion boundaries for correction memory."
            ),
            YouMemoryLensItem(
                id: "memory-lens-open-captures",
                title: "Open capture context",
                summary: openCaptures == 0
                    ? "No open captures need Search right now."
                    : "\(openCaptures) open captures may need placement before they influence planning.",
                sourceLabel: "Captured thought",
                sourceAgeLabel: openCaptures == 0 ? "Current" : "May need review",
                whyRemembered: "Why remembered: unresolved captures may explain what needs a place without becoming hidden work.",
                privacyShutterLabel: "Stored on this device",
                reviewLabel: "Place before stronger use",
                correctionLabel: "Edit in Capture",
                rejectionLabel: "Archive from Capture",
                state: openCaptures == 0 ? .success : .warning,
                accessibilityLabel: "Search open capture context",
                accessibilityValue: openCaptures == 0 ? "Current. Stored on this device." : "May need review. Stored on this device.",
                accessibilityHint: "Shows source age, privacy boundary, and placement controls for open capture recall."
            ),
            YouMemoryLensItem(
                id: "memory-lens-capture-staging",
                title: "Capture staging boundary",
                summary: "\(stagedInputs.count) staged input kind\(stagedInputs.count == 1 ? "" : "s") keep local privacy, export, redaction, and retention labels before save.",
                sourceLabel: "Capture",
                sourceAgeLabel: "Current",
                whyRemembered: "Why remembered: Capture staging should stay inspectable and local before it becomes a route or receipt.",
                privacyShutterLabel: "Stored on this device",
                reviewLabel: "Review before stronger use",
                correctionLabel: "Edit in Capture",
                rejectionLabel: "Archive from Capture",
                state: .success,
                accessibilityLabel: "Search capture staging boundary",
                accessibilityValue: "Current. Stored on this device. Review before stronger use.",
                accessibilityHint: "Shows the local staging policy for text, voice, image, share, proof, and context input kinds."
            )
        ]
    }

    func makeRuntimeInspectionItems(
        eventCount: Int,
        proofFeedbackCount: Int,
        correctionCount: Int,
        openCaptures: Int
    ) -> [YouRuntimeInspectionItem] {
        [
            YouRuntimeInspectionItem(
                id: "runtime-inspection-learned",
                kind: .learned,
                title: "What Ambitions learned",
                summary: correctionCount == 0
                    ? "No local learning signal is saved yet."
                    : "\(correctionCount) correction signal\(correctionCount == 1 ? "" : "s") can teach Ambitions how to reject or reuse similar recommendations.",
                sourceLabel: "Local learning",
                controlLabel: correctionCount == 0 ? "Available when present" : "Reset or delete in Search Ambitions",
                privacyLabel: "Local and source-tied",
                state: correctionCount == 0 ? .default : .success,
                accessibilityLabel: "What Ambitions learned",
                accessibilityValue: correctionCount == 0 ? "No local learning signal saved yet. Local and source-tied." : "\(correctionCount) correction signals. Local learning, local and source-tied.",
                accessibilityHint: "Shows learned local correction state and where reuse can be reset, deleted, corrected, or rejected."
            ),
            YouRuntimeInspectionItem(
                id: "runtime-inspection-used",
                kind: .used,
                title: "What Ambitions used",
                summary: proofFeedbackCount + eventCount == 0
                    ? "No proof, feedback, or recent event records are available for current explanations."
                    : "\(proofFeedbackCount + eventCount) proof, feedback, or event record\(proofFeedbackCount + eventCount == 1 ? "" : "s") can ground reviews, receipts, and Why Changed.",
                sourceLabel: "Proof, feedback, Event Ledger",
                controlLabel: "Inspect in owning surfaces",
                privacyLabel: "Summary first",
                state: proofFeedbackCount + eventCount == 0 ? .warning : .success,
                accessibilityLabel: "What Ambitions used",
                accessibilityValue: proofFeedbackCount + eventCount == 0 ? "No current proof, feedback, or recent event records. Summary first." : "\(proofFeedbackCount + eventCount) local records. Summary first.",
                accessibilityHint: "Shows the local records used for review and change explanations."
            ),
            YouRuntimeInspectionItem(
                id: "runtime-inspection-ignored",
                kind: .ignored,
                title: "What Ambitions ignored or rejected",
                summary: openCaptures == 0
                    ? "No open captures are being held back from stronger memory use right now."
                    : "\(openCaptures) open capture\(openCaptures == 1 ? "" : "s") stay held until you place, edit, or archive them.",
                sourceLabel: "Capture review boundary",
                controlLabel: "Place, edit, archive, or reject reuse",
                privacyLabel: "No hidden work",
                state: openCaptures == 0 ? .success : .warning,
                accessibilityLabel: "What Ambitions ignored or rejected",
                accessibilityValue: openCaptures == 0 ? "No held open captures. No hidden work." : "\(openCaptures) open captures held for review. No hidden work.",
                accessibilityHint: "Shows what local context is being held back or rejected before stronger memory use."
            ),
            YouRuntimeInspectionItem(
                id: "runtime-inspection-changed",
                kind: .changed,
                title: "What Ambitions changed",
                summary: eventCount == 0
                    ? "No recent local change events are available yet."
                    : "\(eventCount) recent event\(eventCount == 1 ? "" : "s") can explain what changed without exposing raw history here.",
                sourceLabel: "Event Ledger",
                controlLabel: "Review receipt or owning surface",
                privacyLabel: "Private by default",
                state: eventCount == 0 ? .default : .success,
                accessibilityLabel: "What Ambitions changed",
                accessibilityValue: eventCount == 0 ? "No recent local change events. Private by default." : "\(eventCount) recent local change events. Private by default.",
                accessibilityHint: "Shows recent change state and keeps destructive controls outside this inspection row."
            )
        ]
    }

}
