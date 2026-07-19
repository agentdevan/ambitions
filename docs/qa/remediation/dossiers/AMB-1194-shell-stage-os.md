# AMB-1194 — Shell / Stage OS

## Objective

Rebuild shell chrome into full-bleed Stage OS behavior with icon-only root navigation, honest global access patterns, mature safe-area behavior, and semantic haptics/glyphs.

## Covered Linear issues

- `AMB-1185`
- `AMB-1194`
- shell and full-bleed QA leaves attached to `AMB-1185`

## Covered repo issue IDs

- `AMB-ISSUE-0006`
- `AMB-ISSUE-0007`
- `AMB-ISSUE-0806`
- `AMB-ISSUE-0901`
- `AMB-ISSUE-0902`
- `AMB-ISSUE-1011`
- `AMB-ISSUE-1701`
- `AMB-ISSUE-1702`
- `AMB-ISSUE-1703`
- `AMB-ISSUE-1704`
- `AMB-ISSUE-1705`
- `AMB-ISSUE-1706`
- `AMB-ISSUE-1707`
- `AMB-ISSUE-1708`
- `AMB-ISSUE-1709`

## Product law

Shell = Stage OS. It owns root navigation, route depth, Capture/Search access, global gestures, safe areas, motion, haptics, accessibility actions, and semantic glyphs.

## Architecture law

Use four coordinated icon-only root buttons with an invisible rail. Dock is root-only. Capture and Search are reached by gestures, accessibility actions, keyboard/App Shortcut paths, and teaching.

## Runtime honesty law

No fake Capture/Search controls. No decorative dock affordances that imply behavior they do not own. If a gesture path is unavailable, hide it or expose an honest unavailable path.

## Visual law

- four icon-only buttons
- invisible rail
- active accent icon only
- no dock labels
- no dock border
- full-bleed background
- no oversized root headers with internal object names

## Copy and iconography law

No root internal architecture names. Labels appear only for teaching, long press, or accessibility. Glyphs are semantic, not decorative.

## State model

- root surface = dock visible
- drilldown/global flow = dock hidden
- gesture handling follows system > accessibility > active controls > route gestures > shell gestures
- motion and haptics are semantic and state-aware

## Required deletion / replacement

- delete bordered dock chrome
- delete visible root labels
- delete persistent Capture/Search buttons
- delete header treatments exposing internal object names
- replace artificial safe-area shelves with true full-bleed layout

## Required implementation

- Shell = Stage OS
- four icon-only buttons
- invisible rail
- active accent icon only
- no dock labels
- no dock border
- no persistent Capture/Search buttons
- global Capture/Search gestures and accessibility alternatives
- gesture arena
- dock root-only
- full-bleed safe area
- semantic haptics
- semantic glyph registry

## Files likely in scope

Codex must inspect current source before editing. Likely areas include shell/navigation containers, root headers, gesture handling, safe-area composition, haptics/glyph mappings, App Shortcut or keyboard command hooks where present, and `docs/qa/KNOWN_ISSUES.md`. Unexpected files must be justified in closeout.

## Files forbidden unless explicitly justified

- unrelated domain-model rewrites
- search/capture implementation internals beyond shell access paths
- product canon files other than required cross-links

## Accessibility requirements

Provide VoiceOver labels/actions for root navigation, Capture/Search access, and selected state. Preserve Reduce Motion fallback and honest focus order.

## Testing / audit requirements

Run build/tests plus shell chrome audit, safe-area audit, gesture-path checks, accessibility action checks, and any keyboard/App Shortcut checks that exist.

## Screenshot / device proof requirements

Provide root and drilldown screenshot matrix, gesture proof, accessibility-action proof, keyboard/App Shortcut proof if implemented, and safe-area audit output.

## docs/qa/KNOWN_ISSUES.md update requirements

Update shell, full-bleed, and root-header rows with proof status and remaining risk.

## Status ceiling

Without device proof and safe-area audit, shell status cannot exceed Yellow.

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
