# Ambitions Docs Reconciliation Review

Status: Active post-canon documentation reconciliation review.

Date: 2026-04-28.

Purpose: Review the repository documentation after Waves 1-19 canon completion and identify contradictions, stale terminology, shipped/planned/deferred ambiguity, duplicate/overlapping docs, archive candidates, required updates, and the next Codex-safe reconciliation edit pass.

This is a docs review, not app implementation.

No app code was changed.
No docs were deleted.
No docs were archived.
No new product canon was invented.

---

## 1. Executive Summary

The repo is directionally aligned after Waves 1-19, but it still needs a documentation reconciliation edit pass.

The strongest remaining problems are documentation-control problems, not product-definition problems:

1. `docs/codex/CONTEXT_INDEX.md` still uses the older post-Batch-60 read order and does not start with the completed Waves 1-19 source-of-truth structure.
2. `docs/archive/README.md` still lists an older active source-of-truth set and omits the new canon completion/reporting docs.
3. `docs/codex/batches/README.md` describes the batch docs as historical but also says they are future work, and labels older frontend transformation docs as `Canon Sources`.
4. `docs/codex/BATCH_REGISTRY.md` is operationally useful but still links older continuity docs in a way that could be mistaken for active canon unless softened.
5. `README.md` is mostly accurate, but its canonical planning stack should now start with `SOURCE_OF_TRUTH_MAP.md`, `PRODUCT_DECISIONS.md`, and `AMBITION_CANON_COMPLETION_REPORT.md`.
6. Active roadmap and batch docs are mostly careful about planned/future language, but they still need a full reconciliation pass against Waves 1-19 to mark items as shipped, planned, deferred, duplicate, superseded, or needs-canon-proposal.
7. Historical docs preserved inside `docs/canon/` remain useful, but several should become archive candidates after roadmap/batch reconciliation confirms unique content has been migrated.

The correct next action is an edit pass, not another question wave.

---

## 2. Active Docs Reviewed

Primary control and index docs reviewed:

- `docs/codex/BATCH_REGISTRY.md`
- `docs/canon/SOURCE_OF_TRUTH_MAP.md`
- `docs/canon/PRODUCT_DECISIONS.md`
- `docs/canon/AMBITION_CANON_COMPLETION_REPORT.md`
- `docs/README.md`
- `docs/canon/README.md`
- `README.md`
- `docs/archive/README.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/batches/README.md`

Roadmap / batch / audit docs reviewed:

- `docs/canon/Ambitions_2_0_Roadmap.md`
- `docs/canon/Ambitions_2_0_Batch_Plan.md`
- `docs/canon/Ambitions_2_0_Implementation_Gap_Audit.md`
- `docs/canon/Ambitions_2_0_Roadmap_Merge_Audit.md`
- `docs/canon/Documentation_Cleanup_Audit.md`
- `docs/implementation-backlog.md`

Search/review coverage also checked references to:

- `Profile`
- `Insights`
- `Habits`
- `account sync`
- old frontend batch docs
- old continuity docs
- active external-surface docs

Focused canon set was not rewritten during this review. It was treated as the active target canon defined by `SOURCE_OF_TRUTH_MAP.md`.

---

## 3. Contradictions Found

