# Repo Phase 0 — Orientation Audit And Canon Pointer Cleanup

Status: Yellow
Date: 2026-05-08

## Summary

Repo Phase 0 verified that the Ambitions Design System and AmbitionsCanon pack are present and readable, installed narrow source-truth pointer notes in allowed docs, and mapped the current app/source structure enough for a future implementation-planning prompt.

Yellow is the correct result because older source-truth and handoff docs still contain conflicting or superseded object names and implementation-planning vocabulary that should not be bulk-rewritten in this docs-only orientation pass. Current app source also preserves internal compatibility names such as `captures`, `profile`, `habits`, and `insights`; visible top-level tabs appear to remain Today / Goals / Capture / Plan / You, but those compatibility seams need a later boundary map before implementation.

This report is docs-only evidence. It does not implement UI, start the global batch train, prove tests, prove accessibility, prove performance, prove visual quality, or claim release readiness.

## Files Inspected

- `README.md`
- `AGENTS.md`
- `docs/README.md`
- `docs/canon/README.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/AmbitionsCanon/README.md`
- `docs/AmbitionsCanon/Archive/README.md`
- `docs/AmbitionsCanon/Ambitions_Design_System.md`
- `docs/AmbitionsCanon/00_Canon_Index_10_10_Maturity_Gate.md`
- `docs/AmbitionsCanon/01_Product_Canon.md`
- `docs/AmbitionsCanon/02_Continuity_Layer_Chrome.md`
- `docs/AmbitionsCanon/03_Signature_Object_Specs.md`
- `docs/AmbitionsCanon/04_Trust_Privacy_Automation.md`
- `docs/AmbitionsCanon/05_Accessibility_Motion_Performance.md`
- `docs/AmbitionsCanon/06_QA_Preview_Visual_Drift.md`
- `docs/AmbitionsCanon/07_Native_Shell_Tokens_Materials.md`
- `docs/AmbitionsCanon/08_Implementation_Codex_Repo_Integration.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/Ambitions_Signature_Interface_System.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Repo_Traceability_Map.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_File_Boundary_Map.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Final_File_Boundary_Approval.md`
- `docs/handoff/Ambitions_4_0_Signature_Interface_Handoff.md`
- `Native/Ambitions/App/AmbitionsApp.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/Features/Today/`
- `Native/Ambitions/Features/Goals/`
- `Native/Ambitions/Features/Captures/`
- `Native/Ambitions/Features/Plan/`
- `Native/Ambitions/Features/Profile/`
- `Native/Ambitions/PreviewSupport/`
- `Sources/Previews/`
- `Native/AmbitionsTests/`
- `Native/AmbitionsUITests/`
- `Sources/`
- `AppUI/Sources/`

## Files Added

- `docs/audits/ambitions-canon-pack-repo-phase-0-orientation-audit.md`

## Files Modified

- `README.md`
- `AGENTS.md`
- `docs/README.md`
- `docs/canon/README.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/AmbitionsCanon/Archive/README.md`

## Files Intentionally Not Modified

