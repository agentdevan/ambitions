# Ambitions Known Issues — Live Register

**Status:** source-reconciled; not runtime-revalidated.

**Last source reconciliation:** 2026-06-22

**Baseline commit reviewed:** `ce75bb77122350fcab9500806e5ff26f8ee02e58` (`AMB-1180 rebuild LifeShape field object`)

## Rules

- This file is the living known-issue register. Preserve IDs and dedupe keys.
- Historical screenshot evidence stays useful, but current closure requires current proof.
- Source-repaired means **candidate resolved**, not closed.
- Runtime-only findings stay open until there are current screenshots, UI tests, crash logs, accessibility proof, or real-device evidence.
- Do not mark anything `Closed - verified` without proof artifacts attached in `docs/validation`, CI output, screenshots, or a current testing report.

## Source signals used

- `AMB-1161` / commit `545b1b0` added shell chrome and safe-area audits for duplicate nav, dock hidden in drilldowns, activated Capture dock hiding, and clearance.
- `AMB-1163` / commit `0c0de34` wired Time/Today clock behavior through `AmbitionsClock`, clock context refresh, and time-zone-aware boundary logic.
- `AMB-1164`–`AMB-1177` rebuilt Time/LifeShape: data contract, Open/Protected engines, Today coupling, SwiftUI-first field, mutations, inspection-only why-this, Pressure/Buffer layers, visual pass, old Time fallback deletion, and sequencing guard.
- `AMB-1180` / commits `a678f4b` and `ce75bb7` rebuilt the LifeShape field object after rendered-product acceptance enforcement.
- `Train 6 closure refraction` / commit `2dceb7e` was Yellow: source/build-for-testing passed, but receipt-visible screenshot proof failed/not rerun.
- Capture routing commits `8470e98`, `d95e3a7`, and `a19fd89` moved Capture toward global composer overlay behavior.

## Current status summary

- Total issues: **75**
- P0: **23**
- P1: **47**
- P2: **5**
- Candidate/partial source repairs: **30**
- Still open or source-audit required: **43**

## Issue table

