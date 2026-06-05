<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-513-PREVIEW-REPAIR - Accessibility Adaptive Interface Preview Compile Repair

## Batch Type

source-changing focused repair

## User Request

Run a focused repair batch first for:

`Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift`

This repair exists because AMB-513 accepted Yellow was blocked by rebuilt Xcode proof failing in this untouched design-system preview file.

## Required Truth Boundary

Read and obey, in order:

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

Active product canon remains `Today / Goals / Time / Motion / You` with global `Capture`.

## Failure To Repair

Current rebuilt validation fails with:

```text
Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift:129:22: error: cannot convert value of type 'any KeyPath<EnvironmentValues, Bool> & Sendable' to expected argument type 'WritableKeyPath<EnvironmentValues, Bool>'
Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift:134:22: error: value of type 'EnvironmentValues' has no member 'accessibilityContrast'
Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift:139:22: error: cannot convert value of type 'any KeyPath<EnvironmentValues, Bool> & Sendable' to expected argument type 'WritableKeyPath<EnvironmentValues, Bool>'
Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift:144:22: error: cannot convert value of type 'any KeyPath<EnvironmentValues, Bool> & Sendable' to expected argument type 'WritableKeyPath<EnvironmentValues, Bool>'
Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift:49:40: error: value of type 'AmbitionTheme.Typography' has no member 'captionStrong'
Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift:76:44: error: value of type 'AmbitionTheme.Colors' has no member 'borderPrimary'
```

## Allowed Scope

Allowed source change:

- `Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift`

Allowed prompt/process artifact:

- `prompts/batches/AMB-513-PREVIEW-REPAIR.md`

Allowed behavior:

- Replace unavailable theme member references with existing `AmbitionTheme` APIs.
- Remove or replace preview-only environment overrides that are not writable or unavailable in the current Xcode/iOS 26 SwiftUI toolchain.
- Preserve the preview gallery and its accessibility review intent.
- Keep Dynamic Type preview coverage if it compiles.
- Keep static motion preview coverage through `.transaction { transaction.disablesAnimations = true }` if it compiles.

## Forbidden Scope

Do not change:

- product truth files
- `project.yml`
- `Package.swift`
- runtime app behavior
- app features under `Native/Ambitions/`
- app tests
- theme API definitions unless there is no single-file repair
- generated project files
- visual/screenshot baselines
- privacy manifests, entitlements, signing, CI, backend, analytics, telemetry, hosted services, or dependencies

Do not introduce:

- new top-level IA
- a new design primitive owner
- a parallel theme or accessibility system
- release, accessibility, performance, device, TestFlight, App Store, privacy/legal, or CI readiness claims

## Required Implementation Strategy

1. Inspect `Sources/Theme/AmbitionTheme.swift` and nearby `Sources/Previews/*.swift` conventions.
2. Patch only `Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift`.
3. Prefer existing theme members over compatibility aliases.
4. Keep the file preview-only; no runtime behavior changes.
5. If the repair cannot stay single-file, stop and report Red instead of broadening.

## Runtime And Inspection Boundary

This batch must not modify runtime recommendation, source ledger, proof, receipt, replay, closure, recovery, step candidate, goal relevance, time planning, momentum reflow, runtime learning, personal runtime, or What Ambitions knows behavior.

If any compile repair unexpectedly touches those areas, it must preserve the existing SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows inspection path and stop for review before broadening.

## Validation Commands

Run at minimum:

```bash
git diff --check
bash -n scripts/ambitions-codex-train.sh
jq empty docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
python3 scripts/ambitions-champion-coverage-check.py --batch AMB-513-PREVIEW-REPAIR
python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-513-PREVIEW-REPAIR --prompt prompts/batches/AMB-513-PREVIEW-REPAIR.md --batch-type source-changing
scripts/ambitions-xcode-validate.sh --batch AMB-513-PREVIEW-REPAIR --lane build-for-testing
```

After changes:

```bash
python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-513-PREVIEW-REPAIR --prompt prompts/batches/AMB-513-PREVIEW-REPAIR.md --changed-from <BASE_SHA> --batch-type source-changing
```

If the repaired build-for-testing passes, rerun the AMB-513 focused proof path:

```bash
make xcode-focused-test BATCH=AMB-513 TEST=AmbitionsTests/TodayRealityMeridianExperienceElevationTests
```

## Green Criteria

Green only if:

- the repair stays inside the allowed file boundary,
- champion coverage and parallel guard pre/post are Green,
- `scripts/ambitions-xcode-validate.sh --batch AMB-513-PREVIEW-REPAIR --lane build-for-testing` passes or fails only on a newly discovered unrelated blocker with accepted Yellow,
- no product, release, accessibility, device, performance, privacy/legal, TestFlight, App Store, or CI claim is made without proof,
- the final report includes proof boundaries and rollback.

## Yellow Criteria

Yellow is acceptable if:

- the single-file repair is correct and guards pass,
- but broader Xcode proof is blocked by a separate unrelated compile/test issue outside this repair scope.

## Red Criteria

Return Red and stop if:

- fixing the blocker requires modifying files outside the allowed source file,
- the patch changes product behavior,
- a guard reports blocked concept violations,
- the repair would require changing product truth, project configuration, theme owner APIs, dependencies, privacy/security, signing, CI, or app runtime behavior.

## Final Report Requirements

Include:

- files changed
- why the change was needed
- truth files inspected
- validation run and result
- validation not run and reason
- proof/claim boundaries
- risks or Yellow items
- rollback command
- next eligible Codex command
