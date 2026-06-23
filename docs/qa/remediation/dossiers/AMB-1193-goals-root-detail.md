# AMB-1193 — Goals Root / Detail Rebuild

## Objective

Rebuild Goals from diagnostic/report-card UI into a customizable Life Area Atlas with full-screen area detail and operational Goal Detail/path timeline.

## Covered Linear issues

- `AMB-1184` parent train
- `AMB-1193` execution bundle
- Goals QA leaves under `AMB-1184`

## Product law

Goals root is broad customizable Life Area Atlas. Life areas are the root object. Goal creation routes through global Capture with typed context. Goal Detail is profile + path operation surface + historical journal.

## Architecture law

Preserve valid domain/runtime models where useful. Delete/replace diagnostic report-card UI. No final `V2` naming after replacement. Capture owns goal seed creation flow; Goals owns area atlas, area detail, goal thread display, and goal operation/detail routes.

## Runtime honesty law

`+` must not crash. No fake goal creation. No fake Today relationship. No source/proof/context debug rows on root. Life areas are never “done”; goals can be accomplished.

## Visual law

Root is simple, modern, elegant, sparse-to-medium density. Default life areas: Work, Body, Home, People, Self, Future. Each can be renamed, hidden, reordered, assigned an icon, and customized. Use SF Symbols through glyph mapping. No root `GOALS · Constellation Atlas` copy.

## Copy and iconography law

Root copy is sparse: area names, tiny state labels only if needed, accessible labels. No explanatory paragraphs. No `Feeds Today` text; use minimal focus/highlight when a step is planned for Today.

## State model

Life areas contain goals, free-floating steps, thoughts, proof, receipts, sources/context, area settings, accomplished goals/history. Open Field is a valid non-junk holding area. Goal Detail path nodes include Proof, Step, Decision, Recovery, Pause, Accomplished.

## Required deletion / replacement

- Delete current diagnostic/report-card Goals root UI.
- Delete `Thread Focus` as root diagnostic console.
- Delete root source/proof/context/why-this rows.
- Delete duplicate creation affordances.
- Delete internal header naming.

## Required implementation

- Life Area Atlas root.
- Full-screen area detail.
- Goal thread glyphs / inline preview when elegant.
- Free-floating step beads/chips.
- Thought pool/sparks.
- Custom area create/edit/hide/reorder/icon.
- Capture launch for contextual goal creation.
- Full-screen Goal Detail path timeline with proof stitches, path editing, recovery, pause/resume, accomplish/archive, delete rules, thought attachment, future step editing, and Today/Time/Capture relationships.

## Files likely in scope

- Goals surface/views/models
- Goal detail / area detail routes
- Capture typed launch hooks
- local goal/step/thought/proof repositories
- design-system glyph components
- tests and QA docs

## Files forbidden unless justified

- unrelated Time calendar internals except route contracts
- shell architecture except navigation hooks
- cloud/LLM services

## Accessibility requirements

VoiceOver labels for areas, thread glyphs, path nodes, proof stitches, actions, custom area controls. Dynamic Type and Reduce Motion for path timeline are required.

## Testing / audit requirements

No-crash `+`, goal seed route through Capture, custom area persistence, goal lifecycle, path editing, proof append-correction, reload persistence, forbidden string audit.

## Screenshot / device proof requirements

Root atlas empty defaults, custom area create/edit, area detail, goal creation path, goal detail timeline, add proof, add future step, edit future step, pause/resume, accomplish/archive, Light/Dark, accessibility notes.

## Known issues update

Update Goals rows including `AMB-ISSUE-0401` through `0406` and `1301` through `1309`.

## Status ceiling

No no-crash proof = Red. No goal lifecycle/persistence proof = Runtime Yellow max. No device screenshots = Visual Yellow max.

## Closeout template

Use the global closeout template from `docs/qa/remediation/2026-06-22-codex-remediation-law.md`.
