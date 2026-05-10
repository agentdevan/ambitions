<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
<!-- RUNNER_STATUS_PARSER_NOTE: phase outputs must not echo the phrase "Hard Red" unless the actual final status is STATUS: RED; use "hard-stop" when describing stop-condition classes in Green or Yellow reports. -->

# Batch ID

THROUGHPUT-ACCELERATION-01

# Objective

Build the Ambitions batch-throughput factory so the remaining global batch queue can be completed as fast as possible without degrading product quality, source-truth discipline, proof honesty, local-first posture, EFC obligations, or final GPT-5.5 gate authority.

This batch is not a product-feature batch. It is a Codex OS / runner-governance / throughput-infrastructure batch.

The target operating model is:

```text
GPT-5.5 plan / source-truth / senior judgment
-> GPT-5.3-Codex-Spark bounded implementation patch
-> GPT-5.5 review / repair / validation / final commit eligibility
```

The desired outcome is a repo-local batch factory with:

1. one canonical write lane through `scripts/ambitions-codex-train.sh`
2. many read-only prep lanes for Spark / mini / unknown-tier models
3. deterministic lane classification for queued batches
4. faster prompt hardening for future batches
5. known-yellow quarantine so repeated unrelated failures do not waste cycles
6. test-router mapping so each batch chooses focused validation quickly
7. repair/finalization routing so the train does not stall unnecessarily
8. senior-only escalation rules so Spark never becomes source-of-truth authority
9. clear next command to continue to PK16 after this batch closes

This batch must leave the repo faster, safer, and more autonomous.

# Execution model

This prompt must be run through the Ambitions runner only:

```bash
make batch BATCH=THROUGHPUT-ACCELERATION-01 PROMPT=prompts/batches/THROUGHPUT-ACCELERATION-01.md
```

Do not bypass the runner.

Do not run nested `make batch` commands from inside this batch.

Do not run PK16 inside this batch. This batch prepares the throughput system and then reports the exact next PK16 command.

# Active source truth to inspect

