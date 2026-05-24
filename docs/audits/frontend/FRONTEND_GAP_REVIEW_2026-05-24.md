# Frontend Gap Review 2026-05-24

Audit ID: `FRONTEND-GAP-REVIEW-2026-05-24`
Batch: `FRONTEND-GAP-REVIEW-COMPLETION-01`
Repo: `agentdevan/ambitions`
Status: `RED`

## Executive Verdict

Ambitions has a real native SwiftUI frontend with the locked top-level IA wired as `Today / Goals / Capture / Time / You`, but the current frontend is not flagship-proven. The Encyclopedia to Frontend OS control plane is useful routing evidence, not implementation proof. Its own dashboard reports `159` mature surfaces, `105` `canon_only_pending_lock`, `48` `planned`, `6` `implemented_unproven`, `0` proven surfaces, `159` surfaces missing receipts, and proof status outside scope.

The ruthless source-backed verdict is Red: primary root source exists, iOS 26 deployment is configured, and shared iOS 26 Liquid Glass primitives exist with availability/fallback logic, but product proof is missing across screenshots, manual visual QA, accessibility traversal, runtime end-to-end proof, receipts, and current build/test logs. Several source paths still contain compatibility or stale product-object language (`Habits`, `Insights`, `Plan`, `Profile`, `Task`) that is acceptable only when explicitly internal or subordinate; multiple user-facing strings still need scoped copy review.

## Green / Yellow / Red Summary

- Green: canonical five-tab root is wired in `Native/Ambitions/App/AmbitionsRootView.swift:107`; `AppTab.allCases` returns only Today, Goals, Capture, Time, You in `Native/Ambitions/App/AppTab.swift:19`.
- Green: deployment target and package platform are iOS 26.0 in `project.yml:9` and `Package.swift:7`; Xcode reports `Xcode 26.3`, iPhoneOS SDK `26.2`, iPhoneSimulator SDK `26.2`.
- Yellow: iOS 26 Liquid Glass primitives exist in shared chrome and navigation, but older-OS fallback proof is mostly irrelevant because minimum supported iOS is 26.0; visual/accessibility screenshot proof for the glass paths is still missing.
- Red: control-plane Green reports do not prove implementation maturity; `build/reports/frontend-implementation-dashboard.md` reports zero proven surfaces and all surfaces missing receipts.
- Red: screenshots/manual visual proof are not current product proof; release truth explicitly rejects accessibility, device, performance, TestFlight, and release claims without evidence.
- Red: root surfaces still lean on card/disclosure/depth stacks in several places and need object-first visual proof before flagship claims.

## Top 25 Frontend Gaps

