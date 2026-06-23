# AMB-1192 — Capture Route Graph + Composer

## Objective

Rebuild Capture as the global typed route graph and full-screen Stage composer for goals, steps, thoughts, proof, protected time, fixed points, constraints, and attachments.

## Covered Linear issues

- `AMB-1183` parent train
- `AMB-1192` execution bundle
- Capture QA leaves under `AMB-1183`

## Product law

Capture is global intake, not a root tab, half sheet, quick box, route-debug UI, or category wall. Capture is a flow of screens: Composer → optional context/depth → Proposal → Commit/Receipt.

## Architecture law

Implement typed route graph. Entry points pass intent/context and skip known steps. Required route families: free, goal seed, step seed, proof, time protect, note/thought, fixed point/constraint, attachment/context.

## Runtime honesty law

No dead mic. No fake route certainty. No fake capture save. No `Task` language. Runtime paths must create real local objects or honest unavailable states.

## Visual law

Full-screen Stage takeover. Field-first atmospheric canvas. No header copy such as `Open Field` or `review before save`. No internal chips such as `Activated`, `Keyboard`, `Local read`. No rounded explanatory composer block.

## Copy and iconography law

No placeholder text in the root field. Use spatial cursor, iconography, and one-time teaching. No visible taxonomy while composing. Receipt/edit may use human destinations such as goal, step, thought, protected time, or life area.

## State model

- global no-context capture opens blank composer,
- contextual life-area goal launch opens Capture with intent Goal and known life area,
- Proposal shows captured text, proposed destination, editable fields, accept/change/undo,
- unresolved route can create new goal, custom life area, thought, free-floating step, or Open Field item,
- system keyboard dictation is supported through native text input; no custom mic state machine in this train,
- attachments are real local capture attachments with role based on destination.

## Required deletion / replacement

- Delete half-screen bottom sheet presentation.
- Delete visible route/debug/internal chips.
- Delete dead custom mic affordance.
- Delete `Task` user-facing language.
- Delete category UI that overtakes the input field.

## Required implementation

- Full-screen Stage takeover.
- Typed route graph and context skipping.
- Native text input and keyboard dictation path.
- Attachment support.
- Proposal screen with local deterministic resolver.
- Receipt with ambient proof stitch, destination, change destination, undo, inspect.
- Persistence proof: create → reload/reopen store → object exists and can route/inspect.

## Files likely in scope

- `Native/Ambitions/Composer/**`
- Capture route/intake models
- Stage overlay / route host
- local persistence repositories for capture records
- design-system field/glyph components
- tests and QA docs

## Files forbidden unless justified

- unrelated Goals/Time/Today UI beyond typed launch hooks
- cloud/LLM services
- product truth files except cross-links

## Accessibility requirements

VoiceOver actions for dismiss/submit/change destination, Dynamic Type, keyboard focus, dictation compatibility, attachment controls, no gesture-only access.

## Testing / audit requirements

Build/tests, persistence tests, route graph tests, forbidden string audit, no-crash launch/submit proof.

## Screenshot / device proof requirements

Composer blank, contextual life-area goal launch, text entry, keyboard dictation path, attachment, Proposal, change destination, Receipt, reload persistence, Light/Dark, accessibility notes.

## Known issues update

Update Capture rows including `AMB-ISSUE-0002`, `0003`, `0008`, `0012`, `0201` through `0205`, and `1101` through `1111`.

## Status ceiling

No persistence proof = Runtime Yellow max. No device composer/keyboard proof = Visual Yellow max.

## Closeout template

Use the global closeout template from `docs/qa/remediation/2026-06-22-codex-remediation-law.md`.
