<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`PK15-FINALIZE-01`

# Runner Command

```bash
ALLOW_DIRTY=1 ALLOW_MAIN_COMMIT=1 AUTO_BRANCH=0 make batch BATCH=PK15-FINALIZE-01 PROMPT=prompts/batches/PK15-FINALIZE-01.md
```

# Objective

Finalize the existing PK15 receipt-backend work from the current dirty worktree without rerunning PK15 from scratch, without relaunching the global conductor, and without re-entering the Spark implementation loop that caused the previous overlap/lock failure.

This is a **PK15 finalization / review / closeout batch**.

The current repo state is expected to contain unresolved PK15 source/test work under:

```text
Native/Ambitions/Persistence/*
Native/AmbitionsTests/Persistence/ActionReceiptHistoryRepositoryTests.swift
```

The goal is to inspect the existing PK15 diff, verify whether it is bounded and valid, run focused validation sequentially, classify any unrelated full-suite failure honestly, and either:

1. close and commit PK15 as Green or accepted Yellow, or
2. stop Red with rollback instructions if the PK15 diff is unsafe.

Do **not** rerun the original PK15 implementation batch.
Do **not** rerun Spark implementation from scratch.
Do **not** run the global train.
Do **not** invoke nested `make batch`.
Do **not** start another PK15 child runner.
Do **not** broaden PK15.
Do **not** fix unrelated failures unless PK15 caused them.
Do **not** claim full-suite Green unless proven.

---

# Ambitions Standard

Operate at Ambitions’ required standard:

* world-class native iPhone-first product quality
* senior FAANG-level engineering/process discipline
* local-first/on-device-first posture unless active truth files say otherwise
* strict release/proof honesty
* no false completion claims
* no uncontrolled automation loops
* no repeated same-root retry churn
* no nested runner recursion
* no concurrent Xcode validation
* no hidden mutation
* no broad cleanup
* path-limited commits only
* clean queue/state authority
* precise Green / accepted Yellow / Red closeout

This batch must behave like a senior release/QA/iOS/repo-hygiene closeout, not like a new implementation attempt.

---

# Known Current State

The previous operating sequence produced this state:

* `AUTO-HARDEN-01` completed Green and was pushed.
* `GLOBAL-SEQUENCE-AUTONOMY-01` completed Green and was pushed.
* `GLOBAL-RUNNER-LOOP-PROOF-01` reached Yellow, then its governance layer was committed manually in `a8c4163f`.
* Active runner/Codex/Xcode conflicts were cleared.
* PK15 source/test work remains dirty and uncommitted.
* `PK15-FINALIZE-01` exists as the required next safe batch.
* Supervisor `--next` points to `PK15-FINALIZE-01`.
* `make global-train-until-complete` must not run until PK15 finalization closes Green or accepted Yellow.
* `prompts/batches/CLEAR-RUNNER-CONFLICTS-01.md` may remain untracked; do not let it interfere with PK15 finalization.

Prior PK15 evidence indicated:

* PK15 Phase 01 closed Green.
* Spark implemented bounded receipt backend persistence/query work and focused tests.
* Focused PK15 receipt repository tests eventually passed.
* The full `AmbitionsTests` suite had one remaining failure outside PK15 scope:
  `ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior`
* A continuation attempt reran Phase 02 instead of finalizing existing work and hit Xcode build database locking.
* That continuation noise must not be treated as evidence that PK15 source work is invalid.

---

# Active Source Truth To Inspect

Read these first, in order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/IMPLEMENTATION_TRUTH.md`
4. `docs/truth/RELEASE_TRUTH.md`
5. `docs/truth/CODEX_PROCESS_TRUTH.md`
6. `docs/truth/HISTORICAL_POLICY.md`
7. `AGENTS.md`
8. `.codex/state/active-batch.yml`
9. `.codex/state/global-train-attempt-ledger.md`
10. `.codex/reports/current-batch-train-state.md`
11. `docs/codex/BATCH_REGISTRY.md`
12. `docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md`
13. `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
14. `docs/codex/POST_BATCH_GATE_REGISTRY.md`
15. `docs/codex/ambitions-hybrid-runner.md`
16. `docs/codex/global-train-supervisor.md`
17. `prompts/batches/PK15.md`
18. latest `.codex/runs/PK15/*/final-summary.md`, if present
19. latest `.codex/runs/PK15/*/final/*.final.md`, if present
20. latest `.codex/runs/PK15/*/status/*.txt`, if present
21. current git diff