| Finding | File path | Issue | Severity | Recommended update |
| --- | --- | --- | --- | --- |
| Old read order conflicts with completed Waves 1-19 source map. | `docs/codex/CONTEXT_INDEX.md` | Required read order starts with `AGENTS.md`, free workflow, and older Ambitions 2.0 docs before `SOURCE_OF_TRUTH_MAP.md`, `PRODUCT_DECISIONS.md`, and `AMBITION_CANON_COMPLETION_REPORT.md`. This conflicts with the new source map where the operating sequence begins with registry/status, source map, decision ledger, and completion report. | Required now | Update read order and precedence model to incorporate Waves 1-19 canon completion. |
| Archive index has stale active source-of-truth list. | `docs/archive/README.md` | The archive readme still lists the older source-of-truth set and omits `SOURCE_OF_TRUTH_MAP.md`, `PRODUCT_DECISIONS.md`, `AMBITION_CANON_COMPLETION_REPORT.md`, and focused canon docs. | Required now | Update archive README to point users back to the current source map and canon index, not a stale partial list. |
| Historical batch folder has mixed status language. | `docs/codex/batches/README.md` | The file says the folder contains historical completed pre-Batch-61 work, but also says “These docs are future work only.” It also labels older transformation docs as `Canon Sources`. | Required now | Rewrite as historical execution docs only; relabel old sources as historical/supporting, not active canon. |
| Registry still exposes older preserved continuity docs near active queue. | `docs/codex/BATCH_REGISTRY.md` | The registry links old continuity docs under “Older preserved continuity docs.” It does say the canonical planning stack wins, but after Waves 1-19 those links should be clearly labeled historical/supporting and not active canon. | Required now | Add a stronger note that these older docs are not active source of truth and future prompts should start from `SOURCE_OF_TRUTH_MAP.md`. |
| Root README active stack is now incomplete. | `README.md` | The canonical planning stack starts at `CONTEXT_INDEX.md` and lists older Ambitions 2.0 files, but omits `SOURCE_OF_TRUTH_MAP.md`, `PRODUCT_DECISIONS.md`, and `AMBITION_CANON_COMPLETION_REPORT.md`. | Required now | Add the Waves 1-19 source-control docs above the older product/roadmap docs. |
| Canon index omits this review until indexed. | `docs/canon/README.md` | After this file is created, it must be indexed so future docs work can discover it. | Required now | Add `DOCS_RECONCILIATION_REVIEW.md` to active consolidation canon or active supporting canon. |
| Root docs index omits this review until indexed. | `docs/README.md` | After this file is created, it must be indexed near the completion report. | Required now | Add `DOCS_RECONCILIATION_REVIEW.md` to the “Start here” and active consolidation sections. |

---

## 4. Stale Terminology Found

These are not all code bugs. Some are acceptable compatibility names, but they should not leak into future user-facing canon.

| Term | File path(s) | Issue | Handling |
| --- | --- | --- | --- |
| `Profile` | `Native/Ambitions/Features/Profile/*`, `Native/Ambitions/Domain/ProfileModels.swift`, `Native/AmbitionsTests/Profile/*`, `docs/canon/YOU_PROFILE_REVIEWS.md`, historical batch docs | Current canon allows `Profile` as legacy compatibility terminology during migration only. Code folders/tests may remain until owning migration batch. | Later implementation cleanup; do not rename casually. Ensure new user-facing docs say `You`. |
| `Insights` | `Native/Ambitions/Features/Insights/*`, `Native/Ambitions/Domain/InsightsModels.swift`, `README.md`, `MASTER_PRODUCT_SPEC.md`, historical batch docs | Current canon says analytics live in `You -> Reviews / Patterns`, and Insights must not return as a top-level tab. Internal compatibility may remain. | Later cleanup. Active docs should call this contextual intelligence/reviews unless referring to legacy code. |
| `Habits` | `Native/Ambitions/Features/Habits/*`, `Native/Ambitions/Domain/HabitsModels.swift`, `docs/codex/batches/README.md`, historical batch docs | Current canon says habits live as rituals in Plan / Today / Goal Detail, not as a top-level Habits tab. Existing code may remain compatibility/legacy until Ritual split alignment. | Later D16/Ritual split cleanup. Do not treat as top-level IA. |
| `Tasks` as a standalone top-level idea | historical batch docs, roadmap/batch references, possible code comments | Current canon allows `Task` as standalone One-Step Goal, but not a top-level Tasks tab. | D02/D09 cleanup. Every active doc should distinguish Task vs Step. |
| `AI` / model language | older Codex/batch docs, intelligence-related historical docs | Current canon says normal UI should not expose AI/model language. Docs can discuss internal intelligence only with no fake capability claims. | Keep in implementation/governance docs only; avoid product UI language. |

