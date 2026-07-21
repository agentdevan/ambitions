# Phase 3 Task 3 Report — Typed quick-capture runtime adapter

## Status

Implementation complete; independent review pending.

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
  after text changes or a successful save, so later identical text is not
  deduplicated.
- `SystemSurfaceBootstrap.swift` and `PreviewAppContainer.swift` compose the
  typed adapter over the existing runtime client.
- Existing shell/global-composer tests were adapted to the typed injection
  point. `FlagshipRuntimeIntentAdapterTests.swift` covers translation,
  deterministic retry identity, distinct drafts with identical text, empty
  validation, executor failure summary preservation, receipt/object/cursor
  mapping, materialization recovery, incomplete returned evidence, real
  executor exact-once expectations, and source-boundary inspection.

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
  and coherent projection cursor arrays maps to projection-ready.
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

The hosted adapter tests were authored before the app adapter/router
implementation. The monolithic `AmbitionsTests` target did not reach test
execution within bounded runs; see the proof ceiling below. The app production
target did compile successfully with the completed adapter and composition.

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
python3 scripts/ambitions-flagship-boundary-audit.py
```

Exit `0`: `Flagship boundary audit passed`.

```sh
xcodegen generate
git diff --exit-code -- Ambitions.xcodeproj
git diff --check
```

All exited `0` (`Ambitions.xcodeproj` is generated and repository-ignored).

Strict SwiftLint using `--use-script-input-files` over exactly the 13 changed
Swift files exited `0`: `0 violations, 0 serious`.

## Proof ceiling

- The first focused hosted test run on the booted iOS 26.5 simulator was
  cancelled after a 10-minute bound while the monolithic test target was still
  continuously compiling. Its xcresult recorded `errorCount: 0`, four
  unrelated existing warnings, and zero executed tests.
- A cached retry was cancelled after a three-minute bound while compiler workers
  remained active. Its xcresult recorded `errorCount: 0`, `warningCount: 0`,
  and zero executed tests. Therefore the new hosted adapter tests are source
  present but not runtime-executed proof in this task.
- A standalone `swiftc -typecheck` attempt is not evidence because the direct
  invocation lacked Xcode's XCTest Swift overlay and the test-support factory
  sources.
- No full test plan, UI run, screenshot, accessibility, physical-device,
  migration, archive, or signed build was performed.
- The meaningful-mutation/direct-write registry was not changed and is not
  claimed Green. Other intent families and other direct-write paths remain for
  later Phase 3 slices.