If run artifacts are untracked, inspect them as local evidence but do not commit `.codex/runs/**`.

---

# Required Preflight

Before changing anything, run:

```bash
scripts/ambitions-process-preflight.sh --assert-clear
git status --short --branch
git diff --name-only
```

If the helper returns `STATUS: BLOCKED`, classify blockers and stop with `STATUS: RED` unless uncertainty is resolved by the owning repair prompt.
If it returns `STATUS: UNKNOWN`, stop with `STATUS: RED`.
If it returns `STATUS: CLEAR`, continue.
`xcodebuildmcp` must not be treated as a real build blocker.

* stop with `STATUS: RED`
* do not kill it from this batch unless the user explicitly authorized process cleanup
* report exact PIDs and next safe cleanup command

If only untracked `.codex/runs/**` and untracked prompt files exist, classify them and continue if safe.

---

# Required Diagnosis

Determine and report:

1. What files are currently dirty?
2. Which dirty files are PK15-owned?
3. Which dirty files are unrelated/unexpected?
4. Does the PK15 diff implement receipt backend scope only?
5. Did the prior focused PK15 tests pass?
6. Is the full-suite failure still the known unrelated external-surface test?
7. Did PK15 cause that external-surface failure?
8. Is PK15 closeable as Green, accepted Yellow, or Red?
9. What queue/state files need update if PK15 closes?
10. What exact commit should be created if safe?

---

# PK15 Intended Scope

PK15 is:

```text
PK15 — Receipt Backend
```

Expected product/engineering intent:

* durable local receipt/action history backend
* local-first SwiftData/source-level persistence/query foundation
* no user-facing UI change
* no new top-level IA
* no cloud/backend/LLM/provider behavior
* no release/readiness claim
* no visual/accessibility/performance/device claim unless separately proven

Expected source/test ownership may include:

```text
Native/Ambitions/Persistence/
Native/AmbitionsTests/Persistence/
docs/audits/pk15-*.md
.codex/state/active-batch.yml
.codex/reports/current-batch-train-state.md
docs/codex/BATCH_REGISTRY.md
docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
```

Do not broaden this scope.

---

# Allowed Scope

You may modify only:

```text
Native/Ambitions/Persistence/
Native/AmbitionsTests/Persistence/ActionReceiptHistoryRepositoryTests.swift
docs/audits/pk15-receipt-backend-report.md
.codex/state/active-batch.yml
.codex/state/global-train-attempt-ledger.md
.codex/reports/current-batch-train-state.md
docs/codex/BATCH_REGISTRY.md
docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
```

You may read any file needed for diagnosis.

You may add a PK15 audit report if missing:

```text
docs/audits/pk15-receipt-backend-report.md
```

Only update queue/state files if PK15 can be honestly closed.

---

# Forbidden Scope

Do not modify:

```text
Native/Ambitions/Features/
Native/Ambitions/App/
Sources/
AppUI/
Package.swift
project.yml
docs/truth/
.github/
Native/AmbitionsUITests/
```

Do not:

* run PK15 from scratch
* run `make batch BATCH=PK15 ...`
* run global train
* invoke nested `make batch`
* run concurrent Xcode commands
* fix unrelated external-surface tests unless PK15 caused them
* edit feature UI
* alter top-level IA
* add hosted CI
* add dependencies
* add signing/TestFlight/App Store automation
* add external/cloud LLM behavior
* add backend/provider/network behavior
* delete tests
* weaken tests
* commit `.codex/runs/**`
* broad-stage files
* claim full-suite Green unless proven
* claim release/readiness/accessibility/performance/device proof

---

# Validation Expectations

Run commands sequentially only.

No concurrent Xcode commands.

## Required pre-validation

```bash
scripts/ambitions-process-preflight.sh --assert-clear
git status --short --branch
git diff --check
python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json >/tmp/ambitions-global-queue-json-check.txt
```

## Required focused PK15 validation

Inspect the previous PK15 run artifacts and identify the exact focused test command/class.

Then run focused PK15 tests only.

Likely command shape:

```bash
xcodegen generate
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination "platform=iOS Simulator,name=<available-simulator-name>" \
  -only-testing:AmbitionsTests/ActionReceiptHistoryRepositoryTests \
  test
```

