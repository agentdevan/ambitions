# Prompt Patterns

Use these patterns when a request keeps arriving underspecified or misclassified.

## Strong Intake Pattern

- desired outcome
- repo area or feature surface
- whether this is plan-only, plan-plus-implement, validate-only, or release-hardening
- what must be preserved
- what was actually verified versus only desired

## Weak Prompt Signals To Correct In Review

- `make this better` with no target files or surface
- `add support` when runtime seam is unspecified
- `validate this` with no mention of environment limits
- `ship this` with no release-readiness definition

## Ambitions Examples

- good: `Expand CaptureSourceType for notification-originated captures, stop if runtime ingestion would require a new seam, and separate verified from unverified.`
- weak: `Make notifications work.`
- good: `Prepare this branch for merge, check docs truth, config, and validation gaps, and say exactly what was not verified.`
- weak: `Final polish before ship.`