---

## 5. Shipped / Planned / Deferred Ambiguity Found

| Area | File path | Ambiguity | Recommended status treatment |
| --- | --- | --- | --- |
| Widgets / Live Activities | `README.md`, `docs/codex/BATCH_REGISTRY.md`, `docs/canon/Ambitions_2_0_Roadmap.md`, `docs/canon/Ambitions_2_0_Batch_Plan.md` | Repo has scaffolding and some productized foundations, but platform verification remains incomplete. Current wording is mostly conservative, but future docs need consistent `planned/deferred unless verified` labels. | Planned/deferred for production-ready claims; scaffolded/foundation when referencing code. |
| App Intents / Shortcuts | `README.md`, `BATCH_REGISTRY.md`, `EXTERNAL_SURFACES_NOTIFICATIONS_WIDGETS.md` | Existing scaffolding exists, but Wave 14 requires capture support, receipts, privacy, and confirmation alignment before full claims. | Foundation/scaffolded now; planned alignment in D22/D25. |
| Export / import | `README.md`, `DATA_LOCAL_SYNC_EXPORT.md`, `BATCH_REGISTRY.md`, `Ambitions_2_0_Batch_Plan.md` | Existing portable backup/restore or snapshot foundations appear in history, but Wave 15 says export should not be claimed before implementation and should support user-selectable categories. | Treat basic foundations as existing only where evidenced; product export/import remains planned unless implemented and user-facing. |
| Sync | `README.md`, `BATCH_REGISTRY.md`, `Ambitions_2_0_Roadmap.md`, `Ambitions_2_0_Batch_Plan.md` | Batch 12 says `Sync-trust foundation` completed, but Wave 15 says no launch sync and sync later only after trust/export are strong. | Always label as boundary/foundation or future decision. Do not imply launch sync. |
| Accessibility Nutrition | `Documentation_Cleanup_Audit.md`, `Ambitions_2_0_Implementation_Gap_Audit.md`, `ACCESSIBILITY_FOCUS_SUPPORT.md` | Infrastructure exists, but verification and user-facing claims are still future. | Internal infrastructure shipped; user-facing verified claims deferred. |
| You / Profile migration | `README.md`, `BATCH_REGISTRY.md`, `YOU_PROFILE_REVIEWS.md`, code paths | User-facing You exists, but code and tests remain Profile-backed. | Shipped as user-facing You foundation; Profile-to-You code migration planned. |
| Roadmap launch scope | `Ambitions_2_0_Roadmap.md`, `Ambitions_2_0_Batch_Plan.md`, `LAUNCH_SCOPE_MVP_QUALITY_BAR.md` | Roadmap still spans broad 2.0 maturity through sync, widgets, path intelligence, RC lock. Wave 17 narrows launch proof to one meaningful goal organized into a believable execution system. | Reconcile roadmap into launch-critical vs post-launch/deferred phases. |

---

## 6. Roadmap / Batch Reconciliation Findings

| Finding | File path | Issue | Recommendation |
| --- | --- | --- | --- |
| D01 is still the next implementation batch, but docs reconciliation is now the immediate docs task. | `BATCH_REGISTRY.md`, `SOURCE_OF_TRUTH_MAP.md`, `AMBITION_CANON_COMPLETION_REPORT.md` | Operational queue says D01 is next dependency-safe implementation batch. Source map/completion report say next phase is roadmap/batch reconciliation. Both can be true, but this docs reconciliation should be recorded as a docs-only pass before D01. | Add a docs-only note after this review: post-canon docs reconciliation review complete; D01 remains next implementation batch after reconciliation edits. |
| Batches 61-88 are complete for planning, but not all have equally strong validation evidence. | `BATCH_REGISTRY.md` | Rows 73-82 are “marked complete for planning by repo-wide status correction” and warn not to infer feature validation. | Keep status, but reconciliation should preserve weaker-evidence notes and avoid claiming stronger implementation truth. |
| Original Batches 89-120 remain future/resequenced. | `BATCH_REGISTRY.md`, `Ambitions_2_0_Roadmap_Merge_Audit.md` | This is correct, but roadmap/batch docs need consistent shipped/planned/deferred tagging. | Required later: roadmap/batch reconciliation edit pass. |
| Batch plan still contains old ready-to-paste prompts for completed batches. | `Ambitions_2_0_Batch_Plan.md` | Historical prompts are useful but can confuse future Codex sessions if copied casually. | Add a stronger historical-prompt warning or move old prompts behind a clear historical section later. |
| Roadmap milestone language remains broad. | `Ambitions_2_0_Roadmap.md` | Milestones B-D mention sync, widgets, Live Activities, Path Intelligence, etc. That is fine as future roadmap intent, but Wave 17 launch scope is narrower. | Add launch-critical / post-launch / deferred classification. |