| ID | Severity | Classification | Surface | Evidence | Gap |
|---|---:|---|---|---|---|
| FG-001 | P0 | proof_missing | All | `build/reports/frontend-implementation-dashboard.md` | `0` proven surfaces; control plane marked proof out of scope. |
| FG-002 | P0 | receipt_missing | All | `build/reports/frontend-source-bindings.md` | All listed mature surfaces are missing receipts in the generated binding report. |
| FG-003 | P0 | source_present_unproven | Today | `Native/Ambitions/Features/Today/TodayScreen.swift:52` | Reality Meridian source exists, but no current screenshot/manual visual proof ties it to flagship quality. |
| FG-004 | P0 | source_present_unproven | Goals | `Native/Ambitions/Features/Goals/GoalsScreen.swift:51` | Goals uses Mission Control lanes and atlas preview; Constellation Atlas final visual proof remains unproven. |
| FG-005 | P0 | source_present_unproven | Capture | `Native/Ambitions/Features/Capture/CaptureScreen.swift:43` | Atmosphere Composer source exists, but post-input route and receipt proof are not current product proof. |
| FG-006 | P0 | source_present_unproven | Time | `Native/Ambitions/Features/Time/TimeScreen.swift:43` | Time still uses hero/card/depth composition around dashboard state; LifeShape Field final root proof is missing. |
| FG-007 | P0 | source_present_unproven | You | `Native/Ambitions/Features/You/YouRootSurface.swift:66` | User System Profile source exists, but public accessibility and system-control proof are explicitly not proven. |
| FG-008 | P1 | stale_language | App shell | `Native/Ambitions/App/AppTab.swift:9` | `habits` and `insights` remain enum cases. They are excluded from `allCases`, but still require compatibility-boundary documentation. |
| FG-009 | P1 | stale_language | Goals | `Native/Ambitions/Features/Goals/GoalsScreen.swift:190` | User-facing copy says `standalone Task`; canonical language prefers `Step` except normal non-object English. |
| FG-010 | P1 | stale_language | Time | `Native/Ambitions/Features/Time/TimeScreen.swift:22` | Shared visual context still passes `.plan`; acceptable only as compatibility context, not product object language. |
| FG-011 | P1 | stale_language | You | `Native/Ambitions/Features/You/YouRootSurface.swift:16` | `planBehavior` is an internal enum case; visible title is repaired to `Time Behavior`, but internal naming remains migration debt. |
| FG-012 | P1 | implemented_visually_immature | Goals | `Native/Ambitions/Features/Goals/GoalsScreen.swift:76` | Multiple panels/cards remain visible below the root instrument; needs proof that the root is not a dashboard stack. |
| FG-013 | P1 | implemented_visually_immature | Time | `Native/Ambitions/Features/Time/TimeScreen.swift:47` | Capacity envelope plus disclosure cards risk calendar/dashboard feel without current visual QA. |
| FG-014 | P1 | screenshot_missing | All | `frontend/visual-encyclopedia/trace/SCREENSHOT_PROOF_MATRIX.md` | Existing matrices are authority/control-plane material until tied to current build screenshots. |
| FG-015 | P1 | implemented_accessibility_unproven | All | `docs/truth/RELEASE_TRUTH.md` | Source accessibility labels exist, but manual VoiceOver/Dynamic Type/Reduce Motion proof is not current release proof. |
| FG-016 | P1 | implemented_runtime_unproven | Today | `docs/truth/PRODUCT_MOAT_TRUTH.md` | Same intent plus different local context plus replay plus closure adaptation is the moat proof target, not proven by Today source alone. |
| FG-017 | P1 | implemented_runtime_unproven | Capture | `Native/Ambitions/Features/Capture/CaptureScreen.swift:50` | Composer calls capture/goals services, but route-to-proof lifecycle needs current end-to-end evidence. |
| FG-018 | P1 | implemented_runtime_unproven | Time | `Native/Ambitions/Features/Time/TimeScreen.swift:187` | Calendar-aware action is present, but EventKit denied/allowed visual/runtime paths need proof. |
| FG-019 | P1 | ios_api_era_risk | Shared chrome | `Sources/Components/NavigationPrimitives.swift:99` | iOS 26 glass is source-present; visual/accessibility proof of actual rendered chrome remains missing. |
| FG-020 | P2 | preview_missing | Goals | `rg #Preview` | Goals root has tests but no obvious root preview block in `GoalsScreen.swift`; preview coverage is indirect. |
| FG-021 | P2 | preview_missing | Time | `Native/Ambitions/Features/Time/TimeScreen.swift:1972` | Time has seeded/empty previews but no full matrix for overloaded/protected/vacation/stale states in root file. |
| FG-022 | P2 | preview_missing | Today | `Native/Ambitions/Features/Today/TodayScreen.swift:417` | Today has multiple previews, but proof still needs current screenshots and manual inspection. |
| FG-023 | P2 | generic_ui_regression | Shared | `Sources/Theme/AmbitionTheme.swift:247` | Radius tokens default above the stricter generic card threshold; acceptable only where established native visual language proves it. |
| FG-024 | P2 | proof_missing | Screenshots | `output/logs/*.png`, `.codex/proof/*.png` | Screenshot files exist but are not a current audited proof packet for this commit. |
| FG-025 | P2 | ios_api_era_risk | Primary surfaces | `rg glassEffect` | iOS 26 API use is centralized in shared primitives, not surface-specific; each root still needs surface-level rendered proof. |

## Root Surface Status

