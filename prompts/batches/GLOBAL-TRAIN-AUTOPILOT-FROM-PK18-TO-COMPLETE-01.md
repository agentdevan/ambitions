<!-- AMBITIONS_RUNNER_REQUIRED: true -->

<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->

<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# GLOBAL-TRAIN-AUTOPILOT-FROM-PK18-TO-COMPLETE-01

## Batch ID

GLOBAL-TRAIN-AUTOPILOT-FROM-PK18-TO-COMPLETE-01

## Runner command

```bash
scripts/ambitions-codex-train.sh GLOBAL-TRAIN-AUTOPILOT-FROM-PK18-TO-COMPLETE-01 prompts/batches/GLOBAL-TRAIN-AUTOPILOT-FROM-PK18-TO-COMPLETE-01.md
```

Equivalent:

```bash
make batch BATCH=GLOBAL-TRAIN-AUTOPILOT-FROM-PK18-TO-COMPLETE-01 PROMPT=prompts/batches/GLOBAL-TRAIN-AUTOPILOT-FROM-PK18-TO-COMPLETE-01.md
```

## Operating Mode

Run through the Ambitions runner only:

```text
GPT-5.5 plan -> GPT-5.3-Codex-Spark bounded patch -> GPT-5.5 review/repair/final commit
```

Direct Codex execution is forbidden unless the user explicitly bypasses the Ambitions runner.

This conductor batch runs the Ambitions global batch train from the current next eligible product implementation batch, expected to be `PK18 Today Command Handler Extraction`, through every remaining executable batch in canonical queue order.

## Required Current State To Verify

Verify from repo truth, not memory:

- PK17 Today Read Model Extraction is complete and pushed.
- XCODE-BUILD-SYSTEM-MAX-01 is complete and pushed.
- XCODE-BUILD-SYSTEM-MAX-01 repair is complete and pushed.
- HEAD and origin/main resolve to the same current commit.
- Build Lab scripts exist.
- Build Lab final report is Green.
- PK18 remains the next product implementation batch.
- Control-plane check is Green.
- Queue snapshot reports exactly one executable_now item, expected PK18.
- No app release/device/TestFlight/App Store/accessibility/performance/privacy/legal readiness claim has been made.

Expected known commits to verify if present:

```text
efc22a21 PK17: complete Today read model extraction
3e3d1f7e Add Ambitions Xcode Build Lab
94b22497 Repair Xcode validation artifact roots
3ead1df0 XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01: complete hybrid Codex batch
```

Do not fail merely because abbreviated SHAs differ after rebase if repo evidence proves equivalent commits exist on `origin/main`.

## Mandatory Preflight

Run before starting PK18 and record true exit codes:

```bash
git status --short --branch
git fetch origin main
git status --short --branch
git log --oneline -n 12
git diff --check
python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json >/tmp/ambitions-global-queue-json-check.txt
python3 -m json.tool docs/codex/AMB_REMAINING_BATCH_REFERENCE.json >/tmp/ambitions-remaining-batch-reference-json-check.txt
python3 -m json.tool docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json >/tmp/ambitions-global-remaining-train-blueprint-json-check.txt
python3 scripts/ambitions-queue-snapshot.py
python3 scripts/ambitions-control-plane-check.py
python3 scripts/ambitions-source-atlas-title-check.py --strict
make prompt-audit
make batch-self-check
make build-lab-doctor || true
scripts/ambitions-xcode-validate.sh --batch GLOBAL-TRAIN-AUTOPILOT-FROM-PK18-TO-COMPLETE-01 --lane none
```

Commands with `|| true` may continue but must still be reported honestly. `lane none` may return the documented no-Xcode-needed code and should be reported as such rather than converted into a false full validation claim.

If preflight shows uncommitted user work unrelated to this batch/train, classify it. If unknown user work is present, stop Red rather than overwriting it.

## Active Source Truth To Inspect

