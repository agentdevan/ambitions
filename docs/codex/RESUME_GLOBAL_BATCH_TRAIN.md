# Resume Global Batch Train

Alias phrase: `resume global batch train`
Status: active Codex operating alias.
Scope: global batch-train continuation with repair loops until complete or unrecoverable Red.

## Purpose

When the user says `resume global batch train`, Codex must resume Ambitions global execution from repo evidence, not from chat memory, and continue the global batch train until every eligible batch is complete or an unrecoverable Red condition blocks safe continuation.

For model-tier-specific execution, prefer:

- `resume mini global batch train` for Mini Execution Tier / `gpt-5.4-mini` runs.
- `resume senior global batch train` for Senior Judgment Tier / `gpt-5.5` or stronger selected-model runs.

The generic alias still loads model-tier policy so unknown-tier sessions do not accidentally close senior-only gates.

## Source-Truth Loading Order

Before doing any work, read:

1. `README.md`
2. `AGENTS.md`
3. `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`
4. `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`
5. `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`
6. `docs/codex/FLAGSHIP_IMPLEMENTATION_UPGRADE_OVERLAY.md`
7. `.codex/reports/current-run-state.md`
8. `.codex/reports/current-batch-train-state.md`
9. `docs/codex/BATCH_REGISTRY.md`
10. `docs/codex/CONTEXT_INDEX.md`
11. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
12. `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
13. `docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md` when the live full-stack tail has cleared or a blocking hygiene Red explicitly selects RHC
14. target batch prompt and target train manifest
15. target canon/source files named by that batch

If these files disagree, use the active source hierarchy and repair stale dependent artifacts only where the newest proven repo evidence is clear. Do not silently choose between contradictory source-truth files.

## Model-Tier Rule

If the active model is known, record it in the batch report. If the model is unknown, record `model tier: unknown` and apply Mini-safe restrictions.

- Mini / unknown tier may execute only Mini-safe batches.
- Mini / unknown tier must defer non-blocking senior-only batches to `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`.
- Mini / unknown tier must stop on blocking senior-only prerequisites.
- Senior tier must inspect and resolve blocking deferrals before final closeout or judgment-heavy continuation.

## Current Resume Target

Do not trust this section over live repo evidence. The live target must be selected from `.codex/reports/current-run-state.md`, `.codex/reports/current-batch-train-state.md`, `docs/codex/BATCH_REGISTRY.md`, and `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`.

Current repo evidence at the time this alias was refreshed:

- AFI01-AFI08 are complete / Accepted Yellow.
- AFI source truth controls product/IA/UI/visual/copy decisions.
- Active flagship IA is `Today / Goals / Capture / Time / You`.
- `Plan` is superseded as a top-level destination and remains valid only as contextual/action language or internal compatibility seam.
- AFI09 Time LifeShape Field is the next eligible global batch unless newer repo evidence shows a dirty/half-complete batch, blocking prerequisite, or senior-only model-tier stop.
- LDI01-LDI14 have closed Green in current order evidence; LDI15-LDI22 remain queued after AFI unless global order or dependency proof selects otherwise.

## Required First-Pass Checks

```bash
git status --short
git branch --show-current
git rev-parse HEAD
git log -1 --oneline
test ! -d .github/workflows
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
scripts/global-train-next-batch.sh || true
rg -n "MODEL_TIER_EXECUTION_POLICY|RESUME_MINI_GLOBAL_BATCH_TRAIN|RESUME_SENIOR_GLOBAL_BATCH_TRAIN|MODEL_TIER_DEFERRAL_LEDGER" AGENTS.md docs/codex .codex || true
rg -n "\.github/workflows|GitHub Actions|hosted CI|Actions artifact|ios-validate\.yml" README.md docs .codex || true
```

If active docs still instruct contributors to use GitHub Actions, hosted CI, Actions artifacts, or `.github/workflows/ios-validate.yml` as current validation, repair those active docs before marking any validation overlay Green.

If remaining mentions are historical, archived, removed-policy, or forbidden-current-proof references, classify them in the relevant audit/current-state note and continue.

## Queued Repo Hygiene Closeout

RHC01-RHC06 Repo Hygiene Closeout is queued but must not interrupt unfinished AFI/LDI/AOS/FCP/PFC/PK work. Codex may select RHC only after the active full-stack tail clears or when a Hard Red proves repo hygiene blocks the active batch and the repair is limited to the blocking owner files.

RHC source truth:

- `docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md`
- `docs/codex/batches/RHC01_Repo_Hygiene_Triage_And_Owner_Map_Prompt.md`
- `docs/codex/batches/RHC02_Large_File_Extraction_And_Module_Boundary_Prompt.md`
- `docs/codex/batches/RHC03_Placeholder_Stub_And_Compatibility_Seam_Cleanup_Prompt.md`
- `docs/codex/batches/RHC04_Stale_Copy_Docs_And_Generated_Artifact_Hygiene_Prompt.md`
- `docs/codex/batches/RHC05_Validation_Script_Noise_And_Allowlist_Hardening_Prompt.md`
- `docs/codex/batches/RHC06_Repo_Hygiene_Closeout_And_Handoff_Prompt.md`

RHC must preserve local/Codex-operated validation, avoid hosted workflows, avoid release/platform/legal/privacy/device/public-accessibility claims, and never delete or rename route/raw-value/persistence/external-surface compatibility seams without owner proof and focused tests.

## Continuation Policy

Codex must continue automatically across eligible global batches when each batch is Green or accepted Yellow with explicit owner, safety reason, follow-up, and recheck condition.

Do not stop for ordinary Yellow advisories when they are non-blocking, owned, and evidence-bounded.

Stop for Hard Red or unrecoverable Red. Mini / unknown tier also stops for blocking senior-only prerequisites.

## Repair Loop Policy

For every failing check:

1. Inspect the failure.
2. Classify it as expected advisory, unrelated pre-existing issue, repairable scoped failure, Hard Red, model-tier deferral, or unrecoverable Red.
3. Make the smallest targeted repair if it is in scope.
4. Rerun the relevant check.
5. Record proof and residual Yellow notes.
6. Continue the train if no Hard Red or blocking senior-only gate remains.

Do not widen scope to unrelated cleanup. Do not weaken validators to pass. Do not fabricate proof.

## Unrecoverable Red Definition

Unrecoverable Red means one of:

- required source-truth file missing with no safe fallback
- source-truth hierarchy conflict that cannot be resolved from repo evidence
- forbidden file boundary required for progress but not authorized
- production/app/release/privacy/legal/platform claim would be needed without evidence
- workflow files cannot be removed or are reintroduced
- active docs still require hosted workflows as current proof and repair is blocked
- build/focused-test/validator failure cannot be repaired without broad unauthorized refactor
- dependency, signing, entitlement, persistence/schema, release, sync/cloud, AI runtime, or LDI runtime change is required but not authorized by the current batch
- privacy, memory, source, safety, or release-claim ambiguity requires human decision
- Mini / unknown tier reaches a blocking senior-only gate
- commit/push/proof artifact creation fails and cannot be repaired locally

On unrecoverable Red, stop with a Red report and a copy/paste repair or decision prompt.

## Hard Constraints

Preserve:

- Ambitions canon
- top-level tabs: Today, Goals, Capture, Time, You
- `Plan` only as contextual/action language or internal compatibility seam
- Start Here Surface as Today flagship object
- Capture as minimalist and composer-driven
- Mission Control as Goals detail, not a top-level tab
- Action Closure / recovery language instead of binary overdue/failure framing
- local/Codex-operated validation only
- terminal-only physical-device proof
- no hosted workflow files

Never introduce dashboard, generic task app, stacked-card, inbox/feed/notes-app, PM board, calendar clone, sci-fi shell, chatbot wrapper, productivity score, trophy/streak, confidence percentage, unsupported release claim, or unsupported platform/device/legal/privacy/accessibility claim drift.

## Per-Batch Execution Contract

For each batch:

1. Confirm repo state.
2. Read source truth.
3. Classify model tier and Mini-safe status when relevant.
4. Name exact allowed files before edits.
5. Execute the smallest safe implementation slice.
6. Run focused validation first.
7. Run required broader docs/scripts/build/tests when scoped.
8. Repair failures in loop.
9. Write or update the batch report.
10. Update registry/context/current-state/order files where safe.
11. Update model-tier deferral ledger when a Mini/Senior split is created or closed.
12. Commit with a batch-specific message.
13. Select the next eligible batch from repo evidence.
14. Continue until complete, deferred, or unrecoverable Red.

## Required Final Response Shape

At each visible checkpoint, report:

- Model tier used
- Batch status: Green / accepted Yellow / Deferred / Red
- Current train state before the batch
- Files changed
- Implementation summary
- Tests/checks run
- Proof artifacts
- Senior-only gates encountered
- Deferrals created or closed
- Hard Reds, if any
- Yellow advisories, if any
- Registry/context/current-state/ledger updates
- Next eligible global batch
- Whether the train is continuing or stopped
