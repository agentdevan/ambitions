# CS02 Profile/You Compatibility Contract Ledger

Status: CS02A compatibility contract ledger for global order `041`.
Date: 2026-05-02

## Contract

Ambitions may show the user-facing surface as `You` while preserving internal and raw compatibility seams named `Profile` / `profile`. A rename is not a compatibility improvement unless it preserves routes, defaults, accessibility identifiers, tests, external payloads, and rollback.

## Seam Contracts

| Symbol/string | File path | Current role | User-facing or internal | Route/raw-value status | Persistence/defaults status | Accessibility identifier status | Test dependency status | External/deep-link/shortcut/widget status | Safe action now | Unsafe action | Required proof before retirement | Owner batch |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `AppTab.profile` / `profile` | `Native/Ambitions/App/AppTab.swift` | Shell tab enum case and raw value | Internal/raw; display helper returns `You` | Stable compatibility value | May be used by selected/default tab preferences | Indirect via shell/UI tests | Shell and external routing tests | Deep links and payloads may carry `profile` | Keep raw value; test display title | Renaming case/raw value or deleting old value | Raw parser, shell, default-tab, external route, UI smoke proof | CS02B |
| `You` title | `Native/Ambitions/App/AppTab.swift`, `Native/Ambitions/App/AmbitionsRootView.swift`, Profile feature files | User-facing product label | User-facing | Not a raw value | Not persisted as raw value | Visible label can be used by UI tests | Shell/UI tests | None as raw payload | Preserve | Regress visible tab to `Profile` | Shell/UI proof | CS02B |
| `profileNavigation()` | `Native/Ambitions/App/AmbitionsRootView.swift` | Private shell helper | Internal | Not raw itself, hosts `.profile` route | None directly | None directly | Shell tests | None directly | Leave or rename only locally after proof | Broad rename with behavior changes | Build/shell tests and diff boundary | CS02C |
| `ProfileScreen` | `Native/Ambitions/Features/Profile/ProfileScreen.swift` | You surface view owner | Internal type; visible title is `You` | None directly | User settings/defaults rendered inside | `profile.screen` root id | UI and unit tests | None directly | Keep | Rename without accessibility/test alias proof | Build, UI smoke, Profile tests, identifier plan | CS02C |
| `ProfileFeatureService` | `Native/Ambitions/Features/Profile/ProfileFeatureService.swift` | You projection/service owner | Internal | None directly | May project default tab/settings rows | Produces `profile-*` row ids | `ProfileFeatureServiceTests` | None directly | Keep | Rename/delete ids or symbols broadly | Focused service tests and accessibility ledger | CS02C |
| `ProfileModels` and `Profile*` models | `Native/Ambitions/Domain/ProfileModels.swift` | Domain models behind You | Internal/domain | Unknown until proven | Possible import/export or persistence adjacency must be reviewed before rename | None directly | Profile/unit tests | Unknown external assumptions until proven | Keep | Rename as product-language cleanup | Full call-site, persistence/import/export, route, and tests proof | CS02C |
| `profile.screen` and `profile.*` identifiers | `Native/Ambitions/Features/Profile/ProfileScreen.swift`, `ProfileFeatureService.swift` | UI automation/accessibility compatibility IDs | Internal/accessibility surface | Not route raw values | Not persistence values | Stable IDs | UI/unit tests may depend on them | Automation may depend on them | Freeze | Rename or remove without alias/deprecation proof | Identifier inventory, focused UI/unit proof, replacement map | CS02B/CS02C |
| `you.root`, `you.row.*` identifiers | `Native/Ambitions/Features/Profile/ProfileRootSurface.swift` | Canonical You root identifiers | Internal/accessibility surface | Not route raw values | None directly | Stable IDs | UI/unit tests may depend on them | None directly | Keep | Collapse into `profile.*` or duplicate destinations | UI/unit proof if changed | CS02B |
| `ambitions://tab/profile` | `Native/Ambitions/App/AppExternalRouting.swift`, tests | External route to You/Profile surface | External/raw | Must remain supported | May initialize selected tab | None directly | External routing tests | Deep-link compatibility | Preserve and test | Change to `you` only | External route compatibility and fallback tests | CS02B |
| `preferredTab` / default tab rows | Profile feature tests and settings UI | User setting/default behavior | User-facing setting with internal raw backing | Depends on `AppTab` raw parsing | Must support existing old value if stored | Row identifiers stable | Profile tests | None directly | Preserve | Change stored value semantics without migration | Default-tab migration proof and focused tests | CS02B |

## Compatibility Rules

- `profile` remains the compatibility raw value until a later batch proves a migration shim and rollback path.
- `You` remains the user-facing label.
- `Profile` internal owner names may remain intentionally and are not product-language regressions by themselves.
- Accessibility identifiers are frozen unless a later batch creates alias/deprecation proof.
- CS02C may retire only seams that are local, non-route, non-persistent, non-accessibility, non-external, and covered by tests.

## Rollback Plan

- CS02A docs/control changes can be reverted as a documentation repair.
- CS02B test/helper changes must preserve `profile` parsing and visible `You`; rollback must restore any removed assertion.
- CS02C rename attempts must be reversible by restoring old names and leaving compatibility aliases until all consumers are proven migrated.

## Result

Result: Green for CS02A. The contract blocks direct retirement and allows only staged compatibility proof.
