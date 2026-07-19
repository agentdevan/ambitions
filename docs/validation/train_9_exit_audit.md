# Train 9 Exit Audit - Time Refraction

Date: 2026-06-20

Issue: AMB-1146

Audit head: `c4e6f5fa57a23aeac7cdf8cbd49f29642ca64f72`

Train 9 ritual-evidence slice: `06cef368199efe85c75079d5815e27d135cde264`

Scope: Read-only Train 9 exit audit. No product source edits. No `docs/truth` edits. No long build.

## Decision

Train 9 exits as accepted Yellow, not Green.

The current repo has enough source, focused-test, architecture, and strict-gate evidence to stop Train 9 from absorbing generic cleanup. Time now reads from canonical owners, the strict quality gate passes at the audit head, no Swift files remain under `Native/Ambitions/Features`, Time-focused files are below the extraction-law threshold, and later Train 9 focused tests supersede earlier failures.

Green is not claimed because the audit did not find current Time screenshot proof or a current manual accessibility/visual evaluation artifact for the LifeShape Field, horizon alternatives, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, and VoiceOver semantics. The bounded follow-up is AMB-1147 only.

## Authority Read

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
- `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`
- `docs/superpowers/plans/2026-06-18-design-truth-refraction-trains-6-completion.md`

## Exit Criteria Audit

| Criterion | Status | Evidence | Remaining gap |
| --- | --- | --- | --- |
| Time reads as LifeShape Field, not calendar clone | Source evidence present | `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift`, `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldCanvas.swift`, `Native/Ambitions/Surfaces/Time/TimeObjectView.swift`, `Native/Ambitions/Projection/SurfaceLenses/TimeLens.swift`, `Native/Ambitions/Surfaces/Time/TimeSurfaceContractSnapshot.swift` | Needs current visual proof that the rendered surface actually lands as a LifeShape Field, not only source declarations. |
| Horizon alternatives accessible without gestures | Source evidence present | `LifeShapeFieldView.lifeShapeZoomControl`, `LifeShapeFieldView.horizonControl`, `LifeShapeFieldCanvas.horizonTextButton`, `TimeInteractions.chooseDay/week/month/year` | Needs screenshot/manual accessibility proof for tap targets, labels, focus order, Dynamic Type, and VoiceOver behavior. |
| Live-time behavior uses `AmbitionsClock` | Source and focused-test evidence present | `TimeSurface` loads with `featureFactory.clock`; `TimeRitualsSurface` and `WeeklyReviewScreen` use injected clock; `Native/AmbitionsTests/Time/TimeClockTests.swift` covers injected clock/day-boundary behavior and disallowed direct current-time defaults. | No new long build was run in this audit. Existing focused summaries are retained proof, not a current full regression. |
| Capture entry from Time routes through global composer only | Source evidence present | `TimeSurface.presentTimeCapture()` routes to `commandRouter.presentCommandSheet(intent: .quickCapture, source: .timeQuickCapture, presentationContext: .quickCapture)`; `TimeInteractions.openGlobalCapture`; `TimeLens.captureSupportSummary`. | Needs current end-to-end interaction proof if Train 9 Green is required. |
| Time ritual/detail behavior is Time-owned and no Habits root surface returns | Source and focused-test evidence present | `Native/Ambitions/Surfaces/Time/TimeRitualsSurface.swift`; `TimeRitualsProjectionServiceTests`; `find Native/Ambitions -path '*Habits*' -o -path '*Features*'` shows legacy directories only; `find Native/Ambitions -path '*Features*' -type f -name '*.swift'` returns zero files. | Empty legacy directories are not source ownership, but should be cleaned only under a separately scoped architecture hygiene issue if needed. |
| Top-level Plan, reflow, debug, or Habits wording absent from first-layer Time UI | Accepted for exit | Focused grep found no `debug` or `Habits` in Time paths. `Plan` hits are internal planning model names or lifecycle strings such as "Planned, not active yet". `reflow` hits are internal projection/model names and non-first-layer action state; first-layer source uses Time/LifeShape language such as `Shape Time`, `LifeShape Field`, `Review pressure`, and `Preview changes`. | AMB-1147 should visually inspect first-layer rendered strings before claiming Green. |
| Touched Train 9 production Swift files obey extraction law | Pass for audited Time files | `wc -l Native/Ambitions/Surfaces/Time/*.swift Native/Ambitions/Projection/SurfaceLenses/Time*.swift Native/Ambitions/Core/Time/*.swift Native/Ambitions/DesignSystem/ProductObjects/*LifeShape*.swift` found no audited file over 400 LOC. Largest audited files: `WeeklyReviewScreen.swift` 329, `TimeLifeShapeModels.swift` 328, `TimeSurfaceState.swift` 324. | None for this audit. |
| Strict quality gate current Green | Pass as a gate, not as train completeness | `python3 scripts/ambitions-quality-gate.py --max-per-gate 20` returned `GREEN all strict quality gates passed`. | Strict-gate Green is a global precondition only. It does not substitute for UI screenshot/accessibility proof. |
| `Features` Swift count is zero | Pass | `find Native/Ambitions -path '*Features*' -type f -name '*.swift'` returned no files. | None for Swift ownership. |
| Time screenshot/accessibility proof exists | Missing | `find .codex -path '*screenshots*' -type f | rg -i 'train9|train-9|b9|time|ritual|lifeshape'` found no Train 9 Time screenshot artifacts. Existing Train 9 xcode summary extraction directories may contain empty screenshot folders, but no retained Time screenshot proof was found. | AMB-1147 must capture and visually review current Time screenshots plus accessibility proof. |

