<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MOAT-GOAL-REALITY-FULL-SEQUENCE-TRAIN — Full Goal Reality Compiler Moat Train

## Batch ID

`MOAT-GOAL-REALITY-FULL-SEQUENCE-TRAIN`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-GOAL-REALITY-FULL-SEQUENCE-TRAIN prompts/batches/MOAT-GOAL-REALITY-FULL-SEQUENCE-TRAIN.md
```

Equivalent:

```bash
make batch BATCH=MOAT-GOAL-REALITY-FULL-SEQUENCE-TRAIN PROMPT=prompts/batches/MOAT-GOAL-REALITY-FULL-SEQUENCE-TRAIN.md
```

## Objective

Run the complete Goal Reality Compiler maturity train from core compiler to evaluation harness. This is the full local-only backend/runtime moat installation sequence for Ambitions’ proof-gated intent-to-day execution engine.

This sequence must preserve the product thesis:

```text
Ambitions does not schedule what the user says.
Ambitions locally compiles what the user means into the safest next proof of the life they want.
```

## Required Execution Order

Run these batches in order:

```text
01 MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01
02 MOAT-GOAL-REALITY-FIXTURE-LAB-02
03 MOAT-GOAL-REALITY-RUNTIME-SERVICE-03
04 MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04
05 MOAT-GOAL-REALITY-GOALS-BRIDGE-05
06 MOAT-GOAL-REALITY-TODAY-BRIDGE-06
07 MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07
08 MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08
09 MOAT-GOAL-REALITY-SOURCE-PACKS-09
10 MOAT-GOAL-REALITY-EVAL-HARNESS-10
```

Prompt paths:

```text
prompts/batches/MOAT-UNIVERSAL-GOAL-REALITY-COMPILER-01.md
prompts/batches/MOAT-GOAL-REALITY-FIXTURE-LAB-02.md
prompts/batches/MOAT-GOAL-REALITY-RUNTIME-SERVICE-03.md
prompts/batches/MOAT-GOAL-REALITY-CAPTURE-BRIDGE-04.md
prompts/batches/MOAT-GOAL-REALITY-GOALS-BRIDGE-05.md
prompts/batches/MOAT-GOAL-REALITY-TODAY-BRIDGE-06.md
prompts/batches/MOAT-GOAL-REALITY-RECEIPT-CLOSURE-07.md
prompts/batches/MOAT-GOAL-REALITY-LOCAL-PERSISTENCE-08.md
prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md
prompts/batches/MOAT-GOAL-REALITY-EVAL-HARNESS-10.md
```

## Active Source Truth

Before starting and after each batch, inspect:

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md
docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md
docs/audits/goal-reality-golden-fixture-matrix.md if present
```

Live source and passing tests outrank docs. Docs-only plans are not implementation proof.

## Global Laws

Every batch must preserve:

```text
local-only core runtime
no hosted AI dependency
no chatbot UI
no automatic plan mutation
no hidden commitment mutation
no external user-data server
no user-facing confidence score
no guarantee language
no punitive closure language
no generic productivity scoring
no top-level IA changes
no release/App Store/TestFlight claims
no specialized professional instructions
source/professional boundary gates
receipt-backed reframe and correction
rollback path
implementation-truth honesty
```

## Stop / Continue Policy

Continue through Yellow advisories if they are non-blocking and explicitly accepted in the batch report.

Stop only for Hard Red conditions such as:

```text
external LLM/API/network dependency required for core behavior
hosted backend/user-data server required
schema migration without rollback proof
unsafe specialized professional instructions
automatic plan or commitment mutation
hidden learning
new top-level route/tab
release readiness claim
validator weakening
missing core tests for a batch
build cannot be restored
```

If a Hard Red occurs:

1. Stop sequence.
2. Produce exact Red report with file/path/reason.
3. Do not patch around safety boundaries.
4. Recommend the smallest safe repair batch.

## Global Validation Expectations

Each batch must run its own validation. After Batch 10 or after the final completed batch, run a consolidated validation lane where feasible:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityCompilerCoreTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityGoldenFixtureTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityNegativeFixtureTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityRuntimeBoundaryTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityReceiptTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityEvaluationHarnessTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

If tests are renamed by implementation, use the nearest exact generated test names and document the mapping.

## Required Final Artifacts

By the end of the sequence, the repo should contain or explicitly defer with Yellow:

```text
Goal Reality core models
Goal Reality compiler
Goal Reality validator
full golden fixture lab
negative fixture lab
runtime service exposure
Capture bridge
Goals bridge
Today bridge
receipt/closure/correction loop
local persistence or explicit deferred persistence report
source-pack boundary or explicit deferred source-pack report
evaluation harness
fixture matrix
audit reports for each batch
implementation truth update
rollback notes
claim boundary
```

## Final Claim Boundary

Only if all ten batches are Green or explicitly accepted Yellow with no missing critical moat layer, the sequence may claim:

```text
Ambitions has a local Goal Reality Compiler that converts risky, vague, moonshot, regulated, or emotionally loaded ambitions into proof-gated execution candidates with source/professional boundaries, reversible Today steps, non-shaming closure, correction controls, local-only posture, and inspectable receipts.
```

Still forbidden unless separately proven:

```text
Ambitions fully handles every goal.
Ambitions understands all raw intent.
Ambitions provides medical/legal/financial advice.
Goal Reality Compiler is production complete.
Local AI is complete.
Personalized execution engine is complete.
Release-ready.
Device-verified.
App Store-ready.
```

## Final Report

Create or update:

```text
docs/audits/moat-goal-reality-full-sequence-train-report.md
```

Include:

```text
sequence result
batch-by-batch status
files changed by batch
validation results
Hard Reds if any
accepted Yellow advisories
remaining deferred work
claim boundary
rollback strategy
next recommended batch
```

## Rollback Strategy

Each batch should be independently revertible. If the full sequence is reverted, do not leave partial schema, route, entitlement, release, workflow, or hosted-service residue.

If persistence batch introduces migration work, rollback must cite the persistence batch’s rollback proof.

## Expected Mature Outcome

The target mature outcome is not “a planner.” It is a local intelligence kernel with this grammar:

```text
risk -> truth -> permission -> proof -> safe Today step -> receipt -> correction
```

That grammar is the Ambitions moat.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
