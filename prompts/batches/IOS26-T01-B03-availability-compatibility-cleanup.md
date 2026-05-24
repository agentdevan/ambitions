<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T01-B03 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T01-B03`

## Train ID and title
`TRAIN_01` - iOS 26 minimum migration foundation

## Batch role in train
Batch 3 of 3 in TRAIN_01

## Upstream dependencies
- `TRAIN_00`

## Downstream dependencies
- `TRAIN_02`
- `TRAIN_03`
- `TRAIN_11`

## Objective
Remove only obsolete availability branches made impossible by iOS 26 minimum.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
No cloud AI/LLM, hosted backend, analytics/tracking SDK, or privacy manifest weakening.

## Accessibility constraints
Do not claim accessibility proof. Preserve accessibility behavior if scripts or source are touched.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.

## Allowed files/directories
Source edits limited to availability branches whose lower OS check is impossible after iOS 26 minimum.
build/reports/ios26-migration/availability-cleanup.md

## Forbidden files/directories
Do not remove legacy route aliases yet. Do not change UI behavior beyond removing impossible branches.

## Exact implementation steps
1. Grep for #available, @available, and if #available.
2. Verify each candidate API still exists under the local SDK.
3. Remove only redundant branches and keep behavior identical.
4. Add/update tests if branch removal changes coverage.

## Validation commands
```bash
grep -RIn "#available\|@available\|if #available" Native Sources AppUI 2>/dev/null || true
xcodegen generate
scripts/build-local.sh
```

## Proof artifacts to write
build/reports/ios26-migration/availability-cleanup.md
- `build/reports/ios26-baseline/`
- `build/reports/ios26-migration/`
- `build/reports/ios26-shell/`
- `build/reports/private-life-runtime/`
- `build/reports/goal-intent-compiler/`
- `build/reports/life-context/`
- `build/reports/step-optionality/`
- `build/reports/source-atlas-runtime-bridge/`
- `build/reports/capture-runtime-bridge/`
- `build/reports/core-replacement-contracts/`
- `build/reports/core-life-object-store/`
- `build/reports/time-operations/`
- `build/reports/reminder-operations/`
- `build/reports/project-step-operations/`
- `build/reports/life-knowledge-operations/`
- `build/reports/life-command-search/`
- `build/reports/private-life-runtime-integration/`
- `build/reports/reality-meridian/`
- `build/reports/lifeshape-field/`
- `build/reports/constellation-atlas/`
- `build/reports/atmosphere-composer/`
- `build/reports/user-system-profile/`
- `build/reports/proof-receipts-replay/`
- `build/reports/data-safety/`
- `build/reports/external-surfaces/`
- `build/reports/accessibility-nutrition/`
- `build/reports/performance/`
- `build/reports/repo-hygiene/`
- `build/reports/release-candidate/`

## Green / Yellow / Red gates
Green: scoped work complete with evidence and no forbidden changes.
Yellow: blocker or proof gap explicit with owner, no-claim boundary, and post-batch gate.
Red: forbidden change, missing runner metadata, unverified API adoption, privacy/local-first breach, or false release/readiness claim.

## Rollback behavior
Revert only files touched by this batch. Do not reset unrelated work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
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

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
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
----- END ORIGINAL PROMPT -----