## Focused Test Evidence Found

Later passing summaries supersede the earlier failed `HorizonCapacityPrimitiveFamilyTests` summary from `20260619T131655Z`.

- `.codex/xcode-summaries/train9-time-refraction/20260619T131528Z-AmbitionsTests-TimeProjectionServiceTests-6617-15063/focused-test-summary.json`: passed, 49 tests.
- `.codex/xcode-summaries/train9-time-refraction/20260619T131624Z-AmbitionsTests-LifeShapeFieldViewReconstructionTests-8018-5243/focused-test-summary.json`: passed, 3 tests.
- `.codex/xcode-summaries/train9-time-refraction/20260619T131655Z-AmbitionsTests-TimeClockTests-8612-10656/focused-test-summary.json`: passed, 3 tests.
- `.codex/xcode-summaries/train9-time-refraction/20260619T131912Z-AmbitionsTests-HorizonCapacityPrimitiveFamilyTests-11001-11354/focused-test-summary.json`: passed, 5 tests.
- `.codex/xcode-summaries/train-9-time-scenarios-extraction/20260619T210920Z-AmbitionsTests-TimeClockTests-2871-23413/focused-test-summary.json`: passed, 3 tests.
- `.codex/xcode-summaries/train-9-time-ritual-route/20260619T230620Z-AmbitionsTests-TimeProjectionServiceTests-3002-11742/focused-test-summary.json`: passed, 49 tests.
- `.codex/xcode-summaries/train-9-time-ritual-model-migration/20260619T232557Z-AmbitionsTests-TimeRitualsProjectionServiceTests-20322-10054/focused-test-summary.json`: passed, 3 tests.
- `.codex/xcode-summaries/train-9-progress-evidence-ritual/20260620T000706Z-AmbitionsTests-TimeRitualsProjectionServiceTests-58469-13777/focused-test-summary.json`: passed, 3 tests.

## Commands Run

```bash
git status --short --branch
git rev-parse HEAD
git log --oneline --date=short --pretty='%h %ad %s' c8fedf042..HEAD
python3 scripts/ambitions-quality-gate.py --max-per-gate 20
find Native/Ambitions -path '*Features*' -type f -name '*.swift'
find Native/Ambitions -path '*Habits*' -o -path '*Features*' | sort
wc -l Native/Ambitions/Surfaces/Time/*.swift Native/Ambitions/Projection/SurfaceLenses/Time*.swift Native/Ambitions/Core/Time/*.swift Native/Ambitions/DesignSystem/ProductObjects/*LifeShape*.swift
rg -n "Plan|reflow|debug|Habits|Capture|Motion|LifeShape|AmbitionsClock|TimeRitual" Native/Ambitions/Surfaces/Time Native/Ambitions/Projection/SurfaceLenses Native/Ambitions/Core/Time Native/Ambitions/App Native/Ambitions/Composer --glob '*.swift'
rg -n "Plan|reflow|debug|Habits" Native/Ambitions/Surfaces/Time Native/Ambitions/Projection/SurfaceLenses/Time*.swift Native/Ambitions/Core/Time
find .codex/xcode-summaries -maxdepth 3 -type f | rg 'train9|train-9|b9|Time|Ritual'
find .codex -path '*screenshots*' -type f | rg -i 'train9|train-9|b9|time|ritual|lifeshape'
jq . <focused-test-summary.json>
```

The broad `rg` command was intentionally summarized here rather than pasted as raw output. The output was noisy because it includes expected canonical terms and non-Time app/composer references; the focused Time-only grep is the decision source for first-layer Time language classification.

## Not Claimed

- No Train 9 Green claim.
- No full build or full regression claim from this audit.
- No device proof, TestFlight proof, release proof, or App Store readiness claim.
- No screenshot, VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, keyboard, or manual visual proof for current Time.
- No product source change.

## Next Issue

AMB-1147 is the exact next issue. Its scope is a bounded Train 9 Time visual/accessibility/state-coherence proof slice. It should capture current Time screenshots, visually inspect the LifeShape Field and horizon alternatives, prove accessibility behavior, and either close Train 9 Green or produce one bounded Time-specific repair. It must not become generic cleanup.

If AMB-1147 passes without source repair, the next implementation train is AMB-1148, Train 10 You Refraction.

## Rollback

This audit is docs-only. Roll back by reverting the commit that adds this ledger and its validation README link. There is no product-source rollback for AMB-1146.
