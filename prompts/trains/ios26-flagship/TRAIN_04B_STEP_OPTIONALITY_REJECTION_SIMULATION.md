<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_04B - Step Optionality, Rejection Replanning & Simulation Proof

## Objective
Install runtime, UI, receipt, replay, and proof requirements for step optionality, rejection learning, alternative generation, deadline simulation, and user-approved replanning.

## Why this exists
Ambitions must not be a brittle one recommended task app. The Private Life Runtime must generate a ranked field of valid step candidates, show the best step first, let the user reject it, ask why, generate alternatives, simulate timeline impact, keep the same goal/deadline when realistic, warn when the deadline becomes tighter, require approval for material changes, and record receipts.

Core product truth:

```text
Same goal + same deadline + different rejected step reason = different next step, different pressure projection, different receipt.
```

Ambitions must give the user choice without lying about consequences.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`. This train depends on TRAIN_03, TRAIN_04, and TRAIN_04A and sits after TRAIN_04A and before TRAIN_05.

Downstream dependency updates:
- TRAIN_05 depends on TRAIN_04B.
- TRAIN_06 depends on TRAIN_04B.
- TRAIN_07 depends on TRAIN_04B.
- TRAIN_10 depends on TRAIN_04B.
- TRAIN_16 depends on TRAIN_04B through the full train chain.

## Batch list
- IOS26-T04B-B01
- IOS26-T04B-B02
- IOS26-T04B-B03
- IOS26-T04B-B04
- IOS26-T04B-B05
- IOS26-T04B-B06

## User-facing language
Use:
- Start here
- Recommended step
- Not this
- Show another
- Why not this?
- Try a lighter step
- Keep deadline
- Adjust timeline
- This keeps you on track
- This makes the deadline tighter
- This likely delays the goal
- Choose this step

Avoid:
- failure
- noncompliance
- punishment
- AI replan
- users like you
- optimization bucket

## Source scope
See the exact source areas in each mapped batch prompt. Future implementation must inspect Runtime, Recommendation engine, Goal compiler, Today, Time, Goals, You, Persistence, Receipts, Replay, Services, Sources/Theme, Native/AmbitionsTests, Native/AmbitionsUITests, and Preview fixtures.

## Proof artifacts
Use `build/reports/step-optionality/` and the specific batch prompt.

## Train-level acceptance gate
Create `build/reports/step-optionality/TRAIN_04B_CLOSEOUT.md` when the train is executed.

The closeout must include:
- Status
- Batches completed
- Candidate field proof
- Rejection loop proof
- Deadline simulation proof
- Approval/receipt proof
- Simulation gauntlet proof
- Today UI proof
- Accessibility status
- Privacy/local-first status
- Known gaps
- Claims allowed
- Claims forbidden
- Next eligible train

## Claims allowed only if Green
- "Ambitions can generate multiple valid step candidates."
- "Rejected steps can change future recommendations."
- "Alternative steps can be simulated against the same goal deadline."
- "Ambitions can show when a lighter choice makes the deadline tighter."

## Claims forbidden unless proven
- "Unlimited steps"
- "Perfect alternatives"
- "Guaranteed goal completion"
- "Professional recruiting/training advice"
- "Medical advice"
- "Fully autonomous replanning"
- "App Store-ready simulation engine"

## Red conditions
- single-step-only recommendation engine
- fake alternatives that are copy changes only
- no deadline impact shown
- rejected steps immediately resurface without reason
- silent deadline/schedule mutation
- impossible deadlines shown as on track
- sensitive rejection reasons logged
- demographic template branching
- no deterministic replay
- no simulation gauntlet
- Today becomes a generic option list

## Red/Yellow/Green closeout rules
Green requires evidence. Yellow requires owner, reason, no-claim boundary, and gate. Red stops.

## Rollback strategy
Rollback only touched files. Preserve unrelated dirty work.

## Sequential commands for that train
```bash
scripts/ambitions-codex-train.sh IOS26-T04B-B01 prompts/batches/IOS26-T04B-B01-step-candidate-field.md
scripts/ambitions-codex-train.sh IOS26-T04B-B02 prompts/batches/IOS26-T04B-B02-rejection-reasoning-loop.md
scripts/ambitions-codex-train.sh IOS26-T04B-B03 prompts/batches/IOS26-T04B-B03-deadline-simulation-engine.md
scripts/ambitions-codex-train.sh IOS26-T04B-B04 prompts/batches/IOS26-T04B-B04-approval-receipts-learning.md
scripts/ambitions-codex-train.sh IOS26-T04B-B05 prompts/batches/IOS26-T04B-B05-exhaustive-simulation-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04B-B06 prompts/batches/IOS26-T04B-B06-today-optionality-ui.md
```

## Batch summaries
- IOS26-T04B-B01: `prompts/batches/IOS26-T04B-B01-step-candidate-field.md`
- IOS26-T04B-B02: `prompts/batches/IOS26-T04B-B02-rejection-reasoning-loop.md`
- IOS26-T04B-B03: `prompts/batches/IOS26-T04B-B03-deadline-simulation-engine.md`
- IOS26-T04B-B04: `prompts/batches/IOS26-T04B-B04-approval-receipts-learning.md`
- IOS26-T04B-B05: `prompts/batches/IOS26-T04B-B05-exhaustive-simulation-gauntlet.md`
- IOS26-T04B-B06: `prompts/batches/IOS26-T04B-B06-today-optionality-ui.md`

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
