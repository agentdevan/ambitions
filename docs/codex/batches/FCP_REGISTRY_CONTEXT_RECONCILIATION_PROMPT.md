# FCP Registry / Context Reconciliation Prompt
<!-- markdownlint-disable MD013 -->

Status: Safe local Codex reconciliation prompt for the FCP source-truth package.
Date: 2026-05-05

Use this prompt after pulling the commits that added:

- `docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md`
- `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md`
- `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md`
- `docs/codex/batches/FCP_NEXT_ELIGIBLE_BATCH_PROMPT.md`
- `docs/audits/flagship-completion-plan-source-truth-report.md`

```markdown
You are operating in the Ambitions repo.

Task:
Safely reconcile the newly added Ambitions 10/10 Flagship Completion Plan source-truth package into the operational registry, context index, and run-state files.

This is docs-only reconciliation.
Do not implement Swift.
Do not edit production app code.
Do not change routes, raw values, persistence/schema, dependencies, workflows, signing, entitlements, generated project files, or CI.
Do not claim FCP implementation has started.
Do not claim release readiness, App Store readiness, TestFlight readiness, physical-device proof, public accessibility proof, AI/LDI runtime, durable memory behavior, sync/cloud behavior, export/delete behavior, or legal/privacy signoff.

Required read stack:
1. docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md
2. docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md
3. docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md
4. docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md
5. docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md
6. docs/audits/flagship-completion-plan-source-truth-report.md
7. docs/codex/BATCH_REGISTRY.md
8. docs/codex/CONTEXT_INDEX.md
9. .codex/reports/current-run-state.md
10. .codex/reports/current-batch-train-state.md
11. docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md

Required edits:

1. Update `docs/codex/BATCH_REGISTRY.md` with a short FCP planning-truth section under Ambitions 4.0 Execution Program Status:
   - FCP01-FCP30 Flagship Completion Plan source truth is created as docs-only planning truth.
   - FCP implementation has not started.
   - FCP is queued behind PD15-PD18 by default unless explicitly inserted by user approval.
   - FCP targets 25 major objects and app-wide 10/10 audit closure.
   - No production Swift, route/raw, persistence/schema, dependency/workflow/signing/CI, release/platform/accessibility/privacy/AI/runtime claim is authorized by the docs alone.

2. Update `docs/codex/CONTEXT_INDEX.md`:
   - Add the FCP source-truth files to the read order for flagship/product-object work.
   - Add a current operating truth bullet: FCP source truth exists; FCP implementation is queued and not started.
   - Add `docs/codex/batches/FCP_NEXT_ELIGIBLE_BATCH_PROMPT.md` as the implementation prompt only after user phrase `Start Flagship Completion Train`.

3. Update `.codex/reports/current-run-state.md`:
   - Preserve Active train: Product Depth and Current batch: PD14 complete / Green unless a later local state proves otherwise.
   - Add a section titled `Flagship Completion Plan Source Truth` noting FCP package exists and implementation has not started.
   - State recommended next active implementation remains PD15 unless explicit user instruction inserts FCP ahead of PD15.

4. Update `.codex/reports/current-batch-train-state.md` with the same lightweight FCP source-truth note while preserving Product Depth state.

5. Write `docs/audits/fcp-registry-context-reconciliation-report.md` with:
   - Result
   - files read
   - files changed
   - validation run
   - no-claim boundaries
   - unresolved Yellows
   - next eligible batch recommendation

Required validation:
- `git status --short`
- `git diff --check`
- verify no production Swift files changed
- verify no route/raw/persistence/schema/workflow/dependency/signing/entitlement/CI files changed
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- scan edited files for unsupported release/platform/accessibility/privacy/AI/runtime claims

Stop on Red:
- any production Swift edit
- any route/raw/persistence/schema/workflow/dependency/signing/CI edit
- registry says FCP implementation started without an implementation batch
- registry displaces Product Depth truth without explicit user instruction
- any unsupported claim
- any unresolved doc conflict

Final response must include:
- Result
- files changed
- validation run
- unresolved Yellow items
- next eligible batch
```
