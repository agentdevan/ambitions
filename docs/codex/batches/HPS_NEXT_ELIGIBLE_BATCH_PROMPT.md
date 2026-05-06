# HPS Next Eligible Batch Prompt
<!-- markdownlint-disable MD013 -->

Status: Reusable Codex prompt for HPS01-HPS12.
Date: 2026-05-06

```markdown
You are operating in the Ambitions repo as a full FAANG-level product, iOS, AI systems, privacy, platform, design, QA, and strategy organization.

Task:
Run exactly one next eligible HPS batch unless the active global prompt authorizes continuous global execution.

Do not implement production Swift unless the selected HPS batch explicitly permits it.
Do not add a new tab, dashboard, vertical product, marketplace, hosted AI backend, user-data server, or unsupported legal/release/acquisition claim.

Required source stack:
1. README.md
2. AGENTS.md
3. docs/canon/Ambitions_Human_Progress_Systems_Upgrade.md
4. docs/codex/batch-trains/HPS01_HPS12_HUMAN_PROGRESS_SYSTEMS_UPGRADE_TRAIN.md
5. docs/codex/HPS_GATE_MATRIX.md
6. docs/codex/HPS_CROSS_TRAIN_INTEGRATION_MAP.md
7. docs/codex/HPS_CODEX_OS_UPGRADE_MAP.md
8. docs/codex/HPS_MOAT_AND_ACQUISITION_READINESS_MAP.md
9. docs/codex/GLOBAL_HPS_COMPLETION_ORDER_OVERLAY.md
10. docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
11. docs/codex/GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md
12. docs/codex/BATCH_REGISTRY.md
13. docs/codex/CONTEXT_INDEX.md
14. .codex/reports/current-run-state.md
15. .codex/reports/current-batch-train-state.md
16. docs/canon/Ambitions_Found_Life_Layer.md
17. docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md
18. docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md
19. relevant CQS and FVQ source truth

Preflight:
1. Run `git status --short`.
2. Confirm current live state and do not replay completed batches.
3. Select the next eligible HPS batch.
4. State selected batch, owner, dependencies, allowed files, forbidden files, validation requirements, and stop conditions.

Implementation law:
- HPS strengthens the operating system; it does not widen the app.
- One app. Five tabs. One daily Start Here.
- HPS primitives are internal substrate unless a later UI batch explicitly exposes a restrained object.
- No dashboard, no KPI board, no generic card stack, no AI theater, no hidden mutation.
- Every recommendation/proof/source/memory/dream claim requires source/freshness/privacy/review path where relevant.
- Every UI-affecting later batch needs rendered proof.

Required validation:
- `git status --short`
- `git diff --check`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- `scripts/hps-no-sprawl-scan.sh || true`
- `scripts/hps-moat-coverage-scan.sh || true`
- `scripts/hps-claim-boundary-scan.sh || true`
- relevant CQS scripts

Report:
Write `docs/audits/hpsXX-<kebab-name>-report.md` with:
- Result
- batch ID
- files read
- files changed
- HPS primitives touched
- HPS gates invoked
- no-sprawl proof
- five-tab coherence proof
- validation run
- Yellow items
- Hard Red status
- rollback path
- next eligible batch

Stop on Hard Red:
- top-level tab creation
- dashboard/productivity/KPI sprawl
- production Swift changed without scope
- hidden mutation
- privacy leak
- source-free recommendation/proof/path claim
- unsupported legal/release/App Store/TestFlight/acquisition/hosted-AI claim
- vertical product implementation
- severe Ambitions canon drift

Final response:
- Result
- selected batch
- files changed
- validation result
- unresolved Yellow items
- next eligible batch
```
