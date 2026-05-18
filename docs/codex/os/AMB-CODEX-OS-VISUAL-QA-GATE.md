# AMB-CODEX-OS-VISUAL-QA-GATE

Supporting note: This gate supports current Ambitions Codex work but does not override `docs/truth/`.

## Purpose

Require visual proof for UI changes that affect flagship surfaces.

## Check

1. Verify preview or screenshot evidence exists for the changed surface.
2. Consider a supported iPhone size, Dynamic Type, and Reduce Motion.
3. Check normal, empty, dense, loading, error, and recovery states where relevant.
4. Confirm the surface still has one primary object and one primary action.
5. Reject dashboard, card-stack, and generic task-app fallback layouts.

## Routes to existing support

- `premium-ios-visual-reviewer`
- `visual-qa-preview-fixture-reviewer`
- `accessibility-conformance-tester`
- `screenshot-visual-qa-reviewer`

## Non-claims

This gate does not prove runtime quality by itself.
