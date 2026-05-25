# IOS26-T04H-B03 Labels, Filters, And Saved Views

Status: Yellow
Batch: IOS26-T04H-B03
Train: TRAIN_04H / Project Step Operations / Todoist Things Replacement

## Scope

- Add local deterministic labels/tags to `OneStepGoal`.
- Project filterable saved views for the B03 P0 contract.
- Keep the behavior local, inspectable, and replay-safe without adding a new task engine.

## Source behavior changed

- `OneStepGoal` now derives stable local label tags from existing source, status, timing, proof, and review fields.
- `OneStepGoalProjector` now projects:
  - a local label index,
  - filter summaries,
  - saved-view summaries.
- Label and saved-view projection now excludes sensitive, explicitly hidden, hidden-area, and fully redacted items so local discovery does not leak protected source/proof/review categories.
- Saved-view membership preserves the incoming local order of eligible items instead of re-sorting them, so filtered views stay inspectable and deterministic.
- `privacySafeCompact` strips label rows and clears filter/saved-view counts, IDs, and criteria tags so compact redacted projections do not leak work discovery metadata.
- The projected view set covers:
  - `labels/tags`
  - `Today`
  - `Upcoming`
  - `Scheduled`
  - `Open`
  - `Waiting`
  - `Blocked`
  - `Held`
  - `Someday/Future`
  - `Proof Needed`
  - `Needs Review`
  - `Source Needed`
- `IOS26TodoistP0ContractHarnessTests` now asserts the expanded filter/saved-view contract while preserving the `SourceRecord` / `Receipt` / `ReplayTrace` / `What Ambitions knows` inspection seam.

## Proof points

- Labels/tags are derived deterministically from the local `OneStepGoal` shape.
- Filters and saved views are generated from the same local projection logic.
- Saved views preserve the source order of eligible items rather than inventing a new ranking.
- Hidden and sensitive One-Step Goals remain out of label/filter/saved-view ID lists.
- Redacted compact projections do not carry label rows, saved-view/filter membership IDs, or criteria tags.
- The projection remains inspectable through the existing project-step and Todoist contract harness boundaries.
- No UI, network, hosted backend, or cloud LLM dependency was introduced.

## Validation run

- `git diff --check -- Native/Ambitions/Domain/OneStepGoalModels.swift Native/Ambitions/Services/OneStepGoalProjector.swift Native/AmbitionsTests/Services/OneStepGoalProjectorTests.swift Native/AmbitionsTests/Domain/IOS26TodoistP0ContractHarnessTests.swift Native/AmbitionsTests/Domain/OneStepGoalModelsTests.swift build/reports/project-step-operations/labels-filters-saved-views.md build/reports/project-step-operations/IOS26-T04H-B03.md prompts/batches/IOS26-T04H-B03-labels-filters-and-saved-views.md`
- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04H-B03`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch IOS26-T04H-B03 --prompt prompts/batches/IOS26-T04H-B03-labels-filters-and-saved-views.md --allow-yellow`
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04H-B03`
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04H-B03`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04H-B03 --prompt prompts/batches/IOS26-T04H-B03-labels-filters-and-saved-views.md --changed-from 8b0e099336449c97463a22799a793e4eb341cfe4 --allow-yellow`
- `scripts/codex-forbidden-claim-scan.sh build/reports/project-step-operations/labels-filters-saved-views.md build/reports/project-step-operations/IOS26-T04H-B03.md prompts/batches/IOS26-T04H-B03-labels-filters-and-saved-views.md`
- `python3 tools/mcp/ambitions_repo_mcp/server.py --self-test`
- `python3 tools/mcp/ambitions_proof_mcp/server.py --claim-scan`

## Validation results

- `git diff --check` passed.
- Champion coverage check passed.
- Parallel guard pre check passed with accepted Yellow boundary on `proof_receipt_replay`.
- IOS26 flagship preflight passed.
- Core replacement proof shape check passed.
- Parallel guard post check returned Yellow with the accepted `proof_receipt_replay` lock and no duplicate/runtime wiring issues.
- Claim scan found no blocking report hits; targeted MCP claim scan reported existing forbidden-claim strings only inside a negative-test fixture.
- Ambitions Repo MCP self-test passed.

## Phase 04 repair pass

- Final gate added one additional compact-redaction repair after the Phase 04 report: filter/saved-view criteria tags are now cleared in `privacySafeCompact`.
- Current source redacts labels and clears filter/saved-view counts, membership IDs, and criteria tags in `privacySafeCompact`.
- Non-Xcode validation was rerun on 2026-05-25 under `AMBITIONS_SKIP_XCODE_TESTING=1`.
- `scripts/ambitions-xcode-benchmark.sh --status` confirmed the benchmark helper is installed, with timing evidence only and no build/test/release claim.

## Validation not run

- Xcode build, XCTest, simulator, device, accessibility, performance, CI, TestFlight, App Store, and release validation were skipped because `AMBITIONS_SKIP_XCODE_TESTING=1` is set.

## Proof artifacts

- `build/reports/project-step-operations/labels-filters-saved-views.md`
- `build/reports/project-step-operations/IOS26-T04H-B03.md`

## Claims allowed

- Source-level labels, filters, and saved-view projection behavior.
- Local inspection and replay-safe contract proof through existing harnesses.

## Claims forbidden

- Build, XCTest, simulator, device, accessibility, performance, CI, TestFlight, App Store, or release claims.

## Yellow items

- Xcode validation is intentionally paused by operator policy.
- The accepted `proof_receipt_replay` Yellow boundary remains in effect.
- Saved-view ordering is intentionally source-order preserving rather than re-ranked.
- Repo-intelligence findings were used only as advisory routing and verified through direct source/report inspection.

## Red items

- None.