Read in this order before editing:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/IMPLEMENTATION_TRUTH.md`
4. `docs/truth/RELEASE_TRUTH.md`
5. `docs/truth/CODEX_PROCESS_TRUTH.md`
6. `docs/truth/HISTORICAL_POLICY.md`
7. `AGENTS.md`
8. `README.md`
9. `docs/README.md`
10. `.codex/state/active-batch.yml`
11. `.codex/reports/current-batch-train-state.md`
12. `.codex/state/global-train-attempt-ledger.md`
13. `docs/codex/BATCH_REGISTRY.md`
14. `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
15. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
16. `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
17. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md`
18. `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
19. `docs/codex/POST_BATCH_GATE_REGISTRY.md`
20. `docs/codex/CONTEXT_INDEX.md`
21. `docs/codex/CODEX_OS_INDEX.md`
22. `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`
23. `docs/codex/MODEL_TIER_BATCH_MATRIX.md`
24. `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`
25. `docs/codex/ambitions-hybrid-runner.md`
26. `Makefile`
27. `scripts/ambitions-codex-train.sh`
28. `scripts/ambitions-autonomous-train.sh`
29. `scripts/ambitions-process-preflight.sh`
30. `scripts/ambitions-prompt-audit.sh`
31. `scripts/ambitions-global-train-supervisor.sh`
32. `prompts/_RUNNER_REQUIRED_HEADER.md`
33. `prompts/_BATCH_TEMPLATE.md`
34. `prompts/_BATCH_FINALIZE_TEMPLATE.md`
35. `prompts/batches/PK16.md`

If any listed file is missing, record it in the report and continue only if active source truth still permits safe docs/tooling work.

# Current repo facts to preserve

Preserve these as operating facts unless repo evidence proves they changed:

* Active train: Global full-stack execution.
* Current/previous platform state: PK15 Receipt Backend is accepted-yellow / previous closeout.
* Next eligible implementation batch: PK16 Trust History Query.
* Branch creation is not allowed by active batch state.
* Production Swift is allowed for current PK implementation batches, but not for this throughput batch.
* EFC proof overlay is active and must be inherited by future batches.
* GPT-5.5 owns planning, source-truth judgment, canon, review, repair, and final commit eligibility.
* GPT-5.3-Codex-Spark owns bounded implementation patches only.
* Direct pasted implementation prompts are forbidden unless the user explicitly bypasses the Ambitions runner.
* Plan is not an active top-level destination; Today / Goals / Capture / Time / You remain active top-level IA.
* No release, device, TestFlight, App Store, full-suite, legal/privacy, public accessibility, or production-readiness claims may be introduced without matching proof.

# Allowed scope

This is a Codex OS / throughput infrastructure batch.

You may add or modify only repo-governance, Codex OS, advisory-tooling, prompt-template, audit, and throughput-planning files.

Allowed paths include:

```text
docs/codex/BATCH_THROUGHPUT_OPERATING_MODEL.md
docs/codex/BATCH_LANE_CLASSIFICATION_POLICY.md
docs/codex/BATCH_PREP_FACTORY.md
docs/codex/BATCH_TEST_ROUTER.md
docs/codex/KNOWN_YELLOW_QUARANTINE_LEDGER.md
docs/codex/batch-prep/README.md
docs/codex/batch-prep/PK16.md
docs/codex/batch-prep/PK17.md
docs/codex/batch-prep/PK18.md
docs/codex/batch-prep/PK19.md
docs/codex/batch-prep/PK20.md
docs/codex/batch-prep/PK21.md
docs/codex/batch-prep/PK22.md
docs/codex/batch-prep/PK23.md
docs/codex/batch-prep/PK24.md
docs/codex/batch-prep/PK25.md
docs/audits/throughput-acceleration-01-report.md
scripts/ambitions-throughput-plan.sh
scripts/ambitions-batch-lane-classifier.py
scripts/ambitions-batch-prep-scaffold.py
scripts/ambitions-known-yellow-scan.sh
prompts/_BATCH_PREP_TEMPLATE.md
Makefile
docs/codex/CONTEXT_INDEX.md
docs/codex/CODEX_OS_INDEX.md
```

`Makefile` changes must be additive only. Add convenience targets only if they improve throughput and do not alter existing runner behavior.

Optional additive Makefile targets may include:

```text
throughput-status
throughput-next
throughput-classify
throughput-prep
known-yellow-scan
```

Any new script must be:

* local-only
* deterministic
* no network
* no secrets
* no mutation of app source
* no git mutation
* no branch creation
* no commit/push behavior
* standard-library only unless the repo already has a dependency and active policy permits it

# Forbidden scope

Do not modify:

```text
Native/Ambitions/**
Sources/**
AppUI/**
Package.swift
project.yml
*.xcodeproj/**
*.xcworkspace/**
.github/workflows/**
entitlement files
signing/provisioning files
runtime app dependencies
route/raw-value definitions
persistence/schema/model-record files
production Swift files
test files for app behavior
assets
localized product copy
release/signing/App Store/TestFlight automation
hosted CI configuration
write-capable MCP tooling
GitHub write tooling
```

Do not create or switch branches.

Do not run PK16.

Do not implement app product behavior.

Do not delete historical material.

Do not loosen source-truth hierarchy.

Do not weaken prompt direct-execution restrictions.

Do not weaken EFC obligations.

Do not mark any queued product/platform batch as complete.

Do not claim this batch fixes UI, performance, accessibility, privacy/legal, release readiness, device proof, TestFlight readiness, App Store readiness, or global queue completion.

# Required work

## 1. Create the throughput operating model

Create:

```text
docs/codex/BATCH_THROUGHPUT_OPERATING_MODEL.md
```

It must define the fastest safe operating model:

```text
one canonical write lane
many read-only prep lanes
GPT-5.5 owns judgment
Spark owns bounded execution
runner owns commit path
repair desk owns non-Green recovery
shadow lanes prepare the next N batches
proof honesty is never relaxed
```

It must include exact command flows:

```bash
git pull --ff-only
git status --short --branch
make batch-self-check
make prompt-audit
make autonomous-train-status
make autonomous-train-next
make autonomous-train-run-current
make autonomous-train
make repair-status
make repair-next
make repair-current
```

It must explain when to use:

```bash
make batch BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md
make batch-no-commit BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md
AUTO_PUSH=1 make batch BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md
```

Auto-push must remain discouraged until several clean eligible batches have closed.

## 2. Create lane classification policy

Create:

```text
docs/codex/BATCH_LANE_CLASSIFICATION_POLICY.md
```

Define these lane classes:

```text
critical_serial_write
parallel_readonly_prep
spark_bounded_patch_candidate
senior_judgment_required
repair_or_finalize_required
blocked_hard_red
defer_with_ledger
```

For each class, define:

* purpose
* allowed model tier
* allowed actions
* forbidden actions
* proof requirements
* continuation rule
* escalation rule

The policy must make clear:

* Spark/mini/unknown-tier models may prepare, classify, summarize, map tests, and execute bounded patches only after runner authorization.
* Spark/mini/unknown-tier models may not decide source truth, architecture, release posture, deletion, cleanup authority, privacy/legal posture, visual acceptance, or final commit eligibility.
* GPT-5.5 is required for senior-only gates.

## 3. Create prep factory documentation

Create:

```text
docs/codex/BATCH_PREP_FACTORY.md
docs/codex/batch-prep/README.md
prompts/_BATCH_PREP_TEMPLATE.md
```

The prep factory must define a read-only shadow-lane output format:

```text
Batch ID:
Title:
Queue classification:
Current dependency status:
Active truth files:
Prompt file:
Likely owner files:
Likely forbidden files:
Likely tests:
Validation commands:
EFC applicability:
Known yellow caveats:
Senior-only risks:
Spark-safe work:
Hard Red triggers:
Rollback notes:
Non-claims:
Next runner command:
```

The prep template must be explicitly read-only. It must not authorize implementation.

## 4. Seed prep notes for the next platform critical path

Create prep notes for at least PK16-PK25 if the queue and prompt files are sufficiently discoverable. If any prompt file is missing, create the prep note anyway, but mark prompt availability as missing and do not fabricate implementation details.

Preferred seed files:

```text
docs/codex/batch-prep/PK16.md
docs/codex/batch-prep/PK17.md
docs/codex/batch-prep/PK18.md
docs/codex/batch-prep/PK19.md
docs/codex/batch-prep/PK20.md
docs/codex/batch-prep/PK21.md
docs/codex/batch-prep/PK22.md
docs/codex/batch-prep/PK23.md
docs/codex/batch-prep/PK24.md
docs/codex/batch-prep/PK25.md
```

Each prep note must be concise but useful. Do not make false claims. Do not invent touched files without saying they are candidate files.

If time or token budget becomes constrained, seed PK16-PK20 and create tooling that can generate PK21-PK25 later. Record this honestly in the report.

## 5. Create known-yellow quarantine ledger

Create:

```text
docs/codex/KNOWN_YELLOW_QUARANTINE_LEDGER.md
```

It must capture accepted-yellow caveats and known unrelated blockers so future batches do not:

* rediscover them wastefully
* falsely claim they are fixed
* incorrectly block unrelated focused proof
* ignore them when they become relevant

Seed the ledger with the known PK15 caveat if still present in current repo evidence:

```text
ExternalSurfaceVerificationChecklistTests.testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior
```

Do not mark it fixed. Do not claim full-suite green.

Each ledger entry must include:

```text
ID:
Source:
Observed in:
Status:
Owner:
Why it is quarantined:
When it blocks:
When it does not block:
Recheck command:
No-claim boundary:
```

## 6. Create test-router map

Create:

```text
docs/codex/BATCH_TEST_ROUTER.md
```

It must map touched file families to likely focused validation commands.

Include at least:

```text
Persistence / SwiftData
Domain models
Services
Today feature
Goals feature
Capture feature
Time / Plan compatibility seam
You / Profile
External surfaces
Widgets
Live Activities
App Intents
Notifications / EventKit / Reminders
Codex OS docs/tooling
Prompt templates
Repo governance
Visual/UI-facing SwiftUI
Privacy/legal/security docs
Release/proof docs
```

For each, include:

* likely focused tests
* whether `xcodegen generate` is needed
* whether `xcodebuild test` is needed
* whether screenshot/visual proof is needed
* whether GPT-5.5 senior judgment is required
* whether full-suite green may be claimed

Full-suite green must not be claimed unless actually run and passed with current evidence.

## 7. Create advisory throughput tooling

Create read-only scripts if they do not already exist:

```text
scripts/ambitions-batch-lane-classifier.py
scripts/ambitions-batch-prep-scaffold.py
scripts/ambitions-known-yellow-scan.sh
scripts/ambitions-throughput-plan.sh
```

All scripts must be deterministic and local-only.

### `scripts/ambitions-batch-lane-classifier.py`

Requirements:

* Python 3 standard library only.
* Read `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`.
* Support:

```bash
python3 scripts/ambitions-batch-lane-classifier.py --help
python3 scripts/ambitions-batch-lane-classifier.py --queue docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json --limit 20
python3 scripts/ambitions-batch-lane-classifier.py --queue docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json --batch PK16
```

* Print a concise table or markdown-style list.
* Classify each batch using queue classification plus simple deterministic rules.
* Never mutate files.
* Never mark implementation complete.

### `scripts/ambitions-batch-prep-scaffold.py`

Requirements:

* Python 3 standard library only.
* Support:

```bash
python3 scripts/ambitions-batch-prep-scaffold.py --help
python3 scripts/ambitions-batch-prep-scaffold.py --batch PK16 --output docs/codex/batch-prep/PK16.md
python3 scripts/ambitions-batch-prep-scaffold.py --from-queue docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json --limit 10 --output-dir docs/codex/batch-prep
```

* Generate read-only prep-note scaffolds only.
* Do not overwrite an existing prep note unless `--force` is explicitly supplied.
* Do not fabricate owner files.
* Use candidate wording when evidence is inferred.

### `scripts/ambitions-known-yellow-scan.sh`

Requirements:

* Shell script.
* Read known repo state files.
* Print known yellow caveats from the ledger and current batch state.
* No mutation.
* No network.
* No git mutation.

### `scripts/ambitions-throughput-plan.sh`

Requirements:

* Shell script.
* Support:

```bash
bash scripts/ambitions-throughput-plan.sh --help
bash scripts/ambitions-throughput-plan.sh --status
bash scripts/ambitions-throughput-plan.sh --next
bash scripts/ambitions-throughput-plan.sh --classify --limit 20
bash scripts/ambitions-throughput-plan.sh --known-yellow
```

* Delegate to existing runner/supervisor commands where useful.
* Never run implementation batches.
* Never run nested `make batch`.
* Never commit, push, branch, or mutate source.

## 8. Add Makefile conveniences only if safe

If current Makefile shape permits additive targets, add:

```makefile
throughput-status
throughput-next
throughput-classify
throughput-known-yellow
throughput-prep
```

These must call only the read-only scripts.

Do not alter existing `batch`, `autonomous-train`, `repair-current`, or runner targets except to add independent read-only conveniences.

## 9. Update indexes if appropriate

If current source truth permits, update relevant indexes so future Codex sessions can find the new throughput layer:

```text
docs/codex/CONTEXT_INDEX.md
docs/codex/CODEX_OS_INDEX.md
```

Do not overstate authority. The new throughput docs are Codex OS operating aids subordinate to active truth files, `AGENTS.md`, and the canonical runner.

## 10. Create closeout report

Create:

```text
docs/audits/throughput-acceleration-01-report.md
```

The report must include:

```text
Batch:
Model tier used:
Model-tier source:
Mini/Spark-safe classification:
Source truth inspected:
Files changed:
Files created:
Scripts added:
Makefile targets added:
Prep notes seeded:
Known-yellow entries seeded:
Validation run:
Verified:
Failed:
Not run:
Not applicable:
EFC applicability:
Senior-only gates encountered:
Deferrals created:
No-claim boundary:
Rollback:
Next recommended command:
```

The next recommended command should be:

```bash
make autonomous-train-next
make batch BATCH=PK16 PROMPT=prompts/batches/PK16.md
```

or, if repo evidence says autonomous train is preferred:

```bash
make autonomous-train-run-current
```

Do not say PK16 was run. Do not say the global queue is complete.

# Validation expectations

Run and record the results.

Required:

```bash
git status --short --branch
make batch-self-check
make prompt-audit
python3 -m py_compile scripts/ambitions-batch-lane-classifier.py scripts/ambitions-batch-prep-scaffold.py
python3 scripts/ambitions-batch-lane-classifier.py --help
python3 scripts/ambitions-batch-lane-classifier.py --queue docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json --limit 20
python3 scripts/ambitions-batch-lane-classifier.py --queue docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json --batch PK16
python3 scripts/ambitions-batch-prep-scaffold.py --help
bash scripts/ambitions-throughput-plan.sh --help
bash scripts/ambitions-throughput-plan.sh --status
bash scripts/ambitions-throughput-plan.sh --next
bash scripts/ambitions-throughput-plan.sh --classify --limit 20
bash scripts/ambitions-known-yellow-scan.sh
git diff --check
```

If Makefile targets are added, also run:

```bash
make throughput-status
make throughput-next
make throughput-classify
make throughput-known-yellow
```

Optional if available:

```bash
shellcheck scripts/ambitions-throughput-plan.sh scripts/ambitions-known-yellow-scan.sh
```

Do not run `xcodebuild` unless this batch unexpectedly touches app source. Touching app source should be treated as Hard Red unless active source truth proves a narrow exception, which is not expected for this batch.

# Visual proof expectations

Not applicable.

This batch must not change UI, SwiftUI surfaces, visual tokens, screenshots, previews, app assets, interaction behavior, product copy, route labels, or top-level IA.

If any UI-facing source is touched, stop and classify as Hard Red unless repo evidence proves the touched file is a docs/tooling false positive.

# Hard Red stop conditions

Stop immediately and do not commit if any occur:

* production Swift files are modified
* app tests are modified to mask behavior
* route/raw-value behavior is modified
* persistence/schema/model-record behavior is modified
* package/project/signing/entitlement/workflow files are modified
* branch creation is attempted
* hosted CI is added
* GitHub write automation is added
* write-capable MCP tooling is added
* app behavior is implemented or claimed
* PK16 is run inside this batch
* nested `make batch` is invoked
* prompt direct-execution policy is weakened
* EFC applicability is removed, bypassed, or diluted
* Spark/mini/unknown-tier is allowed to decide senior-only gates
* active truth files conflict and cannot be resolved from repo evidence
* release, device, App Store, TestFlight, privacy/legal, public accessibility, full-suite, production-readiness, or global-completion proof is claimed without matching evidence
* scripts mutate app source, git state, branches, remotes, network state, secrets, signing, or workflows
* Makefile changes alter existing runner semantics instead of only adding read-only conveniences

# Rollback expectations

Before closeout, provide:

```bash
git diff --stat
git diff --check
git status --short --branch
```

The closeout report must list rollback commands for all changed files.

Suggested rollback format:

```bash
git restore <changed-file-1> <changed-file-2> ...
git clean -f <new-file-1> <new-file-2> ...
```

If the runner creates an eligible commit, record the commit hash.

If Hard Red occurs, leave changes uncommitted for inspection and report the safest rollback command.

# Required final response from Codex

The final response must include:

1. Green / Yellow / Red classification
2. files changed
3. validation results
4. known failures or skipped checks
5. EFC applicability
6. no-claim boundary
7. rollback command
8. exact next command to run PK16 or continue the autonomous train

Do not include marketing language.

Do not claim this completed any product/platform implementation batch.

Do not claim the remaining 100+ batches are complete.

Do not claim Spark is unlimited.

Do not claim release readiness.

# Runner command

```bash
make batch BATCH=THROUGHPUT-ACCELERATION-01 PROMPT=prompts/batches/THROUGHPUT-ACCELERATION-01.md
```
