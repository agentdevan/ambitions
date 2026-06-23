# AMB-1192 — Capture Route Graph + Composer

## Objective

Rebuild Capture as a typed global flow engine and full-screen Stage composer with stable field dominance, honest dictation behavior, and real local attachments.

## Covered Linear issues

- `AMB-1183`
- `AMB-1192`
- capture QA leaves attached to `AMB-1183`

## Covered repo issue IDs

- `AMB-ISSUE-0002`
- `AMB-ISSUE-0003`
- `AMB-ISSUE-0008`
- `AMB-ISSUE-0012`
- `AMB-ISSUE-0201`
- `AMB-ISSUE-0202`
- `AMB-ISSUE-0203`
- `AMB-ISSUE-0204`
- `AMB-ISSUE-0205`
- `AMB-ISSUE-1101`
- `AMB-ISSUE-1102`
- `AMB-ISSUE-1103`
- `AMB-ISSUE-1104`
- `AMB-ISSUE-1105`
- `AMB-ISSUE-1106`
- `AMB-ISSUE-1107`
- `AMB-ISSUE-1108`
- `AMB-ISSUE-1109`
- `AMB-ISSUE-1110`
- `AMB-ISSUE-1111`

## Product law

Capture is the global typed route graph and full-screen Stage composer. It is not a sheet, tab, floating card, or quick-capture wall.

## Architecture law

Entry points pass typed context and skip known steps. The flow is Composer -> optional depth -> Proposal -> Commit/Receipt. Goal + life area launch, one-step-goal proposal, and unresolved destination handling are required.

## Runtime honesty law

Use system keyboard dictation only. No dead mic. Attachments must be real local attachments. If a route is unavailable, hide or honestly disable it.

## Visual law

- full-screen Stage takeover
- no sheet
- no placeholder text
- no route UI while typing
- field-first atmospheric canvas
- stable field dominance during typing, routing, keyboard, and expansion

## Copy and iconography law

No `Task` language. No internal header/chips/copy such as `Open Field`, `Activated`, `Keyboard`, `Local read`, `Capture composer`, or `Inspectable route`.

## State model

- intent routes: free, goal seed, step seed, proof, time protect, note/thought, constraint/fixed point, attachment/context capture
- input remains primary while typing
- proposal and receipt are explicit states, not hidden side effects
- persistence must survive reload/reopen

## Required deletion / replacement

- replace half-screen sheet with full-screen composer
- remove route categories while typing
- remove internal chips/header copy
- replace dead mic path with native dictation or no mic control
- replace `Task` with Step / one-step goal model

## Required implementation

- typed Capture route graph
- full-screen Stage takeover
- no sheet
- no placeholder text
- no route UI while typing
- system keyboard dictation only
- real attachments
- dynamic flow Composer -> optional depth -> Proposal -> Commit/Receipt
- Goal + life area contextual launch
- one-step goal proposes Step
- unresolved destination can create goal, custom area, thought, free-floating step, Open Field
- receipt proof stitch
- persistence proof

## Files likely in scope

Codex must inspect current source before editing. Likely areas include Capture route graph, composer/container views, proposal/receipt flows, attachment handling, dictation affordances, contextual launchers, persistence paths, and `docs/qa/KNOWN_ISSUES.md`. Unexpected files must be justified in closeout.

## Files forbidden unless explicitly justified

- unrelated goal/time rebuild internals
- backend/cloud/LLM search code
- product canon files other than required cross-links

## Accessibility requirements

Ensure keyboard focus, dictation affordance clarity, VoiceOver labels/actions, and honest disabled states.

## Testing / audit requirements

Run build/tests plus string audit for banned capture terms, crash-free expansion path checks, attachment persistence checks, and route proof checks.

## Screenshot / device proof requirements

Provide collapsed, focused-with-keyboard, expanded, attachment tray, route preview, and mic granted/denied proof. Include persistence/reload proof.

## docs/qa/KNOWN_ISSUES.md update requirements

Update all Capture rows to reflect full-screen status, dictation honesty, copy cleanup, and proof state.

## Status ceiling

No device proof or persistence proof = Yellow maximum.

## Closeout template

```text
Status:
Bundle:
Linear issues covered:
Repo issue IDs covered:
Files changed:
Product law implemented:
Architecture law implemented:
Runtime honesty proof:
Validation run:
Validation not run:
Screenshots/videos:
Accessibility proof:
docs/qa/KNOWN_ISSUES.md updates:
Status ceiling:
Known risks:
Rollback plan:
```
