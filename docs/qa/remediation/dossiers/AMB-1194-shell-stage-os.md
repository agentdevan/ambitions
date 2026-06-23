# AMB-1194 — Shell / Stage OS

## Objective

Replace prototype shell chrome with Stage OS: four icon-only root buttons, global Capture/Search gestures, safe-area law, route-depth policy, motion, haptics, accessibility actions, and semantic glyphs.

## Covered Linear issues

- `AMB-1185` parent train
- `AMB-1194` execution bundle
- Shell / dock / header / full-bleed QA leaves under `AMB-1185`

## Product law

Shell is not a tab bar wrapper. Shell is Stage OS.

Visible root shell:

- four separate floating icon-only buttons,
- structurally coordinated by invisible rail,
- active state = accent icon only,
- no labels except onboarding / long press / accessibility,
- no bordered dock,
- no internal surface names,
- no persistent Capture/Search buttons.

## Architecture law

Centralize route-depth, safe-area, gesture, glyph, haptic, and accessibility behavior. Avoid per-surface shell hacks.

## Runtime honesty law

Global Capture/Search must remain accessible through explicit gestures and accessibility/system alternatives. No hidden-only critical functions.

## Visual law

Full-bleed Stage background. Interactive chrome respects true status/gesture zones. No artificial shelves. No root headers. No `GOALS · Constellation Atlas`, `TIME · LifeShape Field`, or `YOU · Profile and settings` visible on root.

## Copy and iconography law

Root dock is icon-only. Labels exist only in teaching, long press, and accessibility. Use semantic glyph registry with SF Symbols now.

## Required deletion / replacement

- Remove bordered dock container.
- Remove dock labels.
- Remove active rings/underlines/glows/capsules.
- Remove large root headers and internal object subtitles.
- Remove per-surface artificial safe-area shelves.

## Required implementation

- Four icon-only root buttons.
- Invisible structural rail for spacing, hit targets, focus order, and safe-area behavior.
- Stage gesture coordinator / equivalent centralized gesture arbitration.
- Long-press Stage Capture gesture.
- Pull-down Stage Search gesture.
- Keyboard/App Shortcut/VoiceOver action paths for Capture/Search.
- Dock visible only on root surfaces.
- Unified dismiss policy for non-root routes.
- Reduce Motion path and semantic haptics.

## Files likely in scope

- `Native/Ambitions/Stage/**`
- `Native/Ambitions/Stage/Chrome/**`
- root scene / navigation host files
- design-system glyph/motion/haptic files
- shell QA/audit scripts
- `docs/qa/KNOWN_ISSUES.md`

## Files forbidden unless justified

- runtime domain models unrelated to shell
- Capture/Goals/Time feature logic except access hooks
- product truth files except cross-links

## Accessibility requirements

VoiceOver labels for each root button, selected state, custom actions for Capture/Search, focus order, large hit targets, Reduce Motion alternatives, no color-only active state.

## Testing / audit requirements

Build/tests plus ShellChrome/SafeArea/ForbiddenLanguage/ReduceMotion audits where available.

## Screenshot / device proof requirements

Root screenshots for Today/Goals/Time/You in Light/Dark, dock hidden in drilldowns, Capture/Search route proof, safe-area proof, Dynamic Type proof, VoiceOver action notes.

## Known issues update

Update Shell rows including `AMB-ISSUE-0006`, `0007`, `0806`, `0901`, `0902`, `1011`, `1701` through `1709`.

## Status ceiling

No device screenshot matrix = Visual Yellow max. No accessibility action proof = Accessibility Yellow max.

## Closeout template

Use the global closeout template from `docs/qa/remediation/2026-06-22-codex-remediation-law.md`.
