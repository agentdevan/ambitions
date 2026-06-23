# AMB-1196 — Search Find / Act / Inspect

## Objective

Rebuild Search as a local-only full-screen Find / Act / Inspect surface with deterministic indexing, origin-biased ranking, actionable results, and proof-safe mutations.

## Covered Linear issues

- `AMB-1187` parent train
- `AMB-1196` execution bundle
- Search QA leaves under `AMB-1187`

## Product law

Search is not a shallow sheet, chatbot, generic command palette, or abstract result demo. It finds local Ambitions objects, navigates to them, exposes valid actions, and supports inspection without leaking internal route jargon.

## Architecture law

Build local deterministic SearchIndex first. Spotlight can mirror later. No cloud search and no hosted LLM query path. Search can pass query into Capture as prefilled input/context; Search does not create objects directly.

## Runtime honesty law

No abstract fake results. Every result opens a real object/context or shows honest unavailable state. Mutations are state-gated and receipt-backed.

## Visual law

Full-screen Stage takeover with soft origin context. Command field with optional tokens. Result rows are compact and object-specific, not cards.

## Copy and iconography law

Row anatomy: object glyph, title, source/area, state, one valid action, optional inspect glyph. No `Inspectable route`, `Handoff`, `owning surfaces`, implementation labels, or source-freshness copy on primary rows.

## State model

Search supports goals, steps, thoughts, proof, receipts, life areas, captures, time windows, settings/actions/system areas. Scope is global with origin-biased ranking. Empty state offers one contextual action.

## Required deletion / replacement

- Delete shallow sheet/card Search presentation.
- Delete abstract implementation-description result rows.
- Delete separate low-quality Search button if present.
- Delete internal routing labels from results.

## Required implementation

- Full-screen Search Stage takeover.
- Local deterministic SearchIndex repository.
- Origin-biased ranking.
- Command field with optional tokens.
- Real result families and navigation routes.
- State-gated action exposure via secondary gesture/action glyph.
- Capture handoff for query-to-capture.
- Proof/receipt search with user-facing detail.

## Files likely in scope

- Search overlay/surface files
- local search index models/repositories
- route registry
- Capture handoff hooks
- proof/receipt indexing adapters
- tests and QA docs

## Files forbidden unless justified

- cloud services / hosted LLM search
- unrelated surface rebuilds
- private life graph upload paths

## Accessibility requirements

Full keyboard navigation, VoiceOver labels/actions per result, Dynamic Type, Reduce Motion, no color-only state.

## Testing / audit requirements

Index tests, query/ranking tests, navigation proof, action proof, no-cloud audit, persistence/reload proof, forbidden string audit.

## Screenshot / device proof requirements

Search from multiple origins, populated results, empty state, result open, action exposure, Capture handoff, proof result, Light/Dark, accessibility notes.

## Known issues update

Update Search rows including `AMB-ISSUE-0701` and `1601` through `1605`.

## Status ceiling

No local index proof = Runtime Yellow max. Any cloud query path = Red. No device screenshots = Visual Yellow max.

## Closeout template

Use the global closeout template from `docs/qa/remediation/2026-06-22-codex-remediation-law.md`.
