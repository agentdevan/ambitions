# Resume Global Batch Train

Alias phrase: `resume global batch train`
Status: active Codex operating alias.
Scope: global batch-train continuation with repair loops until complete or unrecoverable Red.

## Purpose

When the user says `resume global batch train`, Codex must resume Ambitions global execution from repo evidence, not from chat memory, and continue the global batch train until every eligible batch is complete or an unrecoverable Red condition blocks safe continuation.

This alias exists so the user does not need to restate the full global orchestration prompt after compaction, usage interruption, local machine handoff, or Yellow repair-loop closure.

## Source-Truth Loading Order

Before doing any work, read:

1. `README.md`
2. `AGENTS.md`
3. `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`
4. `docs/codex/FLAGSHIP_IMPLEMENTATION_UPGRADE_OVERLAY.md`
5. `.codex/reports/current-run-state.md`
6. `.codex/reports/current-batch-train-state.md`
7. `docs/codex/BATCH_REGISTRY.md`
8. `docs/codex/CONTEXT_INDEX.md`
9. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
10. `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
11. target batch prompt and target train manifest
12. target canon/source files named by that batch

If these files disagree, use the active source hierarchy and repair stale dependent artifacts only where the newest proven repo evidence is clear. Do not silently choose between contradictory source-truth files.

## Immediate Resume Rule

The FIO01/PFC05A/DPTG00 governance package is complete / Green, hosted
workflows are intentionally absent, and current validation is local/Codex-
operated only. Physical-device proof is final-only, terminal-only, and blocked
until all pre-device gates close.

LDI01 Living Dream Architecture Source Truth is complete / Green as docs/Codex
OS source-truth and governance evidence. LDI02 Capture Handling Ladder is
complete / Green as a local value-model contract with focused tests. LDI03
Dream Safety Legality Feasibility Triage is the next eligible global batch
unless a later repo-truth update proves newer progress.

Required first-pass checks:

```bash
git status --short
git branch --show-current
git rev-parse HEAD
git log -1 --oneline
test ! -d .github/workflows
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
rg -n "FLAGSHIP_IMPLEMENTATION_UPGRADE_OVERLAY|DPTG00|Physical Device Terminal Gate|terminal-only" docs .codex README.md || true
rg -n "\.github/workflows|GitHub Actions|hosted CI|Actions artifact|ios-validate\.yml" README.md docs .codex || true
```

If active docs still instruct contributors to use GitHub Actions, hosted CI, Actions artifacts, or `.github/workflows/ios-validate.yml` as current validation, repair those active docs before marking the overlay Green.

If remaining mentions are historical, archived, removed-policy, or forbidden-current-proof references, classify them in the relevant audit/current-state note and continue.

## Current Known Resume Target

Current proven repo evidence before this alias selected:

- FIO01 / PFC05A / DPTG00 complete / Green.
- AOS17 Privacy Safety Kernel complete / Green.
- AOS18 Evaluation Golden Scenarios complete / Green.
- AOS19 Experience Kernel Celestial Cognitive Load complete / Green.
- AOS20 Adaptation Kernel Local Personalization complete / Green.
- AOS21 Interoperability Kernel App Intents EventKit Planning complete / Green.
- AOS22 Longevity Kernel Archive Aging complete / Green.
- AOS23 Governance Kernel Registry complete / Green.
- LDI01 Living Dream Architecture Source Truth complete / Green.
- LDI02 Capture Handling Ladder complete / Green.
- LDI03 Dream Safety Legality Feasibility Triage is the next eligible global batch unless newer
  repo evidence selects a later batch.

Continue to LDI03 unless a Hard Red or unrecoverable Red is found.

## Continuation Policy

Codex must continue automatically across eligible global batches when each batch is Green or accepted Yellow with explicit owner, reason, follow-up, and recheck condition.

Do not stop for ordinary Yellow advisories when they are non-blocking, owned, and evidence-bounded.

Stop only for Hard Red or unrecoverable Red.

## Repair Loop Policy

For every failing check:

1. Inspect the failure.
2. Classify it as expected advisory, unrelated pre-existing issue, repairable scoped failure, Hard Red, or unrecoverable Red.
3. Make the smallest targeted repair if it is in scope.
4. Rerun the relevant check.
5. Record proof and residual Yellow notes.
6. Continue the train if no Hard Red remains.

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
- commit/push/proof artifact creation fails and cannot be repaired locally

On unrecoverable Red, stop with a Red report and a copy/paste repair or decision prompt.

## Hard Constraints

Preserve:

- Ambitions canon
- top-level tabs: Today, Goals, Capture, Plan, You
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
3. Name exact allowed files before edits.
4. Execute the smallest safe implementation slice.
5. Run focused validation first.
6. Run required broader docs/scripts/build/tests when scoped.
7. Repair failures in loop.
8. Write or update the batch report.
9. Update registry/context/current-state/order files where safe.
10. Commit with a batch-specific message.
11. Select the next eligible batch from repo evidence.
12. Continue until complete or unrecoverable Red.

## Required Final Response Shape

Latest train checkpoint: LDI02 Capture Handling Ladder is complete Green as a
local value-model contract with focused tests. It does not implement UI
integration, route/raw-value changes, persistence/schema, sync/cloud, hosted
AI, user-data server, professional-advice behavior, release/device proof,
legal/privacy compliance proof, public accessibility proof, or full LDI runtime
behavior. LDI03 is next unless repo evidence shows later progress.

At each visible checkpoint, report:

- Batch status: Green / Yellow / Red
- Current train state before the batch
- Files changed
- Implementation summary
- Tests/checks run
- Proof artifacts
- Hard Reds, if any
- Yellow advisories, if any
- Registry/context/current-state updates
- Next eligible global batch
- Whether the train is continuing or stopped
