# CS02 Profile/You Compatibility Seam Inventory

Status: CS02A compatibility inventory for global order `041`.
Date: 2026-05-02

## Scope

This inventory maps current `Profile` / `profile` / `You` seams before any rename. It supports the repaired CS02 staged plan:

- CS02A maps and freezes compatibility seams.
- CS02B proves visible `You` and old `profile` compatibility can coexist.
- CS02C may retire only proven-safe internal names later.

No production Swift, tests, routes, raw values, persistence, accessibility identifiers, or behavior were changed by this inventory.

## Discovery Commands

- `grep -R "AppTab.profile\\|\\.profile\\|ProfileScreen\\|ProfileFeatureService\\|ProfileModels\\|Profile" Native docs .codex | cat || true`
- `grep -R "profile\\|Profile\\|you\\|You" Native/AmbitionsTests Native/AmbitionsUITests docs/codex docs/canon .codex | cat || true`
- `grep -R "accessibilityIdentifier\\|accessibility(identifier" Native | cat || true`
- `grep -R "defaultTab\\|selectedTab\\|rawValue\\|AppTab" Native | cat || true`
- `find Native -iname "*Profile*" -o -iname "*You*" | sort`

## Inventory Summary

| Bucket | Current evidence | Risk | Recommended action | Owner |
| --- | --- | --- | --- | --- |
| User-facing copy that should say `You` | `AppTab.profile.title` returns `You`; shell tab label renders `You`; `ProfileRootSurface` root title is `You`; `ProfileScreen` navigation title is `You`. | Green | Preserve visible `You`; add/keep tests that reject a visible top-level `Profile` tab. | CS02B |
| Internal Swift type/file name that can remain `Profile` temporarily | `ProfileScreen`, `ProfileFeatureService`, `ProfileModels`, `ProfileViewModel`, `Native/Ambitions/Features/Profile`. | Yellow | Keep as compatibility/owner names; do not rename until route/test/accessibility proof says local retirement is safe. | CS02C or CS10 handoff |
| Route/raw value that must remain stable | `AppTab.profile.rawValue == "profile"`; `AppTab(rawValue:)` is used by external tab routes; `AppExternalRouting` emits `profile` for profile tab payloads. | Red if renamed now | Preserve raw value; CS02B may add focused proof. | CS02B |
| Persistence/default value that must support compatibility | `selectedTab`, preferred/default tab values, `AppTab(rawValue:)`, profile settings preferred tab tests. | Yellow/Red if touched | Do not change defaults or raw values in CS02A; prove old `profile` selected/default behavior before any migration. | CS02B |
| Accessibility identifier that must remain stable | `profile.screen`, `profile.*`, `you.root`, `you.row.*`, `you.grouped-navigation-root`. | Red if renamed without alias proof | Freeze identifiers; document any future replacement before code edits. | CS02B/CS02C |
| Test fixture or preview name | `AppShellNavigationTests`, `ExternalRoutingTests`, `ProfileFeatureServiceTests`, `AmbitionsUITests`, preview/internal references. | Yellow | Keep tests as compatibility proof; update only to add stronger assertions, not weaken expectations. | CS02B |
| Documentation/canon wording | CS02 prompt and global status previously called the seam a direct retirement. | Yellow fixed by CS02A | Reword as staged compatibility repair; do not claim retirement. | CS02A |
| External shortcut/widget/deep-link assumption | `ambitions://tab/profile`, external route payload tab values, widget/App Intent route docs from CS07. | Red if changed without proof | Preserve `profile` as external compatibility value. | CS02B |
| Dead/obsolete reference | No dead `Profile` seam is proven dead by CS02A discovery. | Yellow | Treat as live until proof says otherwise. | CS02C |
| Unsafe/unclear reference requiring owner | Detail row title `Profile` inside You; internal `profile-*` IDs; `profileNavigation()` private method. | Yellow | Do not rename in CS02A; classify for CS02B proof or CS02C retirement. | CS02B/CS02C |

## High-Risk Seam Ledger

| File path | Symbol/string found | Current role | Risk | Safe to rename now? | Required proof before rename |
| --- | --- | --- | --- | --- | --- |
| `Native/Ambitions/App/AppTab.swift` | `case profile`, raw value `profile`, title `You` | Canonical shell enum case and external/raw compatibility value with user-facing `You` display helper. | Red if raw/case deleted | No | Focused tests for raw parsing, shell labels, selected/default tab fallback, external route payloads, and no duplicate tab. |
| `Native/Ambitions/App/AmbitionsRootView.swift` | `.tag(AppTab.profile)`, `profileNavigation()`, `ProfileScreen` | Shell selection and You surface host. | Red if shell behavior changes | No | Shell navigation tests and UI smoke proving selected tab and visible `You` remain stable. |
| `Native/Ambitions/App/AppNavigation.swift` | `selectedTab`, `.profile`, `.insights -> .profile` | Route selection and legacy Insights compatibility target. | Red if target changes | No | Route tests for old and canonical destinations. |
| `Native/Ambitions/App/AppExternalRouting.swift` | `AppTab(rawValue:)`, `tab = profile` payload | Deep-link/external route compatibility. | Red if raw value changes | No | External route tests for `profile` and unknown fallback behavior. |
| `Native/Ambitions/Features/Profile/ProfileScreen.swift` | `ProfileScreen`, `profile.screen`, navigation title `You` | You surface implementation with stable internal owner/accessibility ID. | Yellow | No | Accessibility identifier inventory, UI tests, and CS02C local rename proof if attempted. |
| `Native/Ambitions/Features/Profile/ProfileRootSurface.swift` | `ProfileRootSurface`, `you.root-title`, `ProfileRootDetail.profile` | You root routing surface plus one internal detail destination. | Yellow | Partial, only after proof | CS02B should prove top-level `You`; PD15/SI11 may own any user-facing detail language refinement. |
| `Native/Ambitions/Features/Profile/ProfileFeatureService.swift` | `ProfileFeatureService`, `profile-*` row ids | You feature projection service and test fixture IDs. | Yellow | No | Focused ProfileFeatureService tests and accessibility compatibility plan. |
| `Native/Ambitions/Domain/ProfileModels.swift` | `Profile*` model names | Domain model owner names behind You. | Yellow | No | Full call-site proof and import/export/persistence review if any model crosses stored payloads. |
| `Native/AmbitionsTests/App/AppShellNavigationTests.swift` | `.profile`, `Profile` tab absence checks | Shell compatibility proof. | Green dependency | Do not weaken | Add stronger `profile` raw/display assertions in CS02B. |
| `Native/AmbitionsTests/App/ExternalRoutingTests.swift` | `.profile`, tab route assumptions | External route compatibility proof. | Green dependency | Do not weaken | Add explicit `ambitions://tab/profile` proof in CS02B if absent. |
| `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift` | `profile-*` IDs, Profile row/title checks | You/Profile feature contract proof. | Yellow dependency | Do not weaken | Keep current compatibility assertions; update only with canon-backed proof. |
| `Native/AmbitionsUITests/AmbitionsUITests.swift` | top-level `Profile` absence checks, You/Profile flows | UI automation compatibility. | Yellow | No | UI smoke or documented Yellow owner if not run. |

## CS02A Result

Result: Green for inventory creation. The original broad rename remains Red if attempted, so CS02 is repaired as a staged compatibility batch rather than a direct retirement.
