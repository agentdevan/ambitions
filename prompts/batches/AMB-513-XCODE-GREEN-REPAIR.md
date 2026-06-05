<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-513-XCODE-GREEN-REPAIR

## User Authorization

The user authorized broadening scope until Xcode proof is unblocked:

> Repair until fully green. I authorize broadening scope until xcode proof is unblocked

## Goal

Repair the current AMB-513 Xcode compile blockers until the repo wrapper build proof is Green.

Primary validation target:

```bash
scripts/ambitions-xcode-validate.sh --batch AMB-513-XCODE-GREEN-REPAIR --lane build-for-testing
```

## Active Authority

Start from the active truth-file hierarchy and live source evidence:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `README.md`
10. `docs/README.md`
11. `project.yml`
12. `Package.swift`
13. relevant source, tests, scripts, and current Xcode wrapper logs

## Known Starting Blockers

The previous accepted-Yellow focused repair left the wrapper build blocked outside its narrow file boundary:

- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift:617`: `cannot find 'detail' in scope`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift:629`: missing argument for parameter `primaryAction`

Repair those first, then rerun the wrapper. If the wrapper names additional compile blockers, repair only the files directly named by the fresh current wrapper logs. Continue until `build-for-testing` passes or a hard Red stop is reached.

## Allowed Scope

Allowed:

- `Native/Ambitions/PreviewSupport/**`
- `Native/Ambitions/Features/Today/**`
- `Native/AmbitionsTests/Today/TodayRealityMeridianExperienceElevationTests.swift` when named by current wrapper or focused-test logs
- `Sources/Previews/**`
- Directly related app source files named by fresh `AMB-513-XCODE-GREEN-REPAIR` Xcode wrapper compile logs
- This prompt file

Use the smallest source edit that preserves the active Today / Start here / Recommended step / Step Detail / Step Session behavior and current local-first proof posture.

## Forbidden Scope

Do not edit:

- `docs/truth/**`
- `project.yml`
- `Package.swift`
- entitlements, privacy manifests, signing, provisioning, CI, dependencies, or hosted services
- screenshot, visual, or snapshot baselines
- unrelated product surfaces not named by fresh wrapper errors

Do not add runtime dependencies, hosted AI, analytics, crash SDKs, backend SDKs, paid services, or release automation.

## Product and Proof Boundaries

Preserve active IA:

```text
Today / Goals / Time / Motion / You
Global Capture
```

Preserve locked language:

- `Start here`
- `Recommended step`
- `step`
- `Start now`
- `Open step`

Do not revive `Pulse`, `Capture` as a tab, `Plan` as a top-level destination, `Review`, `Profile`, `Calendar`, `Inbox`, or a sixth tab.

When touching Today or Step Detail code, preserve the local proof vocabulary and route behavior:

- `SourceRecord`
- `Receipt`
- `ReplayTrace`
- `You / What Ambitions knows`

No accessibility, visual, performance, device, TestFlight, App Store, privacy/legal, CI, or release readiness claim may be made unless current proof artifacts actually exist.

## Required Process

1. Capture current `git status --short --branch --untracked-files=all` and base SHA.
2. Run champion coverage before source edits.
3. Run the parallel implementation guard pre-check.
4. Repair the current Xcode compile blockers with narrow source changes.
5. Run `git diff --check`.
6. Run the parallel implementation guard post-check.
7. Run the Xcode wrapper build-for-testing lane.
8. If the wrapper fails with fresh compile blockers, inspect the current log and repeat only for files named in the fresh log.
9. After build-for-testing is Green, run the focused AMB-513 Today proof test if available:

```bash
make xcode-focused-test BATCH=AMB-513 TEST=AmbitionsTests/TodayRealityMeridianExperienceElevationTests
```

If the focused test target is missing, skipped, or blocked after build Green, report that honestly as Yellow unless the runner policy classifies it as not applicable.

## Green Criteria

Return Green only when:

- changed files are inside the authorized current-log-driven scope,
- champion coverage is Green,
- parallel implementation guard pre and post are Green,
- `git diff --check` passes,
- `scripts/ambitions-xcode-validate.sh --batch AMB-513-XCODE-GREEN-REPAIR --lane build-for-testing` passes,
- no proof, accessibility, device, release, or CI overclaim is made.

## Yellow Criteria

Return Yellow only for a non-blocking evidence gap after the build proof is unblocked or for a focused test that is unavailable/blocked after build Green.

## Red Criteria

Stop Red for:

- guard weakening,
- product truth ambiguity,
- forbidden file changes,
- required cloud/AI/backend/analytics/signing/CI/dependency changes,
- stale IA or Pulse/Capture-tab/Plan-tab revival,
- release/readiness claims without proof.

## Closeout Requirements

Report:

- files changed,
- why the change was needed,
- active truth files inspected,
- validation run with command names,
- validation not run with reasons,
- proof and claim boundaries,
- Green/Yellow/Red status,
- remaining risks or Yellow items,
- rollback command,
- branch, commit, and push state.
