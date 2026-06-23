# AMB-1198 — You Settings / Appearance / Privacy

## Objective

Make You read as a native settings/profile surface with real controls, live theme propagation, and Ambitions privacy/local-first cohesion.

## Covered Linear issues

- `AMB-1189`
- `AMB-1198`
- You QA leaves attached to `AMB-1189`

## Covered repo issue IDs

- `AMB-ISSUE-0601`
- `AMB-ISSUE-0602`
- `AMB-ISSUE-0603`
- `AMB-ISSUE-0604`
- `AMB-ISSUE-0605`
- `AMB-ISSUE-0606`
- `AMB-ISSUE-0607`
- `AMB-ISSUE-1501`
- `AMB-ISSUE-1502`
- `AMB-ISSUE-1503`
- `AMB-ISSUE-1504`
- `AMB-ISSUE-1505`

## Product law

You = Apple iOS Settings + ChatGPT iOS settings clarity + Ambitions privacy/local-first cohesion.

## Architecture law

Use grouped native settings rooted in Appearance, Capture, Life Areas, Privacy, Local Data, Sources, Receipts, Accessibility, and About. Every visible row opens real detail or an honest unavailable state.

## Runtime honesty law

Do not leave dead settings rows that pretend to be actionable. Appearance changes must propagate live or stay explicitly unresolved.

## Visual law

- top profile/local-status capsule
- grouped native settings rows
- no table dividers
- no bottom glow
- no dashboard treatment
- compact, premium native hierarchy

## Copy and iconography law

No root system-facing headers like `YOU · Profile and settings` or `Your System`. No explanatory trust-copy wall on root. Use compact, stateful row copy only when useful.

## State model

- Appearance = System / Light / Dark, live propagation
- settings rows are either real controls, drilldowns, or honest unavailable states
- privacy/local data/source/receipts/accessibility all have real state surfaces

## Required deletion / replacement

- delete divider-line stack
- delete bottom glow artifact
- delete root internal/system-facing headers
- replace dead settings rows with real detail or honest unavailable state
- remove relaunch requirement for theme propagation

## Required implementation

- Apple iOS Settings + ChatGPT iOS settings clarity + Ambitions cohesion
- grouped native settings
- top profile/local-status capsule
- rows: Appearance, Capture, Life Areas, Privacy, Local Data, Sources, Receipts, Accessibility, About
- no table dividers
- no bottom glow
- no dashboard
- every row opens real detail or honest unavailable state
- Appearance live propagation
- privacy/local data/source/receipt/accessibility surfaces

## Files likely in scope

Codex must inspect current source before editing. Likely areas include You root/detail settings flows, Appearance propagation, grouped row rendering, privacy/local data surfaces, and `docs/qa/KNOWN_ISSUES.md`. Unexpected files must be justified in closeout.

## Files forbidden unless explicitly justified

- unrelated capture/time/goals implementation files
- backend/network/R2 files
- product canon files other than required cross-links

## Accessibility requirements

Preserve Dynamic Type, VoiceOver row labels/actions, contrast, haptic preferences, and honest unavailable states.

## Testing / audit requirements

Run build/tests plus appearance live-propagation proof, settings-depth checks, and row-density/copy review.

## Screenshot / device proof requirements

Provide dark/light You root screenshots, theme change before/after without relaunch, settings detail screenshot set, and proof that rows open real detail or honest unavailable states.

## docs/qa/KNOWN_ISSUES.md update requirements

Update You rows for divider/glow removal, live theme behavior, settings actionability, and root-copy cleanup.

## Status ceiling

Without live-propagation proof and device screenshots, You remains Yellow.

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