Read and consult before starting PK18 and before every train transition:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
AGENTS.md
.codex/state/active-batch.yml
.codex/reports/current-batch-train-state.md
.codex/reports/current-run-state.md
.codex/state/global-train-attempt-ledger.md
docs/codex/BATCH_REGISTRY.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md
docs/codex/AMB_REMAINING_BATCH_REFERENCE.md
docs/codex/AMB_REMAINING_BATCH_REFERENCE.json
docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.md
docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json
docs/codex/AMB_GLOBAL_TRAIN_CODEX_IMPLEMENTATION_INSTRUCTIONS.md
docs/codex/AMB_GLOBAL_TRAIN_CONSOLIDATION_AND_MODIFICATION_PLAN.md
docs/codex/AMB_GLOBAL_BATCH_TRAIN_SEQUENCE.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md
docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md
docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md
docs/codex/XCODE_BUILD_LAB_PROTOCOL.md
docs/codex/XCODE_VALIDATION_LANE_MATRIX.md
docs/codex/XCODE_TOOLCHAIN_PINNING.md
docs/codex/XCODE_RESULT_BUNDLE_PROTOCOL.md
docs/audits/xcode-build-system-max-report.md
prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md
prompts/batches/**
scripts/ambitions-queue-snapshot.py
scripts/ambitions-control-plane-check.py
scripts/ambitions-source-atlas-title-check.py
scripts/ambitions-final-report-gate.py
scripts/ambitions-batch-scope-guard.py
scripts/ambitions-xcode-validate.sh
scripts/ambitions-xcode-failure-classifier.py
```

## Product Truth That Must Remain True

- Active top-level IA is Today / Goals / Capture / Time / You.
- Plan is superseded as a top-level destination.
- Core intelligence is local-first and deterministic.
- External/cloud LLMs are not part of core architecture.
- R2 may only host public non-personal freshness/reference packs if authorized by source truth.
- Apple/iCloud-style sync may only be optional user-owned data sync if authorized by source truth.
- No custom hosted user-data backend.
- No telemetry/analytics unless explicitly authorized by active source truth.
- No chatbot-first UI.
- No generic productivity app drift.
- No generic dashboard/card-stack drift.
- No shame/overdue/failure/streak language.
- No release/TestFlight/App Store/device/accessibility/performance/privacy/legal claims without proof.

## Autopilot Loop

Repeat until no remaining executable batch exists, or until a true unrecoverable Hard Red occurs:

1. Refresh repo and queue truth:

```bash
git status --short --branch
python3 scripts/ambitions-queue-snapshot.py
python3 scripts/ambitions-control-plane-check.py
```

2. Resolve the next eligible batch from active repo truth. Do not guess. Expected first batch is `PK18`.
3. Confirm `prompts/batches/<NEXT_BATCH_ID>.md` exists.
4. Run:

```bash
make batch BATCH=<NEXT_BATCH_ID> PROMPT=prompts/batches/<NEXT_BATCH_ID>.md
```

5. Inspect `git status --short` and `git diff --check`.
6. Run the batch validators from its prompt/final report. Prefer:

```bash
scripts/ambitions-xcode-validate.sh --batch <NEXT_BATCH_ID> --lane <LANE_FROM_PROMPT_OR_MATRIX>
```

7. If validation fails, classify and repair within active batch scope.
8. Close Green or valid Accepted Yellow only with honest evidence.
9. Stage only files owned by the active batch.
10. Commit with exact batch ID and title.
11. Fetch, rebase if needed, rerun relevant validators if conflicts occurred, and push to `origin/main`.
12. Continue to the next eligible batch from repo truth.

Do not literally use placeholders.

## Queue Order

Start from `PK18 Today Command Handler Extraction` unless repo truth proves another batch is next.

Preserve PK17-PK41 as separate executable batch IDs. PK17 is complete and must not be reactivated.

Expected PK continuation:

```text
PK18 -> PK19 -> PK20 -> PK21 -> PK22 -> PK23 -> PK24 -> PK25 -> PK26 -> PK27 -> PK28 -> PK29 -> PK30 -> PK31 -> PK32 -> PK33 -> PK34 -> PK35 -> PK36 -> PK37 -> PK38 -> PK39 -> PK40 -> PK41
```

After PK41, continue through active canonical queue truth across remaining trains, including IR, SA, LDI, AOS, FCP, PFC, proof-bound EFC overlays, late owner-mapped RHC, conditional CS, PX only when active queue truth explicitly says so, and terminal DPTG only if all pre-device gates are closed.

Do not fabricate DPTG or release/device proof.

## Build Lab Validation

Use the Build Lab wrapper as the default Xcode path. Do not default to raw `xcodegen generate` or `xcodebuild test`.

Expected PK lanes unless prompt/source truth says otherwise:

```text
PK18-PK34: focused-test
PK35-PK36: build-for-testing or focused-test
PK37: focused-test
PK38-PK41: build
```

Use full suite only at explicit train gates. Use UI/simulator proof only when a UI/FET/FVQ/PX/DPTG batch touches UI or requires it. Use terminal device proof only when DPTG is actually terminal-eligible.

## Repair, Yellow, And Hard Red Policy

Repair directly only when failure is inside current batch scope, root cause is clear, repair does not broaden scope, repair does not touch forbidden files, repair does not reactivate completed batches, repair does not change canonical queue order, repair does not introduce external/cloud LLM core behavior, repair does not make release/readiness claims, and repair can be validated.

Accepted Yellow may proceed only when non-blocking, fully documented, safe for privacy/data/persistence/queue/source/DPTG/release-claim integrity, and final report explicitly allows the next batch to proceed.

Stop only for true unrecoverable Hard Red, including data-loss risk, unknown dirty user work, completed-batch reactivation, canonical ID drift, queue corruption, PK17 reactivation, skipped PK18 without evidence, collapsed PK17-PK41, out-of-scope production mutation, forbidden Package/project/workflow/signing/entitlement/generated-project mutation, external/cloud LLM core behavior, custom hosted personal-data backend, Plan restored as a top-level destination, blocking Source Atlas strict failure, standalone AIR, broad EFC sprawl, early broad RHC cleanup, non-terminal DPTG, unsafe validation wrapper behavior, unproven release/readiness claims, unresolvable remote rebase conflict, or unavailable required credentials with no safe local alternative.

Do not stop for ordinary repairable compile/test failures, informational prompt-audit Yellow, missing optional Build Lab tools that degrade correctly, documented lane-none no-validation-required result, clean remote rebase, simulator sickness with safe repair path, stale repo-local DerivedData with safe repo-local clean, focused proof instead of full suite where sufficient, no visual proof for non-UI batches, or valid Accepted Yellow.

## Commit And Push Policy

After every Green or valid Accepted Yellow batch:

```bash
git status --short
git diff --check
git add <only current-batch-owned files>
git commit -m "<BATCH_ID>: <batch title>"
git fetch origin main
git pull --rebase origin main
git push origin main
```

Do not commit `.codex/runs/**`, `.codex/DerivedData/**`, `.codex/xcode-results/**`, `.codex/xcode-logs/**`, `.codex/xcode-summaries/**`, generated Xcode project files unless the active batch explicitly allows them, or unrelated local artifacts.

## Required Report Per Batch

Each batch must produce/update its required final report including status, batch ID, objective, files changed/not changed, queue evidence, source truth inspected, validation commands and exit codes, Build Lab lane used, Xcode result/log paths if any, defects found/repaired/deferred, Accepted Yellow rationale if any, claims made/not made, privacy/local-first assessment, external/cloud LLM assessment, Source Atlas/AIR/EFC/FET/FVQ/RHC/CS/DPTG applicability, rollback notes, and next eligible batch.

Run:

```bash
python3 scripts/ambitions-final-report-gate.py <REPORT_PATH> --strict || true
```

Record the true result.

## Global Final Closeout

When no remaining executable batch exists and terminal/conditional rules are resolved, create:

```text
docs/audits/global-train-execution-final-report.md
```

Include status, starting batch PK18, final executed batch, total executed, Green/Accepted Yellow/Red counts, skipped/conditional batches and why, DPTG status, queue evidence, validation evidence, Build Lab usage summary, final commit range, files changed, remaining Yellow debt, claims made/not made, release/device/accessibility/performance/privacy/legal proof status, rollback strategy, and recommended next action.

Do not claim public beta, 1.0, TestFlight, App Store, device proof, accessibility compliance, performance readiness, privacy/legal approval, or release readiness unless the specific terminal proof gates actually ran and passed.

## Final Response Fields

After completion or Hard Red, respond with:

```text
Status: Green / Accepted Yellow / Red
Starting batch
Batches executed
Last successful batch
Current next eligible batch, if any
Commits pushed
Validation summary
Build Lab lane summary
Defects repaired
Defects deferred
Yellow debt remaining
Claims not made
Rollback command(s)
Final report path
Recommended next action
```

## Start

Begin with mandatory preflight. If preflight is Green, run:

```bash
make batch BATCH=PK18 PROMPT=prompts/batches/PK18.md
```

Then continue batch-by-batch from active queue truth until full global train completion or a true unrecoverable Hard Red.