| Surface | Status | Evidence | Verdict |
|---|---|---|---|
| Today / Reality Meridian + Start Here | Red | `TodayScreen.swift:52`, `TodayStartHereSurface.swift:28` | Best source maturity, still unproven visually/runtime/accessibility. |
| Goals / Constellation Atlas | Red | `GoalsScreen.swift:51`, `GoalsScreen.swift:71` | Source-present but still reads as Mission Control lanes plus panels before proof establishes Constellation Atlas. |
| Capture / Atmosphere Composer | Red | `CaptureScreen.swift:43`, `CaptureScreen.swift:174` | Composer-led shape exists; route, receipt, dictation, attachment, uncertainty states need proof. |
| Time / LifeShape Field | Red | `TimeScreen.swift:43`, `TimeLifeShapeField.swift:192` | Time is source-present but still carries `.plan` visual context and card/depth stack risk. |
| You / User System Profile | Red | `YouScreen.swift:41`, `YouRootSurface.swift:66` | Settings-style system center exists; accessibility/public claim lock remains explicit. |
| Global shell / navigation | Yellow | `AmbitionsRootView.swift:107`, `AppMeridianShell.swift:49` | IA wiring is good; chrome needs current rendered proof and iOS 26 glass QA. |

## Design System Review

The design-system layer is source-present and substantial: theme tokens live in `Sources/Theme/AmbitionTheme.swift`, material/chrome primitives live under `Sources/Components`, and generated frontend authority lives in `Sources/Theme/AmbitionsFrontendAuthority.generated.swift`. The strongest implementation evidence is the iOS 26 Liquid Glass path: `ambitionShouldUseLiquidGlass` guards on Reduce Transparency and increased contrast in `Sources/Components/AmbitionsPremiumMaterials.swift:4`, and shared chrome applies `.glassEffect` in `Sources/Components/ChromeButtonPrimitives.swift:148`, `SurfaceShellPrimitives.swift:166`, and `NavigationPrimitives.swift:99`.

The gap is proof, not source volume. Root surfaces still use multiple `StateDrivenMaterialPanel`, `AppCard`, and disclosure/card rows. That can be acceptable only if the rendered experience remains one-primary-object first. No current visual proof packet establishes that for all five primary surfaces.

## Accessibility Review

Source-level accessibility work is real: root files use `accessibilityIdentifier`, `accessibilityLabel`, Dynamic Type branching, Reduce Motion environment values, and accessibility-focused previews. However, release truth blocks public claims without manual proof. The audit status is therefore `implemented_accessibility_unproven`, not Green.

Highest-risk gaps:

- Manual VoiceOver traversal is not current proof for Today, Goals, Capture, Time, You.
- Dynamic Type screenshot proof is not current proof for all primary states.
- Reduce Motion proof is not current proof for root transitions and iOS 26 glass chrome.
- Increased Contrast / Reduce Transparency proof is not current proof for Liquid Glass fallback behavior.

## Proof / Receipt Review

The frontend control-plane reports are internally inconsistent with product-proof needs. `frontend-implementation-dashboard.md` says Green while also reporting every mature surface as proof out of scope and every surface missing receipts. For this audit, source wins over control-plane optimism: receipt and proof coverage are Red until tied to current runtime behavior, screenshots, tests, and receipts.

## Stale Language Review

Hard Red avoided: the active tab bar does not expose `Plan`, `Profile`, `Habits`, or `Insights` as top-level tabs. Remaining stale-language risks:

- `AppTab` retains `.habits`, `.insights`, `.plan`, `.profile`, and `.captures` compatibility paths.
- Time visual primitives still use `.plan` as an internal context.
- Goals user-facing copy includes `standalone Task`.
- Services still contain user-facing strings such as `Carry into Plan` and `Why this belongs in Plan` in review/resilience projectors; these require scoped review before release-facing copy proof.

Normal English use of `task`, `profile`, `plan`, and `habits` is acceptable only when it is not acting as a product object, tab, destination, model, or architecture object.

## iOS API Era Audit

Environment status: checked. Xcode 26.3 is installed; iPhoneOS and iPhoneSimulator SDK versions report 26.2. `project.yml` and `Package.swift` set minimum iOS to 26.0, so iOS 26 APIs are safe from a deployment-target perspective. Availability guards are still useful for package/test compatibility and local fallback behavior, but older iOS runtime fallback is not required by the current declared minimum.

