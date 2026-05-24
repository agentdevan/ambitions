# Xcode Build Lab Protocol

Date: 2026-05-11
Owner: Ambitions Codex
Scope: Build/test reliability for global batch execution

## Purpose

Provide a local-first validation posture for runner-owned batches with deterministic
paths, narrow lanes, and conservative failure handling.

## Lane model

- `none` - no Xcode validation required
- `build` - full compile of production targets only (`xcodebuild build`)
- `build-for-testing` - compile once and emit build-for-testing artifacts
- `focused-test` - targeted test without rebuilding (`xcodebuild test-without-building`)
- `test-plan` - named test plan run
- `ui-proof` - UI proof lane, only where batch requires it
- `terminal-device-proof` - terminal proof lane, only where batch requires it

## Wrapper

Primary entrypoint:

- `scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane <lane> [--test <TEST_ID>] [--test-plan <PLAN_NAME>]`

The wrapper is non-mutating for control flow, but it may call dedicated helper
scripts that run xcodebuild.

Performance helper:

- `scripts/ambitions-xcode-benchmark.sh --status`
- `scripts/ambitions-xcode-benchmark.sh --batch <BATCH_ID> --lane <lane> -- <command> [args...]`

The validate wrapper also writes lane timing metadata for every run. Benchmark
summaries are timing evidence only; they are not build, test, release,
accessibility, device, TestFlight, or App Store proof.

## XcodeGen and rebuild policy

- `scripts/ambitions-xcodegen-needed.sh` determines project drift.
- Required regeneration happens before build-oriented lanes when inputs changed.
- `xcodegen generate` is preferred only when necessary.

## DerivedData policy

- Repo-local only: `.codex/DerivedData/Ambitions`
- Do not delete global DerivedData.
- Cleanup helper: `scripts/ambitions-deriveddata-manager.sh clean --batch <id> --reason ...`
- Clean local DerivedData only for mapped project drift / stale cache failures.

## Simulator policy

- Simulator lanes use `scripts/ambitions-xcode-sim-health.sh`.
- Preboot strategy:
  1. `AMBITIONS_SIM_UDID`
  2. `AMBITIONS_SIM_NAME`
  3. repo-standard fallback name (e.g., iPhone 17/16/15)
- Default preboot uses non-destructive repair (`--repair`).
- `--erase-selected` is explicit opt-in.
- Never erase all simulators by default.

## Artifacts

- Result bundles: `.codex/xcode-results/<BATCH>/<TIMESTAMP>/`
- Logs: `.codex/xcode-logs/<BATCH>/<TIMESTAMP>/`
- Summaries: `.codex/xcode-summaries/<BATCH>/<TIMESTAMP>/`
- Benchmarks: `.codex/xcode-benchmarks/<BATCH>/<TIMESTAMP>/`

All four roots are ignored by git.

## Failure mapping / retry

- Failures map to wrapper exit codes (10/20/21/22/23/24/25/26).
- Simulator sickness class triggers one retry with simulator repair.
- Slow validation must be diagnosed with `.codex/xcode-benchmarks` timing
  evidence before repo-local DerivedData cleanup or broader-suite escalation.
- Keep first observed command output and include mapped category.
- Failure causes are surfaced in validate summary and in wrapper stdout exit.

## No-claim policy

- Do not claim full-suite confidence, signed-device pass, App Store readiness, or
  production release proof from local wrapper execution alone.
- Claims must match local evidence and explicit batch proof gates.

## Continuation and rollback

- Wrapper updates are tooling-only and do not alter app behavior.
- To rollback phase tooling:
  - `git revert <commit-sha>`
  - remove wrapper/build-lab files listed for this batch
  - restore `.gitignore` entries
