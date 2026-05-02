# ME04 TodayPanels Extraction Report
<!-- markdownlint-disable MD013 -->

Status: PASS WITH YELLOW
Date: 2026-05-02

## Batch

- Batch ID: ME04
- Batch name: TodayPanels Extraction
- Global order number: 031
- Train: ME maintainability extraction train
- Result: PASS WITH YELLOW
- Validation strength: Strong implementation validation

## Continuation Memory Note

- Last completed batch: ME03 TodayFeatureService Extraction
- Last commit SHA: `5c56965d9c4a850828e58183b65869e1ed4bf372`
- Current global order number: 031
- Next selected batch: ME04 TodayPanels Extraction
- Unresolved Red count: 0 after repair
- Unresolved Yellow count: 4
- Deferred Yellow owners: docs QA backlog; human/operator proof remains REC/release-owned; remaining Today/ME extraction debt remains ME05-ME07/ME09-owned; architecture scan large-file advisories remain ME-owned
- Current validation strength: Strong for ME04 implementation
- Continuation allowed: Yes after ME04 commit/push; next eligible batch is ME05 only after dry-run selection says `Execution allowed: YES`

## Dry-Run Selection

- Selected global batch: 031 ME04 TodayPanels Extraction
- Batch prompt path: `docs/codex/batches/ME04_TodayPanels_Extraction_Prompt.md`
- Train: ME
- Current status before edits: queued/blocked/not started; direct successor after ME03
- Approval phrase satisfied: yes, `Run Global Batch Sequence Until Blocked` covers routine ME train continuation under the global continuation protocol
- Allowed files: `Native/Ambitions/Features/Today/TodayPanels.swift`, directly extracted Today panel/component files, focused tests if needed, `docs/**`, and `.codex/**`
- Forbidden files: workflows, dependencies, signing/project config, persistence/schema, route/raw-value changes, visual redesign, behavior expansion, copy/accessibility identifier changes, release/platform claims, unrelated refactors
- Required gates: ME01 Green, ME08 Green/accepted Yellow, ME10 Green/accepted Yellow, ME02 Green, ME03 Green, source truth, scope boundary, maintainability, file-size/diff-size, testability, compatibility, release-claim safety, validation evidence, rollback, continuation
- Expected validation strength: Strong implementation validation
- Human-proof risk: Low
- Expected stop condition: unsafe owner ambiguity, behavior drift, build/test failure, route/raw-value/persistence/accessibility uncertainty, or weak implementation validation
- Execution allowed: YES

## Execution Budget

- Max file count touched: 10
- Max intended new files: 2
- Max intended deleted files: 0
- Max diff size category: Medium
- App code allowed: yes, Today panel/support only
- Docs-only mode: no
- Tests may be edited: only if valid behavior-preservation proof requires it; no test edits were made
- Screenshots/previews required: no, because no UI behavior changed
- Human proof may be required: no

Actual touched-file count stayed within budget at 8 files.

## Scope Completed

ME04 performed one narrow behavior-preserving extraction from
`TodayPanels.swift`.

The Day Rail / Step Detail panel family moved into
`TodayDayRailPanels.swift`. This includes `AmbitionsDayRailView`,
Day Rail hero/section/row/reserved-slot/private-state components,
`TodayStepDetailSheet`, and the rail node/shape helpers.

The live Today product behavior, visible UI, copy, accessibility identifiers,
routes, raw values, persistence/schema, dependencies, workflows, project
configuration, and release posture were not changed.

## Files Changed

- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `docs/audits/me04-today-panels-extraction-report.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Created

- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `docs/audits/me04-today-panels-extraction-report.md`

## Source Files Read

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_4_0_Execution_Program.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/batches/ME04_TodayPanels_Extraction_Prompt.md`
- `docs/canon/Ambitions_Beyond_3_0_Maintainability_Extraction_Plan.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/audits/me03-today-feature-service-extraction-report.md`
- `.codex/skills/large-file-extraction-architect.md`
- `.codex/skills/faang-staff-ios-architect.md`

## Code Files Inspected

- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- Today-focused tests selected through `AmbitionsTests`

## Responsibilities Moved

`TodayDayRailPanels.swift` now owns the Day Rail / Reality Rail presentation
family and Step Detail sheet presentation family. The file stays feature-local
and does not create a generic card/component bucket.

`TodayPrimaryActionButton` changed from file-private to app-module internal so
the extracted Day Rail file can keep using the existing action button without
duplicating or redesigning it. The button implementation, copy,
accessibility identifiers, and action routing were not changed.

## File-Size And Complexity Snapshot

| File | Before | After | Result |
| --- | ---: | ---: | --- |
| `TodayPanels.swift` | 2,423 | 1,741 | Reduced by 682 lines |
| `TodayDayRailPanels.swift` | 0 | 686 | New focused Day Rail / Step Detail panel file |
| Combined touched Today panel footprint | 2,423 | 2,427 | Net +4 lines from file headers/import boundary |

