# Ambitions Canon Master Implementation Plan

Status: Yellow
Date: 2026-05-08

This plan turns the AmbitionsCanon pack and Phase 1 boundary map into ordered, evidence-bound implementation batches. It is a planning document and does not itself implement UI, change Swift source, modify assets, alter project settings, change dependencies, or start release-readiness claims.

Yellow is intentional: exact token values, visual QA, accessibility behavior, Reduce Motion behavior, and device performance require implementation and proof later.

## Source Truth

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
- `docs/handoff/Ambitions_Canon_To_Implementation_Boundary_Map.md`

## Universal Batch Rules

- Work on `main`.
- Use the smallest safe touch budget.
- Inspect files before editing.
- Preserve visible top-level tabs: Today, Goals, Capture, Plan, You.
- Do not introduce runtime dependencies.
- Do not touch persistence/migration/defaults unless that batch explicitly owns them and has migration proof.
- Do not claim visual, accessibility, performance, device, TestFlight, App Store, or release readiness without matching raw evidence.
- Green continues automatically.
- Safe Yellow may be parked with owner, safety reason, and no-claim boundary.
- Red stops.

## Ordered Implementation Batches

| Batch | Goal | Allowed files | Forbidden files | Validation commands | Preview requirements | Accessibility requirements | Reduced Motion requirements | Trust/source/receipt requirements | Hard Red stop conditions |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 3.1 Token / Material Inventory And Safe Foundation | Map existing theme/material tokens to AmbitionsCanon semantic tokens; add only safe aliases if compile-safe. | `Sources/Theme/AmbitionTheme.swift`, `Sources/Components/SurfacePrimitives.swift`, docs/handoff reports | Persistence defaults, migrations, broad restyling, assets | `git diff --check`; `xcodegen generate` and focused build only if Swift changes | Token preview inventory if existing previews support it | No color-only semantics; contrast notes | No motion dependency | No trust claim | Raw feature colors, destructive renames, final value claims without visual QA |
| 3.2 Preview Fixture Inventory / Scaffolding | Map existing fixtures to required Canon fixture matrix; add isolated fixture scaffolds only if safe. | `Native/Ambitions/PreviewSupport/`, `Sources/Previews/`, docs/handoff reports | Runtime behavior, tests unless fixture tests are explicitly scoped | `git diff --check`; focused preview/test lane only if Swift changes | Matrix for required fixture states | Include Dynamic Type and nonvisual notes | Include Reduce Motion fixture names | No private/user data in fixtures | Happy-path-only fixture plan or runtime behavior changes |
| 3.3 Shell / Continuity Dock Audit And Narrow Foundation | Preserve five tabs; map shell to AmbitionsShell / Continuity Dock / Meridian Edge. | `Native/Ambitions/App/AppTab.swift`, `AmbitionsRootView.swift`, `AppMeridianShell.swift`, shell docs | New top-level destinations, broad navigation rewrite | `xcodegen generate`; focused shell tests if Swift changes | Shell/tab previews where present | Tab labels and markers accessible | Dock/edge state must not require motion | Receipts only through approved seam | Sixth tab, Capture plus tab, red badge/count behavior |
| 3.4 Context Crown / Trust Seam / Receipt Surface Foundation | Map proof/receipt/trust/chrome primitives; add additive primitives only if safe. | `Sources/Components/TrustReceiptLayerPrimitives.swift`, `Native/Ambitions/Features/Profile/`, `Native/Ambitions/Features/Today/`, docs | Feature rewrites, chatbot/assistant chrome, notification feed | Focused build/tests if Swift changes | Trust/receipt preview inventory | Source/control/receipt labels accessible | Seam opens with static disclosure equivalent | Source labels, receipts, user control required | Black-box automation or AI assistant chrome |
| 3.5 Today Reality Meridian + Start Here Boundary | Map Reality Rail/Day Rail/Hero Step to Reality Meridian/Start Here. | `Native/Ambitions/Features/Today/`, Today preview fixtures/tests | Broad Today rewrite, domain behavior changes without proof | Focused Today tests/build if Swift changes | Today required fixture list | Now/Next/Later summary, Start Here source/actions | Static active markers and before/after reflow | Why this?/Receipt paths preserved | Generic task list, detached card stack, forbidden copy |
| 3.6 Capture Atmosphere Composer | Preserve composer-first Capture and route reveal after input. | `Native/Ambitions/Features/Captures/`, Capture preview fixtures/tests | Feed/inbox/chat/category-board defaults, Capture tab plus icon | Focused Capture tests/build if Swift changes | Keyboard, large text, route reveal fixtures | Composer and route states accessible | Static route reveal | Needs a Place / source path only after input | Keyboard covers composer, plus as tab icon |
| 3.7 You User System Profile / Automation & Trust | Map Profile to You / User System Profile and trust controls. | `Native/Ambitions/Features/Profile/`, `Sources/Components/PersonalSystemCenterPrimitives.swift`, docs | Social/family/admin console, hidden automation controls | Focused Profile/You tests/build if Swift changes | You trust/privacy/automation fixtures | Grouped navigation and settings summaries | Static grouped state changes | Manual/Suggest/Preview Reflow only unless later approved | Vague privacy controls, hidden automation |
| 3.8 Plan LifeShape Field | Map Plan/LifeShape to LifeShape Field with capacity/pressure/reflow. | `Native/Ambitions/Features/Plan/`, Plan preview fixtures/tests | Calendar-grid primary UI, silent rearrangement, analytics dashboard | Focused Plan tests/build if Swift changes | Week/default, pressure, denied calendar, reflow fixtures | Capacity/pressure source summaries | Before/after reflow summaries | Preview before meaningful change, receipt after apply | Calendar clone, red warning pressure system |
| 3.9 Goals Constellation Atlas + Orbital Lens | Map LifePath/Mission Control to Atlas/Lens; keep Mission Control inside Goal Detail. | `Native/Ambitions/Features/Goals/`, Goals preview fixtures/tests | Top-level Mission Control, KPI/ranking/habit/astrology model | Focused Goals tests/build if Swift changes | Atlas/Lens/life area fixtures | Ordered life areas and selected area accessible | Static selected state | Goal thread/source proof labels | Mission Control top-level or ranked life score |
| 3.10 Accessibility / Reduce Motion / Visual QA Hardening | Verify/add object-level summaries, motion equivalents, preview/QA docs. | `Sources/Accessibility/`, `Sources/Previews/`, feature docs/tests if scoped | Public conformance claims, screenshots unless explicitly generated | Focused accessibility/preview tests if available | Coverage table for all top-level surfaces | VoiceOver/Dynamic Type notes for each object | Reduce Motion coverage for each object | Receipt/trust discoverability | Claiming accessibility/performance without proof |

## Green / Yellow / Red Batch Report Template

```text
Status: Green / Yellow / Red

Batch:
- ...

Source truth read:
- ...

Files inspected:
- ...

Files changed:
- ...

Files intentionally not changed:
- ...

Validation run:
- command — exit code — evidence path or terminal evidence

Validation not run:
- ...

Accessibility / Reduce Motion:
- ...

Trust / source / receipt:
- ...

Canon enforced:
- ...

Yellow parked:
- owner:
- safety reason:
- no-claim boundary:

Red stop:
- ...

Next eligible batch:
- ...
```

## Canon Implementation Train Decision

The first safe run through Batches 3.1-3.10 should prefer inventory, mapping, and narrow additive source changes only when the current repo proves the boundary is isolated and validation can run. Broad object rewrites are not authorized by this plan.

## Recommended Next Phase

```text
Phase 3 — Implementation Train
```
