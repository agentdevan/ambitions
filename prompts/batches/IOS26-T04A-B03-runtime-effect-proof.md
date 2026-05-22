<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04A-B03 - Runtime effect proof

## Batch type
Private Life Runtime integration and deterministic proof

## Objective
Prove Life Context changes actual Private Life Runtime output, not only UI copy or static reports.

## Why this exists
The moat is reality-aware execution: the same goal should produce different inspectable daily plans for different user-owned life contexts.

## Dependencies
IOS26-T04A-B01 and IOS26-T04A-B02.

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
Life Context domain/repository/projection; Goal intent compiler; recommendation candidate generation; feasibility scoring; capacity planning; travel/time-fit estimation; opportunity-aware step generation; recovery planning; Today Start Here explanation inputs; Time/LifeShape capacity proof where safe; runtime tests.

## Exact changes allowed
Runtime/domain/compiler integration, deterministic fixtures/tests, Today/Time explanation input adapters only where required, receipt/replay proof needed for runtime-difference scenarios, and `build/reports/life-context/runtime-effect-proof.md`.

## Exact changes forbidden
No fake UI-only proof. No stereotype language. No external AI, hosted backend, analytics SDK, or tracking dependency. No sensitive-detail exposure beyond the visible reason needed. No broad UI recomposition.

## Implementation steps
1. Inspect Life Context projection, compiler, recommendation, capacity, recovery, Today explanation, and replay seams.
2. Wire LifeContextRuntimeProjection into runtime decision inputs using typed fields, not fragile string-only logic.
3. Add deterministic fixture scenarios A through E.
4. Assert actual output differences in compiler/recommendation/Start Here outputs.
5. Add replay/receipt proof for paused/deleted context changing output.
6. Write `build/reports/life-context/runtime-effect-proof.md`.

## Wire LifeContextRuntimeProjection into
- Goal intent compiler
- recommendation candidate generation
- feasibility scoring
- capacity planning
- travel/time-fit estimation
- opportunity-aware step generation
- recovery planning
- Today Start Here explanation inputs
- Time/LifeShape capacity proof where safe

## Required deterministic proof scenarios
Scenario A:
Same goal: "Make varsity football."
User 1: age 14, freshman, 4-year runway, YMCA, parent rides 3 days/week.
User 2: age 16, junior, 1-year runway, school weight room, limited offseason.
Expected:
- Different milestones
- Different urgency
- Different weekly cadence
- Different Start Here step
- Different explanation

Scenario B:
Same goal: "Play professional basketball."
User 1: woman, high school player, WNBA pathway relevant.
User 2: male pathway context.
Expected:
- Different pathway labels where relevant
- Different exposure/recruiting assumptions
- No stereotype language
- Eligibility/pathway reason appears in explanation

Scenario C:
Same goal: "Start mountain biking weekly."
User 1: small town, trail 15 minutes away, has bike.
User 2: city, no nearby trails, no bike, travel radius 20 minutes.
Expected:
- User 1 gets ride/trail step.
- User 2 gets equipment/location discovery or indoor conditioning step.
- Travel feasibility changes plan.

Scenario D:
Same goal with historical context:
User has prior failed attempt, injury limitation, and older context marked May Need Review.
Expected:
- Plan is more conservative.
- Recovery/confirmation appears.
- Older context is not treated as current fact without review.

Scenario E:
Deleted/paused context:
A fact previously affected recommendations, then user pauses it.
Expected:
- Runtime output changes.
- Receipt records the change.
- Replay explains difference.

## Tests to add/update
- Deterministic tests assert actual plan/recommendation differences.
- Missing context does not crash and degrades gracefully.
- Deleted/paused context is excluded.
- Source/freshness appears in proof.
- Explanations include why context mattered without exposing sensitive details unnecessarily.

## Commands to run
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B03 TEST=AmbitionsTests
git diff --check
```

## Required proof artifacts
build/reports/life-context/runtime-effect-proof.md

## Accessibility requirements
Classify accessibility as source support unless UI explanation surfaces are touched. If UI is touched, preserve VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, and non-color-only state.

## Privacy/local-first requirements
No required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or hidden sensitive assumptions. Sensitive context must be visible, editable, deletable, and purpose-limited.

## iOS 26 API verification requirements
No new iOS 26 API adoption is required for runtime proof. If touched UI adapters use new APIs, record current source proof and non-claims in the proof artifact.

## Green / Yellow / Red closeout rules
Green: deterministic tests pass, context changes output, missing context does not crash, deleted/paused context excluded, source/freshness appears in proof.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: fake UI-only proof, stereotype language, hidden sensitive use, external AI/backend dependency, release overclaim, or missing truth-file read.

## Rollback strategy
Revert only files touched by this batch. Preserve unrelated dirty work.

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
Claims allowed:
Claims forbidden:
Release blockers:
Post-batch gates:
Rollback:
Next eligible batch:
```
