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

## Natural-language trigger

When the user says any of the following, treat this file as the active conductor unless a newer active conductor is present in repo truth:

```text
run autonomous train
run the autonomous train
run global train
run the full global train
continue autonomous train
```

Do not answer with a new plan-only prompt when this conductor exists. Run through the Ambitions runner, inspect the repo, execute the next eligible batch, close it with proof, push, and continue until queue completion or true Hard Red.

## Operating mode

Run through the Ambitions runner only:

```text
GPT-5.5 plan -> GPT-5.3-Codex-Spark bounded patch -> GPT-5.5 review/repair/final commit
```

Direct Codex execution is forbidden unless the user explicitly bypasses the Ambitions runner.

This conductor runs the Ambitions global batch train from the current next eligible product implementation batch through every remaining executable batch in canonical queue order. It must factor active HBI and MRI authority into every batch, not as optional sidecar work.

## Required current state to verify

Verify from repo truth, not memory:

- PK17 Today Read Model Extraction is complete and pushed.
- XCODE-BUILD-SYSTEM-MAX-01 is complete and pushed.
- XCODE-BUILD-SYSTEM-MAX-01 repair is complete and pushed.
- HEAD and origin/main resolve to the same current commit.
- Build Lab scripts exist.
- Build Lab final report is Green.
- The next product implementation batch is resolved from queue truth, not guessed.
- Control-plane check is Green or its non-Green result is classified honestly.
- Queue snapshot reports the next executable item.
- HBI overlay, manifest, train doc, guard, and handoff prompt exist.
- MRI autonomous routing tools/state exist or their absence is classified before proceeding.
- No app release/device/TestFlight/App Store/accessibility/performance/privacy/legal readiness claim has been made without proof.

Expected known commits to verify if present:

```text
efc22a21 PK17: complete Today read model extraction
3e3d1f7e Add Ambitions Xcode Build Lab
94b22497 Repair Xcode validation artifact roots
3ead1df0 XCODE-BUILD-SYSTEM-MAX-01-REPAIR-01: complete hybrid Codex batch
```

Do not fail merely because abbreviated SHAs differ after rebase if repo evidence proves equivalent commits exist on `origin/main`.

## Mandatory global overlays

### HBI Historical Baseline Overlay

HBI is active global authority for any batch touching source records, evidence, imported user material, candidate extraction, claims, confidence, staleness, contradiction handling, review queue, current-state snapshots, runtime inspection, recommendation influence, portability, delete/restore, local simulation, monetization gates, or final proof.

Read these before preflight and before every batch transition:

```text
docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md
docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json
docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md
prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md
scripts/ambitions-historical-baseline-train-guard.py
```

Run the HBI install guard during preflight and at every major train boundary:

```bash
python3 scripts/ambitions-historical-baseline-train-guard.py
```

HBI placement rule:

1. Continue the active canonical queue.
2. If SA17-SA25 are next or pending, apply HBI constraints to that Source Atlas foundation work.
3. After Source Atlas import/review foundation is complete, run HBI-00 through RRE-01 in manifest order before downstream source-aware personalization maturity claims.
4. Do not allow downstream AOS/LDI/FCP/PFC/RHC claims to imply mature source-aware personalization until the relevant HBI proof exists.

HBI sequence:

```text
HBI-00 -> HBI-01 -> HBI-02 -> HBI-03 -> HBI-04 -> HBI-05 -> HBI-06 -> HBI-07 -> HBI-08 -> SCI-01 -> SCI-02 -> SCI-03 -> IRQ-01 -> IRQ-02 -> HBI-09 -> HBI-10 -> PRI-01 -> RHE-01 -> PPL-01 -> PPL-02 -> LSF-01 -> MGP-01 -> RRE-01
```

HBI hard rules:

- Imported evidence creates reviewable candidates, not active goals.
- User-facing trust, correction, export, delete, restore, and review controls must not be paywalled.
- Source influence must be sourceable, dateable, correctable, suppressible, exportable, and deletable where relevant.
- Do not introduce cloud storage, cloud parsing, cloud AI dependency, full-library defaults, broad crawling, silent promotion, silent winner-picking, hidden scoring, irreversible silent deletion, or autonomous life decisions.

