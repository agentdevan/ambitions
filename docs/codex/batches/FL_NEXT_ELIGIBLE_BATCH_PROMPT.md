# FL Next Eligible Batch Prompt
<!-- markdownlint-disable MD013 -->

Status: Reusable Codex prompt for FL01-FL06 Found Life Layer.
Date: 2026-05-05

Use this prompt when the global full-stack order selects the next eligible FL batch, or when the user says:

`Start Found Life Layer Train`

```markdown
You are operating in the Ambitions repo as a product-soul canon writer, AmbitionsOS architect, privacy/trust reviewer, ADHD/cognitive-load reviewer, and Codex OS batch operator.

Task:
Run exactly one next eligible Found Life Layer batch.

Do not run multiple FL batches unless the user explicitly requests continuous global execution.
Do not implement production Swift unless the selected FL batch explicitly permits it.
Do not add a new top-level tab.
Do not make unsupported runtime, AI, sync, memory, legal, privacy, App Store, or release claims.

Required source stack:
1. README.md
2. AGENTS.md
3. docs/canon/Ambitions_Found_Life_Layer.md
4. docs/codex/batch-trains/FL01_FL06_FOUND_LIFE_LAYER_TRAIN.md
5. docs/codex/FOUND_LIFE_LAYER_GATE_MATRIX.md
6. docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
7. docs/codex/GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md
8. docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md
9. docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md
10. docs/codex/BATCH_REGISTRY.md
11. docs/codex/CONTEXT_INDEX.md
12. .codex/reports/current-run-state.md
13. .codex/reports/current-batch-train-state.md
14. relevant FCP/AOS/LDI/PFC source truth if the batch references it
15. relevant CQS skills and scripts

Selection rule:
Select the next FL batch whose dependencies are complete and whose file scope is allowed.

Preflight:
1. State selected FL batch, owner, dependencies, allowed files, forbidden files, and stop conditions.
2. Run `git status --short`.
3. Inspect required source truth.
4. Verify Found Life is placed before FCP17 in the global order if this has not already happened.
5. Verify current run-state so no completed batch is overwritten or duplicated.

Implementation rules:
1. Keep Found Life as a layer under Today / Goals / Capture / Plan / You.
2. Preserve the locked tagline: `Find your life. Keep your promises. Build your future. Enjoy today.`
3. Preserve the product soul: lost in life, enjoying every day, wanting to become found while actively building goals.
4. Do not create dashboard, notes app, task dump, habit tracker, diary, CRM, LMS, career website, generic AI memory chatbot, or surveillance-feeling memory system.
5. Treat inferred memories and commitments as reviewable, not fact.
6. Require source/freshness/privacy/review path for recall and path recommendations.
7. Protect sensitive family, relationship, work, money, career, and health-adjacent context.
8. Keep Open Loop closure non-shaming.
9. Preserve option value when a user pivots.
10. Write docs so later FCP/AOS/LDI/PFC batches can implement without rethinking the concept.

Required validation:
- `git status --short`
- `git diff --check`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- Found Life drift scan if available
- no-claim scan
- verify no production Swift changed for docs-only FL batches
- verify no route/raw/persistence/schema/sync/cloud/monetization/legal/release/workflow/signing/CI files changed unless explicitly permitted

Batch report:
Write `docs/audits/flXX-<kebab-name>-report.md` with:
- Result
- selected batch
- dependency proof
- files read
- files changed
- Found Life object changes
- validation run
- privacy/source/trust status
- no-claim boundaries
- unresolved Yellow items
- rollback path
- next eligible batch

Stop on hard Red:
- sixth tab
- dashboard/life database/notes/task/habit/diary/chatbot drift
- surveillance-feeling memory model
- shame framing
- inferred memory presented as fact
- sensitive life data exposed without privacy gates
- unsupported legal/career/education/health/financial claim
- production behavior edited during docs-only batch
- source-truth conflict that affects safety

Final response must include:
- Result
- selected batch
- files changed
- validation result
- unresolved Yellow items
- rollback path
- next eligible batch
```
