# Batch Execution Protocol

Use this protocol for active post-hardening frontend transformation batches.

## Goals

- preserve quality
- reduce repeated canon rereads
- reduce validation thrash
- keep one active batch at a time
- make closeout truth explicit

## Required Start Slice

Before any plan, implementation, or closeout pass:

1. check `docs/codex/BATCH_REGISTRY.md`
2. check the active batch doc in `docs/codex/batches/`
3. check any touched program-status wording in `docs/canon/Ambitions_Full_Frontend_Transformation_Program.md`
4. reconcile only narrow stale status truth before broader work

Do not start product edits while the active batch doc still says `Queued`.

## Fixed Three-Pass Loop

### 1. Batch Plan Pass

Required outputs:

- current-state findings
- exact files/modules/docs to touch
- implementation slices in order
- validation plan using the transformation validation matrix
- risks / drift checks
- explicit touch budget

Rules:

- no implementation in this pass
- no future-batch work
- identify the narrowest truthful canon/design read set
- decide whether full `AmbitionsUITests` is actually needed

### 2. Batch Implementation Pass

Required behavior:

- execute only the approved touch budget
- use the smallest safe slice first
- avoid opportunistic cleanup outside the batch seam
- do not reopen prior-batch architecture without a proven bug

Rules:

- if new drift is found, correct only the touched control truth
- if a blocker appears, stop with exact root cause, exact files, and the smallest next fix
- do not silently convert implementation into broad QA wandering

### 3. Batch Closeout Pass

Required behavior:

- run only the validations required by the matrix and the batch plan
- perform the relevant manual signoff checklist
- update control docs only if the closeout gate is actually complete
- commit
- push directly to `main`
- verify `origin/main == HEAD`

Rules:

- closeout is not a feature pass
- if only one bounded bug remains, fix only that bug
- if only manual signoff remains, stop and ask for or use human signoff instead of looping broad reruns

## Pass Expansion Rule

Do not create a fourth pass by default.
A fourth pass is allowed only when one of these is true:

- a real product bug was found during validation
- a known flake must be isolated to prove it is still bounded
- the user explicitly requests a broader repo review

## Touch Budget Rule

Every implementation prompt must name:

- primary files
- secondary files only if strictly needed
- files that must not be touched

If a new file becomes necessary mid-run, explain why before widening.

## Validation Truth Rule

Every closeout summary must separate:

- verified
- not verified
- known accepted caveats
- manual follow-up still required

Do not convert isolated proof into claims about full-suite proof.

## Manual Signoff Rule

Use manual signoff when:

- the surface is highly visual or posture-dependent
- reduced motion and readability matter more than raw UI-test coverage
- a bounded combined UI flake remains after isolated reruns

Manual signoff is not a shortcut. It is a required quality gate for premium surface work.

## Wrap Requirements

A batch is only wrapped when all of these are true:

- active-batch scope is complete
- validation meets the planned bar
- manual signoff is complete when required
- control docs reflect the actual result
- commit created
- pushed directly to `main`
- `origin/main == HEAD`

## Required Wrap Output

1. implementation summary
2. exact files changed
3. validation results
4. verified
5. not verified
6. whether the batch is complete
7. exact commit hash if committed
8. confirmation whether changes were pushed to GitHub `main`
9. confirmation whether `origin/main` matches local `HEAD`
10. remaining risks / drift checks
