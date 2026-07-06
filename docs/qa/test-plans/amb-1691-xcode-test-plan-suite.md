# AMB-1691 Xcode Test Plan Suite

Status: Implemented Yellow

AMB-1691 installs the named Xcode test-plan suite for smoke, runtime,
accessibility, deterministic screenshots, and release-candidate routing. This
is project, CI, and static configuration proof only; no local test execution is
claimed while build proof is intentionally skipped.

## Plans

| Plan | Scheme | Target scope | When it runs |
| --- | --- | --- | --- |
| `Native/TestPlans/Smoke.xctestplan` | `AmbitionsSmoke` | Small launch/unit and launch-URL UI smoke selectors from AMB-1812. | Manual CI dispatch for a fast route check, or local focused preflight after build proof is re-enabled. |
| `Native/TestPlans/Runtime.xctestplan` | `AmbitionsRuntime` | LocalRuntimeOS scenario, Source influence receipt, privacy/data class, app-group snapshot, export/import/reset, and runtime replay smoke selectors. | Manual CI dispatch when runtime/local-first remediation needs focused proof. |
| `Native/TestPlans/Accessibility.xctestplan` | `AmbitionsAccessibility` | Automated accessibility nutrition and flagship-surface accessibility state selectors. | Manual CI dispatch when accessibility evidence needs source-level nutrition proof. |
| `Native/TestPlans/Screenshots.xctestplan` | `AmbitionsScreenshots` | Deterministic screenshot UI lane `DeterministicScreenshotLaneUITests/testAMB1815TimeRootLightMScreenshotLane()`. | Manual CI dispatch when screenshot artifacts are needed after build proof is re-enabled. |
| `Native/TestPlans/ReleaseCandidate.xctestplan` | `AmbitionsReleaseCandidate` | Aggregate `AmbitionsTests` and `AmbitionsUITests` test targets with code coverage enabled. | Manual CI dispatch before release-candidate evidence is requested. This is not release proof until it runs and passes. |

The workflow route is `.github/workflows/ambitions-xcode-test-plans.yml`. It is
manual-dispatch only, maps each plan to its named scheme, runs
`scripts/ambitions-xcode-build-for-testing.sh`, then runs
`scripts/ambitions-xcode-test-plan.sh`, and uploads `.codex/xcode-*` artifacts.

## Proof Ceiling

- This packet proves test-plan files, XcodeGen scheme wiring, and manual CI
  routing are source-present.
- This packet does not prove any plan compiles, executes, passes, or produces
  screenshots.
- This packet does not claim CI Green, accessibility conformance, performance
  readiness, Visual Green, Release Green, device readiness, TestFlight
  readiness, App Store readiness, privacy/legal approval, or production release
  readiness.

## Closeout Validation

Static validation for AMB-1691 is recorded in
`docs/linear/reconciliation/2026-07-06-amb-1691-xcode-test-plans-parent.md` and
the paired JSON packet.
