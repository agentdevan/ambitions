# AMB-1191 — Theme / Design System Tokens

## Objective

Install the foundation design-system layer so Light/Dark/System rendering, semantic tokens, materials, motion, haptics, spacing, typography, and glyph semantics are real and reusable across every remediation train.

## Covered Linear issues

- `AMB-1182` parent train
- `AMB-1191` execution bundle
- Light Mode/theme QA leaves under `AMB-1182`

## Product law

Ambitions must render from a full design-system package/layer. Light Mode is native Apple luminous graphite-on-mist. Dark and Light come from one semantic token model. No hard-coded dark colors in runtime UI.

## Architecture law

Create or repair a real design-system layer for:

- semantic colors,
- materials,
- typography,
- spacing,
- motion,
- haptics,
- semantic glyph registry,
- preview matrices,
- audits where feasible.

Use environment or equivalent dependency injection so Light/Dark/System updates propagate live. Do not scatter direct color literals through surfaces.

## Runtime honesty law

Theme switching must update live. If a surface cannot yet render correctly in Light Mode, it must be called out as unresolved in `docs/qa/KNOWN_ISSUES.md`; do not hide or fake it.

## Visual law

Light Mode: mist, pearl, pale graphite, restrained celestial warmth, high contrast. No grey-on-grey. No washed-out dimming. Dark Mode must be rebuilt from the same semantic model.

## Copy and iconography law

No copy changes should be used to cover visual/system token defects. Iconography must flow through semantic glyph mapping where touched.

## Required deletion / replacement

- Remove scoped hard-coded dark colors encountered in primary UI paths.
- Remove local theme hacks that bypass global tokens.
- Remove theme state paths that require app relaunch to apply.

## Required implementation

- Design-system token families.
- Live Light/Dark/System propagation.
- Preview matrix covering core surfaces.
- Auditable references to no hard-coded dark colors in changed files.
- Theme settings integration path for You/Appearance.

## Files likely in scope

- `Native/Ambitions/DesignSystem/**`
- SwiftUI environment/token files
- appearance/theme settings files
- root surface token consumers
- QA/audit scripts if existing
- `docs/qa/KNOWN_ISSUES.md`

## Files forbidden unless justified

- product truth canon files, unless only linking this dossier
- unrelated runtime/domain model rewrites
- network/account/R2 code

## Accessibility requirements

Dynamic Type, Increase Contrast, Reduce Transparency, VoiceOver contrast, and color-not-alone state must be preserved where touched.

## Testing / audit requirements

Run available build/tests plus any token, hard-coded-color, Dynamic Type, and visual audit scripts. Document commands not run.

## Screenshot / device proof requirements

Light/Dark/System screenshots for Today, Goals, Time, You, Capture, Search, Closure, Appearance. Simulator screenshots cap visual status at Yellow; device proof is needed for Visual Green.

## Known issues update

Update all Light Mode/theme rows, including `AMB-ISSUE-1901` through `AMB-ISSUE-1906`, `AMB-ISSUE-1503`, and `AMB-ISSUE-0802` coverage.

## Status ceiling

No device proof = Visual Yellow max. Source/tests only = Runtime Yellow max.

## Closeout template

Use the global closeout template from `docs/qa/remediation/2026-06-22-codex-remediation-law.md`.
