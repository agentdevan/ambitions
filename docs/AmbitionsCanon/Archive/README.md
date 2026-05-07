# Ambitions Canon Archive / Supersession Index

Status: docs-only conflict and supersession index.

This archive index preserves older Ambitions design/product/canon sources as historical or supporting context when they conflict with the Ambitions Design System and the split Ambitions Canon Pack.

No existing docs were deleted during canon installation.

No app code, assets, Xcode settings, tests, CI, generated screenshots, or implementation files were modified.

---

## 1. Supersession Rule

The source-truth hierarchy installed in `docs/AmbitionsCanon/README.md` wins when older sources conflict:

1. Ambitions Design System
2. `docs/AmbitionsCanon/00_Canon_Index_10_10_Maturity_Gate.md`
3. `docs/AmbitionsCanon/01_Product_Canon.md`
4. `docs/AmbitionsCanon/02_Continuity_Layer_Chrome.md`
5. `docs/AmbitionsCanon/03_Signature_Object_Specs.md`
6. `docs/AmbitionsCanon/04_Trust_Privacy_Automation.md`
7. `docs/AmbitionsCanon/05_Accessibility_Motion_Performance.md`
8. `docs/AmbitionsCanon/06_QA_Preview_Visual_Drift.md`
9. `docs/AmbitionsCanon/07_Native_Shell_Tokens_Materials.md`
10. `docs/AmbitionsCanon/08_Implementation_Codex_Repo_Integration.md`
11. Visual references
12. Existing repo convenience

Older docs remain useful only as historical context, implementation evidence, stricter release/proof gates, or compatibility records where they do not conflict with this canon pack.

---

## 2. Existing Canon / Drift Sources Found

| Existing file | Risk | Action taken | Follow-up |
| --- | --- | --- | --- |
| `README.md` | Yellow: declares Ambitions 3.0 read order as current source of truth and describes Ambitions 4.0 execution status. This can conflict with the newly installed Ambitions Design System hierarchy if used as future product/design truth. | Not edited. Listed here as superseded where conflicting. | Future docs cleanup should add a short pointer to `docs/AmbitionsCanon/README.md` once source-truth migration is approved. |
| `docs/README.md` | Yellow: declares Ambitions 3.0 active rebuild documentation system and older PXOS/future canon structure. | Not edited. Listed here as superseded where conflicting. | Future docs cleanup should update the read order to include AmbitionsCanon. |
| `docs/canon/README.md` | Yellow: lists active 3.0 governance and visual/system docs as active canon. | Not edited. Listed here as superseded where conflicting. | Future docs cleanup should add AmbitionsCanon as the higher-level product/design source truth. |
| `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md` | Yellow: active 3.0 override supersedes older front-end material but is now lower priority than the Ambitions Design System and AmbitionsCanon pack for future visual/product direction. | Not edited. Listed here as superseded where conflicting. | Future cleanup should add a supersession note instead of rewriting history. |
| `docs/canon/Ambitions_Product_Experience_OS_Index.md` | Yellow: future PXOS canon already aligns with five tabs and anti-generic rules, but its object names and Product Depth framing may conflict with the newer Reality Meridian / Constellation Atlas / Atmosphere Composer / LifeShape Field / User System Profile model. | Not edited. Listed here as supporting context unless compatible. | Future orientation audit should map PXOS terms to AmbitionsCanon terms. |
| `docs/canon/Ambitions_Signature_Interface_System.md` | Yellow: useful future implementation canon, but its older primitive names such as DayTimelineRail, Hero Step Panel, LifePath View, and Personal System Center are superseded by AmbitionsCanon object names where conflicting. | Not edited. Listed here as supporting implementation context. | Future implementation prompts should cite AmbitionsCanon first, then map older SI primitive names carefully. |
| `docs/canon/Ambitions_3_0_Ambition_Meridian_Shell_SwiftUI_Build_Spec.md` | Yellow: older active shell build spec defines Ambition Meridian Shell; the new Continuity Layer / Chrome canon supersedes it where it conflicts with Context Crown, Meridian Edge, Continuity Dock, Trust Seam, and signal routing law. | Not edited. Listed here as superseded where conflicting. | Future shell audit should decide whether to adapt existing Meridian shell into Continuity Dock. |
| `docs/handoff/Ambitions_Product_Experience_Pack_Repo_Traceability_Map.md` | Yellow: useful planning/audit artifact with current repo file mapping, but it names older locked objects such as Reality Rail, LifePath View, LifeShape Map, and Personal System Center. | Not edited. Listed here as supporting evidence, not source truth. | Future Repo Phase 0 should reconcile this traceability map with AmbitionsCanon. |
| `Native/Ambitions/App/AppTab.swift` | Yellow app-code evidence only: current app enum includes compatibility cases `habits`, `insights`, and `profile` while active `allCases` resolves to five tabs and visible title for profile is You. | Not edited. App code modifications were forbidden. | Future implementation audit should distinguish internal compatibility cases from user-facing top-level tab canon. |

---

## 3. Conflict Handling Policy

Do not delete older docs unless unique content has been checked.

Do not bulk-rename source files or internal compatibility identifiers from this docs-only phase.

Do not treat visual references, generated images, old prompts, or prior Chrome & Behavior material as higher authority than the Ambitions Design System.

Any prior Chrome & Behavior material is superseded by `02_Continuity_Layer_Chrome.md` if it conflicts.

---

## 4. Hard Red Follow-Up Conditions

Future work must stop if:

1. an older doc is treated above the Ambitions Design System
2. Mission Control is promoted to a top-level tab
3. old Chrome & Behavior overrides the Continuity Layer
4. Start Here is rebuilt as a detached card
5. Capture becomes a plus-tab, feed, inbox, or chatbot
6. Plan becomes a calendar clone
7. Goals becomes a KPI dashboard, habit system, ranked score, or astrology map
8. You becomes a social profile, family hub, admin console, or search-first settings clone
9. implementation starts before Repo Phase 0 orientation evidence
10. release/readiness/completion claims are made without proof

---

## 5. Recommended Next Action

Next safe action:

```text
Repo Phase 0 — Orientation Audit
```

Repo Phase 0 should inspect current app source, docs, previews, tests, assets, shell, navigation, and feature files and produce an evidence-based map. It must not implement features.
