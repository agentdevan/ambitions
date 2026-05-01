# Batch Train Continuation Pack

Path: .codex/validation/batch-train-continuation-pack.md
Status: Active validation pack

## Purpose
Decide whether Codex may continue automatically.

## Required Checks
- git status and allowed/forbidden file diff review
- task width did not escalate
- build/focused tests for implementation work
- copy guard for touched visible strings
- privacy/trust review for touched projection or memory/receipt data
- accessibility identifier and label preservation for touched UI
- no runtime dependency additions
- no workflow edits
- report Green/Yellow/Red with evidence

## Output
Validation summary with verified, failed, not verified, and human/device follow-up separated.
