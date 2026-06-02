# AESP-013 Goals / Constellation Atlas Evidence

- Batch: `AESP-013`
- Branch: `main`
- Base commit: `778c9218c84c2a22762e1334aa41152ed28f3786`
- Evidence timestamp UTC: `2026-06-02T03:04:14Z`
- Worktree status: dirty with pre-existing unrelated changes outside this patch slice

## Files Changed

- `Native/Ambitions/Features/Goals/GoalsOverviewBoardProjection.swift`
- `Native/Ambitions/Features/Goals/GoalsOverviewProjector.swift`
- `Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift`
- `build/reports/aesp/AESP-013/goals-constellation-atlas-evidence.md`

## Why This Changed

- Removed numeric priority-position copy from the Goals atlas card projection and replaced it with qualitative direction language.
- Strengthened state-specific copy for active, crowded, stalled, blocked, waiting, protected, completed, archived, low-proof, and manual-fallback cases.
- Added regression coverage for no-goals empty copy, waiting-state copy, low-proof state, and no-plan manual fallback.
- Preserved the existing Goals owner path and the source/receipt/replay/You inspection basis already wired into the surface.

## Validation

### Passed

- `python3 scripts/ambitions-champion-coverage-check.py --batch AESP-013`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AESP-013 --prompt prompts/batches/AESP-013.md --batch-type source-changing --allow-yellow`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AESP-013`
- `make xcode-focused-test BATCH=AESP-013 TEST=AmbitionsTests/GoalsOverviewAtlasTests`
- `make xcode-focused-test BATCH=AESP-013 TEST=AmbitionsTests/GoalsShellIntegrationTests`
- `make xcode-focused-test BATCH=AESP-013 TEST=AmbitionsTests`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AESP-013 --prompt prompts/batches/AESP-013.md --changed-from 778c9218c84c2a22762e1334aa41152ed28f3786 --batch-type source-changing --allow-yellow`

### Wrapper Evidence

- Champion coverage report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- Parallel guard pre report: `build/reports/parallel-implementation-guard/AESP-013-pre.md`
- Parallel guard post report: `build/reports/parallel-implementation-guard/AESP-013-post.md`
- Build-for-testing summary: `.codex/xcode-summaries/AESP-013/20260602T024552Z/build-for-testing-summary.json`
- Build-for-testing log: `.codex/xcode-logs/AESP-013/20260602T024552Z/build-for-testing.log`
- Build-for-testing result bundle: `.codex/xcode-results/AESP-013/20260602T024552Z/build-for-testing.xcresult`
- Focused Goals atlas summary: `.codex/xcode-summaries/AESP-013/20260602T024716Z/focused-test-summary.json`
- Focused Goals atlas log: `.codex/xcode-logs/AESP-013/20260602T024716Z/focused-test.log`
- Focused Goals shell summary: `.codex/xcode-summaries/AESP-013/20260602T024820Z/focused-test-summary.json`
- Focused Goals shell log: `.codex/xcode-logs/AESP-013/20260602T024820Z/focused-test.log`
- Broad `AmbitionsTests` summary: `.codex/xcode-summaries/AESP-013/20260602T024918Z/focused-test-summary.json`
- Broad `AmbitionsTests` log: `.codex/xcode-logs/AESP-013/20260602T024918Z/focused-test.log`

### Phase 03 Review Rerun Evidence

- Build-for-testing summary: `.codex/xcode-summaries/AESP-013/20260602T025653Z/build-for-testing-summary.json`
- Build-for-testing log: `.codex/xcode-logs/AESP-013/20260602T025653Z/build-for-testing.log`
- Build-for-testing result bundle: `.codex/xcode-results/AESP-013/20260602T025653Z/build-for-testing.xcresult`
- Focused Goals atlas summary: `.codex/xcode-summaries/AESP-013/20260602T025751Z/focused-test-summary.json`
- Focused Goals atlas log: `.codex/xcode-logs/AESP-013/20260602T025751Z/focused-test.log`
- Focused Goals shell summary: `.codex/xcode-summaries/AESP-013/20260602T025852Z/focused-test-summary.json`
- Focused Goals shell log: `.codex/xcode-logs/AESP-013/20260602T025852Z/focused-test.log`
- Broad `AmbitionsTests` summary: `.codex/xcode-summaries/AESP-013/20260602T025947Z/focused-test-summary.json`
- Broad `AmbitionsTests` log: `.codex/xcode-logs/AESP-013/20260602T025947Z/focused-test.log`

## Accessibility And Visual Status

- Dynamic Type: reviewed in source paths only; no new truncation-sensitive layout was introduced in the projection layer.
- Reduce Motion: no new motion-dependent behavior was added.
- Visual proof: not run.
- Device proof: not run.
- Manual accessibility audit: not run.

## Known Yellow Items

- No screenshot/session-based visual proof was run.
- No device-based accessibility verification was run.
- The worktree also contains unrelated pre-existing changes outside this patch slice:
  - `.swiftpm/xcode/xcuserdata/devan.xcuserdatad/xcschemes/xcschememanagement.plist`
  - `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-a.json`
  - `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-b.json`

## Proof Boundaries

- This batch proves source-backed Goals copy, state projection, and test coverage only.
- It does not claim device-verified polish, screenshot parity, or release readiness.
- It does not change app routes, persistence, entitlements, dependency graph, or top-level IA.

## Repair Notes

- The first focused test run exposed stale expectations around waiting and manual-fallback copy.
- Those assertions were corrected and rerun to green before closeout.

## Rollback Notes

- Restore the slice with:

```bash
git restore Native/Ambitions/Features/Goals/GoalsOverviewBoardProjection.swift Native/Ambitions/Features/Goals/GoalsOverviewProjector.swift Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift build/reports/aesp/AESP-013/goals-constellation-atlas-evidence.md
```

## Guard Fields

- Champion coverage status: `GREEN`
- Champion coverage report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- Parallel guard pre status: `GREEN`
- Parallel guard pre report: `build/reports/parallel-implementation-guard/AESP-013-pre.md`
- Parallel guard post status: `GREEN`
- Parallel guard post report: `build/reports/parallel-implementation-guard/AESP-013-post.md`
- Canonical owner extended: `goals_root`
- New implementation owners: `none`
- Canonical owner map changed: `no`
- Supersession ledger updated: `not needed`
- Best-code rescue checked: `yes`
- Runtime wiring gate: `preserved`
- Yellow accepted reason: `no screenshot/device/manual accessibility proof`
- Red blockers: `none`

## Repo Intelligence Fields

- Repo intelligence status: `NOT_USED`
- CodeGraph used: `no`
- Semble used: `no`
- Understand Anything used: `no`
- Advisory findings directly verified: `none`
- Accepted owner candidates: `goals_root`
- Accepted proof/wiring findings: `existing Goals projection, source, receipt, replay, and You inspection paths`
- Advisory findings rejected: `none`
- Advisory-only findings used as proof: `none`
- Generated local tool artifacts staged: `none`; wrapper artifacts exist under `.codex/xcode-summaries/AESP-013`, `.codex/xcode-logs/AESP-013`, and `.codex/xcode-results/AESP-013` but are not staged
