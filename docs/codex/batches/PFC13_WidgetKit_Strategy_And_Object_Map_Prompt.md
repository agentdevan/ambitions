# PFC13 WidgetKit Strategy And Object Map Prompt
<!-- markdownlint-disable MD013 -->

Status: Completed Green
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion
Batch: PFC13 WidgetKit Strategy And Object Map
Owner: Widgets / Platform / Privacy

## Purpose

PFC13 defines which Ambitions objects are allowed to appear in WidgetKit
surfaces and what each may expose. It creates a widget object map and privacy
matrix for later PFC14 implementation/repair work.

This prompt does not authorize new widget runtime behavior, new widget families,
entitlement/signing changes, project generation changes, App Store/TestFlight
claims, public accessibility claims, or release readiness claims.

## Source Truth

- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
- `docs/audits/pfc12-app-groups-shared-storage-boundary-report.md`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceContractModels.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift`
- `Native/Ambitions/Support/ExternalSurfaceVerificationChecklist.swift`
- `Native/AmbitionsWidgetExtension/NextStepWidget.swift`
- `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`

## Scope

Allowed:

- Inspect existing WidgetKit, external snapshot, app-group, routing, privacy,
  and verification files.
- Create the WidgetKit strategy and object map.
- Create the PFC13 audit report.
- Run focused existing widget projection/checklist tests.
- Update train, registry, context, current run state, and global order docs.

Forbidden:

- Do not edit production Swift.
- Do not edit widget extension source.
- Do not edit entitlements, signing, provisioning, workflows, `project.yml`, or
  generated project files.
- Do not add widget families or runtime behavior.
- Do not claim rendered widget gallery, real-device behavior, App Store
  readiness, TestFlight readiness, public accessibility conformance, or
  legal/privacy compliance.

## Required Result

- Widget object map.
- Privacy matrix.
- Widget family guidance.
- Accessibility / Reduced Motion requirements.
- Performance / battery requirements.
- PFC14 implementation boundary.

## Required Validation

- `git status --short`
- `git diff --check`
- Touched-doc trailing whitespace scan
- Focused widget tests:
  - `ExternalWidgetProjectionTests`
  - `ExternalSurfaceVerificationChecklistTests`
- CQS privacy/security claim scan on touched PFC13 docs
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Stop Conditions

Hard Red if PFC13 requires production Swift edits, entitlement/signing changes,
new widget runtime behavior, privacy/legal/release claims, rendered device proof,
external credential setup, schema/data-loss risk, or a product decision that
existing source truth cannot resolve.