`TodayPanels.swift` still exceeds the large-file threshold and remains an
ME-owned risk, but ME04 materially reduced the owner file without adding
behavior. Future extraction should continue splitting coherent panel families
instead of adding new Today UI behavior to the owner file.

## Compatibility And Product Boundaries

- Routes/raw values: unchanged.
- Persistence/schema: unchanged.
- External surfaces/import/export: unchanged.
- Accessibility identifiers: unchanged.
- User-facing copy: unchanged.
- Top-level navigation: unchanged; `Today / Goals / Capture / Plan / You` remains locked.
- Product behavior: unchanged.
- Signature Interface: not implemented.

## Red Issues Fixed

ME04 found one current-batch Red during validation:

- `scripts/build-local.sh` initially failed because the extracted
  `TodayDayRailPanels.swift` file could not see `TodayPrimaryActionButton`,
  which had been file-private inside `TodayPanels.swift`.

Repair:

- `TodayPrimaryActionButton` was changed from file-private to app-module
  internal. This preserves a single shared implementation and avoids duplicating
  the action button in the extracted file.

Validation after repair:

- `scripts/build-local.sh` passed on `iPhone 17`.
- Focused Today behavior-preservation tests passed with 44 tests and 0 failures.

## Validation Commands Run

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `wc -l Native/Ambitions/Features/Today/TodayPanels.swift Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `xcodegen generate`
- `git diff --check`
- `scripts/build-local.sh`
- Focused `xcodebuild test` for:
  `TodayViewModelTests`, `TodayFreshGoalVisibilityTests`,
  `TodayShellIntegrationTests`, `CalendarReminderActionFlowTests`, and
  `DailyLoopAlphaQATests`
- `scripts/swiftui-architecture-scan.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- release/PXOS/AOS/Product Depth/Signature Interface claim scan
- changed-file boundary check

Results:

- Branch/status preflight: `main` at
  `5c56965d9c4a850828e58183b65869e1ed4bf372` before ME04 edits.
- `xcodegen generate`: pass; no project-file drift.
- Initial `scripts/build-local.sh`: Red, missing `TodayPrimaryActionButton`
  visibility; log `output/logs/build-local-20260502-122248.log`.
- Repaired `scripts/build-local.sh`: pass on `iPhone 17`; log
  `output/logs/build-local-20260502-122415.log`.
- Focused Today tests: pass, 44 tests, 0 failures; log
  `output/logs/me04-focused-tests-20260502-122514.log`.
- Architecture scan: Yellow advisory expected from existing repo-wide large
  owner files; `TodayPanels.swift` is reduced to 1,741 lines and still
  extraction-required; `TodayDayRailPanels.swift` is responsibility-review at
  686 lines.
- Doc QA: Yellow advisory expected from existing stale-guidance,
  deprecated-language, and markdownlint backlog; lychee reports 647 links OK.
- Batch-train gate check: expected dirty-tree advisory before ME04 commit.
- Release/platform claim scan: hits are forbidden-claim lists, scan commands,
  historical logs, or explicit non-claims; no active readiness claim introduced.

## Yellow Advisories Deferred

- Existing Repo-Wide Advisory: docs QA backlog remains outside ME04 scope.
- Already Owned by Later Batch: `TodayPanels.swift` still exceeds the
  large-file threshold; ME continuation owns further splits.
- Already Owned by Later Batch: broader Today surface/signature redesign remains
  future SI/PD-owned, not ME04-owned.
- Human-Proof Advisory: release/operator proof remains REC/release-owned and
  blocks readiness upgrades.

## What ME04 Claims

- ME04 completed one behavior-preserving TodayPanels extraction.
- Day Rail / Step Detail presentation now lives in a dedicated feature-local
  panel file.
- The current-batch compile Red was fixed without weakening tests or product
  canon.
- Native build and focused Today behavior tests passed after the repair.

## What ME04 Does Not Claim

- No product behavior expansion.
- No UI redesign or Signature Interface implementation.
- No Product Depth implementation.
- No PXOS implementation.
- No AmbitionsOS implementation.
- No compatibility seam retirement.
- No release readiness, App Store readiness, TestFlight readiness,
  physical-device proof, signed archive proof, public accessibility proof,
  legal/privacy signoff, platform proof, final release approval, or human proof.

## Rollback Path

Revert the ME04 commit and any ME04 post-commit report-SHA repair commit. That
restores the Day Rail / Step Detail panel family to `TodayPanels.swift`, returns
`TodayPrimaryActionButton` to file-private visibility, and removes the ME04
status evidence.

## Next Eligible Batch

The next global batch is ME05 PlanFeatureService Extraction only if its dry-run
selection says `Execution allowed: YES` and ME04 commit/push drift checks pass.

## Commit SHA

Pending commit.
