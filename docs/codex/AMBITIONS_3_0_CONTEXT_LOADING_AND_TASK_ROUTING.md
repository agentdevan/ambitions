# Ambitions 3.0 Context Loading And Task Routing

Status: Active Codex routing guide

## Source Order

1. `README.md`
2. `docs/README.md`
3. `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
4. `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
5. `docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md`
6. `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
7. `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
8. `docs/canon/Ambitions_3_0_Product_Language_System.md`
9. The target Ambitions 3.0 primitive, surface, state-machine, privacy, accessibility, QA, release, or dependency doc.
10. `docs/codex/BATCH_REGISTRY.md` for implementation status truth only.

## Choosing A Context Pack

- Default/docs/governance: `.codex/context-packs/minimal-default-context.md`
- Today/Reality Rail: `.codex/context-packs/today-reality-rail-context.md`
- Capture/Placement: `.codex/context-packs/capture-placement-context.md`
- Plan: `.codex/context-packs/plan-life-suite-context.md`
- Goals: `.codex/context-packs/goals-mission-control-context.md`
- You/Trust/Memory: `.codex/context-packs/you-trust-memory-context.md`
- Shell/Meridian: `.codex/context-packs/shell-meridian-context.md`
- Closure/Proof/Receipts: `.codex/context-packs/action-closure-proof-receipts-context.md`
- Recommendations/AI: `.codex/context-packs/ai-recommendation-context.md`
- Privacy/Accessibility: `.codex/context-packs/privacy-accessibility-context.md`
- External surfaces: `.codex/context-packs/external-surfaces-context.md`
- Release: `.codex/context-packs/release-readiness-context.md`
- Dependencies: `.codex/context-packs/dependency-management-context.md`

## Avoiding Huge Context Loads

Read the required source order, one context pack, and only the target docs/files named by the pack. Use `rg` for exact symbols and identifiers. Do not read all canon or all batches unless the task is a source-truth audit.

## When To Inspect Code

Inspect code when a claim is about implemented behavior, validation failure, routing, state, UI, persistence, project wiring, dependency boundaries, or release evidence.

## When To Run Tests

Run tests after code, project, routing, persistence, domain, UI, privacy, accessibility, or App Intent changes. Docs-only changes usually need scans and `git diff --check`, not full tests.

## Focused Vs Full Validation

Run focused validation first. Escalate to full build/test when touching shared shell, routing, project config, persistence, external surfaces, release gates, or cross-surface primitives.

## Avoiding Broad Rewrites

Name touch budget. Use existing seams. Do not migrate all internal identifiers just because a scan finds them; follow migration playbooks and tests.

## Escalation Path

Docs -> source inspection -> focused code/test -> broader validation -> report. Do not jump from docs directly to large implementation.

## Partial Completion

Report PARTIAL when validation fails, tooling is unavailable, or release/device/accessibility evidence is missing. Do not launder PARTIAL into PASS.

## Stale Batch References

Use `BATCH_REGISTRY.md` for status only. Use 3.0 F-series canon for next active implementation work.

## Status Distinctions

Canonized, designed, implementation-scoped, implemented, previewed, tested, device-verified, and release-ready are distinct states.