### MRI Moat Runtime Integration Overlay

MRI is active global authority for moat/runtime integration, runtime-object routing, object graph integrity, cross-surface runtime behavior, autonomous routing decisions, and runtime proof discipline.

Read these before preflight and before every runtime/integration train transition when present:

```text
Makefile.mri
scripts/ambitions-mri-autonomous-train.sh
scripts/ambitions-mri-autonomous-router.py
scripts/ambitions-mri-materialize-prompts.py
.codex/state/mri-autonomous-state.json
docs/audits/mri-autonomous-routing-install-report.md
docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md
docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md
docs/codex/OBJECT_OS_INDEX.md
docs/codex/OBJECT_OS_MRI25_34_UPGRADE_OVERLAY.md
prompts/batches/MRI00-MOAT-RUNTIME-GAP-LOCK.md
```

MRI routing rule:

1. If MRI router/state says a runtime/moat integration batch is required before the next canonical batch, classify it and either run it through the runner or document why canonical queue authority takes precedence.
2. If canonical queue and MRI routing conflict, stop Red unless the repo has an explicit authority rule resolving the conflict.
3. Do not bypass MRI on batches touching runtime objects, object graph, cross-surface routing, moat loops, recommendation runtime, proof receipts, or autonomous routing.
4. Do not let MRI collapse unrelated batch IDs into a mega-patch. MRI may route; it may not erase queue proof.

Run these MRI checks when present and safe:

```bash
make -f Makefile.mri help || true
python3 scripts/ambitions-mri-autonomous-router.py --help || true
python3 scripts/ambitions-mri-materialize-prompts.py --help || true
```

If `scripts/ambitions-mri-autonomous-train.sh` is the repo-authorized entry point for MRI-routed execution, use it only after verifying it preserves the Ambitions runner requirements and does not bypass queue/source-truth gates.

## Mandatory preflight

Run before starting the first next eligible batch and record true exit codes:

```bash
git status --short --branch
git fetch origin main
git status --short --branch
git log --oneline -n 12
git diff --check
python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json >/tmp/ambitions-global-queue-json-check.txt
python3 -m json.tool docs/codex/AMB_REMAINING_BATCH_REFERENCE.json >/tmp/ambitions-remaining-batch-reference-json-check.txt
python3 -m json.tool docs/codex/AMB_GLOBAL_REMAINING_TRAIN_BLUEPRINT.json >/tmp/ambitions-global-remaining-train-blueprint-json-check.txt
python3 -m json.tool docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json >/tmp/ambitions-hbi-manifest-json-check.txt
python3 scripts/ambitions-historical-baseline-train-guard.py
python3 scripts/ambitions-queue-snapshot.py
python3 scripts/ambitions-control-plane-check.py
python3 scripts/ambitions-source-atlas-title-check.py --strict
make prompt-audit
make batch-self-check
make -f Makefile.mri help || true
python3 scripts/ambitions-mri-autonomous-router.py --help || true
python3 scripts/ambitions-mri-materialize-prompts.py --help || true
make build-lab-doctor || true
scripts/ambitions-xcode-validate.sh --batch GLOBAL-TRAIN-AUTOPILOT-FROM-PK18-TO-COMPLETE-01 --lane none
```

Commands with `|| true` may continue but must still be reported honestly. `lane none` may return the documented no-Xcode-needed code and should be reported as such rather than converted into a false full validation claim.

If preflight shows uncommitted user work unrelated to this batch/train, classify it. If unknown user work is present, stop Red rather than overwriting it.

## Active source truth to inspect

