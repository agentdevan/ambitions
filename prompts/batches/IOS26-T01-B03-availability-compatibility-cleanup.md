<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T01-B03 — Availability compatibility cleanup

## Batch type
Compatibility cleanup

## Objective
Remove only obsolete availability branches made impossible by iOS 26 minimum.

## Why this exists
After iOS 26 minimum, old availability guards add noise and can hide dead code.

## Dependencies
IOS26-T01-B02.

## Truth files to read
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Exact source areas to inspect
Native/Ambitions/
Native/AmbitionsWidgetExtension/
Native/AmbitionsShareExtension/
Sources/
AppUI/Sources/

## Exact changes allowed
Source edits limited to availability branches whose lower OS check is impossible after iOS 26 minimum.
build/reports/ios26-migration/availability-cleanup.md

## Exact changes forbidden
Do not remove legacy route aliases yet. Do not change UI behavior beyond removing impossible branches.

## Implementation steps
1. Grep for #available, @available, and if #available.
2. Verify each candidate API still exists under the local SDK.
3. Remove only redundant branches and keep behavior identical.
4. Add/update tests if branch removal changes coverage.

## Tests to add/update
Focused tests for touched code.

## Commands to run
```bash
grep -RIn "#available\|@available\|if #available" Native Sources AppUI 2>/dev/null || true
xcodegen generate
scripts/build-local.sh
```

## Required proof artifacts
build/reports/ios26-migration/availability-cleanup.md

## Accessibility requirements
Do not claim accessibility proof. Preserve accessibility behavior if scripts or source are touched.

## Privacy/local-first requirements
No cloud AI/LLM, hosted backend, analytics/tracking SDK, or privacy manifest weakening.

## iOS 26 API verification requirements
Green only when impossible branches are removed and build passes. Yellow when SDK verification is unavailable and no source change is made. Red for behavioral rewrite beyond scope.

## Green / Yellow / Red closeout rules
Green: scoped work complete with evidence and no forbidden changes.
Yellow: blocker or proof gap explicit with owner, no-claim boundary, and post-batch gate.
Red: forbidden change, missing runner metadata, unverified API adoption, privacy/local-first breach, or false release/readiness claim.

## Rollback strategy
Revert only files touched by this batch. Do not reset unrelated work.

## Final report format
```text
Status: Green / Yellow / Red
Batch:
Train:
Scope:
Branch:
Commit:
Files changed:
Truth files inspected:
Source areas inspected:
Commands run:
Commands not run:
Environment:
Evidence:
Passes:
Failures:
Skipped:
Unproven:
Accessibility status:
Privacy/local-first status:
iOS 26 API verification status:
Claims allowed:
Claims forbidden:
Release blockers:
Post-batch gates:
Rollback:
Next eligible batch:
```
