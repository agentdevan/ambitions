# Xcode Result Bundle Protocol

Date: 2026-05-11

## Artifact roots

- Result bundles: `.codex/xcode-results/<BATCH>/<timestamp>/`
- Raw logs: `.codex/xcode-logs/<BATCH>/<timestamp>/`
- Structured summaries: `.codex/xcode-summaries/<BATCH>/<timestamp>/`

## Required wrapper output

Each wrapper invocation writes:
- `.xcresult` bundle
- command log
- wrapper summary JSON (`validate-summary.json`)
- optional extracted summary via `scripts/ambitions-xcode-result-extract.sh`

## When to extract

Run extraction after non-no-op lanes:
- `build-for-testing`
- `focused-test`
- `test-plan`
- `ui-proof`
- `terminal-device-proof`

Extraction is a no-op if `xcparse` is missing; raw logs and bundle path remain usable for follow-up.

## Commit policy

- `.codex/xcode-results`, `.codex/xcode-logs`, `.codex/xcode-summaries` are ignored and should not be committed.
- Store only summary pointers in audits when needed.

## Final evidence

- Batch and audit docs should reference:
  - exit code
  - lane
  - failure category
  - timestamps/artifact root path
