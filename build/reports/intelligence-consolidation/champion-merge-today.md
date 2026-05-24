# AMB-CHAMPION-MERGE-TODAY-01

Status: YELLOW

## Guard Fields
- Champion coverage status: GREEN
- Champion coverage report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- Parallel guard pre status: GREEN
- Parallel guard pre report: `build/reports/parallel-implementation-guard/AMB-CHAMPION-MERGE-TODAY-01-pre.md`
- Parallel guard post status: YELLOW
- Parallel guard post report: `build/reports/parallel-implementation-guard/AMB-CHAMPION-MERGE-TODAY-01-post.md`
- Canonical owner extended: `today_root`
- New implementation owners: none
- Canonical owner map changed: no
- Supersession ledger updated: yes
- Best-code rescue checked: yes
- Runtime wiring gate: existing Today projector and Start Here surface only; no parallel runtime introduced
- Yellow accepted reason: accepted because the post guard has no defects, no new types, no duplicate risks, no runtime wiring gaps, and no old-term violations; its only warning is the intentional retirement deletion of `Native/Ambitions/Features/Today/TodayHeroStepSignaturePrimitives.swift`, recorded in the supersession and coverage ledgers.
- Red blockers: none

## Batch Summary
- Concept: Today / Start Here / legacy hero surface
- Canonical owner before: `today_root`
- Canonical owner after: `today_root`
- Competing implementations: `Sources/Previews/**`, historical Today hero/rail names
- Better fragments rescued: source, reason, receipt, proof, and replay/inspection labels, plus accessibility copy
- Active code changed: `Native/Ambitions/Features/Today/DayRailProjection.swift`, `Native/Ambitions/Features/Today/DayRailViewState.swift`, `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`, `Native/Ambitions/Features/Today/TodayStartHereSurface.swift`, `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`, `Native/Ambitions/Features/Today/TodayHeroStepSignaturePrimitives.swift` retired, `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- Runtime wires: `DayRailProjection -> TodayExecutionProjector -> StartHereSurface` using existing Today state
- SourceRecord: `Source record stays local`
- Receipt: `Start Here receipt seam`
- ReplayTrace: `Replay trace stays inspectable`
- You inspection: not changed in this batch
- Reset/delete: not changed in this batch
- Duplicates remaining: preview references and legacy names still exist as historical/compatibility references
- Retirement candidates: `TodayDayRailPanels` legacy naming, `TodayHeroStepSignaturePrimitives` legacy naming in historical references

## Validation
- `python3 scripts/ambitions-champion-coverage-check.py`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-CHAMPION-MERGE-TODAY-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-TODAY-01.md`
- `make xcode-focused-test BATCH=AMB-CHAMPION-MERGE-TODAY-01 TEST=AmbitionsTests/TodayViewModelTests` - passed; summary `.codex/xcode-summaries/AMB-CHAMPION-MERGE-TODAY-01/20260524T133423Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=AMB-CHAMPION-MERGE-TODAY-01 TEST=AmbitionsTests/TodayShellIntegrationTests` - passed; summary `.codex/xcode-summaries/AMB-CHAMPION-MERGE-TODAY-01/20260524T133653Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=AMB-CHAMPION-MERGE-TODAY-01 TEST=AmbitionsTests/ReplayableDecisionTraceTests` - passed; summary `.codex/xcode-summaries/AMB-CHAMPION-MERGE-TODAY-01/20260524T133906Z/focused-test-summary.json`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-CHAMPION-MERGE-TODAY-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-TODAY-01.md --changed-from 4dc56e993f8081740c702c3abcd6e76099f3881b --allow-yellow` - accepted Yellow for intentional legacy helper deletion only
- `git diff --check`

## Phase 04 Repair Pass 1
- Phase 04 inspected the post-guard Yellow and found no source repair inside the frozen Today boundary that would make the guard Green without undoing the intentional retirement of `Native/Ambitions/Features/Today/TodayHeroStepSignaturePrimitives.swift` or changing guard policy.
- Phase 04 reran `python3 scripts/ambitions-champion-coverage-check.py` - GREEN.
- Phase 04 reran `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-CHAMPION-MERGE-TODAY-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-TODAY-01.md` - GREEN.
- Phase 04 reran `make xcode-focused-test BATCH=AMB-CHAMPION-MERGE-TODAY-01 TEST=AmbitionsTests/TodayViewModelTests` - passed; summary `.codex/xcode-summaries/AMB-CHAMPION-MERGE-TODAY-01/20260524T134506Z/focused-test-summary.json`.
- Phase 04 reran `make xcode-focused-test BATCH=AMB-CHAMPION-MERGE-TODAY-01 TEST=AmbitionsTests/TodayShellIntegrationTests` - passed; summary `.codex/xcode-summaries/AMB-CHAMPION-MERGE-TODAY-01/20260524T134729Z/focused-test-summary.json`.
- Phase 04 reran `make xcode-focused-test BATCH=AMB-CHAMPION-MERGE-TODAY-01 TEST=AmbitionsTests/ReplayableDecisionTraceTests` - passed; summary `.codex/xcode-summaries/AMB-CHAMPION-MERGE-TODAY-01/20260524T135001Z/focused-test-summary.json`.
- Phase 04 reran `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-CHAMPION-MERGE-TODAY-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-TODAY-01.md --changed-from 4dc56e993f8081740c702c3abcd6e76099f3881b --allow-yellow` - accepted Yellow. The only guard warning remains the intentional retired-helper deletion; no duplicate risks, runtime wiring gaps, old-term violations, blocked concept violations, or concept-lock update requirements were reported.
- Phase 04 reran `git diff --check` - clean.
- Dirty-worktree boundary: unrelated repo-intelligence control-plane files appeared in the worktree during this phase and were not repaired, staged, or claimed as part of this Today batch.

## Phase 03 Review Repair
- The unqualified wrapper commands `TEST=TodayViewModelTests`, `TEST=TodayShellIntegrationTests`, and `TEST=ReplayableDecisionTraceTests` produced passed summary JSON, but their raw `focused-test.log` files show Xcode rejected those unqualified identifiers as not members of the scheme. Those unqualified runs are not accepted as XCTest proof.
- Phase 03 reran the same focused lanes with scheme-qualified identifiers under the repo wrapper and confirmed `** TEST EXECUTE SUCCEEDED **` in the raw logs listed above.
- Phase 03 also retired the unused legacy hero-panel helper instead of renaming it into a new implementation type, removed the active-source DayTimelineRail compatibility comment, and updated the champion coverage map.

## Proof Notes
- Today now surfaces source, reason, receipt, proof, and replay/inspection labels from the existing Today owner.
- No new owner, runtime engine, receipt ledger, or replay model was introduced.
- No release/device/simulator proof was claimed beyond the focused xcode test lanes above.

## Claims Allowed
- Start Here uses the canonical Today owner.
- Start Here exposes the rescued source/reason/receipt/proof/replay wording.
- Focused Today, shell, and replay-trace tests passed.

## Claims Forbidden
- Release proof
- Device proof
- App Store / TestFlight readiness
- Any claim that the broader Today surface is complete beyond the focused batch scope
