#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, replace_all, require_markers, write, write_proof

MOTION = "Native/Ambitions/Features/Motion/MotionCurrentScreen.swift"
MODEL = "Native/Ambitions/Features/Motion/MotionCurrentAction.swift"

MODEL_SWIFT = r'''
import Foundation

/// Typed Motion action contract.
///
/// Motion is proof/progress/inspection, not analytics and not a passive ledger.
/// Root shell routing can map these actions to Today, Goals, Time, Trust, receipt,
/// or proof-detail destinations without adding a sixth tab.
enum MotionCurrentAction: Equatable, Hashable, Sendable {
    case inspectProof(String?)
    case openReceipt(String?)
    case openThread(String?)
    case openToday
    case openGoals
    case openTime
    case openTrust
}
'''


def main() -> int:
    write(MODEL, MODEL_SWIFT)
    text = read(MOTION)
    text = replace_all(text, {
        "A living field for proof, recovery, and return paths moving between Today, Goals, Time, and You.": "What moved, what needs recovery, and where to return.",
        "History lane": "What moved",
        "Origin visible": "History available",
        "Source, proof, and owning surface stay braided before the thread enters Today.": "Recent movement stays attached to the step or goal it came from.",
        "Recovery path": "What needs recovery",
        "Return lane": "Where to return",
        "Re-entry available": "Return available",
        "Open thread": "Re-enter thread",
        "Continuity Dock": "Continue",
        "Source, proof, receipt": "History available",
        "Context, history, and review remain inspectable before Motion changes.": "Source, proof, and receipt stay inspectable when you open the history detail.",
    })
    text = text.replace(
        '''        Button {
            NotificationCenter.default.post(
                name: Notification.Name("AmbitionsMotionCurrentActionSelected"),
                object: nil
            )
        } label: {
''',
        '''        Button {
            NotificationCenter.default.post(
                name: Notification.Name("AmbitionsMotionCurrentActionSelected"),
                object: title
            )
        } label: {
'''
    )
    write(MOTION, text)
    require_markers(MODEL, ["MotionCurrentAction", "openThread", "openTrust"])
    require_markers(MOTION, ["What moved", "What needs recovery", "Where to return", "Re-enter thread", "Continue"])
    write_proof(
        "REPORT_BATCH_23_MOTION_CURRENT.md",
        """
# Batch 23 — Motion Current functional rewrite

Status: applied.

Scope:
- Added a typed MotionCurrentAction routing contract.
- Reframed Motion first viewport around what moved, what needs recovery, and where to return.
- Restored canonical Re-enter thread copy expected by Motion proof.
- Changed Motion action notification payloads from nil to the selected action title as an interim route signal.
- Preserved Source / Proof / Receipt as inspectable history concepts instead of first-viewport ledger labels.

Atlas gates:
- Motion remains the fifth root tab and active object.
- Motion is not Pulse, analytics, feed, or dashboard.
- Motion actions are routeable and no longer semantically empty.
""",
    )
    print("Applied Batch 23 Motion Current functional rewrite.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
