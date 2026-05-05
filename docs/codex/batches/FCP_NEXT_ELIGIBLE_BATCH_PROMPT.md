# FCP Next Eligible Batch Prompt
<!-- markdownlint-disable MD013 -->

Status: Reusable Codex prompt for the Ambitions 10/10 Flagship Completion Plan.
Date: 2026-05-05

Use this prompt only after FCP source truth has been committed and the user explicitly says:

`Start Flagship Completion Train`

Do not use this prompt to run multiple FCP batches at once.

```markdown
You are operating in the Ambitions repo as a FAANG-caliber iPhone product implementation team, SwiftUI architecture team, design systems team, trust/privacy reviewer, accessibility reviewer, and Codex OS batch operator.

Task:
Run exactly one next eligible Ambitions Flagship Completion Plan batch.

Do not run multiple FCP batches.
Do not skip dependencies.
Do not broaden scope.
Do not edit unrelated files.
Do not make release/platform/accessibility/AI/privacy/sync/cloud/export/delete claims without evidence.

Required source stack:
1. README.md
2. AGENTS.md
3. docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md
4. docs/canon/Ambitions_Product_Experience_OS_Index.md
5. docs/canon/PXOS_Surface_Hierarchy_And_Navigation.md
6. docs/canon/Ambitions_Signature_Interface_System.md
7. docs/canon/Ambitions_Product_Depth_Canon_Inventory_And_Ownership_Map.md
8. docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md
9. docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md
10. docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md
11. docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md
12. docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md
13. docs/codex/BATCH_REGISTRY.md
14. docs/codex/CONTEXT_INDEX.md
15. .codex/reports/current-run-state.md
16. .codex/reports/current-batch-train-state.md
17. current source files and tests for the selected batch owner
18. existing PD/SI/DAV/EB/ME/CS reports relevant to the selected object

Selection rule:
Select only the next eligible FCP batch whose dependencies are complete and whose owner files are allowed by the FCP file-boundary map. If Product Depth is still active and PD15-PD18 remain incomplete, stop and report whether user approval explicitly inserted FCP ahead of PD15. Without explicit insertion approval, recommend continuing Product Depth instead of running FCP implementation.

Preflight:
1. State selected batch, owner, dependencies, and allowed file set.
2. Run `git status --short`.
3. Inspect all required source truth.
4. Inspect owner files.
5. Inspect existing focused tests and previews.
6. Inspect relevant `.codex/skills/*`.
7. State hard stop conditions for this batch.

Implementation rules:
1. Implement only the selected batch.
2. Preserve Today / Goals / Capture / Plan / You.
3. Preserve route/raw-value/persistence/schema/import/export/widget/AppIntent compatibility unless the batch explicitly permits changes and CS gates pass.
4. Preserve dependency, workflow, signing, entitlement, and CI boundaries unless explicitly approved.
5. Prefer small reusable SwiftUI primitives with state models and previews.
6. Do not create generic cards, dashboards, settings dumps, calendar clones, inbox/feed modes, habit/streak/trophy systems, chatbot wrappers, fake confidence scores, or silent automation.
7. Every meaningful recommendation, placement, reflow, proof, closure, correction, or mutation must expose source/trust/privacy/receipt behavior.
8. Every meaningful motion must have a reduced-motion equivalent.
9. Every status must have non-color meaning.
10. Add or update focused tests.
11. Add or update previews/state matrices.

Required validation:
- `git status --short`
- `git diff --check`
- `xcodegen generate` if project generation may be affected
- focused `xcodebuild` tests for changed owner files
- `scripts/build-local.sh`
- product drift scan
- copy/release-claim scan
- accessibility and Reduce Motion advisory scan
- file-size/diff-size review
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Batch report:
Write `docs/audits/fcpXX-<kebab-name>-report.md` with:
- Result: PASS / GREEN, PASS WITH ACCEPTED YELLOW, or RED
- selected batch
- dependency proof
- files read
- files changed
- product object changes
- tests/previews added or updated
- validation run
- accessibility / reduced-motion proof
- trust/source/privacy/receipt proof
- release-claim status
- file-size/diff-size status
- unresolved Yellow items
- rollback path
- next eligible batch

Registry/context updates:
Only after successful validation, update docs/codex/BATCH_REGISTRY.md, docs/codex/CONTEXT_INDEX.md, .codex/reports/current-run-state.md, and .codex/reports/current-batch-train-state.md to record the completed FCP batch. Do not overwrite Product Depth truth unless the user explicitly inserted FCP ahead of PD15.

Stop immediately on Red:
- new top-level tab
- top-level card stack/dashboard/grid/calendar clone/inbox/feed/settings dump
- unsupported release/platform/accessibility/AI/privacy/legal/export/delete/sync/cloud claim
- hidden mutation or silent automation
- weak validation
- missing focused tests
- source-truth conflict
- route/raw/persistence/schema compatibility break
- file-size Red without extraction plan
- privacy-sensitive VoiceOver leak
- color-only or motion-only meaning

Final response must include:
- Result
- selected batch
- files changed
- tests run
- validation result
- unresolved Yellow items
- rollback path
- next eligible batch
```
