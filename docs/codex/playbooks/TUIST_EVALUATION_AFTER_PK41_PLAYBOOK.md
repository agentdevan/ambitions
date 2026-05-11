# Playbook: Tuist Evaluation After PK41

## Trigger

- Evaluate only after PK41 and when active truth allows platform-framework alignment.

## Objective

- Confirm whether Tuist provides measurable non-destructive benefits for this repo.

## Boundaries

- No migration or source-of-truth changes are made in this batch.
- Maintain current XcodeGen + XcodeLab wrapper flow until evaluation is approved.

## Evidence required

- Repo-local `xcodebuild` time and failure-rate comparison
- XcodeGen + build graph stability evidence
- Team/operator risk matrix and rollback cost

## Decision outputs

- Continue XcodeGen + wrapper path, defer Tuist migration, or create a short
  follow-on batch if clear safety and value criteria are met.
