# PFC18 App Intents / Shortcuts Implementation And Tests Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Green as bounded App Intents source hardening and tests.
Date: 2026-05-06
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Owner: App Intents / External Actions / Privacy

## Purpose

Implement or repair the existing App Intents and Shortcuts surface so the
PFC17 launch contract remains bounded, privacy-safe, source-testable, and
honest about proof limits.

PFC18 does not approve new top-level destinations, hidden mutation,
destructive shortcut actions, Spotlight indexing of user life content,
entitlements, signing, project wiring, release readiness, App Store readiness,
TestFlight readiness, physical-device proof, public accessibility conformance,
legal/privacy compliance, or final privacy-label truth.

## Source Truth

Read before execution:

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

## Allowed Files

- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- focused App Intent / external action routing tests
- PFC18 prompt/report and train-state docs

## Forbidden Files

- Entitlements, signing, provisioning, project files, workflows, dependencies,
  persistence schema, sync/account/backend runtime, AI/LDI runtime, new
  top-level destinations, new Spotlight/CoreSpotlight indexing, destructive
  inline mutation, App Store Connect state, release/legal/privacy readiness
  claims, and physical-device/public accessibility claims.

## Required Acceptance

- Public App Intent launch candidates stay limited to the PFC17-approved
  route-opening and review surfaces.
- Compatibility destinations stay available only as internal route
  compatibility, not widened public launch truth.
- Text capture trims local input, queues local review through Capture, and
  does not echo private text in the success dialog.
- Mutation-capable shortcuts require in-app confirmation and receipt posture.
- App Intent deep links keep `origin=app_intent` evidence.
- Build/test evidence proves the existing App Intents metadata still compiles.
- Real Shortcuts app, Siri, Spotlight, device, and rendered accessibility proof
  remain Yellow-owned.

## Required Validation

Run:

- `git status --short`
- `git diff --check`
- focused App Intent / external-action tests
- `scripts/build-local.sh`
- relevant CQS scans `|| true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Closeout

Close Green if scoped source behavior is implemented and tested, build proof
passes, no forbidden files are touched, and remaining Shortcuts/Siri/Spotlight/
device/App Store proof is explicitly Yellow-owned.
