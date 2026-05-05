# FL02 Life Inventory Object Model Prompt
<!-- markdownlint-disable MD013 -->

Status: Completed Green on 2026-05-05.
Train: FL01-FL06 Found Life Layer.
Type: Docs/domain contract.

## Purpose

Run FL02 to define the Life Inventory object model, ownership map, privacy classification, and surface mapping for Found Life.

FL02 is docs-only. It does not implement a memory database, search runtime, sync behavior, production Swift, schema, navigation, or new top-level surface.

## Required Source Truth

1. `docs/canon/Ambitions_Found_Life_Layer.md`
2. `docs/codex/batch-trains/FL01_FL06_FOUND_LIFE_LAYER_TRAIN.md`
3. `docs/codex/FOUND_LIFE_LAYER_GATE_MATRIX.md`
4. `docs/audits/fl01-founder-backstory-product-soul-lock-report.md`
5. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
6. `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
7. `docs/codex/BATCH_REGISTRY.md`
8. `docs/codex/CONTEXT_INDEX.md`
9. `.codex/reports/current-run-state.md`
10. `.codex/reports/current-batch-train-state.md`

## Locked FL02 Decisions

- Life Inventory contains reviewable life threads, not an all-at-once dashboard.
- Life threads require state, source state, freshness, privacy class, owner surface, review path, proof links, and visibility rule.
- Inferred candidate threads are not fact.
- Sensitive/private threads cannot surface externally by default.
- Life Inventory maps to Today, Capture, Goals, Plan, You, Memory Lens, AmbitionsOS, and LDI without creating a sixth tab.

## Allowed Files

- `docs/canon/Ambitions_Found_Life_Layer.md`
- `docs/codex/batch-trains/FL01_FL06_FOUND_LIFE_LAYER_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/batches/FL02_Life_Inventory_Object_Model_Prompt.md`
- `docs/audits/fl02-life-inventory-object-model-report.md`

## Forbidden Files

- Production Swift files.
- Route/raw-value files.
- Persistence/schema files.
- Sync/cloud files.
- Monetization files.
- Legal/release claim files.
- Workflow/signing/CI files.
- Generated project files.

## Acceptance

- Life thread object fields are defined.
- Life thread states, source states, freshness, privacy classes, owner surfaces, and review paths are defined.
- Surface mapping covers Today, Capture, Goals, Plan, You, Memory Lens, AOS, and LDI.
- No dashboard, all-at-once life database, hidden automation, or runtime claim is introduced.

## Next Batch

FL03 Commitment Memory / Open Loop Registry.