| ID | P | Surface | Current status | Issue | Next proof required |
|---|---|---|---|---|---|
| `AMB-ISSUE-0001` | P0 | Today | Candidate source-resolved; needs runtime proof | Today current-time marker may not be clock-backed | Real-device screenshots + clock injection test + grep result |
| `AMB-ISSUE-0002` | P0 | Capture | Open - runtime proof required | Capture expansion crashes from quick capture bullseye/full-screen control | Screen recording + crash-free test run |
| `AMB-ISSUE-0003` | P0 | Capture | Open - runtime/permission proof required | Mic and voice controls appear nonfunctional or permission-blind | Permission-state screenshots + device test notes |
| `AMB-ISSUE-0004` | P0 | Today / Closure | Partial source repair; needs runtime proof | Closure save does not visibly mutate Today | Before/action/after screenshots + VoiceOver announcement notes + receipt/proof artifact |
| `AMB-ISSUE-0005` | P0 | Stage / Navigation | Partial source repair; needs runtime proof | Primary actions route too shallowly or lose context | Route trace + screenshots from origin and target |
| `AMB-ISSUE-0006` | P0 | Shell / Dock | Candidate resolved - source audit installed; runtime proof required | Duplicate bottom navigation shelf appears under floating dock | ShellChromeAudit result + root/drilldown screenshot matrix |
| `AMB-ISSUE-0007` | P0 | Shell / Dock | Candidate resolved - source policy/audit verified; runtime proof required | Root dock overlaps content and appears in drilldowns/overlays | Audit results + screenshot matrix |
| `AMB-ISSUE-0008` | P0 | Capture / Keyboard | Candidate resolved - source policy verified; keyboard proof required | Composer can be trapped between dock and keyboard | Focused-keyboard screenshots + video |
| `AMB-ISSUE-0009` | P0 | Time | Candidate resolved - Time source rebuilt; Dynamic Type proof required | Time source/receipt columns wrap into unreadable vertical letters | Dynamic Type screenshots + audit output |
| `AMB-ISSUE-0010` | P0 | All primary surfaces | Still open - source audit and user-facing scan required | Forbidden/internal runtime language appears in primary UI | Audit output + root screenshot review |
| `AMB-ISSUE-0011` | P0 | Stage / Motion | Candidate source-resolved; needs runtime proof | Motion must not remain a root destination or persistent surface | Code grep + root screenshot matrix + scenario run |
| `AMB-ISSUE-0012` | P0 | Capture | Candidate resolved - source architecture verified; composer runtime proof required | Capture appears as low-quality quick/add sheet instead of global Atmosphere Composer | Overlay screenshots + keyboard video |
| `AMB-ISSUE-0013` | P0 | Architecture / Privacy | Open - architecture/privacy proof required | Offline core, account optionality, and R2 separation need release proof | Offline test notes + network/request audit |
| `AMB-ISSUE-0014` | P0 | Quality | Source partially repaired - proof artifacts still required | Required audits and proof artifacts are not yet evidenced | Audit outputs + screenshot manifest |
| `AMB-ISSUE-0015` | P0 | Runtime / Projection | Partial source repair; needs runtime proof | StageMutation contract and proof artifacts need implementation validation | Tests + mutation proof artifacts |
| `AMB-ISSUE-0016` | P0 | All surfaces | Open - current runtime validation still blocked without app run | Frontend blocks meaningful runtime validation | Scenario matrix + screenshots + notes |
| `AMB-ISSUE-0101` | P1 | Today | Open; Today runtime/design proof | Today does not yet prove Reality Meridian as live, scrollable daily object | Root Today screenshots + scroll/VO notes |
| `AMB-ISSUE-0102` | P1 | Today | Open; Today runtime/design proof | Start Here state is contradictory or detached from a real recommended Step | Start Here + no-step screenshots |
| `AMB-ISSUE-0103` | P1 | Today | Open; Today runtime/design proof | Today CTA stack replaces primary object/action clarity | Root screenshot + action map |
| `AMB-ISSUE-0104` | P1 | Today | Open - language audit/runtime screenshot required | Today exposes source/error language instead of calm fallback | Broken-source screenshot + audit result |
| `AMB-ISSUE-0105` | P1 | Today | Open; Today runtime/design proof | Up Next and meridian placement are temporally incoherent | Dense Today screenshot + semantic model output |
| `AMB-ISSUE-0106` | P1 | Today | Open; Today runtime/design proof | Meridian icons appear detached from semantic meaning | Semantic model dump + VO notes |
| `AMB-ISSUE-0107` | P1 | Today | Open; Today runtime/design proof | Today empty/dense/broken/recovery states need scenario proof | Scenario screenshots + VisualRegressionHarness output |
| `AMB-ISSUE-0108` | P1 | Today / Time | Source partially repaired - Time side verified; Today proof required | Protect this window is ambiguous and unproven as a direct object operation | Before/action/after/undo screenshots |
| `AMB-ISSUE-0201` | P1 | Capture | Open; Capture runtime/design proof | Capture visual quality is below flagship composer standard | Capture screenshot set across states |
| `AMB-ISSUE-0202` | P1 | Capture | Source partially repaired - copy audit required | Capture uses disallowed/generic routing copy | Audit output |
| `AMB-ISSUE-0203` | P1 | Capture | Open; Capture runtime/design proof | Attachment/date/reminder/repeat/location/scan controls need real implementation proof | Control tray screenshots + device test notes |
| `AMB-ISSUE-0204` | P1 | Capture | Open; Capture runtime/design proof | Capture routing preview is internal rather than user-useful | Routing preview screenshots |
| `AMB-ISSUE-0205` | P1 | Capture | Open; Capture runtime/design proof | Capture collapsed/focused/multiline/max-height/full-screen state machine needs proof | Scenario videos + VO notes |
| `AMB-ISSUE-0301` | P1 | Closure | Partial source repair; Yellow; needs runtime proof | Closure overlay does not clearly show current Step identity/context | Closure screenshots |
| `AMB-ISSUE-0302` | P1 | Closure | Partial source repair; Yellow; needs runtime proof | Closure outcome selection is too verbose and slow by default | Default closure screenshot |
| `AMB-ISSUE-0303` | P1 | Closure | Partial source repair; Yellow; needs runtime proof | Advanced closure states are buried or clutter default closure | Advanced closure screenshots |
| `AMB-ISSUE-0304` | P1 | Closure / Trust | Partial source repair; Yellow; needs runtime proof | Closure sheet reads like system report with noisy receipt preview | Closure and receipt screenshots |
| `AMB-ISSUE-0305` | P1 | Closure / Motion | Partial source repair; Yellow; needs runtime proof | Closure proof stitch, undo, and recovery consequences need implementation proof | Scenario matrix + screenshots |
| `AMB-ISSUE-0401` | P1 | Goals | Open; Goals review required | Goals does not yet prove Constellation Atlas as relational goal object | Root Goals screenshots + semantic model |
| `AMB-ISSUE-0402` | P1 | Goals | Open; Goals review required | Life areas read as weak dashboard tiles with unclear repeated Today statuses | Goals state screenshots |
| `AMB-ISSUE-0403` | P1 | Goals | Open; Goals review required | Goal threads/step chains/substeps/attachments/dates/reminders are not proven | Goal detail screenshot set + scenario tests |
| `AMB-ISSUE-0404` | P1 | Goals / Today | Open; Goals review required | Recommended Step relationship from Goals to Today is not visually proven | Cross-surface screenshots/video |
| `AMB-ISSUE-0405` | P1 | Goals | Open; Goals review required | Opening goals and goal actions are unclear; drilldown chrome not proven | Goal drilldown screenshots + gesture test notes |
| `AMB-ISSUE-0406` | P2 | Goals | Open; Goals review required | Pull-to-refresh on Goals may imply external sync without clear source model | Gesture behavior notes |
| `AMB-ISSUE-0501` | P1 | Time | Candidate source-resolved; needs runtime/visual proof | Time does not yet prove LifeShape Field / capacity object | Time root screenshots + semantic model |
| `AMB-ISSUE-0502` | P1 | Time | Candidate source-resolved; needs runtime/visual proof | Time action grid feels detached from actual time object | Time root screenshot + interaction map |
| `AMB-ISSUE-0503` | P1 | Time | Candidate source-resolved; needs runtime/visual proof | Week shape, horizon, reflow, and continuity sections are text/policy-heavy | Time screenshots at day/week/month/list |
| `AMB-ISSUE-0504` | P1 | Time | Candidate source-resolved; needs runtime/visual proof | Day/week/month/year/list hierarchy and Today anchor are not proven | Horizon screenshots + reduced-motion fallback |
| `AMB-ISSUE-0505` | P1 | Time | Candidate source-resolved; needs runtime/visual proof | Fixed points/open capacity/protected windows are not clearly translated from calendar semantics | Calendar-granted/denied screenshots |
| `AMB-ISSUE-0506` | P1 | Time | Candidate source-resolved; needs runtime/visual proof | Reflow preview and receipt/source detail appear on top-level Time | Root and reflow overlay screenshots |
| `AMB-ISSUE-0507` | P2 | Time | Candidate source-resolved; needs runtime/visual proof | Pinch zoom, drag preview, and non-gesture alternatives are not proven | Gesture video + accessible alternative screenshots |
| `AMB-ISSUE-0601` | P1 | You | Open; You review required | You lacks a recognizable user-first profile header | You root screenshot |
| `AMB-ISSUE-0602` | P1 | You | Open; You review required | You does not yet resemble premium native settings/profile surface | Root You screenshots across Dynamic Type |
| `AMB-ISSUE-0603` | P1 | You | Open; You review required | Settings rows are verbose and visually heavy | Root You screenshot + copy count |
| `AMB-ISSUE-0604` | P1 | You detail | Open; You review required | You detail surfaces show explanatory policy/docs instead of direct controls | Detail screenshot matrix |
| `AMB-ISSUE-0605` | P1 | You / Account / Privacy | Open; You review required | Privacy, permissions, account/R2, export/share, history controls need proof | You settings matrix + account/offline test notes |
| `AMB-ISSUE-0606` | P1 | You detail / All drilldowns | Open; You review required | Detail/modal screens need full-screen native treatment with root dock hidden | Detail screenshots + back gesture notes |
| `AMB-ISSUE-0607` | P2 | You / Appearance | Open; You review required | Appearance Studio is closer but still overbuilt; primitive approval needed for theme controls | Appearance screenshots + approval record |
| `AMB-ISSUE-0701` | P1 | Search | Open - current Search overlay proof required | Search results are abstract and need actionable scoped overlay behavior | Search screenshots + route tests |
| `AMB-ISSUE-0801` | P1 | All surfaces | Open; visual/runtime review | Generic card stacks, nested panels, borders, rails dominate primary UI | Screenshot matrix + visual QA notes |
| `AMB-ISSUE-0802` | P1 | Shell / Materials | Open; visual/runtime review | Materials/glass do not yet prove native quiet luxury, legibility, or accessibility fallback | Device screenshots across accessibility settings |
| `AMB-ISSUE-0803` | P1 | All surfaces | Open; visual/runtime review | Typography hierarchy and copy budgets fail root-surface clarity | Copy audit report |
| `AMB-ISSUE-0804` | P1 | All surfaces | Open; visual/runtime review | Iconography is dense and often decorative rather than semantic/actionable | VO labels/actions transcript |
| `AMB-ISSUE-0805` | P2 | All surfaces | Open; visual/runtime review | Celestial atmosphere risks decorative wallpaper instead of semantic orientation | Semantic role annotations + screenshots |
| `AMB-ISSUE-0806` | P0 | Shell / All surfaces | Candidate resolved - shell source/audit repaired; visual proof required | Header barriers and unsafe scroll-edge treatment make shell feel web/admin-like | Audit outputs + screenshot matrix |
| `AMB-ISSUE-0807` | P1 | All surfaces | Open - accessibility proof required | VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, High Contrast, haptics not evidenced | Audit results + transcripts/screenshots/video |
| `AMB-ISSUE-0901` | P0 | Architecture / Stage | Candidate resolved - source verified; stale vocabulary follow-up added | Root must be AmbitionsStage, not TabView/RootTab product model | Code grep output + screenshots |
| `AMB-ISSUE-0902` | P0 | Stage / Overlay | Candidate resolved - source policy verified; overlay runtime proof required | StageOverlay route contracts need implementation proof | Code references + screenshots |
| `AMB-ISSUE-0903` | P0 | Core Time | Candidate source-resolved; needs runtime proof | AmbitionsClock/SystemClock/PreviewClock path needs verification | Test output + grep result |
| `AMB-ISSUE-0904` | P0 | Projection / Language | Open - forbidden-language source audit required | Surface lenses must stop emitting forbidden terms into primary UI | Audit output + reviewed files |
| `AMB-ISSUE-0905` | P1 | Rendering / Accessibility | Open - semantic mirror/accessibility proof required | Canvas/product objects need semantic mirrors and text fallbacks | Semantic model tests + VO notes |
| `AMB-ISSUE-0906` | P1 | Persistence | Open; source audit | SwiftData/local persistence and migration health checks not evidenced | Test output + device notes |
| `AMB-ISSUE-0907` | P1 | Permissions | Open; source audit | Contextual permission prompts and fallbacks are not evidenced | Permission-state screenshot set |
| `AMB-ISSUE-0908` | P1 | Core Domain | Open; source audit | Step/GoalThread/CaptureIntake/ClosureOutcome/UserSystemProfile capability coverage needs verification | Code audit summary + scenario results |
| `AMB-ISSUE-0909` | P0 | Scenarios / Visual Regression | Source partially repaired - visual/audit outputs required | Scenario catalog and visual regression coverage need to become issue-closing gates | Screenshot manifest + test report |
| `AMB-ISSUE-0910` | P1 | Diagnostics / Dependencies | Open; source audit | Diagnostics and third-party dependency posture need audit | Dependency audit output |
| `AMB-ISSUE-0911` | P0 | Account / Source Atlas / R2 | Open; source audit | Source Atlas/R2 must remain public-reference only and never receive private life graph data | Network audit + offline tests |
| `AMB-ISSUE-0912` | P2 | Architecture / Routing | Still present - source verified | Internal route/deep-link vocabulary still uses tab/rootTab/openTab terminology | Source diff + compatibility tests for existing external URLs |
| `AMB-ISSUE-0913` | P1 | Time / Trust | Needs source review - possible primary UI trust-language leak | Time mutation proof banner may expose receipt/proof/haptic metadata in primary flow | Current Time post-mutation screenshot + primary UI string audit |

