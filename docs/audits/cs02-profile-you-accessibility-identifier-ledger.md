# CS02 Profile/You Accessibility Identifier Ledger

Status: CS02A accessibility identifier freeze ledger for global order `041`.
Date: 2026-05-02

## Policy

Accessibility identifiers are compatibility surfaces. CS02 must not rename or remove `profile.*` or `you.*` identifiers unless a later stage provides alias/deprecation proof and focused UI/test evidence.

## Identifier Families

| Identifier family | Current owner | Current role | Risk if renamed | CS02 action | Required proof before retirement |
| --- | --- | --- | --- | --- | --- |
| `profile.screen` | `ProfileScreen` | Root You/Profile screen automation anchor. | Red: UI automation and accessibility traversal may lose the surface. | Freeze. | UI smoke and replacement alias strategy. |
| `profile.retry-button` | `ProfileScreen` | Retry affordance in error/degraded state. | Yellow/Red: automation and fallback flows may fail. | Freeze. | Focused degraded-state test proof. |
| `profile.*-card`, `profile.*-row`, `profile.*-section` | `ProfileFeatureService`, `ProfileScreen` | Internal You surface cards/rows/sections and unit-test anchors. | Red if changed without test updates and alias plan. | Freeze. | `ProfileFeatureServiceTests`, UI smoke, and replacement map. |
| `profile.default-tab-picker` and related preference identifiers | Profile settings surface | Default-tab/preference control anchors. | Red: default-tab migration proof could become untestable. | Freeze. | Focused default-tab tests and UI automation proof. |
| `you.root`, `you.root-title`, `you.grouped-navigation-root` | `ProfileRootSurface` | Canonical You root surface anchors. | Yellow: top-level You proof may become unstable. | Preserve. | UI/unit proof if changed. |
| `you.row.*` | `ProfileRootSurface` | You grouped navigation row anchors. | Yellow: grouped navigation automation may fail. | Preserve. | UI/unit proof if changed. |

## Current Test Dependencies

- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift` depends on stable profile-family row IDs and product-contract ordering.
- `Native/AmbitionsUITests/AmbitionsUITests.swift` checks visible top-level `You` and absence of a top-level `Profile` tab.
- Shell and external routing tests depend on `.profile` resolving to the You surface.

## CS02 Freeze Decision

No accessibility identifiers are renamed in CS02A. CS02B may add proof that existing identifiers and visible labels coexist. CS02C may rename only after a replacement map and focused UI/test evidence exist.

## Result

Result: Green for CS02A. The identifier contract is frozen and prevents accidental automation/accessibility breakage.
