# AMB-1812 Smoke Test Plan Bootstrap

Status: Implemented Yellow

AMB-1812 adds the first explicit Xcode test plan without changing the default broad `Ambitions` scheme behavior. The new `AmbitionsSmoke` scheme points at `Native/TestPlans/Smoke.xctestplan` and keeps the plan intentionally small until test execution is re-enabled.

## Plan Scope

- Plan: `Native/TestPlans/Smoke.xctestplan`
- Scheme: `AmbitionsSmoke`
- Unit smoke selector: `AppReleaseConfigurationTests/testLaunchBuildAdvertisesIPhoneOnlyPortraitOnlyScope()`
- UI smoke selector: `LaunchURLFocusedUITests/testLaunchURLCanLandOnCanonicalTimeSurface()`
- Coverage: disabled for the smoke plan.
- Parallel UI execution: disabled for the UI smoke target.

## Proof Ceiling

- This is project/test-plan configuration proof only.
- No test execution is claimed.
- No full release validation suite, CI Green, TestFlight readiness, App Store readiness, Visual Green, or Release Green is claimed.
- Runtime correctness still requires executing the plan after testing is re-enabled.

## Closeout Validation

- Test-plan execution: not run under the current user instruction authorizing issue completion without testing.
- `jq empty Native/TestPlans/Smoke.xctestplan`: passed.
- `xcodegen generate`: passed.
- `xcodegen dump --type parsed-json`: confirmed `AmbitionsSmoke.test.testPlans[0].path == Native/TestPlans/Smoke.xctestplan` and `defaultPlan == true`.
- Generated scheme inspection: `AmbitionsSmoke.xcscheme` contains a `<TestPlans>` entry referencing `container:Native/TestPlans/Smoke.xctestplan`.
- `scripts/ambitions-bounded-xcodebuild.sh --timeout 45s --kill-after 5s --log .codex/xcode-logs/AMB-1812-smoke-plan/show-test-plans.log -- xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsSmoke -showTestPlans`: timed out with `XCODEBUILD_TIMEOUT_NO_TEST_LOG=1`; no test-plan list proof is claimed.
- `python3 scripts/ambitions-remediation-governance-check.py`: GREEN.
- `python3 scripts/ambitions-quality-gate.py`: GREEN.
- `git diff --check && git diff --cached --check`: passed.
- `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s`: passed after clearing active Xcode blockers with the repo repair path.
