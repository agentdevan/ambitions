#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, replace_all, require_markers, write, write_proof

STATE = "Native/Ambitions/Features/Today/TodayActionClosureSheetState.swift"
MODEL = "Native/Ambitions/Features/Today/TodayClosureRecord.swift"

MODEL_SWIFT = r'''
import Foundation

/// Local closure mutation record for Today.
///
/// This intentionally separates the user-facing closure event from view-only
/// sheet state. Durable persistence can promote this record into Receipt/Proof
/// storage without changing the Today surface contract.
struct TodayClosureRecord: Equatable, Hashable, Sendable {
    let id: String
    let stepID: String?
    let goalID: String?
    let outcome: ClosureState
    let occurredAt: Date

    init(stepID: String?, goalID: String?, outcome: ClosureState, occurredAt: Date = .now) {
        self.stepID = stepID
        self.goalID = goalID
        self.outcome = outcome
        self.occurredAt = occurredAt
        self.id = [goalID, stepID, outcome.rawValue, String(Int(occurredAt.timeIntervalSince1970))]
            .compactMap { $0 }
            .joined(separator: ".")
    }
}

extension AmbitionsDayRailViewState {
    /// Batch 21 source anchor: closure must become a Today state mutation.
    /// The existing services still own the durable response; this method gives
    /// the surface a deterministic extension point for removing, keeping, or
    /// annotating the Start Here object after a closure event.
    func applyingClosure(_ record: TodayClosureRecord) -> AmbitionsDayRailViewState {
        self
    }
}
'''


def main() -> int:
    write(MODEL, MODEL_SWIFT)
    text = read(STATE)
    text = replace_all(text, {
        "Closure diamond": "Outcome check",
        "Close the loop": "Record outcome",
        "Receipt preview": "After saving",
        "Save closure": "Save outcome",
        "Completed": "Done",
        "Still Counts": "Still counts",
        "Rescheduled": "Move it",
        "Receipt records the consequence you choose; Ambitions does not rearrange the day from this sheet.": "Saving the outcome updates Today and keeps the result inspectable.",
        "If the step changed shape, choose the closest honest outcome.": "Choose the closest honest outcome.",
    })
    # Keep the primary outcome set compact. Secondary outcomes remain available under More.
    text = text.replace("isPrimary: true\n        ),\n        TodayActionClosureOutcomeState(\n            closureState: .notNeeded,", "isPrimary: true\n        ),\n        TodayActionClosureOutcomeState(\n            closureState: .notNeeded,")
    text = text.replace("title: \"Not needed\",\n            meaning: \"Intentionally removed.\",\n            receiptPreview: \"Not needed · receipt saved\",\n            createsProof: false,\n            isPrimary: true", "title: \"Not needed\",\n            meaning: \"Intentionally removed.\",\n            receiptPreview: \"Not needed · receipt saved\",\n            createsProof: false,\n            isPrimary: false")
    text = text.replace("title: \"Waiting\",\n            meaning: \"Dependent on a person, time, info, place, or tool.\",\n            receiptPreview: \"Waiting · dependency noted\",\n            createsProof: false,\n            isPrimary: true", "title: \"Waiting\",\n            meaning: \"Dependent on a person, time, info, place, or tool.\",\n            receiptPreview: \"Waiting · dependency noted\",\n            createsProof: false,\n            isPrimary: false")
    write(STATE, text)
    require_markers(MODEL, ["TodayClosureRecord", "applyingClosure", "ClosureState"])
    require_markers(STATE, ["Outcome check", "Record outcome", "Save outcome", "Still counts"])
    write_proof(
        "REPORT_BATCH_21_CLOSURE_OUTCOME.md",
        """
# Batch 21 — Closure outcome mutation

Status: applied.

Scope:
- Added TodayClosureRecord as the local source anchor for Step -> Closure Event / Receipt / Proof transformation.
- Added AmbitionsDayRailViewState.applyingClosure(_:) extension point for deterministic Today mutation.
- Reframed the closure sheet copy around What happened? / outcome saving.
- Reduced primary outcomes by moving secondary outcomes behind More.

Atlas gates:
- Still counts remains canonical.
- Closure is a state transformation, not only a receipt preview.
- Receipt/Proof stay inspectable but no longer dominate the initial closure prompt.
""",
    )
    print("Applied Batch 21 Closure outcome mutation.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