- `Native/**`
- `Sources/**`
- `AppUI/**`
- `Native/AmbitionsTests/**`
- `Native/AmbitionsUITests/**`
- `project.yml`
- `Package.swift`
- `.github/**`
- `assets/**`
- `Native/Ambitions/Resources/**`
- `Ambitions.xcodeproj/**`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/Ambitions_Signature_Interface_System.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Repo_Traceability_Map.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_File_Boundary_Map.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Final_File_Boundary_Approval.md`
- `docs/handoff/Ambitions_4_0_Signature_Interface_Handoff.md`
- Existing untracked files: `Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift`, `Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamTodayBridgeModelsTests.swift`

## Canon Pack Verification Table

| Canon doc | Path | Present | Notes |
| --- | --- | --- | --- |
| Ambitions Design System | `docs/AmbitionsCanon/Ambitions_Design_System.md` | Yes | Highest source truth; locks native/obvious/useful/elegant/celestial/adaptive/alive/evolving direction and taste profile. |
| Canon Index / 10-10 Maturity Gate | `docs/AmbitionsCanon/00_Canon_Index_10_10_Maturity_Gate.md` | Yes | Distinguishes canon maturity from implementation, visual QA, accessibility, performance, and release proof. |
| Product Canon | `docs/AmbitionsCanon/01_Product_Canon.md` | Yes | Locks five tabs and primary objects. |
| Continuity Layer / Chrome | `docs/AmbitionsCanon/02_Continuity_Layer_Chrome.md` | Yes | Locks Context Crown, Meridian Edge, Living Continuity Dock, Trust Seam, and signal routing law. |
| Signature Object Specs | `docs/AmbitionsCanon/03_Signature_Object_Specs.md` | Yes | Locks Reality Meridian, Start Here Surface, Atmosphere Composer, LifeShape Field, Constellation Atlas, Orbital Lens, and User System Profile direction. |
| Trust / Privacy / Automation | `docs/AmbitionsCanon/04_Trust_Privacy_Automation.md` | Yes | Locks Manual / Suggest / Preview Reflow launch automation cap. |
| Accessibility / Motion / Performance | `docs/AmbitionsCanon/05_Accessibility_Motion_Performance.md` | Yes | Locks nonvisual and Reduce Motion requirements without proving implementation. |
| QA / Preview / Visual Drift | `docs/AmbitionsCanon/06_QA_Preview_Visual_Drift.md` | Yes | Defines Visual QA and preview proof requirements without creating artifacts. |
| Native Shell / Tokens / Materials | `docs/AmbitionsCanon/07_Native_Shell_Tokens_Materials.md` | Yes | Locks semantic token names and native shell rules; exact values remain validation tasks. |
| Implementation / Codex / Repo Integration | `docs/AmbitionsCanon/08_Implementation_Codex_Repo_Integration.md` | Yes | Requires repo orientation and file-boundary approval before implementation. |
| Canon README | `docs/AmbitionsCanon/README.md` | Yes | Canon pack source-truth hierarchy installed. |
| Archive README | `docs/AmbitionsCanon/Archive/README.md` | Yes | Supersession index present and updated with pointer note. |

## Existing Source-Truth Conflicts / Drift Sources

| Existing file | Risk | Action taken | Follow-up |
| --- | --- | --- | --- |
| `README.md` | Previously put Ambitions 3.0 read order first and may be used as future product/design truth. | Added concise AmbitionsCanon source-truth pointer. | Phase 1 should separate current implementation baseline from future canon implementation planning. |
| `AGENTS.md` | Required read order was still Ambitions 3.0 first. | Added AmbitionsCanon as read-order item 0 for future product/design/planning work. | Phase 1 should decide whether AGENTS needs a fuller Canon Pack workflow block. |
| `docs/README.md` | Still frames Ambitions 3.0 and Ambitions 4.0 execution program as primary docs. | Added concise AmbitionsCanon source-truth pointer. | Later docs reconciliation can reorganize index sections if approved. |
| `docs/canon/README.md` | Lists Ambitions 3.0 active docs and PXOS/SI as active/future canon without AmbitionsCanon precedence. | Added concise pointer noting AmbitionsCanon priority where conflicts exist. | Do not bulk-edit old canon index until Phase 1 boundary map names exact sections. |
| `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md` | Explicitly says Ambitions 3.0 decides rebuild/front-end truth; now lower priority than AmbitionsCanon for future product/visual/shell/IA work. | Added supersession pointer while preserving 3.0 as baseline/evidence context. | Future cleanup should not erase 3.0 history. |
| `docs/canon/Ambitions_Product_Experience_OS_Index.md` | PXOS is broadly compatible with five tabs and anti-generic rules but object names and Product Depth framing conflict with AmbitionsCanon objects. | Not edited; listed as supporting context only where compatible. | Phase 1 should map PXOS names to AmbitionsCanon names. |
| `docs/canon/Ambitions_Signature_Interface_System.md` | Useful SI implementation canon, but primitive names like DayTimelineRail, LifePathView, MissionControlLane, LifeShapeMap, and Personal System Center are superseded where conflicting. | Not edited. | Phase 1 should define alias/compatibility map before implementation prompts. |
| `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md` | Locks older Product Experience Pack hierarchy and older object names such as Reality Rail, LifePath View, LifeShape Map, Personal System Center. | Not edited. | Treat as historical handoff evidence, not highest source truth. |
| `docs/handoff/Ambitions_Product_Experience_Pack_Repo_Traceability_Map.md` | Valuable file mapping but older object names and unresolved MissionControlTimeSpine order remain. | Not edited. | Reuse in Phase 1 as a compatibility input. |
| `docs/handoff/Ambitions_Product_Experience_Pack_File_Boundary_Map.md` | Good boundary map, but source-truth hierarchy predates AmbitionsCanon pack. | Not edited. | Phase 1 should produce updated file-boundary map rather than editing app code. |
| `docs/handoff/Ambitions_Product_Experience_Pack_Final_File_Boundary_Approval.md` | Preserves useful stop conditions but predates Canon Pack object names. | Not edited. | Phase 1 should reconcile approvals with Canon Pack objects. |
| `docs/handoff/Ambitions_4_0_Signature_Interface_Handoff.md` | SI closed with older primitive vocabulary and states Product Depth readiness; can be mistaken for implementation permission. | Not edited. | Keep as evidence only; Phase 1 should restate no implementation permission. |
| Old Chrome / Behavior / Meridian / Shell docs found under `docs/canon/` and handoff reports | Older shell/chrome language can conflict with Context Crown, Meridian Edge, Continuity Dock, and Trust Seam. | Pointer notes installed in top-level allowed docs. | Future shell mapping should be docs-only before source edits. |

## Current App Structure Map

| Area | Current path(s) | Notes / AmbitionsCanon mapping |
| --- | --- | --- |
| app root / shell | `Native/Ambitions/App/AmbitionsApp.swift`, `Native/Ambitions/App/AmbitionsRootView.swift`, `Native/Ambitions/App/AppShellView.swift`, `Native/Ambitions/App/AppMeridianShell.swift`, `Native/Ambitions/UI/` | App boots through SwiftUI entry and root `TabView`. Future mapping should treat current shell as implementation evidence, not Canon Pack completion. |
| tabs/navigation | `Native/Ambitions/App/AppTab.swift`, `Native/Ambitions/App/AmbitionsRootView.swift`, `Native/Ambitions/App/AppNavigation.swift`, `Native/Ambitions/App/AppExternalRouting.swift` | `AppTab.allCases` maps visible tabs to Today, Goals, Capture, Plan, You. Internal cases preserve `captures`, `profile`, `habits`, and `insights` compatibility. |
| Today | `Native/Ambitions/Features/Today/` | Current Today folder maps to future Reality Meridian and Start Here Surface planning, but older Reality Rail/Day Rail terms remain. |
| Goals | `Native/Ambitions/Features/Goals/` | Maps to Constellation Atlas, Orbital Lens, and Goal Detail Mission Control. Mission Control must remain inside Goal Detail only. |
| Capture | `Native/Ambitions/Features/Captures/` | Current folder name is plural `Captures`; future user-facing canon remains singular Capture and maps to Atmosphere Composer. |
| Plan | `Native/Ambitions/Features/Plan/` | Maps to LifeShape Field and reflow preview rules. Calendar-clone risk remains a validation concern. |
| You/Profile | `Native/Ambitions/Features/Profile/` | User-facing You maps to User System Profile; internal Profile naming remains compatibility debt. |
| shared UI/design system | `Native/Ambitions/Features/Shared/`, `Native/Ambitions/UI/`, `Sources/Theme/`, `Sources/Components/`, `AppUI/Sources/` | Current shared primitives and token packages need Phase 1 mapping to Canon Pack tokens/materials before implementation. |
| preview fixtures | `Native/Ambitions/PreviewSupport/`, `Sources/Previews/` | Preview infrastructure exists, but Canon Pack visual drift gallery and object fixture payloads are not proven complete. |
| tests | `Native/AmbitionsTests/`, `Native/AmbitionsUITests/` | Test folders exist by feature/domain. No tests were run or modified in this pass. |

## Current Top-Level IA Evidence

Visible primary tabs appear to remain Today / Goals / Capture / Plan / You:

- `Native/Ambitions/App/AppTab.swift` defines internal enum cases `today`, `captures`, `goals`, `habits`, `plan`, `insights`, and `profile`.
- `AppTab.allCases` returns `[.today, .goals, .captures, .plan, .profile]`.
- `AppTab.title` renders `.captures` as `Capture` and `.profile` as `You`.
- `Native/Ambitions/App/AmbitionsRootView.swift` composes `todayNavigation()`, `goalsNavigation()`, `captureNavigation()`, `planNavigation()`, and `profileNavigation()` inside the root `TabView`.

Compatibility cases exist and need later mapping:

- `.habits` maps canonically to `.plan`.
- `.insights` maps canonically to `.profile`.
- `.captures` is internal plural but visible title is singular `Capture`.
- `.profile` is internal compatibility owner but visible title is `You`.

No app code was edited.

## Future Implementation Readiness Map

| Future area | Current evidence | Readiness | First safe follow-up |
| --- | --- | --- | --- |
| Design tokens/materials | `Sources/Theme/`, `Sources/Components/`, `docs/AmbitionsCanon/07_Native_Shell_Tokens_Materials.md` | Yellow | Map existing token names to Canon Pack semantic tokens; no values changed. |
| Continuity Dock | Current root `TabView`, `AppMeridianShell`, shell docs | Yellow | Define whether current tab bar or Meridian rail is the future Continuity Dock target. |
| Context Crown | Current `AppShellScaffold`/header rail and shell copy | Yellow | Map shell header/crown behavior without source edits. |
| Meridian Edge | Current shell/Today edge concepts and older Meridian docs | Yellow | Produce docs-only shell/chrome boundary map. |
| Trust Seam | Existing trust/receipt primitives and You/Profile trust surfaces | Yellow | Map Trust Seam states to current proof/source/receipt components. |
| Reality Meridian | Current Today implementation and older Reality Rail evidence | Yellow | Alias Reality Rail/Day Rail to Reality Meridian requirements before code. |
| Start Here Surface | Current Today Start Here/Recommendation evidence in docs/source folders | Yellow | Define object boundary and preview fixture requirements. |
| Atmosphere Composer | `Native/Ambitions/Features/Captures/CaptureAtmosphereComposer.swift` path evidence | Yellow | Map plural Captures folder and text-first composer to Canon Pack object. |
| LifeShape Field | Plan LifeShape files and Plan folder evidence | Yellow | Define LifeShape Field scope and calendar-clone guard. |
| Constellation Atlas | Goals folder and existing LifePath/Mission Control evidence | Yellow | Map Goals primary object; keep Mission Control inside Goal Detail only. |
| Orbital Lens | Existing Goals/Goal Detail lens concepts | Yellow | Define Orbital Lens relationship to Goal Detail and selected area/thread behavior. |
| User System Profile | Profile folder and Personal System Center evidence | Yellow | Map internal Profile to user-facing You and Canon Pack User System Profile. |
| Accessibility fixtures | `Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift`, accessibility docs | Yellow | Define object-level VoiceOver/Dynamic Type fixtures before implementation. |
| Reduce Motion | Existing motion previews and docs | Yellow | Map Canon Pack Reduce Motion requirements to current motion primitives. |
| Visual QA | Existing `docs/audits/visual-evidence/`, `Sources/Previews/SignatureInterfaceVisualQAPreviews.swift` | Yellow | Future pass needs fresh screenshots and Visual QA scoring; none generated here. |
| Tests/previews | `Native/AmbitionsTests/`, `Native/AmbitionsUITests/`, `Native/Ambitions/PreviewSupport/`, `Sources/Previews/` | Yellow | Phase 1 should identify exact tests/previews to use later; no tests modified. |

## Validation Tasks Remaining

- Exact token values need visual QA.
- Visual drift gallery examples need screenshots.
- Accessibility proof needs implementation.
- Reduce Motion proof needs implementation.
- Performance proof needs device profiling.
- Repo code audit still needed before implementation.
- Preview fixture payloads need implementation data.
- Top-level surfaces need Visual QA scoring.

## App Code Safety Confirmation

- No Swift app code modified.
- No assets modified.
- No Xcode project modified.
- No dependencies modified.
- No tests/CI modified.
- No generated screenshots modified.
- No feature implementation started.
- No global batch train started.

## Result Rationale

Green conditions mostly hold for presence/readability, pointer installation, app-code safety, and structure mapping. The result remains Yellow because source-truth conflicts intentionally remain in older docs and internal compatibility names require later mapping before implementation.

No Red condition was hit.

## Next Safe Step

```text
Repo Phase 1 — Canon-To-Implementation Boundary Map
```

Phase 1 should define exact implementation file boundaries and first narrow batch options, but still should not implement UI unless separately authorized.
