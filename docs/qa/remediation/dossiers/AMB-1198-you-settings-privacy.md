# AMB-1198 — You Settings / Appearance / Privacy

## Objective

Rebuild You into Apple iOS Settings structure + ChatGPT iOS settings clarity/compactness + Ambitions privacy/local-first cohesion.

## Covered Linear issues

- `AMB-1189` parent train
- `AMB-1198` execution bundle
- You QA leaves under `AMB-1189`

## Product law

You is a native Settings/Profile control surface backed by User System Profile. It is not a dashboard, product manifesto, diagnostic console, or status wall.

## Architecture law

You must consume global design-system tokens. Appearance changes must propagate live app-wide. Life Areas management mirrors Goals/Capture contextual creation. Privacy/local data/source/receipt settings must control real app state or show honest unavailable state.

## Runtime honesty law

Every visible row opens a real detail surface or honest unavailable state. No dead settings. No theme changes requiring app relaunch. No hard-coded dark colors.

## Visual law

Apple Settings grouping + ChatGPT compact clarity + Ambitions materials. No hard dividers, no bottom glow, no table-dashboard feel, no root paragraphs.

## Copy and iconography law

Row anatomy: SF Symbol/Ambitions glyph, title, optional short secondary state only if useful, chevron/native control. Minimal copy.

## Root hierarchy

- Appearance
- Capture
- Life Areas
- Privacy
- Local Data
- Sources
- Receipts
- Accessibility
- About

Small profile/local-status capsule may appear at top.

## Required deletion / replacement

- Remove root explanatory trust copy.
- Remove hard dividers and bottom glow artifact.
- Remove dead setting rows.
- Remove internal header language such as `YOU · Profile and settings` and `Your System`.
- Remove local theme hacks.

## Required implementation

- Native grouped settings root.
- Appearance System/Light/Dark with live propagation and real-token preview.
- Capture settings: input behavior, keyboard dictation, attachments, gesture teaching reset, permission state.
- Life Areas management: rename/hide/reorder/icon/custom areas.
- Privacy controls: local-only, permissions, data boundaries, export/delete, source access.
- Local Data: export, erase, store/migration status, diagnostics deeper.
- Sources: add/remove/disable/inspect.
- Receipts: searchable proof ledger.
- Accessibility: Dynamic Type, Reduce Motion, Increase Contrast, haptics, icon labels, VoiceOver actions.
- About: version/build/local-first/privacy/legal/diagnostics export.

## Files likely in scope

- You/settings views
- Appearance/theme settings
- Life Area settings
- privacy/local data/source/receipt settings
- accessibility settings
- design-system token consumers
- tests and QA docs

## Files forbidden unless justified

- unrelated root surface rebuilds
- network/account changes beyond displaying existing settings state
- product truth files except cross-links

## Accessibility requirements

Native control semantics, Dynamic Type, VoiceOver labels/actions, Reduce Motion, Increase Contrast, destructive action confirmation, export/delete safety.

## Testing / audit requirements

Every visible row opens real detail or honest unavailable state, Appearance live-switch, no hard-coded dark colors, no dead rows, export/delete safety, forbidden string audit.

## Screenshot / device proof requirements

You root, every detail row, Appearance live-switch, Light/Dark/System, no dividers/glow, Dynamic Type, VoiceOver notes, Reduce Motion.

## Known issues update

Update You rows including `AMB-ISSUE-0601` through `0607` and `1501` through `1505`.

## Status ceiling

Any dead row = Red. Theme relaunch requirement = Red. No device screenshots = Visual Yellow max.

## Closeout template

Use the global closeout template from `docs/qa/remediation/2026-06-22-codex-remediation-law.md`.
