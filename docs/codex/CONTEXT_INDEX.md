# Ambitions Codex Context Index

This file defines the standing source-of-truth hierarchy for future Ambitions work. Use it before planning or implementing any non-trivial task.

## Current Operating Truth

- Product-decision Waves 1-19 are complete.
- Current execution status remains: Batches 00-88 and D01-D08 are complete for planning purposes; D09 / One-Step Goals Object Model is the next dependency-safe implementation batch from the Design Constitution delta/alignment backlog.
- D04 Panel Size + Display Density foundation exists as shared design-system support; future batches own broad surface adoption.
- D05 Receipt / Action Closure Search and Privacy Contract exists as a local-first receipt history/search foundation over existing Action Closure receipts, with typed filters, deterministic ordering, redacted/full-detail projections, privacy levels, safe-to-show flags, undo/proof/trust labels, and calm missing-detail fallback.
- D06 Smart Attachment Foundation exists as a local-first routing/confidence/clarification contract over Capture and Command, with deterministic bounded local classification, Needs a Place fallback, D05-compatible receipts, redacted/full-detail projections, and correction/change affordances.
- D07 Life Areas Overview / Atlas Object Model exists as a local-first Life Areas object/projection foundation over existing Life Graph domains and goals, with canonical labels, deterministic overview ordering, privacy-safe compact/redacted projection, accessibility labels/values/hints, and a minimal Goal Atlas preview adapter. It does not implement One-Step Goals, semantic zoom, a sixth tab, or broad surface redesign.
- D08 North Stars / Dormant Ambitions Object Model exists as a local-first North Star object/projection foundation under Life Areas, with calm posture states, deterministic grouping/counts, linked active-goal counts, privacy-safe compact/redacted projection, accessibility labels/values/hints, revival/shaping metadata, and relationship hooks for future goals, proof, decisions, receipts, reviews, and One-Step Goals. It does not implement One-Step Goal behavior, semantic zoom, new navigation, detail rails, or broad surface redesign.
- D01-D26 classification now lives in `docs/canon/ROADMAP_BATCH_CLASSIFICATION.md` and distinguishes launch-critical, soon-after-launch, post-launch, deferred, decision-gated, and infrastructure-unlock work.
- Original Batches 89-120 remain future planned roadmap work only through the classifications and dependencies in `docs/canon/Ambitions_2_0_Roadmap_Merge_Audit.md`.
- Post-D26 Layer 2/Layer 3 maturity planning now lives in `docs/canon/POST_D26_MATURITY_ROADMAP.md`. It rewrites original Batches 89-120 into M-series maturity batches and R-series release-readiness gates. It is planning only and does not mark D01-D26 complete.
- The locked top-level shell is `Today / Goals / Capture / Plan / You`.
- Launch-critical work must map to the Golden Launch Loop: capture, place, plan, do today, recover, save proof.
- Launch posture is local-first: no required account, no launch sync, export before sync.
- Archived and historical docs are context only. They do not override active canon.

## Required Read Order

For non-trivial work, read these in order before planning:

1. [AGENTS.md](../../AGENTS.md) and any more-specific scoped `AGENTS.md`.
2. [BATCH_REGISTRY.md](BATCH_REGISTRY.md) for active work status only.
3. [SOURCE_OF_TRUTH_MAP.md](../canon/SOURCE_OF_TRUTH_MAP.md) for document ownership and reading order.
4. [PRODUCT_DECISIONS.md](../canon/PRODUCT_DECISIONS.md) for resolved Waves 1-19 product decisions.
5. [GOLDEN_LAUNCH_LOOP.md](../canon/GOLDEN_LAUNCH_LOOP.md) for the smallest undeniable launch loop, launch-critical cutline, demo story, and product-strength rules.
6. [ROADMAP_BATCH_CLASSIFICATION.md](../canon/ROADMAP_BATCH_CLASSIFICATION.md) for D01-D26 launch-critical / post-launch / deferred / decision-gated classification.
7. [HUMAN_LANGUAGE_REVIEW.md](../canon/HUMAN_LANGUAGE_REVIEW.md) for user-facing language rules and AI/producty copy rejection.
8. [AMBITION_CANON_COMPLETION_REPORT.md](../canon/AMBITION_CANON_COMPLETION_REPORT.md) for completion status, open questions, no-drift rules, archive candidates, and next reconciliation prompt.
9. [DOCS_RECONCILIATION_REVIEW.md](../canon/DOCS_RECONCILIATION_REVIEW.md) when doing documentation cleanup, source-order updates, roadmap/batch reconciliation, or archive-candidate review.
10. [MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md) for current shipping product truth and product promise.
11. [Ambitions_Design_Constitution.md](../canon/design/Ambitions_Design_Constitution.md) for design, IA, UX writing, interaction, trust, accessibility, and external-surface authority.
12. [Ambitions_2_0_Object_Terminology.md](../canon/Ambitions_2_0_Object_Terminology.md) for shared object terminology.
13. [Ambitions_2_0_Product_Architecture.md](../canon/Ambitions_2_0_Product_Architecture.md) for surface ownership and drilldown rules.
14. [Ambitions_2_0_Systems_Architecture.md](../canon/Ambitions_2_0_Systems_Architecture.md) for shared engines, local-first systems, and system ownership.
15. [Ambitions_2_0_Visual_System.md](../canon/Ambitions_2_0_Visual_System.md) plus focused visual/design docs when UI or component work is involved.
16. Relevant focused canon docs listed in [SOURCE_OF_TRUTH_MAP.md](../canon/SOURCE_OF_TRUTH_MAP.md).
17. [Ambitions_2_0_Roadmap.md](../canon/Ambitions_2_0_Roadmap.md), [Ambitions_2_0_Batch_Plan.md](../canon/Ambitions_2_0_Batch_Plan.md), [Ambitions_2_0_Implementation_Gap_Audit.md](../canon/Ambitions_2_0_Implementation_Gap_Audit.md), and [Ambitions_2_0_Roadmap_Merge_Audit.md](../canon/Ambitions_2_0_Roadmap_Merge_Audit.md) for execution sequencing after source-map alignment.
18. [POST_D26_MATURITY_ROADMAP.md](../canon/POST_D26_MATURITY_ROADMAP.md) only when planning Layer 2/Layer 3 after D26, or when explicitly asked to plan post-D26 work without changing current D-batch status.
19. [FREE_WORKFLOW_OPERATING_SYSTEM.md](FREE_WORKFLOW_OPERATING_SYSTEM.md), [Ambitions_2_0_Codex_Execution_Guide.md](Ambitions_2_0_Codex_Execution_Guide.md), and [MASTER_CODEX_SYSTEM.md](MASTER_CODEX_SYSTEM.md) for Codex/process behavior.
20. [VISUAL_REVIEW_CHECKLIST.md](../review/VISUAL_REVIEW_CHECKLIST.md) when visible UI, navigation, empty states, copy, or hierarchy changes.
21. [FRICTION_LOG.md](../review/FRICTION_LOG.md) when observed product friction needs to be captured without expanding active scope.
22. [docs/README.md](../README.md), [canon/README.md](../canon/README.md), and [archive/README.md](../archive/README.md) for index/navigation support.

## Precedence Model

When sources conflict, use this precedence:

1. Direct user task instructions.
2. Root [AGENTS.md](../../AGENTS.md) and any more-specific scoped `AGENTS.md`.
3. [BATCH_REGISTRY.md](BATCH_REGISTRY.md) for operational status only.
4. [SOURCE_OF_TRUTH_MAP.md](../canon/SOURCE_OF_TRUTH_MAP.md) for document ownership and reading order.
5. [PRODUCT_DECISIONS.md](../canon/PRODUCT_DECISIONS.md) for resolved Waves 1-19 product decisions.
6. [GOLDEN_LAUNCH_LOOP.md](../canon/GOLDEN_LAUNCH_LOOP.md) for launch-critical scope and product-strength cutline.
7. [ROADMAP_BATCH_CLASSIFICATION.md](../canon/ROADMAP_BATCH_CLASSIFICATION.md) for D01-D26 classification and launch spine.
8. [POST_D26_MATURITY_ROADMAP.md](../canon/POST_D26_MATURITY_ROADMAP.md) for Layer 2/Layer 3 maturity sequencing after D26 only.
9. [HUMAN_LANGUAGE_REVIEW.md](../canon/HUMAN_LANGUAGE_REVIEW.md) for visible language quality.
10. [AMBITION_CANON_COMPLETION_REPORT.md](../canon/AMBITION_CANON_COMPLETION_REPORT.md) and [DOCS_RECONCILIATION_REVIEW.md](../canon/DOCS_RECONCILIATION_REVIEW.md) for post-canon reconciliation status and no-drift instructions.
11. [MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md) for shipping product truth where not superseded by later canon decisions.
12. [Ambitions_Design_Constitution.md](../canon/design/Ambitions_Design_Constitution.md) for design/IA/UX/trust/accessibility/external-surface authority.
13. Product, systems, visual, and focused canon docs listed in [SOURCE_OF_TRUTH_MAP.md](../canon/SOURCE_OF_TRUTH_MAP.md).
14. Roadmap, batch, gap, and merge-audit docs for sequencing after reconciliation.
15. Codex workflow docs for process behavior.
16. Review/friction docs for support only.
17. Archived and historical docs for context only.