---

## 7. Duplicate / Overlapping Docs

These should not be archived yet. They should be reviewed after the reconciliation edit pass.

| Docs / area | Overlap | Suggested handling |
| --- | --- | --- |
| `Ambitions_2_0_Decision_Log.md` and `PRODUCT_DECISIONS.md` | Two decision-ledger concepts now exist. `PRODUCT_DECISIONS.md` is the Waves 1-19 ledger. | Later: mark `Ambitions_2_0_Decision_Log.md` as legacy/supporting or merge unique entries into the new ledger. |
| `CANON_CONSOLIDATION_GAP_AUDIT.md`, `AMBITION_CANON_COMPLETION_REPORT.md`, and this review | All discuss documentation gaps, but at different stages. | Keep all for now. This review is the post-Wave docs reconciliation review. |
| `Documentation_Cleanup_Audit.md` and this review | Cleanup audit predates Waves 1-19; this review supersedes some of its “current” hygiene status. | Later: update or mark as pre-Wave-19 cleanup baseline. |
| `Ambitions_OS_Master_Roadmap.md`, `Ambitions_Surgical_Execution_Plan.md`, `Ambitions_Codex_Batch_Plan.md` | Older roadmap/execution planning overlaps active roadmap, batch plan, and governance docs. | Later archive candidates after unique content migration check. |
| `Ambitions_Full_Frontend_Transformation_Program.md`, `Ambitions_Frontend_Batches_49_60_Revised.md`, `docs/codex/batches/batch-39.md` through `batch-59.md` | Older frontend transformation planning overlaps active visual/system/canon docs. | Historical only; candidate for stronger archive classification or moved index once unique references are migrated. |
| `Ambitions_App_Store_Release_Compliance.md`, `Ambitions_Launch_Master_Checklist.md`, launch operator runbooks, release candidate checklists | Multiple launch/release readiness surfaces overlap with Wave 17 launch scope and release docs. | Later reconcile into launch-critical vs App Store operations vs historical checklist. |
| `Ambitions_Accessibility_Nutrition_Labels_Audit.md`, `Ambitions_2_0_Accessibility_Nutrition.md`, `ACCESSIBILITY_FOCUS_SUPPORT.md`, acceptance gates | Accessibility docs overlap; new canon separates product posture from verification infrastructure. | Keep all for now; later classify exact owner for user-facing claims vs internal verification. |

---

## 8. Archive Candidates, Not Archived Yet

Archive candidates after roadmap/batch reconciliation:

- `docs/canon/Ambitions_OS_Master_Roadmap.md`
- `docs/canon/Ambitions_Surgical_Execution_Plan.md`
- `docs/canon/Ambitions_Codex_Batch_Plan.md`
- `docs/canon/Ambitions_State_Continuity_Mesh.md`
- `docs/canon/Ambitions_Product_Addendum_Continuity_Reality_Execution.md`
- `docs/canon/Ambitions_Frontend_Batches_49_60_Revised.md`
- `docs/canon/Ambitions_Full_Frontend_Transformation_Program.md`
- `docs/canon/Ambitions_App_Store_Release_Compliance.md`
- `docs/canon/Ambitions_Launch_Master_Checklist.md`
- `docs/canon/Ambitions_Accessibility_Nutrition_Labels_Audit.md`
- `docs/codex/batches/batch-39.md` through `docs/codex/batches/batch-59.md`, if not already treated as historical enough

