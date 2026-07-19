# Frontend Missing Screen Audit

Status: Current-main missing screen audit / Implemented Yellow
Date: 2026-07-05
Scope: AMB-1751
Baseline SHA: `9885e8fbd32089c872376b47ff2aa8ab9b338afd`

## Missing Or Evidence-Limited Screens

| Area | Current state | Classification | Why it is not Green | Exact follow-up |
| --- | --- | --- | --- | --- |
| Rendered root shell proof | Source routes exist, and AMB-1749 defines screenshot lanes. No current AMB-1751 screenshot was produced. | docs-only in this pass | Source route evidence cannot prove visual quality, safe areas, hit targets, or device rendering. | Run root shell screenshot proof under AMB-1751-FU-01 when testing is re-enabled. |
| Today action proof | Today root and sheets exist. State-gated action journeys were not run. | partial-source-present | No current mutation, receipt, accessibility announcement, or screenshot proof for each closure/recovery state. | AMB-1751-FU-03 against `Native/Ambitions/Surfaces/Today/Overlays/` and runtime receipt owners. |
| Goals detail proof | Goals root, life-area detail, and goal-detail routes exist. | partial-source-present | No current rendered proof that all details open and return inside the Goals owner. | AMB-1751-FU-04 against `Native/Ambitions/Surfaces/Goals/` and `Native/Ambitions/Stage/StageRoute.swift`. |
| Time Life Calendar proof | Time root, rituals, and weekly review exist. | partial-source-present | No current rendered proof of calendar-grade layout, Dynamic Type, Reduce Motion, or permission boundary. | AMB-1751-FU-06 against `Native/Ambitions/Surfaces/Time/`. |
| You detail availability proof | You detail routes exist for many settings/control rows. | partial-source-present | No current row-by-row proof that every visible row opens real detail or honest unavailable state. | AMB-1751-FU-08 against `Native/Ambitions/Surfaces/You/`. |
| Search result proof | Search overlay source exists and filters trusted handoffs. | partial-source-present | No current proof for result quality, no-result Capture fallback, stale destination blocker, or local-only boundary. | AMB-1751-FU-09 against `Native/Ambitions/Stage/Overlays/` and `Native/Ambitions/App/ShellCommandRouter.swift`. |
| Capture keyboard/save proof | Global Capture source exists as overlay/seam and composer surface. | partial-source-present | No current proof for keyboard clearance, save mutation, placement review, or focus restoration. | AMB-1751-FU-10 against `Native/Ambitions/Composer/Capture/` and `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift`. |
| Proof/Privacy/Receipt invocation paths | Wrapper views exist. | partial-source-present | Wrapper source alone does not prove concrete user invocation from owning objects. | AMB-1751-FU-11, AMB-1751-FU-13, AMB-1751-FU-14 under `Native/Ambitions/Trust/`. |
| Source inspection proof | Source inspection view exists. | partial-source-present | No current rendered proof of redaction, accessibility-size behavior, or Source Atlas public/private boundary. | AMB-1751-FU-12 under `Native/Ambitions/Trust/` and `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/`. |
| External routes | Deep-link and external-source registry exists. | partial-source-present | No current runtime proof for each external source. | AMB-1751-FU-15 against `Native/Ambitions/App/AppDeepLinkRegistry.swift`, `Native/Ambitions/App/AppExternalRouting.swift`, and external snapshot owners. |
| Preview/VSP artifacts | Multiple historical screenshot and Figma/VSP artifacts exist. | prototype / docs-only | They can inform direction but do not prove current SwiftUI runtime. | Quarantine or link them as design references only; do not use them as current runtime proof. |

## Screens Not Missing As Source

Current production source contains active owners for:

- Root shell and dock
- Today root
- Goals root
- Goal detail
- Life area detail
- Create goal
- Time root
- Time rituals
- Weekly review
- You root
- You detail rows
- History inspection
- Global Capture composer
- Search / Memory Lens
- Proof, Source, Privacy, and Receipt inspection wrappers

Those screens are not missing as source. Their proof ceiling remains Yellow until
the exact rendered/runtime/accessibility/device evidence is produced.

## Dead Route Result

No current canonical root route is missing for Today, Goals, Time, or You.
Capture and Motion are intentionally absent as root routes. Proof, Source,
Privacy, History, and Receipts are intentionally absent as root routes.
