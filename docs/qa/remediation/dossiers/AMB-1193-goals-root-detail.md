# AMB-1193 — Goals Root / Detail

## Objective

Replace the current Goals root/detail implementation with a real Life Area Atlas root and operational goal-path detail surface.

## Covered Linear issues

- `AMB-1184`
- `AMB-1193`
- goals QA leaves attached to `AMB-1184`

## Covered repo issue IDs

- `AMB-ISSUE-0401`
- `AMB-ISSUE-0402`
- `AMB-ISSUE-0403`
- `AMB-ISSUE-0404`
- `AMB-ISSUE-0405`
- `AMB-ISSUE-0406`
- `AMB-ISSUE-1301`
- `AMB-ISSUE-1302`
- `AMB-ISSUE-1303`
- `AMB-ISSUE-1304`
- `AMB-ISSUE-1305`
- `AMB-ISSUE-1306`
- `AMB-ISSUE-1307`
- `AMB-ISSUE-1308`
- `AMB-ISSUE-1309`

## Product law

Goals root is a broad customizable Life Area Atlas. Goal Detail is a goal profile, operational path timeline, and historical journal.

## Architecture law

Life areas are the root object. Area drilldowns own goals, free-floating steps, thoughts, proof, receipts, context, settings, and history. Goal Detail owns the scrubbable path field, node history, future path editing, recovery, accomplishment, and Today/Time/Capture connections.

## Runtime honesty law

Do not leave the current diagnostic root recognizable and call it fixed. If a capability is not built yet, leave an honest unavailable state or keep the issue open.

## Visual law

- broad customizable Life Area Atlas
- visible default life areas
- sparse/medium root density
- full-screen area detail
- no dashboard, no report card, no diagnostic console
- detail path field is operational, not decorative

## Copy and iconography law

No root internal headers such as `GOALS · Constellation Atlas`. No `Thread Focus` diagnostic console language. Copy at root stays sparse; deeper explanation belongs in detail/inspection.

## State model

- life areas can be renamed, hidden, reordered, iconized, and customized
- Open Field is a valid holding area
- goal nodes: Proof, Step, Decision, Recovery, Pause, Accomplished
- past proof is append-corrected, not overwritten
- late proof may reflow path
- paused goals stay visible; accomplished goals preserve proof/history

## Required deletion / replacement

- delete diagnostic/report-card Goals root patterns
- delete `Thread Focus` diagnostic rows
- delete duplicate creation affordances
- replace static tiles/cards with Atlas behavior
- remove root header/object language exposing internals

## Required implementation

Root:

- broad customizable Life Area Atlas
- defaults: Work, Body, Home, People, Self, Future
- customizable names/icons/order/hide
- Open Field
- root sparse/medium, no dashboard, no generic list
- full-screen area detail

Detail:

- goal profile + operational path + historical journal
- horizontal/scrubbable path field
- proof/step/decision/recovery/pause/accomplished nodes
- append proof corrections
- late proof reflows path
- future path editing
- accomplished/share/create output
- Today/Time/Capture connections

## Files likely in scope

Codex must inspect current source before editing. Likely areas include Goals root/detail views, area models, path/detail interaction surfaces, create flows, crash path around `+`, and `docs/qa/KNOWN_ISSUES.md`. Unexpected files must be justified in closeout.

## Files forbidden unless explicitly justified

- unrelated Time/Search rebuild files
- backend/network/R2 files
- product canon files other than required cross-links

## Accessibility requirements

VoiceOver must understand life areas, current step focus, path nodes, and detail actions. Preserve Dynamic Type, reduced motion fallback, and semantic state mirrors.

## Testing / audit requirements

Run build/tests plus no-crash creation proof, state/path scenario checks, and language audit for internal root terms.

## Screenshot / device proof requirements

Provide current Goals root and goal-detail screenshots, creation recording, and scenario proof for life areas, active threads, step chains, recommended Step feeding Today, blocked/waiting/completed states.

## docs/qa/KNOWN_ISSUES.md update requirements

Update all Goals rows to reflect crash status, root-model replacement status, and proof state after the train.

## Status ceiling

Without crash-free device proof and route/detail proof, Goals remains Yellow or Red.

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
