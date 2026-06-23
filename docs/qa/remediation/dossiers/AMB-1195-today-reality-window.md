# AMB-1195 — Today Reality Window / Action Gating

## Objective

Rebuild Today as a visually rich, actionable Reality Window with state-gated actions, real Step fit, proof-aware closure, and no CTA stack or internal rail copy.

## Covered Linear issues

- `AMB-1186` parent train
- `AMB-1195` execution bundle
- Today QA leaves under `AMB-1186`

## Product law

Today is the current day’s usable reality. It shows what can fit now and helps the user begin or recover truthfully. It is not a generic planner, task list, dashboard, CTA stack, or fake timeline.

## Architecture law

Today and Time share placement/protection truth. Today selects by fit across goal-linked and free-floating Steps equally. Capture/pathing/Time Fit resolve conflicts; Today does not hard-code fake priority rules.

## Runtime honesty law

No dead root actions. No Record Outcome without a started/proof-eligible Step. No Shape Time route to Time root. No Protect Window route to Time root. No fake current step. No nonsemantic icons.

## Visual law

Reality Window shows day context and token-in-window behavior for valid Start Here. No valid step shows recovery/calm Open Field state. Use semantic glyphs, protected boundary shading, current node behavior, and next fixed point anchor. Root is quiet and rich.

## Copy and iconography law

Almost no root copy: Step title, tiny state labels, accessible labels. Remove Start Here/Meridian toggle, `Live now` visible text, `No source change yet`, `All from work context`, and generic `Capture what changed`.

## State model

Required states: valid Step, no Step, too little time, low capacity, free-floating Step candidate, thought placement, protected window, proof-eligible Step, post-closure proof stitch, unavailable action.

## Required deletion / replacement

- Remove Start Here/Meridian toggle.
- Remove rail/status copy.
- Remove generic Capture CTA.
- Remove dead Review Context button.
- Remove nonsemantic timeline icons.
- Remove fixed CTA stack.

## Required implementation

- Reality Window root object.
- Token-in-window Step action.
- State-gated action cluster.
- Scoped Time Fit flow.
- Scoped Protect Window flow.
- Inspection glyph/long press for why-this/why-now/source/capacity.
- Closure affordance only when proof-eligible.
- Proof stitch after closure.
- Free-floating Step fit behavior.
- Thought placement behavior.

## Files likely in scope

- Today surface/views/models
- placement/protection shared model access
- closure/proof hooks
- Time Fit / Protect Window route contracts
- semantic glyph components
- tests and QA docs

## Files forbidden unless justified

- unrelated Goals/Time feature rewrites beyond route contracts
- capture composer internals except route hooks
- product truth files except cross-links

## Accessibility requirements

VoiceOver action for Begin, proof/closure, inspect, protect if available. Semantic labels for window, next fixed point, protected boundary, proof stitch. Dynamic Type and Reduce Motion support.

## Testing / audit requirements

State-gating tests, no dead action tests, route proof tests, closure mutation proof, persistence/reload proof, forbidden string audit.

## Screenshot / device proof requirements

Valid step, no-step recovery, too-little-time, low-capacity, free-floating step, thought placement, protect window, Time Fit route, closure proof, reload persistence, Light/Dark, accessibility notes.

## Known issues update

Update Today rows including `AMB-ISSUE-0001`, `0004`, `0005`, `0016`, `0101` through `0108`, `1001` through `1011`, and `1201`.

## Status ceiling

No state-gating proof = Runtime Yellow max. Any dead action = Red. No device screenshots = Visual Yellow max.

## Closeout template

Use the global closeout template from `docs/qa/remediation/2026-06-22-codex-remediation-law.md`.