Do not archive until:

1. roadmap/batch reconciliation is complete
2. unique content has been migrated or explicitly preserved
3. indexes and backlinks are updated
4. active source-of-truth docs no longer depend on the candidate

---

## 9. Docs That Require Updates

### Required now

| File | Required update |
| --- | --- |
| `docs/codex/CONTEXT_INDEX.md` | Add `SOURCE_OF_TRUTH_MAP.md`, `PRODUCT_DECISIONS.md`, `AMBITION_CANON_COMPLETION_REPORT.md`, and `DOCS_RECONCILIATION_REVIEW.md` to the top of read order. Update precedence model for Waves 1-19. |
| `docs/archive/README.md` | Replace stale active source-of-truth list with a pointer to `SOURCE_OF_TRUTH_MAP.md` and `canon/README.md`; do not maintain a partial duplicated active list. |
| `docs/codex/batches/README.md` | Clarify historical-only status. Remove or rename `Canon Sources` section to `Historical sources / context`. |
| `README.md` | Add current canon-control docs to canonical planning stack. Keep compatibility-naming note. |
| `docs/canon/README.md` | Add this review file to the active consolidation/review set. |
| `docs/README.md` | Add this review file near the completion report and source map. |

### Required in the next reconciliation edit pass

| File | Required update |
| --- | --- |
| `docs/canon/Ambitions_2_0_Roadmap.md` | Mark launch-critical, post-launch, future, deferred, and decision-gated work more explicitly against Waves 1-19. |
| `docs/canon/Ambitions_2_0_Batch_Plan.md` | Add a post-Wave-19 warning that old prompts are historical unless reconciled; align next step with docs reconciliation then D01. |
| `docs/codex/BATCH_REGISTRY.md` | Add a docs-only reconciliation status note; keep D01 as next implementation batch after reconciliation. |
| `docs/canon/Documentation_Cleanup_Audit.md` | Mark as pre-Wave-19 cleanup baseline or update with the new review result. |
| `docs/canon/Ambitions_2_0_Decision_Log.md` | Clarify relationship to `PRODUCT_DECISIONS.md`. |

### Later / optional

| File / area | Optional update |
| --- | --- |
| historical canon docs in `docs/canon/` | Move to archive or add stronger historical notices after unique content migration check. |
| batch files 39-59 | Keep historical, but reduce their visibility as active prompts. |
| `.codex` operational docs | Review only if active Codex behavior conflicts with Waves 1-19. |

---

## 10. Docs That Should Not Be Touched In This Review

Do not edit these in this review unless a specific contradiction is found later:

- `docs/canon/PRODUCT_DECISIONS.md`
- `docs/canon/SOURCE_OF_TRUTH_MAP.md`
- `docs/canon/AMBITION_CANON_COMPLETION_REPORT.md`
- focused canon docs such as `IA_NAVIGATION_DRILLDOWN.md`, `DATA_LOCAL_SYNC_EXPORT.md`, `LAUNCH_SCOPE_MVP_QUALITY_BAR.md`, `ROADMAP_BATCH_GOVERNANCE.md`
- app source files under `Native/Ambitions/`
- tests under `Native/AmbitionsTests/` and `Native/AmbitionsUITests/`
- archived docs under `docs/archive/`

Those files are either already current or outside the scope of this docs-only review.

---

## 11. Remaining Canon Proposals Needed

None are required to complete this documentation review.

Still-open product decisions from the canon completion report remain open and should not be silently implemented:

- exact free-tier limits and pricing
- exact launch must-ship vs defer list
- exact export format and categories
- exact sync provider/path, if any
- exact Focus Support controls
- exact accessibility verification matrix
- exact widget/Live Activity scope, if later shipped
- exact Profile-to-You code migration plan
- exact archive list after reconciliation

