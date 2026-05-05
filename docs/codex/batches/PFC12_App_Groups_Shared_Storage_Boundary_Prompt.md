# PFC12 App Groups Shared Storage Boundary Prompt
<!-- markdownlint-disable MD013 -->

Status: Completed Green
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion
Batch: PFC12 App Groups / Shared Storage Boundary
Owner: Platform / Privacy

## Purpose

PFC12 defines the App Group and shared-storage boundary for Ambitions external
surfaces. It records what the app, widget extension, Live Activity surface, App
Intents, and share extension may share through the app group, and what must stay
inside the main app.

This prompt is not approval to add new entitlements, new platform surfaces,
CloudKit, server sync, notifications, StoreKit, release claims, App Store claims,
or production feature behavior. It captures current repo evidence and test proof.

## Source Truth

- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `Native/Ambitions/Support/Ambitions.entitlements`
- `Native/AmbitionsWidgetExtension/AmbitionsWidgetExtension.entitlements`
- `Native/AmbitionsShareExtension/AmbitionsShareExtension.entitlements`
- `Native/Ambitions/ExternalSnapshots/SharedExternalSnapshotStore.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalCreationContracts.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotContracts.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceContractModels.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceVerificationChecklistTests.swift`
- `Native/AmbitionsTests/App/ExternalCreationImportServiceTests.swift`

## Scope

Allowed:

- Inspect existing entitlement, shared snapshot, external creation, widget,
  Live Activity, App Intent, and share extension files.
- Document the app group data map and privacy-safe sharing proof.
- Run focused existing tests that prove the shared container boundary.
- Update train, registry, context, and run-state docs.

Forbidden:

- Do not edit production Swift.
- Do not edit entitlements, signing, provisioning, `project.yml`, workflows, or
  generated project files.
- Do not add CloudKit, server sync, account systems, notification delivery,
  StoreKit, App Store metadata, privacy manifests, or external credentials.
- Do not claim real-device app-group I/O, widget gallery rendering, Live
  Activity lifecycle, Shortcuts/Siri invocation, TestFlight readiness, App Store
  readiness, public accessibility conformance, or legal/privacy compliance.

## Shared Storage Boundary

| Shared item | Current owner | Location | Allowed contents | Forbidden contents |
| --- | --- | --- | --- | --- |
| External surface snapshot | Main app writer; widget/Live Activity readers | `group.com.ambitions.shared/ExternalSnapshots/external-snapshot.v1.json` | Lightweight privacy-safe snapshot, stale/unavailable labels, safe route references, continuity receipt labels. | Full dashboards, every goal, raw calendar data, private details by default, heavy recompute, mutation history, legal/release claims. |
| External creation queue | Share extension writer; main app importer | `group.com.ambitions.shared/ExternalCreations/external-creations.v1.json` | User-submitted text/URL capture requests, source type, landing intent. | Silent goal upgrades, automatic placement, account/server payloads, sensitive preview expansion, destructive mutations. |
| Entitlement identifier | App, widget extension, share extension | `group.com.ambitions.shared` | Shared local container for bounded extension continuity. | Cloud sync identity, legal compliance proof, release readiness proof, or backend/shared-account claim. |

## Privacy Rules

- The app group is a local extension bridge, not a sync layer.
- External surfaces consume minimized snapshots and safe fallback routes.
- Private details stay hidden by default on external surfaces.
- Stale or unavailable state must tell the user to open Ambitions before acting.
- Mutation-capable external actions must route through the shared command
  pipeline and require receipts/confirmation where sensitive.
- The shared container must not become a separate receipt store, source of truth,
  analytics log, or hidden automation channel.

## Required Validation

- `git status --short`
- `git diff --check`
- Touched-doc trailing whitespace scan
- Focused shared-container/external-creation tests:
  - `ExternalSurfaceVerificationChecklistTests`
  - `ExternalCreationImportServiceTests`
- `scripts/cqs-privacy-security-claim-scan.sh <touched PFC12 docs> || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Stop Conditions

Hard Red if PFC12 requires entitlement/signing/provisioning changes, physical
device proof, App Store/TestFlight action, privacy/legal compliance claims,
schema/data-loss risk, sensitive external data exposure, CloudKit/server sync
implementation, or a new platform surface decision that existing source truth
does not authorize.

