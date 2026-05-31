# AFRI-004 Legacy IA Route Retirement Proof

Status: Green
Issue: AMB-356 / AFRI-004 -- Legacy IA route retirement
Created: 2026-05-31
Baseline commit inspected before change: ff548eb70

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
- Relevant app navigation, external routing, App Intent, feature, service, preview, and test sources.

## Change Summary

- Retired active `AppTab` API cases and aliases for legacy top-level names. Active top-level tabs are now only Today, Goals, Capture, Time, and You.
- Added `LegacyIARouteCompatibility` as the bounded adapter for legacy raw strings such as `captures`, `plan`, `habits`, `profile`, and `insights`.
- Mapped legacy Habits routes into Time ritual subroutes and legacy Insights/Profile routes into You support/history routes without reintroducing hidden top-level tabs.
- Updated external route and shell command APIs to use canonical Time/You route names while preserving raw legacy payload values where compatibility requires it.
- Updated App Intent destination case names toward canonical IA while preserving legacy raw values only for compatibility decoding and stored shortcut continuity.
- Added `scripts/ambitions-legacy-ia-route-lint.py` to prevent active route API reintroduction of deprecated top-level object names.
- Updated navigation, external routing, App Intent, shell command, onboarding, memory lens, and preview tests for canonical route ownership plus explicit compatibility shims.

## Validation Run

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-356 --prompt /tmp/AMB-356-AFRI-004-guard-prompt.md`
  - Result: Green
  - Report: `build/reports/parallel-implementation-guard/AMB-356-pre.md`
- `python3 scripts/ambitions-legacy-ia-route-lint.py`
  - Result: Green
  - Output: `GREEN: active route APIs are canonical; legacy IA is adapter-bounded`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/AppShellNavigationTests -only-testing:AmbitionsTests/ExternalRoutingTests -only-testing:AmbitionsTests/AppIntentRoutingTests -only-testing:AmbitionsTests/ShellCommandRouterTests -only-testing:AmbitionsTests/MemoryLensServiceTests build-for-testing`
  - Result: `** TEST BUILD SUCCEEDED **`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/AppShellNavigationTests -only-testing:AmbitionsTests/ExternalRoutingTests -only-testing:AmbitionsTests/AppIntentRoutingTests -only-testing:AmbitionsTests/ShellCommandRouterTests -only-testing:AmbitionsTests/MemoryLensServiceTests`
  - Result: `** TEST SUCCEEDED **`
  - Tests: 85 executed, 0 failures
  - Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_10-50-52--0400.xcresult`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-356 --prompt /tmp/AMB-356-AFRI-004-guard-prompt.md --changed-from ff548eb70 ...`
  - Result: Green
  - Report: `build/reports/parallel-implementation-guard/AMB-356-post.md`
- `git diff --check`
  - Result: clean

## Proof Boundaries

- Verified: active route APIs and focused navigation/App Intent/external routing tests use canonical IA while legacy strings remain adapter-bounded.
- Not verified: full app test suite, full UI test suite, physical device behavior, signed archive, TestFlight/App Store readiness, privacy/legal approval, performance, and public accessibility proof.
- SourceRecord / Receipt / ReplayTrace boundary: this migration changes route names and compatibility adapters only; it does not create a new source ledger, receipt owner, or replay trace owner.
- Compatibility boundary: inbound legacy deep links and stored raw values remain supported only through explicit adapter paths. No product completeness or release readiness claim is made from this proof.

## Rollback Notes

- Revert the AMB-356 commit to restore the previous broader route API.
- If only compatibility behavior needs adjustment, change `LegacyIARouteCompatibility` and rerun the lint plus focused navigation/App Intent/external routing tests.
