# Harness Runs

Slice 1 run notes.

## Current support install

Batch: `IOS26-HARNESS-T02-B01-artifact-proof-wrapper-static-gates`

- Install focus: artifact helper, inventory-only proof wrapper, static gates, scorecard, and follow-up prompt.
- Output root: `build/reports/harness/<batch-id>/<utc-timestamp>/`
- Claims not made: app build, app tests, simulator proof, accessibility proof, performance proof, device proof, TestFlight readiness, App Store readiness, or release readiness.

## Existing support runs

- `HARNESS-T00-B01-baseline-audit` recorded the slice 1 baseline state.
- `HARNESS-T01-B01-docs` verified the installed docs-only support surface.

## Validation posture

- `python3 -m py_compile scripts/harness/ambitions-artifact-helper.py scripts/harness/ambitions-static-gates.py`
- `bash -n scripts/harness/ambitions-proof-wrapper.sh`
- `python3 scripts/harness/ambitions-static-gates.py`
- `bash scripts/harness/ambitions-proof-wrapper.sh --inventory-only --batch IOS26-HARNESS-T02-B01-artifact-proof-wrapper-static-gates`
- `git status --short`

These are support-tooling validations only. They do not prove app behavior or release posture.
