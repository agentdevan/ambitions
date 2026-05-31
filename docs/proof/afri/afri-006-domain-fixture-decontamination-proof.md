# AFRI-006 Domain Fixture Decontamination Proof

Status: Green
Issue: AMB-358 / AFRI-006 -- Domain fixture decontamination
Created: 2026-05-31
Baseline commit inspected before change: b72e9dcdd

## Authority Inspected

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
- Relevant LifeContext domain, engine-contract, persistence, and focused test sources.

## Change Summary

- Replaced the stale sports/outdoor LifeContext fixture personas with neutral Ambitions-native scenarios:
  - teen portfolio launch with guardian transport
  - teen portfolio launch with school access
  - creator cohort application pathway
  - maker residency application pathway
  - adult workshop launch with maker-space access
  - city workshop launch without personal equipment
- Updated deterministic life-context labels so fixture-specific wording no longer drives scenario output.
- Updated domain, engine, and persistence tests to preserve the same scenario shape with neutral fixture vocabulary.
- Added `scripts/ambitions-domain-fixture-lint.py` to prevent the retired fixture terms from returning in the bounded fixture and scenario files.
- Added an AMB-358 allowance to `docs/codex/concept-lock-registry.yml` for the adjacent domain/engine paths this fixture cleanup must touch.

## Validation Run

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-358 --prompt /tmp/AMB-358-AFRI-006-guard-prompt.md`
  - Result: Green after prompt repair
  - Report: `build/reports/parallel-implementation-guard/AMB-358-pre.md`
- `xcodegen generate`
  - Result: succeeded
- `python3 scripts/ambitions-domain-fixture-lint.py`
  - Result: Green
  - Output: `GREEN: bounded domain fixtures use neutral Ambitions-native scenario vocabulary`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/LifeContextModelsTests -only-testing:AmbitionsTests/LifeContextRuntimeEffectProofTests -only-testing:AmbitionsTests/LifeContextRepositoryTests build-for-testing`
  - Result: `** TEST BUILD SUCCEEDED **`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/LifeContextModelsTests -only-testing:AmbitionsTests/LifeContextRuntimeEffectProofTests -only-testing:AmbitionsTests/LifeContextRepositoryTests`
  - First run: Red; 3 focused assertion failures exposed stale deterministic label ordering and one old recovery phrase.
  - Repair cycle: reordered the high-school scenario milestone rule, renamed the old recovery attempt title, and reran lint.
  - Final result: `** TEST SUCCEEDED **`
  - Tests: 7 executed, 0 failures
  - Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_11-29-46--0400.xcresult`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-358 --prompt /tmp/AMB-358-AFRI-006-guard-prompt.md --changed-from b72e9dcdd ...`
  - Result: Green
  - Report: `build/reports/parallel-implementation-guard/AMB-358-post.md`
- `git diff --check`
  - Result: clean

## Proof Boundaries

- Verified: bounded LifeContext fixture vocabulary, focused deterministic scenario output, focused SwiftData LifeContext projection behavior, and the new fixture lint.
- Not verified: full app test suite, full UI test suite, physical device behavior, signed archive, TestFlight/App Store readiness, public accessibility proof, performance, privacy/legal approval, and release readiness.
- SourceRecord / Receipt / ReplayTrace boundary: this issue changes fixture data, deterministic labels, tests, and lint only. It does not create a new source ledger, receipt owner, replay owner, planning owner, or persisted user-data migration.
- Scope boundary: other domain or test files may still contain legitimate general-domain words for parsers, classifiers, or broader runtime coverage. This proof only claims the bounded fixture/scenario files covered by the lint.

## Rollback Notes

- Revert the AMB-358 commit to restore the previous fixture names, deterministic labels, tests, lint, and concept-lock allowance.
- If only vocabulary policy changes, update `scripts/ambitions-domain-fixture-lint.py` and rerun lint plus the focused LifeContext test command.