| Area | Uses iOS 26 API | Should Use iOS 26 API | Evidence | Recommendation |
|---|---|---|---|---|
| Global shell chrome | Yes | Yes | `AmbitionsRootView.swift:145`, shared `NavigationPrimitives.swift:99` | Keep centralized glass usage; add rendered proof. |
| Destination dock / bottom chrome | Yes | Yes | `NavigationPrimitives.swift:112`, `NavigationPrimitives.swift:125` | Correct use if visual and accessibility fallback proof lands. |
| Surface shell header | Yes | Yes | `SurfaceShellPrimitives.swift:166`, `SurfaceShellPrimitives.swift:271` | Keep; add Reduce Transparency / Increased Contrast screenshots. |
| Chrome buttons | Yes | Yes | `ChromeButtonPrimitives.swift:148` | Keep; test hit targets and contrast. |
| Theme glass tokens | Yes | Yes | `AmbitionTheme.swift:868`, `AmbitionTheme.swift:912` | Keep centralized; avoid duplicating glass tokens. |
| Today root | No direct symbol found | Maybe | `TodayScreen.swift:52` | Do not add novelty APIs until root visual proof defines the need. |
| Goals root | No direct symbol found | Maybe | `GoalsScreen.swift:51` | Consider only if it reduces card-stack chrome or improves atlas fidelity. |
| Capture root | No direct symbol found | Maybe | `CaptureScreen.swift:43` | Consider only for composer/sheet fidelity with input accessibility proof. |
| Time root | No direct symbol found | Maybe | `TimeScreen.swift:43` | Consider only if it improves LifeShape canvas, not calendar/dashboard chrome. |
| You root | No direct symbol found | No | `YouRootSurface.swift:90` | Settings-style grouped navigation should stay native and restrained; no novelty glass requirement. |

## iOS 26 API Usage Table

| Symbol | Path | Availability / fallback | Risk |
|---|---|---|---|
| `Glass.regular.interactive` | `Sources/Theme/AmbitionTheme.swift:868` | Central token only; deployment target iOS 26 | Low target risk, medium proof risk. |
| `.glassEffect` | `Sources/Components/ChromeButtonPrimitives.swift:148` | Gated through `ambitionShouldUseLiquidGlass` | Needs rendered contrast/reduce transparency proof. |
| `.glassEffect` | `Sources/Components/SurfaceShellPrimitives.swift:166` | Gated through `ambitionShouldUseLiquidGlass` | Needs chrome proof in root surfaces. |
| `GlassEffectContainer` | `Sources/Components/NavigationPrimitives.swift:112` | Gated through `ambitionShouldUseLiquidGlass` | Needs navigation/dock screenshot and VoiceOver proof. |
| `#available(iOS 26, *)` | `Sources/Components/AmbitionsPremiumMaterials.swift:12` | Returns false below iOS 26 | Correct defensive wrapper; older fallback not release-critical while min iOS is 26. |

## Implementation Order

1. `FRONTEND-PROOF-01`: create current screenshot/manual visual proof packet for five roots and shell.
2. `TODAY-REALITY-MERIDIAN-PROOF-01`: prove Start Here recommendation, receipt, rejection, replacement, closure, and replay states.
3. `TIME-LIFESHAPE-PROOF-01`: replace or prove non-generic LifeShape root visual hierarchy; resolve internal `.plan` visual context naming if feasible.
4. `CAPTURE-ATMOSPHERE-COMPOSER-PROOF-01`: prove composer idle, typing, route reveal, receipt, error, Dynamic Type, Reduce Motion.
5. `GOALS-CONSTELLATION-ATLAS-PROOF-01`: prove atlas/object-first shape over panel stack; remove or quarantine `Task` copy.
6. `YOU-SYSTEM-PROFILE-PROOF-01`: prove grouped navigation, trust center, reset/forget, accessibility lock, local runtime controls.
7. `IOS26-GLASS-CHROME-QA-01`: prove glass paths under normal, Reduce Transparency, Increased Contrast, Dynamic Type, VoiceOver.

## Non-Goals

- No Swift source changes in this audit.
- No flagship readiness claim.
- No accessibility conformance claim.
- No release, TestFlight, App Store, device, privacy/legal, or performance claim.
- No generic recommendation to adopt iOS 26 APIs for novelty.
- No resurrection of `Plan` as top-level IA.

## Risks

- Existing control-plane Green status can mislead future agents into treating source bindings as product proof.
- iOS 26 APIs are deployment-safe but can still regress accessibility or visual restraint if unreviewed.
- Stale internal compatibility names can leak into user-facing copy.
- Screenshot files and old logs can be mistaken for current commit proof.

## Unknowns

- Current full build was not run in this audit.
- Current simulator screenshots were not captured in this audit.
- Exact rendered quality of root surfaces is unknown without fresh screenshots.

STATUS: RED
