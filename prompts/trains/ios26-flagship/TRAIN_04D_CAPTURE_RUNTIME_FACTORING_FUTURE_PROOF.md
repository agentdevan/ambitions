<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_04D - Capture-to-Runtime Factoring & Future Proof Bridge

## Objective
Install the prompt plan and proof gates required to make Capture a first-class intake bridge into runtime planning, goal relevance, future proof, historical context, life context, receipts, replay, and user-approved schedule mutation.

## Why this exists
Ambitions Capture must not be a passive inbox. A capture such as "play pickleball at 8 next Tuesday" must be preserved, locally understood, safely factored, held for user approval where needed, receipt-backed, replayable, and useful later when it cannot be matched today.

Core product truth:

```text
Nothing meaningful is lost.
Nothing sensitive is silently used.
Nothing scheduled is silently mutated.
Nothing gets forced into a goal when the match is weak.
Everything important leaves a receipt.
```

This train installs only the future implementation plan, manifest wiring, dependency updates, proof root, and batch prompts. It does not implement the runtime bridge and does not prove app behavior.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`. This train depends on TRAIN_03, TRAIN_04, TRAIN_04A, TRAIN_04B, and TRAIN_04C and sits after TRAIN_04C and before TRAIN_05.

Downstream dependency updates:
- TRAIN_05 depends on TRAIN_04D.
- TRAIN_06 depends on TRAIN_04D.
- TRAIN_07 depends on TRAIN_04D.
- TRAIN_08 depends on TRAIN_04D.
- TRAIN_09 depends on TRAIN_04D for What Ambitions Knows / Capture context controls.
- TRAIN_10 depends on TRAIN_04D for receipts/replay.
- TRAIN_11 depends on TRAIN_04D where persistence models are added.
- TRAIN_16 depends on TRAIN_04D through the full train chain.

## Required pipeline
The final executed train must prove this end-to-end pipeline:

```text
CaptureInput
-> CaptureSemanticExtraction
-> CaptureTimeInterpretation
-> CaptureActivityClassification
-> CaptureRuntimeFactoringCandidate
-> GoalRelevanceScan
-> PlanInsertionCandidate
-> FutureProofContextCandidate
-> UserReviewDecision
-> Receipt
-> ReplayTrace
-> FutureRuntimeUse
```

## Required runtime objects
Future implementation must install or connect:
- `CaptureSemanticExtraction`
- `CaptureTimeInterpretation`
- `CaptureRuntimeFactoringCandidate`
- `GoalRelevanceScan`
- `PlanInsertionCandidate`
- `FutureProofContextCandidate`
- `CaptureRuntimeReceipt`

Required object fields are defined in the mapped batch prompts.

## Batch list
- IOS26-T04D-B01
- IOS26-T04D-B02
- IOS26-T04D-B03
- IOS26-T04D-B04
- IOS26-T04D-B05
- IOS26-T04D-B06
- IOS26-T04D-B07

## Source scope
See the exact source areas in each mapped batch prompt. Future implementation must inspect `Native/Ambitions/Features/Capture/`, `Native/Ambitions/Features/Captures/`, `Native/Ambitions/Services/SmartAttachmentService.swift`, `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`, Runtime, Goal compiler, Recommendation engine, Source Atlas runtime bridge, Life Context, Time, Goals, Today, You, Persistence, Receipts, Replay, `Native/AmbitionsTests`, `Native/AmbitionsUITests`, and preview fixtures.

## Proof artifacts
Use `build/reports/capture-runtime-bridge/` and the specific batch prompt.

## Train-level acceptance gate
Create `build/reports/capture-runtime-bridge/TRAIN_04D_CLOSEOUT.md` when the train is executed.

The closeout must include: Status, Batches completed, Files changed, Extraction proof, Goal relevance proof, Plan insertion proof, Future context proof, Receipts/replay proof, Gauntlet proof, UI proof, Privacy/local-first proof, Accessibility support status, Known gaps, Claims allowed, Claims forbidden, Next eligible train.

## Claims allowed only if Green
- "Capture can extract structured runtime meaning locally."
- "Capture can suggest goal relevance without forcing attachment."
- "Scheduled captures can become user-approved Time candidates."
- "Unmatched useful captures can become future context."
- "Capture factoring is receipt-backed and replayable."

## Claims forbidden unless proven
- "Capture understands everything."
- "Automatic perfect scheduling."
- "Automatic calendar write."
- "Medical/injury advice."
- "Fully autonomous semantic planning."
- "App Store-ready capture intelligence."
- "Cloud-level natural language understanding."

## Red conditions
- Capture text is lost.
- Weak match is forced into a goal.
- Schedule is mutated silently.
- Calendar write occurs without explicit confirmation.
- Sensitive context is used without review.
- Capture is stored but not queryable later.
- No receipt exists.
- No replay exists.
- No correction path exists.
- No deterministic gauntlet exists.
- Cloud/LLM dependency is added.
- Capture becomes a dashboard/admin inbox.

## Red/Yellow/Green closeout rules
Green requires current evidence from the batch prompts. Yellow requires owner, safety reason, no-claim boundary, validation posture, and post-batch gate. Red stops.

## Rollback strategy
Rollback only files touched by TRAIN_04D work. Preserve unrelated dirty work.

## Sequential commands for that train
```bash
scripts/ambitions-codex-train.sh IOS26-T04D-B01 prompts/batches/IOS26-T04D-B01-capture-semantic-extraction.md
scripts/ambitions-codex-train.sh IOS26-T04D-B02 prompts/batches/IOS26-T04D-B02-goal-relevance-scanner.md
scripts/ambitions-codex-train.sh IOS26-T04D-B03 prompts/batches/IOS26-T04D-B03-plan-insertion-approval.md
scripts/ambitions-codex-train.sh IOS26-T04D-B04 prompts/batches/IOS26-T04D-B04-future-proof-context-storage.md
scripts/ambitions-codex-train.sh IOS26-T04D-B05 prompts/batches/IOS26-T04D-B05-receipts-replay-corrections.md
scripts/ambitions-codex-train.sh IOS26-T04D-B06 prompts/batches/IOS26-T04D-B06-capture-runtime-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04D-B07 prompts/batches/IOS26-T04D-B07-capture-ui-review-surface.md
```

## Batch summaries
- IOS26-T04D-B01: `prompts/batches/IOS26-T04D-B01-capture-semantic-extraction.md`
- IOS26-T04D-B02: `prompts/batches/IOS26-T04D-B02-goal-relevance-scanner.md`
- IOS26-T04D-B03: `prompts/batches/IOS26-T04D-B03-plan-insertion-approval.md`
- IOS26-T04D-B04: `prompts/batches/IOS26-T04D-B04-future-proof-context-storage.md`
- IOS26-T04D-B05: `prompts/batches/IOS26-T04D-B05-receipts-replay-corrections.md`
- IOS26-T04D-B06: `prompts/batches/IOS26-T04D-B06-capture-runtime-gauntlet.md`
- IOS26-T04D-B07: `prompts/batches/IOS26-T04D-B07-capture-ui-review-surface.md`

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