## Active Source-Of-Truth Entry Points

Use these entry points instead of duplicating a separate active-doc list here:

- [SOURCE_OF_TRUTH_MAP.md](../canon/SOURCE_OF_TRUTH_MAP.md)
- [PRODUCT_DECISIONS.md](../canon/PRODUCT_DECISIONS.md)
- [GOLDEN_LAUNCH_LOOP.md](../canon/GOLDEN_LAUNCH_LOOP.md)
- [ROADMAP_BATCH_CLASSIFICATION.md](../canon/ROADMAP_BATCH_CLASSIFICATION.md)
- [HUMAN_LANGUAGE_REVIEW.md](../canon/HUMAN_LANGUAGE_REVIEW.md)
- [Ambitions_2_0_Object_Terminology.md](../canon/Ambitions_2_0_Object_Terminology.md)
- [POST_D26_MATURITY_ROADMAP.md](../canon/POST_D26_MATURITY_ROADMAP.md)
- [AMBITION_CANON_COMPLETION_REPORT.md](../canon/AMBITION_CANON_COMPLETION_REPORT.md)
- [DOCS_RECONCILIATION_REVIEW.md](../canon/DOCS_RECONCILIATION_REVIEW.md)
- [canon/README.md](../canon/README.md)
- [docs/README.md](../README.md)

## Historical / Archived Docs

- [archive/README.md](../archive/README.md) indexes superseded design/frontend transformation docs.
- Older roadmap, surgical, frontend-transformation, and continuity docs preserved in `docs/canon/` are historical/supporting only unless the source map says otherwise.
- Do not treat older batch prompts as runnable active prompts unless they have been reconciled against Waves 1-19, the Golden Launch Loop, Roadmap/Batch Classification, and the post-D26 maturity roadmap when relevant.

## Execution Guardrails

- Work on `main` only unless the user explicitly requests branch-based work.
- Do not create, switch to, or suggest branches for normal Ambitions execution.
- Do not skip ahead of the execution order in [BATCH_REGISTRY.md](BATCH_REGISTRY.md), [Ambitions_2_0_Batch_Plan.md](../canon/Ambitions_2_0_Batch_Plan.md), and the delta queue unless explicitly told otherwise.
- Do not start M01 or other post-D26 M/R work before D26 unless the user explicitly authorizes planning-only scenario preparation.
- Do not add top-level tabs casually.
- Do not reintroduce top-level Insights, Habits, Tasks, Calendar, Life Areas, or Profile tabs.
- Do not treat non-Golden-Launch-Loop work as launch-critical without explicit justification.
- Do not ignore the classifications in [ROADMAP_BATCH_CLASSIFICATION.md](../canon/ROADMAP_BATCH_CLASSIFICATION.md).
- Do not ignore [POST_D26_MATURITY_ROADMAP.md](../canon/POST_D26_MATURITY_ROADMAP.md) when planning or executing post-D26 M/R work.
- Do not rename canon casually.
- Do not implement fake capability.
- Do not claim sync, export, AI, accessibility, privacy, platform behavior, or production readiness before implementation evidence exists.
- Do not require an account at launch.
- Do not build launch sync.
- Do not paywall trust/privacy/data controls.
- Do not make external writes silently.
- Do not build surfaces before their owning engines/services exist.
- Do not build extension-heavy features before shared container, receipts, command, privacy, and external-surface boundaries exist.
- Do not build sync backend logic before export/import, trust, failure states, and conflict policy are strong.
- If an unresolved question is found, create a canon proposal or decision-log entry rather than silently implementing it.

## Next Operating Step

Continue with D09 - One-Step Goals Object Model unless the user explicitly changes the execution order. Post-D26 M/R work remains planning-only until D26 is complete or the user explicitly authorizes otherwise.
