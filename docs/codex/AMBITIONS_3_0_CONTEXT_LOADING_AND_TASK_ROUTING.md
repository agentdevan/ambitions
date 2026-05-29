# Ambitions 3.0 Context Loading And Task Routing

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-39578311, AMB28-same_source_file_targeted_by_multiple_active_batches-56479248, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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

## Operating Protocol Routing

- Always classify task width with `docs/canon/Ambitions_3_0_Task_Width_And_Batch_Combining_Gate.md` and `.codex/operations/task-width-gate-protocol.md`.
- Use `.codex/operations/multi-primitive-batch-protocol.md` before combining primitives.
- Use `.codex/operations/ui-test-modernization-protocol.md` before changing failing UI tests after 3.0 canon changes.
- Use `.codex/operations/run-state-refresh-protocol.md` and `.codex/operations/large-batch-checkpoint-protocol.md` for L/XL or long-running work.
- Use `.codex/operations/release-claim-truth-protocol.md` before making implementation, test, device, accessibility, TestFlight, App Store, release, or handoff claims.
- Use `.codex/operations/human-approval-escalation-protocol.md` when runtime dependencies, persistence migrations, privacy model changes, app shell replacement, signed release, major navigation architecture, large historical deletions, or repeated validation failures enter scope.

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

## Developer Tool Routing

- Before major local work, run `scripts/validate-dev-tools.sh` or document why the missing tool is non-blocking.
- For docs-heavy changes, run `scripts/run-doc-qa.sh`; use strict mode only when the docs backlog is expected to be clean.
- For app build proof, prefer `scripts/build-local.sh` unless debugging a wrapper issue.
- For full local test proof, run `scripts/test-local.sh || true` and classify known UI smoke failures separately from new failures.
- When `Brewfile`, scripts, dependency docs, or workflow docs change, load `.codex/context-packs/dependency-management-context.md` and run `.codex/validation/dependency-drift-pack.md`.
- Before saying local validation mirrors CI, run `.codex/validation/local-ci-parity-pack.md`.

## Batch Train Orchestrator

When a prompt spans multiple Ambitions 3.0 batches, load `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`, select exactly one manifest under `docs/codex/batch-trains/`, initialize `.codex/reports/current-batch-train-state.md`, and continue only on Green. Yellow/Red stops with repair/resume material. FAANG handoff remains PARTIAL unless its gate is re-run and passes.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
