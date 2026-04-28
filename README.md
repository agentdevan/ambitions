# Ambitions Native iOS App

Ambitions is a native iOS SwiftUI application.

## Source of truth

- `Native/Ambitions/` is the UI source of truth for the shipping app.
- `Sources/` contains the `AmbitionsDesignSystem` Swift package used by the native app.
- `AppUI/Sources/` contains the `AmbitionsWidgetUI` Swift package used by the native app.

## Canonical planning stack

Use [docs/codex/CONTEXT_INDEX.md](docs/codex/CONTEXT_INDEX.md) for the Codex/session read order, but start product, design, roadmap, and implementation reasoning from the completed Waves 1-19 canon-control docs:

- [SOURCE_OF_TRUTH_MAP.md](docs/canon/SOURCE_OF_TRUTH_MAP.md)
- [PRODUCT_DECISIONS.md](docs/canon/PRODUCT_DECISIONS.md)
- [GOLDEN_LAUNCH_LOOP.md](docs/canon/GOLDEN_LAUNCH_LOOP.md)
- [ROADMAP_BATCH_CLASSIFICATION.md](docs/canon/ROADMAP_BATCH_CLASSIFICATION.md)
- [HUMAN_LANGUAGE_REVIEW.md](docs/canon/HUMAN_LANGUAGE_REVIEW.md)
- [AMBITION_CANON_COMPLETION_REPORT.md](docs/canon/AMBITION_CANON_COMPLETION_REPORT.md)
- [DOCS_RECONCILIATION_REVIEW.md](docs/canon/DOCS_RECONCILIATION_REVIEW.md)
- [Canon index](docs/canon/README.md)
- [Docs index](docs/README.md)

The permanent planning docs live in [docs/canon](docs/canon). Core active docs include:

- [Ambitions_Design_Constitution.md](docs/canon/design/Ambitions_Design_Constitution.md)
- [Ambitions_2_0_Master_Plan.md](docs/canon/Ambitions_2_0_Master_Plan.md)
- [Ambitions_2_0_Product_Architecture.md](docs/canon/Ambitions_2_0_Product_Architecture.md)
- [Ambitions_2_0_Systems_Architecture.md](docs/canon/Ambitions_2_0_Systems_Architecture.md)
- [Ambitions_2_0_Visual_System.md](docs/canon/Ambitions_2_0_Visual_System.md)
- [Ambitions_2_0_Roadmap.md](docs/canon/Ambitions_2_0_Roadmap.md)
- [Ambitions_2_0_Batch_Plan.md](docs/canon/Ambitions_2_0_Batch_Plan.md)
- [Ambitions_2_0_Implementation_Gap_Audit.md](docs/canon/Ambitions_2_0_Implementation_Gap_Audit.md)
- [Ambitions_2_0_Roadmap_Merge_Audit.md](docs/canon/Ambitions_2_0_Roadmap_Merge_Audit.md)
- [IMPLEMENTATION_ACCEPTANCE_GATES.md](docs/canon/IMPLEMENTATION_ACCEPTANCE_GATES.md)

Superseded and historical docs are indexed from [docs/archive/README.md](docs/archive/README.md) or marked as historical in [docs/canon/README.md](docs/canon/README.md). Historical docs are context only and do not override the current source map, decision ledger, Golden Launch Loop, Roadmap/Batch Classification, Human Language Review, or focused canon docs.

## Native structure

- `Native/Ambitions/App`
  App entry, bootstrapper, dependency container, environment injection, root tabs.
- `Native/Ambitions/Domain`
  Native domain models for launch/session and first-pass dashboard contracts.
- `Native/Ambitions/Services`
  Startup and feature service protocols plus repository-backed implementations for the active Today / Goals / Capture / Plan / You shell. Some internal compatibility seams still use older Habits, Insights, or Profile names.
- `Native/Ambitions/Persistence`
  SwiftData-backed native persistence for goals, drafts, evidence, feedback, and app preferences.
- `Native/Ambitions/Features`
  Today, Capture, Goals, Plan, and You-facing screens. Some folder names remain compatibility-oriented until their owning delta batches rename or absorb them.
- `Native/Ambitions/UI`
  Shared shell UI like the launch gate and background canvas.
- `Native/Ambitions/PreviewSupport`
  Preview-safe bootstrap and fixture data.

## Repo boundaries

