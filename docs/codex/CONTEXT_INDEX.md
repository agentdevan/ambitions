# Ambitions Codex Context Index

This file defines the standing source-of-truth hierarchy for future Ambitions work. Use it before planning or implementing any non-trivial task.

## Current Operating Truth

- Product-decision Waves 1-19 are complete.
- The next phase is documentation/roadmap/batch reconciliation, then D01 implementation.
- Current execution status remains: Batches 00-88 are complete for planning purposes; D01 is the next dependency-safe implementation batch from the Design Constitution delta/alignment backlog.
- Original Batches 89-120 remain future planned roadmap work only through the classifications and dependencies in `docs/canon/Ambitions_2_0_Roadmap_Merge_Audit.md`.
- The locked top-level shell is `Today / Goals / Capture / Plan / You`.
- Launch posture is local-first: no required account, no launch sync, export before sync.
- Archived and historical docs are context only. They do not override active canon.

## Required Read Order

For non-trivial work, read these in order before planning:

1. [AGENTS.md](../../AGENTS.md) and any more-specific scoped `AGENTS.md`.
2. [BATCH_REGISTRY.md](BATCH_REGISTRY.md) for active work status only.
3. [SOURCE_OF_TRUTH_MAP.md](../canon/SOURCE_OF_TRUTH_MAP.md) for document ownership and reading order.
4. [PRODUCT_DECISIONS.md](../canon/PRODUCT_DECISIONS.md) for resolved Waves 1-19 product decisions.
5. [AMBITION_CANON_COMPLETION_REPORT.md](../canon/AMBITION_CANON_COMPLETION_REPORT.md) for completion status, open questions, no-drift rules, archive candidates, and next reconciliation prompt.
6. [DOCS_RECONCILIATION_REVIEW.md](../canon/DOCS_RECONCILIATION_REVIEW.md) when doing documentation cleanup, source-order updates, roadmap/batch reconciliation, or archive-candidate review.
7. [MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md) for current shipping product truth and product promise.
8. [Ambitions_Design_Constitution.md](../canon/design/Ambitions_Design_Constitution.md) for design, IA, UX writing, interaction, trust, accessibility, and external-surface authority.
9. [Ambitions_2_0_Product_Architecture.md](../canon/Ambitions_2_0_Product_Architecture.md) for surface ownership and drilldown rules.
10. [Ambitions_2_0_Systems_Architecture.md](../canon/Ambitions_2_0_Systems_Architecture.md) for shared engines, local-first systems, and system ownership.
11. [Ambitions_2_0_Visual_System.md](../canon/Ambitions_2_0_Visual_System.md) plus focused visual/design docs when UI or component work is involved.
12. Relevant focused canon docs listed in [SOURCE_OF_TRUTH_MAP.md](../canon/SOURCE_OF_TRUTH_MAP.md).
13. [Ambitions_2_0_Roadmap.md](../canon/Ambitions_2_0_Roadmap.md), [Ambitions_2_0_Batch_Plan.md](../canon/Ambitions_2_0_Batch_Plan.md), [Ambitions_2_0_Implementation_Gap_Audit.md](../canon/Ambitions_2_0_Implementation_Gap_Audit.md), and [Ambitions_2_0_Roadmap_Merge_Audit.md](../canon/Ambitions_2_0_Roadmap_Merge_Audit.md) for execution sequencing after source-map alignment.
14. [FREE_WORKFLOW_OPERATING_SYSTEM.md](FREE_WORKFLOW_OPERATING_SYSTEM.md), [Ambitions_2_0_Codex_Execution_Guide.md](Ambitions_2_0_Codex_Execution_Guide.md), and [MASTER_CODEX_SYSTEM.md](MASTER_CODEX_SYSTEM.md) for Codex/process behavior.
15. [VISUAL_REVIEW_CHECKLIST.md](../review/VISUAL_REVIEW_CHECKLIST.md) when visible UI, navigation, empty states, copy, or hierarchy changes.
16. [FRICTION_LOG.md](../review/FRICTION_LOG.md) when observed product friction needs to be captured without expanding active scope.
17. [docs/README.md](../README.md), [canon/README.md](../canon/README.md), and [archive/README.md](../archive/README.md) for index/navigation support.

## Precedence Model

When sources conflict, use this precedence:

1. Direct user task instructions.
2. Root [AGENTS.md](../../AGENTS.md) and any more-specific scoped `AGENTS.md`.
3. [BATCH_REGISTRY.md](BATCH_REGISTRY.md) for operational status only.
4. [SOURCE_OF_TRUTH_MAP.md](../canon/SOURCE_OF_TRUTH_MAP.md) for document ownership and reading order.
5. [PRODUCT_DECISIONS.md](../canon/PRODUCT_DECISIONS.md) for resolved Waves 1-19 product decisions.
6. [AMBITION_CANON_COMPLETION_REPORT.md](../canon/AMBITION_CANON_COMPLETION_REPORT.md) and [DOCS_RECONCILIATION_REVIEW.md](../canon/DOCS_RECONCILIATION_REVIEW.md) for post-canon reconciliation status and no-drift instructions.
7. [MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md) for shipping product truth where not superseded by later canon decisions.
8. [Ambitions_Design_Constitution.md](../canon/design/Ambitions_Design_Constitution.md) for design/IA/UX/trust/accessibility/external-surface authority.
9. Product, systems, visual, and focused canon docs listed in [SOURCE_OF_TRUTH_MAP.md](../canon/SOURCE_OF_TRUTH_MAP.md).
10. Roadmap, batch, gap, and merge-audit docs for sequencing after reconciliation.
11. Codex workflow docs for process behavior.
12. Review/friction docs for support only.
13. Archived and historical docs for context only.

## Active Source-Of-Truth Entry Points

Use these entry points instead of duplicating a separate active-doc list here:

- [SOURCE_OF_TRUTH_MAP.md](../canon/SOURCE_OF_TRUTH_MAP.md)
- [PRODUCT_DECISIONS.md](../canon/PRODUCT_DECISIONS.md)
- [AMBITION_CANON_COMPLETION_REPORT.md](../canon/AMBITION_CANON_COMPLETION_REPORT.md)
- [DOCS_RECONCILIATION_REVIEW.md](../canon/DOCS_RECONCILIATION_REVIEW.md)
- [canon/README.md](../canon/README.md)
- [docs/README.md](../README.md)

## Historical / Archived Docs

- [archive/README.md](../archive/README.md) indexes superseded design/frontend transformation docs.
- Older roadmap, surgical, frontend-transformation, and continuity docs preserved in `docs/canon/` are historical/supporting only unless the source map says otherwise.
- Do not treat older batch prompts as runnable active prompts unless they have been reconciled against Waves 1-19.

## Execution Guardrails

- Work on `main` only unless the user explicitly requests branch-based work.
- Do not create, switch to, or suggest branches for normal Ambitions execution.
- Do not skip ahead of the execution order in [BATCH_REGISTRY.md](BATCH_REGISTRY.md), [Ambitions_2_0_Batch_Plan.md](../canon/Ambitions_2_0_Batch_Plan.md), and the delta queue unless explicitly told otherwise.
- Do not add top-level tabs casually.
- Do not reintroduce top-level Insights, Habits, Tasks, Calendar, Life Areas, or Profile tabs.
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

Finish the documentation-control cleanup identified in [DOCS_RECONCILIATION_REVIEW.md](../canon/DOCS_RECONCILIATION_REVIEW.md), then resume implementation with D01 unless the user explicitly changes the execution order.
