# PFC18 App Intents / Shortcuts Implementation And Tests Report
<!-- markdownlint-disable MD013 -->

Result: Green
Date: 2026-05-06
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Batch: PFC18 App Intents / Shortcuts Implementation And Tests
Owner: App Intents / External Actions / Privacy

## Summary

PFC18 hardened the existing App Intents and Shortcuts source contract without
adding new destinations, entitlements, signing, project changes, dependencies,
persistence/schema changes, sync/account/backend behavior, Spotlight indexing,
hidden mutation, or release claims. Public launch candidates are now
source-testable against the PFC17-approved surface, text capture has a pure
local-review request builder, and mutation-capable shortcuts remain bound to
in-app confirmation plus receipt posture.

## Files Read

- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/canon/Ambitions_App_Intents_Shortcuts_Spotlight_Strategy.md`
- `docs/audits/pfc17-app-intents-shortcuts-spotlight-strategy-report.md`
- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- `Native/Ambitions/App/AppIntentLaunchRouter.swift`
- `Native/Ambitions/Services/ExternalActionCommandService.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalCreationContracts.swift`
- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`
- `Native/AmbitionsTests/App/ExternalActionCommandServiceTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceActionPayloadTests.swift`

## Files Changed

- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`
- `docs/codex/batches/PFC18_App_Intents_Shortcuts_Implementation_And_Tests_Prompt.md`
- `docs/audits/pfc18-app-intents-shortcuts-implementation-tests-report.md`
- train-state, registry, context, dependency, and global-order docs

No entitlement, signing, project, workflow, dependency, privacy manifest,
persistence schema, sync/account, backend, AI/LDI runtime, App Store Connect,
or release file changed.

## Implementation

- `AmbitionsAppShortcutDestination` now exposes a pure
  `isPFC18PublicLaunchCandidate` boundary so public launch truth is testable
  without widening internal compatibility routes.
- PFC17-approved public candidates are limited to Today, Plan, Capture, Add
  Something, What Ambitions Knows, Start Here, Close Loop, and Make Doable.
- Compatibility destinations for legacy quick capture, recovery, focus, and
  plan patch routing remain excluded from public launch truth.
- `CreateAmbitionsCaptureIntent` now builds its external creation request
  through a pure helper that trims local text, preserves `appIntent` source,
  routes to Capture review, and rejects empty input.
- Focused tests cover public candidate boundaries, local capture-review request
  construction without private dialog echo, and mutation-capable shortcut
  confirmation/receipt posture.

## Tests Run

- `git status --short`
- `git diff --check`
- `xcodebuild test -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AppIntentRoutingTests -only-testing:AmbitionsTests/ExternalActionCommandServiceTests -only-testing:AmbitionsTests/ExternalSurfaceActionPayloadTests`
- `scripts/build-local.sh`
- PFC18-targeted CQS scans
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Result

- Green.
- `git diff --check` passed.
- Focused Xcode tests passed: `AppIntentRoutingTests`,
  `ExternalActionCommandServiceTests`, and `ExternalSurfaceActionPayloadTests`
  executed 25 tests with 0 failures. Result bundle:
  `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.06_11-10-12--0400.xcresult`.
- `scripts/build-local.sh` passed and generated
  `output/logs/build-local-20260506-111813.log`; the build compiled and
  validated the app, widget extension, share extension, and App Intents
  metadata extraction.
- PFC18-targeted CQS privacy/security claim scans reported
  `CQS_PRIVACY_SECURITY_CLAIM_HITS=0` for the App Intents source file,
  focused test file, prompt, and report.
- `scripts/cqs-accessibility-motion-scan.sh || true` reported existing broad
  advisory hits across `Native/Ambitions`. PFC18 adds no UI renderer and keeps
  manual VoiceOver, Dynamic Type, Reduce Motion, contrast, truncation, and real
  Shortcuts/Siri proof Yellow-owned.
- `scripts/cqs-performance-budget-scan.sh || true` reported existing broad
  advisory hits. PFC18 adds a pure request builder and public-candidate
  classifier only; it adds no background loop, indexing job, network work, or
  high-frequency update path.
- `scripts/run-doc-qa.sh || true` completed with advisory stale-guidance,
  deprecated-language, markdownlint backlog, and lychee 0 errors / 1 redirect.
  Logs:
  `docs/audits/doc-qa/20260506-111835-stale-guidance.log`,
  `docs/audits/doc-qa/20260506-111835-deprecated-language.log`,
  `docs/audits/doc-qa/20260506-111835-markdownlint.log`, and
  `docs/audits/doc-qa/20260506-111835-lychee.log`.
- `scripts/batch-train-gate-check.sh || true` completed with the expected
  working-tree Yellow hint before commit.

## Repairs Attempted

- Repaired App Intent public-surface proof so compatibility routes cannot drift
  into public launch truth without an explicit proof batch.
- Added a pure local capture-request builder so capture text trimming,
  empty-input rejection, and Capture-review routing are testable without
  invoking the App Intents runtime.

## Remaining Yellow Items

- Real Shortcuts app visibility and Siri invocation remain unproven.
- Spotlight/CoreSpotlight user-life-content indexing remains not approved by
  default and unimplemented.
- Physical-device App Intent invocation remains unproven.
- Manual VoiceOver, Dynamic Type, Reduce Motion, contrast, and truncation review
  remain human/operator proof.
- App Store/TestFlight/release readiness, legal/privacy compliance, final
  privacy-label truth, and public accessibility conformance remain blocked.

## Red Classification

No Red. New top-level destinations, hidden mutation, destructive inline
shortcuts, user-life-content Spotlight indexing, entitlement/signing/project
changes, sensitive text exposure in shortcut dialogs, unsupported release
claims, or device proof claims without evidence would be Hard Red.

## Rollback Path

Revert the PFC18 commit to restore the prior App Intent destination and capture
request behavior and remove PFC18 prompt/report/train-state updates. No
entitlement, signing, project, workflow, dependency, schema, or generated
rollback is needed.

## Next Eligible Batch

PFC20 Notifications / Calendar / Reminders Implementation Proof.
