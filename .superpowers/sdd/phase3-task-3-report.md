# Phase 3 Task 3 Report — Typed quick-capture runtime adapter

## Status

Independent-review findings addressed; re-review pending.

This slice routes only the production global-shell quick-capture mutation
through `FlagshipIntentSending`. It does not claim that other mutation families,
the complete direct-write registry, or Phase 3 are complete.

## Changed behavior and files

- `Packages/AmbitionsPresentation/.../FlagshipContracts.swift` adds typed
  quick-capture entry/source/route context, affected-object references, and
  additive receipt summary/object fields.
- `Native/Ambitions/App/FlagshipRuntimeIntentAdapter.swift` is the only code in
  this slice that translates `FlagshipIntent.quickCapture` into the legacy
  `AmbitionsCommand`/`RuntimeCommandClient` boundary.
- `Native/Ambitions/App/ShellCommandRouter.swift` now stores only an
  `FlagshipIntentSending` capability for mutation. It no longer constructs an
  `AmbitionsCommand`, stores a `CommandExecuting`, or calls an executor.
- `AppShellActivatedCaptureSeam.swift` and `CaptureViewModel.swift` own a draft
  save-attempt identity. It is stable across retry without editing and is reset
  after text changes, selected placement changes, or a successful save, so a
  changed route cannot deduplicate against the prior placement while an
  unchanged retry remains idempotent.
- `SystemSurfaceBootstrap.swift` and `PreviewAppContainer.swift` compose the
  typed adapter over the existing runtime client.
- Existing shell/global-composer tests were adapted to the typed injection
  point. `FlagshipRuntimeIntentAdapterTests.swift` covers translation,
  deterministic retry identity, distinct drafts with identical text, empty
  validation, executor failure summary preservation, receipt/object/cursor
  mapping, materialization recovery, incomplete returned evidence, real
  executor exact-once expectations, duplicate projection-cursor rejection, and
  source-boundary inspection.

The review repair additionally makes duplicate projection cursor identifiers
fail closed as catch-up-required, marks catch-up receipt proof unavailable
until runtime evidence is ready, and uses the existing generic
`Capture could not be saved.` fallback for internal source/proof failures.

No visual component, layout, styling, destination, or navigation behavior was
changed. Successful saves still use the legacy executor summary as the visible
title and open the same global Capture overlay. Empty input still returns
`Capture needs text`. Executor failures preserve the legacy result summary.

## Runtime mapping

- The legacy command ID is `shell.capture.command-<SHA256(idempotencyKey)>`.
  It is derived only from the caller-supplied save-attempt key, never from
  text/source/time.
- Source, source type, source surface, selected route/destination, private-user-
  text classification, local-only behavior, and `captureCommandPath` metadata
  are preserved.
- A successful result with returned receipt, capture identity, materialization,
  and coherent projection cursor arrays maps to projection-ready. Cursor IDs
  must also be unique; duplicates fail closed without constructing a
  `Dictionary` that can precondition-crash.
- `captureMaterialization == needs_recovery`, absent cursors, or absent returned
  receipt/capture metadata maps to committed/catch-up-required. For legacy
  `.succeeded` results with incomplete returned metadata, deterministic legacy
  receipt/capture references are derived from the command ID; the adapter never
  falsely reports rejected-before-mutation.
- Semantic undo remains false because this slice adds no typed inverse.
- Non-quick-capture intent families are explicitly rejected by this provisional
  adapter and are not used by the production shell path in this slice.

## TDD evidence

The Presentation contract test was added first and failed as expected:

```sh
swift test --package-path Packages/AmbitionsPresentation \
  --filter FlagshipContractsTests
```

Exit `1`: missing `FlagshipObjectReference`,
`FlagshipQuickCaptureContext`, receipt initializer fields, and the quick-capture
context argument. After the minimal contract implementation, the same lane
passed `5 tests, 0 failures`.

The review regressions were also run RED against the unmodified implementation:

- The duplicate-cursor test executed and crashed on
  `Dictionary(uniqueKeysWithValues:)` with `Duplicate values for key: 'today'`;
  its xcresult recorded one executed failed test.
- Four route-identity, catch-up-proof, and generic-copy tests executed with
  seven expected assertion failures: unchanged IDs across a route change,
  absent seam rotation wiring, a falsely satisfied/persisted catch-up receipt,
  and the internal proof copy.

After the minimal repair, the same regressions passed within the four complete
focused hosted suites described below.

## Final validation

```sh
swift test --package-path Packages/AmbitionsPresentation
```

Exit `0`: `5 tests, 0 failures`.

```sh
xcodebuild build -quiet \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination 'platform=iOS Simulator,id=DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6' \
  CODE_SIGNING_ALLOWED=NO
```

Exit `0` on the booted iPhone 17 Pro Max simulator with iOS 26.5.

```sh
xcodebuild build-for-testing \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination 'platform=iOS Simulator,id=DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6' \
  CODE_SIGNING_ALLOWED=NO

xcodebuild test-without-building \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination 'platform=iOS Simulator,id=DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6' \
  -only-testing:AmbitionsTests/FlagshipRuntimeIntentAdapterTests \
  -only-testing:AmbitionsTests/ShellCommandRouterTests \
  -only-testing:AmbitionsTests/GlobalComposerHardeningTests \
  -only-testing:AmbitionsTests/ShellPresentationDependencyTests
```

Both exited `0`. The final build-for-testing recorded `0 errors, 0 warnings`.
The hosted lane executed `37 tests, 0 failures`: adapter `10`, shell router
`15`, global composer `9`, and shell presentation dependencies `3`.

```sh
python3 scripts/ambitions-flagship-boundary-audit.py
```

Exit `0`: `Flagship boundary audit passed`.

```sh
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
git diff --check
```

All exited `0` (`Ambitions.xcodeproj` is generated and repository-ignored).

Strict SwiftLint using `--use-script-input-files` over exactly the seven Swift
files in the review-fix delta exited `0`: `0 violations, 0 serious`.

## Proof ceiling

- The four focused hosted suites are runtime-executed proof on an iPhone 17 Pro
  Max iOS 26.5 simulator. The build disabled code signing, and the test host
  logged expected `NOT_CODESIGNED` app-group diagnostics; the 37 selected tests
  still completed with zero failures.
- No full test plan, UI run, screenshot, accessibility, physical-device,
  migration, archive, or signed build was performed.
- The meaningful-mutation/direct-write registry was not changed and is not
  claimed Green. Other intent families and other direct-write paths remain for
  later Phase 3 slices.