Read and consult before starting the first batch and before every train transition:

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
.codex/state/mri-autonomous-state.json
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
docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md
docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json
docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md
docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md
docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md
docs/codex/OBJECT_OS_INDEX.md
docs/codex/OBJECT_OS_MRI25_34_UPGRADE_OVERLAY.md
docs/codex/XCODE_BUILD_LAB_PROTOCOL.md
docs/codex/XCODE_VALIDATION_LANE_MATRIX.md
docs/codex/XCODE_TOOLCHAIN_PINNING.md
docs/codex/XCODE_RESULT_BUNDLE_PROTOCOL.md
docs/audits/xcode-build-system-max-report.md
docs/audits/historical-baseline-global-train-install-report.md
docs/audits/mri-autonomous-routing-install-report.md
prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md
prompts/batches/**
scripts/ambitions-queue-snapshot.py
scripts/ambitions-control-plane-check.py
scripts/ambitions-source-atlas-title-check.py
scripts/ambitions-final-report-gate.py
scripts/ambitions-batch-scope-guard.py
scripts/ambitions-xcode-validate.sh
scripts/ambitions-xcode-failure-classifier.py
scripts/ambitions-historical-baseline-train-guard.py
scripts/ambitions-mri-autonomous-router.py
scripts/ambitions-mri-materialize-prompts.py
scripts/ambitions-mri-autonomous-train.sh
```

## Product truth that must remain true

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

## Autopilot loop

Repeat until no remaining executable batch exists, or until a true unrecoverable Hard Red occurs:

1. Refresh repo and queue truth:

```bash
git status --short --branch
python3 scripts/ambitions-queue-snapshot.py
python3 scripts/ambitions-control-plane-check.py
python3 scripts/ambitions-historical-baseline-train-guard.py
```

2. Refresh MRI routing truth where present:

```bash
python3 scripts/ambitions-mri-autonomous-router.py --help || true
```

3. Resolve the next eligible batch from active repo truth. Do not guess.
4. Apply HBI overlay if the batch touches source/evidence/candidates/review/current state/runtime inspection/recommendation influence/portability/delete-restore/simulation/monetization/proof.
5. Apply MRI overlay if the batch touches runtime objects, moat loops, object graph, cross-surface routing, recommendation runtime, proof receipts, or autonomous routing.
6. Confirm `prompts/batches/<NEXT_BATCH_ID>.md` exists.
7. Run:

```bash
make batch BATCH=<NEXT_BATCH_ID> PROMPT=prompts/batches/<NEXT_BATCH_ID>.md
```

8. Inspect `git status --short` and `git diff --check`.
9. Run the batch validators from its prompt/final report. Prefer:

```bash
scripts/ambitions-xcode-validate.sh --batch <NEXT_BATCH_ID> --lane <LANE_FROM_PROMPT_OR_MATRIX>
```

10. If validation fails, classify and repair within active batch scope.
11. Close Green or valid Accepted Yellow only with honest evidence.
12. Stage only files owned by the active batch.
13. Commit with exact batch ID and title.
14. Fetch, rebase if needed, rerun relevant validators if conflicts occurred, and push to `origin/main`.
15. Continue to the next eligible batch from repo truth.

Do not literally use placeholders.

## Queue order

Start from the next eligible batch reported by repo truth. The original expected continuation after PK17 was:

```text
PK18 -> PK19 -> PK20 -> PK21 -> PK22 -> PK23 -> PK24 -> PK25 -> PK26 -> PK27 -> PK28 -> PK29 -> PK30 -> PK31 -> PK32 -> PK33 -> PK34 -> PK35 -> PK36 -> PK37 -> PK38 -> PK39 -> PK40 -> PK41
```

After PK41, continue through active canonical queue truth across remaining trains, including IR, SA, HBI, SCI, IRQ, PRI, RHE, PPL, LSF, MGP, RRE, LDI, AOS, FCP, PFC, proof-bound EFC overlays, MRI/object runtime overlays, late owner-mapped RHC, conditional CS, PX only when active queue truth explicitly says so, and terminal DPTG only if all pre-device gates are closed.

Do not fabricate DPTG or release/device proof.

## Build Lab validation

Use the Build Lab wrapper as the default Xcode path. Do not default to raw `xcodegen generate` or `xcodebuild test`.

Expected PK lanes unless prompt/source truth says otherwise:

```text
PK18-PK34: focused-test
PK35-PK36: build-for-testing or focused-test
PK37: focused-test
PK38-PK41: build
```

Use full suite only at explicit train gates. Use UI/simulator proof only when a UI/FET/FVQ/PX/DPTG batch touches UI or requires it. Use terminal device proof only when DPTG is actually terminal-eligible.

## Repair, Yellow, and Hard Red policy

Repair directly only when failure is inside current batch scope, root cause is clear, repair does not broaden scope, repair does not touch forbidden files, repair does not reactivate completed batches, repair does not change canonical queue order, repair does not introduce external/cloud LLM core behavior, repair does not make release/readiness claims, and repair can be validated.

Accepted Yellow may proceed only when non-blocking, fully documented, safe for data/persistence/queue/source/DPTG/release-claim integrity, and final report explicitly allows the next batch to proceed.

Stop only for true unrecoverable Hard Red, including data-loss risk, unknown dirty user work, completed-batch reactivation, canonical ID drift, queue corruption, PK17 reactivation, skipped PK18 without evidence, collapsed PK17-PK41, out-of-scope production mutation, forbidden Package/project/workflow/signing/entitlement/generated-project mutation, external/cloud LLM core behavior, custom hosted personal-data backend, Plan restored as a top-level destination, blocking Source Atlas strict failure, HBI guard failure, MRI routing conflict, standalone AIR, broad EFC sprawl, early broad RHC cleanup, non-terminal DPTG, unsafe validation wrapper behavior, unproven release/readiness claims, unresolvable remote rebase conflict, or unavailable required credentials with no safe local alternative.

Do not stop for ordinary repairable compile/test failures, informational prompt-audit Yellow, missing optional Build Lab tools that degrade correctly, documented lane-none no-validation-required result, clean remote rebase, simulator sickness with safe repair path, stale repo-local DerivedData with safe repo-local clean, focused proof instead of full suite where sufficient, no visual proof for non-UI batches, or valid Accepted Yellow.

## Commit and push policy

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

## Required report per batch

Each batch must produce/update its required final report including status, batch ID, objective, files changed/not changed, queue evidence, HBI applicability, MRI applicability, source truth inspected, validation commands and exit codes, Build Lab lane used, Xcode result/log paths if any, defects found/repaired/deferred, Accepted Yellow rationale if any, claims made/not made, privacy/local-first assessment, external/cloud LLM assessment, Source Atlas/AIR/EFC/FET/FVQ/RHC/CS/DPTG applicability, rollback notes, and next eligible batch.

Run:

```bash
python3 scripts/ambitions-final-report-gate.py <REPORT_PATH> --strict || true
```

Record the true result.

## Global final closeout

When no remaining executable batch exists and terminal/conditional rules are resolved, create:

```text
docs/audits/global-train-execution-final-report.md
```

Include status, starting batch, final executed batch, total executed, Green/Accepted Yellow/Red counts, skipped/conditional batches and why, HBI status, MRI status, DPTG status, queue evidence, validation evidence, Build Lab usage summary, final commit range, files changed, remaining Yellow debt, claims made/not made, release/device/accessibility/performance/privacy/legal proof status, rollback strategy, and recommended next action.

Do not claim public beta, 1.0, TestFlight, App Store, device proof, accessibility compliance, performance readiness, privacy/legal approval, or release readiness unless the specific terminal proof gates actually ran and passed.

## Final response fields

After completion or Hard Red, respond with:

```text
Status: Green / Accepted Yellow / Red
Starting batch
Batches executed
Last successful batch
Current next eligible batch, if any
HBI status
MRI status
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

Begin with mandatory preflight. If preflight is Green, run the next eligible batch from queue truth, not memory. If queue truth still says PK18 is next, run:

```bash
make batch BATCH=PK18 PROMPT=prompts/batches/PK18.md
```

Then continue batch-by-batch from active queue truth until full global train completion or a true unrecoverable Hard Red.