---

## 12. Recommended Next Codex Prompt For The Edit Pass

```markdown
We are in the Ambitions repo on `main`.

Task: Perform the documentation reconciliation edit pass based on `docs/canon/DOCS_RECONCILIATION_REVIEW.md`.

Do not implement app code.
Do not delete docs.
Do not archive docs yet.
Do not invent new product canon.
Do not change the product roadmap scope beyond labeling and source-of-truth reconciliation.

Read first:
1. `docs/canon/SOURCE_OF_TRUTH_MAP.md`
2. `docs/canon/PRODUCT_DECISIONS.md`
3. `docs/canon/AMBITION_CANON_COMPLETION_REPORT.md`
4. `docs/canon/DOCS_RECONCILIATION_REVIEW.md`
5. `docs/README.md`
6. `docs/canon/README.md`
7. `README.md`
8. `docs/codex/CONTEXT_INDEX.md`
9. `docs/codex/BATCH_REGISTRY.md`
10. `docs/archive/README.md`
11. `docs/codex/batches/README.md`
12. `docs/canon/Ambitions_2_0_Roadmap.md`
13. `docs/canon/Ambitions_2_0_Batch_Plan.md`
14. `docs/canon/Documentation_Cleanup_Audit.md`
15. `docs/canon/Ambitions_2_0_Decision_Log.md`

Required updates:
- Update `docs/codex/CONTEXT_INDEX.md` so Waves 1-19 source map, decisions, completion report, and docs reconciliation review are in the top read order and precedence model.
- Update `docs/archive/README.md` so it points to `SOURCE_OF_TRUTH_MAP.md` and does not duplicate a stale active source-of-truth list.
- Update `docs/codex/batches/README.md` so historical frontend batch docs are clearly historical only, not future runnable prompts or active canon sources.
- Update `README.md` so the canonical planning stack starts with `SOURCE_OF_TRUTH_MAP.md`, `PRODUCT_DECISIONS.md`, and `AMBITION_CANON_COMPLETION_REPORT.md`.
- Update `docs/canon/README.md` and `docs/README.md` to include `DOCS_RECONCILIATION_REVIEW.md`.
- Add a docs-only reconciliation note to `docs/codex/BATCH_REGISTRY.md`; keep D01 as the next implementation batch after reconciliation.
- Do not edit app code.
- Do not archive docs.

Optional only if safe and minimal:
- Add a short notice to `Documentation_Cleanup_Audit.md` that it is a pre-Wave-19 cleanup baseline.
- Add a short notice to `Ambitions_2_0_Decision_Log.md` that `PRODUCT_DECISIONS.md` is the active Waves 1-19 decision ledger.

Acceptance gates:
- No product canon is invented.
- No app code changes.
- No docs are deleted or archived.
- The locked shell remains Today / Goals / Capture / Plan / You.
- Local-first launch, no required account, no launch sync, and export-before-sync posture remain intact.
- Historical docs are clearly separated from active source-of-truth docs.
- Roadmap/batch docs still preserve completed history while preventing future Codex drift.

Completion summary must list changed files, skipped files, validation performed, remaining archive candidates, and remaining unresolved decisions.
```

---

## 13. Validation Performed

- Read active source map, completion report, docs indexes, registry, roadmap, batch plan, implementation gap audit, merge audit, archive index, root README, Codex context index, implementation backlog, and batch docs index.
- Searched repo for stale terminology and compatibility names: `Profile`, `Insights`, `Habits`, `account sync`.
- Created this review file only.
- No app code validation was run because no app code was changed.

---

## 14. Bottom Line

The repo does not need more product-definition waves.

It needs a controlled docs edit pass that updates source-of-truth routing, historical-doc labeling, and roadmap/batch shipped/planned/deferred language. After that pass, D01 remains the next dependency-safe implementation batch unless a later explicit user decision changes the execution order.