If the destination differs from existing repo scripts, use the repo’s established local simulator selection pattern.

Record exact command, destination, exit code, and result.

## Optional full-suite validation

Run full `AmbitionsTests` only if:

* focused PK15 validation passes
* no Xcode build lock exists
* the command can run sequentially
* doing so will not cause another overlap loop

If full suite is run and the only failure is still:

```text
ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior
```

then classify it as accepted Yellow only if evidence shows it is unrelated to PK15.

Do not fix that failure in this batch unless PK15 caused it.

---

# Yellow Acceptance Rule

PK15 may close as accepted Yellow only if all are true:

* PK15-owned focused tests pass
* PK15 diff is bounded to receipt backend scope
* the full-suite failure is unrelated or not rerun for a documented reason
* no source-truth conflict exists
* no release/readiness claim is made
* owner is recorded
* reason is recorded
* no-claim boundary is recorded
* retirement condition is recorded
* resume path is recorded

Accepted Yellow owner:

```text
QA / External Surface owner
```

Accepted Yellow reason:

```text
Full AmbitionsTests suite has an unrelated external-surface expectation mismatch not caused by PK15; PK15-focused receipt backend validation passed.
```

Retirement condition:

```text
Run/fix ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior in its owning external-surface validation batch or repair lane.
```

Resume path:

```text
Continue global train after PK15 closeout; do not claim full-suite Green until the external-surface failure is fixed or accepted by its owner.
```

---

# Closeout Requirements

If PK15 closes Green or accepted Yellow, update queue/state consistently:

* mark PK15 complete or accepted Yellow according to evidence
* set next eligible batch to PK16 if sequence rules allow
* keep normal remaining counts consistent with current queue math
* update attempt ledger so PK15 is no longer `finalization-required`
* record proof paths
* do not mark full train complete

If PK15 cannot close:

* stop Red
* leave source/test diff uncommitted
* record rollback instructions
* keep PK15 as next eligible/finalization-required

---

# Commit Rule

If PK15 is safe to close:

* stage only explicit PK15 files
* exclude `.codex/runs/**`
* exclude unrelated/untracked prompt files unless they are directly required
* do not use `git add -A`
* do not use `git add .`
* do not use `git commit -a`

Before commit, run:

```bash
git diff --cached --check
git diff --cached --name-only
```

Commit message:

```text
PK15: add receipt backend
```

Commit body must include:

* focused PK15 validation result
* full-suite status if run
* accepted Yellow note if applicable
* proof paths
* claims not made

Push to `main` if the runner/commit policy permits and the branch is `main`.

---

# Hard Red Stop Conditions

Stop with `STATUS: RED` if:

* active runner/Codex/Xcode processes remain
* current diff includes unexpected unrelated files
* PK15-focused tests fail
* PK15 diff is not bounded to receipt backend scope
* PK15 appears to cause the external-surface failure
* queue/state would need to lie about full-suite Green
* validation cannot run due persistent build lock
* committing would include `.codex/runs/**`
* committing would include unrelated prompt/governance files
* app UI/source outside persistence is touched
* any unsupported release/readiness/accessibility/performance/device claim would be introduced

---

# Required Final Report

End with:

```markdown
## Status

STATUS: GREEN | STATUS: YELLOW | STATUS: RED

## PK15 Finalization Decision

- closeable:
- final status:
- reason:

## Dirty Worktree Diagnosis

- PK15-owned files:
- unrelated files:
- untracked run artifacts:
- untracked prompt files:

## Files Changed

- path — reason

## Validation

Commands run:
- command — exit code — result

Commands not run:
- command — reason

## Accepted Yellow

- item:
- owner:
- reason:
- no-claim boundary:
- retirement condition:
- resume path:

## Queue / State Updates

- path — change

## Commit

- committed:
- commit SHA:
- pushed:
- staged files:

## Claims Not Made

- full-suite Green unless proven
- release readiness
- build success beyond recorded commands
- test success beyond recorded commands
- visual quality
- accessibility conformance
- performance validation
- physical-device validation
- TestFlight/App Store readiness
- global train completion

## Next Recommended Step

If PK15 closes Green or accepted Yellow, run:

```bash
make global-train-until-complete
```

If PK15 stops Red, do not run global train. Follow the Red stop report.
```