## Current source-verified findings

### Resolved in source, still needs runtime proof

- `AMB-ISSUE-0011`: Motion is no longer an `AmbitionsSurface`; current surface enum is Today / Goals / Time / You only.
- `AMB-ISSUE-0012`: Capture is no longer a persistent surface in `AmbitionsSurface`; current source routes it through overlay/composer policy.
- `AMB-ISSUE-0901`: launch path is `AmbitionsRootScene` → `LaunchGateView` → `AmbitionsStageHost` → `AmbitionsStage`, not a `TabView` root product model.
- `AMB-ISSUE-0006`, `AMB-ISSUE-0007`, `AMB-ISSUE-0008`, `AMB-ISSUE-0806`: shell/dock/keyboard policy and audits exist, but screenshots are still required.
- `AMB-ISSUE-0501`–`AMB-ISSUE-0507`: Time/LifeShape has been rebuilt in source, but rendered quality, mutation, Dynamic Type, and visual acceptance still require current proof.

### Still source-present / newly found

- `AMB-ISSUE-0912`: internal route/deep-link source still uses stale `tab` terminology (`rootTab`, `openTab`, `owningTab`, `ambitions://tab/...`). This is source hygiene/canon-drift risk, not proof of a visible tab UI.
- `AMB-ISSUE-0913`: Time mutation feedback may expose receipt/proof/haptic metadata in a primary mutation flow; needs direct current-source check and screenshot proof.

## Next review pass

Run the current app and attach a new proof set: Today root, Capture collapsed/focused/expanded, Closure before/action/after, Goals root/detail, Time root + mutation + Dynamic Type, You root/detail, Search overlay, and at least one drilldown proving dock hidden.
