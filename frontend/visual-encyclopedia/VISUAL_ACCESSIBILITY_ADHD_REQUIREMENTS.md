# Visual Accessibility And ADHD Requirements

Status: Active intended requirement set

These are recipe requirements, not implementation proof.

## Review Checklist

This file is the visual review lens. It is intentionally shorter than the behavior canon so it can be used during lock review without duplicating the full law set line-for-line.

## What To Check

- The surface keeps one dominant action at rest.
- Capture never expands into more than three visible choices.
- State remains readable without color, glow, or motion tricks.
- Metadata collapses before the primary action does.
- "Needs a Place" and recovery paths read as success, not failure.
- VoiceOver, Dynamic Type, Reduce Motion, and Reduce Transparency all preserve the same object meaning.
- Destructive or automation-changing actions stay previewable.

## What To Reject

- Any surface that needs gamified pressure or shame language to motivate the user.
- Any surface that hides source, proof, or correction behind decoration.
- Any surface that would still make sense if pasted into a generic productivity app.

## Proof Boundary

This file is a checklist for visual and accessibility review. It does not prove conformance.
