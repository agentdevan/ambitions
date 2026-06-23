# AMB-1191 — Theme / Design System

## Objective

Install the full design-system package layer so theme, materials, spacing, typography, motion, haptics, and semantic glyph rendering come from one coherent token model.

## Covered Linear issues

- `AMB-1182`
- `AMB-1191`
- the Light Mode / theme QA leaves attached to `AMB-1182`

## Covered repo issue IDs

- `AMB-ISSUE-1901`
- `AMB-ISSUE-1902`
- `AMB-ISSUE-1903`
- `AMB-ISSUE-1905`
- `AMB-ISSUE-1906`
- `AMB-ISSUE-0802`

## Product law

Ambitions must render from a full design-system package layer. Light Mode is luminous graphite-on-mist. Dark and Light come from one semantic token model. Theme changes must apply live.

## Architecture law

Build semantic color tokens, material tokens, spacing tokens, typography tokens, motion tokens, haptic semantics, and a semantic glyph registry. Do not scatter hard-coded colors or local theme overrides through surfaces.

## Runtime honesty law

If Light Mode is still broken anywhere after source changes, leave the issue open and document it in `docs/qa/KNOWN_ISSUES.md`. Do not claim visual closure from source-only work.

## Visual law

Light Mode must be high-contrast, restrained, and premium. No washed-out grey. No dark objects stranded in Light Mode. Dark and Light are rebuilt together from one semantic model.

## Copy and iconography law

Do not use copy to explain theme defects away. Touched icons must route through semantic glyph mapping.

## State model

- Appearance mode = System / Light / Dark
- Theme propagation = live
- Surface state = semantic token driven, not literal-color driven
- Visual proof state = simulator or device, with device required for Visual Green

## Required deletion / replacement

- Delete hard-coded dark colors in touched runtime paths.
- Replace local color hacks with semantic tokens.
- Delete any close/reopen requirement for theme updates.

## Required implementation

- full design-system package layer
- semantic tokens
- Light Mode luminous graphite-on-mist
- Dark/Light from one token model
- no hard-coded dark colors
- no close/reopen theme update
- proof hooks for token audit, Dynamic Type, and route proof

## Files likely in scope

Codex must inspect current source before editing. Likely areas include `Native/Ambitions/DesignSystem/**`, theme environment files, appearance settings files, root surface token consumers, and `docs/qa/KNOWN_ISSUES.md`. Unexpected files must be justified in closeout.

## Files forbidden unless explicitly justified

- unrelated runtime/domain model rewrites
- backend/network/R2 files
- product canon files other than required cross-links

## Accessibility requirements

Preserve contrast, Dynamic Type, semantic state, Reduce Transparency, and VoiceOver clarity wherever theme changes land.

## Testing / audit requirements

Run available build/tests plus token audit, hard-coded-color audit, Dynamic Type checks, and route proof that navigation, Capture, and Search still work.

## Screenshot / device proof requirements

Provide Light, Dark, and System screenshots for Today, Goals, Time, You, Capture, Search, and Closure. Device proof is required for Visual Green.

## docs/qa/KNOWN_ISSUES.md update requirements

Update all theme-related rows to reflect source status, runtime proof status, and remaining Light Mode risk after the train.

## Status ceiling

Source/test only = Source Green / Runtime Yellow max. Simulator-only visual proof = Visual Yellow max.

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
