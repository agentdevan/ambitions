# Linear Closeout Standard

Status: Active Codex OS v2 standard
Authority: Process standard, subordinate to repo truth and actual Linear state

## What It Is

Linear closeout is an evidence-backed status update after a successful push to `main`.

## What It Is Not

Linear is not repo truth. Linear Done does not prove implementation, release readiness, accessibility, privacy/legal approval, or owner approval unless current evidence exists.

## Required Inputs

Issue IDs, branch, pushed hash, changed files, validation commands and exits, proof paths, run-state status, Green/Yellow/Red, non-claims, and next gate.

## Required Output

Closeout must state issues covered, pushed to main, push hash, app source changed, new parallel OS created, existing OS extended, runner active-default status, Goal Mode default status, installed components, validation run, Red blockers, Yellow drift, owner approval claimed, release/TestFlight/App Store readiness claimed, and next action.

## Validation

Use `python3 scripts/codex/linear-closeout-validate.py <file>` or stdin. The validator is local-only and never updates Linear.

## Green / Yellow / Red

Green: push hash verified, no hidden Red, validation/proof cited, no overclaims.
Yellow: Linear access unavailable or non-blocking proof remains with manual text prepared.
Red: push not verified, app source changed unexpectedly, or owner/release/accessibility/privacy claims lack evidence.

## Repair / Rollback / Linear

Repair closeout text before posting. If access is unavailable or issues do not exist, write exact manual closeout text in the program report. Correct wrong Linear comments with a follow-up comment rather than deleting history.