- Do not add new production UI work outside `Native/Ambitions/`, `Sources/`, or `AppUI/Sources/`.
- Do not reintroduce Expo, React Native, or TypeScript runtime files.
- Do not add top-level tabs casually. The active shell is Today / Goals / Capture / Plan / You.
- Do not treat non-Golden-Launch-Loop work as launch-critical without explicit justification.
- Do not ignore D01-D26 classifications in [ROADMAP_BATCH_CLASSIFICATION.md](docs/canon/ROADMAP_BATCH_CLASSIFICATION.md).
- Do not claim sync, export, AI, accessibility, privacy, platform behavior, or production readiness before implementation evidence exists.

## Running the native app

This repo includes an XcodeGen spec rather than a checked-in `.xcodeproj`.

On a Mac with Xcode 16+ and XcodeGen installed:

1. Run `xcodegen generate`.
2. Open `Ambitions.xcodeproj`.
3. Build and run the `Ambitions` scheme on an iOS Simulator.

The full reproducible native generation, build, test, UI test, and archive flow lives in [docs/native-build-and-release.md](docs/native-build-and-release.md).

## Docs status

Use [docs/README.md](docs/README.md) as the index for current native SwiftUI docs and active repo-truth references.
Batch control status for active work now lives in [docs/codex/BATCH_REGISTRY.md](docs/codex/BATCH_REGISTRY.md).

## Codex workflow

Shared Codex behavior starts with [docs/codex/CONTEXT_INDEX.md](docs/codex/CONTEXT_INDEX.md), then follows [docs/canon/SOURCE_OF_TRUTH_MAP.md](docs/canon/SOURCE_OF_TRUTH_MAP.md) for source-of-truth order. Windows and Mac Codex sessions should both pull the latest repo state from GitHub and use those files as standing session context; Mac sessions can start from [docs/codex/MAC_SESSION_BOOT_PROMPT.md](docs/codex/MAC_SESSION_BOOT_PROMPT.md).

## iOS native validation

GitHub Actions validates iOS-native integrity on `macos-15` in [.github/workflows/ios-validate.yml](.github/workflows/ios-validate.yml).

What the workflow verifies now:

- Installs XcodeGen and regenerates `Ambitions.xcodeproj` from `project.yml`.
- Derives the project name and primary scheme from `project.yml` and fails if generation drifts.
- Lists the generated project and resolves Swift package dependencies.
- Builds the native app target for `iphonesimulator` with signing disabled.
- Runs `AmbitionsTests` on a deterministically selected available simulator.
- Runs `AmbitionsUITests` in a separate macOS job using `build-for-testing` plus `test-without-building`.
- Runs an unsigned Release archive sanity check with `CODE_SIGNING_ALLOWED=NO`.
- Uploads `.xcresult` bundles for unit and UI test jobs.

What the workflow does not verify:

- Signed archives
- TestFlight or App Store Connect validation
- Distribution exports
- Physical-device behavior

The UI test job is honest but scoped: it validates the current preview-bootstrapped UI flow, not a signed production install path.

Local reproduction, including exact build, unit test, UI test, and archive commands, is documented in [docs/native-build-and-release.md](docs/native-build-and-release.md).

## Runtime behavior

- Appearance defaults to `System` and can be explicitly switched to Light or Dark from You.
- First-run identity is blank and neutral until the user enters personal data; preview/demo fixtures remain clearly non-production.
- The current shipped surface is local-first and on-device first.
- Today quick capture persists into the Captures tab through the native capture service.
- Notification scheduling and calendar/reminder wiring exist in the native app.
- Widget and Live Activity foundations exist in the repo, but they still need manual platform verification and should not be treated as fully verified shipped behavior from this README alone.
- Account sync is not implemented.
- The iOS target now includes a complete native app icon set and `PrivacyInfo.xcprivacy`.

## Current status

The repo is now Swift-native and XcodeGen-driven. The app boots through the native SwiftUI entry point, persists state through SwiftData, and preserves the active Today / Goals / Capture / Plan / You shell. Older internal Captures, Habits, Insights, and Profile naming remains compatibility-only where it still exists.

Product-definition Waves 1-19 are complete. The Golden Launch Loop, Roadmap/Batch Classification, and Human Language Review are active product-strength gates. Full roadmap/batch doc reconciliation, broader user-facing string cleanup, and later archive cleanup remain pending before treating the docs layer as fully clean.
